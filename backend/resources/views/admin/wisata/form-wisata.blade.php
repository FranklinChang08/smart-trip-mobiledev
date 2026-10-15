@extends('layouts.admin')

@section('title', 'Data Wisata')
@php
    $pageTitle = 'Kelola Data Destinasi Wisata';
    $pageDesc = 'Halaman ini digunakan untuk mengelola data tempat wisata, rute, dan kategori destinasi SmartTrip.';
@endphp

@section('content')
    <div class="max-w-4xl mx-auto p-6 space-y-6">


        @if ($errors->any())
            <div class="mb-4 rounded-lg border border-red-300 bg-red-50 p-4">
                <p class="font-semibold text-red-700">
                    Data gagal divalidasi:
                </p>

                <ul class="mt-2 list-disc pl-5 text-sm text-red-600">
                    @foreach ($errors->all() as $error)
                        <li>{{ $error }}</li>
                    @endforeach
                </ul>
            </div>
        @endif

        @if (session('error'))
            <p class="mb-4 text-sm text-red-600">
                {{ session('error') }}
            </p>
        @endif


        <!-- FORM UTAMA -->
        <form action="{{ route('admin.wisata.store') }}" method="POST" class="space-y-6" enctype="multipart/form-data">
            @csrf
            @method('POST')

            <!-- Header / Judul Form -->
            <div class="flex items-center justify-between border-b border-border pb-4">
                <div>
                    <h1 class="text-xl font-bold text-textPrimary">Tambah Tempat Wisata</h1>
                    <p class="text-sm text-textSecondary">Lengkapi formulir di bawah ini untuk menambahkan data
                        destinasi wisata baru.</p>
                </div>
                <div class="flex items-center space-x-3">
                    <button type="button"
                        class="px-4 py-2 border border-border rounded-lg text-sm font-medium text-textSecondary bg-white hover:bg-slate-50 transition">
                        Batal
                    </button>
                    <button type="submit"
                        class="px-4 py-2 bg-primary text-white text-sm font-semibold rounded-lg hover:opacity-95 transition shadow-sm">
                        Simpan Data Wisata
                    </button>
                </div>
            </div>

            <!-- CONTAINER 1: Data Umum, Kecamatan, & Kategori -->
            <div class="bg-white p-6 rounded-xl border border-border shadow-sm space-y-5">
                <h2 class="text-base font-bold text-textPrimary flex items-center">
                    <span class="w-2 h-5 bg-primary rounded-full mr-2"></span>
                    Informasi Umum Destinasi
                </h2>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <!-- Nama Wisata (tabel wisata -> nama_wisata) -->
                    <div class="md:col-span-2">
                        <label class="block text-sm font-medium text-textPrimary mb-1.5">Nama Wisata <span
                                class="text-red-500">*</span></label>
                        <input type="text" name="nama_wisata" value="{{ old('nama_wisata') }}"
                            placeholder="Contoh: Candi Borobudur"
                            class="w-full px-3.5 py-2 bg-background border border-border rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 focus:ring-primary">
                        @error('nama_wisata')
                            <p class="mt-1.5 text-xs text-red-500" role="alert">
                                {{ $message }}
                            </p>
                        @enderror
                    </div>

                    <!-- Kategori Wisata (tabel kategori_destinasi & kategori -> id_kategori) -->
                    <div class="md:col-span-2">
                        <x-multi-selection name="categories" label="Kategori Wisata" placeholder="Pilih Kategori"
                            searchPlaceholder="Tambah kategori baru..." :initial-options="$categories" :selected-values="old('categories', [])"
                            :allow-add="true" />

                        @if ($errors->has('categories'))
                            <p class="mt-1.5 text-xs text-red-500" role="alert">
                                {{ $errors->first('categories') }}
                            </p>
                        @endif

                        @foreach ($errors->get('categories.*') as $messages)
                            @foreach ($messages as $message)
                                <p class="mt-1.5 text-xs text-red-500" role="alert">
                                    {{ $message }}
                                </p>
                            @endforeach
                        @endforeach
                    </div>

                    <!-- Kecamatan (tabel wisata -> id_kecamatan) -->
                    <div class="md:col-span-2">
                        <x-searchable-select name="id_kecamatan" id="id_kecamatan" label="Kecamatan" :options="$kecamatan"
                            :selectedValue="old('id_kecamatan')" placeholder="Pilih Kecamatan" searchPlaceholder="Cari kecamatan..."
                            :required="true" />

                        {{-- Menampilkan Pesan Error Validasi Laravel --}}
                        @error('id_kecamatan')
                            <p class="mt-1.5 text-xs text-red-500" role="alert">
                                {{ $message }}
                            </p>
                        @enderror
                    </div>



                    <!-- Alamat Detail (tabel wisata -> alamat_Detail_wisata) -->
                    <div class="md:col-span-2">
                        <label class="block text-sm font-medium text-textPrimary mb-1.5">Alamat Detail <span
                                class="text-red-500">*</span></label>
                        <textarea name="alamat_detail_wisata" rows="2" placeholder="Masukkan alamat lengkap lokasi wisata..."
                            class="w-full px-3.5 py-2 bg-background border border-border rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 focus:ring-primary">{{ old('alamat_detail_wisata') }}</textarea>
                        @error('alamat_detail_wisata')
                            <p class="mt-1.5 text-xs text-red-500" role="alert">
                                {{ $message }}
                            </p>
                        @enderror
                    </div>

                    <!-- Latitude (tabel wisata -> latitude) -->
                    <div>
                        <label class="block text-sm font-medium text-textPrimary mb-1.5">Latitude <span
                                class="text-red-500">*</span></label>
                        <input type="number" step="any" name="latitude" value="{{ old('latitude') }}"
                            placeholder="Contoh: -7.60790000"
                            class="w-full px-3.5 py-2 bg-background border border-border rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 focus:ring-primary font-mono">
                        @error('latitude')
                            <p class="mt-1.5 text-xs text-red-500" role="alert">
                                {{ $message }}
                            </p>
                        @enderror
                    </div>

                    <!-- Longitude (tabel wisata -> longitude) -->
                    <div>
                        <label class="block text-sm font-medium text-textPrimary mb-1.5">Longitude <span
                                class="text-red-500">*</span></label>
                        <input type="number" step="any" name="longitude" value="{{ old('longitude') }}"
                            placeholder="Contoh: 110.20370000"
                            class="w-full px-3.5 py-2 bg-background border border-border rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 focus:ring-primary font-mono">
                        @error('longitude')
                            <p class="mt-1.5 text-xs text-red-500" role="alert">
                                {{ $message }}
                            </p>
                        @enderror
                    </div>

                    <!-- Link Google Maps (tabel wisata -> link_on_maps) -->
                    <div class="md:col-span-2">
                        <label class="block text-sm font-medium text-textPrimary mb-1.5">Link Google
                            Maps <span class="text-red-500">*</span></label>
                        <input type="url" name="link_on_maps" value="{{ old('link_on_maps') }}"
                            placeholder="https://goo.gl/maps/..."
                            class="w-full px-3.5 py-2 bg-background border border-border rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 focus:ring-primary">
                        @error('link_on_maps')
                            <p class="mt-1.5 text-xs text-red-500" role="alert">
                                {{ $message }}
                            </p>
                        @enderror
                    </div>

                    <!-- Harga Tiket Masuk (tabel wisata -> harga_tiket_masuk) -->
                    <div class="md:col-span-2">
                        <label class="block text-sm font-medium text-textPrimary mb-1.5">Harga Tiket Masuk
                            (Rp)</label>
                        <div class="relative">
                            <span
                                class="absolute inset-y-0 left-0 flex items-center pl-3.5 text-sm text-textSecondary font-medium">Rp</span>
                            <input type="number" name="harga_tiket_masuk" value="{{ old('harga_tiket_masuk') }}"
                                min="0" placeholder="50000"
                                class="w-full pl-11 pr-4 py-2 bg-background border border-border rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 focus:ring-primary">
                            @error('harga_tiket_masuk')
                                <p class="mt-1.5 text-xs text-red-500" role="alert">
                                    {{ $message }}
                                </p>
                            @enderror
                        </div>
                    </div>

                    <!-- Deskripsi (tabel wisata -> deskripsi) -->
                    <div class="md:col-span-2">
                        <label class="block text-sm font-medium text-textPrimary mb-1.5">Deskripsi
                            Destinasi</label>
                        <textarea name="deskripsi" rows="4" placeholder="Tuliskan deskripsi lengkap mengenai tempat wisata ini..."
                            class="w-full px-3.5 py-2 bg-background border border-border rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 focus:ring-primary">{{ old('deskripsi') }}</textarea>
                        @error('deskripsi')
                            <p class="mt-1.5 text-xs text-red-500" role="alert">
                                {{ $message }}
                            </p>
                        @enderror
                    </div>
                </div>
            </div>

            <!-- CONTAINER 2: Jam Operasional (tabel jam_operasi) -->
            <x-jam-operasional />


            <!-- CONTAINER 3: Foto Destinasi -->
            <div class="bg-white p-6 rounded-xl border border-border shadow-sm space-y-4" data-photo-upload>
                <h2 class="text-base font-bold text-textPrimary flex items-center">
                    <span class="w-2 h-5 bg-primary rounded-full mr-2"></span>
                    Foto Destinasi (Opsional)
                </h2>

                <p class="text-xs text-textSecondary">
                    Unggah beberapa foto pendukung untuk memperjelas visual lokasi wisata.
                </p>

                <!-- Area Drag and Drop -->
                <div data-dropzone role="button" tabindex="0"
                    class="border-2 border-dashed border-border rounded-xl p-6 text-center hover:border-primary transition bg-background cursor-pointer">
                    <div class="flex flex-col items-center justify-center space-y-2">
                        <div class="p-3 bg-white rounded-full shadow-sm border border-border text-primary">
                            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z">
                                </path>
                            </svg>
                        </div>

                        <div class="text-sm text-textPrimary font-medium">
                            Seret & letakkan foto di sini, atau
                            <span class="text-primary underline">pilih file</span>
                        </div>

                        <p class="text-xs text-textSecondary">
                            PNG, JPG, JPEG — maksimal 5 MB per gambar, maksimal 10 gambar.
                        </p>
                    </div>

                    <input type="file" name="foto_destinasi[]" accept=".png,.jpg,.jpeg,image/png,image/jpeg" multiple
                        class="hidden" data-file-input>
                </div>

                <!-- Pesan Validasi -->
                <div data-error class="hidden text-sm text-red-600" role="alert" aria-live="polite"></div>
                @if ($errors->has('foto_destinasi'))
                    <p class="text-sm text-red-600" role="alert">
                        {{ $errors->first('foto_destinasi') }}
                    </p>
                @endif

                @foreach ($errors->get('foto_destinasi.*') as $messages)
                    @foreach ($messages as $message)
                        <p class="text-sm text-red-600" role="alert">
                            {{ $message }}
                        </p>
                    @endforeach
                @endforeach
                <!-- Daftar Foto -->
                <div class="space-y-2 pt-2">
                    <label class="block text-xs font-semibold text-textSecondary uppercase tracking-wider">
                        Antrean Upload Foto
                    </label>

                    <div data-file-list class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                        <p data-empty
                            class="col-span-full text-sm text-textSecondary text-center py-4 border border-dashed border-border rounded-lg">
                            Belum ada foto yang dipilih.
                        </p>
                    </div>

                    <p data-upload-status class="text-xs text-textSecondary" aria-live="polite"></p>
                </div>
            </div>


        </form>
    </div>


    <script>
        document.addEventListener('DOMContentLoaded', () => {
            document.querySelectorAll('[data-photo-upload]').forEach((component) => {
                const dropzone = component.querySelector('[data-dropzone]');
                const input = component.querySelector('[data-file-input]');
                const fileList = component.querySelector('[data-file-list]');
                const emptyState = component.querySelector('[data-empty]');
                const errorBox = component.querySelector('[data-error]');
                const uploadStatus = component.querySelector('[data-upload-status]');

                const MAX_SIZE = 5 * 1024 * 1024;
                const MAX_FILES = 10;
                const ALLOWED_TYPES = ['image/jpeg', 'image/png'];

                let selectedFiles = [];
                let isSubmitting = false;

                const form = component.closest('form');

                if (!form) {
                    console.error('Komponen upload harus berada di dalam form.');
                    return;
                }

                if (!dropzone || !input || !fileList || !emptyState ||
                    !errorBox || !uploadStatus) {
                    console.error('Elemen komponen upload belum lengkap.');
                    return;
                }

                function formatSize(bytes) {
                    return bytes >= 1024 * 1024 ?
                        (bytes / (1024 * 1024)).toFixed(2) + ' MB' :
                        (bytes / 1024).toFixed(1) + ' KB';
                }

                function showError(messages = []) {
                    errorBox.textContent = messages.join(' ');
                    errorBox.classList.toggle('hidden', messages.length === 0);
                }

                // Sinkronkan file yang dipilih ke input HTML.
                function syncInputFiles() {
                    const transfer = new DataTransfer();

                    selectedFiles.forEach((item) => {
                        transfer.items.add(item.file);
                    });

                    input.files = transfer.files;
                }

                function renderFiles() {
                    fileList.querySelectorAll('[data-file-item]').forEach((item) => {
                        item.remove();
                    });

                    emptyState.classList.toggle('hidden', selectedFiles.length > 0);

                    selectedFiles.forEach((item) => {
                        const card = document.createElement('div');
                        card.dataset.fileItem = '';
                        card.className =
                            'flex items-center justify-between p-3 rounded-lg border border-border bg-white shadow-sm';

                        const left = document.createElement('div');
                        left.className = 'flex items-center space-x-3 overflow-hidden';

                        const thumbnail = document.createElement('img');
                        thumbnail.src = item.previewUrl;
                        thumbnail.alt = 'Preview ' + item.file.name;
                        thumbnail.className =
                            'w-12 h-12 rounded-md object-cover border border-border shrink-0';

                        const details = document.createElement('div');
                        details.className = 'min-w-0 truncate';

                        const filename = document.createElement('p');
                        filename.className =
                            'text-xs font-semibold text-textPrimary truncate';
                        filename.textContent = item.file.name;

                        const status = document.createElement('p');
                        status.className =
                            'text-[11px] text-emerald-600 font-medium mt-0.5';
                        status.textContent =
                            'Siap diunggah (' + formatSize(item.file.size) + ')';
                        status.dataset.fileStatus = '';

                        details.append(filename, status);
                        left.append(thumbnail, details);

                        const removeButton = document.createElement('button');
                        removeButton.type = 'button';
                        removeButton.className =
                            'p-1.5 text-slate-400 hover:text-red-600 transition shrink-0';
                        removeButton.title = 'Hapus foto';
                        removeButton.setAttribute(
                            'aria-label',
                            'Hapus ' + item.file.name
                        );
                        removeButton.innerHTML = `
                    <svg class="w-4 h-4" fill="none"
                        stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round"
                            stroke-linejoin="round" stroke-width="2"
                            d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16">
                        </path>
                    </svg>
                `;

                        removeButton.addEventListener('click', () => {
                            if (isSubmitting) return;

                            URL.revokeObjectURL(item.previewUrl);

                            selectedFiles = selectedFiles.filter(
                                (selected) => selected.id !== item.id
                            );

                            syncInputFiles();
                            renderFiles();
                            showError();

                            uploadStatus.textContent = selectedFiles.length ?
                                selectedFiles.length + ' dari ' + MAX_FILES +
                                ' foto dipilih.' :
                                '';
                        });

                        card.append(left, removeButton);
                        fileList.appendChild(card);
                    });

                    uploadStatus.textContent = selectedFiles.length ?
                        selectedFiles.length + ' dari ' + MAX_FILES + ' foto dipilih.' :
                        '';
                }

                function addFiles(files) {
                    if (isSubmitting) return;

                    const errors = [];

                    Array.from(files).forEach((file) => {
                        const duplicate = selectedFiles.some((item) =>
                            item.file.name === file.name &&
                            item.file.size === file.size &&
                            item.file.lastModified === file.lastModified
                        );

                        if (duplicate) {
                            errors.push(file.name + ': file sudah dipilih.');
                            return;
                        }

                        if (!ALLOWED_TYPES.includes(file.type)) {
                            errors.push(file.name + ': hanya JPG, JPEG, atau PNG.');
                            return;
                        }

                        if (file.size > MAX_SIZE) {
                            errors.push(file.name + ': ukuran melebihi 5 MB.');
                            return;
                        }

                        if (selectedFiles.length >= MAX_FILES) {
                            errors.push('Maksimal ' + MAX_FILES + ' gambar.');
                            return;
                        }

                        selectedFiles.push({
                            id: crypto.randomUUID(),
                            file,
                            previewUrl: URL.createObjectURL(file)
                        });
                    });

                    syncInputFiles();
                    renderFiles();
                    showError(errors);
                }

                // Buka file picker.
                dropzone.addEventListener('click', (event) => {
                    if (event.target.closest('button')) return;
                    if (!isSubmitting) input.click();
                });

                // Dukungan keyboard.
                dropzone.addEventListener('keydown', (event) => {
                    if (
                        (event.key === 'Enter' || event.key === ' ') &&
                        event.target === dropzone
                    ) {
                        event.preventDefault();
                        if (!isSubmitting) input.click();
                    }
                });

                // File yang dipilih dari komputer.
                input.addEventListener('change', () => {
                    addFiles(input.files);

                    // Kembalikan file input ke antrean yang telah disinkronkan.
                    // Antrean selectedFiles tetap menyimpan pilihan sebelumnya.
                    syncInputFiles();
                });

                // Drag and drop.
                ['dragenter', 'dragover'].forEach((eventName) => {
                    dropzone.addEventListener(eventName, (event) => {
                        event.preventDefault();

                        if (!isSubmitting) {
                            dropzone.classList.add('border-primary');
                        }
                    });
                });

                ['dragleave', 'drop'].forEach((eventName) => {
                    dropzone.addEventListener(eventName, (event) => {
                        event.preventDefault();
                        dropzone.classList.remove('border-primary');
                    });
                });

                dropzone.addEventListener('drop', (event) => {
                    if (isSubmitting) return;
                    addFiles(event.dataTransfer.files);
                });

                // Kirim foto bersama data form ke Laravel.
                form.addEventListener('submit', (event) => {
                    if (isSubmitting) {
                        event.preventDefault();
                        return;
                    }

                    // Pastikan antrean foto sudah masuk ke input sebelum submit.
                    syncInputFiles();

                    if (selectedFiles.length > MAX_FILES) {
                        event.preventDefault();
                        showError(['Maksimal ' + MAX_FILES + ' gambar.']);
                        return;
                    }

                    // Jangan menonaktifkan input file di sini.
                    // Input disabled tidak ikut dikirim dalam form.
                    console.log('Data form sebelum dikirim:');

                    const formData = new FormData(form);

                    for (const [key, value] of formData.entries()) {
                        if (value instanceof File) {
                            console.log(key, value.name, value.size, value.type);
                        } else {
                            console.log(key, value);
                        }
                    }

                    isSubmitting = true;

                    component.querySelectorAll('button').forEach((button) => {
                        button.disabled = true;
                    });

                    dropzone.classList.add('opacity-60', 'cursor-not-allowed');

                    fileList.querySelectorAll('[data-file-status]').forEach((status) => {
                        status.textContent = 'Dikirim bersama formulir...';
                        status.classList.remove('text-emerald-600');
                        status.classList.add('text-primary');
                    });

                    uploadStatus.textContent = selectedFiles.length ?
                        'Mengirim ' + selectedFiles.length + ' foto bersama data wisata...' :
                        'Mengirim data wisata tanpa foto.';
                });

                // Jika validasi browser menggagalkan submit, aktifkan kembali kontrol.
                form.addEventListener('invalid', () => {
                    isSubmitting = false;

                    component.querySelectorAll('button').forEach((button) => {
                        button.disabled = false;
                    });

                    dropzone.classList.remove('opacity-60', 'cursor-not-allowed');
                }, true);
            });
        });
    </script>

@endsection
