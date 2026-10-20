<?php

namespace App\Http\Controllers;

use App\Models\Kategori;
use App\Models\Wisata;
use Illuminate\Http\Request;

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

        // Menyesuaikan data agar lebih mudah digunakan Flutter
        $data = $wisata->map(function ($item) {
            $result = $item->toArray();

            $result['kategori'] = $item->kategoris
                ->pluck('nama_kategori')
                ->first() ?? 'Wisata';

            return $result;
        });

        return response()->json([
            'success' => true,
            'data' => $data,
        ]);
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

    public function showKategori()
    {
        $kategori = Kategori::orderBy('nama_kategori')->get();

        return response()->json([
            'success' => true,
            'data' => $kategori,
        ]);
    }
}