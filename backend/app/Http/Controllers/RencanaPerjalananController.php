<?php

namespace App\Http\Controllers;

use App\Models\DetailItinerary;
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

        $query = RencanaPerjalanan::with(['preferensi', 'detailItineraries'])
            ->orderBy('created_at', 'desc');

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
            'preferensi',
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

    // Membuat Rencana Perjalanan & Mengisi Preferensi Perjalanan
    public function store(Request $request)
    {
        $validated = $request->validate([
            'nama_rencana' => 'required|string|max:255',
            'tanggal_mulai' => 'required|date',
            'tanggal_selesai' => 'required|date|after_or_equal:tanggal_mulai',
            'titik_awal' => 'required|string|max:255',
            'total_anggaran' => 'nullable|numeric|min:0',
            'prioritas_anggaran' => 'nullable|string',
            'transportasi' => 'nullable|string',
            'catatan' => 'nullable|string',
            'kategori_minat' => 'nullable|array',
            'kecamatan_pilihan' => 'nullable|array',
            'preferensi_kuliner' => 'nullable|array',
            'custom_destinations' => 'nullable|array', // Untuk Memilih Destinasi Kustom
        ]);

        $start = Carbon::parse($validated['tanggal_mulai']);
        $end = Carbon::parse($validated['tanggal_selesai']);
        $totalDays = max(1, $start->diffInDays($end) + 1);

        $userId = $request->user()?->id_pengguna;

        DB::beginTransaction();
        try {
            // Ubah rencana sebelumnya menjadi status tersimpan agar hanya rencana terbaru yang aktif
            if ($userId) {
                RencanaPerjalanan::where('id_pengguna', $userId)->where('status', 'aktif')->update(['status' => 'selesai']);
            } else {
                RencanaPerjalanan::where('status', 'aktif')->update(['status' => 'selesai']);
            }
            // Simpan Header Rencana Perjalanan
            $plan = RencanaPerjalanan::create([
                'id_pengguna' => $userId,
                'nama_rencana' => $validated['nama_rencana'],
                'tanggal_mulai' => $start->toDateString(),
                'tanggal_selesai' => $end->toDateString(),
                'total_hari' => $totalDays,
                'titik_awal' => $validated['titik_awal'],
                'total_anggaran' => $validated['total_anggaran'] ?? null,
                'prioritas_anggaran' => $validated['prioritas_anggaran'] ?? 'Kuliner & Seafood Kelong',
                'transportasi' => $validated['transportasi'] ?? 'Mobil Sewa + Driver Lokal',
                'catatan' => $validated['catatan'] ?? null,
                'status' => 'aktif',
            ]);

            // Simpan Preferensi Perjalanan 
            $plan->preferensi()->create([
                'kategori_minat' => $validated['kategori_minat'] ?? ['Wisata Alam', 'Wisata Pantai'],
                'kecamatan_pilihan' => $validated['kecamatan_pilihan'] ?? ['Batam Kota', 'Nongsa'],
                'preferensi_kuliner' => $validated['preferensi_kuliner'] ?? ['halal' => true],
            ]);

            // Susun Detail Itinerary
            if (!empty($validated['custom_destinations'])) {
                // Memilih Destinasi Kustom
                $this->saveCustomItinerary($plan, $validated['custom_destinations']);
            } else {
                // Memperoleh Rekomendasi
                $this->generateRecommendationItinerary(
                    $plan,
                    $totalDays,
                    $validated['titik_awal'],
                    $validated['kecamatan_pilihan'] ?? [],
                    $validated['kategori_minat'] ?? []
                );
            }

            DB::commit();

            $fullPlan = RencanaPerjalanan::with(['preferensi', 'detailItineraries'])
                ->find($plan->id_rencana);

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

    // Menyusun Urutan Kunjungan
    public function updateUrutan(Request $request, $id)
    {
        $plan = RencanaPerjalanan::find($id);
        if (!$plan) {
            return response()->json([
                'success' => false,
                'message' => 'Rencana perjalanan tidak ditemukan',
            ], 404);
        }

        $validated = $request->validate([
            'items' => 'required|array',
            'items.*.id_detail' => 'required|string',
            'items.*.hari_ke' => 'required|integer|min:1',
            'items.*.urutan' => 'required|integer|min:1',
        ]);

        DB::beginTransaction();
        try {
            foreach ($validated['items'] as $item) {
                DetailItinerary::where('id_detail', $item['id_detail'])
                    ->where('id_rencana', $id)
                    ->update([
                        'hari_ke' => $item['hari_ke'],
                        'urutan' => $item['urutan'],
                    ]);
            }
            DB::commit();

            $updatedPlan = RencanaPerjalanan::with(['preferensi', 'detailItineraries'])
                ->find($id);

            return response()->json([
                'success' => true,
                'message' => 'Urutan kunjungan itinerary berhasil diperbarui',
                'data' => $updatedPlan,
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Gagal memperbarui urutan kunjungan: ' . $e->getMessage(),
            ], 500);
        }
    }

    //  Menghapus Rencana Perjalanan
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

    //  Menyimpan destinasi kustom pilihan pengguna
    private function saveCustomItinerary(RencanaPerjalanan $plan, array $customItems)
    {
        foreach ($customItems as $index => $item) {
            DetailItinerary::create([
                'id_rencana' => $plan->id_rencana,
                'hari_ke' => $item['hari_ke'] ?? 1,
                'urutan' => $item['urutan'] ?? ($index + 1),
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
        array $selectedThemes
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

        // Ambil restoran yang sesuai
        $restoranQuery = Restoran::query();
        if (!empty($kecamatanIds)) {
            $restoranQuery->whereIn('id_kecamatan', $kecamatanIds);
        }
        $availableRestoran = $restoranQuery->take(10)->get();

        $wisataIdx = 0;
        $restoranIdx = 0;

        for ($day = 1; $day <= $totalDays; $day++) {
            $order = 1;

            // Titik Kedatangan Awal
            if ($day === 1) {
                DetailItinerary::create([
                    'id_rencana' => $plan->id_rencana,
                    'hari_ke' => 1,
                    'urutan' => $order++,
                    'tipe_item' => 'titik_awal',
                    'nama_tempat' => $startLocation,
                    'kategori' => 'Titik Awal & Penjemputan',
                    'waktu_mulai' => '08:30',
                    'waktu_selesai' => '09:00',
                    'estimasi_biaya' => 0,
                    'catatan' => 'Titik awal penjemputan dan briefing rute perjalanan Batam.',
                    'is_kustom' => false,
                ]);
            }

            // Wisata Budaya / Sejarah / Landmark
            $pagiWisata = $availableWisata->get($wisataIdx % max(1, $availableWisata->count()));
            $wisataIdx++;
            DetailItinerary::create([
                'id_rencana' => $plan->id_rencana,
                'hari_ke' => $day,
                'urutan' => $order++,
                'tipe_item' => 'wisata',
                'id_wisata' => $pagiWisata?->id_wisata,
                'nama_tempat' => $pagiWisata?->nama_wisata ?? ($day == 1 ? 'Museum Raja Ali Haji & Ikon Welcome to Batam' : 'Taman Rusa Sekupang & Kawasan Hijau'),
                'kategori' => 'Wisata Pagi Unggulan',
                'waktu_mulai' => '09:15',
                'waktu_selesai' => '11:30',
                'estimasi_biaya' => $pagiWisata?->harga_tiket_masuk ?? 15000,
                'catatan' => 'Menikmati udara sejuk dan spot foto ikonik Batam.',
                'is_kustom' => false,
            ]);

            // Santap Siang Kuliner Khas
            $siangResto = $availableRestoran->get($restoranIdx % max(1, $availableRestoran->count()));
            $restoranIdx++;
            DetailItinerary::create([
                'id_rencana' => $plan->id_rencana,
                'hari_ke' => $day,
                'urutan' => $order++,
                'tipe_item' => 'restoran',
                'id_restoran' => $siangResto?->id_restoran,
                'nama_tempat' => $siangResto?->nama_restoran ?? ($day == 1 ? 'Kuliner Mie Tarempa Khas Kepri' : 'Sentra Makan Siang Selera Melayu'),
                'kategori' => 'Kuliner Khas Batam',
                'waktu_mulai' => '12:00',
                'waktu_selesai' => '13:30',
                'estimasi_biaya' => $siangResto?->harga_makan_per_orang ?? 45000,
                'catatan' => 'Istirahat dan santap siang kuliner khas lokal.',
                'is_kustom' => false,
            ]);

            // Spot Sore: Wisata Pantai / Wisata Belanja
            $soreWisata = $availableWisata->get($wisataIdx % max(1, $availableWisata->count()));
            $wisataIdx++;
            DetailItinerary::create([
                'id_rencana' => $plan->id_rencana,
                'hari_ke' => $day,
                'urutan' => $order++,
                'tipe_item' => 'wisata',
                'id_wisata' => $soreWisata?->id_wisata,
                'nama_tempat' => $soreWisata?->nama_wisata ?? ($day == 1 ? 'Grand Batam Mall & Pusat Belanja Nagoya' : 'Kawasan Jembatan 1 Barelang & Sunset Senja'),
                'kategori' => 'Wisata Sore & Belanja',
                'waktu_mulai' => '14:30',
                'waktu_selesai' => '17:30',
                'estimasi_biaya' => $soreWisata?->harga_tiket_masuk ?? 10000,
                'catatan' => 'Jelajah destinasi wisata sore dan pemandangan senja.',
                'is_kustom' => false,
            ]);

            // Spot Malam: Santap Malam Seafood Kelong
            $malamResto = $availableRestoran->get($restoranIdx % max(1, $availableRestoran->count()));
            $restoranIdx++;
            DetailItinerary::create([
                'id_rencana' => $plan->id_rencana,
                'hari_ke' => $day,
                'urutan' => $order++,
                'tipe_item' => 'restoran',
                'id_restoran' => $malamResto?->id_restoran,
                'nama_tempat' => $malamResto?->nama_restoran ?? 'Seafood Kelong Tepi Laut Batam',
                'kategori' => 'Santap Malam Seafood',
                'waktu_mulai' => '18:30',
                'waktu_selesai' => '20:30',
                'estimasi_biaya' => $malamResto?->harga_makan_per_orang ?? 85000,
                'catatan' => 'Menikmati hidangan seafood segar dengan panorama laut malam hari.',
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

