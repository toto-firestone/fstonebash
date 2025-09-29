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

## Basic process ##

function optimizer(h_str,a_str,N,K,m,n)
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

When I started playing firestone on s8, the standard strategy for blueprint
upgrade on WM was : maximize everything in only one WM. On s10, my second
server, it was also the most followed blueprint upgrade pattern. After a
long break, I restarted on s14 and some players started to state that
blueprint upgrades on WM armor were useless. I also started to read some
old players on official discord server of Firestone, giving the same kind of
advice. Either useless or not a priority, WM armor is not as wanted as before.

However, we need to recall that winnning a WM campaign mission is a two steps
process : 1) reach the battle power requirement for mission unlocking, 2) beat
the mobs in less than 20 rounds. Even if WM armor does not help for step 2),
it may help for step 1) in a solo WM configuration.

This software is intended to check whether spending blueprints in WM armor is
worthy or not. In order to answer to that question, we can try to find the
optimal combination of WM health and armor upgrades for the achievement of
a precise defensive improvement : survive 1 or more ennemy hits.

There will be a summary of some mathematical background that have been used
in this quest. Then we will explain how the answer to our question is
derived from actual data. After that, there are more details about how
answer is actually calculated. And finally, a user manual of the software
is given.
"""

BACKGROUND = """
II - Background

Optimization is a frequent word in Firestone. We all try to obtain the
maximum efficiency at minimal cost. In mathematics, optimization is a
field dedicated to applications. The goal is not building some new theories.
It's rather about using theories for the improvement of our technologies.

The first step is to write down the cost with a math function. We have
2 parameters related to blueprint upgrade levels in HP and armor respectively.
And we want to minimize the cost of these upgrades. This one is easy to figure
out. The second step is to write down the constraints on our parameters
with a math function again. That one is more tricky. We need to say "I want
to survive longer" with only maths. How to evaluate survival potential
as a function by blueprint upgrade is the key of the method.

Let's introduce now some notations :
J : cost function
C : constraint function
h : health
a : armor
N : number of hits that 1 WM can take before destruction
K : number of extra hits that we need
n : current number of blueprints in health
m : current number of blueprints in armor
p : number of health upgrades
q : number of armor upgrades
x : relative increase in health
y : relative increase in armor
D : current ennemy damage
"""

METHODS = """
III - Method

Let's start by writing the constraint, which is the most difficult task. In
optimization, integer number parameters is way more difficult to handle than
real number ones. Continuous maths offer way more tools than discrete maths.
So the first step consist in finding a formulation in the continuous field
that can be related to the discrete problem.

Each blueprint upgrade gives a 1.05 multiplier to an attribute. The attribute
multiplier after p blueprint upgrades is 1.05^p (power function). Then we
introduce the relative increase of an attribute value after p upgrades :

x = (upgraded_value - base_value) / base_value

Let's apply this for health and armor blueprint upgrades :

x = (h*1.05^p - h) / h = 1.05^p - 1
y = 1.05^q - 1

Now we are going to work with x and y (real numbers) instead of p and q
(integer numbers). So health and armor improvement can be written as follows :

h_upgr = (1 + x)*h
a_upgr = (1 + y)*a

The second step is another choice for the sake of simplification. Ennemy
damage is written no where in the game. The scaling up law of ennemy stats
is given only in Fandom Wiki. It's still a complex formula depending on
mission number and difficulty type. Then the two options we have are :
1) Code the ennemy damage as a function of mission and difficulty. This is
technically possible but quite difficult to test and check. Actual ennemy
damage value is written no where and too many missions remain locked
in my accounts at the time I write this.
2) Use an approximation of ennemy damage by replacing it with the number
of ennemy hits required to destroy the WM that needs defensive improvement.
Thus ennemy damage is estimated approximatively while watching the battle
we need to win, which is a practical way to ensure that the damage value
is realistic. 
So I choose 2) in order to avoid an implementation and test difficulties.
Being destroyed by N hits is written as follows :

N*(D - a) = h

The approximations come from counting the hits (not easy with healing ability)
and from the assumption that the equality should actually be a greater or equal
(>=). The damage estimation is :

D = a + h/N

Since h is quite huge, a counting error on N will not be a big deal. With this
approximation of ennemy damage, we can update the number of hits by using
upgraded values of health and armor (h_upgr and a_upgr). A substitution
leads to :

N + K = h_upgr / (a + h/N - a_upgr)

Note that N + K is the number of hits that the WM should be able to take after
blueprint upgrades. With some calculations, the final expression of constraint
is :

C(x,y) = h*x + a*(N + K)*y - (K/N)*h = 0

x and y are positive real numbers.

Now it's cost function's turn. We need to go back to integer field using
logarithm and ceil rounding :

p = ceil(Ln(1 + x)/Ln(1.05))
q = ceil(Ln(1 + y)/Ln(1.05))

p and q are now functions of x and y.

Then the cost of p health and q armor blueprint upgrades, starting from
levels m+1 and n+1 respectively is :

J = sum{i=m+1 to m+p} cost(i) + sum{i=n+1 to n+q} cost (i)
cost(i) = 100 + (i - 1)*5
"""

SOLVING = """
IV - Solving

The optimization of blueprint upgrades can be written as :

find (x,y) that minimize J(x,y) such that C(x,y) = 0

We are going to find that with a basic approach that does not exhibit the
exact formula of optimal (x,y). Instead of that, we go for an approxmimated
graphical solution of the problem. There are already approximations so
is does not make sense to look for an exact formula.

We start to reduce the 2-dimensional parameter space into a 1-dimensional
one. C(x,y) = 0 is actually 1 dimensional and affine. So we reduce that
to a single parameter t in the [0,1] interval :

(1 - t)*(0,y_0) + t*(x_0,0)

where y_0 and x_0 are admissible values for the constraint when x=0 or y=0.
They can be found easily by solving  C(x_0,y=0)=0 and C(x=0,y_0)=0 :

x_0 = K/N
y_0 = (h/a) * K/(N*(N+K))

The set of points defined by (x(t),y(t)) is a zero line for the constraint.
We can easily check that :

C(x(t),y(t)) = 0

Then we only need to find t that minimize J(x(t),y(t)). By calculating several
values of the cost J in the range [0,1] by steps of 0.1, we can see which
values of x(t) and y(t) have the smaller cost, given h, a, N, K, m, and n.
By transforling x(t) and y(t) to p and q, we get the number of blueprints
upgrades for health and armor for each value of the parameter t.

This calculation leads to the conclusion that armor is worthless in battle.
Minimal values of J are always found at y=0, which means no armor upgrade.
The fact that x_0 is independant of current health and armor values means
that health upgrade is a good deal in any case. 
Furthermore, the (h/a) term in y_0 tells that once armor lags behind
health, it becomes even more useless to catch up... unless pure battle power
increase is required to unlock a new mission in a solo WM set up.
"""

USAGE = """
V - Usage

optimizer(h_str,a_str,N,K,m,n)

Example :

optimizer("9.15e8","6.52e6",23,1,40,38)

"9.15e8" is the value of health found in crew edition screen
"6.52e6" is the value of armor found in crew edition screen
23 is the number of hits counted during a lost battle
1 is the additional hit i need to take
40 is the blueprint level of health found in garage
38 is the blueprint level of armor found in garage

Be careful to enclose health and armor values in double quotes. Scientific
notation is a requirement. it means that an armor of 90 needs to be written
like "9e1". The presence of e is always required.

And for basic usage, just calculating the bp cost for filling up a few stats :

summation_bp_cost(n,k)

where n is current level, k is the number of additional level ups.
"""

function manual()
	println(PURPOSE)
	println(BACKGROUND)
	println(METHODS)
	println(SOLVING)
	println(USAGE)
	println("Version 1.0")
end

manual()
