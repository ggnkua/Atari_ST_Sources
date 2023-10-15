/*  OP_FILE.C 
 *  Das CPX-Modul zur Steuerung von WRAPMOUSE
 *
 *  (c)1992 by Richard Kurz
 *  Vogelherdbogen 62
 *  7992 Tettnang
 *  Fido 2:241/7232
 *
 *  FÅr's TOS-Magazin
 *
 *  Erstellt mit Pure C
 */
 
#include <aes.h>
#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "wrapauto.h"


int fselect(char *fname, char *text)
/* Komfortionîse Datei-Auswahl.                                 */
{
    static char pfad[128]="!:\\";
    static char tp[128];

    int ok,knopf;
    char *s;
    
    if(pfad[0]=='!')
    {
        Dgetpath(tp,0);
        if(tp[strlen(tp)-1]!='\\') strcat(tp,"\\");
        strcpy(&pfad[2],tp);
        pfad[0]='A'+Dgetdrv(); pfad[1]=':';
    }

    s=strrchr(pfad,'\\');
    if(s!=NULL)
        strcpy(++s,"*.*");
    else
        strcpy(pfad,"*.*");

    if((Sversion()>>8)<=20) ok=fsel_input(pfad,fname,&knopf);
    else ok=fsel_exinput(pfad,fname,&knopf,text);

    if(!ok || !knopf)
    {
        s=strrchr(pfad,'\\');
            if(s != NULL)
                pfad[s+1]=0;
            else
                pfad[0]=0;
        return(FALSE);
    }
    
    s=strrchr(pfad,'\\');
    if(s != NULL)
        strcpy(++s,fname);
    else
        strcpy(pfad,fname);
    return(TRUE);
}/* fselect */
