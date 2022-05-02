module.exports = {
    posts: async (req, res) => {
        try {
        const posts = await Post.find()
        res.send(posts)
        } catch(err){
            return res.serverError(err.toString())
        }
    },
    create: (req, res) => {
        const title = req.body.title
        const postBody = req.body.postBody
        Post.create({title:title, postBody:postBody}).exec((err) => {
            if (err) {
                return res.serverError(err.toString())
            }
            console.log("post object created successfuly")
            return res.redirect('/home')
        })
    },
    findById: (req, res) => {
        const postId = req.param('postId')
        const filteredPosts = allPosts.filter( p => {return p.id == postId})
        if (filteredPosts.length > 0){
            res.send(filteredPosts[0])
        } else {
            res.send("failed to find post by id: " + postId)
        }
        res.send(postId)
    },
    delete: async (req, res) => {
        const postId = req.param('postId')
        await Post.destroy({id:postId})
        res.send("deletion successful")
    }
}