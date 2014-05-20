class @PublishStub
  @collection: []

  @added: ( collection, id, fields ) ->
    PublishStub.collection[ id ] = fields

  @changed: ( collection, id, fields ) ->
    _.extend PublishStub.collection[ id ], fields

  @removed: ( collection, id ) ->
    if PublishStub.collection[ id ]
      delete PublishStub.collection[ id ]