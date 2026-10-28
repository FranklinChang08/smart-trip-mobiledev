<aside
    class="w-64 bg-white border-r border-border flex flex-col justify-between shrink-0 h-screen sticky top-0 font-manrope">
    <div>
        <!-- Bagian atas sidebar -->
        <div class="h-20 px-6 flex items-center gap-3 border-b border-[#F3F4F6]">
            <img src="{{ asset('images/logo_smarttrip.png') }}" alt="SmartTrip Logo" class="w-8 h-8 object-contain">
            <div>
                <h1 class="font-bebas text-lg font-bold text-primary leading-tight">SmartTrip</h1>
                <span
                    class="inline-block px-1.5 py-0.5 rounded text-[0.625rem] font-bold uppercase tracking-[0.08em] text-primary bg-[#F0FDF9] border border-[#99F6E4] mt-0.5">Admin
                    Panel</span>
            </div>
        </div>

        <!-- Menu Navigasi -->
        <nav class="p-4 flex flex-col gap-2">
            <!-- Dashboard -->
            <p class="font-semibold text-xs text-gray-400">Overview</p>
            <a href="{{ route('admin.dashboard') }}"
                class="flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-sm font-semibold transition-colors {{ request()->routeIs('admin.dashboard') ? 'bg-primary text-white shadow-sm shadow-primary/30' : 'text-textSecondary hover:bg-[#F3F4F6] hover:text-textPrimary' }}">
                <svg class="w-5 h-5 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8"
                        d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6">
                    </path>
                </svg>
                <span>Dashboard</span>
            </a>
            <div class="w-full h-px rounded-full bg-primary my-3"></div>
            <p class="font-bold text-xs text-gray-400">Management Destinasi</p>
            <!-- Data Wisata -->
            <a href="{{ route('admin.wisata.index') }}"
                class="flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-sm font-semibold transition-colors {{ request()->routeIs('admin.wisata*') ? 'bg-primary text-white shadow-sm shadow-primary/30' : 'text-textSecondary hover:bg-[#F3F4F6] hover:text-textPrimary' }}">
                <svg class="w-5 h-5 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8"
                        d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path>
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8"
                        d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path>
                </svg>
                <span>Data Wisata</span>
            </a>

            <!-- Data Restoran -->
            <a href="{{ route('admin.restoran.index') }}"
                class="flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-sm font-semibold transition-colors {{ request()->routeIs('admin.restoran*') ? 'bg-primary text-white shadow-sm shadow-primary/30' : 'text-textSecondary hover:bg-[#F3F4F6] hover:text-textPrimary' }}">
                <svg class="w-5 h-5 shrink-0" xmlns="http://www.w3.org/2000/svg" width="24" height="24"
                    viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                    stroke-linejoin="round" class="lucide lucide-utensils preview-icon">
                    <path d="M3 2v7c0 1.1.9 2 2 2h4a2 2 0 0 0 2-2V2" />
                    <path d="M7 2v20" />
                    <path d="M21 15V2a5 5 0 0 0-5 5v6c0 1.1.9 2 2 2h3Zm0 0v7" />
                </svg>
                <span>Data Restoran</span>
            </a>
            <a href="{{ route('admin.penginapan.index') }}"
                class="flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-sm font-semibold transition-colors {{ request()->routeIs('admin.penginapan*') ? 'bg-primary text-white shadow-sm shadow-primary/30' : 'text-textSecondary hover:bg-[#F3F4F6] hover:text-textPrimary' }}">
                <svg class="w-5 h-5 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8"
                        d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4">
                    </path>
                </svg>
                <span>Data Penginapan</span>
            </a>
            <a href="{{ route('admin.lokasi.index') }}"
                class="flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-sm font-semibold transition-colors {{ request()->routeIs('admin.lokasi*') ? 'bg-primary text-white shadow-sm shadow-primary/30' : 'text-textSecondary hover:bg-[#F3F4F6] hover:text-textPrimary' }}">
                <svg class="w-5 h-5 shrink-0" xmlns="http://www.w3.org/2000/svg" width="24" height="24"
                    viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                    stroke-linejoin="round" class="lucide lucide-plane-takeoff preview-icon">
                    <path d="M2 22h20" />
                    <path
                        d="M6.36 17.4 4 17l-2-4 1.1-.55a2 2 0 0 1 1.8 0l.17.1a2 2 0 0 0 1.8 0L8 12 5 6l.9-.45a2 2 0 0 1 2.09.2l4.02 3a2 2 0 0 0 2.1.2l4.19-2.06a2.41 2.41 0 0 1 1.73-.17L21 7a1.4 1.4 0 0 1 .87 1.99l-.38.76c-.23.46-.6.84-1.07 1.08L7.58 17.2a2 2 0 0 1-1.22.18Z" />
                </svg>
                <span>Data Lokasi Transportasi</span>
            </a>
            <div class="w-full h-px rounded-full bg-primary my-3"></div>
            <p class="font-bold text-xs text-gray-400">Data Pendukung</p>
            <a href=""
                class="flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-sm font-semibold transition-colors text-textSecondary hover:bg-[#F3F4F6] hover:text-textPrimary">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none"
                    stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"
                    class="lucide lucide-layout-dashboard preview-icon">
                    <rect width="7" height="9" x="3" y="3" rx="1" />
                    <rect width="7" height="5" x="14" y="3" rx="1" />
                    <rect width="7" height="9" x="14" y="12" rx="1" />
                    <rect width="7" height="5" x="3" y="16" rx="1" />
                </svg>
                <span>Data Kategori</span>
            </a>
            <a href=""
                class="flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-sm font-semibold transition-colors text-textSecondary hover:bg-[#F3F4F6] hover:text-textPrimary">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none"
                    stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"
                    class="lucide lucide-building-complex-plus preview-icon">
                    <path d="M10 12h4" />
                    <path d="M10 21v-3a2 2 0 013.05-1.702" />
                    <path d="M10 8h4" />
                    <path d="M16 19h6" />
                    <path d="M18 7h2a2 2 0 012 2v4.355" />
                    <path d="M19 16v6" />
                    <path d="M6 10H4a2 2 0 00-2 2v7a2 2 0 002 2h8.535" />
                    <path d="M6 21V5a2 2 0 012-2h8a2 2 0 012 2v7.126" />
                </svg>
                <span>Data Kecamatan</span>
            </a>
            <a href=""
                class="flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-sm font-semibold transition-colors text-textSecondary hover:bg-[#F3F4F6] hover:text-textPrimary">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"
                    fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                    stroke-linejoin="round" class="lucide lucide-house-cog preview-icon">
                    <path
                        d="M10.584 21H5a2 2 0 01-2-2v-9a2 2 0 01.709-1.527l7-6a2 2 0 012.582 0l7 6A2 2 0 0121 10.001v.583" />
                    <path d="M14 12H10a1 1 0 00-1 1v8" />
                    <path d="m14.305 19.53.923-.382" />
                    <path d="m15.229 16.852-.924-.383" />
                    <path d="m16.852 15.228-.383-.923" />
                    <path d="m16.852 20.773-.383.924" />
                    <path d="m19.148 15.228.383-.923" />
                    <path d="m19.53 21.697-.382-.924" />
                    <path d="m20.773 16.852.922-.383" />
                    <path d="m20.773 19.148.922.383" />
                    <circle cx="18" cy="18" r="3" />
                </svg>
                <span>Data Fasilitas</span>
            </a>
        </nav>
    </div>

    <!-- Footer Sidebar + Logout -->
    <div class="p-4 border-t border-[#F3F4F6] flex flex-col gap-3">
        <div class="p-3 rounded-xl bg-background border border-[#F3F4F6] flex items-center gap-3 overflow-hidden">
            <div
                class="w-9 h-9 rounded-full bg-primary text-white font-bold text-sm flex items-center justify-center shrink-0">
                {{ strtoupper(substr(Auth::user()->nama_pengguna ?? (Auth::user()->name ?? 'A'), 0, 1)) }}
            </div>
            <div class="overflow-hidden">
                <div class="text-xs font-bold text-textPrimary truncate">
                    {{ Auth::user()->nama_pengguna ?? (Auth::user()->name ?? 'Administrator') }}
                </div>
                <div class="text-[0.6875rem] text-textSecondary truncate">
                    {{ Auth::user()->email ?? 'admin@smarttrip.com' }}
                </div>
            </div>
        </div>

        <!-- Tombol Logout -->
        <form action="{{ route('admin.logout') }}" method="POST">
            @csrf
            <button type="submit"
                class="w-full flex items-center gap-2.5 px-3.5 py-2.5 rounded-xl text-sm font-semibold text-[#DC2626] bg-transparent border border-transparent hover:bg-[#FEF2F2] hover:border-[#FECACA] hover:text-[#B91C1C] cursor-pointer transition-colors">
                <svg class="w-5 h-5 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8"
                        d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1">
                    </path>
                </svg>
                <span>Logout</span>
            </button>
        </form>
    </div>
</aside>
