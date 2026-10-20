<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('preferensi_perjalanan', function (Blueprint $table) {
            $table->uuid('id_preferensi')->primary();
            $table->uuid('id_rencana');
            $table->json('kategori_minat')->nullable();
            $table->json('kecamatan_pilihan')->nullable();
            $table->json('preferensi_kuliner')->nullable();
            $table->timestamps();

            $table->foreign('id_rencana')
                ->references('id_rencana')
                ->on('rencana_perjalanan')
                ->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('preferensi_perjalanan');
    }
};
