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
        'budget_trip',
        'type_food',
        'start_time',
        'end_time',
        'status',
    ];

    protected $appends = [
        'titik_awal',
        'titik_akhir',
        'titik_awal_location',
        'titik_akhir_location',
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

    // Helper accessor untuk titik awal (diambil dari lokasi awal hari ke-1)
    public function getTitikAwalAttribute()
    {
        return $this->hariPerjalanan->first()?->lokasi_awal;
    }

    // Helper accessor untuk titik akhir (diambil dari lokasi akhir hari terakhir)
    public function getTitikAkhirAttribute()
    {
        return $this->hariPerjalanan->last()?->lokasi_akhir ?? $this->titik_awal;
    }

    // Helper accessor untuk lokasi awal morph object
    public function getTitikAwalLocationAttribute()
    {
        return $this->hariPerjalanan->first()?->lokasiAwalLocation;
    }

    // Helper accessor untuk lokasi akhir morph object
    public function getTitikAkhirLocationAttribute()
    {
        return $this->hariPerjalanan->last()?->lokasiAkhirLocation;
    }
}