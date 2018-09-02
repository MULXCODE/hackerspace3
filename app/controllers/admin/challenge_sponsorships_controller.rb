class Admin::ChallengeSponsorshipsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_for_privileges

  def new
    @challenge = Challenge.find(params[:challenge_id])
    @challenge_sponsorship = @challenge.challenge_sponsorships.new()
    return if params[:term].blank?
    search_sponsors
  end

  def create
    @challenge = Challenge.find(params[:challenge_id])
    @sponsor = Sponsor.find(params[:sponsor_id])
    @challenge_sponsorship = @challenge.challenge_sponsorships.new(sponsor: @sponsor)
    if @challenge_sponsorship.save
      flash[:notice] = 'New challenge sponsorship created'
      redirect_to admin_region_challenge_path(@challenge.region_id, @challenge)
    else
      flash.now[:alert] = @challenge_sponsorship.errors.full_messages.to_sentence
      render :new
    end
  end

  def destroy
    @sponsorship = ChallengeSponsorship.find(params[:id])
    @sponsorship.destroy
    @challenge = @sponsorship.challenge
    flash[:notice] = 'Challenge Sponsorship Destroyed'
    redirect_to admin_region_challenge_path(@challenge.region_id, @challenge)
  end

  private

  def check_for_privileges
    return if current_user.region_privileges?
    flash[:alert] = 'You must have valid assignments to access this section.'
    redirect_to root_path
  end

  def search_sponsors
    @sponsor = Sponsor.find_by_name(params[:term])
    if @sponsor.present?
      @existing_sponsorship = Sponsorship.find_by(sponsor: @sponsor, sponsorable: @sponsorable)
    else
      @sponsors = Sponsor.search(params[:term])
    end
  end
end