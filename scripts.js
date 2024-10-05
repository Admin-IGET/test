document.addEventListener('DOMContentLoaded', function() {
    setInterval(updateTimeDate, 1000);
    var savedWallpaper = localStorage.getItem('uvikWallpaper');
    if (savedWallpaper) {
        document.body.style.backgroundImage = 'url("' + savedWallpaper + '")';
    } else {
        changeWallpaper('default');
    }
});

function updateTimeDate() {
    var now = new Date();
    document.getElementById('time').textContent = now.toLocaleTimeString();
    document.getElementById('date').textContent = now.toLocaleDateString();
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

function redirectToMobile() {
    window.location.href = "https://admin-iget.github.io/test/UvikMobile.html"; // Redirect to mobile version
}

function openApp(appName) {
    var urls = {
        notepad: "https://admin-iget.github.io/test/notepad.html",
        internet: "https://admin-iget.github.io/test/UvikSEARCH2.html",
        youtube: "https://admin-iget.github.io/test/youtube.html",
        game: "https://admin-iget.github.io/test/UvikHra1.html",
        store: "https://admin-iget.github.io/test/UvikObchod.html"
    };
    createWindow(appName, '<iframe src="' + urls[appName] + '" width="100%" height="100%"></iframe>');
}

function createWindow(title, content) {
    var appContainer = document.getElementById('app-container');
    var windowDiv = document.createElement('div');
    windowDiv.className = 'window';

    // Assign a unique ID to each window for tracking in taskbar
    var windowId = Date.now();
    windowDiv.dataset.windowId = windowId;

    windowDiv.innerHTML = `
        <div class="window-titlebar">
            <span>${title}</span>
            <button onclick="closeWindow(this)">X</button>
        </div>
        <div class="window-content">${content}</div>
        <div class="window-resize-handle"></div>`;
    
    appContainer.appendChild(windowDiv);
    makeDraggable(windowDiv);
    makeResizable(windowDiv);
    bringToFront(windowDiv);

    // Create a taskbar button for the window
    addTaskbarButton(title, windowDiv);
}

function addTaskbarButton(title, windowDiv) {
    var taskbarApps = document.getElementById('taskbar-apps');
    var taskbarButton = document.createElement('div');
    taskbarButton.className = 'taskbar-button';
    taskbarButton.dataset.windowId = windowDiv.dataset.windowId; // Link taskbar button to window

    taskbarButton.innerHTML = `
        <span>${title}</span>
        <button class="minimize-btn">-</button>`;
    
    taskbarApps.appendChild(taskbarButton);

    // Click taskbar button to bring the window to front
    taskbarButton.onclick = function() {
        bringToFront(windowDiv);
        if (windowDiv.classList.contains('hidden-window')) {
            windowDiv.classList.remove('hidden-window'); // Restore if minimized
        }
    };

    // Minimize button to hide the window
    var minimizeButton = taskbarButton.querySelector('.minimize-btn');
    minimizeButton.onclick = function(e) {
        e.stopPropagation(); // Prevent triggering the taskbarButton click event
        if (windowDiv.classList.contains('hidden-window')) {
            windowDiv.classList.remove('hidden-window'); // Restore window
        } else {
            windowDiv.classList.add('hidden-window'); // Minimize window
        }
    };
}

function closeWindow(button) {
    var windowElement = button.closest('.window');
    if (windowElement) {
        windowElement.remove(); // Removes the window from the DOM
    }

    // Remove the corresponding taskbar button when window is closed
    removeTaskbarButton(windowElement);
}

function removeTaskbarButton(windowElement) {
    var taskbarApps = document.getElementById('taskbar-apps');
    var taskbarButton = taskbarApps.querySelector(`.taskbar-button[data-window-id="${windowElement.dataset.windowId}"]`);
    if (taskbarButton) {
        taskbarButton.remove(); // Remove the taskbar button when the window is closed
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
    if (type === 'default') {
        var defaultWallpaper = "https://admin-iget.github.io/test/f43981720.jpg";
        document.body.style.backgroundImage = 'url("' + defaultWallpaper + '")';
        localStorage.setItem('uvikWallpaper', defaultWallpaper); // Save default wallpaper
    } else if (type === 'custom') {
        var fileInput = document.getElementById('custom-wallpaper');
        var file = fileInput.files[0];
        if (file) {
            var reader = new FileReader();
            reader.onload = function(e) {
                var customWallpaper = e.target.result;
                document.body.style.backgroundImage = 'url("' + customWallpaper + '")';
                localStorage.setItem('uvikWallpaper', customWallpaper); // Save custom wallpaper
            };
            reader.readAsDataURL(file);
        }
    }
}

function makeDraggable(element) {
    var titlebar = element.querySelector('.window-titlebar');
    
    titlebar.onmousedown = function (event) {
        bringToFront(element); // Bring window to the top when dragging starts
        disableIframes(); // Disable iframe interactions when dragging starts
        disableTaskbar(); // Disable taskbar interactions when dragging starts

        var shiftX = event.clientX - element.offsetLeft;
        var shiftY = event.clientY - element.offsetTop;

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
            enableIframes(); // Enable iframe interactions when dragging ends
            enableTaskbar(); // Enable taskbar interactions when dragging ends
        };
    };

    titlebar.ondragstart = function () {
        return false;
    };
}

function makeResizable(element) {
    var resizeHandle = element.querySelector('.window-resize-handle');
    
    resizeHandle.onmousedown = function (event) {
        disableIframes(); // Disable iframe interactions while resizing
        disableTaskbar(); // Disable taskbar interactions while resizing

        function onMouseMove(event) {
            element.style.width = (event.pageX - element.offsetLeft) + 'px';
            element.style.height = (event.pageY - element.offsetTop) + 'px';
        }

        document.addEventListener('mousemove', onMouseMove);

        resizeHandle.onmouseup = function () {
            document.removeEventListener('mousemove', onMouseMove);
            resizeHandle.onmouseup = null;
            enableIframes(); // Enable iframe interactions again
            enableTaskbar(); // Enable taskbar interactions again
        };
    };

    resizeHandle.ondragstart = function () {
        return false;
    };
}

// Function to disable taskbar interactions
function disableTaskbar() {
    var taskbar = document.getElementById('taskbar');
    taskbar.style.pointerEvents = 'none'; // Disable pointer events
}

// Function to enable taskbar interactions
function enableTaskbar() {
    var taskbar = document.getElementById('taskbar');
    taskbar.style.pointerEvents = 'auto'; // Enable pointer events
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

    input.click(); // Trigger the file picker
}
