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
        'id_pengguna',
        'type_food',
        'maks_budget_trip',
    ];

    protected $casts = [
        'maks_budget_trip' => 'decimal:2',
    ];

    public function pengguna()
    {
        return $this->belongsTo(User::class, 'id_pengguna', 'id_pengguna');
    }

    public function rencanaPerjalanan()
    {
        return $this->hasMany(RencanaPerjalanan::class, 'id_preferensi', 'id_preferensi');
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

    public function kecamatans()
    {
        return $this->belongsToMany(
            Kecamatan::class,
            'preferensi_kecamatan',
            'id_preferensi',
            'id_kecamatan'
        );
    }

    public function getKecamatanPilihanAttribute($value)
    {
        if ($this->relationLoaded('kecamatans') && $this->kecamatans->isNotEmpty()) {
            return $this->kecamatans->pluck('nama_kecamatan')->all();
        }

        return $value;
    }
}