const app = require('express')()
const loggerMiddleware = require('./app/middleware/logger')
const log = require("./app/utils/logger")
const generateFile = require("./app/utils/generateFile")
const path = require("path")
const textLog = require("./app/utils/textLog")

const { HTTP_PORT, FILE_NAME, TEST_NAME } = require("./app/utils/dotenvDefault")

app.use(loggerMiddleware)

app.get("/", (req,res) => {
    res.send("<a href='/download'>Click to download test file</a>")
})

app.get("/download", (req, res) => {
    let fPath = path.resolve(__dirname, "app/static",  FILE_NAME)
    generateFile(1024*1024*100, fPath)
    
    res.download(fPath, err => {
        if (err) log.warn(err)

        else textLog(path.resolve(__dirname, "logs", "download.log"),
        {testName: TEST_NAME, event: "DownloadSuccess"})
    })
})

app.get("*", (req, res) => {
    jsonResponse = {
        req: {
            headers: {
                cookie: req.cookies,
                sessionId: req.sessionID,
                accept: req.headers.accept,
            },
            method: req.method,
            sessionId: req.sessionId,
            originalUrl: req.originalUrl,
            query: req.query,
            body: req.body,
            params: req.params,
        }
    }
    res.send(`<pre>${JSON.stringify(jsonResponse, null, 2)}</pre>`)
})

app.listen(HTTP_PORT, () => log.info(`Example app listening on port ${HTTP_PORT}`))