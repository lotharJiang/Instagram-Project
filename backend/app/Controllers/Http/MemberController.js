"use strict";
const Encryption = use("Encryption");
const Member = use("App/Models/Member");
const imagePath = "UserPortrait";
const Database = use("Database");
const Post = use("App/Models/Post");

class MemberController {
  /*
  Description:
    Display recommended users

  Algorithm: Jaccard Similarity

                  |Intersection Set of Neighbor(i) and Neighbor(j)|
    Score(x,y) =  -------------------------------------------------
                      |Union Set of Neighbor(i) and Neighbor(j)|
  */
  async suggestedUser({ params, response }) {
    const member = await Member.findBy("email", params.userEmail);
    const followings = await Database.from("followings").where({
      MemberID: member.id
    });

    //Acquire recommended user's followers
    let memberFollowing = [];
    followings.map(following => {
      memberFollowing.push(following.FollowingMemberID);
    });
    const followMe = [];
    const followMeFollower = await Database.from("followings").where({
      FollowingMemberID: member.id
    });
    followMeFollower.map(following => {
      followMe.push(following.MemberID);
    });
    let aSet = new Set(memberFollowing);
    let bSet = new Set(followMe);
    memberFollowing = Array.from(new Set(followMe.filter(v => aSet.has(v))));

    //Acquire others user's
    const users = await Database.from("members").whereNot("id", member.id);
    // console.log(users)
    let usersArray = [];
    //Acquire others user's followers

    for (let index in users) {
      let user = users[index];
      let temObj = new Object();
      //I follow who
      let followers = await Database.from("followings").where({
        MemberID: user.id
      });
      let followerArray = [];
      followers.map(follower => {
        followerArray.push(follower.FollowingMemberID);
      });

      //who follow me
      const followMe = [];
      const followMeFollower = await Database.from("followings").where({
        FollowingMemberID: user.id
      });
      followMeFollower.map(following => {
        followMe.push(following.MemberID);
      });
      let aSet = new Set(followerArray);
      let bSet = new Set(followMe);
      followerArray = Array.from(new Set(followMe.filter(v => aSet.has(v))));

      temObj.userID = user.id;
      temObj.followers = followerArray;
      usersArray.push(temObj);
    }

    //Exclude existed follower
    let excludedArray = [];
    usersArray.map(user => {
      let isIn = false;
      memberFollowing.map(id => {
        if (user.userID === id) {
          isIn = true;
        }
      });
      if (!isIn) {
        excludedArray.push(user);
      }
    });
    usersArray = excludedArray;

    /*usersArray, memberFollowing */
    //Assign recommend value
    let recommendArray = [];
    usersArray.map(user => {
      let unionSet = Array.from(
        new Set(user.followers.concat(memberFollowing))
      );
      let recommendUser = new Object();
      recommendUser.userID = user.userID;
      if (unionSet.length === 0) {
        recommendUser.coe = 0;
      } else {
        let aSet = new Set(memberFollowing);
        let bSet = new Set(user.followers);

        let intersection = Array.from(
          new Set(memberFollowing.filter(v => bSet.has(v)))
        );
        recommendUser.coe = intersection.length / parseFloat(unionSet.length);
      }
      recommendArray.push(recommendUser);
    });
    recommendArray.sort(function(a, b) {
      var keyA = new Date(a.coe),
        keyB = new Date(b.coe);
      if (keyA < keyB) return 1;
      if (keyA > keyB) return -1;
      return 0;
    });

    //Format response data
    let responseData = [];
    for (let index in recommendArray) {
      let recommend = recommendArray[index];
      let temObj = new Object();
      const member = await Member.find(recommend.userID);
      temObj.userEmail = member.email;
      temObj.profilePic = member.profilePic;
      responseData.push(temObj);
    }
    response.json({ data: responseData });
  }
  async acquireLatestActionFromFollower({ params, response }) {
    try {
      //email -> likes -> truncate into 10 -> adding event attribute
      const member = await Member.findBy("email", params.userEmail);
      const likes = await Database.from("likes").where({
        postFromID: member.id
      });
      likes.slice(0, 10);
      likes.map(like => {
        like.event = "like";
      });
      //email -> follow -> truncate into 10 -> adding event attribute
      const followings = await Database.from("followings").where({
        FollowingMemberID: member.id
      });
      followings.slice(0, 10);
      followings.map(following => {
        following.event = "follow";
      });

      //Join two arrays and proceed sort by created_at
      let activityArray = likes.concat(followings);
      activityArray.sort(function(a, b) {
        var keyA = new Date(a.created_at),
          keyB = new Date(b.created_at);
        if (keyA < keyB) return 1;
        if (keyA > keyB) return -1;
        return 0;
      });
      activityArray.slice(0, 10);

      for (let index in activityArray) {
        let activity = activityArray[index];
        let userEmail = await Member.find(activity.MemberID);
        activity.userEmail = userEmail.email;

        //Adding Time to now
        let date = new Date();
        let created_at = new Date(activity.created_at);
        activity.timeToNow = Math.ceil((date - created_at) / (1000 * 3600));

        //Adding Figures
        if (activity.event === "like") {
          const member = await Member.find(activity.MemberID);
          activity.memberPortrait = member.profilePic;
          const post = await Post.find(activity.PostID);
          activity.postPic = post.postPic;
        } else {
          const member = await Member.find(activity.MemberID);
          activity.memberPortrait = member.profilePic;
          activity.postPic = "http://115.146.84.191/UserPost/test2.jpg";
        }
      }

      //Format response
      response.json({ data: activityArray });
    } catch (error) {
      console.log(error);
    }
  }

  /*
  request{
    lastLikeID:
    lastFollowID:
    userEmail:
  }
  Description:
    Acquire former data for Activity Feed: User
  */
  async acquireOldActionFromFollower({ params, response }) {
    //email -> like -> truncate into 10 -> adding event attribute
    const member = await Member.findBy("email", params.userEmail);
    const likes = await Database.from("likes")
      .where({
        postFromID: member.id
      })
      .where("id", "<", params.lastLikeID);
    likes.slice(0, 10);
    likes.map(like => {
      like.event = "like";
    });
    //email -> follow -> truncate into 10 -> adding event attribute
    const followings = await Database.from("followings")
      .where({
        FollowingMemberID: member.id
      })
      .where("id", "<", params.lastFollowID);
    followings.slice(0, 10);
    followings.map(following => {
      following.event = "follow";
    });
    //Join two arrays and proceed sort by created_at
    let activityArray = likes.concat(followings);
    activityArray.sort(function(a, b) {
      var keyA = new Date(a.created_at),
        keyB = new Date(b.created_at);
      if (keyA < keyB) return 1;
      if (keyA > keyB) return -1;
      return 0;
    });
    activityArray.slice(0, 10);

    for (let index in activityArray) {
      let activity = activityArray[index];
      let userEmail = await Member.find(activity.MemberID);
      // console.log(userEmail.userName);
      activity.userEmail = userEmail.userName;

      //Adding Time to now
      let date = new Date();
      let created_at = new Date(activity.created_at);
      activity.timeToNow = Math.ceil((date - created_at) / (1000 * 3600));

      //Adding Figures
      if (activity.event === "like") {
        const member = await Member.find(activity.MemberID);
        activity.memberPortrait = member.profilePic;
        const post = await Post.find(activity.PostID);
        activity.postPic = post.postPic;
      } else {
        const member = await Member.find(activity.MemberID);
        activity.memberPortrait = member.profilePic;
        activity.postPic = "http://115.146.84.191/UserPost/test2.jpg";
      }
    }

    //Find lastFollowEventID and lastLikeEventID
    let lastLikeID = 999;
    let lastFollowID = 999;
    activityArray.map(activity => {
      if (activity.event === "like") {
        if (activity.id < lastLikeID) {
          lastLikeID = activity.id;
        }
      } else {
        if (activity.id < lastFollowID) {
          lastFollowID = activity.id;
        }
      }
    });
    //Format response
    response.send(
      JSON.stringify({
        lastLikeID: lastLikeID,
        lastFollowID: lastFollowID,
        activities: activityArray
      })
    );
  }

  /*
  response{
        status: "Success/Fail",
        user: member,
        following: following,
        follower: follower,
        posts: posts,
        isFollow:isFollow,
        reason:(When status is Fail)
  }
  Description：
    Acquire other user's profile
  */
  async acquireOthersProfile({ params, response }) {
    try {
      let isFollow = await Database.table("followings")
        .where({ MemberID: params.userEmail })
        .where({ FollowingMemberID: params.othersEmail });

      if (isFollow.length === 0) {
        isFollow = false;
      } else {
        isFollow = true;
      }
      const member = await Member.findBy("email", params.othersEmail);
      const following = Database.table("followings").where({
        MemberID: member.id
      });
      const follower = Database.table("followings").where({
        FollowingMemberID: member.id
      });
      const posts = Database.table("posts").where({ MemberID: member.id });

      return response.json({
        status: "Success",
        user: member,
        following: following,
        follower: follower,
        posts: posts,
        isFollow: isFollow
      });
    } catch (error) {
      console.log(error);
      return response.json({
        status: "Fail",
        reason: "Server Error"
      });
    }
  }

  //AcquirePortrait -> url
  async acquirePortrait({ params, response }) {
    try {
      const member = await Member.findBy("email", params.userEmail);
      response.send(member.profilePic);
    } catch (error) {
      console.log(error);
    }
  }
  //AcquireInfo -> PostNum, Follower, Following
  async acquireUserInfo({ params, response }) {
    try {
      const member = await Member.findBy("email", params.userEmail);

      const following = await Database.table("followings").where({
        MemberID: member.id
      });

      const follower = await Database.table("followings").where({
        FollowingMemberID: member.id
      });

      const posts = await Database.table("posts").where({
        MemberID: member.id
      });

      response.send(
        posts.length + "," + follower.length + "," + following.length
      );
    } catch (error) {
      console.log(error);
    }
  }
  //AcquirePost -> urlString
  async acquireUserPosts({ params, response }) {
    try {
      const member = await Member.findBy("email", params.userEmail);
      let posts = await Database.table("posts").where({
        MemberID: member.id
      });
      posts = posts.reverse();
      let postArray = "";
      posts.map(post => {
        if (postArray != "") {
          postArray = postArray + "," + post.postPic;
        } else {
          postArray = post.postPic;
        }
      });
      response.send(postArray);
    } catch (error) {
      console.log(error);
    }
  }
  /*
  response{
    status:"Success/Fail",
    user:,
    following:,
    follower:,
    posts:,
    reason:(When status is Fail
  }

  Description:
    Acquire User's Profile
  */
  async acquireSelfProfile({ params, response }) {
    try {
      const member = await Member.findBy("email", params.userEmail);
      const following = await Database.table("followings").where({
        MemberID: member.id
      });
      const follower = await Database.table("followings").where({
        FollowingMemberID: member.id
      });
      const posts = await Database.table("posts").where({
        MemberID: member.id
      });

      return response.json({
        status: "Success",
        user: member,
        following: following,
        follower: follower,
        posts: posts
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
  response{
    status:'Success/Fail',
    reason:(When status is Fail),
    user:
  }

  Description:
    Search users
  */
  async searchUser({ params, response }) {
    try {
      let data = [];
      if (params.userEmail === params.searchedUser) {
        let obj = new Object();
        obj.email = params.userEmail;
        const user = await Database.table("members").where({
          email: params.userEmail
        });
        obj.profilePic = user[0].profilePic;
        obj.isFollow = false;
        data.push(obj);
        return response.json({ data: data });
      }

      const user = await Database.table("members").where({
        email: params.searchedUser
      });
      if (user != undefined) {
        //has user
        const actionUser = await Member.findBy("email",params.userEmail)
        const isFollow = await Database.from("followings")
          .where({ MemberID: actionUser.id })
          .where({ FollowingMemberID: user[0].id });
        let obj = new Object();
        obj.isFollow = false;
        if (isFollow.length > 0) {
          obj.isFollow = true;
        }

        obj.email = user[0].email;
        obj.profilePic = user[0].profilePic;
        data.push(obj);
        return response.json({ data: data });
      } else {
        return response.json({ data: data });
      }
    } catch (error) {
      console.log(error);
      let data = [];
      return response.json({ data: data });
    }
  }

  /*
  request{
    userEmail:"",
    userPortrait:{Picture stream}
  }
  response{
    status:"Success/Fail",
    reason:(When status is Fail)
  }
  Description:
    Upload/Update user's portrait
  */
  async updatePortrait({ request, response }) {
    try {
      const postPic = request.file("userPortrait", {
        types: ["image"],
        size: "15mb"
      });
      //Change File Name
      let fileName = `${new Date().getTime()}.${postPic.subtype}`;

      //Giving File Path
      let filePath = imagePath + "/" + fileName;
      const uploadPath = Helpers.publicPath(imagePath);

      //Save File
      await postPic.move(uploadPath, {
        name: fileName
      });

      //Server Error
      if (!postPic.moved()) {
        return postPic.error();
      }

      const member = await Member.findBy("email", request.input("userEmail"));
      member.merge({ profilePic: filePath });
      await member.save();

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

  /*
  request{
    loginEmail:'',
    loginPass:''
  }
  response{
    status:'Success/Fail',
    reason:(Only when status is Fail)
  }

  Description:
    Users login with email and password
  */
  async login({ request, response }) {
    try {
      let member = await Member.findBy("email", request.input("loginEmail"));

      //Whether email exists
      if (member === null) {
        return response.send("Email Not Existed");
      }

      const password = Encryption.decrypt(member.password);
      //Whether password is correct
      if (password != request.input("loginPassword")) {
        return response.send("Pass Word Incorrect");
      }

      //Login successes
      if (member != null && password === request.input("loginPassword")) {
        return response.send("success");
      }
    } catch (err) {
      console.log(err);
      return response.send("Server Error");
    }
  }

  /*Register()
  request: {
      registerPassword:'',
      registerEmail:''
    }
  response:{
    registerEmail:'',
    status:Success/Fail,
    reason:(Only when status is Fail)
  }

  Description:
  Users register with email and password
  */
  async register({ request, response }) {
    try {
      const requestData = request.all();

      //Use Encryption to encrypt user plain password
      const encrypted = Encryption.encrypt(requestData.registerPassword);
      const userEmail = await Database.table("members")
        .where("email", requestData.registerEmail)
        .select("email");

      //email is not exist -> new user
      if (userEmail.length <= 0) {
        const member = new Member();
        member.email = requestData.registerEmail;
        member.password = encrypted;
        await member.save();

        return response.send("success");
      } else {
        return response.send("Email Existed");
      }
    } catch (err) {
      console.log(err);
      return response.send("Server Error");
    }
  }
}

module.exports = MemberController;
