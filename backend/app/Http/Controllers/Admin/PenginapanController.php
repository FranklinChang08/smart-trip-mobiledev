<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Fasilitas;
use App\Models\FotoDestinasi;
use App\Models\Kategori;
use App\Models\Kecamatan;
use App\Models\Penginapan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class PenginapanController extends Controller
{
    /**
     * Menampilkan daftar penginapan.
     */
    public function index(Request $request)
    {
        $admin = Auth::user();

        $query = Penginapan::with([
            'kecamatan',
            'kategoris',
            'fotoDestinasis',
            'fasilitas',
        ]);

        // Pencarian berdasarkan nama atau alamat.
        if ($request->filled('search')) {
            $search = $request->search;

            $query->where(function ($q) use ($search) {
                $q->where('nama_penginapan', 'like', "%{$search}%")
                    ->orWhere(
                        'alamat_detail_penginapan',
                        'like',
                        "%{$search}%"
                    );
            });
        }

        $penginapans = $query->latest()->paginate(10);

        return view(
            'admin.penginapan.penginapan',
            compact('admin', 'penginapans')
        );
    }

    /**
     * Menampilkan form tambah penginapan.
     */
    public function create()
    {
        $kecamatan = Kecamatan::all();

        $categories = Kategori::where(
            'jenis_kategori',
            'penginapan'
        )->get();

        $fasilitas = Fasilitas::orderBy('nama_fasilitas')->get();

        $selectedCategories = old('categories', []);
        $selectedFasilitas = old('fasilitas', []);

        return view(
            'admin.penginapan.form-penginapan',
            compact(
                'kecamatan',
                'categories',
                'fasilitas',
                'selectedCategories',
                'selectedFasilitas'
            )
        );
    }

    /**
     * Menyimpan penginapan baru.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'nama_penginapan' => ['required', 'string', 'max:255',],
            'id_kecamatan' => ['required', 'integer', 'exists:kecamatan,id_kecamatan',],
            'type_penginapan' => ['required', 'in:Hotel,Resort,Villa,Guest House,Hostel,Homestay',],
            'harga_penginapan' => ['nullable', 'numeric', 'min:0',],
            'alamat_detail_penginapan' => ['required', 'string',],
            'latitude' => ['required', 'numeric', 'between:-90,90',],
            'longitude' => ['required', 'numeric', 'between:-180,180',],
            'link_on_maps' => ['nullable', 'url', 'max:2048',],
            'deskripsi' => ['nullable', 'string',],
            'categories' => ['required', 'array', 'min:1',],
            'categories.*' => ['required', 'integer', 'distinct', 'exists:kategori,id_kategori',],
            'fasilitas' => ['nullable', 'array',],
            'fasilitas.*' => ['required', 'integer', 'distinct', 'exists:fasilitas,id_fasilitas',],
            'foto_destinasi' => ['nullable', 'array', 'max:10',],
            'foto_destinasi.*' => ['required', 'image', 'mimes:jpg,jpeg,png', 'max:5120',],
        ], [
            'nama_penginapan.required' => 'Nama penginapan wajib diisi.',
            'id_kecamatan.required' => 'Kecamatan wajib dipilih.',
            'id_kecamatan.exists' => 'Kecamatan yang dipilih tidak valid.',
            'type_penginapan.required' => 'Tipe penginapan wajib dipilih.',
            'type_penginapan.in' => 'Tipe penginapan yang dipilih tidak valid.',
            'harga_penginapan.numeric' => 'Harga penginapan harus berupa angka.',
            'alamat_detail_penginapan.required' => 'Alamat penginapan wajib diisi.',
            'latitude.required' => 'Latitude wajib diisi.',
            'longitude.required' => 'Longitude wajib diisi.',
            'link_on_maps.url' => 'Link Maps harus berupa URL yang valid.',
            'categories.required' => 'Pilih minimal satu kategori penginapan.',
            'categories.min' => 'Pilih minimal satu kategori penginapan.',
            'categories.*.exists' => 'Kategori yang dipilih tidak ditemukan.',
            'fasilitas.*.exists' => 'Fasilitas yang dipilih tidak ditemukan.',
            'foto_destinasi.max' => 'Maksimal 10 foto yang dapat diunggah.',
            'foto_destinasi.*.image' => 'File harus berupa gambar.',
            'foto_destinasi.*.mimes' => 'Format foto harus JPG, JPEG, atau PNG.',
            'foto_destinasi.*.max' => 'Ukuran setiap foto maksimal 5 MB.',
        ]);

        $storedPaths = [];

        try {
            DB::transaction(function () use ($validated, $request, &$storedPaths) {
                // 1. Simpan data utama penginapan.
                $penginapan = Penginapan::create([
                    'id_penginapan' => (string) Str::uuid(),
                    'id_kecamatan' => $validated['id_kecamatan'],
                    'nama_penginapan' => $validated['nama_penginapan'],
                    'alamat_detail_penginapan' =>
                        $validated['alamat_detail_penginapan'],
                    'latitude' => $validated['latitude'],
                    'longitude' => $validated['longitude'],
                    'link_on_maps' =>
                        $validated['link_on_maps'] ?? null,
                    'harga_penginapan' =>
                        $validated['harga_penginapan'] ?? null,
                    'type_penginapan' => $validated['type_penginapan'],
                    'deskripsi' => $validated['deskripsi'] ?? null,
                ]);

                // 2. Simpan relasi kategori.
                $penginapan->kategoris()->sync(
                    $validated['categories']
                );

                // 3. Simpan relasi fasilitas.
                $penginapan->fasilitas()->sync(
                    $validated['fasilitas'] ?? []
                );

                // 4. Simpan foto penginapan jika tersedia.
                foreach (
                    $request->file('foto_destinasi', []) ?? []
                    as $file
                ) {
                    $path = $file->store(
                        'penginapan/' . $penginapan->id_penginapan,
                        'public'
                    );

                    if ($path === false) {
                        throw new \RuntimeException(
                            'Gagal menyimpan foto penginapan.'
                        );
                    }

                    $storedPaths[] = $path;

                    FotoDestinasi::create([
                        'id_photo' => (string) Str::uuid(),
                        'destinasi_id' => $penginapan->id_penginapan,
                        'destinasi_type' => $penginapan->getMorphClass(),
                        'link_photo' => $path,
                    ]);
                }
            });
        } catch (\Throwable $e) {
            Storage::disk('public')->delete($storedPaths);

            report($e);

            return back()
                ->withInput($request->except('foto_destinasi'))
                ->with(
                    'error',
                    'Data penginapan gagal disimpan. Periksa data dan coba lagi.' . $e
                );
        }

        return redirect()
            ->route('admin.penginapan.index')
            ->with('success', 'Data penginapan berhasil disimpan.');
    }

    /**
     * Menampilkan form detail atau edit penginapan.
     */
    public function show($id)
    {
        $penginapan = Penginapan::with([
            'kecamatan',
            'fotoDestinasis',
            'kategoris',
            'fasilitas',
        ])->findOrFail($id);

        $kecamatan = Kecamatan::all();

        $categories = Kategori::where(
            'jenis_kategori',
            'penginapan'
        )->get();

        $fasilitas = Fasilitas::orderBy('nama_fasilitas')->get();

        $selectedCategories = old(
            'categories',
            $penginapan->kategoris
                ->pluck('id_kategori')
                ->toArray()
        );

        $selectedFasilitas = old(
            'fasilitas',
            $penginapan->fasilitas
                ->pluck('id_fasilitas')
                ->toArray()
        );

        $fotoDestinasi = $penginapan->fotoDestinasis;

        return view(
            'admin.penginapan.form-penginapan',
            compact(
                'penginapan',
                'kecamatan',
                'categories',
                'fasilitas',
                'selectedCategories',
                'selectedFasilitas',
                'fotoDestinasi'
            )
        );
    }

    /**
     * Memperbarui data penginapan.
     */
    public function update(Request $request, $id)
    {
        $penginapan = Penginapan::findOrFail($id);

        $validated = $request->validate([
            'nama_penginapan' => ['required', 'string', 'max:255',],
            'id_kecamatan' => ['required', 'integer', 'exists:kecamatan,id_kecamatan',],
            'type_penginapan' => ['required', 'in:Hotel,Resort,Villa,Guest House,Hostel,Homestay',],
            'harga_penginapan' => ['nullable', 'numeric', 'min:0',],
            'alamat_detail_penginapan' => ['required', 'string',],
            'latitude' => ['required', 'numeric', 'between:-90,90',],
            'longitude' => ['required', 'numeric', 'between:-180,180',],
            'link_on_maps' => ['nullable', 'url', 'max:2048',],
            'deskripsi' => ['nullable', 'string',],
            'categories' => ['required', 'array', 'min:1',],
            'categories.*' => ['required', 'integer', 'distinct', 'exists:kategori,id_kategori',],
            'fasilitas' => ['nullable', 'array',],
            'fasilitas.*' => ['required', 'integer', 'distinct', 'exists:fasilitas,id_fasilitas',],
            'foto_destinasi' => ['nullable', 'array', 'max:10',],
            'foto_destinasi.*' => ['required', 'image', 'mimes:jpg,jpeg,png', 'max:5120',],
        ], [
            'nama_penginapan.required' => 'Nama penginapan wajib diisi.',
            'id_kecamatan.required' => 'Kecamatan wajib dipilih.',
            'id_kecamatan.exists' => 'Kecamatan yang dipilih tidak valid.',
            'type_penginapan.required' => 'Tipe penginapan wajib dipilih.',
            'type_penginapan.in' => 'Tipe penginapan yang dipilih tidak valid.',
            'harga_penginapan.numeric' => 'Harga penginapan harus berupa angka.',
            'alamat_detail_penginapan.required' => 'Alamat penginapan wajib diisi.',
            'latitude.required' => 'Latitude wajib diisi.',
            'longitude.required' => 'Longitude wajib diisi.',
            'link_on_maps.url' => 'Link Maps harus berupa URL yang valid.',
            'categories.required' => 'Pilih minimal satu kategori penginapan.',
            'categories.min' => 'Pilih minimal satu kategori penginapan.',
            'categories.*.exists' => 'Kategori yang dipilih tidak ditemukan.',
            'fasilitas.*.exists' => 'Fasilitas yang dipilih tidak ditemukan.',
            'foto_destinasi.max' => 'Maksimal 10 foto yang dapat diunggah.',
            'foto_destinasi.*.image' => 'File harus berupa gambar.',
            'foto_destinasi.*.mimes' => 'Format foto harus JPG, JPEG, atau PNG.',
            'foto_destinasi.*.max' => 'Ukuran setiap foto maksimal 5 MB.',
        ]);

        $storedPaths = [];

        try {
            DB::transaction(function () use ($validated, $request, &$storedPaths, $penginapan) {
                // 1. Perbarui data utama penginapan.
                $penginapan->update([
                    'id_kecamatan' => $validated['id_kecamatan'],
                    'nama_penginapan' => $validated['nama_penginapan'],
                    'alamat_detail_penginapan' =>
                        $validated['alamat_detail_penginapan'],
                    'latitude' => $validated['latitude'],
                    'longitude' => $validated['longitude'],
                    'link_on_maps' =>
                        $validated['link_on_maps'] ?? null,
                    'harga_penginapan' =>
                        $validated['harga_penginapan'] ?? null,
                    'type_penginapan' => $validated['type_penginapan'],
                    'deskripsi' => $validated['deskripsi'] ?? null,
                ]);

                // 2. Sinkronisasi kategori.
                $penginapan->kategoris()->sync(
                    $validated['categories']
                );

                // 3. Sinkronisasi fasilitas.
                $penginapan->fasilitas()->sync(
                    $validated['fasilitas'] ?? []
                );

                // 4. Tambahkan foto baru jika tersedia.
                foreach (
                    $request->file('foto_destinasi', []) ?? []
                    as $file
                ) {
                    $path = $file->store(
                        'penginapan/' . $penginapan->id_penginapan,
                        'public'
                    );

                    if ($path === false) {
                        throw new \RuntimeException(
                            'Gagal menyimpan foto penginapan.'
                        );
                    }

                    $storedPaths[] = $path;

                    FotoDestinasi::create([
                        'id_photo' => (string) Str::uuid(),
                        'destinasi_id' => $penginapan->id_penginapan,
                        'destinasi_type' => $penginapan->getMorphClass(),
                        'link_photo' => $path,
                    ]);
                }
            });
        } catch (\Throwable $e) {
            Storage::disk('public')->delete($storedPaths);

            report($e);

            return back()
                ->withInput($request->except('foto_destinasi'))
                ->with(
                    'error',
                    'Data penginapan gagal diperbarui. Periksa data dan coba lagi.'
                );
        }

        return redirect()
            ->route('admin.penginapan.index')
            ->with('success', 'Data penginapan berhasil diperbarui.');
    }

    /**
     * Menghapus data penginapan beserta foto dan relasinya.
     */
    public function destroy($id)
    {
        $paths = [];

        try {
            DB::transaction(function () use ($id, &$paths) {
                $penginapan = Penginapan::with([
                    'fotoDestinasis',
                    'kategoris',
                    'fasilitas',
                ])->findOrFail($id);

                // 1. Kumpulkan path foto dan hapus record foto.
                foreach ($penginapan->fotoDestinasis as $foto) {
                    $path = $foto->link_photo ?? $foto->path_foto;

                    if ($path) {
                        $paths[] = $path;
                    }

                    $foto->delete();
                }

                // 2. Putus relasi kategori dan fasilitas.
                $penginapan->kategoris()->detach();
                $penginapan->fasilitas()->detach();

                // 3. Hapus data penginapan.
                $penginapan->delete();
            });

            // Hapus file setelah transaksi database berhasil.
            Storage::disk('public')->delete($paths);

            // Hapus direktori penginapan jika sudah tidak diperlukan.
            $directory = 'penginapan/' . $id;

            if (Storage::disk('public')->exists($directory)) {
                Storage::disk('public')->deleteDirectory($directory);
            }

            if (request()->expectsJson()) {
                return response()->json([
                    'success' => true,
                    'message' =>
                        'Data penginapan beserta foto dan relasinya berhasil dihapus.',
                ]);
            }

            return redirect()
                ->route('admin.penginapan.index')
                ->with(
                    'success',
                    'Data penginapan beserta foto dan relasinya berhasil dihapus.'
                );
        } catch (\Throwable $e) {
            report($e);

            if (request()->expectsJson()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Gagal menghapus data penginapan.',
                ]);
            }

            return back()->with(
                'error',
                'Terjadi kesalahan saat menghapus data penginapan.'
            );
        }
    }
}