/*********************************************************************/
/* THE MANDELBROT SET --- faster than ever             PUBLIC DOMAIN */
/* (C) 1987 by J. Loviscach, D-4800 Bielefeld,  Tel. (0521) 88 97 81 */
/*********************************************************************/

/*********************************************************************/
/* INCLUDE FILES                                                     */
/*********************************************************************/

#include <stdio.h>
#include <obdefs.h>
#include <define.h>
#include <gemdefs.h>
#include <osbind.h>
#include "mandelbr.h"

/*********************************************************************/
/* DEFINES                                                           */
/*********************************************************************/

#define WI_KIND         (NAME)

#define NO_WINDOW (-1)

#define MIN_WIDTH  (2*gl_wbox)
#define MIN_HEIGHT (3*gl_hbox)
#define MAX_DEPTH 8
int seed;
#define rand() ( seed=abs((int)(seed * 6707 + 170253)) )
#define min(x,y) ( x>y ? y : x )
#define max(x,y) ( x>y ? x : y )
#define ONE 134217728
#define FOUR 520000000  /* at least similar to 4*ONE */
#define ROWS 82
#define COLUMNS 1300

/*********************************************************************/
/* EXTERNALS                                                         */
/*********************************************************************/

extern int gl_apid;

/*********************************************************************/
/* GLOBAL VARIABLES                                                  */
/*********************************************************************/

int     gl_hchar;
int     gl_wchar;
int     gl_wbox;
int     gl_hbox;                /* system sizes */

int phys_handle;        /* physical workstation handle */
int handle;                     /* virtual workstation handle */
int     wi_handle;              /* window handle */
int     top_window;             /* handle of topped window */

int     xdesk,ydesk,hdesk,wdesk;
int     xold,yold,hold,wold;
int     xwork,ywork,hwork,wwork;        /* desktop and work areas */

int     msgbuff[8];     /* event message buffer */
int     keycode;        /* keycode returned by event-keyboard */
int     mx,my;          /* mouse x and y pos. */
int     butdown;        /* button state tested for, UP/DOWN */
int     ret;            /* dummy return variable */
int i,j;
long k;
long scradr;

int     hidden;         /* current state of cursor */

int     contrl[12];
int     intin[128];
int     ptsin[128];
int     intout[128];
int     ptsout[128];    /* storage wasted for idiotic bindings */

int work_in[11];        /* Input to GSX parameter array */
int work_out[57];       /* Output from GSX parameter array */
int pxyarray[10];       /* input point array */

/****************************************************************/
/*  GSX UTILITY ROUTINES                                        */
/****************************************************************/

hide_mouse()
{
        if(! hidden){
                graf_mouse(M_OFF,0x0L);
                hidden=TRUE;
        }
}

show_mouse()
{
        if(hidden){
                graf_mouse(M_ON,0x0L);
                hidden=FALSE;
        }
}

/****************************************************************/
/* open virtual workstation                                     */
/****************************************************************/

open_vwork()
{
        for(i=0;i<10;work_in[i++]=1);
        work_in[10]=2;
        handle=phys_handle;
        v_opnvwk(work_in,&handle,work_out);
}

/****************************************************************/
/* Init. Until First Event_Multi                                */
/****************************************************************/

OBJECT *maintree,*helptree; 

int xobj,yobj,wobj,hobj,xhi,yhi,xlo,ylo,xhi0,yhi0,xlo0,ylo0;
int max_depth,frames,depth,recalc_on;
int a[8],b[8];
int buffer_flag;
long elements;
char *malloc(),*matrix,*addr;

main()
{
        scradr=xbios(3);    /* logbase */
        appl_init();
        phys_handle=graf_handle(&gl_wchar,&gl_hchar,&gl_wbox,&gl_hbox);
        wind_get(0, WF_WORKXYWH, &xdesk, &ydesk, &wdesk, &hdesk);
        open_vwork();

        if(work_out[13]!=2)
                form_alert(1,"[3][Monochrome|version only.][Sorry!]");  
        else
        {

        if(!rsrc_load("mandelbr.rsc"))
                form_alert(1,"[3][I would like|to get my RSC file!][Damn!]");
        else
        {

        elements=((long)(3))*ROWS*COLUMNS;
        matrix=malloc(32000);
        for ( k=32000; k<elements; k+=32000 ) malloc(32000);
        if( !( malloc(32000) ) ) 
                form_alert(1,"[3][Kill your silly|accessoires and then|try again!][Bye...]");
        else
        {

        rsrc_gaddr(0,TREE01,&helptree);
        form_center(helptree,&xobj,&yobj,&wobj,&hobj);
        form_dial(FMD_START,xobj,yobj,wobj,hobj);
        form_dial(FMD_GROW,0,0,0,0,xobj,yobj,wobj,hobj);
        objc_draw(helptree,0,MAX_DEPTH,xobj,yobj,wobj,hobj);

        graf_mouse(ARROW,0x0L);
        hidden=FALSE;
        butdown=TRUE;

        form_do(helptree,0);

        form_dial(FMD_SHRINK,0,0,0,0,xobj,yobj,wobj,hobj);
        form_dial(FMD_FINISH,xobj,yobj,wobj,hobj);

        rsrc_gaddr(0,TREE00,&maintree);
        form_center(maintree,&xobj,&yobj,&wobj,&hobj);
        form_dial(FMD_START,xobj,yobj,wobj,hobj);
        form_dial(FMD_GROW,0,0,0,0,xobj,yobj,wobj,hobj);
        objc_draw(maintree,0,MAX_DEPTH,xobj,yobj,wobj,hobj);
        
        xlo=maintree[0].ob_x+maintree[PIC].ob_x;
        yhi=maintree[0].ob_y+maintree[PIC].ob_y;
        xhi=xlo+maintree[PIC].ob_width;
        ylo=yhi+maintree[PIC].ob_height;

        a[0]=-1; a[1]=0; a[2]=1; a[3]=1; a[4]=1; a[5]=0; a[6]=-1; a[7]=-1;
        b[0]=-1; b[1]=-1; b[2]=-1; b[3]=0; b[4]=1; b[5]=1; b[6]=1; b[7]=0;

        seed=6346;

        buffer_flag=FALSE;
        objc_change(maintree,PRINT,0,xdesk,ydesk,wdesk,hdesk,DISABLED,1);

        max_depth=20;
        print_val4(max_depth,DATA);
        frames=1;
        print_val4(frames,DATAF);

        large();
        objc_change(maintree,ADD,0,xdesk,ydesk,wdesk,hdesk,DISABLED,1);
        recalc_on=TRUE;
        output();
        objc_change(maintree,READY,0,xdesk,ydesk,wdesk,hdesk,NORMAL,1);
                
        multi();

        form_dial(FMD_SHRINK,0,0,0,0,xobj,yobj,wobj,hobj);
        form_dial(FMD_FINISH,xobj,yobj,wobj,hobj);
        
        }
        }
    rsrc_free();
        }
        v_clsvwk(handle);
    appl_exit();
}

/****************************************************************/
/* dispatches all tasks                                         */
/****************************************************************/

float rehi,relo,imhi,imlo,rehi0,relo0,imlo0,imhi0;
int u,v;
float delta_x,delta_y;
int wrub,hrub;
int event,item;

multi()
{
  do {
        event = evnt_multi(MU_BUTTON,
                        1,1,butdown,
                        0,0,0,0,0,
                        0,0,0,0,0,
                        msgbuff,0,0,&mx,&my,&ret,&ret,&keycode,&ret);

        item = objc_find(maintree,0,MAX_DEPTH,mx,my);

        switch(item) {
        
                case INC:
                if (max_depth<5000)
                {
                        max_depth+=max_depth/10;
                        print_val4(max_depth,DATA);
                        objc_change(maintree,RECALC,0,xdesk,ydesk,wdesk,hdesk,NORMAL,1);
                        objc_change(maintree,ADD,0,xdesk,ydesk,wdesk,hdesk,DISABLED,1);
                        objc_change(maintree,PRINT,0,xdesk,ydesk,wdesk,hdesk,DISABLED,1);
                        recalc_on=TRUE;
                }
                break;

                case DEC:
                if (max_depth>10)
                {
                        max_depth-=max_depth/11;
                        print_val4(max_depth,DATA);
                        objc_change(maintree,RECALC,0,xdesk,ydesk,wdesk,hdesk,NORMAL,1);
                        objc_change(maintree,ADD,0,xdesk,ydesk,wdesk,hdesk,DISABLED,1);
                        objc_change(maintree,PRINT,0,xdesk,ydesk,wdesk,hdesk,DISABLED,1);
                        recalc_on=TRUE;
                }
                break;  

                case INCF:
                if (frames<100)
                {
                        frames++;
                        print_val4(frames,DATAF);
                        objc_change(maintree,RECALC,0,xdesk,ydesk,wdesk,hdesk,NORMAL,1);
                        objc_change(maintree,ADD,0,xdesk,ydesk,wdesk,hdesk,DISABLED,1);
                        objc_change(maintree,PRINT,0,xdesk,ydesk,wdesk,hdesk,DISABLED,1);
                        recalc_on=TRUE;
                }
                break;

                case DECF:
                if (frames>1)
                {
                        frames--;
                        print_val4(frames,DATAF);
                        objc_change(maintree,RECALC,0,xdesk,ydesk,wdesk,hdesk,NORMAL,1);
                        objc_change(maintree,ADD,0,xdesk,ydesk,wdesk,hdesk,DISABLED,1);
                        objc_change(maintree,PRINT,0,xdesk,ydesk,wdesk,hdesk,DISABLED,1);
                        recalc_on=TRUE;
                }
                break;  
        
                case PRINT:
                if (buffer_flag&&(!recalc_on))
                {
                        objc_change(maintree,PRINT,0,xdesk,ydesk,wdesk,hdesk,SELECTED,1);
                        gemdos(0x5,27);
                        gemdos(0x5,51);
                        gemdos(0x5,24);
                        gemdos(0x5,13);
                        for ( i=0; i<ROWS; i++ )
                        {
                                print_val4(i,NUMBER);
                                gemdos(0x5,27);
                                gemdos(0x5,42);
                                gemdos(0x5,39);
                                gemdos(0x5,COLUMNS%256);
                                gemdos(0x5,COLUMNS/256);
                                for ( k=(long)(i)*COLUMNS; k<(long)(i+1)*COLUMNS; k++ )
                                {
                                        addr=matrix+3*k;
                                        gemdos(0x5,*addr);
                                        gemdos(0x5,*(addr+1));
                                        gemdos(0x5,*(addr+2));
                                }
                                gemdos(0x5,10); 
                                gemdos(0x5,13);
                        } 
                        objc_change(maintree,PRINT,0,xdesk,ydesk,wdesk,hdesk,NORMAL,1);
                }
                break;
                
                case BUFFER:
                objc_change(maintree,ADD,0,xdesk,ydesk,wdesk,hdesk,DISABLED,1);
                objc_change(maintree,RECALC,0,xdesk,ydesk,wdesk,hdesk,NORMAL,1);
                recalc_on=TRUE;
                evnt_timer(200,0);
                if (!buffer_flag)
                {
                        objc_change(maintree,BUFFER,0,xdesk,ydesk,wdesk,hdesk,SELECTED,1);
                        buffer_flag=TRUE;
                }
                else
                {
                        objc_change(maintree,BUFFER,0,xdesk,ydesk,wdesk,hdesk,NORMAL,1);
                        buffer_flag=FALSE;
                        objc_change(maintree,PRINT,0,xdesk,ydesk,wdesk,hdesk,DISABLED,1);       
                }
                break;
                
                case PIC:
                relo=delta_x*(float)(mx-xlo)+relo0;
                imhi=-delta_y*(float)(my-yhi)+imhi0;
                graf_rubberbox(mx,my,4,4,&wrub,&hrub);
                rehi=delta_x*(float)(min(mx+wrub-xlo,xhi-xlo))+relo0;
                imlo=-delta_y*(float)(min(my+hrub-yhi,ylo-yhi))+imhi0;
                pxyarray[0]=mx;
                pxyarray[1]=my;
                pxyarray[2]=mx;
                pxyarray[3]=(min(my+hrub,ylo));
                pxyarray[4]=(min(mx+wrub,xhi));
                pxyarray[5]=(min(my+hrub,ylo));
                pxyarray[6]=(min(mx+wrub,xhi));
                pxyarray[7]=my;
                pxyarray[8]=mx;
                pxyarray[9]=my;
                hide_mouse();
                v_pline(handle,5,pxyarray);
                show_mouse();
                print_range();
                objc_change(maintree,RECALC,0,xdesk,ydesk,wdesk,hdesk,NORMAL,1);
                objc_change(maintree,ADD,0,xdesk,ydesk,wdesk,hdesk,DISABLED,1);
                objc_change(maintree,PRINT,0,xdesk,ydesk,wdesk,hdesk,DISABLED,1);
                recalc_on=TRUE;
                break;

                case RECALC:
                if (recalc_on)
                {
                        objc_change(maintree,READY,0,xdesk,ydesk,wdesk,hdesk,DISABLED,1);
                        objc_draw(maintree,PIC,1,xobj,yobj,wobj,hobj);
                        if(buffer_flag)
                        {
                                for ( k=0; k<elements; k++ ) *(matrix+k)=0;
                        }
                        output();
                        objc_change(maintree,READY,0,xdesk,ydesk,wdesk,hdesk,NORMAL,1);
                }
                break;

                case ADD:
                if (!recalc_on)
                {
                        objc_change(maintree,READY,0,xdesk,ydesk,wdesk,hdesk,DISABLED,1);
                        output();
                        objc_change(maintree,READY,0,xdesk,ydesk,wdesk,hdesk,NORMAL,1);
                }
                break;

                case LARGE:
                large();
                objc_change(maintree,RECALC,0,xdesk,ydesk,wdesk,hdesk,NORMAL,1);
                objc_change(maintree,ADD,0,xdesk,ydesk,wdesk,hdesk,DISABLED,1);
                objc_change(maintree,PRINT,0,xdesk,ydesk,wdesk,hdesk,DISABLED,1);
                recalc_on=TRUE;
                break;

                case EXIT:
                break;
                }

   }while( item != EXIT ); 

}

/****************************************************************/
/* print routines                                               */
/****************************************************************/

print_val4(data,pointer) int data,pointer;
{
        char str[4];
        sprintf(str,"%4d",data);

        ((TEDINFO *)maintree[pointer].ob_spec)->te_ptext = str;
        objc_draw(maintree,pointer,1,xdesk,ydesk,wdesk,hdesk);
}

print_float(data,pointer) float data; int pointer;
{
        char str[10];

        ((TEDINFO *)maintree[pointer].ob_spec)->te_ptext = "          ";
        objc_draw(maintree,pointer,1,xdesk,ydesk,wdesk,hdesk);

        sprintf(str,"%8.7f",data);

        ((TEDINFO *)maintree[pointer].ob_spec)->te_ptext = str;
        objc_draw(maintree,pointer,1,xdesk,ydesk,wdesk,hdesk);
}

print_range()
{
        print_float(rehi,XHI);
        print_float(relo,XLO);
        print_float(imhi,YHI);
        print_float(imlo,YLO);
}

/****************************************************************/
/* and now : ...                                                */
/****************************************************************/

set_delta()
{       
                delta_x=(rehi-relo)/(float)(xhi-xlo);
                delta_y=(imhi-imlo)/(float)(ylo-yhi);  /* N.B. yhi<ylo */
}

large()
{
        rehi=2.5;
        relo=-.7;
        imhi=1;
        imlo=-1;
        print_range();
}

long dx,dy,rl,ih;
int zero_flag,zero_v;
int ui,vi;

output()
{
        if (!buffer_flag)
        {
                xhi0=xhi-2;
                xlo0=xlo+1;
                yhi0=yhi+1;
                ylo0=ylo-2;
        }
        else
        {
                xhi0=3*8*ROWS-1;
                xlo0=1;
                yhi0=1;
                ylo0=COLUMNS-1;
        }               

        rehi0=rehi;
        relo0=relo;
        imhi0=imhi;
        imlo0=imlo;
        set_delta();
        if (!buffer_flag)
        {
                dx=(long)(delta_x*ONE);
                dy=(long)(delta_y*ONE);
        }
        else
        {
                dx=(long)( ( (rehi-relo)/(float)(3*8*ROWS) ) * ONE );
                dy=(long)( ( (imhi-imlo)/(float)COLUMNS ) * ONE );
        }
        rl=(long)(relo*ONE);
        ih=(long)(imhi*ONE);
        
        zero_flag=(imlo<0&&imhi>0);     /* zero is included in Im range */

        if ( zero_flag )        
        {
                ih-=ih%dy;      /* cy=0 shall be reached exactly */
                zero_v=(!buffer_flag)?(yhi+ih/dy):(ih/dy);
        }               

        depth=max_depth;

        if ( find_interior() )
        {
                hide_mouse();
                for( depth=max_depth; depth>=max(1,max_depth-frames+1); depth-- )
                { 
                        print_val4(max_depth-depth+1,NUMBER);
                        u=ui;
                        v=vi;
                        if ( radial() )
                        {
                                margin();
                                if (recalc_on)
                                {
                                        objc_change(maintree,RECALC,0,xdesk,ydesk,wdesk,hdesk,DISABLED,1);
                                        objc_change(maintree,ADD,0,xdesk,ydesk,wdesk,hdesk,NORMAL,1);
                                        if (buffer_flag)
                                          objc_change(maintree,PRINT,0,xdesk,ydesk,wdesk,hdesk,NORMAL,1);
                                        recalc_on=FALSE;
                                }
                        }
                }
                show_mouse();
        }
}

find_interior()
{
        j=0;

        do
        {       
                j++;
                ui=xlo0+(rand()%(xhi0-xlo0+1));
                vi=yhi0+(rand()%(ylo0-yhi0+1)); 
        } while ( test(ui,vi) && (j<40) );
        /* N.B. Numerically yhi < ylo *******************/

        if (j==40)
        { 
                form_alert(1,"[1][I did not happen to find|any interior point.|But that doesn't mean|anything at all.|Try RECALC or ADD again.][Forget it!]");
                return(FALSE); 
        }
        return(TRUE);
}

int pstatus;

radial()
{
        do      
        {
                ui=u;
                vi=v;
                u++;
                v++;
                vq_key_s(handle,&pstatus);
        } while ( (!test(u,v))
          && (u<=xhi0) && (u>=xlo0) && (v>=yhi0) && (v<=ylo0)
          && (!(pstatus==14)) );
        if (pstatus!=14) set_pixel(u-1,v-1);
        return ((pstatus==14) ? FALSE : TRUE);
}

int n,m,o;
int u0,v0;
int u1,v1;      /* u1, v1 must be global! */
int flag;       

margin()
{
        u0=u;
        v0=v;

        o=1;
        do
        {
                n=0;
                do
                {
                        m=(n+o)&0x7;    /* instead of ...%8 */  
                        u1=u+a[m];
                        v1=v+b[m];
                        if ( get_pixel() ) flag=FALSE;
                        else
                        { 
                                if ( (u1>xhi0)||(u1<xlo0)||(v1<yhi0)||(v1>ylo0) )       flag=TRUE;
                                else
                                {
                                        if ( !(flag=test(u1,v1)) )
                                        {
                                                set_pixel(u1,v1);
                                                if ( zero_flag && v1>yhi0 && v1<ylo0 )
                                                {
                                                        i=2*zero_v-v1;  /* mirror */
                                                        if ( i>=yhi0 && i<=ylo0 ) set_pixel(u1,i);
                                                }
                                        }
                        } 
                        }
                        n++;
                } while (!(flag||(n==8)));
                o=m+5;
                u=u1;
                v=v1;
                vq_key_s(handle,&pstatus);
        } while ( (!(u==u0&&v==v0)) && (!(pstatus==14)) );
} 

long cx,cy;
int     sign;

test(u,v) int u,v;
{
        if (!buffer_flag)
        asm {
                                move.w  u(A6),D0
                                sub.w   xlo(A4),D0              ;u-xlo
                                move.w  D0,D4
                                move.l  dx(A4),D2
                                mulu    D2,D4                   ;lo prod
                                swap    D2
                                mulu    D2,D0                   ;hi prod
                                swap    D0                              ;shift by 16 pos. N.B. hi byte = 0
                                add.l   D4,D0                   ;(u-xlo)*dx
                                add.l   rl(A4),D0
                                move.l  D0,cx(A4)               ;cx=rl+(u-xlo)*dx

                                move.w  v(A6),D1
                                sub.w   yhi(A4),D1              ;v-yhi
                                move.w  D1,D5
                                move.l  dy(A4),D3
                                mulu    D3,D5                   ;lo prod
                                swap    D3
                                mulu    D3,D1                   ;hi prod
                                swap    D1                              ;shift by 16 pos. N.B. hi byte = 0
                                add.l   D5,D1                   ;(v-yhi)*dy
                                neg.l   D1
                                add.l   ih(A4),D1
                                move.l  D1,cy(A4)               ;cy=ih-(v-yhi)*dy
        }
        else
        {
                cx=rl+u*dx;
                cy=ih-v*dy;
        }
                        
        asm {
                                move.w  depth(A4),i(A4)

                                clr.l   D4                              ;x
                                clr.l   D5                              ;y

                loop:   move.l  D4,D0
                                jsr             square                  
                                move.l  D0,D6                   ;x*x

                                move.l  D5,D0
                                jsr             square          
                                move.l  D0,D7                   ;y*y
        
                                move.l  D4,D0
                                move.l  D5,D1
                                jsr             twtmpr                  ;subroutine ruins D4!
                                move.l  D0,D5                   ;2*x*y
        
                                move.l  D6,D4
                                sub.l   D7,D4
                                bvs             true
                                sub.l   cx(A4),D4               ;x*x-y*y-cx
                                bvs     true

                                sub.l   cy(A4),D5               ;2*x*y-cy
                                bvs             true

                                add.l   D7,D6                   ;x*x+y*y
                                bcs             true
                                subi.l  #FOUR,D6
                                bpl             true

                                subq.w  #1,i(A4)
                                bmi             false

                                jmp             loop

                false:  clr.l   D0
                                jmp             end

                true:   move.l  #1,D0
                                jmp             end


                twtmpr: clr.w   sign(A4)                ;two times product

                                tst.l   D0
                                bpl             a_pl
                                neg.l   D0
                                addq.w  #1,sign(A4)
                a_pl:   
                                clr.l   D2
                                move.w  D0,D2                   ;alo
                                swap    D0                              ;ahi    hi word is ignored!

                                tst.l   D1
                                bpl             b_pl
                                neg.l   D1
                                subq.w  #1,sign(A4)
                b_pl:   
                                clr.l   D3
                                move.w  D1,D3                   ;blo
                                swap    D1                              ;bhi
                
                                move.l  D2,D4
                                mulu    D3,D4                   ;D4 <- alo*blo  
                                mulu    D0,D3                   ;D3 <- ahi*blo
                                mulu    D1,D0                   ;D0 <- ahi*bhi
                                mulu    D2,D1                   ;D1 <- alo*bhi

                                lsr.l   #2,D3
                                lsr.l   #2,D1
                                add.l   D3,D1
                                lsr.l   #8,D1                   ;two times middle sum

                                swap    D4
                                and.l   #0xFFFF,D4              ;shift by 16 positions
                                lsr.w   #8,D4
                                lsr.w   #2,D4                   ;two times low sum
                                
                                lsl.l   #6,D0                   ;two times high sum
                        
                                add.l   D1,D0
                                bcc             c1
                                clr.w   i(A4)
                c1:             add.l   D4,D0
                                bcc             c2
                                clr.w   i(A4)
        
                c2:             tst.w   sign(A4)
                                beq     end1
                                neg.l   D0
                end1:   rts     

        
                square: tst.l   D0                              ;square
                                bpl             pl
                                neg.l   D0
                pl:     
                                clr.l   D2
                                move.w  D0,D2                   ;alo
                                swap    D0                              ;ahi    hi word is ignored!

                                move.l  D2,D1
                                mulu    D0,D1                   ;D1 <- alo*ahi  
                                mulu    D2,D2                   ;D2 <- alo*alo
                                mulu    D0,D0                   ;D0 <- ahi*ahi

                                lsr.l   #2,D1
                                lsr.l   #8,D1                   ;middle sum times two

                                swap    D2
                                and.l   #0xFFFF,D2              ;shift by 16 positions
                                lsr.w   #8,D2
                                lsr.w   #3,D2                   ;low sum
                                
                                lsl.l   #5,D0                   ;high sum
                        
                                add.l   D1,D0
                                bcc             c3
                                clr.w   i(A4)
                c3:             add.l   D2,D0                   ;return square in D0
                                bcc     c4
                                clr.w   i(A4)
                                
                c4:             rts

                end:
        }       
}
                        
set_pixel(u,v) int u,v;
{
        if (!buffer_flag) set_pix(u,v);
        else
        {
                addr = matrix+3*(COLUMNS*(long)(1+(u/24))-v-1)+(u/8)%3;
                *addr |= 128>>(u%8);
                set_pix( (int)(xlo+((long)(xhi-xlo)*u)/(3*8*ROWS)),
                  (int)(yhi+((long)(ylo-yhi)*v)/COLUMNS) );
        }
}

set_pix(_u,_v) int _u,_v;
{
        asm {
                                clr.l   D1
                                clr.l   D3
                                move.w  _u(A6),D1
                                move.l  D1,D2
                                lsr.w   #3,D1
                                and.w   #0x7,D2
                                move.w  _v(A6),D3
                                lsl.l   #4,D3
                                add.l   D3,D1
                                lsl.l   #2,D3
                                add.l   D3,D1
                                add.l  scradr(A4),D1
                                move.l  D1,A0
                                move.b  #0x80,D0
                                lsr.b   D2,D0
                                or.b    D0,(A0)
        }
}

get_pixel() 
{
        if (!buffer_flag)
        asm {                                           
                                clr.l   D1
                                clr.l   D3
                                move.w  u1(A4),D1
                                move.l  D1,D2
                                lsr.w   #3,D1
                                and.w   #0x7,D2
                                move.w  v1(A4),D3
                                lsl.l   #4,D3
                                add.l   D3,D1
                                lsl.l   #2,D3
                                add.l   D3,D1
                                addi.l  #1015808,D1
                                move.l  D1,A0
                                move.b  (A0),D0
                                lsl.b   D2,D0
                                and.l   #0x80,D0
        } 
        else
        {
                addr = matrix+3*(COLUMNS*(long)(1+(u1/24))-v1-1)+(u1/8)%3;
                return( (*addr) & (128>>(u1%8)) );
        }
}
