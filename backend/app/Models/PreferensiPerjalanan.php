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
        'kecamatan_pilihan',
        'is_halal',
        'is_seafood',
    ];

    protected $casts = [
        'kecamatan_pilihan' => 'array',
        'is_halal' => 'boolean',
        'is_seafood' => 'boolean',
    ];

    public function rencana()
    {
        return $this->belongsTo(RencanaPerjalanan::class, 'id_rencana', 'id_rencana');
    }

    public function kategoris()
    {
        return $this->belongsToMany(
            Kategori::class,
            'preferensi_kategori',
            'id_preferensi',
            'id_kategori'
        );
    }
}
