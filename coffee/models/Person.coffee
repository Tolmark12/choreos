share.People = People = new Mongo.Collection "people", {idGeneration : 'MONGO'}

if Meteor.isServer
  getCardStates = (personId, dayId, completedChores)->
    person = share.People.findOne _id: new Meteor.Collection.ObjectID(personId)
    day    = share.Days.findOne day:dayId
    cardStates = {}
    # Loop through all the cards
    for cardId in person.cards
      card = share.ChoreCards.findOne _id:cardId
      totalDone = 0
      # Count how many completed chores each card has
      for chore in card.chores
        if completedChores.indexOf(chore._str) != -1
          totalDone++

      # Set the completion state of the card
      if totalDone == 0
        cardStates[cardId._str] = ""
      else if totalDone == card.chores.length
        cardStates[cardId._str] = "done"
      else
        cardStates[cardId._str] = "doing"
    return cardStates


  Meteor.methods
    "updateChore": (personId, today, completedChores)->
      card_states = getCardStates personId, today, completedChores
      share.Days.update(
        {day:today, person:new Meteor.Collection.ObjectID(personId)}
        {
          $set         : { completed_chores:completedChores, card_states:card_states }
          $setOnInsert : { day:today, person:new Meteor.Collection.ObjectID(personId) }
        }
        {upsert:true}
      )

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
      return chores
    card_status : () ->
      personId = UI._parentData(1)._id
      day      = share.Days.findOne({person:personId, day:getToday() })
      if day?
        day.card_states[this._id._str]
      else
        return ""
    choreIsComplete: ()->
      personId = UI._parentData(2)._id
      day      = share.Days.findOne({person:personId, day:getToday() })
      if !day?
        return false
      for chore in day.completed_chores
        if chore == this._id._str
          return true
      false

    historic_days:()->
      ar = []
      date = getToday()
      for day in [0..7]
        day = share.Days.findOne({person:this._id, day:date })
        date.setDate(date.getDate()-1);
        ar.push day
      ar

    historic_card_class:()->
      for key, state of this.card_states
        return ""
      return "no-cards"

    historic_chore_card:()->
      states = []
      for key, state of this.card_states
        states.push state
      return states


  Template.index.events
    "click .chore" : (e, template)->
      $(e.target).toggleClass "complete"
      personId        = $(e.target).attr "data-person"
      today           = getToday()
      completedChores = $(".chore.complete", $(e.target).parent().parent().parent()).map( () ->
        $(this).data "id"
      ).get()

      Meteor.call('updateChore', personId, today, completedChores);

  getToday = () ->
    today = new Date()
    today.setHours 0
    today.setMinutes 0
    today.setSeconds 0
    today.setMilliseconds 0
    today
  today = getToday()
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
    isSelected: ()->
      return this._id._str == UI._parentData(1)._str
  Template.edit_person.events
    "click .add-card" : (e, template)->
      People.update this._id, { $push: {'cards': "" } }
    "click .remove-card" : (e, template)->
      cardId = $(e.currentTarget).attr("card-id")
      People.update template.data._id, { $pull: {'cards': cardId} }

    "change select.card" : (e,template)->
      ar = []
      template.$("select").each (i,el)=>
        ar.push new Meteor.Collection.ObjectID( $(el).val() )
      People.update template.data._id, {$set: {'cards': ar}}
