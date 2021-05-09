class Helper
  require 'text-table'

  def self.today_as_string
    today = DateTime.now
    today.strftime('%Y-%m-%d')
  end

  def self.get_token(path)
    raise StandardError unless File.exists? path
    File.open(path, &:readline).strip
  end

  def self.add_today(event,args)
    $logger.info "Adding today from #{event.user.name}"
    return StringBuilder.add_help unless args
    matches = args.join(' ').scan(REGEX_ADD_FLIGHT_TODAY)
    result = ''
    if matches[0].size == 4
      result = 'Got your flight pilot!'
      start = today_as_string + 'T' + matches[0][2]
      finish = today_as_string + 'T' + matches[0][3]
      Flight.create(user: event.user.name, plane_id: get_plane_id(matches[0][0]), start: start, finish: finish, legs: matches[0][1])
    else
      $logger.warn "Adding not possible due wrong syntax: #{args.join ' '}"
      result = 'What?'
    end
    result
  end

  def self.change_flight(args)
    return "No!" unless args[0].is_a? Integer
    flight = Flight.find(args[0])

  end

  def self.pilot_stats(args)
    $logger.info "Showing pilot stats"
    range = 500
    range = args.first.to_i unless args.first.nil?
    table = Text::Table.new
    table.head = ['Pilot', 'Count']
    Flight.where('start > ?', Date.today - range.month).group(:user).count.sort { |a,b| b[1] <=> a[1] }.each do |array|
      table.rows << array
    end
    "```\nFlights since #{Date.today - range.month}\n\n#{table.to_s.truncate(1900)}\n```"
  end

  def self.legs_stats(args)
    $logger.info "Showing legs stats"
    range = 500
    range = args.first.to_i unless args.first.nil?
    table = Text::Table.new
    table.head =  ['LEGS', 'Count']
    Flight.where('start > ?', Date.today - range.month).group(:legs).count.sort { |a,b| b[1] <=> a[1] }.each do |array|
      table.rows << array
    end
    "```\nFlights since #{Date.today - range.month}\n\n#{table.to_s.truncate(1900)}\n```"
  end

  def self.plane_stats(args)
    $logger.info "Showing plane stats"
    range = 500
    range = args.first.to_i unless args.first.nil?
    table = Text::Table.new
    table.head =  ['Plane', 'Count', 'Last flight']
    Plane.joins(:flights).where('flights.start > ?', Date.today - range.months).group(:name).count.sort{|a,b| b[1]<=>a[1]}.each do |array|
      last_flight = Plane.find_by_name(array.first).flights.order(:finish).last.finish.to_date
      table.rows << (array.push last_flight)
    end
    "```\nFlights since #{Date.today - range.month}\n\n#{table.to_s.truncate(1900)}\n```"
  end

  def self.get_plane_id(name)
    case name
    when 'A320', 'M.A320', 'B.A320', 'M.A.320', 'a320'
      Plane.find_or_create_by(name: 'A320').id
    when 'DC6'
      Plane.find_or_create_by(name: 'DC6').id
    when 'B757', 'b757', 'b752', 'B737-800', 'B753', '753', '757', 'M.757', 'L.757', 'L757'
      Plane.find_or_create_by(name: 'B757').id
    when 'Citation2'
      Plane.find_or_create_by(name: 'Citation2').id
    when 'B738', 'B378', '737', 'b737', 'B737', 'b738'
      Plane.find_or_create_by(name: 'B738').id
    when 'E195', 'L195', 'L.195', 'L-E195', 'EMB195', 'L.E195'
      Plane.find_or_create_by(name: 'E195').id
    when 'E170'
      Plane.find_or_create_by(name: 'E170').id
    when 'B748'
      Plane.find_or_create_by(name: 'B748').id
    when 'S340'
      Plane.find_or_create_by(name: 'S340').id
    when 'DC3'
      Plane.find_or_create_by(name: 'DC3').id
    when 'TMB', 'TMB850'
      Plane.find_or_create_by(name: 'TMB850').id
    when 'MD82', 'MD-82', 'md82', 'MD80', 'md80', 'md-80'
      Plane.find_or_create_by(name: 'MD82').id
    else
      Plane.find_or_create_by(name: name).id
    end
  end

  def self.add_future(event,args)
    $logger.info "Adding future from #{event.user.name}"
    return "Pattern: \"Aircraft: LEG1-LEG2-LEG3 dd.mm.YYYY HH:MM-HH:MM\"" unless args || args.flatten = ['']
    matches = args.join(' ').scan(REGEX_ADD_FLIGHT_FUTURE)
    result = ''
    if matches[0].size == 5
      result = 'Got your flight pilot'
      date = matches[0][2]
      start = date + ' ' + matches[0][3]
      finish = date + ' ' + matches[0][4]
      Flight.create(user: event.user.name, plane_id: get_plane_id(matches[0][0]), start: start, finish: finish, legs: matches[0][1])
    else
      $logger.warn "Adding not possible due wrong syntax: #{args.join ' '}"
      result = 'What?'
    end
    result
  end

  def self.delete(event,args)
    $logger.info "Deleting from #{event.user.name}"
    result = ''
    if !!args.first
      Flight.find(args.first).delete
      return "Deleted flight with id #{args.first}"
    else
      Flight.where(user: event.user.name).each do |flight|
        result += "#{flight.id}: #{flight.plane.name} - #{flight.legs}\n"
      end
      return result
    end
    result
  end

  def self.show_plan
    $logger.info "Showing plan"
    result = ''
    flights = Flight.where('finish > ?', DateTime.now + 2.hours).order(finish: :asc) 
    if flights.count > 0
      flights.each do |flight|
        result += StringBuilder.show_plan(flight.user,
                                          flight.plane.name,
                                          flight.legs,
                                          flight.start,
                                          flight.finish,
                                          is_today?(flight.finish)) + "\n"
      end
    else
      result = 'No flights in schedule'
    end
    result
  end

  def self.id(user)
    $logger.info "Showing ids from #{user}"
    result = ''
    Flight.where(user: user).where('finish >= ?', DateTime.now).each do |flight|
      result += StringBuilder.id(flight.id, flight.plane.name, flight.legs) + "\n"
    end
    result ? result : 'There are no flights'
  end

  def self.is_today?(date_time)
    date_time.to_date == Date.today
  end
end
