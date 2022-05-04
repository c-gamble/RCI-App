module.exports = async (req, res) => {
    console.log("route for home")
    //const userId = req.session.userId
    const allPosts = await Post.find({})
    res.view('pages/home', {allPosts})
}