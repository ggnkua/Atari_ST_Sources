/* The Voice nr 2 */
/* Mini Turbo C Tutor */
/* Program pokazuje dzialanie zmienych typu extern */
/* Program moze byc skompilowany jako EXTERN.PRG i 
uruchomiony z DESK TOPU */

# include <stdio.h> /* standardowa bibloteka wyjscia wejscia */

 int a;			/* Jezeli zapiszesz int a; przed glownym programem */
				/* main() to oznacza to, ze zmienna a bedzie traktowana */
				/* jako zmienna glonalna (nie zmienia sie podczas */
				/* wykonywania procedur */
				/* mozna to takze zapisac jako extern int a; */
void proc()		/* procedura proc() */
{
a=1;
}

void proc1()	/* procedura proc1 () */
{
printf("\nA = %d",a);
}

main()			/* program glowny */
{				/* Nalezy o tym pamietac */
proc();			/* Wywolanie procedury proc()*/
proc1 ();		/* wywolanie procedura proc1()*/
return (0);		/* Zwracamy wartosc zero */
}				/* bye ! */

/* Zwroc uwage na to, ze wykonanie procedur nie zmienia wartosci
zmiennej a, w przeciwienstwie do zmienych typu auto, czyli
lokalnych */

