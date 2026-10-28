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
        Schema::create('lokasi_transportasi', function (Blueprint $table) {
            $table->uuid('id_lokasi')->primary();
            $table->unsignedInteger('id_kecamatan');

            // Atribut warisan dari destinasi
            $table->string('nama_lokasi');
            $table->text('alamat_detail_lokasi');
            $table->decimal('latitude', 10, 8);
            $table->decimal('longitude', 11, 8);
            $table->text('deskripsi')->nullable();
            $table->string('link_on_maps')->nullable();

            // Atribut khusus lokasi
            $table->enum('type_lokasi', [
                'Bandara',
                'Pelabuhan',
                'Terminal Bus',
                'Stasiun',
            ]);

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
        Schema::dropIfExists('lokasi_transportasi');
    }
};
