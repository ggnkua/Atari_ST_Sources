/*
 * WTERMF - Window Terminal, 'full' version
 *
 * Matt Kimmel, 1987
 *
 * This program implements a terminal program inside a window as a desk
 * accessory.  See the header in the 'stripped' version for programming
 * notes.
 *
 * This version is larger and slower but contains many features - three
 * font sizes, RS232 buffer sizing, a cursor, setting of RS232 parameters,
 * and saving of configuration.  This version requires a resource file,
 * WTERMF.C.
 *
 */
#include <stdio.h>
#include <gemdefs.h>
#include <osbind.h>
#include <obdefs.h>
#include <string.h>
#include "wtermf.h" /* Resource defs */

/* Defines for window gadgets */
#define NAME 0x0001
#define CLOSE 0x0002
#define FULL 0x0004
#define MOVE 0x0008
#define SIZE 0x0020
/* Macros to turn mouse pointer on and off */
#define MOUSE_ON graf_mouse(257,&j)
#define MOUSE_OFF graf_mouse(256,&j)

/* Structure for iorec() */
typedef struct {
  char *ibuf;
  int ibufsiz;
  int ibufhd;
  int ibuftl;
  int ibuflow;
  int ibufhi;
  } IORECORD;

/* VDI variables - why aren't these in a header file? */
int contrl[12], intin[128],ptsin[128],intout[128],ptsout[128];
int w_handle, handle, workin[11], workout[57];
int x,y,w,h; /* Current coordinates of window */
int j;
int nx, ny; /* coordinates of next character to be output */
int tx, ty, tw, th; /* Work area of window */
int hsize, vsize; /* Horizontal and vertical size of characters */
int apid, menuid;
OBJECT *mainmenu, *setrs, *setfont, *rsize;
int baud, ucr, flow, cursor, point, buffer_size; /* Various parameters */
char *rb; /* Pointer to our RS232 buffer */
char strsiz[10];
char aboutstr[] = "[1][Window Term 1.0|Full Version|by Matt Kimmel, 1987][OK]";

main()
{
  int j;
  int msg[8];
  FILE *conf;
  int dx,dy,dw,dh; /* Desktop work area */

  apid = appl_init();
  if (!rsrc_load("WTERMF.RSC"))
    for(;;)
      evnt_mesag(msg); /* If we can't open the resource file, we'll
                          just sit here and release the system to
                          the time slicer */
  rsrc_gaddr(0,MENU,&mainmenu);
  rsrc_gaddr(0,RS232,&setrs);
  rsrc_gaddr(0,FONT,&setfont);
  rsrc_gaddr(0,BUFSET,&rsize);
  ((TEDINFO *)rsize[BSIZ].ob_spec)->te_ptext = strsiz;
  if ((conf = fopen("\WTERMF.INF","r")) == NULL) {
    /* If we can't open the config file, set up the defaults */
    baud = 7; /* 1200 baud */
    ucr = 136; /* 8,N,1 */
    flow = 0; /* no flow control */
    cursor = 1; /* cursor on */
    point = ((Getrez() == 2)?(10):(9)); /* normal font for this resolution */
    buffer_size = 8192; /* 8K RS232 buffer */
    /* default window coordinates */
    x=50;
    y=50;
    w=200;
    h=100;
    }
  else {
    /* Get parameters from the config file */
    fscanf(conf,"%d",&baud);
    fscanf(conf,"%d",&ucr);
    fscanf(conf,"%d",&flow);
    fscanf(conf,"%d",&cursor);
    fscanf(conf,"%d",&point);
    fscanf(conf,"%d",&buffer_size);
    fscanf(conf,"%d",&x);
    fscanf(conf,"%d",&y);
    fscanf(conf,"%d",&w);
    fscanf(conf,"%d",&h);
    fclose(conf);
    }
  wind_get(0,WF_WORKXYWH,&dx,&dy,&dw,&dh); /* Get work area of desktop */
  /* Fix window coordinates if necessary to fit inside desktop */
  if ((x < dx) || (x > (dx + dw))) x=dx;
  if ((y < dy) || (y > (dy+dh))) y=dy;
  if ((x + w) > (dx + dw)) w=((dx + dw) - x) - 8;
  if ((y + h) > (dy + dh)) h=((dy + dh) - x);
  /* Align window to be byte-aligned in screen RAM */
  align8(&x,&y,&w,&h);
  init_buttons(); /* Set up buttons in dialog boxes */
  if ((point == 10) && (Getrez() != 2)) point = 9; /* Fix font for color */
  Rsconf(baud,flow,ucr,-1,-1,-1);
  menuid = menu_register(apid,"  Window Terminal");
  handle = graf_handle(&j,&j,&j,&j);
  for(j=0;j++<=9;workin[j]=1);
  workin[10] = 2;
  v_opnvwk(workin,&handle,workout);
  vst_alignment(handle,0,5,&j,&j);
  vst_point(handle,point,&j,&j,&hsize,&vsize);
  vst_color(handle,1);
  vsl_color(handle,1);
  vswr_mode(handle,1);
  /* Allocate new RS232 buffer.  calloc() is used because it zeroes the
     memory it allocates */
  rb = calloc(buffer_size,sizeof(char));
  /* If we can't allocate the memory, hang */
  if (rb == NULL)
    for (;;)
      evnt_mesag(msg);
  set_rsbuf();
  for (;;) {
    evnt_mesag(msg);  /* Wait around to be selected */
    if (msg[0] == AC_OPEN)
      acc();
    }
}

/*
 * This is the main accessory - it handles messages and i/o.
 */
acc()
{
  int msg[8], d, which;
  int i;
  int a, j;
  int desel = 0; /* Is the window deselected? */
  int dx,dy,dw,dh;
  int stopped = 0; /* Has the window been stopped with ALT-S? */
  long l;
  int p[4];

  if (init_window() == 0) return; /*If we can't allocate a window, forget it*/
  align8(&x,&y,&w,&h);
  graf_growbox(24,0,56,16,x,y,w,h);
  wind_open(w_handle,x,y,w,h); /* Open our window */
  wind_get(w_handle,WF_WORKXYWH,&tx,&ty,&tw,&th); /* Get its work area */
  clr(); /* clear it */
  Cauxout(17); /* Send a CTRL-Q, just in case */
  for(;;) {
    /* Release time to the time slicer, but come back every (theoretically)
       0 milliseconds.  Also wait for messages. */
    which = evnt_multi(MU_MESAG|MU_TIMER,0,0,0,0,0,0,0,0,0,0,0,0,0,
                       msg,0,0,&d,&d,&d,&d,&d,&d);
    /* See if our window is still on top */
    wind_get(w_handle,WF_TOP,&a,&j,&j,&j);
    if ((a != w_handle) && (desel == 0)) {   /* Window has been deselected */
      if (stopped != 1) Cauxout(19); /* Send a CTRL-S if the window isn't
                                        stopped */
      desel = 1;
      }
    else
      if ((a == w_handle) && (desel == 1)) { /* Window has been selected */
        if (stopped != 1) Cauxout(17); /* Send a CTRL-Q, if window isn't
                                          stopped */
        desel = 0;
        }
    /* If there are no messages and our window is on top, do some i/o */
    if ((which & MU_TIMER) && (a == w_handle)) {
      /* If there's a character waiting at the keyboard, get it */
      if (Bconstat(2)) {
        l = Bconin(2);
        if (l == 2031616L) /* Is it ALT-S? */
          if (stopped == 0) { /* Yes, toggle stopped window */
            Cauxout(19);
            stopped = 1;
            }
          else {
            Cauxout(17);
            stopped = 0;
            }
        Cauxout((int)l); /* Output the character to RS232.  If it was ALT-S,
                            a 0 will be output */
        }
      /* If there's a character waiting at the RS232 port, and the
         window is not stopped, output it. */
      if (Cauxis() && (stopped == 0)) {
        i = Cauxin();
        MOUSE_OFF; /* turn off mouse */
        if (cursor) { /* erase cursor */
          p[0] = (nx + (hsize / 2));
          p[1] = (ny - 1);
          p[2] = p[0];
          p[3] = ((ny + vsize) + 1);
          vswr_mode(handle,3);
          v_pline(handle,2,p);
          vswr_mode(handle,1);
          }
        outchar(i); /* output the character */
        if (cursor) { /* draw the cursor */
          p[0] = (nx + (hsize / 2));
          p[1] = (ny - 1);
          p[2] = p[0];
          p[3] = ((ny + vsize) + 1);
          vswr_mode(handle,3);
          v_pline(handle,2,p);
          vswr_mode(handle,1);
          }
        MOUSE_ON; /* turn on the mouse */
        }
      }
    if (which & MU_MESAG) {
      switch(msg[0]) {
        case WM_REDRAW : redraw(); /* redraw window and reset character */
                         nx=tx;    /* coordinates                       */
                         ny=ty;
                         break;
        case WM_NEWTOP : /* put appropriate window on top */
        case WM_TOPPED : wind_set(w_handle,WF_TOP,msg[3],0,0,0);
                         clr();
                         break;
        case AC_OPEN   : do_menu(); /* Let the user select a command */
                         break;
        case AC_CLOSE  : return; /* Our window has been closed and deleted */
                         break;  /* for us.                                */
        case WM_CLOSED : wind_close(w_handle); /* close and delete window */
                         graf_shrinkbox(24,0,56,16,x,y,w,h);
                         wind_delete(w_handle);
                         return; /* exit */
                         break;
        case WM_FULLED : full_window();
                         break;
        case WM_MOVED  : wind_get(0,WF_WORKXYWH,&dx,&dy,&dw,&dh);
                         /* Fix window to be inside the desktop */
                         if (((msg[4] + msg[6]) - 1) > ((dx + dw) - 1))
                           msg[4] = ((dx + dw) - 1) - msg[6];
                         if (((msg[5] + msg[7]) - 1) > ((dy + dh) - 1))
                           msg[5] = ((dy + dh) - 1) - msg[7];
                         align8(&msg[4],&msg[5],&msg[6],&msg[7]);
                         nx += (msg[4] - x); /* Cursor will be at the same */
                         ny += (msg[5] - y); /* position relative to the   */
                         x=msg[4];           /* window                     */
                         y=msg[5];
                         w=msg[6];
                         h=msg[7];
                         wind_set(w_handle,WF_CURRXYWH,x,y,w,h);
                         wind_get(w_handle,WF_WORKXYWH,&tx,&ty,&tw,&th);
                         break;
        case WM_SIZED  : x=msg[4]; /* Size window and align it */
                         y=msg[5];
                         w=msg[6];
                         h=msg[7];
                         align8(&x,&y,&w,&h);
                         wind_set(w_handle,WF_CURRXYWH,x,y,w,h);
                         wind_get(w_handle,WF_WORKXYWH,&tx,&ty,&tw,&th);
                         clr();
                         break;
        }
      continue;
      }
    }
}

/*
 * this functions fulfills a redraw request.  It redraws ALL exposed
 * portions of the window rather than just the 'dirty' rectangles.
 */
redraw()
{
  int lx,ly,lw,lh;
  int pxy[4];
  int active;
  int j;

  /* if our window is on top, just use the clr() function.  It's faster. */
  wind_get(w_handle,WF_TOP,&active,&j,&j,&j);
  if (active == w_handle) {
    clr();
    return;
    }
  vsf_interior(handle,0);
  MOUSE_OFF; /* turn off mouse */
  wind_update(BEG_UPDATE); /* Begin update - don't let GEM change anything */
  /* Get rectangles one by one and fill them in.  Fill ALL exposed portions
     of the window. */
  wind_get(w_handle,WF_FIRSTXYWH,&lx,&ly,&lw,&lh);
  while (lw && lh) {
    pxy[0] = lx;
    pxy[1] = ly;
    pxy[2] = (lx + lw) - 1;
    pxy[3] = (ly + lh) - 1;
    vr_recfl(handle,pxy);
    wind_get(w_handle,WF_NEXTXYWH,&lx,&ly,&lw,&lh);
    }
  wind_update(END_UPDATE); /* End our update; let GEM change things again */
  MOUSE_ON; /* turn on mouse */
}

/*
 * clear the window if it's on top.
 */
clr()
{
  int active;
  int j;
  int p[4];

  /* Don't do anything if our window is not on top. */
  wind_get(w_handle,WF_TOP,&active,&j,&j,&j);
  if (active == w_handle) {
    wind_get(w_handle,WF_WORKXYWH,&p[0],&p[1],&p[2],&p[3]); /* get work area */
    p[2] += (p[0] - 1); /* Fix w and h to be x2 and y2 */
    p[3] += (p[1] - 1);
    vsf_interior(handle,0);
    MOUSE_OFF;    
    vr_recfl(handle,p); /* Wipe window */
    nx=tx; /* Reset character coordinates */
    ny=ty;
    /* Draw the cursor if necessary */
    if (cursor) {
      p[0] = (nx + (hsize / 2));
      p[1] = (ny - 1);
      p[2] = p[0];
      p[3] = ((ny + vsize) + 1);
      vswr_mode(handle,1);
      v_pline(handle,2,p);
      }
    MOUSE_ON;
    }
}

/*
 * Make sure that the window's work area is byte-aligned.  this speeds
 * up scrolling with vro_cpyfm().
 */
align8(fx,fy,fw,fh)
int *fx,*fy,*fw,*fh;
{
  int ix,iy,iw,ih;
  
  /* This returns coordinates for the entire window, not just the work
     area, so we need to convert coordinates back and forth with
     wind_calc(). */
  wind_calc(1,NAME|CLOSE|FULL|MOVE|SIZE,*fx,*fy,*fw,*fh,&ix,&iy,&iw,&ih);
  while ((ix % 8) != 0)
    ix++;
  while ((iw % 8) != 0)
    iw++;
  wind_calc(0,NAME|CLOSE|FULL|MOVE|SIZE,ix,iy,iw,ih,fx,fy,fw,fh);
}

/*
 * fulfill a full_window() request.
 */
full_window()
{
  int jx,jy,jw,jh,fx,fy,fw,fh;
  
  /* get 'full size'.  This is already byte-aligned. */
  wind_get(w_handle,WF_FULLXYWH,&fx,&fy,&fw,&fh);
  /* if the window is already full, unfull it. */
  if ((x == fx) && (y == fy) && (w == fw) && (h == fh)) {
    wind_get(w_handle,WF_PREVXYWH,&jx,&jy,&jw,&jh);
    graf_shrinkbox(jx,jy,jw,jh,x,y,w,h);
    x=jx;
    y=jy;
    w=jw;
    h=jh;
    wind_set(w_handle,WF_CURRXYWH,x,y,w,h);
    wind_get(w_handle,WF_WORKXYWH,&tx,&ty,&tw,&th);
    nx=tx;
    ny=ty;
    }
  else { /* full the window */
    wind_get(w_handle,WF_FULLXYWH,&jx,&jy,&jw,&jh);
    graf_growbox(x,y,w,h,jx,jy,jw,jh);
    x=jx;
    y=jy;
    w=jw;
    h=jh;
    wind_set(w_handle,WF_CURRXYWH,x,y,w,h);
    wind_get(w_handle,WF_WORKXYWH,&tx,&ty,&tw,&th);
    nx=tx;
    ny=ty;
    }
  clr();
}

/*
 * initialize and allocate the window
 */
init_window()
{
  int bx,by,bw,bh;
  
  wind_get(0,WF_WORKXYWH,&bx,&by,&bw,&bh); /* set up FULLXYWH value */
  align8(&bx,&by,&bw,&bh);
  bw -= 8;
  w_handle = wind_create(NAME|CLOSE|FULL|MOVE|SIZE,bx,by,bw,bh);
  if (w_handle < 0) { /* If we can't allocate a window, apologize */
    form_alert(1,"[3][There are no more|windows available!][Sorry!]");
    return (0);
    }
  wind_set(w_handle,WF_NAME," Window Term 1.0-F ",0,0);
  return(1);
}

/*
 * Install our new RS232 buffer
 */
set_rsbuf()
{
  IORECORD *b;

  Cauxout(19); /* We don't want incoming characters during this */
  b = (IORECORD *)Iorec(0); /* make our structure point to the RS232 struct */
  b->ibuf = rb; /* fill it in! */
  b->ibufsiz = buffer_size;
  b->ibuflow = buffer_size/4;
  b->ibufhi = buffer_size/4*3;
  b->ibufhd = 0;
  b->ibuftl = 0;
  Cauxout(17); /* Send a CTRL-Q */
}

/*
 * Set up the buttons on the dialog boxes
 */
init_buttons()
{
  int j;
  char foo[10];

  /* Clear all the buttons */
  for (j=0;j<=32;j++)
    if (((setrs[j].ob_type) == G_BUTTON)||((setrs[j].ob_type) == G_BOXCHAR)) {
      setrs[j].ob_state &= (~SELECTED);
      setrs[j].ob_state |= NORMAL;
      }
  for (j=0;j<=7;j++)
    if ((setfont[j].ob_type) == G_BUTTON) {
      setfont[j].ob_state &= (~SELECTED);
      setfont[j].ob_state |= NORMAL;
      }
  /* Set appropriate buttons */
  if (baud == 0) objc_change(setrs,B19200,0,0,0,0,0,SELECTED,0);
  if (baud == 1) objc_change(setrs,B9600,0,0,0,0,0,SELECTED,0);
  if (baud == 2) objc_change(setrs,B4800,0,0,0,0,0,SELECTED,0);
  if (baud == 4) objc_change(setrs,B2400,0,0,0,0,0,SELECTED,0);
  if (baud == 7) objc_change(setrs,B1200,0,0,0,0,0,SELECTED,0);
  if (baud == 9) objc_change(setrs,B300,0,0,0,0,0,SELECTED,0);
  if (flow == 0) objc_change(setrs,FLOWNONE,0,0,0,0,0,SELECTED,0);
  if (flow == 1) objc_change(setrs,FLOWXON,0,0,0,0,0,SELECTED,0);
  if (flow == 2) objc_change(setrs,FLOWRTS,0,0,0,0,0,SELECTED,0);
  if (flow == 3) objc_change(setrs,FLOWBOTH,0,0,0,0,0,SELECTED,0);
  if ((ucr & 4) && (ucr & 2))
    objc_change(setrs,EVEN,0,0,0,0,0,SELECTED,0);
  if ((ucr & 4) && (!(ucr & 2)))
    objc_change(setrs,ODD,0,0,0,0,0,SELECTED,0);
  if (!(ucr & 4))
    objc_change(setrs,NONE,0,0,0,0,0,SELECTED,0);
  if ((!(ucr & 16)) && (ucr & 8))
    objc_change(setrs,STOP1,0,0,0,0,0,SELECTED,0);
  if ((ucr & 16) && (ucr & 8))
    objc_change(setrs,STOP2,0,0,0,0,0,SELECTED,0);
  if ((!(ucr & 64)) && (!(ucr & 32)))
    objc_change(setrs,BIT8,0,0,0,0,0,SELECTED,0);
  if ((!(ucr & 64)) && (ucr & 32))
    objc_change(setrs,BIT7,0,0,0,0,0,SELECTED,0);
  if ((ucr & 64) && (!(ucr & 32)))
    objc_change(setrs,BIT6,0,0,0,0,0,SELECTED,0);
  if ((ucr & 64) && (ucr & 32))
    objc_change(setrs,BIT5,0,0,0,0,0,SELECTED,0);
  if ((point == 10) && (Getrez() != 2))
    objc_change(setfont,COLOR,0,0,0,0,0,SELECTED,0);
  else
    if (point == 10)
      objc_change(setfont,MONO,0,0,0,0,0,SELECTED,0);
  if (point == 9)
    objc_change(setfont,COLOR,0,0,0,0,0,SELECTED,0);
  if (point == 8)
    objc_change(setfont,ICON,0,0,0,0,0,SELECTED,0);
  if (Getrez() != 2)
    objc_change(setfont,MONO,0,0,0,0,0,DISABLED,0);
  sprintf(strsiz,"%d",buffer_size);
}

/*
 * Do main dialog; allow user to select a command
 */
do_menu()
{
  int which;
  int dx,dy,dw,dh;

  evnt_timer(0,0);         /* Lots of stuff to make sure dialogs aren't */
  wind_update(BEG_UPDATE); /* redrawn over by other applications */
  form_center(mainmenu,&dx,&dy,&dw,&dh);
  form_dial(FMD_START,dx,dy,dw,dh,dx,dy,dw,dh);
  objc_draw(mainmenu,0,10,dx,dy,dw,dh);
  which = form_do(mainmenu,0);
  objc_change(mainmenu,which,0,0,0,0,0,NORMAL,0);
  wind_update(END_UPDATE);
  form_dial(FMD_FINISH,dx,dy,dw,dh,dx,dy,dw,dh);
  switch(which) {
    case SETRS232 : set_rs232();
                    break;
    case BUFSIZE  : size_buffer();
                    break;
    case SETSIZE  : set_charsize();
                    break;
    case CURSON   : cursor = ((cursor == 1)?(0):(1));
                    clr();
                    break;
    case SAVESET  : save_settings();
                    break;
    case ABOUT    : form_alert(1,aboutstr);
                    break;
    }
}

/*
 * Let user set RS232 parameters
 */
set_rs232()
{
  int which;
  int dx,dy,dw,dh;

  /* Do the dialog ... */
  evnt_timer(0,0);
  wind_update(BEG_UPDATE);
  form_center(setrs,&dx,&dy,&dw,&dh);
  form_dial(FMD_START,dx,dy,dw,dh,dx,dy,dw,dh);
  objc_draw(setrs,0,10,dx,dy,dw,dh);
  which = form_do(setrs,0);
  objc_change(setrs,which,0,0,0,0,0,NORMAL,0);
  wind_update(END_UPDATE);
  form_dial(FMD_FINISH,dx,dy,dw,dh,dx,dy,dw,dh);
  if (which == RCANCEL) {
    init_buttons();
    return;
    }
  /* ... and set the parameters accordingly */
  if (sel(setrs,B19200)) baud = 0;
  if (sel(setrs,B9600)) baud = 1;
  if (sel(setrs,B4800)) baud = 2;
  if (sel(setrs,B2400)) baud = 4;
  if (sel(setrs,B1200)) baud = 7;
  if (sel(setrs,B300)) baud = 9;
  if (sel(setrs,FLOWNONE)) flow = 0;
  if (sel(setrs,FLOWXON)) flow = 1;
  if (sel(setrs,FLOWRTS)) flow = 2;
  if (sel(setrs,FLOWBOTH)) flow = 3;
  ucr = 0;
  if (sel(setrs,EVEN)) ucr |= 6;
  if (sel(setrs,ODD)) ucr |= 4;
  if (sel(setrs,STOP1)) ucr |= 8;
  if (sel(setrs,STOP2)) ucr |= 24;
  if (sel(setrs,BIT7)) ucr |= 32;
  if (sel(setrs,BIT6)) ucr |= 64;
  if (sel(setrs,BIT5)) ucr |= 96;
  ucr |= 128;
  Rsconf(baud,flow,ucr,-1,-1,-1);
}

/*
 * Let the user size the RS232 buffer
 */
size_buffer()
{
  int dx,dy,dw,dh,which;
  int oldbuf;

  /* Do the dialog */
  evnt_timer(0,0);
  wind_update(BEG_UPDATE);
  form_center(rsize,&dx,&dy,&dw,&dh);
  form_dial(FMD_START,dx,dy,dw,dh,dx,dy,dw,dh);
  objc_draw(rsize,0,10,dx,dy,dw,dh);
  which = form_do(rsize,BSIZ);
  objc_change(rsize,which,0,0,0,0,0,NORMAL,0);
  wind_update(END_UPDATE);
  form_dial(FMD_FINISH,dx,dy,dw,dh,dx,dy,dw,dh);
  if (which == BCANCEL) {
    init_buttons();
    return;
    }
  /* set size */
  oldbuf = buffer_size; /* save old buffer size */
  buffer_size = atoi(strsiz); /* get new one */
  free(rb); /* free the old memory */
  rb = calloc(buffer_size,sizeof(char)); /* allocate the new */
  if (rb == NULL) { /* if bad, generally bomb out. */
    form_alert(1,"[3][Not enough memory|for a buffer of|that size.][Cancel]");
    buffer_size = oldbuf;
    rb = calloc(buffer_size,sizeof(char)); /* reallocate the old buffer. We
                                              don't have any error-checking
                                              here because if this fails,
                                              we're in big trouble anyway */
    init_buttons();
    return;
    }
  set_rsbuf();
}

/*
 * Let user set the font (Mono, color, icon)
 */
set_charsize()
{
  int dx,dy,dw,dh,which,j;

  evnt_timer(0,0);
  wind_update(BEG_UPDATE);
  form_center(setfont,&dx,&dy,&dw,&dh);
  form_dial(FMD_START,dx,dy,dw,dh,dx,dy,dw,dh);
  objc_draw(setfont,0,10,dx,dy,dw,dh);
  which = form_do(setfont,0);
  objc_change(setfont,which,0,0,0,0,0,NORMAL,0);
  wind_update(END_UPDATE);
  form_dial(FMD_FINISH,dx,dy,dw,dh,dx,dy,dw,dh);
  if (which == FCANCEL) {
    init_buttons();
    return;
    }
  if (sel(setfont,MONO)) point = 10;
  if (sel(setfont,COLOR)) point = 9;
  if (sel(setfont,ICON)) point = 8;
  vst_point(handle,point,&j,&j,&hsize,&vsize);
  clr();
}

/*
 * save the configuration
 */
save_settings()
{
  int j;
  FILE *fd;

  if ((fd = fopen("\WTERMF.INF","w")) == NULL) {
    form_alert(1,"[3][Couldn't open|\WTERMF.INF\for writing.][Cancel]");
    return;
    }
  graf_mouse(2,&j); /* "busy as a bee " */
  fprintf(fd,"%d\n",baud);
  fprintf(fd,"%d\n",ucr);
  fprintf(fd,"%d\n",flow);
  fprintf(fd,"%d\n",cursor);
  fprintf(fd,"%d\n",point);
  fprintf(fd,"%d\n",buffer_size);
  fprintf(fd,"%d\n%d\n%d\n%d\n",x,y,w,h);
  fclose(fd);
  graf_mouse(0,&j);
}

/*
 * Return non-zero if obj in tree is selected
 */
sel(tree,obj)
OBJECT *tree;
int obj;
{
  if ((tree[obj].ob_state) & SELECTED)
    return (1);
  else
    return (0);
}

/*
 * output a character to the window, and scroll if necessary.
 * Why doesn't the ST have built-in scrolling and such for its
 * windows?
 */
outchar(ch)
int ch;
{
  char str[2];
  int j;

  if (ch == 10) {    /* Linefeed */
    if ((ny + vsize) > ((ty + th) - vsize)) { /* scroll if necessary */
      scroll();
      return;
      }
    ny += vsize;
    return;
    }
  if (ch == 13) {    /* Carriage Return */
    nx = tx;
    return;
    }
  if (ch == 7)  {    /* Bell */
    Bconout(2,7); /* ding! */
    return;
    }
  if ((ch == 8) && (cursor)) { /* cursor is non-destructive if the cursor */
    if (nx > tx)               /* is on.                                  */
      nx -= hsize;
    return;
    }
  if (ch == 9) {     /* Tab */
    outchar(32);  /* faster than a for loop */
    outchar(32);
    outchar(32);
    outchar(32);
    outchar(32);
    /* Tabs are 5 characters right now.  Perhaps in a later version I'll
       let the user set the tab size. */
    return;
    }
  if (ch == 12) {    /* Form Feed (clear screen) */
    clr();
    nx=tx;
    ny=ty;
    return;
    }
  if ((ch == 127) || ((ch == 8) && (!cursor))) {   /* DEL and Backspace */
    if (nx > tx) {
      nx -= hsize;
      v_gtext(handle,nx,ny," ");
      }
    return;
    }
  str[0] = (char)ch;
  str[1] = '\0';
  v_gtext(handle,nx,ny,str); /* output the character */
  nx += hsize;
  if (nx > ((tx + tw) - hsize)) { /* wrap if necessary */
    nx = tx;
    if ((ny + vsize) > ((ty + th) - vsize)) scroll(); /* scroll if necessary */
    else ny += vsize;
    }
}

/*
 * This routine scrolls the window up one line.  This should be built into
 * the ST - it took me quite a while to get this thing working.
 * Basically what it does is copy all the lines but the top one up one
 * line (as one block).  Then it wipes the bottom line clean.
 */
scroll()
{
  int pxy[4];
  
  blit(tx,(ty + vsize),((tx + tw) - 1),(((ty + vsize) + th) - (vsize + 1)),
       tx,ty,((tx + tw) - 1),((ty + th) - (vsize + 1)));
  pxy[0] = tx;
  pxy[1] = ny;
  pxy[2] = (tx + tw) - 1;
  pxy[3] = ny + vsize;
  vsf_interior(handle,0);
  vr_recfl(handle,pxy);
}

/*
 * copy the block defined by x1, y1, x2, y2 to x3, y3, x4, y4
 */
blit(x1,y1,x2,y2,x3,y3,x4,y4)
int x1,y1,x2,y2,x3,y3,x4,y4;
{
  FDB b;
  int bp[8];
  
  bp[0] = x1;
  bp[1] = y1;
  bp[2] = x2;
  bp[3] = y2;
  bp[4] = x3;
  bp[5] = y3;
  bp[6] = x4;
  bp[7] = y4;
  vro_cpyfm(handle,3,bp,&b,&b); /* zap! */
}
