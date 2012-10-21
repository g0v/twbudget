bcrypt = require \bcrypt
mongoose = require \mongoose
Schema = mongoose.Schema

s = {}
User = s.UserSchema = new Schema do
    name: String
    email: { type: String, +sparse, +unique }
    salt: { type: String }
    hash: { type: String }
    votepref: String
    votearea: String
    accounts: []

User.virtual('password')
    .get -> @_password
    .set (password) ->
        @_password = password
        salt = @salt = bcrypt.genSaltSync 10
        @hash = bcrypt.hashSync password, salt

User.method 'verifyPassword' (password, callback) -> bcrypt.compare password, @hash, callback

User.static 'authenticate' (email, password, callback) ->
    console.log \auth, email
    err, user <- @findOne email: email
    if err => return callback err
    unless user => return callback null null message: "Unknown User"
    user.verifyPassword password, (err, passwordCorrect) ->
        | err              => callback err
        | !passwordCorrect => callback null false message: "Invalid Password"
        | otherwise        => callback null user

module.exports = { [name, mongoose.model name, s[name + 'Schema']] for name in
    <[ User ]>
}
