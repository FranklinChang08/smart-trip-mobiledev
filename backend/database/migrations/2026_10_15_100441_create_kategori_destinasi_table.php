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
        Schema::create('kategori_destinasi', function (Blueprint $table) {
            $table->increments('id_kategori_destinasi')->primary();
            $table->unsignedInteger('id_kategori');
            // Polimorfik relasi untuk mendukung restoran dan wisata sekaligus
            $table->uuidMorphs('destinasi');


            $table->foreign('id_kategori')
                ->references('id_kategori')
                ->on('kategori');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('kategori_destinasi');
    }
};
