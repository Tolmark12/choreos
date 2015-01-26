People = new Mongo.Collection "people"

if Meteor.isClient
  Template.people.helpers
    people: ()=>
      return People.find {}
  Template.people.events
    "click .toggle-checked" : ()->
      People.update(this._id, {$set: {checked: ! this.checked}});
    "click .delete"     : () ->
      People.remove this._id
    "submit .new-person": (event) ->
      # This function is called when the new task form is submitted
      text = event.target.text.value
      People.insert
        name: text
        createdAt: new Date() # current time

      # Clear form
      event.target.text.value = ""

      # Prevent default form submit
      return false
