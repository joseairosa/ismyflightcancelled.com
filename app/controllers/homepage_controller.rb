class HomepageController < ApplicationController

  helper_method :found_flight
  helper_method :requested_flight
  helper_method :requested_date

  def index
    if request.post?
      if valid_submission?
        if requested_flight.starts_with?('FR')
          flight_service = StaticFindFlightService.new(
            flight_number: requested_flight,
            flight_date: requested_date
          ).process
        end
        if !requested_flight.starts_with?('FR') || flight_service.nil?
          flight_service = FlightstatsFindFlightService.new(
            flight_number: requested_flight,
            flight_date: requested_date
          ).process
        end
        @found_flight = FoundFlight.new(flight_service)
        if @found_flight.has_error?
          flash.now[:error] = @found_flight.error_message
          @found_flight = nil
        end
      else
        flash.now[:error] = "Either flight number or date are invalid!"
      end
    else
      @found_flight = nil
    end
  end

  private

  def found_flight
    @found_flight
  end

  def requested_flight
    flight_params[:flight_number].gsub(' ', '').gsub('-', '')
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
