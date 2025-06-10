## Insane huge numbers basic operations ##

struct firestone_number
	mant::Float64
	expo::Int64
end

function firestone_number_normalize(m::Float64,e::Int64)
	if abs(m) == 0.0
		return firestone_number(0.0,0)
	else
		while abs(m) >= 10.0
			m /= 10.0
			e += 1
		end
		while abs(m) < 1.0
			m *= 10.0
			e -= 1
		end
		return firestone_number(m,e)
	end
end

function firestone_number_normalize(fn::firestone_number)
	return firestone_number(fn.mant,fn.expo)
end

function split_scientific_notation(str)
	m = match(r"^([+-]?\d+\.?\d*)[eE]([+-]?\d+)$", str)
	if m !== nothing
		return parse(Float64,m.captures[1]), parse(Int,m.captures[2])
	else
		error("matching failed")
	end
end

function firestone_number_normalize(str::String)
	mant, expo = split_scientific_notation(str)
	return firestone_number_normalize(mant,expo)
end

function firestone_addition(x::firestone_number,y::firestone_number)
	if x.expo <= y.expo
		smaller=x
		larger=y
	else
		larger=x
		smaller=y
	end

	if larger.expo > (smaller.expo+3)
		return firestone_number_normalize(larger)
	else
		lm = larger.mant
		le = larger.expo
		while le > smaller.expo
			lm *= 10.
			le -= 1
		end
		s = lm + smaller.mant
		return firestone_number_normalize(s,smaller.expo)
	end
end

function firestone_negative(x::firestone_number)
	return firestone_number_normalize(-x.mant,x.expo)
end

function firestone_multiplication(x::firestone_number,y::firestone_number)
	mm = x.mant * y.mant
	ee = x.expo + y.expo
	return firestone_number_normalize(mm,ee)
end

function firestone_inverse(x::firestone_number)
	if x.mant == 0.0
		return firestone_number(Inf,0)
	else
		return firestone_number_normalize(1.0/x.mant,-x.expo)
	end
end

function firestone_to_float(x::firestone_number)
	if x.expo >= 308
		return Inf
	else
		return x.mant * 10.0^x.expo
	end
end


## Boundaries of feasible constraint line ##

function C_y_at_x_eq_0(h::firestone_number,a::firestone_number,
			N::Int64,K::Int64)
	N_f = firestone_number_normalize(Float64(N),0)
	K_f = firestone_number_normalize(Float64(K),0)
	h_K = firestone_multiplication(h,K_f)
	N_p_K = firestone_addition(N_f,K_f)
	N_N_p_K = firestone_multiplication(N_f,N_p_K)
	a_N_N_p_K = firestone_multiplication(a,N_N_p_K)
	den = firestone_inverse(a_N_N_p_K)
	y = firestone_multiplication(h_K,den)
	return firestone_to_float(y)
end

function C_x_at_y_eq_0(N::Int64,K::Int64)
	N_f = firestone_number_normalize(Float64(N),0)
	K_f = firestone_number_normalize(Float64(K),0)
	den = firestone_inverse(N_f)
	x = firestone_multiplication(K_f,den)
	return firestone_to_float(x)
end

## Feasible parameter for constraint ##

function constraint_zero_xy(t::Float64,h::firestone_number,a::firestone_number,
			N::Int64,K::Int64)
	p1_y = C_y_at_x_eq_0(h,a,N,K)
	p2_x = C_x_at_y_eq_0(N,K)
	xx = t*p2_x
	yy = (1.0 - t)*p1_y
	return xx, yy
end

## Evaluation of constraint ##

function constraint_function(x::Float64,y::Float64,
			h::firestone_number,a::firestone_number,
			N::Int64,K::Int64)
	x_f = firestone_number_normalize(x,0)
	y_f = firestone_number_normalize(y,0)
	h_x = firestone_multiplication(h,x_f)

	N_f = firestone_number_normalize(Float64(N),0)
	K_f = firestone_number_normalize(Float64(K),0)
	N_p_K = firestone_addition(N_f,K_f)
	a_N_p_K = firestone_multiplication(a,N_p_K)
	a_N_p_K_y = firestone_multiplication(a_N_p_K,y_f)

	f_x_y = firestone_addition(h_x,a_N_p_K_y)

	h_K = firestone_multiplication(h,K_f)
	den = firestone_inverse(N_f)
	cc = firestone_multiplication(h_K,den)
	mcc = firestone_negative(cc)
	return firestone_addition(f_x_y,mcc)
end

## Evaluation of cost ##

function unitary_bp_cost(i)
	return 100 + (i-1)*5
end

function summation_bp_cost(n,k)
	i = 0
	s = 0
        while i < k
		j = n + i + 1
		s += unitary_bp_cost(j)
		i += 1
	end
	return s
end

function bp_cost(t::Float64,h::firestone_number,a::firestone_number,
			N::Int64,K::Int64,m_h,n_a)
	x, y = constraint_zero_xy(t,h,a,N,K)
	c_check = constraint_function(x,y,h,a,N,K)

	p_h = ceil(Int,log(1.0+x)/log(1.05))
	q_a = ceil(Int,log(1.0+y)/log(1.05))

	h_cost = summation_bp_cost(m_h,p_h)
	a_cost = summation_bp_cost(n_a,q_a)
	total_cost = h_cost + a_cost

	return total_cost, h_cost, a_cost, p_h, q_a, x, y, c_check
end

## Basic test ##

function tester(h_str,a_str,N,K,m,n)
	h = firestone_number_normalize(h_str)
	println("h = ",h)
	a = firestone_number_normalize(a_str)
	println("a = ",a)
	println("N=$N K=$K m=$m n=$n")

	t_range = collect(0.0:0.1:1.0)
	for t in t_range
		J, J_h, J_a, p, q, x, y, c_xy_check = bp_cost(t,h,a,N,K,m,n)
		println("**** t = $t ****")
		println("J = $J ($J_h + $J_a)")
		println("p=$p , q=$q")
		println("x,y = $x,$y")
		println("c(x,y) = $c_xy_check")
	end
end

## Manual ##

PURPOSE = """
I - Purpose
"""

BACKGROUND = """
II - Background
"""

METHODS = """
III - Method
"""

FORMULAS = """
IV - Formulas
"""

USAGE = """
V - Usage
"""

function manual()
	println(PURPOSE)
	println(BACKGROUND)
	println(METHODS)
	println(FORMULAS)
	println(USAGE)
	println("Version 1.0")
end
