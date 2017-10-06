/* Constant definitions for gemma.c & other modules */

/*  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

# include <basepage.h>
# include "/usr/GEM/include/gem.h"
# include <gemma/struct.h>

# include "../config.h"

# define VDISYS	115L
# define AESSYS	200L

# define MAX_AES_OP	199

# define WINDIAL_MAGIC	25091973L

# ifndef ulong
#  define ulong unsigned long
# endif
# ifndef ushort
#  define ushort unsigned short
# endif
# ifndef uchar
#  define uchar unsigned char
# endif

struct xattr
{
	ushort	mode;
	long	index;
	ushort	dev;
	ushort	rdev;		/* "real" device */
	ushort	nlink;
	ushort	uid;
	ushort	gid;
	long	size;
	long	blksize;
	long	nblocks;
	ushort	mtime, mdate;
	ushort	atime, adate;
	ushort	ctime, cdate;
	short	attr;
	short	reserved2;
	long	reserved3[2];
};

struct gemma_flags
{
	long parameters;
	long max_pid;
	long pagesize;
	long minpagesize;
	long access_check;
	long res1;
	long button_delay;
	long release_delay;
	long maxaesop;
	const long *ctrl;
	long zoomboxes;
	long moveboxes;
	long screen_comp;
	long system_alerts;
	long blocking_alerts;
};

struct gproc
{
	GEM_ARRAY gem;			/* user-visible part of this structure */
	char *rawrscaddr;		/* address for the raw RSC buffer */
	char *rscaddr;			/* address for the RSC buffer */
	long rsclength;			/* RSC file length (rounded up to longword) */
	char *rscname;			/* RSC filename for broken systems */
	short env_refs;			/* counter for recursions in env_eval() */
	BASEPAGE *base;			/* process basepage address */
	WINDIAL *wchain;		/* the begin of the window chain */
	WINDIAL window;			/* window 0, integrated here to save some RAM */
	short fsel_init_done;		/* is 1 when fselector was called at least once */
	char fsel_path[1024];		/* retains last selected path */
	char fsel_file[256];		/* retains last selected filename */
	char fsel_outname[1024];	/* the complete filename returned */
};

typedef struct gproc PROC_ARRAY;
extern struct gemma_flags sflags;

/* Common macros & function prototypes */

# ifdef DEBUG
#  define DEBUGMSG(p)	debug_print(p)
# else
#  define DEBUGMSG(p)
# endif

# define UNUSED(p)	(void)p
# define LMASK		(sizeof(long) - 1)
# define LROUND(x)	((x + LMASK) & ~LMASK)

# ifdef _ROBUST_AES
#  define TOUCH(p)
# else
#  define TOUCH(p)	\
{\
	if (sflags.access_check)		\
		(void)*(volatile char *)p;	\
}
# endif

# define aes40(p) (p->gem.global[0] >= 0x0400)

# ifdef DEBUG
void debug_print(char *string);
# endif

char *getenv(BASEPAGE *bp, const char *var);
OBJECT *obj2addr(PROC_ARRAY *proc, short type, ulong obj);
PROC_ARRAY *get_contrl(BASEPAGE *bp);

/* EOF */
