/*
Atari ST Notepad desk accessory source
 by Tim Victor

Copyright 1987, COMPUTE! Publications/ABC

Atari Development System linking instruction:
[u,l] notepad.68k = accstart, notepad, findlen, fillstr, osbind, vdibind, aesbind

- Accstart has to be modified and reassembled so that its stack is 10000 bytes long. The Pushpull routine used for on-screen insertions and deletions is recursive and stack-hungry.

- Findlen and Fillstr are assembler routines which are part of Notepad. The files FINDLEN.S and FILLSTR.S must be assembled separately and the two object files linked in.
*/

#include <gemdefs.h>
#include <osbind.h>
#include <obdefs.h>

#define HIDE_MOUSE graf_mouse(M_OFF,0x0L)
#define SHOW_MOUSE graf_mouse(M_ON,0x0L)
#define TRUE 1
#define FALSE 0

/* storage is composed of 2K blocks */

#define BLOCK_SIZE 2048

/* the control structure for managing this memory */

struct mem_control {
     unsigned int size;
     struct mem_control *next;
     struct mem_control *prev;
     char mem[BLOCK_SIZE];
     };

/* structure for screen wordwrap manipulations */
struct blitpoint { int row, col, len; };

/* sleazy workaround */
extern long find_clik(), find_row(), find_prev(), prev_para(),
           srch_back(), srch_for(), doc_len();
extern int  find_len();

/* global memory pointers */

struct mem_control *first_block; /* pointer to first mem_control block */
struct mem_control *last_block;  /* pointer

/* screen display info */

long first_par;     /* text offset of start of screen */
int  first_line;    /* line number in first_par at top of window */

int ch_xsize, ch_ysize; /* size of character cell in pixels */
int ch_cols, ch_rows;   /* number of characters in window */

/* cursor stuff */

int  cur_row;       /* cursor's line on screen */
long cur_line;      /* text offset of start of cursor's line */
int  cur_col;       /* position of cursor in that line */
int  cur_len;       /* length of that line */
long cur_index;     /* position of cursor in document */

  /* selected text region; if equal, none selected */
long sel_start;     /* the first character in the range */
long sel_end;       /* the first character out of the range */

  /* default file selector name and path specs */
char defname[] = "\\*.*";
char fs_name[80], fs_path[80];

/* GEM parameter arrays and global variables */
int  handle;        /* for VDI */
int  wind_handle;   /* for AES */
int  deskx, desky, deskh, deskw;   /* desktop's dimensions */
int  windx, windy;                 /* window position */
int  fullw, fullh, fulled;         /* full window */
int  oldx, oldy, oldw, oldh;
int  xdiff, ydiff;                 /* space used for borders */
int  workx, worky, workh, workw;   /* window workarea's dims */
int  slidsize, slidpos;            /* vertical slider info */

int  topped, opened;               /* am I in control? */

int  ret;           /* when you don't care enough to send the best */
int  msg_buffer[8]; /* AES message buffer */
int  mfdb[10];      /* fake raster definition block */

int  contrl[128];   /* parameter arrays */
int  intin[128];
int  ptsin[128];
int  intout[128];
int  ptsout[128];

int  work_in[11];
int  work_out[57];

extern int gl_apid; /* who am I? */
int  acc_id;        /* desk accessory ID number */

  /* object info */
int  cx, cy, cw, ch;     /* control panel width, height */
int  fx, fy, fw, fh;     /* find/change dialog width, height */

char str0[] = "  Copy";  /* names */
char str1[] = "  Move";
char str2[] = "  Delete";
char str3[] = "  Find...";
char str4[] = "  Load...";
char str5[] = "  Save...";
char str6[] = "  Print";
char str7[] = "  Clear";

OBJECT cntlform[] = {     /* controller object tree */
-1, 1, 8, G_BOX, NONE, NORMAL, 0xFF1100L, 0,0, 12,8,
2, -1, -1, G_STRING, NONE, NORMAL, str0, 0,0, 12,1,
3, -1, -1, G_STRING, NONE, NORMAL, str1, 0,1, 12,1,
4, -1, -1, G_STRING, NONE, NORMAL, str2, 0,2, 12,1,
5, -1, -1, G_STRING, NONE, NORMAL, str3, 0,3, 12,1,
6, -1, -1, G_STRING, NONE, NORMAL, str4, 0,4, 12,1,
7, -1, -1, G_STRING, NONE, NORMAL, str5, 0,5, 12,1,
8, -1, -1, G_STRING, NONE, NORMAL, str6, 0,6, 12,1,
0, -1, -1, G_STRING, LASTOB, NORMAL, str7, 0,7, 12,1};


char fstr0[] = "Find/Change";
char fstr1[] = "\0                               ";
char fstr2[] = "from:________________________________";
char fstr3[] = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
char fstr4[] = "\0                               ";
char fstr5[] = "to:________________________________";
char fstr6[] = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
char fstr7[] = "CHANGE ALL";
char fstr8[] = "CHANGE FIRST";
char fstr9[] = "FIND";
char fstr10[] = "CANCEL";

TEDINFO ted1 = {fstr1, fstr2, fstr3, 3, 6, 0, 0x1180, 0x0, 255, 33,37};
TEDINFO ted2 = {fstr4, fstr5, fstr6, 3, 6, 0, 0x1180, 0x0, 255, 33,35};

OBJECT findform[] = {    /* find/change object tree */
-1, 1, 7, G_BOX, NONE, OUTLINED, 0x21100L, 0,0, 40,10,
2, -1, -1, G_STRING, NONE, NORMAL, fstr0, 14,1, 11,1,
3, -1, -1, G_FTEXT, EDITABLE, NORMAL, ted1, 1,3, 37,1,
4, -1, -1, G_FTEXT, EDITABLE, NORMAL, ted2, 3,4, 35,1,
5, -1, -1, G_BUTTON, 0x5, NORMAL, fstr7, 4,6, 14,1,
6, -1, -1, G_BUTTON, 0x5, NORMAL, fstr8, 22,6, 14,1,
7, -1, -1, G_BUTTON, 0x5, NORMAL, fstr9, 4,8, 14,1,
0, -1, -1, G_BUTTON, 0x25, NORMAL, fstr10, 22,8, 14,1};


/*...........................MAIN CODE..................................*/

main()
{
     init_gem();    /* open the window and all that */
     init_store();  /* make a blank document */
     interact();
}  /* end main */


/*.......................INTERACTION CODE...............................*/

interact()  /* handle all user actions */
{
     int  event, keycode, bstate, kstate;
     char asc;
     int  topwind;
     int  clik_x, clik_y;
     int  oldslide, oldsize;
     long docsize;
     long scrnstart, scrnend;

     while (TRUE) {  /* eternal loop */
     while (!opened)
     {     /* accessory closed loop */
          evnt_mesag(msg_buffer);
          if (msg_buffer[0] == AC_OPEN && msg_buffer[4] == acc_id)
          {
               open_wind();
               if (wind_handle >= 0)
               {
                    opened = TRUE;
                    if (cur_row >= ch_rows)
                         set_screen(ch_rows - 1);
                    rfsh_all();
               }  /* end if */
               else
                    form_alert(1,"[3][No windows available][OK]");
          }  /* end if */
     }  /* end while */

     while (opened)
     {  /* accessory open loop */
     event = evnt_multi(MU_MESAG | MU_KEYBD | MU_BUTTON,
                        1,1,1,
                        0,0,0,0,0,
                        0,0,0,0,0,
                        msg_buffer,0,0,&clik_x,&clik_y,
                        &bstate,&kstate,&keycode,&ret);

     wind_get(wind_handle, WF_TOP, &topwind, &ret, &ret, &ret, &ret);
     topped = (topwind == wind_handle);

     if ((event & MU_KEYBD) && topped)
     {
          asc = keycode & 127;
          if ( asc == 13 || (asc >= ' ' && asc < 127))
               type_char(asc);
          else
               key_cmd(keycode);
     }  /* end if */

       /* control click */
     if ((event & MU_BUTTON) && kstate == 4 && sel_start != sel_end && topped)
     {
          HIDE_MOUSE;
          select(sel_start, sel_end);        /* cancel selection */
          SHOW_MOUSE;
     }  /* end if */

       /* mouse down */
     if ((event & MU_BUTTON) && kstate == 0 && topped)
          if (clik_x >= workx && clik_x < workx + workw &&
              clik_y >= worky && clik_y < worky + workh)
          {  /* in document window */
               wind_update(TRUE);
               wind_klik(clik_x, clik_y);
               wind_update(FALSE);
          }  /* end if */

       /* GEM events */
     if (event & MU_MESAG)
     {
          switch (msg_buffer[0]) {
          case WM_CLOSED:
               if (msg_buffer[3] == wind_handle)
               {
                    close_wind();
                    opened = FALSE;
               }  /* end if */
               break;
          case WM_ARROWED:
               if (msg_buffer[3] == wind_handle)
               {
                    switch (msg_buffer[4]) {
                    case 0:   /* page up */
                         pg_up();
                         break;
                    case 1:   /* page down */
                         pg_down();
                         break;
                    case 2:   /* up arrow */
                         ar_up();
                         break;
                    case 3:   /* down arrow */
                         ar_down();
                         break;
                    }  /* end switch */
                    compact();
               }  /* end if */
               break;
          case WM_VSLID:
               if (msg_buffer[3] == wind_handle &&
                   msg_buffer[4] != slidpos)
                    set_slide(msg_buffer[4]);
               break;
          case WM_SIZED:
               if (msg_buffer[3] == wind_handle)
                    set_size(msg_buffer[6], msg_buffer[7]);
               break;
          case WM_MOVED:
               if (msg_buffer[3] == wind_handle)
                    move_wind(msg_buffer[4], msg_buffer[5]);
               break;
          case WM_REDRAW:
               if (msg_buffer[3] == wind_handle)
                    redraw(msg_buffer[4], msg_buffer[5],
                              msg_buffer[6], msg_buff[7]);
               break;
          case WM_FULLED:
               if (msg_buffer[3] == wind_handle)
               {
                    if (fulled)
                    {
                         move_wind(oldx, oldy);
                         set_size(oldw, oldh);
                    }  /* end if */
                    else
                    {
                         wind_get(wind_handle, WF_CURRXYWH, &oldx, &oldy, &oldw, &oldh);
                         move_wind(deskx, desky);
                         set_size(fullw, fullh);
                    }  /* end else */
                    fulled = !fulled;
               }  /* end if */
               break; 
          case WM_TOPPED:
               if (msg_buffer[3] == wind_handle)
                    wind_set(wind_handle, WF_TOP, 0, 0, 0, 0);
               break;
          case AC_OPEN:
               if (topped && msg_buffer[4] == acc_id)
               {
                    switch (do_control()) {
                    case 1:   /* copy */
                         copy_sel();
                         break;
                    case 2:   /* move */
                         move_sel();
                         break;
                    case 3:   /* delete */
                         del_sel();
                         break;
                    case 4:   /* find */
                         find();
                         break;
                    case 5:   /* load */
                         load();
                         break;
                    case 6:   /* save */
                         save();
                         break;
                    case 7:   /* print */
                         print();
                         break;
                    case 8:   /* clear */
                         clear();
                    }  /* end switch */
                    compact();
               }  /* end if */
               break;
          case AC_CLOSE:
               if (msg_buffer[3] == acc_id)
               {
                    v_clsvwk(handle);
                    opened = FALSE;
               }  /* end if */
               break;
          case WM_NEWTOP:
          }  /* end switch */
     }  /* end if */

     if (opened)
     {
            /* update slider */
          oldslide = slidpos;
          oldsize = slidsize;
          docsize = doc_len();
          scrnstart = find_row(0);
          scrnend = find_clik(ch_cols-1, ch_rows-1);
          if (docsize)
               slidsize = (scrnend-scrnstart)*999/docsize + 1;
          else
               slidsize = 1000;
          if (scrnstart)
               slidpos = scrnstart*999/(docsize+scrnstart-scrnend) + 1;
          else
               slidpos = 0;
          if (slidsize/10 != oldsize/10)
               wind_set(wind_handle, WF_VSLSIZE, slidsize);
          if (slidpos/10 != oldslide/10)
               wind_set(wind_handle, WF_VSLIDE, slidpos);
     }  /* end if */

     }  /* end while */
     }  /* end eternal loop */

}  /* end interact */


key_cmd(cmd_key)
int  cmd_key;
{

     HIDE_MOUSE;
     wind_update(TRUE);
     switch (cmd_key >> 8)
     {
          case 0x48:  /* cursor up */
               cur_up();
               compact();     /* crunch storage */
               break;

          case 0x50:  /* cursor down */
               cur_down();
               compact();     /* crunch storage */
               break;

          case 0x4b:  /* cursor left */
               cur_left();
               break;

          case 0x4d:  /* cursor right */
               cur_right();
               break;

          case 0x0e:  /* backspace key */
               backspace();
               break;

          case 0x0f:  /* tab key */
               do {
                    type_char(' ');
               }  while (cur_col % 5);
               break;

          case 0x53:  /* delete key */
               if (cur_index != doc_len())
               {
                    cur_right();
                    backspace();
               }  /* end if */

     }  /* end switch */
     wind_update(FALSE);
     SHOW_MOUSE;

} /* end key_cmd */


cur_down()  /* move cursor down */
{
     int  old_col, old_row;

     old_col = cur_col;
     old_row = cur_row;

     if ((cur_line = find_row(++cur_row)) == -1)
     {  /* past end of doc */
          cur_line = find_row(--cur_row);
          return;
     }  /* end if */

     if (cur_row == ch_rows)
     {  /* advance off bottom of scrn */
          --old_row;
          --cur_row;
          scrn_up();               /* scroll */
     }  /* end if */

     if (cur_col >= (cur_len = find_len(cur_line)))
          cur_col = cur_len - 1;

     cur_index = cur_line + cur_col;

     rfsh_char(old_col, old_row);
     draw_curs(cur_col, cur_row);

}  /* end cur_down */


cur_up()  /* move cursor up */
{
     int  old_col, old_row;

     old_col = cur_col;
     old_row = cur_row;

     if (--cur_row < 0)
     {
          if (first_par == 0 && first_line == 0)
          {
               cur_row = 0;
               return;
          }  /* end if */

          old_row = 1;
          cur_row = 0;
          scrn_down();
     }  /* end if */

     cur_line = find_row(cur_row);

     if (cur_col >= (cur_len = find_len(cur_line)))
          cur_col = cur_len - 1;

     cur_index = cur_line + cur_col;

     rfsh_char(old_col, old_row);
     draw_curs(cur_col, cur_row);

}  /* end cur_up */


cur_right()  /* cursor advance */
{
     int  old_col, old_row;

     old_col = cur_col;
     old_row = cur_row;

     find_index(++cur_index, &cur_row, &cur_line);

     if (cur_line == -1 )  /* past end of doc or off scrn? */
     {
          if (find_row(ch_rows) == -1)       /* end of doc */
          {
               find_index(--cur_index, &cur_row, &cur_line);
               return;
          }  /* end if */
          else                               /* end of window */
          {
               --old_row;
               scrn_up();                    /* scroll */
               find_index(cur_index, &cur_row, &cur_line);
          }  /* end else */
     }  /* end if */

     cur_col = cur_index - cur_line;
     cur_len = find_len(cur_line);

     rfsh_char(old_col, old_row);
     draw_curs(cur_col, cur_row);

}  /* end cur_right */


cur_left()  /* cursor retreat */
{
     int  old_col, old_row;

     old_col = cur_col;
     old_row = cur_row;

     if (cur_index == 0) return;

     if ((cur_col | cur_row) == 0)      /* should scroll */
     {
          old_row = 1;
          scrn_down();
     }  /* end if */
  
     find_index(--cur_index, &cur_row, &cur_line);
     cur_col = cur_index - cur_line;
     cur_len = find_len(cur_line);

     rfsh_char(old_col, old_row);
     draw_curs(cur_col, cur_row);

}  /* end cur_left */


type_char(charcode)  /* handle normal typing */
char charcode;
{
     struct blitpoint curpos;

     if (ins_string(cur_index, 1L, &charcode) == 0)
          return;        /* insert in doc */

      /* fix screen */
     HIDE_MOUSE;
     wind_update(TRUE);
     scrn_ins(cur_row, cur_col, cur_index++, cur_len, 1L, &curpos);

       /* set cursor position */
     cur_row = curpos.row;
     cur_col = curpos.col;
     cur_len = cur_col + curpos.len;
     cur_line = cur_index - cur_col;

     if (cur_row == -1)
     {
          cur_row = 0;
          scrn_down();                            /* scroll */
     }  /* end if */

     if (cur_row == ch_rows)
     {
          --cur_row;
          scrn_up();
     }  /* end if */

     draw_curs(cur_col, cur_row);
     wind_update(FALSE);
     SHOW_MOUSE;

}  /* end type_char */


backspace()  /* backward delete 1 character */
{
     struct blitpoint curpos;
     int  del_row, del_col;

     if (cur_index == 0) return;

     if (cur_col != 0)
     {
          del_row = cur_row;
          del_col = cur_col - 1;
     }  /* end if */
     else
     {
          del_row = cur_row - 1;
          del_col = find_len(find_prev(cur_row)) - 1;
     }  /* end else */

     del_string(--cur_index, 1L);
     scrn_del(del_row, del_col, cur_index,
              cur_row, cur_col, cur_len, 1L, &curpos);

       /* adjust cursor */
     cur_row = curpos.row;
     cur_col = curpos.col;
     cur_line = cur_index - cur_col;
     cur_len = curpos.len + cur_col;

     if (cur_row == ch_rows)
     {
          --cur_row;
          scrn_up();
     }  /* end if */   

     draw_curs(cur_col, cur_row);

}  /* end backspace */


wind_klik(x, y)     /* left button is pressed over x,y in window */
int  x,y;
{
     int  clik_row, clik_col;      /* position of initial click */
     long clik_index, clik_line;   /* index of initial click */
     int  m_row, m_col;            /* mouse pos working vars */
     int  m_x, m_y;
     long m_index, old_index;      /* mouse index working var */
     int  old_row, old_col;        /* old cur positions */
     int  event, bstate;
     int  sel_flag;

     m_x = x;
     m_y = y;
     m_col = (x - workx)/ch_xsize;
     m_row = (y - worky)/ch_ysize;
     old_row = cur_row;
     old_col = cur_col;

     clik_index = find_clik(m_col, m_row);
     find_index(clik_index, &clik_row, &clik_line);
     clik_col = clik_index - clik_line;

     m_index = clik_index;

     if (sel_start != sel_end)     /* active select? */
          sel_flag = TRUE;
     else
     {
          sel_flag = FALSE;
          sel_start = sel_end = clik_index;
     }  /* end else */

       /* wait for release or movement */
     do {  /* m_col and m_row are always valid here */
          event = evnt_multi(MU_BUTTON | MU_M1, 
                   1,1,0,
                   1, workx+m_col*ch_xsize,
                     worky+m_row*ch_ysize,
                     ch_xsize, ch_ysize,
                   0,0,0,0,0,
                   msg_buffer,0,0,&m_x,&m_y,
                   &bstate,&ret,&ret,&ret);

          if ((event & MU_M1) && sel_flag)
          {      /* cancel previous select */
               HIDE_MOUSE;
               select(sel_start, sel_end);
               SHOW_MOUSE;
               sel_start = sel_end = clik_index;
               sel_flag = FALSE;
          }  /* end if */

          while (bstate == 1 &&
                (m_x<workx || m_y<worky ||
                 m_x>=workx+workw || m_y>=worky+workh))
          {      /* out of window */

                 /* off top? */
               if (m_y < worky && (first_line != 0 || first_par != 0))
               {
                    ar_up();
                    ++clik_row;
                    ++old_row;
               }  /* end if */

                 /* off bottom? */
               if (m_y >= worky + workh && bstate == 1 &&
                 find_row(ch_rows) != -1)
               {
                    ar_down();
                    --clik_row;
                    --old_row;
               }  /* end if */

                 /* track cursor anyway */
               m_row = (m_y - worky)/ch_ysize;
               if (m_row < 0) m_row = 0;
               if (m_row >= ch_rows) m_row = ch_rows - 1;
               m_col = (m_x - workx)/ch_ysize;
               if (m_col < 0) m_col = 0;
               if (m_col >= ch_cols) m_col = ch_cols - 1;

               old_index = m_index;
               m_index = find_clik(m_col, m_row);
               HIDE_MOUSE;
               select(old_index, m_index);
               SHOW_MOUSE;
               vq_mouse(handle, &bstate, &m_x, &m_y);
          }  /* end while */

          if (bstate == 1)
          {
               m_col = (m_x - workx)/ch_xsize;
               m_row = (m_y - worky)/ch_ysize;
               old_index = m_index;
               m_index = find_clik(m_col, m_row);
               HIDE_MOUSE;
               select(old_index, m_index);
               SHOW_MOUSE;
          }  /* end if */
     } while (bstate == 1);

       /* move the cursor? */
     if (clik_index == find_clik(m_col, m_row) &&
           clik_index != cur_index)
     {
          cur_index = clik_index;
          cur_row = clik_row;
          cur_line = clik_line;
          cur_col = clik_col;
          cur_len = find_len(cur_line);

          HIDE_MOUSE;
          rfsh_char(old_col, old_row);
          draw_cur(cur_col, cur_row);
          SHOW_MOUSE;
     }  /* end if */
}  /* end wind_klik */


long find_clik(col, row)      /* find index to associate with cursor */
int  col, row;
{
     long line, index;
     int  len;

     if ((line = find_row(row)) == -1)
            /* past end of doc */
          index = doc_len();
     else
     {
          len = find_len(line);
          index = line + (len > col ? col : len-1);
     }  /* end else */
     return(index);
}  /* find_clik */


  /* select or deselect range; a toggle function. One restriction:
      old_index must be equal to either sel_start or sel_end or both.
      That limit will be adjusted, as will the  on-screen display. */
select(old_index, new_index)
long old_index, new_index;
{
     int  array[4];
     int  st_row, st_col, end_row, end_col;
     long start, end, st_line, end_line, scrn_st, scrn_end;
     int  row, len, rowlen;
     long line;
     char buff;

       /* draw top to bottom */
     if (old_index < new_index)
     {
          start = old_index;
          end = new_index - 1;
     }
     else if (old_index > new_index)
     {
          start = new_index;
          end = old_index - 1;
     }
     else return;

     vswr_mode(handle, 3);         /* XOR mode */

     scrn_st = find_row(0);
     scrn_end = find_clik(ch_cols-1, ch_rows-1);
     if (end >= scrn_st && start <= scrn_end)
     {

     if (start < scrn_st) start = scrn_st;  /* stay on the screen */
     if (end > scrn_end) end = scrn_end;
     find_index(start, &st_row, &st_line);
     st_col = start - st_line;
     find_index(end, &end_row, &end_line);
     end_col = end - end_line;

       /* invert new range */
     for (row = st_row, line = st_line; row <= end_row; ++row)
     {
          len = find_len(line);
            /* set left edge */
          array[0] = row == st_row ? workx + st_col*ch_xsize : workx;
            /* set top */
          array[1] = worky + row*ch_ysize;
            /* set right edge */
          rowlen = row == end_row ? end_col + 1 : len;
          fill_string(line + rowlen - 1, 1L, &buff);
          if (buff == '\r') --rowlen;
          array[2] = workx + rowlen * ch_xsize - 1;
            /* set bottom */
          array[3] = array[1] + ch_ysize - 1;
          if (array[0] < array[2]) vr_recfl(handle, array);

          line += len;
     }  /* end for */
     }  /* end if */

       /* adjust select region boundaries */
     if (old_index == sel_end)
          if (new_index >= sel_start)
               sel_end = new_index;
          else
          {
               sel_end = sel_start;
               sel_start = new_index;
          }  /* end else */
     else
          if (new_index <= sel_end)
               sel_start = new_index;
          else
          {
               sel_start = sel_end;
               sel_end = new_index;
          }  /* end else */
}  /* end select */


ar_up()           /* scroll screen one line */
{
     if (first_par == 0 && first_line == 0) return;

     HIDE_MOUSE;
     scrn_down();
     if (++cur_row >= ch_rows)
     {      /* keep cursor on screen */
          cur_line = find_row(cur_row=ch_rows-1);
          if (cur_col >= (cur_len=find_len(cur_line)))
               cur_col = cur_len-1;
          cur_index = cur_line + cur_col;
          draw_curs(cur_col, cur_row);
          }  /* end if */
     SHOW_MOUSE;
}  /* end ar_up */

ar_down()             /* scroll screen one line */
{
     if (find_row(ch_rows) == -1) return;

     HIDE_MOUSE;
     scrn_up();
     if (--cur_row < 0)
     {      /* keep cursor on screen */
          cur_line = find_row(cur_row=0);
          if (cur_col >= (cur_len=find_len(cur_line)))
               cur_col = cur_len-1;
          cur_index = cur_line + cur_col;
          draw_curs(cur_col, cur_row);
     }  /* end if */
     SHOW_MOUSE;
}  /* end ar_down */


pg_down()                /* move to next page */
{
     int  cnt, par_cnt;

       /* advance one screenful minus one line */
     if (find_row(ch_rows * 2 - 2) != -1)
     {
          cnt = ch_rows + first_line - 1;
          while (cnt >= (par_cnt=cnt_lines(first_par)))
          {
               cnt -= par_cnt;
               first_par = srch_for('\r', first_par) + 1;
          }  /* end while */
          first_line = cnt;
     }  /* end if */
     else
     {
          first_par = srch_back('\r',doc_len()-1) + 1;
          first_line = cnt_lines(first_par) - 1;
          while (find_row(ch_rows-1) == -1 && (first_par != 0 || first_line != 0))
          {
               if (first_line == 0)
               {
                    first_par = srch_back('\r', first_par - 2) + 1;
                    first_line = cnt_lines(first_par);
               }  /* end if */
               --first_line;
          }  /* end while */
     }  /* end else */

     set_cursor(cur_col, cur_row);
     rfsh_all();
}  /* end pg_down */


pg_up()                  /* move to previous page */
{
     int  line_cnt;
     long line;

       /* back up ch_rows-1 lines */
     line_cnt = ch_rows - first_line - 1;
     while (line_cnt > 0 && first_par != 0)
     {
          first_par = srch_back('\r', first_par - 2) + 1;
          line_cnt -= cnt_lines(first_par);
     }  /* end while */

     first_line = line_cnt < 0 ? -line_cnt : 0;

     set_cursor(cur_col, cur_row);
     rfsh_all();
}  /* end pg_up */


set_slide(pos)           /* adjust screen origin for new slider pos */
int  pos;
{
     long index, line;

     index = pos == 1000 ? doc_len() :
      pos*(doc_len()+find_clik(0,0)-find_clik(ch_cols-1,ch_rows-1))/1000;
     first_par = srch_back('\r', index - 1) + 1;
     line = first_par;
     first_line = 0;
     while ((line+=find_len(line)) < index)
          ++first_line;

       /* keep the screen filled */
     while (find_row(ch_rows-1) == -1 && (first_par!=0 || first_line!=0))
     {
          if (first_line == 0)
          {
               first_par = srch_back('\r', first_par-2) + 1;
               first_line = cnt_lines(first_par);
          }  /* end if */
          --first_line;
     }  /* end while */

     set_cursor(cur_col, cur_row);
     rfsh_all();
}  /* end set_slide */


set_size(width, height)  /* respond to window resizing */
int  width, height;
{
     long start, line;
     int  line_cnt, cnt, len, row;

     start = find_row(0);

       /* round off and enforce minimum size */
     ch_cols = (width - xdiff)/ch_xsize;
          if (ch_cols < 2) ch_cols = 2;
     ch_rows = (height - ydiff)/ch_ysize;
          if (ch_rows < 2) ch_rows = 2;

     wind_set(wind_handle, WF_CURRXYWH, windx, windy,
                          ch_cols*ch_xsize + xdiff,
                          ch_rows*ch_ysize + ydiff);
     wind_get(wind_handle, WF_WORKXYWH, &workx, &worky, &workw, &workh);

       /* leave starting index on first line */
     line = first_par;
     first_line = 0;
     while (line + (len=find_len(line)) <= start)
     {
          line += len;
          ++first_line;
     }  /* end while */

       /* but try to fill the window */
     if (find_row(ch_rows - 1) == -1)
     {
          find_index(doc_len(), &row, &line);
          cnt = ch_rows - row - 1;
          line_cnt = first_line;
          while (line_cnt < cnt && first_par != 0)
          {
               first_par = srch_back('\r', first_par - 2) + 1;
               line_cnt += cnt_lines(first_par);
          }  /* end while */

          first_line = line_cnt > cnt ? line_cnt - cnt : 0;
     }  /* end if */
          
     if (cur_row >= ch_rows) cur_row = ch_rows - 1;
     set_cursor(cur_col, cur_row);
     rfsh_all();
}  /* end set_size */


move_wind(x, y)          /* respond to window movement */
int  x, y;
{
       /* keep it all on screen */
     if (x + workw + xdiff > deskx + deskw)
          x = deskx + deskw - workw - xdiff;
     if (y + workh + ydiff > desky + deskh)
          y = desky + deskh - workh - ydiff;

     wind_set(wind_handle, WF_CURRXYWH, (windx=x), (windy=y),
               workw + xdiff, workh + ydiff);
     wind_get(wind_handle, WF_WORKXYWH, &workx, &worky, &workw, &workh);
}  /* end move_wind */


set_cursor(col, row)     /* set cursor pos to (col, row) or nearby */
{
     if ((cur_line = find_row(cur_row=row)) != -1)
     {
          if ((cur_col=col) >= (cur_len=find_len(cur_line)))
               cur_col = cur_len - 1;
          cur_index = cur_line + cur_col;
     }  /* end if */
     else
     {
          find_index((cur_index = doc_len()), &cur_row, &cur_line);
          cur_col = cur_index - cur_line;
          cur_len = cur_col + 1;
     }  /* end else */         

}  /* end set_cursor */


redraw(rl, rt, rw, rh)   /* redraw a portion of the window */
int  rl, rt, rw, rh;         /* rectangle extent */
{
     int  wl, wt, ww, wh;     /* window extent */
     int  clip[4];

     wind_update(TRUE);
     HIDE_MOUSE;
     wind_get(wind_handle, WF_FIRSTXYWH, &wl, &wt, &ww, &wh);
     while (ww && wh)
     {      /* do the rectangles intersect? */
          if (rl < wl+ww && wl < rl+rw && rt < wt+wh && wt < rt+rh)
          {
               clip[0] = wl;
               clip[2] = wl + ww - 1;
               clip[1] = wt;
               clip[3] = wt + wh - 1;
               vs_clip(handle, 1, clip);
               refresh(rl, rt, rw, rh);
               draw_curs(cur_col, cur_row);
          }  /* end if */
          wind_get(wind_handle, WF_NEXTXYWH, &wl, &wt, &ww, &wh);
     }  /* end while */
     SHOW_MOUSE;
     wind_update(FALSE);
     vs_clip(handle, 0, clip);
}  /* end redraw */


copy_sel()     /* copy selected region to cursor pos */
{
     if (sel_start == sel_end) return;
     dup_string(cur_index, sel_start, (long)(sel_end - sel_start));
     set_screen(cur_row);
     rfsh_all();
}  /* end copy_sel */


move_sel()     /* move selected region to cursor pos */
{
     long sel_len;

     if ((sel_len = sel_end-sel_start) == 0) return;
     if (cur_index >= sel_start && cur_index <= sel_end)
          return;

     dup_string(cur_index, sel_start, sel_len);
     if (cur_index >= sel_start) cur_index -= sel_len;
     del_string(sel_start, sel_len);
     sel_start = cur_index;
     sel_end = cur_index + sel_len;
     set_screen(cur_row);
     rfsh_all();
     
}  /* end move_sel */


del_sel()      /* delete selected region */
{
     if (sel_start == sel_end) return;

       /* adjust cursor position */
     if (cur_index >= sel_end)
          cur_index -= sel_end - sel_start;
     else if (cur_index >= sel_start)
          cur_index = sel_start;

     del_string(sel_start, (long)(sel_end - sel_start));

     set_screen(cur_row);
     rfsh_all();
}  /* end del_sel */


find()
{
     int  c, fromlen, tolen;
     char *from, *to;
     long index;

     do_find();

       /* which action? */
     c=4;
     while (findform[c].ob_state != SELECTED)
          ++c;
     findform[c].ob_state = NORMAL;

     from = fstr1;
     for (fromlen = 0; from[fromlen]; ++fromlen);
     to = fstr4;
     for (tolen = 0; to[tolen]; ++tolen);
     index = cur_index;
     if (fromlen == 0) return;

     HIDE_MOUSE;
     wind_update(TRUE);
     refresh(workx, worky, workw, workh);
     draw_curs(cur_col, cur_row);
     wind_update(FALSE);
     SHOW_MOUSE;

     switch (c) {
     case 4:        /* change all */
          while ((index = srch_for(from[0], index)) != -1)
          {
               if (match(index+1, from+1, fromlen-1))
               {
                    replace(index, fromlen, tolen, to);
                    index += tolen;
               }  /* end if */
               else
                    ++index;
          }  /* end while */
          break;
     case 5:        /* change first */
          while ((index = srch_for(from[0], index)) != -1 &&
            !match(index+1, from+1, fromlen-1))
               ++index;

          if (index != -1)
               replace(index, fromlen, tolen, to);
          break;
     case 6:        /* find */
          while ((index = srch_for(from[0], index)) != -1 &&
            !match(index+1, from+1, fromlen-1))
               ++index;

          if (index != -1)
          {
               cur_index = index;
               find_index(index, &cur_row, &cur_line);
               set_screen(cur_row != -1 ? cur_row : ch_rows/2);
               rfsh_all();
          }  /* end if */
          break;
     }  /* end switch */

}  /* end find */


match(index, string, len)     /* compare string with part of doc */
long index;    /* where in doc? */
char *string;  /* with what */
int  len;      /* how many chars? */
{
     register int c;
     char buffer[80];

     if (len == 0) return(TRUE);
     fill_string(index, (long) len, buffer);
     if (buffer[0] == '\0') return(FALSE);
     for(c=0; c<len && string[c] == buffer[c]; ++c);
     return(c == len);
}  /* end match */


replace(index, oldlen, newlen, newtext)
long index;
int  oldlen;
int  newlen;
char *newtext;
{
     long end_line;
     int  end_row, end_col, end_len;
     struct blitpoint newcur;

     HIDE_MOUSE;
     wind_update(TRUE);
     rfsh_char(cur_col, cur_row);

       /* change the text */
     cur_index = index;
     find_index(index, &cur_row, &cur_line);
     if (cur_row != -1)
          set_screen(cur_row);
     else
     {
          set_screen(1);
          refresh(workx, worky, workw, workh);
          draw_cur(cur_col, cur_row);
     }  /* end else */

     find_index(index+oldlen, &end_row, &end_line);
     if (end_row != -1)
     {
          end_col = index + oldlen - end_line;
          end_len = find_len(end_line);
     }  /* end if */
     else
     {
          end_row = ch_rows;
          end_col = 0;
          end_len = 1;
     }  /* end else */

     del_string(index, (long) oldlen);
     scrn_del(cur_row, cur_col, cur_index,
          end_row, end_col, end_len, (long) oldlen, &newcur);

     cur_row = newcur.row;
     cur_col = newcur.col;
     cur_len = cur_col + newcur.len;
     cur_line = cur_index - cur_col;

     if (cur_row == -1)
     {
          cur_row = 0;
          scrn_down();
     }  /* end if */

     if (newlen)
     {
          ins_string(index, (long) newlen, newtext);
          scrn_ins(cur_row, cur_col, cur_index, cur_len,
               (long) newlen, &newcur);

          cur_index += newlen;
          cur_row = newcur.row;
          cur_col = newcur.col;
          cur_len = cur_col + newcur.len;
          cur_line = cur_index - cur_col;

          if (cur_row == -1)
          {
               cur_row = 0;
               scrn_down();
          }  /* end if */

          if (cur_row == ch_rows)
          {
               --cur_row;
               scrn_up();
          }  /* end if */
     }  /* end if */

     draw_curs(cur_col, cur_row);
     wind_update(FALSE);
     SHOW_MOUSE;
}  /* end replace */         


load()
{
     char fname[80], transfer[BLOCK_SIZE];
     int  rflag, fhandle, result;
     long size, ins_point;

     /* append or replace? */
     if (doc_len() > 1)
     {
          rflag = form_alert(1,
"[2][Append new file or|replace existing text.][APPEND|REPLACE|CANCEL]");
          if (rflag == 3) return;
     }  /* end if */
     else rflag = 0;

     get_file(fname);
     if (fname[0] == '\0') return;
     fhandle = Fopen(fname, 0);    /* open for reading */
     if (fhandle < 0)
     {
          form_alert(1,"[3][File could not be opened.][OK]");
          return;
     }  /* end if */

       /* replace mode? */
     if (rflag == 2)
     {
          close_store();
          init_store();
     }  /* end if */

       /* fill it */
     ins_point = doc_len();
     do{
     size = Fread(fhandle, (long)BLOCK_SIZE, transfer);
     result = ins_string(ins_point, size, transfer);
     ins_point += size; 
     }  while(size == BLOCK_SIZE && result != 0);

     Fclose(fhandle);
     rfsh_all();
}  /* end load */


save()
{
     char fname[80], transfer[BLOCK_SIZE];
     int  rflag, fhandle;
     long sindex, slen, len;

       /* save selected region or whole document? */
     sindex = 0;
     slen = doc_len(); 
     if (sel_start != sel_end)
     {
          rflag = form_alert(1,
               "[2][Save selected region only?][  ALL  |SELECT|CANCEL]");
          if (rflag == 3) return;
          if (rflag == 2)
          {
               sindex = sel_start;
               slen = sel_end - sel_start;
          }  /* end if */
     }  /* end if */

     get_file(fname);
     if (fname[0] == '\0') return;
     fhandle = Fcreate(fname, 0);    /* open for writing */
     if (fhandle < 0)
     {
          form_alert(1,"[3][File could not be opened.][OK]");
          return;
     }  /* end if */

     while (slen)
     {
          len = slen > BLOCK_SIZE ? BLOCK_SIZE : slen;
          fill_string(sindex, len, transfer);
          Fwrite(fhandle, len, transfer);
          slen -= len;
          sindex += len;
     }  /* end while */

     Fclose(fhandle);
}  /* end save */


print()
{
     long pstart, plen, pindex;
     char buff[160];
     int  rflag, len, c;

     if (!Cprnos)
     {
          form_alert(1, "[3][No printer available.][OK]");
          return;
     }  /* end if */

       /* print selected region or whole document? */
     pstart = 0;
     plen = doc_len();
     if (sel_start != sel_end)
     {
          rflag = form_alert(2,
               "[2][Print selected region only?][SELECT|  ALL  ]");
          if (rflag == 1)
          {
               pstart = sel_start;
               plen = sel_end - sel_start;
          }  /* end if */
     }  /* end if */

     while (plen > 0)
     {
          len = find_len(pstart);
          fill_string(pstart, (long) len, buff);
          pstart += len;
          plen -= len;
          if (buff[len-1] == '\r') --len;
          for (c=0; c<len; Cprnout(buff[c++]));
          Cprnout('\r');
          Cprnout('\n');
          if (Cconis())
               if (form_alert(1,"[2][Quit printing?][CONTINUE|QUIT]")==2)
                    plen = 0;
     }  /* end while */
}  /* end print */


clear()                  /* erase all text */
{
       /* really? */
     if (
       form_alert(2,"[1][CLEAR will discard all text.][CLEAR |CANCEL]")
         == 2) return;

     close_store();
     init_store();
     rfsh_all();
}  /* end clear */


set_screen(row)          /* adjust display so cursor's near this row */
int  row;
{
     int  cnt;

     if (row < 0 || row >= ch_rows) return;

       /* put cursor on row 0 */
     cur_line = first_par = srch_back('\r', cur_index - 1) + 1;
     while (cur_line + (cur_len=find_len(cur_line)) <= cur_index)
     {
          ++first_line;
          cur_line += cur_len;
     }  /* end while */

       /* scroll down the right number of rows */
     cnt = row - first_line;
     while (cnt > 0 && first_par != 0)
     {
          first_par = srch_back('\r', first_par - 2) + 1;
          cnt -= cnt_lines(first_par);
     }  /* end while */

     first_line = cnt < 0 ? -cnt : 0;

       /* go further if screen can be filled more */
     while (find_row(ch_rows-1) == -1 && (first_line!=0 || first_par!=0))
     {
          if (first_line == 0)
          {
               first_par = srch_back('\r', first_par-2) + 1;
               first_line = cnt_lines(first_par);
          }  /* end if */
          --first_line;
     }  /* end while */

     find_index(cur_index, &cur_row, &cur_line);
     cur_len = find_len(cur_line);
     cur_col = cur_index - cur_line;

}  /* end set_screen */


/*....................DISPLAY MANAGEMENT STUFF..........................*/

refresh(left, top, width, height)
int left, top, width, height; /* these are pixel coordinates */
{
     long line;     /* offset of text at start of line */
     int  row;      /* line counter */
     long index;    /* offset of text at left edge of refresh zone */
     int  chars;    /* length of screen line */
       /* boundaries of refresh zone */
     int  start_row, start_col, end_row, end_col;
       /* working variables for printing a line */
     long pindex;
     long pcol, pchars;

     clr_scrn(left, top, width, height);  /* erase area */

       /* find character cell boundaries for refresh */
     start_row = (top - worky)/ch_ysize;
     if (start_row < 0) start_row = 0;
     start_col = (left - workx)/ch_xsize;
     if (start_col < 0) start_col = 0;
     end_row = (top + height - worky - 1)/ch_ysize + 1;
     if (start_row > ch_rows) start_row = ch_rows;
     end_col = (left + width - workx - 1)/ch_xsize + 1;
     if (start_col > ch_cols) start_col = ch_cols;

       /* any text to draw? */
     if ((line=find_row(start_row)) == -1) return;

       /* draw refresh area */
     for (row = start_row;
          row < end_row && (chars=find_len(line)) != -1;
          row++)
     {
          index = line + start_col;
          line += chars;
          chars = (end_col>chars ? chars : end_col) - start_col;

          if (sel_start == sel_end)     /* no selected region */
          {
               vswr_mode(handle, 1);    /* replace mode */
               if (chars > 0)
                    plot_text(row, start_col, index, (long) chars);
          }  /* end if */
          else                          /* region is selected */
          {
                 /* before selected text */
               vswr_mode(handle, 1);    /* replace mode */
               pchars = sel_start<index+chars ? sel_start-index : chars;
               if (pchars > 0)
                    plot_text(row, start_col, index, pchars);

                 /* selected text */
               vswr_mode(handle, 4);    /* reverse transparent mode */
               if (sel_start > index)
               {
                    pindex = sel_start;
                    pcol = start_col + sel_start - index;
               }  /* end if */
               else
               {
                    pindex = index;
                    pcol = start_col;
               }  /* end else */
               if (sel_end < index + chars)
                    pchars = sel_end - pindex;
               else
                    pchars = chars + index - pindex;
               if (pchars > 0)
                    plot_text(row, (int) pcol, pindex, pchars);

                 /* after selected text */
               vswr_mode(handle, 1);    /* replace mode */
               if (sel_end > index)
               {
                    pindex = sel_end;
                    pchars = index + chars - sel_end;
                    pcol = sel_end - index + start_col;
               }
               else
               {
                    pindex = index;
                    pchars = chars;
                    pcol = start_col;
               }
               if (pchars > 0)
                    plot_text(row, (int) pcol, pindex, pchars);
          }  /* end else */
     }  /* end for */

}  /* end refresh */


plot_text(row, col, index, len)
int  row, col;
long index, len;
{
     char rbuf[160];          /* array for refresh string */

     fill_string(index, (long) len, rbuf);
     rbuf[len] = '\0';                 /* null termite */
     if (rbuf[len-1] == '\r')          /* don't print CR's */
          if (len == 1)
               return;
          else
               rbuf[len-1] = '\0';
     v_gtext(handle, workx+col*ch_xsize, worky+row*ch_ysize, rbuf);
}  /* end plot_text */


draw_curs(col, row) /* draw the cursor */
int  col, row;
{
     long index;         /* document position of cursor */
     int  pts[4];        /* cursor edge array */
     char buff;          /* check character under cursor */

     pts[0] = pts[2] = workx+col*ch_xsize;
     pts[1] = worky+row*ch_ysize;
     pts[3] = pts[1]+ch_ysize-1;
     vswr_mode(handle, 1);         /* replace mode */
     vsf_color(handle, 1);
     if (sel_start != sel_end)     /* selection is active */
          {
               index = find_row(row) + col;
               if (index >= sel_start && index < sel_end)
               {
                    fill_string(index, 1L, &buff);
                    if (buff != '\r')   /* don't invert over CR */
                         vsf_color(handle, 0);
               }  /* end if */
          }  /* end if */
     v_bar(handle, pts);
}  /* end draw_curs */


rfsh_char(col, row)  /* redraw a single char cell */
int  col, row;
{
     refresh(workx+col*ch_xsize, worky+row*ch_ysize,
                ch_xsize, ch_ysize);
}  /* end rfsh_char */


rfsh_all()          /* full screen redraw */
{
     int  buffer[8];

     buffer[0] = WM_REDRAW;        /* make it look like a GEM request */
     buffer[1] = gl_apid;
     buffer[2] = 0;
     buffer[3] = wind_handle;
     buffer[4] = workx;
     buffer[5] = worky;
     buffer[6] = workw;
     buffer[7] = workh;

     appl_write(gl_apid, 16, buffer);
}  /* end rfsh_all */


   /* adjust the display for on-screen insertion of any number of chars,
     return the new location of the first char after insert */
scrn_ins(old_row, old_col, ins_index,
      old_len, ins_len, new_pos)
int  old_row, old_col, old_len;    /* old position of insert point */
long ins_index, ins_len;
struct blitpoint *new_pos;
{
     long row_index, prev_row; /* index of first char in old, prev row */
     int  prev_len;      /* length of preceding row */
     int  row_count, new_len, advance;
     long ind_count, blit_index, rtn;
     int  start_row, start_col, end_row, end_col;
     struct blitpoint source, dest;

     prev_len = (row_index=ins_index-old_col) - 
                    (prev_row=find_prev(old_row));

       /* find row and column where insert starts now */
     if (prev_row >= 0)  /* is there a previous row? */
     {
          row_count = old_row - 1;
          ind_count = prev_row;
     }  /* end if */
     else
     {
          row_count = old_row;
          ind_count = row_index;
     }  /* end else */

     while (ind_count + (new_len=find_len(ind_count)) <= ins_index)
     {
          ind_count += new_len;
          ++row_count;
     }  /* end while */

     start_row = row_count;
     start_col = ins_index - ind_count;

     if (start_row < old_row && old_row != 0 && old_col != 0)
          blit(old_row, 0, old_row-1, prev_len, old_col);

     if (start_row < 0 &&   /* inserting a CR? */
       (rtn = srch_back('\r', ins_index+ins_len)) > first_par)
               /* is the CR above the screen? */
          if (rtn < prev_row + find_len(prev_row))
               {
                    first_par = rtn + 1;
                    first_line = 0;
               }  /* end if */

       /* find row and column of first character after insert */
     while (ind_count+(new_len=find_len(ind_count)) <= ins_index+ins_len)
     {
          ind_count += new_len;
          ++row_count;
     }  /* end while */

     end_row = row_count;
     end_col = ins_index + ins_len - ind_count;

       /* move text following insertion */
     if (end_row >= 0)
     {
          source.row = old_row;
          source.col = old_col;
          source.len = old_len - old_col;
          dest.row = end_row;
          dest.col = end_col;
          dest.len = new_len - end_col;
          blit_index = ins_index + ins_len;
     }  /* end if */
     else
     {  /* dest is off top of screen */
     /* Assumption 1: insert point moved was on the top row of the
       screen and moved up one row, off the screen. It couldn't go any
       further than that, could it? */

          advance = new_len - end_col;
          blit_index = ins_index + ins_len + advance;
          source.row = old_row;
          source.col = old_col + advance;
          source.len = old_len - source.col;
     /* Assumption 2: source.len stays positive. For this not to be true,
       all of old_row would have to move to the end of previous line. But
       it didn't fit there before the insert and the line just got longer,
       so it can't fit now. */
          dest.row = 0;
          dest.col = 0;
          dest.len = find_len(blit_index);
      }  /* end else */    
     pushpull(&source, &dest, blit_index);

      /* move down text to left of cursor */
     if (start_row > old_row)
     {
          if (start_row < ch_rows && start_col != 0)
               blit(old_row, old_col-start_col, start_row, 0, start_col);
          clr_scrn(workx + (old_col-start_col)*ch_xsize,
                   worky + old_row*ch_ysize,
                   workw - (old_col-start_col)*ch_xsize,
                   ch_ysize);
     }  /* end if */

       /* draw inserted text */
     if (start_row == -1)
          start_row = start_col = 0;

     if (start_row == end_row && start_col < end_col
                     && start_row < ch_rows)
          refresh(workx + start_col*ch_xsize,
               worky + start_row*ch_ysize,
               (end_col - start_col)*ch_xsize,
               ch_ysize);

     if (start_row < end_row && start_row < ch_rows)
     {
          refresh(workx + start_col*ch_xsize,
               worky + start_row*ch_ysize,
               workw - start_col*ch_xsize,
               ch_ysize);
          if (end_row - start_row > 1 && start_row + 1 < ch_rows)
               refresh(workx,
                    worky + (start_row+1)*ch_ysize,
                    workw,
                    ((end_row < ch_rows ? end_row : ch_rows)
                       - start_row - 2) * ch_ysize);
          if (end_row < ch_rows && end_col != 0)
               refresh(workx,
                    worky + end_row*ch_ysize,
                    end_col*ch_xsize,
                    ch_ysize);
     }  /* end if */

     /* return new cursor position (end row, end col) */
     new_pos->row = end_row;
     new_pos->col = end_col;
     new_pos->len = new_len - end_col;
     return;

}  /* end scrn_ins */


   /* adjust the display for on-screen deletion of any number of chars,
     return the new location of the first char after delete. If del_index
     is located above row 0, del_row should be set to -1. */
scrn_del(del_row, del_col, del_index,
           old_row, old_col, old_len, del_len, new_pos)
int  del_row, del_col;        /* location of delete start */
long del_index;               /* first character deleted */
int  old_row, old_col, old_len; /* loc and linelen of delete end */   
long del_len;                 /* number of characters deleted */
struct blitpoint *new_pos;
{
     long prev_row;      /* index of preceding row */
     int  row_count, new_len;
     long ind_count;
     int  blit_row, blit_col;
     struct blitpoint source, dest;

       /* find new row and column for char after delete */
     if (del_row >= 0)
     {
          if ((prev_row=find_prev(del_row)) >= 0) /* there is prev row */
          {
               row_count = del_row - 1;
               ind_count = prev_row;
          }  /* end if */
          else
          {
               row_count = del_row;
               ind_count = del_index - del_col;
          }  /* end else */

          while (ind_count + (new_len=find_len(ind_count)) <= del_index)
          {
               ind_count += new_len;
               ++row_count;
          }  /* end while */

          blit_row = row_count;
          blit_col = del_index - ind_count;

            /* back up a row? */
          if (blit_row < del_row)
               if (blit_row >= 0)
               {      /* move text to left of cursor */
                    if (blit_col != 0)
                         blit(del_row, 0, blit_row,
                              blit_col-del_col, del_col);
               }  /* end if */
               else
                    blit_row = 0;

     }  /* end if */
     else
     {
       /* If the start of the delete range is above the top of the
        screen, we have to figure out where the screen starts now. If
        delete region includes the CR before first_par, we can search
        backward from del_index to find a new starting paragraph, then
        count lines to put the delete point at the top of the screen. */

            /* find a new screen origin */
          if (del_index < first_par)
               first_par = srch_back('\r', del_index - 1) + 1;

            /* put del_index on first screen row */
          first_line = 0;
          ind_count = first_par;
          while (ind_count + (new_len=find_len(ind_count)) <= del_index)
          {
               ++first_line;
               ind_count += new_len;
          }  /* end while */

          blit_row = 0;
          blit_col = del_index - ind_count;

     }  /* end else */

       /* move text following deletion */
     source.row = old_row;
     source.col = old_col;
     source.len = old_len - old_col;
     dest.row = blit_row;
     dest.col = blit_col;
     dest.len = new_len - blit_col;
     pushpull(&source, &dest, del_index);

       /* refresh start of first row if needed */
     if (blit_row == 0 && del_row == 0 && blit_col > del_col ||
       del_row < 0 && blit_col > 0)
          refresh(workx, worky, blit_col*ch_xsize, ch_ysize);

       /* if cursor moved forward */
     if (blit_row > del_row && blit_row > 0)
     {
          if (blit_col > 0)
               blit(del_row, del_col-blit_col, blit_row, 0, blit_col);
          clr_scrn(workx + (del_col-blit_col)*ch_xsize,
                    worky + del_row*ch_ysize,
                    workw - (del_col-blit_col)*ch_xsize,
                    ch_ysize);
     }  /* end if */
               
       /* return new cursor position (dest.row, dest.col) */
     new_pos->row = dest.row;
     new_pos->col = dest.col;
     new_pos->len = dest.len;
     return;

}  /* end scrn_del */


   /* move text up or down while maintaining wordwrap */
pushpull(source, dest, index)  /* recursive */
struct blitpoint *source, *dest;
long index;    /* the first character in the document to be moved */
{
     struct blitpoint newsource, newdest;
     int copylen;
     int array[8];

     if (source->col==dest->col && source->row==dest->row)
          return;   /* trivial case */

     if (dest->row >= ch_rows) return;       /* dest off the bottom */

     if (source.len == -1)                   /* end of document */
     {
          if (source->row > dest->row)
               clr_scrn(workx,
                    worky+dest->row*ch_ysize,
                    workw,
                    (source->row-dest->row)*ch_ysize);
          return;
     }  /* end if */

     if (source->row >= ch_rows)             /* source off the bottom */
     {
          refresh(workx + dest->col*ch_xsize,
               worky + dest->row*ch_ysize,
               workw - dest->col*ch_xsize,
               ch_ysize);
          if (dest->row < ch_rows-1)
               refresh(workx,
                    worky + (dest->row+1)*ch_ysize,
                    workw,
                    (ch_rows-dest->row-1)*ch_ysize);
          return;
     }  /* end if */

     if (source->col==0 && dest->col==0)     /* easy blit the rest */
     {
            /* left edge */
          array[0] = array[4] = workx;
            /* top edge  */
          array[1] = worky + source->row*ch_ysize;
          array[5] = worky + dest->row*ch_ysize;
            /* right edge */
          array[2] = array[6] = workx + workw - 1;
          if (dest->row > source->row)
            /* bottom edge */
          {  /* move text down */
               array[7] = worky + workh - 1;
               array[3] = array[7] + (source->row - dest->row)*ch_ysize;
          }  /* end if */
          else
          {  /* move text up */
               array[3] = worky + workh - 1;
               array[7] = array[3] + (dest->row - source->row)*ch_ysize;
          }  /* end else */

          vro_cpyfm(handle, 3, array, mfdb, mfdb);

          if (source->row > dest->row)
               refresh(array[0], worky + (ch_rows-1)*ch_ysize,
                workw, workh - (ch_rows-1)*ch_ysize);

          return;
     }  /* end if */

     /* figure out how much of the row to move and what to do next */
     if (dest->len > source->len)
     {
          copylen = source->len;
          newsource.row = source->row+1;
          newsource.col = 0;
          newsource.len = find_len(index+copylen);
          newdest.row = dest->row;
          newdest.col = dest->col+copylen;
          newdest.len = dest->len-copylen;
     }  /* end if */
     else if (dest->len == source->len)
     {
          copylen = source->len;
          newsource.row = source->row+1;
          newsource.col = 0;
          newsource.len = find_len(index+copylen);
          newdest.row = dest->row+1;
          newdest.col = 0;
          newdest.len = newsource.len;
     }  /* end if */
     else
     {
          copylen = dest->len;
          newsource.row = source->row;
          newsource.col = source->col+copylen;
          newsource.len = source->len-copylen;
          newdest.row = dest->row+1;
          newdest.col = 0;
          newdest.len = find_len(index+copylen);
     }  /* end else */

     if (source->row<dest->row ||
        source->row==dest->row && source->col<dest->col)
          pushpull(&newsource, &newdest, index+copylen);

     blit(source->row, source->col, dest->row, dest->col, copylen);

       /* blank end of line */
     if (newdest.col == 0 && dest->col+copylen < ch_cols)
          clr_scrn(workx + (dest->col+copylen)*ch_xsize,
                    worky + dest->row*ch_ysize,
                    workw - (dest->col+copylen)*ch_xsize,
                    ch_ysize);

     if (source->row>dest->row ||
        source->row==dest->row && source->col>dest->col)
          pushpull(&newsource, &newdest, index+copylen);

}  /* end pushpull */


          /* move chars on the screen */
blit(fromrow, fromcol, torow, tocol, copylen)
int fromrow, fromcol, torow, tocol, copylen;
{
     int array[8];

     array[0] = workx + fromcol*ch_xsize;    /* blit source */
     array[1] = worky + fromrow*ch_ysize;
     array[2] = array[0] + copylen*ch_xsize - 1;
     array[3] = array[1] + ch_ysize - 1;

     array[4] = workx + tocol*ch_xsize;      /* blit dest */
     array[5] = worky + torow*ch_ysize;
     array[6] = array[4] + copylen*ch_xsize - 1;
     array[7] = array[5] + ch_ysize - 1;

     vro_cpyfm(handle, 3, array, mfdb, mfdb);

}  /* end blit */


scrn_up()  /* scroll the screen upward */
{
     int  array[8];

     if (++first_line == cnt_lines(first_par))    /* adjust scrn start */
     {
          first_line = 0;
          first_par = srch_for('\r', first_par) + 1;
     }  /* end if */

     array[0] = array[4] = workx;       /* blit source */
     array[1] = worky + ch_ysize;
     array[2] = array[6] = workx + ch_cols*ch_xsize - 1;
     array[3] = worky + ch_rows*ch_ysize - 1;
     array[5] = worky;                  /* blit dest */
     array[7] = worky + (ch_rows - 1)*ch_ysize - 1;
     vro_cpyfm(handle, 3, array, mfdb, mfdb);

     refresh(workx, worky + (ch_rows-1)*ch_ysize, workw, ch_ysize);

}  /* end scrn_up */


scrn_down()  /* scroll the screen downward */
{
     int  array[8];

     if (--first_line < 0)    /* adjust start of screen */
     {
          first_par = srch_back('\r', first_par - 2) + 1;
          first_line = cnt_lines(first_par) - 1;
     }  /* end if */

     array[0] = array[4] = workx;       /* blit source */
     array[1] = worky;
     array[2] = array[6] = workx + ch_cols*ch_xsize - 1;
     array[3] = worky + (ch_rows - 1)*ch_ysize - 1;
     array[5] = worky + ch_ysize;       /* blit dest */
     array[7] = worky + ch_rows*ch_ysize - 1;
     vro_cpyfm(handle, 3, array, mfdb, mfdb);

     refresh(workx, worky, workw, ch_ysize);

}  /* end scrn_down */


clr_scrn(left, top, width, height)
int left, top, width, height;
{
     int  pts[4];

     vsf_color(handle, 0);
     vswr_mode(handle, 1);         /* replace mode */
     pts[0]=left;
     pts[1]=top;
     pts[2]=left+width-1;
     pts[3]=top+height-1;
     v_bar(handle, pts); /* clear the area */

}  /* end clr_scrn */


long find_row(row)   /* convert scrn row into document index */
int  row;
{
     register long  line;
     register int   len, r;

       /* find index of row */
     line = first_par;
     len = find_len(line);
     for(r = -first_line; r<row; r++)
     {
          line += len;             /* find next line */
          if ((len = find_len(line)) == -1) return(-1);   /* too far? */
     }  /* end for */

     return(line);

}  /* end find_row */


find_index(index, row, start_index)  /* find scrn line containing index */
long index, *start_index;
int  *row;
{
     register long line;
     register int  r,len;

       /* find correct row */
     if (index >= first_par)   /* throw out obvious case */
     {
          line = first_par;
          for (r = -first_line; (len = find_len(line)) != -1  &&
                               line + len <= index  &&
                               r != ch_rows; r++)
               line += len;
     }  /* end if */

     if (index < first_par || len == -1 || r < 0 || r==ch_rows)
     {
          *row = -1;
          *start_index = -1;
     }
     else
     {
          *row = r;
          *start_index = line;
     }
}  /* end find_index */


long find_prev(row)      /* find the index of the start of row-1 */
int  row;
{
     register long prev_row;
     register int count, new_len;

       /* find the start of the previous row */
     if (row > 0)
          prev_row = find_row(row - 1);
     else      /* row 0 */
          if (first_par || first_line)
          {
               if (first_line == 0)
               {         /* last line of prev paragraph */
                    for(prev_row = srch_back('\r', first_par - 2) + 1;
                        prev_row+(new_len=find_len(prev_row))!=first_par;
                        prev_row += new_len);
               }  /* end if */
               else      /* back one line */
               {
                    prev_row = first_par;
                    for(count = first_line-1; count; --count)
                        prev_row += find_len(prev_row);
               }  /* end else */
          }  /* end if */
          else
               prev_row = -1;

     return(prev_row);
}  /* end find_prev */


int  cnt_lines(index)    /* count number of scrn lines in para at index */
long index;
{
     register  long para_end, line;
     register  int  c;

     if ((para_end = srch_for('\r', index)) == -1) return(-1);
     line = index;
     for (c=1; (line += find_len(line)) <= para_end; c++);

     return(c);
}  /* end cnt_lines */
     

/*....................STORAGE MANAGEMENT STUFF..........................*/

init_store()
{
     /* create storage for one block */
     first_block=last_block=Malloc((long) sizeof(struct mem_control));
     first_block->next = first_block->prev = -1;
     first_block->size = 1;
     first_block->mem[0] = '\r';

      /* initialize display parameters */
     cur_index = cur_line = first_par = 0;
     cur_col = cur_row = first_line = 0;
     cur_len = 1;

      /* reset region select registers */
     sel_start = sel_end = 0;

}  /* end init_store */


struct mem_control *add_block(block) /* add memory to doc after block */
struct mem_control *block;
{
     register struct mem_control *nblock,*oblock;

     oblock = block;

      /* allocate memory for the block */
     if ((nblock=Malloc((long) sizeof(struct mem_contro))) == 0)
     {
          form_alert(1,"[3][Out of memory.][OK]");
          return(-1);
     }  /* end if */

      /* chain new block into list */
     nblock->next = oblock->next;
     nblock->prev = oblock;
     if (last_block == oblock)
          last_block = nblock;
     else
          oblock->next->prev = nblock;
     oblock->next = nblock;

      /* block is initially empty */
     nblock->size = 0;

     return(nblock);

}  /* end add_block */


rem_block(block)   /* free a memory block */
struct mem_control *block;
{
     register  struct mem_control *oblock;

     oblock = block;

      /* unhook the block */
     if (first_block == oblock)
          first_block = oblock->next;
     else
          oblock->prev->next = oblock->next;

     if (last_block == oblock)
          last_block = oblock->prev;
     else
          oblock->next->prev = oblock->prev;

      /* throw it away */
     Mfree(oblock);

}  /* end rem_block */


long doc_len()        /* find length of the document */
{
     register long count, nextcount;
     register struct mem_control *block;

      /* find the last block */
     block=first_block;
     count = 0;
     nextcount = block->size;
     while (block != last_block)
     {
          block=block->next;
          count=nextcount;
          nextcount+=block->size;
     }  /* end while */

     return(nextcount - 1);       /* don't count last CR */

}  /* end doc_len */


ins_string(index, length, string)  /* insert text at some point */
long index;
long length;
char string[];
{
     register  char *source, *dest;
     register  struct mem_control *block;
     register  long count, nextcount;
     struct    mem_control *dblock;
     long newsize;

      /* find the block containing index */
     block = first_block;
     count = 0;
     nextcount = block->size;
     while (nextcount < index)
     {
          if ((block=block->next) == -1) return;
          count = nextcount;
          nextcount += block->size;
     }  /* end while */

     dblock = block;          /* assume current block is big enough */
     newsize = block->size + length;  /* size of dest block */

     if (newsize > BLOCK_SIZE)     /* block spillover */
     {
          if (index + length <= count + BLOCK_SIZE)
          {
                /* inserted text fits in original block */
               if ((dblock = add_block(dblock)) == -1) return(0);
               newsize = nextcount - index;
               block->size += length - newsize;
          }  /* end if */
          else
          {
                /* insertion wraps past end of block */
               while (newsize > BLOCK_SIZE)
               {
                    if ((dblock = add_block(dblock)) == -1) return(0);
                    newsize -= BLOCK_SIZE;
               }  /* end while */
          }  /* end else */
     }  /* end if */

      /* copy original text forward to make room for insert */
     source = block->mem + nextcount - count;
     dest = dblock->mem + newsize;
     for (count = nextcount-index; count-- > 0; *(--dest) = *(--source));

      /* copy in string */
     for (count = 0; count < length; *(source++) = string[count++])
     {
          if (source == block->mem + BLOCK_SIZE)
          {
               block->size = BLOCK_SIZE;
               block = block->next;
               source = block->mem;
          } /* end if */
     } /* end for */

     dblock->size = newsize;

       /* adjust region selection variables */
     if (sel_start != sel_end && index < sel_end)
     {
          sel_end += length;
          if (index < sel_start)
               sel_start += length;
     }  /* end if */

     return(1);
}  /* end ins_string */


del_string(index, length)       /* remove text at some point */
long index;
long length;
{
     register  char *source, *dest;
     register  struct mem_control *block;
     register  long count, nextcount;
     long start;
     struct  mem_control *nextblock;

      /* find the block containing index */
     block = first_block;
     count = 0;
     nextcount = block->size;
     while (nextcount <= index)
     {
          if ((block = block->next) == -1) return;
          count = nextcount;
          nextcount += block->size;
     }  /* end while */

     start = index - count;                /* offset of copy target */
     while (nextcount <= index + length)   /* delete past end of block */
     {
          nextblock = block->next;

          if (start == 0)   
               rem_block(block);           /* dump whole blocks */
          else
          {
               block->size = start;        /* truncate partial block */
               start = 0;
          } /* end else */

          if ((block = nextblock) == -1) return;
          count = nextcount;
          nextcount += block->size;
     }  /* end while */

       /* adjust last (or only) block */
     dest = block->mem + start;
     source = block->mem + index + length - count;
     if (dest != source)
     {
          block->size -= source - dest;
         /* register variable 'count' changes meaning here */
          for (count = nextcount - index - length;
               count-- > 0;
               *(dest++) = *(source++));
     } /* end if */

       /* adjust region selection variables */
     if (sel_start != sel_end && index < sel_end)
     {
          if (index <= sel_start)
          {
               if (index+length <= sel_start)
               {
                    sel_start -= length;
                    sel_end -= length;
               }  /* end if */
               else if (index+length < sel_end)
               {
                    sel_start = index;
                    sel_end -= length;
               }  /* end if */
               else
                    sel_start = sel_end = 0;
          }  /* end if */
          else
          {
               if (index + length >= sel_end)
                    sel_end = index;
               else
                    sel_end -= length;
          }  /* end else */
     }  /* end if */

}  /* end del_string */


dup_string(dest, source, length)  /* copy text at source to dest */
long dest, source, length;
{
     register  char *copyfrom, *copyto;
     register  struct mem_control *block;
     register  long count, nextcount;
     struct    mem_control *dblock, *newblock, *iblock;
     long newsize;

     if (source + length > doc_len()) return;

      /* find the block containing dest */
     block = first_block;
     count = 0;
     nextcount = block->size;
     while (nextcount <= dest)
     {
          if ((block=block->next) == -1) return;
          count = nextcount;
          nextcount += block->size;
     }  /* end while */

       /* split document block containing dest */
     if (count == dest)
          iblock = block;
     else
     {
          if ((iblock=add_block(block)) == -1) return;
          copyfrom = block->mem + dest - count;
          copyto = iblock->mem;
          while (copyfrom < block->mem + block->size)
               *(copyto++) = *(copyfrom++);
          block->size = dest - count;
          iblock->size = nextcount - dest;
     }  /* end else */

       /* build chain of blocks for the duplicate text */
     dblock = -1;
     for (newsize = 0; newsize < length; newsize += BLOCK_SIZE)
     {
          newblock = Malloc((long) sizeof (struct mem_control));
          if (newblock == 0) break;
          newblock->next = dblock;
          newblock->size = 0;
          if (dblock != -1)
               dblock->prev = newblock;
          dblock = newblock;
     }  /* end for */

     if (newsize < length)    /* not enough mem */
     {
          while (dblock != -1)
          {      /* free what we already have, then bail out */
               newblock = dblock->next;
               Mfree(dblock);
               dblock = newblock;
          }  /* end while */
          form_alert(1,"[3][Out of memory.][OK]");
          return;
     }  /* end if */

      /* find the block containing source */
     block = first_block;
     count = 0;
     nextcount = block->size;
     while (nextcount <= source)
     {
          if ((block=block->next) == -1) return;
          count = nextcount;
          nextcount += block->size;
     }  /* end while */

       /* copy the text to the duplicate chain */
     copyfrom = block->mem + source - count;
     copyto = newblock->mem;
     for (count = length; count-- > 0; *(copyto++) = *(copyfrom++))
     {
          if (copyfrom == block->mem + BLOCK_SIZE)
          {
               do {
                    block = block->next;
                    copyfrom = block->mem;
               } while (block->size == 0);   /* skip empty blocks */
          }  /* end if */

          if (copyto == newblock->mem + BLOCK_SIZE)
          {
               newblock->size = BLOCK_SIZE;
               newblock = newblock->next;
               copyto = newblock->mem;
          }  /* end if */
     }  /* end for */
     newblock->size = copyto - newblock->mem;

       /* insert copied text into document before iblock */
     if (iblock == first_block)
          first_block = dblock;
     else
          iblock->prev->next = dblock;
     dblock->prev = iblock->prev;
     newblock->next = iblock;
     iblock->prev = newblock;

       /* adjust region selection variables */
     if (sel_start != sel_end && dest < sel_end)
     {
          sel_end += length;
          if (dest < sel_start)
               sel_start += length;
     }  /* end if */

}  /* end dup_string */


compact()   /* crunch document storage */
{
     register  struct mem_control *dblock;
     struct mem_control *sblock;
     register  char   *source, *dest;
     register  long count;

     dblock = first_block;

     while (dblock->next != -1)
     {
          sblock = dblock->next;     
          if (dblock->size == BLOCK_SIZE)
               dblock = sblock;
          else
          {      /* partially filled block */
               source = sblock->mem;
               dest = dblock->mem + dblock->size;

               if (dblock->size + sblock->size <= BLOCK_SIZE)
               {      /* merge two blocks */
                    for (count = sblock->size;
                         count-- > 0;
                         *(dest++) = *(source++));   /* copy text */

                    dblock->size += sblock->size;
                    rem_block(dblock->next);
               }  /* end if */
               else
               {      /* doesn't all fit */
                    for (count = BLOCK_SIZE - dblock->size;
                         count-- > 0;
                         *(dest++) = *(source++));   /* copy text */

                      /* adjust sizes */
                    sblock->size -= BLOCK_SIZE - dblock->size;
                    dblock->size = BLOCK_SIZE;

                    dest = sblock->mem;
                    for (count = sblock->size;
                         count-- > 0;
                         *(dest++) = *(source++));   /* shuffle dest */

                    dblock = sblock;
               }  /* end else */
          }  /* end else */
     }  /* end while */
}  /* end compact */


long srch_back(chr, start)  /* reverse search for char */
char chr;
long start;
{
     register  long count, nextcount;
     register  struct mem_control *block;
     register  char *pnt;

     if (start < 0) return(-1);

      /* find the block containing start */
     block = first_block;
     count = 0;
     nextcount=block->size;
     while (nextcount <= start)
     {
          if ((block=block->next) == -1) return(-1);
          count = nextcount;
          nextcount += block->size;
     }  /* end while */

       /* reverse search for char */
     for (pnt = block->mem + start - count; *pnt != chr; pnt--)
     {
          if (pnt == block->mem)
          {
               do {
                    if ((block=block->prev) == -1) return(-1);
                    pnt = block->mem + block->size;
                    nextcount = count;
                    count -= block->size;
               } while (block->size == 0);   /* skip empty blocks */
          }  /* end if */
     }  /* end for */

     return(count + (pnt - block->mem));

}  /* end srch_back */


long srch_for(chr, start)  /* forward search for char */
char chr;
long start;
{
     register  long count, nextcount;
     register  struct mem_control *block;
     register  char *pnt;

     if (start < 0) return(-1);

      /* find the block containing start */
     block = first_block;
     count = 0;
     nextcount=block->size;
     while (nextcount <= start)
     {
          if ((block=block->next) == -1) return(-1);
          count = nextcount;
          nextcount += block->size;
     }  /* end while */

       /* forward search for char */
     for (pnt = block->mem + start - count; *pnt != chr;)
     {
          if (++pnt == block->mem + nextcount - count)
          {
               do {
                    if ((block=block->next) == -1) return(-1);
                    pnt = block->mem;
                    count = nextcount;
                    nextcount += block->size;
               } while (block->size == 0);   /* skip empty blocks */
          }  /* end if */
     }  /* end for */

     return( count + (pnt - block->mem));

}  /* end srch_back */


close_store()  /* release all storage space */
{
     register  struct mem_control *block, *nextblock;

     block = first_block;
     while (block != -1)
     {
          nextblock=block->next;
          Mfree(block);
          block=nextblock;
     } /* end while */

}  /* end close_store */

/*.............................GEM STUFF................................*/

init_gem()
{
     int  c, cc, attrib[10];

     appl_init();
     acc_id = menu_register(gl_apid, "  Notepad  ");
     opened = FALSE;

     handle=graf_handle(&ret, &ret, &ret, &ret);
     vqt_attributes(handle, attrib);
     ch_xsize = attrib[8];
     ch_ysize = attrib[9];

       /* set up control form (fake menu) */
     for (c=0; c<9; rsrc_obfix(cntlform, c++));    /* make it usable */
     cx = ch_xsize*2-1;
     cntlform[0].ob_x = cx+1;
     cy = ch_ysize+3;
     cntlform[0].ob_y = cy;
     cw = cntlform[0].ob_width + 2;
     ch = cntlform[0].ob_height + 1;

       /* set up find form */
     for (c=0; c<8; rsrc_obfix(findform, c++));
     form_center(findform, &fx, &fy, &fw, &fh);

       /* prepare for file selector */
     fs_name[0] = '\0';
     fs_path[0] = Dgetdrv() + 'A';
     fs_path[1] = ':';
     Dgetpath(fs_path + 2, 0);
     for (c=2; fs_path[c]; ++c);
     cc = 0;
     while (fs_path[c++] = defname[cc++]);     /* default filespec */

}  /* end init_gem */


open_wind()
{
     int  c;

     handle=graf_handle(&ret, &ret, &ret, &ret);
     for (c=0; c<10; work_in[c++]=1);
     work_in[10]=2;
     v_opnvwk(work_in, &handle, work_out);

     vst_alignment(handle, 0, 5, &ret, &ret);
     mfdb[0] = mfdb[1] = 0;

       /* make a window */
     wind_get(0, WF_WORKXYWH, &deskx, &desky, &deskw, &deskh);
     windx = deskx + ch_xsize;
     windy = desky + ch_ysize;

     wind_handle = wind_create(CLOSER|NAME|FULLER|MOVER|SIZER|UPARROW|
          DNARROW|VSLIDE, deskx, desky, deskw, deskh);
     if (wind_handle < 0)
     {
          v_clsvwk(handle);
          return;
     }  /* end if */

     wind_set(wind_handle, WF_NAME, " NOTEPAD ", 0, 0);
     wind_set(wind_handle, WF_VSLIDE, (slidpos=1));
     wind_set(wind_handle, WF_VSLSIZE, (slidsize=1000));
     wind_calc(1, CLOSER|NAME|FULLER|MOVER|SIZER|UPARROW|DNARROW|VSLIDE,
           deskx, desky, deskw, deskh, &ret, &ret, &fullw, &fullh);
     xdiff = deskw - fullw;
     ydiff = deskh - fullh;
     fullw = (fullw/ch_xsize) * ch_xsize + xdiff;
     fullh = (fullh/ch_ysize) * ch_ysize + ydiff;

     ch_cols = 32;
     ch_rows = 8;

     graf_growbox(deskx, desky, ch_xsize, ch_ysize,
          windx, windy, ch_cols*ch_xsize+xdiff, ch_rows*ch_ysize+ydiff);
     wind_open(wind_handle, windx, windy,
               ch_cols*ch_xsize + xdiff,
               ch_rows*ch_ysize + ydiff);
     wind_get(wind_handle, WF_WORKXYWH, &workx, &worky, &workw, &workh);

     fulled = FALSE;
     topped = TRUE;

}  /* end open_wind */


close_wind()
{
     wind_close(wind_handle);
     graf_shrinkbox(workx+workw/2, worky+workh/2, ch_xsize, ch_ysize,
          workx, worky, workw, workh);
     wind_delete(wind_handle);
     v_clsvwk(handle);
}  /* end close_wind */


  /* interact with control form, return # of obj: 1-8 or -1 */
int  do_control()
{
     int  obj, new_obj, mx, my, button, kstate;
     int  event, rectx, recty, rectw, recth, rectf; 

       /* draw it */
     form_dial(FMD_START, 0, 0, 0, 0, cx, cy, cw, ch);
     objc_draw(cntlform, 0, 2, cx, cy, cw, ch);

       /* interact */
     wind_update(BEG_MCTRL);
     obj = -1;           /* nothing highlighted yet */
     graf_mkstate(&mx, &my, &button, &ret);

     do {  /* interaction loop */
     new_obj = objc_find(cntlform, 0, 2, mx, my);
     if (new_obj != obj)
     {
          if (obj >= 0)
               objc_change(cntlform, obj, 0,
                    cx, cy, cw, ch, NORMAL, 1);
          if (new_obj >= 0)
               objc_change(cntlform, new_obj, 0,
                    cx, cy, cw, ch, SELECTED, 1);
          obj = new_obj;
     }  /* end if */

     if (obj == -1)
     {
          rectf = 0;
          rectx = cntlform[0].ob_x;
          recty = cntlform[0].ob_y;
          rectw = cntlform[0].ob_width;
          recth = cntlform[0].ob_height;
     }  /* end if */
     else
     {
          rectf = 1;
          rectx = cntlform[obj].ob_x;
          recty = cntlform[obj].ob_y;
          rectw = cntlform[obj].ob_width;
          recth = cntlform[obj].ob_height;
     }  /* end else */

     event = evnt_multi(MU_M1 | MU_BUTTON,
                        1,1,1,
                        rectf, rectx, recty, rectw, recth,
                        0,0,0,0,0,
                        msg_buffer,0,0,&mx,&my,
                        &button,&ret,&ret,&ret);

     }  while (!(event & MU_BUTTON));

       /* wait for button up */
     evnt_button(1, 1, 0, &mx, &my, &button, &ret);
     wind_update(END_MCTRL);

       /* end it */
     form_dial(FMD_FINISH, 0, 0, 0, 0, cx, cy, cw, ch);
     if (obj >= 0)       /* deselect item but don't redraw */
          objc_change(cntlform, obj, 0, cx, cy, cw, ch, NORMAL, 0);
     return(obj);
}  /* end do_control */


do_find()      /* operate findform dialog */
{
     form_dial(FMD_START, 0, 0, 0, 0, fx, fy, fw, fh);
     objc_draw(findform, 0, 2, fx, fy, fw, fh);
     form_do(findform, 2);
     form_dial(FMD_FINISH, 0, 0, 0, 0, fx, fy, fw, fh);
}  /* end do_find */


get_file(name)      /* operate file selector */
char *name;
{
     int  button;
     char *src, *dest;

     fsel_input(fs_path, fs_name, &button);
     if (button == 0 || *fs_name == '\0' || *fs_name == '@')
     {    /* cancelled */
          *name = '\0';
          return;
     }  /* end if */

       /* concatenate and copy */
     dest = name;
     for (src = fs_path; *src != '\0'; *(dest++) = *(src++));

       /* don't include the *.* stuff */
     for (dest = src = name; *src != '\0'; ++src)
          if (*src == '\\') dest = src + 1;

     for (src = fs_name; *src != '\0'; *(dest++) = *(src++));
     *dest = '\0';
}  /* end get_file */

