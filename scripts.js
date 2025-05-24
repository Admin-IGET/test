document.addEventListener('DOMContentLoaded', function() {
    setInterval(updateTimeDate, 1000);

    const savedWallpaper = localStorage.getItem('uvikWallpaper');
    const twilightMode = localStorage.getItem('uvikTwilight') === "true";

    if (twilightMode) {
        enableTwilightMode();
    } else if (savedWallpaper) {
        document.body.style.backgroundImage = `url("${savedWallpaper}")`;
    } else {
        changeWallpaper('default');
    }

    loadDesktopIcons();
});

window.addEventListener('DOMContentLoaded', () => {
  const taskbarText = document.getElementById('taskbar-text');
  
  if (taskbarText) {
    taskbarText.style.display = 'block';

    setTimeout(() => {
      taskbarText.style.display = 'none';
    }, 3000); 
  }
});

let isAltPressed = false;
let isDragging = false;

// handlee alt key for window dragging
document.addEventListener('keydown', function(event) {
    if (event.altKey) {
        document.body.classList.add('alt-pressed');
        if (activeDragCancel) activeDragCancel();
        if (activeResizeCancel) activeResizeCancel();
    }
    
    // reset icons when ctrl + alt is pressed
    if (event.ctrlKey && event.altKey) {
        localStorage.removeItem('desktopIcons');
        loadDesktopIcons();
    }
});

document.addEventListener('keyup', function(event) {
    if (!event.altKey) {
        document.body.classList.remove('alt-pressed');
    }
});

function disableDraggableAndResizable() {
    const windows = document.querySelectorAll('.window');
    windows.forEach(window => {
        const titlebar = window.querySelector('.window-titlebar');
        titlebar.onmousedown = function(event) {
            event.preventDefault(); 
        };

        const resizeHandle = window.querySelector('.window-resize-handle');
        resizeHandle.onmousedown = function(event) {
            event.preventDefault(); 
        };
    });
}

function enableDraggableAndResizable() {
    const windows = document.querySelectorAll('.window');
    windows.forEach(window => {
        const titlebar = window.querySelector('.window-titlebar');
        titlebar.onmousedown = function(event) {
            if (isAltPressed) return; 
            bringToFront(window);
            disableIframes();
            disableTaskbar();

            const shiftX = event.clientX - window.offsetLeft;
            const shiftY = event.clientY - window.offsetTop;

            function moveAt(pageX, pageY) {
                window.style.left = pageX - shiftX + 'px';
                window.style.top = pageY - shiftY + 'px';
            }

            function onMouseMove(event) {
                if (isAltPressed) {
                    cancelDrag();
                    return;
                }
                moveAt(event.pageX, event.pageY);
            }

            function cancelDrag() {
                if (isDragging) {
                    isDragging = false; 
                    document.removeEventListener('mousemove', onMouseMove);
                    titlebar.onmouseup = null;
                    enableIframes();
                    enableTaskbar();
                }
            }

            isDragging = true;
            document.addEventListener('mousemove', onMouseMove);

            titlebar.onmouseup = function() {
                cancelDrag();
            };
        };

        const resizeHandle = window.querySelector('.window-resize-handle');
        resizeHandle.onmousedown = function(event) {
            if (isAltPressed) return; 

            disableIframes();
            disableTaskbar();

            function onMouseMove(event) {
                if (isAltPressed) {
                    cancelResize();
                    return;
                }
                window.style.width = (event.pageX - window.offsetLeft) + 'px';
                window.style.height = (event.pageY - window.offsetTop) + 'px';
            }

            function cancelResize() {
                document.removeEventListener('mousemove', onMouseMove);
                resizeHandle.onmouseup = null;
                enableIframes();
                enableTaskbar();
            }

            document.addEventListener('mousemove', onMouseMove);

            resizeHandle.onmouseup = function() {
                cancelResize();
            };
        };
    });
}

function updateTimeDate() {
    var now = new Date();
    var timeString = now.toLocaleTimeString();
    var dateString = now.toLocaleDateString();
    var formattedTime = timeString.split(" ")[0]; 
    document.getElementById('time').innerHTML = formattedTime + "<br>" + dateString; 
}

function enableTwilightMode() {
    const twilightWallpaper = "https://admin-iget.github.io/test/twilight.PNG";
    document.body.style.backgroundImage = `url("${twilightWallpaper}")`;
    localStorage.setItem('uvikTwilight', "true");
    console.log("Twilight mode enabled. Wallpaper is now locked.");
}

function disableTwilightMode() {
    localStorage.setItem('uvikTwilight', "false");
    const savedWallpaper = localStorage.getItem('uvikWallpaper');
    if (savedWallpaper) {
        document.body.style.backgroundImage = `url("${savedWallpaper}")`;
    } else {
        changeWallpaper('default');
    }
    console.log("Twilight mode disabled. Wallpaper settings are restored.");
}

function toggleStartMenu() {
    var startMenu = document.getElementById('start-menu');
    if (startMenu.classList.contains('hidden')) {
        startMenu.classList.remove('hidden');
    } else {
        startMenu.classList.add('hidden');
    }
}

function openSettings() {
    createWindow('Nastavení', `
        <div style="padding: 20px; font-family: 'Segoe UI', sans-serif; color: black;">
            <h2>Nastavení</h2>
            <div style="margin: 20px 0;">
                <div style="margin: 10px 0;">
                    <input type="file" id="custom-wallpaper" accept="image/*" style="margin: 5px;">
                    <button onclick="changeWallpaper('custom')" style="padding: 8px 16px; margin: 5px;">Použít vlastní tapetu</button>
                    <p></p>
                    <i> PS : na Windows verzi je nastavení více, a je tam i více programů, stáhněte si ji pokud možno!!</i>
                </div>
            </div>
        </div>
    `, 400, 300);
}

function toggleWindowVisibility(windowDiv) {
    if (windowDiv.classList.contains('hidden-window')) {
        windowDiv.classList.remove('hidden-window');
    } else {
        windowDiv.classList.add('hidden-window');
    }
}

window.UvikOS = {
    openApp: function(appName) {
        const validApps = ["notepad", "internet", "youtube", "game", "apps", "vid", "UvikChat", "calc", "paint"]
        if (validApps.includes(appName)) {
            openApp(appName);
        } else {
            console.warn(`Invalid app name: "${appName}". Valid names are: ${validApps.join(", ")}`);
        }
    },
    setWallpaper: function(url) {
        if (localStorage.getItem('uvikTwilight') === "true") {
            console.warn("Twilight mode is active. Cannot change wallpaper.");
            return;
        }

        if (url && typeof url === "string") {
            document.body.style.backgroundImage = `url("${url}")`;
            localStorage.setItem('uvikWallpaper', url);
            console.log("Wallpaper updated!");
        } else {
            console.error("Invalid wallpaper URL. Please provide a valid string.");
        }
    },
    twilight: function(state) {
        if (state === "true") {
            enableTwilightMode();
        } else if (state === "false") {
            disableTwilightMode();
        } else {
            console.warn('error44.');
        }
    },
    help: function() {
        console.log(`
Available UvikOS commands:
- UvikOS.openApp("appName"): Opens an app. Valid app names: notepad, internet, youtube, game, apps, vid, UvikChat, calc, paint.
- UvikOS.setWallpaper("url"): Changes the wallpaper to the specified URL.
- UvikOS.help(): Displays this help message.
`);
    }
};

console.log("Welcome to UvikOS Console! Type UvikOS.help() for a list of available commands.");

function redirectToMobile() {
    window.location.href = "https://admin-iget.github.io/test/UvikMobile.html";
}

function openApp(appName) {
    // clsoe start
    var startMenu = document.getElementById('start-menu');
    if (!startMenu.classList.contains('hidden')) {
        startMenu.classList.add('hidden');
    }

    switch(appName) {
        case 'notepad':
            createWindow('Poznámkový blok', '<iframe src="notepad.html" style="width: 100%; height: 100%; border: none;"></iframe>');
            break;
        case 'calc':
            createWindow('Kalkulačka', '<iframe src="https://admin-iget.github.io/test/calc" style="width: 100%; height: 100%; border: none;"></iframe>');
            break;
        case 'uvikdraw':
            createWindow('UvíkDraw', '<iframe src="https://admin-iget.github.io/test/UvikPaint" style="width: 100%; height: 100%; border: none;"></iframe>');
            break;
        case 'paint':
            createWindow('Paint', '<iframe src="https://paintz.app" style="width: 100%; height: 100%; border: none;"></iframe>');
            break;
        case 'screenshot':
            createWindow('Screenshot', '<iframe src="https://admin-iget.github.io/test/screenshot.html" style="width: 100%; height: 100%; border: none;"></iframe>');
            break;
        case 'UvikChat':
            createWindow('UvikChat', '<iframe src="https://admin-iget.github.io/test/UvikChat" style="width: 100%; height: 100%; border: none;"></iframe>');
            break;
        case 'internet':
            createWindow('Internet', '<iframe src="https://admin-iget.github.io/test/UvikSEARCH2" style="width: 100%; height: 100%; border: none;"></iframe>');
            break;
        case 'youtube':
            createWindow('YouTube', '<iframe src="https://admin-iget.github.io/test/youtube" style="width: 100%; height: 100%; border: none;"></iframe>');
            break;
        case 'game':
            createWindow('Hry', '<iframe src="https://admin-iget.github.io/test/Uvikhry" style="width: 100%; height: 100%; border: none;"></iframe>');
            break;
        case 'apps':
            createWindow('Aplikace', '<iframe src="https://admin-iget.github.io/test/UvikObchod" style="width: 100%; height: 100%; border: none;"></iframe>');
            break;
        case 'vid':
            createWindow('VideoPřehrávač', '<iframe src="https://admin-iget.github.io/test/vid" style="width: 100%; height: 100%; border: none;"></iframe>');
            break;
        default:
            console.error(`Neplatný název aplikace: ${appName}`);
            return;
    }
}

function createWindow(title, content, width = 600, height = 400) {
    const windowDiv = document.createElement('div');
    windowDiv.className = 'window';
    windowDiv.id = 'window-' + Date.now();
    
    // window center
    const centerX = (window.innerWidth - width) / 2; //
    const centerY = (window.innerHeight - height) / 2;
    windowDiv.style.left = centerX + 'px';
    windowDiv.style.top = centerY + 'px';
    windowDiv.style.width = width + 'px';
    windowDiv.style.height = height + 'px';
    
    const titlebar = document.createElement('div');
    titlebar.className = 'window-titlebar';
    titlebar.innerHTML = `
        <span>${title}</span>
        <div class="window-buttons">
            <button class="minimize-btn" onclick="minimizeWindow(this)">&#x2212;</button>
            <button class="maximize-btn" onclick="maximizeWindow(this)">&#x2610;</button>
            <button class="close-btn" onclick="closeWindow(this)">&#x2715;</button>
        </div>
    `;
    
    const contentDiv = document.createElement('div');
    contentDiv.className = 'window-content';
    contentDiv.innerHTML = content;
    
    const resizeHandle = document.createElement('div');
    resizeHandle.className = 'window-resize-handle-se';
    
    windowDiv.appendChild(titlebar);
    windowDiv.appendChild(contentDiv);
    windowDiv.appendChild(resizeHandle);
    
    document.getElementById('app-container').appendChild(windowDiv);
    addTaskbarButton(title, windowDiv);
    bringToFront(windowDiv);
    
    makeDraggable(windowDiv);
    makeResizable(windowDiv);
    
    return windowDiv;
}

function minimizeWindow(button) {
    const windowDiv = button.closest('.window');
    const taskbarButton = document.querySelector(`[data-window-id="${windowDiv.id}"]`);
    
    windowDiv.classList.add('minimized');
    windowDiv.style.display = 'none';
    if (taskbarButton) {
        taskbarButton.classList.remove('active');
    }
}

function maximizeWindow(button) {
    const windowDiv = button.closest('.window');
    
    if (windowDiv.classList.contains('maximized')) {
        // Unmaximize
        windowDiv.classList.remove('maximized');
        
        windowDiv.style.left = windowDiv.dataset.prevLeft;
        windowDiv.style.top = windowDiv.dataset.prevTop;
        windowDiv.style.width = windowDiv.dataset.prevWidth;
        windowDiv.style.height = windowDiv.dataset.prevHeight;
        
        button.innerHTML = '&#x2610;'; // icon for maximize
    } else {
        // save
        windowDiv.dataset.prevLeft = windowDiv.style.left;
        windowDiv.dataset.prevTop = windowDiv.style.top;
        windowDiv.dataset.prevWidth = windowDiv.style.width;
        windowDiv.dataset.prevHeight = windowDiv.style.height;

        // maximize
        windowDiv.classList.add('maximized');
        windowDiv.style.left = '0';
        windowDiv.style.top = '0';
        windowDiv.style.width = '100%';
        windowDiv.style.height = 'calc(100vh - 40px)';
        
        button.innerHTML = '&#x2611;'; // icon for restore
    }

    bringToFront(windowDiv);
}

function placeTheHolder() {
    alert("Tato funkce funguje jen na Windows verzi UvíkOS!")
}

function addTaskbarButton(title, windowDiv) {
    const taskbarApps = document.getElementById('taskbar-apps');
    const button = document.createElement('button');
    button.className = 'taskbar-button active';
    button.innerHTML = title;
    button.setAttribute('data-window-id', windowDiv.id);
    
    button.onclick = function() {
        const window = document.getElementById(windowDiv.id);
        if (window.classList.contains('minimized')) {
            window.classList.remove('minimized');
            window.style.display = 'flex';
            button.classList.add('active');
            bringToFront(window);
        } else {
            bringToFront(window);
        }
    };
    
    taskbarApps.appendChild(button);
}

function closeWindow(button) {
    const windowDiv = button.closest('.window');
    if (windowDiv) {
        const taskbarButton = document.querySelector(`.taskbar-button[data-window-id="${windowDiv.id}"]`);
        if (taskbarButton) {
            taskbarButton.remove();
        }
        windowDiv.remove();
    }
}

function removeTaskbarButton(windowElement) {
    const taskbarButton = document.querySelector(`.taskbar-button[data-window-id="${windowElement.id}"]`);
    if (taskbarButton) {
        taskbarButton.remove();
    }
}

function bringToFront(element) {
    var allWindows = document.querySelectorAll('.window');
    for (var i = 0; i < allWindows.length; i++) {
        allWindows[i].style.zIndex = 100;
        allWindows[i].classList.remove('active-window');
    }
    element.style.zIndex = 101;
    element.classList.add('active-window');

    const taskbarApps = document.getElementById('taskbar-apps');
    const taskbarButton = document.querySelector(`.taskbar-button[data-window-id="${element.id}"]`);
    if (taskbarButton) {
        taskbarApps.insertBefore(taskbarButton, taskbarApps.firstChild);
    }
}

function changeWallpaper(type) {
    if (localStorage.getItem('uvikTwilight') === "true") {
        console.log("Twilight mode is active. Cannot change wallpaper.");
        return;
    }

    if (type === 'default') {
        var defaultWallpaper = "https://admin-iget.github.io/test/f43981720.jpg";
        document.body.style.backgroundImage = 'url("' + defaultWallpaper + '")';
        localStorage.setItem('uvikWallpaper', defaultWallpaper); 
    } else if (type === 'custom') {
        var fileInput = document.getElementById('custom-wallpaper');
        var file = fileInput.files[0];
        if (file) {
            var reader = new FileReader();
            reader.onload = function(e) {
                var customWallpaper = e.target.result;
                document.body.style.backgroundImage = 'url("' + customWallpaper + '")';
                localStorage.setItem('uvikWallpaper', customWallpaper); 
            };
            reader.readAsDataURL(file);
        }
    }
}

let activeDragCancel = null;
let activeResizeCancel = null;

function makeDraggable(element) {
    const titlebar = element.querySelector('.window-titlebar');

    titlebar.onmousedown = function (event) {
        if (event.altKey) return;

        bringToFront(element);
        disableIframes();

        const shiftX = event.clientX - element.offsetLeft;
        const shiftY = event.clientY - element.offsetTop;

        function moveAt(pageX, pageY) {
            element.style.left = pageX - shiftX + 'px';
            element.style.top = pageY - shiftY + 'px';
        }

        function onMouseMove(event) {
            if (event.altKey) {
                cancelDrag();
                return;
            }
            moveAt(event.pageX, event.pageY);
        }

        function cancelDrag() {
            document.removeEventListener('mousemove', onMouseMove);
            titlebar.onmouseup = null;
            enableIframes();
            activeDragCancel = null;
        }

        document.addEventListener('mousemove', onMouseMove);
        titlebar.onmouseup = cancelDrag;
        activeDragCancel = cancelDrag;
    };

    titlebar.ondragstart = function () {
        return false;
    };
}

function makeResizable(element) {
    const handle = element.querySelector('.window-resize-handle-se');
    
    handle.onmousedown = function(event) {
        if (event.altKey) return;
        event.preventDefault();

        disableIframes();

        const startX = event.clientX;
        const startY = event.clientY;
        const startWidth = element.offsetWidth;
        const startHeight = element.offsetHeight;
        const startLeft = element.offsetLeft;
        const startTop = element.offsetTop;

        function onMouseMove(event) {
            if (event.altKey) {
                cancelResize();
                return;
            }

            const deltaX = event.clientX - startX;
            const deltaY = event.clientY - startY;

            const newWidth = Math.max(200, startWidth + deltaX);
            const newHeight = Math.max(100, startHeight + deltaY);

            element.style.width = newWidth + 'px';
            element.style.height = newHeight + 'px';
        }

        function cancelResize() {
            document.removeEventListener('mousemove', onMouseMove);
            document.removeEventListener('mouseup', onMouseUp);
            enableIframes();
        }

        function onMouseUp() {
            cancelResize();
        }

        document.addEventListener('mousemove', onMouseMove);
        document.addEventListener('mouseup', onMouseUp);
    };
}

function disableIframes() {
    const iframes = document.querySelectorAll('iframe');
    iframes.forEach(iframe => {
        iframe.style.pointerEvents = 'none';
    });
}

function enableIframes() {
    const iframes = document.querySelectorAll('iframe');
    iframes.forEach(iframe => {
        iframe.style.pointerEvents = 'auto';
    });
}

function openFileExplorer() {
    // close start window / menu
    var startMenu = document.getElementById('start-menu');
    if (!startMenu.classList.contains('hidden')) {
        startMenu.classList.add('hidden');
    }

    var input = document.createElement('input');
    input.type = 'file';
    input.accept = '.html,.png,.txt,.jpg';

    input.onchange = function(event) {
        var file = event.target.files[0];
        if (file) {
            if (file.type.indexOf('image') !== -1) {
                var reader = new FileReader();
                reader.onload = function(e) {
                    var contentUrl = e.target.result;
                    createWindow(file.name, '<img src="' + contentUrl + '" alt="' + file.name + '" style="width:100%;height:100%;">');
                };
                reader.readAsDataURL(file);
            } else if (file.type === 'text/plain') {
                var reader = new FileReader();
                reader.onload = function(e) {
                    // Create notepad window
                    const windowDiv = createWindow(file.name, '', 600, 400);
                    const contentDiv = windowDiv.querySelector('.window-content');
                    contentDiv.innerHTML = `
                        <div class="menu-bar">
                            <div class="menu">
                                <button>Soubor</button>
                                <div class="submenu">
                                    <button onclick="saveFile(this.closest('.window'))">Uložit (Alt+S)</button>
                                    <button onclick="saveAsFile(this.closest('.window'))">Uložit jako</button>
                                </div>
                            </div>
                            <div class="menu">
                                <button>Úprava</button>
                                <div class="submenu">
                                    <button onclick="undo(this.closest('.window'))">Zpět (Alt+Z)</button>
                                    <button onclick="redo(this.closest('.window'))">Dopředu (Alt+Y)</button>
                                    <button onclick="findText(this.closest('.window'))">Najít (Alt+F)</button>
                                    <button onclick="replaceText(this.closest('.window'))">Nahradit (Alt+H)</button>
                                </div>
                            </div>
                            <div class="menu">
                                <button>Písmo</button>
                                <div class="submenu">
                                    <button onclick="changeFontSize(1, this.closest('.window'))">Zvětšit</button>
                                    <button onclick="changeFontSize(-1, this.closest('.window'))">Zmenšit</button>
                                </div>
                            </div>
                        </div>
                        <textarea id="notepad" spellcheck="false" style="width: 100%; height: calc(100% - 32px); border: none; resize: none; padding: 10px; font-size: 14px; outline: none; box-sizing: border-box; font-family: 'Consolas', 'Courier New', monospace;"></textarea>
                    `;
                    
                    // Set the file content
                    const textarea = contentDiv.querySelector('#notepad');
                    textarea.value = e.target.result;
                    currentFileName = file.name;
                };
                reader.readAsText(file);
            } else if (file.type === 'text/html') {
                var reader = new FileReader();
                reader.onload = function(e) {
                    var contentUrl = e.target.result;
                    createWindow(file.name, '<iframe src="' + contentUrl + '" width="100%" height="100%"></iframe>');
                };
                reader.readAsDataURL(file);
            } else {
                alert('Nepodporovaný typ souboru.');
            }
        }
    };

    input.click(); 
}

function showDesktop() {
    openFileExplorer();
}

// Notepad functions
let lastSearchIndex = 0;
let currentFileName = '';
let fileHandle = null;
let lastReplaceIndex = 0;

function getNotepadTextarea(windowElement) {
    if (!windowElement) {
        windowElement = document.querySelector('.window:not(.minimized)');
    }
    if (!windowElement) return null;
    return windowElement.querySelector('#notepad');
}

function undo(windowElement) {
    const textarea = getNotepadTextarea(windowElement);
    if (textarea) document.execCommand("undo");
}

function redo(windowElement) {
    const textarea = getNotepadTextarea(windowElement);
    if (textarea) document.execCommand("redo");
}

function findText(windowElement) {
    const textarea = getNotepadTextarea(windowElement);
    if (!textarea) return;
    
    let searchText = prompt("Zadejte hledaný text:");
    let text = textarea.value;

    if (!searchText) return;

    let index = text.indexOf(searchText, lastSearchIndex);
    if (index === -1) {
        lastSearchIndex = 0;
        index = text.indexOf(searchText);
    }

    if (index !== -1) {
        textarea.focus();
        textarea.setSelectionRange(index, index + searchText.length);
        lastSearchIndex = index + 1;
    } else {
        alert("Text nebyl nalezen.");
        lastSearchIndex = 0;
    }
}

function replaceText(windowElement) {
    const textarea = getNotepadTextarea(windowElement);
    if (!textarea) return;
    
    let searchText = prompt("Zadejte hledaný text:");
    if (!searchText) return;

    let replaceText = prompt("Zadejte text pro nahrazení:");
    if (replaceText === null) return;

    let text = textarea.value;
    let newText = text.replace(new RegExp(searchText, 'g'), replaceText);
    
    if (newText !== text) {
        textarea.value = newText;
        alert("Nahrazení dokončeno.");
    } else {
        alert("Text nebyl nalezen.");
    }
}

function changeFontSize(delta, windowElement) {
    const textarea = getNotepadTextarea(windowElement);
    if (!textarea) return;
    
    const currentSize = parseInt(window.getComputedStyle(textarea).fontSize);
    textarea.style.fontSize = (currentSize + delta) + 'px';
}

function saveFile(windowElement) {
    const textarea = getNotepadTextarea(windowElement);
    if (!textarea) return;
    
    const text = textarea.value;
    const blob = new Blob([text], { type: 'text/plain' });
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = currentFileName || 'untitled.txt';
    a.style.display = 'none';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(a.href);
}

function saveAsFile(windowElement) {
    const textarea = getNotepadTextarea(windowElement);
    if (!textarea) return;
    
    const text = textarea.value;
    let filename = prompt("Zadejte název souboru:", currentFileName.replace(/\.[^/.]+$/, "") || "filename");

    if (!filename) return; // user cancelled

    filename = filename.trim();
    if (!filename.toLowerCase().endsWith('.txt')) {
        filename += ".txt";
    }

    const blob = new Blob([text], { type: 'text/plain' });
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = filename;
    a.style.display = 'none';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(a.href);

    currentFileName = filename;
}

// Add keyboard shortcuts for notepad
document.addEventListener("keydown", function(event) {
    if (event.altKey) {
        const activeWindow = document.querySelector('.window.active-window:not(.minimized)');
        if (!activeWindow) return;

        const textarea = activeWindow.querySelector('#notepad');
        if (!textarea) return;

        switch (event.key.toLowerCase()) {
            case "s":
                event.preventDefault();
                saveFile(activeWindow);
                break;
            case "z":
                event.preventDefault();
                undo(activeWindow);
                break;
            case "y":
                event.preventDefault();
                redo(activeWindow);
                break;
            case "f":
                event.preventDefault();
                findText(activeWindow);
                break;
            case "h":
                event.preventDefault();
                replaceText(activeWindow);
                break;
        }
    }
});

// desktop icons that show up by default
const defaultIcons = [
    { id: 'notepad', name: 'Textový editor', icon: './notepad.png', x: 20, y: 20 },
    { id: 'calc', name: 'Kalkulačka', icon: './calc.png', x: 20, y: 140 },
    { id: 'uvikdraw', name: 'UvíkDraw', icon: './uvikdraw.png', x: 20, y: 260 }
];

function loadDesktopIcons() {
    // clear existing icons first
    const desktopIcons = document.getElementById('desktop-icons');
    desktopIcons.innerHTML = '';
    
    const savedIcons = localStorage.getItem('desktopIcons');
    const icons = savedIcons ? JSON.parse(savedIcons) : defaultIcons;
    
    // create icons
    icons.forEach(icon => {
        createDesktopIcon(icon);
    });
}

// save icon positions
function saveDesktopIcons() {
    try {
        const icons = Array.from(document.querySelectorAll('.desktop-icon')).map(icon => {
            const x = parseInt(icon.style.left) || 20;
            const y = parseInt(icon.style.top) || 20;
            return {
                id: icon.dataset.id,
                name: icon.querySelector('span').textContent,
                icon: icon.querySelector('img').src,
                x: x,
                y: y
            };
        });
        
        localStorage.setItem('desktopIcons', JSON.stringify(icons));
    } catch (error) {
        console.error('Error saving desktop icons:', error);
    }
}

// create a icon
function createDesktopIcon(iconData) {
    const icon = document.createElement('div');
    icon.className = 'desktop-icon';
    icon.dataset.id = iconData.id;
    icon.style.left = (iconData.x || 20) + 'px';
    icon.style.top = (iconData.y || 20) + 'px';
    
    icon.innerHTML = `
        <div style="display: flex; flex-direction: column; align-items: center; width: 100px;">
            <img src="${iconData.icon}" alt="${iconData.name}" onerror="this.src='./file.png'" style="width: 64px; height: 64px;">
            <span style="display: block; text-align: center; margin-top: 8px; max-width: 100px; word-wrap: break-word; font-size: 14px;">${iconData.name}</span>
        </div>
    `;
    
    // doubleclick = open
    icon.addEventListener('dblclick', () => {
        if (iconData.id.startsWith('file')) {
            openFile(iconData.id);
        } else {
            openApp(iconData.id);
        }
    });

    // right click to delete
    icon.addEventListener('contextmenu', (e) => {
        e.preventDefault();
        icon.remove();
        saveDesktopIcons();
    });
    
    makeIconDraggable(icon);
    document.getElementById('desktop-icons').appendChild(icon);
}

// make icons draggable
function makeIconDraggable(icon) {
    let isDragging = false;
    let startX, startY;
    let startLeft, startTop;
    const GRID_SIZE = 20;

    function snapToGrid(value) {
        return Math.round(value / GRID_SIZE) * GRID_SIZE;
    }

    function dragStart(e) {
        if (e.button === 2) return;
        
        isDragging = true;
        startX = e.clientX;
        startY = e.clientY;
        startLeft = parseInt(icon.style.left) || 0;
        startTop = parseInt(icon.style.top) || 0;
        
        icon.style.zIndex = '1000';
        e.preventDefault();
    }

    function drag(e) {
        if (!isDragging) return;
        
        const deltaX = e.clientX - startX;
        const deltaY = e.clientY - startY;
        
        let newLeft = startLeft + deltaX;
        let newTop = startTop + deltaY;
        
        newLeft = snapToGrid(newLeft);
        newTop = snapToGrid(newTop);
        
        const desktop = document.getElementById('desktop-icons');
        const maxX = desktop.clientWidth - icon.offsetWidth;
        const maxY = desktop.clientHeight - icon.offsetHeight;
        
        newLeft = Math.max(0, Math.min(newLeft, maxX));
        newTop = Math.max(0, Math.min(newTop, maxY));
        
        icon.style.left = newLeft + 'px';
        icon.style.top = newTop + 'px';
    }

    function dragEnd(e) {
        if (!isDragging) return;
        isDragging = false;
        icon.style.zIndex = '';
        saveDesktopIcons();
    }

    icon.addEventListener('mousedown', dragStart);
    document.addEventListener('mousemove', drag);
    document.addEventListener('mouseup', dragEnd);
    icon.addEventListener('dragstart', (e) => e.preventDefault());
}

function showBatteryInfo() {
    if ('getBattery' in navigator) {
        navigator.getBattery().then(battery => {
            const percentage = Math.round(battery.level * 100);
            const isCharging = battery.charging;
            
            createWindow('UvíkOS Wi-FI a Baterie', `
                <div style="padding: 20px; font-family: 'Segoe UI', sans-serif; color: black;">
                    <h2>Stav baterie(Nastavení wifi je jen na Windows verzi)</h2>
                    <p>Úroveň baterie: ${percentage}%</p>
                </div>
            `);
        });
    } else {
        createWindow('UvíkOS Wi-FI a Baterie', `
            <div style="padding: 20px; font-family: 'Segoe UI', sans-serif; color: black;">
                <h2>Stav baterie(Nastavení wifi je jen na Windows verzi)</h2>
                <p>Informace o baterii nejsou na tomto zařízení dostupné.</p>
            </div>
        `);
    }
}

function showVolumeMixer() {
    createWindow('Směšovač hlasitosti', `
        <div style="padding: 20px; font-family: 'Segoe UI', sans-serif; color: black;">
            <h2>Mixer hlasitosti</h2>
            <div style="margin: 20px 0;">
                <label>Toto funguje jen na Windows verzi!</label>
            </div>
        </div>
    `);
}

function showShutdown() {
    createWindow('Vypnutí systému', `
        <div style="padding: 20px; font-family: 'Segoe UI', sans-serif; text-align: center; color: black;">
            <h2>Co chcete udělat?</h2>
            <div style="display: flex; flex-direction: column; gap: 10px; margin-top: 20px;">
                <button onclick="window.close()" style="padding: 10px; background: #BEBEBE; color: white; border: none; border-radius: 4px;">Zpět do OS (Pokud nefunguje, stiskni CTRL+W)</button>
            </div>
        </div>
    `);
}
