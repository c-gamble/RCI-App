module.exports = async (req, res) => {
    console.log("route for home")
    //const userId = req.session.userId
    const allPosts = await Post.find({})
    
    if (req.wantsJSON){
        return res.send(allPosts)
    }

    res.view('pages/home', {allPosts})
}