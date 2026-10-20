<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RencanaPerjalanan extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'rencana_perjalanan';
    protected $primaryKey = 'id_rencana';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id_rencana',
        'id_pengguna',
        'nama_rencana',
        'tanggal_mulai',
        'tanggal_selesai',
        'total_hari',
        'titik_awal',
        'total_anggaran',
        'prioritas_anggaran',
        'transportasi',
        'catatan',
        'status',
    ];

    protected $casts = [
        'tanggal_mulai' => 'date',
        'tanggal_selesai' => 'date',
        'total_hari' => 'integer',
        'total_anggaran' => 'decimal:2',
    ];

    public function pengguna()
    {
        return $this->belongsTo(User::class, 'id_pengguna', 'id_pengguna');
    }

    public function preferensi()
    {
        return $this->hasOne(PreferensiPerjalanan::class, 'id_rencana', 'id_rencana');
    }

    public function detailItineraries()
    {
        return $this->hasMany(DetailItinerary::class, 'id_rencana', 'id_rencana')
            ->orderBy('hari_ke')
            ->orderBy('urutan');
    }
}
