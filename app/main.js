// Modules to control application life and create native browser window
const {app, BrowserWindow, dialog,Menu, ipcMain} = require('electron');
const path = require('path');
const { exec } = require('child_process');
// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
let mainWindow;
let subWindow;
function createWindow () {
    // Create the browser window.
    mainWindow = new BrowserWindow({
        width: 1096, 
        height: 680,
        webPreferences: {
            nodeIntegration: false,
            contextIsolation: true,
            preload: path.join(__dirname, 'preload.js')
        }
    });
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
    /*mainWindow.webContents.on('will-prevent-unload', (event) => {
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
    });*/
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
        /*{
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
                },
            ]
        },*/
    ]
 
    const menu = Menu.buildFromTemplate(template)
    Menu.setApplicationMenu(menu)

    //const canvas = document.createElement('canvas');

    //canvas.width = 600;
    //canvas.height = 400;

    //document.body.appendChild(canvas);

    //const ctx = canvas.getContext('2d');

    //ctx.strokeRect(0,0,80,80);
    //ctx.fillRect(100,0,80,80);
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

//greenflag-clickチャンネルがメッセージを受信したとき
ipcMain.on('greenflag-click', (event,arg) => {
    if (arg == 'Go') {
        subWindow = new BrowserWindow({
            width: 520, 
            height: 280,
            webPreferences: {
                nodeIntegration: false,
                contextIsolation: true,
                preload: path.join(__dirname, 'preload.js')
            }
        });
        //subWindow.loadFile('flash.html');
        subWindow.loadFile('exec-result.html')
            .then(() => {
                //コマンドcd app & flash.batの実行
                exec('cd ./app & ./app/flash.bat', (error,stdout,stderr) => {
                    /*if(stderr) {
                        // render.jsのexec-finishチャンネルにsend
                        subWindow.webContents.send('exec-finish', stderr + stdout + "<br><<実行終了>>");
                        log = stderr + stdout;
                    }
                    else {
                        // render.jsのexec-finishチャンネルにsend
                        subWindow.webContents.send('exec-finish', stdout + "<br><<実行終了>>");
                        log = stdout;
                    }

                    if(!fs.existsSync('./log')) {
                        fs.mkdirSync('log');
                    }
                    time = new Date();
                    now = String(time.getFullYear()) + String(time.getMonth()+1) + String(time.getDate());
                    fs.appendFile(`log/${now}_testlog.txt`, time + '\n' + log + '\n', (err, stdout) => {
                        if(err) console.log(err);//ファイル書き込みに関するエラー
                        else console.log('write end');
                    });*/
                })
            });
    }
});
// In this file you can include the rest of your app's specific main process
// code. You can also put them in separate files and require them here.