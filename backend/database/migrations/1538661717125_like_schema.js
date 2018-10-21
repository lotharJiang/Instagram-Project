'use strict'

const Schema = use('Schema')

class LikeSchema extends Schema {
  up () {
    this.create('likes', (table) => {
      table.increments()
      table.integer('MemberID').unsigned()
      table.integer('PostID').unsigned().references('id').inTable('posts')
      table.integer('postFromID').unsigned()
      table.timestamps()
    })
  }

  down () {
    this.drop('likes')
  }
}

module.exports = LikeSchema
