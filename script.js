document.addEventListener('DOMContentLoaded', () => {
    const inputElement = document.getElementById('terminal-input');
    const terminalContainer = document.getElementById('interactive-terminal');
    const galleryContainer = document.getElementById('screenshot-gallery');
    const contentArea = document.getElementById('terminal-content');

    inputElement.addEventListener('keydown', (e) => {
        if (e.key === 'Enter') {
            const command = inputElement.value.trim().toLowerCase();
            
            // Clear current input space for structural reuse
            inputElement.value = '';

            if (command === 'screenshots') {
                // Dynamically mutate container border structures to fluid pill layouts
                terminalContainer.classList.add('active-pill-morph');
                
                // Animate image grid rendering context
                galleryContainer.classList.remove('hidden');

                // Print acknowledgment trace inside console view
                const logs = document.createElement('p');
                logs.style.color = '#00ffcc';
                logs.style.margin = '0.5rem 0';
                logs.style.fontSize = '0.9rem';
                logs.innerText = '» Morphing UI parameters engaged. Displaying gallery...';
                contentArea.insertBefore(logs, inputElement.parentElement);
            } else {
                // Handle unknown input events gracefully
                const errorLog = document.createElement('p');
                errorLog.style.color = '#ff5f56';
                errorLog.style.margin = '0.5rem 0';
                errorLog.style.fontSize = '0.9rem';
                errorLog.innerText = `bash: command not found: ${command}`;
                contentArea.insertBefore(errorLog, inputElement.parentElement);
            }
        }
    });
});
