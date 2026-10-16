<header class="h-16 bg-white border-b border-border px-8 flex items-center justify-end sticky top-0 z-20">
    <!-- Info Admin di Ujung Kanan Sesuai Mockup -->
    <div class="flex items-center gap-2.5">
        <span class="text-xs md:text-sm font-semibold text-textPrimary">
            {{ Auth::user()->nama_pengguna ?? Auth::user()->name ?? 'Admin' }}
        </span>
        <div
            class="w-8 h-8 rounded-full bg-[#235D52] text-white flex items-center justify-center text-xs font-bold shadow-sm">
            <svg class="w-4 h-4 text-white" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clip-rule="evenodd" />
            </svg>
        </div>
    </div>
</header>