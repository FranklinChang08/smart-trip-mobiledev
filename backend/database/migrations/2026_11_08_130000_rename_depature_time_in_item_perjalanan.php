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
        if (Schema::hasTable('item_perjalanan')) {
            Schema::table('item_perjalanan', function (Blueprint $table) {
                if (Schema::hasColumn('item_perjalanan', 'depature_time') && !Schema::hasColumn('item_perjalanan', 'departure_time')) {
                    $table->renameColumn('depature_time', 'departure_time');
                }
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        if (Schema::hasTable('item_perjalanan')) {
            Schema::table('item_perjalanan', function (Blueprint $table) {
                if (Schema::hasColumn('item_perjalanan', 'departure_time') && !Schema::hasColumn('item_perjalanan', 'depature_time')) {
                    $table->renameColumn('departure_time', 'depature_time');
                }
            });
        }
    }
};

