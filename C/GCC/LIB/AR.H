
/* this file was hacked together by jrd, cause there doesn't seem to be one
   supplied with the ar.c etc that I found on frosted-flakes.
   The structure of these things was deduced from looking at the code, and
   dumping a file produced by ar.c when compiled on a Eunuchs that I had
   lying around.  The sizes of things are not the same as what Eunuchs
   appears to use, but who cares; they were picked for utility on the atari
*/

/* this appears to be nothing more that a frobule that allows us to recognize
   an object library when we see one.  It looks like any string will do... */
#define	ARMAG	"Gnu is Not eUnuchs.\n"

/* the size of the above tag? */
#define	SARMAG	20

/* a thing that's shoved into each module header?  This appears to be
   required to be 2 bytes, as there's a BCMP in there with a 2 wired into
   its calling sequence... */
#define	ARFMAG	"\r\n"

/* a header for a module of the library. */
struct ar_hdr 
	{
	char ar_name[16];	/* the module name.  Strictly speaking, 
				   12 ought to be enough, as that's the
				   biggest file name we'll see, and we
				   don't see directories, but we'll leave 
				   a little slush in case somebody wants
				   to stick a null in there. */
	char ar_size[12];	/* ascii size number */
	char ar_date[12];	/* ascii representation of date fixnum */
	char ar_mode[8];	/* ??? protection bits??? */
	char ar_uid[4];		/* who knows? */
	char ar_gid[4];		/* ditto... */
	char ar_fmag[2];	/* does this have to be last? */
	};
