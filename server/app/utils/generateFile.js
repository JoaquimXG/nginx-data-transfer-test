const fs = require("fs");
const log = require("../utils/logger")

module.exports = (size, path) => {
    
    log.debug(path)
    try {
        if (!fs.existsSync(path)) {
            log.info("Creating random file")
            fs.writeFileSync(path, new Buffer.alloc(size));
        }
    }
    catch(err) {
        log.error(err)
    }
    return
};