module.exports = {


  friendlyName: 'Create',


  description: 'Create post.',


  inputs: {
    title: {
      description: "title of post object",
      type: "string", 
      required: true
    },
    postBody: {
      description: "content of post object",
      type: "string", 
      required: true
    }
  },


  exits: {

  },


  fn: async function (inputs) {
    const userId = this.req.session.userId
    await Post.create({title: inputs.title, postBody: inputs.postBody, user: userId})
   
    this.res.redirect("/home")

  }


};
