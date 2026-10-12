<header class="topbar">
    <!-- Breadcrumb & Nama Halaman -->
    <div>
        <div class="topbar-breadcrumb">
            <span>Admin</span>
            <span>/</span>
            <span class="crumb-active">{{ $breadcrumb ?? 'Dashboard' }}</span>
        </div>
        <h2 class="topbar-title">{{ $pageTitle ?? 'Dashboard' }}</h2>
    </div>

    <!-- Info Admin -->
    <div class="topbar-user">
        <div class="topbar-user-info">
            <div class="topbar-user-name">{{ Auth::user()->name ?? 'Administrator' }}</div>
            <div class="topbar-user-status">
                <span></span> Online
            </div>
        </div>
        <div class="topbar-avatar">
            {{ strtoupper(substr(Auth::user()->name ?? 'A', 0, 1)) }}
        </div>
    </div>
</header>
