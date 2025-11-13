class ApplicationController < ActionController::Base
  def success_response(msg, data, status: :ok)
    render json: { message: msg, data: data }, status: status
  end

  def error_response(msg, errors, status: :bad_request)
    render json: { message: msg, errors: errors }, status: status
  end
end
