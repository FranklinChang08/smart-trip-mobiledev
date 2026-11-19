<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // 1. Hapus kolom titik_awal dan titik_akhir beserta morph dari rencana_perjalanan
        Schema::table('rencana_perjalanan', function (Blueprint $table) {
            // Drop index morph
            $table->dropIndex(['titik_awal_type', 'titik_awal_id']);
            $table->dropIndex(['titik_akhir_type', 'titik_akhir_id']);

            // Drop columns
            $table->dropColumn([
                'titik_awal',
                'titik_awal_type',
                'titik_awal_id',
                'titik_akhir',
                'titik_akhir_type',
                'titik_akhir_id',
            ]);
        });

        // 2. Hapus kolom kecamatan_pilihan dari preferensi_perjalanan
        Schema::table('preferensi_perjalanan', function (Blueprint $table) {
            if (Schema::hasColumn('preferensi_perjalanan', 'kecamatan_pilihan')) {
                $table->dropColumn('kecamatan_pilihan');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('rencana_perjalanan', function (Blueprint $table) {
            $table->string('titik_awal')->nullable();
            $table->string('titik_awal_type')->nullable();
            $table->string('titik_awal_id', 36)->nullable();
            $table->index(['titik_awal_type', 'titik_awal_id']);
            $table->string('titik_akhir')->nullable();
            $table->string('titik_akhir_type')->nullable();
            $table->string('titik_akhir_id', 36)->nullable();
            $table->index(['titik_akhir_type', 'titik_akhir_id']);
        });

        Schema::table('preferensi_perjalanan', function (Blueprint $table) {
            $table->json('kecamatan_pilihan')->nullable();
        });
    }
};
