<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Restoran extends Model
{
    use HasFactory;

    protected $table = 'restoran';
    protected $primaryKey = 'id_destinasi';

    protected $fillable = [
        'nama_destinasi',
        'alamat_detail_destinasi',
        'latitude',
        'longitude',
        'deskripsi',
        'link_on_maps',
        'created_at',
        'harga_makan_per_orang',
        'type_food',
    ];

    public function jamOperasis()
    {
        return $this->morphMany(JamOperasi::class, 'destinasi');
    }

    public function kecamatans()
    {
        return $this->morphMany(Kecamatan::class, 'destinasi');
    }

    public function fotoDestinasis()
    {
        return $this->morphMany(FotoDestinasi::class, 'destinasi');
    }

    public function kategoris()
    {
        return $this->morphToMany(Kategori::class, 'destinasi', 'kategori_destinasi', 'destinasi_id', 'id_kategori');
    }

    // public function itemDestinasis()
    // {
    //     return $this->morphMany(ItemDestinasi::class, 'destinasi');
    // }
}
