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
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

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
    public function store(Request $request)
    {
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

        $startDateStr = $validated['hari_start'] ?? $validated['tanggal_mulai'] ?? now()->toDateString();
        $endDateStr = $validated['hari_end'] ?? $validated['tanggal_selesai'] ?? $startDateStr;

        $start = Carbon::parse($startDateStr);
        $end = Carbon::parse($endDateStr);
        if ($end->lt($start)) {
            $end = $start->copy();
        }
        $totalDays = max(1, $start->diffInDays($end) + 1);

        $budget = $validated['budget_trip'] ?? $validated['total_anggaran'] ?? null;
        $typeFood = $validated['type_food'] ?? ($request->boolean('is_halal') ? 'Halal' : 'Semua');
        $startTime = $validated['start_time'] ?? '08:30';
        $endTime = $validated['end_time'] ?? '21:00';
        $titikAwal = $validated['titik_awal'] ?? 'Pelabuhan Ferry Batam Center';

        $user = auth('sanctum')->user() ?? $request->user();
        $userId = $user?->id_pengguna;

        DB::beginTransaction();
        try {
            // Nonaktifkan rencana sebelumnya
            if ($userId) {
                RencanaPerjalanan::where('id_pengguna', $userId)->where('status', 'aktif')->update(['status' => 'selesai']);
            }

            // Simpan preferensi perjalanan
            $preferensi = PreferensiPerjalanan::create([
                'id_pengguna' => $userId,
                'type_food' => $typeFood,
                'maks_budget_trip' => $budget,
                'kecamatan_pilihan' => $validated['kecamatan_pilihan'] ?? ['Batam Kota', 'Lubuk Baja'],
            ]);

            // Simpan relasi minat kategori
            $selectedThemes = $validated['kategori_minat'] ?? [];
            if (!empty($selectedThemes)) {
                $categoryIds = [];
                foreach ($selectedThemes as $cat) {
                    if (is_numeric($cat)) {
                        $categoryIds[] = (int) $cat;
                    } else {
                        $katRecord = Kategori::where('nama_kategori', $cat)->first();
                        if ($katRecord) {
                            $categoryIds[] = $katRecord->id_kategori;
                        }
                    }
                }
                if (!empty($categoryIds)) {
                    $preferensi->kategoris()->sync(array_unique($categoryIds));
                }
            }

            // Simpan rencana perjalanan
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

            $isHalal = strtolower($typeFood) === 'halal' || $request->boolean('is_halal');
            $isSeafood = $request->boolean('is_seafood') || str_contains(strtolower($typeFood), 'seafood');


            $this->generateRecommendationItinerary(
                $plan,
                $totalDays,
                $titikAwal,
                $validated['kecamatan_pilihan'] ?? [],
                $selectedThemes,
                $isHalal,
                $isSeafood,
                $startTime,
                $endTime
            );

            DB::commit();

            $fullPlan = RencanaPerjalanan::with([
                'preferensi.kategoris',
                'hariPerjalanan.itemPerjalanan',
                'detailItineraries',
            ])->find($plan->id_rencana);

            return response()->json([
                'success' => true,
                'message' => 'Rencana perjalanan dan susunan itinerary berhasil dibuat',
                'data' => $fullPlan,
            ], 201);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Gagal membuat rencana perjalanan: ' . $e->getMessage(),
            ], 500);
        }
    }

    // Hapus rencana perjalanan
    public function destroy(Request $request, $id)
    {
        $user = auth('sanctum')->user() ?? $request->user();
        $userId = $user?->id_pengguna;

        $query = RencanaPerjalanan::query();
        if ($userId) {
            $query->where('id_pengguna', $userId);
        }
        $plan = $query->find($id);

        if (!$plan) {
            return response()->json([
                'success' => false,
                'message' => 'Rencana perjalanan tidak ditemukan',
            ], 404);
        }

        $plan->delete();

        return response()->json([
            'success' => true,
            'message' => 'Rencana perjalanan berhasil dihapus',
        ]);
    }

    private function generateRecommendationItinerary(
        RencanaPerjalanan $plan,
        int $totalDays,
        string $startLocation,
        array $selectedAreas,
        array $selectedThemes,
        bool $isHalal = false,
        bool $isSeafood = false,
        string $defaultStartTime = '08:30',
        string $defaultEndTime = '21:00'
    ) {
        // Ambil data kecamatan
        $kecamatanIds = Kecamatan::whereIn('nama_kecamatan', $selectedAreas)
            ->pluck('id_kecamatan')
            ->toArray();

        // Ambil data wisata
        $wisataQuery = Wisata::with(['kategoris', 'kecamatan']);
        if (!empty($kecamatanIds)) {
            $wisataQuery->whereIn('id_kecamatan', $kecamatanIds);
        }
        $availableWisata = $wisataQuery->take(15)->get();
        if ($availableWisata->count() < 3) {
            $availableWisata = Wisata::with(['kategoris', 'kecamatan'])->take(15)->get();
        }

        // Ambil data restoran
        $restoranQuery = Restoran::with(['kategoris', 'kecamatan']);
        if (!empty($kecamatanIds)) {
            $restoranQuery->whereIn('id_kecamatan', $kecamatanIds);
        }
        if ($isHalal) {
            $restoranQuery->where('type_food', 'Halal');
        }
        if ($isSeafood) {
            $restoranQuery->where(function ($q) {
                $q->where('nama_restoran', 'like', '%seafood%')
                    ->orWhere('nama_restoran', 'like', '%kelong%')
                    ->orWhere('type_food', 'like', '%seafood%');
            });
        }
        $availableRestoran = $restoranQuery->take(10)->get();
        if ($availableRestoran->count() < 2) {
            $availableRestoran = Restoran::with(['kategoris', 'kecamatan'])->take(10)->get();
        }

        $wisataIdx = 0;
        $restoranIdx = 0;
        $baseDate = Carbon::parse($plan->hari_start ?? now());

        for ($day = 1; $day <= $totalDays; $day++) {
            $currentDayDate = $baseDate->copy()->addDays($day - 1)->toDateString();
            $order = 1;

            // Simpan hari perjalanan
            $hariRecord = HariPerjalanan::create([
                'id_rencana' => $plan->id_rencana,
                'tanggal' => $currentDayDate,
                'urutan_hari' => $day,
                'lokasi_awal' => $day === 1 ? $startLocation : 'Hotel / Penginapan',
                'lokasi_akhir' => 'Hotel / Penginapan',
                'estimasi_biaya' => 0,
            ]);
            // Wisata pagi
            $pagiWisata = $availableWisata->get($wisataIdx % max(1, $availableWisata->count()));
            $wisataIdx++;
            if ($pagiWisata) {
                ItemPerjalanan::create([
                    'id_hari' => $hariRecord->id_hari,
                    'destinasi_type' => Wisata::class,
                    'destinasi_id' => $pagiWisata->id_wisata,
                    'urutan_item' => 1,
                    'depature_time' => '09:15',
                    'arrival_time' => '11:30',
                ]);
            }

            // Kuliner siang
            $siangResto = $availableRestoran->get($restoranIdx % max(1, $availableRestoran->count()));
            $restoranIdx++;
            if ($siangResto) {
                ItemPerjalanan::create([
                    'id_hari' => $hariRecord->id_hari,
                    'destinasi_type' => Restoran::class,
                    'destinasi_id' => $siangResto->id_restoran,
                    'urutan_item' => 2,
                    'depature_time' => '12:00',
                    'arrival_time' => '13:30',
                ]);
            }


            // Wisata sore
            $soreWisata = $availableWisata->get($wisataIdx % max(1, $availableWisata->count()));
            $wisataIdx++;
            if ($soreWisata) {
                ItemPerjalanan::create([
                    'id_hari' => $hariRecord->id_hari,
                    'destinasi_type' => Wisata::class,
                    'destinasi_id' => $soreWisata->id_wisata,
                    'urutan_item' => 3,
                    'depature_time' => '14:30',
                    'arrival_time' => '17:30',
                ]);
            }

            // Kuliner malam
            $malamResto = $availableRestoran->get($restoranIdx % max(1, $availableRestoran->count()));
            $restoranIdx++;
            if ($malamResto) {
                ItemPerjalanan::create([
                    'id_hari' => $hariRecord->id_hari,
                    'destinasi_type' => Restoran::class,
                    'destinasi_id' => $malamResto->id_restoran,
                    'urutan_item' => 4,
                    'depature_time' => '18:30',
                    'arrival_time' => '20:30',
                ]);
            }
        }
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