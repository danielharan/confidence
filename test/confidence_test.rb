require 'test/test_helper'

VOTE_XML = Crack::XML.parse(
  Pathname(__FILE__).dirname.join("fixtures/vote.xml").read
)['Vote']


class VoteTest < MiniTest::Unit::TestCase
  include Apathy

  def setup
    @vote = Vote.new(:doc => VOTE_XML)
  end

  test "api" do
    assert_respond_to Vote,  :fetch
    assert_respond_to @vote, :parliament
    assert_respond_to @vote, :session
    assert_respond_to @vote, :number
    assert_respond_to @vote, :doc
  end

  test "fetches vote data" do
    HTTParty.expects(:get).with(<<-URL.strip).returns({'Vote' => :doc})
      http://www2.parl.gc.ca/HouseChamberBusiness/Chambervotedetail.aspx?Language=E&Mode=1&Parl=40&Ses=2&FltrParl=40&FltrSes=2&vote=45&xml=True
    URL

    vote = Apathy::Vote.fetch(
      :parliament => 40,
      :session    => 2,
      :number     => 45
    )
    assert_kind_of Apathy::Vote, vote
    assert_equal 40,   vote.parliament
    assert_equal 2,    vote.session
    assert_equal 45,   vote.number
    assert_equal :doc, vote.doc
  end

  test "vote participants" do
    assert_equal 271, @vote.participants.size
    assert_kind_of Participant, @vote.participants.first
  end
end

class ParticipantTest < MiniTest::Unit::TestCase
  include Apathy

  def setup
    @vote = Vote.new(:doc => VOTE_XML)
    @participant = @vote.participants.first
  end

  test "api" do
    assert_respond_to @participant, :recorded_vote
  end

  test "recorded vote" do
    assert_equal "yea", @participant.recorded_vote
  end
end
