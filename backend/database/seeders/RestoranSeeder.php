<?php

namespace Database\Seeders;

use App\Models\Kecamatan;
use App\Models\Restoran;
use App\Models\Fasilitas;
use App\Models\Kategori;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class RestoranSeeder extends Seeder
{
    public function run(): void
    {
        DB::transaction(function () {
            $kecamatanIds = Kecamatan::pluck('id_kecamatan')->all();

            if (empty($kecamatanIds)) {
                $this->command?->error(
                    'Data kecamatan belum tersedia. Jalankan KecamatanSeeder terlebih dahulu.'
                );

                return;
            }

            $fasilitasMap = Fasilitas::pluck(
                'id_fasilitas',
                'nama_fasilitas'
            )->all();

            if (empty($fasilitasMap)) {
                $this->command?->error(
                    'Data fasilitas belum tersedia. Jalankan FasilitasSeeder terlebih dahulu.'
                );

                return;
            }

            $kategoriMap = Kategori::pluck(
                'id_kategori',
                'nama_kategori'
            )->all();

            if (empty($kategoriMap)) {
                $this->command?->error(
                    'Data kategori belum tersedia. Jalankan KategoriSeeder terlebih dahulu.'
                );

                return;
            }

            $dataRestoran = [
                [
                    'nama_restoran' => 'Golden Prawn 933',
                    'kecamatan_index' => 0,
                    'alamat_detail_restoran' => 'Bengkong Laut, Batam',
                    'latitude' => 1.1740,
                    'longitude' => 104.0680,
                    'deskripsi' => 'Restoran seafood dengan berbagai pilihan hidangan laut untuk makan bersama keluarga.',
                    'link_on_maps' => 'https://maps.google.com/?q=Golden+Prawn+933+Batam',
                    'harga_makan_per_orang' => 150000,
                    'type_food' => 'Semua',
                    'kategori' => ['Seafood'],
                    'fasilitas' => [
                        'WiFi Gratis',
                        'Area Parkir',
                        'Toilet',
                        'Musholla',
                        'AC (Air Conditioner)',
                        'Area Terbuka / Outdoor',
                        'Pembayaran QRIS / Non-Tunai',
                    ],
                ],
                [
                    'nama_restoran' => 'Mie Tarempa',
                    'kecamatan_index' => 1,
                    'alamat_detail_restoran' => 'Batam, Kepulauan Riau',
                    'latitude' => 1.1320,
                    'longitude' => 104.0450,
                    'deskripsi' => 'Tempat menikmati mie tarempa khas Kepulauan Riau dengan cita rasa gurih dan pedas.',
                    'link_on_maps' => 'https://maps.google.com/?q=Mie+Tarempa+Batam',
                    'harga_makan_per_orang' => 30000,
                    'type_food' => 'Semua',
                    'kategori' => ['Masakan Melayu'],
                    'fasilitas' => [
                        'Area Parkir',
                        'Toilet',
                        'AC (Air Conditioner)',
                        'Pembayaran QRIS / Non-Tunai',
                        'Area Bebas Rokok (Non-Smoking)',
                    ],
                ],
                [
                    'nama_restoran' => 'Love Seafood',
                    'kecamatan_index' => 2,
                    'alamat_detail_restoran' => 'Batam, Kepulauan Riau',
                    'latitude' => 1.1600,
                    'longitude' => 104.0650,
                    'deskripsi' => 'Restoran seafood dengan pilihan hidangan laut untuk makan bersama keluarga.',
                    'link_on_maps' => 'https://maps.google.com/?q=Love+Seafood+Batam',
                    'harga_makan_per_orang' => 120000,
                    'type_food' => 'Semua',
                    'kategori' => ['Seafood'],
                    'fasilitas' => [
                        'Area Parkir',
                        'Toilet',
                        'Musholla',
                        'AC (Air Conditioner)',
                        'Ruang VIP / Private Room',
                        'Akses Ramah Disabilitas',
                        'Pembayaran QRIS / Non-Tunai',
                    ],
                ],
                [
                    'nama_restoran' => 'Wey Wey Seafood',
                    'kecamatan_index' => 3,
                    'alamat_detail_restoran' => 'Batam, Kepulauan Riau',
                    'latitude' => 1.1190,
                    'longitude' => 103.9270,
                    'deskripsi' => 'Restoran dengan pilihan olahan ikan, udang, kepiting, dan hidangan laut lainnya.',
                    'link_on_maps' => 'https://maps.google.com/?q=Wey+Wey+Seafood+Batam',
                    'harga_makan_per_orang' => 120000,
                    'type_food' => 'Semua',
                    'kategori' => ['Seafood'],
                    'fasilitas' => [
                        'Area Parkir',
                        'Toilet',
                        'Musholla',
                        'Area Terbuka / Outdoor',
                        'Pembayaran QRIS / Non-Tunai',
                    ],
                ],
                [
                    'nama_restoran' => 'De Patros Cafe',
                    'kecamatan_index' => 4,
                    'alamat_detail_restoran' => 'Batam, Kepulauan Riau',
                    'latitude' => 1.1570,
                    'longitude' => 103.9860,
                    'deskripsi' => 'Tempat makan dan bersantai dengan pilihan menu makanan serta minuman.',
                    'link_on_maps' => 'https://maps.google.com/?q=De+Patros+Cafe+Batam',
                    'harga_makan_per_orang' => 60000,
                    'type_food' => 'Semua',
                    'kategori' => ['Kafe dan Kedai Kopi'],
                    'fasilitas' => [
                        'WiFi Gratis',
                        'Area Parkir',
                        'Toilet',
                        'AC (Air Conditioner)',
                        'Live Music',
                        'Colokan Listrik / Stop Kontak',
                        'Area Bebas Rokok (Non-Smoking)',
                    ],
                ],
                [
                    'nama_restoran' => 'Kelong Jembatan 2',
                    'kecamatan_index' => 5,
                    'alamat_detail_restoran' => 'Kawasan Barelang, Batam',
                    'latitude' => 0.9810,
                    'longitude' => 104.0380,
                    'deskripsi' => 'Tempat makan di kawasan pesisir dengan pilihan menu makanan laut.',
                    'link_on_maps' => 'https://maps.google.com/?q=Kelong+Jembatan+2+Barelang',
                    'harga_makan_per_orang' => 100000,
                    'type_food' => 'Semua',
                    'kategori' => ['Seafood'],
                    'fasilitas' => [
                        'Area Parkir',
                        'Toilet',
                        'Musholla',
                        'Area Terbuka / Outdoor',
                        'Area Merokok (Smoking Area)',
                    ],
                ],
                [
                    'nama_restoran' => 'A2 Food Court',
                    'kecamatan_index' => 6,
                    'alamat_detail_restoran' => 'Batam, Kepulauan Riau',
                    'latitude' => 1.1450,
                    'longitude' => 104.0100,
                    'deskripsi' => 'Pusat kuliner dengan beragam pilihan makanan untuk makan sehari-hari.',
                    'link_on_maps' => 'https://maps.google.com/?q=A2+Food+Court+Batam',
                    'harga_makan_per_orang' => 30000,
                    'type_food' => 'Semua',
                    'kategori' => ['Masakan Indonesia'],
                    'fasilitas' => [
                        'Area Parkir',
                        'Toilet',
                        'Area Terbuka / Outdoor',
                        'Pembayaran QRIS / Non-Tunai',
                    ],
                ],
                [
                    'nama_restoran' => 'RM Mie Lendir',
                    'kecamatan_index' => 7,
                    'alamat_detail_restoran' => 'Batam, Kepulauan Riau',
                    'latitude' => 1.1300,
                    'longitude' => 104.0530,
                    'deskripsi' => 'Tempat menikmati mie lendir, salah satu hidangan khas Kepulauan Riau.',
                    'link_on_maps' => 'https://maps.google.com/?q=Mie+Lendir+Batam',
                    'harga_makan_per_orang' => 25000,
                    'type_food' => 'Semua',
                    'kategori' => ['Masakan Melayu'],
                    'fasilitas' => [
                        'Area Parkir',
                        'Toilet',
                        'Area Bebas Rokok (Non-Smoking)',
                        'Pembayaran QRIS / Non-Tunai',
                    ],
                ],
                [
                    'nama_restoran' => 'Kedai Kopi Harum Manis',
                    'kecamatan_index' => 8,
                    'alamat_detail_restoran' => 'Batam, Kepulauan Riau',
                    'latitude' => 1.1340,
                    'longitude' => 104.0120,
                    'deskripsi' => 'Kedai untuk menikmati kopi, minuman, dan makanan ringan.',
                    'link_on_maps' => 'https://maps.google.com/?q=Kedai+Kopi+Batam',
                    'harga_makan_per_orang' => 25000,
                    'type_food' => 'Semua',
                    'kategori' => ['Kafe dan Kedai Kopi'],
                    'fasilitas' => [
                        'WiFi Gratis',
                        'Area Parkir',
                        'Toilet',
                        'AC (Air Conditioner)',
                        'Colokan Listrik / Stop Kontak',
                        'Area Bebas Rokok (Non-Smoking)',
                    ],
                ],
                [
                    'nama_restoran' => 'HokBen Batam',
                    'kecamatan_index' => 9,
                    'alamat_detail_restoran' => 'Batam, Kepulauan Riau',
                    'latitude' => 1.1350,
                    'longitude' => 103.9990,
                    'deskripsi' => 'Restoran dengan menu bergaya Jepang, termasuk paket nasi dan lauk.',
                    'link_on_maps' => 'https://maps.google.com/?q=HokBen+Batam',
                    'harga_makan_per_orang' => 50000,
                    'type_food' => 'Semua',
                    'kategori' => ['Fast Food'],
                    'fasilitas' => [
                        'WiFi Gratis',
                        'Area Parkir',
                        'Toilet',
                        'Musholla',
                        'AC (Air Conditioner)',
                        'Kursi Bayi (High Chair)',
                        'Akses Ramah Disabilitas',
                        'Pembayaran QRIS / Non-Tunai',
                    ],
                ],
                [
                    'nama_restoran' => 'Ayam Bakar Wong Solo',
                    'kecamatan_index' => 10,
                    'alamat_detail_restoran' => 'Batam, Kepulauan Riau',
                    'latitude' => 1.1400,
                    'longitude' => 104.0150,
                    'deskripsi' => 'Restoran dengan menu ayam bakar dan hidangan khas Indonesia.',
                    'link_on_maps' => 'https://maps.google.com/?q=Ayam+Bakar+Wong+Solo+Batam',
                    'harga_makan_per_orang' => 45000,
                    'type_food' => 'Semua',
                    'kategori' => ['Masakan Indonesia'],
                    'fasilitas' => [
                        'Area Parkir',
                        'Toilet',
                        'Musholla',
                        'AC (Air Conditioner)',
                        'Kursi Bayi (High Chair)',
                        'Pembayaran QRIS / Non-Tunai',
                    ],
                ],
                [
                    'nama_restoran' => 'RM Padang Sederhana',
                    'kecamatan_index' => 0,
                    'alamat_detail_restoran' => 'Batam, Kepulauan Riau',
                    'latitude' => 1.1500,
                    'longitude' => 104.0200,
                    'deskripsi' => 'Rumah makan dengan aneka masakan Padang dan lauk khas Minangkabau.',
                    'link_on_maps' => 'https://maps.google.com/?q=RM+Padang+Sederhana+Batam',
                    'harga_makan_per_orang' => 35000,
                    'type_food' => 'Semua',
                    'kategori' => ['Masakan Indonesia'],
                    'fasilitas' => [
                        'Area Parkir',
                        'Toilet',
                        'Musholla',
                        'AC (Air Conditioner)',
                        'Pembayaran QRIS / Non-Tunai',
                    ],
                ],
                [
                    'nama_restoran' => 'Pizza Hut Batam',
                    'kecamatan_index' => 1,
                    'alamat_detail_restoran' => 'Batam, Kepulauan Riau',
                    'latitude' => 1.1300,
                    'longitude' => 104.0450,
                    'deskripsi' => 'Restoran dengan menu pizza, pasta, dan makanan bergaya Barat.',
                    'link_on_maps' => 'https://maps.google.com/?q=Pizza+Hut+Batam',
                    'harga_makan_per_orang' => 80000,
                    'type_food' => 'Semua',
                    'kategori' => ['Masakan Western'],
                    'fasilitas' => [
                        'WiFi Gratis',
                        'Area Parkir',
                        'Toilet',
                        'Musholla',
                        'AC (Air Conditioner)',
                        'Ruang VIP / Private Room',
                        'Kursi Bayi (High Chair)',
                        'Akses Ramah Disabilitas',
                        'Pembayaran QRIS / Non-Tunai',
                    ],
                ],
                [
                    'nama_restoran' => 'KFC Batam Centre',
                    'kecamatan_index' => 2,
                    'alamat_detail_restoran' => 'Batam Centre, Batam',
                    'latitude' => 1.1300,
                    'longitude' => 104.0530,
                    'deskripsi' => 'Restoran cepat saji dengan menu ayam goreng dan berbagai paket makanan.',
                    'link_on_maps' => 'https://maps.google.com/?q=KFC+Batam+Centre',
                    'harga_makan_per_orang' => 35000,
                    'type_food' => 'Semua',
                    'kategori' => ['Fast Food'],
                    'fasilitas' => [
                        'Area Parkir',
                        'Toilet',
                        'AC (Air Conditioner)',
                        'Kursi Bayi (High Chair)',
                        'Akses Ramah Disabilitas',
                        'Pembayaran QRIS / Non-Tunai',
                    ],
                ],
                [
                    'nama_restoran' => 'McDonalds Batam',
                    'kecamatan_index' => 3,
                    'alamat_detail_restoran' => 'Batam, Kepulauan Riau',
                    'latitude' => 1.1350,
                    'longitude' => 104.0100,
                    'deskripsi' => 'Restoran cepat saji dengan menu burger, ayam, kentang, dan minuman.',
                    'link_on_maps' => 'https://maps.google.com/?q=McDonalds+Batam',
                    'harga_makan_per_orang' => 40000,
                    'type_food' => 'Semua',
                    'kategori' => ['Fast Food'],
                    'fasilitas' => [
                        'WiFi Gratis',
                        'Area Parkir',
                        'Toilet',
                        'AC (Air Conditioner)',
                        'Kursi Bayi (High Chair)',
                        'Akses Ramah Disabilitas',
                        'Pembayaran QRIS / Non-Tunai',
                    ],
                ],
                [
                    'nama_restoran' => 'Kedai Kopi Ameng',
                    'kecamatan_index' => 4,
                    'alamat_detail_restoran' => 'Batam, Kepulauan Riau',
                    'latitude' => 1.1450,
                    'longitude' => 104.0100,
                    'deskripsi' => 'Kedai kopi lokal untuk sarapan dan menikmati minuman hangat.',
                    'link_on_maps' => 'https://maps.google.com/?q=Kedai+Kopi+Ameng+Batam',
                    'harga_makan_per_orang' => 25000,
                    'type_food' => 'Semua',
                    'kategori' => ['Kafe dan Kedai Kopi'],
                    'fasilitas' => [
                        'WiFi Gratis',
                        'Area Parkir',
                        'Toilet',
                        'Colokan Listrik / Stop Kontak',
                        'Area Merokok (Smoking Area)',
                    ],
                ],
                [
                    'nama_restoran' => 'Bebek Tepi Sawah Batam',
                    'kecamatan_index' => 5,
                    'alamat_detail_restoran' => 'Batam, Kepulauan Riau',
                    'latitude' => 1.1200,
                    'longitude' => 104.0600,
                    'deskripsi' => 'Restoran dengan menu bebek dan masakan Indonesia untuk makan bersama keluarga.',
                    'link_on_maps' => 'https://maps.google.com/?q=Bebek+Tepi+Sawah+Batam',
                    'harga_makan_per_orang' => 85000,
                    'type_food' => 'Semua',
                    'kategori' => ['Masakan Indonesia'],
                    'fasilitas' => [
                        'Area Parkir',
                        'Toilet',
                        'Musholla',
                        'AC (Air Conditioner)',
                        'Kursi Bayi (High Chair)',
                        'Area Terbuka / Outdoor',
                        'Pembayaran QRIS / Non-Tunai',
                    ],
                ],
                [
                    'nama_restoran' => 'Sushi Tei Batam',
                    'kecamatan_index' => 6,
                    'alamat_detail_restoran' => 'Batam, Kepulauan Riau',
                    'latitude' => 1.1350,
                    'longitude' => 103.9990,
                    'deskripsi' => 'Restoran dengan aneka sushi dan hidangan Jepang.',
                    'link_on_maps' => 'https://maps.google.com/?q=Sushi+Tei+Batam',
                    'harga_makan_per_orang' => 100000,
                    'type_food' => 'Semua',
                    'kategori' => ['Masakan Chinese'],
                    'fasilitas' => [
                        'WiFi Gratis',
                        'Area Parkir',
                        'Toilet',
                        'Musholla',
                        'AC (Air Conditioner)',
                        'Ruang VIP / Private Room',
                        'Kursi Bayi (High Chair)',
                        'Akses Ramah Disabilitas',
                        'Pembayaran QRIS / Non-Tunai',
                    ],
                ],
                [
                    'nama_restoran' => 'Morning Bakery',
                    'kecamatan_index' => 7,
                    'alamat_detail_restoran' => 'Batam, Kepulauan Riau',
                    'latitude' => 1.1400,
                    'longitude' => 104.0150,
                    'deskripsi' => 'Tempat sarapan dengan roti, kue, kopi, dan menu makanan ringan.',
                    'link_on_maps' => 'https://maps.google.com/?q=Morning+Bakery+Batam',
                    'harga_makan_per_orang' => 30000,
                    'type_food' => 'Semua',
                    'kategori' => ['Dessert dan Roti'],
                    'fasilitas' => [
                        'WiFi Gratis',
                        'Area Parkir',
                        'Toilet',
                        'AC (Air Conditioner)',
                        'Colokan Listrik / Stop Kontak',
                        'Pembayaran QRIS / Non-Tunai',
                    ],
                ],
                [
                    'nama_restoran' => 'Kedai Kopi Sudi Mampir',
                    'kecamatan_index' => 8,
                    'alamat_detail_restoran' => 'Batam, Kepulauan Riau',
                    'latitude' => 1.1300,
                    'longitude' => 104.0450,
                    'deskripsi' => 'Kedai kopi untuk menikmati minuman dan hidangan sederhana.',
                    'link_on_maps' => 'https://maps.google.com/?q=Kedai+Kopi+Batam',
                    'harga_makan_per_orang' => 25000,
                    'type_food' => 'Semua',
                    'kategori' => ['Kafe dan Kedai Kopi'],
                    'fasilitas' => [
                        'Area Parkir',
                        'Toilet',
                        'Area Merokok (Smoking Area)',
                        'Colokan Listrik / Stop Kontak',
                        'Pembayaran QRIS / Non-Tunai',
                    ],
                ],
            ];

            /*
             * Jam operasional contoh.
             * Verifikasi kembali dengan jam buka masing-masing restoran.
             */
            $jamOperasional = [
                'Golden Prawn 933' => ['11:00', '22:00'],
                'Mie Tarempa' => ['07:00', '21:00'],
                'Love Seafood' => ['11:00', '22:00'],
                'Wey Wey Seafood' => ['11:00', '22:00'],
                'De Patros Cafe' => ['16:00', '23:00'],
                'Kelong Jembatan 2' => ['11:00', '21:00'],
                'A2 Food Court' => ['07:00', '22:00'],
                'RM Mie Lendir' => ['07:00', '17:00'],
                'Kedai Kopi Harum Manis' => ['07:00', '22:00'],
                'HokBen Batam' => ['10:00', '22:00'],
                'Ayam Bakar Wong Solo' => ['10:00', '22:00'],
                'RM Padang Sederhana' => ['09:00', '22:00'],
                'Pizza Hut Batam' => ['10:00', '22:00'],
                'KFC Batam Centre' => ['10:00', '22:00'],
                'McDonalds Batam' => ['07:00', '23:00'],
                'Kedai Kopi Ameng' => ['06:00', '18:00'],
                'Bebek Tepi Sawah Batam' => ['10:00', '22:00'],
                'Sushi Tei Batam' => ['11:00', '22:00'],
                'Morning Bakery' => ['06:00', '21:00'],
                'Kedai Kopi Sudi Mampir' => ['06:00', '18:00'],
            ];

            $fasilitasTidakDitemukan = [];
            $kategoriTidakDitemukan = [];

            foreach ($dataRestoran as $item) {
                $namaRestoran = $item['nama_restoran'];

                $idKecamatan = $kecamatanIds[
                    $item['kecamatan_index'] % count($kecamatanIds)
                ];

                // Pertahankan UUID restoran yang sudah ada.
                $restoran = Restoran::firstOrNew([
                    'nama_restoran' => $namaRestoran,
                ]);

                if (!$restoran->exists) {
                    $restoran->id_restoran = (string) Str::uuid();
                }

                $restoran->id_kecamatan = $idKecamatan;
                $restoran->alamat_detail_restoran =
                    $item['alamat_detail_restoran'];
                $restoran->latitude = $item['latitude'];
                $restoran->longitude = $item['longitude'];
                $restoran->deskripsi = $item['deskripsi'];
                $restoran->link_on_maps = $item['link_on_maps'];
                $restoran->harga_makan_per_orang =
                    $item['harga_makan_per_orang'];
                $restoran->type_food = $item['type_food'];

                $restoran->save();

                /*
                 * Sinkronisasi kategori melalui model Restoran.
                 */
                $kategoriIds = [];

                foreach ($item['kategori'] as $namaKategori) {
                    if (isset($kategoriMap[$namaKategori])) {
                        $kategoriIds[] = $kategoriMap[$namaKategori];
                    } else {
                        $kategoriTidakDitemukan[] = $namaKategori;
                    }
                }

                $restoran->kategoris()->sync(
                    array_values(array_unique($kategoriIds))
                );

                /*
                 * Sinkronisasi seluruh fasilitas restoran.
                 */
                $fasilitasIds = [];

                foreach ($item['fasilitas'] as $namaFasilitas) {
                    if (isset($fasilitasMap[$namaFasilitas])) {
                        $fasilitasIds[] = $fasilitasMap[$namaFasilitas];
                    } else {
                        $fasilitasTidakDitemukan[] = $namaFasilitas;
                    }
                }

                $restoran->fasilitas()->sync(
                    array_values(array_unique($fasilitasIds))
                );

                /*
                 * Sinkronisasi jam operasional menggunakan
                 * relasi polimorfik destinasi.
                 */
                $jam = $jamOperasional[$namaRestoran] ?? null;

                if ($jam !== null) {
                    DB::table('jam_operasi')
                        ->where(
                            'destinasi_id',
                            $restoran->id_restoran
                        )
                        ->where(
                            'destinasi_type',
                            $restoran->getMorphClass()
                        )
                        ->delete();

                    DB::table('jam_operasi')->insert([
                        'id_operasi' => (string) Str::uuid(),
                        'destinasi_id' => $restoran->id_restoran,
                        'destinasi_type' => $restoran->getMorphClass(),
                        'hari_mulai' => 1,
                        'hari_selesai' => 7,
                        'jam_buka' => $jam[0],
                        'jam_tutup' => $jam[1],
                        'is_open' => true,
                        'created_at' => now(),
                        'updated_at' => now(),
                    ]);
                }
            }

            if (!empty($fasilitasTidakDitemukan)) {
                $this->command?->warn(
                    'Fasilitas yang belum terdaftar: ' .
                    implode(
                        ', ',
                        array_unique($fasilitasTidakDitemukan)
                    )
                );
            }

            if (!empty($kategoriTidakDitemukan)) {
                $this->command?->warn(
                    'Kategori yang belum terdaftar: ' .
                    implode(
                        ', ',
                        array_unique($kategoriTidakDitemukan)
                    )
                );
            }

            $this->command?->info(
                count($dataRestoran) .
                ' data restoran berhasil diproses.'
            );
        });
    }
}
