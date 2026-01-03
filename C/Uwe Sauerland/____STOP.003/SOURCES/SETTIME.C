/* PROGRAMM Set Time
 * VERSION  1.0
 * DATUM    24. Juli 1987
 * AUTOR    Uwe Sauerland
 * ZWECK    Setzen der Zeit zur Auto-Zeit
 *
 */

#include <stdio.h>
#include <string.h>
#include <osbind.h>

struct zeit {
    unsigned sekunden: 5;
    unsigned minuten : 6;
    unsigned stunden : 5;
};

struct datum {
    unsigned tag  : 5;
    unsigned monat: 4;
    unsigned jahr : 7;
};

main()
{
    union {
        int target;
        struct zeit time;
    } systime;
    union {
        int target;
        struct datum date;
    } sysdate;

    unsigned sek, min, std, tag, mon, jhr;
    char eingabe[80];
    int inresult;

    appl_init();
    Cursconf(1, 0);
    puts("\033EZeit und Datum setzen");
    puts("Copyright \275 by Uwe Sauerland, Berlin 1987\n");

    for (;;) {
        systime.target = Tgettime(); sysdate.target = Tgetdate();
        sek = systime.time.sekunden; min = systime.time.minuten; std = systime.time.stunden;
        tag = sysdate.date.tag; mon = sysdate.date.monat; jhr = sysdate.date.jahr;
        printf("\nZeit: %02d:%02d:%02d\tDatum %02d.%02d.%04d\tDaten Ok (j/n)? ",
            std, min, sek * 2, tag, mon, 1980 + jhr);
        gets(eingabe);
    if (toupper(eingabe[0]) == 'J')
    break;
        putchar('\n');

        /* lies Zeit */
        do {
            printf("Neue Zeit (std:min:sek): "); gets(eingabe);
            if (strlen(eingabe))
                inresult = sscanf(eingabe, "%d:%d:%d", &std, &min, &sek);
            else
                inresult = EOF;
        } while (inresult != EOF && inresult != 3);
        systime.time.sekunden = sek / 2; systime.time.minuten = min; systime.time.stunden = std;
        Tsettime(systime.target);

        putchar ('\n');

        /* lies Datum */
        do {
            printf("Neues Datum (tt.mm.jjjj): "); gets(eingabe);
            if (strlen(eingabe)) {
                inresult = sscanf(eingabe, "%d.%d.%d", &tag, &mon, &jhr);
                jhr -= 1980;
                if (tag < 1 || tag > 31 || mon < 1 || mon > 12 || jhr < 0 || jhr > 119)
                    inresult = 0;
            } else
                inresult = EOF;
        } while (inresult != EOF && inresult != 3);
        sysdate.date.tag = tag; sysdate.date.monat = mon; sysdate.date.jahr = jhr;
        Tsetdate(sysdate.target);
    }

    Cursconf(0, 0);
    appl_exit();
}

