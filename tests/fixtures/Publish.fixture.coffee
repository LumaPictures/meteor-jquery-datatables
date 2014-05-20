class @PublishStub
  @collection: []

  @added: ( collection, id, fields ) ->
    console.log "added", id
    PublishStub.collection[ id ] = fields

  @changed: ( collection, id, fields ) ->
    console.log "changed", id
    _.extend PublishStub.collection[ id ], fields

  @removed: ( collection, id ) ->
    if PublishStub.collection[ id ]
      console.log "removed", id
      PublishStub.collection.splice id, 1