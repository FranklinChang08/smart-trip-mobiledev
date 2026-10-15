<header class="h-20 bg-white border-b border-border px-8 flex items-center justify-between sticky top-0 z-20">
    <!-- Breadcrumb & Nama Halaman -->
    <div>
        <h2 class="font-serif text-lg font-bold text-primary">{{ $pageTitle ?? 'Dashboard' }}</h2>
        <p class="text-textPrimary mt-0.5 text-sm">{{ $pageDesc ?? 'Dashboard' }}</p>
    </div>

    <!-- Info Admin -->
    <div class="flex items-center gap-3">
        <div class="text-right">
            <div class="text-xs font-bold text-textPrimary">{{ Auth::user()->name ?? 'Administrator' }}</div>
            <div class="text-[0.6875rem] font-semibold text-[#059669] flex items-center justify-end gap-1">
                <span class="w-1.5 h-1.5 rounded-full bg-[#10B981] inline-block"></span> Online
            </div>
        </div>
        <div
            class="w-9 h-9 rounded-full bg-[#F0FDF9] border border-[#99F6E4] text-primary font-bold text-sm flex items-center justify-center">
            {{ strtoupper(substr(Auth::user()->name ?? 'A', 0, 1)) }}
        </div>
    </div>
</header>
