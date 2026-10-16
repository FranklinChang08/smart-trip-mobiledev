<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\FotoDestinasi;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class FotoDestinasiController extends Controller
{
    public function destroy($id)
    {
        try {
            // 1. Cari data foto berdasarkan ID
            $foto = FotoDestinasi::findOrFail($id);

            // 2. Cek apakah file fisiknya ada di storage (public disk), lalu hapus
            // Kolom link_photo berasumsi menyimpan path seperti: 'wisata/nama_file.jpg'
            if ($foto->link_photo && Storage::disk('public')->exists($foto->link_photo)) {
                Storage::disk('public')->delete($foto->link_photo);
            }

            // 3. Hapus record dari database
            $foto->delete();

            // 4. Return response (sesuaikan apakah menggunakan AJAX/JSON atau redirect biasa)
            if (request()->expectsJson()) {
                return response()->json([
                    'success' => true,
                    'message' => 'Foto destinasi berhasil dihapus.'
                ]);
            }

            return back()->with('success', 'Foto destinasi berhasil dihapus.');

        } catch (\Exception $e) {
            if (request()->expectsJson()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Gagal menghapus foto: ' . $e->getMessage()
                ], 500);
            }

            return back()->with('error', 'Gagal menghapus foto: ' . $e->getMessage());
        }
    }
}
