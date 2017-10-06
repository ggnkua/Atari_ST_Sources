/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <osbind.h>
#include <mintbind.h>
#include <signal.h>
#include <fcntl.h>
#include <ioctl.h>
#include <stdio.h>
#include <unistd.h>			/* getcwd() */
#include <stdlib.h>			/* free() */
#include <ctype.h>
#include <string.h>
#include <limits.h>			/* PATH/NAME_MAX */
#include "entries.h"			/* Directory entry stuff */
#include "xa_types.h"
#include "xa_codes.h"
#include "xa_defs.h"
#include "xa_globl.h"
#include "objects.h"
#include "c_window.h"
#include "rectlist.h"
#include RSCHNAME
#include "k_defs.h"
#include "widgets.h"
#include "xa_form.h"
#include "xa_graf.h"
#include "xa_rsrc.h"
#include "xa_fsel.h"
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

short fs_destructor(XA_WINDOW *wind);

XA_WINDOW *fs_open = NULL;
/* HR: (*)() */
fsel_handler *selected = NULL,
             *canceled = NULL,
             fs_unix;

char fs_path[PATH_MAX],
     fs_slash[2],
     fs_pattern[NAME_MAX * 2],
     fs_internal_filter[NAME_MAX * 2],
     fs_internal_file[NAME_MAX];		/* Is the tedindo->te_ptext of FS_FILE */
XA_WIDGET_TREE fs_menu = {0};					/* HR */

/*
 *  find typed characters in the list
 */

/* This one doesnt seem to exist.
   It doesnt reinvent the wheel. :-)	*/
char *stristr(char *in, char *s)
{
	char *x, xs[32],xin[32];

	if (strlen(s) < 32 && strlen(in) < 32)
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
void fs_prompt(SCROLL_INFO *list)
{
	SCROLL_ENTRY *s = list->start;

	if (*fs_internal_file && s)		/* Not if filename empty or list empty */
	{
		list->cur = NULL;		/*     s1      <    s2   ==>   -1 */
		while (s->next && stricmp(s->text, fs_internal_file) < 0)
			s = s->next;
		/* is the text completely at the beginning of a entry ? */
		if (stristr(s->text, fs_internal_file) == s->text)
			list->cur = s;
		elif (s->flag)
		{
			while(s->next && s->flag)
				s = s->next;
			while (s->next && stricmp(s->text, fs_internal_file) < 0)
				s = s->next;
			if (stristr(s->text, fs_internal_file) == s->text)
				list->cur = s;
		}
		scrl_visible(list,s);
	}
}

void free_list(SCROLL_INFO *list)
{
	while (list->start)
	{
		SCROLL_ENTRY *next = list->start->next;
		free(list->start);
		list->start = next;
	}
	list->start = list->cur = list->top = list->last = NULL;
}

#if !POSIX_ENTRIES
char fs_paths[DRV_MAX][NAME_MAX+2];
#endif

void init_fsel(void)
{
#if !POSIX_ENTRIES
	short i;
	for (i = 0; i < DRV_MAX; i++)
		fs_paths[i][0] = 0;
#else
	OBJECT *form = ResourceTree(system_resources, FILE_SELECT);
	form[FS_UNIX].ob_flags |= HIDETREE;
	form[FS_OK].ob_spec = "  OK  ";
#endif
}

short get_drv(char *p)
{
	if (*(p+1) == ':')
	{
		short c = *p;
		if (c >= 'a' && c <= 'z')
			return c - 'a';
		if (c >= 'A' && c <= 'Z')
			return c - 'A';
		if (c >= '0' && c <= '9')
			return (c - '0') + ('z' - ('a' - 1));
	}
	return -1;
}

#if !POSIX_ENTRIES
typedef bool sort_compare(SCROLL_ENTRY *s1, SCROLL_ENTRY *s2);

sort_compare dirflag_name
{
	if (s1->flag < s2->flag)		/* folders(#1) in front */
		return true;
	if (s1->flag == s2->flag && stricmp(s1->text, s2->text) > 0)
		return true;
	return false;
}

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

bool inq_xfs(char *p, char *dsep)		/* yields true if case sensitive */
{
	long c,t;
	c = Dpathconf(p,DP_CASE);
	t = Dpathconf(p,DP_TRUNC);
	DIAG((D.fsel,-1,"inq_xfs '%s': case = %ld, trunc = %ld\n", p, c, t));
#if 0
	* dsep    = c eq DP_SENITIVE ? slash : back_slash;
#else
	* dsep    = back_slash;
#endif
	*(dsep+1) = 0;
	return !(c == 1 && t == 2);
}

char *getsuf(char *f, char sep)
{
	char *p;
	
	if ((p = strrchr(f, '.')) != 0L)
		if ( strchr(p,sep) == 0L)		/* didnt ran over slash? */
			return p+1;
	return 0L;					/* geen  */
}

bool executable(char *nam)
{
	char *ext = getsuf(nam, *fs_slash);
	return
	   (   ext
					/* The mintlib does almost the same :-) */
		&& (   !stricmp(ext, "ttp") || !stricmp(ext, "prg")
		    || !stricmp(ext, "tos") || !stricmp(ext, "g")
		    || !stricmp(ext, "sh")  || !stricmp(ext, "bat")
		    || !stricmp(ext, "gtp") || !stricmp(ext, "app")
		   )
	   );
}

/*
 * Re-load a file list object
 * HR: version without the big overhead of separate dir/file lists
       and 2 quicksorts + the moving around of all that.
       Not needing the Mintlib as well. (Mintbind only).
 */
static
void refresh_filelist(void)
{
	OBJECT *form = ResourceTree(system_resources, FILE_SELECT);
	OBJECT *sl, *temp;
	SCROLL_INFO *list;
	char nm[NAME_MAX+2],
	     *ext;
	short n = 0;
	long i;
	bool csens;

	DIAG((D.fsel,-1,"refresh_filelist:fs_path='%s',fs_pattern='%s'\n", fs_path, fs_pattern));

	sl = form + FS_LIST;
	list = (SCROLL_INFO *)sl->ob_spec;

	csens = inq_xfs(fs_path, fs_slash);

	if (*(fs_path + strlen(fs_path) - 1) != *fs_slash)
		strcat(fs_path, fs_slash);

	free_list(list);		/* Clear out current file list contents */

	graf_mouse(HOURGLASS, NULL);

	temp = form + FS_ICN_DIR;
	temp->r.x = temp->r.y = 0;
	temp->ob_flags |= HIDETREE;
	temp = form + FS_ICN_EXE;
	temp->r.x = temp->r.y = 0;
	temp->ob_flags |= HIDETREE;

	i = Dopendir(fs_path,0);
	if (i > 0)
	{
		SCROLL_ENTRY *entry;
		while (Dreaddir(NAME_MAX,i,nm) eq 0)
		{
			bool dir, match = true;
			char fulln[NAME_MAX+2];
			char *nam = nm+4;

			strcpy(fulln,fs_path);
			strcat(fulln,fs_slash);
			if (!csens)
				strupr(nam);
			strcat(fulln,nam);
			dir = (Fattrib(fulln,0,0)&FA_DIR) ne 0;
			if (!dir)
				match = match_pattern(nam, fs_pattern);
			if (match)
			{
				entry = calloc(1,sizeof(SCROLL_ENTRY) + strlen(nam) + 2);
				entry->text = entry->the_text;
				strcpy(entry->text, nam);
				if (dir)
				{
					entry->icon = form + FS_ICN_DIR;
					entry->flag = FLAG_DIR;
				}
				else if (executable(nam))
					entry->icon = form + FS_ICN_EXE;
				sort_entry(list, entry, dirflag_name);
			}
		}
		Dclosedir(i);
		list->cur = NULL;
		entry = list->start;
		while (entry)
			entry->n = ++n,
			entry = entry->next;
	}

	DIAG((D.fsel,-1,"entries have been read\n"));
	
	list->top = list->cur = list->start;
	list->n = n;
	graf_mouse(ARROW, NULL);
	list->slider(list);
	v_hide_c(V_handle);
	draw_object_tree(form, FS_LIST, 1);
	v_show_c(V_handle, 1);
	fs_prompt(list);							/* HR */
}

#else

static
void refresh_filelist(void)
{
	Lists *lists;
	char **dirs, **files;
	OBJECT *form = ResourceTree(system_resources, FILE_SELECT);
	OBJECT *sl, *temp;
	SCROLL_INFO *list;
	SCROLL_ENTRY *entry;
	short n = 0;						/* HR */
	DIAG((D.fsel,-1,"refresh_filelist:fs_path='%s',fs_pattern='%s'\n", fs_path, fs_pattern));
	sl = form + FS_LIST;
	list = (SCROLL_INFO *)sl->ob_spec;

	if (fs_open)			/* Clear out current file list contents */
	{
		free(list->start);
		free_entries();
	}

	graf_mouse(HOURGLASS, NULL);
	
	read_entries(fs_path);		/* Read new directory */

	DIAG((D.fsel,-1,"entries have been read\n"));

	if((lists = sort_entries(fs_pattern)) == 0)	/* Sort directory */
	{
		graf_mouse(ARROW, NULL);
		return;
	}
	
	list->start = malloc(sizeof(SCROLL_ENTRY) * (lists->num_dirs + lists->num_files));
	entry = list->start;

	temp = form + FS_ICN_DIR;
	temp->r.x = temp->r.y = 0;
	temp->ob_flags |= HIDETREE;
	temp = form + FS_ICN_EXE;
	temp->r.x = temp->r.y = 0;
	temp->ob_flags |= HIDETREE;

	DIAG((D.fsel,-1,"entries have been sorted\n"));
	
	DIAG((D.fsel,-1,"DIRS:\n"));
	
	dirs = lists->dirs;
	while(*dirs)	/* Stick directories at top of list */
	{
		entry->icon = form + FS_ICN_DIR;
		entry->flag = FLAG_DIR;				/* HR */
		entry->text = *(dirs++);
		entry->n = ++n;						/* HR */
		{
			extern short debugging;
			if (debugging >= 2)
				DIAG((D.fsel,-1,"%s\n", entry->text));
		}
		entry->next = entry + 1;
		entry->prev = entry - 1;
		entry++;
	}

	DIAG((D.fsel,-1,"FILES:\n"));

	files = lists->files;
	while(*files)	/* Add files after directories */
	{
		entry->text = *files;
		entry->flag = 0;					/* HR */
		entry->n = ++n;						/* HR */
		if (((Entry *)*files - 1)->flags & FLAG_EXECUTABLE)
			entry->icon = form + FS_ICN_EXE;
		else
			entry->icon = NULL;
		{
			extern short debugging;
			if (debugging >= 2)
				DIAG((D.fsel,-1,"%s\n", entry->text));
		}
		entry->next = entry + 1;
		entry->prev = entry - 1;
		files++;
		entry++;
	}
	list->start->prev = NULL;
	(--entry)->next = NULL;
	
	list->top = list->cur = list->start;
	list->last = entry;							/* HR */
	list->n = n;								/* HR */
	graf_mouse(ARROW, NULL);

	list->slider(list);
	v_hide_c(V_handle);
	draw_object_tree(form, FS_LIST, 1);
	v_show_c(V_handle, 1);
	fs_prompt(list);							/* HR */
}
#endif

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
			sprintf(m[d++].ob_spec,"  %c:",drv + 'A');
			drvs++;
		}
		dmap >>= 1;
		drv++;
	}
	do
		m[d].ob_flags|=HIDETREE;
	while (m[d++].ob_next != FSEL_DRVBOX);
	m[FSEL_DRVBOX].r.h = ((drvs+1)/2) * display.c_max_h;
	sprintf(m[FSEL_DRV].ob_spec," %c:", drive + 'A');
	return drvs;
}

char Filters[23][16];

static
void fsel_filters(OBJECT *m, char *pattern)
{
	char p[16];
	short d  = FSEL_PATA,
	      i = 0;
	if (Filters[0][0])
	{
		while (i < 23 && Filters[i][0])
		{
			m[d].ob_state&=~CHECKED;
			if (stricmp(pattern,Filters[i]) == 0)
				m[d].ob_state|=CHECKED;
			sprintf(m[d++].ob_spec,"  %s",Filters[i++]);
		}
	
		do
			m[d].ob_flags|=HIDETREE;
		while (m[d++].ob_next != FSEL_PATBOX);
		m[FSEL_PATBOX].r.h = i * display.c_max_h;
	} else
	{
		while (i < 23)
		{
			char *s = m[d].ob_spec;
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
	sprintf(m[FSEL_FILTER].ob_spec," %s", p);
}
#endif

static char null_file[] = "NONAME.XXX";

/* HR: a little bit more exact. */
void fs_updir(XA_WINDOW *w)	/* Dont need form as long as everything is global 8-} */
{
	short drv;

	if (*fs_path)
	{
		short s = strlen(fs_path) - 1;
	
		if (fs_path[s] == *fs_slash)
			s--;
	
		while(   s
		      && fs_path[s] != ':'
			  && fs_path[s] != *fs_slash)		/* HR check s */
			s--;
		if (fs_path[s] == ':')
			fs_path[++s] = *fs_slash;
		fs_path[++s] = 0;
	}
#if !POSIX_ENTRIES
	if ((drv = get_drv(fs_path)) >= 0)
		strcpy(fs_paths[drv], fs_path);
#endif
	refresh_filelist();
}

scrl_widget fs_closer
{
	fs_updir(list->wi);
}

/* HR: flag now in SCROLL_ENTRY as well.
		removed dangerous pointer - 1 usage. */
scrl_click fs_dclick /* OBJECT *form, short objc */
{
	OBJECT *ob = form + objc;
	SCROLL_INFO *list = ob->ob_spec;
	XA_WINDOW *wl = list->wi;

	if (list->cur)
	{
		if (list->cur->flag)
		{			
			if (list->cur->text[0] != '.')
			{
				short drv;
				if (fs_path[strlen(fs_path) - 1] != *fs_slash)		
					strcat(fs_path, fs_slash);
				strcat(fs_path, list->cur->text);

#if !POSIX_ENTRIES
				if ((drv = get_drv(fs_path)) >= 0)
					strcpy(fs_paths[drv], fs_path);
#endif

				refresh_filelist();
			}
			else
			if (list->cur->text[1] == '.')
				fs_updir(wl);

			return TRUE;
		}
		else
			strcpy(fs_internal_file, list->cur->text);

		if (selected)
			(*selected)(fs_path, fs_internal_file);
	}
	else
	if (selected)
		(*selected)(fs_path, null_file);

	close_window(fs_open);
	delete_window(fs_open);
	return TRUE;
}

scrl_click fs_click /* OBJECT *form, short objc */
{
	SCROLL_INFO *list;
	OBJECT *ob = form + objc;
		
	list = (SCROLL_INFO *)ob->ob_spec;
	
	if (list->cur)
	{
		if (!list->cur->flag)
		{
			strcpy(fs_internal_file, list->cur->text);
			v_hide_c(V_handle);
			draw_object_tree(form, FS_FILE, 1);
			v_show_c(V_handle, 1);
		}
		else
			fs_dclick(form, objc);		/* HR */
	}

	return TRUE;
}			

void handle_fileselector(ODC_PARM *odc_p)		/* The ''form_do'' part */
{
#ifdef FS_FILTER
	OBJECT *ob = odc_p->tree + FS_LIST;
	SCROLL_INFO *list = ob->ob_spec;
	TEDINFO *filter = (TEDINFO *)(odc_p->tree + FS_FILTER)->ob_spec;
#endif
#ifdef FS_UPDIR
	XA_WINDOW *wl = list->wi;
#endif
	
	switch(odc_p->object)
	{
#ifdef FS_UPDIR
	case FS_UPDIR:			/* Go up a level in the filesystem */
		fs_updir(wl);		/* HR */
		break;
#endif
	case FS_OK:							/* Accept current selection - do the same as a double click */
#ifdef FS_FILTER
		if (strcmp(filter->te_ptext, fs_pattern) != 0)
		{
			strcpy(fs_pattern, filter->te_ptext);			/* changed filter */
			refresh_filelist();
		}
		else
#endif
			fs_dclick(odc_p->tree, FS_LIST);
		break;
#ifdef FS_UNIX
	case FS_UNIX:
		selected = fs_unix;			/* HR: Yeah! */
		fs_dclick(odc_p->tree, FS_LIST);
		break;
#endif
	case FS_CANCEL:					/* Cancel this selector */
		if (canceled)
			(*canceled)(fs_path, "");

		close_window(fs_open);
		delete_window(fs_open);
		break;
	}
}

WindowKeypressCallback fs_key_handler /* XA_WINDOW *wind, unsigned short keycode */ /* HR */
{
	OBJECT *form = ResourceTree(system_resources, FILE_SELECT),
	       *ob = form + FS_LIST;
	SCROLL_INFO *list = ob->ob_spec;

	if (list->n && scrl_cur(list, keycode) != -1)
	{
		if (!list->cur->flag)
		{
			strcpy(fs_internal_file, list->cur->text);
			v_hide_c(V_handle);
			draw_object_tree(form, FS_FILE, 1);
			v_show_c(V_handle, 1);
		}
	} else
	{
		char old[NAME_MAX];
		strcpy(old, fs_internal_file);
		handle_form_key(wind, keycode);
		if (strcmp(old,fs_internal_file) != 0)	/* something typed in there? */
			fs_prompt(list);
	}
	return true;
}

void fs_change(OBJECT *m, short p, short title, short d, char *t)
{
	XA_WIDGET *widg = fs_open->widgets + XAW_MENU;
	short bx = d-1;
	do
		m[d].ob_state&=~CHECKED;
	while (m[d++].ob_next != bx);
	m[p].ob_state|=CHECKED;
	sprintf(m[title].ob_spec," %s", (char *)m[p].ob_spec + 2);
	clear_clip();
	widg->start = 0;
	display_menu_widget(fs_open, widg /*fs_open->widgets + XAW_MENU */);
	strcpy(t, (char *)m[p].ob_spec + 2);
}

/* HR: make a start */
/* dest_pid, msg, source_pid, mp3, mp4,  ....    */
SendMessage fs_msg_handler		/* Here go the menu stuff */
{
	short drv;
	switch (msg)
	{
	case MN_SELECTED:
		if (mp3 == FSEL_FILTER)
			fs_change(fs_menu.tree, mp4, FSEL_FILTER, FSEL_PATA, fs_pattern);
		else
		if (mp3 == FSEL_DRV)
		{
			short drv;
			fs_change(fs_menu.tree, mp4, FSEL_DRV, FSEL_DRVA, fs_path);
#if !POSIX_ENTRIES
			inq_xfs(fs_path, fs_slash);
#endif
			if (*(fs_path + strlen(fs_path) - 1) != *fs_slash)
				strcat(fs_path, fs_slash);
#if !POSIX_ENTRIES
			drv = get_drv(fs_path);
			if (fs_paths[drv][0])
				strcpy(fs_path, fs_paths[drv]);
			else
				strcpy(fs_paths[drv], fs_path);
#endif
		}
		refresh_filelist();
	}
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

   Moreover, the word is annoyingly spurious. The fact that its a pointer to
   a function tells enough.
   Note that both '*' and 'Callback' appeared in the same typeded declaration.

   The typedef name doesnt need to be specific on it's usage, but when it is
   used with a '*', you know that its usage is indirect.
   
   In XaAES the pointer to a function is a simple switching device.
   Nothinh more.

   So: first I removed the '*' from the typedef. This makes the name more widely usable.
   	   then I removed 'Callback' from the name.
old:
void open_fileselector(char *path, char *title, FileSelectedCallback *s, FileSelectedCallback *c)

The bad work of the ANSI committee still remains extremely annoying!!!
"void open_fileselector(char *path, *title; fsel_handler *s, *c;)"  should have been good enough.
This makes a parameterlist syntactically the same as a structure; semantically they're always
have been the same of course.
From the point of view of a procedure, the parameter list is a volatile struct
describing the local memory where the parameters are found. 
*/

void open_fileselector(char *path, char *title, fsel_handler *s, fsel_handler *c)
{
	short dh;			/* HR variable height for fileselector :-) */
	OBJECT *form = ResourceTree(system_resources, FILE_SELECT);
	TEDINFO *filter;
	XA_WINDOW *dialog_window;
#if 0		/* HR: now provided via standard_widgets() */
	XA_WIDGET_LOCATION dialog_menu_loc = {LT, 0, 0};		/* HR */
#endif
	XA_WIDGET_LOCATION dialog_toolbar_loc = {LT, 0, 0};		/* HR */
	RECT r;
	char *pat,*pbt;

	DIAG((D.fsel,-1,"open_fileselector(%s,%s,%lx,%lx)\n", path, title, s, c));
	
	if (fs_open)
	{
		DIAG((D.fsel,-1,"fsel undestructed\n"));
		return;
	}
	selected = s;
	canceled = c;

#ifdef FS_FILTER
	filter = (TEDINFO *)(form + FS_FILTER)->ob_spec;
	filter->te_ptext = fs_internal_filter;
	filter->te_txtlen = NAME_MAX * 2;
#endif

	((TEDINFO *)(form + FS_FILE)->ob_spec)->te_ptext = fs_internal_file;
	
	dh = root_window->wa.h - 7*display.c_max_h - form->r.h;
	form->r.h += dh;
	form[FS_LIST ].r.h += dh;
	form[FS_UNDER].r.y += dh;

	center_form(form, 2*ICON_H);		/* HR */

	strcpy(fs_path, path);

/* Strip out the pattern description */

#if 1
	pat = strrchr(fs_path, back_slash);
	pbt = strrchr(fs_path, slash);
	if (!pat) pat = pbt;
	if (pat)
	{
		
		strcpy(fs_pattern, pat + 1);
		*(pat + 1) = 0;
	}
#else		/* HR: Oh how I hate these kinds of for loops */
	for(pat = fs_path + strlen(fs_path); (pat > fs_path) && (*pat != *fs_slash); pat--)
		;
	if (pat > fs_path)
	{
		*pat++ = '\0';
		strcpy(fs_pattern, pat);
	}
#endif
	else
	{
		fs_pattern[0] = '*';
		fs_pattern[1] = '\0';
	}

#if !POSIX_ENTRIES
	{
		short drv = get_drv(fs_path);
		if (drv >= 0)
			strcpy(fs_paths[drv], fs_path);
	}
#endif

#ifdef FSEL_MENU
	fs_menu.tree = ResourceTree(system_resources, FSEL_MENU);
	fsel_drives(fs_menu.tree,
				*(fs_path+1) == ':'
			  ? tolower(*fs_path) - 'a'
			  : Dgetdrv()
			  );
	fsel_filters(fs_menu.tree, fs_pattern);
#endif

	fs_internal_file[0] = '\0';
	
/* Create a temporary window to work out sizing */
	dialog_window = create_window(nil, AESpid,
							XaMENU|					/* HR */
							NAME|MOVE, MG, form->r);
	Xpolate(&r,&dialog_window->r,&dialog_window->wa);

/* Dispose of the temporary window we created */
	delete_window(dialog_window);

/* Now create the real window */
	dialog_window = create_window(fs_msg_handler, AESpid,
							XaMENU|					/* HR */
							NAME|MOVE|NO_MESSAGES|NO_WORK, MG, r);

	dialog_window->created_by_FMD_START = FALSE;

/* Set the window title */
	dialog_window->widgets[XAW_TITLE].stuff = title;

#ifdef FSEL_MENU				/* HR: at last actually there */
/* Set the menu widget */				
	fs_menu.owner = AESpid;
	set_menu_widget(dialog_window, click_menu_widget, &fs_menu);
#endif

/* Set the main dialog widget */
	dialog_toolbar_loc.r.y = dialog_window->wa.y - dialog_window->r.y;	/* HR */
	set_toolbar_widget(dialog_window, dialog_toolbar_loc, form);

/* HR: We need to do some specific things with the key's,
    so we supply our own handler, */
    dialog_window->keypress = fs_key_handler;

/* HR: set a scroll list object */
	set_slist_widget(AESpid, form, FS_LIST, fs_closer, NULL, fs_dclick, fs_click, fs_path, NULL);
/* HR:  after set_menu_widget (fs_destructor must cover what is in menu_destructor())
    Set the window destructor */
	dialog_window->destructor = &fs_destructor;

	refresh_filelist();		/* HR: after set_slist_widget() */
	DIAG((D.fsel,-1,"Refreshed file list\n"));

	((XA_WIDGET_TREE *)dialog_window->widgets[XAW_TOOLBAR].stuff)->owner = AESpid;
	((XA_WIDGET_TREE *)dialog_window->widgets[XAW_TOOLBAR].stuff)->handler = &handle_fileselector;

	strcpy(fs_internal_filter, fs_pattern);
	
	dialog_window->is_open = TRUE;

	pull_wind_to_top(dialog_window);
	DIAG((D.fsel,-1,"calling display_window()\n"));
/*	if ((window_list->next) && (window_list->next->is_open) && (window_list->next != root_window))
		display_non_topped_window(window_list->next, NULL);		/* HR: Why? */
*/	display_non_topped_window(dialog_window, NULL);
	
	DIAG((D.fsel,-1,"done.\n"));
	
	fs_open = dialog_window;
}

short fs_destructor(XA_WINDOW *wind)		/* Called by delete_window() */
{
	OBJECT *form = ResourceTree(system_resources, FILE_SELECT);
	OBJECT *sl;
	SCROLL_INFO *list;

	sl = form + FS_LIST;
	list = (SCROLL_INFO *)sl->ob_spec;

	delete_window(list->wi);

#if POSIX_ENTRIES
	free(list->start);
	list->start = list->cur = list->top = list->last = NULL;
	free_entries();
#else
	free_list(list);
#endif
	fs_open = NULL;
	selected = NULL;

DIAG((D.fsel,-1,"fsel destructed\n"));
	return TRUE;
}

XA_CLIENT *fsel_owner;
AESPB *fsel_pb;

void to_unix(char *path, char *file)
{
	short drv = get_drv(path);
	char *p = path;

	strlwr(path);
	strlwr(file);

	if (*fs_slash == back_slash)
		while (*p)
		{
			if (*p == slash)
				*p = back_slash;
			p++;
		}
	else
		while (*p)
		{
			if (*p == back_slash)
				*p = slash;
			p++;
		}
	
	if (drv >= 0 && drv != 'u'-'a')
		sprintf(fsel_pb->addrin[0],"u:%s%c%s", fs_slash, *path, path+2);
	else
		strcpy(fsel_pb->addrin[0], path);
	strcpy(fsel_pb->addrin[1], file);
}

fsel_handler handle_fsel  /* char *path, char *file */
{
	unsigned long rtn = XAC_DONE;
	char *tmp;
#if POSIX_ENTRIES
  	to_unix(path, file);			/* HR */
#else			/* As is */
	strcpy(fsel_pb->addrin[0], path);
#endif
	strcpy((char *)fsel_pb->addrin[1], file);

	DIAG((D.fsel,-1,"fsel OK:path=%s,file=%s\n", (char *)fsel_pb->addrin[0], file));
	
	fsel_pb->intout[0] = 1;
	fsel_pb->intout[1] = 1;
	
	Fwrite(fsel_owner->kernel_end, sizeof(unsigned long), &rtn);
}

#ifdef FS_UNIX
/* Lower case, slash & if possible: u: */
fsel_handler fs_unix  /* char *path, char *file */
{
	unsigned long rtn = XAC_DONE;

	to_unix(path, file);

	DIAG((D.fsel,-1,"fsel Unix:path=%s,file=%s\n", fsel_pb->addrin[0], file));
	
	fsel_pb->intout[0] = 1;
	fsel_pb->intout[1] = 1;

	Fwrite(fsel_owner->kernel_end, sizeof(unsigned long), &rtn);
}
#endif

fsel_handler cancel_fsel /* char *path, char *file */
{
	unsigned long rtn = XAC_DONE;
	
	fsel_pb->intout[0] = 1;
	fsel_pb->intout[1] = 0;

	Fwrite(fsel_owner->kernel_end, sizeof(unsigned long), &rtn);
}

#if POSIX_ENTRIES
void fix_path_name(char *path, char *file)
{
	char *tmp;
	short len, i, s;

	len = strlen(path);	
	*fs_slash = slash;				/* HR */

#if 1
	if(!(((path[0] | 32) == 'u') && (path[1] == ':')))	/* Everything but u:... */
	{
		if (path[1] == ':')								/* x:/...  or x:... */
		{
			s = 2;
			if (path[2] == slash)
				s++;
			for(i = len; i >= s; i--)
				path[i + 5 - s] = path[i];
			path[3] = path[0];
			path[4] = slash;
		} else											/* ... */
		{
			for(i = len; i >= 0; i--)
				path[i + 5] = path[i];
			path[3] = (char)Dgetdrv() + 'a';
			path[4] = slash;
		}
		path[0] = 'u';
		path[1] = ':';
		path[2] = slash;
	}
#else	
	if ((t[1] == ':') && ((t[0] | 32) != 'u'))
	{
		t[1] = t[0] | 32;
		t[0] = slash;
	}
#endif

	for(tmp = path; *tmp; tmp++)
	{
		if(*tmp == back_slash)
			*tmp = slash;			/* back to slash ;-) */
	}

	if (!Pdomain(-1))	/* For TOS domain programs, convert path to lower case */
	{
		strlwr(path);	/* HR: */
		strlwr(file);
	}
	DIAG((D.fsel,-1,"modified path=%s, file=%s\n", path, file));
}
#endif

/*
 *	File selector interface routines
 */
static
unsigned long do_fsel_exinput(XA_CLIENT *client, AESPB *pb, char *text)
{
	unsigned long dummy_rtn;

/* Loads of programs lock the screen and the mouse before doing fsel_
   so we've got to unlock them again to allow the XaAES windowed file selector
   to work.
*/
	
	if (update_lock == client->pid)
	{
		update_cnt = 0;
		update_lock = 0;
		Psemaphore(3, UPDATE_LOCK, 0L);
	DIAG((D.fsel,-1,"fsel: after updlock:title=%s\n", text));
	}

	if (mouse_lock == client->pid)
	{
		mouse_cnt = 0;
		mouse_lock = 0;
		Psemaphore(3, MOUSE_LOCK, 0L);
	DIAG((D.fsel,-1,"fsel: after mouslock:title=%s\n", text));
	}

	Psemaphore(2, FSELECT_SEMAPHORE, -1L);	/* Wait for access to the fileselector */

	DIAG((D.fsel,-1,"fsel_(ex)input:title=%s,path=%s,file=%s\n", text, (char *)pb->addrin[0], (char *)pb->addrin[1]));

#if 1
	#if POSIX_ENTRIES
	fix_path_name((char *)pb->addrin[0], (char *)pb->addrin[1]);
	#endif
#else
#include "obsolete/fix_path"
#endif	

	fsel_owner = client;
	fsel_pb = pb;
	
	open_fileselector((char *)pb->addrin[0], text, &handle_fsel, &cancel_fsel);
	
	Fread(client->client_end, sizeof(unsigned long), &dummy_rtn);

	DIAG((D.fsel,-1,"fsel: read:title=%s\n", text));

	Psemaphore(3, FSELECT_SEMAPHORE, 0L);		/* Release the file selector */

	DIAG((D.fsel,-1,"fsel: unlocked:title=%s\n", text));
	return XAC_DONE;
}

AESroutine XA_fsel_input	/* (XA_CLIENT *client, AESPB *pb) */
{
	do_fsel_exinput(client, pb, "");

	return XAC_DONE;
}

AESroutine XA_fsel_exinput	/* (XA_CLIENT *client, AESPB *pb) */
{
	char *t = (char *)pb->addrin[2];		/* HR */
	if (pb->contrl[3] <= 2 || t == NULL)
		t = "";
	do_fsel_exinput(client, pb, t);

	return XAC_DONE;
}
