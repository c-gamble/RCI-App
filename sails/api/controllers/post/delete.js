const PostsController = require("../PostsController");

module.exports = {


  friendlyName: 'Delete',


  description: 'Delete post.',


  inputs: {
    postId: {
      type: "string",
      required: true
    }
  },


  exits: {
    invalid: {
      description: "post requested for deletion is invalid"
    }
  },


  fn: async function (inputs) {
    const record = await Post.destroy({id: inputs.postId}).fetch()

    if (record.length == 0) {
      throw({invalid: `object ${inputs.postId} does not exist`})
    }
    return record;
  }


};
