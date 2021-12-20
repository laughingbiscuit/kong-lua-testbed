const express = require('express')
const app = express()
const port = 3000

app.all('*', (req, res) => {
  res.send(req.originalUrl)
})

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`)
})
