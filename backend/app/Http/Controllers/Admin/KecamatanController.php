<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Kecamatan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\Rule;

class KecamatanController extends Controller
{
    public function index(Request $request)
    {
        $search = $request->input('search');

        $kecamatans = Kecamatan::with([
            // Eager load relasi polimorfik foto destinasi untuk setiap kategori
            'wisatas.fotoDestinasis' => fn($q) => $q->select('destinasi_type', 'destinasi_id', 'link_photo'), // sesuaikan kolom jika 'link_photo' bernama lain
            'restorans.fotoDestinasis' => fn($q) => $q->select('destinasi_type', 'destinasi_id', 'link_photo'),
            'penginapans.fotoDestinasis' => fn($q) => $q->select('destinasi_type', 'destinasi_id', 'link_photo'),
            'lokasiTransportasis.fotoDestinasis' => fn($q) => $q->select('destinasi_type', 'destinasi_id', 'link_photo'),
        ])
            ->withCount([
                'wisatas',
                'restorans',
                'penginapans',
                'lokasiTransportasis'
            ])
            ->when($search, function ($query, $search) {
                return $query->where('nama_kecamatan', 'like', '%' . $search . '%');
            })
            ->orderBy('nama_kecamatan', 'asc')
            ->paginate(8);

        $kecamatans->getCollection()->transform(function ($kecamatan) {
            // Hitung total destinasi
            $kecamatan->total_destinasi =
                $kecamatan->wisatas_count +
                $kecamatan->restorans_count +
                $kecamatan->penginapans_count +
                $kecamatan->lokasi_transportasis_count;

            // Ambil foto destinasi pertama melalui relasi polimorfik fotoDestinasis
            $firstWisataPhoto = optional($kecamatan->wisatas->first()?->fotoDestinasis->first())->link_photo;
            $firstRestoPhoto = optional($kecamatan->restorans->first()?->fotoDestinasis->first())->link_photo;
            $firstInapPhoto = optional($kecamatan->penginapans->first()?->fotoDestinasis->first())->link_photo;
            $firstTransPhoto = optional($kecamatan->lokasiTransportasis->first()?->fotoDestinasis->first())->link_photo;

            $kecamatan->first_destination_photo =
                $firstWisataPhoto ??
                $firstRestoPhoto ??
                $firstInapPhoto ??
                $firstTransPhoto ??
                null;

            return $kecamatan;
        });

        return view('admin.kecamatan.kecamatan', compact('kecamatans'));
    }
}
