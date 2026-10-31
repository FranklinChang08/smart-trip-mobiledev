@extends('layouts.admin')

@section('title', isset($restoran) && $restoran->exists ? 'Edit Data Restoran' : 'Tambah Data Restoran')

@php
    $isEdit = isset($restoran) && $restoran && $restoran->exists;
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

        <form action="{{ $isEdit ? route('admin.restoran.update', $restoran->id_restoran) : route('admin.restoran.store') }}"
            method="POST" class="space-y-6" enctype="multipart/form-data" novalidate id="formRestoran">
            @csrf
            @if ($isEdit)
                @method('PUT')
            @endif

            {{-- Header form --}}
            <div class="border-b border-border pb-4">
                <h1 class="text-xl font-bold text-textPrimary">
                    {{ $isEdit ? 'Edit Tempat Makan / Restoran' : 'Tambah Tempat Makan / Restoran' }}
                </h1>
                <p class="text-sm text-textSecondary mt-1">
                    {{ $isEdit
                        ? 'Perbarui informasi restoran dan kuliner melalui formulir di bawah ini.'
                        : 'Lengkapi formulir di bawah ini untuk menambahkan data restoran baru.' }}
                </p>
            </div>

            {{-- Informasi umum --}}
            <div class="bg-white p-6 rounded-xl border border-border shadow-sm space-y-5">
                <h2 class="text-base font-bold text-textPrimary flex items-center">
                    <span class="w-2 h-5 bg-[#934515] rounded-full mr-2"></span>
                    Informasi Umum Restoran &amp; Kuliner
                </h2>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div class="md:col-span-2">
                        <label for="nama_restoran" class="block text-sm font-semibold text-textPrimary mb-1.5">
                            Nama Restoran / Tempat Makan <span class="text-red-500">*</span>
                        </label>
                        <input id="nama_restoran" type="text" name="nama_restoran"
                            value="{{ old('nama_restoran', $restoran->nama_restoran ?? '') }}"
                            placeholder="Contoh: Harbour Bay Seafood Restaurant"
                            class="w-full px-3.5 py-2.5 bg-background border @error('nama_restoran') border-red-500 ring-1 ring-red-500/20 @else border-border @enderror rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 focus:ring-[#934515] transition-all">
                        <p class="field-error text-xs text-red-600 mt-1.5 ml-1 font-medium {{ $errors->has('nama_restoran') ? '' : 'hidden' }}">
                            {{ $errors->first('nama_restoran') ?: 'Nama restoran wajib diisi' }}
                        </p>
                    </div>

                    <div class="md:col-span-2" id="categories-field-container">
                        <x-multi-selection name="categories" label="Kategori Kuliner" placeholder="Pilih Kategori"
                            searchPlaceholder="Cari atau tambah kategori..." :initial-options="$categories" :selected-values="$selectedCategories"
                            :allow-add="true" />
                        <p class="field-error text-xs text-red-600 mt-1.5 ml-1 font-medium {{ $errors->has('categories') || $errors->has('categories.*') ? '' : 'hidden' }}">
                            {{ $errors->first('categories') ?: ($errors->first('categories.*') ?: 'Kategori kuliner wajib dipilih') }}
                        </p>
                    </div>

                    <div id="kecamatan-field-container">
                        <x-searchable-select name="id_kecamatan" id="id_kecamatan" label="Kecamatan" :options="$kecamatan"
                            :selectedValue="old('id_kecamatan', $restoran->id_kecamatan ?? '')" placeholder="Pilih Kecamatan" searchPlaceholder="Cari kecamatan..."
                            :required="true" />
                        <p class="field-error text-xs text-red-600 mt-1.5 ml-1 font-medium {{ $errors->has('id_kecamatan') ? '' : 'hidden' }}">
                            {{ $errors->first('id_kecamatan') ?: 'Kecamatan wajib dipilih' }}
                        </p>
                    </div>

                    <div>
                        <label for="type_food" class="block text-sm font-semibold text-textPrimary mb-1.5">
                            Tipe Makanan <span class="text-red-500">*</span>
                        </label>
                        <select id="type_food" name="type_food"
                            class="w-full px-3.5 py-2.5 bg-background border @error('type_food') border-red-500 ring-1 ring-red-500/20 @else border-border @enderror rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 focus:ring-[#934515] transition-all">
                            <option value="Semua" {{ old('type_food', $restoran->type_food ?? 'Semua') === 'Semua' ? 'selected' : '' }}>Semua Jenis Makanan</option>
                            <option value="Halal" {{ old('type_food', $restoran->type_food ?? '') === 'Halal' ? 'selected' : '' }}>Halal</option>
                            <option value="Vegetarian" {{ old('type_food', $restoran->type_food ?? '') === 'Vegetarian' ? 'selected' : '' }}>Vegetarian</option>
                        </select>
                        <p class="field-error text-xs text-red-600 mt-1.5 ml-1 font-medium {{ $errors->has('type_food') ? '' : 'hidden' }}">
                            {{ $errors->first('type_food') ?: 'Tipe makanan wajib dipilih' }}
                        </p>
                    </div>

                    <div class="md:col-span-2">
                        <label for="harga_makan_per_orang" class="block text-sm font-semibold text-textPrimary mb-1.5">
                            Estimasi Harga per Orang (Rp)
                        </label>
                        <div class="relative">
                            <span
                                class="absolute inset-y-0 left-0 flex items-center pl-3.5 text-sm text-textSecondary font-medium">Rp</span>
                            <input id="harga_makan_per_orang" type="number" name="harga_makan_per_orang"
                                value="{{ old('harga_makan_per_orang', $restoran->harga_makan_per_orang ?? '') }}" min="0"
                                placeholder="35000"
                                class="w-full pl-11 pr-4 py-2.5 bg-background border @error('harga_makan_per_orang') border-red-500 ring-1 ring-red-500/20 @else border-border @enderror rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 focus:ring-[#934515] transition-all">
                        </div>
                        @error('harga_makan_per_orang')
                            <p class="text-xs text-red-600 mt-1.5 ml-1 font-medium" role="alert">{{ $message }}</p>
                        @enderror
                    </div>

                    <div class="md:col-span-2">
                        <label for="alamat_Detail_restoran" class="block text-sm font-semibold text-textPrimary mb-1.5">
                            Alamat Detail <span class="text-red-500">*</span>
                        </label>
                        <textarea id="alamat_Detail_restoran" name="alamat_Detail_restoran" rows="2"
                            placeholder="Masukkan alamat lengkap lokasi restoran..."
                            class="w-full px-3.5 py-2.5 bg-background border @error('alamat_Detail_restoran') border-red-500 ring-1 ring-red-500/20 @else border-border @enderror rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 focus:ring-[#934515] transition-all">{{ old('alamat_Detail_restoran', $restoran->alamat_Detail_restoran ?? '') }}</textarea>
                        <p class="field-error text-xs text-red-600 mt-1.5 ml-1 font-medium {{ $errors->has('alamat_Detail_restoran') ? '' : 'hidden' }}">
                            {{ $errors->first('alamat_Detail_restoran') ?: 'Alamat restoran wajib diisi' }}
                        </p>
                    </div>

                    <div>
                        <label for="latitude" class="block text-sm font-semibold text-textPrimary mb-1.5">
                            Latitude <span class="text-red-500">*</span>
                        </label>
                        <input id="latitude" type="number" step="any" name="latitude"
                            value="{{ old('latitude', $restoran->latitude ?? '') }}" placeholder="Contoh: 1.13010000"
                            class="w-full px-3.5 py-2.5 bg-background border @error('latitude') border-red-500 ring-1 ring-red-500/20 @else border-border @enderror rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 focus:ring-[#934515] font-mono transition-all">
                        <p class="field-error text-xs text-red-600 mt-1.5 ml-1 font-medium {{ $errors->has('latitude') ? '' : 'hidden' }}">
                            {{ $errors->first('latitude') ?: 'Latitude wajib diisi' }}
                        </p>
                    </div>

                    <div>
                        <label for="longitude" class="block text-sm font-semibold text-textPrimary mb-1.5">
                            Longitude <span class="text-red-500">*</span>
                        </label>
                        <input id="longitude" type="number" step="any" name="longitude"
                            value="{{ old('longitude', $restoran->longitude ?? '') }}" placeholder="Contoh: 104.05290000"
                            class="w-full px-3.5 py-2.5 bg-background border @error('longitude') border-red-500 ring-1 ring-red-500/20 @else border-border @enderror rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 focus:ring-[#934515] font-mono transition-all">
                        <p class="field-error text-xs text-red-600 mt-1.5 ml-1 font-medium {{ $errors->has('longitude') ? '' : 'hidden' }}">
                            {{ $errors->first('longitude') ?: 'Longitude wajib diisi' }}
                        </p>
                    </div>

                    <div class="md:col-span-2">
                        <label for="link_on_maps" class="block text-sm font-semibold text-textPrimary mb-1.5">
                            Link Google Maps <span class="text-red-500">*</span>
                        </label>
                        <input id="link_on_maps" type="url" name="link_on_maps"
                            value="{{ old('link_on_maps', $restoran->link_on_maps ?? '') }}"
                            placeholder="https://maps.google.com/..."
                            class="w-full px-3.5 py-2.5 bg-background border @error('link_on_maps') border-red-500 ring-1 ring-red-500/20 @else border-border @enderror rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 focus:ring-[#934515] transition-all">
                        <p class="field-error text-xs text-red-600 mt-1.5 ml-1 font-medium {{ $errors->has('link_on_maps') ? '' : 'hidden' }}">
                            {{ $errors->first('link_on_maps') ?: 'Link Google Maps wajib diisi' }}
                        </p>
                    </div>

                    <div class="md:col-span-2">
                        <label for="deskripsi" class="block text-sm font-semibold text-textPrimary mb-1.5">
                            Deskripsi Restoran
                        </label>
                        <textarea id="deskripsi" name="deskripsi" rows="4"
                            placeholder="Tuliskan deskripsi lengkap mengenai tempat makan atau restoran ini, menu favorit, suasana..."
                            class="w-full px-3.5 py-2.5 bg-background border @error('deskripsi') border-red-500 ring-1 ring-red-500/20 @else border-border @enderror rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 focus:ring-[#934515] transition-all">{{ old('deskripsi', $restoran->deskripsi ?? '') }}</textarea>
                        @error('deskripsi')
                            <p class="text-xs text-red-600 mt-1.5 ml-1 font-medium" role="alert">{{ $message }}</p>
                        @enderror
                    </div>
                </div>
            </div>

            {{-- Fasilitas Restoran (Many to Many) --}}
            <x-fasilitas-selection :all-fasilitas="$fasilitas ?? []" :selected-fasilitas="$selectedFasilitas ?? []" />

            {{-- Jam operasional --}}
            <x-jam-operasional :initial-data="$jamOperasional ?? []" />

            {{-- Upload Foto --}}
            <x-upload-foto :is-edit="$isEdit" :foto-destinasi="$fotoDestinasi ?? []" :destinasi="$restoran ?? []" />

            {{-- Tombol Bawah --}}
            <div class="flex justify-end gap-3">
                <a href="{{ route('admin.restoran.index') }}"
                    class="px-4 py-2 border border-border rounded-lg text-sm font-medium text-textSecondary bg-white hover:bg-slate-50 transition">
                    Batal
                </a>
                <button type="submit"
                    class="px-4 py-2 bg-[#934515] hover:bg-[#7D3A11] text-white text-sm font-semibold rounded-lg transition shadow-sm">
                    {{ $isEdit ? 'Perbarui Data Restoran' : 'Simpan Data Restoran' }}
                </button>
            </div>
        </form>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const form = document.getElementById('formRestoran');
            if (!form) return;

            function setError(inputEl, containerEl, hasError, message) {
                const errorEl = containerEl.querySelector('.field-error');
                const trigger = containerEl.querySelector('.select-trigger') || containerEl.querySelector('.dropdown-trigger') || inputEl;

                if (hasError) {
                    if (trigger) {
                        trigger.classList.add('border-red-500', 'ring-1', 'ring-red-500/20');
                        trigger.classList.remove('border-border');
                    }
                    if (errorEl) {
                        if (message) errorEl.textContent = message;
                        errorEl.classList.remove('hidden');
                    }
                } else {
                    if (trigger) {
                        trigger.classList.remove('border-red-500', 'ring-1', 'ring-red-500/20');
                        trigger.classList.add('border-border');
                    }
                    if (errorEl) {
                        errorEl.classList.add('hidden');
                    }
                }
            }

            form.querySelectorAll('input, textarea, select').forEach(input => {
                input.addEventListener('input', function () {
                    const container = input.closest('.md\\:col-span-2') || input.closest('div');
                    if (container) setError(input, container, false);
                });
                input.addEventListener('change', function () {
                    const container = input.closest('.md\\:col-span-2') || input.closest('div');
                    if (container) setError(input, container, false);
                });
            });

            // Observer for categories and kecamatan
            const observer = new MutationObserver(function () {
                const catContainer = document.getElementById('categories-field-container');
                if (catContainer) {
                    const catInputs = catContainer.querySelectorAll('input[name="categories[]"]');
                    if (catInputs.length > 0) setError(null, catContainer, false);
                }

                const kecContainer = document.getElementById('kecamatan-field-container');
                if (kecContainer) {
                    const kecInput = kecContainer.querySelector('input[name="id_kecamatan"]');
                    if (kecInput && kecInput.value) setError(null, kecContainer, false);
                }
            });

            observer.observe(form, { childList: true, subtree: true, attributes: true });

            form.addEventListener('submit', function (e) {
                let firstInvalid = null;

                // 1. Nama Restoran
                const nama = form.querySelector('#nama_restoran');
                if (nama && !nama.value.trim()) {
                    setError(nama, nama.closest('div'), true, 'Nama restoran wajib diisi');
                    if (!firstInvalid) firstInvalid = nama;
                }

                // 2. Kategori
                const catContainer = document.getElementById('categories-field-container');
                if (catContainer) {
                    const cats = catContainer.querySelectorAll('input[name="categories[]"]');
                    if (cats.length === 0) {
                        setError(null, catContainer, true, 'Kategori kuliner wajib dipilih');
                        if (!firstInvalid) firstInvalid = catContainer;
                    }
                }

                // 3. Kecamatan
                const kecContainer = document.getElementById('kecamatan-field-container');
                if (kecContainer) {
                    const kec = kecContainer.querySelector('input[name="id_kecamatan"]');
                    if (!kec || !kec.value) {
                        setError(null, kecContainer, true, 'Kecamatan wajib dipilih');
                        if (!firstInvalid) firstInvalid = kecContainer;
                    }
                }

                // 4. Tipe Makanan
                const typeFood = form.querySelector('#type_food');
                if (typeFood && !typeFood.value) {
                    setError(typeFood, typeFood.closest('div'), true, 'Tipe makanan wajib dipilih');
                    if (!firstInvalid) firstInvalid = typeFood;
                }

                // 5. Alamat Detail
                const alamat = form.querySelector('#alamat_Detail_restoran');
                if (alamat && !alamat.value.trim()) {
                    setError(alamat, alamat.closest('div'), true, 'Alamat detail restoran wajib diisi');
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

                // 8. Link Maps
                const maps = form.querySelector('#link_on_maps');
                if (maps && !maps.value.trim()) {
                    setError(maps, maps.closest('div'), true, 'Link Google Maps wajib diisi');
                    if (!firstInvalid) firstInvalid = maps;
                }

                if (firstInvalid) {
                    e.preventDefault();
                    firstInvalid.scrollIntoView({ behavior: 'smooth', block: 'center' });
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
