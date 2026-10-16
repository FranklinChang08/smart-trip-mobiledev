@extends('layouts.admin')

@section('title', isset($wisata) && $wisata->exists ? 'Edit Data Wisata' : 'Tambah Data Wisata')

@php
    $isEdit = isset($wisata) && $wisata && $wisata->exists;
    $selectedCategories = old('categories', $selectedCategories ?? []);
@endphp

@section('content')
    <div class="max-w-4xl mx-auto p-6 space-y-6">
        @if ($errors->any())
            <div class="mb-4 rounded-lg border border-red-300 bg-red-50 p-4">
                <p class="font-semibold text-red-700">Data gagal divalidasi:</p>
                <ul class="mt-2 list-disc pl-5 text-sm text-red-600">
                    @foreach ($errors->all() as $error)
                        <li>{{ $error }}</li>
                    @endforeach
                </ul>
            </div>
        @endif

        @if (session('error'))
            <p class="mb-4 text-sm text-red-600">{{ session('error') }}</p>
        @endif

        @if (session('success'))
            <p class="mb-4 text-sm text-emerald-600">{{ session('success') }}</p>
        @endif

        <form action="{{ $isEdit ? route('admin.wisata.update', $wisata->id_wisata) : route('admin.wisata.store') }}"
            method="POST" class="space-y-6" enctype="multipart/form-data">
            @csrf
            @if ($isEdit)
                @method('PUT')
            @endif

            {{-- Header form --}}
            <div class="flex flex-col gap-4 border-b border-border pb-4 sm:flex-row sm:items-center sm:justify-between">
                <div>
                    <h1 class="text-xl font-bold text-textPrimary">
                        {{ $isEdit ? 'Edit Tempat Wisata' : 'Tambah Tempat Wisata' }}
                    </h1>
                    <p class="text-sm text-textSecondary">
                        {{ $isEdit
                            ? 'Perbarui informasi destinasi wisata melalui formulir di bawah ini.'
                            : 'Lengkapi formulir di bawah ini untuk menambahkan data destinasi wisata baru.' }}
                    </p>
                </div>
                <div class="flex items-center space-x-3">
                    <a href="{{ route('admin.wisata.index') }}"
                        class="px-4 py-2 border border-border rounded-lg text-sm font-medium text-textSecondary bg-white hover:bg-slate-50 transition">
                        Batal
                    </a>
                    <button type="submit"
                        class="px-4 py-2 bg-primary text-white text-sm font-semibold rounded-lg hover:opacity-95 transition shadow-sm">
                        {{ $isEdit ? 'Perbarui Data Wisata' : 'Simpan Data Wisata' }}
                    </button>
                </div>
            </div>

            {{-- Informasi umum --}}
            <div class="bg-white p-6 rounded-xl border border-border shadow-sm space-y-5">
                <h2 class="text-base font-bold text-textPrimary flex items-center">
                    <span class="w-2 h-5 bg-primary rounded-full mr-2"></span>
                    Informasi Umum Destinasi
                </h2>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div class="md:col-span-2">
                        <label for="nama_wisata" class="block text-sm font-medium text-textPrimary mb-1.5">
                            Nama Wisata <span class="text-red-500">*</span>
                        </label>
                        <input id="nama_wisata" type="text" name="nama_wisata"
                            value="{{ old('nama_wisata', $wisata->nama_wisata ?? '') }}" placeholder="Contoh: Pantai Nongsa"
                            required
                            class="w-full px-3.5 py-2 bg-background border border-border rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 focus:ring-primary">
                        @error('nama_wisata')
                            <p class="mt-1.5 text-xs text-red-500" role="alert">{{ $message }}</p>
                        @enderror
                    </div>

                    <div class="md:col-span-2">
                        <x-multi-selection name="categories" label="Kategori Wisata" placeholder="Pilih Kategori"
                            searchPlaceholder="Cari atau tambah kategori..." :initial-options="$categories" :selected-values="$selectedCategories"
                            :allow-add="true" />
                        @if ($errors->has('categories'))
                            <p class="mt-1.5 text-xs text-red-500" role="alert">{{ $errors->first('categories') }}</p>
                        @endif
                        @foreach ($errors->get('categories.*') as $messages)
                            @foreach ($messages as $message)
                                <p class="mt-1.5 text-xs text-red-500" role="alert">{{ $message }}</p>
                            @endforeach
                        @endforeach
                    </div>

                    <div class="md:col-span-2">
                        <x-searchable-select name="id_kecamatan" id="id_kecamatan" label="Kecamatan" :options="$kecamatan"
                            :selectedValue="old('id_kecamatan', $wisata->id_kecamatan ?? '')" placeholder="Pilih Kecamatan" searchPlaceholder="Cari kecamatan..."
                            :required="true" />
                        @error('id_kecamatan')
                            <p class="mt-1.5 text-xs text-red-500" role="alert">{{ $message }}</p>
                        @enderror
                    </div>

                    <div class="md:col-span-2">
                        <label for="alamat_detail_wisata" class="block text-sm font-medium text-textPrimary mb-1.5">
                            Alamat Detail <span class="text-red-500">*</span>
                        </label>
                        <textarea id="alamat_detail_wisata" name="alamat_detail_wisata" rows="2" required
                            placeholder="Masukkan alamat lengkap lokasi wisata..."
                            class="w-full px-3.5 py-2 bg-background border border-border rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 focus:ring-primary">{{ old('alamat_detail_wisata', $wisata->alamat_detail_wisata ?? '') }}</textarea>
                        @error('alamat_detail_wisata')
                            <p class="mt-1.5 text-xs text-red-500" role="alert">{{ $message }}</p>
                        @enderror
                    </div>

                    <div>
                        <label for="latitude" class="block text-sm font-medium text-textPrimary mb-1.5">Latitude <span
                                class="text-red-500">*</span></label>
                        <input id="latitude" type="number" step="any" name="latitude"
                            value="{{ old('latitude', $wisata->latitude ?? '') }}" placeholder="Contoh: 1.13010000"
                            required
                            class="w-full px-3.5 py-2 bg-background border border-border rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 focus:ring-primary font-mono">
                        @error('latitude')
                            <p class="mt-1.5 text-xs text-red-500" role="alert">{{ $message }}</p>
                        @enderror
                    </div>

                    <div>
                        <label for="longitude" class="block text-sm font-medium text-textPrimary mb-1.5">Longitude <span
                                class="text-red-500">*</span></label>
                        <input id="longitude" type="number" step="any" name="longitude"
                            value="{{ old('longitude', $wisata->longitude ?? '') }}" placeholder="Contoh: 104.05290000"
                            required
                            class="w-full px-3.5 py-2 bg-background border border-border rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 focus:ring-primary font-mono">
                        @error('longitude')
                            <p class="mt-1.5 text-xs text-red-500" role="alert">{{ $message }}</p>
                        @enderror
                    </div>

                    <div class="md:col-span-2">
                        <label for="link_on_maps" class="block text-sm font-medium text-textPrimary mb-1.5">Link Google Maps
                            <span class="text-red-500">*</span></label>
                        <input id="link_on_maps" type="url" name="link_on_maps"
                            value="{{ old('link_on_maps', $wisata->link_on_maps ?? '') }}"
                            placeholder="https://maps.google.com/..." required
                            class="w-full px-3.5 py-2 bg-background border border-border rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 focus:ring-primary">
                        @error('link_on_maps')
                            <p class="mt-1.5 text-xs text-red-500" role="alert">{{ $message }}</p>
                        @enderror
                    </div>

                    <div class="md:col-span-2">
                        <label for="harga_tiket_masuk" class="block text-sm font-medium text-textPrimary mb-1.5">Harga
                            Tiket Masuk (Rp)</label>
                        <div class="relative">
                            <span
                                class="absolute inset-y-0 left-0 flex items-center pl-3.5 text-sm text-textSecondary font-medium">Rp</span>
                            <input id="harga_tiket_masuk" type="number" name="harga_tiket_masuk"
                                value="{{ old('harga_tiket_masuk', $wisata->harga_tiket_masuk ?? '') }}" min="0"
                                placeholder="50000"
                                class="w-full pl-11 pr-4 py-2 bg-background border border-border rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 focus:ring-primary">
                        </div>
                        @error('harga_tiket_masuk')
                            <p class="mt-1.5 text-xs text-red-500" role="alert">{{ $message }}</p>
                        @enderror
                    </div>

                    <div class="md:col-span-2">
                        <label for="deskripsi" class="block text-sm font-medium text-textPrimary mb-1.5">Deskripsi
                            Destinasi</label>
                        <textarea id="deskripsi" name="deskripsi" rows="4"
                            placeholder="Tuliskan deskripsi lengkap mengenai tempat wisata ini..."
                            class="w-full px-3.5 py-2 bg-background border border-border rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 focus:ring-primary">{{ old('deskripsi', $wisata->deskripsi ?? '') }}</textarea>
                        @error('deskripsi')
                            <p class="mt-1.5 text-xs text-red-500" role="alert">{{ $message }}</p>
                        @enderror
                    </div>
                </div>
            </div>

            {{-- Jam operasional. Komponen perlu menerima data lama untuk mode edit. --}}
            <x-jam-operasional :initial-data="$jamOperasional ?? []" />

            <x-upload-foto :is-edit="$isEdit" :foto-wisata="$fotoDestinasi ?? []" :wisata="$wisata ?? []" />

            <div class="flex justify-end gap-3">
                <a href="{{ route('admin.wisata.index') }}"
                    class="px-4 py-2 border border-border rounded-lg text-sm font-medium text-textSecondary bg-white hover:bg-slate-50 transition">Batal</a>
                <button type="submit"
                    class="px-4 py-2 bg-primary text-white text-sm font-semibold rounded-lg hover:opacity-95 transition shadow-sm">
                    {{ $isEdit ? 'Perbarui Data Wisata' : 'Simpan Data Wisata' }}
                </button>
            </div>
        </form>
    </div>


@endsection
