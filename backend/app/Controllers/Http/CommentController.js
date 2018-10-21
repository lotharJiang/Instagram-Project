"use strict";
const Comment = use("App/Models/Comment");
const Member = use("App/Models/Member");
const Database = use("Database");

/**
 * Resourceful controller for interacting with comments
 */
class CommentController {
  /*Description:
    Acquiring comments for a post
  */
  async acquireComment({ params, response }) {
    try {
      const comments = await Database.from("comments").where({
        PostID: params.postID
      });
      let data = [];
      for (let index in comments) {
        let commentContent = new Object();
        let comment = comments[index];
        let member = await Member.find(comment.MemberID);
        comment.userEmail = member.email;

        commentContent.comment = comment.comment;
        commentContent.commentUser = comment.userEmail;
        data.push(commentContent);
      }
      return response.json({ data: data });
    } catch (error) {
      console.log(error);
    }
  }

  /*
  request{
    userEmail:'',
    postID:'',
    comment:''
  }
  response{
    status: "Success/Fail",
    reason: (When status is Fail)
  }
  Description:
    Leave a comment to a post
  */
  async postComment({ request, response }) {
    try {
      const member = await Member.findBy("email", request.input("userEmail"));

      const comment = new Comment();
      comment.MemberID = member.id;
      comment.PostID = request.input("postID");
      comment.comment = request.input("comment");
      await comment.save();

      return response.json({
        status: "Success"
      });
    } catch (err) {
      console.log(err);
      return response.json({
        status: "Fail",
        reason: "Server Error"
      });
    }
  }
}

module.exports = CommentController;
