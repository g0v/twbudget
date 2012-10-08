Q = require \q
{Product} = require \./lib/schema
json = try JSON.parse do
    require \fs .readFileSync \environment.json \utf8
mongoose = require \mongoose
mongoose.connect json?MONGOLAB_URI ? process.env?MONGOLAB_URI ? \mongodb://localhost/ydh

p = new Product do
    name: "ONE X"
    brand: "HTC"
    image: "XXX"
    excerpt: 'lalala lal lala'
    description: 'llfdsf kldsfk lfsad '
    meta: {}
    tags: []

defer = Q.defer!
defers = []
defers.push defer.promise

do
    err <- p.save
    defer.resolve!

<- Q.allResolved defers
.then
console.log \alldone
process.exit 0
