/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <osbind.h>
#include <mintbind.h>
#include <stdlib.h>			/* free() */
#include "ctype.h"			/* We use the version without macros!! */
#include <string.h>

#include "xa_types.h"
#include "xa_globl.h"

#include "xa_nkcc.h"
#include "objects.h"
#include "c_window.h"
#include "rectlist.h"
#include RSCHNAME
#include "widgets.h"
#include "xa_form.h"
#include "xa_graf.h"
#include "xa_rsrc.h"
#include "xa_fsel.h"
#include "new_clnt.h"
#include "scrlobjc.h"	/* HR */
#include "menuwidg.h"	/* HR */
#include "matchpat.h"

/*
 *	FILE SELECTOR IMPLEMENTATION
 *	
 *	This give a non-modal windowed file selector for internal
 *	and exported use, with slightly extended pattern matching
 *	from the basic GEM spec.
 */

global
char fs_pattern[NAME_MAX * 2],
     fs_paths[DRV_MAX][NAME_MAX+2];

/* HR: (*)() */
fsel_handler *selected,
             *canceled;

static struct fsel_data				/* HR */
{
	XA_WINDOW *wind;
	XA_TREE menu;			/* HR */
	Path path;						/* HR */
	char fslash[2],
	     filter[NAME_MAX * 2],
	     file  [NAME_MAX];		/* Is the tedindo->te_ptext of FS_FILE */
	long fcase,trunc;
	short drives;
} fs;

global
void init_fsel(void)
{
	short i;
	for (i = 0; i < DRV_MAX; i++)
		fs_paths[i][0] = 0;
	memset(&fs,0,sizeof(fs));
	*fs.fslash = '\\';
}

/*
 *  find typed characters in the list
 */

/* This one didnt exist.
   It doesnt reinvent the wheel. :-)	*/
global
char *stristr(char *in, char *s)
{
	char *x, xs[32],xin[32];

	if (strlen(s) < 32 and strlen(in) < 32)
	{
		strcpy(xs,s),strlwr(xs),strcpy(xin,in),strlwr(xin);
		x = strstr(xin,xs);
		if (x)
			x = in + (xin-x);
	}
	else
		x =strstr(in, s);
	return x;
}

static
bool  fs_prompt(SCROLL_INFO *list)
{
	SCROLL_ENTRY *s = list->start;

	if (*fs.file and s)		/* Not if filename empty or list empty */
	{
		list->cur = nil;		/*     s1      <    s2   ==>   -1 */
		while (s->next and stricmp(s->text, fs.file) < 0)
			s = s->next;
		/* is the text completely at the beginning of a entry ? */
		if (stristr(s->text, fs.file) == s->text)
			list->cur = s;
		elif (s->flag&FLAG_DIR)
		{
			while(s->next and (s->flag&FLAG_DIR))
				s = s->next;
			while (s->next and stricmp(s->text, fs.file) < 0)
				s = s->next;
			if (stristr(s->text, fs.file) == s->text)
				list->cur = s;
		}
		list->vis(list,s);
		return true;
	}
	return false;
}

static
short get_drv(char *p)
{
	if (*(p+1) == ':')
	{
		short c = *p;
		if (c >= 'a' and c <= 'z')
			return c - 'a';
		if (c >= 'A' and c <= 'Z')
			return c - 'A';
		if (c >= '0' and c <= '9')
			return (c - '0') + ('z' - ('a' - 1));
	}
	return -1;
}

typedef bool sort_compare(SCROLL_ENTRY *s1, SCROLL_ENTRY *s2);

static
sort_compare dirflag_name
{
	short f1 = s1->flag&FLAG_DIR, f2 = s2->flag&FLAG_DIR;
	if (f1 < f2)		/* folders in front */
		return true;
	if (f1 == f2 and stricmp(s1->text, s2->text) > 0)
		return true;
	return false;
}

static
void sort_entry(SCROLL_INFO *list, SCROLL_ENTRY *new, sort_compare *greater)
{
/* temporary use of ->cur for sorting */
	if (list->start)
	{
		SCROLL_ENTRY *c = list->cur;
		if (greater(new, c))			/* new > c */
		{
			c = c->next;
			while (c)
			{
				if (greater(new, c))	/* while new < c */
					c = c->next;
				else					/* new < c */
				{
					new->next = c;		/* insert before c */
					new->prev = c->prev;
					c->prev->next = new;
					c->prev = new;
					break;
				}
			}
			if (!c)
			{							/* put at end */
				list->last->next = new;
				new->prev = list->last;
				list->last = new;
			}
		}
		else							/* new < c */
		{
			c = c->prev;
			while (c)
			{
				if (greater(c, new))	/* while new < c */
					c = c->prev;
				else					/* new > c */
				{
					new->next = c->next;	/* insert after c */
					new->prev =c;
					c->next->prev = new;
					c->next = new;
					break;
				}
			}
			if (!c)
			{							/* put in front */
				list->start->prev = new;
				new->next = list->start;
				list->start = new;
			}
		}
	}
	else
		list->start = list->last = new;
	list->cur = new;
}

static
bool inq_xfs(char *p, char *dsep)		/* yields true if case sensitive */
{
	long c,t;
	c = fs.fcase  = Dpathconf(p,DP_CASE);
	t = fs.trunc = Dpathconf(p,DP_TRUNC);
	DIAG((D.fsel,-1,"inq_xfs '%s': case = %ld, trunc = %ld\n", p, c, t));
	if (dsep)
	{
		* dsep    = bslash;
		*(dsep+1) = 0;
	}
	return !(c eq 1 and t eq 2);
}

static
bool executable(char *nam)
{
	char *ext = getsuf(nam);
	return
	   (   ext
					/* The mintlib does almost the same :-) */
		and (   !stricmp(ext, "ttp") or !stricmp(ext, "prg")
		     or !stricmp(ext, "tos") or !stricmp(ext, "g")
		     or !stricmp(ext, "sh")  or !stricmp(ext, "bat")
		     or !stricmp(ext, "gtp") or !stricmp(ext, "app")
		     or !stricmp(ext, "acc")
		    )
	   );
}

static
void add_slash(char *p)
{
	char *pl = p + strlen(p) - 1;

	if (*pl != slash and *pl != bslash)
		strcat(p, fs.fslash);
}

/*
 * Re-load a file_selector listbox
 * HR: version without the big overhead of separate dir/file lists
       and 2 quicksorts + the moving around of all that.
       Also no need for the Mintlib. (Mintbind only).
 */
static
void refresh_filelist(LOCK lock)
{
	enum
	{
		S_IFCHR = 0x2000,
		S_IFDIR = 0x4000,
		S_IFREG = 0x8000,
		S_IFIFO = 0xA000,
		S_IMEM  = 0xC000,
		S_IFLNK = 0xE000
	};

	struct XATTR
	{
	    unsigned short mode;
	    long index;
	    short dev;
	    short reserved1;
	    short nlink;
	    short uid;
	    short gid;
	    long size;
	    long blksize;
	    long nblocks;
	    short mtime;
	    short mdate;
	    short atime;
	    short adate;
	    short ctime;
	    short cdate;
	    unsigned short attr;
	    short reserved2;
	    long reserved3;
	    long reserved4;
	
	} xat;

	OBJECT *form = ResourceTree(C.Aes_rsc, FILE_SELECT);
	OBJECT *sl;
	SCROLL_INFO *list;
	char nm[NAME_MAX+2];
	short n = 0;
	long i,rep;
	bool csens;

	sl = form + FS_LIST;
	list = sl->ob_spec.listbox;
	add_slash(fs.path);
	csens = inq_xfs(fs.path, fs.fslash);

#ifdef FS_DBAR
	{
		TEDINFO *tx = ob_spec(form + FS_CASE);
		sdisplay(tx->te_ptext, "%ld", fs.fcase);
		         tx = ob_spec(form + FS_TRUNC);
		sdisplay(tx->te_ptext, "%ld", fs.trunc);
		display_toolbar(lock, fs.wind, FS_DBAR);
	}
#endif

	DIAG((D.fsel,-1,"refresh_filelist:fs.path='%s',fs_pattern='%s'\n", fs.path, fs_pattern));

	free_scrollist(list);		/* Clear out current file list contents */

	graf_mouse(HOURGLASS, nil);

	i = Dopendir(fs.path,0);
	if (i > 0)
	{
		SCROLL_ENTRY *entry;

		while (Dxreaddir(NAME_MAX,i,nm,(long)&xat,&rep) eq 0)
		{
			char *nam = nm+4;
			bool dir = (xat.mode&0xf000) == S_IFDIR,
			     sln = (xat.mode&0xf000) == S_IFLNK,
			     match = true;

			if (!csens)
				strupr(nam);
			if (sln) 
			{
				char fulln[NAME_MAX+2];
				strcpy(fulln,fs.path);
				strcat(fulln,nam);
DIAG((D.fsel,-1,"Symbolic link: Fxattr on '%s'\n",fulln));
				Fxattr(0,fulln,&xat);
				dir = (xat.mode&0xf000) == S_IFDIR;
DIAG((D.fsel,-1,"After Fxattr dir:%d\n",dir));
			}
			if (!dir)
				match = match_pattern(nam, fs_pattern);
			if (match)
			{
				OBJECT *icon = nil;
				entry = xcalloc(1,sizeof(SCROLL_ENTRY) + strlen(nam) + 2, 106);
				entry->text = entry->the_text;
				strcpy(entry->text, nam);
				if (sln)
					entry->flag |= FLAG_LINK;
				if (dir)
				{
					icon = form + FS_ICN_DIR;
					entry->flag |= FLAG_DIR;		/* text part of the entry, so FLAG_MAL is off */
				}
				else if (executable(nam))
					icon = form + FS_ICN_EXE;
				if (icon)
					icon->r.x = icon->r.y = 0;
				entry->icon = icon;
				sort_entry(list, entry, dirflag_name);
			}
		}
		Dclosedir(i);
		list->cur = nil;
		entry = list->start;
		while (entry)
			entry->n = ++n,
			entry = entry->next;
	}

	DIAG((D.fsel,-1,"entries have been read\n"));
	
	list->top = list->cur = list->start;
	list->n = n;
	graf_mouse(ARROW, nil);
	list->slider(list);
	if (!fs_prompt(list))
		display_toolbar(lock, fs.wind, FS_LIST);
}

#if FSEL_MENU
static
short fsel_drives(OBJECT *m, short drive)
{
	unsigned long sma;
	short drv = 0, drvs = 0,
	      d = FSEL_DRVA;
	unsigned long dmap = Drvmap();

	while(dmap)
	{
		if (dmap&1)
		{
			m[d].ob_state&=~CHECKED;
			if (drv == drive)
				m[d].ob_state|=CHECKED;
			sdisplay(m[d++].ob_spec.string,"  %c:",drv + 'A');
			drvs++;
		}
		dmap >>= 1;
		drv++;
	}

	if (drvs&1)
		m[d-1].r.w = m[FSEL_DRVBOX].r.w;

	do
	{
		m[d].ob_flags|=HIDETREE;
		*(m[d].ob_spec.string + 2) = '~';		/* HR 310501: prevent finding those. */
	}
	while (m[d++].ob_next != FSEL_DRVBOX);
	m[FSEL_DRVBOX].r.h = ((drvs+1)/2) * screen.c_max_h;
	sdisplay(m[FSEL_DRV].ob_spec.string," %c:", drive + 'A');
	return drvs;
}

static
void fsel_filters(OBJECT *m, char *pattern)
{
	char p[16];
	short d  = FSEL_PATA,
	      i = 0;
	if (cfg.Filters[0][0])
	{
		while (i < 23 and cfg.Filters[i][0])
		{
			cfg.Filters[i][15] = 0;
			m[d].ob_state&=~CHECKED;
			if (stricmp(pattern,cfg.Filters[i]) == 0)
				m[d].ob_state|=CHECKED;
			sdisplay(m[d++].ob_spec.string,"  %s",cfg.Filters[i++]);
		}
	
		do
			m[d].ob_flags|=HIDETREE;
		while (m[d++].ob_next != FSEL_PATBOX);
		m[FSEL_PATBOX].r.h = i * screen.c_max_h;
	} else
	{
		while (i < 23)
		{
			char *s = m[d].ob_spec.string;
			if (strstr(s+2,"**") == s+2)		/* check for place holder entry */
				*(s+3) = 0;						/* Keep the 1 '*' */
			else
			{
				short j = strlen(s);
				while (*(s+ --j) == ' ')
					*(s+j) = 0;
			}
			m[d].ob_state&=~CHECKED;
			if (stricmp(pattern,s) == 0)
				m[d].ob_state|=CHECKED;
			d++, i++;
		}
	}
	strncpy(p,pattern,15);
	p[15] = 0;
	sdisplay(m[FSEL_FILTER].ob_spec.string," %s", p);
}
#endif

static char null_file[] = "NONAME.XXX";

/* HR: a little bit more exact. */
static
void fs_updir(XA_WINDOW *w)	/* Dont need form as long as everything is global 8-} */
{
	short drv;

	if (*fs.path)
	{
		short s = strlen(fs.path) - 1;
	
		if (fs.path[s] == slash or fs.path[s] == bslash)
			s--;
DIAG((D.fsel,-1,"fs_updir '%s'\n", fs.path));	
		while(   s
		      and fs.path[s] != ':'
			  and fs.path[s] != slash
			  and fs.path[s] != bslash)		/* HR check s */
			s--;
		if (fs.path[s] == ':')
			fs.path[++s] = *fs.fslash;
		fs.path[++s] = 0;
DIAG((D.fsel,-1,"   -->   '%s'\n", fs.path));	
	}

	if ((drv = get_drv(fs.path)) >= 0)
		strcpy(fs_paths[drv], fs.path);

	refresh_filelist(fsel);
}

static
scrl_widget fs_closer
{
	fs_updir(list->wi);
}

/* HR: flag now in SCROLL_ENTRY as well.
		removed dangerous pointer - 1 usage. */
static
scrl_click fs_dclick /* LOCK lock, OBJECT *form, short objc */
{
	OBJECT *ob = form + objc;
	SCROLL_INFO *list = ob->ob_spec.listbox;
	XA_WINDOW *wl = list->wi;

DIAG((D.fsel, -1, "fs_dclick %lx\n", list->cur));
	if (list->cur)
	{
		if ( (list->cur->flag&FLAG_DIR) == 0)
			strcpy(fs.file, list->cur->text);
		else
		{			
			if (list->cur->text[0] != '.')	/* real directory name */
			{
				short drv;
				add_slash(fs.path);
				strcat(fs.path, list->cur->text);
				if ((drv = get_drv(fs.path)) >= 0)
					strcpy(fs_paths[drv], fs.path);
				refresh_filelist(fsel);
				return true;
			}

			if (list->cur->text[1] == '.')
			{
				fs_updir(wl);		/* cur on double dot line */
				return true;
			}

			/* *fs.file = 0;	*/		/* cur on single dot line :: return path only */
		}
	}
DIAG((D.fsel, -1, "fs_dclick: %s%s\n", fs.path, fs.file));
	if (selected)
		(*selected)(lock, fs.path, fs.file);

	close_window(lock, fs.wind);
	delete_window(lock, fs.wind);
	return true;
}

static
scrl_click fs_click /* LOCK lock, OBJECT *form, short objc */
{
	SCROLL_INFO *list;
	OBJECT *ob = form + objc;
		
	list = ob->ob_spec.listbox;
	
	if (list->cur)
	{
		if ( ! (list->cur->flag&FLAG_DIR))
		{
			strcpy(fs.file, list->cur->text);
			display_toolbar(lock, fs.wind, FS_FILE);
		}
		else
			fs_dclick(lock, form, objc);		/* HR */
	}

	return true;
}			

/* HR 300101: double click now also available for internal handlers. */
static
ObjectHandler handle_fileselector /* (LOCK lock, XA_TREE *odc_p) */		/* The ''form_do'' part */
{
#ifdef FS_FILTER
	OBJECT *ob = odc_p->tree + FS_LIST;
	SCROLL_INFO *list = ob->ob_spec;
	TEDINFO *filter = (TEDINFO *)(odc_p->tree + FS_FILTER)->ob_spec;
#endif
#ifdef FS_UPDIR
	XA_WINDOW *wl = list->wi;
#endif

/*	if (wt->item < 0)
		wt->item = FS_OK;
*/	wt->item&=0xff; 		/* HR 300101: double click. */
	switch(wt->item)
	{
#ifdef FS_UPDIR
	case FS_UPDIR:			/* Go up a level in the filesystem */
		fs_updir(wl);		/* HR */
		break;
#endif
	case FS_OK:							/* Accept current selection - do the same as a double click */
		deselect(wt->tree, FS_OK);
		display_toolbar(lock, fs.wind, FS_OK);
#ifdef FS_FILTER
		if (strcmp(filter->te_ptext, fs_pattern) != 0)
		{
			strcpy(fs_pattern, filter->te_ptext);			/* changed filter */
			refresh_filelist(fsel);
		}
		else
#endif
			fs_dclick(lock, wt->tree, FS_LIST);
		break;
	case FS_CANCEL:					/* Cancel this selector */
		deselect(wt->tree, FS_CANCEL);
		display_toolbar(lock, fs.wind, FS_CANCEL);
		if (canceled)
			(*canceled)(lock, fs.path, "");

		close_window(lock, fs.wind);
		delete_window(lock, fs.wind);
		break;
	}
}

static
short find_drive(short a)
{
	XA_TREE *wt = fs.wind->widgets[XAW_MENU].stuff;
	OBJECT *m = wt->tree;
	short d = FSEL_DRVA;
	do
	{
		short x = tolower(*(m[d].ob_spec.string + 2));
		if (x == '~')
			break;
		if (x == a)
			return d;
	}
	while (m[d++].ob_next != FSEL_DRVA-1);
	Bconout(2,7);		/* ping */
	return -1;
}

static
WindowKeypress fs_key_handler /* LOCK lock, XA_WINDOW *wind, ushort keycode, ushort nkcode, CONKEY raw */ /* HR */
{
	OBJECT *form = ResourceTree(C.Aes_rsc, FILE_SELECT),
	       *ob = form + FS_LIST;
	SCROLL_INFO *list = ob->ob_spec.listbox;

/* HR 310501: ctrl|alt + letter :: select drive */
	if ((raw.conin.state&(K_CTRL|K_ALT)) != 0)
	{
		short nk;
		if (nkcode == 0)
			nkcode = tolower(nkc_tconv(raw.bcon));
		nk = nkcode&0xff;
		if (   (nk >= 'a' and nk <= 'z')
		    or (nk >= '0' and nk <= '9')
		   )
		{
			nk = find_drive(nk);
			if (nk >= FSEL_DRVA)
				wind->send_message(lock, wind, wind->pid, MN_SELECTED, C.AESpid, FSEL_DRV, nk, 0, 0, 0);
		}
	} else
/*  If anything in the list and it is a cursor key */
	if (list->n and scrl_cursor(list, keycode) != -1)
	{
		if ( ! (list->cur->flag&FLAG_DIR))
		{
			strcpy(fs.file, list->cur->text);
			display_toolbar(lock, fs.wind, FS_FILE);
		}
	} else
	{
		char old[NAME_MAX];
		strcpy(old, fs.file);
		if (handle_form_key(lock, wind, keycode, nkcode, raw))			/* HR 290501: if !discontinue */
			if (strcmp(old,fs.file) != 0)	/* something typed in there? */
				fs_prompt(list);
	}
	return true;
}

static
void fs_change(LOCK lock, OBJECT *m, short p, short title, short d, char *t)
{
	XA_WIDGET *widg = fs.wind->widgets + XAW_MENU;
	short bx = d-1;
	do
		m[d].ob_state&=~CHECKED;
	while (m[d++].ob_next != bx);
	m[p].ob_state|=CHECKED;
	sdisplay(m[title].ob_spec.string," %s", m[p].ob_spec.string + 2);
	widg->start = 0;
	display_widget(lock, fs.wind, widg);
	strcpy(t, m[p].ob_spec.string + 2);
}

/* HR: make a start */
/* dest_pid, msg, source_pid, mp3, mp4,  ....    */
static
SendMessage fs_msg_handler		/* Here go the menu stuff */
{
	short drv;
	switch (msg)
	{
	case MN_SELECTED:
		if (mp3 == FSEL_FILTER)
			fs_change(lock, fs.menu.tree, mp4, FSEL_FILTER, FSEL_PATA, fs_pattern);
		else
		if (mp3 == FSEL_DRV)
		{
			short drv;
			fs_change(lock, fs.menu.tree, mp4, FSEL_DRV, FSEL_DRVA, fs.path);
			inq_xfs(fs.path, fs.fslash);
			add_slash(fs.path);
			drv = get_drv(fs.path);
			if (fs_paths[drv][0])
				strcpy(fs.path, fs_paths[drv]);
			else
				strcpy(fs_paths[drv], fs.path);
		}
		refresh_filelist(lock);
	}
}

static
WindowDisplay fs_destructor /* LOCK lock, XA_WINDOW *wind)	*/	/* Called by delete_window() */
{
	OBJECT *form = ResourceTree(C.Aes_rsc, FILE_SELECT);
	OBJECT *sl;
	SCROLL_INFO *list;

	sl = form + FS_LIST;
	list = sl->ob_spec.listbox;

	delete_window(lock, list->wi);

	free_scrollist(list);

	fs.wind = nil;
	selected = nil;

DIAG((D.fsel,-1,"fsel destructed\n"));
	return true;
}

/* HR: (*)()    *s,*c */
/* HR The use of the word 'Callback' is entirely nonsense of course.
   Nothing is 'called back'. Calling is forward, be it indirect.
   'calling back' could eventually be the case in recursions, but
   that is a entirely different story.
   Or when a pointer to structure is used to call back from the OS to a
   application like 'progdefs' then you could use the word 'Callback'.
   But everyone knows by now that such a thing should have been forbidden
   in the first place.

   Moreover, the word is annoyingly superfluous. The fact that its a pointer to
   a function tells enough.
   Note that both '*' and 'Callback' appeared in the same typedefed declaration.

   The typedef name doesnt need to be specific on it's usage, but when it is
   used with a '*', you know that its usage is indirect.
   
   In XaAES the pointer to a function is a simple switching device.
   Nothing more.

   So: first I removed the '*' from the typedef. This makes the name more widely usable.
   	   then I removed 'Callback' from the name.
old:
void open_fsel(LOCK lock, char *path, char *title, FileSelectedCallback *s, FileSelectedCallback *c)

The bad work of the ANSI committee still remains extremely annoying!!!
"void open_fsel(LOCK lock; char *path, *title; fsel_handler *s, *c;)"  should have been good enough.
This makes a parameterlist syntactically the same as a structure; semantically they're always
have been the same of course.
From the point of view of a procedure, the parameter list is a volatile struct
describing the local memory where the parameters are found. 
*/

global
void open_fileselector(LOCK lock, short pid, char *path, char *title, fsel_handler *s, fsel_handler *c)
{
	short dh;			/* HR variable height for fileselector :-) */
	OBJECT *form = ResourceTree(C.Aes_rsc, FILE_SELECT);
	TEDINFO *filter;
	XA_WINDOW *dialog_window;
	XA_TREE *wt;
	char *pat,*pbt;
	static RECT remember = {0,0,0,0};

	DIAG((D.fsel,-1,"open_fileselector for %d(%s,%s,%lx,%lx)\n", pid, path, title, s, c));
	
	if (fs.wind)
	{
		DIAG((D.fsel,-1,"fsel undestructed\n"));
		return;
	}
	selected = s;
	canceled = c;

#ifdef FS_FILTER
	filter = (TEDINFO *)(form + FS_FILTER)->ob_spec;
	filter->te_ptext = fs.filter;
	filter->te_txtlen = NAME_MAX * 2;
#endif

	(form + FS_FILE)->ob_spec.tedinfo->te_ptext = fs.file;

	form[FS_ICONS].ob_flags |= HIDETREE;			/* HR */

	dh = root_window->wa.h - 7*screen.c_max_h - form->r.h;
	form->r.h += dh;
	form[FS_LIST ].r.h += dh;
	form[FS_UNDER].r.y += dh;

/* Work out sizing */
	if (!remember.w)
		center_form(form, 2*ICON_H),		/* HR */
		calc_window(pid, WC_BORDER, XaMENU|NAME, &form->r, &remember);		/* HR */

	strcpy(fs.path, path);

/* Strip out the pattern description */

	pat = strrchr(fs.path, bslash);
	pbt = strrchr(fs.path, slash);
	if (!pat) pat = pbt;
	if (pat)
	{
		strcpy(fs_pattern, pat + 1);
		*(pat + 1) = 0;
	}
	else
	{
		fs_pattern[0] = '*';
		fs_pattern[1] = '\0';
	}

	{
		short drv = get_drv(fs.path);
		if (drv >= 0)
			strcpy(fs_paths[drv], fs.path);
	}

#ifdef FSEL_MENU
	fs.menu.tree = ResourceTree(C.Aes_rsc, FSEL_MENU);
	fs.drives =
	fsel_drives(fs.menu.tree,
				*(fs.path+1) == ':'
			  ? tolower(*fs.path) - 'a'
			  : Dgetdrv()
			  );
	fsel_filters(fs.menu.tree, fs_pattern);
#endif

	fs.file[0] = '\0';
	
/* Create the window */
	dialog_window = create_window(lock, fs_msg_handler,
							pid,					/* HR */
							false,					/* HR */
							XaMENU|					/* HR */
							NAME|
							MOVE|
							NO_MESSAGES|NO_WORK,
							MG,
							remember,
							nil,
							&remember);

/* Set the window title */
	dialog_window->widgets[XAW_TITLE].stuff = title;

#ifdef FSEL_MENU				/* HR: at last actually there */
/* Set the menu widget */				
	fs.menu.pid = C.AESpid;
	set_menu_widget(dialog_window, &fs.menu);
#endif

	wt = set_toolbar_widget(lock, dialog_window, form, FS_FILE);
	wt->pid = C.AESpid;
	wt->handler = handle_fileselector;

/* HR: We need to do some specific things with the key's,
    so we supply our own handler, */
    dialog_window->keypress = fs_key_handler;

/* HR: set a scroll list object */
	set_slist_widget(lock, C.AESpid,
				dialog_window, form, FS_LIST,
				fs_closer, nil,
				fs_dclick, fs_click,
				fs.path, nil, 30);

/* HR:  after set_menu_widget (fs_destructor must cover what is in menu_destructor())
    Set the window destructor */
	dialog_window->destructor = fs_destructor;

	strcpy(fs.filter, fs_pattern);
	fs.wind = dialog_window;
	open_window(lock, pid, dialog_window->handle, dialog_window->r);

	refresh_filelist(lock);		/* HR: after set_slist_widget() & opwn_window */

	DIAG((D.fsel,-1,"done.\n"));
}

static
XA_CLIENT *fsel_owner;
static
AESPB *fsel_pb;

static
fsel_handler handle_fsel  /* char *path, char *file */
{
	strcpy(fsel_pb->addrin[0], path);
	strcpy((char *)fsel_pb->addrin[1], file);

	DIAG((D.fsel,-1,"fsel OK:path=%s,file=%s\n", (char *)fsel_pb->addrin[0], file));
	
	fsel_pb->intout[0] = 1;
	fsel_pb->intout[1] = 1;
	
	Unblock(fsel_owner, XA_OK, 10);
}

fsel_handler cancel_fsel /* char *path, char *file */
{
	fsel_pb->intout[0] = 1;
	fsel_pb->intout[1] = 0;

	Unblock(fsel_owner, XA_OK, 11);
}

/*
 *	File selector interface routines
 */
static
void do_fsel_exinput(LOCK lock, XA_CLIENT *client, AESPB *pb, char *text)
{
	unsigned long dummy_rtn;

/* Loads of programs lock the screen and the mouse before doing fsel_
   so we've got to unlock them again to allow the XaAES windowed file selector
   to work.

   HR: This seems a little bit dangerous, anyway the fileselector
       is controlled by handlers which bypass locking.

	unlock_screen(client->pid);

	if (S.mouse_lock == client->pid)
	{
		DIAG((D.fsel,-1,"fsel: mouse_lock: %d\n", client->pid));
		S.mouse_cnt = 0;
		S.mouse_lock = 0;
		Sema_Dn(MOUSE_LOCK);
	}
*/
	DIAG((D.fsel,-1,"fsel_(ex)input:title=%s,path=%s,file=%s\n", text, (char *)pb->addrin[0], (char *)pb->addrin[1]));

#if 0
#include "obsolete/fix_path"
#endif	

	fsel_owner = client;
	fsel_pb = pb;

	open_fileselector(lock|fsel, client->pid, (char *)pb->addrin[0], text, handle_fsel, cancel_fsel);
}

global
AES_function XA_fsel_input	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	CONTROL(0,2,2)

	do_fsel_exinput(lock, client, pb, "");

	return XAC_BLOCK;
}

global
AES_function XA_fsel_exinput	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	char *t = (char *)pb->addrin[2];		/* HR */

	CONTROL(0,2,3)

	if (pb->contrl[3] <= 2 or t == nil)
		t = "";
	do_fsel_exinput(lock, client, pb, t);

	return XAC_BLOCK;
}
