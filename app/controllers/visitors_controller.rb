class VisitorsController < ApplicationController

  helper_method :found_flights
  helper_method :requested_flight
  helper_method :requested_date

  def index
    if request.post?
      if valid_submission?
        @found_flights = FindFlightService.new(
          flight_number: requested_flight,
          flight_date: requested_date
        ).process
      else
        flash.now[:error] = "Either flight number or date are invalid!"
      end
    else
      @found_flights = nil
    end
  end

  private

  def found_flights
    @found_flights
  end

  def requested_flight
    flight_params[:flight_number]
  end

  def requested_date
    flight_params[:flight_date]
  end

  def valid_submission?
    !requested_flight.empty? && !requested_date.empty? && !Chronic.parse(requested_date).nil?
  end

  def flight_params
    params.permit(:flight_number, :flight_date)
  end
end
