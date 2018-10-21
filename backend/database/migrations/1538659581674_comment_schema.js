'use strict'

const Schema = use('Schema')

class CommentSchema extends Schema {
  up () {
    this.create('comments', (table) => {
      table.increments()
      table.integer('MemberID').unsigned()
      table.string('comment').notNullable()
      table.integer('PostID').unsigned().references('id').inTable('posts');
      table.timestamps()
    })
  }

  down () {
    this.drop('comments')
  }
}

module.exports = CommentSchema
