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
        Schema::create('penginapan', function (Blueprint $table) {
            $table->uuid('id_penginapan')->primary();
            $table->unsignedInteger('id_kecamatan');

            // Atribut warisan dari destinasi
            $table->string('nama_penginapan');
            $table->text('alamat_detail_penginapan');
            $table->decimal('latitude', 10, 8);
            $table->decimal('longitude', 11, 8);
            $table->text('deskripsi')->nullable();
            $table->string('link_on_maps')->nullable();

            // Atribut khusus penginapan
            $table->decimal('harga_penginapan', 12, 2)->nullable();
            $table->enum('type_penginapan', [
                'Hotel',
                'Resort',
                'Villa',
                'Guest House',
                'Hostel',
                'Homestay',
            ])->default('Hotel');

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
        Schema::dropIfExists('penginapan');
    }
};
