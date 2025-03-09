#ifndef drivetypes
#define drivetypes
typedef struct
{
  char  *ibuf;  /* Zeiger auf den buffer */
  int   size;    /* groesse des Buffers   */
  int   nw;    /* naechste Leseposition    */
  int   nl;    /* naechste Schreibposition */
  int   blow;    /* untere Wassermarke       */
  int   bhig;    /* obere Wassermarke        */
} io_rec;
#endif

#define MCTR "MCTR"