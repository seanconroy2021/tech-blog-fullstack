// Dependencies
const express = require("express");
const expressHandlebars = require("express-handlebars");
const session = require("express-session");
const path = require("path");
const SequelizeStore = require("connect-session-sequelize")(session.Store);
const sequelize = require("./config/connection");
const controllers = require("./controllers");
// Import the custom helper methods
const helpers = require("./utils/helpers");
// Incorporate the custom helper methods: ./utils/helpers.js
const handlebars = expressHandlebars.create({ helpers });
require("dotenv").config();

// Sets up the Express App
const app = express();
const PORT = process.env.PORT || 3001;

const sess = {
    secret: process.env.SESSION_SECRET,
    cookie: {
        maxAge: 28800000, // 8 hours in milliseconds
        secure: true, // Ensures the cookie is sent over HTTPS
        httpOnly: true, // Prevents client-side JavaScript from reading the cookie
        sameSite: 'strict', // Prevents CSRF attacks
    },
    resave: false,
    saveUninitialized: true, // Changed to true to comply with laws and regulations
    store: new SequelizeStore({
        db: sequelize,
    }),
};
app.use(session(sess));

//setup handlebars with express
app.engine("handlebars", handlebars.engine);
app.set("view engine", "handlebars");

//allow api to use json and url encoding
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
//set public folder
app.use(express.static(path.join(__dirname, "public")));

// Sets up the routes
app.use(controllers);


// Starts the server to begin listening with sequelize for db connection
//force start should be false if using 'npm run seed' to populate and create db as it will recreate tables each server reload
sequelize.sync({ force: false }).then(() => {
    app.listen(PORT, () => console.log("Now listening: " + PORT));
});
