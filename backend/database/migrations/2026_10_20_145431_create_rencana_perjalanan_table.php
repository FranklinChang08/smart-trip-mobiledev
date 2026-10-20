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
        Schema::create('rencana_perjalanan', function (Blueprint $table) {
            $table->uuid('id_rencana')->primary();
            $table->unsignedBigInteger('id_pengguna')->nullable();
            $table->string('nama_rencana');
            $table->date('tanggal_mulai');
            $table->date('tanggal_selesai');
            $table->integer('total_hari')->default(1);
            $table->string('titik_awal');
            $table->decimal('total_anggaran', 15, 2)->nullable();
            $table->string('prioritas_anggaran')->nullable();
            $table->string('transportasi')->nullable();
            $table->text('catatan')->nullable();
            $table->enum('status', ['aktif', 'selesai', 'draf'])->default('aktif');
            $table->timestamps();

            $table->foreign('id_pengguna')
                ->references('id_pengguna')
                ->on('users')
                ->onDelete('set null');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('rencana_perjalanan');
    }
};
