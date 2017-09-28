class FindFlightService
  def initialize(flight_number:, flight_date:)
    @flight_number = flight_number
    @flight_date = flight_date
  end

  def process
    _find_flight
  end

  private

  def _find_flight
    FILES_REPOSITORY.each_with_object([]) do |(_, list), res|
      list.each do |dates, flights|
        found_date = dates.split('-').any? do |date|
          this_flight_date = Chronic.parse(date).to_date
          this_flight_date == _user_flight_date
        end
        if found_date
          flights.each do |this_flight|
            if @flight_number.gsub(/[^\d]/, '') == this_flight['number'].to_s
              res << {
                flight_number: this_flight['number'],
                flight_travel: this_flight['travel']
              }
            end
          end
        end
      end
    end
  end

  def _user_flight_date
    @parsed_flight_date ||= Chronic.parse(@flight_date).to_date
  end
end
