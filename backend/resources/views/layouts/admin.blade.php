<!DOCTYPE html>
<html lang="id">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'Admin Dashboard') - SmartTrip</title>

    <link rel="stylesheet" href="{{ asset('css/admin.css') }}">
</head>

<body>

    <!-- A. Sidebar (Kiri) -->
    @include('layouts.admin.sidebar')

    <!-- B. Main Content Area -->
    <div class="layout-main">
        <!-- Topbar -->
        @include('layouts.admin.topbar')

        <!-- Main Body -->
        <main class="page-body">
            @yield('content')
        </main>
    </div>

</body>

</html>
