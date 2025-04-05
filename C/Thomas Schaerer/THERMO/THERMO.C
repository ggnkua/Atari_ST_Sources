/**********************************************************/
/*	File:	thermo.c		geschrieben in TURBO-C-2.0 (ATARI)  */
/*				========		von Thomas Schaerer  CH-Effretikon  */
/**********************************************************/

#include <stdlib.h> 			/* Nur notwendig wegen 'exit(0);' in TURBO-C */ 
#include <stdio.h> 
#include <string.h> 
#include <math.h>

#define BELL 7

/* Prototypen */
void err_out(int err);
void my_address(void);
void help(void);



void main(int argc, char **argv)
{
	char *input[10];
	int arg_count;
	double inp, t_abs = 273.16;

	arg_count = argc;

	while (arg_count--)											/* Einlesen der Parameter 		*/
		input[arg_count] = *argv++;  					/* Umsetzung in Feldvariablen */


	if ((argc==2) && (strcmp(input[0],"?")==0))
		my_address();

	else if (argc<3 || argc>=4)							/* Richtige Anzahl Argumente  */
		err_out(1);	 

	else if (argc==3) 
	{

		inp = atof(input[1]);										/* String-Float-Transform.  */

		if(strcmp(strlwr(input[0]),"c")==0)			/* Eingabe in Celsius 	    */
		{
			if(inp>=-t_abs)
			{
				printf(" %7.2lf  Grad Celsius   ( Eingabe)\n",inp);
				printf(" %7.2lf  Grad Kelvin\n",(inp+t_abs));
				printf(" %7.2lf  Grad Fahrenheit\n",((inp*9/5)+32));
			}
			else
				err_out(3);
		}

		else if(strcmp(strlwr(input[0]),"k")==0)	 /* Eingabe in Kelvin  	  */
		{
			if(inp>=0)
			{
				printf(" %7.2lf  Grad Kelvin     (Eingabe)\n",inp);
				printf(" %7.2lf  Grad Celsius\n",(inp-t_abs));
				printf(" %7.2lf  Grad Fahrenheit\n",((inp-t_abs)*9/5)+32);
			}
			else
				err_out(3);
		}

		else if(strcmp(strlwr(input[0]),"f")==0)	 /* Eingabe in Fahrenheit */
		{
			if (inp>=32+(-t_abs*9/5))
			{
				printf(" %7.2lf  Grad Fahrenheit  (Eingabe)\n",inp);
				printf(" %7.2lf  Grad Celsius\n",((inp-32)*5/9));
				printf(" %7.2lf  Grad Kelvin\n",(((inp-32)*5/9)+t_abs));
			}
			else
				err_out(3);
		}

		else
			err_out(2);
	}

	exit(0);					/* Ohne 'exit' meckert TURBO-C, muss immer sein. 	*/
}


/* -------------------------------------------------------------------- */
/* Sub-Funktionen */

void err_out(int err)				/* Fehlerbearbeitung */
{
	putchar(BELL);

	switch(err)
	{
		case 1:
			puts(" Fehler:  Zuwenig oder zuviel Argumente!");
			help();
			break;
		case 2:
			puts(" Fehler:  2. Parameter muss c, k, oder f sein!");
			help();
			break;
		case 3:
			puts(" Fehler:  Sie unterschreiten Null Kelvin. Unmoeglich!!!");
			break;
	}
}


void help(void)
{
	puts("");
	puts(" Korrektes Eingeben:");
	puts("        thermo wert einheit");
	puts("  z.B.  thermo -270.4 c");
	puts(" c=Celsius , k=Kelvin , f=Fahrenheit");
  puts("");
	puts(" ? (1.Param.)  =  Programmversion / Autor");
	puts(""); 
}


void my_address(void)
{
	puts(" Version:  thermo 1.0 ");
  puts(" Datum:    April 1996 ");
	puts(" Autor:    Thomas Schaerer  CH-Effretikon  Schweiz ");
	puts(" E-Mail:   schaerer@isi.ee.ethz.ch ");
	puts(" Status:   thermo  ist mit C-Source public-domain ");
	puts(" Info:     readme.ts lesen (ist nicht viel) ");
}

/*  >>>> ENDE <<<< */

