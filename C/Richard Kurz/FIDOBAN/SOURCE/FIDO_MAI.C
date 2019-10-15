/* FIDO_MAI.C
 * Main-Teil fÅr FIDOBAN
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

/* Globale Variablen */
int Done;
int level=1,old_level=1;
long step=0;

/* Externe Variablen */
extern unsigned long online_time,in_time;

extern int anz_spieler;
extern int spieler_pos;
extern char name[100];
extern char hi_name[100];

extern int cd_flag;
extern int rs_flag;
extern int vt_flag;

extern HSCORE score[200];
extern hi_level;
extern long hi_step;
extern int sx,sy;
extern char g_feld[20][20];
extern char l_feld[20][20];

/* Locale Variablen */
static int off_x,off_y;
static char s[85];
static char u_feld[20][20];
static char t_feld[20][20];

/* Nu geht's los */
void meldung(char *s)
/* Gibt einen String invers im Meldungs-Bereich aus. */
{
    gotoxy(44,11);
    out_string("                                    ");
    if(*s)
    {
        gotoxy(44,11);
        invers(TRUE);
        out_string(" ");
        out_string(s);
        out_string(" ");
        invers(FALSE);
    }
} /* meldung */

int get_level(void)
/* LÑdt einen Level. */
{
    int x,y,mx,my;
    
    if(load_feld(level))
    {
        for(y=0,my=0,mx=0;y<20;y++)
        {
            for(x=0;x<20;x++)
            {
                if(g_feld[x][y]!=' ' && x > mx) mx=x;
                if(g_feld[x][y]!=' ' && y > my) my=y;
            }
        }
        memcpy(u_feld,g_feld,sizeof(u_feld));
    }
    else
    {
        if(level>50)
        {
            cls();
            invers(TRUE);
            out_string("\r\nGratulation!!!!!!!!!! <Space>");
            while(hole_tast()!=' ');
            out_string("\r\nDu hast es geschaft!! <Space>");
            while(hole_tast()!=' ');
            out_string("\r\nSchreibs deinem SysOp <Space>");
            while(hole_tast()!=' ');
            invers(FALSE);
            sprintf(score[spieler_pos].name," !! %s",name);
            save_score();
            return(FALSE);
        }
        else
        {
            cls();
            out_string("\n\rSYSOP ERROR: Der Level fehlt!!!");
            out_string("\n\r<SPACE>");
            while(hole_tast()!=' ');
            Done=TRUE;
            fini(4);
        }
    }
    mx*=2;
    off_x=(40-mx)/2;
    off_y=(20-my)/2;
    return(TRUE);
} /* get_level */

void disp_score(void)
/* Zeigt den aktuellen Spielstand an. */
{
    gotoxy(65,7);
    sprintf(s,"%4li",step);
    out_string(s);
} /* disp_score */

void bild_aufbau(void)
/* Hier wird das Spielfeld auf dem Bildschirm aufgebaut. */
{
    int x,y;
        
    cls();
    for(y=0;y<14;y++)
    {
        gotoxy(42,y);
        switch(y)
        {
            case 0:
                out_string("|");
                invers(TRUE);
                out_string("        FidoBan V 1.1  (c)1992       ");
                invers(FALSE); break;
            case 1:
                out_string("|");
                invers(TRUE);
                out_string("     by Richard Kurz  2:241/7232     ");
                invers(FALSE); break;
            case 3:
                out_string("| Highscore: "); 
                out_string(hi_name); break;
            case 4:
                sprintf(s,"| Level: %3i  Schritte:%4li",hi_level,hi_step);
                out_string(s); break;
            case 6:
                out_string("| Spieler: ");
                out_string(name); break;
            case 7:
                sprintf(s,"| Level: %3i  Schritte: ",level);
                out_string(s); break;
            case 9:
                out_string("+-Meldungen---------------------------"); break;
            case 10:
                sprintf(s,"|                       Restzeit:%4i",1+(int)((online_time-(time(NULL)-in_time))/60));
                out_string(s); break;
            case 13:
                out_string("+-Legende-----------------------------"); break;
            default:
                out_string("|"); break;
        }
    }
    gotoxy(42,14);
    out_string("| @@ Das bist Du");
    gotoxy(42,15);
    out_string("| "); invers(TRUE);out_char('@');invers(FALSE);
    out_string(" Du auf dem Parkplatz");
    gotoxy(42,16);
    out_string("| $$ Die Kisten");
    gotoxy(42,17);
    out_string("| "); invers(TRUE);out_char('$');invers(FALSE);
    out_string(" Geparkte Kisten");
    gotoxy(42,18);
    out_string("| .. Hier muessen die Kisten hin");
    gotoxy(42,19);
    out_string("| "); invers(TRUE);out_char('#');invers(FALSE);
    out_string(" Die Mauer (Auah)");

    gotoxy(0,20);
    out_string("-Bewegung-----------+-Kontrolle-----------+-------------------------------------");
    gotoxy(0,21);
    out_string("        8   Rauf    | X Ende                H  Highscore-Liste");
    gotoxy(0,22);
    out_string("Links 4   6 Rechts  | U Ein Zug zurueck     ^R Bildschirm neu zeichnen");
    gotoxy(0,23);
    out_string("        2   Runter  | R Level neu starten");
    disp_score();

    for(y=0;y+off_y<20;y++)
    {
        gotoxy(off_x,off_y+y);
        for(x=0;off_x+2*x<40;x++)
        {
            switch(g_feld[x][y])
            {
                case '@': sx=x; sy=y;
                case '$':
                    if(l_feld[x][y]!=' ')
                    {
                        invers(TRUE);
                        out_char(g_feld[x][y]);
                        invers(FALSE);
                        break;
                    }
                case ' ':
                case '.':
                    out_char(g_feld[x][y]);
                    break;
                case '#':
                    invers(TRUE);
                    out_char(g_feld[x][y]);
                    invers(FALSE);
                    break;
                
            }
        }
    }
} /* bild_aufbau */

void setze_stein(int x, int y,int farbe)
/* Positioniert die Spielerfigur. */
{
    gotoxy(off_x+x*2,off_y+y);
    if(farbe=='.' || l_feld[x][y]==' ')
    {
        out_char(farbe);
    }
    else
    {
        invers(TRUE);
        out_char(farbe);
        invers(FALSE);
    }
} /* setze_stein */

int play_it(void)
/* Das Intro und die Hauptschleife */
{
    int t,r;

    cls();
    if(!load_score())
    {
        out_string("\n\rSYSOP ERROR: Highscore-Liste <FIDOBAN.SCR> fehlt!!!");
        out_string("\n\r<SPACE>");
        while(hole_tast()!=' ');
        fini(5);
    }
    if(level>0)
    {
        gotoxy(20,5);
        invers(TRUE);
        out_string(" Willkommen zu FidoBan ");
        out_string(name);
        out_string("! ");
        invers(FALSE);
        sprintf(s,"Du bist im %i. Level mit %li Schritten,",level,step);
        gotoxy(20,7);
        out_string(s);
        sprintf(s,"also %i. von %i!",spieler_pos+1,anz_spieler);
        gotoxy(20,8);
        out_string(s);
        gotoxy(20,9);
        out_string(hi_name);
        out_string(" haelt den Highscore.");
        sprintf(s,"Er hat den %i. Level mit %li Schritten.",hi_level,hi_step);
        gotoxy(20,10);
        out_string(s);
        gotoxy(20,12);
        out_string("[1]  Weitermachen");
        gotoxy(20,13);
        out_string("[2]  Neu anfangen");
        gotoxy(20,14);
        out_string("[X]  Zurueck in die Mailbox");
        gotoxy(20,16);
        out_string("<Deine Wahl?>");
        
        t=hole_tast();  
        if(t=='2')
        {
            gotoxy(20,18);
            out_string("Wirklich neu anfangen? J/N");
            t=hole_tast();  
            if(t=='J' || t=='j')
            {
                old_level=level=1;
                step=0;
            }
        }
        else if(t!='1')
        {
            return(0);
        }   
    }

    Done=FALSE;
    out_string(CUR_OFF);
    get_level();
    bild_aufbau();

/* Hier geht's nun wirklich los! */
    while(!Done)
    {
        memcpy(t_feld,g_feld,sizeof(t_feld));
        t=hole_tast();
        meldung("");
        r=FALSE;
        switch(t)
        {
            case 255:
                if(Done)
                {
                    meldung("Deine Zeit ist abgelaufen");
                }
                break;
            case '8': r=spieler_zug(RAUF);      break;
            case '2': r=spieler_zug(RUNTER);    break;
            case '4': r=spieler_zug(LINKS);     break;
            case '6': r=spieler_zug(RECHTS);    break;
            
            case 'r':
            case 'R':
                meldung("Echt? J/N");
                t=hole_tast();
                if(t=='j' || t=='J')
                {
                    get_level();
                    bild_aufbau();
                }
                else
                {
                    meldung("Dann halt nicht");
                }
                break;
            case 18:
                bild_aufbau();
                break;
            case 'u': case 'U':
                memcpy(t_feld,u_feld,sizeof(t_feld));
                memcpy(u_feld,g_feld,sizeof(u_feld));
                memcpy(g_feld,t_feld,sizeof(g_feld));
                bild_aufbau();
                break;
            case 'h': case 'H':
                show_score();
                bild_aufbau();
                break;
            case 'x':
            case 'X':
                meldung("Wirklich aufhoeren J/N");
                t=hole_tast();
                if(t=='j' || t=='J')
                {
                    Done=TRUE;
                }
                else
                {
                    meldung("Dann halt nicht");
                }
                break;
        default:
            meldung("Haeh?");
            break;
        }
        switch(r)
        {
            case OKAY:
                step++;
                memcpy(u_feld,t_feld,sizeof(u_feld));
                break;          
            case BOING:
                step++;
                meldung("BOING");
                break;
            case FERTIG:
                meldung("Gratulation! <Space>");
                while(hole_tast()!=' ');
                score[spieler_pos].level=level;
                score[spieler_pos].step=step;
                level++;
                sort_score();
                if(!get_level()) return(0);
                bild_aufbau();
                break;
            default:
                break;
        }
        disp_score();
    }
    if(level>old_level)
    {
        if(!save_score())
        {
            cls();
            out_string("\n\rSYSOP ERROR: Die Highscore-Liste");
            out_string("\n\rkonnte nicht gesichert werden. :-(");
            out_string("\n\r<SPACE>");
            while(hole_tast()!=' ');
            fini(7);
        }
    }
    return(0);
} /* play_it */

int main(int argc, const char *argv[])
/* Hier werden die Kommandozeilenparameter ausgewertet und */
/* die Flags gesetzt.                                      */
{
    int t;
    
    in_time=time(NULL);
    if(argc>5 || argc<4) fini(3);
    if(argc>=4)
    {
        sprintf(name,"%s %s",argv[1],argv[2]);
        online_time=(unsigned long)atol(argv[3])*60;
        if(carrier_detect())
        {
            rs_flag=TRUE;
            cd_flag=TRUE;
        }
        else
        {
            rs_flag=FALSE;
            cd_flag=FALSE;
            vt_flag=TRUE;
        }
    }
    if(argc==5)
    {
        if(argv[4][0]=='n' || argv[4][0]=='N')
        {
            rs_flag=FALSE;
            cd_flag=FALSE;
        }
        else if(argv[4][0]=='o' || argv[4][0]=='O')
        {
            rs_flag=TRUE;
            cd_flag=FALSE;
        }
        else fini(3);
        online_time=atoi(argv[3])*60;
    }
    
    while(Cauxis()) Cauxin();
    while(Cconis()) Cconin();

    if(online_time<=60)
    {
        cls();
        out_string("\n\n\rSorry, aber deine Zeit reicht nicht mehr\n\r");
        out_string("<Taste> ");
        hole_tast();
        return(0);
    }
    
    for(t=0;t<50;t++) out_string("\n");
    out_string("\n\rFidoBan 1992 by Richard Kurz");
    out_string("\n\rVogelherdbogen 62");
    out_string("\n\r7992 Tettnang (FRG)");
    out_string("\n\r2:241/7232\n\r");
    out_string("\n\rfuer's TOS-Magazin\n\r");

    if(rs_flag)
    {
        out_string("\n\r\n\rIst die vt52 Emulation eingeschaltet? J/N ");
        t=hole_tast();
        if(t!='j' && t!='J')
        {
            out_string("\n\r\n\rSorry, FidoBan laeuft nur mit vt52");
            out_string("\n\r\n\r<TASTE>");
            hole_tast();
            out_string("\n\r\n\rTschuess>");
            return(0);
        }
        out_string(CUR_OFF);
        out_string("\n\n\rWenn diese Zeile zu lesen ist, bitte Taste <N> druecken\n\r");
        cls();
        invers(TRUE);invers(FALSE);
        invers(TRUE);invers(FALSE);
        invers(TRUE);invers(FALSE);
        out_string("\n\rIst der Bildschirm leer? (ausser dieser Zeile!) J/N ");
        t=hole_tast();      
        if(t=='j' || t=='J') vt_flag=TRUE;
        else vt_flag=FALSE;
    }
    else
    {
        out_string("\n\r    <TASTE>");
        hole_tast();
        out_string(CUR_OFF);
    }
    return(play_it());
} /* main */
