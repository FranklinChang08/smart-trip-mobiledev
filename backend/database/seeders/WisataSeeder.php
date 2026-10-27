<?php

namespace Database\Seeders;

use App\Models\Kecamatan;
use App\Models\Wisata;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class WisataSeeder extends Seeder
{
    public function run(): void
    {
        DB::transaction(function () {
            $kecamatanIds = Kecamatan::pluck('id_kecamatan')->values();

            if ($kecamatanIds->isEmpty()) {
                $this->command?->warn(
                    'Data kecamatan belum tersedia. Jalankan KecamatanSeeder terlebih dahulu.'
                );

                return;
            }

            $kategoriIds = DB::table('kategori')
                ->where('jenis_kategori', 'wisata')
                ->pluck('id_kategori', 'nama_kategori');

            /*
             * Data wisata.
             * Sesuaikan nilai dengan data asli yang sudah kamu miliki.
             */
            $dataWisata = [
                [
                    'nama_wisata' => 'Jembatan Barelang',
                    'alamat_detail_wisata' => 'Jembatan Barelang, Batam',
                    'latitude' => 0.9817,
                    'longitude' => 104.0378,
                    'deskripsi' => 'Ikon Kota Batam yang menghubungkan beberapa pulau melalui rangkaian jembatan.',
                    'link_on_maps' => 'https://www.google.com/maps/search/?api=1&query=Jembatan+Barelang+Batam',
                    'harga_tiket_masuk' => 0,
                    'kategori' => ['Wisata Pantai', 'Wisata Rekreasi'],
                ],
                [
                    'nama_wisata' => 'Pantai Nongsa',
                    'alamat_detail_wisata' => 'Kawasan Nongsa, Batam',
                    'latitude' => 1.1833,
                    'longitude' => 104.1197,
                    'deskripsi' => 'Pantai di kawasan Nongsa yang menawarkan pemandangan laut.',
                    'link_on_maps' => 'https://www.google.com/maps/search/?api=1&query=Pantai+Nongsa+Batam',
                    'harga_tiket_masuk' => 10000,
                    'kategori' => ['Wisata Alam', 'Wisata Pantai', 'Wisata Rekreasi'],
                ],
                [
                    'nama_wisata' => 'Mega Wisata Ocarina',
                    'alamat_detail_wisata' => 'Kawasan Sadai, Batam',
                    'latitude' => 1.1590,
                    'longitude' => 104.0310,
                    'deskripsi' => 'Kawasan rekreasi keluarga dengan berbagai fasilitas hiburan.',
                    'link_on_maps' => 'https://www.google.com/maps/search/?api=1&query=Mega+Wisata+Ocarina+Batam',
                    'harga_tiket_masuk' => 25000,
                    'kategori' => ['Wisata Rekreasi'],
                ],
                [
                    'nama_wisata' => 'Pantai Marina',
                    'alamat_detail_wisata' => 'Kawasan Marina, Sekupang, Batam',
                    'latitude' => 1.1050,
                    'longitude' => 103.9280,
                    'deskripsi' => 'Pantai di kawasan Marina untuk menikmati pemandangan laut.',
                    'link_on_maps' => 'https://www.google.com/maps/search/?api=1&query=Pantai+Marina+Batam',
                    'harga_tiket_masuk' => 10000,
                    'kategori' => ['Wisata Alam', 'Wisata Pantai', 'Wisata Rekreasi'],
                ],
                [
                    'nama_wisata' => 'Bukit Senyum',
                    'alamat_detail_wisata' => 'Kawasan Bukit Senyum, Batu Ampar, Batam',
                    'latitude' => 1.1450,
                    'longitude' => 103.9750,
                    'deskripsi' => 'Kawasan perbukitan dengan pemandangan Kota Batam dan laut.',
                    'link_on_maps' => 'https://www.google.com/maps/search/?api=1&query=Bukit+Senyum+Batam',
                    'harga_tiket_masuk' => 0,
                    'kategori' => ['Wisata Alam'],
                ],
                [
                    'nama_wisata' => 'Alun-Alun Engku Putri',
                    'alamat_detail_wisata' => 'Batam Centre, Batam',
                    'latitude' => 1.1304,
                    'longitude' => 104.0530,
                    'deskripsi' => 'Ruang terbuka publik di kawasan pemerintahan Kota Batam.',
                    'link_on_maps' => 'https://www.google.com/maps/search/?api=1&query=Alun+Alun+Engku+Putri+Batam',
                    'harga_tiket_masuk' => 0,
                    'kategori' => ['Wisata Rekreasi', 'Wisata Budaya'],
                ],
                [
                    'nama_wisata' => 'Welcome to Batam',
                    'alamat_detail_wisata' => 'Bukit Clara, Batam Centre, Batam',
                    'latitude' => 1.1305,
                    'longitude' => 104.0550,
                    'deskripsi' => 'Tulisan ikonik yang menjadi salah satu tempat berfoto di Kota Batam.',
                    'link_on_maps' => 'https://www.google.com/maps/search/?api=1&query=Welcome+to+Batam',
                    'harga_tiket_masuk' => 0,
                    'kategori' => ['Wisata Budaya', 'Wisata Rekreasi'],
                ],
                [
                    'nama_wisata' => 'Masjid Sultan Mahmud Riayat Syah',
                    'alamat_detail_wisata' => 'Batu Aji, Batam',
                    'latitude' => 1.0430,
                    'longitude' => 103.9600,
                    'deskripsi' => 'Masjid besar di Batam yang menjadi tujuan wisata religi.',
                    'link_on_maps' => 'https://www.google.com/maps/search/?api=1&query=Masjid+Sultan+Mahmud+Riayat+Syah',
                    'harga_tiket_masuk' => 0,
                    'kategori' => ['Wisata Religi', 'Wisata Budaya'],
                ],
                [
                    'nama_wisata' => 'Kampung Vietnam',
                    'alamat_detail_wisata' => 'Pulau Galang, Batam',
                    'latitude' => 0.7860,
                    'longitude' => 104.1660,
                    'deskripsi' => 'Situs bersejarah yang berkaitan dengan pengungsi Vietnam di Pulau Galang.',
                    'link_on_maps' => 'https://www.google.com/maps/search/?api=1&query=Kampung+Vietnam+Pulau+Galang',
                    'harga_tiket_masuk' => 10000,
                    'kategori' => ['Wisata Sejarah', 'Wisata Edukasi'],
                ],
                [
                    'nama_wisata' => 'Pantai Melur',
                    'alamat_detail_wisata' => 'Pulau Galang, Batam',
                    'latitude' => 0.7590,
                    'longitude' => 104.1800,
                    'deskripsi' => 'Pantai berpasir untuk menikmati suasana pesisir.',
                    'link_on_maps' => 'https://www.google.com/maps/search/?api=1&query=Pantai+Melur+Batam',
                    'harga_tiket_masuk' => 10000,
                    'kategori' => ['Wisata Alam', 'Wisata Pantai', 'Wisata Rekreasi'],
                ],
                [
                    'nama_wisata' => 'Pantai Tanjung Pinggir',
                    'alamat_detail_wisata' => 'Tanjung Pinggir, Sekupang, Batam',
                    'latitude' => 1.1430,
                    'longitude' => 103.9160,
                    'deskripsi' => 'Pantai di Sekupang dengan pemandangan laut.',
                    'link_on_maps' => 'https://www.google.com/maps/search/?api=1&query=Pantai+Tanjung+Pinggir+Batam',
                    'harga_tiket_masuk' => 10000,
                    'kategori' => ['Wisata Alam', 'Wisata Pantai', 'Wisata Rekreasi'],
                ],
                [
                    'nama_wisata' => 'Hutan Wisata Mata Kucing',
                    'alamat_detail_wisata' => 'Kawasan Hutan Wisata Mata Kucing, Batam',
                    'latitude' => 1.0950,
                    'longitude' => 103.9750,
                    'deskripsi' => 'Kawasan wisata alam dengan lingkungan hijau.',
                    'link_on_maps' => 'https://www.google.com/maps/search/?api=1&query=Hutan+Wisata+Mata+Kucing+Batam',
                    'harga_tiket_masuk' => 10000,
                    'kategori' => ['Wisata Alam', 'Wisata Edukasi', 'Wisata Rekreasi'],
                ],
                [
                    'nama_wisata' => 'Panbil Nature Reserve',
                    'alamat_detail_wisata' => 'Kawasan Muka Kuning, Batam',
                    'latitude' => 1.0730,
                    'longitude' => 104.0250,
                    'deskripsi' => 'Kawasan konservasi alam untuk menikmati lingkungan hijau.',
                    'link_on_maps' => 'https://www.google.com/maps/search/?api=1&query=Panbil+Nature+Reserve+Batam',
                    'harga_tiket_masuk' => 10000,
                    'kategori' => ['Wisata Alam', 'Wisata Edukasi', 'Wisata Rekreasi'],
                ],
                [
                    'nama_wisata' => 'Taman Rusa Sekupang',
                    'alamat_detail_wisata' => 'Sekupang, Batam',
                    'latitude' => 1.1150,
                    'longitude' => 103.9400,
                    'deskripsi' => 'Kawasan taman dan wisata keluarga yang dikenal dengan keberadaan rusa.',
                    'link_on_maps' => 'https://www.google.com/maps/search/?api=1&query=Taman+Rusa+Sekupang+Batam',
                    'harga_tiket_masuk' => 5000,
                    'kategori' => ['Wisata Alam', 'Wisata Edukasi', 'Wisata Rekreasi'],
                ],
                [
                    'nama_wisata' => 'Pantai Setokok',
                    'alamat_detail_wisata' => 'Pulau Setokok, Batam',
                    'latitude' => 0.9880,
                    'longitude' => 104.0800,
                    'deskripsi' => 'Pantai di Pulau Setokok untuk rekreasi pesisir.',
                    'link_on_maps' => 'https://www.google.com/maps/search/?api=1&query=Pantai+Setokok+Batam',
                    'harga_tiket_masuk' => 10000,
                    'kategori' => ['Wisata Alam', 'Wisata Pantai', 'Wisata Rekreasi'],
                ],
                [
                    'nama_wisata' => 'Pantai Vio Vio',
                    'alamat_detail_wisata' => 'Pulau Galang, Batam',
                    'latitude' => 0.7550,
                    'longitude' => 104.1800,
                    'deskripsi' => 'Pantai dengan pemandangan laut dan kawasan rekreasi pesisir.',
                    'link_on_maps' => 'https://www.google.com/maps/search/?api=1&query=Pantai+Vio+Vio+Batam',
                    'harga_tiket_masuk' => 10000,
                    'kategori' => ['Wisata Alam', 'Wisata Pantai', 'Wisata Rekreasi'],
                ],
                [
                    'nama_wisata' => 'Dataran Engku Putri',
                    'alamat_detail_wisata' => 'Batam Centre, Batam',
                    'latitude' => 1.1304,
                    'longitude' => 104.0530,
                    'deskripsi' => 'Area terbuka di Batam Centre untuk kegiatan publik.',
                    'link_on_maps' => 'https://www.google.com/maps/search/?api=1&query=Dataran+Engku+Putri+Batam',
                    'harga_tiket_masuk' => 0,
                    'kategori' => ['Wisata Budaya', 'Wisata Rekreasi'],
                ],
                [
                    'nama_wisata' => 'Harbour Bay',
                    'alamat_detail_wisata' => 'Kawasan Harbour Bay, Batu Ampar, Batam',
                    'latitude' => 1.1580,
                    'longitude' => 103.9900,
                    'deskripsi' => 'Kawasan pelabuhan dan komersial dengan fasilitas perjalanan dan rekreasi.',
                    'link_on_maps' => 'https://www.google.com/maps/search/?api=1&query=Harbour+Bay+Batam',
                    'harga_tiket_masuk' => 0,
                    'kategori' => ['Wisata Rekreasi'],
                ],
                [
                    'nama_wisata' => 'Nagoya Hill',
                    'alamat_detail_wisata' => 'Lubuk Baja, Batam',
                    'latitude' => 1.1450,
                    'longitude' => 104.0090,
                    'deskripsi' => 'Pusat perbelanjaan dengan berbagai toko dan kebutuhan pengunjung.',
                    'link_on_maps' => 'https://www.google.com/maps/search/?api=1&query=Nagoya+Hill+Shopping+Mall+Batam',
                    'harga_tiket_masuk' => 0,
                    'kategori' => ['Wisata Belanja'],
                ],
                [
                    'nama_wisata' => 'Grand Batam Mall',
                    'alamat_detail_wisata' => 'Lubuk Baja, Batam',
                    'latitude' => 1.1430,
                    'longitude' => 104.0080,
                    'deskripsi' => 'Pusat perbelanjaan modern dengan beragam toko dan hiburan.',
                    'link_on_maps' => 'https://www.google.com/maps/search/?api=1&query=Grand+Batam+Mall',
                    'harga_tiket_masuk' => 0,
                    'kategori' => ['Wisata Belanja'],
                ],
            ];

            /*
             * Jam operasional awal untuk seluruh destinasi.
             * Hari: 1 = Senin sampai 7 = Minggu.
             */
            $jamOperasionalWisata = [
                'Jembatan Barelang' => ['00:00:00', '23:59:59'],
                'Pantai Nongsa' => ['06:00:00', '18:00:00'],
                'Mega Wisata Ocarina' => ['08:00:00', '18:00:00'],
                'Pantai Marina' => ['06:00:00', '18:00:00'],
                'Bukit Senyum' => ['00:00:00', '23:59:59'],
                'Alun-Alun Engku Putri' => ['00:00:00', '23:59:59'],
                'Welcome to Batam' => ['00:00:00', '23:59:59'],
                'Masjid Sultan Mahmud Riayat Syah' => ['04:00:00', '21:00:00'],
                'Kampung Vietnam' => ['08:00:00', '17:00:00'],
                'Pantai Melur' => ['06:00:00', '18:00:00'],
                'Pantai Tanjung Pinggir' => ['06:00:00', '18:00:00'],
                'Hutan Wisata Mata Kucing' => ['08:00:00', '17:00:00'],
                'Panbil Nature Reserve' => ['08:00:00', '17:00:00'],
                'Taman Rusa Sekupang' => ['08:00:00', '17:00:00'],
                'Pantai Setokok' => ['06:00:00', '18:00:00'],
                'Pantai Vio Vio' => ['06:00:00', '18:00:00'],
                'Dataran Engku Putri' => ['00:00:00', '23:59:59'],
                'Harbour Bay' => ['06:00:00', '23:00:00'],
                'Nagoya Hill' => ['10:00:00', '22:00:00'],
                'Grand Batam Mall' => ['10:00:00', '22:00:00'],
            ];

            foreach ($dataWisata as $index => $item) {
                $wisata = Wisata::firstOrNew([
                    'nama_wisata' => $item['nama_wisata'],
                ]);

                if (!$wisata->exists) {
                    $wisata->id_wisata = (string) Str::uuid();
                }

                $wisata->id_kecamatan = $kecamatanIds[
                    $index % $kecamatanIds->count()
                ];

                $wisata->alamat_detail_wisata = $item['alamat_detail_wisata'];
                $wisata->latitude = $item['latitude'];
                $wisata->longitude = $item['longitude'];
                $wisata->deskripsi = $item['deskripsi'];
                $wisata->link_on_maps = $item['link_on_maps'];
                $wisata->harga_tiket_masuk = $item['harga_tiket_masuk'];

                $wisata->save();

                // Sinkronkan kategori.
                DB::table('kategori_destinasi')
                    ->where('destinasi_id', $wisata->id_wisata)
                    ->where('destinasi_type', $wisata->getMorphClass())
                    ->delete();

                $pivotData = [];

                foreach ($item['kategori'] as $namaKategori) {
                    if (!$kategoriIds->has($namaKategori)) {
                        $this->command?->warn(
                            "Kategori '{$namaKategori}' tidak ditemukan."
                        );

                        continue;
                    }

                    $pivotData[] = [
                        'id_kategori' => $kategoriIds[$namaKategori],
                        'destinasi_id' => $wisata->id_wisata,
                        'destinasi_type' => $wisata->getMorphClass(),
                    ];
                }

                if (!empty($pivotData)) {
                    DB::table('kategori_destinasi')->insert($pivotData);
                }

                // Sinkronkan jam operasional.
                $jam = $jamOperasionalWisata[$item['nama_wisata']] ?? null;

                if ($jam === null) {
                    $this->command?->warn(
                        "Jam operasional {$item['nama_wisata']} belum diatur."
                    );

                    continue;
                }

                DB::table('jam_operasi')
                    ->where('destinasi_id', $wisata->id_wisata)
                    ->where('destinasi_type', $wisata->getMorphClass())
                    ->delete();

                DB::table('jam_operasi')->insert([
                    'id_operasi' => (string) Str::uuid(),
                    'destinasi_id' => $wisata->id_wisata,
                    'destinasi_type' => $wisata->getMorphClass(),
                    'hari_mulai' => 1,
                    'hari_selesai' => 7,
                    'jam_buka' => $jam[0],
                    'jam_tutup' => $jam[1],
                    'is_open' => true,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }

            $this->command?->info(
                'Seeder wisata selesai: '
                . count($dataWisata)
                . ' data wisata diproses.'
            );
        });
    }
}