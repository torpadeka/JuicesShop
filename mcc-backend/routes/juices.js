var express = require("express");
var router = express.Router();
var db = require("./../database/db");
var multer = require("multer");
var auth = require("./../middleware/auth");

// Apply auth middleware to ALL routers here
router.use(auth);

var getJuices = new Promise((resolve, reject) => {
    db.query("select * from juices", (error, result) => {
        if (!!error) reject(error);
        resolve(result);
    });
});

var getJuiceById = (id) =>
    new Promise((resolve, reject) => {
        db.query("select * from juices where id = ?", [id], (error, result) => {
            if (!!error) reject(error);
            resolve(result);
        });
    });

// Set storage config for multer
var storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, "public/images");
    },
    filename: (req, file, cb) => {
        cb(null, `${Date.now()}-${file.originalname}`);
    },
});

// Set upload multer instance with the storage config above
var upload = multer({
    storage: storage,
});

var createJuice = (name, price, category, image) =>
    new Promise((resolve, reject) => {
        db.query(
            "insert into juices (name, price, category, image) value(?, ?, ?, ?)",
            [name, price, category, image],
            (error, result) => {
                if (!!error) reject(error);
                resolve(result);
            }
        );
    });

var updateJuice = (id, name, price, category, image) =>
    new Promise((resolve, reject) => {
        db.query(
            "UPDATE juices SET name = ?, price = ?, category = ?, image = ? WHERE id = ?",
            [name, price, category, image, id],
            (error, result) => {
                if (!!error) reject(error);
                resolve(result);
            }
        );
    });

const deleteJuice = (id) =>
    new Promise((resolve, reject) => {
        db.query("DELETE FROM juices WHERE id = ?", [id], (error, result) => {
            if (error) {
                return reject(error);
            }
            resolve(result);
        });
    });

router.get("/", function (req, res, next) {
    console.log(req.user.username);
    getJuices.then(
        (result) => {
            res.status(200).json(result);
        },
        (error) => {
            res.status(500).send(error);
        }
    );
});

// Example of obtaining parameter
// .json returns data in json format
router.get("/:id", function (req, res, next) {
    getJuiceById(req.params.id).then(
        (result) => {
            res.status(200).json(result);
        },
        (error) => {
            res.status(500).send(error);
        }
    );
});

router.post("/create", upload.single("image"), function (req, res, next) {
    const body = req.body;
    createJuice(body.name, body.price, body.category, req.file.path).then(
        (result) => {
            res.status(200).json(result);
        },
        (error) => {
            res.status(500).send(error);
        }
    );
});

router.post("/update", upload.single("image"), function (req, res, next) {
    const body = req.body;
    updateJuice(
        body.id,
        body.name,
        body.price,
        body.category,
        req.file.path
    ).then(
        (result) => {
            res.status(200).json(result);
        },
        (error) => {
            res.status(500).send(error);
        }
    );
});

router.post("/delete/:id", function (req, res, next) {
    deleteJuice(req.params.id).then(
        (result) => {
            if (result.affectedRows === 0) {
                return res.status(404).send({ message: "Juice not found" });
            }
            res.status(200).json(result);
        },
        (error) => {
            res.status(500).send(error);
        }
    );
});

module.exports = router;
