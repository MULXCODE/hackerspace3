require 'test_helper'

class RegistrationTest < ActiveSupport::TestCase
  setup do
    @assignment = Assignment.find(4)
    @registration = Registration.find(1)
    @event = Event.find(1)
    @user = User.first
  end

  test 'registration associations' do
    assert(@registration.assignment == @assignment)
    assert(@registration.event == @event)
    assert(@registration.user == @user)
  end

  test 'registration validations' do
    @registration.destroy
    # Must have status
    new_registration = @event.registrations.create(assignment: @assignment, status: nil)
    assert_not(new_registration.persisted?)
    # non valid status
    new_registration = @event.registrations.create(assignment: @assignment, status: 'Maybe')
    assert_not(new_registration.persisted?)
    # valid status
    new_registration = @event.registrations.create(assignment: @assignment, status: VALID_ATTENDANCE_STATUSES.first)
    assert(new_registration.persisted?)
  end
end
