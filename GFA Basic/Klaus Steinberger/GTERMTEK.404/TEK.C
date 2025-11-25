/**************************************************/
/*                                                */
/*   tek.c Tektronix emulations routinen          */
/*                                                */
/**************************************************/

#include  "ascii.h"
#include  "define.h"
#include  "obdefs.h"
#include  "gemdefs.h"
#include  "osbind.h"
#include  "tek.h"
#include  "termext.h"
#include  "termmode.h"
#include  "linea.h"

#define   ST_SIZE   32000

struct tek_coord graph_mem;
struct int_coord last_pos;
struct int_coord next_pos;
struct int_coord tek_cursor;
struct int_coord tek_alpha;
struct tek_coord curs_mem;
int tek_state;
int  cell_width;
int  cell_height;
int  dummy;
char tek_cmem[ST_SIZE];
int  tek_wp, tek_rp, tek_length;
int  tek_xx, tek_xy;     /* speicher fuer mouse exchange */
extern int old_mx, old_my;
extern struct t_mode my_setup;
struct    {
     int  fontnr;
     int  textcolor;
     int  rotation;
     int  hor;
     int  vert;
     int  wrt_mode;
     int  width;
     int  height;
     int  cell_width;
     int  cell_height;
}act_font;

struct    ft {
     struct fontdata *fontp[];
};

struct    linea     *lasave;
struct    linea     *ini_linea();
struct    ft  *fonttable;

static struct {
     char csize;
     char ltype;
     int  font;
} ext_status;

tek_init()
{
     tek_state = TEK_ALPHA;
     graph_mem.hiy = 0;
     graph_mem.hix = 0;
     graph_mem.loy = 0;
     graph_mem.lox = 0;
     graph_mem.eb = 0;
     last_pos.x = 0;
     last_pos.y = 0;
     next_pos.x = 0;
     next_pos.y = 0;
/*     vst_height(handle, 6, &dummy, &dummy, &cell_width, &cell_height);*/
/*     vst_alignment(handle, 0, 3, &dummy, &dummy);*/
     cell_width = 8;
     cell_height = 8;
     set_clip(0, 20, 640, 380);
     tek_alpha.x = 0;
     tek_alpha.y = 20+cell_height;
     tek_cursor.x = 320;
     tek_cursor.y = 220;
     tek_erase();
     tek_wp = 0;
     tek_rp = 0;
     tek_length = 0;
     vqt_attributes(handle, &act_font);
     lasave = ini_linea(&fonttable);
     ext_status.csize = ';';
     ext_status.ltype = '`';
     ext_status.font = 1;     /* 8*8 font */
     tek_clear();
}

tek_to_int(tek,ic)
struct tek_coord *tek;
struct int_coord *ic;
{
     if (tek_state & TEK_Y_CHANGE) {
          ic->y = (tek->loy & 0x1f) << 2;
          ic->y |= (tek->hiy & 0x1f) << 7;
          ic->y |= (tek->eb & 0xc) >> 2;
     }
     ic->x = (tek->lox & 0x1f) << 2;
     ic->x |= (tek->hix & 0x1f) << 7;
     ic->x |= (tek->eb & 0x3);
}

tek_scan(c)
char c;
{
     char cntrl;

     if (tek_state & TEK_ESC) {
          switch (c) {
          case NUL:
               break;
          case ENQ:
               tek_enq();
               tek_state &= ~TEK_ESC;
               break;
          case BEL:
               ring_bell();
               tek_state &= ~TEK_ESC;
               break;
          case BS:
               tek_left();
               tek_state &= ~TEK_ESC;
               break;
          case HT:
               tek_right();
               tek_state &= ~TEK_ESC;
               break;
          case CR:
          case LF:
               break;
          case VT:
               tek_up();
               tek_state &= ~TEK_ESC;
               break;
          case FF:
               tek_clear();
               tek_erase();
               if (tek_state & TEK_GIN) {
                    gin_off();
               }
               tek_state &= ~(TEK_ESC|TEK_GRAPH|TEK_VECTOR|TEK_POINT|
                              TEK_INCREMENT|TEK_WRITE|TEK_LOY|TEK_BYPASS|
                              TEK_GIN);
               tek_state |= TEK_ALPHA;
               break;
          case SO:
               tek_alt_char();
               tek_state &= ~TEK_ESC;
               break;
          case SI:
               tek_asc_char();
               tek_state &= ~TEK_ESC;
               break;
          case ETB:
               tek_copy();
               tek_state &= ~TEK_ESC;
          case CAN:
               tek_state &= ~TEK_ESC;
               break;
          case SUB:
               tek_state &= ~TEK_ESC;   /* Crosshair */
               tek_state |= TEK_BYPASS | TEK_GIN;
               gin_on();
               break;
          case FS:
               if (tek_state & TEK_GIN) {
                    gin_off();
               }
               tek_state &= ~(TEK_ESC|TEK_ALPHA|TEK_VECTOR|TEK_INCREMENT|
                              TEK_GIN|TEK_BYPASS|TEK_LOY);
               tek_state |= TEK_GRAPH|TEK_POINT|TEK_Y_COORD|TEK_WRITE;
               break;
          case GS:
               if (tek_state & TEK_GIN) {
                    gin_off();
               }
               tek_state &= ~(TEK_ESC|TEK_ALPHA|TEK_POINT|TEK_INCREMENT|
                              TEK_GIN|TEK_BYPASS|TEK_LOY|TEK_WRITE);
               tek_state |= TEK_GRAPH|TEK_VECTOR|TEK_Y_COORD;
               break;
          case RS:
               if (tek_state & TEK_GIN) {
                    gin_off();
               }
               tek_state &= ~(TEK_ESC|TEK_ALPHA|TEK_POINT|TEK_VECTOR|
                              TEK_GIN|TEK_BYPASS|TEK_LOY);
               tek_state |= TEK_GRAPH|TEK_INCREMENT|TEK_Y_COORD;
               if (tek_state & TEK_IWRITE) {
                    tek_state |= TEK_WRITE;
               } else {
                    tek_state &= ~TEK_WRITE;
               }
               break;
          case US:
               if (tek_state & TEK_GRAPH) {
                    tek_set_alpha();
               }
               if (tek_state & TEK_GIN) {
                    gin_off();
               }
               tek_state &= ~(TEK_ESC|TEK_GRAPH|TEK_POINT|TEK_VECTOR|
                              TEK_INCREMENT|TEK_LOY|TEK_WRITE|
                              TEK_BYPASS|TEK_Y_COORD|TEK_GIN);
               tek_state |= TEK_ALPHA;
               break;
          case '`':
          case 'h':
               vsl_type (handle, 1);    /* set normal line type */
               tek_state &= ~TEK_ESC;
               ext_status.ltype = c;
               break;
          case 'a':
          case 'i':
               vsl_type (handle, 3);    /* set dotted line type */
               tek_state &= ~TEK_ESC;
               ext_status.ltype = c;
               break;
          case 'b':
          case 'j':
               vsl_type (handle, 4);    /* set dot - dash type */
               tek_state &= ~TEK_ESC;
               ext_status.ltype = c;
               break;
          case 'c':
          case 'k':
               vsl_type (handle, 5);    /* set short dash type */
               tek_state &= ~TEK_ESC;
               ext_status.ltype = c;
               break;
          case 'd':
          case 'l':
               vsl_type (handle, 2);    /* set long dash mode */
               tek_state &= ~TEK_ESC;
               ext_status.ltype = c;
               break;
          case 'e':
          case 'm':
          case 'f':
          case 'n':
          case 'g':
          case 'o':
               vsl_type (handle, 1);
               tek_state &= ~TEK_ESC;
               ext_status.ltype = c;
               break;
          case '?':
               graph_mem.loy = c;
               tek_state &= ~TEK_ESC;
               break;
          case ';':
/*               vst_height(handle, 6, &dummy, &dummy, &cell_width,
                                     &cell_height);
               vqt_attributes(handle, &act_font);*/
               ext_status.csize = c;
               ext_status.font = 1;
               cell_height = 8;
               cell_width = 8;
               tek_state &= ~TEK_ESC;
               break;
          case ':':
/*               vst_height(handle, 9, &dummy, &dummy, &cell_width,
                                     &cell_height);
               vqt_attributes(handle, &act_font);*/
               ext_status.csize = c;
               ext_status.font = 1;
               cell_height = 8;
               cell_width = 8;
               tek_state &= ~TEK_ESC;
               break;
          case '9':
/*               vst_height(handle,16, &dummy, &dummy, &cell_width,
                                     &cell_height);
               vqt_attributes(handle, &act_font);*/
               ext_status.csize = c;
               ext_status.font = 2;
               cell_height = 16;
               cell_width = 8;
               tek_state &= ~TEK_ESC;
               break;
          case '8':
/*               vst_height(handle,20, &dummy, &dummy, &cell_width,
                                     &cell_height);
               vqt_attributes(handle, &act_font);*/
               ext_status.csize = c;
               ext_status.font = 2;
               cell_height = 16;
               cell_width = 8;
               tek_state &= ~TEK_ESC;
               break;
          default:
               tek_state &= ~TEK_ESC;
               break;
          }
     } else if (tek_state & TEK_BYPASS) {
          switch (c) {
          case BEL:
               ring_bell();
               break;
          case LF:
               tek_down();
               break;
          case CR:
               if (tek_state & TEK_GRAPH) {
                    tek_m1();
               }
               if (tek_state & TEK_GIN) {
                    gin_off();
               }
               tek_state &= ~(TEK_BYPASS|TEK_GRAPH|TEK_POINT|TEK_VECTOR|
                              TEK_INCREMENT|TEK_LOY|TEK_WRITE|TEK_GIN);
               tek_state |= TEK_ALPHA;
               break;
          case ESC:
               tek_state |= TEK_ESC;
               break;
          case FS:
               if (tek_state & TEK_GIN) {
                    gin_off();
               }
               tek_state &= ~(TEK_ALPHA|TEK_VECTOR|TEK_INCREMENT|
                              TEK_GIN|TEK_BYPASS|TEK_LOY);
               tek_state |= TEK_GRAPH|TEK_POINT|TEK_Y_COORD|TEK_WRITE;
               break;
          case GS:
               if (tek_state & TEK_GIN) {
                    gin_off();
               }
               tek_state &= ~(TEK_ALPHA|TEK_POINT|TEK_INCREMENT|
                              TEK_GIN|TEK_BYPASS|TEK_LOY|TEK_WRITE);
               tek_state |= TEK_GRAPH|TEK_VECTOR|TEK_Y_COORD;
               break;
          case RS:
               if (tek_state & TEK_GIN ) {
                    gin_off();
               }
               tek_state &= ~(TEK_ALPHA|TEK_POINT|TEK_VECTOR|
                              TEK_GIN|TEK_BYPASS|TEK_LOY);
               tek_state |= TEK_GRAPH|TEK_INCREMENT|TEK_Y_COORD|TEK_WRITE;
               if (tek_state & TEK_IWRITE) {
                    tek_state |= TEK_WRITE;
               } else {
                    tek_state &= ~TEK_WRITE;
               }
               break;
          case US:
               if (tek_state & TEK_GRAPH) {
                    tek_set_alpha();
               }
               if (tek_state & TEK_GIN) {
                    gin_off();
               }
               tek_state &= ~(TEK_GRAPH|TEK_VECTOR|TEK_POINT|TEK_INCREMENT|
                              TEK_BYPASS|TEK_LOY|TEK_Y_COORD|TEK_WRITE|
                              TEK_GIN);
               tek_state |= TEK_ALPHA;
               break;
          default:
               break;
          }
     } else if (tek_state & TEK_GRAPH) {
          if (c < 0x20) {     /* Control Characters */
               switch(c) {
               case BEL:
                    ring_bell();
                    break;
               case LF:
                    break;
               case CR:
                    tek_state &= ~(TEK_GRAPH|TEK_VECTOR|TEK_POINT|TEK_INCREMENT);
                    tek_state |= TEK_ALPHA;
                    tek_m1();
                    break;
               case ESC:
                    tek_state |= TEK_ESC;
                    break;
               case FS:
                    tek_state &= ~(TEK_VECTOR|TEK_INCREMENT);
                    tek_state |= TEK_POINT|TEK_WRITE;
                    break;
               case GS:
                    tek_state &= ~(TEK_WRITE|TEK_POINT|TEK_INCREMENT);
                    tek_state |= TEK_VECTOR;
                    break;
               case RS:
                    tek_state &= ~(TEK_VECTOR|TEK_POINT);
                    tek_state |= TEK_INCREMENT|TEK_WRITE;
                    if (tek_state & TEK_IWRITE) {
                         tek_state |= TEK_WRITE;
                    } else {
                         tek_state &= ~TEK_WRITE;
                    }
                    break;
               case US:
                    tek_set_alpha();
                    tek_state &= ~(TEK_GRAPH|TEK_VECTOR|TEK_POINT|
                                   TEK_WRITE|TEK_LOY|TEK_Y_COORD|
                                   TEK_INCREMENT);
                    tek_state |= TEK_ALPHA;
                    break;
               default:
                    /* do nothing */
               }
          } else {
               if (tek_state & TEK_INCREMENT) {
                    switch (c) {
                    case 'P':
                         tek_state |= TEK_WRITE|TEK_IWRITE;
                         break;
                    case ' ':
                         tek_state &= ~(TEK_WRITE|TEK_IWRITE);
                         break;
                    case 'D':
                         next_pos.y += 1;
                         plot_tek();
                         break;
                    case 'E':      /* right and up */
                         next_pos.y += 1;
                         next_pos.x += 1;
                         plot_tek();
                         break;
                    case 'A':
                         next_pos.x += 1;
                         plot_tek();
                         break;
                    case 'I':
                         next_pos.x += 1;
                         next_pos.y -= 1;
                         plot_tek();
                         break;
                    case 'H':
                         next_pos.y -= 1;
                         plot_tek();
                         break;
                    case 'J':
                         next_pos.y -= 1;
                         next_pos.x -= 1;
                         plot_tek();
                         break;
                    case 'B':
                         next_pos.x -= 1;
                         plot_tek();
                         break;
                    case 'F':
                         next_pos.x -= 1;
                         next_pos.y += 1;
                         plot_tek();
                         break;
                    default:
                         break;
                    }
               } else {
                    cntrl = 0x60 & c;
                    if (tek_state & TEK_Y_COORD) {
                         if (cntrl == HIY) {
                              graph_mem.hiy = c;
                              tek_state |= TEK_Y_CHANGE;
                        } else if (cntrl == LOY) {
                              if ((c == DEL) && (my_setup.graphic & M_G_DEL)) {
                                   graph_mem.loy = c;
                                   tek_state &= ~TEK_Y_COORD;
                                   tek_state |= TEK_Y_CHANGE|TEK_LOY;
                              } else {
                                   graph_mem.loy = c;
                                   tek_state &= ~TEK_Y_COORD;
                                   tek_state |= TEK_LOY|TEK_Y_CHANGE;
                              }
                         } else if (cntrl == LOX) {
                              tek_lox(c);
                         }
                    } else {
                         if (cntrl == HIX) {
                              graph_mem.hix = c;
                         } else if (cntrl == LOY) {    /* Extended Byte */
                              if ((c == DEL) && (my_setup.graphic & M_G_DEL)) {
                                   graph_mem.eb = graph_mem.loy;
                                   graph_mem.loy = c;
                                   tek_state |= TEK_Y_CHANGE;
                              } else {
                                   graph_mem.eb = graph_mem.loy;
                                   graph_mem.loy = c;
                                   tek_state |= TEK_Y_CHANGE;
                              }
                         } else if (cntrl == LOX) {
                              tek_lox(c);
                         }
                    }
               }
          }
     } else if (tek_state & TEK_ALPHA) {    /* end if (tek_state & TEK_GRAPH) */
          if (c < 0x20) {     /* Control Character */
               switch (c) {
               case BEL:
                    ring_bell();
                    break;
               case BS:
                    tek_left();
                    break;
               case HT:
                    tek_right();
                    break;
               case LF:
                    tek_down();
                    break;
               case VT:
                    tek_up();
                    break;
               case CR:
                    tek_cr();
                    break;
               case ESC:
                    tek_state |= TEK_ESC;
                    break;
               case FS:
                    tek_state &= ~(TEK_ALPHA|TEK_LOY);
                    tek_state |= TEK_GRAPH|TEK_POINT|TEK_WRITE|TEK_Y_COORD;
                    break;
               case GS:
                    tek_state &= ~(TEK_ALPHA|TEK_WRITE|TEK_LOY);
                    tek_state |= TEK_GRAPH|TEK_VECTOR|TEK_Y_COORD;
                    break;
               case RS:
                    tek_state &= ~(TEK_ALPHA|TEK_LOY);
                    tek_state |= TEK_GRAPH|TEK_INCREMENT|TEK_Y_COORD;
                    if (tek_state & TEK_IWRITE) {
                         tek_state |= TEK_WRITE;
                    } else {
                         tek_state &= ~TEK_WRITE;
                    }
               default: 
                    /* do nothing */
               }
          } else {
               if ( c != 0x7f ) {
                    tek_type(c);
                    tek_right();
               }
          }
     }
}


tek_lox(c)
char c;
{
     graph_mem.lox = c;
     tek_to_int(&graph_mem, &next_pos);
     plot_tek();
     tek_state |= TEK_WRITE|TEK_Y_COORD;
     tek_state &= ~(TEK_LOY|TEK_Y_CHANGE);
}

plot_tek()
{
     long im;

     if (tek_state & TEK_WRITE) {
          if ((tek_state & TEK_VECTOR) ||
              (tek_state & TEK_INCREMENT)) {
               pxyarray[0] = last_pos.x;
               pxyarray[1] = last_pos.y;
               im = (long)319 * (long)next_pos.x;
               pxyarray[2] = (int)((1024L + im) / (long)2048);
               if (tek_state & TEK_Y_CHANGE) {
                    im = (long)63 * (long)next_pos.y;
                    pxyarray[3] = 399 - (int)((260L + im) / (long)520);
                    last_pos.y = pxyarray[3];
               } else {
                    pxyarray[3] = last_pos.y;
               }               
               last_pos.x = pxyarray[2];
               v_pline ( handle, 2, pxyarray);
          } else if (tek_state & TEK_POINT) {
               im = (long)319 * (long)next_pos.x;
               pxyarray[0] = (int)((1024L + im) / (long)2048);
               if (tek_state & TEK_Y_CHANGE) {
                    im = (long)63 * (long)next_pos.y;
                    pxyarray[1] = 399 - (int)((260L + im) / (long)520);
                    last_pos.y = pxyarray[3];
               } else {
                    pxyarray[1] = last_pos.y;
               }               
               last_pos.x = pxyarray[0];
               v_pmarker(handle, 1, pxyarray);
          }
     } else {
          im = (long)319 * (long)next_pos.x;
          last_pos.x = (int)((1024L + im) / 2048L);
          if (tek_state & TEK_Y_CHANGE) {
               im = (long)63 * (long)next_pos.y;
               last_pos.y = 399 - (int)((260L + im) / 520L);
          }
     }
}

int_to_tek(ic, it)
struct tek_coord *it;
struct int_coord *ic;
{
     long im;

     im = (long)ic->x * 2048L;
     im = im / 319L;
     it->hix = ((int)im >> 7) & 0x1f;
     it->lox = ((int)im >> 2) & 0x1f;
     im = (399L - ic->y) * 520L;
     im = im /63L;
     it->hiy = ((int)im >> 7) & 0x1f;
     it->loy = ((int)im >> 2) & 0x1f;
}

ring_bell()
{
     Cconout(BEL);
}

tek_set_alpha()
{
     long im;

     tek_alpha.x = last_pos.x;
     tek_alpha.y = last_pos.y;
}

tek_m1()
{
     long im;
     tek_alpha.x = 0;
     tek_alpha.y = last_pos.y;
}

tek_left()
{
     tek_alpha.x -= cell_width;
     if (tek_alpha.x < 0) {
          tek_alpha.x = 0;
     }
}

tek_right()
{
     tek_alpha.x += cell_width;
     if (tek_alpha.x > 632) {
          tek_alpha.x = 632;
     }
}

tek_up()
{
     tek_alpha.y -= cell_height;
     if (tek_alpha.y < 30) {
          tek_alpha.y = 20+cell_height;
     }
}

tek_down()
{
     tek_alpha.y += cell_height;
     if (tek_alpha.y > 400) {
          tek_alpha.y = 20+cell_height;
     }
}

tek_cr()
{
     graph_mem.eb = 0;
     tek_alpha.x = 0;
}

tek_alt()
{
}

tek_asc()
{
}

tek_enq()
{
     if (tek_state & TEK_ALPHA) {
          int_to_tek(&tek_alpha, &curs_mem);
          Cauxout(0x37);      /* Status Byte */
          Cauxout(0x20 | (curs_mem.hix & 0x1f));
          Cauxout(0x20 | (curs_mem.lox & 0x1f));
          Cauxout(0x20 | (curs_mem.hiy & 0x1f));
          Cauxout(0x20 | (curs_mem.loy & 0x1f));
     } else if (tek_state & TEK_GIN) {
          int_to_tek(&tek_cursor, &curs_mem);
          Cauxout(0x20 | (curs_mem.hix & 0x1f));
          Cauxout(0x20 | (curs_mem.lox & 0x1f));
          Cauxout(0x20 | (curs_mem.hiy & 0x1f));
          Cauxout(0x20 | (curs_mem.loy & 0x1f));
     } else {
          Cauxout(0x33);
          Cauxout(0x20 | (graph_mem.hix & 0x1f));
          Cauxout(0x20 | (graph_mem.lox & 0x1f));
          Cauxout(0x20 | (graph_mem.hiy & 0x1f));
          Cauxout(0x20 | (graph_mem.loy & 0x1f));
     }
     if (my_setup.graphic & M_G_CR) {
          Cauxout(CR);
     }
     if (my_setup.graphic & M_G_EOT) {
          Cauxout(EOT);
     }
}

tek_gin(mx,my)
int  mx,my;
{
     tek_cursor.x = mx;
     tek_cursor.y = my;
     graf_mouse(ARROW, &dummy);
     hide_mouse();
     int_to_tek(&tek_cursor, &curs_mem);
     if (my_setup.comm & M_SLOW) {
          evnt_timer(20,0);   /* wait 20 ms before next send */
     }
     Cauxout(0x20 | (curs_mem.hix & 0x1f));
     if (my_setup.comm & M_SLOW) {
          evnt_timer(20,0);   /* wait 20 ms before next send */
     }
     Cauxout(0x20 | (curs_mem.lox & 0x1f));
     if (my_setup.comm & M_SLOW) {
          evnt_timer(20,0);   /* wait 20 ms before next send */
     }
     Cauxout(0x20 | (curs_mem.hiy & 0x1f));
     if (my_setup.comm & M_SLOW) {
          evnt_timer(20,0);   /* wait 20 ms before next send */
     }
     Cauxout(0x20 | (curs_mem.loy & 0x1f));
     if (my_setup.graphic & M_G_CR) {
          if (my_setup.comm & M_SLOW) {
               evnt_timer(20,0);   /* wait 20 ms before next send */
          }
          Cauxout(CR);
     }
     if (my_setup.graphic & M_G_EOT) {
          if (my_setup.comm & M_SLOW) {
               evnt_timer(20,0);   /* wait 20 ms before next send */
          }
          Cauxout(EOT);
     }
     gin_off();
     tek_state &= ~TEK_GIN;
}

tek_copy()
{
}

/*
tek_type(c)
char c;
{
     char text[2];

     text[0] = c;
     text[1] = '\0';
     v_gtext(handle, tek_alpha.x, tek_alpha.y, text);
}
*/

tek_type(c)
char c;
{
     struct fontdata *fp;     /* pointer to the font header */
     int  sx;
     int  wt;
     register int  char_index;

     fp = fonttable->fontp[ext_status.font];
     char_index = (int)c - fp->firstade;
     sx = lasave->_SOURCEX;
     wt = lasave->_WRT_MODE;
     lasave->_FBASE = fp->font_data;
     lasave->_FWIDTH = fp->form_width;
     lasave->_SOURCEX = *(fp->char_off + (long)char_index);
     lasave->_DELX = *(fp->char_off + (long)(char_index) + 1L) - lasave->_SOURCEX;
     lasave->_DELY = fp->form_height;
     lasave->_DESTX = tek_alpha.x;   /* aligned to bottom */
     lasave->_DESTY = tek_alpha.y - fp->top;
     lasave->_WRT_MODE = 1;   /* transparent */
     lasave->_SCALE = 0;
     lasave->_DDA_INC = 0xffff;
     lasave->_T_SCLSTS = 1;
     lasave->_MONO_STATUS = 1;
     lasave->_XACC_DDA = 0x8000;
     textblt();
     lasave->_WRT_MODE = wt;
     lasave->_SOURCEX = sx;
}

tek_erase()
{
     v_clrwk(handle);
     menu_bar(gl_menu, TRUE);
     tek_alpha.x = 0;
     tek_alpha.y = 20+cell_height;
     graph_mem.eb = 0;
}

tek_clear()
{
     tek_wp = 0;
     tek_rp = 0;
     tek_lenght = 0;
     tek_store(ESC);
     tek_store(ext_status.csize);
     tek_store(ESC);
     tek_store(ext_status.ltype);
}

tek_store(c)
char c;
{
     if (tek_length < ST_SIZE) {
          tek_cmem[tek_wp++] = c;
          tek_length ++;
     }
}

tek_readout()
{
     int  i;

     for (i = 0; i < tek_length; i++) {
          tek_scan(tek_cmem[i]);
     }
}

tek_cross(x,y)
int  x,y;
{
     pxyarray[0] = x;
     pxyarray[1] = 20;
     pxyarray[2] = x;
     pxyarray[3] = 399;
     v_pline(handle,2, pxyarray);
     pxyarray[0] = 0;
     pxyarray[1] = y;
     pxyarray[2] = 639;
     pxyarray[3] = y;
     v_pline(handle, 2, pxyarray);
}

gin_on()
{
     if (my_setup.graphic & M_G_LHAIR) {
          vswr_mode(handle,3);
          old_mx = mx;
          old_my = my;
          tek_cross(mx,my);
     } else {
          show_mouse();
          graf_mouse(THIN_CROSS, &dummy);
     }
}

gin_off()
{
     if (my_setup.graphic & M_G_LHAIR) {
          tek_cross(old_mx,old_my);
          vswr_mode(handle, 1);
     } else {
          graf_mouse(ARROW, &dummy);
          hide_mouse();
     }
}

