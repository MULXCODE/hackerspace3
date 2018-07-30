require 'test_helper'

class CompetitionTest < ActiveSupport::TestCase
  setup do
    @competition = Competition.first
    @assignment = Assignment.first
    @event = Event.first
    @sponsor = Sponsor.first
    @sponsorship_type = SponsorshipType.first
  end

  test 'competition associations' do
    assert(@competition.assignments.include?(@assignment))
    assert(@competition.events.include?(@event))
    assert(@competition.sponsors.include?(@sponsor))
    assert(@competition.sponsorship_types.include?(@sponsorship_type))
  end

  test 'competition validations' do
    @competition.destroy
    # No year
    competition = Competition.create
    assert_not(competition.persisted?)
  end
end