/* Testprogramm zur komplexe-Zahlen Bibliothek */

#include <complex.h>
#include <stdio.h>

int wahl;

void main(void)
	{
	int wahl;
	double exponent;
	komplex_kartes wk1,wk2,ek;
	komplex_polar  wp,ep;
	do	{
		do	{
			printf("Welche Operation ?\n\n");
			printf("1) Addition\n");
			printf("2) Subtraktion\n");
			printf("3) Multiplikation\n");
			printf("4) Division\n");
			printf("5) Potenzierung\n");
			printf("6) Ende\n\n");
			printf("Ihre Wahl: ");
			scanf("%d",&wahl);
			} while((wahl<1)||(wahl>6));
		
		if(wahl==6) break;
		
		printf("Realteil     1: ");
		scanf("%lf",&wk1.re);
		printf("Imagin„rteil 1: ");
		scanf("%lf",&wk1.im);
		if(wahl!=5)	{
					printf("Realteil     2: ");
					scanf("%lf",&wk2.re);
					printf("Imagin„rteil 2: ");
					scanf("%lf",&wk2.im);
					}
		else		{
					printf("Exponent: ");
					scanf("%lf",&exponent);
					}
		
		switch(wahl)
			{
			case 1:	printf("\nWert1 + Wert2 =\n");
					ek=addcx(wk1,wk2);
					ep=kartes_to_polar(ek);
					break;
			case 2:	printf("\nWert1 - Wert2 =\n");
					ek=subcx(wk1,wk2);
					ep=kartes_to_polar(ek);
					break;
			case 3:	printf("\nWert1 * Wert2 =\n");
					ek=mulcx(wk1,wk2);
					ep=kartes_to_polar(ek);
					break;
			case 4:	printf("\nWert1 / Wert2 =\n");
					ek=divcx(wk1,wk2);
					ep=kartes_to_polar(ek);
					break;
			case 5:	printf("\nWert1 ^ Exponent =\n");
					wp=kartes_to_polar(wk1);
					ep=potcx(wp,exponent);
					ek=polar_to_kartes(ep);
					break;
			}
		
		printf("Kartesisch: Re(x) = %.4lf   Im(x) = %.4lf i\n",ek.re,ek.im);
		printf("Polar:      r = %.4lf   phi = %.4lf\n\n",ep.r,ep.phi);
		} while (wahl!=6);
	}
	