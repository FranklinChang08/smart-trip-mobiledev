<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DetailItinerary extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'detail_itinerary';
    protected $primaryKey = 'id_detail';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id_detail',
        'id_rencana',
        'hari_ke',
        'urutan',
        'tipe_item',
        'id_wisata',
        'id_restoran',
        'nama_tempat',
        'kategori',
        'waktu_mulai',
        'waktu_selesai',
        'estimasi_biaya',
        'catatan',
        'is_kustom',
    ];

    protected $casts = [
        'hari_ke' => 'integer',
        'urutan' => 'integer',
        'estimasi_biaya' => 'decimal:2',
        'is_kustom' => 'boolean',
    ];

    public function rencana()
    {
        return $this->belongsTo(RencanaPerjalanan::class, 'id_rencana', 'id_rencana');
    }

    public function wisata()
    {
        return $this->belongsTo(Wisata::class, 'id_wisata', 'id_wisata');
    }

    public function restoran()
    {
        return $this->belongsTo(Restoran::class, 'id_restoran', 'id_restoran');
    }
}
