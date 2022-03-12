/*
   GEM-DEU, by Anthony Jacques.

   Doom Editor Utility, by Brendon Wyber and Rapha‰l Quinet.

   You are allowed to use any parts of this code in another program, as
   long as you give credits to the authors in the documentation and in
   the program itself.  Read the file README.1ST for more information.

   This program comes with absolutely no warranty.

   DEU.C - Main program execution routines.
*/

/* the includes */
#include "gem-deu.h"
#include "deu.h"
#include <time.h>
#include <string.h>

/* global variables */

FILE *logfile = NULL;		/* filepointer to the error log */
Bool NoRegisteredChecks = TRUE; /* Dont set this one to TRUE! ID will not like you... */
Bool Registered = FALSE;	/* registered or shareware game? */
Bool Debug = TRUE;		/* are we debugging? */
Bool SwapButtons = FALSE;	/* swap right and middle mouse buttons */
Bool Quiet = FALSE;		/* don't play a sound when an object is selected */
Bool Quieter = FALSE;		/* don't play any sound, even when an error occurs */
Bool Expert = FALSE;		/* don't ask for confirmation for some operations */
char *CfgFile = DEU_CONFIG_FILE;/* name of the configuration file */
short InitialScale = 8;		/* initial zoom factor for map */
short  VideoMode = 2;		/* default video mode for VESA/SuperVGA */
char *BGIDriver = "VESA";	/* default extended BGI driver */
Bool FakeCursor = FALSE;	/* use a "fake" mouse cursor */
Bool CirrusCursor = FALSE;	/* use hardware cursor on Cirrus Logic VGA cards */
Bool Colour2 = FALSE;		/* use the alternate set for things colors */
Bool InfoShown = TRUE;		/* should we display the info bar? */
Bool AdditiveSelBox = FALSE;	/* additive selection box or select in box only? */
short SplitFactor = 8;		/* factor used by the Nodes builder */
char *DefaultWallTexture  = "GRAY4";	/* default normal wall texture */
char *DefaultUpperTexture = "ICKWALL2";	/* default upper wall texture */
char *DefaultLowerTexture = "GRAY1";	/* default lower wall texture */
char *DefaultFloorTexture = "FLOOR0_3";	/* default floor texture */
char *DefaultCeilingTexture = "FLAT18";	/* default ceiling texture */
short DefaultFloorHeight   = 0;		/* default floor height */
short  DefaultCeilingHeight = 128;	/* default ceiling height */
Bool Select0 = TRUE;		/* select object 0 by default when switching modes */
Bool Reminder = TRUE;		/* display a funny message when DEU starts */
char *MainWad = "DOOM.WAD";	/* name of the main wad file */
char **PatchWads = NULL;	/* list of patch wad files */
OptDesc options[] =		/* description of the command line options */
{
/*   short & long names   type            message if true/changed       message if false              where to store the value */
   { "d",  "debug",       OPT_BOOLEAN,    "Debug mode ON",		"Debug mode OFF",             &Debug          },
   { "q",  "quiet",       OPT_BOOLEAN,    "Quiet mode ON",		"Quiet mode OFF",             &Quiet          },
   { "qq", "quieter",     OPT_BOOLEAN,    "Quieter mode ON",		"Quieter mode OFF",           &Quieter        },
   { "e",  "expert",      OPT_BOOLEAN,    "Expert mode ON",		"Expert mode OFF",            &Expert         },
   { "sb", "swapbuttons", OPT_BOOLEAN,    "Mouse buttons swapped",	"Mouse buttons restored",     &SwapButtons    },
   { "w",  "main",        OPT_STRING,     "Main WAD file",		NULL,                         &MainWad        },
   { NULL, "file",        OPT_STRINGLIST, "Patch WAD file",		NULL,                         &PatchWads      },
   { "pw", "pwad",        OPT_STRINGACC,  "Patch WAD file",		NULL,                         &PatchWads      },
   { NULL, "config",      OPT_STRING,     "Config file",		NULL,                         &CfgFile        },
   { "z",  "zoom",        OPT_INTEGER,    "Initial zoom factor",	NULL,                         &InitialScale   },
   { "c",  "color2",      OPT_BOOLEAN,    "Alternate Things color set",	"Normal Things color set",    &Colour2        },
   { "i",  "infobar",     OPT_BOOLEAN,    "Info bar shown",		"Info bar hidden",            &InfoShown      },
   { "a",  "addselbox",   OPT_BOOLEAN,    "Additive selection box",	"Select objects in box only", &AdditiveSelBox },
   { "sf", "splitfactor", OPT_INTEGER,    "Split factor",		NULL,			      &SplitFactor    },
   { NULL, "walltexture", OPT_STRING,     "Default wall texture",	NULL,                         &DefaultWallTexture    },
   { NULL, "lowertexture",OPT_STRING,     "Default lower wall texture",	NULL,                         &DefaultLowerTexture   },
   { NULL, "uppertexture",OPT_STRING,     "Default upper wall texture",	NULL,                         &DefaultUpperTexture   },
   { NULL, "floortexture",OPT_STRING,     "Default floor texture",	NULL,                         &DefaultFloorTexture   },
   { NULL, "ceiltexture", OPT_STRING,     "Default ceiling texture",	NULL,                         &DefaultCeilingTexture },
   { NULL, "floorheight", OPT_INTEGER,    "Default floor height",	NULL,			      &DefaultFloorHeight    },
   { NULL, "ceilheight",  OPT_INTEGER,    "Default ceiling height",	NULL,			      &DefaultCeilingHeight  },
   { "s0", "select0",     OPT_BOOLEAN,    "Select 0 by default",	"No default selection",	      &Select0,	      },
   { NULL, "noregisterchecks",OPT_BOOLEAN,"ID dont like you...",    NULL,  &NoRegisteredChecks,},
   { NULL, "reminder1",   OPT_BOOLEAN,	  NULL,				NULL,			      &Reminder,      },
   { NULL, NULL,          OPT_END,        NULL,				NULL,                         NULL            }
};


short msgbuf[20];
short workstation;
short apid;
short work_in[11];
short work_out[57];
OBJECT *menu;

/*
** the main program
*/
int main( int argc, char *argv[])
{
 short i,dummy;


 /* Initialise the AES and VDI */
 appl_init();
 if (_AESglobal[0]>0x400)
    {
     menu_register(apid,"  GEM-DEU 0.1");
     shel_write(9,1,0,0,0); /* Yes, can recieve AP_TERM */
    }

 workstation=graf_handle(&dummy,&dummy,&dummy,&dummy);
 for (i = 0; i < 10; i++) work_in[i] = 1;
 work_in[7] = 0;
 work_in[10] = 2;
 v_opnvwk(work_in, &workstation, work_out);

 rsrc_load("gem-deu.rsc");
 graf_mouse(0, 0);

 argv++;
 argc--;
 /* InitSwap must be called before any call to GetMemory(), etc. */
 InitSwap();
 /* quick and dirty check for a "-config" option */
 for (i = 0; i < argc - 1; i++)
      if (!strcmp( argv[ i], "-config"))
         {
          CfgFile = argv[ i + 1];
          break;
         }
 /* read config file and command line options */
 ParseConfigFileOptions( CfgFile);
 ParseCommandLineOptions( argc, argv);
 if (Debug == TRUE)
    {
     logfile = fopen( DEU_LOG_FILE, "a");
     if (logfile == NULL)
         form_alert(1,"[2][Warning, could not |open .LOG file.][ OK ]");

     LogMessage(": Welcome to DEU!\n");
    }
 if (Quieter == TRUE) Quiet = TRUE;
 if (Reminder == TRUE) FunnyMessage( stdout);

 /* load the wad files */
 OpenMainWad( MainWad); 
 if (PatchWads)
     while (PatchWads[ 0])
       {
        OpenPatchWad( strupr( PatchWads[ 0]));
        PatchWads++;
       }

 /* sanity check */
 CloseUnusedWadFiles();

 /* all systems go! */
 MainLoop();

 /* tell the AES and VDI that we have finished. */
 v_clsvwk(workstation);
 appl_exit();

 /* that's all, folks! */
 CloseWadFiles();
 LogMessage( ": The end!\n\n\n");
 if (logfile != NULL)
     fclose( logfile);
 return 0;
}

/*
** Convert moto/intel SHORT
*/
void fixword(short *pcword)
{
 short tmp;

 tmp = *pcword;
 *pcword = ((tmp & 0xff) << 8) + ((tmp >> 8) & 0xff);
}


/*
** Convert moto/intel LONG
*/
void fixlong(long *pclong)
{
 long tmp;

 tmp = *pclong;
 *pclong = ((tmp & 0xff) << 24) + (((tmp >> 8) & 0xff) << 16) +
            (((tmp >> 16) & 0xff) << 8) + ((tmp >> 24) & 0xff);
}

/*
** Get keyboard input. Emulation of PC BIOSKEY function.
*/
char bioskey(short n)
{
 if (!n) return getch();
    else return 0;
}


char *objc_text(OBJECT *tree, short index)
{
 switch (tree[index].ob_type & 0xff)
   {
    case G_STRING: /* For all object types whose ob_specs point to a */
    case G_BUTTON: /* string, do this... */
         return (char *)(tree[index].ob_spec);
    case G_TEXT:    /* Ditto, for anything that has an ob_spec which */
    case G_BOXTEXT: /* points to a TEDINFO structure, do this... */
    case G_FTEXT:
    case G_FBOXTEXT:
         return ((TEDINFO *)(tree[index].ob_spec))->te_ptext;
   }
 return NULL;
}

void objc_newtext(OBJECT *tree, short index, char *text)
{
    char *s;

    s = objc_text(tree, index);
    if (s)
        strcpy(s, text);
}

/*
** Append a string to a null-terminated string list
*/
void AppendItemToList( char ***list, char *item)
{
 short i;

 i = 0;
 if (*list != NULL)
    {
     /* count the number of elements in the list (last = null) */
     while ((*list)[ i] != NULL)
	        i++;
     /* expand the list */
     *list = ResizeMemory( *list, (i + 2) * sizeof( char **));
    }
   else
    {
     /* create a new list */
     *list = GetMemory( 2 * sizeof( char **));
    }
 /* append the new element */
 (*list)[ i] = item;
 (*list)[ i + 1] = NULL;
}



/*
   Handle command line options
*/

void ParseCommandLineOptions( int argc, char *argv[])
{
 short optnum;

 while (argc > 0)
   {
    if (argv[ 0][ 0] != '-' && argv[ 0][ 0] != '+')
        ProgError( "options must start with '-' or '+'");
    if (!strcmp( argv[ 0], "-?") || !stricmp( argv[ 0], "-h") || !stricmp( argv[ 0], "-help"))
       {
	    exit( 0);
       }
    for (optnum = 0; options[ optnum].opt_type != OPT_END; optnum++)
       {
        if (!stricmp( &(argv[ 0][ 1]), options[ optnum].short_name) || !stricmp( &(argv[ 0][ 1]), options[ optnum].long_name))
           {
            switch (options[ optnum].opt_type)
               {
                case OPT_BOOLEAN:
                     if (argv[ 0][ 0] == '-')
                        {
                         *((Bool *) (options[ optnum].data_ptr)) = TRUE;
                         if (options[ optnum].msg_if_true)
                            printf("%s.\n", options[ optnum].msg_if_true);
                        }
                       else
                        {
                         *((Bool *) (options[ optnum].data_ptr)) = FALSE;
                         if (options[ optnum].msg_if_false)
                         printf("%s.\n", options[ optnum].msg_if_false);
                        }
                     break;
                case OPT_INTEGER:
                     if (argc <= 1)
                     ProgError( "missing argument after \"%s\"", argv[ 0]);
                     argv++;
                     argc--;
                     *((short *) (options[ optnum].data_ptr)) = atoi( argv[ 0]);
                     if (options[ optnum].msg_if_true)
                         printf("%s: %d.\n", options[ optnum].msg_if_true, atoi( argv[ 0]));
                     break;
                case OPT_STRING:
                     if (argc <= 1)
                         ProgError( "missing argument after \"%s\"", argv[ 0]);
                     argv++;
                     argc--;
                     *((char **) (options[ optnum].data_ptr)) = argv[ 0];
                     if (options[ optnum].msg_if_true)
                         printf("%s: %s.\n", options[ optnum].msg_if_true, argv[ 0]);
                     break;
                case OPT_STRINGACC:
                     if (argc <= 1)
                     ProgError( "missing argument after \"%s\"", argv[ 0]);
                     argv++;
                     argc--;
                     AppendItemToList( (char ***) options[ optnum].data_ptr, argv[ 0]);
                     if (options[ optnum].msg_if_true)
                         printf("%s: %s.\n", options[ optnum].msg_if_true, argv[ 0]);
                     break;
                case OPT_STRINGLIST:
                     if (argc <= 1)
                         ProgError( "missing argument after \"%s\"", argv[ 0]);
                     while (argc > 1 && argv[ 1][ 0] != '-' && argv[ 1][ 0] != '+')
                           {
                            argv++;
                            argc--;
                            AppendItemToList( (char ***) options[ optnum].data_ptr, argv[ 0]);
                            if (options[ optnum].msg_if_true)
                                printf("%s: %s.\n", options[ optnum].msg_if_true, argv[ 0]);
                           }
                     break;
                default:
                     ProgError( "unknown option type (BUG!)");
               }
	        break;
           }
       }
    if (options[ optnum].opt_type == OPT_END)
    ProgError( "invalid argument: \"%s\"", argv[ 0]);
    argv++;
    argc--;
   }
}



/*
   read the config file
*/

void ParseConfigFileOptions( char *filename)
{
 FILE *cfgfile;
 char  line[ 1024];
 char *value;
 char *option;
 char *p;
 short optnum;

 if ((cfgfile = fopen (filename, "r")) == NULL)
    {
     form_alert(1,"[2][Warning: Configuration file not found.][ OK ]");
     return;
    }
 while (fgets (line, 1024, cfgfile) != NULL)
   {
    if (line[0] == '#' || strlen( line) < 2)
        continue;
    if (line[ strlen( line) - 1] == '\n')
        line[ strlen( line) - 1] = '\0';
    /* skip blanks before the option name */
    option = line;
    while (isspace( option[ 0]))
           option++;
    /* skip the option name */
    value = option;
    while (value[ 0] && value[ 0] != '=' && !isspace( value[ 0]))
           value++;
    if (!value[ 0])
        ProgError( "invalid line in %s (ends prematurely)", filename);
    if (value[ 0] == '=')
       {
	    /* mark the end of the option name */
        value[ 0] = '\0';
       }
      else
       {
        /* mark the end of the option name */
        value[ 0] = '\0';
        value++;
        /* skip blanks after the option name */
        while (isspace( value[ 0]))
               value++;
        if (value[ 0] != '=')
            ProgError( "invalid line in %s (no '=')", filename);
       }
    value++;
    /* skip blanks after the equal sign */
    while (isspace( value[ 0]))
           value++;
    for (optnum = 0; options[ optnum].opt_type != OPT_END; optnum++)
        {
         if (!stricmp( option, options[ optnum].long_name))
            {
             switch (options[ optnum].opt_type)
                {
                 case OPT_BOOLEAN:
                      if (!stricmp(value, "yes") || !stricmp(value, "true") || !stricmp(value, "on") || !stricmp(value, "1"))
                         {
                          *((Bool *) (options[ optnum].data_ptr)) = TRUE;
/*                        if (options[ optnum].msg_if_true)
**                            printf("%s.\n", options[ optnum].msg_if_true);
*/                       }
                      else if (!stricmp(value, "no") || !stricmp(value, "false") || !stricmp(value, "off") || !stricmp(value, "0"))
                         {
                          *((Bool *) (options[ optnum].data_ptr)) = FALSE;
/*                        if (options[ optnum].msg_if_false)
**                            printf("%s.\n", options[ optnum].msg_if_false);
*/                       }
                      else
                          ProgError( "invalid value for option %s: \"%s\"", option, value);
                      break;
                 case OPT_INTEGER:
                      *((short *) (options[ optnum].data_ptr)) = atoi( value);
/*                    if (options[ optnum].msg_if_true)
**                        printf("%s: %d.\n", options[ optnum].msg_if_true, atoi( value));
*/                    break;
                 case OPT_STRING:
                      p = GetMemory( (strlen( value) + 1) * sizeof( char));
                      strcpy( p, value);
                      *((char **) (options[ optnum].data_ptr)) = p;
/*                    if (options[ optnum].msg_if_true)
**                        printf("%s: %s.\n", options[ optnum].msg_if_true, value);
*/                    break;
                 case OPT_STRINGACC:
                      p = GetMemory( (strlen( value) + 1) * sizeof( char));
                      strcpy( p, value);
                      AppendItemToList( (char ***) options[ optnum].data_ptr, p);
/*                    if (options[ optnum].msg_if_true)
**                        printf("%s: %s.\n", options[ optnum].msg_if_true, value);
*/                    break;
                 case OPT_STRINGLIST:
                      while (value[ 0])
                         {
                          option = value;
                          while (option[ 0] && !isspace( option[ 0]))
                                 option++;
                          option[ 0] = '\0';
                          option++;
                          while (isspace( option[ 0]))
                          option++;
                          p = GetMemory( (strlen( value) + 1) * sizeof( char));
                          strcpy( p, value);
                          AppendItemToList( (char ***) options[ optnum].data_ptr, p);
/*                        if (options[ optnum].msg_if_true)
**                            printf("%s: %s.\n", options[ optnum].msg_if_true, value);
*/                        value = option;
                         }
                      break;
                 default:
                      ProgError( "unknown option type (BUG!)");
                }
             break;
            }
       }
    if (options[ optnum].opt_type == OPT_END)
	ProgError( "Invalid option in %s: \"%s\"", filename, option);
   }
 fclose( cfgfile);
}



/*
** output the credits of the program to the specified file
*/
void Credits( FILE *where)
{
 fprintf( where, "\nGEM-DEU: Doom Editor Utilities, ver %s.\n", DEU_VERSION);
 fprintf( where, "By Anthony Jacques (jacquesa@cs.man.ac.uk)\n");
 fprintf( where, "Based on DEU, By Rapha‰l Quinet (quinet@montefiore.ulg.ac.be),\n");
 fprintf( where, "and Brendon J Wyber (b.wyber@csc.canterbury.ac.nz).\n");
}



/*
   display a funny message on the screen
*/

void FunnyMessage( FILE *where)
{
 OBJECT *form;
 short xdial,ydial,wdial,hdial,seld;

 rsrc_gaddr(0,WELCOMEDIAG,&form);

 form_center ( form, &xdial, &ydial, &wdial, &hdial );
 form_dial ( 0,0,0,0,0, xdial, ydial, wdial, hdial );
 objc_draw (form, 0, 2, xdial, ydial, wdial, hdial );

 seld = form_do ( form, 0 ); 

 form_dial ( 3, 0, 0, 0, 0, xdial, ydial, wdial, hdial );
 objc_change (form,seld,-1,-1,-1,-1,-1,NORMAL,1);
}


/*
** play a fascinating tune
*/
void Beep()
{
 if (Quieter == FALSE)
    {
/*   sound( 640);
     delay( 100);
     nosound();*/
    }
}



/*
** play a sound
*/
void PlaySound( int freq, int msec)
{
 if (Quiet == FALSE)
    {
/*   sound( freq);
     delay( msec);
     nosound();*/
    }
}



/*
   terminate the program reporting an error
*/

void ProgError( char *errstr, ...)
{
 va_list args;

 Beep();
 Beep();
 va_start( args, errstr);
 printf( "\nProgram Error: *** ");
 vprintf( errstr, args);
 printf( " ***\n");
 if (Debug == TRUE && logfile != NULL)
    {
     fprintf( logfile, "\nProgram Error: *** ");
     vfprintf( logfile, errstr, args);
     fprintf( logfile, " ***\n");
    }
 va_end( args);
 /* clean up things and free swap space */
 ForgetLevelData();
 ForgetWTextureNames();
 ForgetFTextureNames();
 CloseWadFiles();
 exit( 5);
}



/*
   write a message in the log file
*/

void LogMessage( char *logstr, ...)
{
 va_list  args;
 time_t   tval;
 char    *tstr;

 if (Debug == TRUE && logfile != NULL)
    {
     va_start( args, logstr);
     /* if the messsage begins with ":", output the current date & time first */
     if (logstr[ 0] == ':')
        {
         time( &tval);
         tstr = ctime( &tval);
         tstr[ strlen( tstr) - 1] = '\0';
         fprintf(logfile, "%s", tstr);
        }
     vfprintf( logfile, logstr, args);
     va_end( args);
    }
}



/*
   the main program menu loop
*/

void MainLoop()
{
 char input[ 120],fname[20];
 char *com, *out;
 FILE *file, *raw;
 WadPtr wad;
 short episode, level, i, fselok;
 OBJECT *form;
 short xdial,ydial,wdial,hdial,seld;

 rsrc_gaddr(0,MAINMENU,&menu);
 menu_bar(menu,1);

 do
   {
    evnt_mesag(msgbuf);

    switch(msgbuf[3])
       {
        case T_DESK:
             rsrc_gaddr(0,ABOUTGEMDEU,&form);
             form_center ( form, &xdial, &ydial, &wdial, &hdial );
             form_dial ( 0, 0, 0, 0, 0, xdial, ydial, wdial, hdial );
             objc_draw (form, 0, 2, xdial, ydial, wdial, hdial );
             seld=form_do ( form, 0 ); 
             form_dial ( 3, 0, 0, 0, 0, xdial, ydial, wdial, hdial );
             objc_change (form,seld,-1,-1,-1,-1,-1,NORMAL,1);
             break;
        case T_FILE:
             switch (msgbuf[4])
                {
                 case OPENPWAD:
                      strcpy(input,"E:\\BADMOOD\\*.*");
                      strcpy(fname,"anthony.wad");
                      fsel_input(input,fname,&fselok);
                      for (i=0; input[i]!=0; i++);
                      for (; (input[i]!='\\' && i>0); i--);
                      input[i+1]='\0';
                      out = GetMemory( (strlen(fname)+i+1)*sizeof( char));
                      strcpy( out, input);
                      strcat( out, fname); 
                      OpenPatchWad( out);
                      CloseUnusedWadFiles();
                      break;
                 case CREATE: /* User asked to create a level */
                      episode = 0;
                      level = 0;
                      EditLevel( 0, 0, 1);
                      rsrc_gaddr(0,MAINMENU,&menu);
                      menu_bar(menu,1);
                      msgbuf[3]=T_FILE;
                      msgbuf[4]=CREATE;
                      break;
                 case EDIT: /* user asked to edit a level */
                      episode = 0;
                      level = 0;
                      EditLevel( 0, 0, 0);
                      rsrc_gaddr(0,MAINMENU,&menu);
                      menu_bar(menu,1);
                      msgbuf[3]=T_FILE;
                      msgbuf[4]=EDIT;
                      break;
                 case VIEWSPRITES:
/*                      InitGfx();
*/                      com = strtok( NULL, " ");
                      ChooseSprite( -1, -1, "Sprite viewer", com);
/*                      TermGfx();
*/                      break;
                  case QUIT:  /* user asked to quit */
                      if (!Registered && !NoRegisteredChecks)
                           form_alert(1,"[1][Remember to register |your copy of DOOM!][ OK ]");
                      break;
                 }
        case T_WADMANAGE:
             switch (msgbuf[4])
                {
                 case OPENWADS: /* user asked for list of open WAD files */
                      printf( "%-20s  IWAD  (Main wad file)\n", WadFileList->filename);
                      for (wad = WadFileList->next; wad; wad = wad->next)
                          {
                           if (wad->directory[ 0].name[ 0] == 'E' && wad->directory[ 0].name[ 2] == 'M')
                               printf( "%-20s  PWAD  (Patch wad file for episode %c level %c)\n", wad->filename, wad->directory[ 0].name[ 1], wad->directory[ 0].name[ 3]);
                             else
                               {
                                /* kluge */
	                            strncpy( input, wad->directory[ 0].name, 8);
	                            input[ 8] = '\0';
	                            printf( "%-20s  PWAD  (Patch wad file for %s)\n", wad->filename, input);
	                           }
                          }
                      break;
                 case LISTMASTER: /* user asked for the list of the master directory */
                      out = strtok( NULL, " ");
                      if (out)
                         {
                          printf( "Outputting master directory to \"%s\".\n", out);
                          if ((file = fopen( out, "wt")) == NULL)
                              ProgError( "error opening output file \"%s\"", com);
                          Credits( file);
                          ListMasterDirectory( file);
                          fprintf( file, "\nEnd of file.\n");
                          fclose( file);
                         }
                       else
                          ListMasterDirectory( stdout);
                       break;
                  case LISTWAD: /* user ask for a listing of a WAD file */
                       fsel_input("*.WAD",com,&i);
                       for (wad = WadFileList; wad; wad = wad->next)
                       if (!stricmp( com, wad->filename))
                           break;
                       if (wad == NULL)
                          {
                           printf( "[Wad file \"%s\" is not open.]\n", com);
                           continue;
                          }
                       out = strtok( NULL, " ");
                       if (out)
                          {
                           printf( "Outputting directory of \"%s\" to \"%s\".\n", wad->filename, out);
                           if ((file = fopen( out, "wt")) == NULL)
                               ProgError( "error opening output file \"%s\"", com);
                           Credits( file);
                           ListFileDirectory( file, wad);
                           fprintf( file, "\nEnd of file.\n");
                           fclose( file);
                          }
                       else
                          ListFileDirectory( stdout, wad);
                       break;
                  case GROUPWADS: /* user asked to build a compound patch WAD file */
                       if (WadFileList->next == NULL || WadFileList->next->next == NULL)
                          {
                           form_alert(1,"[2][You need at least two |open wad files | if you want to group them.][ OK ]");
                           continue;
                          }
                       fsel_input("*.WAD",com,&i);
                       for (wad = WadFileList; wad; wad = wad->next)
                            if (!stricmp( com, wad->filename))
                                break;
                       if (wad)
                          {
                           printf( "[File \"%s\" is opened and cannot be overwritten.]\n", com);
                           continue;
                          }
                       BuildNewMainWad( com, TRUE);
                       break;
                  case BUILD: /* user asked to build a new main WAD file */
                       fsel_input("*.WAD",com,&i);
                       for (wad = WadFileList; wad; wad = wad->next)
                       if (!stricmp( com, wad->filename))
                           break;
                       if (wad)
                          {
                           printf( "[File \"%s\" is opened and cannot be overwritten.]\n", com);
                           continue;
	                      }
                       BuildNewMainWad( com, FALSE);
                       break;
                  case SAVEOBJ:
                       form_alert(1,"[1][Object name is missing.][ OK ]");
                       if (strlen( com) > 8 || strchr( com, '.') != NULL)
                           form_alert(1,"[2][Invalid object name.][ OK ]");
                       out = strtok( NULL, " ");
                       if (out == NULL)
                          {
                           printf( "[Wad file name argument missing.]\n");
                           continue;
                          }
                       for (wad = WadFileList; wad; wad = wad->next)
                           if (!stricmp( out, wad->filename))
                               break;
                       if (wad)
                          {
                           form_alert(1,"[2][This WAD file is |already in use. |You may not overwrite it.][ OK ]");
                           continue;
                          }
                       printf( "Saving directory entry data to \"%s\".\n", out);
                       if ((file = fopen( out, "wb")) == NULL)
                           ProgError( "error opening output file \"%s\"", out);
                       SaveDirectoryEntry( file, com);
                       fclose( file);
                       break;
                  case LOADRAW:
                       fsel_input("*.WAD",com,&i);
                       form_alert(1,"[1][Object name is missing.][ OK ]");
                       if (strlen( out) > 8 || strchr( out, '.') != NULL)
                          {
                           form_alert(1,"[2][Invalid object name.][ OK ]");
                           continue;
                          }
                       if ((raw = fopen( com, "rb")) == NULL)
                           ProgError( "error opening input file \"%s\"", com);
                       /* kluge */
                       strcpy( input, out);
                       strcat( input, ".WAD");
                       for (wad = WadFileList; wad; wad = wad->next)
                            if (!stricmp( input, wad->filename))
                                break;
                       if (wad)
                          {
                           printf( "[This Wad file is already in use (%s).  You may not overwrite it.]\n", input);
                           continue;
                          }
                       printf( "Including new object %s in \"%s\".\n", out, input);
                       if ((file = fopen( input, "wb")) == NULL)
                           ProgError( "error opening output file \"%s\"", input);
                       SaveEntryFromRawFile( file, raw, out);
                       fclose( raw);
                       fclose( file);
                       break;
                  case SAVERAW:
                       printf( "[Object name argument missing.]\n");
                       if (strlen( com) > 8 || strchr( com, '.') != NULL)
                          {
                           form_alert(1,"[2][Invalid object name.][ OK ]");
                           continue;
                          }
                       fsel_input("*.WAD",com,&i);
                       for (wad = WadFileList; wad; wad = wad->next)
                           if (!stricmp( out, wad->filename))
                               break;
                       if (wad)
                          {
                           form_alert(1,"[2][You may not overwrite |an opened WAD file |with raw data.][ OK ]");
                           continue;
                          }
                       printf( "Saving directory entry data to \"%s\".\n", out);
                       if ((file = fopen( out, "wb")) == NULL)
                           ProgError( "error opening output file \"%s\"", out);
                       SaveEntryToRawFile( file, com);
                       fclose( file);
                       break;
                  case DUMPENTRY: /* user asked to dump the contents of a WAD file */
                       printf( "[Object name argument missing.]\n");
                       out = strtok( NULL, " ");
                       if (out)
                          {
                           printf( "Outputting directory entry data to \"%s\".\n", out);
                           if ((file = fopen( out, "wt")) == NULL)
                               ProgError( "error opening output file \"%s\"", com);
                           Credits( file);
                           DumpDirectoryEntry( file, com);
                           fprintf( file, "\nEnd of file.\n");
                           fclose( file);
                          }
                        else
                          DumpDirectoryEntry( stdout, com);
                       break;
                 }
       }
    menu_tnormal(menu,msgbuf[3],1);                                  
   } while (msgbuf[4]!=QUIT);

 menu_bar(menu,0);
}

/* end of file */
