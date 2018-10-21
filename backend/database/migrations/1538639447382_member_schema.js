'use strict'

const Schema = use('Schema')

class MemberSchema extends Schema {
  up () {
    this.create('members', (table) => {
      table.increments().primary()
      table.string('email').unique().notNullable()
      table.string('password').notNullable()
      table.string('userName').defaultTo('newUser')
      table.string('profilePic').defaultTo('http://115.146.84.191/UserPortrait/defaultPortrait.png')
      table.timestamps()
    })
  }

  down () {
    this.drop('members')
  }
}

module.exports = MemberSchema
