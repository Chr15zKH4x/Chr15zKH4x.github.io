document.addEventListener('DOMContentLoaded', () => {
    // --- ELASTIC SIDE PANEL & HOVER ZONE ---
    const sidePanel = document.getElementById('side-panel');
    const hoverZone = document.getElementById('hover-zone');
    const panelToggle = document.getElementById('panel-toggle');

    function togglePanel() {
        sidePanel.classList.toggle('open');
    }

    hoverZone.addEventListener('mouseenter', togglePanel);
    panelToggle.addEventListener('click', togglePanel);
    sidePanel.addEventListener('mouseleave', () => {
        sidePanel.classList.remove('open');
    });

    // --- SPA ROUTER SYSTEM FOR ENDPOINTS (/ and /about) ---
    const navRoutes = document.querySelectorAll('.nav-route');
    const views = {
        '/': document.getElementById('home-view'),
        '/about': document.getElementById('about-view')
    };

    function navigateTo(route) {
        Object.keys(views).forEach(r => {
            if (r === route) {
                views[r].classList.add('active');
            } else {
                views[r].classList.remove('active');
            }
        });

        navRoutes.forEach(link => {
            if (link.getAttribute('data-route') === route) {
                link.classList.add('active-link');
            } else {
                link.classList.remove('active-link');
            }
        });

        sidePanel.classList.remove('open');
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    navRoutes.forEach(link => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            const route = link.getAttribute('data-route');
            if (route) navigateTo(route);
        });
    });

    // --- THEME & MODE SWITCHERS ---
    const modeBtn = document.getElementById('mode-btn');
    const modeLabel = document.getElementById('mode-label');
    const themeBtn = document.getElementById('theme-btn');
    const themeLabel = document.getElementById('theme-label');
    const htmlRoot = document.documentElement;

    modeBtn.addEventListener('click', () => {
        const isDark = htmlRoot.getAttribute('data-mode') === 'dark';
        htmlRoot.setAttribute('data-mode', isDark ? 'light' : 'dark');
        modeLabel.textContent = isDark ? '☀️ Light' : '🌙 Dark';
    });

    const themes = ['neon', 'ocean', 'sunset'];
    let themeIdx = 0;

    themeBtn.addEventListener('click', () => {
        themeIdx = (themeIdx + 1) % themes.length;
        const nextTheme = themes[themeIdx];
        htmlRoot.setAttribute('data-theme', nextTheme);
        themeLabel.textContent = nextTheme.charAt(0).toUpperCase() + nextTheme.slice(1);
    });

    // --- INTERACTIVE TERMINAL ---
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
                    log.innerText = '» Morphing UI engaged. Displaying gallery...';
                    contentArea.insertBefore(log, terminalInput.parentElement);
                } else if (command === '/about' || command === 'about') {
                    log.style.color = '#00ffcc';
                    log.innerText = '» Routing to /about endpoint...';
                    contentArea.insertBefore(log, terminalInput.parentElement);
                    setTimeout(() => navigateTo('/about'), 500);
                } else {
                    log.style.color = '#ff5f56';
                    log.innerText = `bash: command not found: ${command}. Try 'screenshots' or '/about'.`;
                    contentArea.insertBefore(log, terminalInput.parentElement);
                }
            }
        });
    }
});
