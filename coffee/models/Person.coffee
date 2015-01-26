People = new Mongo.Collection "people"

if Meteor.isClient

  # -------------------------------- INDEX
  Template.index.helpers
    people: ()->
      return People.find {}
    chore_cards: ()->
      cards = window.ChoreCards.find( { _id : { $in : this.cards } } )
      return cards
    chores: (a)->
      chores = window.Chores.find( { _id : { $in : this.chores } } )
      console.log chores
      return chores
  Template.index.events
    "click .chore" : (e, template)->
      console.log this

  # --------------------------------  EDIT

  Template.edit_people.helpers
    people: ()=>
      return People.find {}
  Template.edit_people.events
    "click .toggle-checked" : ()->
      People.update(this._id, {$set: {checked: ! this.checked}});
    "click .delete-person"     : () ->
      People.remove this._id
    "submit .new-person": (event) ->
      # This function is called when the new task form is submitted
      text = event.target.text.value
      People.insert
        name: text
        cards:[]
        # createdAt: new Date() # current time

      # Clear form
      event.target.text.value = ""

      # Prevent default form submit
      return false

  # -------- EDIT PERSON
  Template.edit_person.helpers
    userCards: ()->
      return this.cards
    availableCards: ()->
      ChoreCards.find {}
    iscool: ()->
      return this._id == UI._parentData(1)
  Template.edit_person.events
    "click .add-card" : (e, template)->
      People.update this._id, { $push: {'cards': "" } }
    "click .remove-card" : (e, template)->
      cardId = $(e.currentTarget).attr("card-id")
      People.update template.data._id, { $pull: {'cards': cardId} }

    "change select.card" : (e,template)->
      ar = []
      template.$("select").each (i,el)=>
        ar.push $(el).val()
      People.update template.data._id, {$set: {'cards': ar}}
