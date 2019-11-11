#include "define.h"
 
extern WORD handle;
extern WORD gl_hchar,gl_wchar;
extern WORD xwork, ywork, wwork, hwork;
extern FDB scr_mfdb,mem_mfdb;

#define LWGET(x) ( *((WORD *)(x)))
#define LLGET(x) ( *((LONG *)(x)))

#define OB_STATE(x) (tree + (x) * sizeof(OBJECT) +10) /* address of state field ofobject x */
#define OB_SPEC(x) (tree + (x) * sizeof(OBJECT) +12) /* address of ob_spec */
#define OB_HEIGHT(x) (tree + (x) * sizeof(OBJECT) +22) /* address of height */
#define OB_WIDTH(x) (tree + (x) * sizeof(OBJECT) +20) /* address of width */

/***********************************************************************/
/********************  object manipulation functions   *****************/
/***********************************************************************/

/*----------------------------*/
/*        rs_objstate         */
/*----------------------------*/
int rs_objstate(tree, which)
long tree;
short which;
{
short *ptr;
     ptr = (short *)OB_STATE(which);
     return ((*ptr & SELECTED)? TRUE:FALSE);
}

/*----------------------------*/
/*        do_obj              */
/*----------------------------*/
static void do_obj(tree, which,bit)
long tree;
short which,bit;
{
short *ptr;
     ptr = (short *)OB_STATE(which);
     *ptr = *ptr | bit;
}
/*----------------------------*/
/*        undo_obj            */
/*----------------------------*/
static void undo_obj(tree, which,bit)
long tree;
short which,bit;
{
short *ptr;
     ptr = (short *)OB_STATE(which);
     *ptr = *ptr & ~bit;
}
/*----------------------------*/
/*        rs_objselect        */
/*----------------------------*/
void rs_objselect(tree, which)
long tree;
short which;
{
     do_obj(tree, which, SELECTED);
}
/*----------------------------*/
/*        rs_objunselect      */
/*----------------------------*/
void rs_objunselect(tree, which)
long tree;
short which;
{
     undo_obj(tree, which, SELECTED);
}

/*----------------------------*/
/*      rs_objxywh            */
/*----------------------------*/
void rs_objxywh(tree, obj, p) /* get xywh for specified object */
long tree;
short obj;
GRECT *p;
{
        objc_offset(tree, obj, &p->g_x, &p->g_y);
        p->g_w = LWGET(OB_WIDTH(obj));
        p->g_h = LWGET(OB_HEIGHT(obj));
}

/*----------------------------*/
/*        rs_drawobject       */
/*----------------------------*/
void rs_drawobject(tree, obj)
long tree, obj;
{
GRECT c;
        rs_objxywh(tree, obj, &c);
        objc_draw(tree, obj, 0, c.g_x, c.g_y, c.g_w, c.g_h);
}

/*****************************************************************/
/********************** miscellanous functions *******************/
/*****************************************************************/

/*----------------------------*/
/*        set_clip            */
/*----------------------------*/
void set_clip(x,y,w,h)
int x,y,w,h;
{
short clip_tb[4];
        clip_tb[0]=x;
        clip_tb[1]=y;
        clip_tb[2]=x+w-1;
        clip_tb[3]=y+h-1;
        vs_clip(handle,1,clip_tb);
}
/*----------------------*/
/*      strtime         */
/*----------------------*/
char *strtime(adr)      /*return the time as a string  */
char *adr;
{
register int time;
        time = Tgettime();
        sprintf(adr, "%02d:%02d:%02d", (time>>11)&31, (time>>5)&63, (time&31)*2);
        return(adr);
}
/*----------------------*/
/*      strdate         */
/*----------------------*/
char *strdate(adr)      /*return the date as a string  */
char *adr;
{
register int date;
        date = Tgetdate();
        sprintf(adr, "%02d/%02d/%02d", date&31, (date>>5)&15, ((date>>9)&127)+80);
        return(adr);
}
/*----------------------*/
/*      rect_point      */
/*----------------------*/
int rect_point(arr_xy,xx,yy)
int xx,yy;
short *arr_xy;
{
        return(xx>=arr_xy[0] && yy>=arr_xy[1] &&
                xx<= arr_xy[0]+arr_xy[2] && yy <= arr_xy[1]+arr_xy[3]);
}
/*----------------------*/
/*      rect_union      */
/*----------------------*/
void rect_union(arr1,arr2)
short *arr1,*arr2;
{
int x0, y0, x1,y1;
        x0 = min(arr1[0], arr2[0]);
        y0 = min(arr1[1], arr2[1]);
        x1 = max(arr1[0]+arr1[2], arr2[0]+arr2[2]);
        y1 = max(arr1[1]+arr1[3], arr2[1]+arr2[3]);
        arr2[0] = x0;
        arr2[1] = y0;
        arr2[2] = x1 - x0;
        arr2[3] = y1 - y0;
}
/*----------------------*/
/*      rect_init       */
/*----------------------*/
void rect_init(arr,x,y,w,h)
short *arr;
int x,y,w,h;
{
        arr[0]=x;
        arr[1]=y;
        arr[2]=w;
        arr[3]=h;
}
/**********************************************************************/
/**********************************************************************/
/****                   Resource Functions                         ****/
/**********************************************************************/
/**********************************************************************/

/*----------------------*/
/*     rs_addralert     */
/*----------------------*/
long rs_addralert(which)        /* returns the address of a string */
short which;
{
long where;
     rsrc_gaddr(R_STRING, which, &where);
     return (where);
}
/*----------------------*/
/*      rs_addrdial     */
/*----------------------*/
long rs_addrdial(which)       /* returns the address of a string */
short which;
{
long where;
     rsrc_gaddr(R_TREE, which, &where);
     return (where);
}
/*----------------------*/
/*      rs_addredit     */
/*----------------------*/
long rs_addredit(tree,which)       /* returns the address of a field */
long tree;
short which;
{
        return(LLGET(LLGET(OB_SPEC(which))));
}
/*----------------------*/
/*     rs_addrbutton    */
/*----------------------*/
long rs_addrbutton(tree,which)       /* returns the address of a text button */
long tree;
short which;
{
        return(LLGET(OB_SPEC(which)));
}
/*----------------------*/
/*      rs_drawalert    */
/*----------------------*/
int rs_drawalert(err)           /* disply an alert box */
int err;
{
        return(form_alert(1, rs_addralert(err)));
}
/*----------------------*/
/*      rs_drawdial     */
/*----------------------*/
static short xdial,ydial,wdial,hdial;
void rs_drawdial(tree)          /* centre, display & interact with a */
long tree;                      /* dialog box */
{
        form_center(tree, &xdial, &ydial, &wdial, &hdial);
        set_clip(xdial,ydial,wdial,hdial);
        graf_mouse(M_OFF,0);
        copy_screen(xdial,ydial,wdial,hdial,&scr_mfdb,&mem_mfdb);
        graf_mouse(M_ON,0);
        /* save screen behind the dialog box */
        form_dial(FMD_START, 0,0,0,0, xdial, ydial, wdial, hdial);
        objc_draw(tree, ROOT, MAX_DEPTH, xdial, ydial, wdial, hdial);
}
void rs_erasedial()
{
        graf_mouse(M_OFF,0);
        copy_screen(xdial,ydial,wdial,hdial,&mem_mfdb, &scr_mfdb);
        graf_mouse(M_ON,0);
/* restore screen behind dialog box */
        set_clip(xwork,ywork,wwork,hwork);
        form_dial(FMD_FINISH, 0,0,0,0, xdial, ydial, wdial, hdial);
/*        evnt_mesag(msgbuff);*/
}

