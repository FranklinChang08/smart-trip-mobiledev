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
        Schema::create('wisata', function (Blueprint $table) {
            $table->uuid('id_wisata')->primary();
            $table->unsignedInteger('id_kecamatan');
            // Atribut warisan dari desinasi
            $table->string('nama_wisata');
            $table->text('alamat_detail_wisata');
            $table->decimal('latitude', 10, 8);
            $table->decimal('longitude', 11, 8);
            $table->text('deskripsi')->nullable();
            $table->string('link_on_maps')->nullable();
            // Atribut khusus Wisata
            $table->decimal('harga_tiket_masuk', 12, 2)->nullable();
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
        Schema::dropIfExists('wisata');
    }
};
