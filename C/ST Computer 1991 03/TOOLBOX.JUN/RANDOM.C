/*
 * Listing 2.8, Datei  : random.c
 * Programm            : RANDOM - Erzeugung einer
 *                       Textdatei zum Check von SORT
 * Modifikationsdatum  : 04-M„r-90
 * Abh„ngigkeiten      : stdio.h, local.h, atom2.h
 */

#include <stdio.h>
#include "local.h"
#include "atom2.h"

main(argc, argv)
short argc;
char  **argv;
{   short i,
          count;
    char  number[100],
          alpha[100],
          month[100];

    if (argc == 2) {
        count = atoi(argv[1]);
        for (i = 0; i < count; i++) {
            random_number(number, 10);
            random_alpha(alpha, 20);
            random_month(month);
            printf("%s | %s | %s\n", number, alpha, month);
        }
    }
}