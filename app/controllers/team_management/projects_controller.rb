class TeamManagement::ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_user_team_privileges!

  def create
    update
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
    update_project
    if @project.save
      flash[:notice] = 'Team Project Saved'
      redirect_to edit_team_management_team_project_path(@project.team, @project)
    else
      flash[:alert] = @project.errors.full_messages.to_sentence
      render :edit
    end
  end

  private

  def project_params
    params.require(:project).permit(:team_name, :description, :data_story,
                                    :source_code_url, :video_url, :homepage_url,
                                    :project_name)
  end

  def update_project
    @project = @team.projects.new(project_params)
    @project.user = current_user
  end

  # IMPROVEMENT - Multiple move up to ApplicationController
  def check_user_team_privileges!
    @team = Team.find(params[:team_id])
    @competition = @team.competition
    return if @team.permission?(current_user) && helpers.in_competition_window?(@team.time_zone)

    check_team_permission
  end

  def check_team_permission
    if @team.permission?(current_user)
      flash[:notice] = 'The competition has closed.'
      redirect_to project_path(@team.current_project.identifier)
    else
      flash[:notice] = 'You do not have access permissions for this team.'
      redirect_to root_path
    end
  end
end
