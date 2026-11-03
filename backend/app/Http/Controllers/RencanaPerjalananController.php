<?php

namespace App\Http\Controllers;

use App\Models\DetailItinerary;
use App\Models\HariPerjalanan;
use App\Models\ItemPerjalanan;
use App\Models\Kategori;
use App\Models\Kecamatan;
use App\Models\PreferensiPerjalanan;
use App\Models\RencanaPerjalanan;
use App\Models\Restoran;
use App\Models\Wisata;
use App\Services\GeminiService;
use Carbon\Carbon;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Log;


class RencanaPerjalananController extends Controller
{
    // Daftar riwayat rencana perjalanan
    public function index(Request $request)
    {
        $user = auth('sanctum')->user() ?? $request->user();
        $userId = $user?->id_pengguna;

        if (!$userId) {
            return response()->json([
                'success' => true,
                'message' => 'Daftar riwayat rencana perjalanan berhasil diambil',
                'data' => [],
            ]);
        }

        $query = RencanaPerjalanan::with([
            'preferensi.kategoris',
            'hariPerjalanan.itemPerjalanan',
            'detailItineraries',
        ])
            ->where('id_pengguna', $userId)
            ->orderBy('created_at', 'desc');

        $plans = $query->get();

        return response()->json([
            'success' => true,
            'message' => 'Daftar riwayat rencana perjalanan berhasil diambil',
            'data' => $plans,
        ]);
    }

    // Detail rencana perjalanan
    public function show($id)
    {
        $plan = RencanaPerjalanan::with([
            'preferensi.kategoris',
            'hariPerjalanan.itemPerjalanan.destinasi',
            'detailItineraries.wisata.fotoDestinasis',
            'detailItineraries.restoran',
        ])->find($id);

        if (!$plan) {
            return response()->json([
                'success' => false,
                'message' => 'Rencana perjalanan tidak ditemukan',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Detail rencana perjalanan berhasil dimuat',
            'data' => $plan,
        ]);
    }

    // Buat rencana perjalanan baru

    public function store(Request $request, GeminiService $geminiService)
    {
        // 1. Validasi request
        $validated = $request->validate([
            'nama_rencana' => 'required|string|max:255',
            'hari_start' => 'nullable|date',
            'hari_end' => 'nullable|date',
            'tanggal_mulai' => 'nullable|date',
            'tanggal_selesai' => 'nullable|date',
            'titik_awal' => 'nullable|string|max:255',
            'budget_trip' => 'nullable|numeric|min:0',
            'total_anggaran' => 'nullable|numeric|min:0',
            'type_food' => 'nullable|string|max:50',
            'start_time' => 'nullable|string',
            'end_time' => 'nullable|string',
            'kategori_minat' => 'nullable|array',
            'kecamatan_pilihan' => 'nullable|array',
            'is_halal' => 'nullable|boolean',
            'is_seafood' => 'nullable|boolean',
            'custom_destinations' => 'nullable|array',
        ]);

        // 2. Persiapan tanggal perjalanan
        $startDateStr = $validated['hari_start']
            ?? $validated['tanggal_mulai']
            ?? now()->toDateString();

        $endDateStr = $validated['hari_end']
            ?? $validated['tanggal_selesai']
            ?? $startDateStr;

        $start = Carbon::parse($startDateStr);
        $end = Carbon::parse($endDateStr);

        if ($end->lt($start)) {
            $end = $start->copy();
        }

        $totalDays = max(1, $start->diffInDays($end) + 1);

        // 3. Persiapan preferensi
        $budget = $validated['budget_trip']
            ?? $validated['total_anggaran']
            ?? null;

        $typeFood = $validated['type_food']
            ?? (($validated['is_halal'] ?? false) ? 'Halal' : 'Semua');

        $startTime = $validated['start_time'] ?? '08:30';
        $endTime = $validated['end_time'] ?? '21:00';

        $titikAwal = $validated['titik_awal']
            ?? 'Pelabuhan Ferry Batam Center';

        $selectedAreas = $validated['kecamatan_pilihan']
            ?? ['Batam Kota', 'Lubuk Baja'];

        $selectedThemes = $validated['kategori_minat'] ?? [];

        // 4. Tentukan preferensi makanan
        $isHalal = strtolower($typeFood) === 'halal'
            || ($validated['is_halal'] ?? false);

        $isSeafood = ($validated['is_seafood'] ?? false)
            || str_contains(strtolower($typeFood), 'seafood');

        // 5. Ambil user
        $user = auth('sanctum')->user() ?? $request->user();

        $userId = $user?->id_pengguna;

        Log::info('Request pembuatan rencana perjalanan', [
            'user_id' => $userId,
            'nama_rencana' => $validated['nama_rencana'],
            'total_days' => $totalDays,
            'budget' => $budget,
        ]);

        // 6. Mulai transaksi database
        DB::beginTransaction();

        try {
            // 7. Nonaktifkan rencana sebelumnya
            if ($userId) {
                RencanaPerjalanan::where('id_pengguna', $userId)
                    ->where('status', 'aktif')
                    ->update([
                        'status' => 'selesai',
                    ]);
            }

            // 8. Simpan preferensi perjalanan
            $preferensi = PreferensiPerjalanan::create([
                'id_pengguna' => $userId,
                'type_food' => $typeFood,
                'maks_budget_trip' => $budget,
                'kecamatan_pilihan' => $selectedAreas,
            ]);

            Log::info('Preferensi perjalanan berhasil dibuat', [
                'id_preferensi' => $preferensi->id_preferensi,
            ]);

            // 9. Simpan relasi kategori minat
            if (!empty($selectedThemes)) {
                $categoryIds = [];

                foreach ($selectedThemes as $cat) {
                    if (is_numeric($cat)) {
                        $categoryIds[] = (int) $cat;
                    } else {
                        $katRecord = Kategori::where(
                            'nama_kategori',
                            $cat
                        )->first();

                        if ($katRecord) {
                            $categoryIds[] = $katRecord->id_kategori;
                        }
                    }
                }

                if (!empty($categoryIds)) {
                    $preferensi->kategoris()->sync(
                        array_unique($categoryIds)
                    );
                }
            }

            // 10. Simpan rencana perjalanan
            $plan = RencanaPerjalanan::create([
                'id_pengguna' => $userId,
                'id_preferensi' => $preferensi->id_preferensi,
                'nama_rencana' => $validated['nama_rencana'],
                'hari_start' => $start->toDateString(),
                'hari_end' => $end->toDateString(),
                'total_hari' => $totalDays,
                'titik_awal' => $titikAwal,
                'budget_trip' => $budget,
                'type_food' => $typeFood,
                'start_time' => $startTime,
                'end_time' => $endTime,
                'status' => 'aktif',
            ]);

            Log::info('Rencana perjalanan berhasil dibuat', [
                'id_rencana' => $plan->id_rencana,
            ]);

            // 11. Generate itinerary menggunakan Gemini
            $this->generateRecommendationItinerary(
                $plan,
                $totalDays,
                $titikAwal,
                $selectedAreas,
                $selectedThemes,
                $geminiService,
                $isHalal,
                $isSeafood,
                $startTime,
                $endTime
            );

            // 12. Ambil hasil itinerary dari database
            $fullPlan = RencanaPerjalanan::with([
                'preferensi.kategoris',
                'hariPerjalanan.itemPerjalanan',
                'detailItineraries',
            ])->findOrFail($plan->id_rencana);

            // 13. Commit seluruh penyimpanan
            DB::commit();

            Log::info('Seluruh rencana perjalanan berhasil disimpan', [
                'id_rencana' => $plan->id_rencana,
            ]);

            // 14. Kirim response ke Flutter
            return response()->json([
                'success' => true,
                'message' => 'Rencana perjalanan dan itinerary AI berhasil dibuat.',
                'data' => $fullPlan,
            ], 201);

        } catch (\Throwable $e) {
            // Batalkan seluruh transaksi jika terjadi error
            DB::rollBack();

            Log::error('Gagal membuat rencana perjalanan', [
                'error' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
                'user_id' => $userId,
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Gagal membuat rencana perjalanan: '
                    . $e->getMessage(),
            ], 500);
        }
    }

    // Hapus rencana perjalanan

    private function generateRecommendationItinerary(
        RencanaPerjalanan $plan,
        int $totalDays,
        string $startLocation,
        array $selectedAreas,
        array $selectedThemes,
        GeminiService $geminiService,
        bool $isHalal = false,
        bool $isSeafood = false,
        string $defaultStartTime = '08:30',
        string $defaultEndTime = '21:00'
    ) {
        // 1. Ambil ID kecamatan berdasarkan area pilihan
        $kecamatanIds = Kecamatan::whereIn('nama_kecamatan', $selectedAreas)
            ->pluck('id_kecamatan')
            ->toArray();

        Log::info('Kecamatan pilihan itinerary', [
            'selected_areas' => $selectedAreas,
            'kecamatan_ids' => $kecamatanIds,
        ]);

        // 2. Ambil kandidat wisata
        $wisataQuery = Wisata::with(['kategoris', 'kecamatan']);

        if (!empty($kecamatanIds)) {
            $wisataQuery->whereIn('id_kecamatan', $kecamatanIds);
        }

        $availableWisata = $wisataQuery->take(15)->get();

        // 3. Ambil kandidat restoran
        $restoranQuery = Restoran::with('kecamatan');

        if (!empty($kecamatanIds)) {
            $restoranQuery->whereIn('id_kecamatan', $kecamatanIds);
        }

        // Filter halal
        if ($isHalal) {
            $restoranQuery->where('type_food', 'Halal');
        }

        // Filter seafood
        if ($isSeafood) {
            $restoranQuery->where(function ($query) {
                $query->where('nama', 'like', '%seafood%')
                    ->orWhere('nama', 'like', '%kelong%');
            });
        }

        $availableRestoran = $restoranQuery->take(10)->get();

        Log::info('Kandidat destinasi ditemukan', [
            'total_wisata' => $availableWisata->count(),
            'total_restoran' => $availableRestoran->count(),
            'is_halal' => $isHalal,
            'is_seafood' => $isSeafood,
        ]);

        // 4. Validasi kandidat
        if ($availableWisata->isEmpty()) {
            throw new \Exception(
                'Tidak ditemukan destinasi wisata yang sesuai.'
            );
        }

        if ($availableRestoran->isEmpty()) {
            throw new \Exception(
                $isHalal
                ? 'Tidak ditemukan restoran halal sesuai preferensi.'
                : 'Tidak ditemukan restoran yang sesuai.'
            );
        }

        // 5. Siapkan data destinasi untuk Gemini
        $destinations = [];

        foreach ($availableWisata as $item) {
            $destinations[] = [
                'destination_id' => $item->id_wisata,
                'name' => $item->nama,
                'type' => 'wisata',
                'description' => $item->deskripsi,
                'price' => $item->harga_tiket,
                'area' => $item->kecamatan->nama_kecamatan ?? null,
            ];
        }

        foreach ($availableRestoran as $item) {
            $destinations[] = [
                'destination_id' => $item->id_restoran,
                'name' => $item->nama,
                'type' => 'restoran',
                'description' => $item->deskripsi,
                'food_type' => $item->type_food,
                'price' => $item->harga_per_orang ?? null,
                'area' => $item->kecamatan->nama_kecamatan ?? null,
            ];
        }

        // 6. Siapkan data untuk Gemini
        $data = [
            'total_days' => $totalDays,
            'start_location' => $startLocation,
            'selected_areas' => $selectedAreas,
            'selected_themes' => $selectedThemes,
            'is_halal' => $isHalal,
            'is_seafood' => $isSeafood,
            'start_time' => $defaultStartTime,
            'end_time' => $defaultEndTime,
            'destinations' => $destinations,
        ];

        // 7. Panggil Gemini
        Log::info('Memulai generate itinerary Gemini', [
            'id_rencana' => $plan->id_rencana,
            'total_days' => $totalDays,
        ]);

        $result = $geminiService->generateItinerary($data);

        Log::info('Hasil rekomendasi Gemini', [
            'result' => $result,
        ]);

        // 8. Validasi hasil Gemini
        if (
            !isset($result['itinerary']) ||
            !is_array($result['itinerary'])
        ) {
            throw new \Exception(
                'Format hasil itinerary dari Gemini tidak valid.'
            );
        }

        $itinerary = $result['itinerary'];

        if (count($itinerary) !== $totalDays) {
            throw new \Exception(
                'Jumlah hari itinerary dari Gemini tidak sesuai.'
            );
        }

        $daysByNumber = [];

        foreach ($itinerary as $day) {
            $dayNumber = $day['day'] ?? null;

            if (
                !is_numeric($dayNumber) ||
                $dayNumber < 1 ||
                $dayNumber > $totalDays ||
                isset($daysByNumber[$dayNumber])
            ) {
                throw new \Exception(
                    'Urutan hari dari Gemini tidak valid.'
                );
            }

            $daysByNumber[$dayNumber] = $day;
        }

        // Pastikan semua hari tersedia
        for ($dayNumber = 1; $dayNumber <= $totalDays; $dayNumber++) {
            if (!isset($daysByNumber[$dayNumber])) {
                throw new \Exception(
                    'Data hari itinerary tidak lengkap.'
                );
            }
        }

        // 9. Simpan itinerary ke database
        // Tidak menggunakan DB::transaction() lagi.
        // Transaksi sudah dikendalikan oleh method store().

        $startDate = Carbon::parse($plan->hari_start ?? now());

        for ($dayNumber = 1; $dayNumber <= $totalDays; $dayNumber++) {
            $day = $daysByNumber[$dayNumber];

            // Simpan hari perjalanan
            $hari = HariPerjalanan::create([
                'id_rencana' => $plan->id_rencana,
                'tanggal' => $startDate->copy()->addDays($dayNumber - 1),
                'urutan_hari' => $dayNumber,
                'lokasi_awal' => $startLocation,
                'lokasi_akhir' => $startLocation,
                'estimasi_biaya' => 0,
            ]);

            Log::info('Hari perjalanan berhasil dibuat', [
                'id_hari' => $hari->id_hari,
                'urutan_hari' => $dayNumber,
            ]);

            // Simpan item perjalanan
            foreach (($day['items'] ?? []) as $index => $item) {
                $destinationId = $item['destination_id'] ?? null;
                $type = $item['type'] ?? null;
                $startTime = $item['start_time'] ?? null;
                $endTime = $item['end_time'] ?? null;

                // Validasi kelengkapan item
                if (!$destinationId || !$startTime || !$endTime) {
                    throw new \Exception(
                        'Data item itinerary tidak lengkap.'
                    );
                }

                // Validasi tipe destinasi
                if (!in_array($type, ['wisata', 'restoran'], true)) {
                    throw new \Exception(
                        'Tipe destinasi dari Gemini tidak valid.'
                    );
                }

                // Validasi format waktu
                if (
                    !preg_match('/^(?:[01]\d|2[0-3]):[0-5]\d$/', $startTime) ||
                    !preg_match('/^(?:[01]\d|2[0-3]):[0-5]\d$/', $endTime) ||
                    $startTime >= $endTime
                ) {
                    throw new \Exception(
                        'Waktu itinerary tidak valid.'
                    );
                }

                // Validasi destinasi berdasarkan tipe
                if ($type === 'wisata') {
                    $destination = $availableWisata->firstWhere(
                        'id_wisata',
                        $destinationId
                    );

                    $destinationType = Wisata::class;
                } else {
                    $destination = $availableRestoran->firstWhere(
                        'id_restoran',
                        $destinationId
                    );

                    $destinationType = Restoran::class;
                }

                if (!$destination) {
                    throw new \Exception(
                        'Gemini memberikan destinasi yang tidak tersedia.'
                    );
                }

                // Simpan item itinerary
                $itemPerjalanan = ItemPerjalanan::create([
                    'id_hari' => $hari->id_hari,
                    'destinasi_type' => $destinationType,
                    'destinasi_id' => $destinationId,
                    'urutan_item' => $index + 1,

                    // Sesuaikan dengan nama kolom migration
                    'depature_time' => $startTime,
                    'arrival_time' => $endTime,
                ]);

                Log::info('Item perjalanan berhasil dibuat', [
                    'id_item' => $itemPerjalanan->id_item,
                    'id_hari' => $hari->id_hari,
                    'destination_id' => $destinationId,
                    'type' => $type,
                ]);
            }
        }

        Log::info('Generate itinerary berhasil', [
            'id_rencana' => $plan->id_rencana,
        ]);

        return true;
    }

    // Aktifkan rencana perjalanan
    public function setActive(Request $request, $id)
    {
        $user = auth('sanctum')->user() ?? $request->user();
        $userId = $user?->id_pengguna;

        if (!$userId) {
            return response()->json([
                'success' => false,
                'message' => 'Silakan login terlebih dahulu',
            ], 401);
        }

        RencanaPerjalanan::where('id_pengguna', $userId)->update(['status' => 'selesai']);
        $plan = RencanaPerjalanan::where('id_pengguna', $userId)->find($id);

        if (!$plan) {
            return response()->json([
                'success' => false,
                'message' => 'Rencana perjalanan tidak ditemukan',
            ], 404);
        }

        $plan->update(['status' => 'aktif']);

        return response()->json([
            'success' => true,
            'message' => 'Rencana perjalanan berhasil diaktifkan',
            'data' => $plan,
        ]);
    }
}