<!DOCTYPE html>
<html lang="id">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title', 'Admin Dashboard') - SmartTrip</title>

    @vite('resources/css/app.css')
</head>

<body class="min-h-screen flex bg-background text-textPrimary antialiased font-manrope">

    {{-- Floating Toast Notification --}}
    @include('components.notification')

    <!-- A. Sidebar (Kiri) -->
    @include('components.sidebar')

    <!-- B. Main Content Area -->
    <div class="flex flex-col flex-1 min-w-0">
        <!-- Topbar -->
        @include('components.topbar')

        <!-- Main Body -->
        <main class="p-8 flex-1">
            @yield('content')
        </main>
    </div>

</body>

</html>