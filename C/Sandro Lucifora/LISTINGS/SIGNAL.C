#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <setjmp.h>
#include <ext.h>

#define BUSERROR 1
#define ADRERROR 2
#define ABBRUCH  3
#define TRUE     1

jmp_buf register_speicher; /* Speicher fÅr 16 Register */
sigfunc_t old[3];          /* Feld mit Pointern auf alte
                              Fehlerroutinen */
/* Prototypen */

void init_signal(void);
void exit_signal(void);
void init_errorcheck(void);
void behandle_signal(int);

int wahl;

void main(void)        /* 3 Bomben legen */
  {
  int *a=NULL,*b=0x3;  /* Bus- und Adress-Error vorbereiten */

  init_signal();       /* Signalhandling initialisieren */

  wahl = BUSERROR;     /* Fangen wir mal dem Bus-Error an */
  init_errorcheck();
  if(wahl==BUSERROR)
    *a=10;             /* Bus-Error gewollt - na bitte! */
  else if(wahl==ADRERROR)
    *b=10;             /* Adress-Error gewollt - aber gern! */
  else
    {
    printf("\n Zum Abbrechen der"
           " Endlosschleife Control D drÅcken!");
    while(TRUE) ;     /* und die gefÅrchtete Endlosschleife */
    }

  exit_signal(); /* Programm definiert verlassen */

  exit(0);       /* hier wÅrde man sonst nie hinkommen */
  }

void behandle_signal(int sig)
  {
  longjmp(register_speicher,sig); 
  /* Umbesetzung aller Register 
     ->Sprung nach setjmp in main */
  }

void init_errorcheck(void)
  {
  int i,rueck,weiter;
  
  if((rueck = setjmp(register_speicher)) != 0) 
  /* RÅcksprungadresse und Register merken */
    {
    switch(rueck)
      {
      case SIGSEGV:       

      /* Bus-Error behandeln */

        printf("\nBus-Error ist aufgetreten!\n"
               "RÅckgabewert von longjmp(): %d\n",rueck);
        printf("Weiter ?");
        wahl = ADRERROR;
        weiter=getch();
        break;
 
      case SIGADR:
 
      /* Adress-Error behandeln */

        printf("\nAdress-Error ist aufgetreten!\n"
               "RÅckgabewert von longjmp(): %d\n",rueck);
        printf("Weiter ?");
        weiter=getch();
        wahl = ABBRUCH;
        break;
      case SIGINT:

        printf("\nControl D wurde gedrÅckt -"
        	   "jetzt nur keine TastendrÅcke!\n"
               "RÅckgabewert von longjmp(): %d\n",rueck);

/* getch(); wird erst mîglich sein, wenn der 
 Fehler in Turbo C  behoben sein wird: statt 
 dessen einfache Schleife und raus */

        for(i=0;i<20000;i++) ;
        weiter = 'n';
        break;
      }
    if(weiter=='j' || weiter=='J')
      {
      init_errorcheck(); 
/* Alle Register neu retten, da sie durch 
 'longjmp()' zerstîrt werden kînnten */
      return;
      }
    exit_signal();
    exit(rueck);
    }
  }

void init_signal(void)
  {
/* Signalverwaltung fÅr SIGINT, SIGSEGV
 und SIGADR einhÑngen */

  old[0] = signal(SIGINT, (void (*)(int))behandle_signal);
  old[1] = signal(SIGSEGV,(void (*)(int))behandle_signal);
  old[2] = signal(SIGADR, (void (*)(int))behandle_signal);
  }

void exit_signal(void)
  {

/* Signalverwaltung fÅr SIGINT, SIGSEGV 
und SIGADR wieder aushÑngen */

  signal(SIGINT, (void (*)(int))old[0]);
  signal(SIGSEGV,(void (*)(int))old[1]);
  signal(SIGADR, (void (*)(int))old[2]);
  }
