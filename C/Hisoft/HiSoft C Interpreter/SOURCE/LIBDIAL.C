/**************************************************************************/
/**************************************************************************/
/*
**                      dialog & object library
*/
/**************************************************************************/
/**************************************************************************/
 
#include "define.h"
 
extern WORD handle;
extern WORD gl_hchar,gl_wchar;
extern WORD wwork, hwork;
extern FDB scr_mfdb,mem_mfdb;
 
#define MAXTREE 40              /* maximum 40 dialog boxes */
 
LONG tree_number;               /* number of initialised trees */
LONG max_objs[MAXTREE];         /* max number of objects in trees */
LONG cur_objs[MAXTREE];         /* current no of objects in trees */
OBJECT *ad_root[MAXTREE];       /* address of root objects */
 
/*----------------------*/
/*      allocate        */
/*----------------------*/
OBJECT *allocate(size)
LONG size;
{
        return((OBJECT *)Malloc(size));
}
/*----------------------*/
/*      adr_box         */
/*----------------------*/
OBJECT *adr_box(no)
LONG no;
{
        if (no>tree_number)
                return((OBJECT*)0);
        return(ad_root[no-1]);
}
/*----------------------*/
/*      init_box        */
/*----------------------*/
LONG init_box(x,y,n)
LONG x,y,n;
{
OBJECT *ptr;
        if (tree_number >= MAXTREE)
                return(0);
        cur_objs[tree_number] = 0;
        max_objs[tree_number] = n;
        ad_root[tree_number++] = ptr = allocate((n+1) * sizeof(OBJECT));
        ptr->ob_next = -1;
        ptr->ob_head = -1;
        ptr->ob_tail = -1;
        ptr->ob_type = G_BOX;
        ptr->ob_flags = NONE;
        ptr->ob_state = OUTLINED;
        ptr->ob_spec = 0x21100;
        ptr->ob_x = 0;
        ptr->ob_y = 0;
        ptr->ob_width = x * gl_wchar;
        ptr->ob_height = y * gl_hchar;
        return(tree_number);
}
 
/*----------------------*/
/*       text_box       */
/*----------------------*/
LONG text_box(n,x,y,str)
LONG x,y,n;
BYTE *str;
{
OBJECT *ptr;
LONG i;
        n--;
        if ((n >= MAXTREE) || (n < 0) || (cur_objs[n]++ >= max_objs[n]))
                return(0);
        if ((i = cur_objs[n]) > 1)
                (&(ad_root[n][i]))->ob_flags ^= LASTOB;
        ptr = &(ad_root[n][cur_objs[n]]);
        ptr->ob_next = -1;
        ptr->ob_head = -1;
        ptr->ob_tail = -1;
        ptr->ob_type = G_STRING;
        ptr->ob_flags = LASTOB;
        ptr->ob_state = NORMAL;
        ptr->ob_spec = (LONG)str;
        ptr->ob_x = x * gl_wchar;
        ptr->ob_y = y * gl_hchar;
        ptr->ob_width = strlen(str) * gl_wchar;
        ptr->ob_height = gl_hchar;
        objc_add(ad_root[n],0,cur_objs[n]);
        return(cur_objs[n]);
}
/*----------------------*/
/*       button_box     */
/*----------------------*/
LONG button_box(n,x,y,str,flags)
LONG x,y,n,flags;
BYTE *str;
{
OBJECT *ptr;
LONG i;
        n--;
        if ((n >= MAXTREE) || (n < 0) || ((i = ++cur_objs[n]) > max_objs[n]))
                return(0);
        if (i > 1)
                (&(ad_root[n][i]))->ob_flags ^= LASTOB;
        ptr = &(ad_root[n][cur_objs[n]]);
        ptr->ob_next = -1;
        ptr->ob_head = -1;
        ptr->ob_tail = -1;
        ptr->ob_type = G_BUTTON;
        ptr->ob_flags = LASTOB+flags;
        ptr->ob_state = NORMAL;
        ptr->ob_spec = (LONG)str;
        ptr->ob_x = x * gl_wchar;
        ptr->ob_y = y * gl_hchar;
        ptr->ob_width = strlen(str) * gl_wchar;
        ptr->ob_height = gl_hchar;
        objc_add(ad_root[n],0,cur_objs[n]);
        return(cur_objs[n]);
}
/*----------------------*/
/*       gtext_box      */
/*----------------------*/
LONG gtext_box(n,x,y,str,char_size,border,fill)
LONG x,y,n,char_size,fill;
BYTE *str;
{
OBJECT *ptr;
TEDINFO *pted;
LONG i;
        n--;
        if ((n >= MAXTREE) || (n < 0) || ((i = ++cur_objs[n]) > max_objs[n]))
                return(0);
        if (i > 1)
                (&(ad_root[n][i]))->ob_flags ^= LASTOB;
        ptr = &(ad_root[n][cur_objs[n]]);
        pted = (TEDINFO *)allocate(sizeof(TEDINFO));
        ptr->ob_next = -1;
        ptr->ob_head = -1;
        ptr->ob_tail = -1;
        ptr->ob_type = border ? G_BOXTEXT : G_TEXT;
        ptr->ob_flags = LASTOB;
        ptr->ob_state = NORMAL;
        ptr->ob_spec = (LONG)pted;
        ptr->ob_x = x * gl_wchar;
        ptr->ob_y = y * gl_hchar;
        ptr->ob_width = (strlen(str)+2) * gl_wchar;
        ptr->ob_height = gl_hchar;
 
        pted->te_ptext = (long)str;
        pted->te_ptmplt = (long)"";
        pted->te_pvalid = (long)"";
        pted->te_font = (char_size != 0) * 2 + 3;
        pted->te_junk1 = 6;
        pted->te_just = 2;
        if (fill < 0 || fill > 7)
                fill = 0;
        pted->te_color = 0x1100 + (fill << 4);
        pted->te_junk2 = 0;
        if (border < 0 || border >3)
                border = 0;
        pted->te_thickness = -border;
        pted->te_txtlen = strlen(str) + 1;
        pted->te_tmplen = 1;
 
        objc_add(ad_root[n],0,cur_objs[n]);
        return(cur_objs[n]);
}
/*----------------------*/
/*       color_box      */
/*----------------------*/
BOOLEAN color_box(n,i,col_border, col_char, col_back)
LONG n, i, col_border, col_char, col_back;
{
OBJECT *ptr;
TEDINFO *pted;
        n--;
        if ((n >= MAXTREE) || (n < 0) || (i > max_objs[n]))
                return(FALSE);
        ptr = &(ad_root[n][i]);
        if (ptr->ob_type != G_BOXTEXT && ptr->ob_type != G_TEXT &&
            ptr->ob_type != G_FBOXTEXT && ptr->ob_type != G_FTEXT)
                return(FALSE);
        pted = (TEDINFO*)(ptr->ob_spec);
        pted->te_color = (pted->te_color & 0x70) + col_back + (col_char << 8)+
                                                        (col_border << 12);
        return(TRUE);
}
/*----------------------*/
/*       readstr_box    */
/*----------------------*/
BYTE *readstr_box(n,i)
LONG n, i;
{
OBJECT *ptr;
TEDINFO *pted;
        n--;
        if ((n >= MAXTREE) || (n < 0) || (i > max_objs[n]))
                return((BYTE*)0);
        ptr = &(ad_root[n][i]);
        if (ptr->ob_type != G_FBOXTEXT && ptr->ob_type != G_FTEXT)
                return((BYTE*)0);
        pted = (TEDINFO*)(ptr->ob_spec);
        return((BYTE*)(pted->te_ptext));
}
/*----------------------*/
/*       readbut_box    */
/*----------------------*/
LONG readbut_box(n,i)
LONG n, i;
{
OBJECT *ptr;
        n--;
        if ((n >= MAXTREE) || (n < 0) || (i > max_objs[n]))
                return(0);
        ptr = &(ad_root[n][i]);
        if (ptr->ob_type != G_BUTTON)
                return(0);
        return((LONG)(ptr->ob_state & SELECTED));
}
/*----------------------*/
/*       edit_box       */
/*----------------------*/
LONG edit_box(n,x,y,str,template,valid,border)
LONG x,y,n,border;
BYTE *str, *valid, *template;
{
OBJECT *ptr;
TEDINFO *pted;
LONG i;
        n--;
        if ((n >= MAXTREE) || (n < 0) || ((i = ++cur_objs[n]) > max_objs[n]))
                return(0);
        if (i > 1)
                (&(ad_root[n][i]))->ob_flags ^= LASTOB;
        ptr = &(ad_root[n][cur_objs[n]]);
        pted = (TEDINFO *)allocate(sizeof(TEDINFO));
        ptr->ob_next = -1;
        ptr->ob_head = -1;
        ptr->ob_tail = -1;
        ptr->ob_type = border ? G_FBOXTEXT:G_FTEXT;
        ptr->ob_flags = LASTOB|EDITABLE;
        ptr->ob_state = NORMAL;
        ptr->ob_spec = (LONG)pted;
        ptr->ob_x = x * gl_wchar;
        ptr->ob_y = y * gl_hchar;
        i = max(max(strlen(str),strlen(template)),strlen(valid));
        ptr->ob_width = (i + 2) * gl_wchar;
        ptr->ob_height = gl_hchar;
 
        if (i & 1)
                i++;
        pted->te_ptext = (long)allocate(i);
        strcpy(pted->te_ptext, str);
        pted->te_ptmplt = (long)template;
        pted->te_pvalid = (long)valid;
        pted->te_font = 3;
        pted->te_junk1 = 6;
        pted->te_just = 2;
        pted->te_color = 0x1180;
        pted->te_junk2 = 0;
        if (border < 0 || border >3)
                border = 0;
        pted->te_thickness = -border;
        pted->te_txtlen = max(strlen(str),strlen(valid)) + 1;
        pted->te_tmplen = strlen(template) + 1;
 
        objc_add(ad_root[n],0,cur_objs[n]);
        return(cur_objs[n]);
}
/*----------------------*/
/*      draw_box        */
/*----------------------*/
LONG draw_box(box_no)      /* centre and display a dialog box */
LONG box_no;
{
OBJECT *tree;
WORD xdial,ydial,wdial,hdial;
LONG result, exit;
LONG i, edit_field;
        if (--box_no < 0 || box_no >= tree_number)
                return(FALSE);
        tree = ad_root[box_no];
        form_center(tree, &xdial, &ydial, &wdial, &hdial);
        copy_screen(xdial,ydial,wdial,hdial,&scr_mfdb,&mem_mfdb);
        /* save screen behind dialog box */

        form_dial(FMD_START,wwork/2,hwork/2,20,20,xdial,ydial,wdial,hdial);
        form_dial(FMD_GROW,wwork/2,hwork/2,20,20,xdial,ydial,wdial,hdial);
        objc_draw(tree, ROOT, MAX_DEPTH,xdial,ydial,wdial,hdial);
        edit_field = -1;
        exit = FALSE;
        for (i = 1; i <= max_objs[box_no]; i++)
        {
                if ((tree[i].ob_type==G_FTEXT || tree[i].ob_type==G_FBOXTEXT)
                                                           && edit_field == -1)
                        edit_field = i;
                if (tree[i].ob_flags & EXIT)
                        exit = TRUE;
        }
        if (exit)
        {
                graf_mouse(M_ON,0);
                result = form_do(tree, edit_field);
                tree[result].ob_state &= ~SELECTED;
                graf_mouse(M_OFF,0);
        }
        else
                result = 0;
        copy_screen(xdial,ydial,wdial,hdial,&mem_mfdb, &scr_mfdb);
        /* restore screen behind dialog box */

        form_dial(FMD_SHRINK,wwork/2,hwork/2,20,20,xdial,ydial,wdial,hdial);
        form_dial(FMD_FINISH,wwork/2,hwork/2,20,20,xdial,ydial,wdial,hdial);
        vs_clip(handle,0,0);
        return(result);
}
/*----------------------*/
/*      copy_screen     */
/*----------------------*/
VOID copy_screen(x,y,w,h,source,dest)
LONG x,y,w,h;
FDB *source, *dest;
{
WORD pxy[8];
        pxy[4] = pxy[0] = x;
        pxy[5] = pxy[1] = y;
        pxy[6] = pxy[2] = x+w;
        pxy[7] = pxy[3] = y+h;
        vro_cpyfm(handle, 3, pxy, source, dest);
}
