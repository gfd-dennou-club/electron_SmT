# mrblib/models/hrt.rb

class Hrt
  def now
    # You can use this from HumanFriendlyHRT. You can consider this value as the result of esp_timer_get_time().
    return timer_get_time()
  end
end
