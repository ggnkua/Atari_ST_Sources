function lorenz (t,x)
	return [-3*(x[1]-x[2]),-x[1]*x[3]+26.5*x[1]-x[2],x[1]*x[2]-x[3]]
endfunction

function lorenza
	t=0:0.02:40;
	s=heun("lorenz",t,[0,1,0]);
	v=view(4,2,0.5,0.5);
	framedwire(s[1]/20,s[2]/20,s[3]/20-1);
	title("The Lorenz attractor");
	wait(180);
	view(v);
	return s
endfunction

"The conputation takes a while, please wait!",
lorenza();

