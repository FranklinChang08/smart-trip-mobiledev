<?php

namespace Database\Seeders;

use App\Models\Kecamatan;
use App\Models\Penginapan;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class PenginapanSeeder extends Seeder
{
    public function run(): void
    {
        DB::transaction(function () {
            $getKecId = function ($name) {
                return Kecamatan::where('nama_kecamatan', $name)->value('id_kecamatan') ?? 1;
            };

            $data = [
                [
                    'nama_penginapan' => 'Harris Resort Barelang Batam',
                    'alamat_detail_penginapan' => 'Jl. Trans Barelang, Tembesi, Sagulung, Kota Batam',
                    'latitude' => 0.9856,
                    'longitude' => 104.0321,
                    'deskripsi' => 'Resort tepi laut bintang 4 dengan pemandangan ikonik Jembatan 1 Barelang, kolam renang infinity, dan pantai pribadi.',
                    'link_on_maps' => 'https://maps.google.com/?q=Harris+Resort+Barelang+Batam',
                    'harga_penginapan' => 950000,
                    'type_penginapan' => 'Resort',
                    'kecamatan' => 'Sagulung',
                ],
                [
                    'nama_penginapan' => 'Montigo Resorts Nongsa',
                    'alamat_detail_penginapan' => 'Jl. Hang Lekiu, Sambau, Nongsa, Kota Batam',
                    'latitude' => 1.1925,
                    'longitude' => 104.1012,
                    'deskripsi' => 'Resort villa bintang 5 mewah bercat putih ala Santorini dengan kolam renang pribadi dan pemandangan sunset Selat Singapura.',
                    'link_on_maps' => 'https://maps.google.com/?q=Montigo+Resorts+Nongsa',
                    'harga_penginapan' => 2400000,
                    'type_penginapan' => 'Resort',
                    'kecamatan' => 'Nongsa',
                ],
                [
                    'nama_penginapan' => 'Radisson Golf & Convention Center Batam',
                    'alamat_detail_penginapan' => 'Jl. Jendral Sudirman, Sukajadi, Batam Kota, Kota Batam',
                    'latitude' => 1.1165,
                    'longitude' => 104.0362,
                    'deskripsi' => 'Hotel bintang 5 premium dengan pemandangan padang golf Sukajadi yang asri, fasilitas spa lengkap, dan pusat konvensi besar.',
                    'link_on_maps' => 'https://maps.google.com/?q=Radisson+Golf+Batam',
                    'harga_penginapan' => 1200000,
                    'type_penginapan' => 'Hotel',
                    'kecamatan' => 'Batam Kota',
                ],
                [
                    'nama_penginapan' => 'Batam Marriott Hotel Harbour Bay',
                    'alamat_detail_penginapan' => 'Kawasan Harbour Bay, Jl. Duyung, Sungai Jodoh, Batu Ampar, Kota Batam',
                    'latitude' => 1.1550,
                    'longitude' => 103.9965,
                    'deskripsi' => 'Hotel mewah bintang 5 tepi laut dengan akses langsung ke terminal ferry Harbour Bay dan pemandangan laut lepas.',
                    'link_on_maps' => 'https://maps.google.com/?q=Batam+Marriott+Harbour+Bay',
                    'harga_penginapan' => 1850000,
                    'type_penginapan' => 'Hotel',
                    'kecamatan' => 'Batu Ampar',
                ],
                [
                    'nama_penginapan' => 'Aston Nagoya City Hotel',
                    'alamat_detail_penginapan' => 'Komplek Nagoya Thamrin City, Lubuk Baja, Kota Batam',
                    'latitude' => 1.1448,
                    'longitude' => 104.0112,
                    'deskripsi' => 'Hotel modern bintang 4 strategis di jantung pusat bisnis dan kuliner Nagoya Batam.',
                    'link_on_maps' => 'https://maps.google.com/?q=Aston+Nagoya+City+Hotel',
                    'harga_penginapan' => 750000,
                    'type_penginapan' => 'Hotel',
                    'kecamatan' => 'Lubuk Baja',
                ],
                [
                    'nama_penginapan' => 'Swiss-Belhotel Harbour Bay',
                    'alamat_detail_penginapan' => 'Jl. Duyung, Sungai Jodoh, Batu Ampar, Kota Batam',
                    'latitude' => 1.1538,
                    'longitude' => 103.9980,
                    'deskripsi' => 'Hotel bintang 4 terintegrasi pusat hiburan dan santap seafood di kawasan pesisir Harbour Bay.',
                    'link_on_maps' => 'https://maps.google.com/?q=Swiss-Belhotel+Harbour+Bay',
                    'harga_penginapan' => 820000,
                    'type_penginapan' => 'Hotel',
                    'kecamatan' => 'Batu Ampar',
                ],
                [
                    'nama_penginapan' => 'Best Western Premier Panbil',
                    'alamat_detail_penginapan' => 'Jl. Ahmad Yani, Muka Kuning, Sei Beduk, Kota Batam',
                    'latitude' => 1.0850,
                    'longitude' => 104.0375,
                    'deskripsi' => 'Hotel bintang 4 dengan suasana hijau dan pemandangan Danau Duriangkang, dekat kawasan industri dan Panbil Mall.',
                    'link_on_maps' => 'https://maps.google.com/?q=Best+Western+Premier+Panbil',
                    'harga_penginapan' => 890000,
                    'type_penginapan' => 'Hotel',
                    'kecamatan' => 'Sei Beduk',
                ],
                [
                    'nama_penginapan' => 'Planet Holiday Hotel & Suites',
                    'alamat_detail_penginapan' => 'Jl. Raja Ali Haji, Sungai Jodoh, Batu Ampar, Kota Batam',
                    'latitude' => 1.1495,
                    'longitude' => 104.0041,
                    'deskripsi' => 'Hotel bintang 4 megah bergaya klasik di kawasan Nagoya dengan fasilitas kolam renang dan pusat kebugaran.',
                    'link_on_maps' => 'https://maps.google.com/?q=Planet+Holiday+Hotel+Batam',
                    'harga_penginapan' => 680000,
                    'type_penginapan' => 'Hotel',
                    'kecamatan' => 'Batu Ampar',
                ],
                [
                    'nama_penginapan' => 'Nagoya Mansion Hotel & Residence',
                    'alamat_detail_penginapan' => 'Jl. Imam Bonjol No.1, Kampung Utama, Lubuk Baja, Kota Batam',
                    'latitude' => 1.1412,
                    'longitude' => 104.0150,
                    'deskripsi' => 'Hotel apartemen terpadu dengan rooftop pool dan panorama pemandangan lanskap kota Batam.',
                    'link_on_maps' => 'https://maps.google.com/?q=Nagoya+Mansion+Batam',
                    'harga_penginapan' => 650000,
                    'type_penginapan' => 'Hotel',
                    'kecamatan' => 'Lubuk Baja',
                ],
                [
                    'nama_penginapan' => 'Artotel Batam',
                    'alamat_detail_penginapan' => 'Jl. Penuin No.1, Lubuk Baja Kota, Lubuk Baja, Kota Batam',
                    'latitude' => 1.1398,
                    'longitude' => 104.0105,
                    'deskripsi' => 'Hotel butik berkonsep seni kontemporer dan gaya hidup modern, dekat dengan pusat kuliner dan belanja Penuin.',
                    'link_on_maps' => 'https://maps.google.com/?q=Artotel+Batam',
                    'harga_penginapan' => 700000,
                    'type_penginapan' => 'Hotel',
                    'kecamatan' => 'Lubuk Baja',
                ],
                [
                    'nama_penginapan' => 'I Hotel Baloi',
                    'alamat_detail_penginapan' => 'Komplek Baloi Kusuma Indah No.7, Batu Selicin, Lubuk Baja, Kota Batam',
                    'latitude' => 1.1325,
                    'longitude' => 104.0078,
                    'deskripsi' => 'Hotel bintang 4 yang nyaman tepat di samping BCS Mall, memudahkan wisatawan berbelanja dan mencicipi aneka kuliner.',
                    'link_on_maps' => 'https://maps.google.com/?q=I+Hotel+Baloi',
                    'harga_penginapan' => 780000,
                    'type_penginapan' => 'Hotel',
                    'kecamatan' => 'Lubuk Baja',
                ],
            ];

            foreach ($data as $item) {
                Penginapan::firstOrCreate(
                    ['nama_penginapan' => $item['nama_penginapan']],
                    [
                        'id_penginapan' => (string) Str::uuid(),
                        'id_kecamatan' => $getKecId($item['kecamatan']),
                        'alamat_detail_penginapan' => $item['alamat_detail_penginapan'],
                        'latitude' => $item['latitude'],
                        'longitude' => $item['longitude'],
                        'deskripsi' => $item['deskripsi'],
                        'link_on_maps' => $item['link_on_maps'],
                        'harga_penginapan' => $item['harga_penginapan'],
                        'type_penginapan' => $item['type_penginapan'],
                    ]
                );
            }
        });
    }
}

