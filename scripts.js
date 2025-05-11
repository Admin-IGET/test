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

document.addEventListener('keydown', function(event) {
    if (event.altKey) {
        if (activeDragCancel) activeDragCancel();
        if (activeResizeCancel) activeResizeCancel();
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
    document.getElementById('settings').classList.remove('hidden');
}

function closeSettings() {
    document.getElementById('settings').classList.add('hidden');
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
    switch(appName) {
        case 'notepad':
            createWindow('Poznámkový blok', '<iframe src="notepad.html" style="width: 100%; height: 100%; border: none;"></iframe>');
            break;
        case 'internet':
            createWindow('Internet', '<iframe src="https://admin-iget.github.io/test/UvikSEARCH2.html" style="width: 100%; height: 100%; border: none;"></iframe>');
            break;
        case 'youtube':
            createWindow('YouTube', '<iframe src="https://admin-iget.github.io/test/youtube.html" style="width: 100%; height: 100%; border: none;"></iframe>');
            break;
        case 'game':
            createWindow('Hry', '<iframe src="https://admin-iget.github.io/test/Uvikhry.html" style="width: 100%; height: 100%; border: none;"></iframe>');
            break;
        case 'paint':
            createWindow('Malování', '<iframe src="https://paintz.app/" style="width: 100%; height: 100%; border: none;"></iframe>');
            break;
        case 'screenshot':
            createWindow('Screenshot', '<iframe src="screenshot.html" style="width: 100%; height: 100%; border: none;"></iframe>');
            break;
        case 'apps':
            createWindow('Všechny Aplikace', '<iframe src="https://admin-iget.github.io/test/UvikObchod.html" style="width: 100%; height: 100%; border: none;"></iframe>');
            break;
        case 'video':
            createWindow('Video', '<iframe src="https://admin-iget.github.io/test/yt.html" style="width: 100%; height: 100%; border: none;"></iframe>');
            break;
        case 'UvikChat':
            createWindow('UvíkChat', '<iframe src="https://admin-iget.github.io/test/UvikChat" style="width: 100%; height: 100%; border: none;"></iframe>');
            break;
        case 'calc':
            createWindow('Kalkulačka', '<iframe src="https://admin-iget.github.io/test/calc" style="width: 100%; height: 100%; border: none;"></iframe>');
            break;
        default:
            console.error(`Invalid app name: ${appName}`);
            return;
    }

    // Automatically close the start menu after opening an app
    var startMenu = document.getElementById('start-menu');
    if (!startMenu.classList.contains('hidden')) {
        startMenu.classList.add('hidden');
    }
}

function createWindow(title, content) {
    var appContainer = document.getElementById('app-container');
    var windowDiv = document.createElement('div');
    windowDiv.className = 'window';

    var windowId = Date.now();
    windowDiv.dataset.windowId = windowId;

    windowDiv.innerHTML = `
        <div class="window-titlebar">
            <span>${title}</span>
            <div class="window-buttons" style="display: inline-flex; gap: 2px;">
                <button class="minimize-header" onclick="minimizeWindow(this)">-</button>
                <button class="maximize-header" onclick="maximizeWindow(this)">□</button>
                <button onclick="closeWindow(this)">X</button>
            </div>
        </div>
        <div class="window-content">${content}</div>
        <div class="window-resize-handle"></div>`;

    appContainer.appendChild(windowDiv);
    makeDraggable(windowDiv);
    makeResizable(windowDiv);
    bringToFront(windowDiv);

    addTaskbarButton(title, windowDiv);
}

function minimizeWindow(button) {
    var windowDiv = button.closest('.window');

    if (windowDiv.classList.contains('mini-mode')) {
        windowDiv.classList.remove('mini-mode');
        button.textContent = '-';
        windowDiv.style.width = windowDiv.dataset.originalWidth;
        windowDiv.style.height = windowDiv.dataset.originalHeight;
        windowDiv.style.left = windowDiv.dataset.originalLeft;
        windowDiv.style.top = windowDiv.dataset.originalTop;
        windowDiv.querySelector('.window-resize-handle').style.display = 'block';
        return;
    }

    if (windowDiv.classList.contains('maximized')) {
        windowDiv.classList.remove('maximized');
        windowDiv.style.width = windowDiv.dataset.originalWidth;
        windowDiv.style.height = windowDiv.dataset.originalHeight;
        windowDiv.style.left = windowDiv.dataset.originalLeft;
        windowDiv.style.top = windowDiv.dataset.originalTop;
    }

    windowDiv.dataset.originalWidth = windowDiv.style.width;
    windowDiv.dataset.originalHeight = windowDiv.style.height;
    windowDiv.dataset.originalLeft = windowDiv.style.left;
    windowDiv.dataset.originalTop = windowDiv.style.top;

    const taskbar = document.getElementById('taskbar');
    const taskbarTop = taskbar.offsetTop;
    const minimizedHeight = 40;
    const minimizedWidth = 150;

    // nerd math
    const existingMinimized = document.querySelectorAll('.mini-mode');
    let miniLeft = 10;
    let takenPositions = Array.from(existingMinimized).map(win => parseInt(win.style.left));

    while (takenPositions.includes(miniLeft)) {
        miniLeft += minimizedWidth + 10;
    }

    windowDiv.classList.add('mini-mode');
    button.textContent = '^';
    windowDiv.style.width = minimizedWidth + 'px';
    windowDiv.style.height = minimizedHeight + 'px';
    windowDiv.style.left = miniLeft + 'px';
    windowDiv.style.top = (taskbarTop - minimizedHeight - 5) + 'px';
    windowDiv.querySelector('.window-resize-handle').style.display = 'none';
}

function maximizeWindow(button) {
    const windowDiv = button.closest('.window');
    const taskbar = document.getElementById('taskbar');
    const taskbarHeight = taskbar.offsetHeight;
    const isMinimized = windowDiv.classList.contains('mini-mode');

    if (isMinimized) {
        const minimizeBtn = windowDiv.querySelector('.minimize-header');
        if (minimizeBtn) minimizeBtn.textContent = '-';
        windowDiv.classList.remove('mini-mode');
        windowDiv.style.width = windowDiv.dataset.originalWidth;
        windowDiv.style.height = windowDiv.dataset.originalHeight;
        windowDiv.style.left = windowDiv.dataset.originalLeft;
        windowDiv.style.top = windowDiv.dataset.originalTop;
        windowDiv.querySelector('.window-resize-handle').style.display = 'block';
    }

    if (windowDiv.classList.contains('maximized')) {
        windowDiv.classList.remove('maximized');
        windowDiv.style.width = windowDiv.dataset.originalWidth;
        windowDiv.style.height = windowDiv.dataset.originalHeight;
        windowDiv.style.left = windowDiv.dataset.originalLeft;
        windowDiv.style.top = windowDiv.dataset.originalTop;
    } else {
        windowDiv.dataset.originalWidth = windowDiv.style.width;
        windowDiv.dataset.originalHeight = windowDiv.style.height;
        windowDiv.dataset.originalLeft = windowDiv.style.left;
        windowDiv.dataset.originalTop = windowDiv.style.top;

        windowDiv.classList.add('maximized');
        windowDiv.style.top = '0';
        windowDiv.style.left = '0';
        windowDiv.style.width = '100vw';
        windowDiv.style.height = `calc(100vh - ${taskbarHeight}px)`;
    }
}

function placeTheHolder() {
    alert("Tato funkce funguje jen na Windows verzi UvíkOS!")
}

function addTaskbarButton(title, windowDiv) {
    var taskbarApps = document.getElementById('taskbar-apps');
    var taskbarButton = document.createElement('div');
    taskbarButton.className = 'taskbar-button';
    taskbarButton.dataset.windowId = windowDiv.dataset.windowId;
    taskbarButton.innerHTML = `<span>${title}</span>`;

    taskbarButton.onclick = function (e) {
        bringToFront(windowDiv);

        if (!e.target.classList.contains('window-resize-handle') && !e.target.closest('.window-buttons')) {
            cancelActiveDragOrResize();
        }

        if (windowDiv.classList.contains('mini-mode')) {
            windowDiv.classList.remove('mini-mode');
            const minimizeBtn = windowDiv.querySelector('.minimize-header');
            if (minimizeBtn) minimizeBtn.textContent = '-';
            windowDiv.style.width = windowDiv.dataset.originalWidth;
            windowDiv.style.height = windowDiv.dataset.originalHeight;
            windowDiv.style.left = windowDiv.dataset.originalLeft;
            windowDiv.style.top = windowDiv.dataset.originalTop;
            windowDiv.querySelector('.window-resize-handle').style.display = 'block';
        }
    };

    taskbarApps.appendChild(taskbarButton);
}

function closeWindow(button) {
    var windowElement = button.closest('.window');
    if (windowElement) {
        windowElement.remove(); 
    }

    removeTaskbarButton(windowElement);
}

function removeTaskbarButton(windowElement) {
    var taskbarApps = document.getElementById('taskbar-apps');
    var taskbarButton = taskbarApps.querySelector(`.taskbar-button[data-window-id="${windowElement.dataset.windowId}"]`);
    if (taskbarButton) {
        taskbarButton.remove(); 
    }
}

function bringToFront(element) {
    var allWindows = document.querySelectorAll('.window');
    for (var i = 0; i < allWindows.length; i++) {
        allWindows[i].style.zIndex = 100;
    }
    element.style.zIndex = 101;
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
        disableTaskbar();

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
            enableTaskbar();
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
    const resizeHandle = element.querySelector('.window-resize-handle');

    resizeHandle.onmousedown = function (event) {
        if (event.altKey) return;

        disableIframes();
        disableTaskbar();

        function onMouseMove(event) {
            if (event.altKey) {
                cancelResize();
                return;
            }
            element.style.width = (event.pageX - element.offsetLeft) + 'px';
            element.style.height = (event.pageY - element.offsetTop) + 'px';
        }

        function cancelResize() {
            document.removeEventListener('mousemove', onMouseMove);
            resizeHandle.onmouseup = null;
            enableIframes();
            enableTaskbar();
            activeResizeCancel = null;
        }

        document.addEventListener('mousemove', onMouseMove);
        resizeHandle.onmouseup = cancelResize;
        activeResizeCancel = cancelResize;
    };

    resizeHandle.ondragstart = function () {
        return false;
    };
}

function disableTaskbar() {
    var taskbar = document.getElementById('taskbar');
    taskbar.style.pointerEvents = 'none'; 
}

function enableTaskbar() {
    var taskbar = document.getElementById('taskbar');
    taskbar.style.pointerEvents = 'auto'; 
}

function disableIframes() {
    var iframes = document.querySelectorAll('iframe');
    for (var i = 0; i < iframes.length; i++) {
        iframes[i].style.pointerEvents = 'none';
    }
}

function enableIframes() {
    var iframes = document.querySelectorAll('iframe');
    for (var i = 0; i < iframes.length; i++) {
        iframes[i].style.pointerEvents = 'auto';
    }
}

function openFileExplorer() {
    var input = document.createElement('input');
    input.type = 'file';
    input.accept = '.html,.png,.txt,.jpg';

    input.onchange = function(event) {
        var file = event.target.files[0];
        if (file) {
            var reader = new FileReader();
            reader.onload = function(e) {
                var contentUrl = e.target.result;
                var fileType = file.type;

                if (fileType.indexOf('image') !== -1) {
                    createWindow(file.name, '<img src="' + contentUrl + '" alt="' + file.name + '" style="width:100%;height:100%;">');
                } else if (fileType === 'text/plain') {
                    createWindow(file.name, '<pre style="white-space: pre-wrap;">' + e.target.result + '</pre>');
                } else if (fileType === 'text/html') {
                    createWindow(file.name, '<iframe src="' + contentUrl + '" width="100%" height="100%"></iframe>');
                } else {
                    alert('Nepodporovaný typ souboru.');
                }
            };
            reader.readAsDataURL(file);
        }
    };

    input.click(); 
}


