// Dynamic text transition structure
const morphText = document.getElementById('morph-text');
const titles = ["Noctalia-Shell", "Caelestia-Shell", "Noctaelestia-Shell"];
let count = 0;

/* Un-comment this block if you want the header to morph automatically over time:
setInterval(() => {
    morphText.style.opacity = 0;
    morphText.style.transform = "scale(0.95) blur(8px)";
    
    setTimeout(() => {
        count = (count + 1) % titles.length;
        morphText.innerText = titles[count];
        morphText.style.opacity = 1;
        morphText.style.transform = "scale(1) blur(0px)";
    }, 500);
}, 4000);
*/
