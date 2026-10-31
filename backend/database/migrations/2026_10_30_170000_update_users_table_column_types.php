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
        Schema::table('users', function (Blueprint $table) {
            $table->string('nama_pengguna', 100)->change();
            $table->string('email', 100)->change();
            $table->string('no_hp', 15)->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('nama_pengguna', 255)->change();
            $table->string('email', 255)->change();
            $table->string('no_hp', 255)->change();
        });
    }
};

