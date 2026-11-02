@extends('layouts.admin')

@section('title', 'Data Wisata')
@php
    $pageTitle = 'Kelola Data Destinasi Wisata';
    $pageDesc = 'Halaman ini digunakan untuk mengelola data tempat wisata, rute, dan kategori destinasi SmartTrip.';
@endphp

@section('content')
    <div class="max-w-7xl mx-auto space-y-6">

        <!-- Page Header -->
        <div class="flex items-center gap-3">
            <h1 class="text-2xl font-bold text-textPrimary tracking-tight">Data Destinasi Wisata</h1>
            <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold bg-teal-50 text-[#235D52] border border-teal-200">
                {{ $wisatas->total() }} Wisata Terdaftar
            </span>
        </div>

        <!-- WRAPPER 1: Form Pencarian & Tombol Tambah -->
        <form method="GET" action="{{ route('admin.wisata.index') }}"
            class="bg-white p-4 rounded-xl border border-border shadow-sm flex flex-col md:flex-row items-center justify-between gap-4">
            <!-- Form Pencarian -->
            <div class="w-full md:w-96 relative">
                <span class="absolute inset-y-0 left-0 flex items-center pl-3 text-textSecondary">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                            d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                    </svg>
                </span>
                <input type="text" name="search" value="{{ request('search') }}"
                    placeholder="Cari nama tempat atau lokasi wisata..."
                    class="w-full pl-10 pr-4 py-2 bg-background border border-border rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent">
            </div>

            <!-- Tombol Tambah Tempat Wisata -->
            <a href="{{ route('admin.wisata.create') }}"
                class="w-full md:w-auto inline-flex items-center justify-center px-4 py-2 bg-primary text-white text-sm font-semibold rounded-lg hover:opacity-95 transition shadow-sm">
                <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
                </svg>
                Tambah Tempat Wisata
            </a>
        </form>

        <!-- WRAPPER 2: Tabel Daftar Tempat Wisata & Multi-Selection Action -->
        <div class="bg-white rounded-xl border border-border shadow-sm overflow-hidden p-4 space-y-4">

            <!-- Opsi Aksi Multi-Selection -->
            <div class="bg-white flex items-center justify-between">
                <div class="flex items-center gap-1.5 text-sm text-textSecondary">
                    <span class="font-semibold text-textPrimary" id="selected-count">0</span>
                    <span>data dipilih</span>
                </div>
                <button type="button" id="bulk-delete-btn" disabled
                    class="inline-flex items-center px-3 py-1.5 bg-red-50 text-red-600 text-xs font-semibold rounded-lg border border-red-200 hover:bg-red-100 transition disabled:opacity-40 disabled:cursor-not-allowed">
                    <svg class="w-4 h-4 mr-1.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                            d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16">
                        </path>
                    </svg>
                    Hapus Terpilih
                </button>
            </div>

            <!-- Tabel Data -->
            <div class="overflow-x-auto border-y border-border">
                <table class="w-full text-left border-collapse">
                    <thead>
                        <tr
                            class="bg-background border-b border-border text-xs font-semibold text-textSecondary uppercase tracking-wider">
                            <th class="p-4 w-10 text-center">
                                <input type="checkbox" id="select-all" class="rounded border-border text-primary focus:ring-primary cursor-pointer">
                            </th>
                            <th class="p-4">No</th>
                            <th class="p-4">Foto</th>
                            <th class="p-4">Nama &amp; Lokasi Tempat</th>
                            <th class="p-4">Kategori</th>
                            <th class="p-4">Jam Operasional</th>
                            <th class="p-4">Harga Tiket</th>
                            <th class="p-4">Longitude, Latitude</th>
                            <th class="p-4 text-center">Aksi</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-border text-sm text-textPrimary">
                        @forelse ($wisatas as $wisata)
                            <tr class="hover:bg-slate-50 transition">
                                <td class="p-4 text-center">
                                    <input type="checkbox" class="row-checkbox rounded border-border text-primary focus:ring-primary cursor-pointer"
                                        value="{{ $wisata->id_wisata }}">
                                </td>
                                <td class="p-4 text-textSecondary">
                                    {{ $wisatas->firstItem() + $loop->index }}
                                </td>
                                <td class="p-4">
                                    @php
                                        $fotoUtama = $wisata->fotoDestinasis->first();
                                    @endphp
                                    <div
                                        class="group relative h-12 w-20 rounded-xl bg-slate-100 overflow-hidden shrink-0 border border-gray-100 shadow-xs flex items-center justify-center text-xs text-slate-400 font-medium">
                                        @if ($fotoUtama && !empty($fotoUtama->link_photo))
                                            <img src="{{ asset('storage/' . $fotoUtama->link_photo) }}"
                                                alt="{{ $wisata->nama_wisata }}"
                                                class="w-full h-full object-cover transition-transform duration-300 group-hover:scale-110">
                                        @else
                                            <svg class="w-5 h-5 text-slate-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                                            </svg>
                                        @endif
                                    </div>
                                </td>
                                <td class="p-4">
                                    <div class="font-bold text-textPrimary leading-snug">{{ $wisata->nama_wisata }}</div>
                                    <div class="text-xs text-textSecondary mt-0.5 line-clamp-2">
                                        {{ $wisata->alamat_detail_wisata }}
                                        @if ($wisata->kecamatan)
                                            , {{ $wisata->kecamatan->nama_kecamatan }}
                                        @endif
                                    </div>
                                </td>
                                <td class="p-4">
                                    <div class="flex flex-wrap gap-1">
                                        @forelse($wisata->kategoris as $kategori)
                                            <span
                                                class="inline-flex px-2.5 py-0.5 text-xs font-semibold rounded-full bg-teal-50 text-primary border border-teal-200">
                                                {{ $kategori->nama_kategori }}
                                            </span>
                                        @empty
                                            <span class="text-xs text-textSecondary italic">Tanpa Kategori</span>
                                        @endforelse
                                    </div>
                                </td>
                                <td class="p-4 text-textSecondary text-xs">
                                    @if ($wisata->jamOperasis->count() > 0)
                                        <div class="flex items-center gap-1.5 font-medium text-slate-600">
                                            <svg class="w-3.5 h-3.5 text-slate-400 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                                            </svg>
                                            <span>{{ \Illuminate\Support\Str::substr($wisata->jamOperasis->first()->jam_buka, 0, 5) }} - {{ \Illuminate\Support\Str::substr($wisata->jamOperasis->first()->jam_tutup, 0, 5) }}</span>
                                        </div>
                                    @else
                                        <span class="text-slate-400">-</span>
                                    @endif
                                </td>
                                <td class="p-4">
                                    <div class="font-bold text-textPrimary">
                                        Rp{{ number_format($wisata->harga_tiket_masuk ?? 0, 0, ',', '.') }}
                                    </div>
                                    <div class="text-[11px] text-textSecondary font-normal">/ tiket</div>
                                </td>
                                <td class="p-4 text-xs font-mono text-textSecondary whitespace-nowrap">
                                    {{ $wisata->longitude }}&deg; E, {{ $wisata->latitude }}&deg; S
                                </td>
                                <td class="p-4 text-center">
                                    <div class="flex items-center justify-center space-x-1.5">
                                        <a href="{{ route('admin.wisata.show', ['wisata' => $wisata->id_wisata]) }}"
                                            class="p-2 text-slate-500 hover:text-primary hover:bg-teal-50 rounded-lg transition"
                                            title="Edit">
                                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                    d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z">
                                                </path>
                                            </svg>
                                        </a>
                                        <form action="{{ route('admin.wisata.destroy', ['wisata' => $wisata->id_wisata]) }}" method="POST"
                                            onsubmit="return confirmDelete(event, this, '{{ addslashes($wisata->nama_wisata) }}');"
                                            class="inline-block">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit"
                                                class="p-2 text-slate-500 hover:text-red-600 hover:bg-red-50 rounded-lg transition"
                                                title="Hapus">
                                                <svg class="w-4 h-4" fill="none" stroke="currentColor"
                                                    viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                        d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16">
                                                    </path>
                                                </svg>
                                            </button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="9" class="p-8 text-center text-textSecondary italic">
                                    Belum ada data tempat wisata yang tersedia.
                                </td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>

            <!-- Pagination di Bawah Tabel -->
            <div class="bg-white border-border pt-2 flex flex-col sm:flex-row items-center justify-between gap-4">
                <div class="text-sm text-textSecondary">
                    Menampilkan
                    <span class="font-medium text-textPrimary">{{ $wisatas->firstItem() ?? 0 }}</span> sampai
                    <span class="font-medium text-textPrimary">{{ $wisatas->lastItem() ?? 0 }}</span> dari
                    <span class="font-medium text-textPrimary">{{ $wisatas->total() }}</span> data
                </div>
                <div>
                    {{ $wisatas->withQueryString()->links() }}
                </div>
            </div>

        </div>

    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const selectAll = document.getElementById('select-all');
            const rowCheckboxes = document.querySelectorAll('.row-checkbox');
            const selectedCountEl = document.getElementById('selected-count');
            const bulkDeleteBtn = document.getElementById('bulk-delete-btn');

            function updateCount() {
                const checked = document.querySelectorAll('.row-checkbox:checked');
                const count = checked.length;
                if (selectedCountEl) {
                    selectedCountEl.textContent = count;
                }
                if (bulkDeleteBtn) {
                    bulkDeleteBtn.disabled = count === 0;
                }
                if (selectAll) {
                    selectAll.checked = rowCheckboxes.length > 0 && count === rowCheckboxes.length;
                }
            }

            if (selectAll) {
                selectAll.addEventListener('change', function () {
                    rowCheckboxes.forEach(cb => {
                        cb.checked = selectAll.checked;
                    });
                    updateCount();
                });
            }

            rowCheckboxes.forEach(cb => {
                cb.addEventListener('change', updateCount);
            });

            if (bulkDeleteBtn) {
                bulkDeleteBtn.addEventListener('click', function () {
                    const checked = document.querySelectorAll('.row-checkbox:checked');
                    if (checked.length === 0) return;
                    confirmDelete(function () {
                        if (window.showToast) {
                            window.showToast('error', 'Fitur hapus massal sedang dalam pengembangan.');
                        }
                    }, `${checked.length} data wisata terpilih`);
                });
            }
        });
    </script>
@endsection
