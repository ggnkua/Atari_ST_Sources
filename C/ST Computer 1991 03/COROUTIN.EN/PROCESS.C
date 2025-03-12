/*                                                                         *\
                  process.c - Modul stellt die Funktionen 
                          NEWPROCESS und TRANSFER 
                                  bereit 
\*                                                                         */


#define ENSMEM          -39     /* TOS-Fehlercode fÅr Speicherplatzmangel  */
#define MIN_STACKSIZE   256     /* minimale Grîûe des Stacks (in Bytes)    */



                                /* Wandelt die 'func' in eine Coroutine um */
                                 
NEWPROCESS (func, loc_stack, stacksize, cor_var)
long func;                      /* Adresse der Funktion                    */
long loc_stack;                 /* Zeiger auf den lokalen Coroutinen-Stack */
int  stacksize;                 /* Grîûe des lokalen Stacks in Bytes       */
long *cor_var;                  /* Zeiger auf die Coroutinen-Variable      */
{
                    /* hîchste gerade Adresse des lokalen Stacks bestimmen */
   register long *stackadr = (long *)((loc_stack + (long)stacksize) & -2L),
                 *coradr   = cor_var;

   if (stacksize<MIN_STACKSIZE) /* lokaler Stack zu klein?                 */
      exit (ENSMEM);

   asm
   {                                   /* Einsprung-Adresse der Coroutine  */
      move.l   func(A6), -(stackadr)   /* auf den lokalen Stack            */
      move.l   A6, -(stackadr)         /* link A6, #0 auf lokalem Stack    */
      movea.l  stackadr, A6            /* simulieren                       */
      movem.l  D0-A6, -(stackadr)      /* Register auf lokalen Stack       */
      movea.l  60(stackadr), A6        /* alten Wert von A6 holen          */
      move.l   stackadr, (coradr)      /* Wert des lokalen Stackpointers   */
   }                                   /* in die Coroutinen-Variable       */
}


                                /* Åbergibt 'to' die Kontrolle, aktueller  */
                                /* Kontext wird in 'from' gemerkt          */
TRANSFER (from, to)
long from,                      /* Adresse der Coroutinen-Variablen, in    */
     to;                        /* die der aktuelle SP geschrieben bzw.    */
{                               /* aus der der neue SP gelesen wird        */
   asm
   {                            /* Register der aktuellen Coroutine auf    */
      movem.l  D0-A6, -(A7)     /* ihren Stack retten                      */
      movea.l  to(A6), A0       /* Wert des neuen SP lesen, damit from und */
      movea.l  (A0), A0         /* to identisch sein kînnen, ...           */
      movea.l  from(A6), A1     /* dann den aktuellen SP in der Coroutinen-*/
      move.l   A7, (A1)         /* Variablen merken und ...                */
      movea.l  A0, A7           /* den neuen SP zum Aktuellen machen       */
      movem.l  (A7)+, D0-A6     /* Register der nun aktuellen Coroutine    */
   }                            /* restaurieren                            */
}


