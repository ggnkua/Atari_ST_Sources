/* The Voice nr 2 by Team From The East
   Turbo C Tutorial
   instrukcja While */
#include <stdio.h>			/* zawsze dolacz standardowa bibloteke*/

main()						/* tu zaczynamy */
{
int lower,upper,step;		/* zmienne typu calkowitego */
							/* lower
							   upper
							   step */
float fahr,celsius;			/* zmienne typu zmiennoprzecinkowego,
							   czyli z wartoscia po przecinku */ 


lower=0;		
upper=300;
step=20;

fahr=lower;
while(fahr<=upper)			/* wykonuje program w petli */
							/* gdy warunek w nawiasie jest prawdziwy */
							/* Jezeli chcesz uzyc operacji 'rozny od' */
							/* musisz napisac !=, a nie <> */
	{						/* tu poczatek petli */
	celsius=(5.0/9.0)*(fahr-32.0);
	printf("Stopnie Celsjusza= %6.1f, Farenheita= %4.0f \n",celsius,fahr);
							/*  ^ wartosc 6.1 przed f oznacza zarezerwuj
							      co najmniej 6 cyfr przed przecinkiem i
							      1 po przecinku w ciagu znakow */
	fahr=fahr+step;
	}						/* koniec petli */
return(0);					
}							/* koniec */

	