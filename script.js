document.addEventListener('DOMContentLoaded', () => {
    // --- SIDE PANEL & ELASTIC HOVER TRIGGER ---
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

    // --- SPA VIEW ROUTER ---
    const routes = document.querySelectorAll('.nav-route');
    const views = document.querySelectorAll('.view');

    function switchView(targetId) {
        views.forEach(view => {
            if (view.id === targetId) {
                view.classList.add('active');
            } else {
                view.classList.remove('active');
            }
        });
        sidePanel.classList.remove('open');
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    routes.forEach(route => {
        route.addEventListener('click', (e) => {
            e.preventDefault();
            const target = route.getAttribute('data-target');
            if (target) switchView(target);
        });
    });

    // --- THEME & MODE SWITCHER ---
    const themeBtn = document.getElementById('theme-btn');
    const themeLabel = document.getElementById('theme-label');
    const modeBtn = document.getElementById('mode-btn');
    const modeLabel = document.getElementById('mode-label');
    const htmlRoot = document.documentElement;

    const themes = ['neon', 'ocean', 'sunset'];
    let currentThemeIndex = 0;

    themeBtn.addEventListener('click', () => {
        currentThemeIndex = (currentThemeIndex + 1) % themes.length;
        const newTheme = themes[currentThemeIndex];
        htmlRoot.setAttribute('data-theme', newTheme);
        themeLabel.textContent = newTheme.charAt(0).toUpperCase() + newTheme.slice(1);
    });

    modeBtn.addEventListener('click', () => {
        const currentMode = htmlRoot.getAttribute('data-mode');
        if (currentMode === 'dark') {
            htmlRoot.setAttribute('data-mode', 'light');
            modeLabel.textContent = 'Light';
        } else {
            htmlRoot.setAttribute('data-mode', 'dark');
            modeLabel.textContent = 'Dark';
        }
    });

    // --- TERMINAL COMMAND CONTROLLER ---
    const inputElement = document.getElementById('terminal-input');
    const terminalContainer = document.getElementById('interactive-terminal');
    const galleryContainer = document.getElementById('screenshot-gallery');
    const contentArea = document.getElementById('terminal-content');

    if (inputElement) {
        inputElement.addEventListener('keydown', (e) => {
            if (e.key === 'Enter') {
                const command = inputElement.value.trim().toLowerCase();
                inputElement.value = '';

                const logs = document.createElement('p');
                logs.style.margin = '0.5rem 0';
                logs.style.fontSize = '0.9rem';

                if (command === 'screenshots') {
                    terminalContainer.classList.add('active-pill-morph');
                    galleryContainer.classList.remove('hidden');
                    logs.style.color = '#00ffcc';
                    logs.innerText = '» Morphing UI parameters engaged. Displaying gallery...';
                    contentArea.insertBefore(logs, inputElement.parentElement);
                } else if (command === '/about' || command === 'about') {
                    logs.style.color = '#00ffcc';
                    logs.innerText = '» Routing to GET /about endpoint...';
                    contentArea.insertBefore(logs, inputElement.parentElement);
                    setTimeout(() => switchView('about-view'), 600);
                } else {
                    logs.style.color = '#ff5f56';
                    logs.innerText = `bash: command not found: ${command}. Try 'screenshots' or '/about'.`;
                    contentArea.insertBefore(logs, inputElement.parentElement);
                }
            }
        });
    }
});
