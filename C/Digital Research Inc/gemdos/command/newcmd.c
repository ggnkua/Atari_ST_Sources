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

NAMES

	JSL	Jason S. Loveman
	LGT	Lou T. Garavaglia
	SCC	Steven C. Cavender

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

extern long div10();
extern int mod10();

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

char zero = { '0' } ;
char hexch[] = { '0','1','2','3','4','5','6','7',
		'8','9','A','B','C','D','E','F' } ;

int drv;
int exeflg;
int rtrnFrmBat;
int prgerr;
int cmderr;

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
char     srcFlNm[67];  /*src file name*/
char     dstFlNm[67];  /* destination file name */
char     srcDir[67];   /*src dir path*/
char     dstDir[67];   /*dst dir path */
char     srcNmPat[13]; /*src file name specified in path */
char     dstNmPat[13]; /*dst file name specified in path */
char     path[67];    /*lst of default path names       */

/*Forward declarations.*/
         xCmdLn ();

/**/

xncmps(n,s,d)
int n;
char *s,*d;
{
	while (n--) if (*s++ != *d++) return(0);
	return(1);
}

prthex(h)
unsigned h;
{
	unsigned h2;
	if (h2 = (h >> 4)) prthex(h2);
	else xwrite(1,1L,"0");
	xwrite(1,1L,&hexch[h & 0x0f]);
}

strlen(s)
char *s;
{
	int n;
	for (n=0; *s++; n++);
	return(n);
}

prtdecl(d)
long d;
{
	if (d) pdl(d);
	else
          xwrite(1,1L,"0");
}

pdl(d)long d;
{
	long d2;
	if (d2 = div10(d)) pdl(d2);
	xwrite(1,1L,&hexch[mod10(d)]);
}

prtDclFmt (d, cnt, ch)
long d;
int cnt;
char * ch;

{
int i;
long k, j;

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

ucase(s)
char *s;
{
	for ( ; *s ; s++) if ((*s >= 'a') && (*s <= 'z')) *s &= ~0x20;
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

  int chkDir (pathExp, dirExp, filExp)

  returns -3 if wild cards specified in path name
          -2 if pathExp does NOT specify a file, directory, or device
          -1 if pathExp evaluates to a subdirectory, or a volume label
           0 if pathExp evaluates to a normal, read-only, or system file

  pathExp - ptr to path expression, w/wo wild cards to be evaluated
  dirExp  - ptr to dir part of pathExp
  filExp  - ptr to file.ext part of pathExp
*/
/***************************************************************************/

int chkDir (pathExp, dirExp, filExp)

char *pathExp, dirExp[], filExp[];

{
int pathLen   = strlen (pathExp);
int dirLen;
int wildLen   = strlen (wildExp);
int wildFnd   = FALSE;
int i         = 0;
int flExsists;
char c;

/*directory length = path length to start with.*/
dirLen = pathLen;

/* Loop thru path expresion from end looking for delimeters and the 1st char.*/
do
   {
   if ((c = pathExp[dirLen]) == '*') wildFnd = TRUE;
   }
while ((c != ':') && (c != '\\') && (dirLen--));
dirLen++;

/* IF nothing specified defalult to wild expresion.*/
if ((pathLen == 0) || 
    (pathExp[pathLen - 1] == '\\') || 
    (pathExp[pathLen - 1] == ':')) 
   {
   while (pathExp[pathLen] = wildExp[i])
      {
      pathLen++;
      i++;
      } 
   wildFnd = TRUE;
   }

/* return file not found if not found.*/
flExsists = xsfirst (pathExp, WAttCode) ? -2 : 0;

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
   if ((dirExp[pathLen] = pathExp[pathLen]) == '*') return -3;

/* chop off file nm from dirExp.*/
dirExp [dirLen] = '\0';

/* copy file name into return var.*/
i = 0;
while (filExp[i++] = pathExp[pathLen++]);

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
int i, k, ndx;
int srcEqDst;

i = ndx = 0;

/* determine If dst dir path = src dir path.*/
while ((srcEqDst = (srcDir[i] == dstDir[i])) && srcDir[i] 
   && (dstFlNm [i] = dstDir[i])) i++; 

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

/* if the entire name matches create a dst file name with '.&&&' as ext*/
if (srcEqDst)
   {
   i = 0;
   while (dstFlNm[ndx] = dstDir[ndx]) ndx++;

   while ((dstFlNm[ndx + i] = srchb[30 + i]) 
      && (dstFlNm[ndx + i] != '.')) i++;
   i++;

   for (k = 0; k <= 2; dstFlNm[i + (k++)] = '&');
   }

/* else file names do not match.*/
else
   {
   i = 0;
   ndx = 0;

   /* copy dst dir path into dst file name.*/
   while (dstFlNm[ndx] = dstDir[ndx]) ndx++;
   
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
int i,j = 0;

/* copy src directroy into src directory file name.*/
for (i=0; (srcFlNm[i] = srcDir[i]); i++);

/* copy source file name from search first/next into src file name.*/
while (srcFlNm[i + j] = srchb[30 + j]) j++;
}
/***************************************************************************/
/*
   wrt - write to standard output
*/
/***************************************************************************/
wrt (msg)
char * msg;

{
xwrite (1, (long)strlen(msg), msg);
}

wrtln (msg)
char *msg;

{
wrt ("\r\n");
wrt (msg);
}
/***************************************************************************/
/*
   dspDir - display directory
*/
/***************************************************************************/
dspDir (p, dir)
char *p, *dir;

{
int i, j;
char ch, tmpbuf[100];

if ((*p) && (p[1] == ':'))
   {
   ch = *p;
   i = p[0] - 'A';
   j = 2;
   }
else
   {
   ch = (i = xgetdrv()) + 'A';
   j = 0;
   }
xwrite (1, 1L, &ch);
wrt (":");
if (!dir[j])
   {
   xgetdir (&tmpbuf, i+1);
   if (tmpbuf[0] == 0)
      {
      tmpbuf[0] = '\\';
      tmpbuf[1] = 0;
      }
   wrt (tmpbuf);
   }
else
   wrt (dir + j);
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
dspMsg (msg)
int msg;
{
switch (msg)
   {
   case 0: wrtln ("Wild cards not allowed in path name."); break;
   case 1: wrtln ("File Not Found."); break;
   case 2: wrtln ("Destination is not a valid wild card expresion."); break;
   case 3: wrtln ("******* TEST  CLI *******"); break;
   case 4: wrtln ("Command v0.39 8/19/85 LTG");break;
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
           wrtln ("CAT or TYPE filenm.ext");
           wrtln ("    Writes filenm.ext to standard output.");
           wrtln ("CD [pathnm]");
           wrtln ("    With pathnm it sets default for working directory.");
           wrtln ("    Without pathnm displays current working directory.");
           wrtln ("CHMOD [pathnm/]filenm mode");
           wrtln ("    Changes the mode of the file specified in filenm to the"); 
           wrtln ("    value of mode.  Acceptable values are < 7:");
           wrtln ("       0 - Normal File Entry");
           wrtln ("       1 - File is Read Only");
           wrtln ("       2 - File is Hidden from directory Search");
           wrtln ("       4 - File is System File");
           wrtln ("CLS");
           wrtln ("    Clears the screen.");
           wrtln ("COPY source_file [destination_file]");
           wrtln ("    Copies source to destination.");
           wrtln ("DIR or LS [filenm.ext] [/f] [/d] [/t]");
           wrtln ("    -f - anything but directoryies.");
           wrtln ("    -d - directories only.");
           wrtln ("    -t - terse: names only.");
           wrtln ("ERR ");
           wrtln ("    Displays the value of the Completion Code for the last command.");
           wrtln ("EXIT");
           wrtln ("    Exits CLI to invoking program.");
           wrtln (""); cr2cont();
           wrtln ("INIT [drive_spec:]");
           wrtln ("    Reinitializes FAT entries this wiping disk.");
           wrtln ("MD [subdirectory name]");
           wrtln ("    Creates a new subdirectory in current directory.");
           wrtln ("MOVE source_file [destination_file]");
           wrtln ("    Copies source to destination and deletes source.");
           wrtln ("PAUSE");
           wrtln ("    Writes 'CR to continue...' to standard output");
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
           wrtln (""); cr2cont();
           wrtln ("REM or ECHO [\"string\"]");
           wrtln ("    Strips quotes and writes string to standard output.");
           wrtln ("    /r is replaced by 0x13, /n by 0x10, /0 by 0x0.");
           wrtln ("    /c by 0x13 0x10, /anything is replaced by anything.");
           wrtln ("REN source_file_nm [destination_file_nm]");
           wrtln ("    Renames source to destination.");
           wrtln ("RD [pathnm]");
           wrtln ("    Removes named directory.");
           wrtln ("RM or DEL or ERA filenm [-q]");
           wrtln ("    Removes named file from directory.");
           wrtln ("    IF the -q option is used, the CLI will display the question");
           wrtln ("    Y/CR... and wait for a responce.");
           wrtln ("SHOW [drive_spec:]");
           wrtln ("    Displays disk status for default drive or drive specified.");
           wrtln ("VERSION");
           wrtln ("    Displays current version of OS.");
           wrtln ("WRAP");
           wrtln ("    Enbles line wrap.");
           break;
   }
}
/***************************************************************************/
/* 
   int copyCmd()

   copyCmd - copy file.
     
   returns 0 if copyied ok
          -1 if no more room on disk
          -2 if copy source to itself
          -3 if file not found.
*/
/***************************************************************************/	
int copyCmd(src, dst, move)			

char *src, *dst;			
int move;

{
int	i, j, srcEqDst, fds, fdd;
long	nr, nw;		
char    newFl[67];		

WSrcReq = src;				
WAttCode = -1;				

compl_code = 0xFFFFFFFF;

/*If not a valid file name...*/
switch (chkDir (src, srcDir, srcNmPat)) 
   {
   case -3: dspMsg (0); break; 
   case -2: dspMsg (1); break;
   default:
      {
      /* Check destination directory.*/
      if (chkDir (dst, dstDir, dstNmPat) == -3) dspMsg (0);

      else
         {
         if (chkDst()) dspMsg(2);
            
         else
            {
            while (gtFlNm())
               {
               if (!(srchb[21] & 0x18))
                  {
                  mkSrc();
                  if (!(srcEqDst = mkDst()))
                     {
                     xunlink (dstFlNm);
                     dspMsg (12); dspMsg(7); dspMsg(10); dspMsg(8); 
                     if ((fds = xopen (srcFlNm, 0)) <= 0) goto error;
                     if ((fdd = xcreat (dstFlNm, 0x20)) <= 0) goto error1;
                     compl_code = 0;
                     nr = nw = -1;
                     while ((nr) && (nw))
                        {
                        if ((nr = xread (fds, (long)BUFSIZ, buf)) > 0)
                           {
                           if ((nw = xwrite (fdd, nr, buf)) < nr)
                              return (-1);
                           }
                        }
                     xclose (fds);
                     if (move) 
                        {
                        xunlink (srcFlNm);
                        wrt (" deleting "); dspMsg(7);
                        }
                     xclose (fdd);
                     }
                  else 
                     {
                     wrtln ("Cannot copy ");
                     dspMsg(7);
                     wrt(" to itself.");
                     return (-2);
                     }
                  }
               }
            dspMsg (12); dspMsg(5);
            }
         }
      }
   }
return (0);

error:
dspMsg (1);
return (-3);

error1:
wrtln ("Error creating file.");
xlongjmp (jb, -1);
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
int	i, j, fds, fdd;
long	nl;		
char    newFl[67];		

WSrcReq = src;				
WAttCode = -1;				

/* Set up completion code to show failure */
compl_code = 0xFFFFFFFF;

/* IF src not specified err out. */
if (!(*src)) dspMsg (6);

/*If not a valid file name...*/
else switch (chkDir (src, srcDir, srcNmPat)) 
   {
   case -3: dspMsg (0); break; 
   case -2: dspMsg (1); break;
   default:
      {
      /* Check destination directory.*/
      if (chkDir (dst, dstDir, dstNmPat) == -3) 
         {
         dspMsg (15);
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
                  if (!mkDst());
                     {
                     mkSrc();
         
                     dspMsg(7); dspMsg(10); dspMsg(8);
                     compl_code = xrename (0, srcFlNm, dstFlNm);
                     }
                  }
               }
            dspMsg(12); dspMsg(5);
            }
         }
      }
   }
}
/***************************************************************************/	
/*
   dspCL - display command line
*/
/***************************************************************************/	
dspCL (argv)
char * argv[];
   {
   int i;
   dspMsg(14);
   i = 0;
   while (*argv[i]) 
      {
      wrt (argv[i++]);
      wrt (" ");
      }
   dspMsg(12);
   }

/***************************************************************************/	
/*
   setPath - set execution path
*/
/***************************************************************************/	
setPath (p)
char * p;
   {
   int i = 0;

   if (!*p) wrt (&path);
   else 
      if (xncmps (2, p, ";")) path[i] = 0;
   else 
      while (path[i] = p[i++]);
   }

/***************************************************************************/	
/*
execPrgm - execute program;
*/
/***************************************************************************/
long execPrgm (s, cmdtl)

char *s, *cmdtl;

{
char cmd[100], ch, * cmdptr;
int k, i, j, gtpath, envLen;
int tlNtFnd = -1;
long err;
char * envPtr;

/* Add len of path definition + 2 for 00 terminator */
envLen = ((i = strlen (path)) + (i ? 5 : 0) + 2);

/*Loop thru enviorment strings looking for '00'*/
i = 0;
while ((prntEnvPtr[i] + prntEnvPtr[i + 1]) != 0) 
   {
   /* if a path has been defined, don't count it.*/
   if (xncmps (5, &prntEnvPtr[i], "PATH="))
      {
      envLen--;
      i += strlen (&prntEnvPtr[i]); 
      }
   else
      {
      envLen++;
      i++;
      }
   }

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
   if (xncmps (5, &prntEnvPtr [envLen], "PATH="))
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

for (i = 0; (cmd[i] = *s); s++, i++) 
   if (*s == '.') tlNtFnd = 0;

if (tlNtFnd)
   for (j = 0; cmd[i] = prgTail[j]; i++, j++);

i = 0;
gtpath = -1;
while (ch = cmd[i++]) if ((ch == ':') || (ch == '\\')) gtpath = 0;

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
int i, j, k, oldsi, gtpath;
int tlNtFnd = -1;
char ch, cmd[100], * cmdptr;

for (i = 0; (cmd[i] = *s); s++, i++) 
   if (*s == '.') tlNtFnd = 0;

if (tlNtFnd)
   for (j = 0; cmd[i] = batTail[j]; i++, j++);

if (xncmps (3, &cmd[ i - 3], "BAT"))
   {
   i = 0;
   gtpath = -1;
   while (ch = cmd[i++]) if ((ch == ':') || (ch == '\\')) gtpath = 0;
   
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
      xCmdLn (parms, &i, &flHnd);
      xclose ((int)flHnd);
      compl_code = 0;
      return -1;
      }
   }

compl_code = 0XFFFFFFFF;
return 0;
}
/***************************************************************************/	
/***************************************************************************/	
getOptns (argv, options)
char *argv[];
long *options;

{
int i, j;
long ndx;

*options = 0;

while (*argv[i])
   {
   ucase (argv[i]);
   if (*argv[i] == '-')
      {
      ndx = 1;
      ndx = ndx << (*(argv[i] + 1) - 'A');
      *option &= ndx;
      j = i;
      while (*(argv[j] = argv[j+1])) j++;
      }
   else i++;
   }
}
/***************************************************************************/	
/***************************************************************************/	
dirCmd (argv, argc)
char *argv[];
int argc;

{
int filonly, dironly, terse;
int i, j;
long options;

filOnly = dirOnly = terse = 0;        
getOptns (argv, &options);

i = 1;
while (*argv[i])
   {
   ucase (argv[i]);

   if (option & ('A' - 'F'))
      {
      filOnly = -1; 
      dirOnly = 0;
      }
   if (option & ('A' - 'D'))
      {
      dirOnly = -1; 
      filOnly = 0;
      }
   if (option & ('A' - 'T'))
      terse   = -1;
 
   chkDir (argv[1], srcDir, srcNmPat);

   if (!terse) 
      {
      wrt("Directory of ");
      dspDir (argv[1], srcDir);
      dspMsg (12);
      }

   WSrcReq = argv[1];  
   WAttCode = -1;      
   if (! gtFlNm())
      {
      compl_code = 0xFFFFFFFF;
      if (!terse) dspMsg (1);
      }
   else 
      {
      compl_code = 0;
      do
         {
         n = strlen(&srchb[30]);
         if ((dirOnly) && (srchb[21] != 0x10)) goto skip;
         if ((filOnly) && (srchb[21] == 0x10)) goto skip;
         if ((terse) &&
            ((xncmps (2, &srchb[30], ".")) || (xncmps (3, &srchb[30], ".."))))
            goto skip;

         wrtln ("");
         xwrite(1,(long) n, &srchb[30]);
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
            prtDclFmt((long)*pl, 6, " ");
            }
         skip:
         }
      while (gtFlNm());   
      wrtln ("");
      if (!terse) dspMsg(5);
      }
   }
}
/***************************************************************************/	
/***************************************************************************/	
chmodCmd (argv, argc)
char *argv[];
int argc;

{
int att, i;

chkDir (argv[1], srcDir, srcNmPat);
WSrcReq = argv[1];  
WAttCode = -1;      
if (! gtFlNm())
   {
   compl_code = 0xFFFFFFFF;
   dspMsg (1);
   }
else 
   {
   mkSrc();
   att = srchb[21];
   if (att & 0x18)
      {
      wrt ("Unable to change mode on subdirectorys or volumes.");
      compl_code = 0xFFFFFFFF;
      }
   else
      {
      compl_code = 0;
      do
         {
         if (!*argv[2]) 
            {
            wrt ("Invalid mode specification.");
            compl_code = 0xFFFFFFFF;
            }
         else
            {
            i = mknum (argv[2]);
            if (i & ~0x7) 
               {
               wrt ("Invalid mode specification.");
               compl_code = 0xFFFFFFFF;
               }
            else
               compl_code = xattrib (srcFlNm, 1, i);
            }
         }   
      while (gtFlNm());   
      }
   if (!compl_code) 
      {
      dspMsg(5);
      }
   }
}

/***************************************************************************/	
/***************************************************************************/	
errCmd ()
{
wrt ("Completion code for previous command = ");
prthex ((int)compl_code);
}
/***************************************************************************/	
/***************************************************************************/	
pathCmd (argv)
char *argv[];

{
ucase (&argv[1]);
setPath (&argv[1]);
}
/***************************************************************************/	
/***************************************************************************/	
envCmd()
{
int i;

i = 0;
while ((prntEnvPtr[i] + prntEnvPtr[i + 1]) != 0) 
   {
   /* if a path has been defined, don't count it.*/
   if (!(xncmps (5, &prntEnvPtr[i], "PATH=")))
      {
      wrtln (&prntEnvPtr[i]); 
      } 
   i += strlen (&prntEnvPtr[i]);
   if (prntEnvPtr[i] + prntEnvPtr[i + 1] == 0) break;
   i += 1;
   }
if (path[0])
   {
   wrtln ("PATH="); wrt (path);
   }
}
/***************************************************************************/	
/***************************************************************************/	
catCmd (argv, argc)
char *argv[];
int argc;

{
int n;
long fd;

if (!(*argv[1])) dspMsg (6);
else
   {
   chkDir (argv[1], srcDir, srcNmPat);
   WSrcReq = argv[1];  
   WAttCode = -1;
   if (! gtFlNm())     
      {
      dspMsg (1);
      compl_code = 0xFFFFFFFF;
      }
   else 
      {
      compl_code = 0;
      do
         {
         mkSrc();
         fd = xopen(srcFlNm, 0); 
         do
            {
            n = xread(fd,1000L,buf);
            if (n > 0) xwrite(1,(long) n,buf);
            }
         while (n > 0);
         }            
      while (gtFlNm());   
      xclose(fd);
      }
   }         
}   
/***************************************************************************/	
/***************************************************************************/	
echoCmd (argv)
char *argv[];

{
chk_str (argv);
while (*argv) 
   {
   wrt (argv++);
   wrt (" ");
   }
dspMsg(12);
}
/***************************************************************************/	
/***************************************************************************/	
execCmd(argv, argc)
char *argv[];
int argc;

{
if (*nonStdIn) dspCL (&argv[0]);
if      (xncmps (3,s,"LS") || 
         xncmps (4,s,"DIR")) 	dirCmd(&argv[0], argc);
else if (xncmps (6,s,"CHMOD")) 	chmodCmd (&argv[0], argc);
else if (xncmps (4,s,"ERR")) 	errCmd();
else if (xncmps (5,s,"PATH")) 	pathCmd (&argv[0]);
else if (xncmps (4,s,"ENV")) 	envCmd ();
else if (xncmps(4,s,"CAT") || 
         xncmps(4,s,"TYPE")) 	catCmd (&argv[0], argc);
else if (xncmps(4,s,"REM") || 
         xncmps(4, s, "ECHO"))	echoCmd (&argv[1]);

else if (xncmps(3,s,"CD"))
{
if (argc == 0)
   {
   xgetdir(buf,drv+1);
   if (!buf[0])   
      {     
      buf[0] = '\\';  
      buf[1] = 0;     
      }      
   xwrite(1,(long) strlen(buf),buf);
   }
else 
   {
   if ((compl_code = xchdir(p)) != 0) 
      wrt ("Directory not found.");
   }
}
 
else if (xncmps(7,s,"CMDERR"))
{
if (*nonStdIn) dspCL (&argv[0]);
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
if (*nonStdIn) dspCL (&argv[0]);
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
if (*nonStdIn) dspCL (&argv[0]);
if ((compl_code = xmkdir(p)) != 0)
   wrt ("Unable to make directory");
}
else if (xncmps(3,s,"RD"))
{
if (*nonStdIn) dspCL (&argv[0]);
if ((compl_code = xrmdir(p)) != 0)
   wrt ("Unable to remove directory");
}
else if (xncmps(3,s,"RM") || xncmps(4,s,"DEL") || xncmps(4,s,"ERA"))
{         
query = 0;
i = 1;
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

if (*nonStdIn) dspCL (&argv[0]);
if (*p)
   {
   chkDir (p, srcDir, srcNmPat);
   WSrcReq = argv[1]; 
   WAttCode = -1;     
   if (! gtFlNm())
      {
      compl_code = 0xFFFFFFFF;
      dspMsg (1);
      }
   else 
      {
      do
         {
         if (!(srchb[21] & 0x18))
            {
            mkSrc();
            dspMsg(7); 
            if (query)
               {
               wrt ("? ");
               lin[0] = xrdchne();
               lin[1] = 0;
               wrt ("\b\b ");
               ucase (&lin[0]);
               if (lin[0] == 'Y') 
                  wrt (" << DELETED");
               else 
                  goto skipdel;
               }
            compl_code = xunlink (srcFlNm);  
skipdel:             dspMsg(12);
            }
         }
      while (gtFlNm());
      dspMsg(5);
      }
   }
else dspMsg(6);
}    
 
else if (xncmps(4,s,"REN"))
{
if (*nonStdIn) dspCL (&argv[0]);
compl_code = renmCmd(argv[1], argv[2]);
}
else if (xncmps(5,s,"SHOW"))
{
if (*nonStdIn) dspCL (&argv[0]);
ucase (p);
xgetfree(sbuf, (*p ? *p-64 : 0));
wrt ("Allocation Information: Drive ");
if (!*p) dspMsg (16);
else wrt (p);
dspMsg(12);
dspMsg(12);
wrt ("Total Units on Drive   "); 
   prtDclFmt ((long)sbuf[1], 6, " "); dspMsg(12);
wrt ("Free Units on Drive    "); 
   prtDclFmt ((long)sbuf[0], 6, " "); dspMsg(12);
wrt ("Sectors per Unit       "); 
   prtDclFmt ((long)sbuf[3], 6, " "); dspMsg(12);
wrt ("Bytes per Sector       "); 
   prtDclFmt ((long)sbuf[2], 6, " "); 
}
 
else if (xncmps(5,s,"INIT"))
{
if (*nonStdIn) dspCL (&argv[0]);
for (i=0; i < BUFSIZ; i++) buf[i] = 0;
ucase (p);
drv = *p - 'A';
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
if (*nonStdIn) dspCL (&argv[0]);
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
if (*nonStdIn) dspCL (&argv[0]);
if (argc >= 1) 
   {
   if (copyCmd(p, argv[2], xncmps(5,s,"MOVE") ? 1 : 0) == -1)
      {
      wrtln ("Disk full -- copy failed.");
      compl_code = 0xFFFFFFFF;
      }
   }
else dspMsg(6);
}    
else if (xncmps(4,s,"GET"))
{
if (*nonStdIn) dspCL (&argv[0]);
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
cr2cont();
}
else if (xncmps(4,s,"PUT"))
{
if (*nonStdIn) dspCL (&argv[0]);
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
else if (xncmps(5,s,"HELP")) dspMsg(17);
else if (xncmps(6,s,"BREAK")) xbrkpt();
else if (xncmps(5,s,"EXIT"))
{
if (*nonStdIn) dspCL (&argv[0]);
xclose(oldsi);
xclose(oldso);
devector();   /* remove vectors */   
xterm(0);
}
else if (xncmps(8,s,"VERSION"))  
{            
if (*nonStdIn) dspCL (&argv[0]);
i = xoscall(0x30);  
prtdecl((long)(i&0xFF));  
xwrite(1,1L,".");   
prtdecl((long)((i>>8)&0xFF));
}         
else if (xncmps(5,s,"WRAP"))  
{
if (*nonStdIn) dspCL (&argv[0]);
xwrite(1,2L,"\033v");     
dspMsg(5);
}
else if (xncmps(7,s,"NOWRAP"))
{
if (*nonStdIn) dspCL (&argv[0]);
xwrite(1,2L,"\033w");     
dspMsg(5);
}
else if (xncmps(4,s,"CLS"))   
xwrite(1,2L,"\033E");     
else 
{
if (*nonStdIn) dspCL (&argv[0]);
if (!(execBat (s, &argv)))
   {
   if ((compl_code = execPrgm (s, cmdtl)) == -32) xlongjmp (jb, -1);
   else if ((compl_code > 0) && prgerr) xlongjmp (jb, -1);
   else 
      if ((compl_code & 0xFFFFFFFF) < 0)
         {
         wrt ("Command not found."); 
         if (prgerr) xlongjmp (jb, -1); 
         }
   }
}
}
/***************************************************************************/	
/***************************************************************************/	
int mknum (str)
char * str;

{
int num, hex = 0;
char ch;

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
chk_sub (tl, parm)
char *tl, *parm[];

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
            {
            *tmptl_ptr = ch;
            tmptl_ptr++;
            }
         break;

      case '%':
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
}
/***************************************************************************/	
/***************************************************************************/	
chk_str (parm)
char * parm[];

{
int i = 0;
char * parm_ptr, * tmp_ptr, ch;

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
char * lin;

{
int i, j = 0;

dspMsg(13);

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

char * lin;
long * flHnd;

{
int i, j = 0;
int chrFnd;
char ch;

while ((chrFnd = xread ((int)*flHnd, 1L, &ch) > 0) && (ch != '\r'))
   lin[j++] = ch;

lin [j] = 0;
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
xCmdLn (parm, pipeflg, nonStdIn)
char * parm[];
int  * pipeflg;
long * nonStdIn;


{
int pipe, nsi, nso, bdChrs;
int rwflg;
int fs,fd,n,n2,nch,fds,fdd;
int i,j,k,att,argc,f1,f2,nd,rec,oldsi,oldso;
int concat, query;
int *dt;
long pos,len,err,siz,*pl,nl, newso, newsi;
long sbuf[4];						
long dskFlHnd;
int next;						
char ch, *cmdtl, *tl0, *tl1, *tl, *d, *s, *argv[MAXARGS];
char *p, *lastp, ltail[130];

BPB *b;

nsi      = nso      = 0;

/* while there is input from the disk or standard input */
while (*nonStdIn ? (bdChrs = readDsk (&lin, nonStdIn)) : readSi(&lin))
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
   tl = &lin[0];
   while (*tl == 0x20) tl++;
   chk_sub (tl, &parm[0]);
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

         if ((dskFlHnd = xopen(tl0, 0)) >= 0)
            {
            pipe = -1;
            }
         else
            {
            wrtln (tl0); wrt (" not found.");
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
            oldsi = dup(0);
            xforce(0,(int)newsi);
            xclose((int)newsi);
            nsi = -1;
            }
         else
            {
            wrtln (tl0); wrt (" not found.");
            }
         break;

      case '>':
         for (tl1 = tl; ch = *tl; tl++)
            {
            if (ch == '>') 
               {
               concat = -1;
               tl1++;
               }
            if (ch == 0x20) break;
            }
         *tl++ = 0;
         if (concat)
            {
            if ((newso = xopen(tl1, 1)) < 0)
               {
               newso = xcreat(tl1, 0);
               }
            }
         else
            {
            xunlink (tl1);
            newso = xcreat(tl1,0);
            nso = -1;
            }
         oldso = dup(1);
         xforce(1, (int)newso);
         xclose((int)newso);
         if (concat)
            xf_seek (0L, 1, 2);
         nso = -1;
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

wrtln ("flag1");
wrtln ("argv =");wrt (argv[0]);
   while (i < MAXARGS - 1) argv[++i] = d;
wrtln ("argv =");wrt (argv[0]);
wrtln ("flag2");

   s = argv[0];
   p = argv[1];
   ucase(s);

   /*Build command tail.*/
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
 
   if (pipe) 
      {
      xCmdLn (&argv, &pipe, &dskFlHnd);
      xclose ((int)dskFlHnd);
      }
   
   if ((strlen(s) == 2) && (s[1] == ':'))
      {
      xsetdrv(drv = (*s -'A'));     
      }
   else 
      execCmd(&argv[0], argc);

   /* if a new standard in specified ...*/
   if (nsi == -1)
      {
      xclose (0);
      xforce(0,oldsi);
      }
   /* if a new standard out specified.*/
   if (nso == -1)
      {
      xclose (1);
      xforce(1,oldso);
      }
   
   again:
   }
}
/***************************************************************************/	
/***************************************************************************/

cmain(bp)
char * bp;                            /*Base page address                 */
{
char * parm[MAXARGS];
int    i, k;
long   j;

basePage = bp;
prntEnvPtr = *((char **) (basePage + 0x2C));
xsetdta(srchb);
path[0] = 0;
compl_code = 0;
prgerr = -1;
cmderr = 0;
dspMsg(4);

i = 0;
while ((prntEnvPtr[i] + prntEnvPtr[i + 1]) != 0) 
   {
   /* if a path has been defined, don't count it.*/
   if (xncmps (5, &prntEnvPtr[i], "PATH="))
      {
      setPath (&prntEnvPtr[i + 5]);
      break;
      }
   i++;
   }

execBat (&autoBat, &parm[0]);

if (xsetjmp(jb))
   {
   for (i = 6; i <= 20; i++) xclose (i);
   }

while (1)
   {
   k = 0;
   j = 0;
   xCmdLn (&parm[0], &k, &j);
   }
}
