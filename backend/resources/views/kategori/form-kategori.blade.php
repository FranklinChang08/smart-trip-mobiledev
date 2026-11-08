@extends('layouts.admin')

@section('title',
    isset($kategoris) && $kategoris->exists
    ? 'Edit Data kategori'
    : 'Tambah Data
    kategori')

    @php
        $isEdit = isset($kategoris) && $kategoris && $kategoris->exists;
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

        <form action="{{ $isEdit ? route('admin.kategori.update', $kategoris->id_kategori) : route('admin.kategori.store') }}"
            method="POST" class="space-y-6" enctype="multipart/form-data">
            @csrf
            @if ($isEdit)
                @method('PUT')
            @endif

            {{-- Header form --}}
            <div class="flex flex-col gap-4 border-b border-border pb-4 sm:flex-row sm:items-center sm:justify-between">
                <div>
                    <h1 class="text-xl font-bold text-textPrimary">
                        {{ $isEdit ? 'Edit Tempat kategori' : 'Tambah Tempat kategori' }}
                    </h1>
                    <p class="text-sm text-textSecondary">
                        {{ $isEdit
                            ? 'Perbarui informasi destinasi kategori melalui formulir di bawah ini.'
                            : 'Lengkapi formulir di bawah ini untuk menambahkan data destinasi kategori baru.' }}
                    </p>
                </div>
                <div class="flex items-center space-x-3">
                    <a href="{{ route('admin.kategori.index') }}"
                        class="px-4 py-2 border border-border rounded-lg text-sm font-medium text-textSecondary bg-white hover:bg-slate-50 transition">
                        Batal
                    </a>
                    <button type="submit"
                        class="px-4 py-2 bg-primary text-white text-sm font-semibold rounded-lg hover:opacity-95 transition shadow-sm">
                        {{ $isEdit ? 'Perbarui Data kategori' : 'Simpan Data kategori' }}
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
                        <label for="nama_kategori" class="block text-sm font-medium text-textPrimary mb-1.5">
                            Nama kategori <span class="text-red-500">*</span>
                        </label>
                        <input id="nama_kategori" type="text" name="nama_kategori"
                            value="{{ old('nama_kategori', $kategoris->nama_kategori ?? '') }}"
                            placeholder="Contoh: Pantai Nongsa"
                            class="w-full px-3.5 py-2 bg-background border border-border rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 focus:ring-primary">
                        @error('nama_kategori')
                            <p class="mt-1.5 text-xs text-red-500" role="alert">{{ $message }}</p>
                        @enderror
                    </div>

                    <div class="md:col-span-2">
                        <x-simple-select name="jenis_kategori" id="jenis_kategori" label="Jenis kategori" :options="[
                            ['value' => 'wisata', 'label' => 'Wisata'],
                            ['value' => 'restoran', 'label' => 'Restoran'],
                            ['value' => 'penginapan', 'label' => 'Penginapan'],
                        ]"
                            :selected-value="old('jenis_kategori', $kategoris->jenis_kategori ?? '')" placeholder="Pilih jenis kategori..." :required="true" />

                        @error('jenis_kategori')
                            <p class="mt-1.5 text-xs text-red-500" role="alert">
                                {{ $message }}
                            </p>
                        @enderror
                    </div>

                </div>
            </div>

            <div class="flex justify-end gap-3">
                <a href="{{ route('admin.kategori.index') }}"
                    class="px-4 py-2 border border-border rounded-lg text-sm font-medium text-textSecondary bg-white hover:bg-slate-50 transition">Batal</a>
                <button type="submit"
                    class="px-4 py-2 bg-primary text-white text-sm font-semibold rounded-lg hover:opacity-95 transition shadow-sm">
                    {{ $isEdit ? 'Perbarui Data kategori' : 'Simpan Data kategori' }}
                </button>
            </div>
        </form>
    </div>

@endsection
