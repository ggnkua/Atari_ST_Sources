.. Optimization routine

function opti (A,b,z)
## Minimizes z.x' with contraints A.x'>=b and x'>=0. Works only,
## if z>=0. Returns {x,K}.
	si=size(A); m=si[2];
	K=id(m); Kb=zeros(m,1);
	x=Kb;
	A1=A; b1=b;
	repeat
		r=A1.x-b1;
		if r>=0; break; endif;
		e=extrema(r'); i=e[2];
		ir=nonzeros(r'~=e[1]); i=ceil(random(1,1)*length(ir)); i=ir[i];
		v=A1[i];
		mu=K'\v'; lambda=K'\z'; j=nonzeros(mu>epsilon());
		if size(j)==[1,0];
			error("No admissable point!");
		else;
			q=lambda[j]/mu[j];
			e=extrema(q'); jj=e[2]; j=j[jj];
		endif;
		tt=K[j]; K[j]=v; A1[i]=tt;
		t=Kb[j]; Kb[j]=b1[i]; b1[i]=t;
		x=K\Kb;
	end;
	return {x',K}
endfunction

function game (A)
## Maximizes G such that A'.q>=G, sum q_i = 1, q_i>=0.
## Returns {q,G,flag}. flag is 1 if its a strongly unique solution.
	m=max(max(A)');
	B=A'-m; si=size(B);
	M=(B|ones(si[1],1))_(ones(1,si[2])|0)_(-1*ones(1,si[2])|0);
	r=zeros(si[1],1)_1_-1;
	z=zeros(1,si[2])|1;
	{q,K}=opti(M,r,z);
	return {q[1:si[2]],m-q[si[2]+1],!any((K'\z')~=0)};
endfunction

function knobeln (n=3)
## Berechnet die beste Strategie beim Knobeln.
## A und B nehmen insgeheim je 0 bis n Hîlzer.
## A nennt eine Zahl und B eine davon verschiedene.
## Wer nÑher an der Summe ist gewinnt die Hîlzer des Gegners plus 1.
	m=2*n+1;
	A=zeros((n+1)*m,(n+1)*(m-1));
	for i=0 to n;
		for ik=0 to m-1;
			for j=0 to n;
				for jk=1 to m-1;
					if i+j==ik;
						A[i*m+ik+1,j*(m-1)+jk]=j+1;
					else
						if (i+j>ik && jk<=ik) || (i+j<ik && jk>ik);
							A[i*m+ik+1,j*(m-1)+jk]=j+1;
						else
							A[i*m+ik+1,j*(m-1)+jk]=-i-1; 
						endif;
					endif;
				end;
			end;
		end;
	end;
	"Matrix berechnet",
	{q,G,flag}=game(A);
	"Gewinn fÅr zuerst ansagenden : "|printf("%10.5f",G),
	for i=0 to n;
		for ik=0 to m-1;
			if q[i*m+ik+1]~=0;
			else
				printf("%7.5f : Nimm ",q[i*m+ik+1])| ..
				printf("%2.0f, sage ",i)|printf("%2.0f",ik),
			endif;
		end;
	end;
	if flag; "Einzige Lîsung!", endif;
	{p,G,flag}=game(-A');
	"Gewinn fÅr zweiten : "|printf("%10.5f",G),
	for j=0 to n;
		printf("Nimm : %2.0f",j),
		for jk=1 to m-1;
			if p[j*(m-1)+jk]~=0;
			else
				printf("%7.5f : unterbiete ab ",p[j*(m-1)+jk])|..
				printf("%2.0f",jk),
			endif;
		end;
	end;	
	if flag; "Einzige Lîsung!", endif;
	return {q,p};
endfunction	

function schere
## Berechnet die optimale Lîsung fÅr das Schere-, Papier-, Brunnen- und
## Steinspiel.
	q=game([0,1,-1,-1;-1,0,1,1;1,-1,0,1;1,-1,-1,0]);
	"WÑhle mit Wahrscheinlichkeit",
	"Schere  : ", q[1],
	"Papier  : ", q[2],
	"Brunnen : ", q[3],
	"Stein   : ", q[4],
	return q;
endfunction

function pokern (w=5,e=5)
## Lîst ein einfaches Pokerspiel. A und B bekommen ein Karte im Wert
## 1 bis w. A passt oder setzt e. B kann dann passen
## oder halten. Der Grundeinsatz ist 1.
	A=zeros(w,w);
	for i=1 to w; ## Setze bei Karte i bis w
		for j=1 to w; ## Halte bei Karte j bis w
			if j<=i;
				A[i,j]=(w-i+1)*(j-1)+(e+1)*(w-i+1)*(i-j)-w*(i-1);
			else
				A[i,j]=(w-i+1)*(j-1)-(e+1)*(w-j+1)*(j-i)-w*(i-1);
			endif;
		end;
	end;
	A=A/(w*w);
	"Matrix erzeugt!",
	{p,G,flag}=game(A);
	"Gewinn : "|printf("%10.5f",G),
	"Strategie fÅr A:"
	for i=1 to w;
		if !(p[i]~=0);
		printf("%7.5f : ",p[i])|printf("Setze bei %2.0f bis ",i)|..
		printf("%2.0f",w),
		endif;
	end;
	{q,G,flag}=game(-A');
	"Gewinn : "|printf("%10.5f",G),
	"Strategie fÅr B:"
	for i=1 to w;
		if !(q[i]~=0);
		printf("%7.5f : ",q[i])|printf("Halte bei %2.0f bis ",i)|..
		printf("%2.0f",w),
		endif;
	end;
	return {p,q};
endfunction

function simulhelp (w,a,k1,b,k2)
	return -(a<k1)+(a>=k1)*((b<k2)+(b>=k2)*(w+1)*((a>b)-(a<b)))
endfunction

function simul (k,w,pa,k1,k2,pb,k3,k4,n=1000)
## Simuliert eine Pokerspiel mit den Regeln aus function poker.
## A setzt mit Wahrscheinlichkeit pa ab k1, mit (1-pa) ab k2.
## B hÑlt mit Wahrscheinlichkeit pb ab k3, mit (1-pb) ab k4.
	a=floor(random(1,n)*k)+1;
	b=floor(random(1,n)*k)+1;
	ra=random(1,n);
	rb=random(1,n);
	win = sum( ..
		(ra<pa) * (rb<pb) * simulhelp(w,a,k1,b,k3) + ..
		(ra>=pa) * (rb<pb) * simulhelp(w,a,k2,b,k3) + ..
		(ra<pa) * (rb>=pb) * simulhelp(w,a,k1,b,k4) + ..
		(ra>=pa) * (rb>=pb) * simulhelp(w,a,k2,b,k4)),
	return win
endfunction

"opti(A,b,z) definiert."
"game(A) definiert."
"knobeln, pokern, schere und simul definiert."
