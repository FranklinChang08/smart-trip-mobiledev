<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Kecamatan extends Model
{
    use HasFactory;

    protected $table = 'kecamatan';
    protected $primaryKey = 'id_kecamatan';
    public $timestamps = false;

    protected $fillable = [
        'nama_kecamatan',
    ];

    public function wisatas()
    {
        return $this->hasMany(Wisata::class, 'id_kecamatan', 'id_kecamatan');
    }

    public function restorans()
    {
        return $this->hasMany(Restoran::class, 'id_kecamatan', 'id_kecamatan');
    }

    public function penginapans()
    {
        return $this->hasMany(Penginapan::class, 'id_kecamatan', 'id_kecamatan');
    }

    public function lokasiTransportasis()
    {
        return $this->hasMany(LokasiTransportasi::class, 'id_kecamatan', 'id_kecamatan');
    }

    public function preferensis()
    {
        return $this->belongsToMany(
            PreferensiPerjalanan::class,
            'preferensi_kecamatan',
            'id_kecamatan',
            'id_preferensi'
        );
    }
}