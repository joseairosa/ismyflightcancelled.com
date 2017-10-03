module Api
  class FlightstatusThirdpartiesApi

    URL = 'https://api.flightstats.com/flex/flightstatus/rest/v2/json'.freeze

    def initialize
    end

    def flight_status(type: :departure, carrier:, flight:, year:, month:, day:)
      path = ["/flight/status"]
      path << carrier.upcase
      path << flight.upcase
      path << _get_url_flight_type(type: type)
      path << year
      path << month
      path << day
      _get(path.join('/'))
      if _last_reponse_error_has_error?
        {
          flight_number: _flight_number,
          date: "#{day}/#{month}/#{year}",
          airline_name: nil,
          from_airport: nil,
          to_airport: nil,
          status: nil,
          error: _last_response_error['errorCode'],
          error_message: _last_response_error['errorMessage']
        }
      else
        {
          flight_number: _flight_number,
          date: "#{day}/#{month}/#{year}",
          airline_name: _airline['name'],
          from_airport: _from_airport['name'],
          to_airport: _to_airport['name'],
          status: _status_to_symbol,
          error: false,
          error_message: nil
        }
      end
    end

    private

    def _get(path)
      @last_response = HTTParty.get("#{URL}#{path}?appId=#{_app_id}&appKey=#{_app_key}&utc=false")
    end

    def _get_url_flight_type(type:)
      case type
      when :departure
        'dep'
      else
        raise StandardError, "Type #{type} not implement for #{__class__}##{__method__}"
      end
    end

    def _app_id
      ENV['ISMYFLIGHTCANCELLED_API_ID']
    end

    def _app_key
      ENV['ISMYFLIGHTCANCELLED_API_KEY']
    end

    def _last_response_json
      return {} if _last_response_code != 200
      @last_response_json ||= JSON.parse(@last_response.body)
    end

    def _last_response_code
      @last_response.code
    end

    def _last_response_message
      @last_response.message
    end

    def _flight_status
      return {} if _last_response_json['appendix'].nil?
      _last_response_json['flightStatuses'][0]
    end

    def _flight_request
      _last_response_json['request']
    end

    def _flight_status_code
      _flight_status['status']
    end

    def _airline
      return {} if _last_response_json['appendix'].nil?
      _last_response_json['appendix']['airlines'][0]
    end

    def _from_airport
      return {} if _last_response_json['appendix'].nil?
      return {} if _last_response_json['appendix']['airports'].nil?
      _last_response_json['appendix']['airports'][0]
    end

    def _to_airport
      return {} if _last_response_json['appendix'].nil?
      return {} if _last_response_json['appendix']['airports'].nil?
      _last_response_json['appendix']['airports'][1]
    end

    def _last_response_error
      if _last_response_json['error'].present?
        _last_response_json['error']
      elsif _last_response_json.empty?
        {
          'errorCode' => _last_response_code,
          'errorMessage' => _last_response_message,
        }
      elsif _from_airport.empty?
        {
          'errorCode' => 404,
          'errorMessage' => "Flight #{_flight_number} not found",
        }
      end
    end

    def _last_reponse_error_has_error?
      _last_response_error.present? || _last_response_code != 200 || _from_airport.empty?
    end

    def _flight_number
      return '' if _flight_request.nil?
      "#{_flight_request['airline']['fsCode']}#{_flight_request['flight']['interpreted']}"
    end

    def _status_to_symbol(status: _flight_status_code)
      return :cancelled if _airline['name'] == 'Monarch Airlines'
      case status
      when 'S'
        :scheduled
      when 'C'
        :cancelled
      when 'L'
        :landed
      end
    end
  end
end
