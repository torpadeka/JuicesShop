var express = require("express");
var router = express.Router();
var db = require("./../database/db");
var multer = require("multer");
var auth = require("./../middleware/auth");

// Apply auth middleware to ALL routers here
router.use(auth);

var createReview = (userId, juiceId, review) =>
    new Promise((resolve, reject) => {
        db.query(
            "insert into reviews (userId, juiceId, review) value(?, ?, ?)",
            [userId, juiceId, review],
            (error, result) => {
                if (!!error) reject(error);
                resolve(result);
            }
        );
    });

var getReviewByJuiceId = (juiceId) =>
    new Promise((resolve, reject) => {
        db.query(
            "select * from reviews where juiceId = ?",
            [juiceId],
            (error, result) => {
                if (!!error) reject(error);
                resolve(result);
            }
        );
    });

var getReviewById = (id) =>
    new Promise((resolve, reject) => {
        db.query(
            "select * from reviews where id = ?",
            [id],
            (error, result) => {
                if (!!error) reject(error);
                resolve(result);
            }
        );
    });

router.get("/:id", function (req, res, next) {
    getReviewById(req.params.id).then(
        (result) => {
            res.status(200).json(result);
        },
        (error) => {
            res.status(500).send(error);
        }
    );
});

router.get("/juice/:juiceId", function (req, res, next) {
    getReviewByJuiceId(req.params.juiceId).then(
        (result) => {
            res.status(200).json(result);
        },
        (error) => {
            res.status(500).send(error);
        }
    );
});

router.post("/create", function (req, res, next) {
    const body = req.body;
    createReview(body.userId, body.juiceId, body.review).then(
        (result) => {
            res.status(200).json(result);
        },
        (error) => {
            res.status(500).send(error);
        }
    );
});

module.exports = router;
