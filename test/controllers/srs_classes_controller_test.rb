require 'test_helper'

class SrsClassesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @srs_class = srs_classes(:one)
  end

  test "should get index" do
    get srs_classes_url
    assert_response :success
  end

  test "should get new" do
    get new_srs_class_url
    assert_response :success
  end

  test "should create srs_class" do
    assert_difference('SrsClass.count') do
      post srs_classes_url, params: { srs_class: { b: @srs_class.b, boat_class_id: @srs_class.boat_class_id, d: @srs_class.d, depl: @srs_class.depl, handicap: @srs_class.handicap, import_description: @srs_class.import_description, klassning: @srs_class.klassning, name: @srs_class.name, pdf_link: @srs_class.pdf_link, skl: @srs_class.skl, srs: @srs_class.srs, srs_wo_fly: @srs_class.srs_wo_fly, version: @srs_class.version, version_name: @srs_class.version_name } }
    end

    assert_redirected_to srs_class_url(SrsClass.last)
  end

  test "should show srs_class" do
    get srs_class_url(@srs_class)
    assert_response :success
  end

  test "should get edit" do
    get edit_srs_class_url(@srs_class)
    assert_response :success
  end

  test "should update srs_class" do
    patch srs_class_url(@srs_class), params: { srs_class: { b: @srs_class.b, boat_class_id: @srs_class.boat_class_id, d: @srs_class.d, depl: @srs_class.depl, handicap: @srs_class.handicap, import_description: @srs_class.import_description, klassning: @srs_class.klassning, name: @srs_class.name, pdf_link: @srs_class.pdf_link, skl: @srs_class.skl, srs: @srs_class.srs, srs_wo_fly: @srs_class.srs_wo_fly, version: @srs_class.version, version_name: @srs_class.version_name } }
    assert_redirected_to srs_class_url(@srs_class)
  end

  test "should destroy srs_class" do
    assert_difference('SrsClass.count', -1) do
      delete srs_class_url(@srs_class)
    end

    assert_redirected_to srs_classes_url
  end
end
