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
        // 1. Modifikasi tabel preferensi_perjalanan agar sesuai ERD
        Schema::table('preferensi_perjalanan', function (Blueprint $table) {
            if (Schema::hasColumn('preferensi_perjalanan', 'id_rencana')) {
                $table->dropForeign(['id_rencana']);
                $table->dropColumn('id_rencana');
            }
            if (!Schema::hasColumn('preferensi_perjalanan', 'id_pengguna')) {
                $table->unsignedBigInteger('id_pengguna')->nullable()->after('id_preferensi');
                $table->foreign('id_pengguna')
                    ->references('id_pengguna')
                    ->on('users')
                    ->onDelete('set null');
            }
            if (!Schema::hasColumn('preferensi_perjalanan', 'type_food')) {
                $table->string('type_food')->nullable()->after('id_pengguna');
            }
            if (!Schema::hasColumn('preferensi_perjalanan', 'maks_budget_trip')) {
                $table->decimal('maks_budget_trip', 15, 2)->nullable()->after('type_food');
            }
            if (Schema::hasColumn('preferensi_perjalanan', 'is_halal')) {
                $table->dropColumn('is_halal');
            }
            if (Schema::hasColumn('preferensi_perjalanan', 'is_seafood')) {
                $table->dropColumn('is_seafood');
            }
        });

        // 2. Modifikasi tabel rencana_perjalanan agar sesuai ERD (menghapus catatan)
        Schema::table('rencana_perjalanan', function (Blueprint $table) {
            if (!Schema::hasColumn('rencana_perjalanan', 'id_preferensi')) {
                $table->uuid('id_preferensi')->nullable()->after('id_pengguna');
                $table->foreign('id_preferensi')
                    ->references('id_preferensi')
                    ->on('preferensi_perjalanan')
                    ->onDelete('set null');
            }
            if (Schema::hasColumn('rencana_perjalanan', 'tanggal_mulai') && !Schema::hasColumn('rencana_perjalanan', 'hari_start')) {
                $table->renameColumn('tanggal_mulai', 'hari_start');
            }
            if (Schema::hasColumn('rencana_perjalanan', 'tanggal_selesai') && !Schema::hasColumn('rencana_perjalanan', 'hari_end')) {
                $table->renameColumn('tanggal_selesai', 'hari_end');
            }
            if (Schema::hasColumn('rencana_perjalanan', 'total_anggaran') && !Schema::hasColumn('rencana_perjalanan', 'budget_trip')) {
                $table->renameColumn('total_anggaran', 'budget_trip');
            }
            if (!Schema::hasColumn('rencana_perjalanan', 'type_food')) {
                $table->string('type_food')->nullable()->after('budget_trip');
            }
            if (!Schema::hasColumn('rencana_perjalanan', 'start_time')) {
                $table->time('start_time')->nullable()->after('type_food');
            }
            if (!Schema::hasColumn('rencana_perjalanan', 'end_time')) {
                $table->time('end_time')->nullable()->after('start_time');
            }
            if (Schema::hasColumn('rencana_perjalanan', 'catatan')) {
                $table->dropColumn('catatan');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('rencana_perjalanan', function (Blueprint $table) {
            if (Schema::hasColumn('rencana_perjalanan', 'id_preferensi')) {
                $table->dropForeign(['id_preferensi']);
                $table->dropColumn('id_preferensi');
            }
            if (Schema::hasColumn('rencana_perjalanan', 'hari_start')) {
                $table->renameColumn('hari_start', 'tanggal_mulai');
            }
            if (Schema::hasColumn('rencana_perjalanan', 'hari_end')) {
                $table->renameColumn('hari_end', 'tanggal_selesai');
            }
            if (Schema::hasColumn('rencana_perjalanan', 'budget_trip')) {
                $table->renameColumn('budget_trip', 'total_anggaran');
            }
            if (Schema::hasColumn('rencana_perjalanan', 'type_food')) {
                $table->dropColumn('type_food');
            }
            if (Schema::hasColumn('rencana_perjalanan', 'start_time')) {
                $table->dropColumn('start_time');
            }
            if (Schema::hasColumn('rencana_perjalanan', 'end_time')) {
                $table->dropColumn('end_time');
            }
            if (!Schema::hasColumn('rencana_perjalanan', 'catatan')) {
                $table->text('catatan')->nullable();
            }
        });

        Schema::table('preferensi_perjalanan', function (Blueprint $table) {
            if (Schema::hasColumn('preferensi_perjalanan', 'id_pengguna')) {
                $table->dropForeign(['id_pengguna']);
                $table->dropColumn('id_pengguna');
            }
            if (Schema::hasColumn('preferensi_perjalanan', 'type_food')) {
                $table->dropColumn('type_food');
            }
            if (Schema::hasColumn('preferensi_perjalanan', 'maks_budget_trip')) {
                $table->dropColumn('maks_budget_trip');
            }
            if (!Schema::hasColumn('preferensi_perjalanan', 'is_halal')) {
                $table->boolean('is_halal')->default(false);
            }
            if (!Schema::hasColumn('preferensi_perjalanan', 'is_seafood')) {
                $table->boolean('is_seafood')->default(false);
            }
            if (!Schema::hasColumn('preferensi_perjalanan', 'id_rencana')) {
                $table->uuid('id_rencana')->nullable();
                $table->foreign('id_rencana')
                    ->references('id_rencana')
                    ->on('rencana_perjalanan')
                    ->onDelete('cascade');
            }
        });
    }
};