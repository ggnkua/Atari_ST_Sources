.. The Demo. Starts automatically.

""
"Demo loading."
""

demodelay=180;

function delay
	global demodelay;
	return demodelay
endfunction

function warten
	wait(delay());
	return 0;
endfunction

function cplot(z)
## cplot(z) plots a matrix of complex values, which contains the values
## of a function at some rectangular grid.
	plot(re(z),im(z)); hold on;
	plot(re(z'),im(z')); hold off;
	return 0;
endfunction

function fisch
## plots a fish
	global Pi;
	t=0:3;
	ph=interp(t,[0.05,0.3,0.2,1.2]);
	pb=interp(t,[0.05,0.5,0.2,0.2]);
	phi=Pi-linspace(0,2*Pi,20);
	l=linspace(0,3,40);
	psin=dup(sin(phi),length(l));
	pcos=dup(cos(phi),length(l));
	lh=dup(interpval(t,ph,l),length(phi))';
	lb=dup(interpval(t,pb,l),length(phi))';
	x=pcos*lb; z=psin*lh; y=dup(l-1.5,length(phi))';
	view(2.5,1.5,0.3,0.1);
	solid(x,y,z);
	title("A solid fish (return)"); warten();
	huecolor(1); solidhue(x,y,z,-y,1);
	title("A shaded fish (return)"); warten();
	return 0;
endfunction

function grafikdemo
## grafikdemo shows the grafik capabilities of EULER
	fullwindow(); hold off;
	global Pi;

	"Demo of EULER's graphics." ""
	"These graphics have been programmed with a few lines."
	"Study demo for more information!"
	weiter();
	
## Abbildungen von R nach R
	t=-Pi:Pi/20:Pi;
	shrinkwindow(); setplot(-Pi,Pi,-2,2);
	linewidth(4); plot(t,sin(t)); linewidth(1); hold on;
	color(2); style("."); plot(t,cos(t)); 
	color(3); style("--"); plot(t,(sin(t)+cos(t))/2);
	xgrid(-3:1:3,1); ygrid(-1:1,1);
	title("2D plots (return)");
	color(1); style(""); fullwindow(); hold off;
	warten();
	
## Abbildungen von R nach R^2 in vier Fenstern
	t=-Pi:Pi/50:Pi;
	window(10,textheight()*1.5,490,490);
	plot(sin(3*t)/3+cos(t),sin(3*t)/3+sin(t)); hold on;
	title("Parametric curves (return)"); 
	window(510,textheight()*1.5,1010,490);
	plot(sin(2*t)/3+cos(t),sin(2*t)/3+sin(t));
	window(10,510,490,1010);
	plot(sin(2*t),sin(3*t));
	window(510,510,1010,1010);
	t=t+2*Pi;
	plot(cos(t)*log(t),sin(t)*log(t));
	hold off;
	warten();
	
## x^2+y^3 als mesh und contour.
	fullwindow();
	t=-1:0.1:1; t=t*Pi;
	{x,y}=field(t,t);
	mesh(x*x+y*y*y); title("x^2+y^3 (return)"); warten();
	contour(x*x+y*y*y,-30:5:30);
	title("Contour plot of this function (return)"); warten();
	t=-1:0.04:1; t=t*Pi;
	{x,y}=field(sin(2*t),cos(2*t));	
	huecolor(1); density(x*y,1);
	title("Density plot of a function (return)"); warten();
	
## e^-r cos(r) als Drahtmodell.
	t=-1:0.1:1; t=t*Pi;
	{x,y}=field(t,t);
	r=x*x+y*y; f=exp(-r)*cos(r);
	view(2,1,0,0.5); ## [ Abstand, Zoom, Winkel rechts, Winkel hoch ]
	wire(x/Pi,y/Pi,f);
    title("Wire frame model (return)"); warten();

## Der Fisch als solides Modell.
	fisch();
	view(2,1,0.2,0.3);

## Eine complexe Abbildung w=z^1.3
	setplot(-1, 2, -0.5, 1.5);
	t=0:0.1:1; z=dup(t,length(t)); z=z+1i*z';
	color(1); style("."); cplot(z); hold on;
	color(2); style(""); cplot(z^1.3); color(1);
	xgrid(0); ygrid(0);
	title("Complex numbers w=z^1.3"); hold off;
	warten();
	
	"End"
	return 0
endfunction

function weiter
	"" "<< Press return to continue >>" warten(); "",
	return 120;
endfunction

function normaldemo
## Einfhrung in EULER
	global Pi; pi=Pi;
	
	"Hint for window versions:"
	""
	"Use the scrollbars to see the complete text"
	"(or Shift+Cursorup or PageUp on some systems),"
	"if the text disappeared."
	weiter();

	"                             Wellcome at EULER" 
	""
	"EULER has been designed to ease numerical computation."
	"Most of the time one has a tiny problem, to tiny to use a compiler"
	"language."
	""
	"Besides, one may want to play with intermediate results, see a"
	"graphical representation, or simply have readily available"
	"numerical functions."
	"" 
	"All this can be done with EULER."
	"It is like using a numerical laboratory."
	weiter();
	
	"But EULER is not a symbolic algebra program. It uses numbers with"
	"finite accuracy as supplied by the C compiler used. It is therefore"
	"faster than a symbolic program, like MATHEMATICA."
	""
	"All commands are entered by the keyboard. Old commands can be"
	"recalled with cursor up or down. ESC interrupts a computation,"
	"and HELP shows the graphics screen."
	weiter();
	
## Eingabe von Matrizen
	"With EULER one can enter matrices like this:" ""
	">x=[5,6,7]" x=[5,6,7], 
	">A=[1,2,3;5,6,7;8,9,0]" A=[1 2 3;5 6 7;8 9 0],
	"The comma may be omitted."
	"These matrices are stored on the variables x and A."
	weiter();
	
	"All computing is done element for element."
	">x*x" x*x,
	">A+A" A+A,
	weiter();
	
## Complexe Zahlen.
	"Complex numbers and complex computations."
	">1+2i", 1+2i,
	">c=[1i 3 4+5i]", c=[1i 3 4+5i],
	"" ">1i*1i", 1i*1i,
	">exp(1i*pi/2)", exp(1i*pi/2),
	weiter();
	
## Matrixprodukt.
	"The dot multiplies two matrices."
	">A.x'" A.x'
	"Note, that x had to be transposed!"
	"" ">x", x,
	weiter();
	
	"" ">x'", x',
	"" ">x'.x" x'.x,
	weiter();
	
## :
	"Generating vectors:"
	">1:10", 1:10,
	">-1:0.3:1", -1:0.3:1,
	weiter();
	
	">[1 2 3]|[4 5]", [1 2 3]|[4 5],
	">[1 2 3]_[4 5 8]", [1 2 3]_[4 5 8],
	">dup([1 2 3],4)", dup([1 2 3],4),
	weiter();
	
## Funktionen.
	"Also all functions are applied to all elements of a matrix."
	"" ">sqrt([1,2,3,4])" sqrt([1,2,3,4]),
	""
	"There are all the numerical functions."
	"See an overview with >list."
	weiter();
	
	"It is easy to generate a table for a function, and with
	"the table, one can plot the function."
	"" ">t=0:pi/50:2*pi; s=sin(t); xplot(t,s);"
	t=0:pi/50:2*pi; s=sin(t);
	"plots the sine function in [0,2*Pi]",
	weiter();
	shrinkwindow(); xplot(t,s); title("Please press return!");
	fullwindow();
	warten();

## Untermatrizen.
	"Submatrices:" ""
	">x=[11 12 13;21 22 23; 31 32 33]"
	x=[11 12 13;21 22 23; 31 32 33],
	">x(1)" x(1),
	"One can write x[...] or x(...).",
	weiter();
	
	">x[1:2,2]", x[1:2,2],
	">x[2:6,2:6]" x[2:6,2:6],
	">x[:,3]", x[:,3],
	">x[1,[2 2 1 3]]", x[1,[2 2 1 3]],
	weiter();
	
## Numerische Integration.
	"An example:" ""
	">sum(sin((1:100)/100))" sum(sin((1:100)/100)),
	"" 
	"Let us integrate the sine in [0,pi] using the simpson method (but"
	"not the builtin functions). The exact value is 2."
	">t=0:pi/50:pi; n=length(t);", 
	t=0:pi/50:pi; n=length(t);
	">f=2*mod((1:n)+1,2)+2; f[1]=1; f[n]=1;",
	f=2*mod((1:n)+1,2)+2; f[1]=1; f[n]=1;
	">result=sum(sin(t)*f)/3*(t[2]-t[1])", 
	longformat(); result=sum(sin(t)*f)/3*(t[2]-t[1]),
	shortformat();
	"" "; surpresses output of intermediate results."
	weiter();
	
	"By the way:"
	">f[1:5]", f[1:5],
	">f[n-4:n]", f[n-4:n],
	weiter();
	
## Gleichungssysteme.
	"Solve linear systems:"
	"" ">a=hilb(10); b=a.dup(1,10); a\b" ""
	longformat(); a=hilb(10); b=a.dup(1,10); a\b, shortformat();
	""
	"The inaccuracy is unavoidable for the Hilbert matrix." 
	weiter();
	
## Kurvendiskussion.
	"A discussion" ""
	"The function:"
	">x=1:0.02:10; y=log(x)/x;"
	x=1:0.02:10; y=log(x)/x;
	"The function looks like this (press any key)"
	warten();
	shrinkwindow();
	xplot(x,y); ygrid(0); title("(return)"); warten();
	"" "The maximal value is: " ">m=max(y)",
	m=max(y),
	"" "it is obtained in" ">x(nonzeros(y>=m))",
	x(nonzeros(y>=m)),
	"" "The first derivative (numerically)"
	">n=length(x); a=(y[2:n]-y[1:n-1])/(x[2:n]-x[1:n-1]);"
	n=length(x); a=(y[2:n]-y[1:n-1])/(x[2:n]-x[1:n-1]);
	xplot((x[2:n]+x[1:n-1])/2,a); ygrid(0); title ("(return)");
	fullwindow();
	warten();
	
	weiter();
	return 0
endfunction

.. *** Approximations - Demo ***

function apprdemo
	global Pi; pi=Pi;
	
## L_2-Approximation.
	"Some approximation problems."
	"" "First the x-values and the function values are computed:"
	"" ">x=0:0.02:1; y=sqrt(x);", x=0:0.02:1; y=sqrt(x);
	"" "Then the matrix of polynomial values:"
	"" ">n=length(x); p=polyfit(x,y,5),",
	n=length(x); p=polyfit(x,y,5),
	"" 
	">plot(x,y); hold on; color(3); "| ..
	"plot(x,polyval(p,x)); color(1); hold off;"
	weiter();
	plot(x,y); hold on; color(3);
	plot(x,polyval(p,x)); color(1); hold off;
	title("sqrt(x) and its best L_2-approximation (return)"); warten();
	plot(x,y-polyval(p,x)); ygrid(0); title("The error (return)"); warten();
	"The maximal error in this interval is"
	"" ">max(abs(y-polyval(p,x)))", max(abs(y-polyval(p,x))),
	weiter();
	
## Interpolation.
	"Interpolation:" ""
	">t=equspace(0,1,5); s=sin(t); d=interp(t,s);",
	t=equispace(0,1,5); s=sin(t); d=interp(t,s);
	"" ">x=0:0.01:1; max(x,abs(interpval(t,d,x)-sin(x)))",
	x=0:0.01:1; max(abs(interpval(t,d,x)-sin(x))),
	"" ">plot(x,interpval(t,d,x)-sin(x)); ygrid(0); ",
	weiter();
	plot(x,interpval(t,d,x)-sin(x)); ygrid(0);
	title("Interpolation error (return)"); warten();	
	
## Fourierreihe.
	"Discrete Fourier series:"
	""
	">n=64; t=0:pi/n:2*pi-pi/n; s=(t<pi); w=fft(s);"
	n=64; t=0:pi/n:2*pi-pi/n; s=(t<pi); w=fft(s);
	">w[12:2*n-10]=zeros(1, 2*n-21); s1=re(ifft(w));"
	w[12:2*n-10]=zeros(1, 2*n-21); s1=re(ifft(w));
	weiter();
	setplot(0, 2*pi, -0.5, 1.5);
	plot(t,s); hold on;
	color(3); plot(t,s1);
	color(1);
	hold off;
	title("(return)"); warten();

## Fourieranalyse.
	"Fourier analysis"
	""
	"The signal:"
	">t=(0:127)*2*pi/128; x=sin(10*t)+2*cos(15*t);"
	t=(0:127)*2*pi/128; x=sin(10*t)+2*cos(15*t);
	"" "Add some noise:"
	">y=x+normal(size(x));"
	y=x+normal(size(x));
	setplot(0,2*pi,-5, 5); 
	plot(t,x); hold on;
	color(3); plot(t,y); color(1);
	title("Signal und signal with noise (return)"); warten();
	hold off;
	""
	"Now the Fourier analysis:" 
	">c=fft(y); p=abs(c)^2;"
	c=fft(y); p=abs(c);
	plot(0:64,p(1:65)); xgrid([10,15]);
	title("Spectral analysis (return)"); warten();
	weiter();
	
	return 0;

endfunction

.. *** Statistik - Demo ***

function statdemo
## Statistikdemo.
	global Pi; pi=Pi;
	
## t-Test.
	"Statistics :" ""
	"Let us generate 10 simulated measurements:"
	"" ">x=1000+5*normal(1, 10)",
	x=1000+5*normal(1, 10),
	"" "Mean value:" ">m=sum(x)/10", m=sum(x/10),
	"" "Standart deviation:", ">d=sqrt(sum((x-m)^2)/9),"
	d=sqrt(sum((x-m)^2)/9),
	weiter();
	"" "A 95-% confidence interval for the mean value:"
	"" ">t=invtdis(0.975,9)*d/3; [m-t,m+t]",
	t=invtdis(0.975,9)*d/3; [m-t,m+t],
	weiter();
	
## xhi^2
	"Statistical evaluation of dice throws."
	""
	">x=random(1, 600); t=count(x*6,6)'",
	x=random(1, 600); t=count(x*6,6),
	"Compute chi^2" ">chi=sum((t-100)^2/100),"
	chi=sum((t-100)^2/100),
	"We decide that the dice is unbiased, since"
	">1-chidis(chi,5)" 1-chidis(chi,5),
	weiter();
	"Now we simulate a biased dice:"
	">x=(x<0.95)*x; t=count(x*6,6), chi=sum((t-100)^2/100);"
	x=(x<0.95)*x; t=count(x*6,6), chi=sum((t-100)^2/100);
	"Error probability:"
	">1-chidis(chi,5)"
	1-chidis(chi,5),
	weiter();
	
## Binomialverteilung
	"The binomial distribution:"
	"" ">n=20; t=0:n; p=0.4; b=p^t*(1-p)^(n-t)*bin(n,t);"
	">color(3); mark(t,b); color(1);"
	n=20; t=0:n; p=0.4; b=p^t*(1-p)^(n-t)*bin(n,t);
	"" ">d=sqrt(n*p*(1-p));"
	">s=exp(-((t-20*p)/d)^2/2)/(d*sqrt(2*pi));"
	">hold on; plot(t,s); hold off;"
	weiter();	
	color(3); mark(t,b); color(1);
	d=sqrt(n*p*(1-p));
	s=exp(-((t-20*p)/d)^2/2)/(d*sqrt(2*pi));
	hold on; plot(t,s);
	title("Binomial and normal distribution (press return)"); hold off;
	warten();

## Mehrfeldertest
	"chi^2 test:"
	""
	"Given the matrix:"
	">a"
	format(5,0);
	a=[23,37,43,52,67,74;45,25,53,40,60,83];
	a, shortformat();
	""
	"The matrix of expected values:"
	">{k,l}=field(sum(a')',sum(a)'); s=totalsum(a); b=(k*l)/s;"
	{k,l}=field(sum(a')',sum(a)'); s=totalsum(a); b=(k*l)/s;
	weiter();
	"Compute chi^2:"
	">chi=totalsum((a-b)^2/b); 1-chidis(chi,5),"
	chi=totalsum((a-b)^2/b); 1-chidis(chi,5),
	""
	"That means we decide that the columns do not depend of the rows."
	weiter();

## Regression.
	"Regression analysis:" ""
	"A linear function with errors: "
	"" ">t=0:0.2:5; s=2*t+3+0.2*normal(size(t));",
	t=0:0.2:5; s=2*t+3+0.2*normal(size(t));
	">p=polyfit(t,s,1),",
	p=polyfit(t,s,1),
	">color(3); mark(t,s); hold on; color(1); plot(t,polyval(p,t)); hold off;"
	weiter();
	color(3); mark(t,s); hold on; color(1); plot(t,polyval(p,t)); hold off;
	title("The best fit (press return)"); warten();
	
	return 0;
endfunction

function fibo(n)
## fibo(n) liefert einen Vektor mit den ersten n Finonaccizahlen.
	if (n<3) return [1 1]; endif;
	f=ones(1, n);
	for i=3 to n; f[i]=f[i-1]+f[i-2]; end;
	return f
endfunction

function itertest(x)
## itertest(x) konvergiert gegen sqrt(2).
	repeat;
		x=(x+2/x)/2; x,
		if x*x~=2; break; endif;
	end;
	return x;
endfunction
	
function multitest
	return {arg1,arg1*arg1}
endfunction

function hut (x,y)
	si=size(x,y); z=zeros(si);
	loop 1 to prod(si);
		r=x{#}^2+y{#}^2;
		if r<1; z{#}=exp(-1/(1-r)); endif;
	end;
	return exp(1)*z
endfunction
		
function udfdemo
	"EULER is programmable.",
	"" "As an example we list a function, which computes the first n"
	"fibonacci numbers when called with fibo(n):"
	weiter();
	">type fibo",
	type fibo;
	">fibo(5)", fibo(5),
	weiter();
	"As you can see, a function starts with" 
	">function name" 
	"and ends with"
	">end"|"function" 
	"Every function must have a return statement, which stops it."
	weiter();
	"Arguments are named arg1, arg2, arg3, ...,"
	"unless they are given names in the function header."
	"argn() gives the number of arguments. All variables are local and"
	"cease to exist after function execution is finished."
	"But the command" ">global name"
	"allows acces of a global variable."
	weiter();
	
	"There are:" 
	""
	"Conditionals:"
	">if condition; ... { else; ... } endif;"
	""
	"The condition can be any expression, especially a test like < > etc."
	"Logical connections are made with || (or) and && (and)."
	"!condition means: not condition."
	weiter();
	"Repetitive statements:"
	">for variable=start to end { step value }; ... end;"
	">loop start to end; ... end;"
	">repeat; ... end;"
	weiter();
	"In loop's the index can be accessed with index() or #."
	"All these statements can be left with a break; or return ...;"
	weiter();
	
	"" "Example:"
	""
	type itertest
	""
	">longformat(); itertest(1.5), shortformat();", 
	longformat(); itertest(1.5), shortformat();
	weiter();

	"A function can return multiple values and these values can be"
	"assigned to several variables."
	""
	"Syntax:"
	">return {variable,variable,...}"
	"The brackets { and } are part of the syntax here."
	"Then the multiple assignment looks like:"
	">{a,b}=test(parameter)"
	weiter();
	"An example:"
	""
	type multitest
	""
	"{a,b}=multitest(2); a, b,", {a,b}=multitest(2); a, b,
	weiter();
	
	"Comments start with #"|"#. Comments are not listet with type."
	"If the first lines of a functions start with #"|"#,"
	"they are considered help text. With help this text can be read."
	""
	">help field" "", help field,
	weiter();

	"Since all EULER functions work for vector and matrix input,"
	"user defined functions should be written the same way."
	"Most of the time, this is automatic. But sometimes a function"
	"uses a complicate algorithm or cases. Then there is the {} indexing"
	"which treats the matrix like a vector."
	weiter();
	">type hut", type hut
	""
	v=view(5,2,0,0.4);
	">{x,y}=field(-1.2:0.2:1.2,-1.2:0.2:1.2); framedsolid(x,y,hut(x,y));",
	{x,y}=field(-1.2:0.2:1.2,-1.2:0.2:1.2); 
	framedsolid(x,y,hut(x,y)); title("(return)");
	view(v);
	wait(delay());
	""
	shrinkwindow();
	">x=-2:0.05:2; xplot(x,hut(x,0));",
	x=-2:0.05:2; xplot(x,hut(x,0)); title("(return)"); wait(delay());
	fullwindow();
	weiter();

	"Functions should be written with an external editor."
	"You can start an editor from within EULER, like any other program."
	"(Not for XWindow version)"
	"" ">exec string",
	weiter();
	"The string must be in double quotes or must be a variable, which"
	"has been assigned a string. It consists of the program name and"
	"paramters to be passed to the program; e.g.,"
	"" ">exec "|char(34)|"editor.prg testfile"|char(34),
	"" "or"
	"" "a="|char(34)|"editor.prg test"|char(34)|"; a",
	a="editor.prg test"; a,
	"" ">exec a"
	"(Calls Editor.prg)"
	weiter();

	"You can echo output to a file"
	""
	">dump filename"
	"" 
	"Again, filename must be string expression."
	weiter();
	"With"
	">dump"
	"echoing is stopped and the file closed."
	""
	"Dumps are always appended to the file."
	"With"
	">remove filename"
	"the file is removed (killed)."
	""
	"By the way:"
	">forget f; clear a;"
	"removes a function and the variable a."
	weiter();
	
	return 0
endfunction

function f(x)
	return exp(x)-1.5;
endfunction

function dgl(x,y)
	return -2*x*y;
endfunction

function specialdemo

## Simpson
	"Simpson integral : ",
	""
	">type f", type f;
	""
	">t=simpson("|char(34)|"f"|char(34)|",0,1)", t=simpson("f",0,1),
	""
	"The error : "
	""
	"t-(exp(1)-2.5)," t-(exp(1)-2.5),
	weiter();

## Bisektion
	"Solutions of an equation : "
	""
	">type f", type f;
	""
	">t=bisect("|char(34)|"f"|char(34)|",0,1),", t=bisect("f",0,1),
	""
	"Error : "
	""
	">t-log(1.5)", t-log(1.5),
	weiter();
	
## Differentialgleichung
	"Differential equations : "
	""
	">type dgl", type dgl;
	""
	">t=0:0.05:2; s=heun("|char(34)|"dgl"|char(34)|",t,1); plot(t,s);"
	t=0:0.05:2; s=heun("dgl",t,1); plot(t,s); title("(return)"); warten();
	""
	"Maximal error : "
	""
	">max(abs(s-exp(-t^2)))", max(abs(s-exp(-t^2))),
	weiter();	

## Eigenwerte :
	"Eigenvalues and eigenvectors : " ""
	"Given the matrix"
	">A=[0,1;1,1]", A=[0,1;1,1],
	""
	"We compute the eigenvalues and eigenvectors of A."
	">{l,V}=eigen(A); l=re(l),"
	{l,V}=eigen(A); l=re(l),"
	">V=re(V),"
	V=re(V), 
	weiter();
	"Then V'.D.V=A."
	""
	">D=diag(size(A),0,l); V'.D.V,"
	D=diag(size(A),0,l); V'.D.V,
	weiter();

	return 0;	
endfunction

function taste
	"<< Please press return >>", "",
	return wait(delay());
endfunction

function grafiktutor
## Erkl„rt die Grafikfunktionen
	hold off;
	global Pi;
	"Explanation of some grafics functions."
	""
	"First we compute a vector of x-values."
	">x=-1:0.02:1;" x=-1:0.02:1;
	"Then we compute the function at these points."
	">y=sin(4*Pi*x)*exp(-x*x);" y=sin(4*Pi*x)*exp(-x*x);
	"Finally we can plot the function."
	">plot(x,y);"
	taste();
	plot(x,y); wait(delay);
	"The plot can be given a title."
	">title("|char(34)|"sin(4*Pi*x)*exp(-x*x),(return)"| ..
		char(34)|");"
	taste();
	title("sin(4*Pi*x)*exp(-x*x),(return)"); wait(delay());
	"For x- and y-grids, we use the following commands."
	">xgrid(-0.5:0.5:0.5); ygrid(-1:0.5:1);"
	taste();
	xgrid(-0.5:0.5:0.5); ygrid(-1:0.5:1); wait(delay);
	"To draw another plot above it, we use the hold command.",
	">hold on; plot(x,cos(4*Pi*x)*exp(-x*x)); hold off;"
	taste();
	hold on; plot(x,cos(4*Pi*x)*exp(-x*x)); hold off; wait(delay);

	"One can plot several curves wth a single plot command."
	"",
	"This time, the grid is to have labels."
	">shrinkwindow();" shrinkwindow();
	"", ">{x,n}=field(linspace(-1,1,50),1:5); T=cos(n*acos(x));"
	{x,n}=field(linspace(-1,1,50),1:5); T=cos(n*acos(x));
	"This way we computed 5 rows of 5 functions cos(n*acos(x))."
	"", "First we set the plot region manually.",
	">setplot(-1.5,1.5,-1.5,1.5);"
	"The we plot all functions."
	">plot(x,T); xgrid(-2:2,1); ygrid(-2:2,1); wait(delay); hold off;"
	setplot(-1.5,1.5,-1.5,1.5);
	plot(x,T); xgrid(-2:2,1); ygrid(-2:2,1); wait(delay); hold off;
	"One can also mark a point on the screen with the mouse."
	">title("|char(34)|"Click the left mouse button."|char(34)| ..
	"); c=mouse(); c,"
	taste();
	if delay>30;
		title("Click the left mouse button."); c=mouse(); c,
		"These are the coordinates, you choose."
		taste();
	endif;
	
	"Now a function with a singularity."
	""
	">t=-1:0.01:1; setplot(-1,1,-10,10); xplot();"
	t=-1:0.01:1; setplot(-1,1,-10,10); xplot();
	">hold on; plot(t,1/t); plot(t,1/t^2); hold off;"
	hold on; plot(t,1/t); plot(t,1/t^2); hold off;
	""
	taste();
	title("1/t and 1/t^2 (return)"); wait(delay());

	"Functions of two variables :"
	""
	"First we compute a grid of x- and y-coordinates."
	">{x,y}=field(-1:0.1:1,-1:0.1:1);"
	{x,y}=field(-1:0.1:1,-1:0.1:1);
	"", "Then we compute the function values at these grid points and"
	"draw them."
	">z=x*x+x*y-y*y; mesh(z);"
	taste();
	z=x*x+x*y-y*y; fullwindow(); mesh(z); wait(delay());
	"The contour level lines of these function we can inspect with"
	">contour(z,-3:0.5:3);"
	taste();
	contour(z,-3:0.5:3); wait(delay);
	"A perspective view of the same surface."
	">view(2.5,1,1,0.5); solid(x,y,z);"
	taste();
	view(2.5,1,1,0.5); solid(x,y,z); wait(delay);
	"A wire fram model."
	">wire(x,y,z);"
	taste();
	wire(x,y,z); wait(delay);
	
	return 0
endfunction

function abspann
	"As I think, this demo has given you a good impression. So"
	"EULER is well suited for many tasks in applied mathematics, as"
	"well as for viewing functions of one or two variables."
	""
	"The author wishes you succes with mathematics and EULER!"
	return 0
endfunction

function torus
## some torus type bodies.
	view([4,1,0,0.6]);
	global Pi;
	x=linspace(0,2*Pi,40);
	y=linspace(0,2*Pi,20);
	cosphi=dup(cos(x),length(y));
	sinphi=dup(sin(x),length(y));
	cospsi=dup(cos(y'),length(x));
	sinpsi=dup(sin(y'),length(x));
## faster than {phi,psi}=field(x,y); cosphi=cos(phi); ...

## a torus with a thick and a thin side.	
	factor=1.5+cospsi*(cosphi/2+0.6);
	X=cosphi*factor;
	Y=sinphi*factor;
	Z=sinpsi*(cosphi/2+0.6);
	solid(X,Y,Z); title("(Return)"); wait(delay);
	
## a deformed torus
	factor=1.5+cospsi;
	X=cosphi*factor;
	Y=sinphi*factor;
	Z=sinpsi+dup(cos(2*x),length(y));
	solid(X,Y,Z); title("(Return)"); wait(delay);
	
## the Moebius band
	t=dup(linspace(-1,1,20)',length(x));	
	x=linspace(0,Pi,40);
	cosphi1=dup(cos(x),length(y));
	sinphi1=dup(sin(x),length(y));
	factor=2+cosphi1*t;
	X=cosphi*factor;
	Y=sinphi*factor;
	Z=sinphi1*t;
	solid(X,Y,Z); title("Return"); wait(delay);

	return 0;
endfunction

function tube
## some tube like bodies.
	view([3,1,0,0.1]);
	global Pi;
	x=linspace(0,2*Pi,40);

## a atomic modell or so.
	y=0.1+(sin(linspace(0,Pi,15))| ..
		1.5*sin(linspace(0,Pi,10))|sin(linspace(0,Pi,15)));
	cosphi=dup(cos(x),length(y));
	sinphi=dup(sin(x),length(y));
	f=dup(y',length(x));
	
	solid(f*cosphi,f*sinphi,dup(linspace(-2,2,length(y)-1)',length(x)));
	title("(Return)");
	wait(delay); 

## a black hole
	t=linspace(0,1,20);
	cosphi=dup(cos(x),length(t));
	sinphi=dup(sin(x),length(t));
	f=dup((t*t+0.2)',length(x));
	view([3,1.5,0,0.7]);
	solid(f*cosphi,f*sinphi,dup(t'*2-1,length(x)));
	title("(Return)"); wait(delay);

	return 0;
endfunction

function minimal (r,phi)
	R=dup(r',length(phi));
	X=R*dup(cos(phi),length(r))+R*R/2*dup(cos(2*phi),length(r));
	Y=-R*dup(sin(phi),length(r))-R*R/2*dup(sin(2*phi),length(r));
	Z=4/3*dup((r^1.5)',length(phi))*dup(cos(1.5*phi),length(r))-1;
	view(9,1,-1.5,0.2);
	solid(X,Y,Z);
	title("A minmal surface (Return)");
	wait(delay);
	return 0;
endfunction

function spiral
	{r,a}=field(0:0.1:1,0:pi()/8:6*pi());
	z=a/8;
	x=r*cos(a)*(1-a/20);
	y=r*sin(a)*(1-a/20);
	z=z-1.5;
	view(4,1.5,0.5,0.3);
	framedsolid(x,y,z); title("(Return)"); wait(delay);
	return 0;
endfunction

function rings
	rr=0.2;
	t=linspace(0,2*pi,10);
	s=linspace(0,2*pi,41); n=length(s);
	r=dup(1+cos(t)*rr,n)'; m=length(t);
	x=dup(cos(s),m)*r; y=dup(sin(s),m)*r;
	z=dup(sin(t)*rr,n)';
	view([4,1.5,0.3,0.3]);
	X=x_(x+1.3)_(x-1.3);
	Y=y_-z_-z;
	Z=z_y_y;
	solid(X,Y,Z,[m,2*m]);
	return 0;
endfunction

function startdemo
	{x,y}=field(-1:0.1:1,-1:0.1:1);
	z=x*x+y*y;
	mesh(z); title("(Return)"); wait(delay);
	return 0;
endfunction

function demo3d
	startdemo();
	torus();
	tube();
	minimal(0.1:0.1:2.5,0:pi()/20:2*pi());
	spiral();
	rings();
	return 0;
endfunction

function demos
	normaldemo();
	grafikdemo();
	apprdemo();
	statdemo();
	udfdemo();
	specialdemo();
	grafiktutor();
	demo3d();
	return 0;
endfunction;

function demo (del)
	global demodelay;
	if argn==1;
		demodelay=del;
	endif;
	repeat;
	shortformat(); style(""); fullwindow(); color(1); hold off;
	demos();
	abspann();
	weiter();
	end;
	return 0
endfunction

""
type demos
""
"Use one of the above, or type demo() or demo(10)."

"<< Demo will start after 10 seconds. Press Esc to stop it. >>"
wait(10);
demo();