<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // 1. Dapatkan mapping id duplikat ke id kanonikal berdasarkan nama_kecamatan
        $allKecamatan = DB::table('kecamatan')->orderBy('id_kecamatan')->get();
        $seen = [];
        $mapping = []; // duplicate_id => canonical_id

        foreach ($allKecamatan as $k) {
            $name = trim($k->nama_kecamatan);
            if (!isset($seen[$name])) {
                $seen[$name] = $k->id_kecamatan;
            } else {
                $mapping[$k->id_kecamatan] = $seen[$name];
            }
        }

        if (!empty($mapping)) {
            foreach ($mapping as $dupId => $canonicalId) {
                // Update tabel wisata
                if (Schema::hasTable('wisata') && Schema::hasColumn('wisata', 'id_kecamatan')) {
                    DB::table('wisata')
                        ->where('id_kecamatan', $dupId)
                        ->update(['id_kecamatan' => $canonicalId]);
                }

                // Update tabel restoran
                if (Schema::hasTable('restoran') && Schema::hasColumn('restoran', 'id_kecamatan')) {
                    DB::table('restoran')
                        ->where('id_kecamatan', $dupId)
                        ->update(['id_kecamatan' => $canonicalId]);
                }

                // Update tabel penginapan
                if (Schema::hasTable('penginapan') && Schema::hasColumn('penginapan', 'id_kecamatan')) {
                    DB::table('penginapan')
                        ->where('id_kecamatan', $dupId)
                        ->update(['id_kecamatan' => $canonicalId]);
                }

                // Update tabel lokasi_transportasi
                if (Schema::hasTable('lokasi_transportasi') && Schema::hasColumn('lokasi_transportasi', 'id_kecamatan')) {
                    DB::table('lokasi_transportasi')
                        ->where('id_kecamatan', $dupId)
                        ->update(['id_kecamatan' => $canonicalId]);
                }

                // Update tabel preferensi_kecamatan
                if (Schema::hasTable('preferensi_kecamatan')) {
                    // Cari preferensi yang sudah memiliki canonicalId
                    $existingPrefs = DB::table('preferensi_kecamatan')
                        ->where('id_kecamatan', $canonicalId)
                        ->pluck('id_preferensi')
                        ->all();

                    // Hapus baris yang akan bentrok dengan canonicalId
                    if (!empty($existingPrefs)) {
                        DB::table('preferensi_kecamatan')
                            ->where('id_kecamatan', $dupId)
                            ->whereIn('id_preferensi', $existingPrefs)
                            ->delete();
                    }

                    // Remap sisanya ke canonicalId
                    DB::table('preferensi_kecamatan')
                        ->where('id_kecamatan', $dupId)
                        ->update(['id_kecamatan' => $canonicalId]);
                }

                // Hapus baris duplikat dari tabel kecamatan
                DB::table('kecamatan')->where('id_kecamatan', $dupId)->delete();
            }
        }

        // 2. Tambahkan unique constraint pada nama_kecamatan agar tidak bisa duplikat lagi
        Schema::table('kecamatan', function (Blueprint $table) {
            $table->unique('nama_kecamatan', 'kecamatan_nama_kecamatan_unique');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('kecamatan', function (Blueprint $table) {
            $table->dropUnique('kecamatan_nama_kecamatan_unique');
        });
    }
};

