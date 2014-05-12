environment = process.env.METEOR_ENV or "development"

settings =
  development:
    public:
      package:
        name: "jquery-datatables"
        description: "Sort, page, and filter millions of records. Reactively."
        owner: "LumaPictures"
        repo: "meteor-jquery-datatables"
    private: {}

  staging:
    public: {}
    private: {}

  production:
    public: {}
    private: {}

unless process.env.METEOR_SETTINGS
  console.log "No METEOR_SETTINGS passed in, using locally defined settings."
  if environment is "production"
    Meteor.settings = settings.production
  else if environment is "staging"
    Meteor.settings = settings.staging
  else
    Meteor.settings = settings.development

  # Push a subset of settings to the client.
  __meteor_runtime_config__.PUBLIC_SETTINGS = Meteor.settings.public  if Meteor.settings and Meteor.settings.public
  console.log "Using [ #{ environment } ] Meteor.settings"