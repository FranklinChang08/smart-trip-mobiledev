<aside class="sidebar">
    <div>
        <!-- Bagian atas sidebar -->
        <div class="sidebar-header">
            <img
                src="{{ asset('images/logo_smarttrip.png') }}"
                alt="SmartTrip Logo"
            >
            <div>
                <h1>SmartTrip</h1>
                <span class="sidebar-badge">Admin Panel</span>
            </div>
        </div>

        <!-- Menu Navigasi -->
        <nav class="sidebar-nav">
            <!-- Dashboard -->
            <a
                href="{{ route('admin.dashboard') }}"
                class="nav-link {{ request()->routeIs('admin.dashboard') ? 'active' : '' }}"
            >
                <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"></path>
                </svg>
                <span>Dashboard</span>
            </a>

            <!-- Data Wisata -->
            <a
                href="{{ route('admin.wisata') }}"
                class="nav-link {{ request()->routeIs('admin.wisata') ? 'active' : '' }}"
            >
                <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path>
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path>
                </svg>
                <span>Data Wisata</span>
            </a>

            <!-- Data Restoran -->
            <a
                href="{{ route('admin.restoran') }}"
                class="nav-link {{ request()->routeIs('admin.restoran') ? 'active' : '' }}"
            >
                <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"></path>
                </svg>
                <span>Data Restoran</span>
            </a>
        </nav>
    </div>

    <!-- Footer Sidebar + Logout -->
    <div class="sidebar-footer">
        <div class="admin-card">
            <div class="admin-avatar">
                {{ strtoupper(substr(Auth::user()->name ?? 'A', 0, 1)) }}
            </div>
            <div style="overflow:hidden">
                <div class="admin-name">{{ Auth::user()->name ?? 'Administrator' }}</div>
                <div class="admin-email">{{ Auth::user()->email ?? 'admin@smarttrip.com' }}</div>
            </div>
        </div>

        <!-- Tombol Logout -->
        <form action="{{ route('admin.logout') }}" method="POST">
            @csrf
            <button type="submit" class="btn-logout">
                <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path>
                </svg>
                <span>Logout</span>
            </button>
        </form>
    </div>
</aside>
