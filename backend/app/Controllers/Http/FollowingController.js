"use strict";
const Following = use("App/Models/Following");
const Member = use("App/Models/Member");
const Database = use("Database");
/**
 * Resourceful controller for interacting with followings
 */
class FollowingController {
  /*
  request{
    userEmail:"",
    followingID:""
  }
   response{
    status:'Success/Fail',
    reason:(When status is Fail)
  }

  Description:
    Unfollow a user
  */
  async unfollow({ request, response }) {
    try {
      const member = await Member.findBy("email", request.input("userEmail"));
      const following = await Member.findBy("email", request.input("followingID"));
      await Database.table("followings")
        .where("MemberID", member.id)
        .where("FollowingMemberID", following.id)
        .delete();

      return response.json({
        status: "Success"
      });
    } catch (error) {
      console.log(error);
      return response.json({
        status: "Fail",
        reason: "Server Error"
      });
    }
  }

  /*
  request{
    userEmail:'',
    followingID:''
  }
  response{
    status:'Success/Fail',
    reason:(When status is Fail)
  }

  Description:
    Follow a user
  */
  async follow({ request, response }) {
    try {
      const follow = new Following();
      const member = await Member.findBy("email", request.input("userEmail"));
      const following = await Member.findBy("email", request.input("followingID"));
      follow.MemberID = member.id;
      follow.FollowingMemberID = following.id;
      await follow.save();

      response.json({
        status: "Success"
      });
    } catch (error) {
      console.log(error);
      return response.json({
        status: "Fail",
        reason: "Server Error"
      });
    }
  }
}

module.exports = FollowingController;
