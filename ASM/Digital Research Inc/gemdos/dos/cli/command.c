/*	command.c

GEMDOS command interpreter

Originally written by JSL.

MODIFICATION HISTORY - As of version 0.20 as modified by LTG

   06-03-85 0.21 LTG Fixed bug in chkDir, not copying null in wildExp.
   06-03-85 0.22 LTG Fixed bug in rename command.
   06-05-85 0.23 LTG Fixed type command - msg 6.
                     Batch files now must end in .BAT.
   06-07-85 0.24 LTG Fixed bug in ERA which erased all with <foo.foo as input
                     Freed up batch files in inhouse version.
   06-07-85 0.25 LTG Move batch files to general consumption version
                     Built enviornment strings
   06-12-85 0.26 LTG Fixed bug with ctl c.
                     Fixed bug with show,  enhanced show command.
                     Added MOVE command.
                     Added Quoted (") strings to REM
                     Added ECHO as a synonym of REM
   06-13-85 0.27 LTG Fixed bug in program execution causing Command Not found
                     message when program returs negative word
   06-17-85 0.29 LTG Fixed bug that caused atari to crash.
   06-17-85 0.30 LTG Added ENV command.
   06-26-85 0.31 LTG Added HELP facility.
   07-22-85 0.32 LTG Added \r \n \0 to REM and ECHO.
   07-25-85 0.33 LTG Added ERR and CHMOD commands.
                     Added err message to CD if directory not found.
                     Fixed bug in diectory display.
   08-06-85 0.34 LTG Changed '\' to '/' in chk_sub() and chk_str().
                     Fixed bug in copy displaying two msg for file not found.
   08-07-85 0.35 LTG Fixed bug in chk_sub() that caused a problem in parameter
                     substitution involving NULL strings.
   08-12-85 0.36 LTG Added code to abort processing if any .prg file returns
                     an error condition.  Thus batch files are terminated show
                     one of its commands fail.
   08-15-85 0.37 LTG Fixed bug running multiple batch files.  Move dup(0) and
                     dup(1) into code specific to I/Oa redirection.
                     Implemented PRGERR to enable/disable command processing abort
                     on non zero completion code from .PRG files.
   08-16-85 0.38 LTG Added querry function to erase.
   08-19-85 0.39 LTG Fixed bug in @CMD function that passed args from previous cmd.
   10-16-85 0.40 LTG Changed CLS to ^h^j
                     Fixed bug with abort when output redirected which stays so
                     Fixed bug in copy which does not respond properly to read error.
                     Added Comment facility.
                     Added WIDE list option to DIR.
                     Added message to warn when ren or copy wild carded name
                     Fixed bug in REN that caused list of renamed files to be
                     put one after the other on display.
   11-08-85 0.41 LTG Added ability to parse command tail passed to command.prg
   11-14-85 0.42 LTG Added code to erase partially created file when copy aborts
                     Fixed bug that disallowed copy \pathn \pathx
                     Added code to allow spec of multiple names in del command
   11-21-85 0.43 LTG Added multiple files to type command.
                     Changed code so that commands ouput to screen when > used.
   12-17-85 0.44 LTG Fixed bug in REM.
   01-17-85 0.45 LTG Added stay STAY and total files to dir.
   02-25-86 0.46 MLC Fixed bug in xCmdLn when removing root directory, crashed.
   		     Fixed bug in ioredirection when an illegal file name is 
		     there, creating the file has problem.
		     Add time, type, date, diff, era, find and format to help
		     message and corrected some misspelling.
   03-07-86 0.47 MLC Fixed bug in SHOW command with illegal drive name.
		     Fixed bug in CHMOD command without mode specification.
		     Fixed bug in I/O redirection, checking if files can be created.
   		     Fixed bug in "copy a:  " command, where a is current directory.
   03-14-86 0.48 MLC Fixed bug in chk_sub. When %% is enter.
    		     date.prg and time.prg are also modified seperately.
   03-18-86 0.49 MLC Fixed bug in HELP command: displays too many lines before
    		     pausing and also pausing when output was redirect.
    		     Fixed bug in dspCL: command line was not completely 
    		     displayed, the redirection symbol and the file name missing
    		     Fixed bug in CHMOD command: when the mode was not 0,
    		     not message was displayed; wildcards was not processed
    		     correctly: only one file get changed mode.
    		     Fixed bug in DIR command: displayed hidden and system file.
    		     Fixed bug in DEL command: displayed "DONE",even the file
    		     is a read only file.
    		     Fixed bug in RD command: when "rd a:".
    		     Fixed bug in REM command: it not only displayed the string
    		     but also the whole command.
    		     Fixed bug in nesting too many levels of batch files causing
    		     the system crash without warning.
   03-25-86 0.50 MLC Fixed scrolling in help command.
   03-31-86 0.51 MLC Fixed bug in RD command. 
    		     Fixed bug in @ directive.
    		     Changed wording in SHOW error message.
    		     Added "Done" message to "RD" and "MD" command when finish.
   04-15-86 0.52 MLC Fixed bug in copy file to it self.
   04-21-86 0.53 MLC Fixed bug in copy command. Put the current directory in
    		     the path name when none is supplied. Also fixed the bug
    		     in a command line specified @ as output file.(e.g. >@)
   05-01-86 0.54 MLC Fixed bug in chk_sub, so that if % is contained in a quoted
    		     string, it will not be processed as parameter substitute.
    		     Fixed bug in rename and copy command.  Also fixed bug in
    		     readDsk. Fixed bug in outputting "command not found".
   05-07-86 0.55 MLC When wildcard in the TYPE command, print error message.
    		     Added cr/lf to the end of help message. Fixed COPY command 
    		     such that it copy the date stamp from the old file. Deleted
    		     the repeated lines in help message.  Fixed DIR command for
    		     the hidden/system file.
   06-03-86 0.57 MLC Fixed bug in COPY command. Fixed invalid drive/path name
    		     in COPY, MOVE, CHANGE DIRECTORY, INIT, PATH commands.
   08-06-86 0.58 MLC Fixed bug in chk_redirect.  Fixed bug in COPY command
    		     so the file attributes is set as the source file.  Fixed
    		     bugs in write error in TYPE command and add wrerr routine.
    		     Also fixed bug in chdir.
   09-15-86 0.59 MGA Fixed bug in creation of the copy of environment strings
		     for an xexec'd process: one byte too few being allocated
		     for the environment.
   10-28-86 0.60 MLC Fixed bug in deleting a file name -.  - is for query option
    		     for the delete command before, since no doc mentions it,
    		     it will be taken away.
   10-30-86 0.61 MLC Fixed bug in dir command with subdirectory names longer
    		     than 67.
   10-31-86 0.62 MLC Fixed bug in file names specified by "?" in the commands
    		     COPY, DIR, MV, DEL, CD, RD etc.  Fixed bug in SHOW when
    		     an illegal drive name is entered.  Correct the spelling
    		     in Help command.  When no file is copied, change "Done"
    		     to "No file found" in COPY command.  Also took care of "*",
    		     "?" in PATH command.
   11-06-86 0.63 MLC Not allow '*' or '?' in PATH, CD, MD and RD commands. 
   11-07-86 0.64 MLC RD did not print the error message when there is a * or ?.
   11-11-86 0.65 MLC '*' or '?' in .bat file or .prg file name, issue error message.
   11-13-86 0.66 MLC Make buffer larger to hold directory/path/file name.  If
    		     no file are deleted, issue "no file deleted" instead of "done"

NAMES

	JSL	Jason S. Loveman
	LGT	Lou T. Garavaglia
	SCC	Steven C. Cavender
	MLC	Mei L. Chung
	MGA	Mark G. Alexander

*/

extern long xoscall();
extern long bios();
extern      in_term();
extern      rm_term();
extern      super();
extern      user();

#define NULLPTR (char *)0
#define FALSE 0
#define TRUE -1
#define MAXARGS 20

#define xrdchne() xoscall (0x08)
#define xecho(a) xoscall (0x02,a)
#define xread(a,b,c) xoscall(0x3f,a,b,c)
#define xwrite(a,b,c) xoscall(0x40,a,b,c)
#define xopen(a,b) xoscall(0x3d,a,b)
#define xclose(a) xoscall(0x3e,a)
#define xcreat(a,b) xoscall(0x3c,a,b)
#define xforce(a,b) xoscall(0x46,a,b)
#define xexec(a,b,c,d) xoscall(0x4b,a,b,c,d)
#define dup(a) xoscall(0x45,a)
#define xgetdrv() xoscall(0x19)
#define xsetdrv(a) xoscall(0x0e,a)
#define xsetdta(a) xoscall(0x1a,a)
#define xsfirst(a,b) xoscall(0x4e,a,b)
#define xsnext() xoscall(0x4f)
#define xgetdir(a,b) xoscall(0x47,a,b)
#define xmkdir(a) xoscall(0x39,a)
#define xrmdir(a) xoscall(0x3a,a)
#define xchdir(a) xoscall(0x3b,a)
#define xunlink(a) xoscall(0x41,a)
#define xrename(a,b,c) xoscall(0x56,a,b,c)
#define xgetfree(a,b) xoscall(0x36,a,b)
#define xterm(a) xoscall(0x4c,a)
#define xf_seek(a,b,c) xoscall(0x42,a,b,c)
#define xmalloc(a) xoscall(0x48,a);
#define xmfree(a) xoscall(0x49,a);
#define xattrib(a,b,c) xoscall(0x43,a,b,c)
#define getbpb(a) bios(7,a)
#define rwabs(a,b,c,d,e) bios(4,a,b,c,d,e)
#define xdatime(a,b,c) xoscall(0x57,a,b,c)

#define BPB struct _bpb
BPB /* bios parameter block */
{
	int	recsiz;
	int	clsiz;
	int 	clsizb;
	int	rdlen; /* root directory length in records */
	int	fsiz; /* fat size in records */
	int	fatrec; /* first fat record (of last fat) */
	int	datrec; /* first data record */
	int	numcl; /* number of data clusters available */
        int     b_flags;
} ;

struct rdb 	 			/*IO redirection info block		*/
	{
	int	nso;
	int	nsi;
	int	oldso;
	int	oldsi;
	};

struct rdb * rd_ptr;

char zero = { '0' } ;
char hexch[] = { '0','1','2','3','4','5','6','7',
		'8','9','A','B','C','D','E','F' } ;

int drv;
int exeflg;
int rtrnFrmBat;
int prgerr;
int cmderr;
int batlev;	/* batch file nested level*/

long jb[3];
long compl_code;

#define BUFSIZ 10000
char buf[BUFSIZ];

char lin[130];
char srchb [44];
char prgTail[5] = {".PRG"};
char batTail[5] = {".BAT"};
char autoBat[13]= {"AUTOEXEC.BAT"};
char pthSymb[6] = {"PATH="};
char drvch;
char * basePage;
char * prntEnvPtr;

/* Declarations for Wild Card processing: */
char    *WSrcReq;
int      WAttCode;
char     wildExp[4] = {"*.*"};
char     srcFlNm[140];  /*src file name*/
char     dstFlNm[140];  /* destination file name */
char     srcDir[140];   /*src dir path*/
char     dstDir[140];   /*dst dir path */
char     srcNmPat[13]; /*src file name specified in path */
char     dstNmPat[13]; /*dst file name specified in path */
char     path[140];    /*lst of default path names       */

/*Forward declarations.*/
xCmdLn (), wrt(), wrtln();


/***************************************************************************/	
/*
   chk_redirect - determines it input or output has been redirected, if so
                  restoring it to previous value.
*/
/***************************************************************************/
chk_redirect (r)
register struct rdb * r;

{
/* if a new standard in specified ...*/
if (r->nsi == -1)
   {
   xclose(0);
   xforce(0,r->oldsi);
   xclose(r->oldsi);
   r->nsi = 0;
   }
/* if a new standard out specified.*/
if (r->nso == -1)
   {
   xclose(1);
   xforce(1,r->oldso);
   xclose(r->oldso);
   r->nso = 0;
   }
}   

/***************************************************************************/	
errout ()
{
chk_redirect (rd_ptr);
xlongjmp (jb, -1);
}

/***************************************************************************/	
xncmps(n,s,d)
register int n;
register char *s,*d;
{
	while (n--) if (*s++ != *d++) return(0);
	return(1);
}

/***************************************************************************/	
prthex(h)
unsigned h;
{
	unsigned h2;
	if (h2 = (h >> 4)) prthex(h2);
	else xwrite(1,1L,"0");
	xwrite(1,1L,&hexch[h & 0x0f]);
}

/***************************************************************************/	
/***************************************************************************/	
strlen(s)
register char *s;
{
	register int n;
	for (n=0; *s++; n++);
	return(n);
}

/***************************************************************************/	
/***************************************************************************/	
prtdecl(d)
long d;
{
	if (d) pdl(d);
	else
          xwrite(1,1L,"0");
}

/***************************************************************************/	
/***************************************************************************/	
pdl(d)
long d;
{
	long d2;
	if (d2 = d / 10) pdl(d2);
	xwrite(1,1L,&hexch[d % 10]);
}

/***************************************************************************/	
/***************************************************************************/	
prtDclFmt (d, cnt, ch)
long d;
int cnt;
char * ch;

{
register int i;
register long k, j;

k = (d ? d : 1);
j = 1;
for (i = 1; i < cnt; i++) j *= 10;
while (k < j) 
   {
   xwrite (1, 1L, ch);
   k *= 10;
   }
prtdecl (d);
}

/***************************************************************************/	
/***************************************************************************/	
ucase(s)
register char *s;
{
	for ( ; *s ; s++) if ((*s >= 'a') && (*s <= 'z')) *s &= ~0x20;
}
/***************************************************************************/
/*chk_wild checks wildcard * and ? in the string s.  If s contains * or ?, */
/*it issue error message and return false, else it return true.	           */
/***************************************************************************/
int chk_wild(s)
char *s;
{
    char *q;
    q=s;		/*scan input to see any * or ? embeded*/
    while(*q && *q != '*' && *q != '?') q++;
    if(*q)
    	   {dspMsg(18); wrt(s); compl_code = -1L; return(0);}
    else return(-1);
}
/***************************************************************************/
/*
   gtFlNm - get file name of the next file in the directory match a 
      path\wildcat specification. The first invocation makes a call to
      xsfirst.  Each subsequent invocation uses xsnext().  To invoke
      the routine, the wildcarded path name is put into WSrcReq and the
      routine called.  For this and each subseqent call the descriptor block
      block for the found file (if one was found) is pointed to by WThisSrc.


   returns 0 if no match
   returns -1 if file found

*/
/***************************************************************************/

int  gtFlNm ()

{
/* First file request?		*/
if (WSrcReq != NULLPTR)			
   {
   if (xsfirst(WSrcReq, WAttCode)) return(FALSE);

   WSrcReq = NULLPTR;
   } 

/* Subsequent file request	*/
else 
   {
   if (xsnext()) return(FALSE);
   }
return (TRUE);
}
/***************************************************************************/
/* 
  chkDir - Evaluates pathExp to determine if it specifies a directory, 
     or a file name.  For convenienc sake it stuffs the directory part in
     dirExp and the file name into filExp.   If a file name (ambiguous or
     not) was found, it is place in filExp.  If no file name was found,
     filExp points to "*.*".

  int chkDir (pathExp, dirExp, filExp, check)

returns	  -4 if Illegal syntax : was found.
returns   -3 if wild cards specified in path name
          -2 if pathExp does NOT specify a file, directory, or device
          -1 if pathExp evaluates to a subdirectory, or a volume label
           0 if pathExp evaluates to a normal, read-only, or system file
           1 if pathExp evaluates to a normal, read-only, or system file but
             was specified with wild cards

  pathExp - ptr to path expression, w/wo wild cards to be evaluated
  dirExp  - ptr to dir part of pathExp
  filExp  - ptr to file.ext part of pathExp
  check	  - flag to check if the file exists.
*/
/***************************************************************************/

int chkDir (pathExp, dirExp, filExp, check)

char *pathExp, dirExp[], filExp[];
int  check;
{
int pathLen   = strlen (pathExp);
int dirLen;
int wildLen   = strlen (wildExp);
int wildFnd   = FALSE;
int i         = 0;
int flExsists;
char c, pathbuf[100], *p, *q;

/*directory length = path length to start with.*/
dirLen = pathLen;
pathbuf[0] = pathbuf[2] = 0;
ucase(pathExp);

if(!pathLen){ /*if no directory was specified, use current drive*/
    pathExp[0] = xgetdrv() + 'A';
    pathExp[1] = ':';
    xgetdir(&pathbuf[0], 0); /*get current path name*/
    for(dirLen = pathLen = 2, p=pathbuf, q=pathExp+2;
    	 *q = *p; dirLen++, pathLen++, p++, q++);
    if(*(q-1) != '\\'){
    	*q++ = '\\';
    	*q = 0;		/*terminated by null*/
    	pathLen++;
    	dirLen++;
    }
}
else{
/* Loop thru path expresion from end looking for delimeters and the 1st char.*/
    do
   	{
   	if ((c = pathExp[dirLen]) == '*' || c == '?') wildFnd = TRUE;
   	}
    while ((c != ':') && (c != '\\') && (dirLen--));
    if(dirLen++ && c == '\\')	/*contains subdiretory name,but not from root*/
    	i = dirLen;
    if(c==':'){
        if (pathExp[1] != ':') return(-4);
    	pathbuf[0] = pathExp[0];
        pathLen -= 2; /*drive name & :*/
    	q = pathExp + 2;
    	xgetdir(&pathbuf[2], pathExp[0] - 'A' + 1);
    	goto cp_dir;
    }
    else if (!dirLen || (pathExp[1] != ':')){	/*no drive was specified*/
    	pathbuf[0] = xgetdrv() + 'A';	/*get the default drive name*/
    	q = pathExp;
    	if(*q == '\\'){	/*root was specified, don't get the default directory*/
    	    pathLen--;
    	    if(i > 1) --i;
    	    q++;
    	    goto cp_dir;
    	}
    	xgetdir(&pathbuf[2], 0);
cp_dir:
    	pathbuf[1] = ':';
    	for(dirLen=2, p=pathbuf+2; *p; p++, dirLen++);
    	if (*(p-1) != '\\'){
    	    *p++ = '\\';
    	    dirLen++;
    	}
    	dirLen += i;
    	for( ; pathLen > 0; pathLen--)	/*copy file name to pathbuf*/
    	    *p++ = *q++;
    	*p = 0; /*terminated by null*/
    	for(p=pathbuf, q=pathExp; *q++ = *p++; pathLen++); /*copy to pathExp*/
    }
}
/* IF nothing specified defalult to wild expresion.*/
if ((pathExp[pathLen - 1] == '\\') || (pathExp[pathLen - 1] == ':')) 
   {
   i = 0;
   while (pathExp[pathLen] = wildExp[i])
      {
      pathLen++;
      i++;
      } 
   wildFnd = TRUE;
   }

/* return file not found if not found.*/
flExsists = xsfirst (pathExp, WAttCode) ? -2 : 0;

/* if wild cards were specified in file name and file exsists return 1 */
flExsists = wildFnd ? (flExsists ? -2 : 1) : flExsists;

if(check && wildFnd && flExsists == -2) return(flExsists);

/* If no wild cards/file name found check if directory. */
if (!wildFnd) 
   {
   /* if a file structure exsists...*/
   if (!flExsists)
      {
      /* if it is a directory or a volume label...*/
      if (srchb[21] & 0x18) 
         {
         /* Set up dirLen to encompas entire path specification.*/
         dirLen = pathLen;

         /*Tackon a path seperator.*/
         pathExp[dirLen++] = '\\';

         /* copy wild card expresion into spec'd path and file name.*/
         for (i = 0; i <= wildLen; i++) 

            /* onto end of path expresion.*/
            pathExp[i + dirLen] = wildExp[i];

         flExsists = -1;
         }
      }
   }
 /* copy path exp into directory expresion.*/
for(pathLen = 0; pathLen < dirLen; pathLen++) 
    dirExp[pathLen] = pathExp[pathLen];

/* chop off file nm from dirExp.*/
dirExp [dirLen] = '\0';

/* copy file name into return var.*/
i = 0;
while (c = filExp[i++] = pathExp[pathLen++])
    if(c == '*') flExsists = -3;

return (flExsists);
}
/***************************************************************************/
/* 
   int chkDst ();

   chkDst - Checks dst file name for validity. If there are any wild cards in
      the source file name the only valid dst names are "*", or "*.*".  Any
      thing else results in an error.

   returns 0 if no error
           -1 if unable to make dst file name

*/   
/***************************************************************************/	
int chkDst ()

{
int i = 0;
char c;

/* check for proper use of wild chards.*/
while (c = srcNmPat[i++])
   {
   /* Look for wild card chars.*/
   switch (c) 
      {
      case '*':
      case '?': 
         
doDstChk:
         /* If dst file name longer than wild exp, must be error.*/
         if (strlen(dstNmPat) > strlen(wildExp)) return -1;

         /* Loop till end of dst fil nam to see if it matches wild exp.*/
         for (i = 0; (c = dstNmPat[i]); i++)
            if (c != wildExp[i]) return -1;

         /* return ok.*/
         return (0);

      default : break;
      }
   }

/* if any wild cards in dst, check for validity.*/
for (i = 0; (c = dstNmPat[i]); i++) 
   if ((c == '*') || (c == '?')) goto doDstChk;

/* return ok.*/
return 0;
}
/***************************************************************************/	
/*
   int mkDst - Make dst file name.

   returns 0 if dst other than src
   returns -1 if dst same as src

   srcFlNm - ptr to string from search first on path name
   dstFlNm - ptr to string that will recieve destination file name
   srcDir  - ptr to src dir path
   dstDir  - ptr to dst dir path
   srcNmPat- ptr to string that contains the file name specified in path
   dstNmPat- ptr to string that contains the dst pattern

*/
/***************************************************************************/	
int mkDst ()

{
register int i, k, ndx;
register int srcEqDst;

i = 0;
ucase(&srchb[30]);

/* determine If dst dir path = src dir path.*/
while ((srcEqDst = (srcDir[i] == dstDir[i])) && srcDir[i] 
   &&  dstDir[i]) i++; 

/* if they do...*/
if (srcEqDst) 
   {
   i = 0;

   /* if the dst is not a wild card (in which case auto match)...*/
   if (!(srcEqDst = (dstNmPat[0] == '*')))

      /* loop, chk each src=dst file.ext for match, setting srcEqDst. */
      while ((srcEqDst = (srchb[30 + i] == dstNmPat[i])) 
         && srchb[30 + i] && dstNmPat[i]) i++;
   }
i = 0;
ndx = 0;
/* copy dst dir path into dst file name.*/
while (dstFlNm[ndx] = dstDir[ndx]) ndx++;

if (srcEqDst)
   {
/* if the entire name matches create a dst file name with '.&&&' as ext*/

   while ((dstFlNm[ndx + i] = srchb[30 + i]) 
      && (dstFlNm[ndx + i] != '.')) i++;
   dstFlNm[ndx + i++] = '.';

   for (k = 0; k <= 2; k++)
    	dstFlNm[ndx + i + k] = '&';
   }

/* else file names do not match.*/
else
   {
   
   /* if dst file pat is wild card, copy src file name into dst file name.*/
   if (dstNmPat[0] == '*')
      while (dstFlNm[ndx + i] = srchb[30 + i]) i++;
   
   else
      /* copy dst name pat directly into dst file name.*/
      while (dstFlNm[ndx + i] = dstNmPat[i]) i++;
   }
return (srcEqDst);
}

/***************************************************************************/
/* 
   mkSrc - make source file name from directory path and file name.

*/
/***************************************************************************/
mkSrc ()

{
register int i,j = 0;

/* copy src directroy into src directory file name.*/
for (i=0; (srcFlNm[i] = srcDir[i]); i++);

/* copy source file name from search first/next into src file name.*/
while (srcFlNm[i + j] = srchb[30 + j]) j++;
ucase(srcFlNm);
}
/***************************************************************************/
/*
    wrerr - write error
*/
/***************************************************************************/
wrerr()
{
   int fd;
   fd = xopen("CON:",2);
   xwrite(fd,24L,"\r\nFile write error....\r\n");
   xclose(fd);
   errout();
}
/***************************************************************************/
/*
   wrt - write to standard output
*/
/***************************************************************************/
wrt (msg)
char * msg;

{  int count, bytes;

bytes = strlen(msg);
count = xwrite (1, (long)strlen(msg), msg);
if (count != bytes)  wrerr();
}

wrtln (msg)
char *msg;

{
wrt ("\r\n");
wrt (msg);
}

wrtch (ch)
char ch;

{
char str [2];

str [0] = ch;
str [1] = 0;
wrt (str);
}

/***************************************************************************/
/*
wrtEol () {wrt ("\r\n");}

to (n)
int n;
{
char ch;
ch = n+'0';
wrt(" OUT<< ");
xwrite (1, 1L, &ch);
wrt ("\r\n");
}

ti (n)
int n;
{
char ch;
ch = n+'0';
wrt(" IN>> ");
xwrite (1, 1L, &ch);
wrtln ("");
}
*/
/***************************************************************************/
/*
   cr2cont - wait for cariage return before continuing.
*/
/***************************************************************************/
cr2cont()
{
wrt ("CR to continue...");
lin[0] = 126;
xoscall(10,&lin[0]);
}
/***************************************************************************/
/*
   dspMsg - dsplay message
*/
/***************************************************************************/
dspMsg (msg, stand_out)
int msg, stand_out;
{
switch (msg)
   {
   case 0: wrtln ("Wild cards not allowed/Cannot rename/type directories."); break;
   case 1: wrtln ("File Not Found."); break;
   case 2: wrtln ("Destination is not a valid wild card expresion."); break;
   case 3: wrtln ("******* TEST  CLI *******"); break;
   case 4: wrtln ("Command v0.66 11/13/86 MLC \n");break;
   case 5: wrt ("Done."); break;
   case 6: wrtln ("Command is incompletely specified.");break;
   case 7: wrt (srcFlNm); break;
   case 8: wrt (dstFlNm); break;
   case 9: wrtln ("."); break;
   case 10:wrt (" to "); break;
   case 11:
           break;
   case 12:wrtln (""); break;
   case 13:wrtln ("");
   case 14:wrt ("{");
           drvch = (drv = xgetdrv()) + 'a';
           xwrite (1,1L,&drvch);
           wrt ("}");
           break;
   case 15:wrtln ("Wild cards not allowed in destination."); break;
   case 16:drvch = (drv = xgetdrv()) + 'a';
           xwrite (1,1L,&drvch);
           wrt (":");
           break;
   case 17:
           wrtln ("# in the first non blank column in a batch file is a comment.");
           wrtln ("CAT or TYPE filenm.ext [[filenm.ext]...]");
           wrtln ("    Writes filenm.ext(s) to standard output.");
           wrtln ("CD [pathnm]");
           wrtln ("    With pathnm it sets default for working directory.");
           wrtln ("    Without pathnm displays current working directory.");
           wrtln ("CHMOD [pathnm/]filenm mode");
           wrtln ("    Changes the mode of the file specified in filenm to the"); 
           wrtln ("    value of mode.  Acceptable values are <= 7:");
           wrtln ("       0 - Normal File Entry");
           wrtln ("       1 - File is Read Only");
           wrtln ("       2 - File is Hidden from directory Search");
           wrtln ("       4 - File is System File");
    	   wrtln ("       3, 5, 6, 7 - are combinations of the above value");
           wrtln ("CLS");
           wrtln ("    Clears the screen.");
           wrtln ("COPY source_file [destination_file]");
           wrtln ("    Copies source to destination.");
	   wrtln ("DATE [mm/dd/yy]");
	   wrtln ("    Sets or displays the date that you enter into the system");
	   wrtln ("DIFF [-b] filespec1 filespec2");
	   wrtln ("    Compares two files character by character.");
	   wrtln ("    -b - ingnores spaces in the files and compares text only");
    	   if(stand_out){
           	wrtln (""); cr2cont();
    	   }
           wrtln ("DIR or LS [filenm.ext] [-f] [-d] [-t] [-w]");
           wrtln ("    -f - anything but directories.");
           wrtln ("    -d - directories only.");
           wrtln ("    -t - terse: names only.");
           wrtln ("    -w - wide: names only displayed horizontally.");
	   wrtln ("ERA [d:][path]filespec");
	   wrtln ("    Removes one or more files from a disk directory");
           wrtln ("ERR ");
           wrtln ("    Displays the value of the Completion Code for the last command.");
           wrtln ("EXIT");
           wrtln ("    Exits CLI to invoking program.");
	   wrtln ("FIND \"string\"filename1 [filename2...filenamelast]");
	   wrtln ("    Search for the occurrence of a character string in one or more files");
	   wrtln ("FORMAT d:");
	   wrtln ("    Prepares a disk to recieve data before it can be used");
           wrtln ("INIT [drive_spec:]");
           wrtln ("    Reinitializes FAT entries, erases data from a disk.");
           wrtln ("MD [subdirectory name]");
           wrtln ("    Creates a new subdirectory in current directory.");
           wrtln ("MOVE source_file [destination_file]");
           wrtln ("    Copies source to destination and deletes source.");
           wrtln ("PAUSE");
           wrtln ("    Writes 'CR to continue...' to standard output");
    	   if(stand_out){
           	wrtln (""); cr2cont();
    	   }
           wrtln ("    and waits for a carriage return from standard input.");
           wrtln ("PRGERR [ON | OFF]");
           wrtln ("    Turns command processing abort feature ON/OFF.");
           wrtln ("    If PRGERR is ON and a .PRG file returns a non zero completion");
           wrtln ("    code, all further processing will stop.  Usefull in .BAT files.");
           wrtln ("    Default is ON.");
           wrtln ("NOWRAP");
           wrtln ("    Disables line wrap.");
           wrtln ("PATH [;[pathnm]...]");
           wrtln ("    With path name sets default path for batch and commands.");
           wrtln ("    Without path name displays current path");
           wrtln ("REM or ECHO [\"string\"]");
           wrtln ("    Strips quotes and writes string to standard output.");
           wrtln ("    /r is replaced by 0x13, /n by 0x10, /0 by 0x0.");
           wrtln ("    /c by 0x13 0x10, /anything is replaced by anything.");
           wrtln ("REN source_file_nm [destination_file_nm]");
           wrtln ("    Renames source to destination.");
           wrtln ("RD [pathnm]");
           wrtln ("    Removes named directory.");
           wrtln ("RM or DEL or ERA filenm [[filemn]...]");
           wrtln ("    Removes named file from directory.");
           wrtln ("SHOW [drive_spec:]");
           wrtln ("    Displays disk status for default drive or drive specified.");
           if(stand_out){
           	wrtln (""); cr2cont();
    	   }
           wrtln ("STAY");
           wrtln ("    Optionally stays in cli instead of exiting when");
           wrtln ("    cli is invoked with parameters.");
	   wrtln ("TIME [hh:mm:ss]");
	   wrtln ("    Sets or displays the time that you enter into the system");
	   wrtln ("TREE [d:]");
	   wrtln("    Displays all the directory paths on a given disk drive");
	   wrtln ("TYPE [d:][path]filename.ext");
	   wrtln ("    Displays the contents of a file on your screen");
           wrtln ("VERSION");
           wrtln ("    Displays current version of OS.");
           wrtln ("WRAP");
           wrtln ("    Enables line wrap.");
           wrtln (">filenm, >>filenm, <filenm");
           wrtln ("    Provides for ouput, concatenation, and input redirection.");
           wrtln ("cmd @filenm");
           wrtln ("    Allows a list of command tails to be put in a file and fed to a command.");
    	   wrt("\r\n");	/*for prn, otherwise, the previous line won't print*/
           break;
   case 18:
    	   wrtln("Invalid drive/path/file name specified "); break;
   }
}
/***************************************************************************/
/*
getYes 
*/
/***************************************************************************/
int getYes ()

{
char inpStr [30];

inpStr[0] = xrdchne();
inpStr[1] = 0;
ucase (&inpStr[0]);
if (inpStr[0] == 'Y') return -1;
return 0;
}

/***************************************************************************/
/* 
   int copyCmd()

   copyCmd - copy file.
     
   returns 0 if copyied ok
          -1 if copy failed
*/
/***************************************************************************/	
int copyCmd(src, dst, move)			

char *src, *dst;			
int move;

{
register int	i, j, srcEqDst, fds, fdd;
long	nr, nw;		
char    srcSpc[140], dstSpc[140], mod;
int	buff[2], nofile;		

for (i=0; srcSpc[i] = src[i]; i++);
for (i=0; dstSpc[i] = dst[i]; i++);

WSrcReq = &srcSpc;				
WAttCode = -1;				
nofile = TRUE;
compl_code = 0xFFFFFFFF;

/*If not a valid file name...*/
switch (chkDir (&srcSpc, srcDir, srcNmPat, 1)) 
   {
   case -2: goto error6;
   case -4: goto error7;
   default:
      {
      /* Check destination directory.*/
      if(chkDir(&dstSpc, dstDir, dstNmPat, 0) == -4) goto error7;
      if (chkDst()) dspMsg(2);
      else
            {
            while (gtFlNm())
               {
               if (!(srchb[21] & 0x18))
                  {
    		  nofile = FALSE;
                  mkSrc();
                  if (!(srcEqDst = mkDst()))
                     {
                     xunlink (dstFlNm);
                     dspMsg (12); dspMsg(7); dspMsg(10); dspMsg(8); 
                     if ((fds = xopen (srcFlNm, 0)) <= 0) goto error0;
                     if ((fdd = xcreat (dstFlNm, 0x20)) <= 0) goto error1;
                     compl_code = 0;
                     nr = nw = -1;
                     while ((nr) && (nw))
                        {
                        if ((nr = xread (fds, (long)BUFSIZ, buf)) > 0)
                           {
                           if ((nw = xwrite (fdd, nr, buf)) < nr)
                              goto error4;
                           }
                        else if (nr < 0)
                           {
                           goto error3;
                           }
                        }
    		     xdatime(buff, fds, 0);/*get the time stamp from source*/
    		     xdatime(buff, fdd, 1);/*set the time stamp for destination*/
		     mod = (char) xattrib(srcFlNm, 0, mod);
		     xattrib(dstFlNm, 1, mod);
                     xclose (fds);
                     if (move) 
                        {
                        xunlink (srcFlNm);
                        wrt (" DELETING "); dspMsg(7);
                        }
                     xclose (fdd);
                     }
                  else 
                     {
                     goto error2;
                     }
                  }
               }
            if(nofile) dspMsg (1); 
    	    else {dspMsg (12); dspMsg(5);}
            }
      }
   }
return (0);

error0: dspMsg (1); return (-1);
error1: wrtln ("Error creating file."); return (-1);
error2: wrtln ("Cannot copy "); dspMsg(7); wrt(" to itself."); return (-1);
error3: wrtln ("Error reading source file."); goto eout;
error4: wrtln ("Write error -- copy failed."); goto eout;
error6: dspMsg (1); return (-1);
error7: dspMsg (18); return(-1);
eout:
xunlink (dstFlNm);
wrt (" DELETING "); wrt (dstFlNm);
return -1;
}
/***************************************************************************/
/* 
   int renmCmd

   renmCmd - rename command

*/
/***************************************************************************/	
renmCmd(src, dst)			

char *src, *dst;			

{
register int	i, j, fds, fdd, code;
long	nl;		
char    srcSpc[140];		
char    dstSpc[140];		

for (i=0; srcSpc[i] = src[i]; i++);
for (i=0; dstSpc[i] = dst[i]; i++);

WSrcReq = &srcSpc;				
WAttCode = -1;				

/* Set up completion code to show failure */
compl_code = 0xFFFFFFFF;

/* IF src not specified err out. */
if (!(*src)) dspMsg (6);

/*If not a valid file name...*/
else switch (i = chkDir (&srcSpc, srcDir, srcNmPat, 1)) 
   {
   case -4: dspMsg (18); break;
   case -3: dspMsg (0); break; 
   case -2: dspMsg (1); break;
   default:
      {
      /* Check destination directory.*/
      if ((code = chkDir (&dstSpc, dstDir, dstNmPat, 0)) == -3) 
         {
         if (i == 1) 
            {
            wrt ("Rename ALL files matching ");
            wrt (srcDir);
            wrt (srcNmPat);
            wrt (" (Y/CR)? ");
            if (!getYes())
               goto skprnm; 
            wrtln ("");
            }
         }
      else if(code == -4){
    	 dspMsg(18); break;
         }
      else
         {
         if (chkDst()) 
            {
            dspMsg(2);
            }   
         else
            {
            while (gtFlNm())
               {
               if (!(srchb[21] & 0x18))
                  {
                  mkSrc();
                  if (!mkDst());
                     {
                     dspMsg (12); dspMsg(7); dspMsg(10); dspMsg(8);
                     compl_code = xrename (0, srcFlNm, dstFlNm);
                     if (compl_code < 0) 
                        {
                        wrt ("  Rename Unsucessfull!");
                        }
                     }
                  }
               }
            dspMsg(12); dspMsg(5);
            }
         }
      }
   }

skprnm:

}
/***************************************************************************/	
/***************************************************************************/	
long dirCmd (argv)
char * argv[];

{
char    srcSpc[140];		
register int     i, j, k, n, att;
int *dt, filOnly, dirOnly, terse, wide, hidSys, tf;
long    compl_code, *pl, ts;

wide = filOnly = dirOnly = terse = tf = ts = hidSys = 0;              
i = 1;
while (*argv[i])
   {
   ucase (argv[i]);
   if (*argv[i] == '-')
      {
      switch (*(argv[i] + 1))
         {
         case 'F' : filOnly = -1; dirOnly = 0; break;
         case 'D' : dirOnly = -1; filOnly = 0; break;
         case 'W' : wide    = -1; 
         case 'T' : terse   = -1; break;
    	 case 'H' : hidSys  = -1; break;/*switch show the hidden, system files*/
         default  : break;
         }
      j = i;
      while (*(argv[j] = argv[j+1])) j++;
      }
   else i++;
   }

WAttCode = -1;
for (i=0; srcSpc[i] = argv[1][i]; i++);
if(chkDir (&srcSpc, srcDir, srcNmPat, 0) == -4) {
    dspMsg(18);
    return(compl_code = 0xFFFFFFFF);
    }
if (!terse) 
   {
   wrt("Directory of ");
   wrt(srcDir);
   dspMsg (12);
   }

WSrcReq = &srcSpc;
if (! gtFlNm())
   {      
   compl_code = 0xFFFFFFFF;
   if (!terse) dspMsg (1);
   }
else 
   {
   compl_code = 0;
   k = 0;
   do
      {
      n = strlen(&srchb[30]);
      if ((dirOnly) && (srchb[21] != 0x10)) goto skip;
      if ((filOnly) && (srchb[21] == 0x10)) goto skip;
      if ((!hidSys) && (srchb[21] & 0x06)) goto skip;
      if ((terse) &&
         ((xncmps (2, &srchb[30], ".")) || (xncmps (3, &srchb[30], ".."))))
         goto skip;

      if (wide)
         {
         wrt (&srchb[30]);
         if (k == 5) 
            {
            wrtln ("");
            k = 0;
            }
         else
            {
            for (i=n; i<13; i++)
               wrt (" ");
            k++;
            }
         }
      else 
         {
         wrtln (&srchb[30]);
         tf++;
         }
      if (!terse)
         {
         for (i=n; i<15; i++)
            xwrite(1,1L," ");
   
         dt = &srchb[24];
         j = *dt;
         prtDclFmt ((long)((j>>5) & 0xF ), 2, "0");
         wrt("/");
         prtDclFmt ((long)(j & 0x1F), 2, "0");
         wrt("/");
         prtDclFmt ((long)(((j>>9) & 0x7F) + 80), 2, "0");
         wrt ("  ");
   
         dt = &srchb[22];
         j = *dt;
         prtDclFmt ((long) ((j>>11) & 0x1F), 2, "0");
         wrt (":");
         prtDclFmt ((long) ((j>>5) & 0x3F), 2, "0");
         wrt (":");
         prtDclFmt ((long) ((j & 0x1F) << 1), 2, "0");
         wrt ("  ");
   
         att = srchb[21];
         if (att < 0x10) wrt ("0");
         prthex(att);
         xwrite(1,2L,"  ");
   
         pl = (long *) &srchb[26];
         ts += *pl;
         prtDclFmt((long)*pl, 6, " ");
         }
      skip:
      }
   while (gtFlNm());         
   wrtln ("");
   if (!terse) 
      {
      wrt ("       "); prtDclFmt((long)tf, 3, " ");
      wrt (" files using "); prtDclFmt(ts, 7, " "); wrt (" bytes of disk.");
      wrtln ("");
      }
   }
return (compl_code);
}
/***************************************************************************/	
/***************************************************************************/	
long chmodCmd (argv)
char * argv[];

{
char    srcSpc[140];		
register int     i, att, mode;
register long    compl_code;

if(!*argv[2]){
	wrt("Mode specification needed for CHMOD command.");
	compl_code = 0xFFFFFFFF;
	}
else{
	mode = mknum (argv[2]);
	if (mode & ~0x7) 
	     {
	     wrt ("Invalid mode specification.");
	     compl_code = 0xFFFFFFFF;
	     }
    	else {
	    for (i=0; srcSpc[i] = argv[1][i]; i++);

	    if(chkDir (&srcSpc, srcDir, srcNmPat, 0) == -4){
    		dspMsg(18);
    		return(compl_code = 0xFFFFFFFF);
    	    }
	    WSrcReq = &srcSpc;        
	    WAttCode = -1;            
	    if (! gtFlNm())
	       {      
	       compl_code = 0xFFFFFFFF;
	       dspMsg (1);
	       }
	    else 
	       {
    		do {
    		   mkSrc();
		   att = srchb[21];
	   	   if (att & 0x18)
	      		{
	      		wrt ("Unable to change mode on subdirectorys or volumes.");
	      		compl_code = 0xFFFFFFFF;
	      		}
	   	   else
	               compl_code = xattrib (srcFlNm, 1, mode);
	         }   while (gtFlNm());
	      }
	   if (compl_code >= 0) 
	      dspMsg(5);
	   }
    }
return (compl_code);
}
/***************************************************************************/	
/***************************************************************************/	
long typeCmd (argv)
char * argv[];

{
char    srcSpc[140];		
register int     i, j, n, fd;
long    compl_code;
char    *p;
int	count, bytes;

if (!(*argv[1])) dspMsg (6);
else
   {
   j = 1;
   while (*argv[j])
      {
      for (i=0; srcSpc[i] = argv[j][i]; i++);
      j++;
      if(chkDir (&srcSpc, srcDir, srcNmPat, 0) == -4){
    	  dspMsg(18);
    	  return(compl_code = 0xFFFFFFFF);
    	  }
      p = srcNmPat;
      while (*p){
    	 if(*p++ == '*'){
    	    dspMsg(0);
    	    return(compl_code = 0xFFFFFFFF);
    	 }
      }
      WSrcReq = &srcSpc;
      WAttCode = -1;            
      if (!gtFlNm())     
         {
         dspMsg (1);
         compl_code = 0xFFFFFFFF;
         }
      else 
         {
         compl_code = 0;
         do
            {
    	    if(srchb[21] & 0x10) {
    		dspMsg(0);
    		return(compl_code = 0xFFFFFFFF);
    	    }
            mkSrc();
            if((fd = xopen(srcFlNm, 0)) <= 0) goto error; 
            do
               {
               n = xread(fd,1000L,buf);
               if (n > 0) {
		bytes = n;
                count = xwrite(1,(long) n,buf);
		if (count != bytes) 
		   wrerr();
		}
               }
            while (n > 0);
            }                  
         while (gtFlNm());         
         xclose(fd);
         }
      }
   }               
return (compl_code);
error: wrtln ("Cannot open file "); wrt(srcFlNm); return(compl_code = -1L);
}
/***************************************************************************/	
/***************************************************************************/	
long delCmd (argv)
char * argv[];

{
char    srcSpc[140];		
register int     i, j, k, file_del;
long    compl_code;

file_del = FALSE;
i = 1;
/*  no documentation memtions about this query, a file with name "-" can't be
    erased, so we take this out.*/
/*
while (*argv[i])
   {
   ucase (argv[i]);
   if (*argv[i] == '-')
      {
      switch (*(argv[i] + 1))
         {
         case 'Q' : query = -1; break;
         default  : break;
         }
      j = i;
      while (*(argv[j] = argv[j+1])) j++;
      }
   else i++;
   }
*/
if (*argv[1])
   {
   k = 1;
   while (*argv[k])
      {
      for (i=0; srcSpc[i] = argv[k][i]; i++);
      k++;
      WSrcReq = &srcSpc;
      WAttCode = -1;     
      if (((i = chkDir (&srcSpc, srcDir, srcNmPat, 0)) == -3) || (i == 1)) 
         {
         wrt ("Delete ALL files matching ");
         wrt (srcDir);
         wrt (srcNmPat);
         wrt (" (Y/CR)? ");
         if (!getYes())
            goto noera; 
         wrtln ("");
         }
      else if (i == -4){
	 dspMsg(18);
    	 return(compl_code = 0xFFFFFFFF);
    	 }
      if (!gtFlNm())
         {
    	 compl_code = 0xFFFFFFFF;
         dspMsg (1);
         wrtln("");
         }
      else 
         {
         do
            {
            if (!(srchb[21] & 0x18))
               {
               mkSrc();
               dspMsg(7); 
    	       if (srchb[21] & 0x01){
    		    wrt(" IS READ-ONLY FILE, NOT DELETED");
    		    compl_code = 0xFFFFFFDC;
    		    goto skipdel;
    		  }
/*             else if (query)
                  {
                  wrt ("? "); 
                  i = getYes();
                  wrt ("\b\b ");
                  if (i)
                     wrt (" << DELETED");
                  else 
                     goto skipdel;
                 }
*/
               compl_code = xunlink (srcFlNm); 
    	       file_del = TRUE;
skipdel:
               dspMsg(12);
               }
            }
         while (gtFlNm());      
         }
      }
   if(file_del) dspMsg(5);
   else wrtln("No file deleted.");
   }
else dspMsg(6);

noera:
return (compl_code);
}
/***************************************************************************/	
/*
   dspCL - display command line
*/
/***************************************************************************/	
dspCL ()
   {
   char *p;

   dspMsg(14);
   wrt (&lin[0]);
   wrtln("");
   }

/***************************************************************************/	
/*
   preCmd - Do pre command processing
*/
/***************************************************************************/	
preCmd (nonStdIn, rd, newsi, newso)
long   nonStdIn;
struct rdb  * rd;
long   newsi;
long   newso;

{
if(nonStdIn) dspCL();
if (rd->nso == -1)
   {
   xforce(1, (int)newso);
   xclose((int)newso);
   }
if (rd->nsi == -1)
   {
   xforce(0,(int)newsi);
   xclose((int)newsi);
   }
}

/***************************************************************************/	
/*
   setPath - set execution path
*/
/***************************************************************************/	
long setPath (p)
char * p;
{
   char buf[130],c;
   register int	i;
   register char *q, *s;

   compl_code = 0;
   if (!*p) wrt (&path);
   else if (xncmps (2, p, ";"))
    	 path[0] = 0;
   else {
      s = p;
      while(*s){
    	  q = buf;
    	  while(*s != ';' && *s != '\0')
    		*q++ = *s++;
    	  *q = '\0';
    	  if(*s == ';') s++;
    	  q = buf + 3;
    	  if(*q-- == 0 && *q-- == '\\' && *q-- == ':' ){
    		i = xgetdrv();
    		c = *q;
    		if (c >= 'a' && c <= 'z') c -= 'a';
    		else if (c >= 'A' && c <= 'Z') c -= 'A';
    		else  c = 60;  /*just set it illegal*/
    		if(c < 0 || c > 15 || xsetdrv((int) c) < 0){
    			xsetdrv(i);
    			return(compl_code = -1L);
    		}
    		xsetdrv(i);	/*restore the old drive*/
    	  }
    	  else {
    		q=buf;		/*scan buf to see any * or ? embeded*/
    		while(*q && *q != '*' && *q != '?') q++;
    		if(*q || xsfirst(buf, 0x010) < 0)
    		    return(compl_code = -1L);
    	  }
      }
      q = path; s = p;
      while (*q++ = *s++);
   }
   return(compl_code);
}
/***************************************************************************/	
/*
execPrgm - execute program;
*/
/***************************************************************************/
long execPrgm (s, cmdtl)

char *s, *cmdtl;

{
char cmd[130], ch, * cmdptr;
register int k, i, j, gtpath, envLen;
int tlNtFnd = -1;
long err;
register char * envPtr;

/* Loop thru environment strings looking for '00.  Don't count
 * any PATH=... definitions in the environment because the user
 * may have redefined the PATH, which is now in path[].
 * The last string in the environment is followed by second NULL.
 */

envLen = 1;				/* one byte for last NULL	*/
envPtr = prntEnvPtr;
while (*envPtr)				/* while not at last NULL	*/
{
    i = strlen(envPtr) + 1;		/* get length + 1 for NULL	*/
    if (! xncmps (5, envPtr, pthSymb))	/* if not PATH=...		*/
	envLen += i;			/* add length of this string	*/
    envPtr += i;			/* move to next string		*/
}

/* Add len of path definition */

if (i = strlen(path))			/* is a new path defined?	*/
    envLen += strlen(pthSymb) + i + 1;	/* space for PATH=... and NULL	*/


/* Allocate envLen number of bytes for enviornment strings.*/
envPtr = xmalloc((long)envLen);

/* copy path string into env.*/
i = 0;
if (path[0]) 
   {
   for (i = 0; pthSymb[i]; i++) envPtr[i] = pthSymb[i];
   j = 0;
   while (envPtr [i] = path[j++]) i++;
   envPtr [i++] = 0;
   }

/* Copy parents enviornmet string into childs.*/
envLen = 0;
while ((envPtr [i] = prntEnvPtr [envLen]) | prntEnvPtr [envLen + 1])
   {
   /* if a path has been defined, don't copy it.*/
   if (xncmps (5, &prntEnvPtr [envLen], pthSymb))
      envLen += (1 + strlen (&prntEnvPtr [envLen])); 
   else
      {
      i++;
      envLen++;
      }
   }
/* inc index past 0.*/
i++;

/* Null termintate.*/
envPtr [i] = 0;

for (i = 0; (cmd[i] = *s) && (i < 130); s++, i++) 
   if (*s == '.') tlNtFnd = 0;

if (tlNtFnd)
   for (j = 0; (cmd[i] = prgTail[j]) && (i < 130); i++, j++);

i = 0;
gtpath = -1;
while ((ch = cmd[i++]) && (i <=130))
	 if ((ch == ':') || (ch == '\\')) gtpath = 0;

exeflg = 1;

super();
rm_term();
user();

cmdptr = &cmd;
j = 0;
while ((((err = xexec(0, cmdptr, cmdtl, envPtr)) & 0xFFFFFFFF) == -33) && (gtpath))
   {
   k = j;
   if (path [j])
      {
      while ((path[j]) && (path[j] != ';')) j++;
      for (i = 0; k < j; k++, i++) buf[i] = path[k];
      if (buf[i - 1] != '\\') buf[i++] = '\\';
      k = 0;
      while (cmd[k]) buf[i++] = cmd[k++];
      buf[i] = 0;
      cmdptr = &buf[0];
      if (!(path[j])) 
         gtpath = 0;
      else
         j++;
      }
   else gtpath = 0;
   }
super();
in_term();
user();

exeflg = 0;
xmfree(envPtr);

return (err);
}
/**************************************************************************/	
/*
   execBat - execute batch file
*/
/***************************************************************************/
int execBat (s, parms)

char *s, *parms[];


{
long flHnd;
int i;
register int j, k;
int oldsi, gtpath;
int tlNtFnd = -1;
register char ch;
char cmd[130], * cmdptr;

for (i = 0; (cmd[i] = *s) && (i <130); s++, i++) 
   if (*s == '.') tlNtFnd = 0;

if (tlNtFnd)
   for (j = 0; (cmd[i] = batTail[j]) && (i<130) ; i++, j++);

if (xncmps (3, &cmd[ i - 3], "BAT"))
   {
   i = 0;
   gtpath = -1;
   while ((ch = cmd[i++]) && (i<=130))
	 if ((ch == ':') || (ch == '\\')) gtpath = 0;
   
   cmdptr = &cmd;
   j = 0;
   while (((flHnd = xopen(cmdptr, 0)) <= 0) && (gtpath))
      {
      k = j;
      if (path [j])
         {
         while ((path[j]) && (path[j] != ';')) j++;
         for (i = 0; k < j; k++, i++) buf[i] = path[k];
         if (buf[i - 1] != '\\') buf[i++] = '\\';
         k = 0;
         while (cmd[k]) buf[i++] = cmd[k++];
         buf[i] = 0;
         cmdptr = &buf[0];
         if (!(path[j])) 
            gtpath = 0;
         else
            j++;
         }
      else gtpath = 0;
      }

   if (flHnd >= 0)
      {
      i = 0;
      if ((++batlev) > 4) {
    	   wrtln("TOO MANY LEVELS OF BATCH FILES NESTED.");
    	   compl_code = 0xFFFFFFFF;
    	   batlev = 0;
    	   if(prgerr) errout();
    	   return (-1);
      }
      xCmdLn (parms, &i, &flHnd, (char *)0L);
      xclose ((int)flHnd);
      --batlev;
      compl_code = 0;
      return -1;
      }
   }

compl_code = 0XFFFFFFFF;
return 0;
}
/***************************************************************************/	
/***************************************************************************/	
int mknum (str)
register char * str;

{
register int num, hex;
register char ch;

hex = 0;
ucase (str);
if (*str == 'X')
   {
   hex = 1;
   str++;
   }

num = 0;
while (ch = *str++)
   {
   if (hex)
      {
      num *= 16;
      if (ch > 9) num += (ch - 'A' + 10);
      else num += ch - '0';
      }
   else
      {
      num *= 10;
      num += ch - '0';
      }
   }
return num;
}

/***************************************************************************/	
/***************************************************************************/	
int chk_sub (tl, parm)
register char *tl, *parm[];

{
char ch, tmptl [167], * tmptl_ptr, * tmp_front, * tl_front, * parm_ptr;

tmptl_ptr = &tmptl;
tmp_front = tmptl_ptr;
tl_front = tl;

while (ch = *tl++)
   {
   switch (ch)
      {

      case '/':
         if (*tl == '%') 
            {
            *tmptl_ptr++ = ch;
            *tmptl_ptr++ = *tl++;
            }
         else
            *tmptl_ptr++ = ch;
         break;
      case '"':
    	    *tmptl_ptr++ = ch;
    	    while(*tl && (*tmptl_ptr++ = *tl++) != '"');
    	    break;
      case '%':
	 if (*tl > '9' || *tl < '0') return (-1);  
         if (*(parm_ptr = parm [*tl++ - '0']))
            {
            while (*tmptl_ptr = *parm_ptr++) tmptl_ptr++;
            }
         break;

      default:
         *tmptl_ptr++ = ch;
         break;
      }
   }
*tmptl_ptr = 0;

while (*tl_front = *tmp_front++) tl_front++;
return(0);
}
/***************************************************************************/	
/***************************************************************************/	
chk_str (parm)
register char * parm[];

{
register int i;
register char * parm_ptr, * tmp_ptr, ch;

i = 0;
while (*parm[i])
   {
   if (*parm[i] == '"') 
      {
      parm[i]++;
      if (*(parm[i] + strlen (parm[i]) - 1) == '"')
         *(parm[i] + strlen (parm[i]) - 1) = 0;
   
      parm_ptr = parm[i];
      while (ch = *parm_ptr)
         {
         if (ch == '/')
            {
            switch (ch = *(parm_ptr + 1))
               {
               case 'c' : *parm_ptr++ = 13;
                          *parm_ptr = 10;
                          goto skip;
               case 'r' : *parm_ptr = 13; break;
               case 'n' : *parm_ptr = 10; break;
               case '0' : *parm_ptr = 0;  break;
               default  : *parm_ptr = ch; break;
               }
            parm_ptr++;
            tmp_ptr = parm_ptr;
            while (*tmp_ptr = *(tmp_ptr + 1)) tmp_ptr++;
         skip:
            }
           
         else
            {
            parm_ptr++;
            }
         }
      }
   i++;
   }
}

/***************************************************************************/	
/*
   readSi - read standard input
*/
/***************************************************************************/
int readSi (lin)
register char * lin;

{
register int i, j;

dspMsg(13);
for (i = 1; i <= 125; lin[i++] = 0);
i = j = 0;

lin[0] = 126;
xoscall(10, &lin[0]);

lin[lin[1] + 2] = 0;

i = 2;
while (lin[i])
   {
   if ((lin[i] >= ' ') && (lin[i] <= '~')) 
      lin[j++] = lin[i];
   i++;
   }

lin[j] = 0;
lin[j+1] = 0;
return (j);
}
/***************************************************************************/	
/*
   readDsk - read from disk file
*/
/***************************************************************************/
int readDsk (lin, flHnd)

register char * lin;
long * flHnd;

{
register int i, j;
int chrFnd;
char ch;

for (i = 0; i <= 125; lin[i++] = 0);
i = j = 0;

while ((chrFnd = xread ((int)*flHnd, 1L, &ch) > 0) && (ch != '\r'))
   lin[j++] = ch;

j = 0;
i = 0;

while (lin[i])
   {
   if ((lin[i] >= ' ') && (lin[i] <= '~')) 
      lin[j++] = lin[i];
   i++;
   }

lin[j] = 0;

return (j ? j : (chrFnd ? -1 : 0));
}
/***************************************************************************/	
/*
   xCmdLn - execute command line.
*/
/***************************************************************************/
xCmdLn (parm, pipeflg, nonStdIn, outsd_tl)
char * parm[];
int  * pipeflg;
long * nonStdIn;
char * outsd_tl;
{
int pipe, bdChrs;
int rwflg;
int fs,fd,n,n2,nch,fds,fdd;
register int i,j,k,argc;
int f1,f2,nd,rec;
int concat;
long pos,len,err,siz,*pl,nl, newso, newsi;
long sbuf[4];						
long dskFlHnd;
int next;						
char ch, *cmdtl, *d, *s, *argv[MAXARGS];
register char *tl, *tl0, *tl1;
char *p, *lastp, ltail[130];
int	count, bytes;

struct rdb rd;

BPB *b;

rd.nso = 0;
rd.nsi = 0;
rd_ptr = &rd;

/* while there is input from the disk or standard input */
while 
((long)outsd_tl ?1 : (*nonStdIn ? (bdChrs = readDsk (&lin, nonStdIn)) : readSi(&lin)))
   {

   /*Garbage chars in disk file.*/
   if ((bdChrs == -1) && *nonStdIn) goto again;

   exeflg = 0; /* not in an exec */
   wrtln ("");
   d = &ltail[0];
   argv[0] = d;
   argc = 0;
   concat = 0;
   pipe = 0;
   dskFlHnd = 0;

   /*Set up for input redirection.*/
   if (*pipeflg)
      {
      argv[0] = parm[0];
      argv[1] = d;
      argc = 1;
      }

   /* find command tail */
   if ((long)outsd_tl)
      {
      tl = outsd_tl + 1;
      tl[outsd_tl[0]] = 0;
      }
   else tl = &lin[0];

   while (*tl == 0x20) tl++;
   if(chk_sub (tl, &parm[0])) {
	wrt(" Illegal usage of %.");
	goto again;
   }

   /* allow remarks in batch files. */
   if ((*nonStdIn) && *tl == '#') goto again; 
   while (ch = *tl++)

   switch(ch)
      {
      case ' ':
         *d++ = 0;
         while (*tl == 0x20) tl++;
         argv[++argc] = d;
         break;

      case '"':
         *d++ = ch;
         while ((*tl) && ((*d++ = *tl++) != '"'));
         break;

      case '@':
         for (tl0 = tl; ch = *tl; tl++)
            {
            if (ch == 0x20) break;
            }
         *tl++ = 0;
         if(!(*tl0)) 
    	    {
    		wrt("File name not specified after @.");
    		goto redrc;
    	    }
         if ((dskFlHnd = xopen(tl0, 0)) >= 0)
            {
            pipe = -1;
            }
         else
            {
            wrtln (tl0); wrt (" not found.");
    	    goto redrc;
            }
         break;

      case '<':
         for (tl0 = tl; ch = *tl; tl++)
            {
            if (ch == 0x20) break;
            }
         *tl++ = 0;

         if ((newsi = xopen(tl0, 0)) >= 0)
            {
            rd.oldsi = dup(0);
            rd.nsi = -1;
            }
         else
            {
            wrtln (tl0); wrt (" not found.");
    	    goto redrc;
            }
         break;

      case '>':
         for (tl1 = tl; ch = *tl; tl++)
            {
            if (*tl1 == '>') 
               {
	       if(concat)
		  {
		   wrtln(" Illegal output file name : ");
		   wrt(tl1);	/*takes	care the case: >>> was in the command line*/
		   goto redrc;
		  }
	       else
		  {
                   concat = -1;
                   tl1++;
		  }
               }
            if (ch == 0x20) break;
            }
         *tl++ = 0;
    	 if(*tl1 == '@' || *tl1 == '<')
    		{
    		wrtln ("Illegal outputfile name:");
    		wrt(tl1);
    		goto redrc;
    		}
         if (concat)
            {
            if ((newso = xopen(tl1, 1)) < 0)
               {
               if((newso = xcreat(tl1, 0)) < 0) {
		   wrtln (" Error of opening/creating output:");
		   wrt(tl1);
		   goto redrc;
		   }
               }
            }
         else
            {
            xunlink (tl1);
            if((newso = xcreat(tl1, 0)) < 0 ) {
		wrtln (" Error of creating output:");
		wrt(tl1);
		goto redrc;
		}
            }
         rd.oldso = dup(1);
         rd.nso = -1;
         if (concat)
            xf_seek (0L, (int)newso, 2);
         break;
      default: *d++ = ch;
      }

   /* If pipe tack on remaining parms if any.*/
   if (*pipeflg)
      {
      i = 1;
      while (*parm[i])
         {
            argv[++argc] = parm [i++];
         }
      }
         
   *d++ = 0;
   *d = 0;
   i = argc;
   argv[++i] = d;

   s = argv[0];
   p = argv[1];
   ucase(s);

   if (pipe) 
      {
      preCmd (*nonStdIn, &rd, newsi, newso);
      xCmdLn (&argv, &pipe, &dskFlHnd, (char *)0L);
      xclose ((int)dskFlHnd);
      }
   else
      {
      if ((strlen(s) == 2) && (s[1] == ':'))      
         {
         preCmd (*nonStdIn, &rd, newsi, newso);
    	 drv = *s -'A';
    	 if(drv < 0 || drv > 15 || xsetdrv(drv) < 0) {
    		dspMsg(18);
    		wrt(s);
    		goto redrc;
    	 	}
         }
      else if (xncmps(3,s,"LS") || xncmps(4,s,"DIR"))
         {
         preCmd (*nonStdIn, &rd, newsi, newso);
         compl_code = dirCmd (&argv[0]);
         }
      else if (xncmps (6,s,"CHMOD"))
         {
         preCmd (*nonStdIn, &rd, newsi, newso);
         compl_code = chmodCmd (&argv[0]);
         }
      else if (xncmps (4,s,"ERR"))
         {
         preCmd (*nonStdIn, &rd, newsi, newso);
         wrt ("Completion code for previous command = ");
         prthex ((int)compl_code);
         }
      else if (xncmps (5,s,"PATH"))
         {
         preCmd (*nonStdIn, &rd, newsi, newso);
         ucase (p);
         if(setPath (p)){
    		dspMsg(18); wrt(p);
    		goto redrc;
    		}
         }
      else if (xncmps (4,s,"ENV"))
         {
         preCmd (*nonStdIn, &rd, newsi, newso);
         i = 0;
         while ((prntEnvPtr[i] + prntEnvPtr[i + 1]) != 0) 
            {
            /* if a path has been defined, don't count it.*/
            if (!(xncmps (5, &prntEnvPtr[i], pthSymb)))
               {
               wrtln (&prntEnvPtr[i]); 
               } 
            i += strlen (&prntEnvPtr[i]);
            if (prntEnvPtr[i] + prntEnvPtr[i + 1] == 0) break;
            i += 1;
            }
         if (path[0])
            {
            wrtln (pthSymb); wrt (path);
            }
         }

      else if (xncmps(4,s,"CAT") || xncmps(4,s,"TYPE"))   
         {            	
         preCmd (*nonStdIn, &rd, newsi, newso);
         compl_code = typeCmd (&argv[0]);
         }   
      else if ((xncmps(4,s,"REM")) || (xncmps(4, s, "ECHO")))
         {
         preCmd (0L, &rd, newsi, newso); /*don't want to print the command*/
         chk_str (&argv[1]);
         i = 1;
         while (*argv[i]) 
            {
            wrt (argv[i++]);
            wrt (" ");
            }
         dspMsg(12);
         }
 
      else if (xncmps(3,s,"CD"))
         {
         preCmd (*nonStdIn, &rd, newsi, newso);
         if (argc == 0)
            {
            xgetdir(buf,drv+1);      
            if (!buf[0])   
               {           
               buf[0] = '\\';  
               buf[1] = 0;     
               }            
               bytes = strlen(buf);
	       count = xwrite(1,(long) strlen(buf),buf);
	       if (count != bytes) wrerr();
            }
         else 
            {
    	     if(chk_wild(p))
    	        if((compl_code = xchdir(p)) != 0) 
                    wrt ("Directory not found.");
            }
         }
    
      else if (xncmps(7,s,"CMDERR"))
         {
         preCmd (*nonStdIn, &rd, newsi, newso);
         if (argc == 0)
            {
            if (cmderr) wrt ("ON");
            else wrt ("OFF");
            }
         else 
            {
            ucase (p);
            if (xncmps(3,p,"ON")) cmderr = -1;
            else if (xncmps(4,p,"OFF")) cmderr = 0;
            else wrt ("Arg must be ON or OFF.");
            }
         }
    
      else if (xncmps(7,s,"PRGERR"))
         {
         preCmd (*nonStdIn, &rd, newsi, newso);
         if (argc == 0)
            {
            if (prgerr) wrt ("ON");
            else wrt ("OFF");
            }
         else 
            {
            ucase (p);
            if (xncmps(3,p,"ON")) prgerr = -1;
            else if (xncmps(4,p,"OFF")) prgerr = 0;
            else wrt ("Arg must be ON or OFF.");
            }
         }
    
      else if (xncmps(3,s,"MD"))
         {
         preCmd (*nonStdIn, &rd, newsi, newso);
    	 if (chk_wild(p))
    		{
         	if ((compl_code = xmkdir(p)) != 0)
            		wrt ("Unable to make directory");
    	 	else dspMsg(5);
    		}
         }
      else if (xncmps(3,s,"RD"))
         {
         preCmd (*nonStdIn, &rd, newsi, newso);
    	 if (!(*p)) dspMsg(6);
    	 else {
    		if(chk_wild(p)){
	            if((*p == '\\' && *(p+1) == 0) || (*(p+1) == ':' && (*(p+2) == 0 
    		    || (*(p+2) == '\\' && *(p+3) == 0)))){
	             	wrt("Cannot remove root directory\n");
    			compl_code = -1L;
    		    }
         	    else if ((compl_code = xrmdir(p)) != 0)
            	        wrt ("Unable to remove directory");
    	 	    else dspMsg(5);
    		    }
    	     }
         }
      else if (xncmps(3,s,"RM") || xncmps(4,s,"DEL") || xncmps(4,s,"ERA"))
         {               
         preCmd (*nonStdIn, &rd, newsi, newso);
         compl_code = delCmd (&argv[0]);
         }          
    
      else if (xncmps(4,s,"REN"))
         {
    	 if(argc < 2)
    		dspMsg(6);
    	 else {
             preCmd (*nonStdIn, &rd, newsi, newso);
    	     compl_code = renmCmd(argv[1], argv[2]);
    	     }
         }
      else if (xncmps(5,s,"SHOW"))
         {
         preCmd (*nonStdIn, &rd, newsi, newso);
         ucase (p);
    	 if(*p && (*p < 65 || *p > 80 || *(p+1) != ':'))
    	   { dspMsg(18); wrt(p); }
         else if(xgetfree(sbuf, (*p ? *p-64 : 0)) < 0) {
		wrt("Unable to get drive information: ");
		wrt(p);
	 }
	 else{
         	wrt ("Allocation Information: Drive ");
         	if (!*p) dspMsg (16);
         	else wrt (p);
         	dspMsg(12);
         	wrtln ("Drive size in BYTES    ");
            prtDclFmt ((long)(sbuf[1] * sbuf[3] * sbuf[2]), 8, " ");
            wrtln ("BYTES used on drive    ");
            prtDclFmt ((long)((sbuf[1] - sbuf[0]) * sbuf[3] * sbuf[2]), 8, " ");            wrtln ("BYTES left on drive    ");
            prtDclFmt ((long)(sbuf[0] * sbuf[3] * sbuf[2]), 8, " ");
            wrtln ("Total Units on Drive   "); 
            prtDclFmt ((long)sbuf[1], 8, " "); 
            wrtln ("Free Units on Drive    "); 
            prtDclFmt ((long)sbuf[0], 8, " "); 
            wrtln ("Sectors per Unit       "); 
            prtDclFmt ((long)sbuf[3], 8, " "); 
            wrtln ("Bytes per Sector       "); 
            prtDclFmt ((long)sbuf[2], 8, " ");
	    }
         }
    
      else if (xncmps(5,s,"INIT"))
         {
         preCmd (*nonStdIn, &rd, newsi, newso);
         for (i=0; i < BUFSIZ; i++) buf[i] = 0;
         i = xgetdrv();  /*default drive*/
    	 if(!*p)
    	    drv = i;
    	 else{
         	ucase (p);
         	drv = *p - 'A';
    		if(drv < 0 || drv > 15 || xsetdrv(drv) < 0){
    		    dspMsg(18); wrt(p);
    		    xsetdrv(i);		/* restore the default drive */
    		    goto redrc;
    		}
    		xsetdrv(i);
    	 }
         buf[0] = 0xf7; buf[1] = 0xff; buf[2] = 0xff;
         super();           
         b = getbpb(drv);
         if (b->b_flags & 1) buf[3] = 0xFF;
         f1 = b->fatrec - b->fsiz;
         f2 = b->fatrec;
         fs = b->fsiz;
         rwabs(1,buf,fs,f1,drv);
         rwabs(1,buf,fs,f2,drv);
         nd = b->recsiz / 32;
         d = buf;
         for (i = 0; i < nd; i++)
            {
            *d++ = 0;
            for (j = 0; j < 31; j++) *d++ = 0; /*formerly f6*/
            }
         rec = f2 + fs;
         for (i = 0; i < b->rdlen; i++, rec++)
            rwabs(1,buf,1,rec,drv);
         user();
         dspMsg(5);
         }
    
      else if (xncmps(8,s,"PUTBOOT"))  
         {                
         preCmd (*nonStdIn, &rd, newsi, newso);
         ucase (p);
         drv = *p - 'A';  
         fd = xopen(argv[2], 0);
         xread(fd,540L,buf);       
         xclose(fd);         
         super();            
         rwabs(1,&buf[28],1,0,drv);  
         user();           
         dspMsg(5);
         }                 
    
      else if ((xncmps(5,s,"COPY")) || (xncmps(5,s,"MOVE"))) 
         {
         preCmd (*nonStdIn, &rd, newsi, newso);
         if (argc >= 1) 
            compl_code = copyCmd(p, argv[2], xncmps(5,s,"MOVE") ? 1 : 0);
         else dspMsg(6);
         }    
      else if (xncmps(4,s,"GET"))
         {
         preCmd (*nonStdIn, &rd, newsi, newso);
         ucase (p);
         cpmopen(p);
         fd = xcreat(argv[2],0x20);   
    
         do
            {
            n = cpmread(buf);
            if (!n) xwrite(fd,128L,buf);
            } 
         while (!n);
    
         xclose(fd);
         dspMsg(5);
         }
    
      else if (xncmps(6,s,"PAUSE"))
         {
         preCmd (*nonStdIn, &rd, newsi, newso);
         cr2cont();
         }
      else if (xncmps(4,s,"PUT"))
         {
         preCmd (*nonStdIn, &rd, newsi, newso);
         cpmcreat(argv[2]);
         fd = xopen(p, 0);      
    
         do
            {
            n = xread(fd,128L,buf);
            if (n > 0)
            compl_code = cpmwrite(buf);
            } 
         while (n > 0);
    
         cpmclose();
         dspMsg(5);
         }
      else if (xncmps(5,s,"HELP")){
    	 preCmd (*nonStdIn, &rd, newsi, newso);
         dspMsg(17, (rd.nso ? 0 :1));
         }
      else if (xncmps(6,s,"BREAK")) xbrkpt();
      else if (xncmps(5,s,"EXIT"))
         {
exit:
         preCmd (*nonStdIn, &rd, newsi, newso);
         xclose(rd.oldsi);
         xclose(rd.oldso);
         devector();   /* remove vectors */   
         xterm(0);
         }
      else if (xncmps(8,s,"VERSION"))        
         {                  
         preCmd (*nonStdIn, &rd, newsi, newso);
         i = xoscall(0x30);  
         prtdecl((long)(i&0xFF));  
         xwrite(1,1L,".");         
         prtdecl((long)((i>>8)&0xFF));
         }               
      else if (xncmps(5,s,"WRAP"))  
         {
         preCmd (*nonStdIn, &rd, newsi, newso);
         xwrite(1,2L,"\033v");     
         dspMsg(5);
         }
      else if (xncmps(7,s,"NOWRAP"))
         {
         preCmd (*nonStdIn, &rd, newsi, newso);
         xwrite(1,2L,"\033w");     
         dspMsg(5);
         }
      else if (xncmps(4,s,"CLS"))   
         xwrite(1,4L,"\033H\033J");     
      else if (xncmps(5,s,"STAY"))   
         xlongjmp (jb, -2);     
      else 
         {
         preCmd (*nonStdIn, &rd, newsi, newso);
    	 if(chk_wild(s)){
            if (!(execBat (s, &argv)))
            {
    	    /*Build command tail.  So lin won't be modified before the command*/
    	    /* was outputed by preCmd which calls dspCL to actually do it*/
       	    cmdtl = lin;
    	    j = 1;
    	    i = 1;
    	    while (*argv[i]) 
    	      {
    	      k = 0;
    	      while (cmdtl[++j] = *(argv[i] + k++));
    	      cmdtl[j] = ' ';
    	      i++;
    	      }
    	    cmdtl[j] = 0xd;
    	    cmdtl[j + 1] = 0;
    	    cmdtl[0] = --j;
    	    cmdtl[1] = ' ';
 
            if ((compl_code = execPrgm (s, cmdtl)) == -32) errout();
            else if ((compl_code > 0) && prgerr) errout();
            else 
               if ((compl_code & 0xFFFFFFFF) < 0)
                  {
                  wrtln ("Command not found.\r\n"); 
                  if (prgerr) errout();
                  }
            }
    	  }
         }
      }
redrc:
   chk_redirect (&rd);

   again:
   /*if command coming from outside the command int exit*/
   if ((long)outsd_tl) goto exit;
   }
}
/***************************************************************************/	
/***************************************************************************/

cmain(bp)
char * bp;                            /*Base page address                 */
{
char * parm[MAXARGS];
register char * tl;
int    i, k, cmd;
long   j;
int    err;

basePage = bp;
prntEnvPtr = *((char **) (basePage + 0x2C));
tl = basePage + 0x80;
if (tl[0]) cmd = -1;
else cmd = 0;

xsetdta(srchb);
path[0] = 0;
compl_code = 0;
prgerr = -1;
cmderr = 0;
if (!cmd) dspMsg(4);

i = 0;
while ((prntEnvPtr[i] + prntEnvPtr[i + 1]) != 0) 
   {
   /* if a path has been defined, don't count it.*/
   if (xncmps (5, &prntEnvPtr[i], pthSymb))
      {
      if(setPath (&prntEnvPtr[i + 5])){
    	    dspMsg(18); wrt(&prntEnvPtr[i + 5]);
      	    }
      break;
      }
   i++;
   }

if (!cmd) execBat (&autoBat, &parm[0]);

if (xsetjmp(jb))
   {
   if (err == -2) goto stayin;
   for (i = 6; i <= 20; i++) xclose (i);
   if (cmd)
      {
      wrtln ("Stay in COMMAND.PRG (Y/CR)? ");
      if (getYes())
         {
         cmd = 0;
         goto stayin;
         }
      tl[0] = 4;
      tl[1] = 'e'; tl[2] = 'x'; tl[3] = 'i'; tl[4] = 't'; 
      tl[5] = 0xd; tl[6] = 0;
      }
   }      

stayin:
do
   {
   k = 0;
   j = 0;
   batlev = 0;
   xCmdLn (&parm[0], &k, &j, cmd ? tl : (char *)0L);
   }
while (1);
}
