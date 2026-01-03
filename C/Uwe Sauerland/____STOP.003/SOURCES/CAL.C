/* PROGRAMM Kalender
 * VERSION  1.0
 * DATUM    27. Juli 1987
 * AUTOR    Uwe Sauerland
 * ZWECK    Erzeugung eines Monats/Jahreskalenders fÅr einen angebenen Zeit-
 *          raum.
 *
 */
 
#include <stdio.h>

#define MSIZE 37

char *monats[12] =
{
    "Januar", "Februar", "MÑrz", "April", "Mai", "Juni", "Juli",
    "August", "September", "Oktober", "November", "Dezember"
};

char *wtags[7] = { "Mon", "Die", "Mit", "Don", "Fre", "Sbd", "Son" };

int mlaenge[2][12] =
{
    31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31,
    31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
};

int jahrestafel[12][MSIZE];

long juldat(tag, monat, jahr)
int tag, monat, jahr;
{
    return  (long) (365.25  * (monat > 2 ? jahr : jahr - 1)) +
            (long) (30.6001 * (monat > 2 ? monat + 1 : monat + 13)) +
            (long) tag + 1720982L;
}

#define wochentag(t,m,j)    ((int) (juldat((t), (m), (j)) % 7L))
#define schaltjahr(j)       ((!(j % 400) || (!(j % 4) && (j % 100))) ? 1 : 0)

gen_monat(monat, jahr)
int monat, jahr;
{
    int tag, offset;
    
    for (offset = 0; offset < wochentag(1, monat + 1, jahr); offset++)
        jahrestafel[monat][offset] = 0;
    for (tag = 0; tag < mlaenge[schaltjahr(jahr)][monat]; tag++)
        jahrestafel[monat][tag + offset] = tag + 1;
    while (offset + tag < MSIZE)
        jahrestafel[monat][offset + tag++] = 0;
}

gen_jahr(jahr)
int jahr;
{
    int monat;
    
    for (monat = 0; monat < 12; gen_monat(monat++, jahr));
}

druck_monat(monat, jahr)
int monat, jahr;
{
    int wtag, i, offset;
    
    printf("Kalender fÅr %s %d\n", monats[monat], jahr);
    for (i = 0; i < 27; i++) putchar('-'); putchar('\n');
    for (wtag = 0; wtag < 7; wtag++)
    {
        printf("%3s ", wtags[wtag]);
        for (offset = wtag; offset < MSIZE; offset += 7)
            if (jahrestafel[monat][offset])
                printf("%2d ", jahrestafel[monat][offset]);
            else
                printf("   ");
        putchar('\n');
    }
}

druck_jahr(jahr)
int jahr;
{
    int quartal, wtag, monat, i, offset;
    
    printf("%40s %d\n\n", "Kalender fÅr das Jahr", jahr);
    
    for (quartal = 0; quartal < 12; quartal += 3)
    {
        printf("    %-17s       %-17s       %-17s\n", monats[quartal], monats[quartal + 1], monats[quartal + 2]);
        for (i = 0; i < 70; i++) putchar('-'); putchar('\n');
        for (wtag = 0; wtag < 7; wtag++)
        {
            for (monat = quartal; monat < quartal + 3; monat++)
            {
                printf("%3s ", wtags[wtag]);
                for (offset = wtag; offset < MSIZE; offset += 7)
                    if (jahrestafel[monat][offset])
                        printf("%2d ", jahrestafel[monat][offset]);
                    else
                        printf("   ");
                if (monat < quartal + 2)
                    if (wtag < 2)
                        printf("  ");
                    else
                        printf("     ");
            }
            putchar('\n');
        }
        putchar('\n');
    }
}

main(argc, argv)
int argc;
char *argv[];
{
    int jahr, monat;
    char dummy;
    
    if (argc < 2)
    {
        printf("usage: cal [<monat>] <jahr>\n\n");
        printf("Kalendergenerator Version 1.0\n");
        printf("Copyright Ω by Uwe Sauerland, Berlin 1987\n");
    }
    else if (argc < 3)
    {
        sscanf(argv[1], "%d", &jahr);
        gen_jahr(jahr);
        druck_jahr(jahr);
    }
    else
    {
        sscanf(argv[1], "%d", &monat);
        sscanf(argv[2], "%d", &jahr);
        gen_monat(monat - 1, jahr);
        druck_monat(monat - 1, jahr);
    }
    putchar('\n'); putchar('\n');
    gets(&dummy);
}

