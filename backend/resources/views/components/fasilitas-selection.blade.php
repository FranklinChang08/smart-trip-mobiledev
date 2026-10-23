@props(['allFasilitas' => [], 'selectedFasilitas' => []])

<div class="bg-white p-6 rounded-xl border border-border shadow-sm space-y-4">
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-2 border-b border-border pb-3">
        <div>
            <h2 class="text-base font-bold text-textPrimary flex items-center">
                <span class="w-2 h-5 bg-[#934515] rounded-full mr-2"></span>
                Fasilitas Restoran (Opsional)
            </h2>
            <p class="text-xs text-textSecondary mt-0.5">
                Pilih fasilitas yang tersedia untuk memudahkan pengunjung. Anda juga dapat menambahkan fasilitas baru.
            </p>
        </div>
        <span class="text-xs text-textSecondary font-medium" id="selected-fasilitas-count">
            {{ count($selectedFasilitas) }} fasilitas dipilih
        </span>
    </div>

    {{-- Form Tambah Fasilitas Baru --}}
    <div class="space-y-1.5 pt-1">
        <label for="new-fasilitas-input" class="block text-xs font-semibold text-textSecondary uppercase tracking-wider">
            Tambah Fasilitas Baru
        </label>
        <div class="flex items-center gap-2">
            <div class="relative flex-1">
                <input type="text" id="new-fasilitas-input"
                    placeholder="Ketik fasilitas baru jika belum ada di daftar (contoh: Area Bermain Anak)..."
                    class="w-full px-3.5 py-2 bg-background border border-border rounded-lg text-xs md:text-sm text-textPrimary focus:outline-none focus:ring-2 focus:ring-[#934515]">
            </div>
            <button type="button" id="btn-add-fasilitas"
                class="px-4 py-2 bg-[#934515] hover:bg-[#7D3A11] text-white text-xs md:text-sm font-semibold rounded-lg transition shadow-sm shrink-0 flex items-center gap-1.5 cursor-pointer">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
                </svg>
                Tambah
            </button>
        </div>
        <p id="fasilitas-feedback" class="text-xs hidden" role="alert"></p>
    </div>

    {{-- Daftar Fasilitas (Grid Checkbox) --}}
    <div class="space-y-1.5 pt-2">
        <label class="block text-xs font-semibold text-textSecondary uppercase tracking-wider">
            Daftar Fasilitas Tersedia
        </label>
        <div id="fasilitas-grid" class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-2.5">
            @forelse($allFasilitas as $item)
                <label class="fasilitas-item relative flex items-center gap-2.5 p-3 rounded-xl border border-border bg-slate-50 cursor-pointer hover:bg-slate-100 transition has-[:checked]:bg-[#934515]/10 has-[:checked]:border-[#934515] has-[:checked]:text-[#934515] has-[:checked]:font-semibold">
                    <input type="checkbox" name="fasilitas[]" value="{{ $item->id_fasilitas }}"
                        {{ in_array($item->id_fasilitas, (array)$selectedFasilitas) ? 'checked' : '' }}
                        class="fasilitas-checkbox w-4 h-4 rounded border-border text-[#934515] focus:ring-[#934515] accent-[#934515] cursor-pointer">
                    <span class="text-xs md:text-sm text-textPrimary select-none truncate" title="{{ $item->nama_fasilitas }}">
                        {{ $item->nama_fasilitas }}
                    </span>
                </label>
            @empty
                <p class="col-span-full text-xs text-textSecondary italic text-center py-4">
                    Belum ada data fasilitas. Tambahkan fasilitas melalui input di atas.
                </p>
            @endforelse
        </div>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        const container = document.getElementById('fasilitas-grid');
        const input = document.getElementById('new-fasilitas-input');
        const addBtn = document.getElementById('btn-add-fasilitas');
        const feedback = document.getElementById('fasilitas-feedback');
        const countLabel = document.getElementById('selected-fasilitas-count');

        function updateCount() {
            if (!container) return;
            const checked = container.querySelectorAll('.fasilitas-checkbox:checked').length;
            if (countLabel) {
                countLabel.textContent = `${checked} fasilitas dipilih`;
            }
        }

        if (container) {
            container.addEventListener('change', function (e) {
                if (e.target && e.target.classList.contains('fasilitas-checkbox')) {
                    updateCount();
                }
            });
        }

        function showFeedback(msg, isSuccess) {
            if (!feedback) return;
            feedback.textContent = msg;
            feedback.className = `text-xs ${isSuccess ? 'text-emerald-600' : 'text-red-500'}`;
            feedback.classList.remove('hidden');
            setTimeout(() => {
                feedback.classList.add('hidden');
            }, 3500);
        }

        async function addNewFasilitas() {
            if (!input || !container) return;
            const val = input.value.trim();
            if (!val) {
                showFeedback('Nama fasilitas tidak boleh kosong.', false);
                return;
            }

            const exists = Array.from(container.querySelectorAll('.fasilitas-item span')).some(
                span => span.textContent.trim().toLowerCase() === val.toLowerCase()
            );
            if (exists) {
                showFeedback('Fasilitas tersebut sudah ada dalam daftar.', false);
                return;
            }

            if (addBtn) {
                addBtn.disabled = true;
                addBtn.classList.add('opacity-75');
            }

            try {
                const csrfMeta = document.querySelector('meta[name="csrf-token"]');
                const csrfToken = csrfMeta ? csrfMeta.content : '';

                const res = await fetch('{{ route("admin.fasilitas.store") }}', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json',
                        'X-CSRF-TOKEN': csrfToken
                    },
                    body: JSON.stringify({ nama_fasilitas: val })
                });

                const data = await res.json();
                if (!res.ok) {
                    throw new Error(data.message || 'Gagal menambahkan fasilitas.');
                }

                const newId = data.fasilitas.id;
                const newName = data.fasilitas.nama_fasilitas;

                // Buat elemen baru dan langsung centang
                const label = document.createElement('label');
                label.className = 'fasilitas-item relative flex items-center gap-2.5 p-3 rounded-xl border border-border bg-slate-50 cursor-pointer hover:bg-slate-100 transition has-[:checked]:bg-[#934515]/10 has-[:checked]:border-[#934515] has-[:checked]:text-[#934515] has-[:checked]:font-semibold';
                label.innerHTML = `
                    <input type="checkbox" name="fasilitas[]" value="${newId}" checked
                        class="fasilitas-checkbox w-4 h-4 rounded border-border text-[#934515] focus:ring-[#934515] accent-[#934515] cursor-pointer">
                    <span class="text-xs md:text-sm text-textPrimary select-none truncate" title="${newName}">
                        ${newName}
                    </span>
                `;

                container.appendChild(label);
                input.value = '';
                showFeedback('Fasilitas berhasil ditambahkan dan dipilih!', true);
                updateCount();
            } catch (err) {
                showFeedback(err.message, false);
            } finally {
                if (addBtn) {
                    addBtn.disabled = false;
                    addBtn.classList.remove('opacity-75');
                }
            }
        }

        if (addBtn) {
            addBtn.addEventListener('click', addNewFasilitas);
        }
        if (input) {
            input.addEventListener('keydown', function (e) {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    addNewFasilitas();
                }
            });
        }
    });
</script>