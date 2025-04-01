/*  STRTEST.C */
/*  Testprogramm fÅr die EXTended-STRing-Library. */
/*  Version : 1.10 */
/*  Datum   : 17.06.1992 */
/*  Autor   : Andreas Papula */
/*  Copyright 1992 by MAXON Computer GmbH. */

/*  Include-Files einbinden. */

#include <ext.h>
#include <stdio.h>
#include <string.h>
#include "extstr.h"

/*  Konstantendeklarationen und Makros */

#define INVERS_ON       printf("\33p")
#define INVERS_OFF  printf("\33q")

/*  Das Hauptprogramm. */

int main(void)
{
    char string[80] = "  Dies ist ein Test !!!   ";
    char string2[80];
    puts("\33E----- Demo zu EXTSTR.C von A.Papula -----");
    /* ursprÅnglichen String ausgeben */
    INVERS_OFF;
    puts("Der ursprÅngliche String:");
    INVERS_ON;
    puts(string);
    strcpy(string2, string);
    /* Leerzeichen am linken Rand entfernen */
    INVERS_OFF;
    puts("Leerzeichen am linken Rand entfernen:");
    INVERS_ON;
    puts(str_lrm(string2));
    strcpy(string2, string);
    /* Leerzeichen am rechten Rand entfernen */
    INVERS_OFF;
    puts("Leerzeichen am rechten Rand entfernen:");
    INVERS_ON;
    puts(str_rrm(string2));
    strcpy(string2, string);
    /* Leerzeichen am Anfang und Ende entfernen */
    INVERS_OFF;
    puts("Leerzeichen am Anfang und Ende entfernen:");
    INVERS_ON;
    puts(str_arm(string2));
    strcpy(string2, string);
    /* String linksbÅndig formatieren */
    INVERS_OFF;
    puts("String linksbÅndig formatieren:");
    INVERS_ON;
    puts(str_ljust(string2));
    strcpy(string2, string);
    /* String rechtsbÅndig formatieren */
    INVERS_OFF;
    puts("String rechtsbÅndig formatieren:");
    INVERS_ON;
    puts(str_rjust(string2));
    strcpy(string2, string);
    /* String zentrieren */
    INVERS_OFF;
    puts("String zentrieren:");
    INVERS_ON;
    puts(str_center(string2));
    strcpy(string2, string);
    /* String im Blocksatz formatieren */
    INVERS_OFF;
    puts("String im Blocksatz formatieren:");
    INVERS_ON;
    puts(str_bjust(string2));
    strcpy(string2, string);
    /* Reihenfolge der Zeichen Ñndern */
    INVERS_OFF;
    puts("Reihenfolge der Zeichen verÑndern:");
    INVERS_ON;
    puts(str_shuffle(string2));
    /* String nach 17 Zeichen splitten */
    INVERS_OFF;
    puts("String nach 17 Zeichen splitten:");
    INVERS_ON;
    puts(str_split(string, string2, 17));
    puts(string2);
    /* String bis 70 Zeichen mit "hallo " fÅllen */
    INVERS_OFF;
    puts("String bis 70 Zeichen mit \"hallo \" fÅllen:");
    INVERS_ON;
    puts(str_fill(string, "hallo ", 70));
    /* Invers-Schrift aufheben */
    INVERS_OFF;
    /* Auf Taste warten */
    getch();
return 0;
}

/* Ende der Datei */

