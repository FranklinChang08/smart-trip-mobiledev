<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application database.
     */
    public function run(): void
    {
        $this->call([
            AdminSeeder::class,
            KategoriSeeder::class,
            KecamatanSeeder::class,
            FasilitasSeeder::class,
            WisataSeeder::class,
            RestoranSeeder::class,
        ]);
    }
}