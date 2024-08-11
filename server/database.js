import mysql from 'mysql2'
import dotenv from 'dotenv'
dotenv.config()

const pool = mysql.createPool({
    host: process.env.MYSQL_HOST,
    user: process.env.MYSQL_USER,
    password: process.env.MYSQL_PASSWORD,
    port: process.env.MYSQL_PORT,
    database: process.env.MYSQL_DATABASE
}).promise()


export async function getPokemons() {
    const [rows] = await pool.query("SELECT * FROM pokemons")
    return rows
}

export async function insertPokemons(name, image) {
    await pool.query(
        `INSERT INTO pokemons (name, image)
        VALUES (?, ?)`,
        [name, image])
     return getPokemons()
}


