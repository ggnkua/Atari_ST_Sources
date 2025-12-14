/* 		Kurzer Funktionstest fÅr LFED 
		Smart Systems 05/92				
		
			...oder wie man es machen sollte
		
		Aus Funktionen, die den CoProzessor nutzen, sollte man
		IMMER mit exit() zurÅckkehren, sofern man nicht ein
		FINKTIONSERGEBNIS erwartet ( siehe FPU_TST2.C und auch
		BGIDEMO.C ), um diese risikolos zu terminieren! */
					
#include <math.h>
#include <time.h>
#include <ext.h>
#include <stdio.h>
#include <stdlib.h>	/* zusÑtzlich wegen exit() */

void main(void)
{
	double	sinus, cosinus, tangens, lauf_var;
	float  startzeit, laufzeit, zeitdiff;
	unsigned int	zaehler;
	
	zaehler = 0;
	startzeit = clock();
	
	for (lauf_var = 0; lauf_var <= 2 * M_PI; lauf_var += 0.0001)
		{
		zaehler++;
		sincos(lauf_var, &sinus, &cosinus); /* dieses bewirkt fast doppelte
		       Laufzeit ! SINCOS ist in MATH.H keine FPU-Funktion */
		tangens = tan(lauf_var);
		};
			
	laufzeit = clock();
	zeitdiff = difftime(laufzeit, startzeit)/200;
	printf("Laufzeit mit FPU: %f Sekunden\n",zeitdiff);
	printf("fÅr %u DurchlÑufe\n\n", zaehler);
	printf("Inhalte der Variblen:\n\nCosinus: %.16f\nSinus: %.16f\nTangens: %.16f\n", cosinus, sinus, tangens); 
	getchar();	
	exit(0);	/* na also, es geht auch ohne Bus-Error */
};
