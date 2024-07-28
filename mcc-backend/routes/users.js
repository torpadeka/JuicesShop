var express = require("express");
var router = express.Router();
var db = require("./../database/db");
var bcrypt = require("bcrypt");
var jwt = require("jsonwebtoken");

/* GET users listing. */
router.get("/", function (req, res, next) {
    res.send("respond with a resource");
});

var doRegister = (username, password) => {
    return new Promise((resolve, reject) => {
        var hashPassword = bcrypt.hashSync(password, 10);
        db.query(
            "insert into users (username, password) value (?, ?)",
            [username, hashPassword],
            (error, result) => {
                if (!!error) return reject(error);
                resolve(result);
            }
        );
    });
};

router.post("/register", function (req, res, next) {
    const body = req.body;
    doRegister(body.username, body.password).then(
        (result) => {
            res.status(200).json(result);
        },
        (error) => {
            console.error(error);
            res.status(500).json({ error: error.message });
        }
    );
});

var doLogin = (username, password) => {
    return new Promise((resolve, reject) => {
        db.query(
            "SELECT id, username, password FROM users WHERE username = ?",
            [username],
            (error, result) => {
                if (error) {
                    console.error("Database query error:", error);
                    return reject(error);
                }
                console.log("Query result:", result); // Debugging line

                if (result.length === 0) {
                    return reject(new Error("User not found"));
                }

                const isUserExists = bcrypt.compareSync(
                    password,
                    result[0].password
                );

                if (isUserExists) {
                    const expiresIn = Math.floor(Date.now() / 1000) + 3600;
                    const token = jwt.sign(
                        { username: result[0].username },
                        process.env.API_SECRET,
                        { expiresIn: "1h" }
                    );

                    resolve({
                        token: token,
                        username: result[0].username,
                        id: result[0].id,
                        expiresIn: new Date(expiresIn * 1000).toISOString(),
                    });
                } else {
                    return reject(new Error("Invalid password"));
                }
            }
        );
    });
};

router.post("/login", function (req, res, next) {
    const body = req.body;
    doLogin(body.username, body.password).then(
        (result) => {
            res.status(200).json(result);
        },
        (error) => {
            console.error(error);
            res.status(500).json({ error: error.message });
        }
    );
});

var getUserInfo = (userId) => {
    return new Promise((resolve, reject) => {
        db.query(
            "select * from users where id = ?",
            [userId],
            (error, result) => {
                if (!!error) return reject(error);
                if (result.length === 0) return reject(new Error("User not found"));
                resolve(result[0].username);
            }
        );
    });
};


router.get("/info/:userId", function (req, res, next) {
    getUserInfo(req.params.userId).then(
        (result) => {
            res.status(200).json({ username: result });
        },
        (error) => {
            res.status(500).json({ error: error.message });
        }
    );
});


module.exports = router;
