@props([
    'name',
    'id',
    'label' => '',
    'options' => [], // Koleksi data: [['id' => 1, 'name' => 'Batam Kota'], ...]
    'selectedValue' => null,
    'placeholder' => 'Pilih opsi...',
    'searchPlaceholder' => 'Cari...',
    'required' => false,
])

<div class="relative w-full searchable-select-container" x-data="{}" data-selected="{{ $selectedValue }}">
    @if ($label)
        <label for="{{ $id }}" class="block text-sm font-medium text-textPrimary mb-1.5">
            {{ $label }} @if ($required)
                <span class="text-red-500">*</span>
            @endif
        </label>
    @endif

    {{-- Input Hidden untuk Backend --}}
    <input type="hidden" id="{{ $id }}" name="{{ $name }}" value="{{ $selectedValue }}"
        @if ($required) required @endif>

    {{-- Trigger Dropdown (Tampilan Utama) --}}
    <div class="select-trigger w-full px-3.5 py-2 bg-background border border-border rounded-lg text-sm text-textPrimary focus:outline-none focus:ring-2 focus:ring-primary flex items-center justify-between cursor-pointer select-none"
        tabindex="0">
        <span class="selected-label truncate text-textPrimary opacity-75">
            {{ $placeholder }}
        </span>
        <div class="flex items-center space-x-1.5">
            {{-- Tombol Clear (Hapus Pilihan) --}}
            <button type="button"
                class="clear-btn text-textPrimary opacity-40 hover:opacity-100 hidden transition-opacity"
                title="Hapus pilihan">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12">
                    </path>
                </svg>
            </button>
            {{-- Ikon Dropdown --}}
            <svg class="w-4 h-4 text-textPrimary opacity-60 transition-transform duration-200 dropdown-arrow"
                fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
            </svg>
        </div>
    </div>

    {{-- Dropdown Panel --}}
    <div
        class="dropdown-panel absolute left-0 right-0 mt-1 bg-background border border-border rounded-lg shadow-lg z-50 hidden overflow-hidden">
        {{-- Kotak Pencarian --}}
        <div class="p-2 border-b border-border bg-background">
            <div class="relative">
                <span
                    class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none text-textPrimary opacity-40">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                            d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                    </svg>
                </span>
                <input type="text"
                    class="search-input w-full pl-9 pr-3 py-1.5 bg-background border border-border rounded-md text-sm text-textPrimary focus:outline-none focus:ring-1 focus:ring-primary"
                    placeholder="{{ $searchPlaceholder }}" autocomplete="off">
            </div>
        </div>

        {{-- Daftar Pilihan --}}
        <ul class="options-list max-h-60 overflow-y-auto divide-y divide-border/40">
            @forelse($options as $option)
                @php
                    // Menyesuaikan dengan berbagai struktur key (id_kecamatan / id, nama_kecamatan / nama)
                    $optId = $option->id_kecamatan ?? ($option->id ?? ($option['id'] ?? null));
                    $optName = $option->nama_kecamatan ?? ($option->nama ?? ($option['name'] ?? ''));
                @endphp
                <li class="option-item px-3.5 py-2 text-sm text-textPrimary hover:bg-primary/10 cursor-pointer transition-colors flex items-center justify-between"
                    data-value="{{ $optId }}" data-name="{{ $optName }}">
                    <span>{{ $optName }}</span>
                    <span class="check-icon text-primary hidden">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7">
                            </path>
                        </svg>
                    </span>
                </li>
            @empty
                <li class="px-3.5 py-3 text-sm text-textPrimary opacity-50 text-center no-data">
                    Data tidak ditemukan
                </li>
            @endforelse
            <li class="px-3.5 py-3 text-sm text-textPrimary opacity-50 text-center no-results hidden">
                Data tidak ditemukan
            </li>
        </ul>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        document.querySelectorAll('.searchable-select-container').forEach(function(container) {
            const hiddenInput = container.querySelector('input[type="hidden"]');
            const trigger = container.querySelector('.select-trigger');
            const selectedLabel = container.querySelector('.selected-label');
            const dropdownPanel = container.querySelector('.dropdown-panel');
            const searchInput = container.querySelector('.search-input');
            const optionsList = container.querySelector('.options-list');
            const options = container.querySelectorAll('.option-item');
            const clearBtn = container.querySelector('.clear-btn');
            const arrowIcon = container.querySelector('.dropdown-arrow');
            const noResultsMsg = container.querySelector('.no-results');

            const placeholderText = selectedLabel.textContent.trim();

            // 1. Inisialisasi nilai awal (termasuk dukungan old())
            const initialVal = hiddenInput.value;
            if (initialVal) {
                options.forEach(opt => {
                    if (opt.getAttribute('data-value') === initialVal) {
                        selectOption(opt, false);
                    }
                });
            }

            // 2. Toggle Dropdown
            trigger.addEventListener('click', function(e) {
                e.stopPropagation();
                toggleDropdown();
            });

            function toggleDropdown(open = null) {
                const isOpen = open !== null ? open : dropdownPanel.classList.contains('hidden');

                // Tutup semua dropdown lain terlebih dahulu
                document.querySelectorAll('.dropdown-panel').forEach(p => p.classList.add('hidden'));
                document.querySelectorAll('.dropdown-arrow').forEach(a => a.style.transform =
                    'rotate(0deg)');

                if (isOpen) {
                    dropdownPanel.classList.remove('hidden');
                    arrowIcon.style.transform = 'rotate(180deg)';
                    searchInput.focus();
                    searchInput.value = '';
                    filterOptions('');
                }
            }

            // Tutup saat klik di luar
            document.addEventListener('click', function(e) {
                if (!container.contains(e.target)) {
                    dropdownPanel.classList.add('hidden');
                    arrowIcon.style.transform = 'rotate(0deg)';
                }
            });

            // 3. Pencarian Real-Time
            searchInput.addEventListener('input', function() {
                filterOptions(this.value.toLowerCase());
            });

            function filterOptions(query) {
                let visibleCount = 0;
                options.forEach(opt => {
                    const text = opt.getAttribute('data-name').toLowerCase();
                    if (text.includes(query)) {
                        opt.style.display = 'flex';
                        visibleCount++;
                    } else {
                        opt.style.display = 'none';
                    }
                });

                if (visibleCount === 0) {
                    noResultsMsg.classList.remove('hidden');
                } else {
                    noResultsMsg.classList.add('hidden');
                }
            }

            // 4. Memilih Opsi
            options.forEach(opt => {
                opt.addEventListener('click', function() {
                    selectOption(this, true);
                    dropdownPanel.classList.add('hidden');
                    arrowIcon.style.transform = 'rotate(0deg)';
                });
            });

            function selectOption(optElement, triggerChange = true) {
                const val = optElement.getAttribute('data-value');
                const name = optElement.getAttribute('data-name');

                hiddenInput.value = val;
                selectedLabel.textContent = name;
                selectedLabel.classList.remove('opacity-75');
                clearBtn.classList.remove('hidden');

                // Tandai pilihan aktif
                options.forEach(o => {
                    o.classList.remove('bg-primary/10', 'font-semibold');
                    o.querySelector('.check-icon').classList.add('hidden');
                });
                optElement.classList.add('bg-primary/10', 'font-semibold');
                optElement.querySelector('.check-icon').classList.remove('hidden');

                if (triggerChange) {
                    hiddenInput.dispatchEvent(new Event('change', {
                        bubbles: true
                    }));
                }
            }

            // 5. Tombol Clear / Hapus Pilihan
            clearBtn.addEventListener('click', function(e) {
                e.stopPropagation();
                hiddenInput.value = '';
                selectedLabel.textContent = placeholderText;
                selectedLabel.classList.add('opacity-75');
                clearBtn.classList.add('hidden');

                options.forEach(o => {
                    o.classList.remove('bg-primary/10', 'font-semibold');
                    o.querySelector('.check-icon').classList.add('hidden');
                });

                hiddenInput.dispatchEvent(new Event('change', {
                    bubbles: true
                }));
            });

            // 6. Navigasi Keyboard Dasar
            trigger.addEventListener('keydown', function(e) {
                if (e.key === 'Enter' || e.key === ' ') {
                    e.preventDefault();
                    toggleDropdown();
                }
            });

            searchInput.addEventListener('keydown', function(e) {
                if (e.key === 'Escape') {
                    dropdownPanel.classList.add('hidden');
                    arrowIcon.style.transform = 'rotate(0deg)';
                    trigger.focus();
                }
            });
        });
    });
</script>
