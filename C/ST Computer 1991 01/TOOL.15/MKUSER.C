/*
 * Listing 3.8, Datei : mkuser.c
 * Programm           : MKUSER - Erzeugen eines
 *                      Benutzerdatensatzes
 * Modifikationsdatum : 27-Dez-90
 * Abh„ngigkeiten     : stdio.h, local.h, usermain.h
 */

#include <stdio.h>
#include "local.h"
#include "usermain.h"

/*
 * Funktion     : DEFAULT_SHELL
 *
 * Aufgabe      :
 *
 * Festlegung der Standardshell.
 */

#define DEFAULT_SHELL "\\BIN\\SSH.TTP"

/*
 * Funktion     : mkuser
 *
 * Parameter    : ok = mkuser(argc, argv);
 *                BOOLEAN ok;
 *                short   argc;
 *                char    *argv[];
 *
 * Aufgabe      :
 *
 * Interpretation der durch <argc> und <argv>
 * spezifizierten Parameterliste gem„ž den Fest-
 * legungen des Kommandos MKUSER.
 */

BOOLEAN mkuser(argc, argv)
short argc;
char  *argv[];
{   short i;

    if (argc == 2 || argc == 3) {
        load_user_data();
        if (argc == 2)
            insert_replace_user(argv[1], "ohne",
                                DEFAULT_SHELL);
        else
            insert_replace_user(argv[1], "ohne",
                                argv[2]);
        save_user_data();
    }
    else {
        fprintf(stderr,
           "SYNOPSIS: mkuser user [ shell ]\n");
        return(FALSE);
    }
    return(TRUE);
}

void main(argc, argv)
short argc;
char  *argv[];
{   if (!mkuser(argc, argv))
        exit(1);
    exit(0);
}

