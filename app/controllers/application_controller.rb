class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def disable_sql_logging
    orig_logger = ActiveRecord::Base.logger

    begin
      ActiveRecord::Base.logger = nil
      res = yield
    ensure
      ActiveRecord::Base.logger = orig_logger
    end

    res
  end
end
