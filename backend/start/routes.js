"use strict";

/*
|--------------------------------------------------------------------------
| Routes
|--------------------------------------------------------------------------
|
| Http routes are entry points to your web application. You can create
| routes for different URL's and bind Controller actions to them.
|
| A complete guide on routing is available here.
| http://adonisjs.com/docs/4.1/routing
|
*/

/** @type {typeof import('@adonisjs/framework/src/Route/Manager'} */
const Route = use("Route");

Route.on("/").render("welcome");
// Member Table
Route.post("/api/register", "MemberController.register");
Route.post("/api/login", "MemberController.login");
Route.put("/api/updatePortrait", "MemberController.updatePortrait");
Route.get(
  "api/searchUser/:userEmail/:searchedUser",
  "MemberController.searchUser"
);
Route.get("api/suggestedUser/:userEmail", "MemberController.suggestedUser");

//Route.get('api/acquireSelfProfile/:userEmail','MemberController.acquireSelfProfile')
Route.get("api/acquirePortrait/:userEmail", "MemberController.acquirePortrait");
Route.get("api/acquireUserInfo/:userEmail", "MemberController.acquireUserInfo");
Route.get(
  "api/acquireUserPosts/:userEmail",
  "MemberController.acquireUserPosts"
);

Route.get(
  "api/acquireOthersProfile/:userEmail/:othersEmail",
  "MemberController.acquireOthersProfile"
);

//Post Table
Route.post("/api/postIns", "PostController.postIns");
Route.get("api/acquirePost/:postID", "PostController.acquirePost");
Route.get(
  "/api/acquireLatestPostsByTime/:userEmail/-1",
  "PostController.acquireLatestPostsByTime"
);
Route.get(
  "/api/acquireOldPostsByTime/:userEmail/:postID",
  "PostController.acquireOldPostsByTime"
);

Route.post(
  "/api/acquireLatestPostsByLocation",
  "PostController.acquireLatestPostsByLocation"
);
Route.post(
  "/api/acquireOldPostsByLocation",
  "PostController.acquireOldPostsByLocation"
);

//Like Table
Route.post("api/like", "LikeController.like");
Route.get("api/whoLike/:postID", "LikeController.whoLike");

//Comment Table
Route.post("api/postComment", "CommentController.postComment");
Route.get("/api/acquireComment/:postID", "CommentController.acquireComment");

//Follow Table
Route.post("api/follow", "FollowingController.follow");
Route.post("api/unfollow", "FollowingController.unfollow");

//Activity Feed
Route.get(
  "api/acquireLatestFollowing/:userEmail/-1",
  "PostController.acquireLatestFollowing"
);
Route.get(
  "api/acquireOldFollowing/:userEmail/:postID",
  "PostController.acquireOldFollowing"
);
Route.get(
  "api/acquireLatestActionFromFollower/:userEmail/-1/-1",
  "MemberController.acquireLatestActionFromFollower"
);
Route.get(
  "api/acquireOldActionFromFollower/:userEmail/:lastLikeID/:lastFollowID",
  "MemberController.acquireOldActionFromFollower"
);
