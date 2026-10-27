<?php

namespace App\Http\Controllers;

use App\Models\FotoDestinasi;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class FotoController extends Controller
{
    public function showFotoDestinasi(string $path)
    {
        $path = ltrim($path, '/');

        // Pastikan hanya file dalam folder wisata yang dapat diakses.
        abort_unless(
            str_starts_with($path, 'wisata/'),
            404,
            'Foto tidak ditemukan.'
        );

        abort_unless(
            Storage::disk('public')->exists($path),
            404,
            'Foto tidak ditemukan.'
        );

        return response()->file(
            Storage::disk('public')->path($path)
        );
    }
    public function showFotoRestoran(string $path)
    {
        $path = ltrim($path, '/');

        // Pastikan hanya file dalam folder wisata yang dapat diakses.
        abort_unless(
            str_starts_with($path, 'restoran/'),
            404,
            'Foto tidak ditemukan.'
        );

        abort_unless(
            Storage::disk('public')->exists($path),
            404,
            'Foto tidak ditemukan.'
        );

        return response()->file(
            Storage::disk('public')->path($path)
        );
    }
}
