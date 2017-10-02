class FlightstatsFindFlightService
  def initialize(flight_number:, flight_date:)
    @flight_number = flight_number
    @flight_date = flight_date
  end

  def process
    _find_flight
  end

  private

  def _find_flight
    carrier = @flight_number.gsub(/[\d\.]/, '')
    flight = @flight_number.gsub(/[^\d\.]/, '')
    Api::FlightstatusThirdpartiesApi.new.flight_status(
      carrier: carrier,
      flight: flight,
      year: _user_flight_date.year,
      month: _user_flight_date.month,
      day: _user_flight_date.day
    )
  end

  def _user_flight_date
    @parsed_flight_date ||= Chronic.parse(@flight_date, endian_precedence: :little).to_date
  end
end
