/*
	@(#)slbload/slbload.c
	
	Julian F. Reschke, 24. Oktober 1998
*/

#include <dosix/errno.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include <tos.h>

#define VERSIONSTRING	"0.25ž"
#define VERSIONDATE		"1998-10-24"

#define DEBUG 0

#if DEBUG
int errno;
#endif


/* GEMDOS basepage + MagiC shared library structure */

typedef struct _sl
{
	BASPAG bp;

	long magic;
#define SLB_MAGIC	0x70004afcL
	char *name;
	long version;
	long flags;
	void cdecl (*slb_init) (void);
	void cdecl (*slb_exit) (void);
	void cdecl (*slb_open) (BASPAG *);
	void cdecl (*slb_close) (BASPAG *);
	long opt;
	struct _sl *next;		/* MagiC: reserved */
	long res[7];
	long fun_cnt;
	long fun_table[123];
} SL;

#define MAX_OWNERS		(32)

/* Shared library owner table */

typedef struct sl_owners
{
	struct sl_owners *next;
	SL *this_lib;
	BASPAG *entry[MAX_OWNERS];
} SL_OWNERS;


/* Variables from interfac.s */

extern BASPAG **act_pd_p;
extern long cdecl slbexec (void);

/* Other globals */

char *alternate_path;	/* alternate path for SLBs */
SL *libs;				/* linked list of loaded libs */
SL_OWNERS *owners;		/* linked list of owner tables */


/* Write a string to the screen using BIOS */

static void
Bconws (char *str)
{
	while (*str)
	{
		if (*str == '\n') Bconout (2, '\r');
		Bconout (2, *str++);
	}
}


/* lookup owner table for a shared library */

static SL_OWNERS *
lookup_owner (SL *lib)
{
	SL_OWNERS *slp;
	
	for (slp = owners; slp; slp = slp->next)
		if (slp->this_lib == lib)
			return slp;
	
	/* this shouldn't happen */
	return NULL;
}



/* load a shared library from internal list */

static long
load_lib_from_mem (const char *name, long minver, SL **slp)
{
	SL *s;
	
	for (s = libs; s; s = s->next)
	{
		if (0 == stricmp (s->name, name) && s->version >= minver)
		{
			SL_OWNERS *so = lookup_owner (s);

			/* add current process to owner table */
			int i;
			
#if DEBUG
fprintf (stderr, "slbload: owner table found at %p\n", so);
#endif

			for (i = 0; i < MAX_OWNERS; i++)
			{
				if (so->entry[i] == NULL)
				{
					so->entry[i] = *act_pd_p;
					break;					
				}
			}
#if DEBUG			
fprintf (stderr, "slbload: `%s' at %p already loaded\n", s->name, s);
#endif		
			*slp = s;
			return s->version;
		}
	}
	
	return EFILNF;
}


/* put a shared lib onto internal list */

static void
link_lib_to_mem (SL *to_add)
{
	/* memory for owner table has been allocated behind SL */

	SL_OWNERS *so = (SL_OWNERS *)(sizeof(BASPAG) + (long)to_add +
		to_add->bp.p_tlen + to_add->bp.p_dlen + to_add->bp.p_blen);

#if DEBUG
fprintf (stderr, "link_lib_to_mem: owner table for SL %p at %p\n",
	to_add, so);
#endif

	/* clear owner list */
	memset (so, 0, sizeof (SL_OWNERS));

	/* set parent pointer, not done by Pexec 3 */
	to_add->bp.p_parent = *act_pd_p;
	
	/* set lib and first owner */
	so->this_lib = to_add;
	so->entry[0] = *act_pd_p;
	
	/* link SL to the list */
	to_add->next = libs;
	libs = to_add;
	
	/* link owner table to the list */
	so->next = owners;
	owners = so;
}


/* remove a shared lib from internal lists */

static void
unlink_lib_from_mem (SL *to_remove)
{
	SL *s, **s_hook = &libs;
	SL_OWNERS *so, **so_hook = &owners;
	
	for (s = libs; s; s = s->next)
	{
		if (s == to_remove)
		{
			*s_hook = s->next;
			break;
		}
		
		s_hook = &s->next;
	}

	for (so = owners; so; so = so->next)
	{
#if DEBUG
fprintf (stderr, "unlink_lib_from_mem: owner table %p, this lib %p, "
	"to remove %p\n", so, so->this_lib, to_remove);
#endif
		if (so->this_lib == to_remove)
		{
			*so_hook = so->next;
			break;
		}
		
		so_hook = &so->next;
	}
}


/* return contents of SLBPATH variable */

#define ENV_SLBPATH	"SLBPATH="
#define ENV_LEN (-1+sizeof(ENV_SLBPATH))

const char *
get_slb_path (void)
{
	const char *c = (*act_pd_p)->p_env;
	
	while (c && c[0])
	{
		if (!strncmp (c, ENV_SLBPATH, ENV_LEN))
			return c + ENV_LEN;
		
		c += strlen (c) + 1;
	}
	
	return NULL;
}


/* try to load shared library from a file */

static long
load_lib_from_file (const char *name, const char *path,
	size_t path_len, long minver)
{
	long pret;
	SL *sl;
	char namebuf[256] = "";
	
	if (path && path_len)
	{
		strncpy (namebuf, path, path_len);
		
		if (namebuf[path_len-1] != '\\' && namebuf[path_len-1] != ':')
			strcat (namebuf, "\\");
	}
	
	strcat (namebuf, name);

	/* try to load overlay */
	
	pret = Pexec (3, namebuf, "\0\0", NULL);
	if (pret < 0) return pret;
	
	sl = (SL *) pret;

	/* check for MagiC 6.x shared lib magic value */
	
	if (sl->magic != SLB_MAGIC) {
		Mfree (sl);
		return EPLFMT;
	}
	
	/* check version number */
	
	if (sl->version < minver) {
		Mfree (sl);
		return ERANGE;
	}

	/* check lib name, not done by MagiC! */
	
	if (0 != stricmp (sl->name, name)) {
		Mfree (sl);
		return ERROR;
	}
	
	/* shrink memory */
	
	Mshrink (0, sl, sizeof (BASPAG) + sl->bp.p_tlen +
		sl->bp.p_dlen + sl->bp.p_blen + sizeof (SL_OWNERS));

	/* copy slb file name into command line area */
	{
		size_t l = strlen (namebuf);
		
		if (l > 127) l = 127;
		strncpy (sl->bp.p_cmdlin, namebuf, l);
		sl->bp.p_cmdlin[127] = '\0';
	}
	

	/* hook into onto the internal list */
	
	link_lib_to_mem (sl);

#if DEBUG
fprintf (stderr, "slbload: `%s' loaded by process %p, calling slb_init\n", sl->name, *act_pd_p);
#endif

	/* call the library init function */

	sl->slb_init ();
	
	return pret;
}



/* load a shared library.

   name:    name of library
   path:    path to use or NULL
   minver:  minimal version number
   slp:     return pointer to shared lib in this **
   
   returns: version number of loaded sl or < 0
*/

static long
load_lib (const char *name, const char *path, const char *alt_path,
	long minver, SL **slp)
{
	long ret;

	/* check for SLB in memory */
	
	ret = load_lib_from_mem (name, minver, slp);
	if (ret >= 0) return ret;

	/* check for SLB in specified path */
	
	ret = load_lib_from_file (name, path, path ? strlen (path) : 0,
		minver);
#if DEBUG
fprintf (stderr, "slbload: `%s' in `%s' -> %ld\n",
	name, path ? path : "(null)", ret);
#endif	

	/* check for SLB elsewhere */
	
	if (ret < 0)
	{
		const char *c = alt_path;

		while (c && *c)
		{
			int l = 0;

			while (c[l] != ';' && c[l] != ',' && c[l] != '\0')
				l += 1;

			ret = load_lib_from_file (name, c, l, minver);
#if DEBUG
{ int i;
fprintf (stderr, "slbload: `%s' in `", name);
for (i = 0; i < l; i++) fputc (c[i], stderr);
fprintf (stderr, "' -> %ld\n", ret);
}
#endif	
			if (ret >= 0) break;
			if (c[l] == '\0') break;
			
			c += l + 1;	
		}
	}

	if (ret < 0) return ret;

	*slp = (SL *) ret;

	return (*slp)->version;
}


/* MetaDOS entry point for Slbopen()

   rts      Return address within MetaDOS
   opcode   GEMDOS opcode
   name     Name of shared library
   path     Path to use or NULL
   min_ver  Minimal version number
   sl       Pointer to shared library
   fn       Pointer to library function hook
   param    ?
*/

long cdecl
Slbopen (long rts, int opcode, const char *name, const char *path,
	long min_ver, SL **slp, void **fn, long param)
{
	long ret;
	SL *sl;
	const char *env_path;

	(void) rts, opcode, param;

	/* get SLBPATH variable from environment */

	env_path = get_slb_path ();
#if DEBUG
	if (env_path)
		fprintf (stderr, "slbload: SLBPATH is `%s'\n", env_path);
#endif

	/* If SLBPATH not specified, try alternate path from CONFIG.SYS */
	if (!env_path) env_path = alternate_path;

	ret = load_lib (name, path, env_path, min_ver, &sl);
	
	if (ret < 0) return ret;
	
#if DEBUG
fprintf (stderr, "slbload: calling slb_open for `%s' and process %p\n",
	sl->name, *act_pd_p);
#endif

	sl->slb_open (*act_pd_p);

	*fn = slbexec;
	*slp = sl;
	
	return ret;
}


/* Shared library close function */

static void
close_slb (BASPAG *curr_proc, SL *sl)
{
	int i;
	SL_OWNERS *so = lookup_owner (sl);
	
	/* call SLB's close function if the current process was
	   one of it's owners */
	
	for (i = 0; i < MAX_OWNERS; i++)
	{
		if (so->entry[i] == curr_proc)
		{
#if DEBUG
fprintf (stderr, "slbload: calling slb_close for `%s' and process %p\n",
	sl->name, curr_proc);
#endif
			sl->slb_close (curr_proc);
			so->entry[i] = 0;
		}
	}

	/* unhook if and only if the current process is the owner
	   of the library */

	if (curr_proc == sl->bp.p_parent)
	{
#if DEBUG
fprintf (stderr, "slbload: `%s' unloaded because parent %p exits, calling slb_exit\n", sl->name, curr_proc);
#endif
		sl->slb_exit ();

		unlink_lib_from_mem (sl);
		Mfree ((void *) sl);
	}
}


/* MetaDOS entry point for Slbclose()

   rts      Return address within MetaDOS
   opcode   GEMDOS opcode
   sl       Pointer to shared library
*/


long cdecl 
Slbclose (long rts, int opcode, SL *sl)
{
	(void) opcode, rts;

	/* Special case: MetaDOS calls Slbclose with a NULL SL pointer
	   when the current process exits */
	
	if (sl == NULL)
	{
		SL *s;
		
		for (s = libs; s; s = s->next)
			close_slb (*act_pd_p, s);
	}
	else
		close_slb (*act_pd_p, sl);

	return E_OK;
}

long function_table[] =
{
	(long) Slbopen, (long) Slbclose,
};


char *
sccsid (void)
{
	return "@(#)slbload.ovl "VERSIONSTRING", Copyright (c) Julian F. Reschke, "__DATE__;
}

void
ShowBanner (void)
{
	extern char startoftext;

	BASPAG *_BasPag = (BASPAG *)(&startoftext - 256);

	_BasPag->p_cmdlin[1 + _BasPag->p_cmdlin[0]] = 0;
	alternate_path = _BasPag->p_cmdlin + 1;
	if (alternate_path[0] == '\0') alternate_path = NULL;
	
	Bconws ("\033p SLBLOAD "VERSIONSTRING" "VERSIONDATE" \033q\r\n");
	if (alternate_path) {
		Bconws (" Default library path is: ");
		Bconws (alternate_path);
		Bconws ("\n");
	}
}
