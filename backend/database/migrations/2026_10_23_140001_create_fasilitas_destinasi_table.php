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
        Schema::create('fasilitas_destinasi', function (Blueprint $table) {
            $table->id('id_fasilitas_destinasi');
            $table->foreignId('id_fasilitas')
                ->constrained('fasilitas', 'id_fasilitas')
                ->onDelete('cascade');
            $table->uuidMorphs('destinasi');
            $table->timestamps();

            $table->unique(['id_fasilitas', 'destinasi_id', 'destinasi_type'], 'fasilitas_destinasi_unique');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('fasilitas_destinasi');
    }
};