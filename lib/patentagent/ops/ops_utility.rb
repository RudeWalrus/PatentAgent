module PatentAgent
  module OPS  
    class Patent
      include Util
      #alias log PatentAgent.log
      
      # figures out if a patent is published or not
      def is_published?(id, kind, country)
        return true if (country == "US" && id =~ /^[5678]\d{6}/)
        return true if (kind[0] =~ /^B/)
        return true if (kind[1].to_i > 1 )
        return false
      end

      #
      # convert patent date to a Time object
      #
      def to_patent_date(text)
        /(\d{4})(\d{2})(\d{2})/.match(text.to_s)
        Time.utc($1, $2, $3) unless $1.nil?
      end
  
      #
      # generic routine to create a publication data Hash
      #
      def get_publication_data(doc)
        country = doc.css("country").text
        id = doc.css("doc-number").text
        kind = doc.css("kind").text
        full = "#{country}.#{id}.#{kind}"
        date =  doc.css("date").text
        published = !!(kind[0] =~ /^B/)
        { full: id, date: date, country: country, number: id, kind: kind, published: published}
      end

      # create a proc version of the above to pass to map, each, etc.
      def pub_data 
        method(:get_publication_data).to_proc
      end
    end
  end
end