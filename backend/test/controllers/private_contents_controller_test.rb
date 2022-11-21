require "test_helper"

class PrivateContentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @private_content = private_contents(:one)
  end

  test "should get index" do
    get private_contents_url
    assert_response :success
  end

  test "should get new" do
    get new_private_content_url
    assert_response :success
  end

  test "should create private_content" do
    assert_difference("PrivateContent.count") do
      post private_contents_url, params: { private_content: { name: @private_content.name } }
    end

    assert_redirected_to private_content_url(PrivateContent.last)
  end

  test "should show private_content" do
    get private_content_url(@private_content)
    assert_response :success
  end

  test "should get edit" do
    get edit_private_content_url(@private_content)
    assert_response :success
  end

  test "should update private_content" do
    patch private_content_url(@private_content), params: { private_content: { name: @private_content.name } }
    assert_redirected_to private_content_url(@private_content)
  end

  test "should destroy private_content" do
    assert_difference("PrivateContent.count", -1) do
      delete private_content_url(@private_content)
    end

    assert_redirected_to private_contents_url
  end
end
