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
        Schema::create('jam_operasi', function (Blueprint $table) {
            $table->uuid('id_operasi')->primary();

            // Relasi polymorphic ke Wisata atau Restoran.
            $table->uuidMorphs('destinasi');

            // Senin = 1 sampai Minggu = 7.
            $table->unsignedTinyInteger('hari_mulai');
            $table->unsignedTinyInteger('hari_selesai');

            $table->time('jam_buka')->nullable();
            $table->time('jam_tutup')->nullable();

            $table->boolean('is_open')->default(true);

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('jam_operasi');
    }
};
