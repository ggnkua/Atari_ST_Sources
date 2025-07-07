
/**************************************************************************
 *
 * BATCHMON -  A simple batch monitor (non-interactive shell).
 *             This program will read lines from a 'batch' or 'script'
 *             file, invoke rudimentary variable subsitution on each line
 *             read, then execute the command or program specified by the
 *             line.  Certain basic commands (DELETE, WAIT, etc), are
 *             implemented internally, but mostly this allows you to run
 *             a set of programs in a given order, passing parms to those
 *             programs.
 *
 * ??/??/??    v1.0 - This was crude indeed, and the source is long lost.
 *
 * 07/24/88    v2.0 - A total re-write, this one is pretty functional.
 *             This version does more than just run programs, it includes
 *             internal implementation of some functions, and support for
 *             simple variable substitution. 
 *
 * 11/05/88    v2.1 - Recompiled with Sozobon, released as part of Sozobon.
 *             This version can be compiled with Sozobon and dLibs; all 
 *             routines linked from '\ianlibs\libi' are now included here  
 *             in source form.  This version also includes more internal 
 *             functions, especially path and envstring support.
 *
 *************************************************************************/

#include <osbind.h>

#define TRUE  1
#define FALSE 0

#define MAXARGS 10

/* translate my lib function int2asc() into dlibs itoa() for sozobon      */
/* translate dlibs bzero() function, because the dlibs version don't work */

#ifdef SOZOBON 
#define int2asc(str,int)  itoa(int,str,10) 
#define bzero(str,int)    myzero(str,int)
#endif

char callbuf[128],
     callparms[128],
     *inpv[MAXARGS],
     inputcmd[128],
     inpfile[128],
     callfile[128],
     exepath[128] = "",
     crlf_str[] = "\r\n";

int  inpc,
     rcflag = TRUE;           /* Flag: Abort on non-zero RC? */

/*************************************************************************
 *
 * Main routine.
 *  Process cmdline parms, or if none were received, prompt the user. Make
 *  sure we can open/read the batch file, then for each line call the 
 *  parser & command processor, continue until end-of-file or I/O error.
 *
 ************************************************************************/

main(argc, argv)
int  argc;
char *argv[];
{
int counter, linlen;

say("\033E\033vBATCHMON: Batch monitor v2.1\r\n\n");

if (argc > 1)
     {
     if (argc > MAXARGS)
          {
          bm_msg("Too many variables/arguments! (Max = 10).\r\n");
          err_exit();
          }
     for (counter = 1; counter < argc; counter++)
          inpv[counter-1] = argv[counter];
     inpc = argc - 1;
     }
else
     {
     say("\033e\r\nEnter batch file name and parms (<CR> to exit)\r\n -> ");
     getstr(inputcmd, 127, "");
     inpc = bldargv(inpv, inputcmd, MAXARGS);
     }
     
say("\033f");                      /* cursor off */

if (inpc == 0)                     /* if <CR>, terminate */
     Pterm(0);

upcase(inpv[0]);                   /* force file/cmd name to uppercase */
inpfile[0] = 0x00;                 /* start with null filename         */
add_extension(inpfile, inpv[0], ".BAT");

linlen = getline(127, inpfile);    /* Open batch command file     */

if (linlen < 0)
     {
     bm_msg("Cannot open batch file '");
     say(inpfile);
     say("', status = ");
     sayint(linlen);
     err_exit();
     }

do   {                             /* main loop: read file, exec cmds.    */
     if (Bconstat(2))              /* if keystroke available...           */
          check_abort();           /* see if user wants abort.            */
     bzero(callbuf, sizeof(callbuf)); /* Start with clean line buffer.    */
     linlen = getline(0, callbuf); /* Get the next line.                  */
     if (linlen >= 0)              /* If not EOF or error...              */
          if (do_substitution())   /* Parse & do variable substitution.   */
               do_command();       /* If non-zero there is a cmd to exec. */
     } while (linlen >= 0);        /* Loop until EOF or I/O error.        */

if (linlen != -128)
     {
     say(crlf_str);
     bm_msg("Error occurred reading batch file '");
     say(inpfile);
     say("', status = ");
     sayint(linlen);
     err_exit();
     }

Pterm(0);                          /* Normal exit, no wait-for-key */

}

/*************************************************************************
 *
 * Internal command modules.  These *have* to appear before the command
 * table structure to compile properly on Alcyon.  Note when adding new
 * routines that the following data structures are available to help them:
 *  
 *  callfile       - The name of the command, for what it's worth.
 *  callparms[0]   - Byte count of string callparms[1-n].
 *  callparms[1-n] - A string of characters which comprise the parms from
 *                   the batch file after variable substitution. The string
 *                   will be null-terminated, and if there were no parms 
 *                   there will be a null char in callparms[1].
 *
 * Each routine should return an integer; zero if all went well, or an
 * error code of some sort.  Right now this makes no difference, but a
 * future version might/will report these return codes to the user and/or
 * treat them in general the same as an RC from an external program.
 ************************************************************************/

/*-------------------------------------------------------------------------
 * DEL/DELETE - Delete 1-10 files.
 *-----------------------------------------------------------------------*/

cmd_delete()
{
char *delv[10];
int  delc,
     counter,
     status;

delc = bldargv(delv, &callparms[1], 10);     /* build filename list     */
     
if (delc)                                    /* if anything to delete...*/
     {
     for (counter = 0; counter < delc; counter++)
          {
          status = Fdelete(delv[counter]);   
          if (status)
               bm_msg("Cannot delete file ");
          else
               bm_msg("Deleted file ");
          say(delv[counter]);
          say(crlf_str);
          }
     }
else
     {
     bm_msg("No files to delete!");
     say(crlf_str);
     }
     
return(0);
}

/*-------------------------------------------------------------------------
 * COM/REM - Do nothing.
 *-----------------------------------------------------------------------*/

cmd_null()
{
return(0);
}

/*-------------------------------------------------------------------------
 * WAIT/PAUSE - Stop and prompt for a keystroke to continue.
 *-----------------------------------------------------------------------*/

cmd_wait()
{
int workchr;

bm_msg("Hit any key to continue...\r\n");

do   {
     workchr = Bconin(2);     /* Another piece of artificial stupidity:   */
     switch (workchr)         /* When waiting for a keystroke, kill       */
          {                   /* the program on a ^C, and ignore ^S & ^Q. */
          case 0x03:          
               Pterm(0);      
          case 0x11:          
          case 0x13:
               break;
          default:
               workchr = 0x00;
          }
     } while (workchr);
     
return(0);
}

/*-------------------------------------------------------------------------
 * RCSTOP - Set the flag to stop on a non-zero return code.
 *-----------------------------------------------------------------------*/

cmd_rcstop()
{
rcflag = TRUE;
return(0);
}

/*-------------------------------------------------------------------------
 * NORCSTOP - Set the flag to cruise through a non-zero return code.
 *-----------------------------------------------------------------------*/

cmd_norcstop()
{
rcflag = FALSE;
return(0);
}

/*-------------------------------------------------------------------------
 * SETENV - Do something to the environment. Something = whatever is on
 *  the command line.
 *-----------------------------------------------------------------------*/

cmd_setenv()
{
putenv(&callparms[1]);
return(0);
}

/*-------------------------------------------------------------------------
 * EXEPATH - Set path for programs called from the batch monitor.
 *-----------------------------------------------------------------------*/

cmd_exepath()
{
fixpath(&callparms[1],TRUE);       /* Force path to end in '\'. */
strcpy(exepath, &callparms[1]);    /* Set new default path for exe files */
return(0);
}

/*-------------------------------------------------------------------------
 * DEFPATH - Set path for programs called from the batch monitor.
 *-----------------------------------------------------------------------*/

cmd_defpath()
{
int status;

fixpath(&callparms[1],FALSE);            /* Force path to not end in '\'. */

upcase(&callparms[1]);

if (callparms[2] == ':')
     {
     Dsetdrv(callparms[1] - 'A');
     status = Dsetpath(&callparms[3]); 
     }
else
     status = Dsetpath(&callparms[1]);
     
if (status)
     {
     bm_msg("DOS status ");
     sayint(status);
     say(" setting path ");
     say(&callparms[1]);
     say(crlf_str);
     }
return(status);
}

/*-------------------------------------------------------------------------
 *
 *-----------------------------------------------------------------------*/

/**************************************************************************
 *
 * Command table structure.  Maps command names to the functions that
 * handle the command. This is serious overkill for this simple batch
 * monitor, but it will make for simpler extension in the future.
 *
 *************************************************************************/

struct {
     int  (*cmd_ptr)();       /* pointer to function that returns int */
     char *cmdname;           /* pointer to command name              */
       } command_table[] = {
     cmd_delete,    "DEL",
     cmd_delete,    "DELETE",
     cmd_wait,      "WAIT",
     cmd_wait,      "PAUSE",
     cmd_null,      "COM",
     cmd_null,      "REM",
     cmd_rcstop,    "RCSTOP",
     cmd_norcstop,  "NORCSTOP",
     cmd_exepath,   "EXEPATH",
     cmd_defpath,   "DEFPATH",
     cmd_setenv,    "SETENV"
       };

#define NUMCMDS 11

/**************************************************************************
 *
 * do_command - Decide whether command is 1) a comment, 2) internal, or
 *              3) external, and take the appropriate action. (Ignore it,
 *              call the internal routine, or call the external program).
 *
 *************************************************************************/

#define COMMENT1 '*'
#define COMMENT2 '!'
#define COMMENT3 ';'

do_command()
{
register char workchr;

char          workname[128];

register int  counter,
              status;

long          execstat;

/*-----------------------------------------------------------------------
 * If the first character is a comment flag, ignore the entire line.
 *-----------------------------------------------------------------------*/
  
workchr = callfile[0];
if ((workchr == COMMENT1) || (workchr == COMMENT2) || (workchr == COMMENT3))
     return(0);

/*-----------------------------------------------------------------------
 *  Force the command/filename to uppercase, and compare it to each 
 *  entry in the command table.  If a match is found, call the 
 *  corresponding internal command processor, return that processor's
 *  return code to our caller.
 *-----------------------------------------------------------------------*/
   
upcase(callfile); 
for (counter = 0; counter < NUMCMDS; counter++) 
     if (0 == strcmp(callfile, command_table[counter].cmdname))
          return( (*(command_table[counter].cmd_ptr))() );           
     
/*-----------------------------------------------------------------------
 * It's not an internal command, so try to call it as a program.
 *-----------------------------------------------------------------------*/

strcpy(workname, exepath);
add_extension(workname, callfile, ".PRG");
status = execstat = Pexec(0, workname, callparms, 0L);

if (execstat < 0L)                 /* If DOS error... */
     {
     bm_msg("Error occurred attempting to run '");
     say(workname);
     say("', status = ");
     sayint(status);
     say(crlf_str);
     }
else
     {
     if (status)                   /* If program returned non-zero... */
          {
          bm_msg("Program exited with status code ");
          sayint(status);
          say(crlf_str);
          if (rcflag)
               check_abort();
          }
     }

return((int)execstat);
}

/**************************************************************************
 *
 * Routine to parse a line from the batch file and perform variable
 * substitution.  Pure ugly brute force coding can be found here.
 *
 *************************************************************************/

do_substitution()
{
register char *p_rawparm,     /* -> curloc in raw input from batch file   */
              *p_parsdparm,   /* -> curloc in parsed cmdline we're building */
              *p_subsparm,    /* -> curloc in a substitution variable     */
              workchr;        /* what do you *think* this is ?            */
              
register int  counter,        /* Count of bytes in parsed cmdline         */
              workidx;        /* used when doing variable substitution    */

char          *callv[2];      /* Pointers to first word & rest of words   */
int           callc;          /* in raw image, and count of pointers.     */

static   int  msgissued[10];  /* Keep track of var subs err msgs issued.  */

/*-----------------------------------------------------------------------
 * Parse command line into 2 pieces and decide what to do with it...
 *-----------------------------------------------------------------------*/

callc = bldargv(callv, callbuf, 2);   /* Separate 1st word from the rest  */

switch (callc)                /* What did the input line look like?       */
     {
     case 0:
          say(crlf_str);      /* An empty input line... just ouput an     */
          return(0);          /* empty line, and return a zero.           */
          break;
     case 1:
          callv[1] = "";      /* Command/prog name w/no parms, force null */
          break;
     default:                 /* Else command & parms, all set to go.     */
          break;
     }

p_rawparm = callv[1];         /* Prime pointer to raw input image.        */
p_parsdparm = &callparms[1];  /* Prime pointer to final cmdline image.    */
counter = 0;                  /* Assume cmdline length of zero.           */

/*-----------------------------------------------------------------------
 * Main loop to process variable substitution into command line image...
 *-----------------------------------------------------------------------*/

do   {                                            /* Loop for var subs...  */           

     workchr = *p_parsdparm = *p_rawparm;         /* Get/move a character  */

     if (workchr == '%')                          /* If char is not '%'    */
          {                                       /* skip to end of loop.  */
          workidx = *(p_rawparm+1) - '0';         /* Turn next char into an*/
          if ((workidx >= 0) && (workidx < inpc)) /* index (%1-%9 = 1-9),  */
               {                                  /* range check against   */
               p_rawparm += 2;                    /* # of args available.  */
               p_subsparm = inpv[workidx];        /* If valid, incr the    */
               while (*p_subsparm)                /* rawparm ptr (suck up  */
                    {                             /* the index char), and  */
                    *p_parsdparm++ = *p_subsparm++;/* copy the subs value  */
                    counter++;                    /* to the final string.  */
                    }                             /* If numeric but not    */
               } /* END var in range */           /* valid, incr the raw   */
          else                                    /* ptr but not the parsed*/
               {                                  /* so that we effectively*/
               if ((workidx >= 0) && (workidx <= 9)) /* make the missing   */
                    {                             /* var just disappear.   */
                    if (!msgissued[workidx])      /* Issue a warning the   */
                         {                        /* 1st time we do this.  */
                         bm_msg("Warning...No runtime value supplied for variable %");
                         Bconout(2,'0' + workidx);
                         say(crlf_str);
                         msgissued[workidx] = TRUE;
                         }
                    p_rawparm += 2;     /* For a '%' followed by a digit   */
                    }                   /* out of range, incr raw ptr past */
               else                     /* both '%' & digit (make var dis- */
                    {                   /* appear).  For '%' followed by   */
                    p_rawparm++;        /* non-digit, incr raw & parsed    */
                    p_parsdparm++;      /* ptrs by one and continue; that  */
                    counter++;          /* is, preserve original values.   */
                    }
               } /* END ELSE of var in range */
          } /* END if (workchr == '%') */
    else
          {
          p_rawparm++;                  /* Other 1/2 of substitution loop..*/
          p_parsdparm++;                /* incr pointers & counter if      */
          counter++;                    /* char just processed is not null */
          }                             /* and not a variable. Continue    */
     } while (workchr);                 /* looping if char was not a null. */

/*------------------------------------------------------------------------
 * Command line is now built, turn it into a TOS cmdlin image for Pexec()
 * display the after-substitution image.
 *-----------------------------------------------------------------------*/
 
callparms[0] = (char)counter-1;         /* Final image done, plug in length*/

strcpy(callfile, callv[0]);             /* Copy the filename to its home.  */

say(callfile);                          /* Output file/command name.  */
say("\011  ");  /* TAB char */          /* Separate command/parms */
say(&callparms[1]);                     /* Output parms after substitution */
say(crlf_str);                          /* Start a new line. */

if (counter > 127)            /* This is totally graceless, but might */
     {                        /* help prevent crashing the machine! */
     bm_msg("Command line is longer than 127 bytes after subsitution (FATAL).\r\n");
     err_exit();
     }

return(1);                              /* Indicate there *is* a command. */
}

/*************************************************************************
 *
 * Add a default file extension if one doesn't exist.
 *  This is a strange function.  It looks at the last four characters
 *  of a string (hopefully a filename), and if it doesn't include a '.'
 *  the default file extension is tacked on.
 *
 *************************************************************************/


add_extension(p_newname, p_fname, p_defext)
char *p_newname, *p_fname, *p_defext;
{
register char *p_work;
register int  slen,
              counter;

slen = strlen(p_fname);
p_work = p_fname + slen;
for (counter = 0; (counter < 4) && (counter < slen); counter++)
     {
     if (*p_work == '\\') /* I hate 'break' almost as much as 'goto', */
          break;          /* but this handles "a:\batfiles.c\c"...    */
     if (*p_work == '.')
          return(0);
     p_work--;
     }
strcat(p_newname, p_fname);
strcat(p_newname, p_defext);
return(0); /* why is this here? */
}

/***************************************************************************
 ***************************************************************************
 *
 * Things which are normally library routines (mine) but are included here
 * to keep from confusing people who don't have my libs.  
 *
 **************************************************************************
 **************************************************************************/

/*-------------------------------------------------------------------------
 * The dLibs bzero() function is VERY broken, this takes it's place.
 *------------------------------------------------------------------------*/

myzero(p_str, count)
register char *p_str;
register int  count;
{
while (count--)
     *p_str++ = 0x00;
}

/*-------------------------------------------------------------------------
 * Check with the user to see if s/he wants to abort the batch run.
 *------------------------------------------------------------------------*/

check_abort()
{
char workstr[4];
int count;

while (Bconstat(2))       /* Suck up buffered characters before prompting. */
     {
     if (0x03 == (char)Bconin(2)) /* If one of the buffered characters is  */
          Pterm(0);               /* a ^C, get out without prompting.      */
     }                    
                          
do   {
     say(crlf_str);
     bm_msg("\033eAbort (Y/N) ? ");     /* cursor on, prompt       */
     count = getstr(workstr,2,"YyNn");  /* get validated answer    */
     } while (count == 0);              /* loop until valid input. */

if ((workstr[0] == 'y') || (workstr[0] == 'Y'))
     Pterm(0);
     
say("\r\n\033f");                     /* cursor off            */
}

/*-------------------------------------------------------------------------
 * fixpath - Make sure a pathname ends in a '\' char or that it doesn't,
 *  depending on the value of 'pathflag' (0=no trailing \, 1=trailing \).
 *  If we change the string, we'll return a 1.
 *-----------------------------------------------------------------------*/

fixpath(p_path, pathflag)
char *p_path;
int pathflag;
{
int pos, len;

pos = strrpos(p_path,'\\');
len = strlen(p_path) -1;

if (len == -1)                /* Hack: If null string, always force'\' */
     {                                          
     strcat(p_path,"\\");                       
     return(1);
     }

if (pathflag)                 /* If the last char should be '\'... */
     {
     if (pos != len)          /* and it's not...                   */
          {                   /* tack one on.                      */
          strcat(p_path, "\\");  
          return(1);
          }
     }
else                          /* If the last char should not be '\'... */
     if (pos == len)          /* and it is...                          */
          {                   /* put a null over it.                   */
          p_path[pos] = 0x00;
          return(1);
          }
          
return(0);                    /* If we made it to here nothing changed. */
}

/*-------------------------------------------------------------------------
 * Issue a message with a 'BATCHMON:' header.
 *-----------------------------------------------------------------------*/
 
bm_msg(p_msg)
char *p_msg;
{
say("BATCHMON: ");
say(p_msg);
}

/*-------------------------------------------------------------------------
 * error exit.  Force the batch file closed and wait for a keystroke.
 *-----------------------------------------------------------------------*/
 
err_exit()
{
getline(-1, 0L); /* Force file closed. */
cmd_wait();
Pterm(0);
}

/*-------------------------------------------------------------------------
 * Force a string to uppercase.  Modifies string in-place.
 *-----------------------------------------------------------------------*/

upcase(p_string)
register char *p_string;
{
do   {
     if ((*p_string >= 'a') && (*p_string <= 'z'))
          *p_string -= 32;
     } while (*++p_string);
}

/*-------------------------------------------------------------------------
 * Some character I/O routines which use BIOS calls, because if you've
 * got TurboST installed the DOS calls are too buggy.
 *-----------------------------------------------------------------------*/

say(p_str)
register char *p_str;
{
while (*p_str)
     Bconout(2,*p_str++);
}

sayint(intnum)
int  intnum;
{
char work[20];

int2asc(work,intnum); /* integer to ascii (becomes itoa() under Sozobon) */
say(work);
}

/***************************************************************************
 *
 * getstr - Get edited string
 *
 *   Usage:
 *
 *        integer = getstr(str_to_fill,int_maxlen,str_of_valid_chars);
 *
 *   Example:
 *
 *        int  length,getstr();
 *        char string[20];
 *        static string ok_chars[] = {"0123456789.-"};
 *        
 *        length = getstr(string,20,ok_chars);
 *
 *   Return:
 *
 *        length contains length of null-terminated string (not including
 *               the null itself).
 *        string contains the string entered.
 *
 *   Externals:
 *
 *        None.
 *
 *   Notes:
 *   
 *        The only thing this routine has over Cconrs() is the validity
 *        checking of valid_chars on a character-by-character basis...
 *        if the user hits a key that's not valid, it won't be echoed
 *        to the screen, cluing him (hopefully) that it's a bad char.
 *
 *        If the length of valid_chars is 0 (null string), all keyboard
 *        chars are considered valid. 
 *
 *        The maximum characters the user can enter is maxlen-1, insuring
 *        room to add the null terminator to the string.  DON'T PASS THIS
 *        ROUTINE A LENGTH OF ONE UNLESS YOU EXPECT TO RECEIVE A NULL
 *        STRING! (A length of 1 has the effect of making this a very
 *        fancy wait-for-carriage-return routine!).
 
 *        The following keys allow the user to edit the input, making it
 *        impossible to return the ASCII value of these keys.  These keys
 *        are ALWAYS valid, regardless of the content of valid_chars:
 *
 *             <RETURN> - Used to terminate input
 *             <DELETE> - Backspace and delete input chars
 *             <ESC>    - Clear input string and start over
 *
 *        Note that no attempt is made to deal with the cursor keys for 
 *        editing input -- they will be returned as data.
 *
 **************************************************************************/

int  getstr(string,maxlen,valid_chars)
int  maxlen;
char string[],valid_chars[];
{

int  done, inctr, ichar, all_valid, index();
char wchar;

all_valid = ! valid_chars[0];
inctr     = 0;
done      = 0;
maxlen--;

while (!done)
     {
     while (!Bconstat(2));    /*do nothing until key is hit*/
     wchar = ichar = Bconin(2) & 0x00FF;

     switch(ichar)
          {
          case 0x000D: /* RETURN ley */


               string[inctr] = 0x00;
               Bconout(2,10);Bconout(2,13);
               done++;
               break;

          case 0x0008: /* DELETE key */

               if (inctr)
                    {
                    Bconout(2,8); Bconout(2,32); Bconout(2,8);
                    inctr--;
                    }
               break;

          case 0x001B: /* ESC key */

               while (inctr)
                    {
                    Bconout(2,8); Bconout(2,32); Bconout(2,8);
                    inctr--;
                    }
               break;

          default:     /* any other key */

               if ((inctr < maxlen) && (all_valid || (instr(valid_chars,wchar))))
                    {
                    string[inctr++] = wchar;
                    Bconout(2,ichar);
                    }
               break;
          }
     }
return(inctr);
}

/* Return 1/0 indicating char is in string, or not. subfunction of getstr()*/

instr(str,chr)
register char *str,chr;
{
while(*str)
     if (chr == *str++)
          return(1);
return(0);
}

/**************************************************************************
 *
 * bldargv --  Scan a string, setting pointers to the space-delimited
 *             words within it.  Null terminate each word except the
 *             last (which should already be null terminated, anyway).
 *             Strip leading spaces from the args (that is...point
 *             past them).
 *
 *   Usage:
 *        Pass this routine a pointer to an array which will hold
 *        the pointers to the arguments, a pointer to the string buffer,
 *        and the maximum number of pointers your array can hold. It
 *        will return the number of pointers generated.  Note that if
 *        there are more words in the buffer than you have pointer slots
 *        for, the last pointer will be to the remainder of the buffer.
 *
 *        Confused?  Check this out:
 *
 *             char string[] = "    c:\test.prg   arga   argb   argc"
 *             char *argv[3];
 *             numargs = bldargv(argv,string,3);
 *
 *        This sequence will yield the following:
 *
 *             numargs = 3
 *             argv[0] -> "c:\test.prg"
 *             argv[1] -> "arga"
 *             argv[2] -> "argb   argc"
 *
 *        Note that the leading spaces were removed from the arguments,
 *        but the imbedded spaces within the 'rest of the buffer' 3rd
 *        arg were left intact.
 *
 * Maintenance:
 *  04/13/87 - Original version. 
 *
 **************************************************************************/

bldargv(argv,p_strbuf,maxarg)
register char *argv[],*p_strbuf;
int  maxarg;
{
register int  argc;

argc = 0;

while(*p_strbuf)
     {
     while (*p_strbuf == ' ')      /* Cruise through spaces */
          p_strbuf++;
     if (*p_strbuf)                /* Found non-space, but skip if null. */
          {
          argv[argc++] = p_strbuf; /* Found start of word, mark its loc. */
          if (argc == maxarg)
               return(argc);       /* If out of pointer slots, return.   */
          while (*p_strbuf != ' ') /* Cruise through word (non-blank).   */
               {
               if (*p_strbuf == 0x00)   /* If end of string, return.     */
                    return(argc);
               p_strbuf++;              /* Else look at next char.       */
               }
          *p_strbuf++ = 0x00;      /* Found end of word, null-term word. */
          }
     }
return(argc); /* If string ended on a run of spaces we'll exit this way. */
}

/***************************************************************************
 *
 * GetLine --  Routine to read a CRLF-terminated line from a file, & 
 *             return it as a NULL-terminated string in your buffer.
 *             A null in the file will hose things but good.
 * Usage:
 *        On the first call, function must be non-zero and indicates 
 *        your maximum buffer size for subsequent calls, and p_out is
 *        a pointer to a file name to process.  This call sets things
 *        up, but doesn't process any actual data. A negative return
 *        from this call is an Fopen() error.  A positive return is the
 *        file handle, but don't fuck with it.  If your buffer is
 *        completely filled (maximum size is returned), you'll get the
 *        rest of the line on the next call.  This can be  good or bad...
 *
 *        On following calls, function is zero, and p_out is a pointer
 *        to a buffer big enough to hold a line.  Big enough is up to
 *        you - there is no kind of overflow checking. A negative return
 *        from this call is an Fread() error, or -128, indicatng EOF;
 *        the file will be closed.  A positive return (including zero) 
 *        indicates the number of characters moved into your buffer.
 *        Zero indicates a line of just CRLF in the file, so you get
 *        an empty (NULL char only) buffer.
 *
 * Maintenance:
 *
 * 04/12/87 -  Original version.
 * 04/13/87 -  Added: If function is negative, it will force a close
 *             of the currently open file.
 *
 **************************************************************************/

getline(function,p_out)
int  function;
register char *p_out;
{
static   char buffer[512],*p_buffer;
static   int  charcntr,fhandle,maxlength;
register int  outlength;

if (function)
    {
    if ((function < 0) && (fhandle > 0))
          {
          Fclose(fhandle);
          fhandle = 0;
          }
     else
          {
          charcntr = 0;
          maxlength = function;
          return((fhandle = Fopen(p_out,0)));
          }
     }

*p_out = outlength = 0;
while(1)
     {
     if (!charcntr)
          {
          if (!(charcntr = Fread(fhandle,512L,buffer)))
               {
               if (outlength)
                    {
                    *p_out = 0x00;
                    return(outlength);
                    }
               else
                    {
                    Fclose(fhandle);
                    fhandle = 0;
                    return(-128);
                    }
               }
          p_buffer = buffer;
          }
     charcntr--;
     if ('\r' == *p_buffer)
          {
          *p_out = 0x00;
          p_buffer++;
          return(outlength);
          }
     if ('\n' == *p_buffer)
          p_buffer++;
     else
          {
          if(++outlength == maxlength)
               {
               *p_out = 0x00;
               return(maxlength);
               }
          *p_out++ = *p_buffer++;
          }
     }
}


