<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RencanaPerjalanan extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'rencana_perjalanan';
    protected $primaryKey = 'id_rencana';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id_rencana',
        'id_pengguna',
        'id_preferensi',
        'nama_rencana',
        'hari_start',
        'hari_end',
        'total_hari',
        'titik_awal',
        'titik_awal_type',
        'titik_awal_id',
        'titik_akhir',
        'titik_akhir_type',
        'titik_akhir_id',
        'budget_trip',
        'type_food',
        'start_time',
        'end_time',
        'status',
    ];

    protected $casts = [
        'hari_start' => 'date',
        'hari_end' => 'date',
        'total_hari' => 'integer',
        'budget_trip' => 'decimal:2',
    ];

    public function pengguna()
    {
        return $this->belongsTo(User::class, 'id_pengguna', 'id_pengguna');
    }

    public function preferensi()
    {
        return $this->belongsTo(PreferensiPerjalanan::class, 'id_preferensi', 'id_preferensi');
    }

    public function hariPerjalanan()
    {
        return $this->hasMany(HariPerjalanan::class, 'id_rencana', 'id_rencana')
            ->orderBy('urutan_hari', 'asc');
    }

    public function titikAwalLocation()
    {
        return $this->morphTo('titikAwalLocation', 'titik_awal_type', 'titik_awal_id');
    }

    public function titikAkhirLocation()
    {
        return $this->morphTo('titikAkhirLocation', 'titik_akhir_type', 'titik_akhir_id');
    }
}