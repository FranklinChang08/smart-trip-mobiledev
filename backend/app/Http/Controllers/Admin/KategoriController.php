<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Kategori;
use Illuminate\Http\Request;

class KategoriController extends Controller
{
    public function index()
    {
        $kategoris = Kategori::withCount([
            'wisatas',
            'restorans',
            'penginapans',
        ])->paginate(10);

        $kategoris->transform(function ($kategori) {
            $kategori->total_destinasi =
                $kategori->wisatas_count +
                $kategori->restorans_count +
                $kategori->penginapans_count;

            return $kategori;
        });

        return view('admin.kategori.kategori', compact('kategoris'));
    }
    // Menampilkan form tambah kategori
    public function create()
    {
        return view('admin.kategori.form-kategori');
    }

    // Menyimpan kategori
    public function store(Request $request)
    {
        // Validasi input
        $validated = $request->validate([
            'nama_kategori' => 'required|string|max:255',
            'jenis_kategori' => 'required|in:wisata,restoran,penginapan',
        ], [
            'nama_kategori.required' => 'Nama kategori wajib diisi.',
            'nama_kategori.string' => 'Nama kategori harus berupa teks.',
            'nama_kategori.max' => 'Nama kategori maksimal 255 karakter.',
            'jenis_kategori.required' => 'Jenis kategori wajib dipilih.',
            'jenis_kategori.in' => 'Jenis kategori tidak valid.',
        ]);

        try {
            // Simpan ke database
            $kategori = Kategori::create([
                'nama_kategori' => $validated['nama_kategori'],
                'jenis_kategori' => $validated['jenis_kategori'],
            ]);

            // Cek jika request dari AJAX/Fetch
            if ($request->expectsJson() || $request->ajax()) {
                return response()->json([
                    'success' => true,
                    'message' => 'Kategori berhasil ditambahkan.',
                    'data' => $kategori
                ]);
            }

            return redirect()
                ->route('admin.kategori.index')
                ->with('success', 'Kategori berhasil ditambahkan.');

        } catch (\Exception $e) {
            if ($request->expectsJson() || $request->ajax()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Gagal menyimpan kategori: ' . $e->getMessage()
                ], 500);
            }

            return redirect()
                ->back()
                ->withInput()
                ->with('error', 'Gagal menyimpan kategori: ' . $e->getMessage());
        }
    }

    // Menampilkan form edit kategori
    public function show($id)
    {
        $kategoris = Kategori::findOrFail($id);

        return view('admin.kategori.form-kategori', compact('kategoris'));
    }

    // Memperbarui data kategori
    public function update(Request $request, $id)
    {
        // Cari kategori berdasarkan ID
        $kategori = Kategori::findOrFail($id);

        // Validasi input
        $validated = $request->validate([
            'nama_kategori' => 'required|string|max:255',
            'jenis_kategori' => 'required|in:wisata,restoran,penginapan',
        ], [
            'nama_kategori.required' => 'Nama kategori wajib diisi.',
            'nama_kategori.string' => 'Nama kategori harus berupa teks.',
            'nama_kategori.max' => 'Nama kategori maksimal 255 karakter.',
            'jenis_kategori.required' => 'Jenis kategori wajib dipilih.',
            'jenis_kategori.in' => 'Jenis kategori tidak valid.',
        ]);

        try {
            // Update data kategori
            $kategori->update([
                'nama_kategori' => $validated['nama_kategori'],
                'jenis_kategori' => $validated['jenis_kategori'],
            ]);

            return redirect()
                ->route('admin.kategori.index')
                ->with('success', 'Kategori berhasil diperbarui.');

        } catch (\Exception $e) {
            return redirect()
                ->back()
                ->withInput()
                ->with('error', 'Gagal memperbarui kategori: ' . $e->getMessage());
        }
    }

    // Menghapus kategori
    public function destroy($id)
    {
        try {
            // Cari kategori berdasarkan ID
            $kategori = Kategori::findOrFail($id);

            // Hapus kategori
            $kategori->delete();

            return redirect()
                ->route('admin.kategori.index')
                ->with('success', 'Kategori berhasil dihapus.');

        } catch (\Exception $e) {
            return redirect()
                ->back()
                ->with('error', 'Gagal menghapus kategori: ' . $e->getMessage());
        }
    }
}
