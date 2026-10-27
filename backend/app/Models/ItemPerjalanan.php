<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ItemPerjalanan extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'item_perjalanan';
    protected $primaryKey = 'id_item';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id_hari',
        'destinasi_type',
        'destinasi_id',
        'urutan_item',
        'depature_time',
        'arrival_time',
    ];

    // Relasi ke Hari Perjalanan
    public function hariPerjalanan()
    {
        return $this->belongsTo(HariPerjalanan::class, 'id_hari', 'id_hari');
    }

    // Relasi Polymorphic ke Destinasi (mendukung morphs)
    public function destinasi()
    {
        return $this->morphTo(__FUNCTION__, 'destinasi_type', 'destinasi_id');
    }
}