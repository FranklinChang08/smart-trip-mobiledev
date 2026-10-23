<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class FasilitasSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $fasilitas = [
            'WiFi Gratis',
            'Area Parkir',
            'Toilet',
            'Musholla',
            'AC (Air Conditioner)',
            'Ruang VIP / Private Room',
            'Area Merokok (Smoking Area)',
            'Area Bebas Rokok (Non-Smoking)',
            'Kursi Bayi (High Chair)',
            'Pembayaran QRIS / Non-Tunai',
            'Akses Ramah Disabilitas',
            'Area Terbuka / Outdoor',
            'Live Music',
            'Colokan Listrik / Stop Kontak',
        ];

        foreach ($fasilitas as $nama) {
            $exists = DB::table('fasilitas')->where('nama_fasilitas', $nama)->exists();
            if (!$exists) {
                DB::table('fasilitas')->insert([
                    'nama_fasilitas' => $nama,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }
        }
    }
}