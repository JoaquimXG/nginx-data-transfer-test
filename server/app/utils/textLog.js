const fs = require("fs")

module.exports = (path, dict) => {
    dict = {ts: new Date().toISOString(), ...dict}
    fs.appendFile(path, `${JSON.stringify(dict)}\n`,
     err => { if (err) console.log(err) })
}
