<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\FotoDestinasi;
use App\Models\JamOperasi;
use App\Models\Kategori;
use App\Models\Kecamatan;
use App\Models\Wisata;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Throwable;

class WisataController extends Controller
{
    public function index(Request $request)
    {
        $admin = Auth::user();
        $query = Wisata::with(['kecamatan', 'kategoris', 'jamOperasis', 'fotoDestinasis']);

        // Fitur pencarian sederhana berdasarkan nama wisata atau alamat
        if ($request->has('search') && $request->search != '') {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('nama_wisata', 'like', "%{$search}%")
                    ->orWhere('alamat_detail_wisata', 'like', "%{$search}%");
            });
        }

        $wisatas = $query->paginate(10);
        return view('admin.wisata.wisata', compact('admin', 'wisatas'));
    }
    public function create()
    {
        $admin = Auth::user();
        $categories = Kategori::all();
        $kecamatan = Kecamatan::query()
            ->orderBy('nama_kecamatan')
            ->get(['id_kecamatan', 'nama_kecamatan']);
        return view('admin.wisata.form-wisata', compact('admin', 'categories', 'kecamatan'));
    }


    public function store(Request $request)
    {
        // 1. Validasi data yang dikirim dari form.
        // Jika masih dalam tahap debugging, dd() bisa dilepas jika sudah siap

        $validated = $request->validate([
            'nama_wisata' => ['required', 'string', 'max:255'],

            'id_kecamatan' => [
                'required',
                'integer',
                'exists:kecamatan,id_kecamatan',
            ],

            'alamat_detail_wisata' => ['required', 'string'],
            'latitude' => ['required', 'numeric'],
            'longitude' => ['required', 'numeric'],

            'link_on_maps' => [
                'required',
                'url',
                'max:2048',
            ],

            'harga_tiket_masuk' => ['nullable', 'numeric', 'min:0'],
            'deskripsi' => ['nullable', 'string'],

            // Kategori wisata.
            'categories' => ['required', 'array', 'min:1'],
            'categories.*' => [
                'required',
                'integer',
                'distinct',
                'exists:kategori,id_kategori',
            ],

            // Jam operasional.
            'jam_operasional' => ['required', 'array'],

            'jam_operasional.*' => [
                'required',
                'array:buka,jam_buka,jam_tutup',
            ],

            'jam_operasional.*.buka' => [
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

            // Foto destinasi.
            'foto_destinasi' => ['nullable', 'array', 'max:10'],

            'foto_destinasi.*' => [
                'required',
                'image',
                'mimes:jpg,jpeg,png',
                'max:5120',
            ],
        ], [
            'nama_wisata.required' => 'Nama wisata wajib diisi.',
            'nama_wisata.max' => 'Nama wisata maksimal 255 karakter.',

            'id_kecamatan.required' => 'Kecamatan wajib dipilih.',
            'id_kecamatan.exists' => 'Kecamatan yang dipilih tidak valid.',

            'alamat_detail_wisata.required' => 'Alamat wisata wajib diisi.',

            'latitude.required' => 'Latitude wajib diisi.',
            'latitude.numeric' => 'Latitude harus berupa angka.',

            'longitude.required' => 'Longitude wajib diisi.',
            'longitude.numeric' => 'Longitude harus berupa angka.',

            'link_on_maps.required' => 'Link Maps wajib diisi.',
            'link_on_maps.url' => 'Link Maps harus berupa URL yang valid.',

            'categories.required' => 'Pilih minimal satu kategori wisata.',
            'categories.min' => 'Pilih minimal satu kategori wisata.',
            'categories.*.required' => 'Kategori tidak boleh kosong.',
            'categories.*.integer' => 'Kategori yang dipilih tidak valid.',
            'categories.*.distinct' => 'Kategori tidak boleh dipilih berulang.',
            'categories.*.exists' => 'Kategori yang dipilih tidak ditemukan.',

            'jam_operasional.required' => 'Jam operasional wajib diisi.',
            'jam_operasional.*.buka.required' =>
                'Status buka atau tutup wajib ditentukan.',

            'jam_operasional.*.jam_buka.date_format' =>
                'Format jam buka harus HH:MM.',

            'jam_operasional.*.jam_tutup.date_format' =>
                'Format jam tutup harus HH:MM.',

            'foto_destinasi.max' => 'Maksimal 10 foto yang dapat diunggah.',
            'foto_destinasi.*.image' => 'File harus berupa gambar.',
            'foto_destinasi.*.mimes' =>
                'Format foto harus JPG, JPEG, atau PNG.',
            'foto_destinasi.*.max' =>
                'Ukuran setiap foto maksimal 5 MB.',
        ]);

        // 4. Siapkan daftar file untuk cleanup jika transaksi gagal.
        $storedPaths = [];

        try {
            DB::transaction(function () use ($validated, $request, &$storedPaths) {
                // Simpan data utama wisata.
                $wisata = Wisata::create([
                    'id_wisata' => (string) Str::uuid(),
                    'id_kecamatan' => $validated['id_kecamatan'],
                    'nama_wisata' => $validated['nama_wisata'],
                    'alamat_detail_wisata' =>
                        $validated['alamat_detail_wisata'],
                    'latitude' => $validated['latitude'],
                    'longitude' => $validated['longitude'],
                    'link_on_maps' => $validated['link_on_maps'],
                    'harga_tiket_masuk' =>
                        $validated['harga_tiket_masuk'] ?? null,
                    'deskripsi' => $validated['deskripsi'] ?? null,
                ]);

                // Simpan relasi kategori wisata.
                $wisata->kategoris()->sync($validated['categories']);


                $kelompokJadwal = $this->kelompokkanJadwal(
                    $validated['jam_operasional']
                );

                foreach ($kelompokJadwal as $jadwal) {
                    $wisata->jamOperasis()->create([
                        'id_operasi' => (string) Str::uuid(),
                        'hari_mulai' => $jadwal['hari_mulai'],
                        'hari_selesai' => $jadwal['hari_selesai'],
                        'is_open' => $jadwal['is_open'],
                        'jam_buka' => $jadwal['jam_buka'],
                        'jam_tutup' => $jadwal['jam_tutup'],
                    ]);
                }

                // Simpan foto destinasi.
                foreach ($request->file('foto_destinasi', []) as $file) {
                    $path = $file->store(
                        'wisata/' . $wisata->id_wisata,
                        'public'
                    );

                    if ($path === false) {
                        throw new \RuntimeException(
                            'Gagal menyimpan salah satu foto destinasi.'
                        );
                    }

                    $storedPaths[] = $path;

                    FotoDestinasi::create([
                        'id_photo' => (string) Str::uuid(),
                        'destinasi_id' => $wisata->id_wisata,
                        'destinasi_type' => $wisata->getMorphClass(),
                        'link_photo' => $path,
                    ]);
                }
            });
        } catch (\Throwable $e) {
            // Database rollback tidak menghapus file secara otomatis.
            Storage::disk('public')->delete($storedPaths);

            report($e);

            return back()
                ->withInput($request->except('foto_destinasi'))
                ->with(
                    'error',
                    'Data wisata gagal disimpan. Periksa data dan coba lagi.'
                );
        }

        return redirect()
            ->route('admin.wisata.index')
            ->with('success', 'Data wisata berhasil disimpan.');
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

            $isOpen = (int) $data['buka'] === 1;

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
