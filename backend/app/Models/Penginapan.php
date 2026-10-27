<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class Penginapan extends Model
{
    use HasUuids;

    protected $table = 'penginapan';
    protected $primaryKey = 'id_penginapan';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id_kecamatan',
        'nama_penginapan',
        'alamat_detail_penginapan',
        'latitude',
        'longitude',
        'deskripsi',
        'link_on_maps',
        'harga_penginapan',
        'type_penginapan',
    ];

    protected $casts = [
        'latitude' => 'float',
        'longitude' => 'float',
        'harga_penginapan' => 'decimal:2',
    ];

    public function kecamatan()
    {
        return $this->belongsTo(
            Kecamatan::class,
            'id_kecamatan',
            'id_kecamatan'
        );
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
            'id_kategori',
            'id_penginapan',
            'id_kategori'
        );
    }

    public function fasilitas()
    {
        return $this->morphToMany(
            Fasilitas::class,
            'destinasi',
            'fasilitas_destinasi',
            'destinasi_id',
            'id_fasilitas',
            'id_penginapan',
            'id_fasilitas'
        )->withTimestamps();
    }
}