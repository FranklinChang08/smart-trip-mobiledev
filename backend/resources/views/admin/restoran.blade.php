@extends('layouts.admin')

@section('title', 'Data Restoran')
@php
    $breadcrumb = 'Data Restoran';
    $pageTitle  = 'Data Restoran';
@endphp

@section('content')
    <div class="card max-w-3xl">
        <div class="flex items-start gap-4">
            <div class="card-icon">
                <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"></path>
                </svg>
            </div>
            <div>
                <h3 class="heading-lora text-xl font-bold text-dark">Kelola Data Restoran &amp; Kuliner</h3>
                <p class="text-sm text-gray mt-1">
                    Halaman ini digunakan untuk mengelola data tempat makan dan rekomendasi kuliner wisatawan.
                </p>
            </div>
        </div>
    </div>
@endsection
