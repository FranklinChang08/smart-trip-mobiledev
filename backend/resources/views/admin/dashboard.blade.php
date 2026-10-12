@extends('layouts.admin')

@section('title', 'Dashboard')
@php
    $breadcrumb = 'Dashboard';
    $pageTitle  = 'Dashboard';
@endphp

@section('content')
    @if (session('success'))
        <div class="alert-success">
            <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
            </svg>
            <span>{{ session('success') }}</span>
        </div>
    @endif

    <!-- Kartu Selamat Datang -->
    <div class="card max-w-3xl">
        <div class="flex items-start gap-4">
            <div class="card-icon">
                <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8" d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z"></path>
                </svg>
            </div>
            <div>
                <h3 class="heading-lora text-xl font-bold text-dark">Selamat Datang</h3>
                <p class="text-sm text-gray mt-1">
                    Login berhasil. Anda masuk sebagai
                    <strong class="text-dark">{{ Auth::user()->name }}</strong>
                    ({{ Auth::user()->email }}).
                </p>
            </div>
        </div>

        <div class="mt-6 pt-6 border-top space-y-2">
            <p class="text-xs text-gray">Silakan gunakan menu di sidebar sebelah kiri untuk menavigasi:</p>
            <ul class="list-disc text-sm text-dark font-medium">
                <li><strong class="text-green">Dashboard:</strong> Halaman utama ringkasan admin.</li>
                <li><strong class="text-green">Data Wisata:</strong> Pengelolaan data destinasi wisata.</li>
                <li><strong class="text-green">Data Restoran:</strong> Pengelolaan data kuliner dan restoran wisata.</li>
            </ul>
        </div>
    </div>
@endsection
