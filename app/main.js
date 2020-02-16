// Modules to control application life and create native browser window
const {app, BrowserWindow, dialog,Menu} = require('electron');
// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
let mainWindow;
let subWindow;
function createWindow () {
    // Create the browser window.
    mainWindow = new BrowserWindow({width: 1096, height: 680});
    // and load the index.html of the app.
    mainWindow.loadFile('index.html');
    // Open the DevTools.
    // mainWindow.webContents.openDevTools()
    // Emitted when the window is closed.
    mainWindow.on('closed', function () {
        // Dereference the window object, usually you would store windows
        // in an array if your app supports multi windows, this is the time
        // when you should delete the corresponding element.
        mainWindow = null;
        subWindow = null;
    });
    mainWindow.webContents.on('will-prevent-unload', (event) => {
        const choice = dialog.showMessageBox(mainWindow, {
            type: 'question',
            buttons: ['終了する', '終了しない'],
            title: '本当にスモウルビーを終了しますか？',
            message: '作成中のプログラムは消えてしまいます。\n' +
                'プログラムを保存する場合は、「終了しない」を選んでから、' +
                'メニュー[ファイル]-[コンピュータに保存する]を選んで保存してください。',
            defaultId: 0,
            cancelId: 1
        });
        const leave = (choice === 0);
        if (leave) {
            event.preventDefault();
        }
    });
}
function initWindowMenu(){
    
    const template = [
        {
            label: 'View',
            submenu: [
                { role: 'reload' },
                { role: 'forcereload' },
                { role: 'toggledevtools' }
            ]
        },
        {
            label: 'esp32',
            submenu: [
                {
                    label: '書き込み',
                    click (){
                        subWindow = new BrowserWindow({width: 420, height: 280});
                        subWindow.loadFile('flash.html');
                    }
                },
                {
                    label: 'クリーン',
                    click (){
                        subWindow = new BrowserWindow({width: 420, height: 280});
                        subWindow.loadFile('clean.html');
                    }
                }
            ]
        }
    ]
 
    const menu = Menu.buildFromTemplate(template)
    Menu.setApplicationMenu(menu)
}

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.on('ready', function() {
    createWindow();
    initWindowMenu();
});
// Quit when all windows are closed.
app.on('window-all-closed', function () {
    // On macOS it is common for applications and their menu bar
    // to stay active until the user quits explicitly with Cmd + Q
    if (process.platform !== 'darwin') {
        app.quit();
    }
});
app.on('activate', function () {
    // On macOS it's common to re-create a window in the app when the
    // dock icon is clicked and there are no other windows open.
    if (mainWindow === null) {
        createWindow();
    }
});
// In this file you can include the rest of your app's specific main process
// code. You can also put them in separate files and require them here.