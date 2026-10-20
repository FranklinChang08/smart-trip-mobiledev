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
        Schema::create('detail_itinerary', function (Blueprint $table) {
            $table->uuid('id_detail')->primary();
            $table->uuid('id_rencana');
            $table->integer('hari_ke')->default(1);
            $table->integer('urutan')->default(1);
            $table->enum('tipe_item', ['wisata', 'restoran', 'titik_awal', 'kustom'])->default('wisata');
            $table->uuid('id_wisata')->nullable();
            $table->uuid('id_restoran')->nullable();
            $table->string('nama_tempat');
            $table->string('kategori')->nullable();
            $table->string('waktu_mulai')->nullable();
            $table->string('waktu_selesai')->nullable();
            $table->decimal('estimasi_biaya', 12, 2)->nullable();
            $table->text('catatan')->nullable();
            $table->boolean('is_kustom')->default(false);
            $table->timestamps();

            $table->foreign('id_rencana')
                ->references('id_rencana')
                ->on('rencana_perjalanan')
                ->onDelete('cascade');

            $table->foreign('id_wisata')
                ->references('id_wisata')
                ->on('wisata')
                ->onDelete('set null');

            $table->foreign('id_restoran')
                ->references('id_restoran')
                ->on('restoran')
                ->onDelete('set null');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('detail_itinerary');
    }
};
