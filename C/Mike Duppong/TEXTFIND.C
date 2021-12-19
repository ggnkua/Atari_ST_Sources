/* Text Searcher   [8/4/87]  Last modified: 9/3/87 */
/* Done with Megamax C       by Mike Duppong */
/* Compute's Atari ST Disk and Magazine */
/* (c) 1988 Compute! Publications/ABC   */

#include <stdio.h>
#include <gemdefs.h>
#include <osbind.h>
#include <obdefs.h>
#include <string.h>
#include "TEXTFIND.H" /* MMRCP-constructed header file */

#define TRUE 1
#define FALSE 0
#define PFL 28      /* Path field length */
#define TFL 21      /* Text field length */
#define PATHLENGTH 60
#define mouse_on(handle) v_show_c(handle, 1)
#define mouse_off(handle) v_hide_c(handle)
#define close_workstation(handle) v_clsvwk(handle); appl_exit()
#define arrow_pointer() graf_mouse(0, 0)
#define busy_bee() graf_mouse(2, 0)

int contrl[12], intin[128], ptsin[128], intout[128], ptsout[128],
    handle, work_out[57], work_in[] = {1,1,1,1,1,1,1,1,1,0,2};
OBJECT *main_dial, *pref_dial,     /* Pointers to OBJECT structures */
       *drive_dial, *path_dial,
       *help_dial;
extern char *malloc();
char srch_text[5][25], /* Search text */
     path[5][PATHLENGTH];  /* Paths */
char text[5][25];      /* Search text, modified for case sensitivity */
char sel_path[PATHLENGTH], /* User-selected path (from fsel_input box) */
     sel_file[14];     /* User-selected file (from fsel_input box) */
char edit[PATHLENGTH]; /* User-editable path (used in edit_path()) */
char output_file[PATHLENGTH]; /* User-selected output file */
char template[PATHLENGTH+1];  /* Template string for 'edit path' field */
char valid[PATHLENGTH+1];     /* Validity string for 'edit path' field */
char drive[2];         /* Current drive (used in drive dialog) */
char run_drv[2];       /* Drive that this program was run from */
char *help[11];        /* Help text (title first, then 10 lines of 35 chrs.) */
int dx, dy, dw, dh;    /* Dialog box coordinates (reused for all dialogs) */
int tb[6],             /* Text button to path button links */
    hb[6];             /* Text buttons currently "on" */
int spxy[8];           /* Coordinates used for screen to RAM transfer */
int fs[5];             /* "Field scroll"- used for scrolling path fields */
int l[5];              /* Contains which text fields are linked to a particular path */
int line;              /* Line counter */
int ram = FALSE;       /* Flag indicating whether or not malloc was used */
int pref_byte;         /* Preferences, all contained within a word */
int gotrsc = FALSE;    /* Flag indicating successful resource load */
FDB scrn_mfdb, ram_mfdb;      /* Memory Form Definition Blocks */
FILE *fopen();
FILE *outfile;         /* Used in output(), set in do_search() */
char *fname;           /* Pointer to DTA + 30 (where file name is held) */



/* One note about the resource file for this thing- if you make any
   changes to it, make SURE that you sort the dialogs by a "Y then X"
   algorithm.  This is important, since many objects are referenced
   by their vertical OFFSETS to an object, not explicitly. For 
   example, the path fields are referenced in places as PATH1 + i,
   where i is an offset to the top path. */


main()
{
  initialize();
  draw_main();  /* Draw the main dialog box */
  interact();   /* "Give control" to interact routine */
}


initialize()
{
  FILE *pref_file;
  int i;

  handle = open_workstation();
  clear_workstation(handle);
  arrow_pointer();         /* Display arrow as mouse pointer */
  if(work_out[13] > 4)     /* If in low res... */
    error("Please switch to|medium resolution");
  if(!rsrc_load("TEXTFIND.RSC"))  /* If can't find resource file... */
    error("Can't find|TEXTFIND.RSC!");
  gotrsc = TRUE;
  init_structs();
  if(!(pref_file = fopen("TEXTFIND.PRF","r"))) /* If file not opened... */
    error("Can't read preferences|(TEXTFIND.PRF)!");
  fscanf(pref_file, "%d", &pref_byte);
  fscanf(pref_file, "%s", output_file);    /* Default output file */
  if(fclose(pref_file))  /* Zero means successful close */
    form_alert(1, "[2][Can't close preferences|file!][ Ok ]");
  set_preferences();     /* Acknowledge preferences */
  tb[5] = 32;  /* Set "All of the above" links as a default */
  for(i=0; i<PATHLENGTH; i++)
  {
    template[i] = '_';   /* Template string */
    valid[i] = 'P';      /* Allow only DOS filename chrs, plus \ : ? * */
  }
  template[PATHLENGTH] = valid[PATHLENGTH] = '\0'; /* Null-terminate */
}


init_structs() /* Initializes dialogs and structures */
{
  int i;

  if(!rsrc_gaddr(0, MAINDIAL, &main_dial)) /* Get address of main dialog */
    error("Can't find|main dialog!");
  if(!rsrc_gaddr(0, PREFDIAL, &pref_dial)) /* Get address of preference dialog */
    error("Can't find|preferences dialog!");
  if(!rsrc_gaddr(0, DRIVDIAL, &drive_dial))/* Get adr. of "set drive" dialog */
    error("Can't find|'set drive' dialog!");
  if(!rsrc_gaddr(0, PATHDIAL, &path_dial)) /* Get adr. of "edit path" dialog */
    error("Can't find|'edit path' dialog!");
  if(!rsrc_gaddr(0, HELPDIAL, &help_dial)) /* Get adr. of the help dialog */
    error("Can't find|help dialog!");
  for(i=0; i<5; i++)
  {
    ((TEDINFO *)main_dial[TEXTF1 + i].ob_spec)->te_ptext = srch_text[i];
    ((TEDINFO *)main_dial[TEXTF1 + i].ob_spec)->te_txtlen = TFL;
    ((TEDINFO *)main_dial[PATH1 + i].ob_spec)->te_ptext = path[i];
    ((TEDINFO *)main_dial[PATH1 + i].ob_spec)->te_txtlen = PFL;
  }
  ((TEDINFO *)path_dial[EDITPATH].ob_spec)->te_ptext = edit;
  ((TEDINFO *)path_dial[EDITPATH].ob_spec)->te_ptmplt = template;
  ((TEDINFO *)path_dial[EDITPATH].ob_spec)->te_pvalid = valid;
  ((TEDINFO *)path_dial[EDITPATH].ob_spec)->te_txtlen = PATHLENGTH;
  ((TEDINFO *)path_dial[EDITPATH].ob_spec)->te_tmplen = PATHLENGTH;
  path_dial[EDITPATH].ob_width = 640;
  ((TEDINFO *)pref_dial[OUTFILE].ob_spec)->te_ptext = output_file;
  ((TEDINFO *)pref_dial[OUTFILE].ob_spec)->te_txtlen = 39;
  drive[0] = run_drv[0] = 'A' + Dgetdrv();
  ((TEDINFO *)drive_dial[DRIVENTR].ob_spec)->te_ptext = drive;
  sel_path[0] = drive[0];
  strcat(sel_path, ":\\*.*");
  sel_file[0] = '\0';
}


interact()     /* Allow user interaction with dialog and take actions */
{
  int b;       /* Flag indicating whether or not to release buttons */

  while(TRUE)     /* Infinite loop */
  {
    b = TRUE;     /* Default has you release mouse buttons */
    switch(form_do(main_dial, TEXTF1))
    {
      case QUIT:      quit(TRUE);     break;
      case PREFEREN:  do_prefs();     break;
      case EXECUTE:   do_search();    break;
      case SETPATH:   set_path();     break;
      case CLEAR:     clear();        break;
      case TEXTB1:    hit_tb(0);      break; /* Text link buttons */
      case TEXTB2:    hit_tb(1);      break;
      case TEXTB3:    hit_tb(2);      break;
      case TEXTB4:    hit_tb(3);      break;
      case TEXTB5:    hit_tb(4);      break;
      case TEXTALL:   hit_tb(5);      break;
      case PATHB1:    link(0);        break; /* Path link buttons */
      case PATHB2:    link(1);        break;
      case PATHB3:    link(2);        break;
      case PATHB4:    link(3);        break;
      case PATHB5:    link(4);        break;
      case PATHALL:   link(5);        break;
      case PATH1:     edit_path(0);   break;
      case PATH2:     edit_path(1);   break;
      case PATH3:     edit_path(2);   break;
      case PATH4:     edit_path(3);   break;
      case PATH5:     edit_path(4);   break;
      case PATHL1:    path_left(0);  b=FALSE; break; /* Path scroll left buttons */
      case PATHL2:    path_left(1);  b=FALSE; break;
      case PATHL3:    path_left(2);  b=FALSE; break;
      case PATHL4:    path_left(3);  b=FALSE; break;
      case PATHL5:    path_left(4);  b=FALSE; break;
      case PATHR1:    path_right(0); b=FALSE; break; /* Path scroll right buttons */
      case PATHR2:    path_right(1); b=FALSE; break;
      case PATHR3:    path_right(2); b=FALSE; break;
      case PATHR4:    path_right(3); b=FALSE; break;
      case PATHR5:    path_right(4); b=FALSE; break;
      case PATHH1:    path_home(0); break;           /* Path home buttons */
      case PATHH2:    path_home(1); break;
      case PATHH3:    path_home(2); break;
      case PATHH4:    path_home(3); break;
      case PATHH5:    path_home(4); break;
      case PATHALLL:  allpaths_left(); b=FALSE; break;  /* Scroll all paths left */
      case PATHALLR:  allpaths_right(); b=FALSE; break; /* Scroll all paths right */
      case PATHALLH:  allpaths_home(); break;           /* Home all paths */
    }
    if(b) release_buttons();
  }
}


do_prefs()
{
  objc_change(main_dial, PREFEREN, 0, 0,0,0,0,NORMAL,1); /* Return PREFERENCES button to normal state */
  draw_pref(); /* Draw preferences dialog */
  while(TRUE)     /* Infinite loop */
  {
    switch(form_do(pref_dial, OUTFILE))
    {
      case PREFDONE: clear_workstation(handle);
                     erase_dialog();
                     return;
                     break;
      case PREFSAVE: save_prefs();   break;
      case FSELECT:  get_output_fname(); break;
      case OUTTOHLP: out_to_help();  break;
      case CASEHELP: case_help();    break;
      case OUTHELP:  out_help();     break;
      case LNUMHELP: lnum_help();    break;
      case FSHELP:   fsel_help();    break;
    }
  }
}


get_output_fname() /* Use fsel_input for output file selection */
{
  char spath[PATHLENGTH], sfile[14];
  int button;

  objc_change(pref_dial, FSELECT, 0, 0,0,0,0,NORMAL,1); /* Return button to normal state */
  strcpy(spath, run_drv);
  strcat(spath, ":\\*.*");
  sfile[0] = '\0';
  form_dial(FMD_FINISH, dx, dy, dw, dh, 0,0,0,0);
  fsel_input(spath, sfile, &button);
  if(button)   /* If DIDN'T cancel... */
  {
    strcpy(output_file, spath);
    strcpy(rindex(output_file, '\\') + 1, sfile);
  }
  clear_workstation(handle);
  draw_main();
  draw_pref();
}


do_search()
{
  int pi;

  objc_change(main_dial, EXECUTE, 0, 0,0,0,0,NORMAL,1); /* Return EXECUTE button to normal state */
  if(!setup_search()) return; /* If had a problem somewhere, exit. */
  get_text();   /* Fill in the text array with upper/lower-case text from text fields */
  mouse_off(handle);
  output("\n"); /* Output one newline chr. to make sure text starts at full left of screen */
  for(pi=0; pi<5; pi++)
    if(determine_links(pi))   /* Find out which text fields are linked to path #pi */
      if(!path_search(pi))    /* If aborted... */
      {
        cleanup_search(TRUE); /* TRUE indicates user-abort. */
        mouse_on(handle);
        return;
      }
  cleanup_search(FALSE); /* If completed successfully with no abort... */
  mouse_on(handle);
}


get_text()
{
  int ti, i;

  for(ti=0; ti<5; ti++)  /* Fill in the text array with upper/lower case text */
  {
    if(pref_dial[CASEOFF].ob_state == SELECTED)  /* If case sensitivity is ON... */
      for(i=0; i<TFL; i++)
        text[ti][i] = toupper(srch_text[ti][i]); /* Convert to upper case */
    else
      strcpy(text[ti], srch_text[ti]); /* Otherwise, just copy as-is. */
  }
}


determine_links(pi) /* Figures out in advance what fields are linked. */
int pi;
{
  int ti, flag=FALSE;

  for(ti=0; ti<5; ti++) /* Loop through the text fields */
  {
    if(path[pi][0] && srch_text[ti][0] && (tb[ti] & (1 << pi) ||
    tb[ti] & 32 || tb[5] & (1 << pi) || tb[5] & 32)) /* If linked to a valid path... */
    {
      l[ti] = TRUE;
      flag = TRUE; /* Indicates that at least one link was made for this path */
    }
    else
      l[ti] = FALSE;
  }
  return(flag); /* If there ARE links, return a TRUE. */
}


path_search(pi) /* Returns FALSE if user aborts, TRUE otherwise. */
int pi;
{
  int ti;
  char fspec[PATHLENGTH], *insert;

  if(!path[pi][0]) return(TRUE); /* If nothing in that path, just return. */
  Dsetdrv(toupper(&path[pi][0]) - 'A'); /* Set working drive */
  fname = (char *)Fgetdta() + 30; /* Points to the file name */
  if(Fsfirst(path[pi], 0) < 0)   /* If couldn't find a file... */
  {
    output("  Can't find ");
    output(path[pi]);
    output(".\n");
    return(TRUE);
  }
  do
  {
    strcpy(fspec, path[pi]);        /* Make a duplicate of the path */
    if(index(fspec, '*') || index(fspec, '?'))  /* If a wildcard is used anywhere... */
    {
      insert = rindex(fspec, '\\'); /* find the last '\'... */
      strcpy(++insert, fname);      /* and slap a file name after it */
    }
    if(!gothrufile(fspec, l)) return(FALSE); /* Return FALSE if aborted */
  }while(Fsnext() >= 0); /* Keep going while there are files left in that path */
  return(TRUE); /* Return TRUE if completed with no abort. */
}


gothrufile(fspec) /* Returns FALSE if user aborts. */
char *fspec; /* This routine does that actual text searching, in the */
{            /* file specified by fspec. */
  char case_line[255], in_line[255];
  int index, length, ti, cll, i;
  FILE *fptr;

  /* No Dsetdrv is needed here- there is one above, in path_search(). */
  if(!(fptr = fopen(fspec, "r"))) /* If unsuccessful open... */
  {
    output("  Can't open "); output(fspec); output(".\n");
    return(TRUE); /* Return TRUE, since user didn't abort. */
  }
  line = 0;  /* Reset line counter */
  while(fgets(in_line,255,fptr)) /* While there is still text in file... */
  {
    ++line;
    if(abort())  /* Check for user-abort */
    {
      mouse_on(handle);
      if(form_alert(1, "[1][Abort search?][ Yes | No ]") == 1)
      {
        mouse_off(handle);
        if(fclose(fptr)) /* Zero means successful close */
          form_alert(1, "[2][Can't close search file!][ Ok ]");
        return(FALSE); /* FALSE indicates user-abort. */
      }
      mouse_off(handle);
    }
    for(ti=0; ti<5; ti++)     /* Loop for number of text fields */
      if(l[ti])               /* If there IS a link to this text field... */
      {
        length = strlen(srch_text[ti]);
        if(length < strlen(in_line)) /* If text field length < line from file... */
        {
          if(pref_dial[CASEOFF].ob_state == SELECTED) /* If NO case sensitivity... */
            for(i=0; i<strlen(in_line); i++)
              case_line[i] = toupper(in_line[i]);
          else strcpy(case_line, in_line);
          index=0;
          cll = strlen(in_line) - length; /* Difference in file line length and text field length */

          do  /* Search the line from the file against text */
          {
            if(!strncmp(&case_line[index++], text[ti], length)) /* If found... */
            {
              output_fname(fspec, ti);
              output_context(in_line);
              break;  /* Abandon this line, go to next line. */
            }
          }while(index < cll);
        }
      }
  }
  if(fclose(fptr))
    form_alert(1, "[2][Can't close search file!][ Ok ]");
  return(TRUE); /* TRUE indicates NO user-abort. */
}


output_fname(fspec, ti)
int ti;
char *fspec;
{
  char temp[10];

  if(pref_dial[OUTFNAME].ob_state == SELECTED ||
  pref_dial[FNCNOUT].ob_state == SELECTED)
  {                           /* If user wants file output... */
    if(pref_dial[OUTCONT].ob_state == SELECTED ||
    pref_dial[FNCNOUT].ob_state == SELECTED) /* If also outputting context... */
      output("\n"); /* seperate lines. */
    output(fspec);  /* Otherwise, just print one after the other with no */
    output(" - found "); /* separation */
    output(srch_text[ti]);
    if(pref_dial[YESLNUM].ob_state == SELECTED &&  /* If only outputting file names */
    pref_dial[OUTFNAME].ob_state == SELECTED) /* and line number output has been selected... */
    {
      output(" in line ");
      sprintf(temp, "%d",line);
      output(temp);
    }
    output("\n");
  }
}


output_context(in_line)
char *in_line;
{
  char temp[10];

  if(pref_dial[OUTCONT].ob_state == SELECTED ||
  pref_dial[FNCNOUT].ob_state == SELECTED)
  {
    if(pref_dial[YESLNUM].ob_state == SELECTED)
    {
      sprintf(temp, "%d) ", line);
      output(temp);
    }
    output(in_line); /* If user wants context output... (\n is already in in_line from file) */
  }
}


abort()  
{
  char ch;

  if(Cconis()) /* If a key is waiting... */
  {
    ch = Crawcin();
    if(ch == 'P' || ch == 'p') /* Pause? */
      do
      {
        ch = Crawcin();
      }while(ch != 'C' && ch != 'c' && ch != 27); /* 27 = ESC key */
    if(ch == 27) return(TRUE);  /* If Esc, quit. */
  }
  return(FALSE);    /* If didn't abort, return FALSE. */
}


output(string)  /* Outputs string to the screen, a file, or both, */
char *string;   /* whichever is set in preferences. */
{
  if(pref_dial[SCRNOUT].ob_state == SELECTED ||
  pref_dial[SCFLOUT].ob_state == SELECTED)
    printf("%s", string);
  if(outfile)
  {
    fprintf(outfile, "%s", string); /* Output to file */
    if(ferror(outfile))  /* If an output error occured... */
    {
      mouse_on(handle);
      fclose(outfile);
      outfile = 0;
      form_alert(1, "[2][Can't output text|to the output file!|(Disk full?)][ Ok ]");
      if(pref_dial[SCRNOUT].ob_state == SELECTED ||
      pref_dial[SCFLOUT].ob_state == SELECTED)
        form_alert(1, "[1][The search will continue|without file output.][ Ok ]");
      else
        form_alert(1, "[1][You may abort the search|by pressing the escape key.][ Ok ]");
      mouse_off(handle);
    }
  }
}


setup_search()  /* Does some preliminary checks and initialization */
{               /* Returns FALSE if no links or can't open output file. */
  int i;

  if(form_alert(1, "[1][START SEARCH|Press P to pause, C to unpause|(continue), or Esc to abort.][ Ok | Cancel ]") == 2)
    return(FALSE);
  if((pref_dial[FILEOUT].ob_state == SELECTED ||
  pref_dial[SCFLOUT].ob_state == SELECTED) && !output_file[0])
  {
    form_alert(1, "[2][No output file selected!][ Ok ]");
    return(FALSE);
  }
  if(pref_dial[SCRNOUT].ob_state == SELECTED ||
  pref_dial[SCFLOUT].ob_state == SELECTED) /* If user wants screen output... */
    clear_workstation(handle);
  outfile = 0; /* Null-out output file pointer as a default */
  if(pref_dial[FILEOUT].ob_state == SELECTED ||
  pref_dial[SCFLOUT].ob_state == SELECTED) /* If user wants file output... */
  {
    Dsetdrv(output_file[0] - 'A'); /* Set working drive */
    if(!(outfile = fopen(output_file, "w")))
    {
      if(pref_dial[SCRNOUT].ob_state == NORMAL &&
      pref_dial[SCFLOUT].ob_state == NORMAL)
      {
        form_alert(1, "[2][Can't open output file!][Abort]");
        cleanup_search(TRUE);
        return(FALSE);
      }
      else if(form_alert(2, "[1][Can't open output file!][Continue|Abort]")==2)
      {
        cleanup_search(TRUE);
        return(FALSE);
      }
    }
  }
  return(TRUE);
}


cleanup_search(flag)    /* Done at end of search to clean things up */
int flag; /* flag = TRUE indicates user-abort. */
{
  int f;

  f = (pref_dial[SCRNOUT].ob_state == SELECTED ||
      pref_dial[SCFLOUT].ob_state == SELECTED);
  if(flag) output("Search aborted.\n");
  else output("Search finished.\n");
  if(outfile)
  {
    if(f) printf("\nClosing output file (%s)...\n",output_file);
    if(fclose(outfile))  /* If output file was opened, close it. */
      form_alert(1, "[2][Can't close output file!][ Ok ]");
    outfile = 0;      /* Null-out the file pointer */
  }
  if(f)
  {
    printf("Press any key.\n");
    Bconin(2);
    clear_workstation(handle);
    draw_main();
  }
}


set_path()
{
  objc_change(main_dial, SETPATH, 0, 0,0,0,0,NORMAL,1); /* Return button to normal state */
  if(path_avail() < 0)     /* If a blank path field doesn't exist... */
  {
    form_alert(1, "[1][No space for another path!][ Ok ]");
    return;
  }
  draw_drive();
  while(TRUE)
  {
    switch(form_do(drive_dial, DRIVENTR))
    {
      case CANCDRIV: erase_dialog();
                     return;
                     break;
      case OKDRIVE:  select_path();
                     clear_workstation(handle);
                     erase_dialog();
                     return;
                     break;
    }
  }
}


select_path()  /* Pops up GEM-standard file selection box */
{
  int i, j, button, found=FALSE;
  char temp, *insert;

  temp = toupper(((TEDINFO *)drive_dial[DRIVENTR].ob_spec)->te_ptext[0]);
  if(temp != drive[0] || !sel_path[0])
  {
    sel_path[0] = drive[0] = temp;
    strcpy(&sel_path[1], ":\\*.*");
  }
  sel_file[0] = '\0'; /* Null out file name in any case. */
  fsel_input(sel_path, sel_file, &button);
  if(button)   /* If DIDN'T cancel... */
  {
    i = path_avail();  /* Get number of blank path (we know one exists) */
    strcpy(path[i], sel_path);
    if(sel_file[0])    /* If a file HAS been selected... */
      if(index(path[i], '*') || index(path[i], '?')) /* If found a wildcard in path... */
      {
        insert = rindex(path[i], '\\') + 1;
        strcpy(insert, sel_file);  /* Insert the file name over wildcard */
      }                            /* (past last occurence of a backslash) */
    for(j=0; j<5; j++) /* Search for same entry in main dialog    */
      if(!strcmp(path[j], path[i]) && j!=i)     /* If DID find same entry...  */
        path[i][0] = '\0';         /* Null out the one just made  */
    fs[i] = 0;         /* Reset field scroll index */
  }
}


path_avail()   /* Searches for a blank path entry in main dialog. */
{              /* Returns a -1 if none available, or the number */
  int i, found=FALSE;  /* of the field if one IS available. */

  for(i=0; i<5; i++)
    if(!path[i][0]) {found=TRUE; break;}
  if(!found) return(-1);
  else return(i);
}


edit_path(field) /* Allows user to edit a path field */
int field;
{
  strcpy(edit, path[field]);
  do
  {
    draw_path();      /* Draw the path-editing dialog box */
    if(form_do(path_dial, 0) == PATHCANC)
    {                                /* If cancelled edit... */
      erase_dialog();
      return;
    }
  }while(!path_check(field));
  strcpy(path[field], edit);
  erase_dialog();
}


path_check() /* Checks edit string for correct format and redundancy with other paths */
{
  int j;

  if(!edit[0]) return(TRUE); /* If nothing there, just return. */
  if(edit[0] < 'A' || edit[0] > 'P')
  {
    form_alert(1, "[2][This path does not have|a valid drive identifier|(A - P). Please re-edit.][ Ok ]");
    return(FALSE);
  }
  for(j=0; j<5; j++) /* Search for same entry in main dialog    */
    if(!strcmp(path[j], edit))     /* If DID find same entry...  */
    {
      form_alert(1, "[1][This path is redundant!|(An identical one already|exists)][ Ok ]");
      return(FALSE);
    }
  if(edit[1] == ':' && edit[2] == '\\')
    return(TRUE);
  else
  {
    form_alert(1, "[2][The path must be in the|format drive:\\path][ Ok ]");
    return(FALSE);
  }
}


path_left(field)    /* Scrolls path text field to the right */
int field;
{
  if(fs[field] < 1) /* If already scrolled the max. just return. */
    return;
  ((TEDINFO *)main_dial[PATH1 + field].ob_spec)->te_ptext =
    &path[field][--fs[field]];
  objc_draw(main_dial, PATH1 + field, 1, dx, dy, dw, dh);
}


path_right(field)   /* Scrolls path text field to the left */
int field;
{
  if(fs[field] > strlen(path[field])-2) /* If scrolled to far, return. */
    return;
  ((TEDINFO *)main_dial[PATH1 + field].ob_spec)->te_ptext = 
    &path[field][++fs[field]];
  objc_draw(main_dial, PATH1 + field, 1, dx, dy, dw, dh);
}


path_home(field)  /* Returns path fields to the left-edge position */
int field;
{
  fs[field] = 0;
  ((TEDINFO *)main_dial[PATH1 + field].ob_spec)->te_ptext = path[field];
  objc_draw(main_dial, PATH1 + field, 1, dx, dy, dw, dh);
}



allpaths_left()     /* Scrolls all paths to the right */
{
  int i;

  for(i=0; i<5; i++)
    path_left(i);
}


allpaths_right()    /* Scrolls all paths to the left */
{
  int i;

  for(i=0; i<5; i++)
    path_right(i);
}


allpaths_home()     /* Moves all paths to the left-edge position */
{
  int i;

  for(i=0; i<5; i++)
    path_home(i);
}


save_prefs()   /* Save preferences to file TEXTFIND.PRF */
{
  FILE *pref_file;

  objc_change(pref_dial, PREFSAVE, 0, 0,0,0,0,NORMAL,1); /* Return button to normal state */
  busy_bee();       /* Make the cursor a busy bee */
  pref_byte = 0;    /* Clear out preferences word */
  if(pref_dial[CASEON].ob_state == SELECTED) pref_byte = 0x01;
  if(pref_dial[SCRNOUT].ob_state == SELECTED) pref_byte |= 0x02;
  if(pref_dial[FILEOUT].ob_state == SELECTED) pref_byte |= 0x04;
  if(pref_dial[SCFLOUT].ob_state == SELECTED) pref_byte |= 0x08;
  if(pref_dial[OUTCONT].ob_state == SELECTED) pref_byte |= 0x10;
  if(pref_dial[OUTFNAME].ob_state == SELECTED) pref_byte |= 0x20;
  if(pref_dial[FNCNOUT].ob_state == SELECTED) pref_byte |= 0x40;
  if(pref_dial[YESLNUM].ob_state == SELECTED) pref_byte |= 0x80;
  Dsetdrv(run_drv[0] - 'A'); /* Set working drive back to original */
  if(!(pref_file = fopen("TEXTFIND.PRF","w"))) /* If can't open file... */
  {
    arrow_pointer();
    form_alert(1, "[2][Can't open preferences|file (TEXTFIND.PRF)|for writing!][ Cancel ]");
    printf("outfile = %d\n",outfile); Bconin(2);
    return;
  }
  fprintf(pref_file, "%d\n", pref_byte);
  fprintf(pref_file, "%s\n", output_file);
  if(fclose(pref_file))
    form_alert(1, "[2][Can't close preferences|file!][ Ok ]");
  arrow_pointer();
  form_alert(1, "[0][Preferences|saved.][ Ok ]");
}


set_preferences()  /* Set all preferences buttons according to pref_byte */
{
  pref_dial[CASEON].ob_state = 
  pref_dial[CASEOFF].ob_state = 
  pref_dial[SCRNOUT].ob_state = 
  pref_dial[FILEOUT].ob_state = 
  pref_dial[SCFLOUT].ob_state =
  pref_dial[OUTCONT].ob_state =
  pref_dial[OUTFNAME].ob_state =
  pref_dial[FNCNOUT].ob_state =
  pref_dial[NOLNUM].ob_state =
  pref_dial[YESLNUM].ob_state = NORMAL;

  if(pref_byte & 0x01) pref_dial[CASEON].ob_state = SELECTED;
  else pref_dial[CASEOFF].ob_state = SELECTED;
  if(pref_byte & 0x02) pref_dial[SCRNOUT].ob_state = SELECTED;
  if(pref_byte & 0x04) pref_dial[FILEOUT].ob_state = SELECTED;
  if(pref_byte & 0x08) pref_dial[SCFLOUT].ob_state = SELECTED;
  if(pref_byte & 0x10) pref_dial[OUTCONT].ob_state = SELECTED;
  if(pref_byte & 0x20) pref_dial[OUTFNAME].ob_state = SELECTED;
  if(pref_byte & 0x40) pref_dial[FNCNOUT].ob_state = SELECTED;
  if(pref_byte & 0x80) pref_dial[YESLNUM].ob_state = SELECTED;
  else pref_dial[NOLNUM].ob_state = SELECTED;
}


hit_tb(button)    /* Text button logic */
int button;
{
  int i;

  vsf_color(handle, 1);  /* Normal text color for button fill */
  hb[button] ^= 1;     /* Toggle the touched button */
  if(button == 5 & hb[5])   /* If hit "All above" text button and it is activated... */
    for(i=0; i<5; i++) hb[i] = 0; /* Reset all touched buttons */
  else if(button != 5) hb[5] = FALSE; /* Turn off "All above" text button */
  draw_buttons();
}


draw_buttons() /* Draws the buttons filled in if they are "on" */
{
  int i, pxy[4];

  mouse_off(handle);
  draw_links();
  for(i=0; i<6; i++)
  {
    if(hb[i])  /* If the button is "on" */
    {
      pxy[0] = main_dial[TEXTB1 + i].ob_x + main_dial[MAINDIAL].ob_x;
      pxy[1] = main_dial[TEXTB1 + i].ob_y + main_dial[MAINDIAL].ob_y;
      pxy[2] = main_dial[TEXTB1 + i].ob_x + main_dial[MAINDIAL].ob_x +
               main_dial[TEXTB1 + i].ob_width;
      pxy[3] = main_dial[TEXTB1 + i].ob_y + main_dial[MAINDIAL].ob_y +
               main_dial[TEXTB1 + i].ob_height;
      vr_recfl(handle, pxy);
    }
  }
  mouse_on(handle);
}


clear()
{
  int i;

  objc_change(main_dial, CLEAR, 0, 0,0,0,0, NORMAL, 1); /* Return CLEAR button to normal state */
  if(form_alert(2, "[3][This function clears all text|fields, links, and paths.|Are you sure you want|to do this?][ Yes | No ]")
    == 2) return;   /* If chickened out, return. */
  for(i=0; i<5; i++) srch_text[i][0] = path[i][0] = tb[i] = hb[i] = 0;
  tb[5] = hb[5] = 0;
  draw_main();
}


link(pathb) /* Takes care of link when path buttons are hit */
int pathb;
{
  int i, hit=FALSE, origpb;

  origpb = pathb;
  pathb = 1 << pathb;  /* pb1 = 1, pb2 = 2, pb3 = 4, pb4 = 8, etc. */
  for(i=0; i<6; i++) hit |= hb[i];
  if(!hit)   /* If a text button hasn't been hit yet... */
  {
    form_alert(1,"[1][Press a text|button first.][ Ok ]");
    return;
  }

  for(i=0; i<6; i++)
    if(hb[i])
      tb[i] ^= pathb;  /* Link/unlink text button to path button */

  for(i=0; i<5; i++)     /* Loop for first five buttons */
    if(hb[i])  /* If a button was "on"... */
    {
      if(tb[i] & 32 && pathb != 32)
        tb[i] ^= 32;
      if(tb[i] & 32 && pathb==32) /* If linked to "All above" path button... */
        tb[i] = pathb; /* Set that link ONLY to "All above" path button */
      if(tb[i] & pathb && tb[5] & pathb) /* If "All above" linked... */
        tb[5] ^= pathb;  /* toggle it. */
      if(tb[5] & 32) tb[5] = 0; /* Clear "All above" to "All above" link */
    }

  if(hb[5])    /* If "All above" text button was on... */
  {
    if(pathb == 32) /* If "All above" to "All above" link... */
    {
      for(i=0; i<5; i++) tb[i] = 0; /* Clear all other links */
      tb[5] = 32;   /* Set exclusive link */
    }
    else
    {
      if(tb[5] & 32) tb[5] ^= 32; /* Turn off "All above" link */
      for(i=0; i<5; i++) /* Check all other text buttons for same link */
        if(tb[i] & pathb) /* If has same link... */
          tb[i] ^= pathb; /* turn it off. */
    }
  }

  draw_links(); /* Draw the new set of links */
  for(i=0; i<6; i++) hb[i] = FALSE; /* Reset buttons to "off" state */
}


draw_links()   /* Draws the links between text & path buttons */
{
  int tix, pix; /* Text and path button indexes */
  int pxy[4];   /* Array for line coordinates */

  mouse_off(handle);
  refresh_screen(); /* Clear out old links on screen */
  vsl_color(handle, 2);
  for(tix=0; tix<6; tix++)
    for(pix=0; pix<6; pix++)
    {
      if(tb[tix] & (1 << pix)) /* If tbutton #tix has link to pbutton #pix... */
      {
        /* Coordinates below represent the middle of the text
           button and the middle of the path button.  These
           are added to the X and Y position of the main
           dialog box (buttons are relative to box)        */
        pxy[0] = main_dial[TEXTB1 + tix].ob_x +
                (main_dial[TEXTB1 + tix].ob_width >> 1) +
                 main_dial[MAINDIAL].ob_x;
        pxy[1] = main_dial[TEXTB1 + tix].ob_y +
                (main_dial[TEXTB1 + tix].ob_height >> 1) +
                 main_dial[MAINDIAL].ob_y;
        pxy[2] = main_dial[PATHB1 + pix].ob_x +
                (main_dial[PATHB1 + pix].ob_width >> 1) +
                 main_dial[MAINDIAL].ob_x;
        pxy[3] = main_dial[PATHB1 + pix].ob_y +
                (main_dial[PATHB1 + pix].ob_height >> 1) +
                 main_dial[MAINDIAL].ob_y;
        v_pline(handle, 2, pxy); /* Draw the line */
      }
    }
  mouse_on(handle);
}


draw_main()    /* Draws main dialog box on the screen */
{
  form_center(main_dial, &dx, &dy, &dw, &dh); /* Center the main dialog box. */
  form_dial(FMD_START, dx, dy, dw, dh, 0,0,0,0); 
  objc_draw(main_dial, 0, 3, dx, dy, dw, dh); /* Draw the dialog box. */
  save_screen(); /* Save button portion of screen for later use */
  draw_links();
  title();     /* Redraw title */
  draw_buttons();
}


draw_pref()    /* Draws "preferences" dialog box */
{
  pref_dial[PREFDONE].ob_state = NORMAL;
  form_center(pref_dial, &dx, &dy, &dw, &dh); /* Center pref box */
  form_dial(FMD_START, dx, dy, dw, dh, 0,0,0,0);
  objc_draw(pref_dial, 0, 3, dx, dy, dw, dh); /* Draw the box. */
}


draw_drive() /* Draws "set drive" dialog box */
{
  drive_dial[OKDRIVE].ob_state =
  drive_dial[CANCDRIV].ob_state = NORMAL;
  form_center(drive_dial, &dx, &dy, &dw, &dh); /* Center dialog */
  form_dial(FMD_START, dx, dy, dw, dh, 0,0,0,0);
  objc_draw(drive_dial, 0, 3, dx, dy, dw, dh); /* Draw the box. */
}


draw_path()  /* Draws "edit path" dialog box */
{
  path_dial[PATHOK].ob_state =
  path_dial[PATHCANC].ob_state = NORMAL;
  form_center(path_dial, &dx, &dy, &dw, &dh); /* Center dialog */
  form_dial(FMD_START, dx, dy, dw, dh, 0,0,0,0);
  objc_draw(path_dial, 0, 3, dx, dy, dw, dh); /* Draw box. */
}


draw_help() /* Draws HELP dialog box */
{
  int i;

  help_dial[HELPTITL].ob_spec = help[0]; /* Dialog title string */
  for(i=1; i<11; i++)
    help_dial[HELPFLD+i-1].ob_spec = help[i]; /* Dialog text strings */
  help_dial[HELPOK].ob_state = NORMAL;
  form_center(help_dial, &dx, &dy, &dw, &dh); /* Center dialog */
  form_dial(FMD_START, dx, dy, dw, dh, 0,0,0,0);
  objc_draw(help_dial, 0, 3, dx, dy, dw, dh); /* Draw dialog. */
  form_do(help_dial, 0); /* Wait for user to press OK button */
  form_dial(FMD_FINISH, dx, dy, dw, dh, 0,0,0,0);
  draw_pref();  /* Redraw the preferences dialog over this one */
}


erase_dialog()   /* Erases dialog box (whichever is active) */
{
  form_dial(FMD_FINISH, dx, dy, dw, dh, 0,0,0,0);
  draw_main();
  draw_links();
  draw_buttons();
}


  /* save_screen() saves the middle portion of the dialog (the text
     and path buttons) so it can later be redisplayed over the old
     portion.  This way the lines don't have to be erased one by
     one or the dialog doesn't have to be redrawn over the old lines
     (looks sloppy, takes to much time). */
save_screen()
{
  spxy[0] = main_dial[TEXTB1].ob_x + main_dial[MAINDIAL].ob_x;
  spxy[1] = main_dial[TEXTB1].ob_y + main_dial[MAINDIAL].ob_y;
  spxy[2] = main_dial[PATHALL].ob_x + main_dial[PATHALL].ob_width +
            main_dial[MAINDIAL].ob_x;
  spxy[3] = main_dial[PATHALL].ob_y + main_dial[PATHALL].ob_height +
            main_dial[MAINDIAL].ob_y;
  spxy[4] = 0;  /* Destination coordinates (in RAM) */
  spxy[5] = 0;
  spxy[6] = spxy[2] - spxy[0];
  spxy[7] = spxy[3] - spxy[1];
  /* The following statement allocates enough memory for the middle
     portion of the main dialog box (width in bytes * height * the
     number of bit planes) and puts this value in the address field
     of the RAM's memory form definition block.  If this
     value happens to be zero (couldn't allocate memory), it pops up
     an alert, then exits the program.  It works.  Take my word for it. */

  if(!ram)  /* If this is the first time through the routine... */
    if(!(ram_mfdb.fd_addr = (long)malloc((long) ((spxy[6] + 7) >> 3)
    * spxy[7] * (work_out[13] >> 1))))
    {                           /* If not enough RAM... */
      form_alert(1,"[1][Not enough RAM!][ Ok ]");
      quit(FALSE);
    }
  scrn_mfdb.fd_addr = (long)Physbase();     /* Address of screen memory */
  scrn_mfdb.fd_w = work_out[0]+1;  /* Hor. res. of screen */
  scrn_mfdb.fd_h = work_out[1]+1;  /* Vertical resolution */
  scrn_mfdb.fd_wdwidth = (work_out[0]+1) >> 4;  /* Word width of screen */
  scrn_mfdb.fd_stand = ram_mfdb.fd_stand = 0;    /* Always zero */
  scrn_mfdb.fd_nplanes = ram_mfdb.fd_nplanes = work_out[13] >> 1; /* Number of bit planes */
  scrn_mfdb.fd_r1 = scrn_mfdb.fd_r2 = scrn_mfdb.fd_r3 =
  ram_mfdb.fd_r1 = ram_mfdb.fd_r2 = ram_mfdb.fd_r3 = 0; /* Reserved */
  ram_mfdb.fd_w = spxy[6];
  ram_mfdb.fd_h = spxy[7];
  ram_mfdb.fd_wdwidth = (spxy[6] + 8) >> 4;
  mouse_off(handle);
  vro_cpyfm(handle, 3, spxy, &scrn_mfdb, &ram_mfdb); /* Copy screen to RAM */
  mouse_on(handle);
  ram = TRUE;               /* That's all there is to it! */
}


refresh_screen()
{
  int pxy[8];

  pxy[0] = 0;  pxy[1] = 0;    /* Source coordinates (in RAM) */
  pxy[2] = spxy[6];  pxy[3] = spxy[7];
  pxy[4] = spxy[0];  pxy[5] = spxy[1]; /* Destination coordinates (screen) */
  pxy[6] = spxy[2];  pxy[7] = spxy[3];
  vro_cpyfm(handle, 3, pxy, &ram_mfdb, &scrn_mfdb);
}


open_workstation()     /* Returns HANDLE */
{
  int dummy, handle;

  appl_init();
  handle=graf_handle(&dummy,&dummy,&dummy,&dummy);
  v_opnvwk (work_in, &handle, work_out);
  return (handle);
}


clear_workstation(handle)
int handle;
{
  mouse_off(handle);
  v_clrwk(handle);
  mouse_on(handle);
}


title()   /* Display the title */
{
  int m, d, w, h, h2;

  mouse_off(handle);

  vst_alignment(handle, 1, 2, &d, &d); /* Center justified, ascent line alignment */
  m = (work_out[1]+1) / 200;   /* vertical multiplier */
  vst_effects(handle, 4);      /* Italic effects on text */
  vst_height(handle, 12 * m, &d, &d, &w, &h);  /* Text height */
  v_gtext(handle, 190, 5 * m, "Text Finder");
  vst_effects(handle, 0);     /* No text effects */
  vst_height(handle, 4, &d, &d, &w, &h2);      /* Smaller text */
  v_gtext(handle, 400, 2, "by Mike M. Duppong");
  v_gtext(handle, 400, (2 + h2) * m, "Compute's Atari ST Disk and Magazine");
  v_gtext(handle, 400, (2 + h2 * 2) * m,"April 1988 - Volume  3, No.  2");
  v_gtext(handle, 400, (2 + h2 * 3) * m,"(c) 1988 Compute! Publications/ABC");
  mouse_on(handle);
}


out_to_help() /* Gives help on the "Output to:" field in preferences */
{
  clear_help();
  help[0] = "OUTPUT TO SCREEN/FILE";
  help[1] = "Select SCREEN if you wish the pro-";
  help[2] = "gress of the search to be displayed";
  help[3] = "on the screen.  Select FILE if you";
  help[4] = "you wish the search output to be";
  help[5] = "placed in a file for later recall.";
  help[6] = "Select BOTH if you wish to have";
  help[7] = "screen AND file output.";
  draw_help();
}


case_help() /* Displays help on case sensitivity */
{
  clear_help();
  help[0] = "CASE SENSITIVITY";
  help[1] = "Select ON if you want to find an";
  help[2] = "exact match of the text that you";
  help[3] = "enter in the text fields.  Select";
  help[4] = "OFF if you wish to match text in";
  help[5] = "upper OR lower case.";
  draw_help();
}


out_help()  /* Displays help on file/context output */
{
  clear_help();
  help[0] = "FILENAME/CONTEXT OUTPUT";
  help[1] = "Select FILENAMES if you wish to";
  help[2] = "output the names of the files that";
  help[3] = "the text is found in.  Select";
  help[4] = "CONTEXT if you wish to display the";
  help[5] = "line of text that the matching text";
  help[6] = "appears in.  Select BOTH if you wish";
  help[7] = "to display both the file names AND";
  help[8] = "the context.";
  draw_help();
}


lnum_help()
{
  clear_help();
  help[0] = "LINE NUMBER OUTPUT";
  help[1] = "Use this function if you desire";
  help[2] = "to output the number of the line";
  help[3] = "in which the match occurs.";
  draw_help();
}


fsel_help()
{
  clear_help();
  help[0] = "FILE SELECTOR";
  help[1] = "You may use the standard GEM file";
  help[2] = "selector box to select an output";
  help[3] = "file with, or you may simply type";
  help[4] = "in the file name yourself.";
  draw_help();
}


clear_help()  /* Nulls out the help[] array */
{
  int i;

  for(i=0; i<11; i++) help[i] = "\0";
}


release_buttons()   /* Waits until mouse buttons are released */
{
  int d, mstate;

  do
  {
    graf_mkstate(&d, &d, &mstate, &d);
  } while (mstate != 0);
}


error(string)
char *string;
{
  char form_string[100];

  sprintf(form_string,"[3][%s][ Exit ]", string);
  form_alert(1, form_string);
  quit(FALSE);
}


quit(prompt)
int prompt;
{

  if(prompt)
  {
    objc_change(main_dial, QUIT, 0, 0,0,0,0,NORMAL,1); /* Return QUIT button to normal state */
    if(form_alert(2, "[2][Sure?][ Yes | No ]")==2) return;
  }
  if(ram) free(ram_mfdb.fd_addr);  /* Free up previously-allocated RAM */
  if(gotrsc && !rsrc_free())
    form_alert(1,"[0][Can't free resource!][ Hmmm ]");
  close_workstation(handle);
  exit(0);
}
  
