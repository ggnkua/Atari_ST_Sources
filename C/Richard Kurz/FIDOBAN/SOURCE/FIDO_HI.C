/* FIDO_HI.C
 * Highscore-Teil fÅr FIDOBAN
 * 1992 by Richard Kurz
 * Vogelherdbogen 62
 * 7992 Tettnang
 * Fido: 2:241/7232.5
 *
 * fÅr's TOS Magazin
 * ICP Verlag
 */

#include <tos.h>
#include <ext.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <screen.h>
#include "fidoban.h"

HSCORE score[200];
int anz_spieler;
int spieler_pos;
int hi_level;
long hi_step;
char name[100];
char hi_name[100];

static char s[100];

extern long step;
extern int level,old_level;

void get_h_zeile(char *sc,char *n,int *l, long *st)
/* Decodiert eine Zeile aus dem Highscore-File */
{
    int i;

    for(i=0;(sc[i]!=',')&&i<80;i++)
        n[i]=sc[i];
    n[i]=0;
    i++;
    *l=atoi(&sc[i]);
    for(;(sc[i]!=',')&&i<80;i++);
    i++;
    *st=atol(&sc[i]);
} /* get_h_zeile */

int ver_score(HSCORE *h1, HSCORE *h2)
/* Vergleichs-Routine fÅr die Highscore-Sortierung */
{
    if(h1->level > h2->level) return(-1);
    if(h1->level < h2->level) return(1);
    if(h1->level == h2->level)
    {
        if(h1->step > h2->step) return(1);
        if(h1->step < h2->step) return(-1);
    }
    return(0);
}

void sort_score(void)
/* Sortiert die HighscoreeintrÑge */
{
    int i;
    
    qsort(score,anz_spieler,sizeof(HSCORE),ver_score);
    strcpy(hi_name,score[0].name);
    hi_step=score[0].step;
    hi_level=score[0].level+1;
    for(i=0;i<anz_spieler;i++)
    {
        if(strcmp(name,score[i].name)==0)
        {
            spieler_pos=i;
            break;
        }
    }
} /* sort_score */

int load_score(void)
/* lÑdt den Highscore */
{
    FILE *f;
    int i;
    static char pfad[256];

    memset(pfad,0,255);
    pfad[0]=Dgetdrv()+'A';
    pfad[1]=':';
    Dgetpath(&pfad[2],0);
    if(pfad[strlen(pfad)-1]!='\\') strcat(pfad,"\\");
    strcat(pfad,"fidoban.scr");
    f=fopen(pfad,"r");
    if(f==NULL) return(FALSE);
    memset(score,0,sizeof(score));
    for(i=0;i<200;i++)
    {
        if(fgets(s,80,f)==NULL) break;
        get_h_zeile(s,score[i].name,&score[i].level,&score[i].step);
    }
    fclose(f);
    anz_spieler=i;

    spieler_pos=-1;
    sort_score();
    if(spieler_pos>=0)
    {
        old_level=level=score[spieler_pos].level+1;
        step=score[spieler_pos].step;
        return(TRUE);
    }
    old_level=1;
    level=1;
    step=0;
    anz_spieler++;
    if(anz_spieler>199)
    {
        out_string("\n\rSorry, wir sind VOLL!!");
        out_string("\n\rIm Moment koennen nur 200 mitspielen :-(");
        out_string("\n\r<SPACE>");
        while(hole_tast()!=' ');
        fini(6);
    }
    spieler_pos=i=anz_spieler-1;
    strcpy(score[i].name,name);
    score[i].level=0;
    score[i].step=0;
    return(TRUE);
}/* load_score */

int save_score(void)
/* Sichert den Highscore */
{
    FILE *f;
    int i;
    static char pfad[256];

    memset(pfad,0,255);
    pfad[0]=Dgetdrv()+'A';
    pfad[1]=':';
    Dgetpath(&pfad[2],0);
    if(pfad[strlen(pfad)-1]!='\\') strcat(pfad,"\\");
    strcat(pfad,"fidoban.scr");
    f=fopen(pfad,"wb");
    if(f==NULL) return(FALSE);
    for(i=0;i<anz_spieler;i++)
    {
        sprintf(s,"%s,%i,%li\r\n",score[i].name,score[i].level,score[i].step);
        if(fwrite(s,strlen(s),1,f)!=1)
        {
            fclose(f);
            return(FALSE);
        }
    }
    fclose(f);
    return(TRUE);
} /* save_score */

void disp_score(void)
/* Zeigt den aktuellen Highscore an */
{
    gotoxy(65,7);
    sprintf(s,"%4li",step);
    out_string(s);
} /* disp_score */

void show_score(void)
/* Zeigt die Highscoreliste an */
{
    int i,z;
    
    sort_score();
    cls();
    for(i=0,z=0;i<anz_spieler;i++,z++)
    {
        if(z==0)
        {
            out_string("--Name-------------------------------------+-Level-----+-Schritte---\r\n");
        }
        sprintf(s,"  %-40s | %5i     | %5li      \r\n",score[i].name,score[i].level+1,score[i].step);
        if(i==0) invers(TRUE);
        out_string(s);
        if(i==0) invers(FALSE);
        if(z>19)
        {
            z=-1;
            out_string("<TASTE>\r\n");
            if(hole_tast()=='s') return;
        }
    }
    out_string("<TASTE>");
    hole_tast();
} /* show_score */
