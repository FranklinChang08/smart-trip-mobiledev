<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Fasilitas;
use App\Models\FotoDestinasi;
use App\Models\JamOperasi;
use App\Models\Kategori;
use App\Models\Kecamatan;
use App\Models\Restoran;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Throwable;

class RestoranController extends Controller
{
    public function index(Request $request)
    {
        $admin = Auth::user();
        $query = Restoran::with(['kecamatan', 'kategoris', 'jamOperasis', 'fotoDestinasis', 'fasilitas']);

        // Fitur pencarian berdasarkan nama restoran atau alamat
        if ($request->has('search') && $request->search != '') {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('nama_restoran', 'like', "%{$search}%")
                    ->orWhere('alamat_Detail_restoran', 'like', "%{$search}%");
            });
        }

        $restorans = $query->latest()->paginate(10);
        return view('admin.restoran.restoran', compact('admin', 'restorans'));
    }

    public function create()
    {
        $kecamatan = Kecamatan::all();
        $categories = Kategori::where('jenis_kategori', 'restoran')->get();
        $fasilitas = Fasilitas::orderBy('nama_fasilitas')->get();

        // Ambil data yang sebelumnya sempat dipilih jika validasi gagal
        $selectedCategories = old('categories', []);
        $selectedFasilitas = old('fasilitas', []);

        return view('admin.restoran.form-restoran', compact(
            'kecamatan',
            'categories',
            'fasilitas',
            'selectedCategories',
            'selectedFasilitas'
        ));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'nama_restoran' => ['required', 'string', 'max:255'],
            'id_kecamatan' => [
                'required',
                'integer',
                'exists:kecamatan,id_kecamatan',
            ],
            'type_food' => ['required', 'in:Halal,Vegetarian,Semua'],
            'harga_makan_per_orang' => ['nullable', 'numeric', 'min:0'],
            'alamat_Detail_restoran' => ['required', 'string'],
            'latitude' => ['required', 'numeric'],
            'longitude' => ['required', 'numeric'],
            'link_on_maps' => [
                'required',
                'url',
                'max:2048',
            ],
            'deskripsi' => ['nullable', 'string'],

            // Kategori kuliner / restoran
            'categories' => ['required', 'array', 'min:1'],
            'categories.*' => [
                'required',
                'integer',
                'distinct',
                'exists:kategori,id_kategori',
            ],

            // Fasilitas restoran (many to many)
            'fasilitas' => ['nullable', 'array'],
            'fasilitas.*' => [
                'integer',
                'exists:fasilitas,id_fasilitas',
            ],

            // Jam operasional
            'jam_operasional' => ['required', 'array'],
            'jam_operasional.*' => [
                'required',
                'array:hari,is_open,jam_buka,jam_tutup',
            ],
            'jam_operasional.*.is_open' => [
                'required',
                'boolean',
            ],
            'jam_operasional.*.jam_buka' => [
                'nullable',
                'date_format:H:i',
            ],
            'jam_operasional.*.jam_tutup' => [
                'nullable',
                'date_format:H:i',
            ],

            // Foto destinasi
            'foto_destinasi' => ['nullable', 'array', 'max:10'],
            'foto_destinasi.*' => [
                'required',
                'image',
                'mimes:jpg,jpeg,png',
                'max:5120',
            ],
        ], [
            'nama_restoran.required' => 'Nama restoran wajib diisi.',
            'nama_restoran.max' => 'Nama restoran maksimal 255 karakter.',
            'id_kecamatan.required' => 'Kecamatan wajib dipilih.',
            'id_kecamatan.exists' => 'Kecamatan yang dipilih tidak valid.',
            'type_food.required' => 'Tipe makanan wajib dipilih.',
            'type_food.in' => 'Tipe makanan harus Halal, Vegetarian, atau Semua.',
            'alamat_Detail_restoran.required' => 'Alamat restoran wajib diisi.',
            'latitude.required' => 'Latitude wajib diisi.',
            'latitude.numeric' => 'Latitude harus berupa angka.',
            'longitude.required' => 'Longitude wajib diisi.',
            'longitude.numeric' => 'Longitude harus berupa angka.',
            'link_on_maps.required' => 'Link Maps wajib diisi.',
            'link_on_maps.url' => 'Link Maps harus berupa URL yang valid.',
            'categories.required' => 'Pilih minimal satu kategori kuliner.',
            'categories.min' => 'Pilih minimal satu kategori kuliner.',
            'categories.*.required' => 'Kategori tidak boleh kosong.',
            'categories.*.integer' => 'Kategori yang dipilih tidak valid.',
            'categories.*.distinct' => 'Kategori tidak boleh dipilih berulang.',
            'categories.*.exists' => 'Kategori yang dipilih tidak ditemukan.',
            'fasilitas.*.integer' => 'Fasilitas yang dipilih tidak valid.',
            'fasilitas.*.exists' => 'Fasilitas yang dipilih tidak ditemukan.',
            'jam_operasional.required' => 'Jam operasional wajib diisi.',
            'jam_operasional.*.is_open.required' => 'Status buka atau tutup wajib ditentukan.',
            'jam_operasional.*.jam_buka.date_format' => 'Format jam buka harus HH:MM.',
            'jam_operasional.*.jam_tutup.date_format' => 'Format jam tutup harus HH:MM.',
            'foto_destinasi.max' => 'Maksimal 10 foto yang dapat diunggah.',
            'foto_destinasi.*.image' => 'File harus berupa gambar.',
            'foto_destinasi.*.mimes' => 'Format foto harus JPG, JPEG, atau PNG.',
            'foto_destinasi.*.max' => 'Ukuran setiap foto maksimal 5 MB.',
        ]);

        $storedPaths = [];

        try {
            DB::transaction(function () use ($validated, $request, &$storedPaths) {
                // 1. Simpan data utama restoran
                $restoran = Restoran::create([
                    'id_restoran' => (string) Str::uuid(),
                    'id_kecamatan' => $validated['id_kecamatan'],
                    'nama_restoran' => $validated['nama_restoran'],
                    'alamat_Detail_restoran' => $validated['alamat_Detail_restoran'],
                    'latitude' => $validated['latitude'],
                    'longitude' => $validated['longitude'],
                    'link_on_maps' => $validated['link_on_maps'],
                    'harga_makan_per_orang' => $validated['harga_makan_per_orang'] ?? null,
                    'type_food' => $validated['type_food'],
                    'deskripsi' => $validated['deskripsi'] ?? null,
                ]);

                // 2. Simpan relasi kategori restoran
                $restoran->kategoris()->sync($validated['categories']);

                // 3. Simpan relasi fasilitas (many to many)
                if (!empty($validated['fasilitas'])) {
                    $restoran->fasilitas()->sync($validated['fasilitas']);
                }

                // 4. Simpan jam operasional
                $kelompokJadwal = $this->kelompokkanJadwal($validated['jam_operasional']);

                foreach ($kelompokJadwal as $jadwal) {
                    $restoran->jamOperasis()->create([
                        'id_operasi' => (string) Str::uuid(),
                        'hari_mulai' => $jadwal['hari_mulai'],
                        'hari_selesai' => $jadwal['hari_selesai'],
                        'is_open' => $jadwal['is_open'],
                        'jam_buka' => $jadwal['jam_buka'],
                        'jam_tutup' => $jadwal['jam_tutup'],
                    ]);
                }

                // 5. Simpan foto destinasi jika ada
                foreach ($request->file('foto_destinasi', []) as $file) {
                    $path = $file->store('restoran/' . $restoran->id_restoran, 'public');

                    if ($path === false) {
                        throw new \RuntimeException('Gagal menyimpan salah satu foto destinasi.');
                    }

                    $storedPaths[] = $path;

                    FotoDestinasi::create([
                        'id_photo' => (string) Str::uuid(),
                        'destinasi_id' => $restoran->id_restoran,
                        'destinasi_type' => $restoran->getMorphClass(),
                        'link_photo' => $path,
                    ]);
                }
            });
        } catch (\Throwable $e) {
            Storage::disk('public')->delete($storedPaths);
            report($e);

            return back()
                ->withInput($request->except(['foto_destinasi']))
                ->with('error', 'Data restoran gagal disimpan. Periksa data dan coba lagi. ' . $e->getMessage());
        }

        return redirect()
            ->route('admin.restoran.index')
            ->with('success', 'Data restoran berhasil disimpan.');
    }

    public function show($id)
    {
        $restoran = Restoran::with('fotoDestinasis', 'jamOperasis', 'kategoris', 'fasilitas')->findOrFail($id);
        $kecamatan = Kecamatan::all();
        $categories = Kategori::where('jenis_kategori', 'restoran')->get();
        $fasilitas = Fasilitas::orderBy('nama_fasilitas')->get();

        $selectedCategories = $restoran->kategoris->map(function ($kategori) {
            return [
                'id_kategori' => $kategori->id_kategori,
                'nama_kategori' => $kategori->nama_kategori,
            ];
        })->toArray();

        $selectedFasilitas = old('fasilitas', $restoran->fasilitas->pluck('id_fasilitas')->toArray());
        $jamOperasional = $restoran->jamOperasis ?? [];
        $fotoDestinasi = $restoran->fotoDestinasis;

        return view('admin.restoran.form-restoran', compact(
            'restoran',
            'kecamatan',
            'categories',
            'fasilitas',
            'selectedCategories',
            'selectedFasilitas',
            'jamOperasional',
            'fotoDestinasi'
        ));
    }

    public function update(Request $request, $id)
    {
        $restoran = Restoran::findOrFail($id);

        $validated = $request->validate([
            'nama_restoran' => ['required', 'string', 'max:255'],
            'id_kecamatan' => [
                'required',
                'integer',
                'exists:kecamatan,id_kecamatan',
            ],
            'type_food' => ['required', 'in:Halal,Vegetarian,Semua'],
            'harga_makan_per_orang' => ['nullable', 'numeric', 'min:0'],
            'alamat_Detail_restoran' => ['required', 'string'],
            'latitude' => ['required', 'numeric'],
            'longitude' => ['required', 'numeric'],
            'link_on_maps' => [
                'required',
                'url',
                'max:2048',
            ],
            'deskripsi' => ['nullable', 'string'],

            // Kategori
            'categories' => ['required', 'array', 'min:1'],
            'categories.*' => [
                'required',
                'integer',
                'distinct',
                'exists:kategori,id_kategori',
            ],

            // Fasilitas (many to many)
            'fasilitas' => ['nullable', 'array'],
            'fasilitas.*' => [
                'integer',
                'exists:fasilitas,id_fasilitas',
            ],

            // Jam operasional
            'jam_operasional' => ['required', 'array'],
            'jam_operasional.*' => [
                'required',
                'array:hari,is_open,jam_buka,jam_tutup',
            ],
            'jam_operasional.*.is_open' => [
                'required',
                'boolean',
            ],
            'jam_operasional.*.jam_buka' => [
                'nullable',
                'date_format:H:i',
            ],
            'jam_operasional.*.jam_tutup' => [
                'nullable',
                'date_format:H:i',
            ],

            // Foto destinasi
            'foto_destinasi' => ['nullable', 'array', 'max:10'],
            'foto_destinasi.*' => [
                'required',
                'image',
                'mimes:jpg,jpeg,png',
                'max:5120',
            ],
        ], [
            'nama_restoran.required' => 'Nama restoran wajib diisi.',
            'nama_restoran.max' => 'Nama restoran maksimal 255 karakter.',
            'id_kecamatan.required' => 'Kecamatan wajib dipilih.',
            'id_kecamatan.exists' => 'Kecamatan yang dipilih tidak valid.',
            'type_food.required' => 'Tipe makanan wajib dipilih.',
            'type_food.in' => 'Tipe makanan harus Halal, Vegetarian, atau Semua.',
            'alamat_Detail_restoran.required' => 'Alamat restoran wajib diisi.',
            'latitude.required' => 'Latitude wajib diisi.',
            'latitude.numeric' => 'Latitude harus berupa angka.',
            'longitude.required' => 'Longitude wajib diisi.',
            'longitude.numeric' => 'Longitude harus berupa angka.',
            'link_on_maps.required' => 'Link Maps wajib diisi.',
            'link_on_maps.url' => 'Link Maps harus berupa URL yang valid.',
            'categories.required' => 'Pilih minimal satu kategori kuliner.',
            'categories.min' => 'Pilih minimal satu kategori kuliner.',
            'categories.*.required' => 'Kategori tidak boleh kosong.',
            'categories.*.integer' => 'Kategori yang dipilih tidak valid.',
            'categories.*.distinct' => 'Kategori tidak boleh dipilih berulang.',
            'categories.*.exists' => 'Kategori yang dipilih tidak ditemukan.',
            'fasilitas.*.integer' => 'Fasilitas yang dipilih tidak valid.',
            'fasilitas.*.exists' => 'Fasilitas yang dipilih tidak ditemukan.',
            'jam_operasional.required' => 'Jam operasional wajib diisi.',
            'jam_operasional.*.is_open.required' => 'Status buka atau tutup wajib ditentukan.',
            'jam_operasional.*.jam_buka.date_format' => 'Format jam buka harus HH:MM.',
            'jam_operasional.*.jam_tutup.date_format' => 'Format jam tutup harus HH:MM.',
            'foto_destinasi.max' => 'Maksimal 10 foto yang dapat diunggah.',
            'foto_destinasi.*.image' => 'File harus berupa gambar.',
            'foto_destinasi.*.mimes' => 'Format foto harus JPG, JPEG, atau PNG.',
            'foto_destinasi.*.max' => 'Ukuran setiap foto maksimal 5 MB.',
        ]);

        $storedPaths = [];

        try {
            DB::transaction(function () use ($validated, $request, &$storedPaths, $restoran) {
                // 1. Update data utama restoran
                $restoran->update([
                    'id_kecamatan' => $validated['id_kecamatan'],
                    'nama_restoran' => $validated['nama_restoran'],
                    'alamat_Detail_restoran' => $validated['alamat_Detail_restoran'],
                    'latitude' => $validated['latitude'],
                    'longitude' => $validated['longitude'],
                    'link_on_maps' => $validated['link_on_maps'],
                    'harga_makan_per_orang' => $validated['harga_makan_per_orang'] ?? null,
                    'type_food' => $validated['type_food'],
                    'deskripsi' => $validated['deskripsi'] ?? null,
                ]);

                // 2. Sinkronisasi kategori restoran
                $restoran->kategoris()->sync($validated['categories']);

                // 3. Sinkronisasi fasilitas restoran (many to many)
                $restoran->fasilitas()->sync($validated['fasilitas'] ?? []);

                // 4. Perbarui jam operasional (hapus yang lama, buat yang baru)
                $restoran->jamOperasis()->delete();

                $kelompokJadwal = $this->kelompokkanJadwal($validated['jam_operasional']);

                foreach ($kelompokJadwal as $jadwal) {
                    $restoran->jamOperasis()->create([
                        'id_operasi' => (string) Str::uuid(),
                        'hari_mulai' => $jadwal['hari_mulai'],
                        'hari_selesai' => $jadwal['hari_selesai'],
                        'is_open' => $jadwal['is_open'],
                        'jam_buka' => $jadwal['jam_buka'],
                        'jam_tutup' => $jadwal['jam_tutup'],
                    ]);
                }

                // 5. Tambahkan foto baru jika ada yang di-upload
                if ($request->hasFile('foto_destinasi')) {
                    foreach ($request->file('foto_destinasi') as $file) {
                        $path = $file->store('restoran/' . $restoran->id_restoran, 'public');

                        if ($path === false) {
                            throw new \RuntimeException('Gagal menyimpan salah satu foto destinasi.');
                        }

                        $storedPaths[] = $path;

                        FotoDestinasi::create([
                            'id_photo' => (string) Str::uuid(),
                            'destinasi_id' => $restoran->id_restoran,
                            'destinasi_type' => $restoran->getMorphClass(),
                            'link_photo' => $path,
                        ]);
                    }
                }
            });
        } catch (\Throwable $e) {
            Storage::disk('public')->delete($storedPaths);
            report($e);

            return back()
                ->withInput($request->except('foto_destinasi'))
                ->with('error', 'Data restoran gagal diperbarui. Periksa data dan coba lagi. ' . $e->getMessage());
        }

        return redirect()
            ->route('admin.restoran.index')
            ->with('success', 'Data restoran berhasil diperbarui.');
    }

    public function destroy($id)
    {
        DB::beginTransaction();

        try {
            $restoran = Restoran::with(['fotoDestinasis', 'jamOperasis', 'kategoris', 'fasilitas'])->findOrFail($id);

            // 1. Hapus file fisik dan record foto di database
            if ($restoran->fotoDestinasis && $restoran->fotoDestinasis->isNotEmpty()) {
                foreach ($restoran->fotoDestinasis as $foto) {
                    $path = $foto->link_photo ?? $foto->path_foto;

                    if ($path && Storage::disk('public')->exists($path)) {
                        Storage::disk('public')->delete($path);
                    }
                    $foto->delete();
                }

                $firstPhotoPath = $restoran->fotoDestinasis->first()->link_photo ?? $restoran->fotoDestinasis->first()->path_foto;

                if ($firstPhotoPath) {
                    $directoryPath = dirname($firstPhotoPath);

                    if ($directoryPath && $directoryPath !== '.' && Storage::disk('public')->exists($directoryPath)) {
                        Storage::disk('public')->deleteDirectory($directoryPath);
                    }
                }
            }

            // 2. Hapus data jam operasional terkait
            if (method_exists($restoran, 'jamOperasis')) {
                $restoran->jamOperasis()->delete();
            }

            // 3. Putus relasi kategori dan fasilitas di tabel pivot
            if (method_exists($restoran, 'kategoris')) {
                $restoran->kategoris()->detach();
            }
            if (method_exists($restoran, 'fasilitas')) {
                $restoran->fasilitas()->detach();
            }

            // 4. Hapus data utama restoran
            $restoran->delete();

            DB::commit();

            if (request()->expectsJson()) {
                return response()->json([
                    'success' => true,
                    'message' => 'Data restoran beserta foto dan jam operasional berhasil dihapus.',
                ]);
            }

            return redirect()
                ->route('admin.restoran.index')
                ->with('success', 'Data restoran beserta seluruh data terkait berhasil dihapus.');

        } catch (\Exception $e) {
            DB::rollBack();

            if (request()->expectsJson()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Gagal menghapus data restoran: ' . $e->getMessage(),
                ], 500);
            }

            return back()->with('error', 'Terjadi kesalahan saat menghapus data: ' . $e->getMessage());
        }
    }

    private function kelompokkanJadwal(array $jadwalInput): array
    {
        $daftarHari = [
            'senin' => 1,
            'selasa' => 2,
            'rabu' => 3,
            'kamis' => 4,
            'jumat' => 5,
            'sabtu' => 6,
            'minggu' => 7,
        ];

        $kelompokJadwal = [];
        $kelompok = [];

        foreach ($daftarHari as $kodeHari => $nomorHari) {
            $data = $jadwalInput[$kodeHari];

            $isOpen = (int) $data['is_open'] === 1;

            $jamBuka = $isOpen
                ? ($data['jam_buka'] ?? null)
                : null;

            $jamTutup = $isOpen
                ? ($data['jam_tutup'] ?? null)
                : null;

            $jadwalSama = !empty($kelompok)
                && $kelompok['hari_selesai'] === $nomorHari - 1
                && $kelompok['is_open'] === $isOpen
                && $kelompok['jam_buka'] === $jamBuka
                && $kelompok['jam_tutup'] === $jamTutup;

            if ($jadwalSama) {
                $kelompok['hari_selesai'] = $nomorHari;
                continue;
            }

            if (!empty($kelompok)) {
                $kelompokJadwal[] = $kelompok;
            }

            $kelompok = [
                'hari_mulai' => $nomorHari,
                'hari_selesai' => $nomorHari,
                'is_open' => $isOpen,
                'jam_buka' => $jamBuka,
                'jam_tutup' => $jamTutup,
            ];
        }

        if (!empty($kelompok)) {
            $kelompokJadwal[] = $kelompok;
        }

        return $kelompokJadwal;
    }
}