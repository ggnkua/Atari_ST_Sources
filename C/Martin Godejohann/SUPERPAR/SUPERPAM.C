 /* SUPERPAM.C
    Routinen fÅr Supervisormodus mit Parametern
    aufrufen. FÅr Turbo-C!
    V 2 - 04.05.90, 09.10.90
    Martin Godejohann
    Dernburgstr. 51
    1000 Berlin 19
 */

#include  <stdio.h>  /* mit printf..        */
#define DUMMY   0L

typedef struct { long   xb_magic;
                 long   xb_id;
                 long   xb_oldvec;
                 } XBRA;

/*  ParameterÅbergabe Åber Stack erzwingen!
    'superpar.o' dazulinken! Prototyp: */
extern long cdecl superpar(
                    long cdecl (*funktion)(),
                    long par1, long par2);


long cdecl peek(void *selfpointer, long par1,
                long dummy)
{   /*  in selfpointer steht die nach dem Aufruf
    durch 'superpar' die Adresse von peek */

    return ( *(long *)par1);
}

long cdecl xbra_test(void *selfpointer,
                      XBRA *startadr, long dummy)
{   /*  eigentlich wird (XBRA *) zurÅckgegeben,
    das kollidiert aber mit der Deklaration von
    (long superpar()) */

    if( (startadr - 1)->xb_magic != 0x58425241L)
        return 0L;       /* falsches xb_magic! */
    else
        return (long)(startadr - 1);
           /*  Auch dieses Casting nur wegen der 
           Deklaration von (long superpar()) */
}

void main()
{
    XBRA *ret_wert, *adresse;
    long dummy = DUMMY;
    int  zlr;
    char kennung[5];

    kennung[4] = '\0';     /* String-Ende-Byte */

    for( zlr = 5; zlr < 15; zlr++)
    {                     /* z. B. ab Vektor 5 */
        adresse = (XBRA *) superpar( peek,
                                 (long)(4 * zlr),
                                 DUMMY);
                /* Aus der Vektornummer die erste
                   Routinenadresse berechnen */
        printf("\n Vektor %4d :",zlr);

        do
        {
            ret_wert = (XBRA *)superpar(
                          xbra_test,
                          (long) adresse, DUMMY);
            if( ret_wert == 0)
            {
                printf(
                   "\n%8lx zeigt nicht auf XBRA",
                   (long) adresse);
            }
            else
            {
                *(long *)kennung = 
                                 ret_wert->xb_id;
                 /* long zu string konvertiert */

                printf(
                    "\nvor %8lx liegt Kennung%s",
                    (long)adresse, kennung);

                adresse = 
                      (XBRA *)adresse->xb_oldvec;
            }
        } while (ret_wert != 0);
    } /* Ende for-Schleife */
    printf("\n Bitte Return drÅcken");
    getchar();
}
