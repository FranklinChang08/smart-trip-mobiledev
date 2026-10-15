{{-- CONTAINER 2: Jam Operasional --}}
@php
    $daftarHari = [
        'senin' => 'Senin',
        'selasa' => 'Selasa',
        'rabu' => 'Rabu',
        'kamis' => 'Kamis',
        'jumat' => 'Jumat',
        'sabtu' => 'Sabtu',
        'minggu' => 'Minggu',
    ];

    $jadwalLama = old('jam_operasional', []);
@endphp

<div class="bg-white p-6 rounded-xl border border-border shadow-sm space-y-4">
    <h2 class="text-base font-bold text-textPrimary flex items-center">
        <span class="w-2 h-5 bg-primary rounded-full mr-2"></span>
        Jam Operasional
    </h2>

    <p class="text-xs text-textSecondary">
        Pilih hari operasional dan tentukan jam buka serta jam tutup
        destinasi wisata.
    </p>

    @if ($errors->has('jam_operasional'))
        <p class="text-sm text-red-600" role="alert">
            {{ $errors->first('jam_operasional') }}
        </p>
    @endif

    <div class="space-y-4 divide-y divide-border">
        @foreach ($daftarHari as $kodeHari => $namaHari)
            @php
                $jadwal = $jadwalLama[$kodeHari] ?? [];

                // Default buka jika belum ada input sebelumnya.
                $isBuka = (string) ($jadwal['buka'] ?? '1') === '1';
            @endphp

            <div class="pt-4 first:pt-0 space-y-2">
                <div class="flex flex-col sm:flex-row sm:items-center
                            justify-between gap-3">

                    <div class="flex items-center gap-3 w-32">
                        {{-- Nilai 0 dikirim jika checkbox tidak dicentang --}}
                        <input type="hidden" name="jam_operasional[{{ $kodeHari }}][buka]" value="0">

                        <input type="checkbox" name="jam_operasional[{{ $kodeHari }}][buka]" value="1"
                            id="hari_{{ $kodeHari }}" @checked($isBuka)>

                        <label for="hari_{{ $kodeHari }}" class="text-sm font-medium text-textPrimary">
                            {{ $namaHari }}
                        </label>
                    </div>

                    <div class="flex flex-wrap items-center gap-2">
                        <div>
                            <label for="buka_{{ $kodeHari }}" class="block text-xs text-textSecondary mb-1">
                                Jam buka
                            </label>

                            <input type="time" id="buka_{{ $kodeHari }}"
                                name="jam_operasional[{{ $kodeHari }}][jam_buka]"
                                value="{{ $jadwal['jam_buka'] ?? '08:00' }}" @disabled(!$isBuka)
                                class="px-3 py-1.5 bg-background border
                                       border-border rounded-lg text-sm
                                       text-textPrimary
                                       disabled:opacity-50
                                       disabled:cursor-not-allowed">
                        </div>

                        <span class="text-xs text-textSecondary mt-5">
                            s/d
                        </span>

                        <div>
                            <label for="tutup_{{ $kodeHari }}" class="block text-xs text-textSecondary mb-1">
                                Jam tutup
                            </label>

                            <input type="time" id="tutup_{{ $kodeHari }}"
                                name="jam_operasional[{{ $kodeHari }}][jam_tutup]"
                                value="{{ $jadwal['jam_tutup'] ?? '17:00' }}" @disabled(!$isBuka)
                                class="px-3 py-1.5 bg-background border
                                       border-border rounded-lg text-sm
                                       text-textPrimary
                                       disabled:opacity-50
                                       disabled:cursor-not-allowed">
                        </div>
                    </div>
                </div>

                {{-- Error per hari --}}
                @foreach (["jam_operasional.$kodeHari.buka", "jam_operasional.$kodeHari.jam_buka", "jam_operasional.$kodeHari.jam_tutup"] as $errorKey)
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
    document.querySelectorAll('input[id^="hari_"]').forEach((checkbox) => {
        checkbox.addEventListener('change', () => {
            const hari = checkbox.id.replace('hari_', '');
            const jamBuka = document.getElementById('buka_' + hari);
            const jamTutup = document.getElementById('tutup_' + hari);

            jamBuka.disabled = !checkbox.checked;
            jamTutup.disabled = !checkbox.checked;
        });
    });
</script>
