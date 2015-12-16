class MethodSpyPlacer
	
	def initialize(spy_pairs = {})

		ENV["spy_log"] = 'spy_log.spy_log'


		@spy_pairs = spy_pairs

		start_and_end_methods.keys.each do |key|
			@spy_pairs[key] = start_and_end_methods[key]
		end

	end

	def scan_for_method_definitions_and_insert_spies source_file

			@spy_pairs.keys.each do |pair|

				original_source = File.read(source_file)

				pattern = @spy_pairs[pair][:regex]
				insert_spy = @spy_pairs[pair][:replacement]
				
				File.open(source_file, "w") do |file|
					matchies = original_source.match(pattern)||[]
					matches = [
						matchies[0],
						matchies[1],
						matchies[2],
						matchies[3],
						matchies[4]
					]
					file << original_source.gsub(pattern) { 
						insert_spy.call(matches)
					}

				end
				
				
			end
			
	end

	def add_spies(spy_pairs = {})
		spy_pairs.keys.each { @spy_pairs }
	end

	def start_and_end_methods

		{
			# apples: {
			# 	regex: /apples/,
			# 	replacement: Proc.new do |match|
			# 		"bananas#{match}mangoes"

			# 	end
			# },
			method_start: {
				regex: /def\s+\w+.*$/,
				replacement: Proc.new do |matches|

					spy = 'File.open("' + ENV["spy_log"] + '", "a") { |file| file << "Psst, a message from a spy!" }'


					whole_match, first_capture = matches

					"#{whole_match}\n#{spy}\n"
					
					
				end
			},
			method_end: {
				# regex: /def\s+\w+\b\n.*?*?(end)/,
				regex: /end/,
				replacement: Proc.new do |matches|
					whole_match, first_capture = matches
					"'I am the end!'\n#{whole_match}"
				end,			
			} 
		}

	end

end

p MethodSpyPlacer.new.scan_for_method_definitions_and_insert_spies 'something.rb'



# trace_report = FinalReport.new

# target_files
# 	.map { |file| SourceFile.new file }
# 	.tap do |source_file| 
# 		scanner.scan_for_method_definitions_and_insert_spies source_file
# 	end

# trace_report.dump_yaml trace_destination