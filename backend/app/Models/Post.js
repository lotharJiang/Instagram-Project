'use strict'

const Model = use('Model')

class Post extends Model {

  comment(){
    return this.hasMany('App/Models/Comment')
  }
}

module.exports = Post
