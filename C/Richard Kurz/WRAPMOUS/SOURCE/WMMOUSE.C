/*  WRAP Mouse
 *  Mouse-Teil
 *
 *  (c)1992 by Richard Kurz
 *  Vogelherdbogen 62
 *  7992 Tettnang
 *  Fido 2:241/7232
 *
 *  fÅr's TOS-Magazin
 *
 *  Erstellt mit Pure C
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include <linea.h>
#include <wrapauto.h>


/* externe Variablen                            */
extern INF inf;
extern long old_mouse;
extern SYSHDR *sh;
extern int ap;

/* globale Variablen                            */
int last_mouse=0xf8;

void do_speed(RELMOUSE *m, int dev)
{
    long x,y,xm,ym;
    int i;
    
    if(m->dx<0) {xm=TRUE;x=-1*m->dx;}
    else        {xm=FALSE;x=m->dx;}
    if(m->dy<0) {ym=TRUE;y=-1*m->dy;}
    else        {ym=FALSE;y=m->dy;}

    for(i=5;i>=0;i--)
    {
        if(x>=inf.d[dev].mw[i])
        {
            x=(x*400L)/((long)(41-inf.d[dev].mf[i])*10L);
            break;
        }
    }
    for(i=5;i>=0;i--)
    {
        if(y>=inf.d[dev].mw[i])
        {
            y=(y*400L)/((long)(41-inf.d[dev].mf[i])*10L);
            break;
        }
    }
    if(x>127) x=127;
    if(y>127) y=127;
    if(xm) x=0-x;
    if(ym) y=0-y;
    m->dx=(char)x;
    m->dy=(char)y;
}/* do_speed */

void do_wrap(RELMOUSE *m, int dev)
{
    static int rl,rr,ro,ru;
    RELMOUSE nm;
    int i;
    
    nm.head=m->head;
    if(Vdiesc->cur_y==0)
    {
        if(m->dy<0)
        {
            if(++ro>inf.d[dev].rand[3])
            {
                ro=0;nm.dy=100;nm.dx=0;
                i=Vdiesc->v_rez_vt/100;
                for(;i>0;i--) set_mouse(&nm);
                nm.dy=Vdiesc->v_rez_vt%100;
                if(nm.dy) set_mouse(&nm);
                return;
            }
        }
    }
    else ro=0;

    if(Vdiesc->cur_y==Vdiesc->v_rez_vt-1)
    {
        if(m->dy>0)
        {
            if(++ru>inf.d[dev].rand[2])
            {
                ru=0;nm.dy=-100;nm.dx=0;
                i=Vdiesc->v_rez_vt/100;
                for(;i>0;i--) set_mouse(&nm);
                nm.dy=-(Vdiesc->v_rez_vt%100);
                if(nm.dy) set_mouse(&nm);
                return;
            }
        }
    }
    else ru=0;
    
    if(Vdiesc->cur_x==0)
    {
        if(m->dx<0)
        {
            if(++rl>inf.d[dev].rand[0])
            {
                rl=0;nm.dy=0;nm.dx=100;
                i=Vdiesc->v_rez_hz/100;
                for(;i>0;i--) set_mouse(&nm);
                nm.dx=Vdiesc->v_rez_hz%100;
                if(nm.dx) set_mouse(&nm);
                return;
            }
        }
    }
    else rl=0;

    if(Vdiesc->cur_x==Vdiesc->v_rez_hz-1)
    {
        if( m->dx>0)
        {
            if(++rr>inf.d[dev].rand[1])
            {
                rr=0;nm.dy=0;nm.dx=-100;
                i=Vdiesc->v_rez_hz/100;
                for(;i>0;i--)set_mouse(&nm);
                nm.dx=-(Vdiesc->v_rez_hz%100);
                if(nm.dx) set_mouse(&nm);
                return;
            }
        }
    }
    else rr=0;
}/* do_wrap */

void do_changes(RELMOUSE *m)
{
    static int tf,df;
    static RELMOUSE nm;
        
    if(inf.pf[ap].c_flag)
    {
        if(m->head==0xf9) m->head=0xfa;
        else if(m->head==0xfa) m->head=0xf9;
    }

    if(inf.pf[ap].t_flag && !inf.pf[ap].d_flag)
    {
        if(m->head&1)
        {
            (*(char *)sh->kbshift)|=(char)inf.pf[ap].t_flag;
            tf=TRUE;
            m->head&=~1;
        }
        else if(tf)
        {
            (*(char *)sh->kbshift)&=~((char)inf.pf[ap].t_flag);
            tf=FALSE;
        }
    }
    else if(inf.pf[ap].d_flag)
    {
        if(inf.pf[ap].t_flag)
        {
            if(df && m->head==0xfb)
            {
                (*(char *)sh->kbshift)|=(char)inf.pf[ap].t_flag;
                tf=TRUE;
                m->head&=~1;
                return;
            }
            else if(tf && !df)
            {
                (*(char *)sh->kbshift)&=~((char)inf.pf[ap].t_flag);
                tf=FALSE;
            }
        }
        if(m->head==0xf9)
        {
            df=TRUE;
            m->head=0xf8;
        }
        else if(!tf && df && m->head==0xf8)
        {
            df=FALSE;
            nm.head=0xfa;
            set_mouse(&nm);
            nm.head=0xf8;
            set_mouse(&nm);
            nm.head=0xfa;
            set_mouse(&nm);
            m->head&=0xf8;
        }
        else
        {
            if(tf)
            {
                (*(char *)sh->kbshift)&=~((char)inf.pf[ap].t_flag);
                tf=FALSE;
            }
            df=FALSE;
        }
    }
}/* do_changes */

void chk_mouse(RELMOUSE *m)
{
    do_changes(m);
    last_mouse=m->head;
        
    if(inf.d[0].s_flag) do_speed(m,0);
    if(inf.d[0].w_flag) do_wrap(m,0);
} /* chk_mouse */

int do_switch(char *t)
{
    static char fn[80];
    int i;
    char *n;

    if(inf.sa.tiefe>=MAX_PROG) return(FALSE);

    n=strrchr(t,'\\');
    if(n)strcpy(fn,++n);
    else strcpy(fn,t);
    
    for(i=0;i<MAX_PROG;i++)
    {
        if(!strcmp(fn,inf.pf[i].name))
        {
            inf.sa.nap[inf.sa.tiefe]=ap;
            ap=i;
            inf.sa.tiefe++;
            return(TRUE);
        }
    }
    return(FALSE);
} /* do_switch */

void end_switch(void)
{
    if(inf.sa.tiefe<=0) return;
    inf.sa.tiefe--;
    ap=inf.sa.nap[inf.sa.tiefe];
} /* end switch */
