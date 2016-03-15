module(..., package.seeall)

function get(filename)
	local f, err = io.open(filename, 'r')
	if not f then return nil, err end

	local initable = {}
	local current_section
	for line in f:lines() do
		local l
		local i = line:find("#")
		if i then
			l = line:sub(1, i - 1)
		end	
		l = l:match("^%s*(.-)%s*$")	

		if l ~= "" then
			local section = l:match("^%[([_%w%s]*)%]$")
			if section then
				current_section = section
				if not initable[current_section] then initable[current_section] = {} end
			else
				local key, value = l:match("([^=]*)%=(.*)")	
				key = key:match("^%s*(.-)%s*$")
				value = value:match("^%s*(.-)%s*$")
				if key and value and section then
					initable[current_section][key] = value
				end	
			end	
		end
	end

	f:close()
	return initable	
end

function set(filename, initable)
	local f, err = io.open(filename, 'w')
	if not f then return nil, err end

	for section, section_table in pairs(initable) do
		f:write("[" .. tostring(section) .. "]\n")
		for key, value in pairs(section_table) do
			f:write(tostring(key) .. "=" .. tostring(value) .. "\n")
		end
	end
	f:close()
end
