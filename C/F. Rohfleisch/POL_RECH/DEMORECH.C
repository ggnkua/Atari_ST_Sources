/*************************************************************************
                          DEMONSTRATIONSPROGRAMM
                    fuer den Formelinterpreter POL_RECH 1.0      
  ----------------------------------------------------------------------  
  Autor:    F. Rohfleisch, 7140 Ludwigsburg              im Oktober 1989
  Compiler: Turbo C 1.1 fuer den Atari ST
*************************************************************************/    

#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <float.h>
#include <time.h>
#include <tos.h>

#include <pol_rech.h>


/*************************************************************************
                             FUNKTIONSPROTOTYPEN
*************************************************************************/

int             main (void);
int             input_string(char *, int);
extern double   pol_rech (char *, double, double, int *);
extern int      translate_formel(char *, char *);


/*************************************************************************
                             FEHLERMELDUNGEN
*************************************************************************/
char  *Fehlertext[] = 
		{
		" ",
		"Klammerfehler",
		"Ergebnis geht gegen pos. Unendlich",
		"Ergebnis geht gegen neg. Unendlich",
		"Wurzel aus negativer Zahl",
		"Potenz von negativer Basis",
		"Logarithmus von negativer Zahl",
		" ",
		" ",
		"Division durch Null",
		"Stack voll",
		"Stack leer",
		"Unbekannte Funktion",
		"Unbekannter Operator",
		"Unbekannte Variable",
		"Notationsfehler",
		"Zuviele Klammerebenen",
		"Puffer-öberlauf"
		};
		

/*
**************************************************************************
* Aufruf:   input_string(char *, int)	
* Eingabe:  char *string;  Zeiger auf eingelesenen String.
*           int maxlen;    Maximale Stringlaenge, einschl. Null-Byte(!);
* Ausgabe:  int;           Laenge des eingelesenen Strings.
*                          0: leerer String.
* Beschreibung: liest String von Standardkanal ein.
* History:  01.10.1989
**************************************************************************
*/ 
input_string (string, maxlen)
char *string;
int maxlen;
   {
   int zeichen;
   int i;
 
   for (i=0; i < (maxlen-1) && (zeichen = (int)Cconin()) != 13; )
      {
      if (zeichen == 8)
         {
         if ( i>0 )
            {
            i--;
            putchar(32);
            putchar (8);
            }
         }
      else if (zeichen >= 32)
         {
         if (islower(zeichen))
         	{
         	zeichen += 'A' - 'a';
         	}
         string[i++] = zeichen;
         }
      }
   string[i] = '\0';
   putchar ('\n');
   return (i);
   }

  
/**************************************************************************
                                 M A I N
**************************************************************************/
main(void)
   {
   char       formel[FUNK_LANG_MAX];
   char       polnot[FUNK_LANG_MAX];
   double     z[500];
   double     dx, x;
   char       schritte[10];
   char       min[11], max[11];
   double     a, b;
   int        err[500];
   int        s, i, j, c;
   long       time1, time2, time3;
   
   printf("\033f\033E");
	printf("      *******************************************************************\n");
	printf("      **                \033pDemonstration von Pol_Rech V1.0\033q                **\n");
	printf("      ** ------------------------------------------------------------- **\n");
	printf("      **  Autor    :  F.Rohfleisch, 7140 Ludwigsburg                   **\n");  
 	printf("      ** --------------------------------------------------------------**\n");
 	printf("      **  Compiler :  Turbo C 1.1 fÅr den Atari ST                     **\n");
 	printf("      **  Datum    :  29.10.1989                                       **\n");
   printf("      *******************************************************************\n");
   printf("\n\n\033e      Bitte Formel eingeben    : "); 
   input_string(formel,FUNK_LANG_MAX);
   printf("      untere Intervallgrenze   : "); 
   input_string(min,11);
   printf("      obere  Intervallgrenze   : "); 
   input_string(max,11);
   printf("      Anzahl Schritte (<= 500) : "); 
   input_string(schritte,11);
   s = atoi(schritte);
   a = atof(min);
   b = atof(max);  
   time1 = clock();
   err[0] = translate_formel(formel,polnot);
   time2 = clock();
   if (err[0] == 0)
   	{
	   printf("\n\033f      Formel in poln. Not.     : %s\n",polnot); 
	   dx = (b - a) / (s-1);
	   for (x = a, i = 0; i < s; i++, x += dx)
	      {          
	      err[i] = 0;
	      z[i] = pol_rech(polnot,x,0.0,&(err[i]));
	      }          
	   time3 = clock();
	   printf("\n      benoetigte Uebersetzungszeit:\033e %6.3f Sekunden",(time2-time1)/200.0);
	   printf("\n      benoetigte Rechenzeit       :\033e %6.3f Sekunden\n",(time3-time2)/200.0);
		printf("\n      Ausgabe der Ergebnisse (j/n)? ");
		while ((c = (int)Cconin()) != 'j' && c != 'J' && c != 'n' && c != 'N')
			{
			;
			}
		if (c == 'j' || c == 'J')
			{
			printf("\033E\033H\033f");
			i = 0;
			while (i < s)
				{
				for (j = 0; j < 24 && i < s; j++)
					{
					printf("     %4d.)  f(%10.6f) = %15.8lf   %s\n",i+1,a,z[i],Fehlertext[err[i]]);
					i++;
				   a += dx;
					}
				printf("      Weiter mit beliebiger Taste ..."); 
				Cconin();
				printf("\033M");
				}  
			}
		printf("\033M");
			   }
	else
		{
		printf("\n\n               \033pAchtung!!!\033q  %s\n\n",Fehlertext[err[0]]);
		}
	printf("      QUIT mit beliebiger Taste ..."); 
	Cconin();
	printf("\033e");
	return (0);	
   }
   
