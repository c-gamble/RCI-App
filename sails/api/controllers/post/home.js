module.exports = async (req, res) => {
    console.log("route for home")
    const allPosts = await Post.find(0)
    res.view('pages/home', {allPosts})
}