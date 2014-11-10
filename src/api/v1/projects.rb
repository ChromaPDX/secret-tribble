doc '/v1/projects'

get '/v1/projects.json' do
  if require_token!
    project_id = params[:project_id]

    unless project_id
      @errors.add("Please provide a project_id.")
      return
    end

    project = Project.get( project_id )

    unless project
      status 404
      @errors.add("No project found with project_id #{project_id}")
      return
    end

    extras = params[:include].split(',') if params[:include]

    if extras and extras.include? 'backers'
      project.with_backers!
    end

    @out = project
    return
  end

  invalid_credentials!
end
