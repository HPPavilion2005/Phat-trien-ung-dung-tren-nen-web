module.exports = {
    uiPort: process.env.PORT || 1880,
    mqttReconnectTime: 15000,
    serialReconnectTime: 15000,

    // Bắt buộc đăng nhập khi truy cập Node-RED Editor
    adminAuth: {
        type: "credentials",
        users: [{
            username: "remu_admin",
            // Mật khẩu tương ứng với chuỗi hash này là: admin123
            password: "$2b$08$8/LskwU6rU1y/hR7Qp8QCe1X8z5aBqJqYQYgL3zVlY7Fm2Yx1G5eq",
            permissions: "*"
        }]
    },

    // Cho phép gọi HTTP API không bị chặn CORS
    httpNodeCors: {
        origin: "*",
        methods: "GET,PUT,POST,DELETE"
    },

    functionGlobalContext: { }
};
