require 'test_helper'

class UserTest < ActiveSupport::TestCase
  self.fixture_table_names = []

  setup do
    @person = Person.new(
      first_name: 'Anna',
      last_name:  'Svensson',
      country:    'Sverige',
      birthday:   '1980-01-01',
      phone:      '0701234567',
      email:      'anna@example.com',
      street:     'Storgatan 1',
      zip:        '12345',
      city:       'Stockholm'
    )
    @person.save!

    @user = User.new(
      email:    'anna@example.com',
      password: 'password123',
      person:   @person
    )
    @user.save!
  end

  test "changing user email updates person email" do
    @user.update!(email: 'anna.new@example.com')

    assert_equal 'anna.new@example.com', @person.reload.email
  end

  test "updating user without changing email does not change person email" do
    @person.update_column(:email, 'something.else@example.com')

    @user.update!(review: true)

    assert_equal 'something.else@example.com', @person.reload.email
  end

  test "new user gets role user by default" do
    assert_equal 'user', @user.role
  end

  test "to_s returns email" do
    assert_equal @user.email, @user.to_s
  end

  test "review! sets review to true" do
    @user.review!

    assert @user.reload.review
  end

  test "destroy soft-deletes the user" do
    @user.destroy

    assert_not_nil @user.reload.deleted_at
    assert User.with_deleted.exists?(@user.id)
  end
end
