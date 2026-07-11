/**
 * MediaCache.js
 * IndexedDB caching layer for media blobs.
 * Stores cached media locally to reduce API calls and S3 bandwidth.
 * Implements LRU (Least Recently Used) cleanup when quota exceeded.
 *
 * Usage:
 *   await MediaCache.initIndexedDB();
 *   const blob = await MediaCache.getFromCache(mediaId);
 *   await MediaCache.putInCache(mediaId, mediaType, blob);
 *   const url = MediaCache.getBlobAsUrl(blob);
 *   await MediaCache.clearAllCache();
 */

class MediaCache {
    static dbName = 'chatsphere-media-cache';
    static dbVersion = 1;
    static storeName = 'mediaCache';
    static db = null;
    static isInitialized = false;
    static isAvailable = true; // Track if IndexedDB is available/working
    static DEBUG = true; // Set to true for development logging

    // Storage limits per media type (in bytes)
    static SIZE_LIMITS = {
        IMAGE: 10 * 1024 * 1024,      // 10 MB
        VIDEO: 50 * 1024 * 1024,     // 50 MB
        DOCUMENT: 10 * 1024 * 1024   // 10 MB
    };

    static TOTAL_QUOTA = 1 * 1024 * 1024 * 1024; // 1 GB total cache limit

    /**
     * Initialize IndexedDB database and object stores
     * @returns {Promise<void>}
     */
    static async initIndexedDB() {
        if (MediaCache.isInitialized) {
            return;
        }

        try {
            return new Promise((resolve, reject) => {
                const request = indexedDB.open(MediaCache.dbName, MediaCache.dbVersion);

                request.onerror = () => {
                    console.warn('[MediaCache] IndexedDB open failed');
                    MediaCache.isAvailable = false;
                    reject(request.error);
                };

                request.onsuccess = () => {
                    MediaCache.db = request.result;
                    MediaCache.isInitialized = true;
                    MediaCache._debugLog('[MediaCache] IndexedDB initialized successfully');

                    // Request persistent storage to prevent browser auto-cleanup
                    // MediaCache.requestStoragePersistence();

                    resolve();
                };

                request.onupgradeneeded = (event) => {
                    const db = event.target.result;

                    // Create object store if it doesn't exist
                    if (!db.objectStoreNames.contains(MediaCache.storeName)) {
                        const store = db.createObjectStore(MediaCache.storeName, { keyPath: 'mediaId' });

                        // Create index on lastAccessed for LRU cleanup
                        store.createIndex('lastAccessed', 'lastAccessed', { unique: false });

                        MediaCache._debugLog('[MediaCache] Object store created');
                    }
                };
            });
        } catch (error) {
            console.warn('[MediaCache] Failed to initialize IndexedDB:', error);
            MediaCache.isAvailable = false;
        }
    }

    /**
     * Retrieve media blob from cache
     * @param {string} mediaId - Media identifier
     * @returns {Promise<Blob|null>} Cached blob or null if not found
     */
    static async getFromCache(mediaId) {
        if (!MediaCache.isAvailable || !MediaCache.db) {
            return null;
        }

        try {
            return new Promise((resolve, reject) => {
                const transaction = MediaCache.db.transaction([MediaCache.storeName], 'readwrite');
                const store = transaction.objectStore(MediaCache.storeName);
                const request = store.get(mediaId);

                request.onsuccess = () => {
                    const result = request.result;
                    if (result) {
                        // Update lastAccessed timestamp on hit
                        result.lastAccessed = Date.now();
                        const updateRequest = store.put(result);
                        updateRequest.onerror = () => console.warn('[MediaCache] Failed to update timestamp');

                        MediaCache._debugLog(`[MediaCache] Cache HIT for mediaId=${mediaId}`);
                        resolve(result.blob);
                    } else {
                        MediaCache._debugLog(`[MediaCache] Cache MISS for mediaId=${mediaId}`);
                        resolve(null);
                    }
                };

                request.onerror = () => {
                    console.warn('[MediaCache] Failed to retrieve from cache:', request.error);
                    resolve(null); // Graceful fallback
                };
            });
        } catch (error) {
            console.warn('[MediaCache] Error retrieving from cache:', error);
            return null;
        }
    }

    /**
     * Store media blob in cache with size validation and quota management
     * @param {string} mediaId - Media identifier
     * @param {string} mediaType - 'IMAGE', 'VIDEO', or 'DOCUMENT'
     * @param {Blob} blob - Media blob to cache
     * @returns {Promise<boolean>} True if cached, false if skipped/failed
     */
    static async putInCache(mediaId, mediaType, blob) {
        if (!MediaCache.isAvailable || !MediaCache.db) {
            return false;
        }

        try {
            // Validate blob size against type limit
            const sizeLimit = MediaCache.SIZE_LIMITS[mediaType];
            if (blob.size > sizeLimit) {
                console.warn(
                    `[MediaCache] Blob too large (${(blob.size / 1024 / 1024).toFixed(2)}MB > ${(sizeLimit / 1024 / 1024).toFixed(0)}MB limit) for type ${mediaType}. Skipping cache.`
                );
                return false;
            }

            // Check if caching would exceed total quota
            const totalUsed = await MediaCache.getTotalCacheSize();
            if (totalUsed + blob.size > MediaCache.TOTAL_QUOTA) {
                MediaCache._debugLog('[MediaCache] Quota exceeded. Performing LRU cleanup...');
                await MediaCache.performLRUCleanup(blob.size);
            }

            return new Promise((resolve, reject) => {
                const transaction = MediaCache.db.transaction([MediaCache.storeName], 'readwrite');
                const store = transaction.objectStore(MediaCache.storeName);

                const cacheEntry = {
                    mediaId,
                    mediaType,
                    blob,
                    size: blob.size,
                    lastAccessed: Date.now(),
                    createdAt: Date.now()
                };

                const request = store.put(cacheEntry);

                request.onsuccess = () => {
                    MediaCache._debugLog(`[MediaCache] Cached mediaId=${mediaId} (${(blob.size / 1024 / 1024).toFixed(2)}MB)`);
                    resolve(true);
                };

                request.onerror = () => {
                    console.warn('[MediaCache] Failed to cache:', request.error);
                    resolve(false);
                };
            });
        } catch (error) {
            console.warn('[MediaCache] Error putting to cache:', error);
            return false;
        }
    }

    /**
     * Get total size of all cached media
     * @returns {Promise<number>} Total bytes used
     */
    static async getTotalCacheSize() {
        if (!MediaCache.isAvailable || !MediaCache.db) {
            return 0;
        }

        try {
            return new Promise((resolve) => {
                const transaction = MediaCache.db.transaction([MediaCache.storeName], 'readonly');
                const store = transaction.objectStore(MediaCache.storeName);
                const request = store.getAll();

                request.onsuccess = () => {
                    const entries = request.result;
                    const totalSize = entries.reduce((sum, entry) => sum + (entry.size || 0), 0);
                    resolve(totalSize);
                };

                request.onerror = () => {
                    console.warn('[MediaCache] Failed to get total cache size');
                    resolve(0);
                };
            });
        } catch (error) {
            console.warn('[MediaCache] Error calculating cache size:', error);
            return 0;
        }
    }

    /**
     * Perform LRU cleanup: delete oldest accessed items until space is available
     * @param {number} neededSpace - Bytes needed to free up
     * @returns {Promise<void>}
     */
    static async performLRUCleanup(neededSpace = MediaCache.TOTAL_QUOTA / 2) {
        if (!MediaCache.isAvailable || !MediaCache.db) {
            return;
        }

        try {
            return new Promise((resolve) => {
                const transaction = MediaCache.db.transaction([MediaCache.storeName], 'readwrite');
                const store = transaction.objectStore(MediaCache.storeName);
                const index = store.index('lastAccessed');
                const request = index.getAll(); // Get all in order

                request.onsuccess = () => {
                    const entries = request.result;
                    let freedSpace = 0;
                    let deletedCount = 0;

                    // Delete oldest entries until we have enough space
                    for (let entry of entries) {
                        if (freedSpace >= neededSpace) break;

                        const deleteRequest = store.delete(entry.mediaId);
                        deleteRequest.onerror = () => console.warn('[MediaCache] Failed to delete entry');

                        freedSpace += entry.size;
                        deletedCount++;
                    }

                    MediaCache._debugLog(
                        `[MediaCache] LRU cleanup: Deleted ${deletedCount} items, freed ${(freedSpace / 1024 / 1024).toFixed(2)}MB`
                    );
                    resolve();
                };

                request.onerror = () => {
                    console.warn('[MediaCache] Failed to perform LRU cleanup');
                    resolve();
                };
            });
        } catch (error) {
            console.warn('[MediaCache] Error during LRU cleanup:', error);
        }
    }

    // /**
    //  * Request persistent storage from the browser so cached data
    //  * is not automatically evicted under storage pressure.
    //  * @returns {Promise<boolean>} True if persistent storage granted
    //  */
    // static async requestStoragePersistence() {
    //     if (navigator.storage && navigator.storage.persist) {
    //         try {
    //             const granted = await navigator.storage.persist();
    //             if (granted) {
    //                 console.log('[MediaCache] Persistent storage granted — browser will not auto-clear cached data.');
    //             } else {
    //                 console.warn('[MediaCache] Persistent storage denied — cached data may be evicted under storage pressure.');
    //             }
    //             return granted;
    //         } catch (error) {
    //             console.warn('[MediaCache] Failed to request storage persistence:', error);
    //             return false;
    //         }
    //     } else {
    //         console.warn('[MediaCache] navigator.storage.persist API not available in this browser.');
    //         return false;
    //     }
    // }

    /**
     * Convert blob to object URL
     * @param {Blob} blob - Media blob
     * @returns {string} blob URL (blob:...)
     */
    static getBlobAsUrl(blob) {
        return URL.createObjectURL(blob);
    }

    /**
     * Clear all cached media (useful for manual cache clearing UI)
     * @returns {Promise<void>}
     */
    static async clearAllCache() {
        if (!MediaCache.isAvailable || !MediaCache.db) {
            return;
        }

        try {
            return new Promise((resolve) => {
                const transaction = MediaCache.db.transaction([MediaCache.storeName], 'readwrite');
                const store = transaction.objectStore(MediaCache.storeName);
                const request = store.clear();

                request.onsuccess = () => {
                    MediaCache._debugLog('[MediaCache] All cache cleared');
                    resolve();
                };

                request.onerror = () => {
                    console.warn('[MediaCache] Failed to clear cache');
                    resolve();
                };
            });
        } catch (error) {
            console.warn('[MediaCache] Error clearing cache:', error);
        }
    }

    /**
     * Internal debug logging function
     * Logs only if MediaCache.DEBUG is true
     * @param  {...any} args - Arguments to log
     */
    static _debugLog(...args) {
        if (MediaCache.DEBUG && typeof console !== 'undefined' && console.log) {
            console.log.apply(console, args);
        }
    }
}


window.MediaCache = MediaCache; // Expose globally for legacy code or inline scripts