@extends('layouts.admin')

@section('title', isset($lokasi_transportasi) && $lokasi_transportasi->exists ? 'Edit Data lokasi' : 'Tambah Data lokasi')

@php
    $isEdit = isset($lokasi_transportasi) && $lokasi_transportasi && $lokasi_transportasi->exists;
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

        <form
            action="{{ $isEdit ? route('admin.lokasi.update', $lokasi_transportasi->id_lokasi) : route('admin.lokasi.store') }}"
            method="POST" class="space-y-6" enctype="multipart/form-data">
            @csrf
            @if ($isEdit)
                @method('PUT')
            @endif

            {{-- Header form --}}
            <div class="flex flex-col gap-4 border-b border-border pb-4 sm:flex-row sm:items-center sm:justify-between">
                <div>
                    <h1 class="text-xl font-bold text-textPrimary">
                        {{ $isEdit ? 'Edit Tempat lokasi' : 'Tambah Tempat lokasi' }}
                    </h1>
                    <p class="text-sm text-textSecondary">
                        {{ $isEdit
                            ? 'Perbarui informasi destinasi lokasi melalui formulir di bawah ini.'
                            : 'Lengkapi formulir di bawah ini untuk menambahkan data destinasi lokasi baru.' }}
                    </p>
                </div>
                <div class="flex items-center space-x-3">
                    <a href="{{ route('admin.lokasi.index') }}"
                        class="px-4 py-2 border border-border rounded-lg text-sm font-medium text-textSecondary bg-white hover:bg-slate-50 transition">
                        Batal
                    </a>
                    <button type="submit"
                        class="px-4 py-2 bg-primary text-white text-sm font-semibold rounded-lg hover:opacity-95 transition shadow-sm">
                        {{ $isEdit ? 'Perbarui Data lokasi' : 'Simpan Data lokasi' }}
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
                        <label for="nama_lokasi" class="block text-sm font-medium text-textPrimary mb-1.5">
                            Nama Lokasi <span class="text-red-500">*</span>
                        </label>
                        <input id="nama_lokasi" type="text" name="nama_lokasi"
                            value="{{ old('nama_lokasi', $lokasi_transportasi->nama_lokasi ?? '') }}"
                            placeholder="Contoh: Pantai Nongsa"
                            class="w-full px-3.5 py-2 bg-background border border-border rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 focus:ring-primary">
                        @error('nama_lokasi')
                            <p class="mt-1.5 text-xs text-red-500" role="alert">{{ $message }}</p>
                        @enderror
                    </div>

                    <div class="md:col-span-2">
                        <x-searchable-select name="id_kecamatan" id="id_kecamatan" label="Kecamatan" :options="$kecamatan"
                            :selectedValue="old('id_kecamatan', $lokasi_transportasi->id_kecamatan ?? '')" placeholder="Pilih Kecamatan" searchPlaceholder="Cari kecamatan..."
                            :required="false" />
                        @error('id_kecamatan')
                            <p class="mt-1.5 text-xs text-red-500" role="alert">{{ $message }}</p>
                        @enderror
                    </div>

                    <div class="md:col-span-2">
                        <x-simple-select name="type_lokasi" id="type_lokasi" label="Jenis Lokasi" :options="[
                            ['value' => 'Bandara', 'label' => 'Bandara'],
                            ['value' => 'Pelabuhan', 'label' => 'Pelabuhan'],
                            ['value' => 'Terminal Bus', 'label' => 'Terminal Bus'],
                            ['value' => 'Stasiun', 'label' => 'Stasiun'],
                        ]"
                            :selected-value="old('type_lokasi', $lokasi_transportasi->type_lokasi ?? '')" placeholder="Pilih jenis lokasi..." :required="true" />

                        @error('type_lokasi')
                            <p class="mt-1.5 text-xs text-red-500" role="alert">
                                {{ $message }}
                            </p>
                        @enderror
                    </div>

                    <div class="md:col-span-2">
                        <label for="alamat_detail_lokasi" class="block text-sm font-medium text-textPrimary mb-1.5">
                            Alamat Detail <span class="text-red-500">*</span>
                        </label>
                        <textarea id="alamat_detail_lokasi" name="alamat_detail_lokasi" rows="2"
                            placeholder="Masukkan alamat lengkap lokasi lokasi..."
                            class="w-full px-3.5 py-2 bg-background border border-border rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 focus:ring-primary">{{ old('alamat_detail_lokasi', $lokasi_transportasi->alamat_detail_lokasi ?? '') }}</textarea>
                        @error('alamat_detail_lokasi')
                            <p class="mt-1.5 text-xs text-red-500" role="alert">{{ $message }}</p>
                        @enderror
                    </div>

                    <div>
                        <label for="latitude" class="block text-sm font-medium text-textPrimary mb-1.5">Latitude <span
                                class="text-red-500">*</span></label>
                        <input id="latitude" type="number" step="any" name="latitude"
                            value="{{ old('latitude', $lokasi_transportasi->latitude ?? '') }}" placeholder="Contoh: 1.13010000"
                            class="w-full px-3.5 py-2 bg-background border border-border rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 focus:ring-primary font-mono">
                        @error('latitude')
                            <p class="mt-1.5 text-xs text-red-500" role="alert">{{ $message }}</p>
                        @enderror
                    </div>

                    <div>
                        <label for="longitude" class="block text-sm font-medium text-textPrimary mb-1.5">Longitude <span
                                class="text-red-500">*</span></label>
                        <input id="longitude" type="number" step="any" name="longitude"
                            value="{{ old('longitude', $lokasi_transportasi->longitude ?? '') }}" placeholder="Contoh: 104.05290000"
                            class="w-full px-3.5 py-2 bg-background border border-border rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 focus:ring-primary font-mono">
                        @error('longitude')
                            <p class="mt-1.5 text-xs text-red-500" role="alert">{{ $message }}</p>
                        @enderror
                    </div>

                    <div class="md:col-span-2">
                        <label for="link_on_maps" class="block text-sm font-medium text-textPrimary mb-1.5">Link Google Maps
                            <span class="text-red-500">*</span></label>
                        <input id="link_on_maps" type="url" name="link_on_maps"
                            value="{{ old('link_on_maps', $lokasi_transportasi->link_on_maps ?? '') }}"
                            placeholder="https://maps.google.com/..."
                            class="w-full px-3.5 py-2 bg-background border border-border rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 focus:ring-primary">
                        @error('link_on_maps')
                            <p class="mt-1.5 text-xs text-red-500" role="alert">{{ $message }}</p>
                        @enderror
                    </div>

                    <div class="md:col-span-2">
                        <label for="deskripsi" class="block text-sm font-medium text-textPrimary mb-1.5">Deskripsi
                            Destinasi</label>
                        <textarea id="deskripsi" name="deskripsi" rows="4"
                            placeholder="Tuliskan deskripsi lengkap mengenai tempat lokasi ini..."
                            class="w-full px-3.5 py-2 bg-background border border-border rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 focus:ring-primary">{{ old('deskripsi', $lokasi_transportasi->deskripsi ?? '') }}</textarea>
                        @error('deskripsi')
                            <p class="mt-1.5 text-xs text-red-500" role="alert">{{ $message }}</p>
                        @enderror
                    </div>
                </div>
            </div>

            <x-fasilitas-selection :all-fasilitas="$fasilitas ?? []" :selected-fasilitas="$selectedFasilitas ?? []" />

            <x-upload-foto :is-edit="$isEdit" :foto-destinasi="$fotoDestinasi ?? []" :destinasi="$lokasi_transportasi ?? []" />

            <div class="flex justify-end gap-3">
                <a href="{{ route('admin.lokasi.index') }}"
                    class="px-4 py-2 border border-border rounded-lg text-sm font-medium text-textSecondary bg-white hover:bg-slate-50 transition">Batal</a>
                <button type="submit"
                    class="px-4 py-2 bg-primary text-white text-sm font-semibold rounded-lg hover:opacity-95 transition shadow-sm">
                    {{ $isEdit ? 'Perbarui Data lokasi' : 'Simpan Data lokasi' }}
                </button>
            </div>
        </form>
    </div>

@endsection
