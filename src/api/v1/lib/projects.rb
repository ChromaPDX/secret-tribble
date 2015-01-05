doc '/v1/projects'

get '/v1/projects.json' do
  if require_token!
    project_id = params[:project_id]

    if project_id
      # get the specific project
      project = Project.get( project_id )

      unless project
        status 404
        @errors.add("No project found with project_id #{project_id}")
        return
      end
      
      @out = project
      return
    else
      # get all the projects for the user
      @out = Project.with_user( @user.user_id )
      return
    end
  end

  invalid_credentials!
end

post '/v1/projects.json' do
  if require_token!
    name = params[:name]
    description = projects[:description]

    if name and description
      p = Project.new( name: name )
    else
      @errors.add("A new project requires a name and description")
      return
    end
  end

  invalid_credentials!
end
