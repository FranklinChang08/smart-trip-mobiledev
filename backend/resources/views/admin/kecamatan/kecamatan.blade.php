@extends('layouts.admin')

@section('title', 'Manajemen Kecamatan')

@php
    $pageTitle = 'Manajemen Kecamatan';
    $pageDesc = 'Lihat data kecamatan dan ringkasan jumlah destinasi di setiap wilayah.';
@endphp

@section('content')
    <div class="max-w-7xl mx-auto space-y-6 font-manrope">

        <!-- PAGE HEADER & SEARCH BAR -->
        <div
            class="bg-white p-5 rounded-xl border border-border shadow-sm flex flex-col sm:flex-row items-center justify-between gap-4">
            <!-- Search Form -->
            <form method="GET" action="{{ route('admin.kecamatan.index') }}" class="w-full sm:w-96 relative">
                <span class="absolute inset-y-0 left-0 flex items-center pl-3 text-textSecondary">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                            d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                    </svg>
                </span>
                <input type="text" name="search" value="{{ request('search') }}" placeholder="Cari nama Kecamatan..."
                    class="w-full pl-10 pr-4 py-2 bg-background border border-border rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition">
            </form>

            <!-- Read-Only Badge Counter -->
            <div class="w-full sm:w-auto flex items-center justify-end text-sm text-textSecondary whitespace-nowrap">
                Total: <span class="font-bold text-textPrimary mx-2">{{ $kecamatans->total() }}</span> Kecamatan
            </div>
        </div>

        <!-- KECAMATAN GRID (Responsive: 1 col mobile, 2 cols tablet, 4 cols desktop) -->
        <div class="bg-white rounded-xl border border-border shadow-sm overflow-hidden p-4 space-y-4">
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                @forelse ($kecamatans as $item)
                    @php
                        // Retrieve first available destination photo across categories (Fallback to default if none exists)
                        $photoUrl = $item->first_destination_photo ?? null;
                    @endphp

                    <div
                        class="bg-white rounded-xl border border-border shadow-sm overflow-hidden flex flex-col justify-between hover:shadow-md transition duration-200">

                        <!-- 1. Destination Photo Section (16:9 aspect ratio) -->
                        <div class="relative w-full aspect-video bg-slate-100 overflow-hidden border-b border-border">
                            @if ($photoUrl)
                                <img src="{{ asset('storage/' . $photoUrl) }}" alt="{{ $item->nama_kecamatan }}"
                                    class="w-full h-full object-cover">
                            @else
                                <!-- Clean & Consistent Placeholder -->
                                <div
                                    class="w-full h-full flex flex-col items-center justify-center text-textSecondary bg-slate-50">
                                    <svg class="w-8 h-8 mb-1 text-slate-300" fill="none" stroke="currentColor"
                                        viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
                                            d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z">
                                        </path>
                                    </svg>
                                    <span class="text-[11px] text-slate-400 font-medium">Tidak ada foto</span>
                                </div>
                            @endif

                            <!-- Total Destination Prominent Badge Overlay -->
                            <div
                                class="absolute top-2.5 right-2.5 bg-primary text-white text-[11px] font-bold px-2 py-0.5 rounded-full shadow-sm flex items-center gap-1">
                                <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z">
                                    </path>
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path>
                                </svg>
                                <span>{{ $item->total_destinasi ?? 0 }} Total</span>
                            </div>
                        </div>

                        <!-- 2. Kecamatan Information & Category Breakdown -->
                        <div class="p-4 flex-1 flex flex-col justify-between space-y-3">
                            <div>
                                <!-- Kecamatan Name Title -->
                                <h3 class="text-base font-bold text-textPrimary tracking-tight truncate">
                                    {{ $item->nama_kecamatan }}
                                </h3>
                                <p class="text-[11px] text-textSecondary">Wilayah Batam</p>
                            </div>

                            <!-- Destination Type Breakdown Grid -->
                            <div class="grid grid-cols-2 gap-2 pt-2 border-t border-border">
                                <!-- Wisata -->
                                <div
                                    class="bg-background p-2 rounded-lg border border-border flex items-center justify-between">
                                    <div class="flex items-center space-x-1.5">
                                        <div class="p-1 rounded bg-teal-50 text-primary">
                                            <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor"
                                                viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                    d="M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 20.488V18a2 2 0 012-2h3.064M21 12a9 9 0 11-18 0 9 9 0 0118 0z">
                                                </path>
                                            </svg>
                                        </div>
                                        <span class="text-[11px] font-medium text-textSecondary">Wisata</span>
                                    </div>
                                    <span class="text-xs font-bold text-textPrimary">{{ $item->wisatas_count ?? 0 }}</span>
                                </div>

                                <!-- Restoran -->
                                <div
                                    class="bg-background p-2 rounded-lg border border-border flex items-center justify-between">
                                    <div class="flex items-center space-x-1.5">
                                        <div class="p-1 rounded bg-orange-50 text-tertiary">
                                            <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor"
                                                viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                    d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253">
                                                </path>
                                            </svg>
                                        </div>
                                        <span class="text-[11px] font-medium text-textSecondary">Restoran</span>
                                    </div>
                                    <span
                                        class="text-xs font-bold text-textPrimary">{{ $item->restorans_count ?? 0 }}</span>
                                </div>

                                <!-- Penginapan -->
                                <div
                                    class="bg-background p-2 rounded-lg border border-border flex items-center justify-between">
                                    <div class="flex items-center space-x-1.5">
                                        <div class="p-1 rounded bg-sky-50 text-secondary">
                                            <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor"
                                                viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                    d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4">
                                                </path>
                                            </svg>
                                        </div>
                                        <span class="text-[11px] font-medium text-textSecondary">Penginapan</span>
                                    </div>
                                    <span
                                        class="text-xs font-bold text-textPrimary">{{ $item->penginapans_count ?? 0 }}</span>
                                </div>

                                <!-- Lokasi Transportasi -->
                                <div
                                    class="bg-background p-2 rounded-lg border border-border flex items-center justify-between">
                                    <div class="flex items-center space-x-1.5">
                                        <div class="p-1 rounded bg-slate-100 text-textSecondary">
                                            <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor"
                                                viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                    d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4"></path>
                                            </svg>
                                        </div>
                                        <span class="text-[11px] font-medium text-textSecondary">Transport</span>
                                    </div>
                                    <span
                                        class="text-xs font-bold text-textPrimary">{{ $item->lokasi_transportasis_count ?? 0 }}</span>
                                </div>
                            </div>

                        </div>
                    </div>
                @empty
                    <!-- EMPTY STATE -->
                    <div
                        class="col-span-full bg-white rounded-xl border border-border p-12 text-center flex flex-col items-center justify-center space-y-3">
                        <div
                            class="w-16 h-16 bg-background rounded-full flex items-center justify-center text-textSecondary border border-border mb-1">
                            <svg class="w-8 h-8 text-slate-400" fill="none" stroke="currentColor"
                                viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
                                    d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z">
                                </path>
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
                                    d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path>
                            </svg>
                        </div>
                        <h3 class="text-base font-bold text-textPrimary">Belum ada data kecamatan.</h3>
                        <p class="text-xs text-textSecondary max-w-sm">Data kecamatan akan ditampilkan di sini setelah
                            tersedia
                            di dalam sistem database SmartTrip.</p>
                    </div>
                @endforelse
            </div>

            <!-- PAGINATION -->
            {{ $kecamatans->withQueryString()->links('components.pagination-custom') }}
        </div>

    </div>
@endsection
