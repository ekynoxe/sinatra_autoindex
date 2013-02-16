require 'rubygems'
require 'sinatra'
require 'erb'

set :rootPath, 'public/files'

get '/*' do
	@requestedPath = '/' + params[:splat].reject{|p| p =~ /^\.{1,2}.*?$/}.join('/')
	localPath = File.join(settings.rootPath , @requestedPath)

	# Listing a directory?
	if File.directory?(localPath)
		# redirecting to directory with trailing slash in case we want to serve a
		# => static site with relative references for assets
		if !match = env['REQUEST_PATH'].match(/(.*)\/$/)
			redirect env['REQUEST_PATH'] + '/'
			return
		end

		# If there's an index.html, serve it.
		indexFile = File.join(localPath, 'index.html')
		if File.exists?(indexFile)
			File.read(indexFile)
		else
			@arr = []
			# If not at the root, add the first parameter as '..' linking to the parent directory
			if @requestedPath != '/'
				@arr << {"path" => File.join(File.dirname(@requestedPath), '') , "filename" => '..'}
			end

			@arr += Dir.foreach(localPath).reject{|filename| filename =~ /^\.{1,2}.*?$/}.map{|filename| {"path" => File.join(@requestedPath, filename), "filename" => filename}}
			
			erb :list
		end
	# Otherwise does the path correspond to a local file?
	elsif File.exists?(localPath)
		send_file(localPath)
	# If all fails...
	else
		halt 404, 'not found'
	end
end
