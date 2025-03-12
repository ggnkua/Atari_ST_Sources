/*
 * Listing 1.7, Datei : date.c
 * Programm           : DATE - Auslesen/Setzen des
 *                      Systemdatums
 * Modifikationsdatum : 15-Nov-89
 * Abh„ngigkeiten     : stdio.h, ctype.h, string.h,
 *                      local.h, atom.h
 */

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include "local.h"
#include "atom.h"

/*
 * Funktion     : date
 *
 * Parameter    : ok = date(argc, argv);
 *                BOOLEAN ok;
 *                short   argc;
 *                char    *argv[];
 *
 * Aufgabe      :
 *
 * Interpretierung der durch <argc> und <argv>
 * spezifizierten Parameterliste gem„ž den Fest-
 * legungen des Kommandos date.
 */

BOOLEAN date(argc, argv)
short argc;
char  *argv[];
{   short day,
          month,
          year;

    if (argc <= 2) {
        if (argc == 2) {
            if (strlen(argv[1]) == 8 &&
                isdigit(argv[1][0]) &&
                isdigit(argv[1][1]) &&
                !isdigit(argv[1][2]) &&
                isdigit(argv[1][3]) &&
                isdigit(argv[1][4]) &&
                !isdigit(argv[1][5]) &&
                isdigit(argv[1][6]) &&
                isdigit(argv[1][7])) {
                day = 10 * todigit(argv[1][0]) +
                      todigit(argv[1][1]);
                month = 10 * todigit(argv[1][3]) +
                      todigit(argv[1][4]);
                year = 1900 + (10 *
                      todigit(argv[1][6]) +
                      todigit(argv[1][7]));
                if (!putdate(day, month, year)) {
                    fprintf(stderr,
                   "date: argument is not a date\n");
                    return(FALSE);;
                }
            }
            else {
                fprintf(stderr,
                   "SYNOPSIS: date [ ddSmmSyy ]\n");
                return(FALSE);
            }
        }
        getdate(&day, &month, &year);
        printf("Date: %02d-%02d-%02d\n", day, month,
               year - 1900);
    }
    else {
        fprintf(stderr,
           "date: need at most one parameter\n");
        return(FALSE);
    }
    return(TRUE);
}

void main(argc, argv)
short argc;
char  *argv[];
{   if (!date(argc, argv))
        exit(1);
    exit(0);
}
