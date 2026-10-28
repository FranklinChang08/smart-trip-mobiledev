<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Fasilitas;
use App\Models\FotoDestinasi;
use App\Models\Kategori;
use App\Models\Kecamatan;
use App\Models\LokasiTransportasi;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class LokasiTransportasiController extends Controller
{
    public function index(Request $request)
    {
        $admin = Auth::user();

        $query = LokasiTransportasi::with([
            'kecamatan',
            'fotoDestinasis',
            'fasilitas',
        ]);

        // Pencarian berdasarkan nama atau alamat.
        if ($request->filled('search')) {
            $search = $request->search;

            $query->where(function ($q) use ($search) {
                $q->where('nama_lokasi', 'like', "%{$search}%")
                    ->orWhere(
                        'alamat_detail_lokasi',
                        'like',
                        "%{$search}%"
                    );
            });
        }

        $lokasi_transportasi = $query->latest()->paginate(10);

        return view(
            'admin.lokasi.lokasi',
            compact('admin', 'lokasi_transportasi')
        );
    }

    /**
     * Menampilkan form tambah lokasi.
     */
    public function create()
    {
        $kecamatan = Kecamatan::all();

        $fasilitas = Fasilitas::orderBy('nama_fasilitas')->get();

        $selectedFasilitas = old('fasilitas', []);

        return view(
            'admin.lokasi.form-lokasi',
            compact(
                'kecamatan',
                'fasilitas',
                'selectedFasilitas'
            )
        );
    }

    /**
     * Menyimpan lokasi baru.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'nama_lokasi' => ['required', 'string', 'max:255',],
            'id_kecamatan' => ['required', 'integer', 'exists:kecamatan,id_kecamatan',],
            'type_lokasi' => ['required', 'in:Bandara,Pelabuhan,Terminal Bus,Stasiun'],
            'harga_lokasi' => ['nullable', 'numeric', 'min:0',],
            'alamat_detail_lokasi' => ['required', 'string',],
            'latitude' => ['required', 'numeric', 'between:-90,90',],
            'longitude' => ['required', 'numeric', 'between:-180,180',],
            'link_on_maps' => ['nullable', 'url', 'max:2048',],
            'deskripsi' => ['nullable', 'string',],
            'fasilitas' => ['nullable', 'array',],
            'fasilitas.*' => ['required', 'integer', 'distinct', 'exists:fasilitas,id_fasilitas',],
            'foto_destinasi' => ['nullable', 'array', 'max:10',],
            'foto_destinasi.*' => ['required', 'image', 'mimes:jpg,jpeg,png', 'max:5120',],
        ], [
            'nama_lokasi.required' => 'Nama lokasi wajib diisi.',
            'id_kecamatan.required' => 'Kecamatan wajib dipilih.',
            'id_kecamatan.exists' => 'Kecamatan yang dipilih tidak valid.',
            'type_lokasi.required' => 'Tipe lokasi wajib dipilih.',
            'type_lokasi.in' => 'Tipe lokasi yang dipilih tidak valid.',
            'harga_lokasi.numeric' => 'Harga lokasi harus berupa angka.',
            'alamat_detail_lokasi.required' => 'Alamat lokasi wajib diisi.',
            'latitude.required' => 'Latitude wajib diisi.',
            'longitude.required' => 'Longitude wajib diisi.',
            'link_on_maps.url' => 'Link Maps harus berupa URL yang valid.',
            'fasilitas.*.exists' => 'Fasilitas yang dipilih tidak ditemukan.',
            'foto_destinasi.max' => 'Maksimal 10 foto yang dapat diunggah.',
            'foto_destinasi.*.image' => 'File harus berupa gambar.',
            'foto_destinasi.*.mimes' => 'Format foto harus JPG, JPEG, atau PNG.',
            'foto_destinasi.*.max' => 'Ukuran setiap foto maksimal 5 MB.',
        ]);

        $storedPaths = [];

        try {
            DB::transaction(function () use ($validated, $request, &$storedPaths) {
                // 1. Simpan data utama lokasi.
                $lokasi_transportasi = LokasiTransportasi::create([
                    'id_lokasi' => (string) Str::uuid(),
                    'id_kecamatan' => $validated['id_kecamatan'],
                    'nama_lokasi' => $validated['nama_lokasi'],
                    'alamat_detail_lokasi' =>
                        $validated['alamat_detail_lokasi'],
                    'latitude' => $validated['latitude'],
                    'longitude' => $validated['longitude'],
                    'link_on_maps' =>
                        $validated['link_on_maps'] ?? null,
                    'harga_lokasi' =>
                        $validated['harga_lokasi'] ?? null,
                    'type_lokasi' => $validated['type_lokasi'],
                    'deskripsi' => $validated['deskripsi'] ?? null,
                ]);

                // 3. Simpan relasi fasilitas.
                $lokasi_transportasi->fasilitas()->sync(
                    $validated['fasilitas'] ?? []
                );

                foreach (
                    $request->file('foto_destinasi', []) ?? []
                    as $file
                ) {
                    $path = $file->store(
                        'lokasi/' . $lokasi_transportasi->id_lokasi,
                        'public'
                    );

                    if ($path === false) {
                        throw new \RuntimeException(
                            'Gagal menyimpan foto lokasi.'
                        );
                    }

                    $storedPaths[] = $path;

                    FotoDestinasi::create([
                        'id_photo' => (string) Str::uuid(),
                        'destinasi_id' => $lokasi_transportasi->id_lokasi,
                        'destinasi_type' => $lokasi_transportasi->getMorphClass(),
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
                    'Data lokasi gagal disimpan. Periksa data dan coba lagi.' . $e
                );
        }

        return redirect()
            ->route('admin.lokasi.index')
            ->with('success', 'Data lokasi berhasil disimpan.');
    }

    /**
     * Menampilkan form detail atau edit lokasi.
     */
    public function show($id)
    {
        $lokasi_transportasi = LokasiTransportasi::with([
            'kecamatan',
            'fotoDestinasis',
            'fasilitas',
        ])->findOrFail($id);

        $kecamatan = Kecamatan::all();

        $fasilitas = Fasilitas::orderBy('nama_fasilitas')->get();

        $fotoDestinasi = $lokasi_transportasi->fotoDestinasis;
        $selectedFasilitas = old(
            'fasilitas',
            $lokasi_transportasi->fasilitas
                ->pluck('id_fasilitas')
                ->toArray()
        );

        return view(
            'admin.lokasi.form-lokasi',
            compact(
                'lokasi_transportasi',
                'kecamatan',
                'fotoDestinasi',
                'selectedFasilitas',
                'fasilitas',
            )
        );
    }

    /**
     * Memperbarui data lokasi.
     */
    public function update(Request $request, $id)
    {
        $lokasi_transportasi = LokasiTransportasi::findOrFail($id);

        $validated = $request->validate([
            'nama_lokasi' => ['required', 'string', 'max:255',],
            'id_kecamatan' => ['required', 'integer', 'exists:kecamatan,id_kecamatan',],
            'type_lokasi' => ['required', 'in:Bandara,Pelabuhan,Terminal Bus,Stasiun'],
            'harga_lokasi' => ['nullable', 'numeric', 'min:0',],
            'alamat_detail_lokasi' => ['required', 'string',],
            'latitude' => ['required', 'numeric', 'between:-90,90',],
            'longitude' => ['required', 'numeric', 'between:-180,180',],
            'link_on_maps' => ['nullable', 'url', 'max:2048',],
            'deskripsi' => ['nullable', 'string',],
            'fasilitas' => ['nullable', 'array',],
            'fasilitas.*' => ['required', 'integer', 'distinct', 'exists:fasilitas,id_fasilitas',],
            'foto_destinasi' => ['nullable', 'array', 'max:10',],
            'foto_destinasi.*' => ['required', 'image', 'mimes:jpg,jpeg,png', 'max:5120',],
        ], [
            'nama_lokasi.required' => 'Nama lokasi wajib diisi.',
            'id_kecamatan.required' => 'Kecamatan wajib dipilih.',
            'id_kecamatan.exists' => 'Kecamatan yang dipilih tidak valid.',
            'type_lokasi.required' => 'Tipe lokasi wajib dipilih.',
            'type_lokasi.in' => 'Tipe lokasi yang dipilih tidak valid.',
            'harga_lokasi.numeric' => 'Harga lokasi harus berupa angka.',
            'alamat_detail_lokasi.required' => 'Alamat lokasi wajib diisi.',
            'latitude.required' => 'Latitude wajib diisi.',
            'longitude.required' => 'Longitude wajib diisi.',
            'link_on_maps.url' => 'Link Maps harus berupa URL yang valid.',
            'fasilitas.*.exists' => 'Fasilitas yang dipilih tidak ditemukan.',
            'foto_destinasi.max' => 'Maksimal 10 foto yang dapat diunggah.',
            'foto_destinasi.*.image' => 'File harus berupa gambar.',
            'foto_destinasi.*.mimes' => 'Format foto harus JPG, JPEG, atau PNG.',
            'foto_destinasi.*.max' => 'Ukuran setiap foto maksimal 5 MB.',
        ]);

        $storedPaths = [];

        try {
            DB::transaction(function () use ($validated, $request, &$storedPaths, $lokasi_transportasi) {
                // 1. Perbarui data utama lokasi.
                $lokasi_transportasi->update([
                    'id_kecamatan' => $validated['id_kecamatan'],
                    'nama_lokasi' => $validated['nama_lokasi'],
                    'alamat_detail_lokasi' =>
                        $validated['alamat_detail_lokasi'],
                    'latitude' => $validated['latitude'],
                    'longitude' => $validated['longitude'],
                    'link_on_maps' =>
                        $validated['link_on_maps'] ?? null,
                    'harga_lokasi' =>
                        $validated['harga_lokasi'] ?? null,
                    'type_lokasi' => $validated['type_lokasi'],
                    'deskripsi' => $validated['deskripsi'] ?? null,
                ]);

                // 2. Sinkronisasi kategori.
                $lokasi_transportasi->kategoris()->sync(
                    $validated['categories']
                );

                // 3. Sinkronisasi fasilitas.
                $lokasi_transportasi->fasilitas()->sync(
                    $validated['fasilitas'] ?? []
                );
                // 4. Tambahkan foto baru jika tersedia.
                foreach (
                    $request->file('foto_destinasi', []) ?? []
                    as $file
                ) {
                    $path = $file->store(
                        'lokasi/' . $lokasi_transportasi->id_lokasi,
                        'public'
                    );

                    if ($path === false) {
                        throw new \RuntimeException(
                            'Gagal menyimpan foto lokasi.'
                        );
                    }

                    $storedPaths[] = $path;

                    FotoDestinasi::create([
                        'id_photo' => (string) Str::uuid(),
                        'destinasi_id' => $lokasi_transportasi->id_lokasi,
                        'destinasi_type' => $lokasi_transportasi->getMorphClass(),
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
                    'Data lokasi gagal diperbarui. Periksa data dan coba lagi.'
                );
        }

        return redirect()
            ->route('admin.lokasi.index')
            ->with('success', 'Data lokasi berhasil diperbarui.');
    }

    /**
     * Menghapus data lokasi beserta foto dan relasinya.
     */
    public function destroy($id)
    {
        $paths = [];

        try {
            DB::transaction(function () use ($id, &$paths) {
                $lokasi_transportasi = LokasiTransportasi::with([
                    'fasilitas',
                ])->findOrFail($id);

                // 1. Kumpulkan path foto dan hapus record foto.
                foreach ($lokasi_transportasi->fotoDestinasis as $foto) {
                    $path = $foto->link_photo ?? $foto->path_foto;

                    if ($path) {
                        $paths[] = $path;
                    }

                    $foto->delete();
                }

                // 2. Putus relasi kategori dan fasilitas.
                $lokasi_transportasi->fasilitas()->detach();

                // 3. Hapus data lokasi.
                $lokasi_transportasi->delete();
            });
            return redirect()
                ->route('admin.lokasi.index')
                ->with(
                    'success',
                    'Data lokasi beserta foto dan relasinya berhasil dihapus.'
                );
        } catch (\Throwable $e) {
            report($e);

            if (request()->expectsJson()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Gagal menghapus data lokasi.',
                ]);
            }

            return back()->with(
                'error',
                'Terjadi kesalahan saat menghapus data lokasi.'
            );
        }
    }
}
