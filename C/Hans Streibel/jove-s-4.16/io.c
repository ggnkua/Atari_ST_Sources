/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

#include "jove.h"
#include "list.h"
#include "fp.h"
#include "jctype.h"
#include "disp.h"
#include "scandir.h"
#include "ask.h"
#include "fmt.h"
#include "insert.h"
#include "marks.h"
#include "sysprocs.h"
#include "proc.h"
#include "wind.h"	/* only used by JReadFile for fixup */
#include "rec.h"

#ifdef MAC
# include "mac.h"
#else
# include <sys/stat.h>
#endif

#ifdef UNIX
# include <sys/file.h>
#endif

#ifdef MSFILESYSTEM
# include <fcntl.h>
# include <io.h>
# include <direct.h>
# include <dos.h>
# include <stdlib.h>	/* _splitpath, _makepath */
extern int UNMACRO(rename)(const char *old, const char *new);	/* <stdin.h> */
# ifndef _MAX_DIR
#  define _MAX_DIR FILESIZE
# endif
# ifndef _MAX_FNAME
#  define _MAX_FNAME 9
# endif
# ifndef _MAX_EXT
#  define _MAX_EXT 4
# endif
#endif /* MSFILESYSTEM */

#include <errno.h>

#ifdef MINT
char *jgetcwd proto((char *, size_t));
char *fixpath proto((char *));
#endif


private void
	filemunge proto((char *newname)),
	chk_divergence proto((Buffer *thisbuf, char *fname, char *how));

private struct block	*lookup_block proto((daddr));

private char	*getblock proto((daddr, bool));

private bool	f_getputl proto((LinePtr line,File *fp));

#ifdef BACKUPFILES
private void
	file_backup proto((char *fname));
#endif

long	io_chars;		/* number of chars in this open_file */
int	io_lines;		/* number of lines in this open_file */

#ifdef BACKUPFILES
bool	BkupOnWrite = NO;	/* VAR: make backup files when writing */
#endif

#ifndef MSFILESYSTEM

#define	Dchdir(to)  chdir(to)

#else /* MSFILESYSTEM */

# ifdef WIN32
#  define _dos_getdrive(dd)		(*(dd)=_getdrive())
#  define _dos_setdrive(d, n)	((*(n)=_getdrive()), _chdrive((d)))
# endif

# ifdef ZTCDOS

#  define _dos_getdrive(dd)	dos_getdrive(dd)
#  define _dos_setdrive(d, n)	dos_setdrive((d), (n))

private void
_splitpath(const char *path, char *drv, char *dir, char *fn, char *ext)
{
	const char	*p;
	size_t	l;

	if (path[0]!='\0' && path[1]==':') {
		*drv++ = *path++;
		*drv++ = *path++;
	}
	*drv = '\0';

	p = strrchr(path, '/');
	if (p != NULL) {
		/* ??? should we have / at the end of the directory? */
		p++;
		memcpy(dir, path, (size_t) (p-path));
		dir += p-path;
		path = p;
	}
	*dir = '\0';

	p = strchr(path, '.');
	if (p == NULL)
		p = path+strlen(path);
	l = p-path;
	if (l > 8)
		l = 8;
	null_ncpy(fn, path, l);

	l = strlen(p);
	if (l > 4)
		l = 4;
	null_ncpy(ext, p, l);
}

private void
_makepath(char *path, const char *drv, const char *dir, const char *fn, const char *ext)
{
	if (drv[0] != '\0') {
		*path++ = drv[0];
		*path++ = ':';
		*path = '\0';
	}
	if (dir[0] != '\0') {
		strcpy(path, dir);
		path += strlen(path);
		if (path[-1] != '/' && path[-1] != '\\') {
			*path++ = '/';
			*path = '\0';
		}
	}
	strcpy(path, fn);
	path += strlen(path);
	switch (ext[0]) {
	case '\0':
		break;
	default:
		*path++ = '.';
		/*FALLTHROUGH*/
	case '.':
		strcpy(path, ext);
		break;
	}
}
# endif /* ZTCDOS */

# if defined(ZTCDOS) || defined(__WATCOMC__)
/* The Zortech C and Watcom libraries do not provide mktemp
 * (nor should they -- ANSI defines tmpnam).
 * Unfortunately tmpnam doesn't do what we want either, so we roll
 * one by hand.  Since mktemp has no way of reporting errors,
 * we're not too careful about checking for them.
 */
char *
mktemp(buf)
char	*buf;
{
	char	*seq;
	char	*p;

	for (seq = buf + strlen(buf); seq>buf && seq[-1]=='X'; seq--)
		;
	for (p = seq; *p != '\0'; p++)
		*p = '0';
	for (;;) {
		struct stat	sb;

		if (stat(buf, &sb) < 0
#  ifdef ZTCDOS
		/* Zortech yields ENOTDIR when path isn't found,
		 * even if the prefix does exist.  Pretty silly!
		 */
		&& errno == ENOTDIR
#  else
		&& errno == ENOENT
#  endif
		)
			break;
		for (p = seq; ; ) {
			if (*p == '\0') {
				abort();	/* we ran out of possible names! */
			} else if (*p == '9') {
				*p++ = '0';
			} else {
				*p += 1;
				break;
			}
		}
	}
	return buf;
}

# endif /* defined(ZTCDOS) || defined(__WATCOMC__) */

/* Change drive and directory
 * This is not quite like a UNIX chdir because each drive has a
 * separate current directory.  If the path is not absolute, it
 * will be relative to the current directory of the drive.
 * On the other hand, this is not the DOS chdir because it does
 * change the current drive if one is specified.
 */
private int
Dchdir(to)
char *to;
{
	unsigned d, dd;

	if (to[1] == ':') {
		d = CharUpcase(to[0]) - ('A' - 1);
		if (d < 'A'-('A'-1) || 'Z'-('A'-1) < d)
			complain("invalid drive");
		_dos_getdrive(&dd);
		if (dd != d)
			_dos_setdrive(d, &dd);	/* ??? no failure report? */
		to += 2;	/* skip drive spec */
	}
	return *to == '\0'? 0 : chdir(to);
}

private char *
fixpath(path)
char *path;
{
	char *p;

	for (p = path; *p != '\0'; p++)
		if (*p == '\\')
			*p = '/';
# ifdef MSDOS
	return strlwr(path);
# else
	return path; /* Win32 is case-preserving. */
# endif
}


private void
abspath(so, dest)
char *so, *dest;
{
	char	cwd[FILESIZE],
		cwdD[3], cwdDIR[_MAX_DIR], cwdF[_MAX_FNAME], cwdEXT[_MAX_EXT],
		soD[3], soDIR[_MAX_DIR], soF[_MAX_FNAME], soEXT[_MAX_EXT];

	_splitpath(fixpath(so), soD, soDIR, soF, soEXT);
	getcwd(cwd, FILESIZE);
	if (*soD != '\0') {
		/* Find current working directory on specified drive
		 * There is a DOS system call to do this (service 0x47),
		 * but the C library doesn't have a glue routine for it.
		 * We get the same effect with this kludgy code.
		 */
		Dchdir(soD);	/* note: without a path, current directory is unchanged */
		getcwd(cwdDIR, FILESIZE);
		cwd[2] = '\0';	/* toss away path, leaving only drive spec */
		Dchdir(cwd);
		strcpy(cwd, cwdDIR);
	}
	(void) fixpath(cwd);
	if (cwd[strlen(cwd)-1] != '/')
		strcat(cwd, "/x.x");	/* need dummy filename */

	_splitpath(fixpath(cwd), cwdD, cwdDIR, cwdF, cwdEXT);
	/* Reconstruct the path as follows:
	 * - If it is NOT a UNC (network) name, and doesn't have a drive letter,
	 *   add one.
	 * - If it is a relative path, add the current drive/directory
	 *   to convert it to an absolute path.
	 */
	_makepath(dest,
		*soD == '\0' && (soDIR[0]!='/'||soDIR[1]!='/') ? cwdD : soD,
		*soDIR != '/'? strcat(cwdDIR, soDIR) : soDIR, soF, soEXT);
	fixpath(dest);	/* can't do it often enough */
}

#endif /* MSFILESYSTEM */


/* Hans:
* my MiNT version of "fixpath". The idea is, that we also change the drive
* letter to an absolute path. Thus for instance, a:/foo becomes
* /dev/a/foo. Sure, this works only under MiNT... */
#if defined (MINT)
char *
fixpath(path)
char *path;
{
char tmpbuf[FILESIZE];	/* should be long enough to hold all pathnames */
char *p, *t;

if( !path )
	return(NULL);

p=path;
if( *p && p[1]==':' ) {
	strcpy(tmpbuf, "/dev/");
	t = tmpbuf+5;
	*t++ = *p;
	*t++ = '/';
	p += 2;
	if( *p == '/' || *p == '\\' )
		p++;
	while( *p ) {
		*t++ = (*p=='\\') ? '/' : *p;
		p++;
	}
	*t = '\0';
	strlwr(tmpbuf);
	strcpy(path, tmpbuf);
	return(path);
} else {	/* we can do the change in place */
	while (*p) {
		if (*p == '\\')
			*p = '/';
		p++;
	}
	return strlwr(path);
}
}
#endif /* MINT */
/* Ende Hans */



void
close_file(fp)
File	*fp;
{
	if (fp != NULL) {
		if (fp->f_flags & F_TELLALL)
			add_mess(" %d lines, %D characters.",
				 io_lines, io_chars);
		f_close(fp);
	}
}

/* Write the region from line1/char1 to line2/char2 to FP.  This
   never CLOSES the file since we don't know if we want to. */

bool	EndWNewline = 1;	/* VAR: end files with a blank line */

void
putreg(fp, line1, char1, line2, char2, makesure)
register File	*fp;
LinePtr	line1,
	line2;
int	char1,
	char2;
bool	makesure;
{
	if (makesure)
		(void) fixorder(&line1, &char1, &line2, &char2);
	while (line1 != line2->l_next) {
		register char	*lp = lcontents(line1) + char1;

		if (line1 == line2) {
			fputnchar(lp, (char2 - char1), fp);
			io_chars += (char2 - char1);
		} else {
			register char	c;

			while ((c = *lp++) != '\0') {
				f_putc(c, fp);
				io_chars += 1;
			}
		}
		if (line1 != line2) {
			io_lines += 1;
			io_chars += 1;
#ifdef USE_CRLF
			f_putc('\r', fp);
#endif /* USE_CRLF */
			f_putc(EOL, fp);
		}
		line1 = line1->l_next;
		char1 = 0;
	}
	flushout(fp);
}

private void
dofread(fp)
register File	*fp;
{
	char	end[LBSIZE];
	bool	xeof;
	LinePtr	savel = curline;
	int	savec = curchar;

	strcpy(end, linebuf + curchar);
	xeof = f_gets(fp, linebuf + curchar, (size_t) (LBSIZE - curchar));
	SavLine(curline, linebuf);
	while(!xeof) {
		curline = listput(curbuf, curline);
		xeof = f_getputl(curline, fp);
	}
	getDOT();
	linecopy(linebuf, (curchar = strlen(linebuf)), end);
	SavLine(curline, linebuf);
	IFixMarks(savel, savec, curline, curchar);
}

void
read_file(file, is_insert)
char	*file;
bool	is_insert;
{
	Bufpos	save;
	File	*fp;

	if (!is_insert)
		curbuf->b_ntbf = NO;
	fp = open_file(file, iobuff, F_READ | F_TELLALL, NO);
	if (fp == NULL) {
		if (!is_insert && errno == ENOENT)
			s_mess("(new file)");
		else
			s_mess(IOerr("open", file));
		return;
	}
	if (!is_insert) {
		(void) do_stat(curbuf->b_fname, curbuf, DS_SET);
		set_arg_value((fp->f_flags & F_READONLY)? 1 : 0);
		TogMinor(ReadOnly);
	}

	DOTsave(&save);
	dofread(fp);
	if (is_insert && io_chars > 0) {
		modify();
		set_mark();
	}
	SetDot(&save);
	getDOT();
	close_file(fp);
}

void
SaveFile()
{
	if (!IsModified(curbuf) && !curbuf->b_diverged) {
		if (curbuf->b_fname != NULL)
			(void) do_stat(curbuf->b_fname, curbuf, DS_NONE);
		if (!curbuf->b_diverged) {
			message("No changes need to be written.");
			return;
		}
	}
	if (curbuf->b_fname == NULL) {
		/* We change LastCmd because otherwise the prompt for
		 * the filename will be ": visit-file".  With this
		 * fudge, it will be ": write-file".
		 */
		data_obj	*saved_lc = LastCmd;
		static data_obj	dummy = { 0, "write-file" };

		LastCmd = &dummy;
		JWriteFile();
		LastCmd = saved_lc;
	} else {
		filemunge(curbuf->b_fname);
		chk_divergence(curbuf, curbuf->b_fname, "save");
		file_write(curbuf->b_fname, NO);
	}
}

char	*HomeDir;	/* home directory */
size_t	HomeLen;	/* length of home directory string */

private List		*DirStack = NULL;
#define dir_name(dp)	((char *) list_data((dp)))
#define PWD_PTR		(list_data(DirStack))
#define PWD		((char *) PWD_PTR)

char *
pwd()
{
	return PWD;
}

char *
pr_name(fname, okay_home)
char	*fname;
bool	okay_home;
{
	int	n;

	if (fname != NULL) {
		n = numcomp(fname, PWD);

		if ((PWD[n] == '\0') &&	/* Matched to end of PWD */
		    (fname[n] == '/'))
			return fname + n + 1;

		if (okay_home && strcmp(HomeDir, "/") != 0
		&& strncmp(fname, HomeDir, HomeLen) == 0
		&& fname[HomeLen] == '/')
		{
			static char	name_buf[100];

			swritef(name_buf, sizeof(name_buf),
				"~%s", fname + HomeLen);
			return name_buf;
		}
	}
	return fname;
}

void
Chdir()
{
	char	dirbuf[FILESIZE];

#ifdef MSFILESYSTEM
	MatchDir = YES;
#endif
	(void) ask_file((char *)NULL, PWD, dirbuf);
#ifdef MSFILESYSTEM
	MatchDir = NO;
#endif
	if (Dchdir(dirbuf) == -1)
	{
		s_mess("cd: cannot change into %s.", dirbuf);
		return;
	}
	UpdModLine = YES;
	setCWD(dirbuf);
	prCWD();
#ifdef MAC
	Bufchange = YES;
#endif
}

#ifdef USE_GETWD
extern char	*getwd proto((char *));

/* ARGSUSED bufsize */
char *
#ifndef MINT
getcwd(buffer, bufsize)
#else
jgetcwd(buffer, bufsize)
#endif
char	*buffer;
size_t	bufsize;
{
#ifndef MINT
	return getwd(buffer);
#else
	return( fixpath(getwd(buffer)) );
#endif
}
#endif

#ifdef USE_PWD
/* ARGSUSED bufsize */
char *
#ifndef MINT
getcwd(buffer, bufsize)
#else
jgetcwd(buffer, bufsize)
#endif
char	*buffer;
size_t	bufsize;
{
	Buffer	*old = curbuf;
	char	*ret_val;

	/* ??? The use of a buffer ought to be more polite --
	 * what if it were already in use?  (a) the buffer contents
	 * might be valuable, so we should ask whether we can clobber,
	 * and (b) we don't have any code to empty the buffer anyway.
	 * Luckily, this is only called once, at the beginning of time,
	 * so things ought to be OK.  Perhaps we should delete this buffer
	 * after we are finished with it.
	 * (MSDOS calls its own version of this routine more often,
	 * but that version is quite different.)
	 */
	SetBuf(do_select((Window *)NULL, "pwd-output"));
	curbuf->b_type = B_PROCESS;
	(void) UnixToBuf(0, "pwd-output", (char *)NULL, "/bin/pwd");
	ToFirst();
	strcpy(buffer, linebuf);
	SetBuf(old);
#	ifdef MINT
	fixpath(buffer);
#	endif
	return buffer;
}
#endif /* USE_PWD */

/* Check if dn is the name of the current working directory
   and that it is in cannonical form */

bool
chkCWD(dn)
char	*dn;
{
#ifdef USE_INO
	char	filebuf[FILESIZE];
	struct stat	dnstat,
			dotstat;

	if (dn[0] != '/')
		return NO;		/* need absolute pathname */
	PathParse(dn, filebuf);
	return stat(filebuf, &dnstat) == 0
		&& stat(".", &dotstat) == 0
		&& dnstat.st_dev == dotstat.st_dev
		&& dnstat.st_ino == dotstat.st_ino;
#else /* !USE_INO */
	return NO;	/* no way of telling */
#endif /* !USE_INO */
}

void
setCWD(d)
char	*d;
{
	if (DirStack == NULL)
		list_push(&DirStack, (UnivPtr)NULL);
	PWD_PTR = freealloc((UnivPtr) PWD, strlen(d) + 1);
	strcpy(PWD, d);
}

void
getCWD()
{
	char	*cwd;
	char	pathname[FILESIZE];

#ifndef MAC	/* no environment in MacOS */
	cwd = getenv("CWD");
	if (cwd == NULL || !chkCWD(cwd)) {
		cwd = getenv("PWD");
		if (cwd == NULL || !chkCWD(cwd)) {
#endif

#ifndef MINT
			cwd = getcwd(pathname, sizeof(pathname));
#else
			cwd = jgetcwd(pathname, sizeof(pathname));
#endif
			if (cwd == NULL)
				error("Cannot get current directory");
#ifndef MAC	/* no environment in MacOS */
		}
	}
#endif
#ifdef MSFILESYSTEM
	cwd = fixpath(cwd);
#endif /* MSFILESYSTEM */
	setCWD(cwd);
}

void
prDIRS()
{
	register List	*lp;

	s_mess(ProcFmt);
	for (lp = DirStack; lp != NULL; lp = list_next(lp))
		add_mess("%s ", pr_name(dir_name(lp), YES));
}

void
prCWD()
{
	f_mess(": %f => \"%s\"", PWD);
	stickymsg = YES;
}

private void
doPushd(newdir)
	char	*newdir;
{
	UpdModLine = YES;
	if (*newdir == '\0') {	/* Wants to swap top two entries */
		char	*old_top;

		if (list_next(DirStack) == NULL)
			complain("pushd: no other directory.");
		old_top = PWD;
		list_data(DirStack) = (UnivPtr) dir_name(list_next(DirStack));
		list_data(list_next(DirStack)) = (UnivPtr) old_top;
		(void) Dchdir(PWD);
	} else {
		if (Dchdir(newdir) == -1)
		{
			s_mess("pushd: cannot change into %s.", newdir);
			return;
		}
		(void) list_push(&DirStack, (UnivPtr)NULL);
		setCWD(newdir);
	}
	prDIRS();
}

void
Pushd()
{
	char	dirbuf[FILESIZE];

#ifdef MSFILESYSTEM
	MatchDir = YES;
#endif
	(void) ask_file((char *)NULL, NullStr, dirbuf);
#ifdef MSFILESYSTEM
	MatchDir = NO;
#endif
	doPushd(dirbuf);
}

void
Pushlibd()
{
	char	dirbuf[FILESIZE];

	PathParse(ShareDir, dirbuf);
	doPushd(dirbuf);
}

void
Popd()
{
	if (list_next(DirStack) == NULL)
		complain("popd: directory stack is empty.");
	UpdModLine = YES;
	free((UnivPtr) list_pop(&DirStack));
	(void) Dchdir(PWD);	/* If this doesn't work, we's in deep shit. */
	prDIRS();
}

#ifdef UNIX

# ifdef USE_GETPWNAM

#include <pwd.h>

private void
get_hdir(user, buf)
register char	*user,
		*buf;
{
	struct passwd	*p;

	p = getpwnam(user);
	endpwent();
	if (p == NULL) {
		add_mess(" [unknown user: %s]", user);
		SitFor(7);
		complain((char *)NULL);
		/* NOTREACHED */
	}
	strcpy(buf, p->pw_dir);
}

# else /* ! USE_GETPWNAM */

#  include "re.h"

private void
get_hdir(user, buf)
register char	*user,
		*buf;
{
	char	fbuf[LBSIZE],
		pattern[100];
	register int	u_len;
	File	*fp;

	u_len = strlen(user);
	fp = open_file("/etc/passwd", fbuf, F_READ, YES);
	swritef(pattern, sizeof(pattern),
		"%s:[^:]*:[^:]*:[^:]*:[^:]*:\\([^:]*\\):", user);
	while (!f_gets(fp, genbuf, LBSIZE))
		if ((strncmp(genbuf, user, u_len) == 0)
		&& LookingAt(pattern, genbuf, 0)) {
			putmatch(1, buf, FILESIZE);
			close_file(fp);
			return;
		}
	close_file(fp);
	add_mess(" [unknown user: %s]", user);
	SitFor(7);
	complain((char *)NULL);
}

# endif /* USE_GETPWNAM */
#endif /* UNIX */

/* Convert path in name into a more-canonical one in intobuf.
 * - makes path absolute
 * - handles ~ (and \~, if not MSFILESYSTEM)
 * - if MSFILESYSTEM, turns \ into /
 * - on MSDOS, lower cases everything
 * Note: because \~ is turned into ~, this routine is not idempotent.
 * ??? I suspect that there are places where in the code that presume
 * it is idempotent!  DHR
 */
void
PathParse(name, intobuf)
char	*name,
	*intobuf;
{
	char	localbuf[FILESIZE];

	intobuf[0] = localbuf[0] = '\0';
	if (*name == '\0')
		return;

	/* Place pathname in localbuf, with any specified home directory */

	if (*name == '~') {
		if (name[1] == '/' || name[1] == '\0') {
			strcpy(localbuf, HomeDir);
			name += 1;
		}
#ifdef UNIX	/* may add for mac in future */
		else {
			char	*uendp = strchr(name, '/'),
				unamebuf[30];

			if (uendp == NULL)
				uendp = name + strlen(name);
			name += 1;
			null_ncpy(unamebuf, name, (size_t) (uendp - name));
			get_hdir(unamebuf, localbuf);
			name = uendp;
		}
#endif
#ifndef MSFILESYSTEM
	} else if (name[0] == '\\' && name[1] == '~') {
		/* allow quoting of ~ (but \ is a path separator in MSDOS) */
		name += 1;
#endif /* MSFILESYSTEM */
	}
	(void) strcat(localbuf, name);

	/* Make path absolute, and prepare for processing each component
	 * of the path by placing prefix in intobuf.
	 */
#ifndef MSFILESYSTEM
	strcpy(intobuf, localbuf[0] == '/'? "/" : PWD);
#else /* MSFILESYSTEM */
	/* Convert to an absolute path, and then fudge thing so that the
	 * generic code does not have to deal with drive specifications.
	 * If the path starts with '//' it is a UNC name. Otherwise,
	 * our absolute path starts with a d: drive specification and
	 * uses forward slashes as the path separator (including one
	 * right after the drive specification).
	 */
	abspath(localbuf, intobuf);
	if (localbuf[0] == '/' && localbuf[1] == '/') {
		strcpy(localbuf, intobuf+1);
		intobuf += 1;
		intobuf[1] = '\0';
	} else {
		strcpy(localbuf, intobuf+3);		/* copy back all but d:/ */
		intobuf += 2;	/* "forget" drive spec: point to / */
		intobuf[1] = '\0';	/* truncate after d:/ */
	}
#endif /* MSFILESYSTEM */

	/* Process each path component, attempting to make the path canonical.
	 * Since processing is lexical, it cannot account for links.
	 */
	{
		char
			*fp = localbuf,	/* start of current component */
			*dp = intobuf;	/* current end of resulting path (but lazy) */

		while (*fp != '\0') {
			/* for each path component: */
			char	*sp = strchr(fp, '/');	/* end of current component */

			if (sp != NULL)
				*sp = '\0';
			dp += strlen(dp);	/* move to end of resulting path */
			if (*fp == '\0' || strcmp(fp, ".") == 0) {
				/* ignore this component */
			} else if (strcmp(fp, "..") == 0) {
				/* Strip one directory name from "intobuf".
				 * Assume that intobuf[0] == '/'.
				 * ??? is this correct for the Mac?  CP/M?
				 */
				do ; while (dp > intobuf+1 && *--dp != '/');
				*dp = '\0';
			} else {
				if (dp!=intobuf && dp[-1]!='/')
					*dp++ = '/';
				strcpy(dp, fp);
			}
			if (sp == NULL)
				break;
			fp = sp + 1;
		}
	}
}

#ifdef UNIX
int	CreatMode = DFLT_MODE;	/* VAR: default mode for creat'ing files */
#endif

private void
DoWriteReg(app)
bool	app;
{
	char	fnamebuf[FILESIZE];
	Mark	*mp = CurMark();
	File	*fp;

	/* Won't get here if there isn't a Mark */
	(void) ask_file((char *)NULL, (char *)NULL, fnamebuf);

	if (!app) {
		filemunge(fnamebuf);
		chk_divergence((Buffer *)NULL, fnamebuf, "write-region");
#ifdef BACKUPFILES
		if (BkupOnWrite)
			file_backup(fnamebuf);
#endif
	}

	fp = open_file(fnamebuf, iobuff, app ? F_APPEND|F_TELLALL : F_WRITE|F_TELLALL, YES);
	putreg(fp, mp->m_line, mp->m_char, curline, curchar, YES);
	close_file(fp);
}

void
WrtReg()
{
	DoWriteReg(NO);
}

void
AppReg()
{
	DoWriteReg(YES);
}

bool	OkayBadChars = NO;	/* VAR: allow bad characters in filenames created by JOVE */

void
JWriteFile()
{
	char
		fnamebuf[FILESIZE];

#ifdef MAC
	if (Macmode) {
		if (pfile(fnamebuf) == NULL)
			return;
	} else
#endif /* MAC */
		(void) ask_file((char *)NULL, curbuf->b_fname, fnamebuf);
	/* Don't allow bad characters when creating new files. */
	if (!OkayBadChars
	&& (curbuf->b_fname==NULL || strcmp(curbuf->b_fname, fnamebuf) != 0))
	{
#ifdef UNIX
		static const char	badchars[] = "!$^&*()~`{}\"'\\|<>? ";
#endif
#ifdef MSDOS
		static const char	badchars[] = "*|<>? ";
#endif
#ifdef WIN32
		static const char	badchars[] = "*|<>?\"";
#endif
#ifdef MAC
		static const char	badchars[] = ":";
#endif
		register char	*cp = fnamebuf;
		register char	c;

		while ((c = *cp++) != '\0')
			if (!jisprint(c) || strchr(badchars, c)!=NULL)
				complain("'%p': bad character in filename.", c);
	}

	filemunge(fnamebuf);
	chk_divergence(curbuf, fnamebuf, "write");
	curbuf->b_type = B_FILE;	/* in case it wasn't before */
	setfname(curbuf, fnamebuf);
	file_write(fnamebuf, NO);
}

void
WtModBuf()
{
	if (!ModBufs(NO))
		message("[No buffers need saving]");
	else
		put_bufs(is_an_arg());
}

void
put_bufs(askp)
bool	askp;
{
	register Buffer	*oldb = curbuf,
			*b;

	for (b = world; b != NULL; b = b->b_next) {
		if (!IsModified(b) || b->b_type != B_FILE)
			continue;
		SetBuf(b);	/* Make this current Buffer */
		if (curbuf->b_fname == NULL) {
			char	*newname;

			newname = ask(NullStr, "Buffer \"%s\" needs a file name; type Return to skip: ", b->b_name);
			if (*newname == '\0')
				continue;
			setfname(b, newname);
		}
		if (askp && !yes_or_no_p("Write %s? ", curbuf->b_fname))
			continue;
		SaveFile();
	}
	SetBuf(oldb);
}

/* Open file FNAME supplying the buffer IO routine with buffer BUF.
   HOW is F_READ, F_WRITE or F_APPEND.  HOW can have the F_TELLALL
   flag to request the displaying of I/O status.  Only if COMPLAINIFBAD
   will a complain diagnostic be produced for a failed open.

   NOTE:  This opens the pr_name(fname, NO) of fname.  That is, FNAME
	  is usually an entire pathname, which can be slow when the
	  pathname is long and there are lots of symbolic links along
	  the way (which has become very common in my experience).  So,
	  this speeds up opens file names in the local directory.  It
	  will not speed up things like "../scm/foo.scm" simply because
	  by the time we get here that's already been expanded to an
	  absolute pathname.  But this is a start.
   */

File *
open_file(fname, buf, how, complainifbad)
register char	*fname;
char	*buf;
register int	how;
bool	complainifbad;
{
	register File	*fp;

	io_chars = 0;
	io_lines = 0;

	fp = f_open(pr_name(fname, NO), how, buf, LBSIZE);
	if (fp == NULL) {
		if (complainifbad) {
			message(IOerr((F_MODE(how) == F_READ) ? "open" : "create",
			    fname));
			complain((char *)NULL);
		}
	} else {
		const char	*rd_only = NullStr;

#ifndef MAC
		if (access(pr_name(fname, NO), W_OK) == -1 && errno != ENOENT) {
			rd_only = " [Read only]";
			fp->f_flags |= F_READONLY;
		}
#endif
		if (how & F_TELLALL)
			f_mess("\"%s\"%s", pr_name(fname, YES), rd_only);
	}
	return fp;
}

/* We're about to write to a file (save-file, write-region, append-region,
 * or write-file):  query user when it is an existing but different file.
 * Note: even if we are doing an append-region or write-region,
 * we assume that the current buffer's file is fair game.
 */
private void
filemunge(newname)
char	*newname;
{
	if (do_stat(newname, curbuf, DS_NONE) != curbuf && was_file) {
		rbell();
		confirm("\"%s\" already exists; overwrite it? ", newname);
		/* in case user has fiddled some more, refresh stat cache */
		(void) do_stat(newname, (Buffer *)NULL, DS_NONE);
	}
}

/* Check to see if the file has been modified since it was
   last visited or saved.  If so, make sure they know what
   they're doing.  Buffer "thisbuf" is tested for divergence;
   if thisbuf is NULL, the first buffer with the file is tested.

   To avoid excessive stats, we presume that the stat cache is
   already primed.  We refresh it if we get a confirmation because
   it left  the user a window of opportunity for fiddling.
   */

private void
chk_divergence(thisbuf, fname, how)
Buffer	*thisbuf;
char	*fname,
	*how;
{
	static const char	mesg[] = "Shall I go ahead and %s anyway? ";
	Buffer	*buf = do_stat(fname, thisbuf, DS_REUSE);

	if (buf != NULL && buf->b_diverged) {
		rbell();
		redisplay();	/* Ring that bell! */
		TOstart("Warning");
		Typeout("\"%s\" now saved on disk is not what you last", pr_name(fname, YES));
		Typeout("visited or saved.  Probably someone else is editing");
		Typeout("your file at the same time.");
		Typeout(NullStr);
		Typeout("Type \"y\" if I should %s, anyway.", how);
		f_mess(mesg, how);
		TOstop();
		confirm(mesg, how);
		/* in case user has fiddled some more, refresh stat cache */
		(void) do_stat(fname, (Buffer *)NULL, DS_NONE);
	}
}

void
file_write(fname, app)
char	*fname;
bool	app;
{
	File	*fp;

#ifdef BACKUPFILES
	if (!app && BkupOnWrite)
		file_backup(fname);
#endif

	fp = open_file(fname, iobuff, app ? F_APPEND|F_TELLALL : F_WRITE|F_TELLALL, YES);

	if (EndWNewline) {	/* Make sure file ends with a newLine */
		Bufpos	save;

		DOTsave(&save);
		ToLast();
		if (length(curline))	/* Not a blank Line */
			LineInsert(1);
		SetDot(&save);
	}
	putreg(fp, curbuf->b_first, 0, curbuf->b_last, length(curbuf->b_last), NO);
	close_file(fp);
	(void) do_stat(curbuf->b_fname, curbuf, DS_SET);
	unmodify();
}

void
JReadFile()
{
	char
		fnamebuf[FILESIZE];
	bool
		reloading;
	Window
		*wp;
	int
		curlineno;

#ifdef MAC
	if (Macmode) {
		if (gfile(fnamebuf) == NULL)
			return;
	} else
#endif /* MAC */
		(void) ask_file((char *)NULL, curbuf->b_fname, fnamebuf);

	if (IsModified(curbuf)
	&& yes_or_no_p("Shall I make your changes to \"%s\" permanent? ", curbuf->b_name))
		SaveFile();

	(void) do_stat(fnamebuf, (Buffer *)NULL, DS_NONE);	/* prime stat cache */
	chk_divergence(curbuf, fnamebuf, "read");

	reloading = do_stat(fnamebuf, curbuf, DS_REUSE) == curbuf;

	/* preserve w_line in each window into curbuf */
	wp = fwind;
	do {
		if (wp->w_bufp == curbuf) {
			/* hijack w_topnum -- nobody was using it anyway */
			wp->w_topnum = reloading? LinesTo(curbuf->b_first, wp->w_line) : 0;
			wp->w_top = wp->w_line = NULL;
			wp->w_flags |= W_TOPGONE;
		}
	} while ((wp = wp->w_next) != fwind);

	curlineno = reloading? LinesTo(curbuf->b_first, curline) : 0;

	buf_clear(curbuf);
	setfname(curbuf, fnamebuf);
	read_file(fnamebuf, NO);

	/* recover dot in each window into curbuf */
	wp = fwind;
	do {
		if (wp->w_bufp == curbuf) {
			wp->w_top = curbuf->b_first;
			wp->w_line = next_line(curbuf->b_first, wp->w_topnum);
		}
	} while ((wp = wp->w_next) != fwind);

	SetLine(next_line(curbuf->b_first, curlineno));
}

void
InsFile()
{
	char
		fnamebuf[FILESIZE];
#ifdef MAC
	if (Macmode) {
		if (gfile(fnamebuf) == NULL)
			return;
	} else
#endif /* MAC */
		(void) ask_file((char *)NULL, curbuf->b_fname, fnamebuf);
	read_file(fnamebuf, YES);
}

#include "temp.h"

bool	DOLsave = NO;	/* Do Lsave flag.  If lines aren't being saved
			   when you think they should have been, this
			   flag is probably not being set, or is being
			   cleared before lsave() was called. */

private int	nleft,	/* number of good characters left in current block */
		tmpfd = -1;
daddr	DFree = 1;	/* pointer to end of tmp file */
private char	*tfname;	/* pathname of tempfile where buffer lines go */

private void
tmpinit()
{
	char	buf[FILESIZE];

	swritef(buf, sizeof(buf), "%s/%s", TmpDir,
#ifdef MAC
		".joveXXX"	/* must match string in mac.c:Ffilter() */
#else
		"joveXXXXXX"
#endif
		);
	tfname = copystr(buf);
	tfname = mktemp(tfname);
#ifndef MSFILESYSTEM
	(void) close(creat(tfname, 0600));
	tmpfd = open(tfname, 2);
#else /* MSFILESYSTEM */
	tmpfd = open(tfname, O_CREAT|O_EXCL|O_BINARY|O_RDWR, S_IWRITE|S_IREAD);
#endif /* MSFILESYSTEM */
	if (tmpfd == -1)
		complain("Warning: cannot create tmp file! %s", strerror(errno));
#ifdef RECOVER
	rectmpname(strrchr(tfname, '/') + 1);
#endif
}

/* Close tempfile before execing a child process.
 * Since we might be vforking, we must not change any variables
 * (in particular tmpfd).
 */
void
tmpclose()
{
	if (tmpfd != -1)
		(void) close(tmpfd);
}

/* Close and remove tempfile before exiting. */

void
tmpremove()
{
	if (tmpfd != -1) {
		tmpclose();
		(void) unlink(tfname);
	}
}

/* get a line at `tl' in the tmp file into `buf' which should be LBSIZE
   long */

/* A prototyped definition is needed because daddr might be affected
 * by default argument promotions.
 */

int	Jr_Len;		/* length of Just Read Line */

void
#ifdef USE_PROTOTYPES
getline proto((daddr addr, register char *buf))
#else
getline(addr, buf)
daddr	addr;
register char	*buf;
#endif
{
	register char	*bp,
			*lp;

	lp = buf;
	bp = getblock(addr, NO);
	do ; while ((*lp++ = *bp++) != '\0');
	Jr_Len = (lp - buf) - 1;
}

/* Put `buf' and return the disk address */

daddr
putline(buf)
char	*buf;
{
	register char	*bp,
			*lp;
	register int	nl;
	daddr	line_daddr;

	lp = buf;
	bp = getblock(DFree, YES);
	nl = nleft;
	while ((*bp = *lp++) != '\0') {
		if (*bp++ == '\n') {
			*--bp = '\0';
			break;
		}
		if (--nl == 0) {
			DFree = blk_chop(DFree) + BLK_CHNKS;
			bp = getblock(DFree, YES);
			lp = buf;	/* start over ... */
			nl = nleft;
		}
	}
	line_daddr = DFree;
	DFree += REQ_CHNKS(lp - buf);	/* (lp - buf) includes the null */
	return line_daddr;
}

/* The theory is that the critical section of code inside this procedure
   will never cause a problem to occur.  Basically, we need to ensure
   that two blocks are in memory at the same time, but I think that
   this can never screw up. */

#define lockblock(addr)
#define unlockblock(addr)

private bool
f_getputl(line, fp)
LinePtr	line;
register File	*fp;
{
	register char	*bp;
	register ZXchar	c;
	register int
			nl,
			room = LBSIZE-1;
	char		*base;

	base = bp = getblock(DFree, YES);
	nl = nleft;
	for (;;) {
		c = f_getc(fp);
		if (c == EOF)
			break;

		/* We can't store NUL in our buffer, so ignore it.
		 * Similarly, we can only store characters less than NCHARS.
		 * Of course, with a little ingenuity we could store NUL:
		 * NUL could be represented by \n.
		 */
		if (c == '\0'
#if NCHARS != UCHAR_ROOF
		|| c >= NCHARS
#endif
		)
			continue;

		if (c == EOL) {
#ifdef USE_CRLF
			/* a CR followed by an EOL is treated as a NL.
			 * Bug: the line-buffer is effectively shortened by one character.
			 */
			if (bp != base && bp[-1] == '\r') {
				bp -= 1;
				room += 1;
			}
#endif /* USE_CRLF */
			break;
		}
		if (--room < 0)
			break;	/* no room for this character */

		if (--nl == 0) {
			char	*newbp;
			size_t	nbytes;
			daddr		old_free_block = blk_chop(DFree);

			lockblock(old_free_block);
			DFree = old_free_block + BLK_CHNKS;
			nbytes = bp - base;
			newbp = getblock(DFree, YES);
			nl = nleft;
			byte_copy(base, newbp, nbytes);
			bp = newbp + nbytes;
			base = newbp;
			unlockblock(old_free_block);
		}
		*bp++ = c;
	}
	*bp++ = '\0';
	line->l_dline = DFree;
	DFree += REQ_CHNKS(bp - base);
	if (room < 0) {
		add_mess(" [Line too long]");
		rbell();
		return YES;
	}
	if (c == EOF) {
		if (--bp != base)
			add_mess(" [Incomplete last line]");
		return YES;
	}
	io_lines += 1;
	return NO;
}

typedef struct block {
	char	b_dirty;	/* (bool) */
	daddr	b_bno;
	char	b_buf[JBUFSIZ];
	struct block
		*b_LRUnext,
		*b_LRUprev,
		*b_HASHnext;
} Block;

#define HASHSIZE	7	/* Primes work best (so I'm told) */
#define B_HASH(bno)	((bno) % HASHSIZE)

#ifdef MALLOC_CACHE
private Block	*b_cache = NULL;
#else
private Block	b_cache[NBUF];
#endif

private Block
	*bht[HASHSIZE],		/* Block hash table. Must be zero initially */
	*f_block = NULL,
	*l_block = NULL;

private daddr	next_bno = 0;

private void	(*blkio) ptrproto((Block *, SSIZE_T (*) ptrproto((int, UnivPtr, size_t))));

/* Needed to comfort dumb MS Visual C */
private void real_blkio ptrproto((Block *, SSIZE_T (*) ptrproto((int, UnivPtr, size_t))));

private void
real_blkio(b, iofcn)
register Block	*b;
register SSIZE_T	(*iofcn) ptrproto((int, UnivPtr, size_t));
{
	(void) lseek(tmpfd, (long)b->b_bno << JLGBUFSIZ, 0);
	if ((*iofcn)(tmpfd, (UnivPtr) b->b_buf, (size_t)JBUFSIZ) != JBUFSIZ)
		error("[Tmp file %s error: to continue editing would be dangerous]",
#ifndef MINT
			(iofcn == read) ? "READ" : "WRITE");
#else
			(iofcn == (SSIZE_T (*) ptrproto((int, UnivPtr, size_t)))read) ? "READ" : "WRITE");
#endif
}

/* Needed to comfort dumb MS Visual C */
private void fake_blkio ptrproto((Block *, SSIZE_T (*) ptrproto((int, UnivPtr, size_t))));

private void
fake_blkio(b, iofcn)
register Block	*b;
register SSIZE_T	(*iofcn) ptrproto((int, UnivPtr, size_t));
{
	tmpinit();
	blkio = real_blkio;
	real_blkio(b, iofcn);
}

void
d_cache_init()
{
	register Block	*bp,	/* Block pointer */
			**hp;	/* Hash pointer */
	register daddr	bno;

#ifdef MALLOC_CACHE
	if (b_cache == NULL) {
		b_cache = (Block *) calloc((size_t)NBUF,sizeof(Block));
		if (b_cache == NULL)
			error("cannot allocate buffer cache");
	}
#endif /* MALLOC_CACHE */

	for (bp = b_cache, bno = NBUF; bno-- > 0; bp++) {
		bp->b_dirty = NO;
		bp->b_bno = bno;
		if (l_block == NULL)
			l_block = bp;
		bp->b_LRUprev = NULL;
		bp->b_LRUnext = f_block;
		if (f_block != NULL)
			f_block->b_LRUprev = bp;
		f_block = bp;

		bp->b_HASHnext = *(hp = &bht[B_HASH(bno)]);
		*hp = bp;
	}
	blkio = fake_blkio;
}

void
SyncTmp()
{
	register Block	*b;
#ifdef MSDOS
	register daddr	bno = 0;

	/* sync the blocks in order, for file systems that don't allow
	   holes (MSDOS).  Perhaps this benefits floppy-based file systems. */

	for (bno = 0; bno < next_bno; bno++) {
		if ((b = lookup_block(bno)) != NULL && b->b_dirty) {
			(*blkio)(b, (SSIZE_T (*) ptrproto((int, UnivPtr, size_t)))write);
			b->b_dirty = NO;
		}
	}
#else /* !MSDOS */
	for (b = f_block; b != NULL; b = b->b_LRUnext)
		if (b->b_dirty) {
			(*blkio)(b, (SSIZE_T (*) ptrproto((int, UnivPtr, size_t)))write);
			b->b_dirty = NO;
		}
#endif /* !MSDOS */
}

/* A prototyped definition is needed because daddr might be affected
 * by default argument promotions.
 */

private Block *
#ifdef USE_PROTOTYPES
lookup_block proto((register daddr bno))
#else
lookup_block(bno)
register daddr	bno;
#endif
{
	register Block	*bp;

	for (bp = bht[B_HASH(bno)]; bp != NULL; bp = bp->b_HASHnext)
		if (bp->b_bno == bno)
			break;
	return bp;
}

private void
LRUunlink(b)
register Block	*b;
{
	if (b->b_LRUprev == NULL)
		f_block = b->b_LRUnext;
	else
		b->b_LRUprev->b_LRUnext = b->b_LRUnext;
	if (b->b_LRUnext == NULL)
		l_block = b->b_LRUprev;
	else
		b->b_LRUnext->b_LRUprev = b->b_LRUprev;
}

private Block *
b_unlink(bp)
register Block	*bp;
{
	register Block	*hp,
			*prev = NULL;

	LRUunlink(bp);
	/* Now that we have the block, we remove it from its position
	   in the hash table, so we can THEN put it somewhere else with
	   it's new block assignment. */

	for (hp = bht[B_HASH(bp->b_bno)]; hp != NULL; prev = hp, hp = hp->b_HASHnext)
		if (hp == bp)
			break;
	if (hp == NULL) {
		writef("\rBlock %ld missing!", (long)bp->b_bno);
		finish(0);
	}
	if (prev)
		prev->b_HASHnext = hp->b_HASHnext;
	else
		bht[B_HASH(bp->b_bno)] = hp->b_HASHnext;

	if (bp->b_dirty) {	/* do, now, the delayed write */
		(*blkio)(bp, (SSIZE_T (*) ptrproto((int, UnivPtr, size_t)))write);
		bp->b_dirty = NO;
	}

	return bp;
}

/* Get a block which contains at least part of the line with the address
   atl.  Returns a pointer to the block and sets the global variable
   nleft (number of good characters left in the buffer). */

/* A prototyped definition is needed because daddr might be affected
 * by default argument promotions.
 */

private char *
#ifdef USE_PROTOTYPES
getblock proto((daddr atl, bool IsWrite))
#else
getblock(atl, IsWrite)
daddr	atl;
bool	IsWrite;
#endif
{
	register daddr	bno,
			off;
	register Block	*bp;
	static Block	*lastb = NULL;

	bno = da_to_bno(atl);
	off = da_to_off(atl);
	/* We don't allow block number MAX_BLOCKS-1 to be used because
	 * NOWHERE_DADDR and NOTYET_DADDR must not be valid disk references,
	 * and we want to prevent space overflow from being undetected
	 * through arithmetic overflow.
	 */
	if (bno >=  MAX_BLOCKS-1)
		error("Tmp file too large.  Get help!");
	nleft = JBUFSIZ - off;
	if (lastb != NULL && lastb->b_bno == bno) {
		bp = lastb;	/* same as last time */
	} else if ((bp = lookup_block(bno)) != NULL) {
		/* The requested block already lives in memory, so we move
		   it to the end of the LRU list (making it Most Recently Used)
		   and then return a pointer to it. */
		if (bp != l_block) {
			LRUunlink(bp);
			if (l_block == NULL)
				f_block = bp;
			else
				l_block->b_LRUnext = bp;
			bp->b_LRUprev = l_block;
			l_block = bp;
			bp->b_LRUnext = NULL;
		}
		if (bno >= next_bno)
			next_bno = bno + 1;
	} else {
		/* The block we want doesn't reside in memory so we take the
		   least recently used clean block (if there is one) and use
		   it.  */
		bp = f_block;
		if (bp->b_dirty)	/* The best block is dirty ... */
			SyncTmp();

		bp = b_unlink(bp);
		if (l_block == NULL)
			f_block = bp;
		else
			l_block->b_LRUnext = bp;	/* Place it at the end ... */
		bp->b_LRUprev = l_block;
		l_block = bp;
		bp->b_LRUnext = NULL;		/* so it's Most Recently Used */

		bp->b_dirty = NO;
		bp->b_bno = bno;
		bp->b_HASHnext = bht[B_HASH(bno)];
		bht[B_HASH(bno)] = bp;

		/* Get the current contents of the block UNLESS this is a new
		   block that's never been looked at before, i.e., it's past
		   the end of the tmp file. */

		if (bno < next_bno)
# ifndef MINT
			(*blkio)(bp, read);
# else
			(*blkio)(bp, (SSIZE_T (*) ptrproto((int, UnivPtr, size_t)))read);
# endif
		else
			next_bno = bno + 1;
	}
	lastb = bp;
	bp->b_dirty |= IsWrite;
	return bp->b_buf + off;
}

char *
lbptr(line)
LinePtr	line;
{
	return getblock(line->l_dline, NO);
}

/* save the current contents of linebuf, if it has changed */

void
lsave()
{
	if (curbuf == NULL || !DOLsave)	/* Nothing modified recently */
		return;

	if (strcmp(lbptr(curline), linebuf) != 0)
		SavLine(curline, linebuf);	/* Put linebuf on the disk. */
	DOLsave = NO;
}

#ifdef BACKUPFILES
private void
file_backup(fname)
char *fname;
{
# ifndef MSFILESYSTEM
	SSIZE_T	rr;
	int
		ffd,
		bffd;
	char
		buf[JBUFSIZ],
		bfname[FILESIZE];

	/* build backup file name */
	{
		char	*s = strrchr(fname, '/');
		size_t	dirlen = (s == NULL)? 0 : s + 1 - fname;

		strcpy(bfname, fname);
		swritef(bfname+dirlen, (size_t) (sizeof(bfname) - dirlen), "#%s~",
			fname+dirlen);
	}

	if ((ffd = open(fname, 0)) < 0)
		return;	/* cannot open original file: nothing to backup, we assume */

	/* create backup file with same mode as input file */
	{
#  ifdef MAC
		int	mode = CreatMode;	/* dummy */
#  else
		struct stat statbuf;
		int	mode = fstat(ffd, &statbuf) != 0? CreatMode : statbuf.st_mode;
#  endif

		if ((bffd = creat(bfname, mode)) < 0) {
			int	e = errno;

			(void) close(ffd);
			complain("[cannot create backup \"%s\": %d %s]",
				bfname, e, strerror(e));
		}
	}

	/* copy the contents */
	while ((rr = read(ffd, (UnivPtr) buf, sizeof(buf))) > 0) {
		char	*p = buf;

		while (rr > 0) {
			SSIZE_T	wr = write(bffd, (UnivPtr) p, (size_t) rr);

			if (wr < 0) {
				int e = errno;

				close(bffd);
				close(ffd);
				complain("[error writing backup: %d %s]", e, strerror(e));
			}
			p += wr;
			rr -= wr;
		}
	}

	if (rr < 0 || close(ffd) != 0)
		complain("[error reading \"%s\": %d %s]", fname, errno, strerror(errno));
#  ifdef USE_FSYNC
	if (fsync(bffd) != 0) {
		int	e = errno;

		(void) close(bffd);
		complain("[error fsyncing backup: %d %s]", e, strerror(e));
	}
#  endif /* USE_FSYNC */
	if (close(bffd) != 0)
		complain("[error closing backup: %d %s]", errno, strerror(errno));

# else /* MSFILESYSTEM */
	/* This code is designed to fit withing the 8.3 limitation of
	 * MSDOS ("FAT" -- huh!) file systems.  Even though newer versions
	 * of these APIs (Win32) may support longer file names, we may still
	 * be dealing with a FAT file system.
	 */
	char	*dot,
			*slash,
			tmp[FILESIZE];

	strcpy(tmp, fname);
	slash = basename(tmp);
	if ((dot = strrchr(slash, '.')) != NULL) {
		if (stricmp(dot,".bak") != 0)
			return;
		*dot = '\0';
	}
	strcat(tmp, ".bak");
	unlink(tmp);
	if (rename(fname, tmp) != 0)
		complain("[cannot rename to \"%s\": %s]", tmp, strerror(errno));
# endif /* MSFILESYSTEM */
}
#endif /* BACKUPFILES */


