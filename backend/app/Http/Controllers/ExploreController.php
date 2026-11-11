<?php

namespace App\Http\Controllers;

use App\Models\Kategori;
use App\Models\LokasiTransportasi;
use App\Models\Penginapan;
use App\Models\Restoran;
use App\Models\Wisata;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class ExploreController extends Controller
{
    public function index(Request $request)
    {
        $query = Wisata::with([
            'kecamatan',
            'kategoris',
            'fotoDestinasis',
            'jamOperasis',
        ]);

        // Pencarian berdasarkan nama wisata atau alamat
        if ($request->filled('search')) {
            $search = $request->search;

            $query->where(function ($q) use ($search) {
                $q->where('nama_wisata', 'like', "%{$search}%")
                    ->orWhere(
                        'alamat_detail_wisata',
                        'like',
                        "%{$search}%"
                    );
            });
        }

        // Filter berdasarkan nama kategori
        if ($request->filled('kategori')) {
            $kategori = $request->kategori;

            $query->whereHas('kategoris', function ($q) use ($kategori) {
                $q->where('nama_kategori', $kategori);
            });
        }

        $wisata = $query->get();

        $data = $wisata->map(function ($item) {
            $result = $item->toArray();

            $result['kategori'] = $item->kategoris
                ->pluck('nama_kategori')
                ->first() ?? 'Wisata Alam';

            return $result;
        });

        return response()->json([
            'success' => true,
            'message' => 'Data destinasi wisata berhasil diambil.',
            'data' => $data,
        ], 200);
    }

    public function indexRestoran(Request $request)
    {
        $query = Restoran::with([
            'kecamatan',
            'kategoris',
            'fasilitas',
            'jamOperasis',
            'fotoDestinasis',
        ]);

        // Pencarian berdasarkan nama wisata atau alamat
        if ($request->filled('search')) {
            $search = $request->search;

            $query->where(function ($q) use ($search) {
                $q->where('nama_restoran', 'like', "%{$search}%")
                    ->orWhere(
                        'alamat_detail_restoran',
                        'like',
                        "%{$search}%"
                    );
            });
        }

        // Filter berdasarkan nama kategori
        if ($request->filled('kategori')) {
            $kategori = $request->kategori;

            $query->whereHas('kategoris', function ($q) use ($kategori) {
                $q->where('nama_kategori', $kategori);
            });
        }

        $restoran = $query->get();

        $data = $restoran->map(function ($item) {
            $result = $item->toArray();

            $result['kategori'] = $item->kategoris
                ->pluck('nama_kategori')
                ->first() ?? 'Restoran';

            return $result;
        });

        return response()->json([
            'success' => true,
            'message' => 'Data restoran berhasil diambil.',
            'data' => $data,
        ], 200);
    }

    public function show(string $id)
    {
        $wisata = Wisata::with([
            'kecamatan',
            'kategoris',
            'jamOperasis',
            'fotoDestinasis',
        ])->find($id);

        if (!$wisata) {
            return response()->json([
                'message' => 'Destinasi wisata tidak ditemukan.',
            ], 404);
        }

        return response()->json([
            'message' => 'Detail destinasi wisata berhasil diambil.',
            'data' => $wisata,
        ], 200);
    }

    public function showRestoran(string $id)
    {
        $restoran = Restoran::with([
            'kecamatan',
            'kategoris',
            'fasilitas',
            'jamOperasis',
            'fotoDestinasis',
        ])->find($id);

        if (!$restoran) {
            return response()->json([
                'message' => 'Restoran tidak ditemukan.',
            ], 404);
        }

        return response()->json([
            'message' => 'Detail restoran berhasil diambil.',
            'data' => $restoran,
        ], 200);
    }

    public function showKategori()
    {
        $kategori = Kategori::orderBy('nama_kategori')->get();

        return response()->json([
            'success' => true,
            'data' => $kategori,
        ]);
    }

    public function getTitikLokasi(Request $request)
    {
        $search = $request->query('search');

        $transportQuery = LokasiTransportasi::with('kecamatan');
        $hotelQuery = Penginapan::with('kecamatan');

        if ($search) {
            $transportQuery->where(function ($q) use ($search) {
                $q->where('nama_lokasi', 'like', "%{$search}%")
                    ->orWhere('alamat_detail_lokasi', 'like', "%{$search}%");
            });
            $hotelQuery->where(function ($q) use ($search) {
                $q->where('nama_penginapan', 'like', "%{$search}%")
                    ->orWhere('alamat_detail_penginapan', 'like', "%{$search}%");
            });
        }

        $transports = $transportQuery->get()->map(function ($item) {
            $cat = strtolower($item->type_lokasi ?? 'pelabuhan');
            $kecName = $item->kecamatan?->nama_kecamatan ?? 'Batam';
            return [
                'id' => $item->id_lokasi,
                'name' => $item->nama_lokasi,
                'type' => "{$item->type_lokasi} • {$kecName}",
                'category' => $cat,
                'model_type' => LokasiTransportasi::class,
                'id_kecamatan' => $item->id_kecamatan,
                'nama_kecamatan' => $kecName,
                'alamat' => $item->alamat_detail_lokasi,
                'latitude' => $item->latitude,
                'longitude' => $item->longitude,
                'deskripsi' => $item->deskripsi,
                'link_on_maps' => $item->link_on_maps,
                'is_quick' => in_array($cat, ['pelabuhan', 'bandara']),
                'quick_label' => Str::limit($item->nama_lokasi, 18),
            ];
        });

        $hotels = $hotelQuery->get()->map(function ($item) {
            $cat = strtolower($item->type_penginapan ?? 'hotel');
            $kecName = $item->kecamatan?->nama_kecamatan ?? 'Batam';
            return [
                'id' => $item->id_penginapan,
                'name' => $item->nama_penginapan,
                'type' => "{$item->type_penginapan} • {$kecName}",
                'category' => $cat,
                'model_type' => Penginapan::class,
                'id_kecamatan' => $item->id_kecamatan,
                'nama_kecamatan' => $kecName,
                'alamat' => $item->alamat_detail_penginapan,
                'latitude' => $item->latitude,
                'longitude' => $item->longitude,
                'deskripsi' => $item->deskripsi,
                'harga' => $item->harga_penginapan,
                'link_on_maps' => $item->link_on_maps,
                'is_quick' => str_contains(strtolower($item->nama_penginapan), 'harris') || str_contains(strtolower($item->nama_penginapan), 'aston'),
                'quick_label' => Str::limit($item->nama_penginapan, 18),
            ];
        });

        $merged = $transports->concat($hotels)->values();

        return response()->json([
            'success' => true,
            'message' => 'Daftar titik lokasi berhasil diambil.',
            'data' => $merged,
        ]);
    }

    public function showTitikLokasi(string $id)
    {
        $transport = LokasiTransportasi::with(['kecamatan', 'fotoDestinasis', 'fasilitas'])->find($id);
        if ($transport) {
            return response()->json([
                'success' => true,
                'data' => array_merge($transport->toArray(), [
                    'model_type' => LokasiTransportasi::class,
                    'is_hotel' => false,
                ]),
            ]);
        }

        $penginapan = Penginapan::with(['kecamatan', 'fotoDestinasis', 'kategoris', 'fasilitas'])->find($id);
        if ($penginapan) {
            return response()->json([
                'success' => true,
                'data' => array_merge($penginapan->toArray(), [
                    'model_type' => Penginapan::class,
                    'is_hotel' => true,
                ]),
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => 'Lokasi tidak ditemukan.',
        ], 404);
    }
}