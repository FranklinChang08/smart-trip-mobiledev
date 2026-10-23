{{-- Floating Compact Toast Notification System --}}
<div id="toast-container"
    style="position: fixed; top: 1.25rem; right: 1.25rem; z-index: 99999; max-width: 350px; width: calc(100% - 2.5rem); pointer-events: none; display: flex; flex-direction: column; gap: 0.75rem; align-items: flex-end;">

    @if (session('success'))
        <div class="toast-item bg-white rounded-xl shadow-lg border border-emerald-200 p-3 flex flex-col gap-1.5 transition-all duration-300 ease-out overflow-hidden relative"
            style="pointer-events: auto; width: 100%; box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.08), 0 8px 10px -6px rgba(0, 0, 0, 0.06);"
            role="alert">
            <div class="flex items-center gap-2.5">
                {{-- Icon --}}
                <div
                    class="w-7 h-7 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center shrink-0 border border-emerald-200">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7"></path>
                    </svg>
                </div>
                {{-- Text Content --}}
                <div class="flex-1 min-w-0">
                    <h3 class="text-xs font-bold text-gray-900 leading-tight">Berhasil!</h3>
                    <p class="text-[11px] text-gray-600 mt-0.5 leading-tight truncate" title="{{ session('success') }}">
                        {{ session('success') }}</p>
                </div>
                {{-- Close Button --}}
                <button type="button" onclick="dismissToast(this.closest('.toast-item'))"
                    class="text-gray-400 hover:text-gray-600 p-0.5 rounded-md hover:bg-gray-100 transition shrink-0 cursor-pointer"
                    title="Tutup">
                    <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12">
                        </path>
                    </svg>
                </button>
            </div>
            {{-- Slim Progress Timer Bar --}}
            <div class="w-full bg-emerald-100 h-0.5 rounded-full overflow-hidden">
                <div
                    class="toast-progress bg-emerald-500 h-full w-full rounded-full transition-all duration-[4000ms] ease-linear">
                </div>
            </div>
        </div>
    @endif

    @if (session('error'))
        <div class="toast-item bg-white rounded-xl shadow-lg border border-red-200 p-3 flex flex-col gap-1.5 transition-all duration-300 ease-out overflow-hidden relative"
            style="pointer-events: auto; width: 100%; box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.08), 0 8px 10px -6px rgba(0, 0, 0, 0.06);"
            role="alert">
            <div class="flex items-center gap-2.5">
                {{-- Icon --}}
                <div
                    class="w-7 h-7 rounded-lg bg-red-50 text-red-600 flex items-center justify-center shrink-0 border border-red-200">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.2"
                            d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z">
                        </path>
                    </svg>
                </div>
                {{-- Text Content --}}
                <div class="flex-1 min-w-0">
                    <h3 class="text-xs font-bold text-gray-900 leading-tight">Terjadi Kesalahan!</h3>
                    <p class="text-[11px] text-gray-600 mt-0.5 leading-tight truncate" title="{{ session('error') }}">
                        {{ session('error') }}</p>
                </div>
                {{-- Close Button --}}
                <button type="button" onclick="dismissToast(this.closest('.toast-item'))"
                    class="text-gray-400 hover:text-gray-600 p-0.5 rounded-md hover:bg-gray-100 transition shrink-0 cursor-pointer"
                    title="Tutup">
                    <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12">
                        </path>
                    </svg>
                </button>
            </div>
            {{-- Slim Progress Timer Bar --}}
            <div class="w-full bg-red-100 h-0.5 rounded-full overflow-hidden">
                <div
                    class="toast-progress bg-red-500 h-full w-full rounded-full transition-all duration-[4000ms] ease-linear">
                </div>
            </div>
        </div>
    @endif
</div>

<script>
    function dismissToast(el) {
        if (!el) return;
        el.style.opacity = '0';
        el.style.transform = 'translateX(100%)';
        setTimeout(() => {
            el.remove();
        }, 300);
    }

    document.addEventListener('DOMContentLoaded', function () {
        const toasts = document.querySelectorAll('.toast-item');
        toasts.forEach(toast => {
            const progress = toast.querySelector('.toast-progress');
            setTimeout(() => {
                if (progress) {
                    progress.style.width = '0%';
                }
            }, 50);

            setTimeout(() => {
                dismissToast(toast);
            }, 4000);
        });
    });

    window.showToast = function (type, message, title) {
        const container = document.getElementById('toast-container');
        if (!container) return;

        const isSuccess = type === 'success';
        const toast = document.createElement('div');
        toast.className = `toast-item bg-white rounded-xl shadow-lg ${isSuccess ? 'border border-emerald-200' : 'border border-red-200'} p-3 flex flex-col gap-1.5 transition-all duration-300 ease-out overflow-hidden relative`;
        toast.style.pointerEvents = 'auto';
        toast.style.width = '100%';
        toast.style.boxShadow = '0 10px 25px -5px rgba(0, 0, 0, 0.08), 0 8px 10px -6px rgba(0, 0, 0, 0.06)';
        toast.setAttribute('role', 'alert');

        const headerTitle = title || (isSuccess ? 'Berhasil!' : 'Terjadi Kesalahan!');
        const iconColor = isSuccess ? 'bg-emerald-50 text-emerald-600 border-emerald-200' : 'bg-red-50 text-red-600 border-red-200';
        const iconSvg = isSuccess
            ? '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7"></path></svg>'
            : '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path></svg>';

        toast.innerHTML = `
            <div class="flex items-center gap-2.5">
                <div class="w-7 h-7 rounded-lg ${iconColor} flex items-center justify-center shrink-0 border">
                    ${iconSvg}
                </div>
                <div class="flex-1 min-w-0">
                    <h3 class="text-xs font-bold text-gray-900 leading-tight">${headerTitle}</h3>
                    <p class="text-[11px] text-gray-600 mt-0.5 leading-tight truncate" title="${message}">${message}</p>
                </div>
                <button type="button" class="text-gray-400 hover:text-gray-600 p-0.5 rounded-md hover:bg-gray-100 transition shrink-0 cursor-pointer" title="Tutup">
                    <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                    </svg>
                </button>
            </div>
            <div class="w-full ${isSuccess ? 'bg-emerald-100' : 'bg-red-100'} h-0.5 rounded-full overflow-hidden">
                <div class="toast-progress ${isSuccess ? 'bg-emerald-500' : 'bg-red-500'} h-full w-full rounded-full transition-all duration-[4000ms] ease-linear"></div>
            </div>
        `;

        toast.querySelector('button').addEventListener('click', () => dismissToast(toast));
        container.appendChild(toast);

        const progress = toast.querySelector('.toast-progress');
        setTimeout(() => {
            if (progress) progress.style.width = '0%';
        }, 50);

        setTimeout(() => {
            dismissToast(toast);
        }, 4000);
    };
</script>