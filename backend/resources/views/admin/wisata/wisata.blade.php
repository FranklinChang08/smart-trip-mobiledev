@extends('layouts.admin')

@section('title', 'Data Wisata')
@php
    $pageTitle = 'Kelola Data Destinasi Wisata';
    $pageDesc = 'Halaman ini digunakan untuk mengelola data tempat wisata, rute, dan kategori destinasi SmartTrip.';
@endphp

@section('content')
    <div class="max-w-7xl mx-auto space-y-6">

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
                <div class="flex items-center space-x-2 text-sm text-textSecondary">
                    <span class="font-medium text-textPrimary">0</span> data dipilih
                </div>
                <button type="button"
                    class="inline-flex items-center px-3 py-1.5 bg-red-50 text-red-600 text-xs font-semibold rounded-md border border-red-200 hover:bg-red-100 transition">
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
                                <input type="checkbox" class="rounded border-border text-primary focus:ring-primary">
                            </th>
                            <th class="p-4">No</th>
                            <th class="p-4">Foto</th>
                            <th class="p-4">Nama & Lokasi Tempat</th>
                            <th class="p-4">Kategori</th>
                            <th class="p-4">Jam Operasional</th>
                            <th class="p-4">Harga</th>
                            <th class="p-4">Longitude, Latitude</th>
                            <th class="p-4 text-center">Aksi</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-border text-sm text-textPrimary">
                        @forelse ($wisatas as $wisata)
                            <tr class="hover:bg-slate-50 transition">
                                <td class="p-4 text-center">
                                    <input type="checkbox" class="rounded border-border text-primary focus:ring-primary"
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
                                        class="h-12 aspect-video rounded-lg bg-slate-200 overflow-hidden flex items-center justify-center text-xs text-slate-500 font-medium">
                                        @if ($fotoUtama && !empty($fotoUtama->link_photo))
                                            <img src="{{ asset('storage/' . $fotoUtama->link_photo) }}"
                                                alt="{{ $wisata->nama_wisata }}" class="w-full h-full object-cover">
                                        @else
                                            Foto
                                        @endif
                                    </div>
                                </td>
                                <td class="p-4">
                                    <div class="font-bold text-textPrimary">{{ $wisata->nama_wisata }}</div>
                                    <div class="text-xs text-textSecondary">
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
                                                class="inline-flex px-2.5 py-1 text-xs font-semibold rounded-full bg-teal-50 text-primary border border-teal-100">
                                                {{ $kategori->nama_kategori }}
                                            </span>
                                        @empty
                                            <span class="text-xs text-textSecondary italic">Tanpa Kategori</span>
                                        @endforelse
                                    </div>
                                </td>
                                <td class="p-4 text-textSecondary text-xs">
                                    @if ($wisata->jamOperasis->count() > 0)
                                        {{ $wisata->jamOperasis->first()->jam_buka }} -
                                        {{ $wisata->jamOperasis->first()->jam_tutup }}
                                    @else
                                        -
                                    @endif
                                </td>
                                <td class="p-4 font-medium">
                                    Rp{{ number_format($wisata->harga_tiket_masuk ?? 0, 0, ',', '.') }}
                                </td>
                                <td class="p-4 text-xs font-mono text-textSecondary">
                                    {{ $wisata->longitude }}° E, {{ $wisata->latitude }}° S
                                </td>
                                <td class="p-4 text-center">
                                    <div class="flex items-center justify-center space-x-2">
                                        <a href="{{ route('admin.wisata.show', ['wisata' => $wisata->id_wisata]) }}" class="p-1.5 text-slate-500 hover:text-primary transition"
                                            title="Edit">
                                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                    d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z">
                                                </path>
                                            </svg>
                                        </a>
                                        <form action="{{ route('admin.wisata.destroy', ['wisata' => $wisata->id_wisata]) }}" method="POST"
                                            onsubmit="return confirm('Apakah Anda yakin ingin menghapus data ini?');"
                                            class="inline-block">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit"
                                                class="p-1.5 text-slate-500 hover:text-red-600 transition" title="Hapus">
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
                                <td colspan="9" class="p-6 text-center text-textSecondary italic">
                                    Belum ada data tempat wisata yang tersedia.
                                </td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>

            <!-- Pagination di Bawah Tabel -->
            <div class="bg-white border-border pt-2 flex items-center justify-between">
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
@endsection
