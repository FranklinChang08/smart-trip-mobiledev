<?php

namespace App\Models;

use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $primaryKey = 'id_pengguna';
    protected $fillable = [
        'nama_pengguna',
        'email',
        'no_hp',
        'foto_profil',
        'password',
        'role',
    ];

    protected $appends = [
        'foto_profil_url',
    ];

    public function getFotoProfilUrlAttribute(): ?string
    {
        if (!$this->foto_profil) {
            return null;
        }

        if (str_starts_with($this->foto_profil, 'http://') || str_starts_with($this->foto_profil, 'https://')) {
            return $this->foto_profil;
        }

        $filename = basename($this->foto_profil);
        $root = request() ? request()->root() : config('app.url');
        return rtrim($root, '/') . "/api/user/foto/{$filename}";
    }

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    public function isAdmin(): bool
    {
        return strtolower($this->role ?? '') === 'admin';
    }

    public function preferensi()
    {
        return $this->hasOne(PreferensiPerjalanan::class, 'id_pengguna', 'id_pengguna');
    }

    public function rencanaPerjalanan()
    {
        return $this->hasMany(RencanaPerjalanan::class, 'id_pengguna', 'id_pengguna');
    }
}