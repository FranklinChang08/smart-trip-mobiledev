<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Kategori;
use Illuminate\Http\Request;

class KategoriController extends Controller
{
    public function store(Request $request)
    {
        // Validasi input
        $validated = $request->validate([
            'nama_kategori' => 'required|string|max:255',
            'jenis_kategori' => 'required|in:wisata,restoran',
        ], [
            'nama_kategori.required' => 'Nama kategori wajib diisi.',
            'jenis_kategori.required' => 'Jenis kategori tidak valid.',
        ]);

        try {
            // Simpan ke database
            $kategori = Kategori::create([
                'nama_kategori' => $validated['nama_kategori'],
                'jenis_kategori' => $validated['jenis_kategori'],
            ]);

            // Kirim kembali response JSON agar dibaca oleh AJAX JavaScript
            return response()->json([
                'success' => true,
                'message' => 'Kategori berhasil ditambahkan.',
                'kategori' => [
                    'id' => $kategori->id_kategori, // Sesuaikan dengan increments('id_kategori')
                    'nama_kategori' => $kategori->nama_kategori,
                    'jenis_kategori' => $kategori->jenis_kategori,
                ]
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal menyimpan kategori: ' . $e->getMessage()
            ], 500);
        }
    }
}
