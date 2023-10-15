/*  WRAP Mouse
 *  Joystick-Teil
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
extern SYSHDR *sh;
extern int last_mouse;
int ok_vbl;

static int bew1,bew2,bew3,bew4;
static int pause,step;

typedef struct 
{
    unsigned char head;
    unsigned char h2;
    unsigned char val;
} JOYREP;

void do_vbljoy(void)
{
    static RELMOUSE nm;
    static int i,st;


    if((bew1||bew2||bew3||bew4) && inf.j_flag)
    {
        if(++pause<inf.d[2].mw[i]) return;
        else pause=100;

        st=1;
        if(inf.d[2].s_flag)
        {
            for(i=5;i>=1;i--)
            {
                if(step>=inf.d[2].mw[i])
                {
                    st=inf.d[2].mf[i];
                    break;
                }
            }
            if(++step>99) step=99;
        }

        nm.head=last_mouse;
        nm.dx=0;
        nm.dy=0;
        if(bew4) nm.dx=st;
        else if(bew3) nm.dx=-st;
        if(bew2)nm.dy=st;
        else if(bew1)nm.dy=-st;
        if(inf.d[2].w_flag) do_wrap(&nm,2);
        set_mouse(&nm);
    }
} /* do_vbljoy */

void chk_joy(JOYREP *m)
{
    static int begin;
    
    if(!inf.j_flag) return;
    if(m->head!=0xff) return;

    if(bew1||bew2||bew3||bew4) begin=FALSE;
    else begin=TRUE;

    if(m->val&1)bew1=TRUE;
    else bew1=FALSE;
    if(m->val&2) bew2=TRUE;
    else bew2=FALSE;
    if(m->val&4) bew3=TRUE;
    else bew3=FALSE;
    if(m->val&8) bew4=TRUE;
    else bew4=FALSE;

    if((bew1||bew2||bew3||bew4)&& begin)
    {
        pause=100;
        step=1;
        do_vbljoy();
        step=0;
        pause=0;
    }
} /* chk_mouse */

