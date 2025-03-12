/*
 * Listing 1.5, Datei : cd.c
 * Programm           : CD - Žndern des aktuellen
 *                      Verzeichnisses
 * Modifikationsdatum : 15-Nov-89
 * Abh„ngigkeiten     : stdio.h, osbind.h, local.h,
 *                      atom.h
 */

#include <stdio.h>
#include <osbind.h>
#include "local.h"
#include "atom.h"

/*
 * Funktion     : cd
 *
 * Parameter    : ok = cd(argc, argv);
 *                BOOLEAN ok;
 *                short   argc;
 *                char    *argv[];
 *
 * Aufgabe      :
 *
 * Interpretierung der durch <argc> und <argv>
 * spezifizierten Parameterliste gem„ž den Fest-
 * legungen des Kommandos cd.
 */

BOOLEAN cd(argc, argv)
short argc;
char  *argv[];
{   if (argc == 2) {
        convupper(argv[1]);
        if (!acd(argv[1])) {
            fprintf(stderr,
                    "cd: can't find directory\n");
            return(FALSE);
        }
    }
    else {
        fprintf(stderr,
                "cd: need exactly one parameter\n");
        return(FALSE);
    }
    return(TRUE);
}

void main(argc, argv)
short argc;
char  *argv[];
{   if (!cd(argc, argv))
        exit(1);
    exit(0);
}
