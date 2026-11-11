<?php

namespace Database\Seeders;

use App\Models\Kecamatan;
use App\Models\LokasiTransportasi;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class LokasiTransportasiSeeder extends Seeder
{
    public function run(): void
    {
        DB::transaction(function () {
            $getKecId = function ($name) {
                return Kecamatan::where('nama_kecamatan', $name)->value('id_kecamatan') ?? 1;
            };

            $data = [
                [
                    'nama_lokasi' => 'Pelabuhan Ferry Batam Center',
                    'alamat_detail_lokasi' => 'Jl. Engku Putri, Teluk Tering, Batam Kota, Kota Batam',
                    'latitude' => 1.1317,
                    'longitude' => 104.0535,
                    'deskripsi' => 'Pelabuhan Ferry Internasional utama di Batam yang melayani rute Batam - Singapura dan Malaysia.',
                    'link_on_maps' => 'https://maps.google.com/?q=Batam+Center+Ferry+Terminal',
                    'type_lokasi' => 'Pelabuhan',
                    'kecamatan' => 'Batam Kota',
                ],
                [
                    'nama_lokasi' => 'Bandara Internasional Hang Nadim (BTH)',
                    'alamat_detail_lokasi' => 'Jl. Hang Nadim No.01, Batu Besar, Nongsa, Kota Batam',
                    'latitude' => 1.1211,
                    'longitude' => 104.1190,
                    'deskripsi' => 'Bandar udara internasional dengan landasan pacu terpanjang di Indonesia, melayani rute domestik dan kargo.',
                    'link_on_maps' => 'https://maps.google.com/?q=Hang+Nadim+Airport',
                    'type_lokasi' => 'Bandara',
                    'kecamatan' => 'Nongsa',
                ],
                [
                    'nama_lokasi' => 'Pelabuhan Ferry Harbour Bay',
                    'alamat_detail_lokasi' => 'Jl. Duyung, Sungai Jodoh, Batu Ampar, Kota Batam',
                    'latitude' => 1.1543,
                    'longitude' => 103.9972,
                    'deskripsi' => 'Pelabuhan ferry modern di pusat bisnis Nagoya/Batu Ampar dengan rute langsung ke HarbourFront Singapura.',
                    'link_on_maps' => 'https://maps.google.com/?q=Harbour+Bay+Ferry+Terminal',
                    'type_lokasi' => 'Pelabuhan',
                    'kecamatan' => 'Batu Ampar',
                ],
                [
                    'nama_lokasi' => 'Pelabuhan Ferry Sekupang',
                    'alamat_detail_lokasi' => 'Tanjung Pinggir, Sekupang, Kota Batam',
                    'latitude' => 1.1228,
                    'longitude' => 103.9261,
                    'deskripsi' => 'Pelabuhan ferry yang melayani perjalanan domestik antarpulau di Kepulauan Riau serta rute ke Singapura.',
                    'link_on_maps' => 'https://maps.google.com/?q=Sekupang+Ferry+Terminal',
                    'type_lokasi' => 'Pelabuhan',
                    'kecamatan' => 'Sekupang',
                ],
                [
                    'nama_lokasi' => 'Pelabuhan Ferry Nongsa Pura',
                    'alamat_detail_lokasi' => 'Jl. Hang Lekiu, Sambau, Nongsa, Kota Batam',
                    'latitude' => 1.1963,
                    'longitude' => 104.0991,
                    'deskripsi' => 'Pelabuhan penyeberangan ferry internasional di kawasan resort Nongsa terhubung langsung ke Tanah Merah Singapura.',
                    'link_on_maps' => 'https://maps.google.com/?q=Nongsapura+Ferry+Terminal',
                    'type_lokasi' => 'Pelabuhan',
                    'kecamatan' => 'Nongsa',
                ],
                [
                    'nama_lokasi' => 'Pelabuhan Roro Telaga Punggur',
                    'alamat_detail_lokasi' => 'Telaga Punggur, Kabil, Nongsa, Kota Batam',
                    'latitude' => 1.0542,
                    'longitude' => 104.1444,
                    'deskripsi' => 'Pelabuhan kapal cepat dan kapal Roro penyeberangan utama antarpulau Batam - Bintan (Tanjung Uban/Tanjung Pinang).',
                    'link_on_maps' => 'https://maps.google.com/?q=Telaga+Punggur+Ferry+Terminal',
                    'type_lokasi' => 'Pelabuhan',
                    'kecamatan' => 'Nongsa',
                ],
            ];

            foreach ($data as $item) {
                LokasiTransportasi::firstOrCreate(
                    ['nama_lokasi' => $item['nama_lokasi']],
                    [
                        'id_lokasi' => (string) Str::uuid(),
                        'id_kecamatan' => $getKecId($item['kecamatan']),
                        'alamat_detail_lokasi' => $item['alamat_detail_lokasi'],
                        'latitude' => $item['latitude'],
                        'longitude' => $item['longitude'],
                        'deskripsi' => $item['deskripsi'],
                        'link_on_maps' => $item['link_on_maps'],
                        'type_lokasi' => $item['type_lokasi'],
                    ]
                );
            }
        });
    }
}

