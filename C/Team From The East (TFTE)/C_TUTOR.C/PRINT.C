/* (c) The Voice nr 2 */
/* Turbo C MINI TUTOR */
/* Program ten pokazuje uzycie instrukcji Printf */
/* oraz opisuje wszystkie potrzebne operacje aby */
/* mozna bylo wyswietlac zmienne */

# include <stdio.h>   /* Dolaczamy standardowa bibloteke wejscia/wyjscia */

main()                /* Tu zaczyna sie program glowny */
{					  /* Otwieramy program main() */
int a;				  /* Tu deklaruje zmienna a, pamietaj o sredniku */
					  /* po kazdej instrukcji */

a = 1;				  /* a=1 */

printf ("\n tu mozesz umieszczac tekst\n");  /* teraz wyswietlamy tekst */
											 /* umieszczony pomiedzy " */
											 /* \n oznacza Return   */
											 
printf ("\n W ten sposob mozesz wyswietlic zmiena a \n"); /* jak wyzej */

printf ("\n Teraz a= %d\n",a); /* w miejsce %d zoszanie umieszczona 1 */
							   /* zmienna po przecinku, tu: a */

/* w miejsce %d mozna takze wstawiac nastepujace znaki
	%o - dla liczb osemkowych
	%x - dla liczb szesnastkowych
	%f - dla liczb zmiennoprzecinkowych/zmiemmopozycyjnych (12.474)
	%c - dla znaku
	%s - dla ciagu znakow */
	   
return (0);				       /* zwracamy wartosc zero funkcji main */
							   /* Tak konczy sie program */
}				/* tu zamykamy program glowny (main()) */


