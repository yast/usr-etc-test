#! /usr/bin/env rspec

require_relative "usr_etc_test_helper"

test = UsrEtcTestHelper.new "Factory"

describe "checking /usr/etc directory for new entries" do
  it "complains new entries which are not on the white list" do
    new_entries = test.check_user_etc()
    expect(new_entries).to be_empty
  end
end

