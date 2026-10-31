<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class RegisterController extends Controller
{
    public function register(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:100',
            'email' => 'required|email|max:100|unique:users,email',
            'phone' => 'required|string|min:10|max:15|unique:users,no_hp',
            'password' => 'required|min:8|confirmed',
        ]);

        $user = User::create([
            'nama_pengguna' => $validated['name'],
            'email' => $validated['email'],
            'no_hp' => $validated['phone'],
            'password' => Hash::make($validated['password']),
        ]);

        $token = $user->createToken('smarttrip-token')->plainTextToken;

        return response()->json([
            'message' => 'Registrasi berhasil',
            'user' => $user,
            'token' => $token,
        ], 201);
    }
}
