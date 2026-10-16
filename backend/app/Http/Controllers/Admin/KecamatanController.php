<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Kecamatan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\Rule;

class KecamatanController extends Controller
{
    public function index(Request $request)
    {
        $admin = Auth::user();
        return view('admin.wisata.wisata', compact('admin'));
    }
    public function create()
    {
        $admin = Auth::user();
        return view('admin.wisata.form-wisata', compact('admin'));
    }


    public function store(Request $request)
    {
        $validated = $request->validate([
            'nama_kecamatan' => [
                'required',
                'string',
                'max:255',
                Rule::unique('kecamatan', 'nama_kecamatan')
                    ->where(fn($query) => $query->whereRaw(
                        'LOWER(nama_kecamatan) = LOWER(?)',
                        [$request->nama_kecamatan]
                    )),
            ],
        ], [
            'nama_kecamatan.required' => 'Nama kecamatan wajib diisi.',
            'nama_kecamatan.unique' => 'Nama kecamatan sudah terdaftar.',
        ]);

        $kecamatan = Kecamatan::create($validated);

        return response()->json([
            'message' => 'Kecamatan berhasil ditambahkan.',
            'kecamatan' => $kecamatan,
        ], 201);
    }
}
