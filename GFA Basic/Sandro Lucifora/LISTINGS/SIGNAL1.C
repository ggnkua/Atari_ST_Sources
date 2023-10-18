#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <setjmp.h>
#include <ext.h>

jmp_buf register_speicher;  /* Speicher f〉 16 Register */

void behandle_bus_error(int);

void main(void)
  {
  sigfunc_t   old_bus_error;      /* Pointer auf alte Fehlerroutine */

  int *a,rueck;
 
   old_bus_error = signal(SIGSEGV,(void (*)(int))behandle_bus_error);
 
  /* Turbo C liefert in der Version 2.03 leider immer
     NULL zur…k und nicht die alte Buserrorroutine */

  if((rueck = setjmp(register_speicher)) != 0)
    {
    printf("\nPuh, das ging noch 'mal gut!\n"
           "R…kgabewert von longjmp(): %d\n",rueck);
    getch();
    signal(SIGSEGV,(void (*)(int))old_bus_error);
    
    /* Alte Routine zur…k */
    exit(rueck);   /* und mit Fehlercode raus */
    }
  a = NULL;  /* Buserror vorbereiten: Nullpointer */
  *a=10;     /* ... und auf Bombensuche */
  exit(0);   /* wird nie erreicht */
  }
void behandle_bus_error(int sig)

/* Diese Routine hatte signal() statt der 
   Bombenwarnung eingetragen  'sig' wird als 
   Signalnummer von 'signal()' zur…kgegeben */

  {
  longjmp(register_speicher,sig); 
  /* Umbesetzung aller Register -> Sprung nach setjmp in main */
  }

