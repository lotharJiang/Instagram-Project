'use strict'

const Schema = use('Schema')

class PostSchema extends Schema {
  up () {
    this.create('posts', (table) => {
      table.increments()
      table.integer('MemberID').notNullable().unsigned().references('id').inTable('members');
      table.string('postPic').notNullable()
      table.string('location')
      table.string('lat')
      table.string('log')
      table.timestamps()
    })
  }

  down () {
    this.drop('posts')
  }
}

module.exports = PostSchema
