/*--------------------------------------------------------------------------*/
/*                                                                          */
/*                                                                          */
/*      ------------         Bit-Bucket Software, Co.                       */
/*      \ 10001101 /         Writers and Distributors of                    */
/*       \ 011110 /          Freely Available<tm> Software.                 */
/*        \ 1011 /                                                          */
/*         ------                                                           */
/*                                                                          */
/*  (C) Copyright 1987-90, Bit Bucket Software Co., a Delaware Corporation. */
/*                                                                          */
/*                                                                          */
/*               This module was written by Vince Perriello                 */
/*                                                                          */
/*                                                                          */
/*                 BinkleyTerm OMMM Control File Generator                  */
/*                                                                          */
/*                                                                          */
/*    For complete  details  of the licensing restrictions, please refer    */
/*    to the License  agreement,  which  is published in its entirety in    */
/*    the MAKEFILE and BT.C, and also contained in the file LICENSE.240.    */
/*                                                                          */
/*    USE  OF THIS FILE IS SUBJECT TO THE  RESTRICTIONS CONTAINED IN THE    */
/*    BINKLEYTERM  LICENSING  AGREEMENT.  IF YOU DO NOT FIND THE TEXT OF    */
/*    THIS  AGREEMENT IN ANY OF THE  AFOREMENTIONED FILES,  OR IF YOU DO    */
/*    NOT HAVE THESE FILES,  YOU  SHOULD  IMMEDIATELY CONTACT BIT BUCKET    */
/*    SOFTWARE CO.  AT ONE OF THE  ADDRESSES  LISTED BELOW.  IN NO EVENT    */
/*    SHOULD YOU  PROCEED TO USE THIS FILE  WITHOUT HAVING  ACCEPTED THE    */
/*    TERMS  OF  THE  BINKLEYTERM  LICENSING  AGREEMENT,  OR  SUCH OTHER    */
/*    AGREEMENT AS YOU ARE ABLE TO REACH WITH BIT BUCKET SOFTWARE, CO.      */
/*                                                                          */
/*                                                                          */
/* You can contact Bit Bucket Software Co. at any one of the following      */
/* addresses:                                                               */
/*                                                                          */
/* Bit Bucket Software Co.        FidoNet  1:104/501, 1:132/491, 1:141/491  */
/* P.O. Box 460398                AlterNet 7:491/0                          */
/* Aurora, CO 80046               BBS-Net  86:2030/1                        */
/*                                Internet f491.n132.z1.fidonet.org         */
/*                                                                          */
/* Please feel free to contact us at any time to share your comments about  */
/* our software and/or licensing policies.                                  */
/*                                                                          */
/*--------------------------------------------------------------------------*/

#include <stdio.h>
#include <signal.h>
#include <ctype.h>
#include <conio.h>
#include <stdlib.h>
#include <string.h>
#ifndef __TOS__
#include <sys/types.h>
#include <sys/stat.h>
#endif

#ifdef __TURBOC__
#ifdef __TOS__
#include <ext.h>
#else
#include <alloc.h>
#endif
#else
#ifndef LATTICE
#include <malloc.h>
#endif
#endif

struct parse_list {
		size_t p_length;
		char *p_string;
		};

/*
 * Use portable word size defintions
 */

#ifdef ATARIST

#include <portab.h>

#ifndef H_BINK
typedef WORD word;
typedef BYTE byte;
#endif

#else
typedef unsigned bit;
typedef unsigned int word;
typedef unsigned char byte;
#endif

#define write_binary "wb"
#ifdef __TOS__
#define read_ascii "r"
#else
#define read_ascii "ra"
#endif

/*--------------------------------------------------------------------------*/
/* The following is excerpted from the control structures used by Opus 1.10 */
/* as it is currently implemented. The only part that really concerns BTCTL */
/* is that part of the _PRM structure that contains the version number and  */
/* the network address. Only those parts are actually handled by this code. */
/* We suspect that no changes will be made in that part of the structure    */
/* between now and the release of Opus 1.10. If I were you, I would make    */
/* no such assumptions about the rest.                                      */
/*--------------------------------------------------------------------------*/

#define  THIS_CTL_VERSION  16       /* PRM structure version number         */

#define CTLSIZE 1
#define OFS     char*

#define  MAX_EXTERN         8       /* max. number of external programs     */
#define  MAXCLASS          12       /* number of possible priv levels       */
#define  ALIAS_CNT         15       /* number of matrix addresses           */

/*--------------------------------------------------------------------------*/
/* FIDONET ADDRESS STRUCTURE                                                */
/*--------------------------------------------------------------------------*/
typedef struct _ADDRESS
   {
   word  Zone;
   word  Net;
   word  Node;
   word  Point;
   } ADDR;

/*--------------------------------------------------------------------------*/
/* Attributes of a given class of users                                     */
/*--------------------------------------------------------------------------*/
struct   class_rec
   {
   byte  ClassPriv;
   byte  class_fill;
   word   max_time;      /* max cume time per day         */
   word   max_call;      /* max time for one call         */
   word   max_dl;        /* max dl bytes per day          */
   word  ratio;         /* ul:dl ratio                   */
   word  min_baud;      /* speed needed for logon        */
   word  min_file_baud; /* speed needed for file xfer    */
   };

/*--------------------------------------------------------------------------*/
/* Registers to pass to a FOSSIL appendage                                  */
/*--------------------------------------------------------------------------*/
struct _FOSREGS
   {
   word  ax;
   word  bx;
   word  cx;
   word  dx;
   };

/*--------------------------------------------------------------------------*/
/* The format of the PRM file, VERSION 16                                   */
/*                                                                          */
/* THIS IS AN EXPLOSIVE STRUCTURE.  IT IS SUBJECT TO CHANGE WITH NO NOTICE. */
/*                                                                          */
/* Offsets to the following item(s) are guaranteed:                         */
/*                                                                          */
/*      byte   version;        /* OFFSET 0, all versions                    */
/*      byte   task_num;       /* OFFSET 1, 16+                             */
/*                                                                          */
/*--------------------------------------------------------------------------*/

struct _PRM
   {
               /*-----------------------------------------------------------*/
               /* DATA                                                      */
               /*-----------------------------------------------------------*/
         byte  version;        /* for safety                          STABLE*/
         byte  task_num;       /* for multi-tasking systems           STABLE*/
         ADDR  alias[ALIAS_CNT];

         byte  video;          /* 0=Dos, 1=Fossil 2=IBM                     */
         byte  testmode;       /* input from keyboard, not modem            */

         word  carrier_mask;
         word  handshake_mask;
         word  max_baud;       /* fastest speed we can use                  */
         word  com_port;       /* Com1=0, Com2=1, FF=keyboard               */

         byte  multitasker;    /* flag for DoubleDos (see below)            */
         byte  mailer_type;    /* 0=Opus, 1=load external, 2=call external  */

         byte  ModemFlag;      /* (See MODEM FLAG below)                    */
         byte  LogFlag;        /* (See LOG FLAG below)                      */

         byte  StyleFlag;      /* (See STYLE FLAG below)                    */
         byte  FWDflag;        /* Bits to control IN TRANSIT messages       */

         byte  Flags;          /* See "FLAGS" below                         */
         byte  Flags2;         /* See "FLAGS 2" below                       */

         byte  edit_exit;      /* ERRORLEVEL to use if Matrix area changed  */
         byte  exit_val;       /* ERRORLEVEL to use after caller            */

         byte  crashexit;      /* non-zero= ErrorLevel exit                 */
         byte  arc_exit;       /* ErrorLevel for after incomming ARCmail    */

         byte  echo_exit;      /* ERRORLEVEL for after inbound echomail     */
         byte  UDB_Flags;      /* User data base flags                      */

         word  min_baud;       /* minimum baud to get on-line               */
         word  color_baud;     /* min baud for graphics                     */
         word  date_style;     /* Used for FILES.BBS display                */

         byte  logon_priv;     /* Access level for new users                */
         byte  seenby_priv;    /* Min priv to see SEEN_BY line              */

         byte  ctla_priv;      /* Priv to see CONTROL-A lines in messages   */
         byte  FromFilePriv;   /* Priv. for doing message from file         */

         byte  AskPrivs[16];   /* Array of privs. for message attr ask's    */
         byte  AssumePrivs[16];/* Array of privs. for message attr assume's */

         word  logon_time;     /* time to give for logons                   */

         word  matrix_mask;
         
         word  MinNetBaud;     /* minimum baud rate for remote netmail      */
         word  MaxJanusBaud;   /* fastest baud to use Ianus                 */

         struct class_rec class[MAXCLASS];
         struct _FOSREGS FosRegs[10];

         word  F_Reward;       /* File upload time reward percentage        */

         word  last_area;      /* Highest msg area presumed to exist        */
         word  last_farea;     /* Highest file area presumed to exist       */

         word  PRM_FILL3[17];


               /*-----------------------------------------------------------*/
               /* OFFSETS                                                   */
               /*-----------------------------------------------------------*/

                               /*-------------------------------------------*/
                               /* MODEM COMMAND STRINGS                     */
                               /*-------------------------------------------*/
         OFS   MDM_Init;       /* modem initialization string               */
         OFS   MDM_PreDial;    /* modem dial command sent before number     */
         OFS   MDM_PostDial;   /* modem command sent after dialed number    */
         OFS   MDM_LookBusy;   /* mdm cmd to take modem off hook            */

                               /*-------------------------------------------*/
                               /* PRIMROSE PATHS                            */
                               /*-------------------------------------------*/
         OFS   misc_path;      /* path to BBS/GBS files                     */
         OFS   sys_path;       /* path to SYSTEM?.BBS files                 */
         OFS   temppath;       /* place to put temporary files              */
         OFS   net_info;       /* path to NODELIST files                    */
         OFS   mailpath;       /* place to put received netmail bundles     */
         OFS   filepath;       /* place to put received netmail files       */
         OFS   hold_area;      /* path to pending outbound matrix traffic   */

                               /*-------------------------------------------*/
                               /* DATA FILE NAMES                           */
                               /*-------------------------------------------*/
         OFS   user_file;      /* path/filename of User.Bbs                 */
         OFS   sched_name;     /* name of file with _sched array            */
         OFS   syl;            /* default system language file              */
         OFS   usl;            /* default user language file                */

                               /*-------------------------------------------*/
                               /* MISCELLANEOUS TEXT                        */
                               /*-------------------------------------------*/
         OFS   system_name;    /* board's name                              */
         OFS   sysop;          /* sysop's name                              */
         OFS   timeformat;
         OFS   dateformat;
         OFS   protocols[MAX_EXTERN]; /* external file protocol programs    */

                               /*-------------------------------------------*/
                               /* BBS/GBS SUPPORT FILES                     */
                               /*-------------------------------------------*/
         OFS   logo;           /* first file shown to a caller              */
         OFS   welcome;        /* shown after logon                         */
         OFS   newuser1;
         OFS   newuser2;
         OFS   rookie;

         OFS   HLP_Editor;     /* Intro to msg editor for novices.          */
         OFS   HLP_Replace;    /* Explain the Msg.Editor E)dit command      */
         OFS   HLP_Inquire;    /* Explain the Msg. I)nquire command         */
         OFS   HLP_Locate;     /* Explain the Files L)ocate command         */
         OFS   HLP_Contents;   /* Explain the Files C)ontents command       */
         OFS   HLP_OPed;       /* help file for the full-screen editor      */
         OFS   OUT_Leaving;    /* Bon Voyage                                */
         OFS   OUT_Return;     /* Welcome back from O)utside                */
         OFS   ERR_DayLimit;   /* Sorry, you've been on too long...         */
         OFS   ERR_TimeWarn;   /* warning about forced hangup               */
         OFS   ERR_TooSlow;    /* explains minimum logon baud rate          */
         OFS   ERR_XferBaud;   /* explains minimum file transfer baud rate  */
         OFS   LIST_MsgAreas;  /* dump file... used instead of Dir.Bbs      */
         OFS   LIST_FileAreas; /* dump file... used instead of Dir.Bbs      */
        
         OFS   FREQ_MyFiles;   /* file to send when FILES is file requested */
         OFS   FREQ_OKList;    /* list of files approved for file requests  */
         OFS   FREQ_About;     /* File Request: ABOUT file                  */

         OFS   OEC_Quotes;
         OFS   byebye;         /* file displayed at logoff                  */
         OFS   local_editor;   /* text editor to use in keyboard mode       */
         OFS   barricade;
         OFS   Files_BBS;      /* FILES.BBS filename override for CD ROM    */
         OFS   mailer;         /* full external mailer command              */
         OFS   common;         /* File with data common to all tasks        */

         OFS   OFS_Filler[13];

               /*-----------------------------------------------------------*/
               /* Log_Name must always be the last offset in this struct    */
               /* because Bbs_Init uses that symbol to flag the end of      */
               /* the offsets.                                              */
               /*-----------------------------------------------------------*/
         OFS   log_name;       /* name of the log file                      */


               /*-----------------------------------------------------------*/
               /* Big blob of stuff                                         */
               /* It's a sequence of null-terminated character arrays...    */
               /* pointed-to by the offsets (above).                        */
               /*-----------------------------------------------------------*/
         char  buf[CTLSIZE];
   };

/* Stuff used later on here */

void           main (void);
void           errxit (char *);
char           *fancy_str (char *);
char           *add_backslash (char *);
char           *delete_backslash (char *);
char           *ctl_string (char *);
char           *ctl_slash_string (char *);
char           *skip_blanks (char *);
void            parse_config (char *);
void            b_initvars (void);
void            b_defaultvars (void);
int             parse (char *, struct parse_list *);

char           *BTCTL_ANN = "BTCtl - Revision 2.40\n\n";
char           *config_name = "Binkley.Cfg";
char           *BINKpath = NULL;
int             pvtnet = 0;
int             net_params = 0;
int             Zone = 1;

/*--------------------------------------------------------------------------*/
/* BTCTL                                                                    */
/* Parse the BINKLEY.CFG file and write out a BINKLEY.PRM file (for use by  */
/* OMMM) and a MAIL.SYS file (for use by FASTTOSS, SCANMAIL, SIRIUS, etc).  */
/* If the environment variable BINKLEY exists use the path specified for    */
/* ALL input and output files.                                              */
/*--------------------------------------------------------------------------*/

/*--------------------------------------------------------------------------*/
/* MAIL.SYS file structure                                                  */
/*--------------------------------------------------------------------------*/
struct _mail
{
word             pri_node;       /* Our node number                          */
float           fudge;          /* Unknown/unused                           */
word             rate;           /* Maximum baud rate                        */
char            mailpath[80];   /* Path for incomming messages              */
char            filepath[80];   /* Path for incomming files                 */
word             pri_net;        /* Our network number                       */
word             alt_node;       /* Alternate node number (mainly for HOSTS) */
word             alt_net;        /* Alternate net number (mainly for HOSTS)  */
};

struct _mail    mailsys;        /* MAIL.SYS used by SIRIUS  */
struct _PRM     ctl;            /* where the .CTL stuff is  */

int             num_addrs = 0;

void main ()
{
   char           *envptr;
   FILE           *stream;
   char            temp[80];
   char           *skip_blanks ();
   struct stat     statbuf;
   int             k;

   printf (BTCTL_ANN);

   b_initvars ();

   envptr = getenv ("BINKLEY");                  /* get path from environment */
   if ((envptr != NULL)                          /* If there was one, and     */
       && (stat (config_name,&statbuf) != 0))    /* No BINKLEY.CFG locally,   */
      {
      BINKpath = malloc (strlen (envptr) + 2);   /* make room for new */
      strcpy (BINKpath, envptr);                 /* use BINKLEY as our path   */
      add_backslash (BINKpath);
      }

   parse_config ("Binkley.Evt");
   parse_config (config_name);

   b_defaultvars ();

   /*
    * Print out what we got.
    */

   if (ctl.system_name != NULL)
      printf ("System: %s\n",ctl.system_name);

   if (ctl.sysop != NULL)
      printf ("Sysop:  %s\n",ctl.sysop);

   for (k = 0; k < ALIAS_CNT; k++)               /* And the alias list        */
      {
      if (!ctl.alias[k].Zone)
         break;
      printf ("Address %u:%u/%u.%u\n",
               ctl.alias[k].Zone,
               ctl.alias[k].Net,
               ctl.alias[k].Node,
               ctl.alias[k].Point);
      }

   if (ctl.mailpath != NULL)
      printf ("Net Mailpath %s\n",ctl.mailpath);

   if (ctl.filepath != NULL)
      printf ("Net Filepath %s\n",ctl.filepath);

   printf ("\n");

   if (!net_params)
      errxit ("Not enough information to establish Netmail session");

   /*
    * Okay, we have the nodelist data from the BINKLEY.CFG file.
    * Now write it into a BINKLEY.PRM file.
    */

   if (BINKpath != NULL)                         /* If there was a BINKLEY,   */
      {
      strcpy (temp, BINKpath);                   /* use it here too           */
      }
   else
      temp[0] = '\0';
   strcat (temp, "Binkley.Prm");                 /* add in the file name      */

   if ((stream = fopen (temp, write_binary)) == NULL)    /* OK, let's open the file   */
      errxit ("Unable to open BINKLEY.PRM");
   if (fwrite (&ctl, sizeof (ctl), 1, stream) != 1) /* Try to write data out  */
      errxit ("Could not write control file data to BINKLEY.PRM");
   fclose (stream);                              /* close output file         */
   printf ("Version 16 Control file successfully written\n");
   printf ("oMMM 1.30 or above is required to use it\n\n");

   /*
    * BINKLEY.PRM now written. Let's write a MAIL.SYS file too.
    */

   mailsys.pri_node = ctl.alias[0].Node;
   mailsys.pri_net  = ctl.alias[0].Net;
   mailsys.alt_node = ctl.alias[1].Node;
   mailsys.alt_net  = ctl.alias[1].Net;
   strcpy (mailsys.mailpath, ctl.mailpath);
   strcpy (mailsys.filepath, ctl.filepath);

   if (BINKpath != NULL)                         /* If there was a BINKLEY,   */
      {
      strcpy (temp, BINKpath);                   /* use it here too           */
      }
   else
      temp[0] = '\0';
   strcat (temp, "Mail.Sys");                    /* add in the file name      */

   if ((stream = fopen (temp, write_binary)) == NULL)    /* OK, let's open the file   */
      errxit ("Could not open MAIL.SYS");        /* no file, no work to do    */
   if (fwrite (&mailsys, sizeof (mailsys), 1, stream) != 1)
      errxit ("Unable to write data to MAIL.SYS");  /* Try to write data out  */
   fclose (stream);                              /* close output file         */
   printf ("MAIL.SYS file successfully written\n"); /* Notify user of success */
}

/**
 ** b_initvars -- called before parse_config. Sets defaults that we want
 ** to have set FIRST.
 **/


void b_initvars ()
{
   int k;

   ctl.version = 16;
   for (k = 0; k < ALIAS_CNT; k++)               /* And the alias list        */
      {
      ctl.alias[k].Zone = ctl.alias[k].Net = 
      ctl.alias[k].Node = ctl.alias[k].Point = 0;
      }

   ctl.alias[0].Zone = 1;                        /* Make sure we have a zone  */
   ctl.alias[0].Net = ctl.alias[0].Node = -1;    /* Default Fidonet address   */
   ctl.alias[0].Point = 0;

   ctl.system_name = ctl.sysop = 
   ctl.hold_area = ctl.mailpath = ctl.filepath = NULL;
}

/**
 ** b_defaultvars -- called after all parse_config passes complete.
 ** sets anything not handled by parse_config to default if we know it.
 **/


void b_defaultvars ()
{
   /* Set up "point" address correctly if we can */
   
   if (ctl.alias[0].Point)
      {
      ctl.alias[0].Net   = pvtnet;
      ctl.alias[0].Node  = ctl.alias[0].Point;
      ctl.alias[0].Point = 0;
      }

   /* If we have the minimum information to do netmail, set the flag */

   if ((ctl.alias[0].Zone  != 0)
   &&  (ctl.alias[0].Net   != 0)
   &&  (ctl.system_name    != NULL)
   &&  (ctl.sysop          != NULL)
   &&  (ctl.hold_area      != NULL)
   &&  (ctl.filepath       != NULL)
   &&  (ctl.mailpath       != NULL))
      net_params = 1;
}


struct parse_list config_lines[] = {
                                    {4,  "Zone"},
                                    {6,  "System"},
                                    {5,  "Sysop"},
                                    {4,  "Boss"},
                                    {5,  "Point"},
                                    {3,  "Aka"},
                                    {7,  "Address"},
                                    {4,  "Hold"},
                                    {7,  "NetFile"},
                                    {7,  "NetMail"},
                                    {7,  "Include"},
                                    {10, "PrivateNet"},
                                    {0, NULL}
};


void parse_config (config_file)
char *config_file;
{
   FILE *stream;
   char temp[256];
   char *c;
   int i;
   int boss_net = 0;
   int boss_node = 0;

   if (BINKpath != NULL)
      sprintf (temp, "%s%s", BINKpath, config_file);
   else
      strcpy (temp, config_file);

   if ((stream = fopen (temp, read_ascii)) == NULL)    /* OK, let's open the file   */
      return;                                    /* no file, no work to do    */

   while ((fgets (temp, 255, stream)) != NULL)   /* Now we parse the file ... */
      {
      c = temp;                                  /* Check out the first char  */
      if ((*c == '%') || (*c == ';'))            /* See if it's a comment
                                                  * line */
         continue;

      i = (int) strlen (temp);                         /* how long this line is     */

      if (i < 3)
         continue;                               /* If too short, ignore it   */

      c = &temp[--i];                            /* point at last character   */
      if (*c == '\n')                            /* if it's a newline,        */
         *c = '\0';                              /* strip it off              */

      switch (parse (temp, config_lines))
         {
         case 1:                                /* "Zone"         */
            c = skip_blanks (&temp[4]);
            Zone = atoi (c);
            if (!Zone)                          /* if we didn't find a zone  */
               printf ("Illegal zone: %s\n", &temp[4]);
            break;

         case 2:                                /* "System"       */
            ctl.system_name = ctl_string (&temp[6]);
            break;

         case 3:                                /* "Sysop"        */
            ctl.sysop = ctl_string (&temp[5]);
            break;

         case 4:                                /* "Boss"         */
            c = skip_blanks (&temp[4]);
            sscanf (c, "%d/%d", &boss_net, &boss_node);
            if (boss_net)
               pvtnet = boss_net;
            break;

         case 5:                                /* "Point"        */
            i = 5;
            goto address;

         case 6:                                /* "Aka"          */
            i = 3;
            goto address;

         case 7:                                /* "Address"      */
            i = 7;
address:
            ctl.alias[num_addrs].Point = 0;
            c = skip_blanks (&temp[i]);
            i = sscanf (c, "%hd:%hd/%hd.%hd",
                       &ctl.alias[num_addrs].Zone,
                       &ctl.alias[num_addrs].Net,
                       &ctl.alias[num_addrs].Node,
                       &ctl.alias[num_addrs].Point);
            if (i < 3)
               {
               i = sscanf (c, "%hd/%hd.%hd", 
                          &ctl.alias[num_addrs].Net,
                          &ctl.alias[num_addrs].Node,
                          &ctl.alias[num_addrs].Point);
               if (i < 2)
                   break;
               ctl.alias[num_addrs].Zone = Zone;
               }
            Zone = ctl.alias[0].Zone;           /* First is real default */
            ++num_addrs;
            break;

         case 8:                               /* "Hold"         */
            ctl.hold_area = ctl_slash_string (&temp[4]);
            break;

         case 9:                               /* "NetFile"      */
            ctl.filepath = ctl_slash_string (&temp[7]);
            break;

         case 10:                              /* "NetMail"      */
            ctl.mailpath = ctl_slash_string (&temp[7]);
            break;

         case 11:                               /* "Include"      */
            c = skip_blanks (&temp[7]);
            parse_config (c);
            break;

         case 12:                               /* "PrivateNet"   */
            c = skip_blanks (&temp[10]);
            pvtnet = atoi (c);
            break;

         default:
            break;
         }
      }
   fclose (stream);                              /* close input file          */

}

int parse (input, list)
char *input;
struct parse_list list[];

{
   int i;

   for (i = 0; list[i].p_length; i++)
      {
      if (strnicmp (input, list[i].p_string, list[i].p_length) == 0)
         return (++i);
      }
   return (-1);
}

void errxit (error)
char           *error;
{
   printf ("\r\n%s\n", error);
   exit (0);
}

char *fancy_str (string)
char *string;
{
   register int flag = 0;
   char *s;

   s = string;

   while (*string)
      {
      if (isalpha (*string))                     /* If alphabetic,     */
         {
         if (flag)                               /* already saw one?   */
            *string = tolower (*string);         /* Yes, lowercase it  */
         else
            {
            flag = 1;                            /* first one, flag it */
            *string = toupper (*string);         /* Uppercase it       */
            }
         }
      else /* if not alphabetic  */ flag = 0;    /* reset alpha flag   */
      string++;
      }

   return (s);
}

char *add_backslash (str)
char           *str;
{
   char           *p;

   p = str + strlen (str) - 1;

   /* Strip off the trailing blanks */
   while ((p >= str) && (isspace (*p)))
      {
      *p = '\0';
      --p;
      }

   /* Put a backslash if there isn't one */
   if ((*p != '\\') && (*p != '/'))
      {
      *(++p) = '\\';
      *(++p) = '\0';
      }

   return (fancy_str (str));
}

char *delete_backslash (str)
char           *str;
{
   char           *p;

   p = str + strlen (str) - 1;

   if (p >= str)
      {
      /* Strip off the trailing blanks */
      while ((p >= str) && (isspace (*p)))
         {
         *p = '\0';
         --p;
         }

      /* Get rid of backslash if there is one */
      if ((p >=str) && ((*p == '\\') || (*p == '/')))
         {
         if ((p > str) && (*(p-1) != ':'))      /* Don't delete on root */
            *p = '\0';
         }
      }

   return (fancy_str (str));
}
char           *ctl_string (source)             /* malloc & copy to ctl      */
char           *source;
{
   char           *dest, *c;

   c = skip_blanks (source);    /* get over the blanks       */
   dest = malloc (strlen (c) + 1);      /* allocate space for string */
   strcpy (dest, c);            /* copy the stuff over       */
   return (dest);               /* and return the address    */
}

char           *ctl_slash_string (source)       /* malloc & copy to ctl      */
char *source;
{
   char *dest, *c;
   size_t i;
   struct stat buffer;

   c = skip_blanks (source);                    /* get over the blanks       */
   i = strlen (c);                              /* get length of remainder   */
   if (i < 1)                                   /* must have at least 1      */
      return (NULL);                            /* if not, return NULL       */
   dest = malloc (i+2);                      	/* allocate space for string */
   strcpy (dest, c);                            /* copy the stuff over       */
   delete_backslash (dest);                     /* get rid of trailing stuff */
   /* Check to see if the directory exists */
   if (stat (dest, &buffer) || (!(buffer.st_mode & S_IFDIR)))
      {
      printf ("Directory '%s' does not exist!\n", dest);
      printf ("  BinkleyTerm may fail to execute properly because of this!\n");
      return(NULL);
      }
   add_backslash (dest);                         /* add the backslash         */
   return (dest);                                /* return the directory name */
}

char           *skip_blanks (string)
char           *string;
{
   while (*string == ' ' || *string == '\t')
      ++string;
   return (string);
}
