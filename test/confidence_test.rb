require 'test/test_helper'

VOTE_DATA = Crack::XML.parse(
  Pathname(__FILE__).dirname.join("fixtures/vote.xml").read
)['Vote']


  class VoteTest < MiniTest::Unit::TestCase
  include Confidence

  def setup
    @vote = Vote.new(:doc => VOTE_DATA)
  end

  test "api" do
    assert_respond_to Vote,  :fetch
    assert_respond_to @vote, :parliament
    assert_respond_to @vote, :session
    assert_respond_to @vote, :number
    assert_respond_to @vote, :decision
    assert_respond_to @vote, :context
    assert_respond_to @vote, :sponsor
    assert_respond_to @vote, :doc
  end

  test "fetches vote data" do
    HTTParty.expects(:get).with(<<-URL.strip).returns({'Vote' => :doc})
      http://www2.parl.gc.ca/HouseChamberBusiness/Chambervotedetail.aspx?Language=E&Mode=1&Parl=40&Ses=2&FltrParl=40&FltrSes=2&vote=45&xml=True
    URL

    vote = Confidence::Vote.fetch(
      :parliament => 40,
      :session    => 2,
      :number     => 45
    )
    assert_kind_of Confidence::Vote, vote
    assert_equal 40,   vote.parliament
    assert_equal 2,    vote.session
    assert_equal 45,   vote.number
    assert_equal :doc, vote.doc
  end

  test "vote decision" do
    assert_equal "Agreed to", @vote.decision
  end

  test "vote context" do
    assert_match /^That the Bill/, @vote.context
  end

  test "vote participants" do
    assert_equal 271, @vote.participants.size
    assert_kind_of Participant, @vote.participants.first
  end
  
  test "vote sponsor" do
    assert_equal "Mr. Day (Minister of International Trade and Minister for the Asia-Pacific Gateway)", @vote.sponsor
  end

  test "vote bill" do
    assert_equal 'C-2', @vote.bill.number
    assert_match /^An Act to implement the/, @vote.bill.title
    assert_kind_of Bill, @vote.bill
  end
end

class ParticipantTest < MiniTest::Unit::TestCase
  include Confidence

  def setup
    @vote = Vote.new(:doc => VOTE_DATA)
    @participant = @vote.participants.first
  end

  test "api" do
    assert_respond_to @participant, :recorded_vote
  end

  test "recorded vote" do
    assert_equal "yea", @participant.recorded_vote
  end
end

class BillTest < MiniTest::Unit::TestCase
  include Confidence

  def setup
    @vote = Vote.new(:doc => VOTE_DATA)
    @bill = @vote.bill
  end

  test "api" do
    assert_respond_to @bill, :number
    assert_respond_to @bill, :title
  end
end
