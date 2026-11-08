@extends('layouts.admin')

@section('title', isset($penginapan) && $penginapan->exists ? 'Edit Data Penginapan' : 'Tambah Data Penginapan')

@php
    $isEdit = isset($penginapan) && $penginapan && $penginapan->exists;
    $selectedCategories = old('categories', $selectedCategories ?? []);
@endphp

@section('content')
    <div class="max-w-4xl mx-auto p-6 space-y-6">

        @if (session('error'))
            <p class="mb-4 text-sm text-red-600">{{ session('error') }}</p>
        @endif

        @if (session('success'))
            <p class="mb-4 text-sm text-emerald-600">{{ session('success') }}</p>
        @endif

        <form
            action="{{ $isEdit ? route('admin.penginapan.update', $penginapan->id_penginapan) : route('admin.penginapan.store') }}"
            method="POST" class="space-y-6" enctype="multipart/form-data" novalidate id="formPenginapan">
            @csrf
            @if ($isEdit)
                @method('PUT')
            @endif

            {{-- Header form --}}
            <div class="border-b border-border pb-4">
                <h1 class="text-xl font-bold text-textPrimary">
                    {{ $isEdit ? 'Edit Tempat Penginapan' : 'Tambah Tempat Penginapan' }}
                </h1>
                <p class="text-sm text-textSecondary mt-1">
                    {{ $isEdit
                        ? 'Perbarui informasi tempat penginapan melalui formulir di bawah ini.'
                        : 'Lengkapi formulir di bawah ini untuk menambahkan data tempat penginapan baru.' }}
                </p>
            </div>

            {{-- Informasi umum --}}
            <div class="bg-white p-6 rounded-xl border border-border shadow-sm space-y-5">
                <h2 class="text-base font-bold text-textPrimary flex items-center">
                    <span class="w-2 h-5 bg-primary rounded-full mr-2"></span>
                    Informasi Umum Penginapan
                </h2>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div class="md:col-span-2">
                        <label for="nama_penginapan" class="block text-sm font-semibold text-textPrimary mb-1.5">
                            Nama Penginapan <span class="text-red-500">*</span>
                        </label>
                        <input id="nama_penginapan" type="text" name="nama_penginapan"
                            value="{{ old('nama_penginapan', $penginapan->nama_penginapan ?? '') }}"
                            placeholder="Contoh: Batam Marriott Hotel Harbour Bay" @class([
                                'w-full px-3.5 py-2.5 bg-background border rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 transition-all',
                                'border-red-500 ring-1 ring-red-500/20 focus:ring-red-500' => $errors->has(
                                    'nama_penginapan'),
                                'border-border focus:ring-primary' => !$errors->has('nama_penginapan'),
                            ])>
                        <p
                            class="field-error text-xs text-red-600 mt-1.5 ml-1 font-medium {{ $errors->has('nama_penginapan') ? '' : 'hidden' }}">
                            {{ $errors->first('nama_penginapan') ?: 'Nama penginapan wajib diisi' }}
                        </p>
                    </div>

                    <div class="md:col-span-2" id="categories-field-container">
                        <x-multi-selection name="categories" label="Kategori Penginapan" placeholder="Pilih Kategori"
                            searchPlaceholder="Cari atau tambah kategori..." :initial-options="$categories" :selected-values="$selectedCategories"
                            :allow-add="true" />
                        <p
                            class="field-error text-xs text-red-600 mt-1.5 ml-1 font-medium {{ $errors->has('categories') || $errors->has('categories.*') ? '' : 'hidden' }}">
                            {{ $errors->first('categories') ?: ($errors->first('categories.*') ?: 'Kategori penginapan wajib dipilih') }}
                        </p>
                    </div>

                    <div id="kecamatan-field-container">
                        <x-searchable-select name="id_kecamatan" id="id_kecamatan" label="Kecamatan" :options="$kecamatan"
                            :selectedValue="old('id_kecamatan', $penginapan->id_kecamatan ?? '')" placeholder="Pilih Kecamatan" searchPlaceholder="Cari kecamatan..."
                            :required="true" />
                        <p
                            class="field-error text-xs text-red-600 mt-1.5 ml-1 font-medium {{ $errors->has('id_kecamatan') ? '' : 'hidden' }}">
                            {{ $errors->first('id_kecamatan') ?: 'Kecamatan wajib dipilih' }}
                        </p>
                    </div>

                    <div id="type-field-container">
                        <x-simple-select name="type_penginapan" id="type_penginapan" label="Jenis Penginapan"
                            :options="[
                                ['value' => 'Hotel', 'label' => 'Hotel'],
                                ['value' => 'Resort', 'label' => 'Resort'],
                                ['value' => 'Villa', 'label' => 'Villa'],
                                ['value' => 'Guest House', 'label' => 'Guest House'],
                                ['value' => 'Hostel', 'label' => 'Hostel'],
                                ['value' => 'Homestay', 'label' => 'Homestay'],
                            ]" :selected-value="old('type_penginapan', $penginapan->type_penginapan ?? '')" placeholder="Pilih jenis penginapan..." :required="true" />
                        <p
                            class="field-error text-xs text-red-600 mt-1.5 ml-1 font-medium {{ $errors->has('type_penginapan') ? '' : 'hidden' }}">
                            {{ $errors->first('type_penginapan') ?: 'Jenis penginapan wajib dipilih' }}
                        </p>
                    </div>

                    <div class="md:col-span-2">
                        <label for="harga_penginapan" class="block text-sm font-semibold text-textPrimary mb-1.5">
                            Estimasi Harga per Malam (Rp)
                        </label>
                        <div class="relative">
                            <span
                                class="absolute inset-y-0 left-0 flex items-center pl-3.5 text-sm text-textSecondary font-medium">Rp</span>
                            <input id="harga_penginapan" type="number" name="harga_penginapan"
                                value="{{ old('harga_penginapan', $penginapan->harga_penginapan ?? '') }}" min="0"
                                placeholder="750000" @class([
                                    'w-full pl-11 pr-4 py-2.5 bg-background border rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 transition-all',
                                    'border-red-500 ring-1 ring-red-500/20 focus:ring-red-500' => $errors->has(
                                        'harga_penginapan'),
                                    'border-border focus:ring-primary' => !$errors->has('harga_penginapan'),
                                ])>
                        </div>
                        @error('harga_penginapan')
                            <p class="text-xs text-red-600 mt-1.5 ml-1 font-medium" role="alert">{{ $message }}</p>
                        @enderror
                    </div>

                    <div class="md:col-span-2">
                        <label for="alamat_detail_penginapan" class="block text-sm font-semibold text-textPrimary mb-1.5">
                            Alamat Detail <span class="text-red-500">*</span>
                        </label>
                        <textarea id="alamat_detail_penginapan" name="alamat_detail_penginapan" rows="2"
                            placeholder="Masukkan alamat lengkap lokasi penginapan..." @class([
                                'w-full px-3.5 py-2.5 bg-background border rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 transition-all',
                                'border-red-500 ring-1 ring-red-500/20 focus:ring-red-500' => $errors->has(
                                    'alamat_detail_penginapan'),
                                'border-border focus:ring-primary' => !$errors->has(
                                    'alamat_detail_penginapan'),
                            ])>{{ old('alamat_detail_penginapan', $penginapan->alamat_detail_penginapan ?? '') }}</textarea>
                        <p
                            class="field-error text-xs text-red-600 mt-1.5 ml-1 font-medium {{ $errors->has('alamat_detail_penginapan') ? '' : 'hidden' }}">
                            {{ $errors->first('alamat_detail_penginapan') ?: 'Alamat detail penginapan wajib diisi' }}
                        </p>
                    </div>

                    <div>
                        <label for="latitude" class="block text-sm font-semibold text-textPrimary mb-1.5">
                            Latitude <span class="text-red-500">*</span>
                        </label>
                        <input id="latitude" type="number" step="any" name="latitude"
                            value="{{ old('latitude', $penginapan->latitude ?? '') }}" placeholder="Contoh: 1.13010000"
                            @class([
                                'w-full px-3.5 py-2.5 bg-background border rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 font-mono transition-all',
                                'border-red-500 ring-1 ring-red-500/20 focus:ring-red-500' => $errors->has(
                                    'latitude'),
                                'border-border focus:ring-primary' => !$errors->has('latitude'),
                            ])>
                        <p
                            class="field-error text-xs text-red-600 mt-1.5 ml-1 font-medium {{ $errors->has('latitude') ? '' : 'hidden' }}">
                            {{ $errors->first('latitude') ?: 'Latitude wajib diisi' }}
                        </p>
                    </div>

                    <div>
                        <label for="longitude" class="block text-sm font-semibold text-textPrimary mb-1.5">
                            Longitude <span class="text-red-500">*</span>
                        </label>
                        <input id="longitude" type="number" step="any" name="longitude"
                            value="{{ old('longitude', $penginapan->longitude ?? '') }}" placeholder="Contoh: 104.05290000"
                            @class([
                                'w-full px-3.5 py-2.5 bg-background border rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 font-mono transition-all',
                                'border-red-500 ring-1 ring-red-500/20 focus:ring-red-500' => $errors->has(
                                    'longitude'),
                                'border-border focus:ring-primary' => !$errors->has('longitude'),
                            ])>
                        <p
                            class="field-error text-xs text-red-600 mt-1.5 ml-1 font-medium {{ $errors->has('longitude') ? '' : 'hidden' }}">
                            {{ $errors->first('longitude') ?: 'Longitude wajib diisi' }}
                        </p>
                    </div>

                    <div class="md:col-span-2">
                        <label for="link_on_maps" class="block text-sm font-semibold text-textPrimary mb-1.5">
                            Link Google Maps <span class="text-xs font-normal text-textSecondary">(Opsional)</span>
                        </label>
                        <input id="link_on_maps" type="url" name="link_on_maps"
                            value="{{ old('link_on_maps', $penginapan->link_on_maps ?? '') }}"
                            placeholder="https://maps.google.com/..." @class([
                                'w-full px-3.5 py-2.5 bg-background border rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 transition-all',
                                'border-red-500 ring-1 ring-red-500/20 focus:ring-red-500' => $errors->has(
                                    'link_on_maps'),
                                'border-border focus:ring-primary' => !$errors->has('link_on_maps'),
                            ])>
                        @error('link_on_maps')
                            <p class="text-xs text-red-600 mt-1.5 ml-1 font-medium" role="alert">{{ $message }}</p>
                        @enderror
                    </div>

                    <div class="md:col-span-2">
                        <label for="deskripsi" class="block text-sm font-semibold text-textPrimary mb-1.5">
                            Deskripsi Penginapan <span class="text-xs font-normal text-textSecondary">(Opsional)</span>
                        </label>
                        <textarea id="deskripsi" name="deskripsi" rows="4"
                            placeholder="Tuliskan deskripsi lengkap mengenai fasilitas, suasana, atau keunggulan tempat penginapan ini..."
                            @class([
                                'w-full px-3.5 py-2.5 bg-background border rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 transition-all',
                                'border-red-500 ring-1 ring-red-500/20 focus:ring-red-500' => $errors->has(
                                    'deskripsi'),
                                'border-border focus:ring-primary' => !$errors->has('deskripsi'),
                            ])>{{ old('deskripsi', $penginapan->deskripsi ?? '') }}</textarea>
                        @error('deskripsi')
                            <p class="text-xs text-red-600 mt-1.5 ml-1 font-medium" role="alert">{{ $message }}</p>
                        @enderror
                    </div>
                </div>
            </div>

            <x-fasilitas-selection :all-fasilitas="$fasilitas ?? []" :selected-fasilitas="$selectedFasilitas ?? []" title="Fasilitas Penginapan (Opsional)"
                accent="primary" />

            <x-upload-foto :is-edit="$isEdit" :foto-destinasi="$fotoDestinasi ?? []" :destinasi="$penginapan ?? []" />

            <div class="flex justify-end gap-3">
                <a href="{{ route('admin.penginapan.index') }}"
                    class="px-4 py-2 border border-border rounded-lg text-sm font-medium text-textSecondary bg-white hover:bg-slate-50 transition">
                    Batal
                </a>
                <button type="submit"
                    class="px-4 py-2 bg-primary text-white text-sm font-semibold rounded-lg hover:opacity-95 transition shadow-sm">
                    {{ $isEdit ? 'Perbarui Data Penginapan' : 'Simpan Data Penginapan' }}
                </button>
            </div>
        </form>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const form = document.getElementById('formPenginapan');
            if (!form) return;

            function setError(input, container, show, message) {
                if (input) {
                    if (show) {
                        input.classList.remove('border-border');
                        input.classList.add('border-red-500', 'ring-1', 'ring-red-500/20');
                    } else {
                        input.classList.remove('border-red-500', 'ring-1', 'ring-red-500/20');
                        input.classList.add('border-border');
                    }
                }
                if (container) {
                    const errEl = container.querySelector('.field-error');
                    if (errEl) {
                        if (message) errEl.textContent = message;
                        errEl.classList.toggle('hidden', !show);
                    }
                    if (!input) {
                        const trigger = container.querySelector(
                            '.multi-select-trigger, .searchable-select-trigger, .simple-select-trigger');
                        if (trigger) {
                            if (show) {
                                trigger.classList.remove('border-border');
                                trigger.classList.add('border-red-500', 'ring-1', 'ring-red-500/20');
                            } else {
                                trigger.classList.remove('border-red-500', 'ring-1', 'ring-red-500/20');
                                trigger.classList.add('border-border');
                            }
                        }
                    }
                }
            }

            form.querySelectorAll('input, textarea, select').forEach(input => {
                input.addEventListener('input', function() {
                    const container = input.closest('.md\\:col-span-2') || input.closest('div');
                    if (container) setError(input, container, false);
                });
                input.addEventListener('change', function() {
                    const container = input.closest('.md\\:col-span-2') || input.closest('div');
                    if (container) setError(input, container, false);
                });
            });

            const catContainer = document.getElementById('categories-field-container');
            if (catContainer) {
                catContainer.addEventListener('click', () => setError(null, catContainer, false));
                catContainer.addEventListener('input', () => setError(null, catContainer, false));
            }

            const kecContainer = document.getElementById('kecamatan-field-container');
            if (kecContainer) {
                kecContainer.addEventListener('click', () => setError(null, kecContainer, false));
            }

            const typeContainer = document.getElementById('type-field-container');
            if (typeContainer) {
                typeContainer.addEventListener('click', () => setError(null, typeContainer, false));
            }

            form.addEventListener('submit', function(e) {
                let firstInvalid = null;

                // 1. Nama Penginapan
                const nama = form.querySelector('#nama_penginapan');
                if (nama && !nama.value.trim()) {
                    setError(nama, nama.closest('div'), true, 'Nama penginapan wajib diisi');
                    if (!firstInvalid) firstInvalid = nama;
                }

                // 2. Kategori
                if (catContainer) {
                    const cats = catContainer.querySelectorAll('input[name="categories[]"]');
                    if (cats.length === 0) {
                        setError(null, catContainer, true, 'Kategori penginapan wajib dipilih');
                        if (!firstInvalid) firstInvalid = catContainer;
                    }
                }

                // 3. Kecamatan
                if (kecContainer) {
                    const kec = kecContainer.querySelector('input[name="id_kecamatan"]');
                    if (!kec || !kec.value) {
                        setError(null, kecContainer, true, 'Kecamatan wajib dipilih');
                        if (!firstInvalid) firstInvalid = kecContainer;
                    }
                }

                // 4. Jenis Penginapan
                if (typeContainer) {
                    const typeInput = typeContainer.querySelector('input[name="type_penginapan"]');
                    if (!typeInput || !typeInput.value) {
                        setError(null, typeContainer, true, 'Jenis penginapan wajib dipilih');
                        if (!firstInvalid) firstInvalid = typeContainer;
                    }
                }

                // 5. Alamat Detail
                const alamat = form.querySelector('#alamat_detail_penginapan');
                if (alamat && !alamat.value.trim()) {
                    setError(alamat, alamat.closest('div'), true, 'Alamat detail penginapan wajib diisi');
                    if (!firstInvalid) firstInvalid = alamat;
                }

                // 6. Latitude
                const lat = form.querySelector('#latitude');
                if (lat && !lat.value.trim()) {
                    setError(lat, lat.closest('div'), true, 'Latitude wajib diisi');
                    if (!firstInvalid) firstInvalid = lat;
                }

                // 7. Longitude
                const lng = form.querySelector('#longitude');
                if (lng && !lng.value.trim()) {
                    setError(lng, lng.closest('div'), true, 'Longitude wajib diisi');
                    if (!firstInvalid) firstInvalid = lng;
                }

                if (firstInvalid) {
                    e.preventDefault();
                    firstInvalid.scrollIntoView({
                        behavior: 'smooth',
                        block: 'center'
                    });
                    if (typeof firstInvalid.focus === 'function') {
                        firstInvalid.focus();
                    }
                    if (window.showToast) {
                        window.showToast('error', 'Silakan lengkapi kolom yang ditandai merah.');
                    }
                    return false;
                }
            });
        });
    </script>
@endsection
