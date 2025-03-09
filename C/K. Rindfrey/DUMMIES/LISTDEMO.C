/*
 * Demo fÅr einfach verkettete Listen.
 * Aufruf: listdemo <textfile>
 * (c) MAXON Computer 1993
 */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "list.h"

static const char such_str[] = "Heinrich";
/* Suchstring zur Demonstration von ls_Search */

/*
 * --------------------- main -------------------
 */
int main( int argc, const char *argv[])
{
    FILE *fp;
    TList *lst;
    TNode *n;
    char str[ 80];

    if( argc != 2){
        puts( "Argumentliste falsch!");
        exit( 1);
    }
    if( ( fp = fopen( argv[ 1], "r")) == NULL){
        puts( "Kann Datei nicht îffnen");
        exit( 1);
    }

    /* Liste anlegen */
    lst = n = ls_Create();

    /* Strings einlesen und gemallocte Kopien
     * in die Liste eintragen                 */
    while( !feof( fp)){
        if( fscanf( fp, "%s", str) > 0)
            n = ls_Insert( n, strdup( str));
    }
    fclose( fp);

    /* "Listenanfang!" an den Listenanfang */
    ls_Insert( lst, strdup( "Listenanfang!"));

    /* Alles mit puts ausgeben */
    ls_ForAll( lst, (Tv_pv)puts);

    /* Suche nach such_str */
    if( ls_Search( such_str, lst,
                     (TCmpF) strcmp) != NULL)
        puts( "\nSuchstring gefunden!");
    else
        puts ( "\nSuchstring nicht gefunden!");

    /* Knoten und Strings freigeben */
    ls_VFree( lst, free);
    return( 0);
}

