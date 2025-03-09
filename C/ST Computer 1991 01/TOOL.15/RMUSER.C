/*
 * Listing 3.9, Datei : rmuser.c
 * Programm           : RMUSER - L”schen eines
 *                      Benutzerdatensatzes
 * Modifikationsdatum : 27-Dez-90
 * Abh„ngigkeiten     : stdio.h, local.h, usermain.h
 */

#include <stdio.h>
#include "local.h"
#include "usermain.h"

/*
 * Funktion     : rmuser
 *
 * Parameter    : ok = rmuser(argc, argv);
 *                BOOLEAN ok;
 *                short   argc;
 *                char    *argv[];
 *
 * Aufgabe      :
 *
 * Interpretation der durch <argc> und <argv>
 * spezifizierten Parameterliste gem„ž den Fest-
 * legungen des Kommandos RMUSER.
 */

BOOLEAN rmuser(argc, argv)
short argc;
char  *argv[];
{   short i;

    if (argc == 2) {
        load_user_data();
        delete_user(argv[1]);
        save_user_data();
    }
    else {
        fprintf(stderr,
           "SYNOPSIS: rmuser user\n");
        return(FALSE);
    }
    return(TRUE);
}

void main(argc, argv)
short argc;
char  *argv[];
{   if (!rmuser(argc, argv))
        exit(1);
    exit(0);
}

