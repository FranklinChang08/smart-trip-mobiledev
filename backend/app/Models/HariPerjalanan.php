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
        'lokasi_akhir',
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
}