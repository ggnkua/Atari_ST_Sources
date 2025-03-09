/*
 * Listing 1.8, Datei : time.c
 * Programm           : TIME - Auslesen/Setzen der
 *                      Systemzeit
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
 * Funktion     : time
 *
 * Parameter    : ok = time(argc, argv);
 *                BOOLEAN ok;
 *                short   argc;
 *                char    *argv[];
 *
 * Aufgabe      :
 *
 * Interpretierung der durch <argc> und <argv>
 * spezifizierten Parameterliste gem„ž den Fest-
 * legungen des Kommandos time.
 */

BOOLEAN time(argc, argv)
short argc;
char  *argv[];
{   short hour,
          minute,
          second;

    if (argc <= 2) {
        if (argc == 2) {
            if ((strlen(argv[1]) == 5 &&
                 isdigit(argv[1][0]) &&
                 isdigit(argv[1][1]) &&
                 !isdigit(argv[1][2]) &&
                 isdigit(argv[1][3]) &&
                 isdigit(argv[1][4])) ||
                (strlen(argv[1]) == 8 &&
                 isdigit(argv[1][0]) &&
                 isdigit(argv[1][1]) &&
                 !isdigit(argv[1][2]) &&
                 isdigit(argv[1][3]) &&
                 isdigit(argv[1][4]) &&
                 !isdigit(argv[1][5]) &&
                 isdigit(argv[1][6])&& 
                 isdigit(argv[1][7]))) {
                hour = 10 * todigit(argv[1][0]) +
                       todigit(argv[1][1]);
                minute = 10 * todigit(argv[1][3]) +
                       todigit(argv[1][4]);
                if (strlen(argv[1]) == 5)
                    second = 0;
                else
                    second = 10 * 
                           todigit(argv[1][6]) +
                           todigit(argv[1][7]);
                if (!puttime(hour, minute, second)) {
                  fprintf(stderr,
                   "time: argument is not a time\n");
                  return(FALSE);
                }
            }
            else {
              fprintf(stderr,
               "SYNOPSIS: time [ hhSmm [ Sss ] ]\n");
              return(FALSE);
            }
        }
        gettime(&hour, &minute, &second);
        printf("Time: %02d:%02d:%02d\n",
               hour, minute, second);
    }
    else {
        fprintf(stderr,
              "time: need at most one parameter\n");
        return(FALSE);
    }
    return(TRUE);
}

void main(argc, argv)
short argc;
char  *argv[];
{   if (!time(argc, argv))
        exit(1);
    exit(0);
}
