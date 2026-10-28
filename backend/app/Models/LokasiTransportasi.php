<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class LokasiTransportasi extends Model
{
    use HasUuids;

    protected $table = 'lokasi_transportasi';
    protected $primaryKey = 'id_lokasi';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id_kecamatan',
        'nama_lokasi',
        'alamat_detail_lokasi',
        'latitude',
        'longitude',
        'deskripsi',
        'link_on_maps',
        'type_lokasi',
    ];

    protected $casts = [
        'latitude' => 'float',
        'longitude' => 'float',
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

    public function fasilitas()
    {
        return $this->morphToMany(
            Fasilitas::class,
            'destinasi',
            'fasilitas_destinasi',
            'destinasi_id',
            'id_fasilitas',
            'id_lokasi',
            'id_fasilitas'
        )->withTimestamps();
    }
}
