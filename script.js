document.addEventListener('DOMContentLoaded', () => {
    // --- SIDE PANEL TOGGLE & HOVER ---
    const sidePanel = document.getElementById('side-panel');
    const hoverZone = document.getElementById('hover-zone');
    const panelToggle = document.getElementById('panel-toggle');

    function openPanel() {
        sidePanel.classList.add('open');
    }

    function closePanel() {
        sidePanel.classList.remove('open');
    }

    hoverZone.addEventListener('mouseenter', openPanel);
    panelToggle.addEventListener('click', (e) => {
        e.stopPropagation();
        sidePanel.classList.toggle('open');
    });

    document.addEventListener('click', (e) => {
        if (!sidePanel.contains(e.target) && e.target !== hoverZone) {
            closePanel();
        }
    });

    // --- NAVIGATION ROUTER (ENDPOINT SYSTEM) ---
    const navRoutes = document.querySelectorAll('.nav-route');
    const views = {
        '/': document.getElementById('home-view'),
        '/about': document.getElementById('about-view')
    };

    function navigateTo(route) {
        Object.keys(views).forEach(r => {
            if (views[r]) {
                if (r === route) {
                    views[r].classList.add('active');
                } else {
                    views[r].classList.remove('active');
                }
            }
        });

        navRoutes.forEach(link => {
            if (link.getAttribute('data-route') === route) {
                link.classList.add('active-link');
            } else {
                link.classList.remove('active-link');
            }
        });

        closePanel();
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    navRoutes.forEach(btn => {
        btn.addEventListener('click', (e) => {
            e.preventDefault();
            e.stopPropagation();
            const route = btn.getAttribute('data-route');
            if (route) {
                navigateTo(route);
            }
        });
    });

    // --- THEME & MODE SWITCHERS ---
    const modeBtn = document.getElementById('mode-btn');
    const modeLabel = document.getElementById('mode-label');
    const themeBtn = document.getElementById('theme-btn');
    const themeLabel = document.getElementById('theme-label');
    const htmlRoot = document.documentElement;

    modeBtn.addEventListener('click', (e) => {
        e.stopPropagation();
        const isDark = htmlRoot.getAttribute('data-mode') === 'dark';
        htmlRoot.setAttribute('data-mode', isDark ? 'light' : 'dark');
        modeLabel.textContent = isDark ? '☀️ Light' : '🌙 Dark';
    });

    const themes = ['neon', 'ocean', 'sunset'];
    let themeIdx = 0;

    themeBtn.addEventListener('click', (e) => {
        e.stopPropagation();
        themeIdx = (themeIdx + 1) % themes.length;
        const nextTheme = themes[themeIdx];
        htmlRoot.setAttribute('data-theme', nextTheme);
        themeLabel.textContent = nextTheme.charAt(0).toUpperCase() + nextTheme.slice(1);
    });

    // --- FULLSCREEN LIGHTBOX MODAL ---
    const lightboxModal = document.getElementById('lightbox-modal');
    const lightboxImg = document.getElementById('lightbox-img');
    const lightboxClose = document.getElementById('lightbox-close');
    const galleryImages = document.querySelectorAll('.gallery-img');

    galleryImages.forEach(img => {
        img.addEventListener('click', () => {
            lightboxImg.src = img.src;
            lightboxModal.classList.add('active');
        });
    });

    function closeLightbox() {
        lightboxModal.classList.remove('active');
    }

    if (lightboxClose) {
        lightboxClose.addEventListener('click', closeLightbox);
    }

    if (lightboxModal) {
        lightboxModal.addEventListener('click', (e) => {
            if (e.target === lightboxModal) {
                closeLightbox();
            }
        });
    }

    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape' && lightboxModal && lightboxModal.classList.contains('active')) {
            closeLightbox();
        }
    });

    // --- INTERACTIVE TERMINAL (SCREENSHOTS & EXIT) ---
    const terminalInput = document.getElementById('terminal-input');
    const terminalContainer = document.getElementById('interactive-terminal');
    const galleryContainer = document.getElementById('screenshot-gallery');
    const contentArea = document.getElementById('terminal-content');

    if (terminalInput) {
        terminalInput.addEventListener('keydown', (e) => {
            if (e.key === 'Enter') {
                const command = terminalInput.value.trim().toLowerCase();
                terminalInput.value = '';

                const log = document.createElement('p');
                log.style.margin = '0.5rem 0';
                log.style.fontSize = '0.9rem';

                if (command === 'screenshots') {
                    terminalContainer.classList.add('active-pill-morph');
                    galleryContainer.classList.remove('hidden');
                    log.style.color = '#00ffcc';
                    log.innerText = '» Liquid morphing engaged. Displaying gallery...';
                    contentArea.insertBefore(log, terminalInput.parentElement);
                } else if (command === 'exit') {
                    terminalContainer.classList.remove('active-pill-morph');
                    galleryContainer.classList.add('hidden');
                    log.style.color = '#ffbd2e';
                    log.innerText = '» Closed gallery. Morphing state restored.';
                    contentArea.insertBefore(log, terminalInput.parentElement);
                } else if (command === '/about' || command === 'about') {
                    log.style.color = '#00ffcc';
                    log.innerText = '» Routing to /about endpoint...';
                    contentArea.insertBefore(log, terminalInput.parentElement);
                    setTimeout(() => navigateTo('/about'), 400);
                } else {
                    log.style.color = '#ff5f56';
                    log.innerText = `bash: command not found: ${command}. Try 'screenshots', 'exit', or '/about'.`;
                    contentArea.insertBefore(log, terminalInput.parentElement);
                }
            }
        });
    }
});
