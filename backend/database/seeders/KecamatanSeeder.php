<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class KecamatanSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $kecamatan = [
            ['nama_kecamatan' => 'Batam Kota'],
            ['nama_kecamatan' => 'Batu Aji'],
            ['nama_kecamatan' => 'Batu Ampar'],
            ['nama_kecamatan' => 'Bengkong'],
            ['nama_kecamatan' => 'Belakang Padang'],
            ['nama_kecamatan' => 'Bulang'],
            ['nama_kecamatan' => 'Galang'],
            ['nama_kecamatan' => 'Lubuk Baja'],
            ['nama_kecamatan' => 'Nongsa'],
            ['nama_kecamatan' => 'Sagulung'],
            ['nama_kecamatan' => 'Sei Beduk'],
            ['nama_kecamatan' => 'Sekupang'],
        ];

        DB::table('kecamatan')->insert($kecamatan);
    }
}
