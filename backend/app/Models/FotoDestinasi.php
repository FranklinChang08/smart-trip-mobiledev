<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class FotoDestinasi extends Model
{
    use HasFactory;

    protected $table = 'foto_destinasi';
    protected $primaryKey = 'id_photo';

    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'id_photo',
        'destinasi_id',
        'destinasi_type',
        'link_photo',
    ];

    public function destinasi()
    {
        return $this->morphTo();
    }
}
