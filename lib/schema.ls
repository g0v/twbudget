mongoose = require \mongoose
Schema = mongoose.Schema

s =
    ProductSchema: Schema do
        name: String
        brand: String
        image: String
        excerpt: String
        description: String
        variant: []
        meta: {}
        tags: []

s.ItemSchema = Schema do
        product: String
        price: Number
        merchant: String

module.exports = { [name, mongoose.model name, s[name + 'Schema']] for name in
    <[ Product ]>
}
