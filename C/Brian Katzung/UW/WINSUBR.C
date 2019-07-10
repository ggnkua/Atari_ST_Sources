/* subroutines for multi-window terminal emulation
 */

#include <obdefs.h>
#include <gemdefs.h>
#include <osbind.h>
#include <stdio.h>
#include "wind.h"
#include "windefs.h"

extern int handle;

/* variables used by various routines
 */

long dummy;				/* dummy return variable */
extern	int	outwind, outport;	/* window selection */
extern	int	scr_x, scr_y;		/* size of the screen */
extern	int	scr_w, scr_h;
extern	int	fast;			/* flag for fast open/close */
extern	int	overstrike;
extern	int	sliders;		/* flag for sliders on new windows */
extern	int	titles;			/* flag for title bars on new windows */
int	tmp;				/* temporary for anything... */
extern	char	alert[300];		/* used for alerts */
extern	FNT	*curfont;		/* current font */
extern	MFDB	screen_mf;		/* screen descriptor */
extern	int	mouse;			/* for mouse on/off */
extern	int	audibell;		/* What happens on BEL? */
extern	int	visibell;
extern	int	toponbel;

struct	wi_str	w[MAX_WIND];

/* the program code...
 */

char *getmem(size)
register long size;
{
  char *got;

  got = (char *) Malloc(size);
#ifdef DEBUG
  printf("alloc returned %lx of %ld size\n", got, size);
#endif
  if (got == NULL)
  {
    sprintf(alert, "[1][Could not get %ld bytes][Ok]", size);
    form_alert(1, alert);
  } else
  {
    bzero(got, size);
  }
  return got;
}

bzero(ptr, size)
register char *ptr;
register long size;
{
  while (size--)
    *ptr++ = 0;
}

/* find_port maps from window handles to UW port identifiers
 */

find_port(wnd)
{
  return w[wnd].port;
}

/* find_wind maps from port ids to window handles
 */

find_wind(port)
{
int i;

  for (i=1; i<MAX_WIND; i++)
    if (w[i].port == port) return i;
  return 0;
}

/* w_open opens a window with the supplied name and port and returns a port
 * number.  If port was zero, a free port is chosen.
 */

w_open(port, name, xsiz, ysiz)
char *name;
{
  register struct wi_str *wp;
  int wdes;
  int i, cnt, wtyp;
  int tmp_x, tmp_y, tmp_w, tmp_h;

  if (port && find_wind(port)) return port;  /* this window is already open */
  if (!port)
  {
    for (i=1; i<MAX_WIND; i++)
    {
      if (!find_wind(i))
      {
        port = i;		/* a free port */
        break;
      }
    }
  }

  wtyp = (sliders ? WI_WITHSLD : 0) | (titles ? WI_NOSLD : 0);
  wind_calc(0, wtyp, 0, 0, curfont->inc_x*xsiz+2*X0,
    curfont->inc_y*ysiz+2*Y0, &dummy, &dummy, &tmp_w, &tmp_h);
  if (tmp_w>scr_w)
    tmp_w = scr_w;	/* full size <= screen size */
  tmp_x = 10*(port-1);
  if (tmp_h>scr_h)
    tmp_h = scr_h;
  tmp_y = scr_y+16*(port-1);

  wdes = wind_create(wtyp, tmp_x, tmp_y, tmp_w,
    tmp_h);
  if (wdes < 0)
  {
    form_alert(1, "[1][Sorry, GEM has|no more windows|for us...][Ok]");
    return 0;
  }
  wp = &w[wdes];
  wp->wi_w = X0*2 + curfont->inc_x*xsiz;
  wp->wi_h = Y0*2 + curfont->inc_y*ysiz;
  wp->port = port;
  if (!fast)
    graf_growbox(0, 0, 20, 10, tmp_x, tmp_y, tmp_w, tmp_h);
  wind_open(wdes, tmp_x, tmp_y, tmp_w, tmp_h);
  wind_get(wdes, WF_WORKXYWH, &wp->x, &wp->y, &wp->w, &wp->h);
  wp->fulled = 0;
  wp->used = 1;
  wp->x_off = 0;
  wp->y_off = 0;
  wp->px_off = 0;
  wp->py_off = 0;
  wp->m_off = wp->x & 15;
  wp->cur_x = X0;
  wp->cur_y = Y0;
  wp->top_y = Y0;
  wp->font = curfont;
  wp->x_chrs = xsiz;
  wp->y_chrs = ysiz;
  wp->wi_mf.wpix = 2*X0 + xsiz*curfont->inc_x;
  wp->wi_mf.hpix = 2*Y0 + ysiz*curfont->inc_y;
#ifdef	KOPY
  wp->wi_mf.wwords = ((wp->wi_mf.wpix>>5) +1) << 1;
#else
  wp->wi_mf.wwords = (wp->wi_mf.wpix>>4) +1;
#endif
  wp->wi_mf.ptr = getmem(((long)wp->wi_mf.hpix+wp->font->inc_y*MAXSCROLLED)
				*wp->wi_mf.wwords*2);
  wp->wi_mf.format = 0;
  wp->wi_mf.planes = 1;
  wp->ptr_status = LOG_NONE;
  wp->wi_style = wtyp;
  w_rename(wdes, name);
  strcpy(wp->wi_fpath, ".\\*.*");
  wp->top_age = 1;
  for (cnt = 1; cnt < MAX_WIND; cnt++)
    if (w[cnt].port != 0)
      w[cnt].top_age++;
  
  setvslide(wdes);
  sethslide(wdes);
  
  return wp->port;
}

/* w_closei removes a window but does not release its storage.
 * This is used if the window contents must be saved for later use.
 */

w_closei(wdes)
{
  int xx, yy, ww, hh;
  register struct wi_str *wp = &w[wdes];

  if (!wp->used) return;
  if (wp->wi_lfd)
    fclose(wp->wi_lfd);
  wind_get(wdes, WF_CURRXYWH, &xx, &yy, &ww, &hh);
  wind_close(wdes);
  if (!fast)
    graf_shrinkbox(0, 0, 20, 10, xx, yy, ww, hh);
  wind_delete(wdes);
}

/* w_close removes a window.  Most work is done by GEM, although w_close
 * does some cleanup functions, too.
 */

w_close(wdes)
{
  register struct wi_str *wp = &w[wdes];

  if (!wp->used) return;
  w_closei(wdes);
  Mfree(wp->wi_mf.ptr);
  bzero(wp, (long)sizeof (struct wi_str));
}

/* w_resize resizes an existing window.
 */

w_resize(wdes, xsiz, ysiz)
{
  register struct wi_str *wp1 = &w[wdes];
  struct wi_str *wp2;
  struct wi_str ws;
  static int c[8];
  int port, wind, i;

  if (!wp1->used) return;
  ws = *wp1;
  port = find_port(wdes);
  w_closei(wdes);
  bzero(wp1, (long)sizeof (struct wi_str));
  port = w_open(port, "", xsiz, ysiz);
  wind = find_wind(port);
  wp2 = &w[wind];
  c[0] = ws.m_off;
  c[1] = ws.top_y + max(0, ws.wi_mf.hpix - wp2->wi_mf.hpix);
  c[2] = c[0] + min(ws.wi_mf.wpix, wp2->wi_mf.wpix);
  c[3] = c[1] + min(ws.wi_mf.hpix, wp2->wi_mf.hpix);
  c[4] = wp2->m_off;
  c[5] = wp2->top_y;
  c[6] = c[4] + min(ws.wi_mf.wpix, wp2->wi_mf.wpix);
  c[7] = c[5] + min(ws.wi_mf.hpix, wp2->wi_mf.hpix);
  /* copy screen */
  vro_cpyfm(handle, FM_COPY, c, &ws.wi_mf, &wp2->wi_mf);
  /* copy parameters */
  wp2->inverse = ws.inverse;
  wp2->insmode = ws.insmode;
  if (wp2->font != ws.font)
  {
    wp2->cur_x = X0;
    wp2->cur_y = (wp2->y_chrs - 1) * wp2->font->inc_y + Y0;
  }
  else
  {
    wp2->cur_x = (wp2->x_chrs - 1) * wp2->font->inc_x + X0;
    if (ws.cur_x < wp2->cur_x)
      wp2->cur_x = ws.cur_x;
    wp2->cur_y = max(0, ws.cur_y - c[1]) + Y0;
  }
  wp2->state = ws.state;
  for (i=0; i<80; i++) wp2->nuname[i] = ws.nuname[i];
  for (i=0; i<80; i++) wp2->wi_fpath[i] = ws.wi_fpath[i];
  for (i=0; i<20; i++) wp2->wi_fname[i] = ws.wi_fname[i];
  wp2->nuptr = ws.nuptr;
  wp2->ptr_status = ws.ptr_status;
  wp2->wi_lfd = ws.wi_lfd;
  wp2->kerm_act = ws.kerm_act;
  w_rename(wind, ws.name);
  
  Mfree(ws.wi_mf.ptr);
  return port;
}

/* w_rename changes the title bar of a window
 */

w_rename(wdes, name)
char *name;
{
  register struct wi_str *wp = &w[wdes];

  if (name)
    strcpy(wp->name, name);
  if (wp->wi_style & NAME)
  {
    sprintf(wp->dname, " %s%s %s ", (wp->ptr_status != LOG_NONE)? "\275": "",
      wp->wi_lfd? "\237": "", wp->name);
    wind_set(wdes, WF_NAME, wp->dname + (wp->dname[1] == ' '), 0, 0);
  }
}

/* w_redraw redraws part of the screen from window contents.
 * The coordinates are screen relative.
 */

w_redraw(wdes, logic, xx, yy, ww, hh)
{
  static int c[8];
  static GRECT t1, t2;
  register struct wi_str *wp = &w[wdes];

  if (xx+ww > scr_w)
    ww = scr_w - xx;
  if (yy+hh > scr_h+scr_y)
    hh = scr_h+scr_y - yy;
  t2.g_x = xx; t2.g_y = yy;
  t2.g_w = ww; t2.g_h = hh;
  t1.g_x = wp->x; t1.g_y = wp->y;
  t1.g_w = wp->w; t1.g_h = wp->h;
  if (!rc_intersect(&t2, &t1)) return;	/* nothing to do... */
  wind_update(TRUE);
  wind_get(wdes, WF_FIRSTXYWH, &t1.g_x, &t1.g_y, &t1.g_w, &t1.g_h);
  while (t1.g_w && t1.g_h)
  {
    if (rc_intersect(&t2, &t1))
    {
      if (mouse)
      {
	/* we have to do graphics, so switch the mouse off.
	 * mouse will be switched on again in main loop.
	 * this is ugly, but it improves speed a bit...
	 */
	mouse = 0;
	graf_mouse(M_OFF, NULL);
      }
#ifdef	KCOPY
      tfbmr(wp->wi_mf.ptr, t1.g_x - wp->x + wp->x_off + wp->m_off,
	t1.g_y - wp->y + wp->y_off + wp->top_y - Y0, wp->wi_mf.wwords >> 1,
	screen_mf.ptr, t1.g_x, t1.g_y, screen_mf.wwords >> 1,
	t1.g_w, t1.g_h, logic);
#else
      c[0] = t1.g_x - wp->x + wp->x_off + wp->m_off;
      c[1] = t1.g_y - wp->y + wp->y_off + wp->top_y - Y0;
      c[2] = c[0] + t1.g_w - 1;
      c[3] = c[1] + t1.g_h - 1;
      c[4] = t1.g_x;
      c[5] = t1.g_y;
      c[6] = c[4] + t1.g_w - 1;
      c[7] = c[5] + t1.g_h - 1;
      vro_cpyfm(handle, logic, c, &wp->wi_mf, &screen_mf);
#endif
    }
    wind_get(wdes, WF_NEXTXYWH, &t1.g_x, &t1.g_y, &t1.g_w, &t1.g_h);
  }
  if (!fast && !mouse)
  {
    mouse = 1;
    graf_mouse(M_ON, NULL);
  }
  wind_update(FALSE);
}

/* w_update copies a portion of the window to the screen.  Coordinates
 * are window-relative
 */

w_update(wdes, logic, xx, yy, ww, hh)
{
  register struct wi_str *wp = &w[wdes];

  w_redraw(wdes, logic, xx + wp->x - wp->x_off, 
  		yy + wp->y - wp->y_off - wp->top_y + Y0, ww, hh);
}

/* w_move sets the window's idea of its own position on the screen
 */

w_move(wdes, xx, yy, ww, hh)
{
  register struct wi_str *wp = &w[wdes];
  int flag = 0;
  int m_w, m_h;
  int x1, x2;
  int tmp;

  wind_calc(1, wp->wi_style, xx, yy, ww, hh, &dummy, &dummy, &m_w, &m_h);
  if (tmp = (m_w-2*X0)%wp->font->inc_x)
  {
    ww -= tmp;
    m_w -= tmp;
  }
  if (tmp = (m_h-2*Y0)%wp->font->inc_y)
  {
    hh -= tmp;
    m_h -= tmp;
  }
  if (m_w>wp->wi_w) ww = ww-(m_w-wp->wi_w);
  if (m_h>wp->wi_h) hh = hh-(m_h-wp->wi_h);
  wind_set(wdes, WF_CURRXYWH, xx, yy, ww, hh);
  wind_get(wdes, WF_WORKXYWH, &wp->x, &wp->y, &wp->w, &wp->h);
  if (wp->x_off+wp->w > wp->wi_w)
  {
    register int inc_x = wp->font->inc_x;
    flag = 1;
    wp->x_off = (wp->wi_w - wp->w)/inc_x*inc_x;
  }
  if (wp->y_off+wp->h > wp->wi_h)
  {
    register int inc_y = wp->font->inc_y;
    flag = 1;
    wp->y_off = (wp->wi_h - wp->h)/inc_y*inc_y;
  }
  x1 = wp->m_off;
  x2 = (wp->x - wp->x_off) & 15;
  if (x1 != x2)
  {
#ifdef	KOPY
    int top = wp->top_y;
    int cnt = wp->wi_mf.wwords >> 1;
    cpbmr(wp->wi_mf.ptr, x1, top, cnt, wp->wi_mf.ptr, x2, top, cnt,
      wp->wi_w, wp->wi_h);
#else
  int c[8];
    c[0] = x1;
    c[1] = wp->top_y;	/* displayed part of memory form starts here */
    c[2] = x1 + wp->wi_w - 1;
    c[3] = wp->wi_h - 1 + c[1];
    c[4] = x2;
    c[5] = c[1];
    c[6] = x2 + wp->wi_w - 1;
    c[7] = c[3];
    vro_cpyfm(handle, 3, c, &wp->wi_mf, &wp->wi_mf);
#endif
    wp->m_off = x2;
  }
  if (flag)
    w_redraw(wdes, FM_COPY, wp->x, wp->y, wp->w, wp->h);
  setvslide(wdes);
  sethslide(wdes);
}
 
/*
 * w_top makes win the top window.
 */
w_top(win)
int win;
{
  int cnt;

  wind_set(win, WF_TOP, 0, 0, 0, 0);
  outport = find_port(win);
  outwind = win;
  w[outwind].top_age = 0;
  for (cnt = 1; cnt < MAX_WIND; cnt++)
    if (find_port(cnt))	/* if window is in use */
      w[cnt].top_age++;
  printer_mark(outwind);
}

/*
 * w_bottom finds the bottom window and puts it on top
 */
w_bottom()
{
  int i;
  int highwin, highcnt;
  
  highcnt = 0;
  highwin = 1;
  for (i = 1; i < MAX_WIND; i++)
    if (w[i].top_age > highcnt)
    {
      highcnt = w[i].top_age;
      highwin = i;
    }
  if (w[highwin].used)
    w_top(highwin);
}

/*
 * w_hide puts the top window on the bottom.  The new top window is returned.
 */
int w_hide()
{
  int i, j;
  int newtop, botwin, highcnt;
  int oldtop, dum;
  
  wind_get(0, WF_TOP, &oldtop, &dum, &dum, &dum);
  if (!oldtop)
    return (0);
  j = -1;
  botwin = 0;
  for (j = -1; ; j--)
  {
    newtop = botwin;
    botwin = oldtop;
    highcnt = 0;
    for (i = 1; i < MAX_WIND; i++)
    {
      if (w[i].top_age > highcnt)
      {
        highcnt = w[i].top_age;
        botwin = i;
      }
    }
    if (botwin == oldtop)
      break;
    wind_set(botwin, WF_TOP, 0, 0, 0, 0);
    w[botwin].top_age = j; /*top_age less than untouched windows (top_age < 0)*/
  }
  for (j = 1; j < MAX_WIND; j++)
    if (find_port(j)) /* if window is in use */
      w[j].top_age += MAX_WIND + 3; /* correct top_age to reflect new order */
  return(newtop ? newtop : oldtop);
}

#define TINYX 80
#define TINYY 70
/*
 * w_shrink saves current size and location and shrinks to standard tiny size.
 * The second from the top non-shrunk window is placed on top.
 */
w_shrink(wdes)
int wdes;
{
  register struct wi_str *wp = &w[wdes];
  int curw, dummy;
  
  /*
   * Don't shrink a window that is currently shrunk
   */
  wind_get(wdes, WF_CURRXYWH, &dummy, &dummy, &curw, &dummy);
  if (curw <= TINYX)
    return;

  /*
   * Set up fulled and previous size and location window variables to tiny
   * size.  Then call w_full
   */
  wp->fulled = 1;
  wp->px = scr_x + scr_w - TINYX + 2;
  wp->py = scr_y + (wdes - 1) * (TINYY - 2);
  wp->pw = TINYX;
  wp->ph = TINYY;
  if (wp->py + 10 > scr_y + scr_h)
  {
    wp->py = wp->py - scr_h + 10;
    wp->px = scr_x + scr_w - TINYY * 2;
  }
  
  return (w_full(wdes));
}

/* w_full toggles size and location
 */
w_full(wdes)
{
  register struct wi_str *wp = &w[wdes];
  int x1, y1, w1, h1;
  int x2, y2, w2, h2;
  int full, topwin;

  full = wp->fulled;
  if (full) {
    x1 = wp->px;
    y1 = wp->py;
    w1 = wp->pw;
    h1 = wp->ph;
  } else
    wind_get(wdes, WF_FULLXYWH, &x1, &y1, &w1, &h1);

  wind_get(wdes, WF_CURRXYWH, &x2, &y2, &w2, &h2);
  wp->px = x2;
  wp->py = y2;
  wp->pw = w2;
  wp->ph = h2;
  if (!fast)
  {
    if (w2>=w1 && h2>=h1)
      graf_growbox(x2, y2, w2, h2, x1, y1, w1, h1);
    else if (w2<=w1 && h2<=h1)
      graf_shrinkbox(x1, y1, w1, h1, x2, y2, w2, h2);
  }

  x2 = wp->x_off;
  y2 = wp->y_off;
  wp->x_off = wp->px_off;
  wp->y_off = wp->py_off;
  wp->px_off = x2;
  wp->py_off = y2;

  w_move(wdes, x1, y1, w1, h1);
  w_redraw(wdes, FM_COPY, wp->x, wp->y, wp->w, wp->h);
  wp->fulled = 1;
  topwin = wdes;
  if (h1 < TINYY + 10)
  {
    int lowcnt, i;
  
    lowcnt = 32000;
    for (i = 1; i< MAX_WIND; i++)
    {
      if (find_port(i))
      {
        wind_get(i, WF_CURRXYWH, &x2, &y2, &w2, &h2);
      
        if (w[i].top_age < lowcnt && h2 > TINYY + 10 )
        { /* find top non-tiny open window */
          lowcnt = w[i].top_age;
          topwin = i;
	}
      }
    }
    wind_set(topwin, WF_TOP, 0, 0, 0, 0);
  }
  return(topwin);
}

w_arrow(wdes, arrow)
{
  register struct wi_str *wp = &w[wdes];
  int inc_x = wp->font->inc_x;
  int inc_y = wp->font->inc_y;

  switch (arrow)
  {
  case 0:	/* page up */
    wp->y_off -= wp->h/inc_y*inc_y;
    goto y_upd;

  case 1:	/* page down */
    wp->y_off += wp->h/inc_y*inc_y;
    goto y_upd;

  case 2:	/* row up */
    wp->y_off -= inc_y;
    goto y_upd;

  case 3:	/* row down */
    wp->y_off += inc_y;
    goto y_upd;

  case 4:	/* page left */
    wp->x_off -= wp->w/inc_x*inc_x;
    goto x_upd;

  case 5:	/* page right */
    wp->x_off += wp->w/inc_x*inc_x;
    goto x_upd;

  case 6:	/* column left */
    wp->x_off -= inc_x;
    goto x_upd;

  case 7:	/* column right */
    wp->x_off += inc_x;
    goto x_upd;
  }

x_upd:
  if (wp->x_off<0) wp->x_off = 0; else
  if (wp->x_off+wp->w > wp->wi_w) wp->x_off = (wp->wi_w - wp->w)/inc_x*inc_x;
  sethslide(wdes);
  goto upd;

y_upd:
  if (wp->y_off<0) wp->y_off = 0; else
  if (wp->y_off+wp->h > wp->wi_h) wp->y_off = (wp->wi_h - wp->h)/inc_y*inc_y;
  setvslide(wdes);
  
upd:
  w_redraw(wdes, FM_COPY, wp->x, wp->y, wp->w, wp->h);
}

w_slide(wdes, hor, val)
{
  register struct wi_str *wp = &w[wdes];

  if (hor)
  {
    tmp = wp->font->inc_x;
    wp->x_off = ((long)val*(wp->wi_w-wp->w)/1000)/tmp*tmp;
    sethslide(wdes);
  } else
  {
    tmp = wp->font->inc_y;
    wp->y_off = ((long)val*(wp->wi_h-wp->h)/1000)/tmp*tmp;
    setvslide(wdes);
  }
  w_redraw(wdes, FM_COPY, wp->x, wp->y, wp->w, wp->h);
}

sethslide(wdes)
{
  register struct wi_str *wp = &w[wdes];

  if (wp->wi_style & HSLIDE)
  {
    tmp = (long)1000*wp->x_off/(wp->wi_w-wp->w);
    wind_set(wdes, WF_HSLIDE, tmp, 0, 0, 0);
    tmp = (long)1000*wp->w/wp->wi_w;
    wind_set(wdes, WF_HSLSIZE, tmp, 0, 0, 0);
  }
}

setvslide(wdes)
{
  register struct wi_str *wp = &w[wdes];

  if (wp->wi_style & VSLIDE)
  {
    tmp = (long)1000*wp->y_off/(wp->wi_h-wp->h);
    wind_set(wdes, WF_VSLIDE, tmp, 0, 0, 0);
    tmp = (long)1000*wp->h/wp->wi_h;
    wind_set(wdes, WF_VSLSIZE, tmp, 0, 0, 0);
  }
}

w_flash(wdes, state)
{
  register struct wi_str *wp = &w[wdes];
  static int wdes_last;
#ifdef	KOPY
  int x, y, cnt;
#else
  int t[8];
#endif

  if (wdes != wdes_last) w_flash(wdes_last, 1);
  wdes_last = wdes;
  if (!wp->used || wp->curstate == state) return;
  if (state == 2)
    wp->curstate = !wp->curstate;
  else
    wp->curstate = state;
#ifdef	KOPY
  x = wp->cur_x + wp->m_off;
  y = wp->cur_y;
  cnt = wp->wi_mf.wwords >> 1;
  tfbmr(wp->wi_mf.ptr, x, y, cnt, wp->wi_mf.ptr, x, y, cnt,
    wp->font->inc_x, wp->font->inc_y, 12);
#else
  t[0] = t[4] = wp->cur_x + wp->m_off;
  t[1] = t[5] = wp->cur_y;
  t[2] = t[6] = t[0]+wp->font->inc_x-1;
  t[3] = t[7] = t[1]+wp->font->inc_y-1;
  vro_cpyfm(handle, 12, t, &wp->wi_mf, &wp->wi_mf);
#endif
  w_update(wdes, FM_COPY, wp->cur_x, wp->cur_y, wp->font->inc_x, wp->font->inc_y);
}
  
/* w_output prints a string onto the window.  The string may
 * contain control chars and escape sequences.  It ends with \0.
 */

w_output(wdes, ptr)
char *ptr;
{
  register struct wi_str *wp = &w[wdes];
  static char ch;
  static int inc_x, cur_x;
  static int state;
  static int inc_y, cur_y;
#ifdef	KOPY
  int x, w, cnt;
#else
  static int t[8];
#endif
  static int f_x, f_y, f_mod;
  static int scrolled;	/* Number of scrolling operations delayed */
  static int xsiz, ysiz;/* Size in chars of terminal emulation for this window*/
  register unsigned char *sptr;
  register unsigned long *dptr;
  register unsigned long mask;
  register int shift;
  register unsigned long val;
  static int count;
  static char * fdata;
  static long width;
  static char * wimfptr;
  static int moffincx;
  static char * savptr;
  

#ifdef DEBUG
  printf("entered w_output\n");
#endif
  if (!wp->font) return;
  state = wp->state;
  inc_x = wp->font->inc_x;
  inc_y = wp->font->inc_y;
  xsiz = wp->x_chrs;
  ysiz = wp->y_chrs;
  f_x = cur_x = wp->cur_x;
  f_y = cur_y = wp->cur_y;
  scrolled = wp->top_y/inc_y;
  fdata = wp->font->f_data;
  width = 2 * wp->wi_mf.wwords;
  wimfptr = ((char *) (wp-> wi_mf.ptr)) - 2;
  moffincx = wp->m_off + inc_x - 1;
  f_mod = 0;
  savptr = ptr;
  
  if (wp->curstate) w_flash(wdes, 0);

  while (ch = *ptr++)
  {
    switch (state)
    {
    case S_NORMAL:
      if (ch >= ' ')
      {
	if (wp->insmode) /* open space for character */
	{
#ifdef	KOPY
	  x = cur_x + wp->m_off;
	  cnt = wp->wi_mf.wwords >> 1;
	  cpbmr(wp->wi_mf.ptr, x, cur_y, cnt,
	    wp->wi_mf.ptr, x + inc_x, cur_y, cnt,
	    (xsiz - 1) * inc_x + wp->m_off - x, inc_y);
#else
	  t[0] = cur_x + wp->m_off;
	  t[1] = t[5] = cur_y;
	  t[2] = (xsiz - 1) * inc_x + wp->m_off - 1;
	  t[3] = t[7] = cur_y + inc_y - 1;
	  t[4] = t[0] + inc_x;
	  t[6] = t[2] + inc_x;
	  vro_cpyfm(handle, 3, t, &wp->wi_mf, &wp->wi_mf);
#endif
	}
	/* paint the character */
	sptr = fdata+ch*16;
	dptr = wimfptr + cur_y*width
		+ (((moffincx + cur_x)>>4)<<1);
	shift = 15 - ((moffincx + cur_x)&15);
	if (overstrike)
	  mask = -1L;
	else
	  mask = (-1L<<(shift+inc_x)|(1<<shift)-1);
	if (wp->inverse)
	{
	  for (count = inc_y; count; count--)
	  {
	    val = ((long)(*sptr++))<<shift ^ ~mask;
	    *dptr = (*dptr&mask)|val;
	    ((char *)dptr) += width;
	  }
	} else
	{
	  for (count = inc_y; count; count--)
	  {
	    val = ((long)(*sptr++))<<shift;
	    *dptr = (*dptr&mask)|val;
	    ((char *)dptr) += width;
	  }
	}
        cur_x += inc_x;
	f_mod = 1;
	if (cur_x > inc_x * xsiz) /* autowrap */
	{
	  cur_y += inc_y;
	  if (cur_y >= wp->top_y + inc_y * ysiz) {
	    if (wp->ptr_status & LOG_TOP)
	      dump_line(wdes, 0);
	    wp->top_y += inc_y;
	    ++ scrolled;
	  }
	  if (! scrolled)
	  {
	    w_update(wdes, FM_COPY, f_x, f_y, cur_x-f_x, inc_y);
	    f_mod = 0;
	  }
	  cur_x = X0;

	  f_x = cur_x;
	  f_y = cur_y;
	}
      } else /* not printable character */
      {
	if (f_mod && !scrolled)
	{
	  if (!wp->insmode)
	    w_update(wdes, FM_COPY, f_x, f_y, cur_x - f_x, inc_y);
	  else
	    w_update(wdes, FM_COPY, f_x, f_y, xsiz * inc_x-f_x, inc_y);
	  f_mod = 0;
	}
	switch (ch)
	{
	case '\007':	/* Bell */
	  if (audibell)
	    Bconout(2, '\007');
	  if (toponbel)
	    /* put this window on top but don't make it the current window.
	     * should we set a flag so that the first input from the current
	     * window puts it back on top?
	     */
	    wind_set(wdes, WF_TOP, wdes, 0, 0, 0);
	  if (visibell)
	  {
	    w_redraw(wdes, FM_INVERT, wp->x, wp->y, wp->w, wp->h);
	    w_redraw(wdes, FM_COPY, wp->x, wp->y, wp->w, wp->h);
	    /* Should clear flag to prevent need for next update? */
	  }
	  break;

	case '\r':	/* Carriage Return */
	  cur_x = X0;
	  break;

	case '\b':	/* Backspace */
	  if (cur_x>X0) cur_x -= inc_x;
	  break;

	case '\n':	/* Newline */
	  cur_y += inc_y;
	  if (cur_y >= inc_y * ysiz + wp->top_y)
	  {
	    if (wp->ptr_status & LOG_TOP)
	      dump_line(wdes, 0);
	    wp->top_y += inc_y;
	    ++ scrolled;
	  }
	  break;

	case '\036':	/* Home */
	  cur_x = X0;
	  cur_y = wp->top_y;
	  break;

	case '\013':	/* Cursor Up */
	  if (cur_y!=wp->top_y) {
	    cur_y -= inc_y;
	  }
	  break;

	case '\014':	/* Cursor Right */
	  if (cur_x < (xsiz - 1) * inc_x) cur_x += inc_x;
	  break;

	case '\032':	/* Clear Screen */
	  wp->inverse = wp->insmode = 0;
	  cur_x = X0;
	  cur_y = Y0;
	  wp->top_y = Y0;
	  lineerase(wp, 0, ysiz - 1 + MAXSCROLLED);
	  ++ scrolled;
	  break;

	case '\t':	/* Tab */
	  cur_x = ((cur_x/inc_x/8+1))*inc_x*8+X0;
	  break;

	case '\033':	/* ESC */
	  state = S_ESC;
	  count = 0; /* count is used for insert or delete line */
	  break;
	}
	f_x = cur_x;
	f_y = cur_y;
      }
      break;

    case S_ESC:
      if (ch >= '0' && ch <= '9') {
        count = count * 10 + ch - '0';
	break;
      }
      switch (ch)
      {
      case '*':		/* Clear Screen */
	f_x = cur_x = X0;
	wp->top_y = f_y = cur_y = Y0;
	wp->inverse = wp->insmode = 0;
	lineerase(wp, 0, ysiz - 1 + MAXSCROLLED);
	++ scrolled;
	state = S_NORMAL;
	break;

      case 'Y':		/* Clear to End of Screen */
	lineerase(wp, cur_y / inc_y + 1, ysiz - 1 + wp->top_y / inc_y);
	if (! scrolled)
	  w_update(wdes, FM_COPY, X0, cur_y + inc_y, xsiz*inc_x, ysiz*inc_y);
	/* fall through */
      case 'T':		/* Clear to End of Line */
#ifdef	KOPY
	x = cur_x + wp->m_off;
	cnt = wp->wi_mf.wwords >> 1;
	tfbmr((short *) 0, 0, 0, 0, wp->wi_mf.ptr, x, cur_y, cnt,
	  X0 + xsiz * inc_x + wp->m_off - x, inc_y, 0);
#else
	t[0] = t[4] = cur_x + wp->m_off;
	t[1] = t[5] = cur_y;
	t[2] = t[6] = X0-1 + xsiz*inc_x +wp->m_off;
	t[3] = t[7] = cur_y+inc_y-1;
	vro_cpyfm(handle, 0, t, &wp->wi_mf, &wp->wi_mf);
#endif
	if (! scrolled)
	  w_update(wdes, FM_COPY, cur_x, cur_y, xsiz * inc_x - cur_x, inc_y);
	state = S_NORMAL;
	break;

      case 'E':		/* Add Line */
      case 'R':		/* Delete Line */
        if (count == 0) {
	  count = 1;
	  /* Look ahead for contiguous insert/delete line operations */
	  while (*ptr == '\033' && ptr[1] == ch) {
	    ptr +=2;
	    count ++;
	  }
	}
	if (ch == 'E')
	  scrolldn(wp, cur_y/inc_y, ysiz-(cur_y-wp->top_y+Y0)/inc_y-count, count);
	else
	  scrollup(wp, cur_y / inc_y,
	    ysiz - (cur_y - wp->top_y + Y0)/inc_y - count, count);
	if (! scrolled)
	  w_update(wdes, FM_COPY, X0, cur_y, xsiz * inc_x,
	    ysiz * inc_y - cur_y + wp->top_y - Y0);
	state = S_NORMAL;
	break;

      case 'q':		/* Insert Mode */
	wp->insmode = 1;
	state = S_NORMAL;
	break;

      case 'r':		/* End Insert */
	wp->insmode = 0;
	state = S_NORMAL;
	break;

      case 'W':		/* Delete Character */
#ifdef	KOPY
	x = cur_x + wp->m_off;
	w = X0 + xsiz * inc_x + wp->m_off - x;
	cnt = wp->wi_mf.wwords >> 1;
	cpbmr(wp->wi_mf.ptr, x + inc_x, cur_y, cnt,
	  wp->wi_mf.ptr, x, cur_y, cnt, w, inc_y);
	tfbmr((short *) 0, 0, 0, 0,
	  wp->wi_mf.ptr, X0 + (xsiz - 1) * inc_x + wp->m_off, cur_y, cnt,
	  inc_x, inc_y, 0);
#else
	t[0] = cur_x + inc_x + wp->m_off;
	t[1] = t[5] = cur_y;
	t[2] = X0 - 1 + xsiz * inc_x + wp->m_off;
	t[3] = t[7] = cur_y+inc_y - 1;
	t[4] = t[0] - inc_x;
	t[6] = t[2] - inc_x;
	vro_cpyfm(handle, 3, t, &wp->wi_mf, &wp->wi_mf);
	t[0] = t[4] = X0 + (xsiz - 1) * inc_x + wp->m_off;
	t[2] = t[6] = t[0] + inc_x - 1;
	vro_cpyfm(handle, 0, t, &wp->wi_mf, &wp->wi_mf);
#endif
	if (! scrolled)
	  w_update(wdes, FM_COPY, cur_x, cur_y, xsiz * inc_x - (cur_x - X0),
	    inc_y);
	state = S_NORMAL;
	break;

      case '=':		/* Cursor Movement */
	state = S_ESC1;
	break;

      case 'G':		/* Switch Inverse/Normal */
	state = S_ESC2;
	break;

      case 'S':		/* Change Status Line */
	state = S_STATUS;
	wp->nuptr = 0;
	break;
	
      case '[':		/* ascii escape */
        state = S_ESCA;
	wp->nuptr = 0;
	break;

      default:		/* Unknown escape sequence */
	state = S_NORMAL;
      }
      break;

    case S_ESC1:	/* get line number */
      if (ch < ' ' || ch >= ' ' + ysiz) ch = ' ';
      f_y = cur_y = (ch-' ')*inc_y + wp->top_y;
      state = S_ESC3;
      break;

    case S_ESC3:	/* get column number */
      if (ch < ' ' || ch >= ' ' + xsiz) ch = ' ';
      f_x = cur_x = (ch-' ')*inc_x +X0;
      state = S_NORMAL;
      break;

    case S_ESC2:	/* get normal/inverse state */
      wp->inverse = ch&1;
      state = S_NORMAL;
      break;

    case S_STATUS:
      if (ch == '\r')
      {
	wp->nuname[wp->nuptr] = '\0';
	w_rename(wdes, wp->nuname);
	state = S_NORMAL;
      } else if (wp->nuptr < 72)
      {
	wp->nuname[wp->nuptr++] = ch;
      }
      break;
    case S_ESCA:
      if (ch >= '0' && ch <= '9')
        wp->nuptr = ch - '0' + 10 * wp->nuptr;
      else if (ch == 't')
      {
        if (wp-> nuptr == 18)
	{
	  char posstr[20];
	  
	  sprintf(posstr, "\033[8;%d;%dt", ysiz, xsiz);
	  proto_out(find_port(wdes), posstr, strlen(posstr));
	}
	state = S_NORMAL;
      }
      else state = S_NORMAL;
      break;
    } /* end switch on state */

    if (scrolled >= MAXSCROLLED)
    {
      if (wp->top_y != Y0) {
        scrollup(wp, 0, ysiz, wp->top_y/inc_y);
	wp->top_y = Y0;
        f_y = cur_y = Y0 + (ysiz - 1) * inc_y;
      }
      w_redraw(wdes, FM_COPY, wp->x, wp->y, wp->w, wp->h);
      scrolled = 0;
    }
  } /* end while loop for each character */

  if (wp->ptr_status & LOG_BOTOM) {
    ptr = savptr;
    while ((ch = *ptr++) && (wp->ptr_status & LOG_BOTOM))
      if (Cprnout(ch) == 0) wp->ptr_status = LOG_NONE;
  }

  if (wp->wi_lfd) {
    while (ch = *savptr++)
      putc(ch, wp->wi_lfd);
  }

  if (scrolled) {
    if (scrolled >= MAXSCROLLED) {
      if (wp->top_y != Y0) {
        scrollup(wp, 0, ysiz, wp->top_y/inc_y);
        wp->top_y = Y0;
        cur_y = Y0 + (ysiz - 1) * inc_y;
      }
    }
    w_redraw(wdes, FM_COPY, wp->x, wp->y, wp->w, wp->h);
  }
  else
    if (f_mod)
    {
      if (!wp->insmode)
        w_update(wdes, FM_COPY, f_x, f_y, cur_x - f_x, inc_y);
      else
        w_update(wdes, FM_COPY, f_x, f_y, xsiz * inc_x-f_x, inc_y);
    }
  wp->cur_x = cur_x;
  wp->cur_y = cur_y;
  wp->state = state;
#ifdef DEBUG
  printf ("calling w_flash\n");
#endif
  w_flash(wdes, 1);
}

lineerase(wp, first, last)
register struct wi_str *wp;
{
  register int *p;
  long count;
  long linespace = wp->wi_mf.wwords*wp->font->inc_y;

  p = wp->wi_mf.ptr + first*linespace + Y0*wp->wi_mf.wwords - 1;
  count = (last-first+1)*linespace;
  while (count > 7)
  {
    *(((long *)p)++) = 0;
    *(((long *)p)++) = 0;
    *(((long *)p)++) = 0;
    *(((long *)p)++) = 0;
    count -= 8;
  }
  while (--count >= 0)
    *++p = 0;
}

scrollup(wp, first, nlines, amount)
register struct wi_str *wp;
{
  register int *p1, *p2;
  register long count;
  int linespace = wp->wi_mf.wwords*wp->font->inc_y;

  p1 = wp->wi_mf.ptr + first*linespace + Y0*wp->wi_mf.wwords;
  p2 = p1 + linespace * amount;
  count = (long)(nlines)*linespace;
  while (count > 15)
  {
    *(((long *)p1)++) = *(((long *)p2)++);
    *(((long *)p1)++) = *(((long *)p2)++);
    *(((long *)p1)++) = *(((long *)p2)++);
    *(((long *)p1)++) = *(((long *)p2)++);
    *(((long *)p1)++) = *(((long *)p2)++);
    *(((long *)p1)++) = *(((long *)p2)++);
    *(((long *)p1)++) = *(((long *)p2)++);
    *(((long *)p1)++) = *(((long *)p2)++);
    count -= 16;
  }
  while (--count >= 0)
    *(p1++) = *(p2++);
  count = linespace * amount;
  while (count > 7)
  {
    *(((long *)p1)++) = 0;
    *(((long *)p1)++) = 0;
    *(((long *)p1)++) = 0;
    *(((long *)p1)++) = 0;
    count -= 8;
  }
  while (--count >= 0)
    *(p1++) = 0;
}

scrolldn(wp, first, nlines, amount)
register struct wi_str *wp;
{
  register int *p1, *p2;
  register long count;
  long linespace = wp->wi_mf.wwords*wp->font->inc_y;

  p1 = wp->wi_mf.ptr + (nlines+first+amount)*linespace + Y0*wp->wi_mf.wwords;

  p2 = p1 - linespace * amount;
  count = (long)(nlines)*linespace;
  while (count > 15)
  {
    *--(long *)p1 = *--(long *)p2;
    *--(long *)p1 = *--(long *)p2;
    *--(long *)p1 = *--(long *)p2;
    *--(long *)p1 = *--(long *)p2;
    *--(long *)p1 = *--(long *)p2;
    *--(long *)p1 = *--(long *)p2;
    *--(long *)p1 = *--(long *)p2;
    *--(long *)p1 = *--(long *)p2;
    count -= 16;
  }
  while (--count >= 0)
    *--p1 = *--p2;
  count = linespace * amount;
  while (count > 7)
  {
    *--(long *)p1 = 0L;
    *--(long *)p1 = 0L;
    *--(long *)p1 = 0L;
    *--(long *)p1 = 0L;
    count -= 8;
  }
  while (--count >= 0)
    *--p1 = 0;
}
