require "test_helper"

class PublicContentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @public_content = public_contents(:one)
  end

  test "should get index" do
    get public_contents_url
    assert_response :success
  end

  test "should get new" do
    get new_public_content_url
    assert_response :success
  end

  test "should create public_content" do
    assert_difference("PublicContent.count") do
      post public_contents_url, params: { public_content: { name: @public_content.name } }
    end

    assert_redirected_to public_content_url(PublicContent.last)
  end

  test "should show public_content" do
    get public_content_url(@public_content)
    assert_response :success
  end

  test "should get edit" do
    get edit_public_content_url(@public_content)
    assert_response :success
  end

  test "should update public_content" do
    patch public_content_url(@public_content), params: { public_content: { name: @public_content.name } }
    assert_redirected_to public_content_url(@public_content)
  end

  test "should destroy public_content" do
    assert_difference("PublicContent.count", -1) do
      delete public_content_url(@public_content)
    end

    assert_redirected_to public_contents_url
  end
end
