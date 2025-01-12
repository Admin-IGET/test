document.addEventListener('DOMContentLoaded', function() {
    setInterval(updateTimeDate, 1000);

    // Load saved wallpaper and header color
    const savedWallpaper = localStorage.getItem('uvikWallpaper');

    if (savedWallpaper) {
        document.body.style.backgroundImage = 'url("' + savedWallpaper + '")';
    } else {
        changeWallpaper('default');
    }

});

function updateTimeDate() {
    var now = new Date();
    var timeString = now.toLocaleTimeString();
    var dateString = now.toLocaleDateString();
    var formattedTime = timeString.split(" ")[0]; // Show time only, without AM/PM
    document.getElementById('time').innerHTML = formattedTime + "<br>" + dateString; // Format time on new line
}

// Expose commands globally for interacting with UvikOS

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


window.UvikOS = {
    // Open an app by name
function openApp(appName) {
    var urls = {
        notepad: "https://admin-iget.github.io/test/notepad.html",
        internet: "https://admin-iget.github.io/test/UvikSEARCH2.html",
        youtube: "https://admin-iget.github.io/test/youtube.html",
        game: "https://admin-iget.github.io/test/UvikHra1.html",
        store: "https://admin-iget.github.io/test/UvikObchod.html"
    };

    if (urls[appName]) {
        createWindow(appName, '<iframe src="' + urls[appName] + '" width="100%" height="100%"></iframe>');
    } else {
        console.error(`Invalid app name: ${appName}`);
    }

    // Close the start menu after opening an app
    var startMenu = document.getElementById('start-menu');
    if (!startMenu.classList.contains('hidden')) {
        startMenu.classList.add('hidden');
    }
}

    }

    
     twilight: function(state) {
        if (state === "true") {
            enableTwilightMode();
        } else if (state === "false") {
            disableTwilightMode();
        } else {
            console.warn('Invalid state for Twilight mode. Use "true" to enable or "false" to disable.');
        }
    },
    

    // Change wallpaper by URL
    setWallpaper: function(url) {
        if (url && typeof url === "string") {
            document.body.style.backgroundImage = `url("${url}")`;
            localStorage.setItem('uvikWallpaper', url);
            console.log("Wallpaper updated!");
        } else {
            console.error("Invalid wallpaper URL. Please provide a valid string.");
        }
    },

    // Show all available commands
    help: function() {
        console.log(`
Available UvikOS commands:
- UvikOS.openApp("appName"): Opens an app. Valid app names: notepad, internet, youtube, game, store.
- UvikOS.setWallpaper("url"): Changes the wallpaper to the specified URL.
- UvikOS.help(): Displays this help message.
`);
    }
};



// Display an initial help message in the console on load
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



// Create a new window and apply the current header color
function createWindow(title, content) {
    var appContainer = document.getElementById('app-container');
    var windowDiv = document.createElement('div');
    windowDiv.className = 'window';
    
    windowDiv.innerHTML = `
        <div class="window-titlebar" style="background-color: ${window.currentHeaderColor};">
            <span>${title}</span>
            <button onclick="closeWindow(this)">X</button>
        </div>
        <div class="window-content">${content}</div>
        <div class="window-resize-handle"></div>`;

    appContainer.appendChild(windowDiv);
    makeDraggable(windowDiv);
    makeResizable(windowDiv);
    bringToFront(windowDiv);
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

function enableRenaming(taskbarButton) {
    taskbarButton.ondblclick = function () {
        const currentText = taskbarButton.querySelector('span').innerText;
        const input = document.createElement('input');
        input.type = 'text';
        input.value = currentText;
        taskbarButton.innerHTML = ''; // Clear current content
        taskbarButton.appendChild(input); // Add input field
        input.focus();

        input.onblur = function () {
            // Save the new name when the input loses focus
            const newName = input.value.trim() || currentText; // Use old name if empty
            taskbarButton.innerHTML = `<span>${newName}</span><button class="minimize-btn">-</button>`;
        };

        input.onkeypress = function (e) {
            if (e.key === 'Enter') {
                // Save the new name when Enter is pressed
                input.blur();
            }
        };
    };
}

function enableWindowRenaming(titleBar) {
    titleBar.ondblclick = function () {
        const currentText = titleBar.querySelector('span').innerText;
        const input = document.createElement('input');
        input.type = 'text';
        input.value = currentText;
        titleBar.innerHTML = ''; // Clear current content
        titleBar.appendChild(input); // Add input field
        input.focus();

        input.onblur = function () {
            const newName = input.value.trim() || currentText; // Use old name if empty
            titleBar.innerHTML = `<span>${newName}</span><button onclick="closeWindow(this)">X</button>`;
            
            // Update the corresponding taskbar button
            updateTaskbarButtonName(titleBar, newName);
        };

        input.onkeypress = function (e) {
            if (e.key === 'Enter') {
                input.blur();
            }
        };
    };
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
            <button onclick="closeWindow(this)">X</button>
        </div>
        <div class="window-content">${content}</div>
        <div class="window-resize-handle"></div>`;
    
    appContainer.appendChild(windowDiv);
    makeDraggable(windowDiv);
    makeResizable(windowDiv);
    bringToFront(windowDiv);

    // Enable renaming on the window title bar
    enableWindowRenaming(windowDiv.querySelector('.window-titlebar'));

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
        const validApps = ["notepad", "internet", "youtube", "game", "store"];
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
- UvikOS.openApp("appName"): Opens an app. Valid app names: notepad, internet, youtube, game, store.
- UvikOS.setWallpaper("url"): Changes the wallpaper to the specified URL.
- UvikOS.help(): Displays this help message.
`);
    }
};

// Display an initial help message in the console on load
console.log("Welcome to UvikOS Console! Type UvikOS.help() for a list of available commands.");

}


