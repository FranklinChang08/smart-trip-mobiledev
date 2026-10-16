<?php

namespace App\Http\Controllers;

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
            'fotoDestinasis',
            'jamOperasis',
        ])->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $wisata,
        ]);
    }
}