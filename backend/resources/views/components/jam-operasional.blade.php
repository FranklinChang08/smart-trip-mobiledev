@props(['initialData' => []])

@php
    $daftarHari = [
        1 => ['kode' => 'senin', 'nama' => 'Senin'],
        2 => ['kode' => 'selasa', 'nama' => 'Selasa'],
        3 => ['kode' => 'rabu', 'nama' => 'Rabu'],
        4 => ['kode' => 'kamis', 'nama' => 'Kamis'],
        5 => ['kode' => 'jumat', 'nama' => 'Jumat'],
        6 => ['kode' => 'sabtu', 'nama' => 'Sabtu'],
        7 => ['kode' => 'minggu', 'nama' => 'Minggu'],
    ];

    $oldJamOperasional = old('jam_operasional', []);
    $jadwalLama = [];

    if (!empty($oldJamOperasional)) {
        // Jika validasi gagal, ambil dari input lama (old)
        $jadwalLama = $oldJamOperasional;
    } else {
        // Jika pertama kali load dari database ($initialData)
        foreach ($initialData as $operasi) {
            $mulai = is_array($operasi) ? $operasi['hari_mulai'] : $operasi->hari_mulai;
            $selesai = is_array($operasi) ? $operasi['hari_selesai'] : $operasi->hari_selesai;
            $isOpen = is_array($operasi) ? $operasi['is_open'] : $operasi->is_open;
            $jamBuka = is_array($operasi) ? $operasi['jam_buka'] : $operasi->jam_buka;
            $jamTutup = is_array($operasi) ? $operasi['jam_tutup'] : $operasi->jam_tutup;

            for ($i = $mulai; $i <= $selesai; $i++) {
                // Cari kode hari berdasarkan index angka (1-7)
                $k = $daftarHari[$i]['kode'] ?? null;
                if ($k) {
                    $jadwalLama[$k] = [
                        'hari' => $i,
                        'is_open' => $isOpen,
                        'jam_buka' => $jamBuka ? date('H:i', strtotime($jamBuka)) : '08:00',
                        'jam_tutup' => $jamTutup ? date('H:i', strtotime($jamTutup)) : '17:00',
                    ];
                }
            }
        }
    }
@endphp

<div class="bg-white p-6 rounded-xl border border-border shadow-sm space-y-4">
    <h2 class="text-base font-bold text-textPrimary flex items-center">
        <span class="w-2 h-5 bg-primary rounded-full mr-2"></span>
        Jam Operasional
    </h2>

    <p class="text-xs text-textSecondary">
        Pilih hari operasional dan tentukan jam buka serta jam tutup destinasi wisata.
    </p>

    @if ($errors->has('jam_operasional'))
        <p class="text-sm text-red-600" role="alert">
            {{ $errors->first('jam_operasional') }}
        </p>
    @endif

    <div class="space-y-4 divide-y divide-border">
        @foreach ($daftarHari as $indexHari => $infoHari)
            @php
                $kodeHari = $infoHari['kode'];
                $namaHari = $infoHari['nama'];

                $jadwal = $jadwalLama[$kodeHari] ?? [];

                // Cek status is_open (default 1 jika belum ada data)
                $isOpen = (int) ($jadwal['is_open'] ?? 1) === 1;
                $jamBukaVal = $jadwal['jam_buka'] ?? '08:00';
                $jamTutupVal = $jadwal['jam_tutup'] ?? '17:00';
            @endphp

            <div class="pb-4 first:pt-0 space-y-2">
                <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3">

                    <div class="flex items-center gap-3 w-32">
                        {{-- Kirim nomor hari (1-7) --}}
                        <input type="hidden" name="jam_operasional[{{ $kodeHari }}][hari]"
                            value="{{ $indexHari }}">

                        {{-- Hidden input pengaman jika checkbox tidak dicentang (mengirim nilai 0) --}}
                        <input type="hidden" name="jam_operasional[{{ $kodeHari }}][is_open]" value="0">

                        <input type="checkbox" name="jam_operasional[{{ $kodeHari }}][is_open]" value="1"
                            id="hari_{{ $kodeHari }}" @checked($isOpen)>

                        <label for="hari_{{ $kodeHari }}"
                            class="text-sm font-medium text-textPrimary cursor-pointer">
                            {{ $namaHari }}
                        </label>
                    </div>

                    <div class="flex flex-wrap items-center gap-2">
                        <div>
                            <label for="buka_{{ $kodeHari }}" class="block text-xs text-textSecondary mb-1">
                                Jam buka
                            </label>

                            <input type="time" id="buka_{{ $kodeHari }}"
                                name="jam_operasional[{{ $kodeHari }}][jam_buka]" value="{{ $jamBukaVal }}"
                                @if (!$isOpen) disabled @endif
                                class="px-3 py-1.5 bg-background border border-border rounded-lg text-sm text-textPrimary disabled:opacity-50 disabled:cursor-not-allowed">
                        </div>

                        <span class="text-xs text-textSecondary mt-5">
                            s/d
                        </span>

                        <div>
                            <label for="tutup_{{ $kodeHari }}" class="block text-xs text-textSecondary mb-1">
                                Jam tutup
                            </label>

                            <input type="time" id="tutup_{{ $kodeHari }}"
                                name="jam_operasional[{{ $kodeHari }}][jam_tutup]" value="{{ $jamTutupVal }}"
                                @if (!$isOpen) disabled @endif
                                class="px-3 py-1.5 bg-background border border-border rounded-lg text-sm text-textPrimary disabled:opacity-50 disabled:cursor-not-allowed">
                        </div>
                    </div>
                </div>

                {{-- Error per hari --}}
                @foreach (["jam_operasional.$kodeHari.is_open", "jam_operasional.$kodeHari.jam_buka", "jam_operasional.$kodeHari.jam_tutup"] as $errorKey)
                    @error($errorKey)
                        <p class="text-xs text-red-500" role="alert">
                            {{ $message }}
                        </p>
                    @enderror
                @endforeach
            </div>
        @endforeach
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', () => {
        const checkboxes = document.querySelectorAll('input[id^="hari_"]');

        checkboxes.forEach((checkbox) => {
            checkbox.addEventListener('change', () => {
                const hari = checkbox.id.replace('hari_', '');
                const jamBuka = document.getElementById('buka_' + hari);
                const jamTutup = document.getElementById('tutup_' + hari);

                jamBuka.disabled = !checkbox.checked;
                jamTutup.disabled = !checkbox.checked;
            });
        });

        // Aktifkan kembali input yang disabled sesaat sebelum form disubmit agar datanya ikut terkirim ke server
        const form = document.querySelector('form');
        if (form) {
            form.addEventListener('submit', () => {
                checkboxes.forEach((checkbox) => {
                    const hari = checkbox.id.replace('hari_', '');
                    const jamBuka = document.getElementById('buka_' + hari);
                    const jamTutup = document.getElementById('tutup_' + hari);

                    if (jamBuka) jamBuka.disabled = false;
                    if (jamTutup) jamTutup.disabled = false;
                });
            });
        }
    });
</script>
