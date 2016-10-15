module ApplicationHelper

	def format_hours secs
		Time.at(secs).utc.strftime("%k:%M:%S") if secs
	end

	def format_minutes secs
		Time.at(secs).utc.strftime("%M:%S") if secs
	end

	def format_mph mph
		mph.round(1) if mph
	end

	def api_race_result_url(race_id, result)
		return "http://localhost:3000/api/races/#{race_id}/results/#{result.id}"
	end

	def api_racer_url racer_id
		return "http://localhost:3000/api/racers/#{racer_id}"
	end

end
