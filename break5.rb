def comment_lines(host_path, break_start_tag, break_end_tag)
	host_content = File.read(host_path)

	break_content = host_content[/#{break_start_tag}(.*?)#{break_end_tag}/m, 1].strip

	break_lines = break_content.split("\n")

	found_lines_to_comment = false

	break_lines.collect! do |line|
		if line.length > 0 and line[0] != "#"
			found_lines_to_comment = true
			line = "#"+line
		end
	end

	if found_lines_to_comment
		new_break_content = break_lines.join("\n")

		host_content.sub! break_content, new_break_content

		File.write(host_path, host_content)

		return true
	end

	return false
end

def un_comment_lines(host_path, break_start_tag, break_end_tag)
	host_content = File.read(host_path)

	break_content = host_content[/#{break_start_tag}(.*?)#{break_end_tag}/m, 1].strip

	break_lines = break_content.split("\n")

	found_lines_to_un_comment = false

	break_lines.collect! do |line|
		if line.length > 0 and line[0] == "#"
			found_lines_to_un_comment = true
			line = line[1..-1]
		end
	end

	if found_lines_to_un_comment
		new_break_content = break_lines.join("\n")

		host_content.sub! break_content, new_break_content

		File.write(host_path, host_content)

		return true
	end

	return false
end

found_lines_to_block = comment_lines("/etc/hosts", "#break", "#/break")

if found_lines_to_block
	sleep(5 * 60)

	un_comment_lines("/etc/hosts", "#break", "#/break")
end