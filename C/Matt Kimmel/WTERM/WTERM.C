/*
 * WTERM - A terminal program within a window
 *         "Stripped" Version
 *         by Matt Kimmel, 1987
 *
 * This is this stripped version of Window Term, a terminal program
 * inside a window.  The stripped version is considerably smaller
 * and slightly faster than the Full version.  However, it doesn't have
 * any of the extra functions that the Full version has.  In the Stripped
 * version, you must use a seperate program to set the RS232 parameters.
 *
 * This code should be fairly portable.  I have used calloc() instead
 * of Malloc() because it initializes the reserved space to zeroes.
 * This is a standard K&R function, so it should be implemented in
 * all the ST compilers.
 *
 * The font size may be toggled between the normal font and "Icon"
 * size with ALT-F.  If you press ALT-S, a CTRL-S is sent, and the
 * program won't accept any characters until you press ALT-S again,
 * at which time a CTRL-Q is sent and output is resumed.
 */

#include <stdio.h>
#include <gemdefs.h>
#include <osbind.h>

/* defines for window gadgets */
#define NAME 0x0001
#define CLOSE 0x0002
#define FULL 0x0004
#define MOVE 0x0008
#define SIZE 0x0020

/* Macros to turn the mouse on and off */
#define MOUSE_ON graf_mouse(257,&j)
#define MOUSE_OFF graf_mouse(256,&j);

/* The size to set the RS232 buffer to */
#define BUFFER_SIZE 8192

/* Structure returned by Iorec() */
typedef struct {
  char *ibuf;
  int ibufsiz;
  int ibufhd;
  int ibuftl;
  int ibuflow;
  int ibufhi;
  } IORECORD;

/* Standard VDI variables */
int contrl[12], intin[128],ptsin[128],intout[128],ptsout[128];
int w_handle, handle, workin[11], workout[57];
int x,y,w,h;  /* Position of window */
int j;  /* General-purpose junk variable */
int nx, ny; /* X,Y coordinates of next character to be output */
int tx, ty, tw, th; /* Size of the work area of the window */
int hsize, vsize; /* Horizontal and vertical size of characters */
int apid, menuid; /* Application and Menu IDs */
char rs232buf[BUFFER_SIZE]; /* RS232 Buffer */

main()
{
  int j; /* Junk variable */
  int msg[8]; /* Message buffer for evnt_mesag */

  apid = appl_init();  /* Initialize our application */
  menuid = menu_register(apid,"  Window Term"); /* Register in Desk menu */
  handle = graf_handle(&j,&j,&j,&j); /* Get handle of the screen */
  for(j=0;j++<=9;workin[j]=1);  /* Set up workin array */
  workin[10] = 2;
  v_opnvwk(workin,&handle,workout); /* Open virtual workstation */
  vst_alignment(handle,0,5,&j,&j); /* Set text alignment so that
                                      so that the y coordinate is
                                      the top line of a character
                                      with v_gtext */
  hsize = 8;  /* Set horizontal and vertical sizes of characters */
  vsize = ((Getrez() == 2)?(16):(8));
  x=50;    /* The window starts with these coordinates */
  y=50;
  w=200;
  h=100;
  set_rsbuf();  /* Set up new RS232 buffer */
  for (;;) {   /* For loop to infinity.... */
    evnt_mesag(msg);  /* Wait for a message */
    if (msg[0] == AC_OPEN)  /* Did someone open our accessory? */
      acc();  /* Yes, go to the main part of the accessory */
    }
}

/*
 * This is the main loop in the program.  It handles the window and
 * input and output of characters.
 */
acc()
{
  int msg[8], d, which; /* message buffer, junk variable, 'which' for
                           evnt_multi */
  int i; /* Character accepted */
  int a, j;
  int desel = 0; /* Pseudo-Boolean variable determines whether our window
                    is the active window */
  int dx,dy,dw,dh; /* Temporary variables */
  int stopped = 0; /* Pseudo-Boolean; determines whether output has been
                      stopped with ALT-S */
  long l;

  if (init_window() == 0) return; /* If we can't create a window, forget it! */
  align8(&x,&y,&w,&h); /* Make sure the text is on 8-bit boundaries */
  graf_growbox(24,0,56,16,x,y,w,h); /* Growing box */
  wind_open(w_handle,x,y,w,h); /* Open window */
  wind_get(w_handle,WF_WORKXYWH,&tx,&ty,&tw,&th); /* Get work area */
  nx=tx; /* Set next character's coordinates */
  ny=ty;
  clr(); /* Clear window */
  Cauxout(17); /* Send a CTRL-Q, in case the user deselected the window
                  (sending a CTRL-S) and then ran a program or some such
                  which closed the window */
  for(;;) {
    which = evnt_multi(MU_MESAG|MU_TIMER,0,0,0,0,0,0,0,0,0,0,0,0,0,
                       msg,0,0,&d,&d,&d,&d,&d,&d);
    wind_get(w_handle,WF_TOP,&a,&j,&j,&j); /* Make sure our window is
                                              still on top */
    if ((a != w_handle) && (desel == 0)) {   /* Window has just
                                                been deselected */
      if (stopped != 1) Cauxout(19); /* Send a CTRL-S */
      desel = 1;
      }
    else
      if ((a == w_handle) && (desel == 1)) { /* Window has just been selected */
        if (stopped != 1) Cauxout(17); /* Send a CTRL-Q */
        desel = 0;
        }
    if ((which & MU_TIMER) && (a == w_handle)) { /* If there are no messages
                                                    and our window is on top */
      if (Bconstat(2)) { /* Is there a character waiting at the keyboard? */
        l = Bconin(2); /* Yes, get it */
        if (l == 2031616L) /* Is it an ALT-S? */
          if (stopped == 0) { /* Yes, is output stopped? */
            Cauxout(19); /* No, stop output and send a CTRL-S */
            stopped = 1;
            }
          else { /* Yes, start output and send a CTRL-Q */
            Cauxout(17);
            stopped = 0;
            }
        if (l == 2162688L) { /* Is the character an ALT-F? */
          toggle_font(); /* Yes, toggle the font size and clear the window */
          clr();
          nx=tx;
          ny=ty;
          }
        Cauxout((int)l); /* Output the character.  If it's ALT-F, a 0 will
                            be output. */
        }
      if (Cauxis() && (stopped == 0)) { /* Is there a character waiting
                                           at the modem port, and is output
                                           enabled? */
        i = Cauxin(); /* Yes.  Get it and output it on the window. */
        MOUSE_OFF;
        outchar(i);
        MOUSE_ON;
        }
      }
    if (which & MU_MESAG) { /* Is there a message for us? */
      switch(msg[0]) { /* Yes, evaluate it */
        case WM_REDRAW : redraw(); /* Redraw the window */
                         nx=tx;
                         ny=ty;
                         break;
        case WM_NEWTOP : /* Top the window that should be on top */
        case WM_TOPPED : wind_set(w_handle,WF_TOP,w_handle,0,0,0);
                         clr();
                         break;
        case AC_OPEN   : form_alert(1,"[1][Window Terminal| |by Matt Kimmel|1987][Okay]");
                         break;  /* Give some credits if someone clicks on our
                                    menu item */
        case AC_CLOSE  : return; /* GEM has closed and deleted our window. */
                         break;
        case WM_CLOSED : wind_close(w_handle);
                         graf_shrinkbox(24,0,56,16,x,y,w,h);
                         wind_delete(w_handle);
                         return; /* The user closed the window.  Close it */
                         break;  /* and delete it */
        case WM_FULLED : full_window(); /* Full the window */
                         break;
        case WM_MOVED  : /* Move the window but make sure the next character
                            output appears after the last, and that the
                            window doesn't go off the screen */
                         wind_get(0,WF_WORKXYWH,&dx,&dy,&dw,&dh);
                         if (((msg[4] + msg[6]) - 1) > ((dx + dw) - 1))
                           msg[4] = ((dx + dw) - 1) - msg[6];
                         if (((msg[5] + msg[7]) - 1) > ((dy + dh) - 1))
                           msg[5] = ((dy + dh) - 1) - msg[7];
                         align8(&msg[4],&msg[5],&msg[6],&msg[7]);
                         nx += (msg[4] - x);
                         ny += (msg[5] - y);
                         x=msg[4];
                         y=msg[5];
                         w=msg[6];
                         h=msg[7];
                         wind_set(w_handle,WF_CURRXYWH,x,y,w,h);
                         wind_get(w_handle,WF_WORKXYWH,&tx,&ty,&tw,&th);
                         break;
        case WM_SIZED  : x=msg[4];  /* Size the window */
                         y=msg[5];
                         w=msg[6];
                         h=msg[7];
                         align8(&x,&y,&w,&h);
                         wind_set(w_handle,WF_CURRXYWH,x,y,w,h);
                         wind_get(w_handle,WF_WORKXYWH,&tx,&ty,&tw,&th);
                         nx=tx;
                         ny=ty;
                         clr();
                         break;
        }
      continue;
      }
    }
}

/*
 * Redraw the window.  We are actually just going to wipe all exposed portions
 * of thw window clean.
 */
redraw()
{
  int lx,ly,lw,lh;
  int pxy[4];
  
  vsf_interior(handle,0); /* Set the fill type to the background color */
  MOUSE_OFF;
  wind_update(BEG_UPDATE); /* Don't let the rectangle lists be changed */
  wind_get(w_handle,WF_FIRSTXYWH,&lx,&ly,&lw,&lh); /* Get first rectangle */
  while (lw && lh) {
    pxy[0] = lx;
    pxy[1] = ly;
    pxy[2] = (lx + lw) - 1;
    pxy[3] = (ly + lh) - 1;
    vr_recfl(handle,pxy); /* Wipe this rectangle */
    wind_get(w_handle,WF_NEXTXYWH,&lx,&ly,&lw,&lh); /* Get next rectangle */
    }
  wind_update(END_UPDATE); /* End update */
  MOUSE_ON;
}

/*
 * Wipe the entire window clean.  Only works if the window is on top.
 */
clr()
{
  int active;
  int j;
  int p[4];

  wind_get(w_handle,WF_TOP,&active,&j,&j,&j); /* Is our window on top? */
  if (active == w_handle) { /* Yes, go ahead */
    wind_get(w_handle,WF_WORKXYWH,&p[0],&p[1],&p[2],&p[3]); /* Get size */
    p[2] += (p[0] - 1);
    p[3] += (p[1] - 1);
    vsf_interior(handle,0); /* Set fill type to background color */
    MOUSE_OFF;    
    vr_recfl(handle,p); /* Wipe the window */
    MOUSE_ON;
    }
}

/*
 * This function takes the _outside_ coordinates and size of a window,
 * and changes them so that the inside x and width are divisible by 8.
 * This means that the inside is on an 8-bit boundary, and will speed up
 * scrolling when we use vro_cpyfm().
 */
align8(fx,fy,fw,fh)
int *fx,*fy,*fw,*fh;
{
  int ix,iy,iw,ih;
  
  /* Get inside size of window */
  wind_calc(1,NAME|CLOSE|FULL|MOVE|SIZE,*fx,*fy,*fw,*fh,&ix,&iy,&iw,&ih);
  /* Align it */
  while ((ix % 8) != 0)
    ix++;
  while ((iw % 8) != 0)
    iw++;
  /* Change the aligned inside to an outside size */
  wind_calc(0,NAME|CLOSE|FULL|MOVE|SIZE,ix,iy,iw,ih,fx,fy,fw,fh);
}

/*
 * Make the window cover the whole desktop.  Once it's aligned, it will
 * actually leave a little bit of the desktop showing.
 */
full_window()
{
  int jx,jy,jw,jh,fx,fy,fw,fh;
  
  wind_get(w_handle,WF_FULLXYWH,&fx,&fy,&fw,&fh); /* Get the full size */
  if ((x == fx) && (y == fy) && (w == fw) && (h == fh)) {
    /* If it's already fulled, make it smaller.  The smaller one will
       always be aligned already with align8(). */
    wind_get(w_handle,WF_PREVXYWH,&jx,&jy,&jw,&jh); /* Get Previous XYWH */
    graf_shrinkbox(jx,jy,jw,jh,x,y,w,h); /* Shrinking Box */
    x=jx;
    y=jy;
    w=jw;
    h=jh;
    wind_set(w_handle,WF_CURRXYWH,x,y,w,h); /* Set new size and get WORKXYWH */
    wind_get(w_handle,WF_WORKXYWH,&tx,&ty,&tw,&th);
    nx=tx;
    ny=ty;
    }
  else { /* Otherwise, full it similarly */
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
  clr(); /* Clear window */
}

/*
 * Create the window.
 */
init_window()
{
  int bx,by,bw,bh;
  
  wind_get(0,WF_WORKXYWH,&bx,&by,&bw,&bh); /* Get size of desktop for 'FULL'
                                              size. */
  align8(&bx,&by,&bw,&bh); /* Align it */
  bw -= 8; /* Make it fit on the desktop a little better */
  w_handle = wind_create(NAME|CLOSE|FULL|MOVE|SIZE,bx,by,bw,bh); /* Create it */
  if (w_handle < 0) { /* Tell the user if there's an error */
    form_alert(1,"[3][There are no more|windows available!][Sorry!]");
    return (0);
    }
  wind_set(w_handle,WF_NAME," Window Term 1.0-S ",0,0); /* Set window name */
  return(1);
}

/*
 * Set the RS232 buffer's information to descrobe our buffer
 */
set_rsbuf()
{
  IORECORD *b;

  Cauxout(19);
  b = (IORECORD *)Iorec(0); /* Get pointer to the RS232 buffer descriptor */
  /* Change the descriptor */
  b->ibuf = rs232buf;
  b->ibufsiz = BUFFER_SIZE;
  b->ibuflow = BUFFER_SIZE/4;
  b->ibufhi = BUFFER_SIZE/4*3;
  b->ibufhd = 0;
  b->ibuftl = 0;
  Cauxout(17);
}

/*
 * Toggle between the normal and small font
 */
toggle_font()
{
  static int font = 0;
  int j;

  if (font == 0) {  /* Change to Icon font */
    vst_point(handle,8,&j,&j,&hsize,&vsize);
    font = 1;
    }
  else {  /* Change to normal font */
    vst_point(handle,((Getrez() == 2)?(10):(9)),&j,&j,&hsize,&vsize);
    font = 0;
    }
}

/*
 * Output a character at the next character position in the window
 * using v_gtext
 */
outchar(ch)
int ch;
{
  char str[2];
  int j;

  if (ch == 10) {    /* Linefeed */
    /* Put the 'cursor' down one line and scroll if necessary */
    if ((ny + vsize) > ((ty + th) - vsize)) {
      scroll();
      return;
      }
    ny += vsize;
    return;
    }
  if (ch == 13) {    /* Carriage Return */
    /* Put the 'cursor' at the beginning of the line */
    nx = tx;
    return;
    }
  if (ch == 7)  {    /* Bell */
    Bconout(2,7);
    return;
    }
  if (ch == 9) {     /* Tab */
    outchar(32);  /* faster than a for loop */
    outchar(32);
    outchar(32);
    outchar(32);
    outchar(32);
    return;
    }
  if (ch == 12) {    /* Form Feed (clear screen) */
    clr();
    nx=tx;
    ny=ty;
    return;
    }
  if ((ch == 127) || (ch == 8)) {   /* DEL and Backspace */
    /* Put 'cursor' back one space and print a space there */
    if (nx > tx) {
      nx -= hsize;
      v_gtext(handle,nx,ny," ");
      }
    return;
    }
  str[0] = (char)ch; /* Construct a string */
  str[1] = '\0';
  v_gtext(handle,nx,ny,str); /* Output the character */
  nx += hsize; /* Move the cursor to the next space */
  /* If necessary, move the cursor to the next line, and scroll if needed */
  if (nx > ((tx + tw) - hsize)) {
    nx = tx;
    if ((ny + vsize) > ((ty + th) - vsize)) scroll();
    else ny += vsize;
    }
}

/*
 * Scroll the contents of the screen up one line using the blit() function
 */
scroll()
{
  int pxy[4];
  
  blit(tx,(ty + vsize),((tx + tw) - 1),(((ty + vsize) + th) - (vsize + 1)),
       tx,ty,((tx + tw) - 1),((ty + th) - (vsize + 1))); /* Call blit() */
  /* clear the bottom line */
  pxy[0] = tx;
  pxy[1] = ny;
  pxy[2] = (tx + tw) - 1;
  pxy[3] = ny + vsize;
  vsf_interior(handle,0);
  vr_recfl(handle,pxy);
}

/*
 * Copy the rectangle described by x1,y1,x2,y2 to the rectangle described
 * by x3,y3,x4,y4 using vro_cpyfm()
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
  vro_cpyfm(handle,3,bp,&b,&b);
}
