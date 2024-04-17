const Sequelize = require("sequelize");
require("dotenv").config();

let sequelize;
//sequelize object with .env config parameter used throughout app
//if statement contains logic to run on heroku or local
if (process.env.JAWSDB_URL) {
    sequelize = new Sequelize(process.env.JAWSDB_URL);
} else {
    sequelize = new Sequelize(
        process.env.DB_NAME,
        process.env.DB_USER,
        process.env.DB_PASSWORD,
        {
            host: process.env.DB_HOST,
            dialect: "mysql",
            port: process.env.DB_PORT,
        }
    );
}

module.exports = sequelize;
