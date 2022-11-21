require "application_system_test_case"

class PublicContentsTest < ApplicationSystemTestCase
  setup do
    @public_content = public_contents(:one)
  end

  test "visiting the index" do
    visit public_contents_url
    assert_selector "h1", text: "Public contents"
  end

  test "should create public content" do
    visit public_contents_url
    click_on "New public content"

    fill_in "Name", with: @public_content.name
    click_on "Create Public content"

    assert_text "Public content was successfully created"
    click_on "Back"
  end

  test "should update Public content" do
    visit public_content_url(@public_content)
    click_on "Edit this public content", match: :first

    fill_in "Name", with: @public_content.name
    click_on "Update Public content"

    assert_text "Public content was successfully updated"
    click_on "Back"
  end

  test "should destroy Public content" do
    visit public_content_url(@public_content)
    click_on "Destroy this public content", match: :first

    assert_text "Public content was successfully destroyed"
  end
end
