/******************************************************************
*
* DFHT.C
*
* Diskrete Schnelle Hartley Transformation DFHT
* Copyright (C) R.A.P. 1991 fuer TOS MAGAZIN
* Compiler: LASER C (bis auf 'lmalloc' 100% portabel)
*
* Im Gegensatz zur 'normalen' schnellen Fouriertransformation bietet
* die DFHT einige entscheidende Vorteile. Diese Routine fuehrt die
* DFHT durch. Nach der Hintransformation werden die einzelnen Elemente
* noch durch ihre Anzahl geteilt,  ansonsten geschieht 
* Hin- und Rueck- transformation mit derselben Routine!
*
* Mit 'power()' laesst sich das Leistungsdichtespektrum berechnen
*
* Diskrete Fouriertransformation, N Elemente:
*
* F(v) = 1/N {Summe t=0 bis N-1: f(t) * exp(-i * 2*PI * v * t / N)}
* f(t) = {Summe v=0 bis N-1: F(v) * exp( i * 2*PI * v * t / N)}
*
* Diskrete Hartleytransformation, N Elemente:
*
* H(v) = 1/N {Summe t=0 bis N-1: f(t) * cas( 2*PI * v * t /N )}
* f(t) = {Summe v=0 bis N-1: H(v) * cas ( 2*PI * v * t / N)}
* Anm: cas(x) = cos(x) + sin(x)
*
* Zusammenhang Hartleytransformation <-> Fouriertransformation
* F(v)=E(v)+ i * O(v) (komplex!)
* mit E(v) = H(v)/2 + H(N - v)/2, O(v) = H(v)/2 - H(N - v)/2
*
* Diese Datei ist Bestandteil der DFHT-DEMO des TOS-Magazins 1991
* und ist eigentlich zum Zusammenlinken mit den anderen Dateien
* dieses Artikels vorgesehen!
*
* Hinweis: Die Variable: '_verbose' steuert die Dokumentation der
* Transformation.
*
* Spezielle LASER C Eigenheiten (!!! Portabilitaet beachten!!!):
*     4 INTEGER-Register (int, long, char, unsigned, ...)
*     4 POINTER-Register (Zeiger auf alle Typen)
*     lmalloc(): Liefert Speicher ueber 64K
* 
******************************************************************/


#include <math.h>					/* Mathefunktionen */
#include <stdio.h>					/* Standard I/O    */

extern char* lmalloc();				/* Speicherbelegung ueber 64 k */
int _verbose=0;						/* Systemvariable: Anzeigen */

/* Anzahl der Stufen der Transformation */
static int stages	= 0;			/* DFHT: Momentane Tiefe */

/* Modulglobale Variablen, die das Leben vereinfachen */
static double PI2	= 6.283185307;	/* PI*2 */ 
static long n;						/* Anzahl Elemente */
static long n_d2;
static long n_d4;					/* Anzahl Elemente/4 */
static long n_d4m1;					/* n_d4-1 zum Ausblenden */

static long m2[32];					/* Potenzen von 2 */
static float *sin_d4;				/* Viertels-Sinus +1 Tabelle */

static float *work_buf;				/* Arbeitsbuffer */

/***********************************************************
* error(): Fehlermeldung und abbrechen
***********************************************************/
error(s)
char *s;{
	printf("\007*** Fehler: %s ***, Ende: <RETURN>\n",s);
	getchar();
	exit(-1);
}
/***********************************************************
* init_dfht(): Initialisierung durchfuehren
***********************************************************/
init_dfht(new_stages)
int new_stages;{

	register long i;
	float *sip;

	if(new_stages==stages) return;		/* Alles wie gehabt */
										/* m2^x berechnen */
	for(i=1, m2[0]=1; i<32; i++) m2[i]=m2[i-1]<<1;
	if(stages){
		free(sin_d4);					/* Speicher freigeben */
		free(work_buf);
	}
	stages=new_stages;					/* merken */
	n=m2[stages];						/* Soviele Elemente ueberhaupt */
	n_d2=n>>1;							/* Elem. /2 */
	n_d4=n>>2;							/* Elem. /4 */
	n_d4m1=n_d4-1;						/* Tabellenmaske */

	work_buf=(float*)lmalloc(n*sizeof(float));		/* Arbeitsbuffer */
	if((sin_d4 = (float*)lmalloc((n_d4+1)*sizeof(float))) == NULL)
		error("init_dhft(): Speicher voll");
										/* Sinustabelle initial. */
	for(i=0, sip=sin_d4; i<=n_d4; i++ ) *sip++=sin((i*PI2)/(float)n);
}
/**************************************************************
* sinus(), cosinus(): Berechnung Trigonometrie
**************************************************************/
float sinus(step)
register long step;{
	float tmp;

	/* Quadrant bestimmen */	
	if(step & n_d4) tmp= sin_d4[n_d4 - (step & n_d4m1)];  /* Q 0,2 */
	else tmp= sin_d4[ step & n_d4m1];					  /* Q 1,3 */

	if(step & n_d2) return -tmp;
	else return tmp;
}
/* Cosinus(x) = Sinus(x+pi/2) */
float cosinus(step)
register long step;{
	return sinus(step+n_d4);	
}
/*****************************************************************
* bit_reverse(): Zahlenfeld permutieren, 'perfect shuffle'
* (Anm: Die Permutation geht erst in Assembler so richtig schnell,
* besonders dann, wenn man sich die Tausch-Indizes merkt!)
*****************************************************************/
bit_reverse(pfeld)
register float *pfeld;{				/* pfeld zeigt auf die Daten */
	register long n_cnt;			/* Counter */
	register long ind_s;			/* Sourceindex */
	register long ind_r;		    /* Reversierter Index */
	register int bits;				/* Soviele Bits zum Revers. */
	float swap_tmp;					/* Zum Austauschen */

	for(n_cnt=0; n_cnt<n; n_cnt++){	/* Alle Elemente durchzaehlen */
		ind_s=n_cnt;
		ind_r=0;
		for(bits=0; bits<stages; bits++){ 	/* Soviele Bits sinds... */
			ind_r<<=1;						/* Platz machen im Ziel */
			if(ind_s & 1) ind_r++;			/* Bit transferieren */
			ind_s>>=1;						/* Naechstes Bit */
		}
		if(ind_r>n_cnt){					/* Nur Tauschen, wenn Ziel- */
			swap_tmp=pfeld[ind_r];			/* index > als Quelle! */
			pfeld[ind_r]=pfeld[n_cnt];
			pfeld[n_cnt]=swap_tmp;
		}		
	}
}
/***********************************************************************
* stage_1(), stage_2(), stage_x(): Die Transformations-Stufen
***********************************************************************/
stage_1(sfeld,dfeld)						/* Stufe 1		  */
register float *sfeld;						/* Von Quelle ... */						
register float *dfeld;{						/* zum Ziel!      */
	register long n_cnt;
	float f0,f1;

	/* Wichtig: Stufe 1: Wahlweise INPLACE oder TRANSPORT wegen Buffer */
	for(n_cnt=0 ;n_cnt<n; n_cnt+=2){
		f0=sfeld[n_cnt];					/* Stufe 1: Nur Addieren! */
		f1=sfeld[n_cnt+1];
		dfeld[n_cnt]=f0+f1;
		dfeld[n_cnt+1]=f0-f1;		
	}
}
stage_2(sfeld,dfeld)						/* Stufe 2		  */
register float *sfeld;						/* Von Quelle ... */						
register float *dfeld;{						/* zum Ziel!      */
	register long n_cnt;
	float f0,f1,f2,f3;
	for(n_cnt=0 ;n_cnt<n; n_cnt+=4){
		f0=sfeld[n_cnt];					/* Stufe 2: Nur Addieren! */
		f1=sfeld[n_cnt+1];
		f2=sfeld[n_cnt+2];
		f3=sfeld[n_cnt+3];
		dfeld[n_cnt]=f0+f2;
		dfeld[n_cnt+1]=f1+f3;		
		dfeld[n_cnt+2]=f0-f2;
		dfeld[n_cnt+3]=f1-f3;		
	}
}
stage_x(sfeld,dfeld,ist_x)					/* Stufe 3,4,5... */
register float *sfeld;						/* Von Quelle ... */						
register float *dfeld;						/* zum Ziel!      */
int ist_x;{									/* Welche Stufe?  */
	long stub, stub_d2, stub_d2m1;			/* Stufenbreite etc. */
	register long n_cnt;					/* Zaehlt... Blocks */
	register long i_cnt;					/* Matrizenelement */

	long tri_s;								/* Trigonom Schrittweite */
	long tri_p=0;							/* Trig. Pos. */

	stub=m2[ist_x];							/* Stufenbreite */
	stub_d2=stub>>1;						/* Halbe Stufenbreite */				
	stub_d2m1=stub_d2-1;					/* Zum 'Unden' */
	tri_s=n/stub;							/* Pro Block ein Durchl. */

	/* Dieses Monster berechnet einen ganzen Block der Stufen-Matrix */
	for(n_cnt=0; n_cnt<n; n_cnt+=stub){
		for(i_cnt=0; i_cnt<stub; i_cnt++, tri_p+=tri_s){
			dfeld[n_cnt+i_cnt]=sfeld[n_cnt+ (i_cnt & stub_d2m1) ]
				+sfeld[n_cnt + stub_d2 + (i_cnt & stub_d2m1)] 
					* cosinus(tri_p)
				+sfeld[n_cnt + stub_d2+ (-i_cnt & stub_d2m1)]
					* sinus(tri_p);
		}
	}
}
/***********************************************************************
*
* void dfht(pdaten, stellen, richtung): Die DFHT
*         Die DFHT wird INPLACE durchgefuehrt. Allerdings wird
*         trotzdem ein Arbeitsspeicher vom Betriebssystem angefordert,
*         ein 'echtes' INPLACE-Programm waere etwas laenger geworden.
*
*         float pdaten[]: Zeigt auf die zu transformierenden Daten
*         int stellen: Logarithmus Dualis der Anzahl der Daten
*		  int richtung: 0: Hin- <>0: Rueck-transformation
*         Kein Rueckgabewert, Fehler werden abgefangen!
*
***********************************************************************/
dfht(pdaten,stellen, richtung)	
float *pdaten;						/* Zeigt auf das Datenfeld */
int stellen;						/* Potenz von 2, (= Feldgr”sse) */
int richtung;{						/* 0: Hin- <>0: Rueck-transformat. */
	float *z0, *z1, *zt;			/* Wechseln: Buffer, Daten */
	int i;
	register long j;

	if(stellen<3 || stellen>32) error("dfht(): Bereich falsch");
	if(_verbose) printf("*** DFHT Initalisieren: %d Bits (Stages)... ***\n",stellen);
	init_dfht(stellen);	

	if(_verbose) printf("*** DFHT Permutieren, %ld Elemente... ***\n",n);
	bit_reverse(pdaten);			/* Daten permutieren */

	if(_verbose) puts("*** DFHT Stage 1... ***");
	if( stellen & 1){				/* Ende: Daten in pdaten[] */
		stage_1(pdaten, pdaten);	/* Ungerade: stage_1: Inplace */
		z0=work_buf;
		z1=pdaten;
	}else{
		stage_1(pdaten, work_buf);	/* Gerade: stage_1: Transport */
		z1=work_buf;
		z0=pdaten;
	}
	if(_verbose) puts("*** DFHT Stage 2... ***");
	stage_2(z1, z0);				/* Sonst: Abwechseln! */
	for(i=3; i<=stellen; i++){
	if(_verbose) printf("*** DFHT Stage %d... ***\n",i);
		stage_x(z0,z1,i);
		zt=z0; z0=z1; z1=zt;
	}
	if(!richtung){
		if(_verbose) printf("*** DFHT %ld Elemente normieren... ***\n",n);
		for(j=0;j<n;pdaten[j++]/=n);
	}
	if(_verbose) puts("*** DFHT Fertig! ***");
}
/***********************************************************************
*
* power(): Powerspektrum berechnen 
*          float sfeld[]: Die Koeffizienten der Hartley-Transf.
*          float dfeld[]: Hierdrin das Spektrum (!!! Halbe Groesse !!!)
*          Return: Wert des groessten Elements.
*
************************************************************************/

float power(sfeld,dfeld,stellen)
register float *sfeld, *dfeld;
int stellen;{
	float maxp;
	float p;
	register long i;

	if(stellen!=stages) error("'power()': Anzahl Elemente falsch!");
	if(_verbose) printf("*** DFHT %ld Elemente Powerspektrum... ***\n",n);
	dfeld[0]=2 * sqr(sfeld[0]);		   /* Sonderfall bei Ausschnitt */
	maxp=dfeld[0];					   /* Maximum initialisieren */
	for(i=1; i< n_d2 ; i++){
		p = sqr(sfeld[i]) + sqr(sfeld[n-i]);
		dfeld[i]=p;
		if(p>maxp) maxp=p;
	}
	if(_verbose) puts("*** DFHT Powerspektrum Fertig! ***");
	return maxp;
}
