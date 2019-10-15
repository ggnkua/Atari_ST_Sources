/* FIDO_RS.C
 * RS232 Routinen fÅr FIDOBAN
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

unsigned long online_time,in_time;
unsigned long ot=0;
unsigned long ta,akt_time;

int cd_flag=TRUE;
int rs_flag=TRUE;
int vt_flag=TRUE;
static char st[100];

extern int Done;

void fini(int f)
/* Das Ende mit Schrecken! */
{
    Clear_home();
    puts("FidoBan (c)1992 by Richard Kurz");
    puts("Vogelherdbogen 62");
    puts("7992 Tettnang (FRG)");
    puts("2:241/7232\n");
    puts("fuer's TOS-Magazin");
    puts("FEHLER:\n");
    
    if(f==1 && cd_flag)
    {
        puts("Und wieder war der Carrier wech :-(");
    }
    else if(f==2)
    {
        puts("Time Out RS232 :-(");
    }
    else if(f==3)
    {
        puts("Falsche Parameter!!");
    }
    else if(f==4)
    {
        puts("Level fehlt!!");
    }
    else if(f==5)
    {
        puts("Highscore-Liste <FIDOBAN.SCR> fehlt!!");
    }
    else if(f==6)
    {
        puts("Zuviele Mitspieler!!");
    }
    else if(f==7)
    {
        puts("Highscore-Liste <FIDOBAN.SCR> konnte nicht gesichert werden!!");
    }
    else
    {
        printf("INTERNER FEHLER Nr. %i",f);
    }
    puts("\nfidoban.ttp vorname name zeit [flag]\n");
    puts("Vorname, Name und Zeit muessen angegeben werden.");
    puts("flag ist optional! Folgende Werte sind moeglich:");
    puts(" o  Online Spiel ohne Carrier Detect");
    puts(" n  Spiel nur an der Console");
    exit(f);
} /* fini */

int carrier_detect(void)
/* Nu wo ist denn der Carrier */
{
    long ssp;
    char reg;
    char *mfp=(char *)(0xfffa01L);
    
    if(!cd_flag) return(TRUE);
    ssp=Super(0L);
    reg=*mfp;
    Super((void *)ssp);
    
    if(!(reg & 2)) return(TRUE);
    return(FALSE);
} /* carrier_detect */

void rs_out(int c)
/* Gibt ein Zeichen auf der seriellen Schnittstelle aus. */
{
    long zeit;
    
    if(!rs_flag) return;
    if(!carrier_detect()) fini(1);
    zeit=time(NULL);
    for(;;)
    {
        if(Cauxos())
        {
            Cauxout(c);
            return;
        }
        if(time(NULL)>zeit+30) fini(2);
    }
} /* rs_out */

void out_string(char *s)
/* Gibt einen String auf der seriellen Schnittstelle und */
/* der Console aus.                                      */
{
    char *z;
    for(z=s;*z;z++) rs_out(*z);

    printf(s);
} /* out_string */

void out_char(int c)
/* Gibt ein Zeichen doppelt auf der seriellen Schnittstelle */
/* und der Console aus.                                     */
{
    rs_out(c);
    rs_out(c);

    printf("%c%c",c,c);
} /* out_char */

void gotoxy(int x, int y)
/* Positioniert den Cursor. */
{
    rs_out(27);
    rs_out('Y');
    rs_out(' '+y);
    rs_out(' '+x);

    Goto_pos(y,x);
} /* gotoxy */

void invers(int flag)
/* Schaltet auf inverse Darstellung um. */
{
    if(vt_flag)
    {
        if(flag) out_string(REV_ON);
        else out_string(REV_OFF);
    }
    if(flag) Rev_on();
    else Rev_off();
}/* invers */

void cls(void)
/* Loescht den Bildschirm */
{
    int i;
    
    if(vt_flag)
    {
        out_string(CLEAR_HOME);
    }
    else
    {
        for(i=0;i<50;i++) out_string("\n");
        gotoxy(0,0);
    }
} /* cls */

int get_tast(void)
/* Wartet auf einen Tastendruck von RS bzw. Console. */
{
    int t,e,rm;
    
    if(ot==0)ot=time(NULL);
    for(;;)
    {
        if(!carrier_detect())fini(1);
        akt_time=time(NULL);
        if(akt_time>in_time+online_time)
        {
            Done=TRUE;
            return(255);
        }
        if(akt_time>ot+60)
        {
            rm=1+(int)((online_time-(akt_time-in_time))/60);
            sprintf(st,"%4i",rm);
            gotoxy(75,10);
            out_string(st);
            ot=akt_time;
        }
        if(Cconis())
        {
            ta=Cnecin();
            t=(unsigned char)ta;
            e=(int)(ta>>16);
            if(!t)
            {
                switch(e)
                {
                    case 72: return('8');
                    case 80: return('2');
                    case 75: return('4');
                    case 77: return('6');
                    default: return('?');
                }
            }
            else
                return(t);
        }
        if(Cauxis())
        {
            t=Cauxin();
            if(t==27)
            {
                e=get_tast();
                switch(e)
                {
                    case 'A': return('8');
                    case 'B': return('2');
                    case 'D': return('4');
                    case 'C': return('6');
                    default: return(e);
                }
            }
            else
                return(t);
        }
    }
} /* get_tast */

int hole_tast(void)
/* Holt eine Taste und lîscht den Buffer. */
{
    int t;
    t=get_tast();
    if(rs_flag) while(Cauxis()) Cauxin();
    while(Cconis()) Cconin();
    if(t==13)t='j';
    return(t);
} /* hole_tast */

