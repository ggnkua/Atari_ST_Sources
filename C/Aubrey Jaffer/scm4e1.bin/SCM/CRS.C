/* Scheme implementation intended for JACAL.
   Copyright (C) 1992, 1993, 1994 Aubrey Jaffer. */

#include "scm.h"
#include <curses.h>

#ifdef MWC
#include <unctrl.h>
#endif

#ifndef __STDC__
int wrefresh();
int wgetch();
#endif

/* define WIN port type */
#define WIN(obj) ((WINDOW*)CDR(obj))
#define WINP(obj) (tc16_window==TYP16(obj))
int freewindow(win)
     WINDOW *win;
{
  if (win==stdscr) return 0;
  delwin(win);
  return 0;
}
int prinwindow(exp,port,writing)
     SCM exp; SCM port; int writing;
{
  prinport(exp,port,"window");
  return !0;
}
int bwaddch(c,win) int c; WINDOW *win; {waddch(win,c);return c;}
int bwaddstr(str,win) char *str; WINDOW *win; {waddstr(win,str);return 0;}
sizet bwwrite(str,siz,num,win)
     sizet siz, num;
     char *str; WINDOW *win;
{
  sizet i = 0, prod = siz*num;
  for (;i < prod;i++) waddch(win,str[i]);
  return num;
}
int tc16_window;
static ptobfuns winptob = {mark0,freewindow,prinwindow,equal0,
			     bwaddch,bwaddstr,bwwrite,wrefresh,
			     wgetch,freewindow};

SCM mkwindow(win)
     WINDOW *win;
{
  SCM z;
  if (NULL==win) return BOOL_F;
  NEWCELL(z);
  DEFER_INTS;
  SETCHARS(z, win);
  CAR(z) = tc16_window | OPN | RDNG | WRTNG;
  ALLOW_INTS;
  return z;
}

SCM *loc_stdscr = 0;
SCM linitscr()
{
  WINDOW *win;
  if NIMP(*loc_stdscr) {
    refresh();
    return *loc_stdscr;
  }
  win = initscr();
  return *loc_stdscr = mkwindow(win);
}
SCM lendwin()
{
  if IMP(*loc_stdscr) return BOOL_F;
  return ERR==endwin() ? BOOL_F : BOOL_T;
}

static char s_newwin[] = "newwin", s_subwin[] = "subwin", s_mvwin[] = "mvwin",
  	    s_overlay[] = "overlay", s_overwrite[] = "overwrite";
SCM lnewwin(lines, cols, args)
     SCM lines, cols, args;
{
  SCM begin_y, begin_x;
  WINDOW *win;
  ASSERT(INUMP(lines), lines, ARG1, s_newwin);
  ASSERT(INUMP(cols), cols, ARG2, s_newwin);
  ASSERT(2==ilength(args), args, WNA, s_newwin);
  begin_y = CAR(args);
  begin_x = CAR(CDR(args));
  ASSERT(INUMP(begin_y), begin_y, ARG3, s_newwin);
  ASSERT(INUMP(begin_x), begin_y, ARG4, s_newwin);
  win = newwin(INUM(lines), INUM(cols),
	       INUM(begin_y), INUM(begin_x));
  return mkwindow(win);
}

SCM lmvwin(win, y, x)
     SCM win, y, x;
{
  ASSERT(NIMP(win) && WINP(win),win,ARG1,s_mvwin);
  ASSERT(INUMP(x),x,ARG2,s_mvwin);
  ASSERT(INUMP(y),y,ARG3,s_mvwin);
  return ERR==mvwin(WIN(win),INUM(y),INUM(x)) ? BOOL_F : BOOL_T;
}

SCM lsubwin(win, lines, args)
     SCM win, lines, args;
{
  SCM cols, begin_y, begin_x;
  WINDOW *nwin;
  ASSERT(NIMP(win) && WINP(win), win, ARG1, s_subwin);
  ASSERT(INUMP(lines), lines, ARG2, s_subwin);
  ASSERT(3==ilength(args), args, WNA, s_subwin);
  cols = CAR(args);
  args = CDR(args);
  begin_y = CAR(args);
  begin_x = CAR(CDR(args));
  ASSERT(INUMP(cols), cols, ARG3, s_subwin);
  ASSERT(INUMP(begin_y), begin_y, ARG3, s_subwin);
  ASSERT(INUMP(begin_x), begin_y, ARG4, s_subwin);
  nwin = subwin(WIN(win), INUM(lines), INUM(cols),
		INUM(begin_y), INUM(begin_x));
  return mkwindow(nwin);
}

SCM loverlay(srcwin, dstwin)
     SCM srcwin, dstwin;
{
  ASSERT(NIMP(srcwin) && WINP(srcwin), srcwin, ARG1, s_overlay);
  ASSERT(NIMP(dstwin) && WINP(dstwin), dstwin, ARG2, s_overlay);
  return ERR==overlay(WIN(srcwin),WIN(dstwin)) ? BOOL_F : BOOL_T;
}

SCM loverwrite(srcwin, dstwin)
     SCM srcwin, dstwin;
{
  ASSERT(NIMP(srcwin) && WINP(srcwin), srcwin, ARG1, s_overwrite);
  ASSERT(NIMP(dstwin) && WINP(dstwin), dstwin, ARG2, s_overwrite);
  return ERR==overwrite(WIN(srcwin),WIN(dstwin)) ? BOOL_F : BOOL_T;
}

static char s_wmove[] = "wmove", s_wadd[] = "wadd", s_winsert[] = "winsert",
	s_box[] = "box";
SCM lwmove(win, y, x)
     SCM win, y, x;
{
  ASSERT(NIMP(win) && WINP(win),win,ARG1,s_wmove);
  ASSERT(INUMP(x),x,ARG2,s_wmove);
  ASSERT(INUMP(y),y,ARG3,s_wmove);
  return ERR==wmove(WIN(win),INUM(y),INUM(x)) ? BOOL_F : BOOL_T;
}

SCM lwadd(win, obj)
     SCM win, obj;
{
  ASSERT(NIMP(win) && WINP(win),win,ARG1,s_wadd);
  if ICHRP(obj)
    return ERR==waddch(WIN(win),ICHR(obj)) ? BOOL_F : BOOL_T;
  if INUMP(obj)
    return ERR==waddch(WIN(win),INUM(obj)) ? BOOL_F : BOOL_T;
  ASSERT(NIMP(obj) && STRINGP(obj),obj,ARG2,s_wadd);
  return ERR==waddstr(WIN(win),CHARS(obj)) ? BOOL_F : BOOL_T;
}

SCM lwinsert(win, obj)
     SCM win, obj;
{
  ASSERT(NIMP(win) && WINP(win),win,ARG1,s_winsert);
  if INUMP(obj)
    return ERR==winsch(WIN(win),INUM(obj)) ? BOOL_F : BOOL_T;
  ASSERT(ICHRP(obj),obj,ARG2,s_winsert);
  return ERR==winsch(WIN(win),ICHR(obj)) ? BOOL_F : BOOL_T;
}

SCM lbox(win, vertch, horch)
     SCM win, vertch, horch;
{
  int v, h;
  ASSERT(NIMP(win) && WINP(win),win,ARG1,s_box);
  if INUMP(vertch) v = INUM(vertch);
  else {
    ASSERT(ICHRP(vertch),vertch,ARG2,s_box);
    v = ICHR(vertch);
  }
  if INUMP(horch) h = INUM(horch);
  else {
    ASSERT(ICHRP(horch),horch,ARG3,s_box);
    h = ICHR(horch);
  }
  return ERR==box(WIN(win),v,h) ? BOOL_F : BOOL_T;
}

static char s_getyx[] = "getyx", s_winch[] = "winch", s_unctrl[] = "unctrl";
SCM lgetyx(win)
     SCM win;
{
  int y, x;
  ASSERT(NIMP(win) && WINP(win),win,ARG1,s_getyx);
  getyx(WIN(win),y,x);
  return cons2(MAKINUM(y), MAKINUM(x), EOL);
}

SCM lwinch(win)
     SCM win;
{
  ASSERT(NIMP(win) && WINP(win),win,ARG1,s_winch);
  return MAKICHR(winch(WIN(win)));
}

SCM lunctrl(c)
     SCM c;
{
  ASSERT(ICHRP(c),c,ARG1,s_unctrl);
  {
    char *str = unctrl(ICHR(c));
    return makfromstr(str,strlen(str));
  }
}
static char s_owidth[] = "output-port-width";
static char s_oheight[] = "output-port-height";
SCM owidth(arg)
     SCM arg;
{
  if UNBNDP(arg) arg = cur_outp;
  ASSERT(NIMP(arg) && OPOUTPORTP(arg),arg,ARG1,s_owidth);
  if NIMP(*loc_stdscr)
    if WINP(arg) return MAKINUM(WIN(arg)->_maxx+1);
    else return MAKINUM(COLS);
  return MAKINUM(80);
}
SCM oheight(arg)
     SCM arg;
{
  if UNBNDP(arg) arg = cur_outp;
  ASSERT(NIMP(arg) && OPOUTPORTP(arg),arg,ARG1,s_owidth);
  if NIMP(*loc_stdscr)
    if WINP(arg) return MAKINUM(WIN(arg)->_maxy+1);
    else return MAKINUM(LINES);
  return MAKINUM(24);
}
SCM lrefresh()
{
  return MAKINUM(wrefresh(curscr));
}

#define SUBR0(lname,name) SCM lname(){name();return UNSPECIFIED;}
SUBR0(lnl,nl)
SUBR0(lnonl,nonl)
SUBR0(lcbreak,cbreak)
SUBR0(lnocbreak,nocbreak)
SUBR0(lecho,echo)
SUBR0(lnoecho,noecho)
SUBR0(lraw,raw)
SUBR0(lnoraw,noraw)
SUBR0(lsavetty,savetty)
SUBR0(lresetty,resetty)

static char s_nonl[] = "nonl", s_nocbreak[] = "nocbreak",
	    s_noecho[] = "noecho", s_noraw[] = "noraw";

static iproc subr0s[] = {
	{"initscr",linitscr},
	{"endwin",lendwin},
	{&s_nonl[2],lnl},
	{s_nonl,lnonl},
	{&s_nocbreak[2],lcbreak},
	{s_nocbreak,lnocbreak},
	{&s_noecho[2],lecho},
	{s_noecho,lnoecho},
	{&s_noraw[2],lraw},
	{s_noraw,lnoraw},
	{"resetty",lresetty},
	{"savetty",lsavetty},
	{"refresh",lrefresh},
	{0,0}};

#define SUBRW(ln,n,s_n,sn) static char s_n[]=sn;\
	SCM ln(w)SCM w;\
	{ASSERT(NIMP(w) && WINP(w),w,ARG1,sn);\
	return ERR==n(WIN(w))?BOOL_F:BOOL_T;}

SUBRW(lwerase,werase,s_werase,"werase")
SUBRW(lwclear,wclear,s_wclear,"wclear")
SUBRW(lwclrtobot,wclrtobot,s_wclrtobot,"wclrtobot")
SUBRW(lwclrtoeol,wclrtoeol,s_wclrtoeol,"wclrtoeol")
SUBRW(lwdelch,wdelch,s_wdelch,"wdelch")
SUBRW(lwdeleteln,wdeleteln,s_wdeleteln,"wdeleteln")
SUBRW(lwinsertln,winsertln,s_winsertln,"winsertln")
SUBRW(lscroll,scroll,s_scroll,"scroll")
SUBRW(ltouchwin,touchwin,s_touchwin,"touchwin")
SUBRW(lwstandout,wstandout,s_wstandout,"wstandout")
SUBRW(lwstandend,wstandend,s_wstandend,"wstandend")

static iproc subr1s[] = {
	{s_werase,lwerase},
	{s_wclear,lwclear},
	{s_wclrtobot,lwclrtobot},
	{s_wclrtoeol,lwclrtoeol},
	{s_wdelch,lwdelch},
	{s_wdeleteln,lwdeleteln},
	{s_winsertln,lwinsertln},
	{s_scroll,lscroll},
	{s_touchwin,ltouchwin},
	{s_wstandout,lwstandout},
	{s_wstandend,lwstandend},
	{s_getyx,lgetyx},
	{s_winch,lwinch},
	{s_unctrl,lunctrl},
	{0,0}};

#define SUBROPT(ln,n,s_n,sn) static char s_n[]=sn;\
	SCM ln(w,b)SCM w,b;\
	{ASSERT(NIMP(w) && WINP(w),w,ARG1,sn);\
	return ERR==n(WIN(w),BOOL_F != b)?BOOL_F:BOOL_T;}

/* SUBROPT(lclearok,clearok,s_clearok,"clearok"); */
/* SUBROPT(lidlok,idlok,s_idlok,"idlok"); */
SUBROPT(lleaveok,leaveok,s_leaveok,"leaveok");
SUBROPT(lscrollok,scrollok,s_scrollok,"scrollok");
SUBROPT(lnodelay,nodelay,s_nodelay,"nodelay");

static char s_clearok[] = "clearok";
SCM lclearok(w,b) SCM w,b;
{
  if (BOOL_T==w) return ERR==clearok(curscr,BOOL_F != b)?BOOL_F:BOOL_T;
  ASSERT(NIMP(w) && WINP(w),w,ARG1,s_clearok);
  return ERR==clearok(WIN(w),BOOL_F != b)?BOOL_F:BOOL_T;
}

static iproc subr2s[] = {
	{s_overlay,loverlay},
	{s_overwrite,loverwrite},
	{s_wadd,lwadd},
	{s_winsert,lwinsert},
	{s_clearok,lclearok},
	/* {s_idlok,lidlok}, */
	{s_leaveok,lleaveok},
	{s_scrollok,lscrollok},
	{s_nodelay,lnodelay},
	{0,0}};

void init_crs()
{
  /*  savetty(); */
  /* "Stdscr" is a nearly inaccessible symbol used as a GC protect. */
  loc_stdscr = &CDR(sysintern("Stdscr", UNDEFINED));
  tc16_window = newptob(&winptob);

  init_iprocs(subr0s, tc7_subr_0);
  init_iprocs(subr1s, tc7_subr_1);
  init_iprocs(subr2s, tc7_subr_2);

  make_subr(s_owidth,tc7_subr_1o,owidth);
  make_subr(s_oheight,tc7_subr_1o,oheight);

  make_subr(s_newwin,tc7_lsubr_2,lnewwin);
  make_subr(s_subwin,tc7_lsubr_2,lsubwin);

  make_subr(s_wmove,tc7_subr_3,lwmove);
  make_subr(s_mvwin,tc7_subr_3,lmvwin);
  make_subr(s_box,tc7_subr_3,lbox);
  add_feature("curses");
  add_final(lendwin);
}
