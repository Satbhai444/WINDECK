const fs = require('fs');
let c = fs.readFileSync('desktop_ui.html', 'utf8');

c = c.replace(/<div id="view-dashboard"[\s\S]*?<!-- Editor View -->/, '<!-- Editor View -->');
c = c.replace(/<!-- Settings View -->[\s\S]*?<\/div>\s*<\/div>\s*<!-- Toast Notification -->/, '</div>\n\n    <!-- Toast Notification -->');
c = c.replace(/<button onclick="showView\('view-dashboard'\)"[\s\S]*?<button onclick="showView\('view-editor'\)"/, '<button onclick="showView(\'view-editor\')"');
c = c.replace(/<button onclick="showSettings\(\)"[\s\S]*?<\/div>\s*<!-- Version Info -->/, '</div>\n\n            <!-- Version Info -->');
c = c.replace(/<button onclick="setAssetTab\('system'\)"[\s\S]*?<\/button>/, '');
c = c.replace(/<div id="asset-list-system"[\s\S]*?<!-- Populated by JS -->\s*<\/div>/, '');
c = c.replace(/<input type="text" id="asset-search"[\s\S]*?class="w-full bg-black\/30/, 
<input type="text" id="asset-search" oninput="filterAssets()"
placeholder="Search Apps, Websites..."
class="w-full bg-black/30);

if (!c.includes('animateSearchPlaceholder')) {
    c = c.replace(/<\/script>\s*<\/body>/, 

    // Animated Search Placeholder
    function animateSearchPlaceholder() {
        const searchInput = document.getElementById('asset-search');
        if (!searchInput) return;
        const placeholders = ['Search Instagram...', 'Search YouTube...', 'Search VS Code...', 'Search Chrome...'];
        let idx = 0;
        setInterval(() => {
            idx = (idx + 1) % placeholders.length;
            searchInput.placeholder = placeholders[idx];
        }, 3000);
    }
    animateSearchPlaceholder();
</script>
</body>);
}

c = c.replace(/showView\('view-dashboard'\);/g, "showView('view-editor');");
c = c.replace(/ipcRenderer\.on\('telemetry-update'[\s\S]*?\}\);/, '');
c = c.replace(/const availableAssets = \[[\s\S]*?\];/, const availableAssets = [];);

fs.writeFileSync('desktop_ui.html', c);
console.log('Modified successfully');
