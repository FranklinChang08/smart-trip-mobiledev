@if ($paginator->hasPages())
    <div class="flex items-center justify-between sm:justify-end gap-3 w-full py-2">
        {{-- Tombol First Page (<<) --}}
        @if ($paginator->onFirstPage())
            <span
                class="px-3 py-2 border border-border rounded-lg text-xs text-textSecondary/40 bg-background cursor-not-allowed flex items-center justify-center"
                title="Halaman Pertama">
                <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M11 19l-7-7 7-7m8 14l-7-7 7-7" />
                </svg>
            </span>
        @else
            <a href="{{ $paginator->url(1) }}"
                class="px-3 py-2 border border-border rounded-lg text-xs text-textPrimary bg-white hover:bg-slate-50 transition flex items-center justify-center"
                title="Halaman Pertama">
                <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M11 19l-7-7 7-7m8 14l-7-7 7-7" />
                </svg>
            </a>
        @endif

        {{-- Tombol Previous (<) --}}
        @if ($paginator->onFirstPage())
            <span
                class="px-3 py-2 border border-border rounded-lg text-xs text-textSecondary/40 bg-background cursor-not-allowed flex items-center justify-center"
                title="Sebelumnya">
                <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
                </svg>
            </span>
        @else
            <a href="{{ $paginator->previousPageUrl() }}"
                class="px-3 py-2 border border-border rounded-lg text-xs text-textPrimary bg-white hover:bg-slate-50 transition flex items-center justify-center"
                title="Sebelumnya">
                <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
                </svg>
            </a>
        @endif

        {{-- Halaman Aktif & Terakhir --}}
        <div class="flex items-center gap-2 text-xs text-textSecondary">
            <span class="px-3.5 py-2 rounded-lg text-xs font-semibold text-white bg-primary shadow-sm cursor-default">
                {{ $paginator->currentPage() }}
            </span>
            <span>of</span>
            <span
                class="px-3.5 py-2 border border-border rounded-lg text-xs font-medium text-textPrimary bg-white cursor-default">
                {{ $paginator->lastPage() }}
            </span>
        </div>

        {{-- Tombol Next (>) --}}
        @if ($paginator->hasMorePages())
            <a href="{{ $paginator->nextPageUrl() }}"
                class="px-3 py-2 border border-border rounded-lg text-xs text-textPrimary bg-white hover:bg-slate-50 transition flex items-center justify-center"
                title="Selanjutnya">
                <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                </svg>
            </a>
        @else
            <span
                class="px-3 py-2 border border-border rounded-lg text-xs text-textSecondary/40 bg-background cursor-not-allowed flex items-center justify-center"
                title="Selanjutnya">
                <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                </svg>
            </span>
        @endif

        {{-- Tombol Last Page (>>) --}}
        @if ($paginator->hasMorePages())
            <a href="{{ $paginator->url($paginator->lastPage()) }}"
                class="px-3 py-2 border border-border rounded-lg text-xs text-textPrimary bg-white hover:bg-slate-50 transition flex items-center justify-center"
                title="Halaman Terakhir">
                <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M13 5l7 7-7 7M5 5l7 7-7 7" />
                </svg>
            </a>
        @else
            <span
                class="px-3 py-2 border border-border rounded-lg text-xs text-textSecondary/40 bg-background cursor-not-allowed flex items-center justify-center"
                title="Halaman Terakhir">
                <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M13 5l7 7-7 7M5 5l7 7-7 7" />
                </svg>
            </span>
        @endif

        {{-- CUSTOM DROPDOWN SELECT HALAMAN (Gaya Senada dengan Desain Anda) --}}
        <div class="flex items-center gap-1.5 text-xs text-textSecondary ml-2">
            <span>Page</span>
            <div class="relative inline-block text-left custom-pagin-dropdown">
                {{-- Trigger Button (Mirip komponen Anda) --}}
                <button type="button" onclick="togglePaginDropdown(event, this)"
                    class="px-3 py-2 bg-white border border-border rounded-lg text-xs font-medium text-textPrimary hover:bg-slate-50 focus:outline-none focus:ring-1 focus:ring-primary flex items-center justify-between gap-2 min-w-13.75 shadow-sm">
                    <span>{{ $paginator->currentPage() }}</span>
                    <svg class="w-3 h-3 text-textPrimary opacity-60 transition-transform duration-200 arrow-icon"
                        fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                    </svg>
                </button>

                {{-- Panel Daftar Pilihan Halaman (Posisi absolute ke atas atau diatur agar tidak terpotong) --}}
                <div
                    class="pagin-dropdown-panel absolute right-0 bottom-full mb-1 w-24 bg-white border border-border rounded-lg shadow-lg z-50 hidden max-h-48 overflow-y-auto divide-y divide-border/40">
                    <div class="py-1">
                        @for ($i = 1; $i <= $paginator->lastPage(); $i++)
                            <a href="{{ $paginator->url($i) }}"
                                class="block px-3 py-1.5 text-xs text-textPrimary hover:bg-primary/10 transition-colors {{ $paginator->currentPage() == $i ? 'font-semibold bg-primary/5 text-primary' : '' }}">
                                Page {{ $i }}
                            </a>
                        @endfor
                    </div>
                </div>
            </div>
            <span>of {{ $paginator->lastPage() }}</span>
        </div>
    </div>

    {{-- Script ringan untuk interaksi buka-tutup dropdown custom --}}
    <script>
        function togglePaginDropdown(event, button) {
            event.stopPropagation();
            const container = button.closest('.custom-pagin-dropdown');
            const panel = container.querySelector('.pagin-dropdown-panel');
            const arrow = container.querySelector('.arrow-icon');

            // Tutup dropdown lain yang mungkin sedang terbuka
            document.querySelectorAll('.pagin-dropdown-panel').forEach(p => {
                if (p !== panel) p.classList.add('hidden');
            });
            document.querySelectorAll('.arrow-icon').forEach(a => {
                if (a !== arrow) a.style.transform = 'rotate(0deg)';
            });

            // Toggle panel saat ini
            panel.classList.toggle('hidden');
            if (!panel.classList.contains('hidden')) {
                arrow.style.transform = 'rotate(180deg)';
            } else {
                arrow.style.transform = 'rotate(0deg)';
            }
        }

        // Tutup dropdown jika klik di luar area
        document.addEventListener('click', function() {
            document.querySelectorAll('.pagin-dropdown-panel').forEach(p => p.classList.add('hidden'));
            document.querySelectorAll('.arrow-icon').forEach(a => a.style.transform = 'rotate(0deg)');
        });
    </script>
@endif
