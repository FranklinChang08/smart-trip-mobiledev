<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class HariPerjalanan extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'hari_perjalanan';
    protected $primaryKey = 'id_hari';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id_rencana',
        'tanggal',
        'urutan_hari',
        'lokasi_awal',
        'lokasi_awal_type',
        'lokasi_awal_id',
        'lokasi_akhir',
        'lokasi_akhir_type',
        'lokasi_akhir_id',
        'estimasi_biaya',
    ];

    // Relasi ke Rencana Perjalanan
    public function rencanaPerjalanan()
    {
        return $this->belongsTo(RencanaPerjalanan::class, 'id_rencana', 'id_rencana');
    }

    // Relasi ke Item Perjalanan
    public function itemPerjalanan()
    {
        return $this->hasMany(ItemPerjalanan::class, 'id_hari', 'id_hari')
            ->orderBy('urutan_item', 'asc');
    }

    public function lokasiAwalLocation()
    {
        return $this->morphTo('lokasiAwalLocation', 'lokasi_awal_type', 'lokasi_awal_id');
    }

    public function lokasiAkhirLocation()
    {
        return $this->morphTo('lokasiAkhirLocation', 'lokasi_akhir_type', 'lokasi_akhir_id');
    }
}