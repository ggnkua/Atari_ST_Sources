/****************************************************/
/*                                                  */
/*		    Demonstration fÅr einen schnellen       */
/*			Formel-Interpreter						*/
/*			erstellt mit TURBO C 2.0				*/
/*													*/
/*			(c) 1991 by Richard Kurz				*/
/*			Vogelherdbogen 62						*/
/*			7992 Tettnang							*/
/*													*/
/*			TOS Magazin								*/
/*													*/
/****************************************************/
/*													*/
/*	Die Formelinterpretation geschieht in zwei		*/
/*	Teilen:											*/
/*	1. Die öbersetzung der Formel in einen PCODE.	*/
/*	2. Die anschlieûende Abarbeitung desselben.		*/
/*	Nach auûen hin sind nur die Funktionen			*/
/*	"make_pcode" und "evalute" sowie die Variable	*/
/*	"fehler" sichtbar.								*/
/*	Die Funktion "make_pcode" generiert aus einer 	*/
/*	Åbergebenen Formel den PCODE.					*/
/*	Dieser Zwischencode kann nun von "evalute"		*/
/*	abgearbeitet werden.							*/
/*													*/
/*	P.S.											*/
/*	Ein Dank an lex & yacc							*/
/*													*/
/****************************************************/

#include <stdio.h>
#include <math.h>
#include <errno.h>
#include <string.h>
#include <ctype.h>
#include "eval.h"

/* Funktionen */
#define ACOS 1
#define ASIN 2
#define ATAN 3
#define COSH 4
#define COS 5
#define EXP 6
#define LOG10 7
#define LOG 8
#define POW10 9
#define SINH 10
#define SIN 11
#define SQRT 12
#define SQR 13
#define TANH 14
#define TAN 15
#define ABS 16

/* Befehle */
#define PLUS 1
#define MINUS 2
#define MAL 3
#define GETEILT 4
#define HOCH 5
#define NEGATION 6
#define FUNK 7
#define NUM 8
#define ERG 9
#define VARI 10
#define KLAMMERAUF 11
#define KLAMMERZU 12
#define ENDE 13
#define NIX 14
#define LENDE -1

/*	Grîûe des PCODE-Compiler-Stack	*/
#define MAXCSTACK 20

/*	Grîûe des Interpreter-Stack		*/
#define MAXESTACK 20

/*	Grîûe des PCODE-SPEICHER		*/
#define MAXPCODE 1024

/* Fehler werden in dieser Variablen gemeldet	*/
/* Folgende Fehler stehen zur Debatte			*/
/*
		case 1: Syntax Fehler
		case 2: Math. öberlauf
		case 3: Stack öberlauf
		case 4: Zahl verlangt
		case 5: Pcode voll
		default: Interner Fehler
*/
int fehler;

static struct BEFEHL
{
	/* Die Art des Befehles liegt im typ (siehe Befehle)			*/
	char typ;
	union
	{
		/* Ist der Befehl eine Zahl	hat sie den "inneren" wert 		*/
		double wert;
		/* Wenn es ein Funktionsaufruf ist, muû auch die Funktions- */
		/* nummer irgendwo abgelegt werden (siehe Funktionen)	 	*/
		int fnr;
	} i;
} 	c_stack[MAXCSTACK], /* Der PCODE-Compiler-Stack				*/
	befehl;				/* Da liegt der aktuelle Befehl			*/
	
static 	int c_stacktop,	/* zeigt dem PCC-Stack wo Oben ist		*/
		b_typ,			/* die Art des Befehles					*/
		lbefehl;		/* Was war denn der vorherige Befehl?	*/

static 	int pcode[MAXPCODE], /* Das Grab des PCODE'S			*/
		pcc;				 /* Wo pcode[pcc] hinzeigt, wird 	*/
							 /* der nÑchste Befehl beerdigt		*/

static char *formel; /*	Ein Zeiger auf die aktuelle Position	*/
					 /* in der Formel							*/

/*	Eine handvoll Prototypen						*/
static int s_gleich(char *s1, char *s2);
static int ist_funktion(void);
static int hole_befehl(void); 
static void push(struct BEFEHL *b);
static struct BEFEHL pop(void);
static void auf_stack(int s); 
static void out_pcode(struct BEFEHL *b);
static void out_befehl(int b);
static int compile(void);

static int s_gleich(char *s1, char *s2)
/*	Liefert TRUE wenn s2 gleich dem Anfang von s1	*/
/*	ist und in s1 ein Trennzeichen folgt			*/
{
	while(*s2)
		if(*s1++ != *s2++) return(FALSE);
	return(!isalnum(*s1));
}/* s_gleich */

static int ist_funktion(void)
/*	Ist das nÑchste Wort vielleicht eine Funktion?	*/
{
	register int l,nr=0;
	
	/* Auch eine Art einen klitze kleinen Suchbaum	*/
	/* zu implementieren							*/
	switch(*formel++)
	{
		case 'A':
			if(s_gleich(formel,"BS")) 		nr=ABS;
			else if(s_gleich(formel,"COS"))	nr=ACOS;
			else if(s_gleich(formel,"SIN"))	nr=ASIN;
			else if(s_gleich(formel,"TAN"))	nr=ATAN;
			break;
		case 'C':
			if(s_gleich(formel,"OSH")) 		nr=COSH;
			else if(s_gleich(formel,"OS")) 	nr=COS;
			break;
		case 'E':
			if(s_gleich(formel,"XP")) 		nr=EXP;
			break;
		case 'L':
			if(s_gleich(formel,"OG10")) 	nr=LOG10;
			else if(s_gleich(formel,"OG")) 	nr=LOG;
			break;
		case 'P':
			if(s_gleich(formel,"OW10")) 	nr=POW10;
			break;
		case 'S':
			if(s_gleich(formel,"INH")) 		nr=SINH;
			else if(s_gleich(formel,"IN")) 	nr=SIN;
			else if(s_gleich(formel,"QRT")) nr=SQRT;
			else if(s_gleich(formel,"QR")) 	nr=SQR;
			break;
		case 'T':
			if(s_gleich(formel,"ANH")) 		nr=TANH;
			else if(s_gleich(formel,"AN")) 	nr=TAN;
			break;
		default:
			nr=FALSE;
			break;
	}
	formel--;

	if(nr)
	{
		for(l=0;isalnum(formel[l]) || formel[l]==' ';l++);
		/* Ist denn auch die îffnende Klammer vorhanden?	*/
		if(formel[l]!='(') return(FALSE);
		formel+=l;
		return(nr);
	}
	return(FALSE);
} /* ist_funktion */

static int hole_befehl(void)
/*	Das aktuelle Zeichen im Eingabestring (formel) sollte	*/
/*	eigentlich ein Befehl sein. Aber welcher?				*/
{
	while (*formel==' ') formel++;
	switch(*formel)
	{
		/* Diese Dinge erklÑren sich selbst	*/
		case  0 : return(ENDE);
		case '+': formel++; return(PLUS);
		case '-': formel++; return(MINUS);
		case '*': formel++; return(MAL);
		case '/': formel++; return(GETEILT);
		case '^': formel++; return(HOCH);
		case '(': formel++; return(KLAMMERAUF);
		case ')': formel++; return(KLAMMERZU);
		case 'X': formel++; return(VARI);
		/* Es kînnte ja auch eine Zahl sein	*/
		case '0': case '1': case '2': case '3': case '4': case '5':
		case '6': case '7': case '8': case '9': case '.':
			befehl.i.wert=strtod(formel,&formel);
			if (errno==ERANGE){errno=0;fehler=2;return(NIX);}
			if(isalnum(*formel))	{fehler=1;return(NIX);}
			return(NUM);
		/* Und zuletzt schauen wir ob es eine Funktion ist	*/
		default:
			if((befehl.i.fnr=ist_funktion())!=0) return(FUNK);
			break;
	}
	/* Tja wenn's nix war, dann war's halt NIX */
	return(NIX);
} /* hole_befehl */

static void push(struct BEFEHL *b)
/*	Der Åbergebene Befehl wird auf den PCC-Stack befîrdert	*/
{
	if(c_stacktop>=MAXCSTACK-1) fehler=3;
	else c_stack[++c_stacktop]=*b;
} /* push */

static struct BEFEHL pop(void)
/*	Wir holen einen Befehl vom PCC-Stack	*/
{
	if(c_stacktop<0)	fehler=1;
	return(c_stack[c_stacktop--]);
} /* pop */

static void auf_stack(int s)
/*	Der aktuelle Befehl kommt auf den PCC-Stack	*/
/*	und der nÑchste Befehl wird geholt			*/
{
	befehl.typ=s;
	push(&befehl);
	b_typ=hole_befehl();
} /* auf_stack */

static void out_pcode(struct BEFEHL *b)
/*	Der PCODE muû raus	*/
{
	/* Ich bin gerne auf der sicheren Seite */
	if(pcc>=MAXPCODE+7)
	{
		fehler=5;
		return;
	}
	switch(b->typ)
	{
		/* Zuerst der typ und dann die Frau ÑÑh Zahl	*/
		case NUM: 
			pcode[pcc++]=NUM;
			*((double *)(&pcode[pcc]))=b->i.wert;
			pcc+=((int)sizeof(double)/2);
			break;

		/* Wieder der typ und dann die Funktionsnummer	*/
		case FUNK: 
			pcode[pcc++]=FUNK;
			pcode[pcc++]=(char) b->i.fnr;
			break;

		/* Ansonsten reicht der typ						*/
		default:
			pcode[pcc++]=b->typ;
			break;
	}
} /* out_pcode */

static void out_befehl(int b)
/* Umwandlung eines Befehles in PCODE	*/
{
	struct BEFEHL par1, par2, bef;

	/* Die öblichen welchen	*/
	if(b>=PLUS && b<=HOCH)
	{
		par1=pop();
		bef=pop();
		par2=pop();
		if (par1.typ!=ERG && par2.typ!=ERG) fehler=4;
		else out_pcode(&bef);
	}
	/* Wer denkt denn hier so negativ?	*/
	else if(b==NEGATION)
	{
		par1=pop();
		bef=pop();
		if (par1.typ!=ERG) fehler=4;
		else out_pcode(&bef);
	}
	/* "Funktionieren" sollte es ja auch	*/
	else if(b==FUNK)
	{
		bef=pop();
		/* Den Rest mÅssen wir aber noch Åbersetzen	*/
		/* Die Rekursion lÑût GrÅûen				*/
		compile();
		if (befehl.typ!=ERG) fehler=4;
		else out_pcode(&bef);
	}
	/* War's denn nicht das ENDE ?	*/
	/* Dann war's faul				*/
	else if(b!=LENDE)
	{
		if(!fehler) fehler=1;
		return;
	}
	/* Aus einer Berechnung folgt logischer Weise	*/
	/* ein Ergebnis.								*/
	befehl.typ=ERG;
	push(&befehl);
} /* out_befehl */

static void out_befehle(int b)
/*	Haben wir einen Befehl erkannt und ist er an der Reihe,	*/
/*	dann sollten wir ihn auch in PCODE umwandeln.			*/
/*	NatÅrlich dÅrfen auch die Parameter nicht vergessen		*/
/*  werden. Die Reihenfolge macht's							*/
{
	while((b!=LENDE)&&!fehler)
	{
		out_befehl(b);
		b=c_stack[c_stacktop-1].typ;
		if( b < b_typ ) break;
	}
} /* out_befehle */

static int compile(void)
/*	Wir stricken uns den PCODE	*/
{
	static struct BEFEHL fb;
	int fertig=FALSE;
	
	/* Aus Rekursions-GrÅnden basteln wir uns eine		*/
	/* Markierung fÅr ein lokales Ende					*/	
	fb.typ=LENDE; push(&fb);
	
	/* Die erste Schandtat								*/
	b_typ=hole_befehl();
	
	do
	{
		/* Wie war doch noch der letzte Befehl?				*/
		lbefehl=c_stack[c_stacktop-1].typ;
		
		/* Was macht man denn mit dem aktuellen Befehl?		*/
		switch (b_typ)
		{
			case NUM: case VARI:
				/* War es eine Zahl?						*/
				/* Dann nichts wie raus damit.				*/
				befehl.typ=b_typ;
				out_pcode(&befehl);
				/* Aus der Zahl wird ein Ergebnis			*/
			case ERG: 
				/* Ergebnisse kommen auf den Stack			*/
				auf_stack(ERG);
				break;

			case MINUS:
				/* Immer der érger mit der Doppeldeutigkeit	*/
				/* es kînnte ja auch ein negativ Denker am	*/
				/* Werke sein.								*/
				if (c_stack[c_stacktop].typ!=ERG)
				{
					auf_stack(NEGATION);
					break;
				}
				/* Der Rest gleich wie PLUS					*/
			case PLUS:
				/* Und nun immer schîn die PrioritÑten 		*/
				/* setzen. 									*/
				/* Hatte der vorherige Befehl eine hîhere	*/
				/* PrioritÑt (Punkt vor Strich, usw.), dann */
				/* muû er raus!								*/
				if(lbefehl>=PLUS) out_befehle(lbefehl);
				auf_stack(b_typ);
				break;
				
			case MAL: case GETEILT:
				if(lbefehl>=MAL) out_befehle(lbefehl);
				auf_stack(b_typ);
				break;

			case HOCH:
				if(lbefehl>=HOCH) out_befehle(lbefehl);
				auf_stack(b_typ);
				break;

			case KLAMMERAUF:
				/* Zum Zwecke der PrioritÑtseinhaltung	*/
				/* stÅrzen wir uns in die Rekursion		*/
				compile();
				if(befehl.typ==ERG) auf_stack(befehl.typ);
				else if(!fehler) fehler=1;
				break;

			case KLAMMERZU:	case ENDE:
				/* Schau, an ein lokales Ende			*/
				/* Vielleicht sogar das Ende von allem?	*/
				while((lbefehl!=LENDE)&&!fehler)
				{
					out_befehle(lbefehl);
					lbefehl=c_stack[c_stacktop-1].typ;
				}
				fertig=TRUE;
				break;

			case FUNK:
				/* Funktionsaufrufe mÅssen immer raus!	*/
				/* Es lauert wieder die Rekursion.		*/
				auf_stack(FUNK);
				out_befehle(FUNK);
				b_typ=hole_befehl();
				break;

			default:
				/* Irgend etwas war oberfaul			*/
				if(!fehler) fehler=1;
				break;
		}
	} while (!fertig && !fehler);

	if(fehler)
		return(FALSE);
	else
	{
		/* Zum Schluû das AufrÑumen nicht vergessen		*/
		befehl=pop();
		pop();
		if(befehl.typ==ERG)
			return(TRUE);
		else
		{
			fehler=1;
			return(FALSE);
		}
	}
} /* compile */

int make_pcode(char *eingabe)
/*	Eigentlich nur Vorbereitung.				*/
/*	In "eingabe" sollte die Formel stehen,		*/
/*	aber NULL terminiert bitte schîn			*/
{
	/* Die Startbedingungen						*/
	formel=eingabe;
	pcc=0;
	c_stacktop=-1;

	/* Das Ganze sollte auch hÅbsch groû sein	*/
	strupr(eingabe);
	
	/* auf in's VergnÅgen						*/
	if(compile())
	{
		pcode[pcc]=0;
		return(TRUE);
	}
	return(FALSE);
} /* make_pcode */

double evalute(double vari)
/* Der erzeugte PCODE will auch abgearbeitet werden	*/
/* In "vari" muû die Zahl Åbergeben werden, welche	*/
/* die Variable X ersetzen soll						*/						
{
	static double stack[MAXESTACK];	/* Auch hier wird ein Stack	*/
									/* gebraucht				*/

	register int stacktop=0;		/* Wo ein Stack, da auch    */
									/* ein Oben					*/

	register int *p_code=pcode;		/* Ein Zeiger auf den		*/
									/* aktuellen Befehl			*/

	double d;						/* fÅr Zwischenergebnisse	*/

	/* Solange noch Stoff da ist und kein Mist passiert	*/
	while(*p_code && !fehler && !errno)
	{
		/* Man nehme den Befehl und gehe eins weiter	*/
		switch(*p_code++)
		{
			case NUM:
				/* Wenn es eine Nummer war, auf den 	*/
				/* Stack damit							*/
				stack[++stacktop]=*((double *)p_code);
				p_code+=(int)(sizeof(double)/2);
				break;
			case VARI:
				/* Da ja nur eine Variable bekannt ist,	*/
				/* macht dieses nun keine Probleme		*/
				stack[++stacktop]=vari;
				break;
			/* Der Code ist selbsterklÑrend. Hoffe ich	*/
			case PLUS:
				stack[stacktop-1]=stack[stacktop-1]+stack[stacktop];
				stacktop--; 
				break;
			case MINUS:
				stack[stacktop-1]=stack[stacktop-1]-stack[stacktop];
				stacktop--;
				break;
			case MAL:
				stack[stacktop-1]=stack[stacktop-1]*stack[stacktop];
				stacktop--;
				break;
			case GETEILT:
				stack[stacktop-1]=stack[stacktop-1]/stack[stacktop];
				stacktop--;
				break;
			case HOCH :
				stack[stacktop-1]=pow(stack[stacktop-1],stack[stacktop]);
				stacktop--;
				break;
			case NEGATION :
				stack[stacktop]= -stack[stacktop];
				break;
			case FUNK :
				/* Wenn es eine Funktion war, dann sollte sie	*/
				/* auch ausgefÅhrt werden						*/
				switch(*p_code++)
				{
					case ABS:   stack[stacktop]=fabs(stack[stacktop]); break;
					case ACOS:  stack[stacktop]=acos(stack[stacktop]); break;
					case ASIN:  stack[stacktop]=asin(stack[stacktop]); break;
					case ATAN:  stack[stacktop]=atan(stack[stacktop]); break;
					case COSH:  stack[stacktop]=cosh(stack[stacktop]); break;
					case COS:   stack[stacktop]=cos(stack[stacktop]);  break;
					case EXP:   stack[stacktop]=exp(stack[stacktop]); break;
					case LOG10: stack[stacktop]=log10(stack[stacktop]);break;
					case LOG:   stack[stacktop]=log(stack[stacktop]); break;
					case POW10: stack[stacktop]=pow10(stack[stacktop]); break;
					case SINH:  stack[stacktop]=sinh(stack[stacktop]); break;
					case SIN:   stack[stacktop]=sin(stack[stacktop]);break;
					case SQRT:  stack[stacktop]=sqrt(stack[stacktop]);break;
					case SQR:   d=stack[stacktop]; stack[stacktop]=d*d; break;
					case TANH:  stack[stacktop]=tanh(stack[stacktop]);break;
					case TAN:   stack[stacktop]=tan(stack[stacktop]);break;
					default: fehler=6; break;
				}
				break;
			default:
				/* Sollte eigentlich nicht passieren, aber der	*/
				/* Teufel ist bekanntlich ein Eichhîrnchen		*/
				fehler=6;
				break;
		}
		if(stacktop<0 || stacktop>=MAXESTACK-1)
		/* Auch das sollte nicht passieren, aber ...			*/
		{
			fehler=3;
			break;
		}
	}
	/* War Mist dabei?	*/
	if(errno && !fehler) fehler=2;
	if(fehler) return(0);
	/* Nein!			*/
	else return(stack[stacktop]);
} /* evalute */
