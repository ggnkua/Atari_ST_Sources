.. Test the spline function.

function test
## Demonstrates the spline functions in RMAT.
	"Klicken Sie eine Anzahl von Punkten (x,y) mit der Maus an.",
	"Das Programm berechnet dann den natrlichen Spline s(x) in einer",
	"Variablen durch diese Punkte, sowie das Interpolationspolynom.",
	"(Bitte Taste drcken)", wait(180);
	""
	setplot(-1.1,1.1,-1.1,1.1); plot(-1.1,-1.1);
	xgrid(-1:0.5:1); ygrid(-1:0.5:1); hold on;
	title("Klicken Sie die Punkte mit der Maus an. Ende -> Hier! <-");
	t=zeros(1,0); s=t; n=0;
	repeat;
		m=mouse(); if abs(m(1))>1.1 || abs(m(2))>1.1; break; endif;
		t=t|m(1); s=s|m(2);
		n=n+1;
		mark([m(1),m(1)],[m(2),m(2)]);
	end;
	{t,i}=sort(t); s=s(i);
	sp=spline(t,s); x=linspace(min(t),max(t),n*10);
	plot(x,splineval(t,s,sp,x));
	color(2); plot(x,interpval(t,interp(t,s),x)); color(1);
	wait(180);
	hold off;
	
	return 0;
endfunction

function test2
## Demonstrates the spline functions in RMAT.
	"Klicken Sie eine Anzahl von Punkten (x,y) mit der Maus an.",
	"Das Programm berechnet dann den natrlichen Spline s(x,y) in zwei",
	"Variablen durch diese Punkte, sowie das Interpolationspolynom.",
	"(Bitte Taste drcken)", wait(180);
	""
	setplot(-1.1,1.1,-1.1,1.1); plot(-1.1,-1.1);
	xgrid(-1:0.5:1); ygrid(-1:0.5:1); hold on;
	title("Klicken Sie die Punkte mit der Maus an. Ende -> Hier! <-");
	t=zeros(1,0); s=t; n=0;
	repeat;
		m=mouse(); if abs(m(1))>1.1 || abs(m(2))>1.1; break; endif;
		t=t|m(1); s=s|m(2);
		n=n+1;
		mark([m(1),m(1)],[m(2),m(2)]);
	end;
	spt=spline(1:n,t); sps=spline(1:n,s);
	x=linspace(1,n,600);
	plot(splineval(1:n,t,spt,x),splineval(1:n,s,sps,x));
	color(2);
	plot(interpval(1:n,interp(1:n,t),x),interpval(1:n,interp(1:n,s),x));
	color(1);
	wait(180);
	hold off;
	
	return 0;
endfunction


test(); test2();

