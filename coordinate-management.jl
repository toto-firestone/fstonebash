### Management of coordinates for Firestone

#
# Reads one text file, filters global coordinates variables
#

function get_second_var(var1)
	if var1[1] == 'X'
		var2 = string('Y',var1[2:end])
	elseif var1[1] == 'Y'
		var2 = string('X',var1[2:end])
	elseif var1[1] == 'x'
		var2 = string('y',var1[2:end])
	elseif var1[1] == 'y'
		var2 = string('x',var1[2:end])
	else
		var2 = var1
	end

	return var2
end


function read_filter_file(fname)
	file_content = readlines(fname)
	filter_content = String[]
	reg_assign = r"^([xXyY]_\w+)="

	for i in 1:length(file_content)
		m_assign = match(reg_assign,file_content[i])
		if m_assign != nothing
			varname = m_assign.captures[1]
			push!(filter_content,varname)
		end
	end

	var_pairs = []
	while !isempty(filter_content)
		var1 = splice!(filter_content,1)
		var2 = get_second_var(var1)
		i2 = findfirst(==(var2),filter_content)
		if i2 != nothing
			var2 = splice!(filter_content,i2)
			push!(var_pairs,(var1,var2))
		else
			push!(var_pairs,(var1,"SOLO_VAR"))
			println("Warning : $var1 is solo variable")
		end
	end

	return var_pairs
end

#
# Processing all text files containing coordinates (any shell command)
#

function legacy_files(fstone_path)
	rdd = readdir(fstone_path)

	conf_files = filter(x -> endswith(x,".conf"),rdd)
	reg_exclude = r"^s\d+.firestone"
	func_include = x -> (match(reg_exclude,x)==nothing)
	filter!(func_include,conf_files)

	sh_files = filter(x -> endswith(x,".sh"),rdd)

	f_list = [ "s1" ; "s1.firestone.conf" ; conf_files ; sh_files ]

	return f_list
end

function vars_in_legacy_files(fstone_path)
	file_and_vars = []
	legacy_list = legacy_files(fstone_path)
	for i in 1:length(legacy_list)
		fname = legacy_list[i]
		full_name = "$fstone_path/$fname"
		v_list = read_filter_file(full_name)
		for j in 1:length(v_list)
			v = v_list[j]
			push!(file_and_vars,(fname,v[1],v[2]))
		end
	end

	return file_and_vars
end

#
# Coordinate database item
#

struct fstone_coordinate
	coord_name
	legacy_file
	x_varname
	y_varname

	legacy_x_val
	legacy_y_val

	category
	description
end

function init_fstone_coordinate(v_triplet,fstone_path)
	legacy_f_name = v_triplet[1]
	coord_x_name = v_triplet[2]
	coord_y_name = v_triplet[3]

	coord_name = coord_x_name[3:end]

	full_fname = "$fstone_path/$legacy_f_name"
	f_str = read(full_fname,String)
	reg_x = Regex("^$coord_x_name=(\\d+)\$","m")
	reg_y = Regex("^$coord_y_name=(\\d+)\$","m")
	mx = match(reg_x,f_str)
	if mx == nothing
		x_val = "0"
	else
		x_val = mx.captures[1]
	end
	my = match(reg_y,f_str)
	if my == nothing
		y_val = "0"
	else
		y_val = my.captures[1]
	end

	return fstone_coordinate(coord_name,legacy_f_name,
			coord_x_name,coord_y_name,x_val,y_val,
			"category","description")
end

#
# Parse and init
#

function parse_and_init_database(fstone_path)
	f_and_v = vars_in_legacy_files(fstone_path)
	coord_db = []
	for i in 1:length(f_and_v)
		ini_val = init_fstone_coordinate(f_and_v[i],fstone_path)
		push!(coord_db,ini_val)
	end

	return coord_db
end

#
# Write human editable and loadable form
#

function write_init_database(fstone_path)
	init_db = parse_and_init_database(fstone_path)

	open("init_coord.jl","w") do f_out
		println(f_out,"COORD_DB = [")

		for i in 1:length(init_db)
			println(f_out,init_db[i])
			println(f_out,";")
		end

		println(f_out,"]")
	end
end
