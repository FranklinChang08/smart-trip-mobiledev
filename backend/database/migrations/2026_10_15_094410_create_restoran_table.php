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
        Schema::create('restoran', function (Blueprint $table) {
            $table->uuid('id_restoran')->primary();
            $table->unsignedInteger('id_kecamatan');
            // Atribut warisan dari desinasi
            $table->string('nama_restoran');
            $table->text('alamat_Detail_restoran');
            $table->decimal('latitude', 10, 8);
            $table->decimal('longitude', 11, 8);
            $table->text('deskripsi')->nullable();
            $table->string('link_on_maps')->nullable();
            // Atribut khusus restoran
            $table->decimal('harga_makan_per_orang', 12, 2)->nullable();
            $table->enum('type_food', ['Halal', 'Vegetarian', 'Semua'])->default('Semua');
            $table->timestamps();

            $table->foreign('id_kecamatan')
                ->references('id_kecamatan')
                ->on('kecamatan');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('restoran');
    }
};
