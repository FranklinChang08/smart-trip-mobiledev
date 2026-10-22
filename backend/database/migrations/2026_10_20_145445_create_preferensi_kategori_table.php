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
        Schema::create('preferensi_kategori', function (Blueprint $table) {
            $table->uuid('id_preferensi');
            $table->unsignedInteger('id_kategori');

            $table->primary(['id_preferensi', 'id_kategori']);

            $table->foreign('id_preferensi')
                ->references('id_preferensi')
                ->on('preferensi_perjalanan')
                ->onDelete('cascade');

            $table->foreign('id_kategori')
                ->references('id_kategori')
                ->on('kategori')
                ->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('preferensi_kategori');
    }
};
