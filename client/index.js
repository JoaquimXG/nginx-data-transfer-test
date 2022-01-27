require("dotenv").config()
const http = require('http');
const fs = require('fs');
const path = require("path")
const textLog = require("./utils/textLog")
const log = require("./utils/logger.js")
const isReachable = require("is-reachable");

const downloadFile = async (url, dest) => {
    var file = fs.createWriteStream(dest);
    return new Promise((resolve, reject) => {
        http.get(url, (res) => {
            res.pipe(file);
            file.on('finish', () => {
                file.end();
                resolve()
            });
        })
            .on('error', (err) => {
                reject(err)
                fs.unlinkSync(dest)
            })
    })
};

const isHostOnline = (hostname, cb) => {
    log.debug("Checking if host is online")
    let interval = setInterval(async () => {
        if (await isReachable(`http://${hostname}`)) {
            log.debug("Host online: starting downloads")
            clearInterval(interval)
            cb()
        }
        else
            log.warn(`host ${hostname} is not reachable. Trying again`)
    }, 3000)
}

const downloadXFiles = (hostname, count, numDownloads) => {
    dest = path.join(__dirname, "downloads", `${hostname}-${count}.bin`)
    let url = `http://${hostname}/download`
    
    if (count == numDownloads) {
        return
    }

    log.info(`Downloading: ${count} from ${hostname}`)
    downloadFile(url, dest)
        .then((res) => {
            textLog(path.join(__dirname, "logs", "downloads.log"),
                { testName: process.env.TEST_NAME, event: "DownloadSuccess", host: hostname })
            log.info(`Completed: ${count} from ${hostname}`)
            downloadXFiles(hostname, ++count, numDownloads)
        })
        .catch((err) => {
            log.error(err)
            textLog(path.join(__dirname, "logs", "downloads.log"),
                { testName: process.env.TEST_NAME, event: "DownloadFailed", host: hostname })
            log.warn(`Failed: ${count} from ${hostname}`)
            downloadXFiles(hostname, count, numDownloads)
        })
}

const main = async () => {
    hosts = process.env.DOWNLOAD_HOSTNAMES.trim().split(",").map(host => host.trim())
    
    log.debug(`Downloading from ${hosts}`)
    
    hosts.forEach(host => {
        isHostOnline(host, () => {
            downloadXFiles(host, 0, process.env.NUM_DOWNLOADS)
        })
    })
}

main()