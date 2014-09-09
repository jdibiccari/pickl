require 'test_helper'

class VotersControllerTest < ActionController::TestCase
  test "New voter is created" do
    get(:create, {'token' => 'abcde'}, {'option' => 1})
    voter = Voter.find_by(uuid: session[:voter])
    assert_not_nil(voter, "voter is not found")
    poll = voter.polls.find_by(token: 'abcde')
    assert_not_nil(poll, "associated poll is not found")
  end

  test "Old voter is found" do
    total_voters_before = Voter.all.count
    session[:voter] = 'ababab'
    get(:create, {'token' => 'abcde'}, {'option' => 1})
    total_voters_after = Voter.all.count
    assert_equal( total_voters_before, total_voters_after, 'A new voter was added incorrectly' )
    voter = Voter.find_by(uuid: 'ababab')
    assert_not_nil(voter, "voter is not found")
    poll = voter.polls.find_by(token: 'abcde')
    assert_not_nil(poll, "associated poll is not found")
  end  
end
