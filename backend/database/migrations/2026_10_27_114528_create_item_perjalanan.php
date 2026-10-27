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
        Schema::create('item_perjalanan', function (Blueprint $table) {
            $table->uuid('id_item')->primary();
            $table->uuid('id_hari');
            $table->uuidMorphs('destinasi');
            $table->integer('urutan_item')->default(2);
            $table->time('depature_time');
            $table->time('arrival_time');
            $table->timestamps();

            $table->foreign('id_hari')
                ->references('id_hari')
                ->on('hari_perjalanan')
                ->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('item_perjalanan');
    }
};
