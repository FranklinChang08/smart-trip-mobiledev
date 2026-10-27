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
        Schema::create('hari_perjalanan', function (Blueprint $table) {
            $table->uuid('id_hari')->primary();
            $table->uuid('id_rencana');
            $table->date('tanggal');
            $table->integer('urutan_hari')->default(2);
            $table->string('lokasi_awal');
            $table->string('lokasi_akhir');
            $table->decimal('estimasi_biaya', 12, 2)->nullable();
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
        Schema::dropIfExists('hari_perjalanan');
    }
};
