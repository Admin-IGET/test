document.addEventListener('DOMContentLoaded', function() {
    setInterval(updateTimeDate, 1000);
    changeWallpaper('default');
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
    windowDiv.innerHTML = 
        '<div class="window-titlebar">' +
            '<span>' + title + '</span>' +
            '<button onclick="closeWindow(this)">X</button>' +
        '</div>' +
        '<div class="window-content">' + content + '</div>' +
        '<div class="window-resize-handle"></div>';
    appContainer.appendChild(windowDiv);
    makeDraggable(windowDiv); // Call draggable function
    makeResizable(windowDiv); // Call resizable function
    bringToFront(windowDiv);  // Bring new window to front
}

function closeWindow(button) {
    var windowElement = findAncestor(button, 'window');
    windowElement.parentNode.removeChild(windowElement);
}

function findAncestor(el, cls) {
    while ((el = el.parentElement) && !el.classList.contains(cls));
    return el;
}

function changeWallpaper(type) {
    if (type === 'default') {
        document.body.style.backgroundImage = 'url("https://admin-iget.github.io/test/f43981720.jpg")';
    } else if (type === 'custom') {
        var fileInput = document.getElementById('custom-wallpaper');
        var file = fileInput.files[0];
        if (file) {
            var reader = new FileReader();
            reader.onload = function(e) {
                document.body.style.backgroundImage = 'url("' + e.target.result + '")';
            };
            reader.readAsDataURL(file);
        }
    }
}

function makeDraggable(element) {
    var titlebar = element.querySelector('.window-titlebar');
    
    titlebar.onmousedown = function (event) {
        bringToFront(element); // Bring window to the top when dragging starts

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

        function onMouseMove(event) {
            element.style.width = (event.pageX - element.offsetLeft) + 'px';
            element.style.height = (event.pageY - element.offsetTop) + 'px';
        }

        document.addEventListener('mousemove', onMouseMove);

        resizeHandle.onmouseup = function () {
            document.removeEventListener('mousemove', onMouseMove);
            resizeHandle.onmouseup = null;
            enableIframes(); // Enable iframe interactions again
        };
    };

    resizeHandle.ondragstart = function () {
        return false;
    };
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

function bringToFront(element) {
    var allWindows = document.querySelectorAll('.window');
    for (var i = 0; i < allWindows.length; i++) {
        allWindows[i].style.zIndex = 100;
    }
    element.style.zIndex = 101;
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
