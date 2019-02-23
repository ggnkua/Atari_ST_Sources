/*......................... include header files .............................*/

#include "osbind.h"

/*....................... define commands and macros .........................*/

#define BADCMD  0
#define LOAD    1	
#define SAVE    2
#define ERASE   3
#define HELP    4
#define LIST    5
#define CLOAD   6
#define CSAVE   7
#define CHANNEL 8
#define PATCH   9

#define TOKEMACRO  if (tokeflag) token2[tokex++]=c; else token1[tokex++]=c

/*........................... global variables ...............................*/

char cmdline[82];             /* command line before parsing */
char token1[80],token2[80];   /* parsed command line */
char filebuf[50000];          /* contains MIDI data */
int  casioflg;                /* if set, do_save() and do_load() try to
                                 handshake with Casio */

   /* Casio handshaking command strings */
char czmess1[7] = {0xF0,0x44,0x00,0x00,0x70,0x10,0x00};
char czmess2[2] = {0x70,0x31};
char czmess3[7] = {0xF0,0x44,0x00,0x00,0x70,0x20,0x00};

typedef struct dta
{
   char stuff[21];
   char fileattr;
   int  filetime;
   int  filedate;
   long filesize;
   char filename[14];
} DTA,*DTAPTR;

/*............................. main program .................................*/

main()
{
   register int cmd=HELP;        /* start with list of available commands */

   while (1)                     /* loop until ctrl-c */
   {
      switch (cmd)
      {
         case BADCMD:
            do_badcmd();
            break;
         case LOAD:
            casioflg=0;       /* no handshaking in do_load() */
            do_load();
            break;
         case SAVE:
            casioflg=0;       /* no handshaking in do_save() */
            do_save();
            break;
         case CLOAD:
            casioflg=1;       /* handshaking in do_load() */
            do_load();
            break;
         case CSAVE:
            casioflg=1;       /* handshaking in do_save() */
            do_save();
            break;
         case PATCH:
            do_patch();
            break;
         case CHANNEL:
            do_channel();
            break;
         case ERASE:
            do_erase();
            break;
         case HELP:
            do_help();
            break;
         case LIST:
            do_list();
      }
      cmd= getcmd();
   } 
} /* end main() */

/*.................... input and parse a command line ........................*/

/* returns one of BADCMD,HELP,LOAD,SAVE,CLOAD,CSAVE,ERASE,LIST,PATCH,CHANNEL */
getcmd()       
{
   register int i;

   for (i=0; i<=81; i++) cmdline[i]=0;     /* fill command line with nulls */

   do
   {
      Cconws("\r\n\n>");      /* prompt */
      cmdline[0]= 80;
      Cconrs(cmdline);
   }
   while (!cmdline[1]);     /* if null command, re-prompt */
   
   lc_to_uc(&cmdline[2]);        /* convert lower case to upper case */
   parse(&cmdline[2]);
   if (!strcmp(token1,"HELP" ))    return(HELP);
   if (!strcmp(token1,"LOAD" ))    return(LOAD);
   if (!strcmp(token1,"SAVE" ))    return(SAVE);
   if (!strcmp(token1,"CLOAD"))    return(CLOAD);
   if (!strcmp(token1,"CSAVE"))    return(CSAVE);
   if (!strcmp(token1,"ERASE"))    return(ERASE);
   if (!strcmp(token1,"LIST" ))    return(LIST);
   if (!strcmp(token1,"PATCH" ))   return(PATCH);
   if (!strcmp(token1,"CHANNEL" )) return(CHANNEL);
   return(BADCMD);
} /* end getcmd() */

/*................... convert lower case to upper case .......................*/

lc_to_uc(s)
char s[];
{
   register int i=0;
   register char c;

   while (c=s[i])
   {
      if ((c>='a')&&(c<='z')) s[i]= c-'a'+'A';
      i++;
   }
} /* end lc_to_uc(s) */
      
/*.............. parse command line into one or two tokens ...................*/

parse(s)
char s[];
{
   register int i=0, charflag=0, tokex=0,  tokeflag=0;
   register char c;

   for (i=0; i<=79; i++) token1[i]=0;     /* fill tokens with nulls */
   for (i=0; i<=79; i++) token2[i]=0;     

   i=0;
   while (  (c=s[i++]) && (i<80)   )
   {
      if (charflag)         /* we are collecting a token */
      {
         if (c!=' ')        /* we've encountered another character */
         {
            TOKEMACRO;
         }
         else               /* we've come to end of a token */
         {
            c=0; TOKEMACRO;           /* append null to token */
            if (tokeflag++) return;   /* return at end of second token */
            tokex= charflag= 0;
         }
      }
      else                  /* we are waiting for a character */
      {
         if (c!=' ')        /* we've encountered the first character */
         {
            TOKEMACRO;
            charflag=1;
         }            
      } /* end if (charflag) */
   } /* end while (  (c=s[i++]) && (i<80)   ) */
} /* end parse(s) */

/*........................... load a file ....................................*/

do_load()
{
   register long error,fileleng;
   register int filehand,filelng;
   DTAPTR dtaaddr;
   DTA tempdta;

   if (!token2[0])
   {
      Cconws("\n\rError:  Missing file name.");
      return;
   }
   error= Fopen(token2,0);       /* try to open file */
   if (error<0L)                 /* if could not open file */
   {    
      Cconws("\n\rError: Cannot open file.");
      return;
   }
   filehand= error;        
   if (Fsfirst(token2,0)) 
   {
      Cconws("\n\rError: Cannot find file.");      
      goto exit;
   }
   dtaaddr=Fgetdta();
   tempdta= *dtaaddr;
   fileleng= tempdta.filesize;
   if (fileleng>50000)
   {
      Cconws("\n\rError: File longer than 50000 bytes.");
      goto exit;
   }
   if (   Fread(filehand,fileleng,filebuf) != fileleng)
   {
      Cconws("\n\rFile read error.");
      goto exit;
   }
   filelng=fileleng-1;     /* # bytes -1 for Midiws */

   if (casioflg) Midiws(6,czmess3);   /* handshaking stuff */
   Midiws(filelng,filebuf);   /* send over MIDI */

exit:
   Fclose(filehand);          /* close file */
} /* end do_load() */

/*........................... save a file ....................................*/

do_save()
{
   register long error,fileleng;
   register int filehand;
   long receive();
   
   if (!token2[0])
   {
      Cconws("\n\rError:  Missing file name.");
      return;
   }
   
   error= Fopen(token2,0);        /* try to open file */
   if (error<0L)                  /* if could not open file */
   {
      error= Fcreate(token2,0);   /* try to create the file */
      if (error<0L)               /* if could not create file */
      {
        Cconws("\n\rError: Cannot create file.");
        return;
      }
      filehand=error;
   }
   else
   {
      Cconws("\n\rError: File already exists.");
      filehand=error;
      goto good_exit;
   }

   if (casioflg)
   {
      fileleng= c_receive();
      if (fileleng!=256)
      {
         Cconws("\n\rIncorrect or no response from Casio.");
         goto bad_exit;
      }
   }
   else
   {
      Cconws("\n\rWaiting for MIDI data; type any key to abort... ");
      if (   !(fileleng=receive())   )
      {
         Cconws("\n\rSave command aborted.");
         goto bad_exit;
      }
      if (fileleng==50000L)
      {
         Cconws("\n\rError: Buffer overflow.");
         goto bad_exit;
      }
   }
    
   if (Fwrite(filehand,fileleng,filebuf)!=fileleng)
   {
      Cconws("\n\rError: Cannot write file.");
      goto bad_exit;
   }
   
   goto good_exit;            /* successful */
   
bad_exit:
      Fdelete(token2);
good_exit:
      Fclose(filehand);       /* close file */
} /* end do_save() */

/*...................... set midi channel for Casio ..........................*/

do_channel()
{
   register int midichan;

   if (!token2[0])
   {
      Cconws("\n\rError:  Missing channel.");
      return;
   }
   midichan= atoi(token2);
   if ((midichan<1)||(midichan>16))
      Cconws("\n\rError:  MIDI channel must be 1-16.");
   else
   {
      midichan--;   /* midi channels are actually 0-15; not 1-16 */
      czmess1[4]= (czmess1[4] & 0xF0) | midichan;
      czmess2[0]= (czmess2[0] & 0xF0) | midichan;
      czmess3[4]= (czmess3[4] & 0xF0) | midichan;
   }

} /* end do_channel() */

/*......................... set patch number for Casio .......................*/

do_patch()
{
   register int patchnum;

   if (!token2[0])
   {
      Cconws("\n\rError:  Missing patch number.");
      return;
   }
   patchnum= atoi(token2);
   if ((patchnum<0)||(patchnum>99)) 
      Cconws("\n\rError:  Patch must be 1-99.");
   else
   {
      czmess1[6]= patchnum;
      czmess3[6]= patchnum;
   }

} /* end do_patch() */

/*............................ erase a file ..................................*/

do_erase()
{
   if (!token2[0])
   {
      Cconws("\n\rError:  Missing file name.");
      return;
   }
   if (Fdelete(token2)) Cconws("\n\rError: Cannot erase file.");
} /* end do_erase() */

/*................................... help ...................................*/

do_help()
{
   Cconws("\n\rMIDISAVE commands are:");
   Cconws("\n\r   HELP             -- displays this list.");
   Cconws("\n\r   LOAD filename    -- transmits from disk file to non-Casio.");
   Cconws("\n\r   SAVE filename    -- receives from non-Casio to disk file.");
   Cconws("\n\r   CLOAD filename   -- transmits from disk file to Casio.");
   Cconws("\n\r   CSAVE filename   -- receives from Casio to disk file.");
   Cconws("\n\r   ERASE filename   -- erases a disk file.");
   Cconws("\n\r   LIST (filename)  -- lists (part of) disk directory.");
   Cconws("\n\r   CHANNEL n        -- select MIDI channel for Casio.");
   Cconws("\n\r   PATCH n          -- select patch number for Casio.");
   Cconws("\n\r   <CTRL-C>         -- exits program.");
} /* end do_help() */

/*................................ bad command ...............................*/

do_badcmd()
{
   Cconws("\n\rUnrecognizable Command.");
} /* end do_badcmd() */

/*........................... list command ...................................*/

do_list()
{
   char *nameptr;

   if (!token2[0]) strcpy(token2,"*.*");

   if (Fsfirst(token2,0)) 
   {
      Cconws("\n\rNo files found.");
      return;
   }
   nameptr=Fgetdta();
   Cconws("\n\rDisk Directory (");
   Cconws(token2);
   Cconws("):");
   Cconws("\n\n\r");
   Cconws("   "); Cconws(nameptr+30);
   while (!Fsnext())
   {
      Cconws("\n\r");
      Cconws("   "); Cconws(nameptr+30);
   }
} /* end do_list() */

