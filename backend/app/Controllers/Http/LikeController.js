"use strict";
const Member = use("App/Models/Member");
const Post = use("App/Models/Post");
const Like = use("App/Models/Like");
const Database = use("Database");
/**
 * Resourceful controller for interacting with likes
 */
class LikeController {
  /*
  Description: Display people who like the post
  */
  async whoLike({ params, response }) {
    try {
      const like = await Database.from("likes").where({
        PostID: params.postID
      });

      //Acquire latest userName of each user
      let memberList = [];
      await like.map(row => {
        memberList.push(row.MemberID);
      });

      const member = await Database.from("members").whereIn("id", memberList);

      await like.map((row, index) => {
        row.userName = member[index].userName;
      });

      return response.json({
        status: "Success",
        likes: like
      });
    } catch (error) {
      console.log(err);
      return response.json({
        status: "Fail",
        reason: "Server Error"
      });
    }
  }

  /*
  request{
    userEmail:'',
    postID:''
  }
  response{
    status: "Success/Fail",
    reason: (When status is Fail)
  }

  Description:
    Like/UnLike a post
  */
  async like({ request, response }) {
    try {
      const member = await Member.findBy("email", request.input("userEmail"));
      const post = await Post.find(request.input("postID"));
      const isLike = await Database.table("likes")
        .where("MemberID", member.id)
        .where("PostID", post.id)
        .first();
      if (isLike === undefined) {
        //Has not liked yet
        const like = new Like();
        like.MemberID = member.id;
        like.PostID = request.input("postID");
        like.postFromID = post.MemberID;
        await like.save();
      } else {
        await Database.table("likes")
          .where("MemberID", member.id)
          .where("PostID", post.id)
          .delete();
      }

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

module.exports = LikeController;
