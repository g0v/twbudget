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

s.BudgetItemSchema = Schema do
    key: String
    nlikes: Number
    nconfuses: Number
    nhates: Number
    ncuts: Number
    likes: []
    confuses: []
    hates: []
    cuts: []
    tags: []

module.exports = { [name, mongoose.model name, s[name + 'Schema']] for name in
    <[ Product BudgetItem ]>
}
