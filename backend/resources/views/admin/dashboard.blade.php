@extends('layouts.admin')

@section('title', 'Dashboard')

@section('content')
    <div class="max-w-7xl mx-auto space-y-8 font-manrope">

        <!-- Page Header-->
        <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
            <div>
                <h1 class="text-3xl font-serif font-bold text-gray-900 tracking-tight">Dashboard</h1>
                <p class="text-sm text-gray-500 mt-1">Kelola data destinasi SmartTrip dan parameter algoritma rekomendasi.</p>
            </div>
            <div class="flex items-center gap-3">
                <!-- Tambah Wisata -->
                <a href="{{ route('admin.wisata.create') }}"
                    class="inline-flex items-center gap-2 px-4 py-2.5 bg-[#2D6A5D] hover:bg-[#24564B] text-white text-xs md:text-sm font-semibold rounded-xl shadow-sm transition-all duration-150">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.2" d="M12 4v16m8-8H4"></path>
                    </svg>
                    <span>Tambah Wisata</span>
                </a>

                <!-- Tambah Restoran -->
                <a href="{{ route('admin.restoran') }}"
                    class="inline-flex items-center gap-2 px-4 py-2.5 bg-[#934515] hover:bg-[#7D3A11] text-white text-xs md:text-sm font-semibold rounded-xl shadow-sm transition-all duration-150">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.2" d="M12 4v16m8-8H4"></path>
                    </svg>
                    <span>Tambah Restoran</span>
                </a>
            </div>
        </div>

        <!-- 2. Tiga Kartu Statistik Sesuai Mockup (Data Asli dari Database) -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">

            <!-- Card 1: Wisata Alam & Heritage -->
            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 flex flex-col justify-between hover:shadow-md transition">
                <div class="flex items-start justify-between">
                    <div>
                        <span class="text-[11px] font-bold tracking-wider text-gray-400 uppercase">WISATA ALAM & HERITAGE</span>
                        <div class="text-xs text-gray-500 font-medium mt-3">Total Wisata</div>
                        <div class="text-3xl font-extrabold text-gray-900 mt-1 tracking-tight">
                            {{ $statWisata }} <span class="text-lg font-bold text-[#2D6A5D]">Destinasi</span>
                        </div>
                    </div>
                    <div class="w-10 h-10 rounded-xl bg-[#CCFBF1] text-[#0F766E] flex items-center justify-center shrink-0">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z">
                            </path>
                        </svg>
                    </div>
                </div>
                <div class="mt-6 pt-4 border-t border-gray-50 flex items-center gap-2 text-xs text-gray-500">
                    <svg class="w-4 h-4 text-emerald-600 shrink-0" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd"
                            d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                            clip-rule="evenodd"></path>
                    </svg>
                    <span>Tempat wisata </span>
                </div>
            </div>

            <!-- Card 2: Total Kuliner -->
            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 flex flex-col justify-between hover:shadow-md transition">
                <div class="flex items-start justify-between">
                    <div>
                        <span class="text-[11px] font-bold tracking-wider text-gray-400 uppercase">TOTAL KULINER</span>
                        <div class="text-xs text-gray-500 font-medium mt-3">Total Restoran</div>
                        <div class="text-3xl font-extrabold text-gray-900 mt-1 tracking-tight">
                            {{ $statRestoran }} <span class="text-lg font-bold text-[#934515]">Restoran</span>
                        </div>
                    </div>
                    <div class="w-10 h-10 rounded-xl bg-[#FFEDD5] text-[#9A3412] flex items-center justify-center shrink-0">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4">
                            </path>
                        </svg>
                    </div>
                </div>
                <div class="mt-6 pt-4 border-t border-gray-50 flex items-center gap-2 text-xs text-gray-500">
                    <svg class="w-4 h-4 text-orange-600 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                            d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z">
                        </path>
                    </svg>
                    <span>Sentra kuliner & resto aktif</span>
                </div>
            </div>

            <!-- Card 3: Total Destinasi (Pilihan 1: Disederhanakan) -->
            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 flex flex-col justify-between hover:shadow-md transition">
                <div class="flex items-start justify-between">
                    <div>
                        <span class="text-[11px] font-bold tracking-wider text-gray-400 uppercase">TOTAL DESTINASI</span>
                        <div class="text-xs text-gray-500 font-medium mt-3">Akumulasi Destinasi</div>
                        <div class="text-3xl font-extrabold text-gray-900 mt-1 tracking-tight">
                            {{ $statTotal }} <span class="text-lg font-bold text-[#0369A1]">Lokasi Terdaftar</span>
                        </div>
                    </div>
                    <div class="w-10 h-10 rounded-xl bg-[#DBEAFE] text-[#1E40AF] flex items-center justify-center shrink-0">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path>
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path>
                        </svg>
                    </div>
                </div>
                <div class="mt-6 pt-4 border-t border-gray-50 flex items-center gap-2 text-xs text-gray-500">
                    <svg class="w-4 h-4 text-blue-600 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                            d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7">
                        </path>
                    </svg>
                    <span>Gabungan data wisata dan restoran aktif</span>
                </div>
            </div>

        </div>

        <!-- 3. Tabel Destinasi Terbaru -->
        <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 md:p-8 space-y-6">

            <!-- Bagian Atas Tabel: Judul, Filter Tabs, & Kolom Pencarian -->
            <div class="flex flex-col lg:flex-row lg:items-center justify-between gap-4">
                <div>
                    <h2 class="text-xl font-serif font-bold text-gray-900">Data Destinasi Terbaru</h2>
                    <p class="text-xs text-gray-400 mt-0.5">Daftar Data Wisata dan Kuliner dari Basis Data</p>
                </div>

                <div class="flex flex-col sm:flex-row items-stretch sm:items-center gap-3">
                    <!-- Filter -->
                    <div class="inline-flex p-1 bg-gray-100/80 rounded-xl text-xs font-medium text-gray-500">
                        <button type="button" data-filter="all"
                            class="filter-tab px-3.5 py-1.5 rounded-lg transition-all bg-white text-gray-900 font-bold shadow-xs">
                            Semua Destinasi
                        </button>
                        <button type="button" data-filter="wisata"
                            class="filter-tab px-3.5 py-1.5 rounded-lg transition-all text-gray-500 hover:text-gray-900 font-medium">
                            Wisata Saja
                        </button>
                        <button type="button" data-filter="restoran"
                            class="filter-tab px-3.5 py-1.5 rounded-lg transition-all text-gray-500 hover:text-gray-900 font-medium">
                            Restoran Saja
                        </button>
                    </div>

                    <!-- Kolom Pencarian -->
                    <div class="relative w-full sm:w-64">
                        <span class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-gray-400">
                            <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                            </svg>
                        </span>
                        <input type="text" id="destinationSearch" placeholder="Cari nama atau kecamatan..."
                            class="w-full pl-8 pr-3 py-1.5 bg-gray-50/80 hover:bg-gray-100/60 focus:bg-white border border-gray-200 focus:border-primary rounded-xl text-xs text-gray-800 placeholder-gray-400 outline-none transition">
                    </div>
                </div>
            </div>

            <!-- Tabel Data -->
            <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse" id="destinationTable">
                    <thead>
                        <tr class="border-b border-gray-100 text-[11px] font-bold text-gray-400 uppercase tracking-wider">
                            <th class="py-3 px-3 text-center w-12">NO</th>
                            <th class="py-3 px-4">NAMA DESTINASI</th>
                            <th class="py-3 px-3">JENIS</th>
                            <th class="py-3 px-4">KATEGORI</th>
                            <th class="py-3 px-4">LOKASI (KECAMATAN)</th>
                            <th class="py-3 px-3">STATUS</th>
                            <th class="py-3 px-3 text-center">AKSI</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-50 text-sm">
                        @forelse ($allDestinasi as $item)
                            <tr class="destination-row hover:bg-gray-50/60 transition" data-jenis="{{ $item->jenis }}"
                                data-search="{{ strtolower($item->nama . ' ' . $item->alamat . ' ' . $item->lokasi . ' ' . $item->kategori) }}">

                                <!-- NO -->
                                <td class="py-4 px-3 text-center text-xs text-gray-400 font-mono font-medium">
                                    {{ $item->no }}
                                </td>

                                <!-- NAMA DESTINASI & FOTO -->
                                <td class="py-4 px-4">
                                    <div class="flex items-center gap-3">
                                        <div class="h-12 aspect-video rounded-lg bg-slate-100 overflow-hidden shrink-0 border border-gray-100 shadow-xs flex items-center justify-center">
                                            @if (!empty($item->foto))
                                                <img src="{{ $item->foto }}" alt="{{ $item->nama }}"
                                                    class="w-full h-full object-cover">
                                            @else
                                                <svg class="w-5 h-5 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
                                                        d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z">
                                                    </path>
                                                </svg>
                                            @endif
                                        </div>
                                        <div>
                                            <div class="text-sm font-bold text-gray-900 hover:text-primary transition">
                                                {{ $item->nama }}
                                            </div>
                                            <div class="flex items-center gap-1 text-[11px] text-gray-400 mt-0.5">
                                                <svg class="w-3 h-3 text-gray-400 shrink-0" fill="none" stroke="currentColor"
                                                    viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                        d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path>
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                        d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path>
                                                </svg>
                                                <span class="max-w-[200px] truncate">{{ $item->alamat }}</span>
                                            </div>
                                        </div>
                                    </div>
                                </td>

                                <!-- JENIS BADGE -->
                                <td class="py-4 px-3">
                                    @if ($item->jenis === 'wisata')
                                        <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[11px] font-semibold bg-[#A7F3D0]/60 text-[#065F46]">
                                            <span class="w-1.5 h-1.5 rounded-full bg-[#059669]"></span>
                                            Wisata
                                        </span>
                                    @else
                                        <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[11px] font-semibold bg-[#FED7AA]/60 text-[#9A3412]">
                                            <span class="w-1.5 h-1.5 rounded-full bg-[#EA580C]"></span>
                                            Restoran
                                        </span>
                                    @endif
                                </td>

                                <!-- KATEGORI -->
                                <td class="py-4 px-4">
                                    <div class="flex flex-wrap gap-1 max-w-[200px]">
                                        @php
                                            $kategoriList = !empty($item->kategori_list)
                                                ? $item->kategori_list
                                                : array_filter(array_map('trim', explode(',', $item->kategori ?? '')));
                                        @endphp
                                        @forelse($kategoriList as $kategori)
                                            <span
                                                class="inline-flex px-2.5 py-1 text-xs font-semibold rounded-full bg-teal-50 text-primary border border-teal-100">
                                                {{ $kategori }}
                                            </span>
                                        @empty
                                            <span class="text-xs text-textSecondary italic">Tanpa Kategori</span>
                                        @endforelse
                                    </div>
                                </td>

                                <!-- LOKASI) -->
                                <td class="py-4 px-4">
                                    <div class="flex items-center gap-1.5 text-xs font-medium text-gray-700">
                                        <svg class="w-4 h-4 text-gray-400 shrink-0" fill="none" stroke="currentColor"
                                            viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8"
                                                d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4">
                                            </path>
                                        </svg>
                                        <span>{{ $item->lokasi }}</span>
                                    </div>
                                </td>

                                <!-- STATUS -->
                                <td class="py-4 px-3">
                                    <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[11px] font-semibold bg-slate-100 text-[#0F766E]">
                                        <span class="w-1.5 h-1.5 rounded-full bg-[#059669]"></span>
                                        {{ $item->status }}
                                    </span>
                                </td>

                                <!-- AKSI (Disamakan dengan Data Wisata: Edit & Hapus) -->
                                <td class="py-4 px-3 text-center">
                                    <div class="flex items-center justify-center space-x-2">
                                        <!-- Edit Icon Sesuai Data Wisata -->
                                        <a href="{{ route('admin.wisata.index') }}"
                                            class="p-1.5 text-slate-500 hover:text-primary transition" title="Edit">
                                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                    d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z">
                                                </path>
                                            </svg>
                                        </a>

                                        <!-- Hapus Icon Sesuai Data Wisata -->
                                        <a href="{{ route('admin.wisata.index') }}"
                                            class="p-1.5 text-slate-500 hover:text-red-600 transition" title="Hapus">
                                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                    d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16">
                                                </path>
                                            </svg>
                                        </a>
                                    </div>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="7" class="py-12 text-center text-gray-400 text-sm">
                                    <div class="flex flex-col items-center justify-center gap-2">
                                        <svg class="w-8 h-8 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
                                                d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10">
                                            </path>
                                        </svg>
                                        <span class="font-medium text-gray-500">Belum ada data destinasi di basis data.</span>
                                        <a href="{{ route('admin.wisata.create') }}" class="text-xs text-primary font-bold hover:underline mt-1">
                                            + Tambah Tempat Wisata Baru
                                        </a>
                                    </div>
                                </td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>

                <!-- State Kosong jika Filter Tidak Menemukan Data -->
                <div id="noResultsMessage" class="hidden py-8 text-center text-xs text-gray-400 italic">
                    Tidak ditemukan destinasi yang sesuai dengan pencarian atau filter.
                </div>
            </div>

        </div>

    </div>

    <!-- Script Interaktif Filter Tab -->
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const tabs = document.querySelectorAll('.filter-tab');
            const searchInput = document.getElementById('destinationSearch');
            const rows = document.querySelectorAll('.destination-row');
            const noResults = document.getElementById('noResultsMessage');

            let currentFilter = 'all';
            let currentSearch = '';

            function updateRows() {
                let visibleCount = 0;

                rows.forEach(row => {
                    const jenis = row.getAttribute('data-jenis');
                    const searchData = row.getAttribute('data-search') || '';

                    const matchesFilter = (currentFilter === 'all') || (jenis === currentFilter);
                    const matchesSearch = !currentSearch || searchData.includes(currentSearch);

                    if (matchesFilter && matchesSearch) {
                        row.classList.remove('hidden');
                        visibleCount++;
                    } else {
                        row.classList.add('hidden');
                    }
                });

                if (noResults) {
                    noResults.classList.toggle('hidden', visibleCount > 0);
                }
            }

            // Event Tab Click
            tabs.forEach(tab => {
                tab.addEventListener('click', function () {
                    tabs.forEach(t => {
                        t.classList.remove('bg-white', 'text-gray-900', 'font-bold', 'shadow-xs');
                        t.classList.add('text-gray-500', 'font-medium');
                    });

                    this.classList.add('bg-white', 'text-gray-900', 'font-bold', 'shadow-xs');
                    this.classList.remove('text-gray-500', 'font-medium');

                    currentFilter = this.getAttribute('data-filter');
                    updateRows();
                });
            });

            // Event Search Input
            if (searchInput) {
                searchInput.addEventListener('input', function () {
                    currentSearch = this.value.trim().toLowerCase();
                    updateRows();
                });
            }
        });
    </script>
@endsection
