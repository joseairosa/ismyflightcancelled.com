class FoundFlight
  def initialize(service_hash)
    @service_hash = service_hash
  end

  def humanized_status
    @service_hash[:status].to_s.capitalize
  end

  def has_error?
    @service_hash[:error]
  end

  def is_cancelled?
    @service_hash[:status] == :cancelled
  end

  def flight_number
    @service_hash[:flight_number]
  end

  def date
    @service_hash[:date]
  end

  def from_airport
    @service_hash[:from_airport]
  end

  def to_airport
    @service_hash[:to_airport]
  end

  def airline_name
    @service_hash[:airline_name]
  end

  def to_s
    "#{flight_number} on the #{date} from #{from_airport} to #{to_airport}"
  end
end
