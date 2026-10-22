<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Kategori extends Model
{
    use HasFactory;

    protected $table = 'kategori';
    protected $primaryKey = 'id_kategori';
    public $incrementing = true;
    public $timestamps = false;

    protected $fillable = [
        'nama_kategori',
        'jenis_kategori'
    ];

    public function restorans()
    {
        return $this->morphedByMany(Restoran::class, 'destinasi', 'kategori_destinasi', 'id_kategori', 'destinasi_id');
    }

    public function wisatas()
    {
        return $this->morphedByMany(Wisata::class, 'destinasi', 'kategori_destinasi', 'id_kategori', 'destinasi_id');
    }

    public function preferensiPerjalanans()
    {
        return $this->belongsToMany(
            PreferensiPerjalanan::class,
            'preferensi_kategori',
            'id_kategori',
            'id_preferensi'
        );
    }
}
