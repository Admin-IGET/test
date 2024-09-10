document.addEventListener('DOMContentLoaded', () => { // ahoj koukas se na source code JS pro UvikOS! pokud mas pristup k editaci, prosim nenic!
    setInterval(updateTimeDate, 1000);
    changeWallpaper('default');
});

function updateTimeDate() {
    const now = new Date();
    document.getElementById('time').textContent = now.toLocaleTimeString();
    document.getElementById('date').textContent = now.toLocaleDateString();
}

function toggleStartMenu() {
    const startMenu = document.getElementById('start-menu');
    startMenu.classList.toggle('hidden');
}

function openSettings() {
    document.getElementById('settings').classList.remove('hidden');
}

function closeSettings() {
    document.getElementById('settings').classList.add('hidden');
}

function openApp(appName) {
    const urls = {
        notepad: "https://admin-iget.github.io/test/notepad.html",
        internet: "https://admin-iget.github.io/test/UvikSearch.html",
        youtube: "https://admin-iget.github.io/test/youtube.html",
        game: "https://admin-iget.github.io/test/UvikHra1.html",
        store: "https://admin-iget.github.io/test/UvikObchod.html" // URLY pro Okna.
    };
    createWindow(appName, `<iframe src="${urls[appName]}" width="100%" height="100%"></iframe>`);
}

function createWindow(title, content) {
    const appContainer = document.getElementById('app-container');
    const windowDiv = document.createElement('div');
    windowDiv.className = 'window';
    windowDiv.innerHTML = `
        <div class="window-titlebar">
            <span>${title}</span>
            <button onclick="closeWindow(this)">X</button>
        </div>
        <div class="window-content">${content}</div>
        <div class="window-resize-handle"></div>
    `;
    appContainer.appendChild(windowDiv);
    makeDraggable(windowDiv); // vyvolat posunovani oken
    makeResizable(windowDiv); // vyvolat meneni velikosti oken
    bringToFront(windowDiv);  // zkusit dat okna do spravneho poradi
}

function closeWindow(button) {
    button.closest('.window').remove();
}

function changeWallpaper(type) {
    if (type === 'default') {
        document.body.style.backgroundImage = 'url("https://admin-iget.github.io/test/f43981720.jpg")';
    } else if (type === 'custom') {
        const fileInput = document.getElementById('custom-wallpaper');
        const file = fileInput.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = function(e) {
                document.body.style.backgroundImage = `url("${e.target.result}")`;
            };
            reader.readAsDataURL(file);
        }
    }
}

function makeDraggable(element) {
    const titlebar = element.querySelector('.window-titlebar');
    
    titlebar.onmousedown = function (event) {
        bringToFront(element); // NEFUNKNI KOD : OPRAVIT dat okno nahoru kdyz se okno resizuje.

        let shiftX = event.clientX - element.getBoundingClientRect().left;
        let shiftY = event.clientY - element.getBoundingClientRect().top;

        function moveAt(pageX, pageY) {
            element.style.left = pageX - shiftX + 'px';
            element.style.top = pageY - shiftY + 'px';
        }

        function onMouseMove(event) {
            moveAt(event.pageX, event.pageY);
        }

        document.addEventListener('mousemove', onMouseMove);

        titlebar.onmouseup = function () {
            document.removeEventListener('mousemove', onMouseMove);
            titlebar.onmouseup = null;
        };
    };

    titlebar.ondragstart = function () {
        return false;
    };
}

function makeResizable(element) {
    const resizeHandle = element.querySelector('.window-resize-handle');
    
    resizeHandle.onmousedown = function (event) {
        disableIframes(); // Vypnout Iframy kdyz resizujes okno aby se celej UvikOS nerozbil

        function onMouseMove(event) {
            element.style.width = event.pageX - element.getBoundingClientRect().left + 'px';
            element.style.height = event.pageY - element.getBoundingClientRect().top + 'px';
        }

        document.addEventListener('mousemove', onMouseMove);

        resizeHandle.onmouseup = function () {
            document.removeEventListener('mousemove', onMouseMove);
            resizeHandle.onmouseup = null;
            enableIframes(); // Zase zapnout interakce z Iframy
        };
    };

    resizeHandle.ondragstart = function () {
        return false;
    };
}

// Disable iframe interactions (pointer-events: none)
function disableIframes() {
    const iframes = document.querySelectorAll('iframe');
    iframes.forEach(iframe => {
        iframe.style.pointerEvents = 'none';
    });
}

// Enable iframe interactions (pointer-events: auto)
function enableIframes() {
    const iframes = document.querySelectorAll('iframe');
    iframes.forEach(iframe => {
        iframe.style.pointerEvents = 'auto';
    });
}

function bringToFront(element) {
    const allWindows = document.querySelectorAll('.window');
    allWindows.forEach(win => win.style.zIndex = 100);
    element.style.zIndex = 101;
}

function openFileExplorer() {
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = '.html,.png,.txt,.jpg'; // limituje explorer na otevreni jen HTML, PNG, TXT, JPG, nemenit, nezmeni to funkci.

    input.onchange = function(event) {
        const file = event.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = function(e) {
                let contentUrl = e.target.result;
                let fileType = file.type;

                if (fileType.includes('image')) {
                    createWindow(file.name, `<img src="${contentUrl}" alt="${file.name}" style="width:100%;height:100%;">`);
                } else if (fileType === 'text/plain') {
                    createWindow(file.name, `<pre style="white-space: pre-wrap;">${e.target.result}</pre>`);
                } else if (fileType === 'text/html') {
                    createWindow(file.name, `<iframe src="${contentUrl}" width="100%" height="100%"></iframe>`);
                } else {
                    alert('Nepodporovaný typ souboru.');
                }
            };
            reader.readAsDataURL(file); // nacist vybrany soubor.
        }
    };

    input.click(); // otevrit explorerove browse okno kdyz je vyvolano.
}
