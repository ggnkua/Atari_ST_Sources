/*  EXTSTRLIB.C */
/*  Erweiterte Routinen zur Stringbehandlung, u.a. Zentrieren eines */
/*  Strings, Abschneiden von Leerzeichen am Zeilenanfang und -ende, */
/*  Links- und/oder RechtsbÅndigmachen, Zentrieren und Splitten in  */
/*  zwei Strings nach einer best. Anzahl von Zeichen. */
/*  Version : 1.07 */
/*  Datum   : 17.06.1992  */
/*  Autor   : Andreas Papula */
/*  Copyright 1992 by MAXON Computer GmbH.  */

/* include-Files einbinden. */

#include    <portab.h>
#include    <stdlib.h>
#include    <string.h>
#include    "extstr.h"

/*  BYTE *str_rjust(BYTE *string) */
/*  Justiert einen String rechtsbÅndig. */
/*  Die LÑnge des Strings wird dabei nicht verÑndert. */
/*  Parameter:Ein Zeiger auf den zu bearbeitenden String. */
/*  RÅckgabe :Ein Zeiger auf den String. */

BYTE *str_rjust(BYTE *string)
{
   ULONG i = 0;
   ULONG   len_1 = 0;
   ULONG len_2 = 0;
   ULONG len_diff = 0;
/* AnfangslÑnge feststellen */
   len_1 = strlen(string);

 /* Leerzeichen am Ende entfernen */
   str_rrm(string);
 /* Neue StringlÑnge feststellen */
   len_2 = strlen(string);
 /* Differenz der LÑngen berechnen */
   len_diff = len_1 - len_2;
 /* String nach rechts verschieben */
   while(len_2) string[--len_1] = string[--len_2];
 /* Am linken Rand mit Leerzeichen auffÅllen */
   for(i = 0; i< len_diff; i++) string[i] = ' ';
   return string;
}

/*  BYTE *str_ljust(BYTE *string) */
/*  Justiert einen String linksbÅndig. */
/*  Die LÑnge des Strings wird dabei nicht verÑndert. */
/*  Parameter:Ein Zeiger auf den zu bearbeitenden String. */
/*  RÅckgabe :Ein Zeiger auf den String. */

BYTE *str_ljust(BYTE *string)
{
   ULONG i = 0;
   ULONG len_1 = 0;
   ULONG len_2 = 0;
   /* LÑnge des Strings am Anfang */
   len_1 = strlen(string);
   /* Leerzeichen am Anfang entfernen */
   str_lrm(string);
   /* Neue LÑnge in Erfahrung bringen */
   len_2 = strlen(string);
   /* Und bis zur alten LÑnge mit Leerzeichen auffÅllen */
   for(i = len_2; i < len_1; i++)string[i] = ' ';
   return string;
}

/*  BYTE *str_center(BYTE *string) */
/*  Zentriert einen String. Die ursprÅngliche LÑnge wird */
/*  dabei nicht verÑndert. */
/*  Parameter:Ein Zeiger auf den zu bearbeitenden String. */
/*  RÅckgabe :Ein Zeiger auf den String, NULL, wenn kein Speicher-  */
/*  platz fÅr den temporÑren Arbeitsstring vorhanden ist.   */

BYTE *str_center(BYTE *string)
{
   ULONG len_1 = 0;
   ULONG len_2 = 0;
   ULONG   len_diff = 0;
   ULONG space_r = 0;
   ULONG space_l = 0;
   ULONG i = 0;
   ULONG j = 0;
   BYTE *tmp_str;
   /* AnfangslÑnge des Strings ermitteln */
   len_1 = strlen(string);
   /* Arbeitskopie des Strings anlegen */
   if((tmp_str = strdup(string)) == NULL)return NULL;
   /* Leerzeichen am Anfang und Ende entfernen */
    str_arm(tmp_str);
   /* LÑnge ermitteln */
    len_2 = strlen(tmp_str);
   /* Differrenz der LÑngen der beiden Strings ermitteln */
    len_diff = len_1 - len_2;
/* Anzahl der einzufÅgenden Leerzeichen berechnen */
    if((len_diff % 2) == 1)
    {
        space_l = (len_diff - 1) / 2;
        space_r = (len_diff + 1) / 2;
    }
    else space_l = space_r = len_diff / 2;
 /* Erst die Leerzeichen am linken Rand */
    for(i = 0; i < space_l; string[i] = ' ', i++);

    /* Dann der Text */
   for(i = space_l, j = 0; i < space_l + len_2;
           string[i] = tmp_str[j], i++, j++);
/* Und jetzt die Leerzeichen am rechten Rand */
    for(i = space_l + len_2; i < space_l + len_2 + space_r;
    string[i] = ' ', i++);
/* Speicherplatz wieder freigeben */
    free(tmp_str);
    return string;
}

/*  BYTE *str_bjust(BYTE *string) */
/*  Formatiert einen String im Blocksatz, d.h. am Anfang und am */
/*  Ende werden alle Leerzeichen entfernt und zwischen den Wîrtern  */
/*  wird der String dann wieder auf die ursprÅngliche LÑnge
/*  aufgefÅllt */
/*  Parameter:Ein Zeiger auf den zu bearbeitenden String. */
/*  RÅckgabe :Ein Zeiger auf den String oder NULL, wenn kein */
/*  peicherplatz fÅr die temporÑren Arbeitsstrings vorhanden 
ist. */

BYTE *str_bjust(BYTE *string)
{
    ULONG i = 0;
    ULONG len = 0;
    ULONG spaces = 0;
    ULONG words = 0;
    ULONG space_flag = 1;
    ULONG min_spaces = 0;
    ULONG extra_spaces = 0;
    BYTE *tmp;
    BYTE *wrk;
    BYTE *pad;
/* LÑnge des Strings besorgen */
    len = strlen(string);
/* Wîrter und Leerzeichen zÑhlen */
    for(i = 0; i < len; i++)
    {
        if(string[i] == ' ')
        {
            spaces++;
            space_flag = 1;
        }
        else if(space_flag)
        {
            words++;
            space_flag = 0;
        }
    }
/* Wenn weniger als zwei Wîrter oder keine Leerzeichen, Abbruch 
*/
    if(words < 2 || spaces == 0) return string;
/* Minimale Anzahl Leerzeichen zwischen den Wîrtern berechnen */
    min_spaces = spaces / (words - 1);
/* String fÅr die minimale Anzahl Leerzeichen besorgen */
    if((pad = (BYTE *)malloc((min_spaces + 1))) == NULL)
    return NULL;
/* pad-String mit Leerzeichen fÅllen */
    pad[min_spaces] = '\0';
    for(i = 0; i < min_spaces; i++) pad[i] = ' ';
/* Anzahl der zusÑtzlichen Leerzeichen berechnen */
    extra_spaces = spaces - (words - 1) * min_spaces;
/* String fÅr zusÑtzliche Leerzeichen besorgen */
    if((tmp = (BYTE *)malloc(words)) == NULL) return NULL;
/* tmp mit Einsen und Nullern fÅllen, um zusÑtzliche */
/* Leerzeichen zu kennzeichnen */
    tmp[words - 1] = '\0';
    for(i = 0; i < words - 1; i++)
      if(i < extra_spaces) tmp[i] = '1';
      else tmp[i] = '0';
/* Reihenfolge der Einsen und Nullen zufÑllig 'machen' */
    str_shuffle(tmp);
/* Arbeitskopie des Åbergebenen Strings anfertigen */
    if((wrk = strdup(string)) == NULL) return NULL;
/* Erstes Wort in den String kopieren */
    strcpy(string, strtok(wrk, " "));
/* Rest des Strings zusammenbauen */
    for(i = 0; i < words - 1; i++)
    {
        /* Minimale Anzahl Leerzeichen hinzufÅgen */
        strcat(string, pad);
/* ZusÑtzliches Leerzeichen hinzufÅgen, wenn angezeigt */
        if(tmp[i] == '1')
            strcat(string, " ");
/* NÑchstes Wort besorgen */
        strcat(string, strtok(NULL, " "));
    }
/* Arbeitsspeicher zurÅckgeben */
    free(wrk);
    free(tmp);
    free(pad);
    return string;
}

/*  BYTE *str_shuffle(BYTE *string) */
/*  éndert die Reihenfolge der Zeichen in dem Åbergebenen 
String. */
/*  Parameter:Ein Zeiger auf den zu bearbeitenden String. */
/*  RÅckgabe :Ein Zeiger auf den String. */

BYTE *str_shuffle(BYTE *string)
{
    ULONG i = 0;
    ULONG j = 0;
    ULONG k = 0;
    ULONG len = 0;
/* LÑnge des Strings feststellen */
    len = strlen(string);
/* Reihenfolge Ñndern */
    for(i = 0; i < len; i++)
    {
        j = rand() % len;
        k = (ULONG)string[i];
        string[i] = string[j];
        string[j] = (BYTE)k;
    }
    return string;
}

/*  BYTE *str_arm(BYTE *string) */
/*  Entfernt Leerzeichen am Anfang und am Ende eines Strings. */
/*  Es werden str_rrm() und str_lrm() benutzt. */
/*  Parameter:Ein Zeiger auf den zu bearbeitenden String. */
/*  RÅckgabe :Ein Zeiger auf den String. */

BYTE *str_arm(BYTE *string)
{
/* Leerzeichen am Ende entfernen */
    str_rrm(string);
/* Leerzeichen am Anfang entfernen */
    str_lrm(string);
    return string;
}

/*  BYTE *str_rrm(BYTE *string) */
/*  Entfernt Leerzeichen am Ende eines Strings. */
/*  Parameter:Ein Zeiger auf den zu bearbeitenden String. */
/*  RÅckgabe :Ein Zeiger auf den String. */

BYTE *str_rrm(BYTE *string)
{
    ULONG len = 0;
/* LÑnge des Strings feststellen */
    len = strlen(string);
/* Leerzeichen am Ende des Strings mit '\0' Åberschreiben */
    while(string[--len] == ' ') string[len] = '\0';
    return string;
}

/*  BYTE *str_lrm(BYTE *string) */
/*  Entfernt Leerzeichen am Anfang eines Strings. */
/*  Parameter:Ein Zeiger auf den zu bearbeitenden String. */
/*  RÅckgabe :Ein Zeiger auf den String.  */

BYTE *str_lrm(BYTE *string)
{
    UWORD i = 0;
    UWORD j = 0;
    ULONG len = 0;
/* Zuerst die LÑnge des Strings besorgen */
    len = strlen(string);
/* Erstes Zeichen, daû kein Leerzeichen ist, suchen */
    for(i = 0; i < len && string[i] == ' '; i++);
/* Zeichen vertauschen */
    for(j = 0; i <= len; string[j++] = string[i++]);
    return string;
}

/*  BYTE *str_split(BYTE *string_1, BYTE *string_2, WORD n) */
/*  Die Funktion splittet den String string_1 in zwei
/*  Teilstrings auf. */
/*  Parameter:Ein Zeiger auf den zu splittenden String und ein */
/*  Zeiger auf den zweiten String, der den Rest des */
/*  ersten Strings enthÑlt und die Anzahl der Zeichen, */
/*  nach, denen spÑtestens gesplittet werden soll. */
/*  RÅckgabe :Ein Zeiger auf den ersten String. */

BYTE *str_split(BYTE *string_1, BYTE *string_2, WORD n)
{
    ULONG len = 0;
/* LÑnge des Strings besorgen */
    len = strlen(string_1);
/* Wenn der String bereits kurz genug ist, dann zurÅckgeben */
    if(len <= n)
    {
        string_2[0] = '\0';
        return string_2;
    }
/* Letztes Leerzeichen vor der Stelle suchen */
    for(;string_1[n] !=' ' && n; n--);
/* Wenn kein Leerzeichen gefunden, auch nicht splitten */
    if(!n)
    {
        string_2[0] = '\0';
        return string_1;
    }
/* Splitten ! */
    strcpy(string_2, &string_1[n+1]);
/* Leerzeichen vom Ende des ersten Strings entfernen */
    while(string_1[n] == ' ') string_1[n--] = '\0';
    return string_1;
}

/*  BYTE *str_fill(BYTE *string_1, BYTE *string_2, WORD n) */
/*  FÅllt string_1 bis zur LÑnge len_1 mit den Zeichen aus 
string_2 */
/*  und hÑngt das Null-Zeichen an. */
/*  Parameter:Ein Zeiger auf den zu bearbeitenden String und ein */
/*  Zeiger auf den FÅllstring, sowie die gewÅnschte LÑnge   */
/*  des zu fÅllenden Strings. */
/*  RÅckgabe :Ein Zeiger auf den gefÅllten String. */

BYTE *str_fill(BYTE *string_1, BYTE *string_2, WORD n)
{
    ULONG i = 0;
    ULONG j = 0;
    ULONG len_2 = 0;
/* LÑnge des FÅllstrings besorgen */
    len_2 = strlen(string_2);
/* Und jetzt fÅllen */
    for(i = j = 0; i < n; i++)
    {
        string_1[i] = string_2[j++];
        if(j == len_2) j = 0;
    }
/* Null-Zeichen dranhÑngen */
    string_1[n] = '\0';
    return string_1;
}

/* Ende der Datei */

