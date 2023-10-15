/*  WRAP Mouse
 *  RS232-Teil
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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include <linea.h>
#include <wrapauto.h>

/* Prototypen aus dem Assemblerteil             */
long ini_m1(void);
long ini_m2(void);
long ini_s1(void);
long ini_s2(void);


/* externe Variablen                            */
extern INF inf;
extern SYSHDR *sh;
extern int last_mouse;
extern int ap;

void init_rs(void)
{
    long old_dev;
    unsigned long ma=0;
    
    get_cookie('_MCH',&ma);
    if(ma<=0x00010000L)
    {
        Rsconf(7,0,136,-1,-1,-1);
        Supexec(ini_m1);
        return;
    }
    
    switch(inf.rp_flag)
    {
        case 1:
            old_dev=Bconmap(6);
            Supexec(ini_m1);
            break;
        case 2:
            old_dev=Bconmap(7);
            Supexec(ini_m2);
            break;
        case 3:
            old_dev=Bconmap(8);
            Supexec(ini_s1);
            break;
        case 4:
            old_dev=Bconmap(9);
            Supexec(ini_s2);
            break;
        default: return;
    }
    Rsconf(7,0,136,-1,-1,-1);
    Bconmap((int)old_dev);
} /* init_rs */

static void do_rschanges(RELMOUSE *m,int mt)
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
        if(mt)
        {
            (*(char *)sh->kbshift)|=(char)inf.pf[ap].t_flag;
            tf=TRUE;
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
            if(df && m->head==0xfa && mt)
            {
                (*(char *)sh->kbshift)|=(char)inf.pf[ap].t_flag;
                tf=TRUE;
                return;
            }
            else if(tf && !df)
            {
                (*(char *)sh->kbshift)&=~((char)inf.pf[ap].t_flag);
                tf=FALSE;
            }
        }
        if(mt)
        {
            df=TRUE;
        }
        else if(!tf && df && !mt)
        {
            df=FALSE;
            nm.head=0xfa;
            set_mouse(&nm);
            nm.head=0xf8;
            set_mouse(&nm);
            nm.head=0xfa;
            set_mouse(&nm);
            nm.head&=0xf8;
            set_mouse(&nm);
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
}/* do_rschanges */

static unsigned char rs[50];
static int rsf;
static RELMOUSE vbm;    

void rs_vbl(void)
{
    static RELMOUSE nmx,nmy;    
    static int wx,wy;
    
    if(!inf.r_flag) return;

    if(rsf)
    {
        rsf=FALSE;
        if(inf.d[1].s_flag) do_speed(&vbm,1);
        if(inf.d[1].w_flag) do_wrap(&vbm,1);

        nmy.head=nmx.head=vbm.head;
        nmx.dx=nmx.dy=nmy.dx=nmy.dy=0;
        
        if(vbm.dx>1 || vbm.dx<-1)
        {
            wx=2;
            nmx.dx=vbm.dx/2;
        }
        else if(vbm.dx)
        {
            wx=1;
            nmx.dx=vbm.dx;
        }

        if(vbm.dy>1 || vbm.dy<-1)
        {
            wy=2;
            nmy.dy=vbm.dy/2;
        }
        else if(vbm.dy)
        {
            wy=1;
            nmy.dy=vbm.dy;
        }
    }
    if(--wy>=0) set_mouse(&nmy);
    if(--wx>=0) set_mouse(&nmx);
}/* rs_vbl */

void chk_rs(unsigned char d)
{
    static int rc;
    
    if(!inf.r_flag) return;

    if(inf.ms_flag)
    {
        if((d&128)&&(d&64)) rc=0;
        else rc++;
        rs[rc]=d;
        
        if(rc>1)
        {
            rc=0;
            vbm.head=0xf8;
            
            if(rs[0]&16) vbm.head|=1;
            else vbm.head&=~1;
            if(rs[0]&32) vbm.head|=2;
            else vbm.head&=~2;

            if(rs[0]&3) vbm.dx=-(192-rs[1]);
            else vbm.dx=rs[1]-128;

            if(rs[0]&12)vbm.dy=-(192-rs[2]);
            else vbm.dy=rs[2]-128;
        
            do_changes(&vbm);
            if(inf.rsm_flag && (last_mouse==vbm.head)) rsf=TRUE;
            else
            {
                last_mouse=vbm.head;
                if(inf.d[1].s_flag) do_speed(&vbm,1);
                if(inf.d[1].w_flag) do_wrap(&vbm,1);
                set_mouse(&vbm);
            }
        }
    }
    else
    {
        rs[rc]=d;
        if(!(rs[0]>=0x80 && rs[0]<=0x87)) rc=0;
        else rc++;
        if(rc>3)
        {
            rc=0;
            vbm.head=0xf8;
            
            if(!(rs[0]&1)) vbm.head|=1;
            else vbm.head&=~1;
            if(!(rs[0]&4)) vbm.head|=2;
            else vbm.head&=~2;

            vbm.dx=rs[1];
            if(rs[2]>128) rs[2]=256-rs[2];
            else rs[2]=-rs[2];
            vbm.dy=rs[2];

            vbm.dx+=rs[3];
            if(rs[4]>128) rs[4]=256-rs[4];
            else rs[4]=-rs[4];
            vbm.dy+=rs[4];
            
            do_rschanges(&vbm,!(rs[0]&2));
            if(inf.rsm_flag && (last_mouse==vbm.head)) rsf=TRUE;
            else
            {
                last_mouse=vbm.head;
                if(inf.d[1].s_flag) do_speed(&vbm,1);
                if(inf.d[1].w_flag) do_wrap(&vbm,1);
                set_mouse(&vbm);
            }
        }
    }
} /* chk_rs */

