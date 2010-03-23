require 'httparty'

module Confidence
  VERSION = '0.5.2'

  class Vote
    def self.fetch(attrs={})
      vote = new(attrs)

      # Parl= and FltrParl= are redundant. Contact your local mp to complain if you care.
      doc = HTTParty.get(
        "http://www2.parl.gc.ca/HouseChamberBusiness/Chambervotedetail.aspx?Language=E&Mode=1&Parl=#{vote.parliament}&Ses=#{vote.session}&FltrParl=#{vote.parliament}&FltrSes=#{vote.session}&vote=#{vote.number}&xml=True"
      )

      vote.doc = doc['Vote']
      vote
    end

    attr_accessor :parliament, :session, :number
    attr_accessor :doc

    def initialize(attrs={})
      @parliament = attrs[:parliament]
      @session    = attrs[:session]
      @number     = attrs[:number]
      @doc        = attrs[:doc]
    end

    def decision
      @doc['Decision']
    end

    def context
      @doc['Context']['Para']
    end

    def sponsor
      @doc['Sponsor']
    end

    def participants
      @doc['Participant'].map {|p| Participant.new(p) }
    end

    def bill
      Bill.new(@doc['RelatedBill'])
    end
  end

  class Bill
    def initialize(attrs={})
      @attrs = attrs
    end

    def number; @attrs['number']; end
    def title;  @attrs['Title'];  end
  end

  class Participant
    def initialize(attrs={})
      @attrs = attrs
    end

    def recorded_vote
      @recorded_vote ||= @attrs['RecordedVote'].select {|k,v| v == '1' }.first.first.downcase
    end
    
    def firstname;    @attrs['FirstName'];    end
    def lastname;     @attrs['LastName'];     end
    def party;        @attrs['Party'];        end
    def constituency; @attrs['Constituency']; end
    def province;     @attrs['Province'];     end
  end
end

