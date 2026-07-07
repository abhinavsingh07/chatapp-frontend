/**
 * mediaLoader.js
 * Handles lazy-loading of media (images and videos) in chat messages using Intersection Observer.
 * 
 * Features:
 * - Lazy load pre-signed URLs only when media enters viewport
 * - Support for IMAGE and VIDEO media types
 * - Full-width image display with lightbox preview modal
 * - Video play button overlay
 * - Silent error handling (empty placeholder on failure)
 * - Responsive grid layout
 */

class MediaLoader {
    static observer = null;
    static loadedMediaIds = new Set(); // Track loaded media to avoid duplicate API calls
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
     * Load a single media item when it becomes visible
     * @param {HTMLElement} placeholderElement - The placeholder div element
     */
    static loadMediaForElement(placeholderElement) {
        const mediaId = placeholderElement.dataset.mediaId;
        const mediaType = placeholderElement.dataset.mediaType;

        if (!mediaId || MediaLoader.loadedMediaIds.has(mediaId)) {
            placeholderElement.dataset.loaded = 'true';
            return;
        }

        let downloadUrl = `${ctx}/api/media/pre-signed-url/${mediaId}`;
        // Fetch pre-signed URL from backend
        fetch(downloadUrl)
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP ${response.status}`);
                }
                return response.json();
            })
            .then(responseData => {
                // Extract presigned URL from response (check data array and presignedDownloadUrl field)
                const data = responseData.data && responseData.data.length > 0
                    ? responseData.data[0]
                    : responseData;

                const presignedUrl = data.presignedDownloadUrl;

                if (!presignedUrl) {
                    console.warn(`[mediaLoader] No presigned URL in response for mediaId=${mediaId}`);
                    placeholderElement.dataset.loaded = 'true';
                    return;
                }

                MediaLoader.renderMedia(placeholderElement, mediaType, presignedUrl);
                MediaLoader.loadedMediaIds.add(mediaId);
                placeholderElement.dataset.loaded = 'true';
            })
            .catch(error => {
                // Silent error handling - just leave placeholder empty
                console.warn(`[mediaLoader] Failed to load media ${mediaId}:`, error);
                placeholderElement.dataset.loaded = 'true';
            });
    }

    /**
     * Render media element (image or video) into placeholder
     * @param {HTMLElement} placeholderElement - The placeholder div
     * @param {string} mediaType - 'IMAGE' or 'VIDEO'
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
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', function () {
    MediaLoader.initMediaLazyLoader();
});
