<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Fasilitas;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class FasilitasController extends Controller
{
    // Menampilkan daftar fasilitas
    public function index()
    {
        $fasilitas = Fasilitas::withCount([
            'restorans',
            'penginapans',
            'lokasiTransportasis',
        ])->paginate(10);

        // Menghitung total seluruh destinasi
        $fasilitas->getCollection()->transform(function ($item) {
            $item->total_destinasi =
                $item->restorans_count +
                $item->penginapans_count +
                $item->lokasi_transportasis_count;

            return $item;
        });

        return view('admin.fasilitas.fasilitas', compact('fasilitas'));
    }

    // Menampilkan form tambah fasilitas
    public function create()
    {
        return view('admin.fasilitas.form-fasilitas');
    }

    // Menyimpan fasilitas
    public function store(Request $request)
    {
        $validated = $request->validate([
            'nama_fasilitas' => 'required|string|max:255',
        ], [
            'nama_fasilitas.required' => 'Nama fasilitas wajib diisi.',
            'nama_fasilitas.string' => 'Nama fasilitas harus berupa teks.',
            'nama_fasilitas.max' => 'Nama fasilitas maksimal 255 karakter.',
        ]);

        try {
            Fasilitas::create([
                'nama_fasilitas' => $validated['nama_fasilitas'],
            ]);

            return redirect()
                ->route('admin.fasilitas.index')
                ->with('success', 'Fasilitas berhasil ditambahkan.');

        } catch (\Exception $e) {
            return redirect()
                ->back()
                ->withInput()
                ->with('error', 'Gagal menyimpan fasilitas: ' . $e->getMessage());
        }
    }

    // Menampilkan form edit fasilitas
    public function show($id)
    {
        $fasilitas = Fasilitas::findOrFail($id);

        return view('admin.fasilitas.form-fasilitas', compact('fasilitas'));
    }

    // Memperbarui fasilitas
    public function update(Request $request, $id)
    {
        $fasilitas = Fasilitas::findOrFail($id);

        $validated = $request->validate([
            'nama_fasilitas' => 'required|string|max:255',
        ], [
            'nama_fasilitas.required' => 'Nama fasilitas wajib diisi.',
            'nama_fasilitas.string' => 'Nama fasilitas harus berupa teks.',
            'nama_fasilitas.max' => 'Nama fasilitas maksimal 255 karakter.',
        ]);

        try {
            $fasilitas->update([
                'nama_fasilitas' => $validated['nama_fasilitas'],
            ]);

            return redirect()
                ->route('admin.fasilitas.index')
                ->with('success', 'Fasilitas berhasil diperbarui.');

        } catch (\Exception $e) {
            return redirect()
                ->back()
                ->withInput()
                ->with('error', 'Gagal memperbarui fasilitas: ' . $e->getMessage());
        }
    }

    // Menghapus fasilitas
    public function destroy($id)
    {
        $fasilitas = Fasilitas::findOrFail($id);

        try {
            DB::transaction(function () use ($fasilitas) {
                // Hapus relasi pivot, bukan data destinasi
                $fasilitas->restorans()->detach();
                $fasilitas->penginapans()->detach();
                $fasilitas->lokasiTransportasis()->detach();

                // Hapus fasilitas
                $fasilitas->delete();
            });

            return redirect()
                ->route('admin.fasilitas.index')
                ->with('success', 'Fasilitas berhasil dihapus.');

        } catch (\Exception $e) {
            return redirect()
                ->back()
                ->with('error', 'Gagal menghapus fasilitas: ' . $e->getMessage());
        }
    }
}