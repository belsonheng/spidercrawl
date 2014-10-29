#
# Copyright (c) 2013 Charles H Martin, PhD
#  

class UserAgents
  # Random agents
  def self.random
    case rand(20)
    when 0
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:#{10+rand(10)}.#{rand(10)}) Gecko/20#{10+rand(3)}#{1000+rand(3)*100+rand(28)} Firefox/20.0"
    when 1
      "Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.2.#{10+rand(10)}) Gecko/20#{10+rand(3)}#{1000+rand(3)*100+rand(28)} Ubuntu/10.10 (maverick) Firefox/3.6.#{14+rand(5)}"
    when 2
      ver = "#{400+rand(99)}.#{10+rand(75)}"
      "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/#{ver} (KHTML, like Gecko) Chrome/12.0.#{700+rand(90)}.#{100+rand(200)} Safari/#{ver}"
    when 3
      ver = "#{400+rand(99)}.#{rand(9)}"
      "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/#{ver} (KHTML, like Gecko) Chrome/13.0.#{700+rand(90)}.#{100+rand(200)} Safari/#{ver}"
    when 4
      "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:5.0) Gecko/20#{10+rand(3)}#{1000+rand(3)*100+rand(28)} Firefox/#{4+rand(1)}.0"
    when 5
      "Mozilla/4.0 (compatible; MSIE 8.#{rand(6)}; Windows NT 6.1; WOW64; Trident/4.0; SLCC2; .NET CLR 2.0.#{50000+rand(7000)}; .NET CLR 3.5.#{30000+rand(8000)}; .NET CLR 3.0.#{30000+rand(8000)}; Media Center PC 6.0; .NET4.0C; .NET4.0E; MS-RTC LM 8; Zune 4.#{6+rand(3)})"
    end
  end
end