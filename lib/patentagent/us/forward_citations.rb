module PatentAgent
  class USPatentFC
    def initialize(number)
      @number = number
    end

    def fc_url(num=@number, pg)
      "http://patft.uspto.gov/netacgi/nph-Parser?Sect1=PTO2&Sect2=HITOFF&p=#{pg}&u=%2Fnetahtml%2Fsearch-adv.htm&r=0&f=S&l=50&d=PALL&Query=ref/#{num}"
    end
  end
end