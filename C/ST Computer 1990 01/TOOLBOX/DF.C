/*
 * Listing 1.9, Datei : df.c
 * Programm           : DF - Auslastungsstatistik
 *                      fÅr Dateisysteme
 * Modifikationsdatum : 15-Nov-89
 * AbhÑngigkeiten     : stdio.h, osbind.h, local.h,
 *                      atom.h
 */

#include <stdio.h>
#include <osbind.h>
#include "local.h"
#include "atom.h"

/*
 * Funktion     : df
 *
 * Parameter    : df(argc, argv);
 *                short argc;
 *                char  *argv[];
 *
 * Aufgabe      :
 *
 * Interpretierung der durch <argc> und <argv>
 * spezifizierten Parameterliste gemÑû den Fest-
 * legungen des Kommandos df.
 */

static void info(drv)
int drv;
{   disk_info inf;

    Dfree(&inf, drv + 1);
    printf(
        "%c:          %-10ld%-10ld%-10ld%-2ld%%\n",
        drv + 'A', inf.b_total, inf.b_total -
        inf.b_free, inf.b_free, 100L * (inf.b_total
        - inf.b_free) / inf.b_total);
}

void df(argc, argv)
short argc;
char  *argv[];
{   long  fsysvec;
    short i;

    printf("%-12s%-10s%-10s%-10s%-10s\n",
           "Filesystem", "kbytes", "used", "avail",
           "capacity");
    if (argc == 1)
        info(Dgetdrv());
    else if (strcmp(argv[1], "-A") == 0 ||
             strcmp(argv[1], "-a") == 0) {
        fsysvec = Dsetdrv(Dgetdrv());
        for (i = 0; i < 31; i++)
            if ((1L << i) & fsysvec)
                info (i);
    }
    else
        for (i = 1; i <= argc - 1; i++) {
            convupper(argv[i]);
            if (strlen(argv[i]) == 1 &&
                argv[i][0] >= 'A' &&
                argv[i][0] <= 'Z') {
                fsysvec = Dsetdrv(Dgetdrv());
                if ((1L << (argv[i][0] - 'A')) &
                    fsysvec)
                    info(argv[i][0] - 'A');
                else
                    fprintf(stderr,
                     "df: %s is not a filesystem\n",
                     argv[i]);
            }
            else
                fprintf(stderr,
                     "df: %s is not a filesystem\n",
                     argv[i]);
        }
}

void main(argc, argv)
short argc;
char  *argv[];
{   df(argc, argv);
    exit(0);
}
