<?php

namespace App\Http\Controllers;

use App\Models\User;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|string|email',
            'password' => 'required|string',
        ]);

        if (!Auth::attempt($request->only('email', 'password'))) {
            throw ValidationException::withMessages([
                'email' => ['Email atau kata sandi salah.'],
            ]);
        }

        $user = Auth::user();
        $token = $user->createToken('smarttrip-token')->plainTextToken;

        return response()->json([
            'message' => 'Login berhasil.',
            'user' => $user,
            'token' => $token,
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Logout berhasil.']);
    }

    public function profile(Request $request)
    {
        return response()->json([
            'success' => true,
            'user' => $request->user(),
        ]);
    }

    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $request->validate([
            'nama_pengguna' => 'required|string|max:100',
            'email' => 'required|string|email|max:100|unique:users,email,' . $user->id_pengguna . ',id_pengguna',
            'no_hp' => 'required|string|min:10|max:15|unique:users,no_hp,' . $user->id_pengguna . ',id_pengguna',
        ]);

        $user->update([
            'nama_pengguna' => $request->nama_pengguna,
            'email' => $request->email,
            'no_hp' => $request->no_hp,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Profil berhasil diperbarui.',
            'user' => $user->fresh(),
        ]);
    }

    public function updatePassword(Request $request)
    {
        $user = $request->user();

        $request->validate([
            'current_password' => 'required|string',
            'password' => 'required|string|min:6',
        ]);

        if (!Hash::check($request->current_password, $user->password)) {
            throw ValidationException::withMessages([
                'current_password' => ['Kata sandi saat ini tidak sesuai.'],
            ]);
        }

        $user->update([
            'password' => Hash::make($request->password),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Kata sandi berhasil diperbarui.',
        ]);
    }

    public function forgotPasswordSendOtp(Request $request)
    {
        $request->validate([
            'email' => 'required|string|email',
        ]);

        $user = User::where('email', $request->email)->first();
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Email tidak terdaftar .',
            ], 404);
        }

        // Generate 6-digit OTP
        $otp = str_pad((string) random_int(100000, 999999), 6, '0', STR_PAD_LEFT);

        try {
            DB::table('password_reset_tokens')->updateOrInsert(
                ['email' => $request->email],
                [
                    'token' => $otp,
                    'created_at' => now(),
                ]
            );
        } catch (\Exception $e) {
            Log::error('Error saving OTP token: ' . $e->getMessage());
        }

        Log::info("Forgot password OTP generated for [{$request->email}]: {$otp}");

        // Kirim email OTP menggunakan template blade
        try {
            Mail::send('emails.otp', ['otp' => $otp, 'user' => $user], function ($message) use ($user) {
                $message->to($user->email, $user->nama_pengguna ?? 'Wisatawan')
                        ->subject('Kode Verifikasi OTP Lupa Kata Sandi - SmartTrip');
            });
        } catch (\Exception $e) {
            Log::error("Gagal mengirim email OTP ke {$user->email}: " . $e->getMessage());
        }

        return response()->json([
            'success' => true,
            'message' => 'Kode OTP 6-digit telah dikirimkan ke email Anda.',
            'debug_otp' => config('app.debug') ? $otp : null,
        ]);
    }

    public function forgotPasswordVerifyOtp(Request $request)
    {
        $request->validate([
            'email' => 'required|string|email',
            'otp' => 'required|string|size:6',
        ]);

        $record = DB::table('password_reset_tokens')
            ->where('email', $request->email)
            ->first();

        if (!$record) {
            return response()->json([
                'success' => false,
                'message' => 'Permintaan OTP tidak ditemukan atau sudah kedaluwarsa.',
            ], 400);
        }

        // OTP expires in 15 minutes
        if ($record->created_at && Carbon::parse($record->created_at)->addMinutes(15)->isPast()) {
            return response()->json([
                'success' => false,
                'message' => 'Kode OTP telah kedaluwarsa. Silakan kirim ulang kode baru.',
            ], 400);
        }

        if ($record->token !== $request->otp) {
            return response()->json([
                'success' => false,
                'message' => 'Kode OTP yang Anda masukkan salah. Periksa kembali.',
            ], 400);
        }

        return response()->json([
            'success' => true,
            'message' => 'Kode OTP berhasil diverifikasi.',
        ]);
    }

    public function forgotPasswordReset(Request $request)
    {
        $request->validate([
            'email' => 'required|string|email',
            'otp' => 'required|string|size:6',
            'password' => 'required|string|min:6',
        ]);

        $record = DB::table('password_reset_tokens')
            ->where('email', $request->email)
            ->first();

        if (!$record || $record->token !== $request->otp) {
            return response()->json([
                'success' => false,
                'message' => 'Verifikasi OTP gagal atau sesi telah berakhir.',
            ], 400);
        }

        if ($record->created_at && Carbon::parse($record->created_at)->addMinutes(15)->isPast()) {
            return response()->json([
                'success' => false,
                'message' => 'Sesi OTP telah kedaluwarsa. Silakan ulangi langkah pemulihan.',
            ], 400);
        }

        $user = User::where('email', $request->email)->first();
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Pengguna tidak ditemukan.',
            ], 404);
        }

        $user->update([
            'password' => Hash::make($request->password),
        ]);

        // Clean up reset token
        DB::table('password_reset_tokens')->where('email', $request->email)->delete();

        return response()->json([
            'success' => true,
            'message' => 'Kata sandi berhasil diperbarui. Silakan masuk menggunakan kata sandi baru.',
        ]);
    }

    public function uploadFotoProfil(Request $request)
    {
        $user = $request->user();

        $request->validate([
            'foto_profil' => 'required|image|mimes:jpeg,png,jpg,webp|max:5120',
        ]);

        if ($request->hasFile('foto_profil')) {
            // Hapus file lama jika ada
            if ($user->foto_profil && Storage::disk('public')->exists($user->foto_profil)) {
                Storage::disk('public')->delete($user->foto_profil);
            }

            $file = $request->file('foto_profil');
            $filename = 'avatar_' . $user->id_pengguna . '_' . time() . '.' . $file->getClientOriginalExtension();
            $path = $file->storeAs('avatars', $filename, 'public');

            $user->update([
                'foto_profil' => $path,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Foto profil berhasil diperbarui.',
                'user' => $user->fresh(),
                'foto_profil_url' => $user->fresh()->foto_profil_url,
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => 'File foto profil tidak ditemukan.',
        ], 400);
    }

    public function showFotoProfil(string $filename)
    {
        $filename = basename($filename);
        $path = 'avatars/' . $filename;

        abort_unless(
            Storage::disk('public')->exists($path),
            404,
            'Foto profil tidak ditemukan.'
        );

        return response()->file(
            Storage::disk('public')->path($path)
        );
    }
}
