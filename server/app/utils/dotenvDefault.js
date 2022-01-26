require("dotenv").config()

const envOrNull = env => env ? env : null

HTTP_PORT = process.env.HTTP_PORT ? process.env.HTTP_PORT : 80
FILE_NAME = envOrNull(process.env.FILE_NAME)
TEST_NAME = envOrNull(process.env.TEST_NAME)

module.exports = {
    HTTP_PORT,
    FILE_NAME,
    TEST_NAME
}