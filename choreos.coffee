console.log "???????"
if (Meteor.isClient)
  console.log "????"
  #counter starts at 0
  Session.setDefault('counter', 0)

  Template.hello.helpers
    counter:  ()=>
      return Session.get('counter')

  Template.hello.events
    'click button': ()=>
      #increment the counter when button is clicked
      Session.set('counter', Session.get('counter') + 1)

if (Meteor.isServer)
  console.log "++++"
  Meteor.startupfunction ()=>
    #code to run on server at startup
