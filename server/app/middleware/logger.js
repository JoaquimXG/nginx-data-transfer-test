const log = require("../utils/logger");

//Creates a middleware function which will be run
//whenever a request is made to express. This function
//takes the request object containing request metadata
//and logs some of the more important pieces of information.
//This is useful when developing and debugging the application
module.exports = (req, res, next) => {
  log.http({
    req: {
      headers: {
        cookie: req.cookies,
        sessionId: req.sessionID,
        accept: req.headers.accept,
        host: req.hostname
      },
      source: req.ip,
      method: req.method,
      sessionId: req.sessionId,
      originalUrl: req.originalUrl,
      query: req.query,
      body: req.body,
      params: req.params,
    },
  });
  next();
};