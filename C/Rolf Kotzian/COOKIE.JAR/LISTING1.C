/*
    So kînnte ein Programm ÅberprÅfen, ob es
    bereits installiert ist; auf diese Weise
    lassen sich Mehrfach-Installationen leicht
    verhindern...

    entwickelt mit Turbo-C (Version 2.0)
*/


#include <stdio.h>

/*  Hier sollte die Header-Datei mit den
    Prototoypen des Cookie-Moduls einge-
    lesen werden.
*/


void main (void)
{
    COOKIE test;
    long wert = 0;

    if (!get_cookie ("XXXX", &wert))
    {
        /*  wir sind noch nicht da !  */
        create_cookie (&test, "XXXX", 0L);
        new_cookie (&test);

        /*  hier geht's weiter...  */
    }

    else
    {
        /*  sind bereits im System  */
        puts ("Hurra - Cookie gefunden !");
        printf ("Cookie-Wert: %lx", wert);
    }
}    


/*  Listing 1  */

