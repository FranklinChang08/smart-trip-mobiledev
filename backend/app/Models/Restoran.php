<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Restoran extends Model
{
    use HasFactory;

    protected $table = 'restoran';
    protected $primaryKey = 'id_restoran';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id_restoran',
        'id_kecamatan',
        'nama_restoran',
        'alamat_Detail_restoran',
        'latitude',
        'longitude',
        'deskripsi',
        'link_on_maps',
        'harga_makan_per_orang',
        'type_food',
    ];

    public function kecamatan()
    {
        return $this->belongsTo(Kecamatan::class, 'id_kecamatan', 'id_kecamatan');
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