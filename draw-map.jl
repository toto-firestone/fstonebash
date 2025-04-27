using Plots
using DelimitedFiles

xyc = readdlm("data20avril.csv",',')

function map_firestone_colors(raw_tab)
	nc=length(raw_tab[:,3])
	cc = fill(:red,nc)

	for i=1:nc
		i_c = raw_tab[i,3]
		if i_c==1
			ccode = :orange
		elseif i_c==2
			ccode = :cyan
		elseif i_c==3
			ccode = :red
		elseif i_c==4
			ccode = :purple
		elseif i_c==5
			ccode = :yellow
		elseif i_c==6
			ccode = :blue
		else
			ccode = :white
		end
		cc[i] = ccode
	end

	return cc
end

cc = map_firestone_colors(xyc)

scatter(xyc[:,1],-xyc[:,2],markercolor=cc,legend=false)
