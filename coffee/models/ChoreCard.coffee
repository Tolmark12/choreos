@ChoreCards = ChoreCards = new Mongo.Collection "chore_cards"

if Meteor.isClient

  # Cards
  Template.chore_cards_edit.helpers
    cards: ()=>
      return @ChoreCards.find {}
  Template.chore_cards_edit.events
    "click .delete-chore"   : () ->
      ChoreCards.remove this._id
    "click .create-new-chore": (event, template) =>
      title  = template.$('input.title').val()

      # Create new Chore
      @ChoreCards.insert
        title: title
        chores: []

      # Clear form
      template.$('input.title').val("")

      # Prevent default form submit
      return false

  # Card
  Template.chore_card_edit.helpers
    chores: ()->
      return window.Chores.find( { _id : { $in : this.chores } } )

  Template.chore_card_edit.events
    "click .add-chore" : ()->
      newChore = window.Chores.insert text:"New Chore"
      this.chores.push(newChore)
      ChoreCards.update this._id, { $set:{chores:this.chores} }
    "click .remove-chore" : (e,template)->
      ChoreCards.update template.data._id, { $pull: {'chores': this._id } }
    "keyup .chore input" : (e, template)->
      window.Chores.update this._id, { $set:{text:$(e.target).val()} }
