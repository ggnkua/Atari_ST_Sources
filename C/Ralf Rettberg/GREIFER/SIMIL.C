/* sonderbeilage			*/
/* hat nix mit dem greifer zu tun	*/


/*	SIMIL.C							20.12.88
................................................................................

	prozent = simil(s1,s2);
	int	prozent;
	char	*s1,*s2;

	die funktion vergleicht 2 strings und liefert einen prozentualen wert
	fuer die aehnlichkeit: 
	0   = keine gemeinsamkeit
	100 = beide strings identisch

	der algorithmus stammt von RATCLIFF/OBERSHELP.
	in DR. DOBBS JOURNAL juli 88 war ein listing in intel-assembler
	abgedruckt, aufgrund dessen ich diese c-version zusammengestoppelt
	habe

	laesst sich sicher noch optimieren, oder vielleicht schreibt's mal
	jemand in 68000er asm, bin ich leider zu bloed/faul zu
	
	eine sinnvolle anwendung fÅr SIMIL sind z.B. fehlertolerante 
	benutzeroberflÑchen, oder compiler die, wenn sie auf 'prozedure' 
	stossen, sagen aha der meint 'procedure'

	Ralf Rettberg
	Moenchebergstr. 8
	3500 Kassel

................................................................................
*/


#include <strings.h>

#define DEBUG 0

typedef struct	{
	int	nchars;
	char	*s1;
	char	*s2;
		} GLEICH;





/*.................................................. maxchars() ..............*/

/*	nimmt 2 zeichenketten s1 u. s2 (brauchen nicht 0 terminiert zu sein)
	der laengen n1 u. n2 und sucht den laengsten gemeinsamen substring.
	returnwert ist ein struct der die anzahl der uebereinstimmenden
	zeichen und fuer jeden string einen pointer auf den beginn der ueber-
	einstimmung enthaelt.
	der compiler sollte strukturzuweisung beherrschen.
*/

GLEICH maxchars(s1,n1,s2,n2)
register char	*s1,*s2;
register int	n2;
int		n1;
{
register int	i,j,k;	
register GLEICH	gleich; 

gleich.nchars	= 0;
gleich.s1	= s1;
gleich.s2	= s2;

for(i=0;i<n1;i++)
	for(j=n1-i;j>gleich.nchars;j--)
		for(k=0;k<=n2;k++)
			if((! strncmp(&s1[i],&s2[k],j)) && j>gleich.nchars )
				{
				gleich.nchars	= j;
				gleich.s1	= &s1[i];
				gleich.s2	= &s2[k];
				}

/*..........................................................debug.............*/

#if DEBUG
printf("maxchars:\n");
printf(" s1: %ld\n s2: %ld\n_s1 %ld\n_s2 %ld\n"
	,s1,s2,gleich.s1,gleich.s2);
printf(">>");
for (i=0;i<gleich.nchars;putchar(gleich.s1[i++]));printf("<<\n");
#endif


return gleich;
}




/*.................................................. simil_0() ...............*/

/*	bestimmt laenge und positionen des groessten gemeinsamen substrings
	ruft sich rekursiv mit den links und rechts der uebereinstimmung
	liegenden teilstrings auf 
	returnwert ist die anzahl der uebereinstimmungen * 2 ( *2 fuer die
	korrekte berechnung des prozentwertes )
*/

int simil_0(s1,n1,s2,n2)
	register char *s1,*s2;
	register int  n1,  n2;
{
register GLEICH	gl;
register int	left_1, left_2;
int		right_1, right_2, nmatch;

	gl = maxchars(s1,n1,s2,n2);
	left_1  = gl.s1 - s1;
	left_2  = gl.s2 - s2;
	right_1 = n1 - (left_1 + gl.nchars);
	right_2 = n2 - (left_2 + gl.nchars);

	nmatch = 2 * gl.nchars;
	if(gl.nchars)
		{
		if(left_1 && left_2 && (! (left_1 == 1 && left_2 == 1)))
			nmatch += simil_0(s1,left_1,s2,left_2);
		if(right_1 && right_2 && (! (right_1 == 1 && right_2 == 1)))
			nmatch += simil_0(&gl.s1[gl.nchars],right_1,
					  &gl.s2[gl.nchars],right_2);
		}
	return(nmatch);
}

/*.................................................. simil() .................*/

/*	stringlaengen berechnen und simil_0 mit dem kuerzeren string als
	erstem parameter aufrufen (spart in maxchars einige ueberfluessige 
	schleifen)
*/

int simil(s1,s2)
	register char	*s1,*s2;
{
register int n1,n2;

	n1=strlen(s1);
	n2=strlen(s2);
	return (int) (100 * 
		( (n1 < n2) 
			? simil_0(s1,n1,s2,n2) 
			: simil_0(s2,n2,s1,n1)
		) 
		/ (n1 + n2));
}

/*............................................... finito .....................*/

/*
der rest ist ein wenig sinnvolles demoprg
fuer die aufgabe waere der greifer weit besser geeignet

anwendung:  simil  prozentwert  wort [<infile] [>outfile]

man beachte dass bei eingabe der parameter in der gem-dia-box zeichen nach
grosssbuchstsben konvertiert werde
*/


#include	<stdio.h>
#include	<ctype.h>

#define		BUFFSIZE 256

main(argc,argv)
int	argc;
char    **argv;
{
char	inp_buff[BUFFSIZE];
char	work_buff[BUFFSIZE];
char	*inp;
int	level;
int	sim;
int	ist_delimiter();

	if(argc!=3)
		{
		fprintf(stderr,"\007anwendung: simil <prozent> wort [<infile] [>outfile]");
 		exit(-1);
		}

	level = atoi(argv[1]);
	if(level<1 || level>100)
		{
		fprintf(stderr,"\007sehr sinnig");
		exit(-1);
		}

	while(gets(inp_buff))
		{
		inp = inp_buff; 
		while(sgetword(work_buff,&inp,BUFFSIZE,ist_delimiter))
			{
			if((sim=simil(work_buff,argv[2])) >= level)
				printf("%4d  %s\n",sim, inp_buff);
			}
		}
}

/*............................................................................

ein pointer auf ist_delimiter() wird an sgetword uebergeben damit bestimmt 
sgetword welche zeichen keine gueltigen wortbestandteile sind

bleistiftsweise:		............................................*/

#ifndef isgerman
#define isgerman(c)(c=='é'||c=='Ñ'||c=='ô'||c=='î'||c=='ö'||c=='Å'||c=='û')
#endif

int ist_delimiter(c)
char	c;
{
return ( ! (isalnum(c) || isgerman(c)));
}
 


/*................................................ sgetword() ...............*/
/*
	kopiert das nÑchste wort oder maximal n-1 zeichen aus dem string 'str'
	in den puffer 'buf', hÑngt ein '\0' an

	was ein wort ist, haengt von is_delim() ab

	returnwert: anzahl der tatsÑchlich gelesenen zeichen

	achtung: es muû die adresse von des pointers 'str' Åbergeben werden,
	nicht die adresse des strings, str wird dabei verÑndert, sollte also
	eine kopie der stringadresse sein, falls diese noch benîtigt wird

	z.B.	char	*mist = "bla bla";
		char	*cp   = mist;
		char	buf[SIZE];
		int	delim_fun();
		while(sgetword(buf,&cp,SIZE,delim_fun))
			printf(buf);
	
*/


sgetword(s,str,n,is_delim)
int 		(*is_delim)();
register char	 *s;
register char	**str;
register int	  n;
{
register int c,i;

	while((*is_delim)(c = *s = *(*str)++))
		if(c == '\0')
			{
			*s = '\0';
			return 0;
			}
	for(i=1;i<n-1;i++)
		if ((*is_delim)(c = *++s = *(*str)++))
			{
			*s = '\0';
			if(c=='\0')
				(*str)--;
			return i;
			}
	*++s='\0';
return i;
}
