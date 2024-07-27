require("dotenv").config();

var express = require("express");
const cors = require('cors');
var path = require("path");
var cookieParser = require("cookie-parser");
var logger = require("morgan");

var indexRouter = require("./routes/index");
var usersRouter = require("./routes/users");
var juicesRouter = require("./routes/juices");
var reviewsRouter = require("./routes/reviews")

var app = express();

app.use(cors());

app.use(logger("dev"));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use('/images', express.static(path.join(__dirname, 'public/images')));

app.use("/", indexRouter);
app.use("/users", usersRouter);
app.use("/juices", juicesRouter);
app.use("/reviews", reviewsRouter);

module.exports = app;
