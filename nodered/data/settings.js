module.exports = {
    uiPort: process.env.PORT || 1880,
    mqttReconnectTime: 15000,
    adminAuth: {
        type: "credentials",
        users: [{
            username: "remu_admin",
            password: "$2b$08$Y.HkfenOdKbqx721Fnvq6eFc3p7LxWWcsf7sfEKrPzmUB5mNwzUfG",
            permissions: "*"
        }]
    },
    httpNodeCors: {
        origin: "*",
        methods: "GET,PUT,POST,DELETE"
    }
};
