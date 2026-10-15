<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Wisata extends Model
{
    use HasFactory;

    protected $table = 'wisata';
    protected $primaryKey = 'id_wisata';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id_wisata',
        'id_kecamatan',
        'nama_wisata',
        'alamat_detail_wisata',
        'latitude',
        'longitude',
        'deskripsi',
        'link_on_maps',
        'harga_tiket_masuk',
    ];

    public function kecamatan()
    {
        return $this->belongsTo(
            Kecamatan::class,
            'id_kecamatan',
            'id_kecamatan'
        );
    }


    public function jamOperasis()
    {
        return $this->morphMany(JamOperasi::class, 'destinasi');
    }


    public function fotoDestinasis()
    {
        return $this->morphMany(FotoDestinasi::class, 'destinasi');
    }

    public function kategoris()
    {
        return $this->morphToMany(
            Kategori::class,
            'destinasi',
            'kategori_destinasi',
            'destinasi_id',
            'id_kategori'
        );
    }
}
