<!DOCTYPE html>
<html lang="id">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>SmartTrip - Login Admin</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link
        href="https://fonts.googleapis.com/css2?family=Lora:ital,wght@0,600;0,700;1,600&family=Manrope:wght@400;500;600;700;800&display=swap"
        rel="stylesheet">

    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: {
                        lora: ['"Lora"', 'serif'],
                        manrope: ['"Manrope"', 'sans-serif'],
                        sans: ['"Manrope"', 'sans-serif'],
                    },
                    colors: {
                        app: {
                            primary: '#00685F',
                            secondary: '#0369A1',
                            tertiary: '#F97316',
                            background: '#F8FAFC',
                            textPrimary: '#111827',
                            textSecondary: '#6B7280',
                            border: '#E5E7EB',
                        }
                    }
                }
            }
        }
    </script>

    <style>
        body {
            font-family: 'Manrope', sans-serif;
            background-color: #F8FAFC;
            color: #111827;
        }

        .heading-lora {
            font-family: 'Lora', serif;
        }

        .input-field {
            transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
        }

        .input-field:focus {
            border-color: #00685F !important;
            box-shadow: 0 0 0 3px rgba(0, 104, 95, 0.12);
            outline: none;
        }

        .input-error {
            border-color: #DC2626 !important;
        }

        .input-error:focus {
            border-color: #DC2626 !important;
            box-shadow: 0 0 0 3px rgba(220, 38, 38, 0.12) !important;
        }

        .btn-login {
            background-color: #F97316;
            transition: all 0.2s ease;
        }

        .btn-login:hover {
            background-color: #EA580C;
            box-shadow: 0 4px 14px rgba(249, 115, 22, 0.28);
        }

        .btn-login:active {
            transform: scale(0.99);
        }
    </style>
</head>

<body
    class="min-h-screen flex items-center justify-center p-4 sm:p-6 bg-slate-50 selection:bg-teal-600 selection:text-white">

    <div class="w-full max-w-md bg-white rounded-2xl sm:rounded-3xl border border-gray-200/90 shadow-sm p-6 sm:p-8">

        <!-- Logo & Header -->
        <div class="flex flex-col items-center">
            <div class="relative flex flex-col items-center mb-4">
                <div
                    class="w-28 h-28 rounded-full bg-white shadow-lg shadow-black/5 border border-gray-100 flex items-center justify-center p-4">
                    <img src="{{ asset('images/logo_smarttrip.png') }}" alt="SmartTrip Logo"
                        class="w-full h-full object-contain">
                </div>

                <div
                    class="-mt-3 bg-white px-3 py-1 rounded-full border-[1.2px] border-[#111827] shadow-sm flex items-center gap-1.5 z-10">
                    <span class="w-1 h-2.5 rounded-sm bg-[#111827]"></span>
                    <span class="text-[10px] font-bold tracking-tight text-[#111827]">
                        1.1301° N, 104.0529° E
                    </span>
                </div>
            </div>

            <div class="text-center mt-1 mb-6">
                <h1 class="heading-lora text-2xl font-bold text-[#111827] leading-snug">
                    Selamat Datang, Admin
                </h1>
                <p class="text-xs text-[#6B7280] font-medium mt-1.5">
                    Masuk untuk mengelola data destinasi SmartTrip
                </p>
            </div>
        </div>

        <!-- Feedback Messages (Success / Status) -->
        @if (session('status'))
            <div class="mb-4 p-3.5 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-xs flex items-center gap-2">
                <svg class="w-4 h-4 text-emerald-600 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                </svg>
                <span>{{ session('status') }}</span>
            </div>
        @endif

        @if (session('success'))
            <div class="mb-4 p-3.5 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-xs flex items-center gap-2">
                <svg class="w-4 h-4 text-emerald-600 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                </svg>
                <span>{{ session('success') }}</span>
            </div>
        @endif

        @if (session('error'))
            <div class="mb-4 p-3.5 rounded-xl bg-red-50 border border-red-200 text-red-700 text-xs flex items-center gap-2">
                <svg class="w-4 h-4 text-red-500 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                </svg>
                <span>{{ session('error') }}</span>
            </div>
        @endif

        <!-- Form Login (novalidate digunakan untuk mematikan tooltip bawaan browser 'Please fill out this field') -->
        <form action="{{ route('admin.login.submit') }}" method="POST" id="loginForm" class="space-y-4" novalidate>
            @csrf

            <!-- Input Alamat Email -->
            <div>
                <label for="email" class="block text-sm font-semibold text-[#111827] mb-2">
                    Alamat Email
                </label>
                <div class="relative">
                    <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-gray-400">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8"
                                d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z">
                            </path>
                        </svg>
                    </div>
                    <input type="text" id="email" name="email" value="{{ old('email') }}" autofocus
                        placeholder="nama@email.com"
                        class="input-field w-full pl-11 pr-4 py-3 rounded-xl bg-white border {{ $errors->has('email') ? 'input-error' : 'border-gray-300' }} text-sm text-[#111827] placeholder-gray-400 font-sans">
                </div>
                <p id="emailError" class="text-xs text-[#DC2626] mt-1.5 ml-1 font-medium {{ $errors->has('email') ? '' : 'hidden' }}">
                    {{ $errors->first('email') }}
                </p>
            </div>

            <!-- Input Kata Sandi -->
            <div>
                <label for="password" class="block text-sm font-semibold text-[#111827] mb-2">
                    Kata Sandi
                </label>
                <div class="relative">
                    <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-gray-400">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8"
                                d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z">
                            </path>
                        </svg>
                    </div>
                    <input type="password" id="password" name="password" placeholder="Masukkan kata sandi"
                        class="input-field w-full pl-11 pr-11 py-3 rounded-xl bg-white border {{ $errors->has('password') ? 'input-error' : 'border-gray-300' }} text-sm text-[#111827] placeholder-gray-400 font-sans">
                    <!-- Tombol Hide Password -->
                    <button type="button" id="togglePasswordBtn"
                        class="absolute inset-y-0 right-0 pr-3.5 flex items-center text-gray-400 hover:text-gray-600 focus:outline-none"
                        title="Tampilkan / Sembunyikan Kata Sandi">
                        <svg id="eyeIcon" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8"
                                d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8"
                                d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z">
                            </path>
                        </svg>
                        <svg id="eyeOffIcon" class="w-5 h-5 hidden" fill="none" stroke="currentColor"
                            viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8"
                                d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l18 18">
                            </path>
                        </svg>
                    </button>
                </div>
                <p id="passwordError" class="text-xs text-[#DC2626] mt-1.5 ml-1 font-medium {{ $errors->has('password') ? '' : 'hidden' }}">
                    {{ $errors->first('password') }}
                </p>
            </div>

            <!-- Tombol login -->
            <div class="pt-2">
                <button type="submit" id="submitBtn"
                    class="btn-login w-full h-12 rounded-[10px] text-white font-bold text-[15px] flex items-center justify-center gap-2 shadow-sm">
                    <span id="btnText" class="flex items-center gap-2">
                        <span>Login</span>
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.2"
                                d="M14 5l7 7m0 0l-7 7m7-7H3"></path>
                        </svg>
                    </span>
                    <span id="btnLoading" class="hidden items-center gap-2">
                        <svg class="animate-spin h-4 w-4 text-white" fill="none" viewBox="0 0 24 24">
                            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4">
                            </circle>
                            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8H4z"></path>
                        </svg>
                        <span>Memproses...</span>
                    </span>
                </button>
            </div>
        </form>

    </div>

    <!-- Script Tampilkan / Sembunyikan Password & Validasi Form -->
    <script>
        const toggleBtn = document.getElementById('togglePasswordBtn');
        const passwordInput = document.getElementById('password');
        const eyeIcon = document.getElementById('eyeIcon');
        const eyeOffIcon = document.getElementById('eyeOffIcon');

        toggleBtn.addEventListener('click', () => {
            const isPassword = passwordInput.type === 'password';
            passwordInput.type = isPassword ? 'text' : 'password';
            eyeIcon.classList.toggle('hidden', isPassword);
            eyeOffIcon.classList.toggle('hidden', !isPassword);
        });

        const form = document.getElementById('loginForm');
        const emailInput = document.getElementById('email');
        const emailError = document.getElementById('emailError');
        const passwordError = document.getElementById('passwordError');
        const submitBtn = document.getElementById('submitBtn');
        const btnText = document.getElementById('btnText');
        const btnLoading = document.getElementById('btnLoading');

        // Bersihkan pesan error saat user mulai mengetik
        emailInput.addEventListener('input', () => {
            emailInput.classList.remove('input-error');
            emailError.textContent = '';
            emailError.classList.add('hidden');
        });

        passwordInput.addEventListener('input', () => {
            passwordInput.classList.remove('input-error');
            passwordError.textContent = '';
            passwordError.classList.add('hidden');
        });

        // Validasi saat form disubmit
        form.addEventListener('submit', (e) => {
            let hasError = false;

            const emailVal = emailInput.value.trim();
            const passwordVal = passwordInput.value;

            if (!emailVal) {
                emailInput.classList.add('input-error');
                emailError.textContent = 'Alamat email wajib diisi';
                emailError.classList.remove('hidden');
                hasError = true;
            } else {
                emailInput.classList.remove('input-error');
                emailError.classList.add('hidden');
            }

            if (!passwordVal) {
                passwordInput.classList.add('input-error');
                passwordError.textContent = 'Kata sandi wajib diisi';
                passwordError.classList.remove('hidden');
                hasError = true;
            } else {
                passwordInput.classList.remove('input-error');
                passwordError.classList.add('hidden');
            }

            if (hasError) {
                e.preventDefault();
                // Fokus pada field pertama yang kosong
                if (!emailVal) {
                    emailInput.focus();
                } else if (!passwordVal) {
                    passwordInput.focus();
                }
                return false;
            }

            // Jika validasi client lolos, tampilkan indikator loading
            btnText.classList.add('hidden');
            btnLoading.classList.remove('hidden');
            btnLoading.classList.add('flex');
            submitBtn.disabled = true;
        });
    </script>

</body>

</html>
