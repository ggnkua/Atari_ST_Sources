/*
	fop.c -- file copy, move, remove, cd, mkdir etc	 08/02/86

	copyright (c) 1986, 1987 pm@Case

*/

#include "gu.h"

struct	de				/* dir entry in the dirstk	*/
{	char *		namep;
	struct	de *	nextp;
};

#define	MVFLAG	0x1122
local	char	*targetdir;		/* destination dir */
local	int	mvflag;			/* == MVFLAG iff mv operation */

local	struct de *	dirstkp;
local	int		dircnt = 0;
local	char		DSE[] = "dir stack is empty";

pwd()
{
	strg = gfgetcwd();
}

	local
cwdvar()
{	register char *p;

	p = gfgetcwd(); insertvar("cwd", p); gfree(p);
}

cdcmd()
{
	register char *p;

	p = lexgetword();
	if (*p == '\000') p = varstr("home");
	cd (p);
	cwdvar();
}


/* Push onto the dir stk the given gmalloc'd str p which is the name
of a dir */
	local
pushdir(p)
register char	*p;
{	register struct de *	dp;

	dp = (struct de *) gmalloc(sizeof(struct de));
	if (dp)
	{	dp->namep = p;	dp->nextp = dirstkp;
		dirstkp   = dp;
}	}

	local char *
popdir()
{
	register struct de *dp;
	register char * dir;

	if (dirstkp == NULL) return NULL;
	dir = dirstkp->namep;
	dp = dirstkp->nextp;	gfree(dirstkp);	dirstkp = dp;
	return dir;
}

dirs()		/* list the directories on the stack into strg 		*/
{
	register struct de	*dp;
	register WS		*ws;
	register char		*cwd;

	ws = initws();
	strwcat(ws, cwd = gfgetcwd(), 0);  gfree(cwd);
	for (dp = dirstkp; dp; dp = dp->nextp)
	{	strwcat(ws, " ", 0);
		strwcat(ws, dp->namep, 0);
	}
	if (ws) {strg = ws->ps; gfree(ws);}
}

pushd()			/* push the given dir onto the stack */
{
	register char	*p, *q;

	p = lexgetword();
	if (*p)
	{	q = gfgetcwd();
		cd(p);
		if (valu >= 0)
		{	cwdvar();  if (q) pushdir(q);
		} else gfree(q);
	}	
	else	/* no arg; so exch top elm with cwd */
	{	p = gfgetcwd(); q = popdir();
		if (q)	{pushdir(p); cd(q); cwdvar();}
		else	{gfree(p); emsg = DSE; valu = -1;}
	}
	dirs();		/* display the stack */
}

popd()
{
	register char *p;

	if (p = popdir()) {cd(p);  cwdvar(); gfree(p);}
	else		  {emsg = DSE; valu = -1; return;}
	dirs();
}

/* isdir()		-- see ls.c	*/

/* Given two pathnames p and q, return TRUE iff they both name the
same parent dir.  */

#if 00
samedir(p, q)
register char *p, *q;
{	register char	*r, *s;
	register int	n;

	r = rindex(p, DSC); s = rindex(q, DSC);
	if (r == s) return TRUE;	/* includes: r == s == NULL	*/
	if (r && s)
	{	*r = *s = '\000';
		n = (strcmp(p, q) == 0);
		*r = *s = DSC;
		return n;
	} else return FALSE;		/* r == NULL or s == NULL */
}
#endif

	local int
samedevice(p, q)
register uchar *p, *q;
{	register uchar	*r, *s;
	register int	n;

	if (p[0] == q[0] && p[1] == ':' && q[1] == ':') return TRUE;
	return (p[1] != ':' && q[1] != ':');
}

rename()
{
	register char *p, *q;

	p = lexgetword();	
	q = lexgetword();	
	valu = (*q ? gfrename(p, q) : -1);
}

rm(p)
register char *p;
{
	valu += gfunlink(p);
}

	local uchar *
mkfullname(p)
register uchar	*p;
{	register uchar	*q;
#define NFILEN	80

	q = (p? gmalloc(NFILEN) : NULL);
	if (q)
	{	if (strlen(p) < NFILEN)
		{	strcpy(q, p);
			fullname(q);
		} else	*q = '\000';
	}
	return q;
}

/* copy one file to another; both names are pathnames.  */

	local		
copyfio(in, ou, iscat)	
register uchar *in, *ou;
{
	register uchar	*s;
	register int	fi, fo, foflag;
	register long	m, n;
	unsigned long	lsz;
	unsigned int	sz, td[2];

	in = mkfullname(in); ou = mkfullname(ou);
	if ((in == NULL) || (ou == NULL)) goto ret;
	if (iscat) {foflag = 0; fo = 1;}
	else
	{	foflag = 1; /* so we can read the opened file right away */
		if (strcmp(in, ou) == 0) {valu = -1; goto ret;}
		if ((mvflag == MVFLAG) && samedevice(in, ou))
		{	rm(ou);
			if (valu == 0 || valu == EFILNF)
				valu = gfrename(in, ou);
			goto ret;
		}
		userfeedback(sprintp("%s -> %s", in, ou), 2);
	}

	lsz = 0x0FFFFE02L;
	s   = maxalloc(&lsz);

	lsz -= 2;		/* room for '\000' for iscat */
	lsz &= 0xFFFFFE00L;	/* better to read multiples of 512 */
	fi = gfopen(in, 0);
	if (fi <= 0) {emsg = sprintp("cp: %s not found", in); goto frees;}
	for (;;)
	{	n =  gfread(fi, s, lsz);
		if (foflag)
		{	fo = gfcreate(ou, 0);
			if (fo < MINFH)
			{ emsg = "could not create dest file";
			  valu = fo;
			  goto closefi;
			}
			foflag = 0;
		}
		if (n <= 0L) break;
		if (iscat) {s[n] = '\000'; outstr(s); m = n;}
		else	m = gfwrite(fo, s, n);
		if (m != n) {valu = EWRITF; break;}
	}
	if (foflag == 0) 
	{	if (fo != 1) valu = gfclose(fo);
		if (posopts['t']) {gfdatime(td, fi, 0); tch(ou, td);}
		/* didn't work for ST: Fdatime(td,fo,1); Fclose(fo);	*/
	}
	closefi:        valu = gfclose(fi);
	frees:		maxfree(s);
	if ((valu == 0) && (mvflag == MVFLAG)) rm(in);
	ret:		gfree(in); gfree(ou);
}

	local
setupdir(q)
register char	*q;
{	register char	*r;

	targetdir = r = gmalloc(strlen(q)+2); /* may need to append DSC */
	if (r == NULL) {valu = ENSMEM; return;}
	strcpy(r, q);
	r += strlen(r) - 1;
	if (*r != DSC) {*++r = DSC; *++r = '\000';}
}

local cpdirtodir();

	local
cpftodir(p)
register char * p;
{
	register char	*q, *r;
	register int	dirflag;

	dirflag = isdir(p);

	r = ((p[0] != '\000') && (p[1] == ':')? p+2 : p);
	q = rindex(r, DSC);
	q = (q == NULL? r : q+1);

	/* q now points to leaf name */
	r = str3cat(targetdir, q, ES);
	if (dirflag)
		{if (negopts['R'] || negopts['r']) cpdirtodir(p, r);}
	else copyfio(p, r, 0);
	gfree(r);
}


/* Copy all the files in directory ind to the dest directory given in oud.
 Dir oud may or may not be an existing one.
*/
	local
cpdirtodir(ind, oud)
char	*ind, *oud;
{	register char	*p, *olddir;
	register WS	*ws;
	extern	 uchar	DS0[];

	olddir = targetdir; ws = NULL;
	gfmkdir(oud);
	/* create dir oud, if it did not exist before; no harm, ow */
	p = ind + strlen(ind) - 1;
	p = (*p == DSC? ES : DS0);
	p = str3cat(ind, p, "*");
	ws = metaexpand(p); gfree(p);
	if (ws == NULL || (p = ws->ps) == NULL) goto ret;
	setupdir(oud);
	for (; *p; p += strlen(p)+1)
	{	if (useraborted()) break;	
		cpftodir(p);
	}
	gfree(targetdir);

	ret:	freews(ws);
	targetdir = olddir;
	if ((valu == 0) && (mvflag == MVFLAG)) valu = gfrmdir(ind);
}

cp()
{
	register char	*p, *q, *op, *r, c;
	register int	i;

	op = (++mvflag == MVFLAG? "mv" : "cp");

	q = lexlastword();
	if (isdir(q))
	{	setupdir(q);
		doforeach(op, cpftodir);
		gfree(targetdir);
	} else
	{	for (i=0, r=NULL;;)
		{	p = lexgetword(); c = *p;
			if (c == '\000') break;
			else {r = p; i++;}
		}
		if (i == 0) emsg = "destination ?";
		if (i >  1) emsg = sprintp("last arg '%s' must be a dir", q);
		else	if (asktodoop(op, r) == 1) copyfio(r, q, 0);
	}
	mvflag = 0;
}

/* Move files to destination.  We do this by copying to dest and
deleting the source.  The mvflag is set to 1-less than MVFLAG, so that
after ++ in cp() it will equal MVFLAG; this takes care of the
situation when mv is interrupted by user, so that the next cp does not
work as if a mv was requested.  */

mv()
{
	mvflag = MVFLAG - 1;
	cp();
}

cat(p)
register uchar	*p;
{
	copyfio(p, ES, 1);
}

/* -eof- */
