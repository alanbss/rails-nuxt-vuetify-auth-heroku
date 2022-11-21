require "application_system_test_case"

class PrivateContentsTest < ApplicationSystemTestCase
  setup do
    @private_content = private_contents(:one)
  end

  test "visiting the index" do
    visit private_contents_url
    assert_selector "h1", text: "Private contents"
  end

  test "should create private content" do
    visit private_contents_url
    click_on "New private content"

    fill_in "Name", with: @private_content.name
    click_on "Create Private content"

    assert_text "Private content was successfully created"
    click_on "Back"
  end

  test "should update Private content" do
    visit private_content_url(@private_content)
    click_on "Edit this private content", match: :first

    fill_in "Name", with: @private_content.name
    click_on "Update Private content"

    assert_text "Private content was successfully updated"
    click_on "Back"
  end

  test "should destroy Private content" do
    visit private_content_url(@private_content)
    click_on "Destroy this private content", match: :first

    assert_text "Private content was successfully destroyed"
  end
end
