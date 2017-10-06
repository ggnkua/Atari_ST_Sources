.. Show the apple set and investigate it, starts automatically or with

function apple1 (z)
## one iteration
	w=1i+z*z;
	return w
endfunction

function apple (z)
## compute 10 iterations
	w=z;
	loop 1 to 10; w=apple1(w); end:
	return w
endfunction

function showapple (a)
## show the apple set in 3D
	{x,y}=field(linspace(a[1],a[2],50),linspace(a[3],a[4],50));
	z=x+1i*y; w=apple(z);
	view(5,3,-0.75,0.7); twosides(0);
	wa=abs(w); wa=max(wa,1);
	l=log(wa); l=2*l/max(max(l)');
	framedsolid(x,y,-l,1);
	return wa;
endfunction

x=[-2,2,-2,2];
w=showapple(x); title("Bitte Taste drcken!"); wait(180);

function test(w)
## show the iterations
	global x;
	setplot(x);
	shrinkwindow(); xplot(); hold on; wl=log(w);
	contour(wl,linspace(1,max(max(wl)'),10));
	title("Klicken Sie einen Punkt an! (Ende -> <Hier>)");
	r=0;
	repeat;
		m=mouse(); z=m[1]+1i*m[2];
		if m[2]>x[4]; break; endif;
		{r,R}=iterate("apple1",z,20);
		color(2); plot(re(R),im(R)); color(1);
	end;
	hold off;
	return r
endfunction

test(w);