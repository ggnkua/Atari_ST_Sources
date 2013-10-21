/*
 * XaAES - XaAES Ain't the AES (c) 1992 - 1998 C.Graham
 *                                 1999 - 2003 H.Robbers
 *
 * A multitasking AES replacement for MiNT
 *
 * This file is part of XaAES.
 *
 * XaAES is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * XaAES is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with XaAES; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <mintbind.h>
#include <ctype.h>			/* We use the version without macros!! */
#include <string.h>

#include "xa_types.h"
#include "xa_globl.h"

#include "xa_nkcc.h"
#include "xalloc.h"
#include "objects.h"
#include "c_window.h"
#include "rectlist.h"
#include "widgets.h"
#include "xa_form.h"
#include "xa_graf.h"
#include "xa_rsrc.h"
#include "xa_fsel.h"
#include "xa_clnt.h"
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
	XA_TREE menu;					/* HR */
	AESPB *pb;
	XA_CLIENT *owner;
	Path path;						/* HR */
	char fslash[2],
	     filter[NAME_MAX * 2],
	     file  [NAME_MAX + 2];		/* Is the tedindo->te_ptext of FS_FILE */
	long fcase,trunc;
	int drives;
	
} fs;

/*
static
XA_CLIENT *fsel_owner;
static
AESPB *fsel_pb;
*/

global
void init_fsel(void)
{
	int i;
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
	SCROLL_ENTRY *s;

	s = list->start;

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

int get_drv(char *p);    /* in xa_shell.c */

typedef bool sort_compare(SCROLL_ENTRY *s1, SCROLL_ENTRY *s2);

static
sort_compare dirflag_name
{
	G_u f1 = s1->flag&FLAG_DIR, f2 = s2->flag&FLAG_DIR;
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
	DIAG((D_fsel,nil,"inq_xfs '%s': case = %ld, trunc = %ld\n", p, c, t));
	if (dsep)
	{
		* dsep    = bslash;
		*(dsep+1) = 0;
	}
	return !(c eq 1 and t eq 2);
}

static
void add_slash(char *p)
{
	char *pl = p + strlen(p) - 1;

	if (*pl != slash and *pl != bslash)
		strcat(p, fs.fslash);
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

/*
 * Re-load a file_selector listbox
 * HR: version without the big overhead of separate dir/file lists
       and 2 quicksorts + the moving around of all that.
       Also no need for the Mintlib. (Mintbind only).
 */
static
void refresh_filelist(LOCK lock, int which)
{
	OBJECT *form = ResourceTree(C.Aes_rsc, FILE_SELECT);
	OBJECT *sl;
	SCROLL_INFO *list;
	char nm[NAME_MAX+2];
	int n = 0;
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

	DIAG((D_fsel,nil,"[%d]refresh_filelist: fs.path='%s',fs_pattern='%s'\n", which, fs.path, fs_pattern));

	free_scrollist(list);		/* Clear out current file list contents */

	graf_mouse(HOURGLASS, nil);

	i = Dopendir(fs.path,0);
DIAGS(("Dopendir -> %lx\n", i));
	if (i > 0)
	{
		XATTR xat;
		SCROLL_ENTRY *entry;

		while (Dxreaddir(NAME_MAX,i,nm,(long)&xat,&rep) eq 0)
		{
			char *nam = nm+4;
			bool dir = (xat.mode&0xf000) == S_IFDIR,
			     sln = (xat.mode&0xf000) == (G_u)S_IFLNK,
			     match = true;

			if (!csens)
				strupr(nam);
			if (sln) 
			{
				char fulln[NAME_MAX+2];
				strcpy(fulln,fs.path);
				strcat(fulln,nam);
DIAG((D_fsel,nil,"Symbolic link: Fxattr on '%s'\n",fulln));
				Fxattr(0,fulln,&xat);
				dir = (xat.mode&0xf000) == S_IFDIR;
DIAG((D_fsel,nil,"After Fxattr dir:%d\n",dir));
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
		{
			entry->n = ++n,
			entry = entry->next;
		}
	}

	DIAG((D_fsel,nil,"%d entries have been read\n", n));
	
	list->top = list->cur = list->start;
	list->n = n;
	graf_mouse(ARROW, nil);
	list->slider(list);
	if (!fs_prompt(list))
		display_toolbar(lock, fs.wind, FS_LIST);
}

#if FSEL_MENU
static
int fsel_drives(OBJECT *m, int drive)
{
	int drv = 0, drvs = 0,
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
	int d  = FSEL_PATA,
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
				int j = strlen(s);
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

/* HR: a little bit more exact. */
static
void fs_updir(XA_WINDOW *w)	/* Dont need form as long as everything is global 8-} */
{
	int drv;

	if (*fs.path)
	{
		int s = strlen(fs.path) - 1;
	
		if (fs.path[s] == slash or fs.path[s] == bslash)
			s--;
DIAG((D_fsel,nil,"fs_updir '%s'\n", fs.path));	
		while(   s
		      and fs.path[s] != ':'
			  and fs.path[s] != slash
			  and fs.path[s] != bslash)		/* HR check s */
			s--;
		if (fs.path[s] == ':')
			fs.path[++s] = *fs.fslash;
		fs.path[++s] = 0;
DIAG((D_fsel,nil,"   -->   '%s'\n", fs.path));	
	}

	if ((drv = get_drv(fs.path)) >= 0)
		strcpy(fs_paths[drv], fs.path);

	refresh_filelist(fsel,1);
}

static
scrl_widget fs_closer
{
	fs_updir(list->wi);
}

/* HR: flag now in SCROLL_ENTRY as well.
		removed dangerous pointer - 1 usage. */
static
scrl_click fs_dclick /* LOCK lock, OBJECT *form, int objc */
{
	OBJECT *ob = form + objc;
	SCROLL_INFO *list = ob->ob_spec.listbox;
	XA_WINDOW *wl = list->wi;

DIAG((D_fsel, nil, "fs_dclick %lx\n", list->cur));
	if (list->cur)
	{
		if ( (list->cur->flag&FLAG_DIR) == 0)
			strcpy(fs.file, list->cur->text);
		else
		{			
			if (strcmp(list->cur->text, "..") == 0)
			{
				fs_updir(wl);		/* cur on double dot line */
				return true;
			}

			if (strcmp(list->cur->text, ".") != 0)
			{
				int drv;
				add_slash(fs.path);
				strcat(fs.path, list->cur->text);
				if ((drv = get_drv(fs.path)) >= 0)
					strcpy(fs_paths[drv], fs.path);
				refresh_filelist(fsel,2);
				return true;
			}
		}
	}
DIAG((D_fsel, nil, "fs_dclick: %s%s\n", fs.path, fs.file));

	if (selected)
		(*selected)(lock, fs.path, fs.file);

	return true;
}

static
scrl_click fs_click /* LOCK lock, OBJECT *form, int objc */
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
		elif (strcmp(list->cur->text, ".") == 0)	/* HR 121102 */
		{
			*fs.file = 0;
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

	wt->current&=0xff; 		/* HR 300101: double click. */
	switch(wt->current)
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
			refresh_filelist(fsel,3);
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

		break;
	}
}

static
int find_drive(int a)
{
	XA_TREE *wt = get_widget(fs.wind, XAW_MENU)->stuff;
	OBJECT *m = wt->tree;
	int d = FSEL_DRVA;
	do
	{
		int x = tolower(*(m[d].ob_spec.string + 2));
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
WindowKeypress fs_key_handler /* LOCK lock, XA_WINDOW *wind, ushort keycode, ushort nkcode, KEY key */ /* HR */
{
	OBJECT *form = ResourceTree(C.Aes_rsc, FILE_SELECT),
	       *ob = form + FS_LIST;
	SCROLL_INFO *list = ob->ob_spec.listbox;

/* HR 310501: ctrl|alt + letter :: select drive */
	if ((key.raw.conin.state&(K_CTRL|K_ALT)) != 0)
	{
		G_u nk;
		if (nkcode == 0)
			nkcode = tolower(nkc_tconv(key.raw.bcon));
		nk = nkcode&0xff;
		if (   (nk >= 'a' and nk <= 'z')
		    or (nk >= '0' and nk <= '9')
		   )
		{
			nk = find_drive(nk);
			if (nk >= FSEL_DRVA)
				wind->send_message(lock, wind, nil,
							MN_SELECTED, 0, 0, FSEL_DRV,
							nk, 0, 0, 0);
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
		char old[NAME_MAX+2];
		strcpy(old, fs.file);
		if (handle_form_key(lock, wind, nil, keycode, nkcode, key))			/* HR 290501: if !discontinue */
			if (strcmp(old,fs.file) != 0)	/* something typed in there? */
				fs_prompt(list);
	}
	return true;
}

static
void fs_change(LOCK lock, OBJECT *m, int p, int title, int d, char *t)
{
	XA_WIDGET *widg = get_widget(fs.wind, XAW_MENU);
	int bx = d-1;
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
	switch (mp0)
	{
	case MN_SELECTED:
		if (mp3 == FSEL_FILTER)
			fs_change(lock, fs.menu.tree, mp4, FSEL_FILTER, FSEL_PATA, fs_pattern);
		else
		if (mp3 == FSEL_DRV)
		{
			int drv;
			fs_change(lock, fs.menu.tree, mp4, FSEL_DRV, FSEL_DRVA, fs.path);
			inq_xfs(fs.path, fs.fslash);
			add_slash(fs.path);
			drv = get_drv(fs.path);
			if (fs_paths[drv][0])
				strcpy(fs.path, fs_paths[drv]);
			else
				strcpy(fs_paths[drv], fs.path);
		}
		refresh_filelist(lock,4);
	break;
	case WM_MOVED:
		move_window(lock, fs.wind, -1, mp4, mp5, fs.wind->r.w, fs.wind->r.h);
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
	canceled = nil;				/* HR 121102 */

DIAG((D_fsel,nil,"fsel destructed\n"));
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

/* HR 060202: The file parameter (pb->addrin[1]) was never used. And I mean never at all.
              New parameter top open_fileselector: char *file */
global
void open_fileselector(LOCK lock, XA_CLIENT *client, char *path, char *file, char *title, fsel_handler *s, fsel_handler *c)
{
	int dh;			/* HR variable height for fileselector :-) */
	OBJECT *form = ResourceTree(C.Aes_rsc, FILE_SELECT);
	XA_WINDOW *dialog_window;
	XA_TREE *wt;
	char *pat,*pbt;
	static RECT remember = {0,0,0,0};

	DIAG((D_fsel,nil,"open_fileselector for %s on '%s', fn '%s', '%s', %lx,%lx)\n",
			c_owner(client), path, file, title, s, c));
	
	if (fs.wind)
	{
		DIAG((D_fsel,nil,"fsel undestructed\n"));
		return;
	}
	selected = s;
	canceled = c;

#ifdef FS_FILTER
	{
		TEDINFO *filter = (TEDINFO *)(form + FS_FILTER)->ob_spec;
		filter->te_ptext = fs.filter;
		filter->te_txtlen = NAME_MAX * 2;
	}
#endif
	
	if (file)
		if (*file)
		{
			strncpy(fs.file, file, sizeof(fs.file) - 1);
			*(fs.file + sizeof(fs.file) - 1) = 0;
		}

	DIAG((D_fsel,nil," -- fs.file '%s'\n", fs.file));

	(form + FS_FILE)->ob_spec.tedinfo->te_ptext = fs.file;

	form[FS_ICONS].ob_flags |= HIDETREE;			/* HR */

	dh = root_window->wa.h - 7*screen.c_max_h - form->r.h;
	form->r.h += dh;
	form[FS_LIST ].r.h += dh;
	form[FS_UNDER].r.y += dh;

/* Work out sizing */
	if (!remember.w)
	{
		center_form(form, 2*ICON_H);		/* HR */
		remember =
		calc_window(lock, client, WC_BORDER,
						XaMENU|NAME,
						MG,
						C.Aes->options.thinframe,
						C.Aes->options.thinwork,
						form->r);		/* HR */
	}

	strcpy(fs.path, path);

/* Strip out the pattern description */

	fs_pattern[0] = '*';
	fs_pattern[1] = '\0';
	pat = strrchr(fs.path, bslash);
	pbt = strrchr(fs.path, slash);
	if (!pat) pat = pbt;
	if (pat)
	{
		strcpy(fs_pattern, pat + 1);
		*(pat + 1) = 0;
		if (strcmp(fs_pattern, "*.*") == 0)
			*(fs_pattern + 1) = 0;
	}

	{
		int drv = get_drv(fs.path);
		if (drv >= 0)
			strcpy(fs_paths[drv], fs.path);
	}

#ifdef FSEL_MENU
	fs.menu.owner = C.Aes;
	fs.menu.tree = ResourceTree(C.Aes_rsc, FSEL_MENU);
	fs.drives =
	fsel_drives(fs.menu.tree,
				*(fs.path+1) == ':'
			  ? tolower(*fs.path) - 'a'
			  : Dgetdrv()
			  );
	fsel_filters(fs.menu.tree, fs_pattern);
#endif

/*	fs.file[0] = '\0';  HR 060202  not anymore */
	
/* Create the window */
	dialog_window = create_window
	                   (lock,
	                    fs_msg_handler,
						client,					/* HR */
						false,					/* HR */
						XaMENU|NAME|TOOLBAR|hide_move(&client->options),	/* HR */
						created_for_AES,		/* HR */
						MG,
						C.Aes->options.thinframe,
						C.Aes->options.thinwork,
						remember,
						nil,
						&remember);

/* Set the window title */
	get_widget(dialog_window, XAW_TITLE)->stuff = title;

#ifdef FSEL_MENU				/* HR: at last actually there */
/* Set the menu widget */				
	set_menu_widget(dialog_window, &fs.menu);
#endif

	wt = set_toolbar_widget(lock, dialog_window, form, FS_FILE);
	wt->zen = true;		/* This can be of use for drawing. (keep off border & outline :-) */
	wt->exit_form = XA_form_exit;		/* HR 250602 */
	wt->exit_handler = handle_fileselector;

/* HR: We need to do some specific things with the key's,
    so we supply our own handler, */
    dialog_window->keypress = fs_key_handler;

/* HR: set a scroll list object */
	set_slist_object(lock,
				wt,						/* HR 290702 */
				form,
				FS_LIST,
				fs_closer, nil,
				fs_dclick, fs_click,
				fs.path, nil, 30);

/* HR:  after set_menu_widget (fs_destructor must cover what is in menu_destructor())
    Set the window destructor */
	dialog_window->destructor = fs_destructor;

	strcpy(fs.filter, fs_pattern);
	fs.wind = dialog_window;
	open_window(lock, dialog_window, dialog_window->r);

	refresh_filelist(lock,5);		/* HR: after set_slist_object() & opwn_window */

	DIAG((D_fsel,nil,"done.\n"));
}

global
void close_fileselector(LOCK lock)		/* HR 121102 */
{
	close_window(lock, fs.wind);
	delete_window(lock, fs.wind);
}

static
fsel_handler handle_fsel  /* char *path, char *file */
{
	strcpy(fs.pb->addrin[0], path);
	strcpy((char *)fs.pb->addrin[1], file);

	DIAG((D_fsel,nil,"fsel OK:path=%s,file=%s\n", (char *)fs.pb->addrin[0], file));
	
	fs.pb->intout[0] = 1;
	fs.pb->intout[1] = 1;
	
	close_fileselector(lock);		/* HR 121102 */

	Unblock(fs.owner, XA_OK, 20);
}

static
fsel_handler cancel_fsel /* char *path, char *file */
{
	fs.pb->intout[0] = 1;
	fs.pb->intout[1] = 0;

	close_fileselector(lock);		/* HR 121102 */

	Unblock(fs.owner, XA_OK, 21);
}

/*
 *	File selector interface routines
 */
static
void do_fsel_exinput(LOCK lock, XA_CLIENT *client, AESPB *pb, char *text)
{
#if 0
/* Loads of programs lock the screen and the mouse before doing fsel_
   so we've got to unlock them again to allow the XaAES windowed file selector
   to work.

   HR: This seems a little bit dangerous, anyway the fileselector
       is controlled by handlers which bypass locking.
*/
	unlock_screen(client,10);

	if (S.mouse_lock == client->pid)
	{
		DIAG((D_fsel,nil,"fsel: mouse_lock: %d\n", client->pid));
		S.mouse_cnt = 0;
		S.mouse_lock = 0;
		Sema_Dn(MOUSE_LOCK);
	}
#endif
	DIAG((D_fsel,nil,"fsel_(ex)input:title=%s,path=%s,file=%s\n", text, (char *)pb->addrin[0], (char *)pb->addrin[1]));

#if 0
#include "obsolete/fix_path"
#endif	

	fs.owner = client;
	fs.pb = pb;
	
/* HR 060202: char *file */
	open_fileselector(lock|fsel, client, pb->addrin[0], pb->addrin[1], text, handle_fsel, cancel_fsel);
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
