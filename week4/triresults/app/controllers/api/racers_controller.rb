module Api
	
	class RacersController < ApplicationController

		def index
			if !request.accept || request.accept == "*/*"
				render plain: "/api/racers"
			else
#				render plain: "/api/racers", status: 200, content_type: "text/plain"
			end
		end

		def show
			if !request.accept || request.accept == "*/*"
				render plain: "/api/racers/#{params[:id]}"
			else
#				render plain: "/api/racers/#{params[:id]}", status: 200, content_type: "text/plain"
			end
		end

		def entries_all
			if !request.accept || request.accept == "*/*"
				render plain: "/api/racers/#{params[:racer_id]}/entries"
			else
#				render plain: "/api/racers/#{params[:racer_id]}/entries", status: 200, content_type: "text/plain"
			end
		end

		def entries_one
			if !request.accept || request.accept == "*/*"
				render plain: "/api/racers/#{params[:racer_id]}/entries/#{params[:id]}"
			else
#				render plain: "/api/racers/#{params[:racer_id]}/entries/#{params[:id]}", status: 200, content_type: "text/plain"
			end
		end

	end

end
