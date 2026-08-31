require 'test_helper'

class MarathonPersonTest < ActiveSupport::TestCase
  test "initials" do
    mp = marathon_people(:anna)
    assert_equal 'AA', mp.initials
  end

  test "full_name" do
    mp = marathon_people(:anna)
    assert_equal 'Anna Andersson', mp.full_name
  end

  test "total_plaque_dist sums all logs" do
    mp = marathon_people(:anna)
    assert_in_delta 500.0, mp.total_plaque_dist, 0.1
  end

  test "total_plaque_dist up_to_year limits sum" do
    mp = marathon_people(:anna)
    assert_in_delta 220.0, mp.total_plaque_dist(up_to_year: 2023), 0.1
  end

  test "plaque_dist_for_year returns correct year sum" do
    mp = marathon_people(:anna)
    assert_in_delta 280.0, mp.plaque_dist_for_year(2024), 0.1
  end

  test "validates presence of first_name and last_name" do
    mp = MarathonPerson.new(last_name: 'Test')
    assert_not mp.valid?
    assert_includes mp.errors[:first_name], "can't be blank"
  end

  test "current_plaque returns correct threshold" do
    result = MarathonThresholds.current_plaque(1500)
    assert_equal 'Guld', result[:plaque]
    assert_equal 'Basic', result[:series]
  end

  test "current_plaque returns nil below lowest threshold" do
    result = MarathonThresholds.current_plaque(100)
    assert_nil result
  end

  test "new_plaques returns thresholds crossed" do
    result = MarathonThresholds.new_plaques(400, 1100)
    assert_equal 2, result.length
    assert_equal 500, result.first[:dist]
    assert_equal 1000, result.last[:dist]
  end

  test "new_plaques returns empty when no new thresholds" do
    result = MarathonThresholds.new_plaques(1000, 1500)
    assert_empty result
  end
end
