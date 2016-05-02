require 'minitest/autorun'
require_relative '../app'

class TestOtherMethods < Minitest::Test
  def test_future_date
    cday = Time.now.day
    cmonth = Time.now.month
    cyear = Time.now.year
    ctime_hour = Time.now.hour
    ctime_min = Time.now.min

    #past dates
    pdates = []
    ptimes = []
    pdates.push "#{cyear-1}-#{cmonth}-#{cday}"
    ptimes.push "#{ctime_hour}:#{ctime_min}"

    pdates.push "#{cyear}-#{cmonth-1}-#{cday}"
    ptimes.push "#{ctime_hour}:#{ctime_min}"

    pdates.push "#{cyear}-#{cmonth}-#{cday-1}"
    ptimes.push "#{ctime_hour}:#{ctime_min}"

    pdates.push "#{cyear}-#{cmonth}-#{cday}"
    ptimes.push "#{ctime_hour-2}:#{ctime_min}"

    pdates.push "#{cyear}-#{cmonth}-#{cday}"
    ptimes.push "#{ctime_hour}:#{ctime_min-5}"


    #future dates
    fdates = []
    ftimes = []
    fdates.push "#{cyear+1}-#{cmonth}-#{cday}"
    ftimes.push "#{ctime_hour}:#{ctime_min}"

    fdates.push "#{cyear}-#{cmonth+1}-#{cday}"
    ftimes.push "#{ctime_hour}:#{ctime_min}"

    fdates.push "#{cyear}-#{cmonth}-#{cday+1}"
    ftimes.push "#{ctime_hour}:#{ctime_min}"

    fdates.push "#{cyear}-#{cmonth}-#{cday}"
    ftimes.push "#{ctime_hour+2}:#{ctime_min}"

    fdates.push "#{cyear}-#{cmonth}-#{cday}"
    ftimes.push "#{ctime_hour}:#{ctime_min+5}"

    (0..pdates.size-1).each {|i| assert_equal(false,future_date(pdates[i],ptimes[i]))}
    (0..pdates.size-1).each {|i| assert_equal(true,future_date(fdates[i],ftimes[i]))}

  end
end