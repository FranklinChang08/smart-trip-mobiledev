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
    // Melihat History Itinerary Perjalanan
    public function index(Request $request)
    {
        $user = auth('sanctum')->user() ?? $request->user();
        $userId = $user?->id_pengguna;

        $query = RencanaPerjalanan::with([
            'preferensi.kategoris',
            'hariPerjalanan.itemPerjalanan',
            'detailItineraries',
        ])->orderBy('created_at', 'desc');

        if ($userId) {
            $query->where(function ($q) use ($userId) {
                $q->where('id_pengguna', $userId)
                  ->orWhereNull('id_pengguna');
            });
        }

        $plans = $query->get();

        return response()->json([
            'success' => true,
            'message' => 'Daftar riwayat rencana perjalanan berhasil diambil',
            'data' => $plans,
        ]);
    }

    // Melihat Detail Rencana Perjalanan
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

    // Membuat Rencana Perjalanan & Mengisi Preferensi Perjalanan (Sesuai ERD)
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

        $userId = $request->user()?->id_pengguna;

        DB::beginTransaction();
        try {
            // Ubah rencana sebelumnya menjadi status selesai agar hanya rencana terbaru yang aktif
            if ($userId) {
                RencanaPerjalanan::where('id_pengguna', $userId)->where('status', 'aktif')->update(['status' => 'selesai']);
            } else {
                RencanaPerjalanan::where('status', 'aktif')->update(['status' => 'selesai']);
            }

            // 1. Simpan Preferensi Perjalanan (USERS 1 --- Mengisi --- 1 PREFERENSI)
            $preferensi = PreferensiPerjalanan::create([
                'id_pengguna' => $userId,
                'type_food' => $typeFood,
                'maks_budget_trip' => $budget,
                'kecamatan_pilihan' => $validated['kecamatan_pilihan'] ?? ['Batam Kota', 'Lubuk Baja'],
            ]);

            // Simpan Relasi Minat Wisata ke Tabel Pivot preferensi_kategori (PREFERENSI M --- Memiliki --- M KATEGORI)
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

            // 2. Simpan Rencana Perjalanan (PREFERENSI 1 --- Mendasari --- M RENCANA PERJALANAN)
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

            // 3. Susun Detail Itinerary (HARI PERJALANAN & ITEM PERJALANAN)
            if (!empty($validated['custom_destinations'])) {
                $this->saveCustomItinerary($plan, $validated['custom_destinations']);
            } else {
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
            }

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

    // Menghapus Rencana Perjalanan
    public function destroy($id)
    {
        $plan = RencanaPerjalanan::find($id);

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

    // Menyimpan destinasi kustom pilihan pengguna
    private function saveCustomItinerary(RencanaPerjalanan $plan, array $customItems)
    {
        foreach ($customItems as $index => $item) {
            DetailItinerary::create([
                'id_rencana' => $plan->id_rencana,
                'hari_ke' => $item['hari_ke'] ?? 1,
                'urutan' => $index + 1,
                'tipe_item' => $item['tipe_item'] ?? 'wisata',
                'id_wisata' => $item['id_wisata'] ?? null,
                'id_restoran' => $item['id_restoran'] ?? null,
                'nama_tempat' => $item['nama_tempat'],
                'kategori' => $item['kategori'] ?? 'Destinasi Pilihan Kustom',
                'waktu_mulai' => $item['waktu_mulai'] ?? null,
                'waktu_selesai' => $item['waktu_selesai'] ?? null,
                'estimasi_biaya' => $item['estimasi_biaya'] ?? null,
                'catatan' => $item['catatan'] ?? null,
                'is_kustom' => true,
            ]);
        }
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
        // Ambil data kecamatan terpilih
        $kecamatanIds = Kecamatan::whereIn('nama_kecamatan', $selectedAreas)
            ->pluck('id_kecamatan')
            ->toArray();

        // Ambil wisata yang sesuai
        $wisataQuery = Wisata::query();
        if (!empty($kecamatanIds)) {
            $wisataQuery->whereIn('id_kecamatan', $kecamatanIds);
        }
        $availableWisata = $wisataQuery->take(15)->get();
        if ($availableWisata->count() < 3) {
            $availableWisata = Wisata::take(15)->get();
        }

        // Ambil restoran yang sesuai
        $restoranQuery = Restoran::query();
        if (!empty($kecamatanIds)) {
            $restoranQuery->whereIn('id_kecamatan', $kecamatanIds);
        }
        if ($isHalal) {
            $restoranQuery->where('type_food', 'Halal');
        }
        if ($isSeafood) {
            $restoranQuery->where(function ($q) {
                $q->where('nama_restoran', 'like', '%seafood%')
                  ->orWhere('nama_restoran', 'like', '%kelong%');
            });
        }
        $availableRestoran = $restoranQuery->take(10)->get();
        if ($availableRestoran->count() < 2) {
            $availableRestoran = Restoran::take(10)->get();
        }

        $wisataIdx = 0;
        $restoranIdx = 0;
        $baseDate = Carbon::parse($plan->hari_start ?? now());

        for ($day = 1; $day <= $totalDays; $day++) {
            $currentDayDate = $baseDate->copy()->addDays($day - 1)->toDateString();
            $order = 1;

            // Simpan ke HARI PERJALANAN (Sesuai ERD)
            $hariRecord = HariPerjalanan::create([
                'id_rencana' => $plan->id_rencana,
                'tanggal' => $currentDayDate,
                'urutan_hari' => $day,
                'lokasi_awal' => $day === 1 ? $startLocation : 'Hotel / Penginapan',
                'lokasi_akhir' => 'Hotel / Penginapan',
                'estimasi_biaya' => 0,
            ]);

            // Titik Kedatangan Awal (Hari 1)
            if ($day === 1) {
                DetailItinerary::create([
                    'id_rencana' => $plan->id_rencana,
                    'hari_ke' => 1,
                    'urutan' => $order++,
                    'tipe_item' => 'titik_awal',
                    'nama_tempat' => $startLocation,
                    'kategori' => 'Titik Awal & Penjemputan',
                    'waktu_mulai' => $defaultStartTime,
                    'waktu_selesai' => '09:00',
                    'estimasi_biaya' => 0,
                    'catatan' => 'Titik awal penjemputan dan briefing rute perjalanan Batam.',
                    'is_kustom' => false,
                ]);
            }

            // Wisata Pagi
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
            DetailItinerary::create([
                'id_rencana' => $plan->id_rencana,
                'hari_ke' => $day,
                'urutan' => $order++,
                'tipe_item' => 'wisata',
                'id_wisata' => $pagiWisata?->id_wisata,
                'nama_tempat' => $pagiWisata?->nama_wisata ?? 'Museum Raja Ali Haji & Ikon Welcome to Batam',
                'kategori' => 'Wisata Pagi Unggulan',
                'waktu_mulai' => '09:15',
                'waktu_selesai' => '11:30',
                'estimasi_biaya' => $pagiWisata?->harga_tiket_masuk ?? 15000,
                'catatan' => 'Menikmati udara sejuk dan spot foto ikonik Batam.',
                'is_kustom' => false,
            ]);

            // Santap Siang Kuliner
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
            DetailItinerary::create([
                'id_rencana' => $plan->id_rencana,
                'hari_ke' => $day,
                'urutan' => $order++,
                'tipe_item' => 'restoran',
                'id_restoran' => $siangResto?->id_restoran,
                'nama_tempat' => $siangResto?->nama_restoran ?? 'Kuliner Mie Tarempa Khas Kepri',
                'kategori' => $isHalal ? 'Kuliner Halal Khas Batam' : 'Kuliner Khas Batam',
                'waktu_mulai' => '12:00',
                'waktu_selesai' => '13:30',
                'estimasi_biaya' => $siangResto?->harga_makan_per_orang ?? 45000,
                'catatan' => 'Istirahat dan santap siang kuliner khas lokal.',
                'is_kustom' => false,
            ]);

            // Spot Sore
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
            DetailItinerary::create([
                'id_rencana' => $plan->id_rencana,
                'hari_ke' => $day,
                'urutan' => $order++,
                'tipe_item' => 'wisata',
                'id_wisata' => $soreWisata?->id_wisata,
                'nama_tempat' => $soreWisata?->nama_wisata ?? 'Grand Batam Mall & Nagoya',
                'kategori' => 'Wisata Sore & Belanja',
                'waktu_mulai' => '14:30',
                'waktu_selesai' => '17:30',
                'estimasi_biaya' => $soreWisata?->harga_tiket_masuk ?? 10000,
                'catatan' => 'Jelajah destinasi wisata sore dan pemandangan senja.',
                'is_kustom' => false,
            ]);

            // Spot Malam
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
            DetailItinerary::create([
                'id_rencana' => $plan->id_rencana,
                'hari_ke' => $day,
                'urutan' => $order++,
                'tipe_item' => 'restoran',
                'id_restoran' => $malamResto?->id_restoran,
                'nama_tempat' => $malamResto?->nama_restoran ?? 'Seafood Kelong Tepi Laut Batam',
                'kategori' => $isSeafood ? 'Santap Malam Seafood Kelong' : 'Santap Malam Khas Batam',
                'waktu_mulai' => '18:30',
                'waktu_selesai' => '20:30',
                'estimasi_biaya' => $malamResto?->harga_makan_per_orang ?? 85000,
                'catatan' => 'Menikmati hidangan lezat dengan panorama pesisir malam hari.',
                'is_kustom' => false,
            ]);
        }
    }

    // Menjadikan Rencana Perjalanan Sebagai Rencana Aktif
    public function setActive(Request $request, $id)
    {
        $user = auth('sanctum')->user() ?? $request->user();
        $userId = $user?->id_pengguna;

        if ($userId) {
            RencanaPerjalanan::where(function ($q) use ($userId) {
                $q->where('id_pengguna', $userId)->orWhereNull('id_pengguna');
            })->update(['status' => 'selesai']);
            $plan = RencanaPerjalanan::where(function ($q) use ($userId) {
                $q->where('id_pengguna', $userId)->orWhereNull('id_pengguna');
            })->find($id);
        } else {
            RencanaPerjalanan::query()->update(['status' => 'selesai']);
            $plan = RencanaPerjalanan::find($id);
        }

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