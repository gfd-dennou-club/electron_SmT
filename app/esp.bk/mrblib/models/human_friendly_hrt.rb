# mrblib/models/human_friendly_hrt.rb

class HumanFriendlyHrt
  def initialize
    @hrt = Hrt.new
  end

  def adjust(timestamp_sec)
    # keep the offset from HRT to UTC
    @offset = timestamp_sec - @hrt.now
  end

  def now
    # this is UTC
    return @offset + @hrt.now
  end
end
