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
        if (Schema::hasTable('wisata')) {
            Schema::table('wisata', function (Blueprint $table) {
                $table->text('link_on_maps')->nullable()->change();
            });
        }

        if (Schema::hasTable('restoran')) {
            Schema::table('restoran', function (Blueprint $table) {
                $table->text('link_on_maps')->nullable()->change();
            });
        }

        if (Schema::hasTable('penginapan')) {
            Schema::table('penginapan', function (Blueprint $table) {
                $table->text('link_on_maps')->nullable()->change();
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        if (Schema::hasTable('wisata')) {
            Schema::table('wisata', function (Blueprint $table) {
                $table->string('link_on_maps')->nullable()->change();
            });
        }

        if (Schema::hasTable('restoran')) {
            Schema::table('restoran', function (Blueprint $table) {
                $table->string('link_on_maps')->nullable()->change();
            });
        }

        if (Schema::hasTable('penginapan')) {
            Schema::table('penginapan', function (Blueprint $table) {
                $table->string('link_on_maps')->nullable()->change();
            });
        }
    }
};