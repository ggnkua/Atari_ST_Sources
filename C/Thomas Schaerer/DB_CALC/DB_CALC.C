/**********************************************************/
/*	File:	db_calc.c		geschrieben in TURBO-C-2.0 (ATARI)  */
/*				=========		von Thomas Schaerer  CH-Effretikon  */
/**********************************************************/

#include <stdlib.h> 			/* Nur notwendig wegen 'exit(0);' in TURBO-C */ 
#include <stdio.h> 
#include <string.h> 
#include <math.h>

#define BELL 7

/* Prototypen */
void err_out(int err);
void quot_out (double out_val);
void my_address(void);


void main(int argc, char **argv)
{
	char *input[10], *u_quot, *p_quot, *u_db, *p_db;
	int arg_count;
	double inp_val, out_val;

	u_quot = "  (Spannungs- oder Stromfaktor)";
	p_quot = "  (Leistungsfaktor)";
	u_db =	 "  (Spannungs- oder Strom-dB-Mass)";
	p_db =	 "  (Leistungs-dB-Mass)";

	arg_count = argc;

	while (arg_count--)											/* Einlesen der Parameter 		*/
		input[arg_count] = *argv++;  					/* Umsetzung in Feldvariablen */


	if ((argc==2) && (strcmp(input[0],"?")==0))
			my_address();

	else if (argc==2)														      /* Quotient -> dB	 */
	{ 
		inp_val = atof(input[0]);
		if (inp_val>0)
		{
			printf(" %7.2lf  dB",(20*log10(inp_val)));		/* Spannung, Strom */
			puts(u_db);
			printf(" %7.2lf  dB",(10*log10(inp_val)));		/* Leistung				 */
			puts(p_db);
		}
		else
		  err_out(1);
	}
																										/* dB -> Quotient */
	else if ((argc==3) && (strcmp(strlwr(input[0]),"db")==0))	
	{	
		inp_val = atof(input[1]);
		out_val = pow(10.0,(inp_val/20.0));							/* Spannung, Strom */
		quot_out(out_val);
		puts(u_quot);
		out_val = pow(10.0,(inp_val/10.0));							/* Leistung				 */
		quot_out(out_val);
		puts(p_quot);

	} 
																					/* Test der Eingabe von 'db' */
	else if (argc==3 && (strcmp(strlwr(input[0]),"db")!=0))
		err_out(2);

	else if (argc<2 || argc>3)
		err_out(3);

	exit(0);					/* Ohne 'exit' meckert TURBO-C, muss immer sein. 	*/
}

/* -------------------------------------------------------------------- */
/* Sub-Funktionen */

void quot_out (double out_val)	/* Umsetzung in Groessenordnungssymbole */
{
		if (out_val >= 1000000000000.0)
			printf (" %9.4lf T",out_val/1000000000000.0);
		else if (out_val >= 1000000000.0)
			printf (" %9.4lf G",out_val/1000000000.0);
		else if (out_val >= 1000000.0)
			printf (" %9.4lf M",out_val/1000000.0);
		else if (out_val >= 1000.0)
			printf (" %9.4lf K",out_val/1000.0);
		else if (out_val >= 1.0)
			printf (" %9.4lf  ",out_val); 
		else if (out_val >= 0.001)
			printf (" %9.4lf  ",out_val);
		else if (out_val >= 0.000001)
			printf (" %9.4lf m",out_val*1000.0);
		else if (out_val >= 0.000000001)
			printf (" %9.4lf u",out_val*1000000.0);
		else if (out_val >= 0.000000000001)
			printf (" %9.4lf n",out_val*1000000000.0);
		else 
			printf (" %9.4lf p",out_val*1000000000000.0);
}



void err_out(int err)				/* Fehlerbearbeitung */
{
	putchar(BELL);

	switch(err)
	{
		case 1:
			puts(" Fehler:  Wert muss groesser als Null sein!");
			break;
		case 2:
			puts(" Fehler:  Beim 2. Parameter muss db, dB oder DB stehen!");
			break;
		case 3:
			puts(" Fehler:  Kein Argument oder eines zuviel!");
			break;
	}
                                                              
	puts("");
	puts(" Korrektes Eingeben:");
	puts("        Quotient zu Dezibel:  db_calc wert");
	puts("        Dezibel zu Quotient:  db_calc wert db");
  puts("");
	puts(" ? (1.Param.)  =  Programmversion / Autor");
	puts(""); 
}


void my_address(void)
{
	puts(" Version:  db_calc 1.0 ");
  puts(" Datum:    April 1996 ");
	puts(" Autor:    Thomas Schaerer  CH-Effretikon  Schweiz ");
	puts(" E-Mail:   schaerer@isi.ee.ethz.ch ");
	puts(" Status:   db_calc  ist mit C-Source public-domain ");
	puts(" Info:     readme.ts lesen (ist nicht viel) ");
}

/*  >>>> ENDE <<<< */