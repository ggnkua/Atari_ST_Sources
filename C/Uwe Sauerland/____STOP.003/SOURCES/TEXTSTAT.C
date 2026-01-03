/* PROGRAMM Textstatistik
 * VERSION  2.0
 * DATUM    17. Juli 1987
 * AUTOR    Uwe Sauerland
 * ZWECK    z„hlt Zeichen, W”rter, S„tze und Zeilen im Eingabestrom
 *
 */
 
#include <stdio.h>
#include <ctype.h>

#define ist_buchstabe(c)    (isalpha(c) || (c >= '€' && c <= 'š') || (c >= ' ' && c <= '¥') || (c >= '°' && c <= '¸'))
#define ist_satzende(c)     (c == '.' || c == ':' || c == '!' || c == '­' || c == '?' || c == '¨')
#define ist_zeilenende(c)   (c == '\n')

unsigned long zeichen = 0, woerter = 0, saetze = 0, zeilen = 0;
char dummy;

scantext(source)
FILE *source;
{
    int ch;
    
    while ((ch = fgetc(source)) != EOF)
    {
        if (ist_buchstabe(ch))
        {
            woerter++;
            while (ist_buchstabe(ch))
            {
                zeichen++;
                if ((ch = fgetc(source)) == EOF)
                    return;
            }
        }
        zeichen++;
        if (ist_satzende(ch)) saetze++;
        if (ist_zeilenende(ch)) zeilen++;
    }
}

showstat()
{
    printf("\nZeichen: %10lu\n", zeichen);
    printf("W”rter : %10lu\n", woerter);
    printf("S„tze  : %10lu\n", saetze);
    printf("Zeilen : %10lu\n\n", zeilen);
}

main(argc, argv)
int argc;
char *argv[];
{
    FILE *source;
    int i;
    char pathname[81];

    if (argc < 2)
        printf("usage: textstat <fname> {<fname>}\n");
    else
    {
        for (i = 1; i < argc; i++)
        {
            strcpy(pathname, argv[i]);
            if ((source = fopen(pathname, "r")) != NULL)
            {
                scantext(source);
                showstat();
            }
            close(source);
        }
    }
    printf("press [return]... "); gets(pathname);
}

