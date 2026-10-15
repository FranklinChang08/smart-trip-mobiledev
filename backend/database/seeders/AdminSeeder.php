<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AdminSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $existingPhoneUser = User::where('no_hp', '085819808954')
            ->where('email', '!=', 'admin@gmail.com')
            ->first();

        if ($existingPhoneUser) {
            $existingPhoneUser->update(['no_hp' => '085819808950']);
        }

        User::updateOrCreate(
            ['email' => 'admin@gmail.com'],
            [
                'nama_pengguna' => 'Admin',
                'no_hp' => '085819808954',
                'role' => 'admin',
                'password' => Hash::make('admin123'),
            ]
        );
    }
}
