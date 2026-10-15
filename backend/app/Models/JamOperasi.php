<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\MorphTo;

class JamOperasi extends Model
{
    protected $table = 'jam_operasi';

    protected $primaryKey = 'id_operasi';

    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'id_operasi',
        'hari_mulai',
        'hari_selesai',
        'jam_buka',
        'jam_tutup',
        'is_open',
    ];

    protected $casts = [
        'hari_mulai' => 'integer',
        'hari_selesai' => 'integer',
        'is_open' => 'boolean',
    ];

    public function destinasi(): MorphTo
    {
        return $this->morphTo();
    }

    public function getRentangHariAttribute(): string
    {
        $hari = [
            1 => 'Senin',
            2 => 'Selasa',
            3 => 'Rabu',
            4 => 'Kamis',
            5 => 'Jumat',
            6 => 'Sabtu',
            7 => 'Minggu',
        ];

        if ($this->hari_mulai === $this->hari_selesai) {
            return $hari[$this->hari_mulai];
        }

        return $hari[$this->hari_mulai]
            . ' – '
            . $hari[$this->hari_selesai];
    }
}
