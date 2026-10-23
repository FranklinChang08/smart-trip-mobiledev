<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Fasilitas;
use Illuminate\Http\Request;

class FasilitasController extends Controller
{
    public function store(Request $request)
    {
        $validated = $request->validate([
            'nama_fasilitas' => 'required|string|max:100|unique:fasilitas,nama_fasilitas',
        ], [
            'nama_fasilitas.required' => 'Nama fasilitas wajib diisi.',
            'nama_fasilitas.max' => 'Nama fasilitas maksimal 100 karakter.',
            'nama_fasilitas.unique' => 'Fasilitas ini sudah ada dalam daftar.',
        ]);

        try {
            $fasilitas = Fasilitas::create([
                'nama_fasilitas' => trim($validated['nama_fasilitas']),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Fasilitas berhasil ditambahkan.',
                'fasilitas' => [
                    'id' => $fasilitas->id_fasilitas,
                    'nama_fasilitas' => $fasilitas->nama_fasilitas,
                ],
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal menyimpan fasilitas: ' . $e->getMessage(),
            ], 500);
        }
    }
}