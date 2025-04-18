document.addEventListener('DOMContentLoaded', function() {
    setInterval(updateTimeDate, 1000);

    // Load saved wallpaper and Twilight mode
    const savedWallpaper = localStorage.getItem('uvikWallpaper');
    const twilightMode = localStorage.getItem('uvikTwilight') === "true";

    if (twilightMode) {
        enableTwilightMode();
    } else if (savedWallpaper) {
        document.body.style.backgroundImage = `url("${savedWallpaper}")`;
    } else {
        changeWallpaper('default');
    }
   document.querySelector('.taskbar-apps').style.display = 'none';
});

    document.addEventListener('keydown', function(event) {
      if (event.altKey) {
        document.querySelector('.taskbar-apps').style.display = 'block';
      }
    });

    document.addEventListener('keyup', function(event) {
      if (!event.altKey) {
        document.querySelector('.taskbar-apps').style.display = 'none';
      }
    });

function updateTimeDate() {
    var now = new Date();
    var timeString = now.toLocaleTimeString();
    var dateString = now.toLocaleDateString();
    var formattedTime = timeString.split(" ")[0]; 
    document.getElementById('time').innerHTML = formattedTime + "<br>" + dateString; // Format time on new line
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
        windowDiv.classList.remove('hidden-window'); // Restore window
    } else {
        windowDiv.classList.add('hidden-window'); // Minimize window
    }
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
    if (localStorage.getItem('uvikTwilight') === "true") {
        console.log("error21.");
        return;
    }

    if (type === 'default') {
        var defaultWallpaper = "https://admin-iget.github.io/test/f43981720.jpg";
        document.body.style.backgroundImage = `url("${defaultWallpaper}")`;
        localStorage.setItem('uvikWallpaper', defaultWallpaper); // Save default wallpaper
    } else if (type === 'custom') {
        var fileInput = document.getElementById('custom-wallpaper');
        var file = fileInput.files[0];
        if (file) {
            var reader = new FileReader();
            reader.onload = function(e) {
                var customWallpaper = e.target.result;
                document.body.style.backgroundImage = `url("${customWallpaper}")`;
                localStorage.setItem('uvikWallpaper', customWallpaper); // Save custom wallpapr
            };
            reader.readAsDataURL(file);
        }
    }
}

// Expose commands globally for interacting with UvikOS
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
        game: "https://admin-iget.github.io/test/Uvikhry.html",
        apps: "https://admin-iget.github.io/test/UvikObchod.html",
        video: "https://admin-iget.github.io/test/yt.html", // New Video App
        UvikChat: "https://admin-iget.github.io/test/UvikChat",
        calc: "https://admin-iget.github.io/test/calc",
        paint: "https://paintz.app/"
    };

    if (urls[appName]) {
        createWindow(appName, '<iframe src="' + urls[appName] + '" width="100%" height="100%"></iframe>');
    } else {
        console.error(`Invalid app name: ${appName}`);
        return; // Exit if the app name is invalid
    }

    // Automatically close the start menu after opening an app
    var startMenu = document.getElementById('start-menu');
    if (!startMenu.classList.contains('hidden')) {
        startMenu.classList.add('hidden');
    }
}



function updateTaskbarButtonName(titleBar, newName) {
    // Get the window ID from the title bar
    const windowId = titleBar.closest('.window').dataset.windowId;
    const taskbarButton = document.querySelector(`.taskbar-button[data-window-id="${windowId}"]`);

    if (taskbarButton) {
        taskbarButton.querySelector('span').innerText = newName; // Update taskbar button text
    }
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
            <div class="window-buttons" style="display: inline-flex; gap: 2px;">
                <button onclick="placeTheHolder()">-</button>
                <button onclick="placeTheHolder()">□</button>
                <button onclick="closeWindow(this)">X</button>
            </div>
        </div>
        <div class="window-content">${content}</div>
        <div class="window-resize-handle"></div>`;

    appContainer.appendChild(windowDiv);
    makeDraggable(windowDiv);
    makeResizable(windowDiv);
    bringToFront(windowDiv);

    // Enable renaming on the window title bar

    // Create a taskbar button for the window
    addTaskbarButton(title, windowDiv);
}

function placeTheHolder() {
    alert("Tato funkce funguje jen na Windows verzi UvíkOS!")
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
    if (localStorage.getItem('uvikTwilight') === "true") {
        console.log("Twilight mode is active. Cannot change wallpaper.");
        return;
    }

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
    const titlebar = element.querySelector('.window-titlebar');

    titlebar.onmousedown = function (event) {
        if (event.altKey) return; // Prevent drag when ALT is held

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
        }

        document.addEventListener('mousemove', onMouseMove);

        titlebar.onmouseup = function () {
            cancelDrag();
        };
    };

    titlebar.ondragstart = function () {
        return false;
    };
}

function makeResizable(element) {
    const resizeHandle = element.querySelector('.window-resize-handle');

    resizeHandle.onmousedown = function (event) {
        if (event.altKey) return; // Prevent resize when ALT is held

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
        }

        document.addEventListener('mousemove', onMouseMove);

        resizeHandle.onmouseup = function () {
            cancelResize();
        };
    };

    resizeHandle.ondragstart = function () {
        return false;
    };
}

// Function to disable taskbar interactons
function disableTaskbar() {
    var taskbar = document.getElementById('taskbar');
    taskbar.style.pointerEvents = 'none'; // Disable pointer events
}

// function to enable taskbar interactions
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
        document.body.style.backgroundImage = 'url("' + savedWallpaper + '")';
    } else {
        changeWallpaper('default');
    }
    console.log("Twilight mode disabled. Wallpaper settings are restored.");
}

    
    // Expose commands globally for interacting with UvikOS
window.UvikOS = {
    // Open an app by name
    openApp: function(appName) {
        const validApps = ["notepad", "internet", "youtube", "game", "apps", "video", "UvikChat", "calc", "paint"];
        if (validApps.includes(appName)) {
            console.log(`Opening ${appName}...`);
            openApp(appName);
        } else {
            console.warn(`Invalid app name: "${appName}". Valid names are: ${validApps.join(", ")}`);
        }
    },

    // Change wallpaper by URL
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

    // Toggle Twilight mode
    twilight: function(state) {
        if (state === "true") {
            enableTwilightMode();
        } else if (state === "false") {
            disableTwilightMode();
        } else {
            console.warn('Invalid state for Twilight mode. Use "true" to enable or "false" to disable.');
        }
    },

    // Show all available commands
    help: function() {
        console.log(`
Available UvikOS commands:
- UvikOS.openApp("appName"): Opens an app. Valid app names: notepad, internet, youtube, game, apps, video, UvikChat, calc, paint.
- UvikOS.setWallpaper("url"): Changes the wallpaper to the specified URL.
- UvikOS.help(): Displays this help message.
`);
    }
};

// Display an initial help message in the console on load
console.log("Welcome to UvikOS Console! Type UvikOS.help() for a list of available commands.");

}


