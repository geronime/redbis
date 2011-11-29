#encoding:utf-8
require 'redis'

module ReDBis

	class Client < Redis

		alias_method :orig_select, :select

		# Options and defaults on top of Redis constructor:
		#   db     - database name (optional, default database #0 used by default)
		#   create - whether to record a new database name if unknown yet (false)
		def initialize o={}
			self.class.hash_keys_to_sym o
			dbname = o.delete :db
			create = o.delete :create
			@dbid, @dbname = 0, nil
			redis = super o
			db_select dbname, create if dbname && !dbname.empty?
			redis
		end

		# Complete the name of the database in case of registered.
		# Override method because of setting @dbid and @dbname.
		def select id
			orig_select 0
			@dbid, @dbname = id, hgetall('ReDBis::databases').key(id.to_s)
			orig_select @dbid
		end

		# Return information about currently selected database:
		# {:id => <selected_database_id>, :name => <database_name>}
		def db_current
			{:id => @dbid, :name => @dbname}
		end

		# Select database by its name.
		# If no such database is already recorded, raise an error for create=false,
		# record a new one with the lowest available db id otherwise (or raise an
		# error if all available db ids are already taken).
		def db_select name, create=false
			orig_select 0
			if hexists 'ReDBis::databases', name
				@dbid, @dbname = hget('ReDBis::databases', name), name
				orig_select @dbid
			elsif !create
				orig_select @dbid # go back
				raise "Unknown database name '#{name}'!"
			else # record a new database name
				TRANSACTION_ATTEMPTS.times{|attempt|
					watch 'ReDBis::databases'
					new_id, used_ids = nil, hgetall('ReDBis::databases').values
					used_ids.each_index{|i| used_ids[i] = used_ids[i].to_i }
					used_ids.sort!
					new_id = used_ids.empty? ? 1 :
						((1 .. used_ids[-1] + 1).to_a - used_ids)[0]
					begin
						orig_select new_id
					rescue
						raise "Database unavailable (all database ids used)!"
					end
					select 0
					multi
					hset 'ReDBis::databases', name, new_id
					next unless exec
					@dbid, @dbname = new_id, name
					break
				}
				orig_select @dbid
				raise "Failed to select database '#{name}'!" unless name == @dbname
			end
		end

		# Delete database with specified name including flushdb.
		def db_delete name
			curr_id, curr_name = @dbid, @dbname
			db_select name, false # raises an exception
			flushdb
			orig_select 0
			hdel 'ReDBis::databases', name
			if curr_name == name # stay on database 0
				@dbid, @dbname = 0, nil
			else
				orig_select curr_id
				@dbid, @dbname = curr_id, curr_name
			end
		end

		# wrapper to catch exception of db_delete:
		# delete the database only if it exists, catch exception if not
		def db_delete! name
			begin
				db_delete name
				true
			rescue
				false
			end
		end

		private

		# attempts to perform transaction using ReDBis::databases hash in DB #0
		TRANSACTION_ATTEMPTS = 3

		def self.hash_keys_to_sym h
			h.each_pair{|k, v| h[k.to_sym] = h.delete k if k.kind_of? String }
		end

	end # Client

end # ReDBis

