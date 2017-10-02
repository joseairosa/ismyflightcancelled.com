class StaticFindFlightService
  def initialize(flight_number:, flight_date:)
    @flight_number = flight_number
    @flight_date = flight_date
  end

  def process
    _find_flight
  end

  private

  def _find_flight
    matching_flights = FILES_REPOSITORY.each_with_object([]) do |(_, data_hash), res|
      airline = data_hash.to_a[0][0]
      list = data_hash.to_a[0][1]
      list.each do |dates, flights|
        found_date = dates.split('-').any? do |date|
          this_flight_date = Chronic.parse(date).to_date
          this_flight_date == _user_flight_date
        end
        if found_date
          flights.each do |this_flight|
            if @flight_number.gsub(/[^\d]/, '') == this_flight['number'].to_s
              travel_array = this_flight['travel'].split(' to ')
              from_airport = travel_array.first
              to_airport = travel_array.last
              res << {
                flight_number: "FR#{this_flight['number']}",
                airline_name: airline.to_s.capitalize,
                date: @flight_date,
                from_airport: from_airport,
                to_airport: to_airport,
                status: :cancelled,
                error: nil,
                error_message: nil
              }
            end
          end
        end
      end
    end
    matching_flights.first
  end

  def _user_flight_date
    @parsed_flight_date ||= Chronic.parse(@flight_date).to_date
  end
end
