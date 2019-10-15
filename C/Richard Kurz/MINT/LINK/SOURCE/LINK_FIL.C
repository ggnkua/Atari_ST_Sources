/*
 * Link
 * Datei-Funktionen
 * Oktober 1992 by Richard Kurz
 * fÅr's TOS-Magazin
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include <aes.h>
#include "mintbind.h"
#include "link.h"

static void get_pfad(char *p)
/* Verwaltet die Zugriffs-Pfade.                                */
{
    static char tp[128];
    
    Dgetpath(tp,0);
    if(tp[strlen(tp)-1]!='\\') strcat(tp,"\\");
    strcpy(&p[2],tp);
    p[0]='A'+Dgetdrv(); p[1]=':';
} /* get_pfad */

static int fselect(char *pfad,char *fname, char *ext, char *text)
/* Komfortionîse Datei-Auswahl.                                 */
{
    long l;
    int ok,knopf;
    char *s;
    
    s=strrchr(pfad,'\\');
    if(s!=NULL)
        strcpy(++s,"*.");
    else
        strcpy(pfad,"*.");
    strcat(pfad,ext);

    if((Sversion()>>8)<=20) ok=fsel_input(pfad,fname,&knopf);
    else ok=fsel_exinput(pfad,fname,&knopf,text);

    if(!ok || !knopf)
    {
        s=strrchr(pfad,'\\');
            if(s != NULL)
                s[1]=0;
            else
                pfad[0]=0;
        return(FALSE);
    }
    
    s=strrchr(pfad,'\\');
    if(s != NULL)
        strcpy(++s,fname);
    else
        strcpy(pfad,fname);
    l=strlen(pfad)-1;
    if(pfad[l]=='\\')
    {
        pfad[l]=0;
        s=strrchr(pfad,'\\');
        if(s != NULL)
            strcpy(fname,++s);
    }
    return(TRUE);
}/* fselect */

void link_fehler(long nr)
/* Sucht die Fehlermeldung zu einer Fehler-Nr. */
{
    char s[40];
    
    switch((int)nr)
    {
        case EINVFN: do_meldung("FEHLER:","Dieses Dateisystem","erlaubt keine Links",""); break;
        case EFILNF: do_meldung("FEHLER:","Datei nicht gefunden","",""); break;
        case EACCDN: do_meldung("FEHLER:","Diese Datei ist kein","symbolischer Link!",""); break;
        default: 
            sprintf(s,"Nr. %li",nr);
            do_meldung("FEHLER:","TOS-Dateifehler",s,"");
            break;
    }
}/* link_fehler */

static char nfile[256]="";
static char ufile[256]="";
static char file[15];

void set_sym_link(void)
/* Setzt einen symbolischen Link */
{
    long i;

    strcpy(ufile,"U:\\");
    if(!nfile[0]) get_pfad(nfile);
    
    if(fselect(nfile,file,"*","Original wÑhlen"))
    {
        if(fselect(ufile,file,"*","Link-Name wÑhlen"))
        {
            i=Fsymlink(nfile,ufile);
            if(i) link_fehler(i);
        }
    }
}/* set_sym_link */

void read_link(void)
/* Liest den original Pfad eines Links */
{
    static char buf[256];
    static char t[3][40];
    long i,l;
    char *s;
    
    strcpy(ufile,"U:\\");
    if(fselect(ufile,file,"*","Link anzeigen"))
    {
        i=Freadlink(256,buf,ufile);
        if(i) link_fehler(i);
        else
        {
            t[0][0]=t[1][0]=t[2][0]=0;
            s=buf;
            l=strlen(s);
            strncpy(t[0],s,30);
            if(l>30)
            {
                s=buf+30;
                strncpy(t[1],s,30);
            }
            if(l>60)
            {
                s=buf+60;
                strncpy(t[2],s,30);
            }
            do_meldung("Original Datei:",t[0],t[1],t[2]);   
        }
    }
}/* read_link */

void del_link(void)
/* Lîscht einen Link und nur den! */
{
    char buf[256];
    
    strcpy(ufile,"U:\\");
    if(fselect(ufile,file,"*","Link lîschen"))
    {
        if(!Freadlink(256,buf,ufile))
        {
            if(Fdelete(ufile))
                do_meldung("FEHLER:","Link konnte nicht","gelîscht werden!","");
        }
        else
        {
            link_fehler(EACCDN);
        }
    }
}/* del_link */
