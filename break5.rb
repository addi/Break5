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

type = ARGV.length > 0 ? ARGV[0] : "break"

break_length = ARGV.length == 2 ? ARGV[1].to_i : 5

if type == "break"
    comment_lines("/etc/hosts", "#break", "#/break")
    
	sleep(break_length * 60)

	un_comment_lines("/etc/hosts", "#break", "#/break")
end

if type == "lock"
    un_comment_lines("/etc/hosts", "#break", "#/break")
end

if type == "unlock"
    comment_lines("/etc/hosts", "#break", "#/break")
end
