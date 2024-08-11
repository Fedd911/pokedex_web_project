import express from 'express'
import cors from 'cors'

import { getPokemons, insertPokemons } from './database.js'

const app = express()

app.use(cors())

app.use(express.json())

app.get("/", async (req, res) => {
    const pokemons = await getPokemons()
    res.send(pokemons)
})

app.post("/", async (req, res) => {
    const { name, image} = req.body
    const pokemon = await insertPokemons(name, image)
    res.send(pokemon)
})

app.use((err, req, res, next) => {
    console.error(err.stack)
    res.status(500).send('Something broke!')
})

app.listen(8080, () => {
    console.log('Server is running on port 8080')
})