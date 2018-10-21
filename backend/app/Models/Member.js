'use strict'

const Model = use('Model')

class Member extends Model {

  post(){
    return this.hasMany('App/Models/Post')
  }
}

module.exports = Member
