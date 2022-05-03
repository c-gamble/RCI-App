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
    await Post.create({title: inputs.title, postBody: inputs.postBody})
   
    return;

  }


};
