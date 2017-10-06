.. Demonstrates planet movements

reset;

function force (x,y)
## simple force of a single body at (0,0)
	r=x*x+y*y; r=r*sqrt(r);
	return {-x/r,-y/r}
endfunction

function dgl (t,p)
	{fx,fy}=force(p{1},p{2});
	return [p{3},p{4},fx,fy];
endfunction

function showcurve
## demonstrates the one body problem
	t=linspace(0,4,100);
	setplot(-1.5,1.5,-1.5,1.5); xplot(); hold on;
	s=heun("dgl",t,[1,0,0,1]);
	plot(s[1],s[2]);
	s=heun("dgl",t,[1,0,0,0.9]);
	plot(s[1],s[2]);
	s=heun("dgl",t,[1,0,0,0.8]);
	plot(s[1],s[2]);
	s=heun("dgl",t,[1,0,0,0.7]);
	plot(s[1],s[2]);
	hold off;
	return plot();
endfunction
"showcurve defined"

function showpotential
## demonstrates the Newton potential
	{x,y}=field(linspace(-0.9,1.1,23),linspace(-1,1,23));
	p=max((-1)/sqrt(x*x+y*y),-10)+0.5;
	view(3,4,0.5,1.2);
	solid(x,y,p); hold on;
	t=linspace(0,3.5,150);
	s=heun("dgl",t,[1,0,0,0.7]);
	ps=-1/sqrt(s[1]*s[1]+s[2]*s[2])+0.5;
	color(2); wire(s[1],s[2],ps); hold off;
	return 0;
endfunction
"showpotential defined",

"",
"Make the screen look square and run showcurve or showpotential",

.. EOF
