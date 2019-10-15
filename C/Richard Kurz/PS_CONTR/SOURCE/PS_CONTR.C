/*
 * PS-Control
 * Main-Teil
 * September 1992 by Richard Kurz
 * fÅr's TOS-Magazin
 */

#include <aes.h>
#include <stdio.h>
#include <stdlib.h>
#include <tos.h>
#include <string.h>
#include <portab.h>

#include "mintbind.h"

#include "ps_glob.h"
#include "ps_contr.h"
#include "ps_contr.rh"
#include "ps_contr.rsh"

extern HWINDOW *win[MAX_WINDOW];    /* Zeiger auf die Fensterliste  */

int entrys;                         /* Anzahl der EintrÑge          */

static PINFO proc;                  /* Die Prozessinformationen     */
static XATTR xa;                    /* Informationen von Fxattr     */
static char screen[MAX_PROZ][80];   /* Puffer fÅr den Bildschirm    */
static char psname[MAX_PROZ][15];   /* Puffer fÅr die Prozessnamen  */
static int pid[20];                 /* Puffer fÅr die ID's          */
static int ps_win;                  /* Die Nummer des Hauptfensters */
static OBJECT *dialog;              /* Der Hauptdialog              */
static OBJECT *psinfo[4];           /* Die Informationdialoge       */
static OBJECT *help;                /* Der Dialog fÅr die Hilfe     */
static OBJECT *info;                /* Der Informationdialog        */

static void do_hilfe(void);

static int al_button(int b,int w)
/* Allgemeiner Button-Handler */
{
    win[w]->obj[b].ob_state &= ~SELECTED;
    close_window(win[w]->handle);
    return(TRUE);
}/* al_button */

static int al_tast(int t,int w)
/* Allgemeiner Tasten-Handler */
{
    int ascii,scan;

    ascii=t<<8;ascii>>=8;
    scan=t>>8;
    
    if(Kbshift(-1) & 4)
    {
        ascii+=0x60;
        switch(ascii)
        {
            case 'q': return(FALSE);
            default:  break;
        }
    }
    else if(scan==0x62) do_hilfe();
    else if(scan==0x61)
    {
        close_window(win[w]->handle);
        return(!win[w]->end);
    }
    return(TRUE);
}/* al_tast */

static void do_info(void)
/* ôffnet das Info-Fenster */
{
    static HWINDOW iw;
    
    if(iw.wopen) wind_set(iw.handle,WF_TOP,0,0,0,0);
    else
    {
        iw.obj=info;
        iw.do_button=al_button;
        iw.do_wtast=al_tast;
        iw.kind=NAME|MOVER;
        iw.title=" PS-Control / Info ";
        if(!open_window(&iw)) return;
    }
} /* do_info */

static void do_hilfe(void)
/* ôffnet das Hilfe-Fenster */
{
    static HWINDOW hw;
    
    if(hw.wopen) wind_set(hw.handle,WF_TOP,0,0,0,0);
    else
    {
        hw.obj=help;
        hw.do_button=al_button;
        hw.do_wtast=al_tast;
        hw.kind=NAME|MOVER;
        hw.title=" PS-Control / Hilfe ";
        if(!open_window(&hw)) return;
    }
} /* do_hilfe */

static int get_inf(char *name)
/* Liest den aktuellen Zustand des Systems */
{
    long ctxtsize;
    long place;
    int fd;
    char file[PATH_MAX];
    
    strcpy(file,"U:\\PROC\\");
    strcat(file,name);
    fd=open(file,O_RDONLY);
    if(fd<0) return(FALSE);
    Fcntl(fd, &place, PPROCADDR);
    if(Fcntl(fd,&ctxtsize,PCTXTSIZE)<0)
        lseek(fd, place+4+2*sizeof(CONTEXT), 0);
    else
        lseek(fd, place, 0);
    read(fd,&proc,sizeof(proc));
    close(fd);
    Fxattr(1,file,&xa);
    return(TRUE);
} /* get_inf */

static void show_inf(int e,int draw)
/* ôffnet & aktuallisiert die Prozess-Fenster */
{
    static HWINDOW siw[4];
    static int oldi[4];
    static struct {int nr;char text[10];}
    statn[7]={0,"Ready",0x01,"Ready",0x20,"Wait",0x21,"Sleep",0x22,"Exit", 0x02,"TSR",0x24,"Stop"};

    int ai,i;
    
    if(draw)
    {
        for(i=0;i<4;i++)
        {
            if(oldi[i]==e && siw[i].wopen)
                {ai=i;break;}
        }
    }
    else
    {
        for(i=0;i<4;i++)
        {
            if(!siw[i].wopen || (oldi[i]==e && siw[i].wopen))
                {oldi[i]=e;ai=i;break;}
        }

    }
    if(i==4)
    {
        if(!draw)form_alert(1,"[1][PS-Control| |Es gibt nur 4|Info-Fenster][ OK ]");
        return;
    }
    if(!get_inf(psname[e])) return;
    
    for(i=0;i<7;i++) {if(xa.attr==statn[i].nr){psinfo[ai][ITSTATUS].ob_spec.free_string=statn[i].text;break;}}
    if(i==7)psinfo[ai][ITSTATUS].ob_spec.free_string="?????";
    sprintf(psinfo[ai][ISTATUS].ob_spec.free_string,"%-4x",xa.attr);
    sprintf(psinfo[ai][IPRI].ob_spec.free_string,"%-4i",proc.pri);
    sprintf(psinfo[ai][IPID].ob_spec.free_string,"%-4i",proc.pid);
    sprintf(psinfo[ai][ICURPRI].ob_spec.free_string,"%-4i",proc.curpri);
    sprintf(psinfo[ai][IPPID].ob_spec.free_string,"%-4i",proc.ppid);
    sprintf(psinfo[ai][IPSYS].ob_spec.free_string,"%-10li",proc.systime/1000L);
    sprintf(psinfo[ai][IPUSR].ob_spec.free_string,"%-10li",proc.usrtime/1000L);
    sprintf(psinfo[ai][ICSYS].ob_spec.free_string,"%-10li",proc.chldstime/1000L);
    sprintf(psinfo[ai][ICUSR].ob_spec.free_string,"%-10li",proc.chldutime/1000L);
    sprintf(psinfo[ai][ISIZE].ob_spec.free_string,"%-20li",xa.size);

    if(draw)
    {
        wind_set(siw[ai].handle,WF_NAME,siw[ai].title,0,0);
        draw_obj(psinfo[ai],ROOT,MAX_DEPTH,siw[ai].nr);
    }
    else if(siw[ai].wopen)
        wind_set(siw[ai].handle,WF_TOP,0,0,0,0);
    else
    {
        siw[ai].obj=psinfo[ai];
        siw[ai].do_wtast=al_tast;
        siw[ai].kind=NAME|CLOSER|MOVER;
        siw[ai].title=psname[e];
        if(!open_window(&siw[ai])) return;
    }
    return;
} /* show_inf */

static void get_proz(int d_flag,int s_flag)
/* öberwacht den aktuellen Zustand des Systems und stellt ihn dar */
{
    static char ts[80],name[PATH_MAX];
    long d;
    int i;
    char v,*s;
    
    /* Im Ordner U:\PROC sind die Informationen zu den aktuellen */
    /* Prozessen enthalten.                                      */
    d=Dopendir("U:\\PROC",0);
    if((d&0xff000000L)==0xff000000L)
        return;

    for(entrys=0;!Dreaddir(PATH_MAX,d,name) && entrys<VISENTRYS;)
    {
        if(get_inf(&name[4]))
        {
            strcpy(psname[entrys],&name[4]);

            s=strchr(&name[4],'.');
            if(s!=NULL)
            {
                *s=0;
                /* Stimmt die PrioritÑt? */
                if(check_pri(&name[4],proc.pid,proc.pri,s_flag)) v=9;
                else v=' ';
                pid[entrys]=proc.pid;

                sprintf(ts,"%c%-8s %3i %4i %2x %7li %8li ",v,&name[4],proc.pid,(int)proc.pri,(int)xa.attr,(proc.systime + proc.usrtime)/1000L,xa.size);
                if(strcmp(ts,screen[entrys])!=0)
                {
                    strcpy(screen[entrys],ts);
                    if(d_flag)
                    {
                        draw_obj(dialog,ZEILE1+entrys,MAX_DEPTH,ps_win);
                        show_inf(entrys,TRUE);
                    }
                }
                entrys++;
            }
        }
    }
    Dclosedir(d);
    
    for(i=0;i<VISENTRYS;i++)
    {
        if(i<entrys) dialog[ZEILE1+i].ob_flags |= TOUCHEXIT;
        else
        {
            dialog[ZEILE1+i].ob_state &= ~SELECTED;
            dialog[ZEILE1+i].ob_flags &= ~TOUCHEXIT;
            if(screen[i][0])
            {
                if(d_flag)
                {
                    strcpy(screen[i],"                                        ");
                    draw_obj(dialog,ZEILE1+i,MAX_DEPTH,ps_win);
                }
                screen[i][0]=0;
            }
        }
    }
} /* get_proz */

static int wm_button(int f,int w)
/* Button-Handler fÅr's Hauptfenster */
{
    static char s[100],*s2;
    int i,mb,mx,my,mk,se,flag,dclick;
    if(f&0x8000)
    {
        dclick=TRUE;
        f&=0x7fff;
    }
    else dclick=FALSE;

    if(f>=ZEILE1 && f<=ZEILE17)
    {
        if(dclick)
        {
            show_inf(f-ZEILE1,FALSE);
            return(TRUE);
        }
        se=dialog[f].ob_state & SELECTED;
        graf_mkstate(&mx,&my,&mb,&mk);
        if(!(mk & 3))
        {
            for(i=0;i<VISENTRYS;i++)
            {
                if(dialog[ZEILE1+i].ob_state & SELECTED)
                {
                    dialog[ZEILE1+i].ob_state &= ~SELECTED;
                    draw_obj(dialog,ZEILE1+i,1,w);
                }
            }
            if(!se) dialog[f].ob_state |= SELECTED;
        }
        else
        {
            if(se) dialog[f].ob_state &= ~SELECTED;
            else dialog[f].ob_state |= SELECTED;
        }
        draw_obj(dialog,f,1,w);
        while(mb&1) graf_mkstate(&mx,&my,&mb,&mk);
        return(TRUE);
    }
    switch(f)
    {
        case SIGNAL:
            dialog[D_FILE].ob_flags |= HIDETREE;
            dialog[D_PRIO].ob_flags |= HIDETREE;
            dialog[D_SIGN].ob_flags &= ~HIDETREE;
            dialog[f].ob_state &= ~SELECTED;
            draw_obj(dialog,D_SIGN,MAX_DEPTH,w);
            return(TRUE);

        case ZURUECK: case ZURUECK2:
            dialog[D_FILE].ob_flags |= HIDETREE;
            dialog[D_SIGN].ob_flags |= HIDETREE;
            dialog[D_PRIO].ob_flags &= ~HIDETREE;
            dialog[f].ob_state &= ~SELECTED;
            draw_obj(dialog,D_PRIO,MAX_DEPTH,w);
            return(TRUE);

        case LOADSAVE:
            dialog[D_SIGN].ob_flags |= HIDETREE;
            dialog[D_PRIO].ob_flags |= HIDETREE;
            dialog[D_FILE].ob_flags &= ~HIDETREE;
            dialog[f].ob_state &= ~SELECTED;
            draw_obj(dialog,D_FILE,MAX_DEPTH,w);
            return(TRUE);

        case LOADI:
             load_inf(NULL);
             break;
        case SAVEI:
             save_inf();
             break;

        case ALLE:
             for(i=0;i<VISENTRYS && i<entrys;i++)
                dialog[i+ZEILE1].ob_state |= SELECTED;
             draw_obj(dialog,DISPLAY,MAX_DEPTH,w);
             break;

        case NIX:
            for(i=0;i<VISENTRYS && i<entrys;i++)
                dialog[i+ZEILE1].ob_state &= ~SELECTED;
            draw_obj(dialog,DISPLAY,MAX_DEPTH,w);
            break;

        case BYRK:
            do_info();
            break;

        case HILFE:
            do_hilfe();
            break; 

        default: 
            for(flag=FALSE,i=0;i<VISENTRYS;i++)
            {
                if(!(dialog[i+ZEILE1].ob_state & SELECTED)) continue;
                flag=TRUE;
                switch(f)
                {
                    case PLUS:  Prenice(pid[i],-1);     break;
                    case MINUS: Prenice(pid[i],1);      break;
                    case MAX:   Prenice(pid[i],-100);   break;
                    case MIN:   Prenice(pid[i],100);    break;
                    case NORM:  Prenice(pid[i],(int)Prenice(pid[i],0)); break;

                    case ADDI: case LOESCHEN:
                        strcpy(s,&screen[i][1]);
                        s2=strchr(s,' ');
                        if(s2!=NULL)
                        {
                            *s2=0;
                            if(f==ADDI)
                            add_entry(s,(int)Prenice(pid[i],0));
                            else if(f==LOESCHEN)
                                del_entry(s);
                         }
                         break;

                    case S_KILL: case S_TERM:
                        if(Pgetpid()==pid[i]) strcpy(s,"[3][ |ACHTUNG!|PS-Control wirklich beenden?][ Ja | Nein]");
                        else sprintf(s,"[2][ |Prozess  Nr. %i|wirklich beenden?][ Ja | Nein]",pid[i]);
                        if(form_alert(2,s)!=1) continue;
                        if(f==S_KILL)      Pkill(pid[i],SIGKILL);
                        else if(f==S_TERM) Pkill(pid[i],SIGTERM);
                        break;

                    case S_STOP: case S_TSTP:
                        if(Pgetpid()==pid[i]) strcpy(s,"[3][ |ACHTUNG!|PS-Control wirklich stoppen?][ Ja | Nein]");
                        else sprintf(s,"[2][ |Prozess Nr. %i|wirklich stoppen?][ Ja | Nein]",pid[i]);
                        if(form_alert(2,s)!=1) continue;
                        if(f==S_STOP)       Pkill(pid[i],SIGSTOP);
                        else if(f==S_TSTP)  Pkill(pid[i],SIGTSTP);
                        break;

                    case S_CONT: Pkill(pid[i],SIGCONT); break;

                    default: flag=TRUE; break;
                }
            }
            if(!flag) form_alert(1,"[1][Bitte zuerst mindestens einen|Prozess durch Anklicken mit|der Maus anwÑhlen][ OK ]");
            get_proz(TRUE,TRUE);
            break;
    }
    if(dialog[f].ob_state & SELECTED)
    {
        dialog[f].ob_state &= ~SELECTED;
        draw_obj(dialog,f,1,w);
    }
    return(TRUE);
} /* wm_button */

static int wm_tast(int t,int w)
/* Tasten-Handler fÅr's Hauptfenster */
{
    int ascii,scan;

    ascii=t<<8;ascii>>=8;
    scan=t>>8;
    
    if(Kbshift(-1) & 4)
    {
        ascii+=0x60;
        switch(ascii)
        {
            case 'q': return(FALSE);
            default:  break;
        }
    }
    else if(scan==0x62)
    {
        dialog[HILFE].ob_state |= SELECTED;
        draw_obj(dialog,HILFE,1,w);
        do_hilfe();
        dialog[HILFE].ob_state &= ~SELECTED;
        draw_obj(dialog,HILFE,1,w);
    }
    else if(scan==0x61) return(FALSE);
    else
    {
        switch(ascii)
        {
            case 'a': case 'A': scan=ALLE; break;
            case 'n': case 'N': scan=NIX; break;
            case 'i': case 'I': scan=BYRK; break;
            case '+': scan=PLUS; break;
            case '-': scan=MINUS; break;
            case '0': scan=NORM; break;
            case '(': scan=MAX; break;
            case ')': scan=MIN; break;
            default: return(TRUE);
        }
        dialog[scan].ob_state |= SELECTED;
        draw_obj(dialog,scan,1,w);
        wm_button(scan,w);
    }
    return(TRUE);
}/* wm_tast */

void gem_main(void)
/* ôffnet das Hauptfenster */
{
    static HWINDOW mw;
    
    get_proz(FALSE,FALSE);

    mw.obj=dialog;
    mw.do_button=wm_button;
    mw.do_wtast=wm_tast;
    mw.end=TRUE;
    mw.kind=NAME|CLOSER|MOVER;
    mw.title=" PS-Control ";
    if(!open_window(&mw)) return;
    ps_win=mw.nr;
    loop();
} /* gem_main */

void init_dialog(void)
/* Initiallisiert unsere Dialoge */
{
    int i,j;
    
    dialog=rs_trindex[DIALOG];
    help  =rs_trindex[HELP];
    info  =rs_trindex[EINFO];
    psinfo[0]=rs_trindex[PSINFO1];
    psinfo[1]=rs_trindex[PSINFO2];
    psinfo[2]=rs_trindex[PSINFO3];
    psinfo[3]=rs_trindex[PSINFO4];

    for(i=0;i<NUM_OBS;i++)
        rsrc_obfix(&rs_object[i],0);

    for(j=0,i=ZEILE1;i<=ZEILE1+VISENTRYS-1;i++,j++)
    {
        dialog[i].ob_spec.tedinfo->te_ptext=screen[j];
    }   
    dialog[D_SIGN].ob_flags |= HIDETREE;
    dialog[D_SIGN].ob_x=dialog[D_PRIO].ob_x;
    dialog[D_FILE].ob_flags |= HIDETREE;
    dialog[D_FILE].ob_x=dialog[D_PRIO].ob_x;
    load_inf("PS_CONTR.INF");
} /* init_dialog */

void do_timer(void)
/* Wenn die Zeit gekommen ist..... */
{
    if(win[ps_win] && win[ps_win]->wopen) get_proz(TRUE,FALSE);
    else get_proz(FALSE,FALSE);
}/* do_timer */

