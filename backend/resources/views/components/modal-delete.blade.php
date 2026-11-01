{{-- Modal Konfirmasi Hapus Data Modern & Universal --}}
<div id="delete-confirmation-modal"
    class="fixed inset-0 z-[99999] flex items-center justify-center p-4 bg-slate-900/40 backdrop-blur-xs transition-opacity duration-200 hidden"
    role="dialog" aria-modal="true" aria-labelledby="delete-modal-title">

    {{-- Modal Box Card --}}
    <div id="delete-modal-card"
        class="bg-white rounded-2xl max-w-sm w-full p-6 text-center shadow-2xl border border-slate-100 transform transition-all duration-200 scale-95 opacity-0">

        {{-- Icon Peringatan Merah --}}
        <div class="w-14 h-14 mx-auto mb-4 rounded-full bg-red-50 text-red-500 border border-red-100 flex items-center justify-center shadow-xs">
            <svg class="w-7 h-7" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                    d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16">
                </path>
            </svg>
        </div>

        {{-- Judul Modal --}}
        <h3 class="text-lg font-bold text-slate-900 tracking-tight" id="delete-modal-title">
            Konfirmasi Hapus Data
        </h3>

        {{-- Deskripsi Pesan --}}
        <p class="text-sm text-slate-500 mt-2 leading-relaxed" id="delete-modal-desc">
            Apakah Anda yakin ingin menghapus data ini?
        </p>

        {{-- Tombol Aksi --}}
        <div class="mt-6 flex items-center gap-3">
            <button type="button" onclick="closeDeleteModal()"
                class="flex-1 py-2.5 px-4 rounded-xl border border-slate-200 text-slate-700 font-semibold text-sm hover:bg-slate-50 active:bg-slate-100 transition cursor-pointer">
                Batal
            </button>
            <button type="button" id="confirm-delete-btn"
                class="flex-1 py-2.5 px-4 rounded-xl bg-red-600 hover:bg-red-700 active:bg-red-800 text-white font-semibold text-sm shadow-sm transition flex items-center justify-center gap-1.5 cursor-pointer">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                </svg>
                <span>Ya, Hapus</span>
            </button>
        </div>
    </div>
</div>

<script>
    (function () {
        let currentDeleteAction = null;

        window.confirmDelete = function (eventOrAction, targetForm, itemName = '', customMessage = '') {
            let form = null;
            let callback = null;

            if (typeof eventOrAction === 'function') {
                callback = eventOrAction;
                itemName = targetForm || '';
            } else if (eventOrAction && typeof eventOrAction.preventDefault === 'function') {
                eventOrAction.preventDefault();
                eventOrAction.stopPropagation();

                if (targetForm && targetForm.tagName === 'FORM') {
                    form = targetForm;
                } else if (eventOrAction.target && eventOrAction.target.tagName === 'FORM') {
                    form = eventOrAction.target;
                } else if (eventOrAction.target && eventOrAction.target.closest) {
                    form = eventOrAction.target.closest('form');
                }
            } else if (eventOrAction && eventOrAction.tagName === 'FORM') {
                form = eventOrAction;
                itemName = targetForm || '';
            }

            currentDeleteAction = { form, callback };

            const modal = document.getElementById('delete-confirmation-modal');
            const card = document.getElementById('delete-modal-card');
            const descEl = document.getElementById('delete-modal-desc');
            const confirmBtn = document.getElementById('confirm-delete-btn');

            if (descEl) {
                if (customMessage) {
                    descEl.innerHTML = customMessage;
                } else if (itemName) {
                    descEl.innerHTML = `Apakah Anda yakin ingin menghapus <strong class="text-slate-800 font-semibold">"${itemName}"</strong>?`;
                } else {
                    descEl.innerHTML = 'Apakah Anda yakin ingin menghapus data ini?';
                }
            }

            if (confirmBtn) {
                confirmBtn.disabled = false;
                confirmBtn.innerHTML = `
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                            d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                    </svg>
                    <span>Ya, Hapus</span>
                `;
            }

            if (modal && card) {
                modal.classList.remove('hidden');
                void modal.offsetWidth; // Force reflow
                card.classList.remove('scale-95', 'opacity-0');
                card.classList.add('scale-100', 'opacity-100');
            }

            return false;
        };

        window.closeDeleteModal = function () {
            const modal = document.getElementById('delete-confirmation-modal');
            const card = document.getElementById('delete-modal-card');
            if (!modal || !card) return;

            card.classList.remove('scale-100', 'opacity-100');
            card.classList.add('scale-95', 'opacity-0');
            setTimeout(() => {
                modal.classList.add('hidden');
                currentDeleteAction = null;
            }, 150);
        };

        document.addEventListener('DOMContentLoaded', function () {
            const modal = document.getElementById('delete-confirmation-modal');
            const confirmBtn = document.getElementById('confirm-delete-btn');

            if (modal) {
                modal.addEventListener('click', function (e) {
                    if (e.target === modal) {
                        closeDeleteModal();
                    }
                });
            }

            document.addEventListener('keydown', function (e) {
                if (e.key === 'Escape' && modal && !modal.classList.contains('hidden')) {
                    closeDeleteModal();
                }
            });

            if (confirmBtn) {
                confirmBtn.addEventListener('click', function () {
                    if (!currentDeleteAction) return;

                    confirmBtn.disabled = true;
                    confirmBtn.innerHTML = `
                        <svg class="animate-spin h-4 w-4 text-white inline-block" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                        </svg>
                        <span>Menghapus...</span>
                    `;

                    if (currentDeleteAction.callback) {
                        const cb = currentDeleteAction.callback;
                        closeDeleteModal();
                        cb();
                    } else if (currentDeleteAction.form) {
                        currentDeleteAction.form.submit();
                    }
                });
            }
        });
    })();
</script>

