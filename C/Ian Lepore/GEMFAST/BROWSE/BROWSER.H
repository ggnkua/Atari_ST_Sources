#ifndef BROWSER_H

#ifndef GEMFAST_H
  #include <gemfast.h>
#endif

#ifndef DLLUTIL_H
  #include "dllutil.h"
#endif

typedef struct browse_line {
	DllHeader	hdr;
	char		*string;
	short		length;
} BrowseLine;

typedef struct browser {
	DllHeader	hdr;
	void		*userdata;
	long		userflags;
	int 		(*useraction)();
	DlList		linelist;
	long		num_lines;
	char		*title;
	short		whandle;
#ifdef BROWSER_INTERNALS		// clients can't touch (or even see) these...
	short		wchar;
	short		hchar;
	short		longest_line;
	long		curline_num;
	short		leftcol_num;
	short		rows_in_window;
	short		cols_in_window;
	GRECT		workrect;
#endif
} Browser;

#define BR_PREDELETE	1001
#define BR_KEYSTROKE	1002
#define BR_SEARCHSTR	1003

#if __STDC__

  extern void		  *br_malloc(unsigned size);
  extern void		  br_free(void *block);

  extern void		  br_update(Browser *b, int repaint);
  extern Browser	  *br_handle(int window_id);
  extern void		  br_action(Browser *b, int action, long lparm);
  extern int		  __br_action(Browser *b, int action, long lparm);
  extern char		  *br_title(Browser *b, char *newtitle);
  extern void		  br_event(XMULTI *xm);
  extern void		  br_delete(Browser *b);
  extern void		  br_shutdown(void);
  extern Browser	  *br_create(char *title, DlList *lines, GRECT *openrect);

  extern BrowseLine   *brl_add(DlList *lines, char *newline);
  extern BrowseLine   *br_ladd(Browser *b, char *newline);
  extern void		  brl_delete(DlList *lines, void *line);
  extern void		  br_ldelete(Browser *b, BrowseLine *line);
  extern void		  br_recount(Browser *b);

  extern int		  brf_load(char *filename, DlList *linelist);
  extern Browser	  *br_file(char *filename);

#else

  extern void		  *br_malloc();   /* in brmalloc.c */
  extern void		  br_free();

  extern Browser	  *br_create();   /* in brevent.c */
  extern void		  br_shutdown();
  extern void		  br_action();
  extern int		  __br_action();
  extern char		  *br_title();
  extern void		  br_update();
  extern void		  br_delete();
  extern void		  br_event();
  extern Browser	  *br_handle();

  extern BrowseLine   *brl_add();	  /* in brllist.c */
  extern BrowseLine   *br_ladd();
  extern void		  brl_delete();
  extern void		  br_ldelete();
  extern void		  br_recount();

  extern int		  brf_load();	  /* in brfile.c */
  extern Browser	  *br_file();

#endif

extern short br_errno;

#endif /* BROWSER_H */

