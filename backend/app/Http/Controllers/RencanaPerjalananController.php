<?php

namespace App\Http\Controllers;

use App\Models\HariPerjalanan;
use App\Models\ItemPerjalanan;
use App\Models\Kategori;
use App\Models\Kecamatan;
use App\Models\LokasiTransportasi;
use App\Models\Penginapan;
use App\Models\PreferensiPerjalanan;
use App\Models\RencanaPerjalanan;
use App\Models\Restoran;
use App\Models\Wisata;
use App\Services\GeminiService;
use App\Services\GroqService;
use App\Services\OpenRouterService;
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
            'preferensi.kecamatans',
            'hariPerjalanan.lokasiAwalLocation',
            'hariPerjalanan.lokasiAkhirLocation',
            'hariPerjalanan.itemPerjalanan',
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
            'preferensi.kecamatans',
            'hariPerjalanan.lokasiAwalLocation',
            'hariPerjalanan.lokasiAkhirLocation',
            'hariPerjalanan.itemPerjalanan.destinasi',
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

    public function store(Request $request, GeminiService $geminiService, OpenRouterService $openRouterService, GroqService $groqService)
    {
        // 1. Validasi request
        $validated = $request->validate([
            'nama_rencana' => 'required|string|max:255',
            'hari_start' => 'nullable|date',
            'hari_end' => 'nullable|date',
            'tanggal_mulai' => 'nullable|date',
            'tanggal_selesai' => 'nullable|date',
            'titik_awal' => 'nullable|string|max:255',
            'titik_awal_id' => 'nullable|string|max:36',
            'titik_awal_type' => 'nullable|string|max:255',
            'titik_akhir' => 'nullable|string|max:255',
            'titik_akhir_id' => 'nullable|string|max:36',
            'titik_akhir_type' => 'nullable|string|max:255',
            'budget_trip' => 'nullable|numeric|min:0',
            'total_anggaran' => 'nullable|numeric|min:0',
            'type_food' => 'nullable|string|max:50',
            'start_time' => 'nullable|string',
            'end_time' => 'nullable|string',
            'kategori_minat' => 'nullable|array',
            'kecamatan_pilihan' => 'nullable|array',
            'is_halal' => 'nullable|boolean',
            'is_seafood' => 'nullable|boolean',
            'is_draft' => 'nullable|boolean',
            'mode' => 'nullable|string',
            'status' => 'nullable|string',
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

        // Resolve Titik Awal
        $titikAwalName = $validated['titik_awal'] ?? null;
        $titikAwalId = $validated['titik_awal_id'] ?? null;
        $titikAwalType = $validated['titik_awal_type'] ?? null;

        if ($titikAwalId) {
            if (!$titikAwalType) {
                if ($trans = LokasiTransportasi::find($titikAwalId)) {
                    $titikAwalType = LokasiTransportasi::class;
                    $titikAwalName = $titikAwalName ?: $trans->nama_lokasi;
                } elseif ($hotel = Penginapan::find($titikAwalId)) {
                    $titikAwalType = Penginapan::class;
                    $titikAwalName = $titikAwalName ?: $hotel->nama_penginapan;
                }
            }
        } elseif ($titikAwalName) {
            if ($trans = LokasiTransportasi::where('nama_lokasi', $titikAwalName)->first()) {
                $titikAwalId = $trans->id_lokasi;
                $titikAwalType = LokasiTransportasi::class;
            } elseif ($hotel = Penginapan::where('nama_penginapan', $titikAwalName)->first()) {
                $titikAwalId = $hotel->id_penginapan;
                $titikAwalType = Penginapan::class;
            }
        }

        if (!$titikAwalName) {
            $defaultTransport = LokasiTransportasi::first();
            $titikAwalName = $defaultTransport?->nama_lokasi ?? 'Pelabuhan Ferry Batam Center';
            $titikAwalId = $defaultTransport?->id_lokasi;
            $titikAwalType = LokasiTransportasi::class;
        }

        // Resolve Titik Akhir
        $titikAkhirName = $validated['titik_akhir'] ?? null;
        $titikAkhirId = $validated['titik_akhir_id'] ?? null;
        $titikAkhirType = $validated['titik_akhir_type'] ?? null;

        if ($titikAkhirId) {
            if (!$titikAkhirType) {
                if ($trans = LokasiTransportasi::find($titikAkhirId)) {
                    $titikAkhirType = LokasiTransportasi::class;
                    $titikAkhirName = $titikAkhirName ?: $trans->nama_lokasi;
                } elseif ($hotel = Penginapan::find($titikAkhirId)) {
                    $titikAkhirType = Penginapan::class;
                    $titikAkhirName = $titikAkhirName ?: $hotel->nama_penginapan;
                }
            }
        } elseif ($titikAkhirName) {
            if ($trans = LokasiTransportasi::where('nama_lokasi', $titikAkhirName)->first()) {
                $titikAkhirId = $trans->id_lokasi;
                $titikAkhirType = LokasiTransportasi::class;
            } elseif ($hotel = Penginapan::where('nama_penginapan', $titikAkhirName)->first()) {
                $titikAkhirId = $hotel->id_penginapan;
                $titikAkhirType = Penginapan::class;
            }
        }

        if (!$titikAkhirName) {
            $titikAkhirName = $titikAwalName;
            $titikAkhirId = $titikAwalId;
            $titikAkhirType = $titikAwalType;
        }

        $selectedAreas = $validated['kecamatan_pilihan']
            ?? ['Batam Kota', 'Lubuk Baja'];

        $selectedThemes = $validated['kategori_minat'] ?? [];

        // 4. Tentukan preferensi makanan
        $isHalal = strtolower($typeFood) === 'halal'
            || ($validated['is_halal'] ?? false);

        $isSeafood = ($validated['is_seafood'] ?? false)
            || str_contains(strtolower($typeFood), 'seafood');

        // Mode draft / manual vs AI
        $isDraft = ($request->boolean('is_draft') || ($validated['mode'] ?? '') === 'manual' || ($validated['status'] ?? '') === 'draf');
        $planStatus = $isDraft ? 'draf' : 'aktif';

        // 5. Ambil user
        $user = auth('sanctum')->user() ?? $request->user();
        $userId = $user?->id_pengguna;

        Log::info('Request pembuatan rencana perjalanan', [
            'user_id' => $userId,
            'nama_rencana' => $validated['nama_rencana'],
            'total_days' => $totalDays,
            'budget' => $budget,
            'status' => $planStatus,
            'titik_awal' => $titikAwalName,
            'titik_akhir' => $titikAkhirName,
        ]);

        // 6. Mulai transaksi database
        DB::beginTransaction();

        try {
            // 7. Nonaktifkan rencana sebelumnya jika status aktif
            if ($userId && $planStatus === 'aktif') {
                RencanaPerjalanan::where('id_pengguna', $userId)
                    ->where('status', 'aktif')
                    ->update([
                        'status' => 'selesai',
                    ]);
            }

            // 8. Simpan preferensi perjalanan (data kecamatan disimpan murni ke tabel pivot preferensi_kecamatan)
            $preferensi = PreferensiPerjalanan::create([
                'id_pengguna' => $userId,
                'type_food' => $typeFood,
                'maks_budget_trip' => $budget,
            ]);

            Log::info('Preferensi perjalanan berhasil dibuat', [
                'id_preferensi' => $preferensi->id_preferensi,
            ]);

            // Sync pivot preferensi_kecamatan
            if (!empty($selectedAreas)) {
                $kecamatanIds = Kecamatan::whereIn('id_kecamatan', $selectedAreas)
                    ->orWhereIn('nama_kecamatan', $selectedAreas)
                    ->orderBy('id_kecamatan')
                    ->get()
                    ->unique('nama_kecamatan')
                    ->pluck('id_kecamatan')
                    ->all();

                if (!empty($kecamatanIds)) {
                    $preferensi->kecamatans()->sync($kecamatanIds);
                }
            }

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
                'budget_trip' => $budget,
                'type_food' => $typeFood,
                'start_time' => $startTime,
                'end_time' => $endTime,
                'status' => $planStatus,
            ]);

            Log::info('Rencana perjalanan berhasil dibuat', [
                'id_rencana' => $plan->id_rencana,
            ]);

            if ($isDraft) {
                // Buat struktur hari_perjalanan untuk draf (tanpa memanggil AI)
                for ($dayNumber = 1; $dayNumber <= $totalDays; $dayNumber++) {
                    HariPerjalanan::create([
                        'id_rencana' => $plan->id_rencana,
                        'tanggal' => $start->copy()->addDays($dayNumber - 1),
                        'urutan_hari' => $dayNumber,
                        'lokasi_awal' => $titikAwalName,
                        'lokasi_awal_type' => $titikAwalType,
                        'lokasi_awal_id' => $titikAwalId,
                        'lokasi_akhir' => $titikAkhirName,
                        'lokasi_akhir_type' => $titikAkhirType,
                        'lokasi_akhir_id' => $titikAkhirId,
                        'estimasi_biaya' => 0,
                    ]);
                }
            } else {
                // 11. Generate itinerary menggunakan Gemini / Groq AI
                $this->generateRecommendationItinerary(
                    $plan,
                    $totalDays,
                    $titikAwalName,
                    $titikAwalType,
                    $titikAwalId,
                    $titikAkhirName,
                    $titikAkhirType,
                    $titikAkhirId,
                    $selectedAreas,
                    $selectedThemes,
                    $geminiService,
                    $openRouterService,
                    $groqService,
                    $isHalal,
                    $isSeafood,
                    $startTime,
                    $endTime
                );
            }

            // 12. Ambil hasil itinerary dari database
            $fullPlan = RencanaPerjalanan::with([
                'preferensi.kategoris',
                'preferensi.kecamatans',
                'hariPerjalanan.lokasiAwalLocation',
                'hariPerjalanan.lokasiAkhirLocation',
                'hariPerjalanan.itemPerjalanan.destinasi',
            ])->findOrFail($plan->id_rencana);

            // 13. Commit seluruh penyimpanan
            DB::commit();

            Log::info('Seluruh rencana perjalanan berhasil disimpan', [
                'id_rencana' => $plan->id_rencana,
            ]);

            // 14. Kirim response ke Flutter
            return response()->json([
                'success' => true,
                'message' => $isDraft
                    ? 'Draf rencana perjalanan berhasil disimpan.'
                    : 'Rencana perjalanan dan itinerary AI berhasil dibuat.',
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

    public function destroy($id)
    {
        try {
            DB::transaction(function () use ($id) {

                // 1. Cari rencana perjalanan milik pengguna
                $plan = RencanaPerjalanan::where(
                    'id_rencana',
                    $id
                )
                    ->lockForUpdate()
                    ->findOrFail($id);

                // 2. Ambil preferensi perjalanan
                $preferensi = $plan->preferensi;

                // 3. Hapus rencana perjalanan
                // Event deleting otomatis menghapus hari dan item
                $plan->delete();

                // 4. Hapus preferensi jika tidak digunakan lagi
                if ($preferensi) {

                    // Pastikan tidak ada rencana lain yang menggunakan preferensi
                    if (!$preferensi->rencanaPerjalanan()->exists()) {

                        $preferensi->kategoris()->detach();
                        $preferensi->kecamatans()->detach();

                        // Event deleting preferensi juga dijalankan
                        $preferensi->delete();
                    }
                }
            });

            return response()->json([
                'success' => true,
                'message' => 'Rencana perjalanan berhasil dihapus.',
            ], 200);

        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {

            return response()->json([
                'success' => false,
                'message' => 'Rencana perjalanan tidak ditemukan.',
            ], 404);

        } catch (\Exception $e) {

            Log::error('Gagal menghapus rencana perjalanan', [
                'id_rencana' => $id,
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Gagal menghapus rencana perjalanan.',
            ], 500);
        }
    }


    private function generateRecommendationItinerary(
        RencanaPerjalanan $plan,
        int $totalDays,
        string $startLocation,
        ?string $titikAwalType,
        ?string $titikAwalId,
        ?string $titikAkhirName,
        ?string $titikAkhirType,
        ?string $titikAkhirId,
        array $selectedAreas,
        array $selectedThemes,
        GeminiService $geminiService,
        OpenRouterService $openRouterService,
        GroqService $groqService,
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

        if (!empty($selectedThemes)) {
            $wisataQuery->whereHas('kategoris', function ($query) use ($selectedThemes) {
                $query->whereIn('nama_kategori', $selectedThemes);
            });
        }

        $availableWisata = $wisataQuery->get();

        // Fallback: Jika di kecamatan yang dipilih belum ada data wisata, ambil data wisata lain di Batam
        if ($availableWisata->isEmpty()) {
            $availableWisata = Wisata::with(['kategoris', 'kecamatan'])->take(15)->get();
        }

        // 3. Ambil kandidat restoran
        $restoranQuery = Restoran::with('kecamatan');

        if (!empty($kecamatanIds)) {
            $restoranQuery->whereIn('id_kecamatan', $kecamatanIds);
        }

        if ($isHalal && !$isSeafood) {
            $restoranQuery->where('type_food', 'Halal');
        } elseif ($isSeafood && !$isHalal) {
            $restoranQuery->where('type_food', 'Seafood');
        }

        $availableRestoran = $restoranQuery->get();


        // Fallback: Jika di kecamatan tersebut belum ada restoran yang cocok, ambil restoran yang ada
        if ($availableRestoran->isEmpty()) {
            $availableRestoran = Restoran::with('kecamatan')->take(10)->get();
        }

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

        // 5. Siapkan data destinasi untuk Gemini / AI
        $destinations = [];

        foreach ($availableWisata as $item) {
            $destinations[] = [
                'destination_id' => $item->id_wisata,
                'name' => $item->nama_wisata ?? $item->nama ?? 'Wisata Batam',
                'type' => 'wisata',
                'description' => $item->deskripsi,
                'price' => (float) ($item->harga_tiket_masuk ?? $item->harga_tiket ?? 0),
                'area' => $item->kecamatan->nama_kecamatan ?? null,
            ];
        }

        foreach ($availableRestoran as $item) {
            $destinations[] = [
                'destination_id' => $item->id_restoran,
                'name' => $item->nama_restoran ?? $item->nama ?? 'Restoran Batam',
                'type' => 'restoran',
                'description' => $item->deskripsi,
                'food_type' => $item->type_food,
                'price' => (float) ($item->harga_makan_per_orang ?? $item->harga_per_orang ?? 0),
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

        $result = $this->generateAiItinerary(
            $data,
            $geminiService,
            $openRouterService,
            $groqService,
        );

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

        // Pastikan semua hari tersedia (buat fallback jika ada hari yang terlewat oleh AI)
        for ($dayNumber = 1; $dayNumber <= $totalDays; $dayNumber++) {
            if (!isset($daysByNumber[$dayNumber])) {
                $fallbackItems = [];
                if ($availableWisata->isNotEmpty()) {
                    $w = $availableWisata->random();
                    $fallbackItems[] = [
                        'destination_id' => $w->id_wisata,
                        'type' => 'wisata',
                        'start_time' => '09:00',
                        'end_time' => '11:30',
                    ];
                }
                if ($availableRestoran->isNotEmpty()) {
                    $r = $availableRestoran->random();
                    $fallbackItems[] = [
                        'destination_id' => $r->id_restoran,
                        'type' => 'restoran',
                        'start_time' => '12:00',
                        'end_time' => '13:30',
                    ];
                }
                $daysByNumber[$dayNumber] = [
                    'day' => $dayNumber,
                    'items' => $fallbackItems,
                ];
            }
        }

        // 9. Simpan itinerary ke database
        // Tidak menggunakan DB::transaction() lagi.
        // Transaksi sudah dikendalikan oleh method store().

        $startDate = Carbon::parse($plan->hari_start ?? now());

        for ($dayNumber = 1; $dayNumber <= $totalDays; $dayNumber++) {
            $day = $daysByNumber[$dayNumber];

            // Cek apakah hari perjalanan sudah ada sebelumnya
            $hari = HariPerjalanan::where('id_rencana', $plan->id_rencana)
                ->where('urutan_hari', $dayNumber)
                ->first();

            if (!$hari) {
                // Simpan hari perjalanan baru
                $hari = HariPerjalanan::create([
                    'id_rencana' => $plan->id_rencana,
                    'tanggal' => $startDate->copy()->addDays($dayNumber - 1),
                    'urutan_hari' => $dayNumber,
                    'lokasi_awal' => $startLocation,
                    'lokasi_awal_type' => $titikAwalType,
                    'lokasi_awal_id' => $titikAwalId,
                    'lokasi_akhir' => $titikAkhirName ?: $startLocation,
                    'lokasi_akhir_type' => $titikAkhirType ?: $titikAwalType,
                    'lokasi_akhir_id' => $titikAkhirId ?: $titikAwalId,
                    'estimasi_biaya' => 0,
                ]);
            } else {
                // Hapus item lama sebelum mengisi rekomendasi baru
                $hari->itemPerjalanan()->delete();
            }

            Log::info('Hari perjalanan berhasil dibuat', [
                'id_hari' => $hari->id_hari,
                'urutan_hari' => $dayNumber,
            ]);

            $totalBiayaHari = 0;

            // Simpan item perjalanan
            foreach (($day['items'] ?? []) as $index => $item) {
                $destinationId = $item['destination_id'] ?? null;
                $type = $item['type'] ?? 'wisata';
                $startTime = $item['start_time'] ?? null;
                $endTime = $item['end_time'] ?? null;

                // Validasi kelengkapan item
                if (!$destinationId) {
                    continue;
                }

                // Validasi tipe destinasi
                if (!in_array($type, ['wisata', 'restoran'], true)) {
                    $type = 'wisata';
                }

                // Validasi format waktu
                if (
                    !$startTime ||
                    !$endTime ||
                    !preg_match('/^(?:[01]\d|2[0-3]):[0-5]\d$/', $startTime) ||
                    !preg_match('/^(?:[01]\d|2[0-3]):[0-5]\d$/', $endTime) ||
                    $startTime >= $endTime
                ) {
                    $startHour = 8 + ($index * 2);
                    $startTime = sprintf('%02d:30', min(20, $startHour));
                    $endTime = sprintf('%02d:00', min(22, $startHour + 2));
                    if ($startTime >= $endTime) {
                        $endTime = '22:00';
                    }
                }

                $destination = null;
                $destinationType = null;
                $itemCost = 0;

                // 1. Validasi destinasi berdasarkan tipe
                if ($type === 'wisata') {
                    $destination = $availableWisata->firstWhere(
                        'id_wisata',
                        $destinationId
                    );

                    if ($destination) {
                        $destinationType = Wisata::class;
                        $itemCost = (float) ($destination->harga_tiket_masuk ?? 0);
                    }
                } else {
                    $destination = $availableRestoran->firstWhere(
                        'id_restoran',
                        $destinationId
                    );

                    if ($destination) {
                        $destinationType = Restoran::class;
                        $itemCost = (float) ($destination->harga_makan_per_orang ?? 0);
                    }
                }

                // 2. Fallback cek silang (jika AI menukar type wisata dan restoran atau ID ada di tabel lain)
                if (!$destination) {
                    $altWisata = $availableWisata->firstWhere('id_wisata', $destinationId) ?? Wisata::find($destinationId);
                    if ($altWisata) {
                        $destination = $altWisata;
                        $destinationId = $altWisata->id_wisata;
                        $destinationType = Wisata::class;
                        $type = 'wisata';
                        $itemCost = (float) ($altWisata->harga_tiket_masuk ?? 0);
                    } else {
                        $altResto = $availableRestoran->firstWhere('id_restoran', $destinationId) ?? Restoran::find($destinationId);
                        if ($altResto) {
                            $destination = $altResto;
                            $destinationId = $altResto->id_restoran;
                            $destinationType = Restoran::class;
                            $type = 'restoran';
                            $itemCost = (float) ($altResto->harga_makan_per_orang ?? 0);
                        }
                    }
                }

                // 3. Fallback jika AI memberikan ID halusinasi, pilih dari kandidat yang ada tanpa melempar exception
                if (!$destination) {
                    if ($type === 'restoran' && $availableRestoran->isNotEmpty()) {
                        $destination = $availableRestoran->random();
                        $destinationId = $destination->id_restoran;
                        $destinationType = Restoran::class;
                        $itemCost = (float) ($destination->harga_makan_per_orang ?? 0);
                    } elseif ($availableWisata->isNotEmpty()) {
                        $destination = $availableWisata->random();
                        $destinationId = $destination->id_wisata;
                        $destinationType = Wisata::class;
                        $itemCost = (float) ($destination->harga_tiket_masuk ?? 0);
                    } else {
                        continue;
                    }
                }

                $totalBiayaHari += $itemCost;

                Log::info('Data item perjalanan sebelum disimpan', [
                    'start_time' => $startTime,
                    'end_time' => $endTime,
                    'cost' => $itemCost,
                ]);
                // Simpan item itinerary
                $itemPerjalanan = ItemPerjalanan::create([
                    'id_hari' => $hari->id_hari,
                    'destinasi_type' => $destinationType,
                    'destinasi_id' => $destinationId,
                    'urutan_item' => $index + 1,

                    // Sesuaikan dengan nama kolom migration
                    'departure_time' => $startTime,
                    'arrival_time' => $endTime,
                ]);

                Log::info('Item perjalanan berhasil dibuat', [
                    'id_item' => $itemPerjalanan->id_item,
                    'id_hari' => $hari->id_hari,
                    'destination_id' => $destinationId,
                    'type' => $type,
                ]);
            }

            // Update estimasi biaya riil per hari dari destinasi yang terpilih
            $hari->update(['estimasi_biaya' => $totalBiayaHari]);
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

    public function generateAiItinerary(
        array $data,
        GeminiService $geminiService,
        OpenRouterService $openRouterService,
        GroqService $groqService
    ): array {
        // 1. Coba Groq lebih dulu (kecepatan respon ~1-2 detik)
        try {
            return $groqService->generateItinerary($data);

        } catch (Exception $e) {
            Log::warning('Groq gagal, mencoba OpenRouter', [
                'error' => $e->getMessage(),
            ]);
        }

        // 2. Coba OpenRouter (~2-4 detik)
        try {
            return $openRouterService->generateItinerary($data);

        } catch (Exception $e) {
            Log::warning('OpenRouter gagal, mencoba Gemini', [
                'error' => $e->getMessage(),
            ]);
        }

        // 3. Cadangan terakhir: Gemini
        try {
            return $geminiService->generateItinerary($data);

        } catch (Exception $e) {
            Log::error('Semua layanan AI gagal', [
                'error' => $e->getMessage(),
            ]);

            throw new Exception('Semua layanan AI gagal menghasilkan itinerary.');
        }
    }

    /**
     * Generate rekomendasi itinerary AI untuk rencana perjalanan yang sudah ada (misal dari draf).
     */
    public function generateAi(
        Request $request,
        $id,
        GeminiService $geminiService,
        OpenRouterService $openRouterService,
        GroqService $groqService
    ) {
        $plan = RencanaPerjalanan::with([
            'preferensi.kategoris',
            'preferensi.kecamatans',
            'hariPerjalanan.lokasiAwalLocation',
            'hariPerjalanan.lokasiAkhirLocation',
            'hariPerjalanan.itemPerjalanan.destinasi',
        ])->find($id);

        if (!$plan) {
            return response()->json([
                'success' => false,
                'message' => 'Rencana perjalanan tidak ditemukan',
            ], 404);
        }

        DB::beginTransaction();
        try {
            $totalDays = $plan->total_hari ?? 1;
            $preferensi = $plan->preferensi;

            $selectedAreas = $preferensi && $preferensi->kecamatans->isNotEmpty()
                ? $preferensi->kecamatans->pluck('nama_kecamatan')->all()
                : ['Batam Kota', 'Lubuk Baja'];

            $selectedThemes = $preferensi && $preferensi->kategoris->isNotEmpty()
                ? $preferensi->kategoris->pluck('nama_kategori')->all()
                : [];

            $typeFood = $plan->type_food ?? $preferensi?->type_food ?? 'Semua';
            $isHalal = strtolower($typeFood) === 'halal';
            $isSeafood = str_contains(strtolower($typeFood), 'seafood');
            $startTime = $plan->start_time ?? '08:30';
            $endTime = $plan->end_time ?? '21:00';

            // Ambil titik awal & akhir dari hari perjalanan
            $firstDay = $plan->hariPerjalanan->sortBy('urutan_hari')->first();
            $lastDay = $plan->hariPerjalanan->sortBy('urutan_hari')->last();

            $titikAwalName = $firstDay?->lokasi_awal ?? 'Pelabuhan Ferry Batam Center';
            $titikAwalType = $firstDay?->lokasi_awal_type;
            $titikAwalId = $firstDay?->lokasi_awal_id;

            $titikAkhirName = $lastDay?->lokasi_akhir ?? $titikAwalName;
            $titikAkhirType = $lastDay?->lokasi_akhir_type ?? $titikAwalType;
            $titikAkhirId = $lastDay?->lokasi_akhir_id ?? $titikAwalId;

            // Generate rekomendasi itinerary
            $this->generateRecommendationItinerary(
                $plan,
                $totalDays,
                $titikAwalName,
                $titikAwalType,
                $titikAwalId,
                $titikAkhirName,
                $titikAkhirType,
                $titikAkhirId,
                $selectedAreas,
                $selectedThemes,
                $geminiService,
                $openRouterService,
                $groqService,
                $isHalal,
                $isSeafood,
                $startTime,
                $endTime
            );

            // Perbarui status menjadi aktif
            $plan->update(['status' => 'aktif']);

            DB::commit();

            $fullPlan = RencanaPerjalanan::with([
                'preferensi.kategoris',
                'preferensi.kecamatans',
                'hariPerjalanan.lokasiAwalLocation',
                'hariPerjalanan.lokasiAkhirLocation',
                'hariPerjalanan.itemPerjalanan.destinasi',
            ])->find($id);

            return response()->json([
                'success' => true,
                'message' => 'Rekomendasi itinerary berhasil disusun oleh AI.',
                'data' => $fullPlan,
            ]);
        } catch (\Throwable $e) {
            DB::rollBack();
            Log::error('Gagal generate AI itinerary', [
                'error' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
                'plan_id' => $id,
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Gagal menyusun rekomendasi: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Memperbarui Titik Awal / Akhir pada satu hari perjalanan.
     */
    public function updateLokasiHari(Request $request, $idPlan, $idHari)
    {
        $validated = $request->validate([
            'lokasi_awal' => 'nullable|string|max:255',
            'lokasi_awal_type' => 'nullable|string|max:255',
            'lokasi_awal_id' => 'nullable|string|max:36',
            'lokasi_akhir' => 'nullable|string|max:255',
            'lokasi_akhir_type' => 'nullable|string|max:255',
            'lokasi_akhir_id' => 'nullable|string|max:36',
        ]);

        $hari = HariPerjalanan::where('id_hari', $idHari)->first();
        if (!$hari) {
            return response()->json([
                'success' => false,
                'message' => 'Data hari perjalanan tidak ditemukan',
            ], 404);
        }

        // Resolusi morph model type jika ID diberikan tanpa model_type
        if (!empty($validated['lokasi_awal_id']) && empty($validated['lokasi_awal_type'])) {
            if (LokasiTransportasi::where('id_lokasi', $validated['lokasi_awal_id'])->exists()) {
                $validated['lokasi_awal_type'] = LokasiTransportasi::class;
            } elseif (Penginapan::where('id_penginapan', $validated['lokasi_awal_id'])->exists()) {
                $validated['lokasi_awal_type'] = Penginapan::class;
            }
        }

        if (!empty($validated['lokasi_akhir_id']) && empty($validated['lokasi_akhir_type'])) {
            if (LokasiTransportasi::where('id_lokasi', $validated['lokasi_akhir_id'])->exists()) {
                $validated['lokasi_akhir_type'] = LokasiTransportasi::class;
            } elseif (Penginapan::where('id_penginapan', $validated['lokasi_akhir_id'])->exists()) {
                $validated['lokasi_akhir_type'] = Penginapan::class;
            }
        }

        $hari->update(array_filter($validated, fn($val) => $val !== null));

        return response()->json([
            'success' => true,
            'message' => 'Titik lokasi hari ke-' . $hari->urutan_hari . ' berhasil diperbarui',
            'data' => $hari->fresh(['lokasiAwalLocation', 'lokasiAkhirLocation', 'itemPerjalanan.destinasi']),
        ]);
    }

    /**
     * Tambah destinasi manual ke hari perjalanan.
     */
    public function tambahItemHari(Request $request, $idPlan, $idHari)
    {
        $validated = $request->validate([
            'destinasi_id' => 'required|string',
            'destinasi_type' => 'nullable|string',
            'departure_time' => 'nullable|string',
            'arrival_time' => 'nullable|string',
        ]);

        $hari = HariPerjalanan::where('id_hari', $idHari)->first();
        if (!$hari) {
            return response()->json([
                'success' => false,
                'message' => 'Hari perjalanan tidak ditemukan',
            ], 404);
        }

        $destinasiId = $validated['destinasi_id'];
        $destinasiType = $validated['destinasi_type'] ?? null;
        $cost = 0;

        if (!$destinasiType || $destinasiType === 'wisata' || str_contains(strtolower($destinasiType), 'wisata')) {
            $wisata = Wisata::find($destinasiId);
            if ($wisata) {
                $destinasiType = Wisata::class;
                $cost = (float) ($wisata->harga_tiket_masuk ?? 0);
            }
        }

        if (!$destinasiType || $destinasiType === 'restoran' || str_contains(strtolower($destinasiType), 'restoran')) {
            $restoran = Restoran::find($destinasiId);
            if ($restoran) {
                $destinasiType = Restoran::class;
                $cost = (float) ($restoran->harga_makan_per_orang ?? 0);
            }
        }

        if (!$destinasiType) {
            if ($wisata = Wisata::find($destinasiId)) {
                $destinasiType = Wisata::class;
                $cost = (float) ($wisata->harga_tiket_masuk ?? 0);
            } elseif ($restoran = Restoran::find($destinasiId)) {
                $destinasiType = Restoran::class;
                $cost = (float) ($restoran->harga_makan_per_orang ?? 0);
            } else {
                return response()->json([
                    'success' => false,
                    'message' => 'Destinasi tidak ditemukan',
                ], 404);
            }
        }

        $nextUrutan = ($hari->itemPerjalanan()->max('urutan_item') ?? 0) + 1;
        $depTime = $validated['departure_time'] ?? '09:00';
        $arrTime = $validated['arrival_time'] ?? '10:30';

        $item = ItemPerjalanan::create([
            'id_hari' => $hari->id_hari,
            'destinasi_type' => $destinasiType,
            'destinasi_id' => $destinasiId,
            'urutan_item' => $nextUrutan,
            'departure_time' => $depTime,
            'arrival_time' => $arrTime,
        ]);

        $hari->increment('estimasi_biaya', $cost);

        return response()->json([
            'success' => true,
            'message' => 'Destinasi berhasil ditambahkan ke hari ke-' . $hari->urutan_hari,
            'data' => $item->load('destinasi'),
        ], 201);
    }

    /**
     * Hapus destinasi dari jadwal hari perjalanan.
     */
    public function hapusItemHari($idItem)
    {
        $item = ItemPerjalanan::find($idItem);
        if (!$item) {
            return response()->json([
                'success' => false,
                'message' => 'Item perjalanan tidak ditemukan',
            ], 404);
        }

        $hari = $item->hariPerjalanan;
        $destinasi = $item->destinasi;
        $cost = 0;
        if ($destinasi instanceof Wisata) {
            $cost = (float) ($destinasi->harga_tiket_masuk ?? 0);
        } elseif ($destinasi instanceof Restoran) {
            $cost = (float) ($destinasi->harga_makan_per_orang ?? 0);
        }

        $item->delete();

        if ($hari) {
            $newCost = max(0, ($hari->estimasi_biaya ?? 0) - $cost);
            $hari->update(['estimasi_biaya' => $newCost]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Destinasi berhasil dihapus dari jadwal',
        ]);
    }
}