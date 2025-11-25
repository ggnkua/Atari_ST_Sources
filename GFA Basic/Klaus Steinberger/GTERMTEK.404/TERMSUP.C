/*********************************************************************/
/* Support routines for GTERM                                        */
/*      started 2/15/86 K.S.   Copyright Beschleungierlabor TU+UNI   */
/*                                       MÅnchen                     */
/*********************************************************************/

/*********************************************************************/
/* INCLUDE FILES                                                     */
/*********************************************************************/

#include "obdefs.h"
#include "define.h"
#include "gemdefs.h"
#include "osbind.h"
#include "portab.h"
#include "machine.h"
#include "treeaddr.h"
#include "term.h"
#include "termdef.h"
#include "termext.h"
#include "tek.h"
#include "termmode.h"


#define   OB_SELECTED(a)    (OB_STATE(a) & SELECTED)

#define X_GETDRV 0x19
#define X_CREAT 0x3C
#define X_OPEN 0x3D
#define X_CLOSE 0x3E
#define X_READ 0x3F
#define X_WRITE 0x40
#define X_GETDIR 0x47
#define X_MALLOC 0x48
#define X_MFREE 0x49

#define MFDB struct memform
MFDB
{
    LONG        mp;
    WORD        fwp;
    WORD        fh;
    WORD        fww;
    WORD        ff;
    WORD        np;
    WORD        r1;
    WORD        r2;
    WORD        r3;
};

long malloc();                          /* malloc routine returns long */

extern int  tek_state;
extern struct t_mode my_setup;
GRECT   scrn_area;                      /* whole screen area            */
GRECT   work_area;                      /* drawing area of main window  */
GRECT   undo_area;                      /* area equal to work_area      */
GRECT   save_area;                      /* save area for full/unfulling */
WORD    scrn_width;                     /* screen width in pixels       */
WORD    scrn_height;                    /* screen height in pixels      */
WORD    scrn_planes;                    /* number of color planes       */
WORD    scrn_xsize;                     /* width of one pixel           */
WORD    scrn_ysize;                     /* height of one pixel          */
MFDB    undo_mfdb;                      /* undo buffer mmry frm def blk */
MFDB    scrn_mfdb;                      /* screen memory form defn blk  */
UWORD   buff_size;                      /* ST and LISA buffers < 64K    */
LONG    buff_location;                  /* screen buffer pointer        */

long dos_all();
int  DOS_ERR;

/*

Page*/
/************************************************************************/
/************************************************************************/
/****                                                                ****/
/****                       Local Procedures                         ****/
/****                                                                ****/
/************************************************************************/
/************************************************************************/
        VOID
dos_func(function, parm)
        UWORD           function;
        LONG            parm;
{
        return( gemdos(function,parm) );
}

        WORD
dos_gdrv()
{
        return( gemdos(X_GETDRV) );
}

        WORD
dos_open(pname, access)
        BYTE            *pname;
        WORD            access;
{
        LONG            ret;

        ret = gemdos(X_OPEN,pname,access);
        if (DOS_ERR)
          return(FALSE);
        else
          return((UWORD)ret);
}

        WORD
dos_close(handle)
        WORD            handle;
{
        return( gemdos(X_CLOSE,handle) );
}

        UWORD
dos_read(handle, cnt, pbuffer)
        WORD            handle;
        UWORD           cnt;
        LONG            pbuffer;
{
        return(gemdos(X_READ,handle,(ULONG)cnt,pbuffer));
}

        UWORD
dos_write(handle, cnt, pbuffer)
        WORD            handle;
        UWORD           cnt;
        LONG            pbuffer;
{
        return(gemdos(X_WRITE,handle,(ULONG)cnt,pbuffer));
}

        WORD
dos_gdir(drive, pdrvpath)
        WORD            drive;
        REG BYTE *      pdrvpath;
{
        REG WORD ret;

        ret = gemdos(X_GETDIR,pdrvpath,drive);
        if (pdrvpath[0] == '\\')
          strcpy(pdrvpath,&pdrvpath[1]);        /* remove leading '\' */
        return(ret);
}

        LONG
dos_create(name, attr)
        BYTE    *name;
        WORD    attr;
{
        return(gemdos(X_CREAT,name,attr));
}

long dos_alloc(nbytes)
long nbytes;
{
        REG LONG ret;

        ret = gemdos(X_MALLOC,nbytes);
        if (ret == 0)
          DOS_ERR = TRUE;               /* gemdos() sets it to FALSE    */
        return(ret);
}

        WORD
dos_free(maddr)
        LONG            maddr;
{
        return( gemdos(X_MFREE,maddr) );
}

/****************************************************************/
/*              Init Resource and menu                          */
/****************************************************************/
gterm_ini()
{
        gl_apid = appl_init();                  /* initialize libraries */
        if (gl_apid == -1)
                return(4);
        wind_update(BEG_UPDATE);
        graf_mouse(HOURGLASS, 0x0L);
        if (!rsrc_load( "TERM.RSC" ))
        {
                graf_mouse(ARROW, 0x0L);
                form_alert(1,
                "[3][Fatal Error !|TERM.RSC|File Not Found][ Abort ]");
                return(1);
        }
        phys_handle=graf_handle(&gl_wchar,&gl_hchar,&gl_wbox,&gl_hbox);
        wind_get(0, WF_WORKXYWH, &xwork, &ywork, &wwork, &hwork);
        open_vwork();

        scrn_width = work_out[0] + 1;
        scrn_height = work_out[1] + 1;
        scrn_xsize = work_out[3];
        scrn_ysize = work_out[4];

        vq_extnd(handle, 1, work_out);
        scrn_planes = work_out[4];

        undo_mfdb.fwp = scrn_width;
        undo_mfdb.fww = undo_mfdb.fwp>>4;
        undo_mfdb.fh = scrn_height;
        undo_mfdb.np = scrn_planes;
        undo_mfdb.ff = 0;
        buff_size = (UWORD)(undo_mfdb.fwp>>3) *
            (UWORD)undo_mfdb.fh *
            (UWORD)undo_mfdb.np;
        buff_location =
            undo_mfdb.mp  = dos_all((long)buff_size & 0xffffL);
        if (undo_mfdb.mp == 0) {
                graf_mouse(ARROW, 0x0L);
                form_alert(1,
                "[3][Fatal Error !|malloc|no storage][ Abort ]");
                return(2);
        }
        scrn_area.g_x = 0;
        scrn_area.g_y = 0;
        scrn_area.g_w = scrn_width;
        scrn_area.g_h = scrn_height;
        scrn_mfdb.mp = 0x0L;

        rc_copy(&scrn_area, &undo_area);
        rast_op(0, &undo_area, &scrn_mfdb, &undo_area, &undo_mfdb);
        open_window();
        rsrc_gaddr(R_TREE, TERMMENU, &gl_menu);
        menu_bar(gl_menu, TRUE);
        graf_mouse(ARROW,0x0L);
        wind_update(END_UPDATE);
        return(0);
}


/****************************************************************/
/*  GSX UTILITY ROUTINES.                                       */
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

/*------------------------------*/
/*      hndl_mouse              */
/*------------------------------*/
WORD
hndl_mouse()
{
    BOOLEAN done;

     if (m_out) {
          graf_mouse(ARROW, 0x0L);
          show_mouse();
     } else {
          if (!(tek_state & TEK_GIN)) {
               graf_mouse(THIN_CROSS, 0x0L);
               hide_mouse();
          } else if (my_setup.graphic & M_G_LHAIR) {
               hide_mouse();
          }
     }
     m_out = !m_out;
     done = FALSE;
     return(done);
}

/****************************************************************/
/* open virtual workstation                                     */
/****************************************************************/
open_vwork()
{
int i;
        for(i=0;i<10;work_in[i++]=1);
        work_in[10]=2;
        handle=phys_handle;
        v_opnvwk(work_in,&handle,work_out);
}

/****************************************************************/
/* set clipping rectangle                                       */
/****************************************************************/
set_clip(x,y,w,h)
int x,y,w,h;
{
int clip[4];
        clip[0]=x;
        clip[1]=y;
        clip[2]=x+w-1;
        clip[3]=y+h-1;
        vs_clip(handle,1,clip);
}

/****************************************************************/
/* open window                                                  */
/****************************************************************/
open_window()
{
        wi_handle=wind_create(WI_KIND,xwork,ywork,wwork,hwork);
        wind_set(wi_handle, WF_NAME," IMA SAMPLE ",0,0);
        graf_growbox(xwork+wwork/2,ywork+hwork/2,gl_wbox,gl_hbox,xwork,ywork,wwork,hwork);
        wind_open(wi_handle,xwork,ywork,wwork,hwork);
        wind_get(wi_handle,WF_WORKXYWH,&xwork,&ywork,&wwork,&hwork);
}

/****************************************************************/
/* find and redraw all clipping rectangles                      */
/****************************************************************/
do_redraw(xc,yc,wc,hc)
int xc,yc,wc,hc;
{
GRECT t1,t2;

        hide_mouse();
        wind_update(TRUE);
        t2.g_x=xc;
        t2.g_y=yc;
        t2.g_w=wc;
        t2.g_h=hc;
        wind_get(wi_handle,WF_FIRSTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
        while (t1.g_w && t1.g_h) {
          if (rc_intersect(&t2,&t1)) {
/*            set_clip(t1.g_x,t1.g_y,t1.g_w,t1.g_h);*/
/*            draw_sample(); */
          }
          wind_get(wi_handle,WF_NEXTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
        }
        wind_update(FALSE);
        show_mouse();
}


/*------------------------------*/
/*      move_do                 */
/*------------------------------*/
VOID
move_do(tree, obj, inc)
LONG    tree;
WORD    obj, inc;
{
        WORD    cobj; 
        LONG    n, bind, arry, limit, obspec;

        obj = get_parent(tree, obj);
        obj = OB_NEXT(obj);
        bind = OB_SPEC(obj);
        arry = *(long *)(bind + sizeof(LONG));
        n = *(long *)(arry) * sizeof(LONG);
        limit = arry + n;

        for (cobj = OB_HEAD(obj); cobj != obj;
        cobj =OB_NEXT(cobj))
        {
                obspec = OB_SPEC(cobj);
                obspec += inc * sizeof(LONG);
                while (obspec <= arry || obspec > limit)
                        obspec += n * ((obspec > limit)? -1: 1);
                OB_SPEC(cobj) = obspec;
        }

        redraw_do(tree, obj);
}

/*------------------------------*/
/*      redraw_do               */
/*------------------------------*/
VOID
redraw_do(tree, obj)
LONG    tree;
WORD    obj;
{
        GRECT   o;

        objc_xywh(tree, obj, &o);
        o.g_x -= 3; o.g_y -= 3; o.g_w += 6; o.g_h += 6;
        objc_draw(tree, ROOT, MAX_DEPTH, o.g_x, o.g_y, o.g_w, o.g_h);
}

/*------------------------------*/
/*        do_obj                */
/*------------------------------*/
VOID
do_obj(tree, which, bit)      /* clear specified bit in object state  */
LONG    tree;
WORD    which, bit;
{
        WORD    state;

        state = OB_STATE(which);
        OB_STATE(which) = state | bit;
}



/*------------------------------*/
/*      undo_obj                */
/*------------------------------*/
VOID
undo_obj(tree, which, bit)      /* clear specified bit in object state  */
LONG    tree;
WORD    which, bit;
{
        WORD    state;

        state = OB_STATE(which);
        OB_STATE(which) = state & ~bit;
}

/*------------------------------*/
/*        sel_obj               */
/*------------------------------*/
VOID
sel_obj(tree, which)          /* turn off selected bit of spcfd object*/
LONG    tree;
WORD    which;
{
        do_obj(tree, which, SELECTED);
}



/*------------------------------*/
/*      desel_obj               */
/*------------------------------*/
VOID
desel_obj(tree, which)          /* turn off selected bit of spcfd object*/
LONG    tree;
WORD    which;
{
        undo_obj(tree, which, SELECTED);
}



/*------------------------------*/
/*      get_parent              */
/*------------------------------*/
/*
*       Routine that will find the parent of a given object.  The
*       idea is to walk to the end of our siblings and return
*       our parent.  If object is the root then return NIL as parent.
*/
WORD
get_parent(tree, obj)
LONG            tree;
WORD            obj;
{
        WORD            pobj;

        if (obj == NIL)
                return (NIL);
        pobj = OB_NEXT(obj);
        if (pobj != NIL)
        {
                while( OB_TAIL(pobj) != obj ) 
                {
                        obj = pobj;
                        pobj = OB_NEXT(obj);
                }
        }
        return(pobj);
} 

/*------------------------------*/
/*      objc_xywh               */
/*------------------------------*/
VOID
objc_xywh(tree, obj, p)         /* get x,y,w,h for specified object     */
LONG    tree;
WORD    obj;
GRECT   *p;
{
        objc_offset(tree, obj, &p->g_x, &p->g_y);
        p->g_w = OB_WIDTH(obj);
        p->g_h = OB_HEIGHT(obj);
}


/*------------------------------*/
/*      xtend_do                */
/*------------------------------*/
WORD
xtend_do(tree, obj, xtype)
LONG    tree;
WORD    obj, xtype;
{
        LONG    obspec;

        switch (xtype) {
                case X_SEL:
                        obspec = OB_SPEC(obj);
                        obj = get_parent(tree, obj);
                        obj = OB_NEXT(obj);
                        OB_SPEC(obj) = obspec;
                        redraw_do(tree, obj);
                        break;
                case X_FWD:
                        move_do(tree, obj, 1);
                        redraw_do(tree, obj);
                        break;
                case X_BAK:
                        move_do(tree, obj, -1);
                        redraw_do(tree, obj);
                        break;
                default:
                        break;
        }
        return(FALSE);
}

/*------------------------------*/
/*      grect_to_array          */
/*------------------------------*/
VOID
grect_to_array(area, array)     /* convert x,y,w,h to upr lt x,y and    */
GRECT   *area;                  /*                    lwr rt x,y        */
WORD    *array;
{
        *array++ = area->g_x;
        *array++ = area->g_y;
        *array++ = area->g_x + area->g_w - 1;
        *array = area->g_y + area->g_h - 1;
}

/*------------------------------*/
/*      rast_op                 */
/*------------------------------*/
VOID
rast_op(mode, s_area, s_mfdb, d_area, d_mfdb)   /* bit block level trns */
WORD    mode;
GRECT   *s_area, *d_area;
MFDB    *s_mfdb, *d_mfdb;
{
        WORD    pxy[8];

        grect_to_array(s_area, pxy);
        grect_to_array(d_area, &pxy[4]);
        vro_cpyfm(handle, mode, pxy, s_mfdb, d_mfdb);
}

/*------------------------------*/
/*      save_work               */
/*------------------------------*/
VOID
save_work(save_area)                     /* copy work_area to undo_area buffer   */
GRECT     *save_area;
{
        GRECT   tmp_area;

        rc_copy(save_area, &tmp_area);
        graf_mouse(M_OFF, 0x0L);
        rast_op(3, save_area, &scrn_mfdb, &tmp_area, &undo_mfdb);
        graf_mouse(M_ON, 0x0L);
}

/*------------------------------*/
/*      overwrite_work          */
/*------------------------------*/
VOID
overwrite_work(save_area)                  /* restore work_area from undo_area     */
GRECT     *save_area;
{
        GRECT   tmp_area;
        int    pxy[8];

        rc_copy(save_area,&tmp_area);
        graf_mouse(M_OFF, 0x0L);
        grect_to_array(&tmp_area, pxy);
        grect_to_array(&save_area, &pxy[4]);
        vro_cpyfm(handle, 1, pxy, &undo_mfdb, &scrn_mfdb); 
        graf_mouse(M_ON, 0x0L);
}

/*------------------------------*/
/*      restore_work            */
/*------------------------------*/
VOID
restore_work(save_area)                  /* restore work_area from undo_area     */
GRECT     *save_area;
{
        GRECT   tmp_area;

        rc_copy(save_area,&tmp_area);
        graf_mouse(M_OFF, 0x0L);
        rast_op(3, &tmp_area, &undo_mfdb, save_area, &scrn_mfdb);
        graf_mouse(M_ON, 0x0L);
}



hndl_dial(tree, def, x, y, w, h)
LONG    tree;
WORD    def;
WORD    x, y, w, h;
{
        WORD    xdial, ydial, wdial, hdial, exitobj;
        WORD    xtype;

        form_center(tree, &xdial, &ydial, &wdial, &hdial);
        form_dial(0, x, y, w, h, xdial, ydial, wdial, hdial);
        form_dial(1, x, y, w, h, xdial, ydial, wdial, hdial);
        objc_draw(tree, ROOT, MAX_DEPTH, xdial, ydial, wdial, hdial);

        FOREVER
        {
                exitobj = form_do(tree, def) & 0x7FFF;
                xtype = OB_TYPE(exitobj) & 0xFF00;
                if (!xtype)
                        break;
                if (xtend_do(tree, exitobj, xtype))
                        break;
        }

        form_dial(2, x, y, w, h, xdial, ydial, wdial, hdial);
        form_dial(3, x, y, w, h, xdial, ydial, wdial, hdial);
        return (exitobj);
}

/****************************************************************/
/* handles the menu tasks                                       */
/****************************************************************/
WORD
hndl_menu(title, item)
WORD title,item;
{
     WORD done;
     int  restore;
     GRECT     save_area;

     restore = TRUE;
     graf_mouse(ARROW, 0x0L);
     show_mouse();
     save_area.g_x = xwork;
     save_area.g_y = ywork;
     save_area.g_w = wwork;
     save_area.g_h = hwork;
     done = FALSE;
     save_work(&save_area);
     switch (title) {
     case TERMDESK:
          if (item == TERMINFO)
               do_about();
          break;

     case TERMFILE:
          switch (item) {
          case TERMQUIT:
               done = TRUE;
               break;
          default:
          }
          break;
     case TERMSET:
          switch (item) {
          case TERMGEN:
               do_genset();
               break;
          case TERMCOMM:
               do_commset();
               break;
          case TERMGRAF:
               do_graset();
               break;
          default:
          }
          break;
     case TERMOPTS:
          switch (item) {
          case TERMNV:
               tek_erase();
               tek_readout();
               break;
          default:
          }
          restore = FALSE;
          break;
     default:
          break;
     }
     menu_tnormal(gl_menu, title, TRUE);
     hide_mouse();
     if (restore) {
          restore_work(&save_area);
     }
     show_mouse();
     return(done);
}

/****************************************************************/
/* display about message                                        */
/****************************************************************/
VOID
do_about()
{
     LONG tree;
     GRECT     box;

     objc_xywh(gl_menu, TERMDESK, &box);
     rsrc_gaddr(R_TREE, ABOUT, &tree);
     show_mouse();
     graf_mouse(ARROW, 0x0L);
     hndl_dial(tree, 0, box.g_x, box.g_y, box.g_w, box.g_h);
     desel_obj(tree, TERMOK);
}

/****************************************************************/
/* display general setup and handle it                          */
/****************************************************************/
VOID do_genset()
{
     long tree;
     GRECT     box;
     int  exit_obj;

     objc_xywh(gl_menu, TERMGEN, &box);
     rsrc_gaddr(R_TREE, GENSETUP, &tree);
     show_mouse();
     graf_mouse(ARROW, 0x0L);
     if (my_setup.general & M_ONLINE) {
          sel_obj(tree, GENONLIN);
     } else {
          sel_obj(tree, GENLOCAL);
     }
     if (my_setup.general & M_CRLF) {
          sel_obj(tree, GENCRLF);
     } else {
          sel_obj(tree, GENCR);
     }
     exit_obj = hndl_dial(tree, 0, box.g_x, box.g_y, box.g_w, box.g_h);
     if (exit_obj == GENOK) {
          desel_obj(tree, GENOK);
          if (OB_STATE(GENCRLF) & SELECTED) {
               my_setup.general |= M_CRLF;
          } else {
               my_setup.general &= ~ M_CRLF;
          }
          if (OB_STATE(GENONLIN) & SELECTED) {
               my_setup.general |= M_ONLINE;
          } else {
               my_setup.general &= ~M_ONLINE;
          }
     } else {
          desel_obj(tree, GENCANC);
     }
     desel_obj(tree,GENCR);
     desel_obj(tree,GENCRLF);
     desel_obj(tree,GENONLIN);
     desel_obj(tree,GENLOCAL);
}

/****************************************************************/
/* display graphik setup and handle it                          */
/****************************************************************/
VOID do_graset()
{
     long tree;
     GRECT     box;
     int  exit_obj;

     objc_xywh(gl_menu, TERMGRAF, &box);
     rsrc_gaddr(R_TREE, GRAFSET, &tree);
     show_mouse();
     graf_mouse(ARROW, 0x0L);
     if (my_setup.graphic & M_G_LHAIR) {
          sel_obj(tree, GSLHAIR);
     }
     if (my_setup.graphic & M_G_DEL) {
          sel_obj(tree, GSDEL);
     }
     if ((my_setup.graphic & M_G_CR) &&
         (my_setup.graphic & M_G_EOT)) {
          sel_obj(tree, GSGINCRE);
     } else if (my_setup.graphic & M_G_CR) {
          sel_obj(tree, GSGINCR);
     } else if (my_setup.graphic & M_G_EOT) {
          sel_obj(tree, GSGINEOT);
     } else {
          sel_obj(tree, GSGINNO);
     }

     exit_obj = hndl_dial(tree, 0, box.g_x, box.g_y, box.g_w, box.g_h);
     if (exit_obj == GSOK) {
          desel_obj(tree, GSOK);
          if (OB_STATE(GSLHAIR) & SELECTED) {
               my_setup.graphic |= M_G_LHAIR;
          } else {
               my_setup.graphic &= ~M_G_LHAIR;
          }
          if (OB_STATE(GSGINNO) & SELECTED) {
               my_setup.graphic &= ~(M_G_CR|M_G_EOT);
          }
          if (OB_STATE(GSGINCR) & SELECTED) {
               my_setup.graphic |= M_G_CR;
               my_setup.graphic &= ~M_G_EOT;
          }
          if (OB_STATE(GSGINEOT) & SELECTED) {
               my_setup.graphic |= M_G_EOT;
               my_setup.graphic &= ~M_G_CR;
          }
          if (OB_STATE(GSGINCRE) & SELECTED) {
               my_setup.graphic |= M_G_CR|M_G_EOT;
          }
          if (OB_STATE(GSDEL) & SELECTED) {
               my_setup.graphic |= M_G_DEL;
          } else {
               my_setup.graphic &= ~M_G_DEL;
          }
     } else {
          desel_obj(tree, GSCANC);
     }
     desel_obj(tree, GSLHAIR);
     desel_obj(tree, GSDEL);
     desel_obj(tree, GSGINCR);
     desel_obj(tree, GSGINCRE);
     desel_obj(tree, GSGINEOT);
     desel_obj(tree, GSGINNO);
}

/****************************************************************/
/* display communication setup and handle it                    */
/****************************************************************/
VOID do_commset()
{
     long tree;
     GRECT     box;
     int  exit_obj;

     objc_xywh(gl_menu, TERMCOMM, &box);
     rsrc_gaddr(R_TREE, COMMSET, &tree);
     switch (my_setup.comm & M_CSBAUD) {
     case M_CS19200:
          sel_obj(tree, CS19200);
          break;
     case M_CS9600:
          sel_obj(tree, CS9600);
          break;
     case M_CS4800:
          sel_obj(tree, CS4800);
          break;
     case M_CS3600:
          sel_obj(tree, CS3600);
          break;
     case M_CS2400:
          sel_obj(tree, CS2400);
          break;
     case M_CS2000:
          sel_obj(tree, CS2000);
          break;
     case M_CS1800:
          sel_obj(tree, CS1800);
          break;
     case M_CS1200:
          sel_obj(tree, CS1200);
          break;
     case M_CS600:
          sel_obj(tree, CS600);
          break;
     case M_CS300:
          sel_obj(tree, CS300);
          break;
     case M_CS200:
          sel_obj(tree, CS200);
          break;
     case M_CS150:
          sel_obj(tree, CS150);
          break;
     case M_CS134:
          sel_obj(tree, CS134);
          break;
     case M_CS110:
          sel_obj(tree, CS110);
          break;
     case M_CS75:
          sel_obj(tree, CS75);
          break;
     case M_CS50:
          sel_obj(tree, CS50);
          break;
     }
     if (my_setup.comm & M_IXON) {
          sel_obj(tree, CSIXON);
     } else {
          sel_obj(tree, CSNOIXON);
     }
     if (my_setup.comm & M_RTS) {
          sel_obj(tree, CSRTS);
     } else {
          sel_obj(tree, CSNORTS);
     }
     if (my_setup.comm & M_LECHO) {
          sel_obj(tree, CSLECHO);
     } else {
          sel_obj(tree, CSNOLECH);
     }
     if (my_setup.comm & M_SLOW) {
          sel_obj(tree, CSSLOW);
     } else {
          sel_obj(tree, CSFAST);
     }
     show_mouse();
     graf_mouse(ARROW, 0x0L);
     exit_obj = hndl_dial(tree, 0, box.g_x, box.g_y, box.g_w, box.g_h);
     if (exit_obj == CSOK) {
          desel_obj(tree, CSOK);
          my_setup.comm &= ~M_CSBAUD;
          if (OB_SELECTED(CS19200)) {
               my_setup.comm |= M_CS19200;
          } else if (OB_SELECTED(CS9600)) {
               my_setup.comm |= M_CS9600;
          } else if (OB_SELECTED(CS4800)) {
               my_setup.comm |= M_CS4800;
          } else if (OB_SELECTED(CS3600)) {
               my_setup.comm |= M_CS3600;
          } else if (OB_SELECTED(CS2400)) {
               my_setup.comm |= M_CS2400;
          } else if (OB_SELECTED(CS2000)) {
               my_setup.comm |= M_CS2000;
          } else if (OB_SELECTED(CS1800)) {
               my_setup.comm |= M_CS1800;
          } else if (OB_SELECTED(CS1200)) {
               my_setup.comm |= M_CS1200;
          } else if (OB_SELECTED(CS600)) {
               my_setup.comm |= M_CS600;
          } else if (OB_SELECTED(CS300)) {
               my_setup.comm |= M_CS300;
          } else if (OB_SELECTED(CS200)) {
               my_setup.comm |= M_CS200;
          } else if (OB_SELECTED(CS150)) {
               my_setup.comm |= M_CS150;
          } else if (OB_SELECTED(CS134)) {
               my_setup.comm |= M_CS134;
          } else if (OB_SELECTED(CS110)) {
               my_setup.comm |= M_CS110;
          } else if (OB_SELECTED(CS75)) {
               my_setup.comm |= M_CS75;
          } else if (OB_SELECTED(CS50)) {
               my_setup.comm |= M_CS50;
          }
          if (OB_SELECTED(CSIXON)) {
               my_setup.comm |= M_IXON;
          } else {
               my_setup.comm &= ~M_IXON;
          }
          if (OB_SELECTED(CSRTS)) {
               my_setup.comm |= M_RTS;
          } else {
               my_setup.comm &= ~M_RTS;
          }
          if (OB_SELECTED(CSLECHO)) {
               my_setup.comm |= M_LECHO;
          } else {
               my_setup.comm &= ~M_LECHO;
          }
          if (OB_SELECTED(CSSLOW)) {
               my_setup.comm |= M_SLOW;
          } else {
               my_setup.comm &= ~M_SLOW;
          }
          set_comm();
     } else {
          desel_obj(tree, CSCANCEL);
     }
     desel_obj(tree, CS19200);
     desel_obj(tree, CS9600);
     desel_obj(tree, CS4800);
     desel_obj(tree, CS3600);
     desel_obj(tree, CS2400);
     desel_obj(tree, CS2000);
     desel_obj(tree, CS1800);
     desel_obj(tree, CS1200);
     desel_obj(tree, CS600);
     desel_obj(tree, CS300);
     desel_obj(tree, CS200);
     desel_obj(tree, CS150);
     desel_obj(tree, CS134);
     desel_obj(tree, CS110);
     desel_obj(tree, CS75);
     desel_obj(tree, CS50);
     desel_obj(tree, CSIXON);
     desel_obj(tree, CSNOIXON);
     desel_obj(tree, CSRTS);
     desel_obj(tree, CSNORTS);
     desel_obj(tree, CSLECHO);
     desel_obj(tree, CSNOLECH);
     desel_obj(tree, CSSLOW);
     desel_obj(tree, CSFAST);
}

int  set_comm()
{
     int  ctrl;

     ctrl = (my_setup.comm & M_IXON) ? 1 : 0 ;
     ctrl |=(my_setup.comm & M_RTS)  ? 2 : 0 ;
     Rsconf(my_setup.comm & M_CSBAUD, ctrl, -1, -1, -1, -1);
}
