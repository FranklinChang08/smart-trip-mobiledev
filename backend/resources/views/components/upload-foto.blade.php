   @props([
       'isEdit' => false,
       'fotoWisata' => collect(),
       'wisata' => null,
   ])

   <div class="bg-white p-6 rounded-xl border border-border shadow-sm space-y-4" data-photo-upload>
       <h2 class="text-base font-bold text-textPrimary flex items-center">
           <span class="w-2 h-5 bg-primary rounded-full mr-2"></span>
           Foto Destinasi (Opsional)
       </h2>
       <p class="text-xs text-textSecondary">
           Unggah foto baru untuk menambahkan foto pendukung. Foto lama tetap tersimpan jika tidak dihapus melalui fitur
           penghapusan foto.
       </p>

       {{-- TAMBAHKAN ID DAN WRAPPER DI SINI --}}
       @if ($isEdit && isset($fotoWisata) && $fotoWisata->isNotEmpty())
           <div id="existing-photos-container" class="space-y-3">
               <div class="grid grid-cols-2 sm:grid-cols-3 gap-3">
                   @foreach ($fotoWisata as $foto)
                       <div class="rounded-lg border border-border p-1.5 relative group bg-white shadow-sm"
                           data-photo-id="{{ $foto->id_photo ?? $foto->id }}">

                           {{-- Gambar Foto --}}
                           <img src="{{ asset('storage/' . $foto->link_photo) }}"
                               alt="Foto {{ $wisata->nama_wisata ?? ($wisata->nama_restoran ?? 'Destinasi') }}"
                               class="h-28 w-full rounded-md object-cover">

                           {{-- Tombol Hapus Absolute di Kanan Atas --}}
                           <button type="button"
                               onclick="deleteExistingPhoto('{{ $foto->id_photo ?? $foto->id }}', this)"
                               class="absolute top-3 right-3 p-1.5 bg-white/90 hover:bg-red-600 text-red-600 hover:text-white rounded-full shadow-md transition duration-200 backdrop-blur-sm"
                               title="Hapus foto" aria-label="Hapus foto">
                               <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"
                                   aria-hidden="true">
                                   <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                       d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16">
                                   </path>
                               </svg>
                           </button>

                       </div>
                   @endforeach
               </div>
           </div>
       @endif

       {{-- Bagian dropzone input file baru tetap di bawahnya --}}
       <div data-dropzone role="button" tabindex="0"
           class="border-2 border-dashed border-border rounded-xl p-6 text-center hover:border-primary transition bg-background cursor-pointer">
           <div class="flex flex-col items-center justify-center space-y-2">
               <div class="p-3 bg-white rounded-full shadow-sm border border-border text-primary">
                   <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
                       <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                           d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z">
                       </path>
                   </svg>
               </div>
               <div class="text-sm text-textPrimary font-medium">
                   Seret & letakkan foto di sini, atau <span class="text-primary underline">pilih file</span>
               </div>
               <p class="text-xs text-textSecondary">PNG, JPG, JPEG — maksimal 5 MB per gambar, maksimal 10 gambar baru.
               </p>
           </div>
           <input type="file" name="foto_destinasi[]" accept=".png,.jpg,.jpeg,image/png,image/jpeg" multiple
               class="hidden" data-file-input>
       </div>

       <div data-error class="hidden text-sm text-red-600" role="alert" aria-live="polite"></div>

       @error('foto_destinasi')
           <p class="text-sm text-red-600" role="alert">{{ $message }}</p>
       @enderror

       @error('foto_destinasi.*')
           <p class="text-sm text-red-600" role="alert">{{ $message }}</p>
       @enderror

       <div class="space-y-2 pt-2">
           <label class="block text-xs font-semibold text-textSecondary uppercase tracking-wider">Antrean Upload
               Foto</label>
           <div data-file-list class="grid grid-cols-1 sm:grid-cols-2 gap-3">
               <p data-empty
                   class="col-span-full text-sm text-textSecondary text-center py-4 border border-dashed border-border rounded-lg">
                   Belum ada foto baru yang dipilih.
               </p>
           </div>
           <p data-upload-status class="text-xs text-textSecondary" aria-live="polite"></p>
       </div>
   </div>
   <script>
       async function deleteExistingPhoto(photoId, buttonElement) {
           if (!confirm('Apakah Anda yakin ingin menghapus foto ini?')) {
               return;
           }

           let deleteUrl = `/admin/wisata/foto/${photoId}`;

           if (window.location.pathname.includes('/restoran')) {
               deleteUrl = `/admin/restoran/foto/${photoId}`;
           } else if (window.location.pathname.includes('/wisata')) {
               deleteUrl = `/admin/wisata/foto/${photoId}`;
           }

           const photoCard = buttonElement.closest('[data-photo-id]');
           photoCard.style.opacity = '0.5';

           try {
               const response = await fetch(deleteUrl, {
                   method: 'DELETE',
                   headers: {
                       'Content-Type': 'application/json',
                       'Accept': 'application/json',
                       'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content
                   }
               });

               const data = await response.json();

               if (!response.ok) {
                   throw new Error(data.message || 'Gagal menghapus foto dari server.');
               }

               // Hapus card foto dari DOM
               photoCard.remove();

               // Cek apakah grid foto lama sudah habis
               const container = document.getElementById('existing-photos-container');
               if (container) {
                   const grid = container.querySelector('.grid');
                   // Jika grid tidak punya anak (card foto sudah habis terhapus)
                   if (!grid || grid.children.length === 0) {
                       container.remove(); // Hapus seluruh container pembungkusnya
                   }
               }

               if (typeof showFeedback === 'function') {
                   showFeedback('Foto berhasil dihapus.', 'success');
               }

           } catch (error) {
               photoCard.style.opacity = '1';
               alert(error.message);
           }
       }
       document.addEventListener('DOMContentLoaded', () => {
           document.querySelectorAll('[data-photo-upload]').forEach((component) => {
               const dropzone = component.querySelector('[data-dropzone]');
               const input = component.querySelector('[data-file-input]');
               const fileList = component.querySelector('[data-file-list]');
               const emptyState = component.querySelector('[data-empty]');
               const errorBox = component.querySelector('[data-error]');
               const uploadStatus = component.querySelector('[data-upload-status]');
               const form = component.closest('form');

               const MAX_SIZE = 5 * 1024 * 1024;
               const MAX_FILES = 10;
               const ALLOWED_TYPES = ['image/jpeg', 'image/png'];
               let selectedFiles = [];
               let isSubmitting = false;

               if (!form || !dropzone || !input || !fileList || !emptyState || !errorBox || !
                   uploadStatus) {
                   console.error('Komponen upload foto belum lengkap.');
                   return;
               }

               function formatSize(bytes) {
                   return bytes >= 1024 * 1024 ?
                       (bytes / (1024 * 1024)).toFixed(2) + ' MB' :
                       (bytes / 1024).toFixed(1) + ' KB';
               }

               function showError(messages = []) {
                   errorBox.textContent = messages.join(' ');
                   errorBox.classList.toggle('hidden', messages.length === 0);
               }

               function syncInputFiles() {
                   const transfer = new DataTransfer();
                   selectedFiles.forEach((item) => transfer.items.add(item.file));
                   input.files = transfer.files;
               }

               function renderFiles() {
                   fileList.querySelectorAll('[data-file-item]').forEach((item) => item.remove());
                   emptyState.classList.toggle('hidden', selectedFiles.length > 0);

                   selectedFiles.forEach((item) => {
                       const card = document.createElement('div');
                       card.dataset.fileItem = '';
                       card.className =
                           'flex items-center justify-between p-3 rounded-lg border border-border bg-white shadow-sm';

                       const left = document.createElement('div');
                       left.className = 'flex items-center space-x-3 overflow-hidden';
                       const thumbnail = document.createElement('img');
                       thumbnail.src = item.previewUrl;
                       thumbnail.alt = 'Preview ' + item.file.name;
                       thumbnail.className =
                           'w-12 h-12 rounded-md object-cover border border-border shrink-0';

                       const details = document.createElement('div');
                       details.className = 'min-w-0 truncate';
                       const filename = document.createElement('p');
                       filename.className = 'text-xs font-semibold text-textPrimary truncate';
                       filename.textContent = item.file.name;
                       const status = document.createElement('p');
                       status.className = 'text-[11px] text-emerald-600 font-medium mt-0.5';
                       status.textContent = 'Siap diunggah (' + formatSize(item.file.size) + ')';
                       status.dataset.fileStatus = '';
                       details.append(filename, status);
                       left.append(thumbnail, details);

                       const removeButton = document.createElement('button');
                       removeButton.type = 'button';
                       removeButton.className =
                           'p-1.5 text-slate-400 hover:text-red-600 transition shrink-0';
                       removeButton.title = 'Hapus foto';
                       removeButton.setAttribute('aria-label', 'Hapus ' + item.file.name);
                       removeButton.textContent = 'Hapus';
                       removeButton.addEventListener('click', () => {
                           if (isSubmitting) return;
                           URL.revokeObjectURL(item.previewUrl);
                           selectedFiles = selectedFiles.filter((selected) => selected
                               .id !== item.id);
                           syncInputFiles();
                           renderFiles();
                           showError();
                       });

                       card.append(left, removeButton);
                       fileList.appendChild(card);
                   });
                   uploadStatus.textContent = selectedFiles.length ?
                       selectedFiles.length + ' dari ' + MAX_FILES + ' foto baru dipilih.' :
                       '';
               }

               function addFiles(files) {
                   if (isSubmitting) return;
                   const errors = [];
                   Array.from(files).forEach((file) => {
                       const duplicate = selectedFiles.some((item) => item.file.name === file
                           .name && item.file.size === file.size && item.file.lastModified ===
                           file.lastModified);
                       if (duplicate) {
                           errors.push(file.name + ': file sudah dipilih.');
                           return;
                       }
                       if (!ALLOWED_TYPES.includes(file.type)) {
                           errors.push(file.name + ': hanya JPG, JPEG, atau PNG.');
                           return;
                       }
                       if (file.size > MAX_SIZE) {
                           errors.push(file.name + ': ukuran melebihi 5 MB.');
                           return;
                       }
                       if (selectedFiles.length >= MAX_FILES) {
                           errors.push('Maksimal ' + MAX_FILES + ' gambar baru.');
                           return;
                       }
                       selectedFiles.push({
                           id: crypto.randomUUID(),
                           file,
                           previewUrl: URL.createObjectURL(file)
                       });
                   });
                   syncInputFiles();
                   renderFiles();
                   showError(errors);
               }

               dropzone.addEventListener('click', (event) => {
                   if (event.target.closest('button')) return;
                   if (!isSubmitting) input.click();
               });
               dropzone.addEventListener('keydown', (event) => {
                   if ((event.key === 'Enter' || event.key === ' ') && event.target === dropzone) {
                       event.preventDefault();
                       if (!isSubmitting) input.click();
                   }
               });
               input.addEventListener('change', () => {
                   addFiles(input.files);
                   syncInputFiles();
               });
               ['dragenter', 'dragover'].forEach((eventName) => dropzone.addEventListener(eventName, (
                   event) => {
                   event.preventDefault();
                   if (!isSubmitting) dropzone.classList.add('border-primary');
               }));
               ['dragleave', 'drop'].forEach((eventName) => dropzone.addEventListener(eventName, (
                   event) => {
                   event.preventDefault();
                   dropzone.classList.remove('border-primary');
               }));
               dropzone.addEventListener('drop', (event) => {
                   if (!isSubmitting) addFiles(event.dataTransfer.files);
               });
               form.addEventListener('submit', () => {
                   syncInputFiles();
                   isSubmitting = true;
                   component.querySelectorAll('button').forEach((button) => button.disabled =
                       true);
                   dropzone.classList.add('opacity-60', 'cursor-not-allowed');
                   uploadStatus.textContent = selectedFiles.length ?
                       'Mengirim ' + selectedFiles.length + ' foto bersama data wisata...' :
                       'Mengirim data wisata tanpa foto baru.';
               });
           });
       });
   </script>
