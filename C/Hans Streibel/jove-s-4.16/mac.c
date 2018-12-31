/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/


/* (C) 1986, 1987, 1988 Ken Mitchum.  This code is intended only for use with Jove. */

/* In 1995 December, D. Hugh Redelmeier hacked on the code to make
 * it work again.  The environment was Think C 5.0 under System 7.1.
 *
 * Obligatory excuses:
 * - Hugh is not a Mac expert
 * - Think C 5.0 is quite obsolete (1991)
 * - The only goal was to get the code working, not working well.
 *
 * Known issues:
 * - the keyboard routines were designed for the Mac Plus keyboard.
 *   + "Command" is taken as "Control" and ` is taken as ESC.
 *   + There should be support for a distinct Command keymap
 *     with Mac-like default bindings.
 * - "macify" ought to be extended to find-file and perhaps
 *   other commands
 * - perhaps there are newer MacOS facilities that ought to be
 *   exploited.  Apple Events?
 * - the hacky way the command keystrokes are described in About Jove
 *   ought to be improved.
 * - Highlighting ought to be supported.
 * - Mouse support ought to be better.  For example, selecting text
 *   ought to be at least as well done as under XTerm!
 * - [supposition] Because double-clicking is supported, nothing
 *   is done for a single click until the double-click timeout
 *   happens.  Since the double-click action is a superset of
 *   the single-click action, the single click action ought to
 *   be immediately performed and then augmented if a double-click
 *   happens.
 * - see also comments containing ???
 */

#include "tune.h"

#ifdef MAC	/* the body is the rest of this file */

#include "jove.h"

#include <Controls.h>
#include <Desk.h>
#include <Dialogs.h>
#include <Errors.h>
#include <Events.h>
#include <Files.h>
#include <Fonts.h>
#include <Lists.h>
#include <LoMem.h>
#include <Menus.h>
#include <Quickdraw.h>
#include <Resources.h>
#include <SegLoad.h>
#include <StandardFile.h>
#include <ToolUtils.h>
#include <Types.h>
#include <Windows.h>

#include <errno.h>
#include <pascal.h>

#include "mac.h"
#include "ask.h"
#include "chars.h"
#include "disp.h"
#include "extend.h"
#include "fp.h"	/* for flushscreen() */
#include "commands.h"
#include "fmt.h"
#include "marks.h"
#include "misc.h"
#include "move.h"
#include "screen.h"
#include "scandir.h"
#include "term.h"
#include "vars.h"
#include "version.h"
#include "wind.h"

extern struct menu Menus[NMENUS];   /* from menumaps.txt => menumaps.c */

private	EventRecord the_Event;

private void SetBounds proto((void));
private void Set_std proto((void));
private void Reset_std proto((void));
private bool findtext proto((void));


/* tn.h Modified for variable screen size 11/21/87. K. Mitchum */

#define SCREENSIZE (wc->w_rows * ROWSIZE)
#define FONT monaco
#define TEXTSIZE 9

#define HEIGHT 11
#define WIDTH 6
#define DESCENT 2
#define TWIDTH CO * WIDTH
#define THEIGHT LI * HEIGHT

/* window specs */

#define SCROLLWIDTH 16	/* width of scroll bar control in pixels */
#define WINDWIDTH (wc->w_width - SCROLLWIDTH + 1)	/* local coordinates */
#define WINDHEIGHT (wc->w_height)	/* local coordinates */
#define MAXROW ILI
#define MAXCOL (CO - 1)


/* for keyboard routines */
#define MCHARS 32	/* length of circular buffer -- must be a power of two */
#define NCHMASK (MCHARS - 1)	/* mask for modulo MCHARS */


/***************************************************/

private void
	putcurs proto((unsigned row, unsigned col, bool vis)),
	curset proto((bool desired)),
	dellines proto((int n, int bot)),
	inslines proto((int n, int bot));

private Rect LimitRect;	/* bounds we can't move past */

struct wind_config {
	int w_width;	/* pixel width of the Mac window */
	int	w_height;
	int	w_rows;	/* rows of characters which fit the window */
	int	w_cols;
} wc_std, wc_user, *wc;

private WindowPtr theScreen;

bool
	Windchange,
	EventCmd,
	Keyonly,
	Bufchange,
	Modechange;

bool
	Macmode = NO;	/* VAR: use Mac file selector */

/* Initialization Routines. */

void
getTERM()
{
}

/* For each binding, mark the command with the binding.
 * We use it for "About Jove ...".
 * ??? This is faster than using find_binds, but it has problems:
 * - it only notes the last binding of each command
 * - it only reflects the three listed keymaps
 * - it requires a wart on struct cmd
 * - it is MAC-only
 */

private void
InitMapBinds(km, kmc)
data_obj	**km;
char	kmc;
{
	ZXchar i;

	for (i = 0; i < NCHARS; i++) {
		if (*km != NULL && obj_type(*km) == COMMAND) {
			struct cmd	*c = (struct cmd *) *km;

			c->c_map = kmc;
			c->c_key = i;
		}
		km += 1;
	}
}

private void
InitBinds()
{
	InitMapBinds(MainKeys, F_MAINMAP);
	InitMapBinds(EscKeys, F_PREF1MAP);
	InitMapBinds(CtlxKeys, F_PREF2MAP);
}

private	WindowPtr window;
private	Rect r;
private CursHandle cross;

private void InitSysMenu proto((void));

void
InitEvents()
{
	window = theScreen;
	InitSysMenu();
	SetRect(&r, window->portRect.left,
		window->portRect.top,
		window->portRect.right - SCROLLWIDTH,
		window->portRect.bottom - SCROLLWIDTH);
	cross = GetCursor(crossCursor);
}

private void	tn_init proto((void));
private int	getdir proto((void));

void
MacInit()
{
	tn_init();
	getdir();
	strcpy(TmpDir, gethome());
	strcpy(ShareDir, TmpDir);
	InitBinds();
}

void
ttysetattr(n)
bool	n;	/* also used as subscript! */
{
}

/* Surrogate unix-style file i/o routines for Jove.  These replace the
   routines distributed in the libraries.  They work with Jove, but may
   not be general enough for other purposes. */

#define NFILES 10

private int cur_vol;	/* Disk or volume number */
private long cur_dir;	/* Directory number */
private int cur_vref;	/* ugh.. Vref for volume + directory */

struct ftab {
	bool inuse;
	int refnum;	/* Mac file reference number */
} ft[NFILES];

private void
fsetup(p)
HParmBlkPtr p;
{
	byte_zero(p, sizeof(HParamBlockRec));
	p->fileParam.ioVRefNum = cur_vol;
	p->fileParam.ioDirID = cur_dir;
	/* p->fileParam.ioFVersNum = 0; */
}

private void
isetup(p)
IOParam *p;
{
	byte_zero(p, sizeof(IOParam));
	p->ioVRefNum = cur_vol;
}


/* Kludge to convert Macintosh error codes to something like Unix. */

private int
cvt_err(err)	/* some of these don't make sense... */
int	err;
{
	switch(err) {
	case noErr:
		errno = 0;
		return 0;
	case dirFulErr:
	case dskFulErr:
		errno = ENOSPC;
		break;
	/* case nsvErr: */
	/* case mFulErr: */
	/* case tmfoErr: */
	/* case fnfErr: */
	default:
		errno = ENOENT;
		break;
	case ioErr:
		errno = EIO;
		break;
	case bdNamErr:
	case opWrErr:
	case paramErr:
		errno = EINVAL;
		break;
	case fnOpnErr:				/* dubious... */
	case rfNumErr:
		errno = EBADF;
		break;
	case eofErr:				/* ditto */
	case posErr:
		errno = /* no longer defined: ESPIPE */ EIO;
		break;
	case wPrErr:
		errno = EROFS;
		break;
	case fLckdErr:
	case permErr:
		errno = EACCES;
		break;
	case fBsyErr:
		errno = EBUSY;
		break;
	case dupFNErr:
		errno = EEXIST;
		break;
	case gfpErr:
	case volOffLinErr:
	case volOnLinErr:
	case nsDrvErr:
		errno = ENODEV;
		break;
	case noMacDskErr:
	case extFSErr:
		errno = EIO;
		break;
	case fsRnErr:
	case badMDBErr:
	case wrPermErr:
		errno = /* no longer defined: EPERM */ EACCES;
		break;
	}
	return -1;
}

private StringPtr
cvt_fnm(file)
const char *file;
{
	static char nm[255];
	char *t;

	if (*file == '/') {
		strcpy(nm, file + 1);	/* full path */
	} else {
		if (strchr(file + 1, '/') != NULL)
			strcpy(nm, "/");	/* make a partial pathname */
		else
			nm[0] = '\0';
		strcat(nm, file);
	}
	for (t = nm; (t = strchr(t, '/')) != NULL; )
		*t++ = ':';
	return CtoPstr(nm);
}

private int do_creat proto((HParmBlkPtr p, StringPtr nm));

int
creat(name, perm)	/* permission mode is irrelevant on a Mac */
const char	*name;
int	perm;
{
	int fd, err;
	StringPtr nm;
	HParamBlockRec p;

	nm = cvt_fnm(name);	/* convert filename to Mac type name */
	for (fd = 0; ft[fd].inuse; fd++) {
		if (fd == NFILES-1) {
			errno = EMFILE;
			return -1;
		}
	}
	fsetup(&p);	/* try to delete it, whether it is there or not. */
	p.fileParam.ioNamePtr = nm;
	if ((err = PBHDelete(&p, 0)) != noErr && err != fnfErr)
		return cvt_err(err);
	if (do_creat(&p, nm) != 0)
		return -1;
	ft[fd].inuse = YES;
	ft[fd].refnum = p.ioParam.ioRefNum;
	return fd + 1;
}

#ifdef USE_PROTOTYPES
int
open(const char *path, int flags, ...)
#else
int
open(path, flags)
const char	*path;
int	flags;
#endif
{
	int fd, err;
	StringPtr nm;
	HParamBlockRec p;

	nm = cvt_fnm(path);	/* convert filename to Mac type name */
	for (fd = 0; ft[fd].inuse; fd++) {
		if (fd == NFILES-1) {
			errno = EMFILE;
			return -1;
		}
	}
	fsetup(&p);
	switch (flags & 3) {
	case 0:	/* O_RDONLY */
		p.ioParam.ioPermssn = fsRdPerm;
		break;
	case 1:	/* O_WRONLY */
		p.ioParam.ioPermssn = fsWrPerm;
		break;
	case 2:	/* O_RDWR */
		p.ioParam.ioPermssn = fsRdWrPerm;
		break;
	}
	p.ioParam.ioNamePtr = nm;
	p.ioParam.ioMisc = 0;
	if ((err = PBHOpen(&p, 0)) != noErr)
		return cvt_err(err);
	ft[fd].refnum = p.ioParam.ioRefNum;
	p.ioParam.ioPosMode = fsFromStart;
	p.ioParam.ioPosOffset = 0;
	if ((err = PBSetFPos((ParamBlockRec *) &p, 0)) != noErr)
		return cvt_err(err);
	ft[fd].inuse = YES;
	errno = 0;
	return fd + 1;
}

private int
do_creat(p, nm)
HParmBlkPtr p;
StringPtr nm;
{
	int err;

	fsetup(p);
	p->fileParam.ioNamePtr = nm;
	if ((err = PBHCreate(p, 0)) != noErr)
		return cvt_err(err);

	fsetup(p);
	p->fileParam.ioNamePtr = nm;
	p->fileParam.ioFDirIndex = 0;
	if ((err = PBHGetFInfo(p, 0)) != noErr)
		return cvt_err(err);

	p->fileParam.ioDirID = cur_dir;
	p->fileParam.ioFlFndrInfo.fdType = 'TEXT';
	p->fileParam.ioFlFndrInfo.fdCreator = 'JV01';
	p->fileParam.ioFlFndrInfo.fdFlags = 0;
	p->fileParam.ioFVersNum = 0;
	if ((err = PBHSetFInfo(p, 0)) != noErr)
		return cvt_err(err);

	fsetup(p);
	p->ioParam.ioNamePtr = nm;
	p->ioParam.ioPermssn = fsRdWrPerm;
	p->ioParam.ioMisc = 0;
	if (cvt_err(PBHOpen(p, 0)))
		return -1;

	return 0;
}


int
close(fd)
int	fd;
{
	int err;
	HParamBlockRec p;

	if (!ft[--fd].inuse) {
		errno = EBADF;
		return -1;
	}

	fsetup(&p);
	p.ioParam.ioRefNum = ft[fd].refnum;
	ft[fd].inuse = NO;
	if (cvt_err(PBClose((ParamBlockRec *) &p, 0)) < 0)
		return -1;

	fsetup(&p);
	p.ioParam.ioNamePtr = NULL;
	if (cvt_err(PBFlushVol((ParamBlockRec *) &p, 0)) < 0)
		return -1;

	return 0;
}

private SSIZE_T con_read proto((char *buf, size_t size));

/* Raw UNIX-like read */

SSIZE_T
read(fd, ubuf, n)
int	fd;
UnivPtr	ubuf;
size_t	n;
{
	char	*buf = ubuf;	/* char * is more useful */
	int err;
	IOParam p;

	if (fd == 0) {
		return con_read(buf, n);
	} else {
		if (!ft[--fd].inuse) {
			errno = EBADF;
			return -1;
		}
		isetup(&p);
		p.ioRefNum = ft[fd].refnum;
		p.ioBuffer = buf;
		p.ioReqCount = n;
		p.ioPosMode = fsFromMark;
		p.ioPosOffset = 0;
		if ((err = PBRead((ParamBlockRec *)&p, 0)) != noErr && err != eofErr)
			return cvt_err(err);

		errno = 0;
		return p.ioActCount;
	}
}

/* Raw UNIX-like write */

SSIZE_T
write(fd, ubuf, n)
int	fd;
UnivConstPtr	ubuf;
size_t	n;
{
	const char	*buf = ubuf;	/* char * is more convenient */

	if (fd == 0) {
		writetext((unsigned char *)buf, n);
		return n;
	} else {
		IOParam p;
		int	err;
		const char	*ebuf = buf + n;

		if (!ft[--fd].inuse) {
			errno = EBADF;
			return -1;
		}
		isetup(&p);
		p.ioRefNum = ft[fd].refnum;
		p.ioPosMode = fsFromMark;
		p.ioReqCount = n;
		p.ioBuffer = (Ptr)buf;
		p.ioPosOffset = 0L;	/* bidirectional */
		if ((err = PBWrite((ParamBlockRec *)&p, 0)) != noErr)
			return cvt_err(err);
		return p.ioActCount;
	}
}

long
lseek(fd, offset, whence)
int	fd;
long	offset;
int	whence;
{
	int err;
	long cur_mark, leof, new_mark;
	IOParam p;

	if (!ft[--fd].inuse) {
		errno = EBADF;
		return -1;
	}

	isetup(&p);
	p.ioRefNum = ft[fd].refnum;
	if ((err = PBGetFPos((ParamBlockRec *)&p, 0)) != noErr)
		return cvt_err(err);

	cur_mark = p.ioPosOffset;
	isetup(&p);
	p.ioRefNum = ft[fd].refnum;
	if ((err = PBGetEOF((ParamBlockRec *)&p, 0)) != noErr)
		return cvt_err(err);

	leof = (long) p.ioMisc;
	switch(whence) {
	case 0:
		new_mark = offset;
		break;
	case 1:
		new_mark = offset + cur_mark;
		break;
	case 2:
		new_mark = offset + leof;
		break;
	default:
		errno = EINVAL;
		return -1;
	}
	if (new_mark > leof) {
		/* need more space in file -- grow it */
		isetup(&p);
		p.ioRefNum = ft[fd].refnum;
		p.ioMisc = (Ptr) new_mark;
		if ((err = PBSetEOF((ParamBlockRec *)&p, 0)) != noErr)
			return cvt_err(err);
	}
	isetup(&p);
	p.ioRefNum = ft[fd].refnum;
	p.ioPosOffset = new_mark;
	p.ioPosMode = fsFromStart;
	if ((err = PBSetFPos((ParamBlockRec *)&p, 0)) != noErr)
		return cvt_err(err);
	errno = 0;
	return p.ioPosOffset;
}

/* delete file, if it exists */

int
unlink(name)
const char *name;
{
	int fd, err;
	HParamBlockRec p;

	fsetup(&p);
	p.fileParam.ioNamePtr = cvt_fnm(name);
	if ((err = PBHDelete(&p, 0)) != noErr && err != fnfErr)
		return cvt_err(err);
	return 0;
}

/* Console read routine */

private ZXchar rawgetc proto((void));

private SSIZE_T
con_read(buf, size)
char *buf;
size_t size;
{
	size_t n;
	ZXchar p;


	n = 0;
	do {
		p = rawgetc();
		*buf++ = p;
		n++;
	} while (rawchkc() && n <= size);
	return n;
}

void
dobell(n)	/* declared in term.h */
int	n;
{
	while (--n >= 0)
		SysBeep(5);
	flushscreen();
}

/* Simplified stat() routine emulates what is needed most. */

int
stat(fname, buf)
const char *fname;
struct stat *buf;
{
	CInfoPBRec p;
	StringPtr nm;

	nm = cvt_fnm(fname);
	byte_zero(&p, sizeof(CInfoPBRec));
	p.hFileInfo.ioCompletion = 0;
	p.hFileInfo.ioNamePtr = nm;
	p.hFileInfo.ioFVersNum = 0;
	p.hFileInfo.ioFDirIndex = 0;
	p.hFileInfo.ioVRefNum = cur_vol;
	p.hFileInfo.ioDirID = cur_dir;

	switch (PBGetCatInfo(&p, 0)) {
	case noErr:
		errno = 0;
		buf->st_dev = p.hFileInfo.ioVRefNum + 1;	/* don't want 0 */
		buf->st_ino = p.hFileInfo.ioDirID;
		buf->st_size = p.hFileInfo.ioFlLgLen;
		buf->st_mtime = p.hFileInfo.ioFlMdDat;
		buf->st_mode = (p.hFileInfo.ioFlAttrib & 0x10) ? S_IFDIR : S_IFREG;
		return 0;
	case nsvErr:
	case paramErr:
	case bdNamErr:
	case fnfErr:
		errno = ENOENT;
		break;
	case ioErr:
		errno = EIO;
		break;
	default:
		errno = ENOENT;
		break;
	}
	return -1;
}

/* Directory related routines.  Jove keeps track of the true Volume (disk)
   number and directory number, and avoids "Working Directory Reference
   Numbers", which are confusing. */

private int
getdir()	/* call this only once, during startup. */
{
	WDPBRec p;

	p.ioCompletion = 0;
	p.ioNamePtr = NULL;
	if (PBHGetVol(&p, 0) != noErr)
		return -1;	/* BIG trouble (but caller never checks returned value!) */
	cur_vol = p.ioWDVRefNum;
	cur_dir = p.ioWDDirID;
	SFSaveDisk = 0 - cur_vol;	/* these are for SF dialogs */
	CurDirStore = cur_dir;
	return 0;
}

private int
setdir(vol, dir)
int	vol;
long	dir;
{
	WDPBRec p;

	p.ioCompletion = 0;
	p.ioNamePtr = NULL;
	p.ioVRefNum = vol;
	p.ioWDDirID = dir;
	if (PBHSetVol(&p, 0) != noErr)
		return -1;

	cur_vol = vol;
	cur_dir = dir;
	SFSaveDisk = 0 - vol;	/* these are for SF dialogs */
	CurDirStore = dir;
	return 0;
}

private bool
lookupdir(dir, d)
const char	*dir;	/* UNIX-like pathname for directory */
CInfoPBPtr	d;	/* info from directory */
{
	char
		nm[FILESIZE + 1],
		*t;

	if (strcmp(dir, ".") == 0)
		getcwd(nm, sizeof(nm) - 1);
	else
		strcpy(nm, dir);

	for (t = nm; (t = strchr(t, '/')) != NULL; )
		*t++ = ':';

	t = nm;	/* get rid of initial slashes */
	while (*t == ':')
		t++;

	strcat(t, ":");	/* force trailing ':', signifying directory */

	byte_zero(d, sizeof(*d));
	/* d->dirInfo.ioCompletion = 0; */
	d->dirInfo.ioNamePtr = CtoPstr(t);
	d->dirInfo.ioVRefNum = cur_vol;
	/* d->dirInfo.ioFDirIndex = 0; */
	/* d->dirInfo.ioDrDirID = 0; */
	PBGetCatInfo(d, 0);
	return d->dirInfo.ioResult == noErr
		&& (d->dirInfo.ioFlAttrib & 0x10) != 0;
}

int
chdir(dir)
const char *dir;
{
	CInfoPBRec d;

	if (strcmp(dir, "/") == 0	/* There is no root... */
	|| !lookupdir(dir, &d)
	|| setdir(d.dirInfo.ioVRefNum, d.dirInfo.ioDrDirID) < 0)
		return -1;
	return 0;
}

/* Scandir returns the number of entries or -1 if the directory cannot
   be opened or malloc fails.
   Note: if we ever support RECOVER, this code will have to be moved
   to scandir.c */

int
jscandir(dir, nmptr, qualify, sorter)
char	*dir;
char	***nmptr;
bool	(*qualify) ptrproto((char *));
int	(*sorter) ptrproto((UnivConstPtr, UnivConstPtr));
{
	long DirID;
	char	**ourarray;
	unsigned int	nalloc = 10,
			nentries = 0,
			index = 1;

	if (strcmp(dir, "/") == 0) {
		/* we are enumerating volumes */
		DirID = 0;
	} else {
		/* we are enumerating the contents of a volume or directory */
		CInfoPBRec	d;

		if (!lookupdir(dir, &d))
			return -1;
		DirID = d.dirInfo.ioDrDirID;
	}

	ourarray = (char **) emalloc(nalloc * sizeof (char *));
	for (;;) {
		Str32 name;	/* 31 is limit, but we might add a '/' */

		if (DirID == 0) {
			/* we are enumerating volumes */
			ParamBlockRec	d;

			byte_zero(&d, sizeof(d));
			d.volumeParam.ioCompletion = 0;
			d.volumeParam.ioNamePtr = name;
			d.volumeParam.ioVRefNum = 0;
			d.volumeParam.ioVolIndex = index++;
			if (PBGetVInfo(&d, 0) != noErr)
				break;	/* we are done, then */
			PtoCstr(name);
#ifdef DIRECTORY_ADD_SLASH
			/* I *think* this has got to be a volume */
			strcat((char *)name, "/");
#endif

		} else {
			/* we are enumerating the contents of a volume or directory */
			CInfoPBRec	d;

			byte_zero(&d, sizeof(d));
			d.dirInfo.ioCompletion = 0;
			d.dirInfo.ioNamePtr = name;
			d.dirInfo.ioVRefNum = cur_vol;
			d.dirInfo.ioFDirIndex = index++;
			d.dirInfo.ioDrDirID = DirID;	/* .ioDirID == .ioDrDirID */
			if (PBGetCatInfo(&d, 0) != noErr)
				break;	/* we are done, then */
			PtoCstr(name);
#ifdef DIRECTORY_ADD_SLASH
			if (d.dirInfo.ioFlAttrib & 0x10)	/* see Inside Mac IV-122 */
				strcat((char *)name, "/");
#endif
		}
		if (qualify != NULL && !(*qualify)((char *) name))
			continue;
		/* note: test ensures one space left in ourarray for NULL */
		if (nentries+1 == nalloc)
			ourarray = (char **) erealloc((char *) ourarray, (nalloc += 10) * sizeof (char *));
		ourarray[nentries++] = copystr((char *)name);
	}
	ourarray[nentries] = NULL;

	if (sorter != NULL)
		qsort((char *) ourarray, nentries, sizeof (char **), sorter);
	*nmptr = ourarray;

	return nentries;
}


char *
getcwd(buf, size)
char	*buf;
size_t	size;
{
	CInfoPBRec d;
	Str31 nm;
	char	*p = buf + size;	/* build from right */

	if (p == buf)
		return NULL;	/* not even room for NUL */

	*--p = '\0';

	for (d.dirInfo.ioDrDirID = cur_dir; ; d.dirInfo.ioDrDirID = d.dirInfo.ioDrParID) {
		d.dirInfo.ioCompletion = 0;
		d.dirInfo.ioNamePtr = nm;
		d.dirInfo.ioVRefNum = cur_vol;
		d.dirInfo.ioFDirIndex = -1;
		PBGetCatInfo(&d, 0);
		if (d.dirInfo.ioResult != noErr)
			return NULL;

		if (p - buf <= Length(nm))
			return NULL;	/* insufficient room for / and name */

		p -= Length(nm);
		memcpy((UnivPtr)p, (UnivPtr) (nm+1), Length(nm));
		*--p = '/';

		if (d.dirInfo.ioDrDirID == 2)
			break;	/* home directory */
	}
	strcpy(buf, p);	/* left justify */
	return buf;
}

char *
gethome()		/* this will be startup directory */
{
	static char *ret = NULL;
	char	space[FILESIZE];

	if (ret == NULL)
		ret = copystr(getcwd(space, sizeof(space)));
	return ret;
}



/* Routines that put up and manipulate the "About Jove" dialog. */


/* (ORIGINALLY IN) about_j.c. */


#define DLOGNAME "\pABOUT_JDLOG"

#define DONE_ITEM 1
#define LIST_ITEM 2


#define DWIDTH 460		/* there should be an easy way to get this */
#define DHEIGHT 240		/* from the resource file! */

WindowPtr makedisplay();
ListHandle makelist();


private WindowPtr theWindow;
private ListHandle theList;
private Rect theListRect;
private EventRecord theEvent;



private void
	do_list proto((void)),
	do_events proto((void));

private WindowPtr
	makedisplay proto((void));

private ListHandle
	makelist proto((void));

private void
about_j()
{
	WindowPtr OldWindow;

	GetPort(&OldWindow);

	if ((theWindow = makedisplay()) == 0)
		return;
	SetPort(theWindow);
	if (theList = makelist()) {
		LActivate(1, theList);
		do_list();
		ShowWindow(theWindow);
		do_events();
	}
	SetPort(OldWindow);
	LDispose(theList);
	DisposDialog(theWindow);
}


private WindowPtr
makedisplay()
{
	static short dlogid = 0;

	DialogPtr theDialog;
	Handle theHandle;
	Handle theResource;
	Str255 buf;
	ResType resType;
	short itemType;
	Rect theRect;
	short dh, dv;	/* to center dialog on the screen */
	Str255 nostring;

	if (dlogid == 0) {
		if ((theResource = GetNamedResource('DLOG', DLOGNAME)) == NULL)
			return (WindowPtr)NULL;
		itemType = 'DLOG';
		GetResInfo(theResource, &dlogid, &resType, buf);
	}

	theDialog = GetNewDialog(dlogid, 0L, (WindowPtr) -1);
	nostring[0] = 0;	/* set length of Pascal String to 0 */
	ParamText(
		"\pMacJove - Copyright (C) 1986-1996 J. Payne, K. Gegenfurtner,",
		"\pK. Mitchum. Portions (C) THINK Technologies, Inc.",
		nostring, nostring);

	dh = qd.screenBits.bounds.left + (qd.screenBits.bounds.right - DWIDTH) / 2;
	dv = qd.screenBits.bounds.top  + (qd.screenBits.bounds.bottom - DHEIGHT) / 2;
	MoveWindow((WindowPtr)theDialog, dh, dv, 0);
	ShowWindow((WindowPtr)theDialog);


	GetDItem(theDialog, LIST_ITEM, &itemType, &theHandle, &theRect);
	theListRect = theRect;
	theListRect.right -= 15;
	((WindowPtr)theDialog)->txFont = FONT;
	((WindowPtr)theDialog)->txSize = TEXTSIZE;

	return (WindowPtr) theDialog;
}

private void
do_display()		/* draw necessary controls, lines */
{
	Rect rViewF;		/* framing rect for list */
	int offset;

	rViewF = theListRect;

	rViewF.left--;
	rViewF.top--;
	rViewF.right++;
	rViewF.bottom++;
	FrameRect(&rViewF);

	DrawControls(theWindow);
}

private ListHandle
makelist()
{
	Point csize;
	Rect dataBounds, rView;	/* list boundaries */

	csize.h = csize.v = 0;
	SetRect(&dataBounds, 0, 0, 1, 0);
	return LNew(&theListRect, &dataBounds, csize, 0, theWindow, 0, 0, 0, 1);
}

private void
printbind(f, buf)
const struct cmd *f;
char *buf;
{
	char c;

	if (f->c_map == 0 || (c = f->c_key) == 0x7f) {
		strcpy(buf, "        ");
		return;
	}
	switch(f->c_map) {
	case F_MAINMAP:
		strcpy(buf, "     ");
		break;

	case F_PREF1MAP:
		strcpy(buf, " ESC ");
		break;

	case F_PREF2MAP:
		strcpy(buf, "  ^X ");
		break;
	}
	if (c < ' ') {
		buf[5] = '^';		/* control char */
		c |= 0x40;
	} else {
		buf[5] = ' ';
	}
	if ('a' <= c && c <= 'z')
		c &= 0x5f;
	buf[6] = c;
	buf[7] = ' ';
	buf[8] = '\0';
}

private void
do_list()
{
	int row, col;
	const struct cmd *f;
	char buf[255];
	Point theCell;

	theCell.h = 0;

	for (f = commands, row = 0; f->Name; f++, row++) {
		LAddRow(1, row, theList);
		theCell.v = row;

		printbind(f, buf);
		strcat(buf, f->Name);
		LSetCell(buf, strlen(buf), theCell, theList);
	}
}



private pascal Boolean
ProcFilter(theDialog, event, itemHit)
DialogPtr theDialog;
EventRecord *event;
short *itemHit;
{
	theEvent = *event;
	if (theEvent.what == keyDown && theEvent.message & charCodeMask == '\r') {
		*itemHit = 1;
		return YES;
	}
	if (theEvent.what == activateEvt && (WindowPtr) theEvent.message == theWindow) {
		LDoDraw(1, theList);
		LActivate(1, theList);
	}
	if (theEvent.what == updateEvt && (WindowPtr) theEvent.message == theWindow) {
		BeginUpdate(theWindow);
		do_display();
		DrawDialog(theWindow);
		LUpdate(theWindow->visRgn, theList);
		EndUpdate(theWindow);
	}

	return NO;
}


void
do_events()
{
	short item;
	bool done = NO;
	Point p;

	while (!done) {
		ModalDialog(ProcFilter, &item);
		switch(item) {
		case DONE_ITEM:
			done = YES;
			/* ??? fall through? -- DHR */
		case LIST_ITEM:
			p = theEvent.where;
			GlobalToLocal(&p);
			LClick(p, theEvent.modifiers, theList);
			break;
		}
	}
}

/* Window and Control related routines. */

/* (ORIGINALLY IN) tcon.c.
   control handler routines for Jove. K. Mitchum 12/86 */


#define MINC 0
#define MAXC 100
#define INITC 0
#define EVENTLIST (mDownMask | keyDownMask )

private Point p;
private bool wc_adjust proto((int, int, struct wind_config *, int));

private void
	MakeScrollBar proto((Window *w)),
	AdjustScrollBar proto((Window *w)),
	drawfluff proto((void));

void
docontrols()	/* called from redisplay routines */
{
	Window *w;
	int top;

	w = fwind;
	top = 0;
	do {
		if (w->w_control != NULL)
			HideControl(w->w_control);
		w = w->w_next;
	} while (w != fwind);
	w = fwind;
	do {
		w->w_topline = top;
		if (w->w_control != NULL)
			AdjustScrollBar(w);
		else
			MakeScrollBar(w);
		ShowControl(w->w_control);
		top += w->w_height;
		w = w->w_next;
	} while (w != fwind);
	Windchange = NO;
	drawfluff();
}


private void
MakeScrollBar(w)	/* set up control */
Window *w;
{
	Rect BarRect;
	int wheight, wtop;
	WindowPtr window = theScreen;

	wheight = w->w_height;
	wtop = w->w_topline;
	SetRect(&BarRect, window->portRect.right - SCROLLWIDTH + 1,
		window->portRect.top -2 + wtop * HEIGHT,
		window->portRect.right +1,
		window->portRect.top + ((wheight + wtop) * HEIGHT + 1));
	w->w_control = NewControl(window, &BarRect, "\psbar", 1, INITC,
		MINC, MAXC, scrollBarProc, (long)w);
}

private void
AdjustScrollBar(w)	/* redo existing control */
Window *w;
{
	ControlHandle handle = w->w_control;;

	if (handle != NULL) {
		int	wtop = w->w_topline;
		int	wheight = w->w_height;
		WindowPtr	window = (*handle)->contrlOwner;

		SizeControl(handle, SCROLLWIDTH, wheight * HEIGHT + 1);

		MoveControl(handle, window->portRect.right - SCROLLWIDTH + 1,
			window->portRect.top - 1 + wtop * HEIGHT);
	}
}

private int ltoc proto((void));	/* calculate ctlvalue for line position */

void
SetScrollBar(w)	/* set value of the bar */
Window *w;
{
	SetCtlValue(w->w_control, ltoc());
}

private void
drawfluff()		/* draw controls and dividers */
{
	Window *w = fwind;

	DrawControls(theScreen);
	DrawGrowIcon(theScreen);
}

void
RemoveScrollBar(w)
Window *w;
{
	if (w->w_control != NULL)
		DisposeControl(w->w_control);
	w->w_control = NULL;
}

private pascal void
DScroll(control, part)
ControlHandle control;
int part;
{
	DownScroll();
	redisplay();
}

private pascal void
UScroll(control, part)
ControlHandle control;
int part;
{
	UpScroll();
	redisplay();
}

private pascal void
NPage(control, part)
ControlHandle control;
int part;
{	NextPage();
	redisplay();
}

private pascal void
PPage(control, part)
ControlHandle control;
int part;
{	PrevPage();
	redisplay();
}

private long npos;	/* number of lines in buffer */

private int
ltoc()	/* calculate ctlvalue for line position */
{
	long ipos = LinesTo(curbuf->b_first, curline) + 1;

	npos = ipos + LinesTo(curline, (LinePtr)NULL) - 1;
	return (int) ((ipos * MAXC) / npos);
}

private LinePtr
ctol(ctlv)	/* find buffer line for ctlvalue */
int ctlv;
{
	return next_line(curbuf->b_first, (int) ((npos * ctlv)/MAXC));
}

private void
doWind(event, window)
EventRecord *event;
WindowPtr window;
{
	p = event->where;
	GlobalToLocal(&p);

	if (event->what == mouseDown) {
		ControlHandle whichControl;
		Window
			*jwind,
			*cwind;
		bool	notcurwind = NO;
		int	cpart;	/* control part */

		if ((cpart = FindControl(p, window, &whichControl)) == 0)
			return;

		if ((jwind = (Window *) (*whichControl)->contrlRfCon) != curwind) {
			notcurwind = YES;
			cwind = curwind;
			SetWind(jwind);
		}
		switch (cpart) {
		case inUpButton:
			TrackControl(whichControl, p, (ProcPtr) DScroll);
			break;
		case inDownButton:
			TrackControl(whichControl, p, (ProcPtr) UScroll);
			break;
		case inPageUp:
			TrackControl(whichControl, p, (ProcPtr) PPage);
			break;
		case inPageDown:
			TrackControl(whichControl, p, (ProcPtr) NPage);
			break;
		case inThumb:
			if (TrackControl(whichControl, p, (ProcPtr)NULL)) {
				int	newval = GetCtlValue(whichControl);

				if (newval == MAXC)
					Eof();
				else if (newval == MINC)
					Bof();
				else
					SetLine(ctol(newval));
			}
			break;
		}
		if (notcurwind) {
			SetWind(cwind);
			redisplay();
		}
		redisplay();	/* again, to set the cursor */
	} else {
		if (findtext())
			redisplay();
	}
}

#define std_state(w) (*((WStateData **)((WindowPeek)((w)))->dataHandle))->stdState
#define user_state(w) (*((WStateData **)((WindowPeek)((w)))->dataHandle))->userState

private void
doDrag(event, window)
EventRecord *event;
WindowPtr window;
{
	Rect old_std = std_state(window);

	DragWindow(window, event->where, &LimitRect);
	if (wc == &wc_std) {
		wc_user = wc_std;
		user_state(theScreen) = std_state(theScreen);
		ZoomWindow(window, 7, 1);
		wc = &wc_user;
		Reset_std();
	}
}

private void
doGrow(event, window)
EventRecord *event;
WindowPtr window;
{
	long size;

	/* zero means user didn't change anything */
	if ((size = GrowWindow(window, event->where, &LimitRect)) != 0) {
		if (wc == &wc_std) {
			wc_user = wc_std;
			user_state(theScreen) = std_state(theScreen);
			ZoomWindow(window, 7, 1);
			wc = &wc_user;
			Reset_std();
		}
		if (wc_adjust(LoWord(size), HiWord(size), wc, 0)) {
			EraseRect(&window->portRect);
			SizeWindow(window, wc->w_width, wc->w_height, YES);
			win_reshape(0);	/* no signals here... */
		}
	}
}

private void
doZoomIn(event, window)
EventRecord *event;
WindowPtr window;
{
	if (TrackBox(window, event->where, 7)) {
			EraseRect(&window->portRect);
			ZoomWindow(window, 7, 1);
			wc = &wc_user;
			win_reshape(0);	/* we do our own toggle, not ZoomWindow() */
		}
}

private void
doZoomOut(event, window)
EventRecord *event;
WindowPtr window;
{
	if (TrackBox(window, event->where, 8)) {
			EraseRect(&window->portRect);
			ZoomWindow(window, 8, 1);
			wc = &wc_std;
			win_reshape(0);	/* we do our own toggle, not ZoomWindow() */
		}
}

private void
doGoAway(event, window)
EventRecord *event;
WindowPtr window;
{
	if (TrackGoAway(window, event->where))
		Leave();
}

private Window *
rtowind(row)	/* return jove window row is in */
int row;
{
	Window *w = fwind;

	do {
		if ((w->w_topline <= row) && ((w->w_height + w->w_topline) > row))
			return w;
		w = w->w_next;
	} while (w != fwind);
	return NULL;
}

private LinePtr
windtol(w, row)		/* return line for row in window */
Window *w;
int row;
{
	LinePtr l = w->w_top;

	while (row-- && l != NULL)
		l = l->l_next;
	return l;
}

private int	ptoxy proto((Point, int *, int *));	/* convert Point to terminal x, y coordinate */

private bool
findtext()		/* locate and move the point to match the mouse */
{
	int row, col;
	int offset;
	long ticks;
	EventRecord event;
	Window *w;
	LinePtr l;

	ticks = Ticks;
	ptoxy(p, &row, &col);
	if ((w = rtowind(row)) == NULL)
		return NO;

	if (w != curwind)
		SetWind(w);
	offset = PhysScreen[row].s_offset;	/* account for horizontal scrolling and */
	offset += SIWIDTH(offset) + W_NUMWIDTH(w);	/* line number */
	row -= w->w_topline;		/* now have row number in window */
	if (row >= w->w_height -1)
		return NO;

	if ((l = windtol(w, row)) == NULL)
		return NO;

	if (l->l_dline == NULL_DADDR)
		return NO;

	this_cmd = LINECMD;
	SetLine(l);		/* Curline is in linebuf now */
	col -= offset;
	if (col < 0)
		col = 0;
	curchar = how_far(curline, col);
	do {
		if (GetNextEvent(mUpMask, &event) && (event.when < ticks + DoubleTime)) {
			set_mark();
			break;
		}
	} while ((Ticks - ticks) < DoubleTime);
	return YES;
}


private int
ptoxy(p, row, col)	/* convert Point to terminal x, y coordinate */
Point p;
int *row, *col;
{
	*row = (p.v / HEIGHT);
	*col = (p.h / WIDTH );
	if ((*row > MAXROW) || (*col > MAXCOL))
		return JMP_ERROR;
	return 0;
}

/* Event-related routines.  The Event loop is CheckEvents(), and is called
   whenever a console read occurs or a call to charp().  During certain
   activities, such as ask(), etc. non-keyboard events are ignored.
   This is set by the variable Keyonly.  As an update or activate event
   generates a call to redisplay(), it is important that redisplay() and
   related routines NOT check for keyboard characters. */

/* (ORIGINALLY IN) tevent.c
	event handler for Jove. K Mitchum 12/86 */


#define SYS_ID 100
#define NOFUNC ((void (*) ptrproto((EventRecord *event)))NULL)
#define NEVENTS 16

private void
	doMouse proto((EventRecord *event)),
	dokeyDown proto((EventRecord *event)),
	doUpdate proto((EventRecord *event)),
	doActivate proto((EventRecord *event));

private void p_refresh proto((void));

private MenuHandle SysMenu;

private void (*eventlist[]) ptrproto((EventRecord *event)) =
{
	NOFUNC,	/* nullEvent */
	doMouse,	/* mouseDown */
	doMouse,	/* mouseUp */
	dokeyDown,	/* keyDown */
	NOFUNC,	/* keyUp */
	dokeyDown,	/* autoKey */
	doUpdate,	/* updateEvt */
	NOFUNC,	/* diskEvt */
	doActivate,	/* activateEvt */
	NOFUNC,	/* not  used */
	NOFUNC,	/* networkEvt = 10 */
	NOFUNC,	/* driverEvt */
	NOFUNC,	/* app1Evt */
	NOFUNC,	/* app2Evt */
	NOFUNC,	/* app3Evt */
	NOFUNC	/* app4Ev */
};


private void
	SetBufMenu proto((void)),
	MarkModes proto((void));

private void
CheckEvents()
{
	EventRecord theEvent;
	static long time = 0;

	static void (*fptr) ptrproto((EventRecord *event));

	if (FrontWindow() == window) {
		Point Mousep;

		GetMouse(&Mousep);
		if (PtInRect(Mousep, &r))
			SetCursor(*cross);
		else
			SetCursor(&qd.arrow);
	}

	SystemTask();
	if (EventCmd && !Keyonly)
		return;
	if (Bufchange)
		SetBufMenu();
	if (Modechange)
		MarkModes();
	while (GetNextEvent(everyEvent, &theEvent)) {
		if ((theEvent.what < NEVENTS) && (fptr = eventlist[theEvent.what])) {
			(*fptr)(&theEvent);
		}
		SystemTask();
	}
	if (TimeDisplayed && (Ticks - time) > 3600) {
		time = Ticks;
		UpdModLine = YES;
		redisplay();
	}
}

private void InitLocalMenus proto((void));

private void
InitSysMenu()
{
	SysMenu = NewMenu(SYS_ID, "\p\24");
	AppendMenu(SysMenu, "\pAbout Jove");
	AddResMenu(SysMenu, 'DRVR');
	InsertMenu(SysMenu, 0);
	InitLocalMenus();
	DrawMenuBar();
}

private void
	doWind proto((EventRecord *event, WindowPtr window)),
	doGoAway proto((EventRecord *event, WindowPtr window)),
	doSysMenu proto((EventRecord *event, WindowPtr window)),
	doSysClick proto((EventRecord *event, WindowPtr window)),
	doDrag proto((EventRecord *event, WindowPtr window)),
	doGrow proto((EventRecord *event, WindowPtr window)),
	doZoomIn proto((EventRecord *event, WindowPtr window)),
	doZoomOut proto((EventRecord *event, WindowPtr window));

#define NMEVENTS 9

private void (*mouselist[]) ptrproto((EventRecord *event, WindowPtr window)) =
{
	(void (*) ptrproto((EventRecord *event, WindowPtr window)))NULL,	/* inDesk */
	doSysMenu,	/* inMenuBar */
	doSysClick,	/* inSysWindow */
	doWind,	/* inContent */
	doDrag,	/* inDrag */
	doGrow,	/* inGrow */
	doGoAway,	/* inGoAway */
	doZoomIn,	/* inZoomIn */
	doZoomOut	/* inZoomOut */
};


private void
doMouse(event)
EventRecord *event;
{
	if (Keyonly) {
		if (event->what == mouseDown)
			SysBeep(2);
	} else {
		WindowPtr theWindow;
		int wpart = FindWindow(event->where, &theWindow);
		void (*fptr) ptrproto((EventRecord *event, WindowPtr window));

		if (wpart < NMEVENTS && (fptr = mouselist[wpart]) != NULL)
			(*fptr)(event, theWindow);
	}
}

private void ProcMenu proto((int menuno, int itemno));

private void
doSysMenu(event, window)
EventRecord *event;
WindowPtr window;
{
	long result = MenuSelect(event->where);
	int	Menu = (result >> 16) & 0xffff;
	int	Item = result & 0xffff;

	if (Item == 0)
		return;	/* no choice made */

	if (Menu == SYS_ID) {			/* apple menu */
		Str255 Name;
		GrafPtr Port;

		if (Item == 1) {
			about_j();
		} else {
			GetItem(SysMenu, Item, Name);
			GetPort(&Port);
			OpenDeskAcc(Name);
			SetPort(Port);
		}
	} else {
		ProcMenu(Menu, Item);
	}
	HiliteMenu(0);
	EventCmd = YES;
	menus_on();
}

private void
doSysClick(event, window)
EventRecord *event;
WindowPtr window;
{
	SystemClick(event, window);
}


private void
doUpdate(event)
EventRecord *event;
{
	WindowPtr
		theWindow = (WindowPtr) event->message,
		oldPort;

	GetPort(&oldPort);
	SetPort(theWindow);
	BeginUpdate(theWindow);
	p_refresh();
	drawfluff();
	EndUpdate(theWindow);
	SetPort(oldPort);
}

private void
doActivate(event)
EventRecord *event;
{
	WindowPtr theWindow = (WindowPtr) event->message;
	ControlHandle control;
	int hilite;

	SetPort(theWindow);
	hilite = (event->modifiers & activeFlag)? 0 : 255;
	for (control = (ControlHandle) (((WindowPeek) theWindow)->controlList)
	; (control != 0); control = (*control)->nextControl)
	{
			HiliteControl(control, hilite);
	}
}

/* Keyboard routines. */

/* Keycodes (from Inside MacIntosh I-251).  This table is ONLY used when
 * we are trying to make the Option key work as a Meta key.  When we are
 * doing this, the system-supplied character is wrong, so we retranslate
 * the key code to a character code.
 *
 * Since we only use this table when the character generated by an
 * option-modified key is greater than DEL, and since the Option
 * modifier does not so affect keypad keys, we need not provide for
 * them in this table.
 *
 * ??? This may need to be updated to reflect keyboards newer than the Mac+!
 */

#define NOKEY '?'

private char nsh_keycodes[] = {
	'a','s','d','f','h',					/* 00 - 04 */
	'g','z','x','c','v',					/* 05 - 09 */
	NOKEY,'b','q','w','e',					/* 0A - 0E */
	'r','y','t','1','2',					/* 0F - 13 */
	'3','4','6','5','=',					/* 14 - 18 */
	'9','7','-','8','0',					/* 19 - 1D */
	']','O','u','[','i',					/* 1E - 22 */
	'p',CR,'l','j','\'',					/* 23 - 27 */
	'k',';','\\',',','/',					/* 28 - 2C */
	'n','m','.','\t',NOKEY,					/* 2D - 31 */
	'`',DEL									/* 32 - 33*/
};

private char sh_keycodes[] = {
	'A','S','D','F','H',					/* 00 - 04 */
	'G','Z','X','C','V',					/* 05 - 09 */
	NOKEY,'B','Q','W','E',					/* 0A - 0E */
	'R','Y','T','!','@',					/* 0F - 13 */
	'#','$','^','%','+',					/* 14 - 18 */
	'(','&','_','*',')',					/* 19 - 1D */
	'}','O','U','{','I',					/* 1E - 22 */
	'P',CR,'L','J','\'',					/* 23 - 27 */
	'K',';','|','<','?',					/* 28 - 2C */
	'N','M','>','\t',NOKEY,					/* 2D - 31 */
	'~',DEL									/* 32 - 33 */
};

/* (ORIGINALLY IN) tkey.c
   keyboard routines for Macintosh. K Mitchum 12/86 */

jmp_buf auxjmp;

private nchars = 0;
private char charbuf[MCHARS];

/* The following kludges a meta key out of the option key by
   sending an escape sequence back to the dispatch routines.  This is
   not elegant but it works, and doesn't alter escape sequences for
   those that prefer them.  To remap the control or meta keys,
   see mackeys.h. */

private void
dokeyDown(event)
EventRecord *event;
{
	unsigned mods;
	int c;
	static int cptr = 0;

	if (MCHARS - nchars < 2)
		return;

	c  = event->message & charCodeMask;

	mods = event->modifiers;

	if (MetaKey && (mods & optionKey)) {
		/* Treat the Option key as a Meta key.
		 * We have to "undo" the normal option key effect.
		 * This means that, if the character is greater than DEL
		 * and the code is known to our table, we retranslate the
		 * code into a character.
		 * This seems pretty dubious.  I wonder if "KeyTrans" would
		 * be a better tool.
		 */
		int	code = (event->message & keyCodeMask) >> 8;

		if (c > DEL && code < elemsof(sh_keycodes))
			c  = ((mods & shiftKey)? sh_keycodes : nsh_keycodes)[code];

		/* jam an ESC prefix */
		charbuf[cptr++] = ESC;
		cptr &= NCHMASK;
		nchars++;
	}

	if (mods & (cmdKey | controlKey)) {
		/* control key (command key is treated as a control key too) */
		if (c == '@' || c == '2' || c == ' ')
			c = '\0';	/* so we have a null char */
		if (c != '`')
			c = CTL(c);		/* make a control char */
	} else if (c == '`') {
		c = ESC;	/* for those used to escapes */
	}

	charbuf[cptr++] = c;
	cptr &= NCHMASK;
	nchars++;
}

private ZXchar
rawgetc()
{
	static int cptr = 0;
	ZXchar c;

	if (EventCmd)
		longjmp(auxjmp, 1);

	while (nchars <= 0) {
		nchars = 0;
		if (EventCmd)
			longjmp(auxjmp, 1);

		CheckEvents();	/* ugh! WAIT for a character */
	}
	nchars--;
	c = ZXRC(charbuf[cptr++]);
	cptr &= NCHMASK;		/* zero if necessary */
	return c;
}

bool
rawchkc()
{
	if (EventCmd)
		longjmp(auxjmp, 1);

	if (nchars == 0)
		CheckEvents();	/* this should NOT be necessary! */
	return nchars > 0;
}

/* Routines for calling the standard file dialogs, when macify is YES.
   If the user changes the directory using the file dialogs, Jove's notion
   of the current directory is updated. */


/* (ORIGINALLY IN) tmacf.c. K. Mitchum 12/86.
   Macify routines for jove. */

int CurrentVol;			/* see tfile.c */

#define TYPES  (-1)

private Point px = {100, 100};
private unsigned char pmess[] = "\pSave file as: ";

private pascal Boolean
Ffilter(p)
ParmBlkPtr p;
{
	Boolean r;
	char	*name;

	if (p->fileParam.ioFlFndrInfo.fdType == 'APPL')
		return YES;

	/* Filter out our tempfiles.
	 * ??? the test doesn't check to see if the directories match.
	 */
	name = PtoCstr(p->fileParam.ioNamePtr);
	r = strcmp(name, ".joveXXX") == 0
#ifdef ABBREV
		|| strcmp(name, ".jabbXXX") == 0
#endif
#ifdef RECOVER
		|| strcmp(name, ".jrecXXX") == 0
#endif
		;
	CtoPstr(name);
	return r;
}

private void
check_dir()
{
	if (cur_vol != 0 - SFSaveDisk || cur_dir != CurDirStore) {
		char	space[FILESIZE];

		setdir(0 - SFSaveDisk, CurDirStore);
		UpdModLine = YES;	/* make sure jove knows the change */
		Modechange = YES;
		setCWD(getcwd(space, sizeof(space)));
	}
}

char *
gfile(namebuf)	/* return a filename to get */
char *namebuf;
{
	SFReply frec;
	char ans[FILESIZE];

	SFSaveDisk = 0 - cur_vol;	/* in case a Desk Accessory changed them */
	CurDirStore = cur_dir;
	SFGetFile(px, 0L, Ffilter, TYPES, 0L, 0L, &frec);
	check_dir();	/* see if any change, set if so */
	if (frec.good) {
		EventRecord theEvent;

		do; while (GetNextEvent(updateMask, &theEvent) == 0);
		doUpdate(&theEvent);
		strcpy(ans, PtoCstr(frec.fName));
		CtoPstr((char *)frec.fName);
		PathParse(ans, namebuf);
		return namebuf;
	}
	return NULL;
}

char *
pfile(namebuf)
char *namebuf;
{
	SFReply frec;
	StringPtr nm;

	SFSaveDisk = 0 - cur_vol;	/* in case a Desk Accessory changed them */
	CurDirStore = cur_dir;
	strncpy(namebuf, filename(curbuf), FILESIZE-1);
	nm = cvt_fnm(namebuf);
	SFPutFile(px, pmess, nm, 0L, &frec);
	check_dir();	/* see if any change, set if so */
	if (frec.good) {
		EventRecord theEvent;
		char *h, *p;

		do; while (GetNextEvent(updateMask, &theEvent) == 0);
		doUpdate(&theEvent);
		h = PtoCstr(frec.fName);
		while (*h == ':')
			h++;	/* convert to unix style */
		for (p = h; (p = strchr(p, ':')) != NULL; )
			*p++ = '/';
		PathParse(h, namebuf);
		return namebuf;
	}
	return NULL;
}


/* getArgs() returns an argument list based on documents clicked on by the user. */

int
getArgs(avp)
char ***avp;
{
	int argc, old_vol;
	short nargs, type;
	long old_dir;
	char **argv;
	char *pathname;
	AppFile p;
	WDPBRec d;

	old_vol = cur_vol;
	old_dir = cur_dir;

	CountAppFiles(&type, &nargs);
	if (nargs > 0) {	/* files to open... */
		argv = (char **) emalloc((nargs + 2) * sizeof(char *));
		for (argc = 1; argc <= nargs; argc++) {
			GetAppFiles(argc, &p);
			if (type == 0) {
				char	space[FILESIZE];

				PtoCstr((StringPtr)p.fName);
				d.ioCompletion = 0;
				d.ioNamePtr = NULL;
				d.ioVRefNum = p.vRefNum;
				d.ioWDIndex = 0;
				PBGetWDInfo(&d, 0);
				cur_vol = d.ioWDVRefNum;
				cur_dir = d.ioWDDirID;
				pathname = getcwd(space, sizeof(space));
				argv[argc] = emalloc(strlen((char *)p.fName) + strlen(pathname) + 2);
				strcpy(argv[argc], pathname);
				strcat(argv[argc], "/");
				strcat(argv[argc], (char *)p.fName);
			}
			ClrAppFiles(argc);
		}
		if (type != 0)
			argc = 1;
	} else {
		argv = (char **) emalloc(2 * sizeof(char*));
		argc = 1;
	}
	argv[0] = "jove";

	argv[argc] = NULL;
	*avp = argv;
	cur_dir = old_dir;
	cur_vol = old_vol;
	return argc;
}

char *
mktemp(name)
char *name;
{
	return name;	/* what, me check? */
}


/* Menu routines.  The menus items are set up in a similar manner as keys, and
   are bound prior to runtime.  See menumaps.txt, which must be run through
   setmaps.  Unlike keys, menu items may be bound to variables, and to
   buffers.  Buffer binding is only done at runtime. */

private void
	InitMenu proto((struct menu *M)),
	make_edits proto((int menu));

private void
InitLocalMenus()
{
	int i;

	for (i = 0; i < NMENUS; i++) {
		InitMenu(&Menus[i]);
		if (i == 0)
			make_edits(Menus[i].menu_id + 1);
	}
}

private void
InitMenu(M)
struct menu *M;
{
	int i;
	StringPtr ps;

	if (M->menu_id == 0)
		return;

	M->Mn = NewMenu(M->menu_id, ps=CtoPstr(M->Name));
	PtoCstr(ps);

	for (i = 0; i < NMENUITEMS; i++) {
		data_obj *d = M->m[i];

		if (d == NULL)
			break;	/* last item... */

		switch (d->Type & TYPEMASK) {
		case STRING:
			AppendMenu(M->Mn, ps=CtoPstr(d->Name));
			PtoCstr(ps);
			break;
		case VARIABLE:
			AppendMenu(M->Mn, ps=CtoPstr(d->Name));
			PtoCstr(ps);
			if ((((struct variable *)d)->v_flags & V_TYPEMASK) == V_BOOL
			&& *(bool *)(((struct variable *)d)->v_value))
				CheckItem(M->Mn, i + 1, YES);
			break;
		case COMMAND:
			AppendMenu(M->Mn, ps=CtoPstr(d->Name));
			PtoCstr(ps);
			break;
		}
	}
	InsertMenu(M->Mn, 0);
}

private void	MacSetVar proto((struct variable *vp, int mnu, int itm));

private void
ProcMenu(menuno, itemno)
int menuno, itemno;
{
	int i;
	data_obj *d;

	for (i = 0; i < NMENUS; i++) {
		if (Menus[i].menu_id == menuno) {
			itemno--;
			d = Menus[i].m[itemno];
			switch(d->Type & TYPEMASK) {
			case COMMAND:
				ExecCmd((data_obj *) d);
				break;
			case BUFFER:
				SetABuf(curbuf);
				tiewind(curwind, (Buffer *) d);
				SetBuf((Buffer *) d);
				break;
			case VARIABLE:
				MacSetVar((struct variable *) d, i, itemno);
				break;
			}
			break;
		}
	}
}


private void
make_edits(menu)	/* add dummy edit menu */
int menu;
{
	MenuHandle M;
	int item;
	char *fname;

	M = NewMenu((menu), "\pEdit");
	AppendMenu(M,
		"\pUndo/Z;(-;Cut/X;Copy/C;Paste/V;Clear;Select All;(-;Show Clipboard");
	InsertMenu(M, 0);
	DisableItem(M, 0);
}

void
menus_off()
{
	int i;

	if (Keyonly || EventCmd)
		return;

#ifdef MENU_DISABLE		/* NOBODY likes this, but it's here if you want it... */
	DisableItem(SysMenu, 0);
	for (i = 0; i < NMENUS; i++)
		if (Menus[i].Mn)
			DisableItem(Menus[i].Mn, 0);
	DrawMenuBar();
#endif
	Keyonly = YES;
}

void
menus_on()
{
	int i;

	if (!Keyonly)
		return;

#ifdef MENU_DISABLE
	EnableItem(SysMenu, 0);
	for (i = 0; i < NMENUS; i++)
		if (Menus[i].Mn)
			EnableItem(Menus[i].Mn, 0);
	DrawMenuBar();
#endif
	Keyonly = NO;
}

private char *
BufMPrint(b, i)
Buffer	*b;
int	i;
{
	char *p;
	char *nm = filename(b);
	char t[35];

	if (strlen(nm) > 30) {
		strcpy(t, "...");
		strcat(t, nm + strlen(nm) - 30);
	} else {
		strcpy(t, nm);
	}
	nm = t;
	while (*nm) {
		switch(*nm) {	/* ugh... these are metacharacter for Menus */
		case '/':
			*nm = ':';
			break;
		case '^':
		case '!':
		case '<':
		case '(':
		case ';':
			*nm = '.';
			break;	/* that will confuse everybody */
		}
		nm++;
	}
	p = sprint("%-2d %-11s \"%-s\"", i, b->b_name, t);
	return p;
}

private void
SetBufMenu()
{
	Buffer *b;
	int i, j, stop;
	struct menu *M;

	Bufchange = NO;
	for (i = 0; i < NMENUS; i++) {
		if (strcmp(Menus[i].Name, "Buffer") == 0) {
			M = &Menus[i];
			for (j = 0; j < NMENUITEMS; j++) {
				data_obj *d = Menus[i].m[j];

				if (d == NULL)
					break;

				if ((d->Type & TYPEMASK) == BUFFER) {
					for (i = j, b = world; i < NMENUITEMS && b != NULL; i++, b = b->b_next) {

						if (M->m[i] == NULL)
							AppendMenu(M->Mn, CtoPstr(BufMPrint(b, i-j+1)));	/* add the item */
						else
							SetItem(M->Mn, i + 1, CtoPstr(BufMPrint(b, i-j+1)));	/* or change it */
						M->m[i] = (data_obj *) b;
					}
					stop = i;
					/* out of buffers? */
					for (; i < NMENUITEMS && M->m[i]; i++) {
						DelMenuItem(M->Mn, stop + 1);	/* take off last item */
						M->m[i] = NULL;
					}
					break;
				}
			}
			break;
		}
	}
}

private void
MacSetVar(vp, mnu, itm)	/* Set a variable from the menu */
struct variable *vp;
int mnu, itm;
{
	if ((vp->v_flags & V_TYPEMASK) == V_BOOL) {
		/* toggle the value */
		*((bool *) vp->v_value) = !*((bool *) vp->v_value);
		MarkVar(vp, mnu, itm);
	} else {
		char	prompt[128];

		swritef(prompt, sizeof(prompt), "Set %s: ", vp->Name);
		vset_aux(vp, prompt);
	}
}

private void
MarkModes()
{
	int mnu, itm;
	data_obj *d;

	Modechange = NO;
	for (mnu = 0; mnu < NMENUS; mnu++) {
		for (itm = 0; itm < NMENUITEMS; itm++) {
			if ((d = Menus[mnu].m[itm]) == NULL)
				break;

			if ((d->Type & (MAJOR_MODE | MINOR_MODE))
			|| ((d->Type & TYPEMASK) == BUFFER))
			{
				bool	checked;

				if (d->Type & (MAJOR_MODE))
					checked = curbuf->b_major == (d->Type >> 8);
				else if (d->Type & (MINOR_MODE))
					checked = (curbuf->b_minor & (d->Type >> 8)) != 0;
				else
					checked = d == (data_obj *) curbuf;
				CheckItem(Menus[mnu].Mn, itm + 1, checked);
			}
		}
	}
}

void
MarkVar(vp, mnu, itm)	/* mark a boolean menu item */
const struct variable *vp;
int mnu, itm;
{
	if (mnu == -1) {		/* we don't know the item... slow */
		for (mnu = 0; ; mnu++) {
			if (mnu >= NMENUS)
				return;	/* not found */
			for (itm = 0; (itm < NMENUITEMS); itm++) {
				if ((struct variable *) (Menus[mnu].m[itm]) == vp)
					break;
			}
			if (itm < NMENUITEMS)
				break;
		}
	}
	CheckItem(Menus[mnu].Mn, itm + 1, *(bool *)vp->v_value);
}

/* Screen routines and driver. The Macinitosh Text Edit routines are not utilized,
   as they are slow and cumbersome for a terminal emulator. Instead, direct QuickDraw
   calls are used. The fastest output is obtained writing a line at a time, rather
   than on a character basis, so the major output routine is writechr(), which takes
   a pascal-style string as an argument. See do_sputc() in screen.c. */

void
Placur(line, col)
int line, col;
{
	CapCol = col;
	CapLine = line;
	putcurs(line, col, YES);
}

void
NPlacur(line, col)
int line, col;
{
	CapCol = col;
	CapLine = line;
	putcurs(line, col, NO);
}

void
i_lines(top, bottom, num)
int top, bottom, num;
{
	Placur(bottom - num + 1, 0);
	dellines(num, bottom);
	Placur(top, 0);
	inslines(num, bottom);
}

void
d_lines(top, bottom, num)
int top, bottom, num;
{
	Placur(top, 0);
	dellines(num, bottom);
	Placur(bottom + 1 - num, 0);
	inslines(num, bottom);
}

/* (ORIGINALLY IN) tn.c   */
/* window driver for MacIntosh using windows. */
/* K. Mitchum 9/86 */


/*#define VARFONT*/
#ifdef VARFONT
private height, width, theight, twidth, descent;
#else
# define height HEIGHT
# define width WIDTH
# define theight THEIGHT
# define twidth TWIDTH
# define descent DESCENT
#endif

private int trow, tcol;
private bool	cursvis;
#ifdef NEVER
private bool insert;
#endif
private Rect cursor_rect;
private char *p_scr, *p_curs;	/* physical screen and cursor */
private int p_size;

private Rect  vRect;
private WindowRecord myWindowRec;

#define active() SetPort(theScreen)
#define maxadjust(r) OffsetRect((r), 0, 2)

private char *
conv_p_curs(row, col)
int	row,
	col;
{
	return p_scr + (row * (CO)) + col;
}

#ifdef NEVER
private void
INSmode(new)
bool new;
{
	insert = new;
}
#endif

void
SO_effect(new)
bool new;
{
	theScreen->txMode = new? notSrcCopy : srcCopy;
}

private void	init_slate proto((void));

private void
tn_init()
{
#ifdef NEVER
	INSmode(NO);
#endif
	init_slate();
	SO_off();
	ShowPen();
}

void
clr_page()	/* clear and home function */
{
	Rect r;

	memset(p_scr, ' ', p_size);
	active();
	SetRect(&r, 0, 0, WINDWIDTH, WINDHEIGHT);
	EraseRect(&r);
	putcurs(0, 0, NO);	/* ??? "NO" guess by DHR */
	drawfluff();
}

private void
putcurs(row, col, vis)
unsigned	row, col;
bool	vis;
{
	active();
	curset(NO);
	trow = row;
	tcol = col;
	curset(vis);
}

private void
curset(invert)
bool	invert;
{
	int
		colpix = tcol * width,
		rowpix = trow * height;

	if (trow == MAXROW)
		rowpix += 2;	/* leave space for 2 pixel rule */
	p_curs = conv_p_curs(trow, tcol);
	MoveTo(colpix, rowpix + height - descent);
	DrawChar(*p_curs);
	cursvis = invert;
	if (invert) {
		SetRect(&cursor_rect, colpix, rowpix,
			colpix + width - 1, rowpix + height - 1);
		InvertRect(&cursor_rect);
	}
	MoveTo(colpix, rowpix + height - descent);
}

void
clr_eoln()
{
		Rect r;

		active();
		SetRect(&r, tcol * width, trow * height, WINDWIDTH, (trow +1) * height);
		if (trow == MAXROW)
			maxadjust(&r);
		EraseRect(&r);
		memset(p_curs, ' ', CO - tcol);
		curset(YES);
}

#ifdef NEVER
private void
delchars()
{
	Rect r;
	RgnHandle updateRgn;

	active();
	curset(NO);
	updateRgn = NewRgn();
	SetRect(&r, tcol * width, trow * height, twidth - width, (trow+1) * height);
	if (trow == MAXROW)
		maxadjust(&r);
	ScrollRect(&r, -width, 0, updateRgn);
	DisposeRgn(updateRgn);
	BlockMove(p_curs + 1, p_curs, (long) (MAXCOL - tcol));
	*conv_p_curs(trow, MAXCOL) = ' ';
	curset(YES);
}
#endif /* NEVER */

private void
dellines(n, bot)
int n, bot;
{
	RgnHandle updateRgn = NewRgn();
	Rect r;
	long len;

	active();
	curset(NO);
	SetRect(&r, 0, ((trow) * height), WINDWIDTH, ((bot + 1) * height));
	ScrollRect(&r, 0, 0 - (n * height), updateRgn);
	DisposeRgn(updateRgn);
	len = ((bot - trow - n + 1) * CO);
	BlockMove(conv_p_curs(trow + n, 0), conv_p_curs(trow, 0), len);
	memset(conv_p_curs(bot - n + 1, 0), ' ', n * CO);
	putcurs(trow, 0, YES);	/* ??? "YES" guess by DHR */
}

private void
inslines(n, bot)
int n, bot;
{
	RgnHandle updateRgn = NewRgn();
	Rect r;
	long len;

	active();
	curset(NO);
	SetRect(&r, 0, trow * height, WINDWIDTH, (bot +1) * height);
	ScrollRect(&r, 0, (n * height), updateRgn);
	DisposeRgn(updateRgn);
	len = ((bot - trow - n +1) * CO);
	BlockMove(conv_p_curs(trow, 0), conv_p_curs(trow + n, 0), len);
	memset(conv_p_curs(trow, 0), ' ', (n * CO));
	putcurs(trow, 0, YES);	/* ??? "YES" guess by DHR */
}

void
writetext(str, len)
const unsigned char *str;
size_t	len;
{
	active();
	curset(NO);
#ifdef NEVER
	if (insert) {
		RgnHandle updateRgn = NewRgn();
		Rect r;

		SetRect(&r, tcol * width, trow * height, twidth - width * len, (trow +1) * height -1);
		if (trow == MAXROW)
			maxadjust(&r);
		ScrollRect(&r, width * len, 0, updateRgn);
		DisposeRgn(updateRgn);
	}
#endif
	DrawText(str, (short)0, (short)len);
#ifdef NEVER
	if (insert)
		BlockMove(p_curs, p_curs + len, (long) (CO - tcol - len));
#endif
	memcpy((UnivPtr)p_curs, (UnivPtr)str, len);
	putcurs(trow, tcol+len <= MAXCOL? tcol+len : MAXCOL, YES);	/* ??? "YES" guess by DHR */
}

private Rect myBoundsRect;

private void
init_slate()
{
	FontInfo f;

	char *Name = "Jove ";
	char *Title;

	InitGraf(&qd.thePort);
	InitWindows();
	InitCursor();
	InitFonts();
	InitMenus();
	InitDialogs((ProcPtr)NULL);		/* no restart proc */

	/* figure limiting rectangle for window moves */
	SetRect(&LimitRect,
		qd.screenBits.bounds.left + 3,
		qd.screenBits.bounds.top + 20,
		qd.screenBits.bounds.right - 3,
		qd.screenBits.bounds.bottom -3);

	Set_std();
	SetBounds();

	/* initialize char array for updates */
	p_scr = emalloc(p_size = wc_std.w_cols * wc_std.w_rows);	/* only once */
	p_curs = p_scr;

	Title = sprint("%s%s", Name, jversion);
	theScreen = NewWindow(&myWindowRec, &myBoundsRect, CtoPstr(Title),
		1, 8, (WindowPtr) -1, 1, 0L);

	/* figure an initial window configuration and adjust it */
	wc = &wc_std;
	wc_user = wc_std;	/* initially, only one configuration to toggle */
	user_state(theScreen) = std_state(theScreen);
	SetPort(theScreen);

	theScreen->txFont = FONT;
	theScreen->txSize = TEXTSIZE;

#ifdef VARFONT
	GetFontInfo(&f);
	height = f.ascent+f.descent+f.leading;
	width = f.widMax;
	twidth = width * wc->w_cols;
	theight = height * wc->w_rows;
	descent = f.descent;
#endif

	theScreen->txMode = srcCopy;
	theScreen->pnMode = patCopy;
	PenNormal();
}

private void
p_refresh()
{
	int lineno;

	for (lineno = 0; lineno < LI; lineno++) {
		char *curs = conv_p_curs(lineno, 0);

		MoveTo(0, (lineno+1) * height - descent + (lineno == MAXROW? 2 : 0));
		/* The following kludgy line is to get SO right.  It depends on:
		 * - !defined(HIGHLIGHTING)
		 * - this routine not being called at an inauspicious time
		 *   i.e. in the middle of a SO output.
		 * - the fact that the last line will non-SO so that the text
		 *   mode will be left non-SO.
		 */
		SO_effect(Screen[lineno].s_effects);
		DrawText(curs, (short)0, (short)CO);
	}
	curset(cursvis);
}


private bool
wc_adjust(w, h, wcf, init)		/* adjust window config to look nice */
int w, h;
struct wind_config *wcf;
int init;
{
	static int LIMIT_R, LIMIT_C;
	int rows, cols;

	if (init) {
		LIMIT_R = (h - 4) / HEIGHT;
		LIMIT_C = (w - SCROLLWIDTH - 1) / WIDTH + 1;
	}
	if ((w < WIDTH * 40) ||(h < HEIGHT * 10)	/* too small */
	|| ((rows = (h - 4) / HEIGHT) > LIMIT_R)	/* too big */
	|| ((cols = (w - SCROLLWIDTH - 1) / WIDTH + 1) > LIMIT_C))
		return NO;

	wcf->w_rows = rows;
	wcf->w_cols = cols;
	wcf->w_width = wcf->w_cols * WIDTH + 1 + SCROLLWIDTH;
	wcf->w_height = wcf->w_rows * HEIGHT + 4;
	return YES;
}

private int
getCO()	/* so that jove knows params */
{
	return wc->w_cols;
}

private int
getLI()
{
	return wc->w_rows;
}

void
ttsize()
{
	/* ??? We really ought to wait until the screen is big enough:
	 * at least three lines high (one line each for buffer, mode,
	 * and message) and at least twelve columns wide (eight for
	 * line number, one for content, two for overflow indicators,
	 * and one blank at end).
	 */
	/* ??? This should be made more like UNIX version */
	CO = getCO();
	if (CO > MAXCOLS)
		CO = MAXCOLS;
	LI = getLI();
	Windchange = YES;
	clr_page();
	ILI = LI - 1;
}

private void
SetBounds()
{
	SetRect(&myBoundsRect,
		qd.screenBits.bounds.left + 3,
		qd.screenBits.bounds.top + 40,
		qd.screenBits.bounds.left + 3 + wc_std.w_width,
		qd.screenBits.bounds.top + 40 + wc_std.w_height);
}

private void
Set_std()
{
	(void) wc_adjust(qd.screenBits.bounds.right - qd.screenBits.bounds.left - 6,
		qd.screenBits.bounds.bottom - qd.screenBits.bounds.top - 42,
		&wc_std, 1);
}

private void
Reset_std()
{
	Set_std();
	std_state(theScreen) = myBoundsRect;
}
#endif /* MAC */
