<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PreferensiPerjalanan extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'preferensi_perjalanan';
    protected $primaryKey = 'id_preferensi';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id_preferensi',
        'id_rencana',
        'kategori_minat',
        'kecamatan_pilihan',
        'preferensi_kuliner',
    ];

    protected $casts = [
        'kategori_minat' => 'array',
        'kecamatan_pilihan' => 'array',
        'preferensi_kuliner' => 'array',
    ];

    public function rencana()
    {
        return $this->belongsTo(RencanaPerjalanan::class, 'id_rencana', 'id_rencana');
    }
}
