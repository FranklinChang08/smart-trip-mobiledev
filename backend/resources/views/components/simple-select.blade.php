@props([
    'name',
    'id',
    'label' => '',
    'options' => [],
    'selectedValue' => null,
    'placeholder' => 'Pilih opsi...',
    'required' => false,
])

<div class="relative w-full simple-select-container">
    @if ($label)
        <label for="{{ $id }}" class="block text-sm font-medium text-textPrimary mb-1.5">
            {{ $label }}

            @if ($required)
                <span class="text-red-500">*</span>
            @endif
        </label>
    @endif

    {{-- Input untuk Backend --}}
    <input type="hidden" id="{{ $id }}" name="{{ $name }}" value="{{ $selectedValue }}"
        @if ($required) required @endif>

    {{-- Trigger Dropdown --}}
    <div class="simple-select-trigger w-full px-3.5 py-2 bg-background
               border border-border rounded-lg text-sm text-textPrimary
               focus:outline-none focus:ring-2 focus:ring-primary
               flex items-center justify-between cursor-pointer select-none"
        tabindex="0" role="combobox" aria-expanded="false" aria-controls="{{ $id }}-options">
        <span class="simple-selected-label truncate text-textPrimary opacity-75">
            {{ $placeholder }}
        </span>

        <div class="flex items-center space-x-1.5">
            {{-- Tombol Clear --}}
            <button type="button"
                class="simple-clear-btn text-textPrimary opacity-40
                       hover:opacity-100 hidden transition-opacity"
                title="Hapus pilihan" aria-label="Hapus pilihan">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                </svg>
            </button>

            {{-- Ikon Dropdown --}}
            <svg class="w-4 h-4 text-textPrimary opacity-60
                       transition-transform duration-200 simple-dropdown-arrow"
                fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
            </svg>
        </div>
    </div>

    {{-- Dropdown Panel --}}
    <div
        class="simple-dropdown-panel absolute left-0 right-0 mt-1
               bg-background border border-border rounded-lg shadow-lg
               z-50 hidden overflow-hidden">
        <ul id="{{ $id }}-options"
            class="simple-options-list max-h-60 overflow-y-auto divide-y divide-border/40" role="listbox">
            @forelse ($options as $option)
                @php
                    if (is_array($option)) {
                        $value = $option['value'] ?? ($option['id'] ?? '');
                        $text = $option['label'] ?? ($option['name'] ?? $value);
                    } elseif (is_object($option)) {
                        $value = data_get($option, 'value', data_get($option, 'id', ''));
                        $text = data_get($option, 'label', data_get($option, 'name', $value));
                    } else {
                        $value = $option;
                        $text = $option;
                    }
                @endphp

                <li class="simple-option-item px-3.5 py-2 text-sm text-textPrimary
                           hover:bg-primary/10 cursor-pointer transition-colors
                           flex items-center justify-between"
                    data-value="{{ $value }}" data-name="{{ $text }}" role="option" tabindex="0">
                    <span>{{ $text }}</span>

                    <span class="simple-check-icon text-primary hidden">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                        </svg>
                    </span>
                </li>
            @empty
                <li class="px-3.5 py-3 text-sm text-textPrimary opacity-50 text-center">
                    Data tidak ditemukan
                </li>
            @endforelse
        </ul>
    </div>
</div>

<script>
    (() => {
        function initSimpleSelects() {
            document.querySelectorAll('.simple-select-container:not([data-initialized])')
                .forEach(container => {
                    container.dataset.initialized = 'true';

                    const input = container.querySelector('input[type="hidden"]');
                    const trigger = container.querySelector('.simple-select-trigger');
                    const label = container.querySelector('.simple-selected-label');
                    const panel = container.querySelector('.simple-dropdown-panel');
                    const clearBtn = container.querySelector('.simple-clear-btn');
                    const arrow = container.querySelector('.simple-dropdown-arrow');
                    const options = container.querySelectorAll('.simple-option-item');
                    const placeholder = label.textContent.trim();

                    function closeDropdown() {
                        panel.classList.add('hidden');
                        arrow.style.transform = 'rotate(0deg)';
                        trigger.setAttribute('aria-expanded', 'false');
                    }

                    function selectOption(option, dispatch = true) {
                        input.value = option.dataset.value;
                        label.textContent = option.dataset.name;
                        label.classList.remove('opacity-75');
                        clearBtn.classList.remove('hidden');

                        options.forEach(item => {
                            item.classList.remove('bg-primary/10', 'font-semibold');
                            item.querySelector('.simple-check-icon')
                                .classList.add('hidden');
                            item.setAttribute('aria-selected', 'false');
                        });

                        option.classList.add('bg-primary/10', 'font-semibold');
                        option.querySelector('.simple-check-icon')
                            .classList.remove('hidden');
                        option.setAttribute('aria-selected', 'true');

                        if (dispatch) {
                            input.dispatchEvent(new Event('change', {
                                bubbles: true
                            }));
                        }

                        closeDropdown();
                    }

                    function openDropdown() {
                        document.querySelectorAll('.simple-dropdown-panel')
                            .forEach(item => item.classList.add('hidden'));

                        document.querySelectorAll('.simple-dropdown-arrow')
                            .forEach(item => item.style.transform = 'rotate(0deg)');

                        panel.classList.remove('hidden');
                        arrow.style.transform = 'rotate(180deg)';
                        trigger.setAttribute('aria-expanded', 'true');
                    }

                    trigger.addEventListener('click', event => {
                        event.stopPropagation();

                        if (panel.classList.contains('hidden')) {
                            openDropdown();
                        } else {
                            closeDropdown();
                        }
                    });

                    trigger.addEventListener('keydown', event => {
                        if (event.key === 'Enter' || event.key === ' ') {
                            event.preventDefault();

                            if (panel.classList.contains('hidden')) {
                                openDropdown();
                            } else {
                                closeDropdown();
                            }
                        }

                        if (event.key === 'Escape') {
                            closeDropdown();
                        }
                    });

                    options.forEach(option => {
                        option.addEventListener('click', () => {
                            selectOption(option);
                        });

                        option.addEventListener('keydown', event => {
                            if (event.key === 'Enter' || event.key === ' ') {
                                event.preventDefault();
                                selectOption(option);
                                trigger.focus();
                            }
                        });
                    });

                    clearBtn.addEventListener('click', event => {
                        event.stopPropagation();

                        input.value = '';
                        label.textContent = placeholder;
                        label.classList.add('opacity-75');
                        clearBtn.classList.add('hidden');

                        options.forEach(option => {
                            option.classList.remove('bg-primary/10', 'font-semibold');
                            option.querySelector('.simple-check-icon')
                                .classList.add('hidden');
                            option.setAttribute('aria-selected', 'false');
                        });

                        input.dispatchEvent(new Event('change', {
                            bubbles: true
                        }));
                    });

                    document.addEventListener('click', event => {
                        if (!container.contains(event.target)) {
                            closeDropdown();
                        }
                    });

                    // Inisialisasi pilihan awal, termasuk old() dan data edit
                    const initialOption = Array.from(options).find(
                        option => option.dataset.value === input.value
                    );

                    if (initialOption && input.value !== '') {
                        selectOption(initialOption, false);
                    }
                });
        }

        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', initSimpleSelects);
        } else {
            initSimpleSelects();
        }
    })();
</script>
