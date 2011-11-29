#encoding:utf-8
require 'redbis/version'
require 'redbis/client'

module ReDBis

	class << self
		def new o={}
			ReDBis::Client.new o
		end
	end

end

