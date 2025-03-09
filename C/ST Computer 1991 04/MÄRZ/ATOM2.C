/*
 * Listing 2.1, Datei : atom2.c
 * Modul              : ATOM2 - ATOMare Manipulationen,
 *                      2.Teil
 * Modifikationsdatum : 04-MÑr-90
 * AbhÑngigkeiten     : stdio.h, string.h, ctype.h, 
 *                      osbind.h, local.h
 */

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <osbind.h>
#include "local.h"

/*
 * Funktion     : onlyws
 *
 * Parameter    : isonlyws = onlyws(str);
 *                BOOLEAN isonlyws;
 *                char    *str;
 *
 * Aufgabe      :
 *
 * Der String <str> wird daraufhin untersucht, ob er
 * nur Leerzeichen (SPACE und TAB) enthÑlt. Es wird
 * ein entsprechender Wahrheitswert zurÅckgegeben.
 */

BOOLEAN onlyws(str)
char *str;
{   short i;

    for (i = 0; i < strlen(str); i++)
        if (!(str[i] == ' ' || str[i] == '\t'))
            return(FALSE);
    return(TRUE);
}

/*
 * Funktion     : patmat
 *
 * Parameter    : ismatching = patmat(pattern, string);
 *                BOOLEAN ismatching;
 *                char    *pattern,
 *                        *string;
 *
 * Aufgabe      :
 *
 * Die Funktion <patmat> (Pattern Matching) vergleicht
 * das Muster <pattern> mit der Zeichenkette <string> 
 * und liefert einen Wahrheitswert, der dem Ergebnis des
 * Vergleichs entspricht. <pattern> darf dabei das Zeichen
 * '?' zur Kennzeichnung eines unbekannten Buchstaben und 
 * das Zeichen '*' zur Kennzeichnung eines unbekannten
 * Teilstrings enthalten. <patmat> ergÑnzt dabei das 
 * Åbergebene Muster rechts und links mit dem Zeichen '*',
 * um <pattern> an beliebiger Stelle im <string> zu erkennen.
 */

static void strcompare(string, pattern, erg)
char    *string,
        *pattern;
BOOLEAN *erg;
{   char *str = string,
         *pat = pattern;
    
    if (!(*erg)) {
        if (strlen(pat) == 0)
            *erg = strlen(str) == 0;
        else
            switch(pat[0]) {
                case '*':
                    if (strlen(str) > 0) {
                        strcompare(++str,pat,erg);
                        --str;
                    }
                    if (!(*erg))
                        strcompare(str,++pat,erg);
                    break;
                case '?':
                    if (strlen(str) != 0)
                        strcompare(++str,++pat,erg);
                    break;
                default:
                    if (pat[0] == str[0])
                        strcompare(++str,++pat,erg);
            }
    }
}

BOOLEAN patmat(pattern, string)
char *pattern,
     *string;
{   BOOLEAN erg = 0;
    char    *w1 = malloc(strlen(string) + 1),
            *w2 = malloc(strlen(pattern) + 3);
            
    strcpy(w1, string);
    strcpy(w2, "*");
    strcat(w2, pattern);
    strcat(w2, "*");
    strcompare(w1, w2, &erg);
    free(w1);
    free(w2);
    return(erg);
}

/*
 * Funktion     : outline
 *
 * Parameter    : outline(string, fold);
 *                char    *string;
 *                BOOLEAN fold;
 *
 * Aufgabe      :
 *
 * Ausgabe einer Zeile unter BerÅcksichtigung des
 * Parameters <fold>. <fold> gibt an ob die Zeile beim
 * Zeilenende "abgeschnitten" oder "abgeknickt" wird.
 */

void outline(string, fold)
char    *string;
BOOLEAN fold;
{   short i = 1;

    for (i = 0; i < strlen(string); i++) {
        if (fold && (i + 1) % 80 == 0)
            printf("\n");
        putchar(string[i]);
    }
    printf("\n");
}

/*
 * Funktion     : filter_dict
 *
 * Parameter    : filter_dict(string)
 *                char *string;
 *
 * Aufgabe      :
 *
 * <filter_dict> entfernt alle Zeichen aus einem String,
 * die weder Leerzeichen noch alphanumerische Zeichen
 * sind.
 */

void filter_dict(string)
char *string;
{   short i,
          j,
          l;
    
    j = 0;
    l = strlen(string);
    for (i = 0; i < l; i++)
        if (isspace(string[i]) ||
            isalnum(string[i]))
            string[i - j] = string[i];
        else
            j++;
    string[l - j] = 0;
}

/*
 * Funktion     : random_number, random_alpha,
 *                random_month
 *
 * Parameter    : random_number(string, count);
 *                random_alpha(string, count);
 *                random_month(string);
 *                char  *string;
 *                short count;
 *
 * Aufgabe      :
 *
 * Erzeugen von Zufallsstrings. <random_number> und 
 * <random_alpha> erzeugen Zufallsstrings der LÑnge <count>
 * an der Adresse <string>. <random_number> erzeugt dabei
 * Ziffern; <random_alpha> Groûbuchstaben. <random_month>
 * erzeugt einen drei Zeichen langen Zufallsstring, der
 * einem der zwîlf folgenden MonatskÅrzel entspricht:
 *
 * JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC
 */

void random_number(string, count)
char  *string;
short count;
{   short i;

    for (i = 0; i < count; i++)
        string[i] = Random() % 10 + '0';
    string[count] = 0;
}

void random_alpha(string, count)
char  *string;
short count;
{   short i;

    for (i = 0; i < count; i++)
        string[i] = Random() % 26 + 'A';
    string[count] = 0;
}

void random_month(string)
char  *string;
{   short i;

    switch (Random() % 12) {
        case 0:
            strcpy(string, "JAN");
            break;
        case 1:
            strcpy(string, "FEB");
            break;
        case 2:
            strcpy(string, "MAR");
            break;
        case 3:
            strcpy(string, "APR");
            break;
        case 4:
            strcpy(string, "MAY");
            break;
        case 5:
            strcpy(string, "JUN");
            break;
        case 6:
            strcpy(string, "JUL");
            break;
        case 7:
            strcpy(string, "AUG");
            break;
        case 8:
            strcpy(string, "SEP");
            break;
        case 9:
            strcpy(string, "OCT");
            break;
        case 10:
            strcpy(string, "NOV");
            break;
        case 11:
            strcpy(string, "DEC");
            break;
    }
}

