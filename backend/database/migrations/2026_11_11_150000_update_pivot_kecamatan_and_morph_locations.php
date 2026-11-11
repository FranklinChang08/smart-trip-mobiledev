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
        // 1. Buat tabel pivot preferensi_kecamatan
        if (!Schema::hasTable('preferensi_kecamatan')) {
            Schema::create('preferensi_kecamatan', function (Blueprint $table) {
                $table->uuid('id_preferensi');
                $table->unsignedInteger('id_kecamatan');

                $table->primary(['id_preferensi', 'id_kecamatan']);

                $table->foreign('id_preferensi')
                    ->references('id_preferensi')
                    ->on('preferensi_perjalanan')
                    ->onDelete('cascade');

                $table->foreign('id_kecamatan')
                    ->references('id_kecamatan')
                    ->on('kecamatan')
                    ->onDelete('cascade');
            });
        }

        // 2. Tambahkan kolom morph titik_awal dan titik_akhir di rencana_perjalanan
        Schema::table('rencana_perjalanan', function (Blueprint $table) {
            if (!Schema::hasColumn('rencana_perjalanan', 'titik_awal_type')) {
                $table->string('titik_awal_type')->nullable()->after('titik_awal');
                $table->string('titik_awal_id', 36)->nullable()->after('titik_awal_type');
                $table->index(['titik_awal_type', 'titik_awal_id']);
            }
            if (!Schema::hasColumn('rencana_perjalanan', 'titik_akhir')) {
                $table->string('titik_akhir')->nullable()->after('titik_awal_id');
            }
            if (!Schema::hasColumn('rencana_perjalanan', 'titik_akhir_type')) {
                $table->string('titik_akhir_type')->nullable()->after('titik_akhir');
                $table->string('titik_akhir_id', 36)->nullable()->after('titik_akhir_type');
                $table->index(['titik_akhir_type', 'titik_akhir_id']);
            }
        });

        // 3. Tambahkan kolom morph lokasi_awal dan lokasi_akhir di hari_perjalanan
        Schema::table('hari_perjalanan', function (Blueprint $table) {
            if (!Schema::hasColumn('hari_perjalanan', 'lokasi_awal_type')) {
                $table->string('lokasi_awal_type')->nullable()->after('lokasi_awal');
                $table->string('lokasi_awal_id', 36)->nullable()->after('lokasi_awal_type');
                $table->index(['lokasi_awal_type', 'lokasi_awal_id']);
            }
            if (!Schema::hasColumn('hari_perjalanan', 'lokasi_akhir_type')) {
                $table->string('lokasi_akhir_type')->nullable()->after('lokasi_akhir');
                $table->string('lokasi_akhir_id', 36)->nullable()->after('lokasi_akhir_type');
                $table->index(['lokasi_akhir_type', 'lokasi_akhir_id']);
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('preferensi_kecamatan');

        Schema::table('rencana_perjalanan', function (Blueprint $table) {
            if (Schema::hasColumn('rencana_perjalanan', 'titik_awal_type')) {
                $table->dropIndex(['titik_awal_type', 'titik_awal_id']);
                $table->dropColumn(['titik_awal_type', 'titik_awal_id']);
            }
            if (Schema::hasColumn('rencana_perjalanan', 'titik_akhir_type')) {
                $table->dropIndex(['titik_akhir_type', 'titik_akhir_id']);
                $table->dropColumn(['titik_akhir_type', 'titik_akhir_id', 'titik_akhir']);
            }
        });

        Schema::table('hari_perjalanan', function (Blueprint $table) {
            if (Schema::hasColumn('hari_perjalanan', 'lokasi_awal_type')) {
                $table->dropIndex(['lokasi_awal_type', 'lokasi_awal_id']);
                $table->dropColumn(['lokasi_awal_type', 'lokasi_awal_id']);
            }
            if (Schema::hasColumn('hari_perjalanan', 'lokasi_akhir_type')) {
                $table->dropIndex(['lokasi_akhir_type', 'lokasi_akhir_id']);
                $table->dropColumn(['lokasi_akhir_type', 'lokasi_akhir_id']);
            }
        });
    }
};

