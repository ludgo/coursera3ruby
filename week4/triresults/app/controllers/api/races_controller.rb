module Api

	class RacesController < ApplicationController

		protect_from_forgery with: :null_session

		def index
			if !request.accept || request.accept == "*/*"
				render plain: "/api/races, offset=[#{params[:offset]}], limit=[#{params[:limit]}]"
			else
#				render plain: "/api/races", status: 200, content_type: "text/plain"
			end
		end

		def create
			if !request.accept || request.accept == "*/*"
				render plain: params[:race][:name], status: :ok
			else
				race = Race.create(race_params)
				render plain: race.name, status: :created
			end
		end

		def show
			if !request.accept || request.accept == "*/*"
				render plain: "/api/races/#{params[:id]}"
			else
				race = Race.find(params[:id])
				render :status=>:ok, :template=>"api/show", :locals=>{ :name=>"#{race.name}", :date=>"#{race.date}" }
			end
		end

		def update
			Rails.logger.debug("method=#{request.method}")
			race = Race.find(params[:id])
			race.update(race_params)
			render json: race, status: :ok
		end

		def destroy
			race = Race.find(params[:id])
			race.destroy
			render :nothing=>true, :status => :no_content
		end

		def results_index
			if !request.accept || request.accept == "*/*"
				render plain: "/api/races/#{params[:race_id]}/results"
			else
				@race=Race.find(params[:race_id])
				@entrants=@race.entrants
				#fresh_when(last_modified: @entrants.max(:updated_at))
				if stale?(last_modified: @entrants.max(:updated_at))
					render :status=>:ok, :template=>"api/results_index"
				end
			end
		end

		def results_show
			if !request.accept || request.accept == "*/*"
				render plain: "/api/races/#{params[:race_id]}/results/#{params[:id]}"
			else
				@result=Race.find(params[:race_id]).entrants.where(:id=>params[:id]).first
				render :partial=>"result", :object=>@result, status: :ok
			end
		end

		def results_update
			update_values = params[:result]
			if update_values
				@result=Race.find(params[:race_id]).entrants.where(:id=>params[:id]).first
				if update_values[:swim]
					@result.swim = @result.race.race.swim
					@result.swim_secs = update_values[:swim].to_f
				end
				if update_values[:t1]
					@result.t1 = @result.race.race.t1
					@result.t1_secs = update_values[:t1].to_f
				end
				if update_values[:bike]
					@result.bike = @result.race.race.bike
					@result.bike_secs = update_values[:bike].to_f
				end
				if update_values[:t2]
					@result.t2 = @result.race.race.t2
					@result.t2_secs = update_values[:t2].to_f
				end
				if update_values[:run]
					@result.run = @result.race.race.run
					@result.run_secs = update_values[:run].to_f
				end
				@result.save
			end
			render :partial=>"result", :object=>@result, status: :ok
		end

		rescue_from Mongoid::Errors::DocumentNotFound do |exception|
			render :status=>:not_found, :template=>"api/error_msg", :locals=>{ :msg=>"woops: cannot find race[#{params[:id]}]" }
		end

		rescue_from ActionView::MissingTemplate do |exception|
			Rails.logger.debug exception
			render plain: "woops: we do not support that content-type[#{request.accept}]", :status=>:unsupported_media_type
		end

		private
			def race_params
				params.require(:race).permit(:name, :date)
			end

			def result_params
				params.require(:result).permit(:swim, :t1, :bike, :t2, :run)
			end

	end

end
