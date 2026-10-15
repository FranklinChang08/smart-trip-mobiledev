@props([
    'name' => 'items',
    'label' => 'Pilih Data',
    'placeholder' => 'Pilih Opsi',
    'searchPlaceholder' => 'Cari atau tambah baru...',
    'initialOptions' => [],
    'selectedValues' => [],
    'allowAdd' => true,
])

@php
    $componentId = 'multi-select-' . uniqid();
@endphp

<div class="w-full space-y-2 relative" id="{{ $componentId }}" data-options='@json($initialOptions)'
    data-selected='@json($selectedValues)'>

    <!-- Label -->
    @if ($label)
        <label class="block text-sm font-medium text-textPrimary mb-1.5">
            {{ $label }} <span class="text-red-500">*</span>
        </label>
    @endif

    <!-- Container untuk Hidden Inputs (Otomatis dikirim via Form Laravel tanpa JS submit) -->
    <div class="hidden-inputs-container"></div>

    <!-- Dropdown Trigger Container -->
    <div class="relative">
        <div
            class="dropdown-trigger w-full px-3.5 py-2 bg-background border border-border rounded-lg text-sm text-textPrimary flex items-center justify-between cursor-pointer focus:outline-none focus:ring-2 focus:ring-primary">
            <span class="selected-label truncate">{{ $placeholder }}</span>
            <svg class="dropdown-arrow w-4 h-4 transition-transform text-textPrimary/60" fill="none"
                stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
            </svg>
        </div>

        <!-- Dropdown Menu -->
        <div
            class="dropdown-menu hidden absolute z-10 w-full mt-1 bg-background border border-border rounded-lg shadow-lg max-h-72 overflow-y-auto">

            <!-- Search & Add Input di Bagian Atas -->
            @if ($allowAdd)
                <div class="p-2 border-b border-border bg-background/50 sticky top-0 z-20 backdrop-blur-sm">
                    <div class="flex gap-2">
                        <input type="text"
                            class="search-input w-full px-3 py-1.5 bg-background border border-border rounded-md text-sm text-textPrimary focus:outline-none focus:ring-1 focus:ring-primary"
                            placeholder="{{ $searchPlaceholder }}">
                        <button type="button"
                            class="btn-add-option px-3 py-1.5 bg-primary text-white rounded-md text-sm font-medium hover:opacity-90 transition-opacity whitespace-nowrap">
                            Tambah
                        </button>
                    </div>
                    <p class="feedback-msg text-xs mt-1.5 hidden"></p>
                </div>
            @endif

            <!-- Daftar Opsi -->
            <div class="options-list p-2 space-y-1">
                <!-- Di-generate via JS Native -->
            </div>

            <!-- Informasi Sisa Data Lainnya -->
            <div
                class="options-info px-3 py-2 text-xs text-textPrimary/60 text-center border-t border-border/50 bg-background/30 italic hidden">
                <!-- Di-generate via JS Native -->
            </div>
        </div>
    </div>

    <!-- Selected Items as Pills -->
    <div class="pills-container flex flex-wrap gap-1.5 pt-1">
        <!-- Di-generate via JS Native -->
    </div>
</div>

<!-- JavaScript Native Logic -->
<script>
    document.addEventListener('DOMContentLoaded', function() {
        const root = document.getElementById('{{ $componentId }}');
        if (!root) return;

        // Parse data dari atribut HTML
        let options = JSON.parse(root.dataset.options || '[]');
        let selected = JSON.parse(root.dataset.selected || '[]');
        const fieldName = '{{ $name }}';

        // Selektor DOM internal
        const trigger = root.querySelector('.dropdown-trigger');
        const menu = root.querySelector('.dropdown-menu');
        const arrow = root.querySelector('.dropdown-arrow');
        const selectedLabel = root.querySelector('.selected-label');
        const optionsList = root.querySelector('.options-list');
        const optionsInfo = root.querySelector('.options-info');
        const hiddenInputsContainer = root.querySelector('.hidden-inputs-container');
        const pillsContainer = root.querySelector('.pills-container');
        const searchInput = root.querySelector('.search-input');
        const btnAddOption = root.querySelector('.btn-add-option');
        const feedbackMsg = root.querySelector('.feedback-msg');

        let searchQuery = '';

        // Render awal
        render();

        // Toggle Dropdown
        trigger.addEventListener('click', (e) => {
            e.stopPropagation();
            menu.classList.toggle('hidden');
            arrow.classList.toggle('rotate-180');
            if (!menu.classList.contains('hidden') && searchInput) {
                searchInput.focus();
            }
        });

        // Tutup dropdown jika klik di luar
        document.addEventListener('click', (e) => {
            if (!root.contains(e.target)) {
                menu.classList.add('hidden');
                arrow.classList.remove('rotate-180');
            }
        });

        // Event listener untuk Search & Input Tambah Baru
        if (searchInput) {
            searchInput.addEventListener('input', (e) => {
                searchQuery = e.target.value.toLowerCase().trim();
                render();
            });

            searchInput.addEventListener('keydown', (e) => {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    const matchedOption = options.find(opt => opt.nama_kategori.toLowerCase() ===
                        searchQuery);
                    if (!matchedOption && searchQuery !== '') {
                        handleAddNew();
                    } else if (matchedOption) {
                        toggleOption(matchedOption);
                    }
                }
            });
        }

        if (btnAddOption) {
            btnAddOption.addEventListener('click', handleAddNew);
        }

        function handleAddNew() {
            const text = searchInput.value.trim();
            if (!text) {
                showFeedback('Input tidak boleh kosong.', 'error');
                return;
            }

            // Cek duplikat case-insensitive
            const isDuplicate = options.some(opt => opt.nama_kategori.toLowerCase() === text.toLowerCase());
            if (isDuplicate) {
                showFeedback('Data tersebut sudah ada dalam daftar.', 'error');
                return;
            }

            const newObj = {
                id_kategori: 'custom-' + Date.now(),
                nama_kategori: text
            };

            options.push(newObj);
            selected.push(newObj);
            searchInput.value = '';
            searchQuery = '';
            showFeedback('Berhasil ditambahkan!', 'success');

            render();
        }

        function showFeedback(msg, type) {
            if (!feedbackMsg) return;
            feedbackMsg.textContent = msg;
            feedbackMsg.className =
                `feedback-msg text-xs mt-1.5 ${type === 'error' ? 'text-red-500' : 'text-green-600'}`;
            feedbackMsg.classList.remove('hidden');
            setTimeout(() => {
                feedbackMsg.classList.add('hidden');
            }, 3000);
        }

        function toggleOption(option) {
            const index = selected.findIndex(item => item.id_kategori == option.id_kategori);
            if (index > -1) {
                selected.splice(index, 1);
            } else {
                selected.push(option);
            }
            render();
        }

        function removePill(id) {
            selected = selected.filter(item => item.id_kategori != id);
            render();
        }

        function render() {
            // 1. Render Hidden Inputs agar data ikut terkirim saat form disubmit secara native oleh Laravel
            hiddenInputsContainer.innerHTML = '';
            if (selected.length > 0) {
                selectedLabel.textContent = `${selected.length} dipilih`;
                selected.forEach(item => {
                    const input = document.createElement('input');
                    input.type = 'hidden';
                    input.name = `${fieldName}[]`; // Format array (cth: categories[])
                    input.value = item.id_kategori;
                    hiddenInputsContainer.appendChild(input);
                });
            } else {
                selectedLabel.textContent = '{{ $placeholder }}';
            }

            // 2. Filter Opsi Berdasarkan Search Query
            const filteredOptions = options.filter(option =>
                option.nama_kategori.toLowerCase().includes(searchQuery)
            );

            const limit = 8;
            const displayedOptions = searchQuery ? filteredOptions : filteredOptions.slice(0, limit);
            const remainingCount = filteredOptions.length - limit;

            // 3. Render Daftar Opsi di Dropdown
            optionsList.innerHTML = '';
            if (filteredOptions.length === 0) {
                optionsList.innerHTML =
                    `<div class="px-3 py-2 text-xs text-textPrimary/50 text-center italic">Tidak ditemukan. Tekan "Tambah" untuk membuat baru.</div>`;
            } else {
                displayedOptions.forEach(option => {
                    const isSelected = selected.some(item => item.id_kategori == option.id_kategori);
                    const div = document.createElement('div');
                    div.className = `px-3 py-2 text-sm rounded-md cursor-pointer flex items-center justify-between transition-colors ${
                        isSelected ? 'bg-primary/10 text-primary font-medium' : 'hover:bg-border/50 text-textPrimary'
                    }`;

                    div.innerHTML = `
                        <span>${option.nama_kategori}</span>
                        ${isSelected ? '<svg class="w-4 h-4 text-primary" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>' : ''}
                    `;

                    div.addEventListener('click', (e) => {
                        e.stopPropagation();
                        toggleOption(option);
                    });
                    optionsList.appendChild(div);
                });
            }

            if (!searchQuery && remainingCount > 0) {
                optionsInfo.textContent =
                    `Terdapat ${remainingCount} data lainnya (gunakan kolom pencarian di atas)`;
                optionsInfo.classList.remove('hidden');
            } else {
                optionsInfo.classList.add('hidden');
            }

            // 4. Render Pills di Bawah Input
            pillsContainer.innerHTML = '';
            if (selected.length > 0) {
                selected.forEach(item => {
                    const pill = document.createElement('span');
                    pill.className =
                        'inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-medium bg-primary/15 text-primary border border-primary/20 transition-all';
                    pill.innerHTML = `
                        <span>${item.nama_kategori}</span>
                        <button type="button" class="hover:bg-primary/20 rounded-full p-0.5 transition-colors" aria-label="Hapus">
                            <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                            </svg>
                        </button>
                    `;

                    pill.querySelector('button').addEventListener('click', (e) => {
                        e.stopPropagation();
                        removePill(item.id_kategori);
                    });

                    pillsContainer.appendChild(pill);
                });
            } else {
                const emptySpan = document.createElement('span');
                emptySpan.className = 'text-xs text-textPrimary/50 italic';
                emptySpan.textContent = 'Belum ada pilihan yang dipilih.';
                pillsContainer.appendChild(emptySpan);
            }
        }
    });
</script>
