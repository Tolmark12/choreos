People = new Mongo.Collection "people"

if Meteor.isClient
  # -------- PEOPLE
  Template.people.helpers
    people: ()=>
      return People.find {}
  Template.people.events
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

  # -------- PERSON
  Template.person.helpers
    userCards: ()->
      return this.cards
    availableCards: ()->
      ChoreCards.find {}
    iscool: ()->
      return this._id == UI._parentData(1)
  Template.person.events
    "click .add-card" : (e, template)->
      People.update this._id, { $push: {'cards': "" } }
    "change select.card" : (e,template)->
      ar = []
      template.$("select").each (i,el)=>
        ar.push $(el).val()
      People.update template.data._id, {$set: {'cards': ar}}
      # console.log template.data
