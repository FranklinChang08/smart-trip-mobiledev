<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Kategori;
use App\Models\Kecamatan;
use App\Models\Restoran;
use App\Models\Wisata;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class DashboardController extends Controller
{
    public function index(Request $request)
    {
        $admin = Auth::user();

        // 1. Hitung jumlah 
        $statWisata = Wisata::count();
        $statRestoran = Restoran::count();
        $statTotal = $statWisata + $statRestoran;

        // 2. Ambil data destinasi
        $dbWisata = Wisata::with(['kecamatan', 'kategoris', 'fotoDestinasis'])->latest()->get();

        $destinasiItems = [];
        foreach ($dbWisata as $w) {
            $foto = $w->fotoDestinasis->first();
            $kategoriStr = $w->kategoris->pluck('nama_kategori')->implode(', ');
            $destinasiItems[] = [
                'nama' => $w->nama_wisata,
                'alamat' => $w->alamat_detail_wisata,
                'jenis' => 'wisata',
                'kategori' => $kategoriStr ?: 'Wisata Alam',
                'lokasi' => $w->kecamatan->nama_kecamatan ?? 'Batam',
                'status' => 'Aktif',
                'status_type' => 'aktif',
                'foto' => $foto && !empty($foto->link_photo) ? asset('storage/' . $foto->link_photo) : null,
                'id' => $w->id_wisata,
            ];
        }

        // Ambil data restoran
        if ($statRestoran > 0) {
            $dbRestoran = Restoran::with(['kecamatans', 'kategoris', 'fotoDestinasis'])->latest()->get();
            foreach ($dbRestoran as $r) {
                $foto = $r->fotoDestinasis->first();
                $kategoriStr = $r->kategoris->pluck('nama_kategori')->implode(', ');
                $destinasiItems[] = [
                    'nama' => $r->nama_destinasi ?? $r->nama_restoran,
                    'alamat' => $r->alamat_detail_destinasi ?? $r->alamat_Detail_restoran,
                    'jenis' => 'restoran',
                    'kategori' => $kategoriStr ?: 'Restoran',
                    'lokasi' => $r->kecamatans->first()->nama_kecamatan ?? ($r->kecamatan->nama_kecamatan ?? 'Batam'),
                    'status' => 'Aktif',
                    'status_type' => 'aktif',
                    'foto' => $foto && !empty($foto->link_photo) ? asset('storage/' . $foto->link_photo) : null,
                    'id' => $r->id_destinasi ?? $r->id_restoran,
                ];
            }
        }

        $allDestinasi = collect($destinasiItems)->map(function ($item, $key) {
            $item['no'] = sprintf('%02d', $key + 1);
            return (object) $item;
        });

        return view('admin.dashboard', compact(
            'admin',
            'statWisata',
            'statRestoran',
            'statTotal',
            'allDestinasi'
        ));
    }

    public function restoran()
    {
        $admin = Auth::user();
        return view('admin.restoran', compact('admin'));
    }
}
