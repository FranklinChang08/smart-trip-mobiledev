<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    /**
     * Tampilkan form login admin.
     * Tidak auto-redirect ke dashboard agar admin selalu melihat form login ketika membuka rute login.
     */
    public function showLoginForm()
    {
        return view('admin.auth.login');
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => ['required', 'string'],
            'password' => ['required', 'string'],
        ], [
            'email.required' => 'Alamat email wajib diisi',
            'password.required' => 'Kata sandi wajib diisi',
        ]);

        $loginInput = $request->input('email');
        $loginField = filter_var($loginInput, FILTER_VALIDATE_EMAIL) ? 'email' : 'name';

        $credentials = [
            $loginField => $loginInput,
            'password' => $request->input('password'),
        ];

        $remember = $request->boolean('remember');

        $user = User::where($loginField, $loginInput)->first();
        if (!$user) {
            return back()
                ->withInput($request->only('email', 'remember'))
                ->withErrors([
                    'email' => 'Alamat email tidak terdaftar',
                ]);
        }

        // Cek autentikasi password
        if (!Auth::attempt($credentials, $remember)) {
            return back()
                ->withInput($request->only('email', 'remember'))
                ->withErrors([
                    'password' => 'Kata sandi yang Anda masukkan salah.',
                ]);
        }

        $user = Auth::user();

        if (!$user->isAdmin()) {
            Auth::logout();
            $request->session()->invalidate();
            $request->session()->regenerateToken();

            return back()
                ->withInput($request->only('email'))
                ->withErrors([
                    'email' => 'Akses ditolak. Akun ini tidak memiliki hak akses Administrator.',
                ]);
        }

        $request->session()->regenerate();

        return redirect()->route('admin.dashboard')->with('success', 'Selamat datang kembali, ' . $user->name . '!');
    }

    // logout
    public function logout(Request $request)
    {
        Auth::logout();

        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('admin.login')->with('success', 'Anda telah berhasil logout.');
    }
}
