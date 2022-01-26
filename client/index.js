require("dotenv").config()
const http = require('http');
const fs = require('fs');
const path = require("path")
const textLog = require("./utils/textLog")
const log = require("./utils/logger.js")

const downloadFile = async (url, dest, cb) => {
    var file = fs.createWriteStream(dest);
    http.get(url, (res) => {
        res.pipe(file);
        file.on('finish', () => {
            file.end();
            cb()
        });
    })
    .on('error', () => {
        fs.unlink(dest)
    });
};

const downloadSingleServer = async (hostname) => {
    let url = `http://${hostname}/download`
    
    count = 0;
    let interval = setInterval(async () => {
        log.info(`Downloading: ${count} from ${hostname}`)
        dest = path.join(__dirname, "downloads", `${hostname}-${count}.bin`)

        await downloadFile(url, dest, {
            success: () => {
                textLog(path.join(__dirname, "logs", "downloads.log"),
                    {testName: process.env.TEST_NAME, event: "DownloadSuccess", downloadHostname: hostname})
                log.info(`Completed: ${count} from ${hostname}`)
            }, 
            error: () => {
                textLog(path.join(__dirname, "logs", "downloads.log"),
                    {testName: process.env.TEST_NAME, event: "DownloadFailed", downloadHostname: hostname})
                log.warn(`Failed: ${count} from ${hostname}`)
            }
        })
        
        if (++count == process.env.NUM_DOWNLOADS) {
            clearInterval(interval)
        }
    }, 1000*10)
}

const main = () => {
    // TODO: Handle multiple hosts at the same time
    downloadSingleServer(process.env.DOWNLOAD_HOSTNAME)
}

main()