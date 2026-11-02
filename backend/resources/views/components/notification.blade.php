{{-- Floating Notification System Matching Frontend AppNotification --}}
<div id="toast-container"
    class="fixed top-3 right-4 z-[99999] pointer-events-none flex flex-col gap-3 items-end max-w-[380px] w-[calc(100%-2rem)]">

    @if (session('success'))
        @php
            $successTitle = session('success_title');
            if (!$successTitle) {
                $successTitle = \Illuminate\Support\Str::contains(session('success'), ['Selamat datang', 'login', 'Login'])
                    ? 'Login Berhasil'
                    : 'Berhasil';
            }
        @endphp
        <div class="toast-item bg-white rounded-2xl p-3 px-3.5 flex items-center gap-3 transition-all duration-300 ease-out relative cursor-pointer font-manrope pointer-events-auto w-full"
            style="border: 1.2px solid rgba(0, 104, 95, 0.25); box-shadow: 0 6px 16px rgba(0, 104, 95, 0.12), 0 2px 6px rgba(0, 0, 0, 0.05); transform: translateY(-20px); opacity: 0;"
            role="alert" onclick="dismissToast(this)">
            {{-- Circular Icon Badge --}}
            <div class="w-[38px] h-[38px] rounded-full flex items-center justify-center shrink-0"
                style="background-color: rgba(0, 104, 95, 0.12); color: #00685F;">
                <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd"
                        d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                        clip-rule="evenodd" />
                </svg>
            </div>

            {{-- Text Content --}}
            <div class="flex-1 min-w-0">
                <h3 class="text-[13.5px] font-bold text-[#111827] leading-tight">
                    {{ $successTitle }}
                </h3>
                <p class="text-xs text-[#6B7280] font-medium mt-0.5 leading-snug line-clamp-2" title="{{ session('success') }}">
                    {{ session('success') }}
                </p>
            </div>

            {{-- Close Button --}}
            <button type="button" onclick="event.stopPropagation(); dismissToast(this.closest('.toast-item'))"
                class="text-gray-400 hover:text-gray-600 p-1 rounded-md transition shrink-0 cursor-pointer"
                title="Tutup">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.2" d="M6 18L18 6M6 6l12 12"></path>
                </svg>
            </button>
        </div>
    @endif

    @if (session('error'))
        <div class="toast-item bg-white rounded-2xl p-3 px-3.5 flex items-center gap-3 transition-all duration-300 ease-out relative cursor-pointer font-manrope pointer-events-auto w-full"
            style="border: 1.2px solid rgba(220, 38, 38, 0.25); box-shadow: 0 6px 16px rgba(220, 38, 38, 0.12), 0 2px 6px rgba(0, 0, 0, 0.05); transform: translateY(-20px); opacity: 0;"
            role="alert" onclick="dismissToast(this)">
            {{-- Circular Icon Badge --}}
            <div class="w-[38px] h-[38px] rounded-full flex items-center justify-center shrink-0"
                style="background-color: rgba(220, 38, 38, 0.12); color: #DC2626;">
                <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd"
                        d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z"
                        clip-rule="evenodd" />
                </svg>
            </div>

            {{-- Text Content --}}
            <div class="flex-1 min-w-0">
                <h3 class="text-[13.5px] font-bold text-[#111827] leading-tight">
                    {{ session('error_title') ?? 'Gagal' }}
                </h3>
                <p class="text-xs text-[#6B7280] font-medium mt-0.5 leading-snug line-clamp-2" title="{{ session('error') }}">
                    {{ session('error') }}
                </p>
            </div>

            {{-- Close Button --}}
            <button type="button" onclick="event.stopPropagation(); dismissToast(this.closest('.toast-item'))"
                class="text-gray-400 hover:text-gray-600 p-1 rounded-md transition shrink-0 cursor-pointer"
                title="Tutup">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.2" d="M6 18L18 6M6 6l12 12"></path>
                </svg>
            </button>
        </div>
    @endif
</div>

<script>
    function showToastElement(el) {
        if (!el) return;
        requestAnimationFrame(() => {
            el.style.transform = 'translateY(0)';
            el.style.opacity = '1';
        });
    }

    function dismissToast(el) {
        if (!el) return;
        el.style.transform = 'translateY(-20px)';
        el.style.opacity = '0';
        setTimeout(() => {
            el.remove();
        }, 300);
    }

    document.addEventListener('DOMContentLoaded', function () {
        const toasts = document.querySelectorAll('.toast-item');
        toasts.forEach(toast => {
            showToastElement(toast);
            setTimeout(() => {
                dismissToast(toast);
            }, 3200);
        });
    });

    window.showToast = function (type, message, title) {
        const container = document.getElementById('toast-container');
        if (!container) return;

        const isSuccess = type === 'success';
        const isWarning = type === 'warning';

        let badgeBg, badgeColor, borderColor, shadowColor, defaultTitle, iconSvg;

        if (isSuccess) {
            badgeBg = 'rgba(0, 104, 95, 0.12)';
            badgeColor = '#00685F';
            borderColor = 'rgba(0, 104, 95, 0.25)';
            shadowColor = 'rgba(0, 104, 95, 0.12)';
            defaultTitle = 'Berhasil';
            iconSvg = `<svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/></svg>`;
        } else if (isWarning) {
            badgeBg = 'rgba(245, 158, 11, 0.12)';
            badgeColor = '#F59E0B';
            borderColor = 'rgba(245, 158, 11, 0.25)';
            shadowColor = 'rgba(245, 158, 11, 0.12)';
            defaultTitle = 'Peringatan';
            iconSvg = `<svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/></svg>`;
        } else {
            badgeBg = 'rgba(220, 38, 38, 0.12)';
            badgeColor = '#DC2626';
            borderColor = 'rgba(220, 38, 38, 0.25)';
            shadowColor = 'rgba(220, 38, 38, 0.12)';
            defaultTitle = 'Gagal';
            iconSvg = `<svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/></svg>`;
        }

        const toast = document.createElement('div');
        toast.className = 'toast-item bg-white rounded-2xl p-3 px-3.5 flex items-center gap-3 transition-all duration-300 ease-out relative cursor-pointer font-manrope pointer-events-auto w-full';
        toast.style.cssText = `border: 1.2px solid ${borderColor}; box-shadow: 0 6px 16px ${shadowColor}, 0 2px 6px rgba(0, 0, 0, 0.05); transform: translateY(-20px); opacity: 0;`;
        toast.setAttribute('role', 'alert');

        toast.innerHTML = `
            <div class="w-[38px] h-[38px] rounded-full flex items-center justify-center shrink-0" style="background-color: ${badgeBg}; color: ${badgeColor};">
                ${iconSvg}
            </div>
            <div class="flex-1 min-w-0">
                <h3 class="text-[13.5px] font-bold text-[#111827] leading-tight">${title || defaultTitle}</h3>
                <p class="text-xs text-[#6B7280] font-medium mt-0.5 leading-snug line-clamp-2" title="${message}">${message}</p>
            </div>
            <button type="button" class="close-btn text-gray-400 hover:text-gray-600 p-1 rounded-md transition shrink-0 cursor-pointer" title="Tutup">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.2" d="M6 18L18 6M6 6l12 12"></path></svg>
            </button>
        `;

        toast.addEventListener('click', () => dismissToast(toast));
        const closeBtn = toast.querySelector('.close-btn');
        if (closeBtn) {
            closeBtn.addEventListener('click', (e) => {
                e.stopPropagation();
                dismissToast(toast);
            });
        }

        container.appendChild(toast);
        showToastElement(toast);

        setTimeout(() => {
            dismissToast(toast);
        }, 3200);
    };
</script>
