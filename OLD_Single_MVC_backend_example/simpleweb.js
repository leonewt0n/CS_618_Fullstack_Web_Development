import { createServer } from 'node:http'
import { readFileSync } from 'node:fs'
const server = createServer((req, res) => {
  res.statsCode = 200
  res.setHeader('Content-Type', 'application/json')
  res.end(readFileSync('users.json'))
})
const host = 'localhost'
const port = 3000
server.listen(port, host, () => {
  console.log(`Server listening on ${host}:${port}`)
})
