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
            'Batam Kota',
            'Batu Aji',
            'Batu Ampar',
            'Bengkong',
            'Belakang Padang',
            'Bulang',
            'Galang',
            'Lubuk Baja',
            'Nongsa',
            'Sagulung',
            'Sei Beduk',
            'Sekupang',
        ];

        foreach ($kecamatan as $nama) {
            DB::table('kecamatan')->updateOrInsert(
                ['nama_kecamatan' => $nama],
                ['nama_kecamatan' => $nama]
            );
        }
    }
}
