/**
 * mediaLoader.js
 * Handles lazy-loading of media (images and videos) in chat messages using Intersection Observer.
 *
 * Dependencies:
 * - MediaCache.js (IndexedDB caching layer) — must be loaded before this script
 *
 * Features:
 * - Lazy load pre-signed URLs only when media enters viewport
 * - Support for IMAGE and VIDEO media types
 * - Full-width image display with lightbox preview modal
 * - Video play button overlay
 * - Silent error handling (empty placeholder on failure)
 * - Responsive grid layout
 * - Uses MediaCache for IndexedDB-backed fast repeat loads
 */

class MediaLoader {
    static observer = null;
    static profilePictureObserver = null; // Separate observer for profile picture elements
    static loadedMediaIds = new Set(); // Track loaded media to avoid duplicate API calls
    static loadedProfilePictureIds = new Set(); // Track loaded profile pictures to avoid duplicates
    static imageModal = null; // Reference to lightbox modal
    static currentImageIndex = 0; // Current image in modal
    static currentModalImages = []; // Images in current modal

    /**
     * Initialize Intersection Observer for lazy-loading media
     * Call this on page load or after new messages are added
     */
    static initMediaLazyLoader() {
        if (MediaLoader.observer) {
            return; // Already initialized
        }

        const options = {
            root: document.getElementById('messagesContainer'),
            rootMargin: '100px', // Start loading 100px before entering viewport
            threshold: 0.1 // Trigger when 10% visible
        };

        MediaLoader.observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting && !entry.target.dataset.loaded) {
                    MediaLoader.loadMediaForElement(entry.target);
                }
            });
        }, options);

        // Observe all media placeholders
        document.querySelectorAll('.media-lazy-placeholder').forEach(placeholder => {
            MediaLoader.observer.observe(placeholder);
        });

        // Initialize lightbox modal
        MediaLoader.createLightboxModal();
    }

    /**
     * Show loading spinner in placeholder
     * @param {HTMLElement} placeholderElement - The placeholder div
     */
    static showLoadingSpinner(placeholderElement) {
        placeholderElement.innerHTML = `
            <div class="media-loading-spinner">
                <div class="spinner-border-custom"></div>
                <div class="media-loading-text">Loading...</div>
            </div>
        `;
    }

    /**
     * Load a single media item when it becomes visible
     * First checks IndexedDB cache, then falls back to presigned URL
     * @param {HTMLElement} placeholderElement - The placeholder div element
     */
    static async loadMediaForElement(placeholderElement) {
        const mediaId = placeholderElement.dataset.mediaId;
        const mediaType = placeholderElement.dataset.mediaType;
        const userId = placeholderElement.dataset.userId;
        let presignedUrl = placeholderElement.dataset.presignedUrl;

        if (!mediaId || MediaLoader.loadedMediaIds.has(mediaId)) {
            placeholderElement.dataset.loaded = 'true';
            return;
        }

        try {
            // Step 2: Cache miss - show loading spinner and fetch presigned URL from backend
            MediaLoader.showLoadingSpinner(placeholderElement);

            // Step 1: Check IndexedDB cache first
            const cachedBlob = await MediaCache.getFromCache(mediaId);

            if (cachedBlob) {
                // Cache hit - render from cached blob
                const blobUrl = MediaCache.getBlobAsUrl(cachedBlob);
                MediaLoader.renderMedia(placeholderElement, mediaType, blobUrl);
                MediaLoader.loadedMediaIds.add(mediaId);
                placeholderElement.dataset.loaded = 'true';
                return;
            }

            if (!presignedUrl) {

                const downloadUrl = `${ctx}/api/media/pre-signed-url/${userId}/${mediaId}`;
                const urlResponse = await fetch(downloadUrl);

                if (!urlResponse.ok) {
                    throw new Error(`HTTP ${urlResponse.status}`);
                }

                const urlResponseData = await urlResponse.json();
                const data = urlResponseData.data && urlResponseData.data.length > 0
                    ? urlResponseData.data[0]
                    : urlResponseData;

                presignedUrl = data.presignedDownloadUrl;

                if (!presignedUrl) {
                    console.warn(`[mediaLoader] No presigned URL in response for mediaId=${mediaId}`);
                    placeholderElement.dataset.loaded = 'true';
                    return;
                }
            }
            // Step 3: Download the media blob from presigned URL
            const blobResponse = await fetch(presignedUrl);
            if (!blobResponse.ok) {
                throw new Error(`Failed to download media: HTTP ${blobResponse.status}`);
            }

            const blob = await blobResponse.blob();

            // Step 4: Cache the blob for future use
            await MediaCache.putInCache(mediaId, mediaType, blob);

            // Step 5: Render the media using blob URL
            const blobUrl = MediaCache.getBlobAsUrl(blob);
            MediaLoader.renderMedia(placeholderElement, mediaType, blobUrl);
            MediaLoader.loadedMediaIds.add(mediaId);
            placeholderElement.dataset.loaded = 'true';

        } catch (error) {
            // Silent error handling - just leave placeholder empty
            console.warn(`[mediaLoader] Failed to load media ${mediaId}:`, error);
            placeholderElement.dataset.loaded = 'true';
        }
    }

    /**
     * Render media element (image or video) into placeholder
     * @param {HTMLElement} placeholderElement - The placeholder div
     * @param {string} mediaType - 'IMAGE', 'VIDEO', or 'DOCUMENT'
     * @param {string} presignedUrl - Pre-signed download URL
     */
    static renderMedia(placeholderElement, mediaType, presignedUrl) {
        // Clear placeholder
        placeholderElement.innerHTML = '';

        if (mediaType === 'IMAGE') {
            const img = document.createElement('img');
            img.src = presignedUrl;
            img.className = 'media-thumbnail media-image';
            img.alt = 'Chat media';
            img.style.opacity = '0';
            img.style.cursor = 'pointer';

            // Fade in on load
            img.onload = () => {
                img.style.transition = 'opacity 0.3s ease-in';
                img.style.opacity = '1';
            };

            img.onerror = () => {
                // Silent failure - leave empty
                console.warn('[mediaLoader] Image failed to load');
            };

            // Add click handler to open lightbox
            img.addEventListener('click', (e) => {
                e.stopPropagation();
                MediaLoader.openImageLightbox(img);
            });

            placeholderElement.appendChild(img);
        }
        else if (mediaType === 'VIDEO') {
            const video = document.createElement('video');
            video.src = presignedUrl;
            video.className = 'media-thumbnail';
            video.controls = true;
            video.style.opacity = '0';

            // Fade in on load
            video.onloadedmetadata = () => {
                video.style.transition = 'opacity 0.3s ease-in';
                video.style.opacity = '1';
            };

            video.onerror = () => {
                // Silent failure - leave empty
                console.warn('[mediaLoader] Video failed to load');
            };

            // Add play button overlay
            const playOverlay = MediaLoader.createPlayButtonOverlay();
            placeholderElement.appendChild(video);
            placeholderElement.appendChild(playOverlay);
        }
        else if (mediaType === 'DOCUMENT') {
            // Create document link container
            const docContainer = document.createElement('a');
            docContainer.href = presignedUrl;
            docContainer.target = '_blank';
            docContainer.rel = 'noopener noreferrer';
            docContainer.className = 'media-document-link';
            docContainer.style.display = 'flex';
            docContainer.style.flexDirection = 'column';
            docContainer.style.alignItems = 'center';
            docContainer.style.justifyContent = 'center';
            docContainer.style.width = '100%';
            docContainer.style.height = '100%';
            docContainer.style.padding = '12px';
            docContainer.style.textDecoration = 'none';
            docContainer.style.color = '#2563EB';
            docContainer.style.cursor = 'pointer';
            docContainer.style.transition = 'all 0.3s ease';

            // Document icon
            const docIcon = document.createElement('i');
            docIcon.className = 'fas fa-file-pdf fa-2x';
            docIcon.style.marginBottom = '8px';
            docIcon.style.color = '#DC2626';

            // Filename from data attribute
            const fileName = placeholderElement.dataset.fileName || 'Document';
            const docName = document.createElement('span');
            docName.textContent = fileName;
            docName.style.fontSize = '12px';
            docName.style.fontWeight = '500';
            docName.style.textAlign = 'center';
            docName.style.wordBreak = 'break-word';
            docName.style.maxWidth = '100%';

            // Download icon hint
            const downloadIcon = document.createElement('i');
            downloadIcon.className = 'fas fa-download fa-xs';
            downloadIcon.style.marginTop = '4px';
            downloadIcon.style.opacity = '0.6';
            downloadIcon.style.fontSize = '10px';

            docContainer.appendChild(docIcon);
            docContainer.appendChild(docName);
            docContainer.appendChild(downloadIcon);

            // Hover effect
            docContainer.addEventListener('mouseenter', () => {
                docIcon.style.transform = 'scale(1.1)';
                docContainer.style.backgroundColor = '#F0F9FF';
                docContainer.style.borderRadius = '4px';
            });

            docContainer.addEventListener('mouseleave', () => {
                docIcon.style.transform = 'scale(1)';
                docContainer.style.backgroundColor = 'transparent';
            });

            placeholderElement.appendChild(docContainer);
        }
    }

    /**
     * Create lightbox modal for image preview
     */
    static createLightboxModal() {
        if (document.getElementById('mediaLightbox')) {
            return; // Already exists
        }

        const modal = document.createElement('div');
        modal.id = 'mediaLightbox';
        modal.className = 'media-lightbox d-none';
        modal.innerHTML = `
            <div class="media-lightbox-overlay"></div>
            <div class="media-lightbox-container">
                <button class="media-lightbox-close" aria-label="Close preview">
                    <i class="fas fa-times"></i>
                </button>
                <button class="media-lightbox-nav media-lightbox-prev d-none" aria-label="Previous image">
                    <i class="fas fa-chevron-left"></i>
                </button>
                <img id="mediaLightboxImage" class="media-lightbox-image" src="" alt="Preview" />
                <button class="media-lightbox-nav media-lightbox-next d-none" aria-label="Next image">
                    <i class="fas fa-chevron-right"></i>
                </button>
                <div class="media-lightbox-counter d-none">
                    <span id="mediaLightboxCurrent">1</span> / <span id="mediaLightboxTotal">1</span>
                </div>
            </div>
        `;

        document.body.appendChild(modal);
        MediaLoader.imageModal = modal;

        // Event listeners
        modal.querySelector('.media-lightbox-close').addEventListener('click', () => MediaLoader.closeLightbox());
        modal.querySelector('.media-lightbox-overlay').addEventListener('click', () => MediaLoader.closeLightbox());
        modal.querySelector('.media-lightbox-prev').addEventListener('click', () => MediaLoader.previousImage());
        modal.querySelector('.media-lightbox-next').addEventListener('click', () => MediaLoader.nextImage());

        // Keyboard shortcuts
        document.addEventListener('keydown', (e) => {
            if (MediaLoader.imageModal && !MediaLoader.imageModal.classList.contains('d-none')) {
                if (e.key === 'Escape') MediaLoader.closeLightbox();
                if (e.key === 'ArrowLeft') MediaLoader.previousImage();
                if (e.key === 'ArrowRight') MediaLoader.nextImage();
            }
        });
    }

    /**
     * Open lightbox with image and find all images in same message
     * @param {HTMLImageElement} imgElement - The clicked image
     */
    static openImageLightbox(imgElement) {
        // Find all images in the same message bubble
        const messageBubble = imgElement.closest('.message-bubble');
        const allImages = messageBubble ?
            Array.from(messageBubble.querySelectorAll('.media-image')) :
            [imgElement];

        MediaLoader.currentModalImages = allImages;
        MediaLoader.currentImageIndex = allImages.indexOf(imgElement);

        // Show lightbox
        MediaLoader.imageModal.classList.remove('d-none');
        MediaLoader.displayImageInLightbox(MediaLoader.currentImageIndex);

        // Show/hide navigation buttons
        const prevBtn = MediaLoader.imageModal.querySelector('.media-lightbox-prev');
        const nextBtn = MediaLoader.imageModal.querySelector('.media-lightbox-next');
        const counter = MediaLoader.imageModal.querySelector('.media-lightbox-counter');

        if (allImages.length > 1) {
            prevBtn.classList.remove('d-none');
            nextBtn.classList.remove('d-none');
            counter.classList.remove('d-none');
        } else {
            prevBtn.classList.add('d-none');
            nextBtn.classList.add('d-none');
            counter.classList.add('d-none');
        }

        // Prevent body scroll
        document.body.style.overflow = 'hidden';
    }

    /**
     * Display image in lightbox at given index
     * @param {number} index - Image index
     */
    static displayImageInLightbox(index) {
        if (index < 0 || index >= MediaLoader.currentModalImages.length) {
            return;
        }

        const imgElement = MediaLoader.currentModalImages[index];
        const lightboxImg = MediaLoader.imageModal.querySelector('#mediaLightboxImage');
        lightboxImg.src = imgElement.src;

        // Update counter
        const current = MediaLoader.imageModal.querySelector('#mediaLightboxCurrent');
        const total = MediaLoader.imageModal.querySelector('#mediaLightboxTotal');
        current.textContent = index + 1;
        total.textContent = MediaLoader.currentModalImages.length;

        // Update navigation button states
        const prevBtn = MediaLoader.imageModal.querySelector('.media-lightbox-prev');
        const nextBtn = MediaLoader.imageModal.querySelector('.media-lightbox-next');

        prevBtn.style.opacity = index === 0 ? '0.5' : '1';
        nextBtn.style.opacity = index === MediaLoader.currentModalImages.length - 1 ? '0.5' : '1';
    }

    /**
     * Show previous image in lightbox
     */
    static previousImage() {
        if (MediaLoader.currentImageIndex > 0) {
            MediaLoader.currentImageIndex--;
            MediaLoader.displayImageInLightbox(MediaLoader.currentImageIndex);
        }
    }

    /**
     * Show next image in lightbox
     */
    static nextImage() {
        if (MediaLoader.currentImageIndex < MediaLoader.currentModalImages.length - 1) {
            MediaLoader.currentImageIndex++;
            MediaLoader.displayImageInLightbox(MediaLoader.currentImageIndex);
        }
    }

    /**
     * Close lightbox modal
     */
    static closeLightbox() {
        MediaLoader.imageModal.classList.add('d-none');
        document.body.style.overflow = ''; // Restore scroll
    }

    /**
     * Create video play button overlay element
     * @returns {HTMLElement} Play button div
     */
    static createPlayButtonOverlay() {
        const overlay = document.createElement('div');
        overlay.className = 'video-play-button';
        overlay.innerHTML = '<i class="fas fa-play"></i>';
        return overlay;
    }

    /**
     * Reinitialize observer for newly added media elements
     * Call this after new messages are inserted into DOM
     */
    static observeNewMedia() {
        if (!MediaLoader.observer) {
            MediaLoader.initMediaLazyLoader();
        }

        document.querySelectorAll('.media-lazy-placeholder:not([data-loaded])').forEach(placeholder => {
            MediaLoader.observer.observe(placeholder);
        });
    }

    // ──────────────────────────────────────────────
    //  Profile Picture Observer
    // ──────────────────────────────────────────────

    /**
     * Initialize a dedicated Intersection Observer for profile picture divs
     * marked with data-profilepicture="true".
     *
     * Call this once on page load.  It watches for elements like:
     *   <div data-usermediaid="abc-123" data-profilepicture="true"></div>
     *
     * The observer lazy-loads the profile picture: IndexedDB → presigned URL →
     * download blob → cache → render as a circular <img> inside the container.
     */
    static initProfilePictureObserver() {
        if (MediaLoader.profilePictureObserver) {
            return; // Already initialized
        }

        const options = {
            root: null,        // Use the viewport (profile pictures are typically in the header / sidebar)
            rootMargin: '50px',
            threshold: 0.01
        };

        MediaLoader.profilePictureObserver = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting && !entry.target.dataset.profileLoaded) {
                    MediaLoader.loadProfilePicture(entry.target);
                }
            });
        }, options);

        // Observe every profile-picture placeholder already in the DOM
        document.querySelectorAll('[data-profilepicture="true"]').forEach(el => {
            MediaLoader.profilePictureObserver.observe(el);
        });
    }

    /**
     * Load a single profile picture into the placeholder div.
     *
     * Flow:
     *   1. Guard against duplicate loads (data-profile-loaded flag + Set).
     *   2. Try IndexedDB cache first.
     *   3. On miss → fetch presigned URL from /api/media/pre-signed-url/{mediaId}.
     *   4. Download the image blob from the presigned URL.
     *   5. Cache blob in IndexedDB via MediaCache.
     *   6. Render a circular <img> tag inside the placeholder.
     *
     * @param {HTMLElement} placeholderEl - The div with data-usermediaid + data-profilepicture
     */
    static async loadProfilePicture(placeholderEl) {
        const mediaId = placeholderEl.dataset.usermediaid;
        const userId = placeholderEl.dataset.userid;

        try {

            //show loader spinner while loading
            MediaLoader.showLoadingSpinner(placeholderEl);

            // ── 1. Check IndexedDB cache ──
            const cachedBlob = await MediaCache.getFromCache(mediaId);

            if (cachedBlob) {
                const blobUrl = MediaCache.getBlobAsUrl(cachedBlob);
                MediaLoader.renderProfilePicture(placeholderEl, blobUrl);
                MediaLoader.loadedProfilePictureIds.add(mediaId);
                placeholderEl.dataset.profileLoaded = 'true';
                return;
            }

            // ── 2. Fetch presigned URL from backend ──
            const downloadUrl = `${ctx}/api/media/pre-signed-url/${userId}/${mediaId}`;
            const urlResponse = await fetch(downloadUrl);

            if (!urlResponse.ok) {
                throw new Error(`HTTP ${urlResponse.status}`);
            }

            const urlResponseData = await urlResponse.json();
            const data = urlResponseData.data && urlResponseData.data.length > 0
                ? urlResponseData.data[0]
                : urlResponseData;

            const presignedUrl = data.presignedDownloadUrl;

            if (!presignedUrl) {
                console.warn(`[mediaLoader] No presigned URL for profile picture mediaId=${mediaId}`);
                placeholderEl.dataset.profileLoaded = 'true';
                return;
            }

            // ── 3. Download the image blob ──
            const blobResponse = await fetch(presignedUrl);
            if (!blobResponse.ok) {
                throw new Error(`Failed to download profile picture: HTTP ${blobResponse.status}`);
            }

            const blob = await blobResponse.blob();

            // ── 4. Cache for future loads ──
            await MediaCache.putInCache(mediaId, 'IMAGE', blob);

            // ── 5. Render ──
            const blobUrl = MediaCache.getBlobAsUrl(blob);
            MediaLoader.renderProfilePicture(placeholderEl, blobUrl);
            MediaLoader.loadedProfilePictureIds.add(mediaId);
            placeholderEl.dataset.profileLoaded = 'true';

        } catch (error) {
            console.warn(`[mediaLoader] Failed to load profile picture ${mediaId}:`, error);
            placeholderEl.dataset.profileLoaded = 'true';
        }
    }

    /**
     * Render the profile picture <img> inside the placeholder div.
     *
     * The image fills the parent .cs-user-avatar circle via CSS:
     * width/height 100%, object-fit cover, border-radius 50%.
     *
     * @param {HTMLElement} placeholderEl - The div that holds data-profilepicture
     * @param {string} srcUrl - Blob URL or presigned URL to use as img src
     */
    static renderProfilePicture(placeholderEl, srcUrl) {
        // Clear any existing content
        placeholderEl.innerHTML = '';

        const img = document.createElement('img');
        img.src = srcUrl;
        img.alt = 'Profile picture';
        img.classList.add('pf-avatar');

        img.onload = () => {
            img.style.opacity = '1';
        };

        img.onerror = () => {
            console.warn('[mediaLoader] Profile picture image failed to load');
            // Keep the initial-letter fallback visible (the sibling span.cs-user-initial)
        };

        placeholderEl.appendChild(img);
    }

    /**
     * Re-scan the DOM for new profile-picture elements and start observing them.
     * Call this after new UI sections containing profile pictures are inserted.
     */
    static observeNewProfilePictures() {
        if (!MediaLoader.profilePictureObserver) {
            MediaLoader.initProfilePictureObserver();
        }

        document.querySelectorAll('[data-profilepicture="true"]:not([data-profile-loaded])')
            .forEach(el => {
                MediaLoader.profilePictureObserver.observe(el);
            });
    }
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', async function () {
    // Initialize IndexedDB cache
    await MediaCache.initIndexedDB();

    // Initialize media lazy loader (chat messages)
    MediaLoader.initMediaLazyLoader();

    // Initialize profile picture observer (header, sidebar, etc.)
    MediaLoader.initProfilePictureObserver();
});
