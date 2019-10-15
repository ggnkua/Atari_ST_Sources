/*
 * PS-Control
 * Verwaltet die PrioritÑtenliste
 * September 1992 by Richard Kurz
 * fÅr's TOS-Magazin
 */

#include <stdio.h>
#include <stdlib.h>
#include <tos.h>
#include <aes.h>
#include <string.h>

#include "mintbind.h"

#include "ps_glob.h"

static char pname[MAX_PROZ][20];    /* Puffer fÅr die Namen */
static int  anz,                    /* Wieviele sind's?     */
       wpri[MAX_PROZ];              /* Die PrioritÑten      */

char *fselect(char *text)
/* Verwaltet die Fileselectbox */
{
    static char rpfad[256],pfad[256],fname[20];
    int ok,knopf;
    char *s;
    
    if(!pfad[0])
    {
        pfad[0]='A'+Dgetdrv(); pfad[1]=':';
        Dgetpath(&pfad[2],0);
        if(pfad[strlen(pfad)-1]!='\\') strcat(pfad,"\\");
        
    }
    if(!fname[0]) strcpy(fname,"PS_CONTR.INF");
    s=strrchr(pfad,'\\');
    if(s!=NULL)
        strcpy(++s,"*.");
    else
        strcpy(pfad,"*.");
    strcat(pfad,"INF");

    if((Sversion()>>8)<=20) ok=fsel_input(pfad,fname,&knopf);
    else ok=fsel_exinput(pfad,fname,&knopf,text);

    if(!ok || !knopf)
    {
        s=strrchr(pfad,'\\');
            if(s != NULL)
                pfad[s+1]=0;
            else
                pfad[0]=0;
        return(NULL);
    }
    
    strcpy(rpfad,pfad);
    s=strrchr(rpfad,'\\');
    if(s != NULL)
        strcpy(++s,fname);
    else
        strcpy(rpfad,fname);
    return(rpfad);
}/* fselect */

int load_inf(char *fn)
/* lÑdt den Info-File (PS_CONTR.INF) */
{
    FILE *fp;
    int i=FALSE;
    char *s,ts[80];
    
    if(fn==NULL) fn=fselect("PS-Control Info laden");
    else i=TRUE;

    if(fn==NULL) return(FALSE);
    fp=fopen(fn,"r");
    if(fp==NULL)
    {
        if(!i) form_alert(1,"[3][ |Datei konnte nicht|geîffnet werden][ OK ]");
        return(FALSE);
    }

    for(anz=0;anz<MAX_PROZ;)
    {
        if(fgets(ts,70,fp)==NULL) break;
        s=strchr(ts,' ');
        if(s==NULL) continue;
        *s=0;s++;
        strncpy(pname[anz],ts,18);
        wpri[anz]=atoi(s);
        if(wpri[anz]>20) wpri[anz]=20;
        else if(wpri[anz]<-20) wpri[anz]=-20;
        anz++;
    }
    fclose(fp);
    return(TRUE);
}/* load_inf */

void save_inf(void)
/* Sichert den Info-File */
{
    FILE *fp;
    int i;
    char *fn;
    
    fn=fselect("PS-Control Info sichern");
    if(fn==NULL) return;
    fp=fopen(fn,"w");
    if(fp==NULL)
    {
        form_alert(1,"[3][ |Datei konnte nicht|geîffnet werden][ OK ]");
        return;
    }
    for(i=0;i<anz;i++)
        fprintf(fp,"%-8s %i\n",pname[i],wpri[i]);
    fclose(fp);
} /* save_inf */

int check_pri(char *n,int id, long p, int flag)
/* Kontrolliert, ob die PrioritÑten richtig gesetzt sind */
{
    int i,j,r=FALSE;
    
    for(i=0;i<anz;i++)
    {
        if(strcmp(n,pname[i])!=0) continue;
        r=TRUE;
        if(flag)
        {
            wpri[i]=(int)Prenice(id,0);
        }
        else
        {
            for(j=0;j<50 && p!=wpri[i];j++)
            {
                if(p<wpri[i]) Prenice(id,-1);
                else if(p>wpri[i]) Prenice(id,1);
                p=(int)Prenice(id,0);
            }
        }
    }
    return(r);
} /* check_pri */

void add_entry(char *n, int pri)
/* Nimmt einen Eitrag in die Liste auf */
{
    int i;
    
    for(i=0;i<anz;i++)
    {
        if(strcmp(n,pname[i])==0)
        {
            form_alert(1,"[1][ |Name ist bereits|vorhanden!][ OK ]");
            return;
        }
    }
    if(anz>=MAX_PROZ)
    {
        form_alert(1,"[1][ |Interne Liste|ist voll!][ OK ]");
        return;
    }
    strcpy(pname[anz],n);
    wpri[anz]=pri;
    anz++;  
} /* add_entry */

void del_entry(char *n)
/* Entfernt einen Eintrag aus der Liste */
{
    int i,j;
    
    for(i=0;i<anz;i++)
    {
        if(strcmp(n,pname[i])==0)
        {
            anz--;
            for(j=i;j<anz;j++)
            {
                strcpy(pname[j],pname[j+1]);
                wpri[j]=wpri[j+1];
            }
            return;
        }
    }
} /* del_entry */
