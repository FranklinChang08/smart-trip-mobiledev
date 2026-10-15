<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class KategoriSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $kategori = [
            // Kategori wisata
            ['nama_kategori' => 'Wisata Alam', 'jenis_kategori' => 'wisata'],
            ['nama_kategori' => 'Wisata Pantai', 'jenis_kategori' => 'wisata'],
            ['nama_kategori' => 'Wisata Sejarah', 'jenis_kategori' => 'wisata'],
            ['nama_kategori' => 'Wisata Budaya', 'jenis_kategori' => 'wisata'],
            ['nama_kategori' => 'Wisata Religi', 'jenis_kategori' => 'wisata'],
            ['nama_kategori' => 'Wisata Edukasi', 'jenis_kategori' => 'wisata'],
            ['nama_kategori' => 'Wisata Rekreasi', 'jenis_kategori' => 'wisata'],
            ['nama_kategori' => 'Wisata Belanja', 'jenis_kategori' => 'wisata'],

            // Kategori restoran
            ['nama_kategori' => 'Masakan Indonesia', 'jenis_kategori' => 'restoran'],
            ['nama_kategori' => 'Masakan Melayu', 'jenis_kategori' => 'restoran'],
            ['nama_kategori' => 'Seafood', 'jenis_kategori' => 'restoran'],
            ['nama_kategori' => 'Masakan Chinese', 'jenis_kategori' => 'restoran'],
            ['nama_kategori' => 'Masakan Western', 'jenis_kategori' => 'restoran'],
            ['nama_kategori' => 'Fast Food', 'jenis_kategori' => 'restoran'],
            ['nama_kategori' => 'Kafe dan Kedai Kopi', 'jenis_kategori' => 'restoran'],
            ['nama_kategori' => 'Dessert dan Roti', 'jenis_kategori' => 'restoran'],
        ];

        foreach ($kategori as $item) {
            $exists = DB::table('kategori')
                ->where('nama_kategori', $item['nama_kategori'])
                ->where('jenis_kategori', $item['jenis_kategori'])
                ->exists();

            if (!$exists) {
                DB::table('kategori')->insert([
                    'nama_kategori' => $item['nama_kategori'],
                    'jenis_kategori' => $item['jenis_kategori'],
                ]);
            }
        }
    }
}
