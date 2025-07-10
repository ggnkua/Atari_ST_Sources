/******************************************************************************/
/* Datei: example.c                                                           */
/* Beispielprogramm zum Formelinterpreter formel.c                            */
/* Damit dieses Programm laufen kann, sollte formel.c compiliert und zu       */
/* example.o gelinkt werden. Fuer TURBOC (ST & AT) existieren bereits Projekte*/
/* ---------------------------------------------------------------------------*/
/*    Vorgehensweise zur Berechnung einer Formel                              */
/* 1. fpars() mit Formelstring als Argument aufrufen.                         */
/*    Returnwert von 1 bedeutet kein Syntaxfehler in der Formel               */
/* 2. fcalc() mit Variablenwerten X und Y aufrufen.                           */
/*    Returnwert ist das Ergebnis der Formel.                                 */
/*                                                                            */
/*                   ODER                                                     */
/*                                                                            */
/* 1. fpc() mit Formelstring und den Variablenwerten aufrufen.                */
/*    Returnwert ist wieder das Ergebnis der Formel oder HUGE_VAL bei Fehler. */
/*                                                                            */
/* Moechte man die gleiche Formel mit verschiedenen Variablenwerten von       */
/* X oder Y berechnen lassen, so muss diese nicht jedesmal neu mit fpars()    */
/* uebersetzt werden. Einfach fcalc() mit den anderen X-, Y-Werten aufrufen.  */
/******************************************************************************/
#include <stdio.h>
#include <string.h>

extern int    fpars(char *);
extern double fcalc(double, double);
extern double fpc(char *, double, double);

void main(void)
{
  double  x, y;
  char    formel[80];

  for(;;)
  {
    printf("Geben Sie eine Formel oder ENDE ein: ");
    gets(formel);
    if(!strcmp(strlwr(formel), "ende")) break;
    if(strrchr(formel, 'x') != NULL)
    {
      printf("Geben Sie den Wert von X ein: ");
      scanf("%lf", &x);
      fflush(stdin);
    }

    if(strrchr(formel, 'y') != NULL)
    {
      printf("Geben Sie den Wert von Y ein: ");
      scanf("%lf", &y);
      fflush(stdin);
    }

    if(fpars(formel) == 1)
      printf("Das Ergebnis lautet: %lf\n\n", fcalc(x, y));
    else
      puts("Die Syntax der Formel ist fehlerhaft!\n");
  }
}
