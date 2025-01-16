/* The Voice nr 2  by Team From The East */
/* Turbo mini C Tutor */
/* Program pokazuje dzialanie zmienej calkowitej typu auto */
/* czyli zmienej lokalnej */

#include <stdio.h> /* standard i/o */

void proc() /* tworze procedure */
{			/* zaczynamy */
int a;		/* deklaruj zmiena typu auto */
			/* zamiast int a; mozemy napisac auto int a; */
			/* to znaczy dokladnie to samo */
			/* roznica pomiedzy deklarowaniem zmienej auto i */
			/* extern polega na umieszczenu instrukcji int a; */
		    /* to w programie glownym main(), lub poza nim */
a=2;
printf ("\n Zmienna w procedurze wynosi %d ",a); /* ile wynosi a */
} /* koniec procedury */

main ()     /* program glowmny */
{			/* poczatek */
int a;		/* deklaruj a */
a=1;		/* tu a=1 */
printf ("\n Zmienna typu auto wynosi %d (main)",a); /* ile wynosi a */
proc();		/* wywolaj procedure */
			/* procedura deklaruje wlasne a jednoczesnie nie */
			/* naruszajac a z glownego programu */

printf ("\n Teraz zmienna wynosi %d (main), program przywrocil stara wartosc.",a);
			/* Teraz zmiena a ma znowu poprzednia wartosc (1) */
return(0);	/* oddaj zero */

}			/* bye, bye .... */
