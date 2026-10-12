@extends('layouts.admin')

@section('title', 'Data Wisata')
@php
    $breadcrumb = 'Data Wisata';
    $pageTitle  = 'Data Wisata';
@endphp

@section('content')
    <div class="card max-w-3xl">
        <div class="flex items-start gap-4">
            <div class="card-icon">
                <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path>
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path>
                </svg>
            </div>
            <div>
                <h3 class="heading-lora text-xl font-bold text-dark">Kelola Data Destinasi Wisata</h3>
                <p class="text-sm text-gray mt-1">
                    Halaman ini digunakan untuk mengelola data tempat wisata, rute, dan kategori destinasi SmartTrip.
                </p>
            </div>
        </div>
    </div>
@endsection
