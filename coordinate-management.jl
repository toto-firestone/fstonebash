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
	conf_file
	description
end

function init_fstone_coordinate(v_triplet,fstone_path)
	legacy_f_name = v_triplet[1]
	coord_x_name = v_triplet[2]
	coord_y_name = v_triplet[3]

	coord_name = coord_x_name[3:end]

	full_fname = "$fstone_path/$legacy_f_name"
	f_str = read(full_fname,String)
	reg_x = Regex("^$coord_x_name=\"?(-?\\d+)\"?\$","m")
	reg_y = Regex("^$coord_y_name=\"?(-?\\d+)\"?\$","m")
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
			"category",".conf","description")
end

#
# Parse and init legacy database
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

function write_init_legacy_database(fstone_path)
	error("Non executable function : only manual edit of legacy-coord.jl")
	init_db = parse_and_init_database(fstone_path)

	open("legacy-coord.jl","w") do f_out
		println(f_out,"LEGACY_COORD_DB = [")

		for i in 1:length(init_db)
			println(f_out,init_db[i])
			println(f_out,";")
		end

		println(f_out,"]")
	end
end

#
# Transition from legacy to single config file system
#

struct fstone_globcoord
	coord_name
	x_varname
	y_varname

	x_val
	y_val

	category
	description
end

function init_globcoord_from_legacy(lc)
	return fstone_globcoord(lc.coord_name,lc.x_varname,lc.y_varname,
			lc.legacy_x_val,lc.legacy_y_val,
			lc.category,lc.description)
end

function coord_summary(c::fstone_coordinate)
	return "$(c.category); $(c.coord_name) / $(c.legacy_file)"
end

function coord_summary(c::fstone_globcoord)
	return "$(c.category); $(c.coord_name)"
end

function print_db(coord_db)
	for i in 1:length(coord_db)
		elm = coord_db[i]
		println(i," - ",coord_summary(elm))
	end
end

using Dates

function get_categories(coord_db)
	all_cat = unique([c.category for c in coord_db])
	filter!(!=("ServerSpecific"),all_cat)
	filter!(!=("Duplicate"),all_cat)
	pushfirst!(all_cat,"Duplicate")

	return all_cat
end

function get_assignments(coo::fstone_coordinate)
	a1 = "$(coo.x_varname)=$(coo.legacy_x_val)"
	if coo.y_varname == "SOLO_VAR"
		a2 = ""
	else
		a2 = "$(coo.y_varname)=$(coo.legacy_y_val)\n"
	end

	return a1, a2
end

function get_assignments(coo::fstone_globcoord)
	a1 = "$(coo.x_varname)=$(coo.x_val)"
	if coo.y_varname == "SOLO_VAR"
		a2 = ""
	else
		a2 = "$(coo.y_varname)=$(coo.y_val)\n"
	end

	return a1, a2
end

function legacy_to_single_conf()
	error("Non executable function : only manual edit of glob-coord.jl")
	include("legacy-coord.jl")

	by_category_db = sort(LEGACY_COORD_DB,by=c->c.category,
			alg=Base.Sort.MergeSort)
	print_db(by_category_db)

	now_d = Dates.format(now(),"dd/mm/yyyy HH:MM")
	conf_file = "glob-coord.conf"
	conf_intro_msg = """
###   $conf_file   ###
### GENERATED BY legacy_to_single_conf() FUNCTION ###
###           IN coordinate-management.jl         ###
###   $now_d   ###
"""
	db_file = "glob-coord.jl"
	db_intro_msg = """
###   $db_file   ###
### GENERATED BY legacy_to_single_conf() FUNCTION ###
###           IN coordinate-management.jl         ###
###   $now_d   ###
"""

	categs = get_categories(by_category_db)
	open(conf_file,"w") do f_out
	open(db_file,"w") do g_out
		println(f_out,conf_intro_msg)
		println(g_out,db_intro_msg)
		println(g_out,"GLOB_COORD_DB = [")
		for cat in categs
			cat_msg = "\n\n### $cat ###"
			println(f_out,cat_msg)
			println(g_out,cat_msg)

			this_cat = filter(c -> c.category==cat,by_category_db)
			for i in 1:length(this_cat)
				coo = this_cat[i]
				println(f_out,"# ($i) $(coo.coord_name)")
				println(g_out,"# ($i) $(coo.coord_name)")

				ax, ay = get_assignments(coo)
				println(f_out,ax)
				println(f_out,ay)

				new_coo = init_globcoord_from_legacy(coo)
				println(g_out,new_coo)
				println(g_out,";")
			end
		end
		println(g_out,"]")
	end
	end
	return
end

#
# Transfers database in Julia format to bash shell config file
#

function rewrite_globcoord_conf()
	include("glob-coord.jl")

	# no sorting required
	print_db(GLOB_COORD_DB)

	now_d = Dates.format(now(),"dd/mm/yyyy HH:MM")
	conf_file = "glob-coord.conf"
	run(`cp $conf_file $conf_file.bak`)
	conf_intro_msg = """
###   $conf_file   ###
### GENERATED BY rewrite_globcoord_conf() FUNCTION ###
###            IN coordinate-management.jl         ###
###   $now_d   ###
"""

	# no tweek with ServerSpecific and Duplicate
	categs = unique([c.category for c in GLOB_COORD_DB])
	open(conf_file,"w") do f_out
		println(f_out,conf_intro_msg)
		for cat in categs
			cat_msg = "\n\n### $cat ###"
			println(f_out,cat_msg)

			this_cat = filter(c -> c.category==cat,GLOB_COORD_DB)
			for i in 1:length(this_cat)
				coo = this_cat[i]
				println(f_out,"# ($i) $(coo.coord_name)")

				ax, ay = get_assignments(coo)
				println(f_out,ax)
				println(f_out,ay)
			end
		end
	end
	return
end

#
# Load the database file
#

function load_globcoord_db()
	include("glob-coord.jl")
	print_db(GLOB_COORD_DB)

	return GLOB_COORD_DB
end

#
# All further operation on Julia format database will require a save
#

function save_globcoord_db(coord_db)
	# no sorting required here
	# should be done earlier (push new element at the end and merge sort)

	now_d = Dates.format(now(),"dd/mm/yyyy HH:MM")
	db_file = "glob-coord.jl"
	run(`cp $db_file $db_file.bak`)
	db_intro_msg = """
###   $db_file   ###
### GENERATED BY save_globcoord_db() FUNCTION ###
###         IN coordinate-management.jl       ###
###   $now_d   ###
"""

	# no tweek with ServerSpecific and Duplicate
	categs = unique([c.category for c in coord_db])
	open(db_file,"w") do g_out
		println(g_out,db_intro_msg)
		println(g_out,"GLOB_COORD_DB = [")
		for cat in categs
			cat_msg = "\n\n### $cat ###"
			println(g_out,cat_msg)

			this_cat = filter(c -> c.category==cat,coord_db)
			for i in 1:length(this_cat)
				coo = this_cat[i]
				println(g_out,"# ($i) $(coo.coord_name)")

				println(g_out,coo)
				println(g_out,";")
			end
		end
		println(g_out,"]")
	end

	return
end
