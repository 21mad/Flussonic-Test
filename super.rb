require 'date'

class PeriodsChain
  attr_reader :start_date, :periods

  def initialize(start_date, periods)
    @start_date = Date.parse(start_date)
    @periods = periods
    @last_period = { Y: @start_date.year , M: @start_date.month, D: @start_date.day }
  end

  def valid?
    res_date = @start_date
    valid = true
    counter = { Y: 0, M: 0, D: 0 }
    prev_date = { Y: @start_date.year , M: @start_date.month, D: @start_date.day }
    periods.each do |period|
      break unless valid
      if period.match?(/^\d{4}M\d{1,2}D.{1,2}$/) # daily period
        daily = parse_period(period)
        if daily[:Y] == prev_date[:Y] && daily[:M] == prev_date[:M] && daily[:D] == prev_date[:D]
          counter[:D]+= 1
          prev_date[:D] += 1
        else
          valid = false
        end
      end
      if period.match?(/^\d{4}M\d{1,2}$/) # monthly period
        monthly = parse_period(period)
        if monthly[:Y] == prev_date[:Y] && monthly[:M] == prev_date[:M]
          counter[:M]+= 1
          prev_date[:M] += 1
        else
          valid = false
        end
      end
      if period.match?(/^\d{4}$/) # annually period
        annually = parse_period(period)
        if annually[:Y] == prev_date[:Y]
          counter[:Y]+= 1
          prev_date[:Y] += 1
        else
          valid = false
        end
      end
    end
    res_date = res_date.next_year(counter[:Y]).next_month(counter[:M]).next_day(counter[:D])
    @last_period = prev_date
    valid
  end

  def add(new_period_type)
    if self.valid?
      case new_period_type
      when "daily"
        @periods.push("#{@last_period[:Y]}M#{@last_period[:M]}D#{@last_period[:D]}")        
      when "monthly"
        @periods.push("#{@last_period[:Y]}M#{@last_period[:M]}")
      when "annually"
        @periods.push("#{@last_period[:Y]}")
      else
        puts 'Incorrect period.'
      end
    else
      puts 'Invalid chain.'
    end
  end

  private

  def parse_period(string_period)
    period = { Y: 0, M: 0, D: 0}
    if string_period.match?(/^\d{4}$/)  # annually
      period[:Y] = string_period.to_i
    elsif string_period.match?(/^\d{4}M\d{1,2}$/) # monthly
      period[:Y] = string_period[0..3].to_i
      period[:M] = string_period[5..].to_i
    elsif string_period.match?(/^\d{4}M\d{1,2}D.{1,2}$/)  # daily
      period[:Y] = string_period[0..3].to_i
      period[:M] = string_period[5..string_period.index('D')-1].to_i
      period[:D] = string_period[string_period.index('D')+1..].to_i
    end
    period
  end
end

puts 'Enter the start date (DD.MM.YYYY): '
start_date = gets().chomp
puts 'Enter periods separated by a space: '
periods = gets().chomp.split()
if Date.parse(start_date)
  periods_chain = PeriodsChain.new(start_date, periods)
  print 'Periods chain is valid: '; p periods_chain.valid?
  puts 'Adding function testing: '
  periods_chain.add("daily"); p periods_chain.periods
  periods_chain.add("monthly"); p periods_chain.periods
  periods_chain.add("annually"); p periods_chain.periods
  print 'Periods chain is valid: '; p periods_chain.valid?
end
