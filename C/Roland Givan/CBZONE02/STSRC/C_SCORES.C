#include "c_includes.h"
/*
 * cbzone_scores.c
 *  -- Todd W Mummert, December 1990, CMU
 *
 * ATARI Mods - Roland Givan Summer/Autumn/Winter 1993
 *
 * RCS Info
 *  $Header: c_scores.c,v 1.1 91/01/12 02:03:36 mummert Locked $
 *
 *  Derived from work I did on our local version of golddig.  Thanks
 *  to Bennet Yee (CMU) for the flock() code.
 */
  
/*
 * Okay, let's try to clean this up.  The following things may
 * happen:
 *   score < 0:  then the user is just asking for scores.  the score
 *               file should not be changed.
 *   score >= 0: score is either valid, for practice, or played by an
 *               old version.  In all cases, the file should change.
 *
 *   file status:
 *     can be not there
 *            available for reading
 *            available for both reading and writing
 *            not there but can be written
 *
 * we know the following:
 *   whether the game was for practice only.
 *   any scores in the score file WILL be in the correct order.
 *
 *  the format of the score file is as follows:
 *    Version identification
 *    number of games played, followed by number of valid games
 *    scores, one per line w/uid and player's name
 *
 * how should we go about comparing users?
 *  use getuid and cuserid...check both of them since we may be
 *  saving scores over a distributed file system
 *
 * if the game was scoresonly, print to tty if opt->output allows;
 *  else print to X screen.
 */

#ifdef ATARI
extern char *score_dialog(void);
#endif
  
extern int errno;
int x, y, ydelta;


void xprintf(s, output)                 /* print to the X screen */
     char* s;
     Bool output;
{
  printstring (x, y, s, strlen(s));
  y += ydelta;
}

void nprintf(s, output)                 /* print to the parent tty   */
     char* s;
     Bool output;
{
  if (output)
    printf("%s\n", s);
}

void printandwait(s, c)                 /* print a string and then */
     char* s;                           /* wait for a character c  */
     char c;                            /* to be pressed.  If c==0 */
{                                       /* then any keypress will  */
  y += ydelta;                          /* do.                     */
  xprintf(s, True);
  waitforkey(c);
}

int scores(score)
     int score;
{
  struct score_struct {
    int score;
    int uid;
    char name[50];
    struct score_struct *next;
  } player, *current, *top_score, *prev_score;

  FILE *sfile;
  char buf[100];
  char version[100];
#ifndef LATTICE
  char *login, *getlogin();
#endif
  int i;
#ifndef ATARI
  Font fontid
#else
  int fontid;
#endif
  int numgame = 0;
  int numscore = 0;
  int numscoreable = 0;	
  int player_scores = 0;
#ifndef ATARI
  int tries = MAX_RETRIES;
#endif
  Bool score_printed = False;
  Bool scoresonly = False;
  Bool wrong_version = False;
  Bool file_readable = False;
  Bool file_writeable = False;
  Bool practice = opt->practice;
#ifndef ATARI
  struct passwd* pw;
#endif
  void (*p)();

  version[0] ='\0';
  if (score < 0) {
    practice = True;
    scoresonly = True;
    p = nprintf;
  }
  else {
    p = xprintf;
    gprsetclippingactive(False);
#ifndef ATARI
    fontid = gprloadfontfile(GAMEOVERFONT);
    gprsettextfont(fontid);
#endif
    printstring (165, 300, "GAME OVER", 9);
#ifndef ATARI
    fontid = gprloadfontfile(GENERALFONT);
#else
	fontid = 0;
#endif
    gprsettextfont(fontid);

    printstring (165, 320, "1986 JSR", 8);
    flushwindow();
    sleep(1);
    clearentirescreen();
  }

  x = 350;
  y = 100;
  ydelta = 15;

  sprintf(buf,"%s%s",TANKDIR,SCOREFILE);
  sfile = fopen(buf,"r");	/* just check if it is there */

  if (sfile == NULL) {
    p("Score file not readable.", opt->output);
    if (scoresonly)
      return 1;
    else {
      p("Will try and create new scorefile.", opt->output);
    }
  }
  else
    file_readable = True;

  if (!scoresonly) {
    (void) signal(SIGINT, SIG_IGN); /* no leaving this routine */
#ifndef LATTICE
    (void) signal(SIGHUP, SIG_IGN); /* no how, no way */
#endif
    file_writeable = True;
    if (sfile != NULL)
      fclose(sfile);
    
  retry:
    if (file_readable)
      sfile = fopen(buf,"r+");	/* okay, now open for update */
    else
      sfile = fopen(buf,"w");
      
    if (sfile != NULL) {
#ifndef ATARI
/* Dont bother with file locking */
      if (flock(fileno(sfile),LOCK_EX) < 0) {
        if (errno == EWOULDBLOCK && AFS) {
          fclose(sfile);
          sleep(AFS_SLEEP);
          if (tries--)
            goto retry;
        }
        p("File not lockable, scores will not be saved.", opt->output);
        file_writeable = False;
      }
#endif
    }
    else {
      p("File not writeable, scores will not be saved.", opt->output);
      file_writeable = False;
    }

    /* okay, it's possible we could have closed the file and never
     * reopened it.  Also, we just may not have been able to lock
     * it.  In either case, lets close it again and then open only
     * for reading.
     */
    if (file_readable && !file_writeable) {
      if (sfile != NULL)
        fclose(sfile);
      if ((sfile = fopen(buf, "r")) == NULL)
        file_readable = False;
    }
  }

  if (!file_readable && !file_writeable) {
    p("Scorefile not readable or writeable...Goodbye!", opt->output);
    (void) signal(SIGINT, SIG_DFL); /* this would probably happen */
#ifndef LATTICE
    (void) signal(SIGHUP, SIG_DFL); /* on exit anyway             */
#endif
    if (!scoresonly)
      printandwait("Press any key to continue...", 0);
    return 1;
  }
  
  if (file_readable) {
    if(fgets(version,200,sfile) && file_writeable) {
      version[strlen(version)-1] = '\0'; /* strip the newline */
      if (strcmp(version,VERSION)) {
        wrong_version = True;
        p("Incorrect version played for this scorefile.", opt->output);
        p("Score not valid for inclusion.", opt->output);
        sprintf(buf,"Your version is \"%s\", while",VERSION);
        p(buf, opt->output);
        sprintf(buf, "  the scorefile version is \"%s\"", version);
        p(buf, opt->output);
      }
    }
    
    if (*version == '\0')
      strcpy(version,VERSION);

    if(fgets(buf,200,sfile))
      sscanf(buf,"%d %d",&numgame,&numscoreable);
    top_score = (struct score_struct*) malloc(sizeof(struct score_struct));
    current = top_score;
    
    while(fgets(buf,200,sfile) && numscore < NUMHIGH) 
      if (sscanf(buf,"%d %d %[^\n]",&current->score,
                 &current->uid,current->name) != 3) {
        p("Invalid line in score file...Skipping.", opt->output);
      }
      else {
        current->next = (struct score_struct*)
          malloc(sizeof(struct score_struct));
        prev_score = current;
        current = current->next;
        numscore ++;
      }
  }
  
  if (numscore)
    prev_score->next = NULL;
  else
    top_score = NULL;

  if (numgame < numscoreable)
    numgame = numscoreable;

  if (!scoresonly) {
    /* try to get it from the passwd file first, just in case this
     * person su'd from another acct.
     */

    player.score = score;
#ifndef ATARI
    player.uid = getuid();
    pw = getpwuid(player.uid);
    if (pw == NULL)
      if ((login = getlogin()) != NULL)
        strcpy(player.name, login);
      else {
        p("Can't find out who you are....bye.", opt->output);
        fclose(sfile);
        (void) signal(SIGINT, SIG_DFL);
        (void) signal(SIGHUP, SIG_DFL);
        if (!scoresonly) 
          printandwait("Press any key to continue...", 0);
        return 1;
      }
    else
      strcpy(player.name, pw->pw_name);
#else
	player.name[0]='@';
	/* returns different things under TOS and MTOS! */
	while ((player.name[0]=='@') || (player.name[0]==0)){
		strcpy(player.name,score_dialog());
	}
	clearentirescreen();
#endif
    if (numscore < NUMHIGH || player.score > prev_score->score) {
      score_printed = True;
      numscore++;
    
      for (current = top_score;
           current != NULL && player.score <= current->score;
           prev_score = current, current = current->next);
      
      player.next = current;
      
      if (current == top_score)
        top_score = &player;
      else
        prev_score->next = &player;
    }

    numgame++;
    if (!practice && !wrong_version)
      numscoreable++;
  }
  
  sprintf(buf, "High scores after %d games, %d scoreable:",
          numgame, numscoreable);
  p(buf, opt->output);
  current = top_score;
  while (current != NULL) {
    if (current == &player)
      *buf = '>';
    else
      *buf = ' ';
    sprintf(buf+1, "%-20s %8d", current->name, current->score);
    p(buf, opt->output);
    
    if (((wrong_version || practice) && current==&player) ||
        (current->uid==player.uid && !strcmp(player.name, current->name) &&
         ++player_scores>INDIVIDUAL_SCORES)) {
      numscore--;
      if (current == top_score) 
        top_score = current->next;
      else 
        prev_score->next = current->next;
    }
    else
      prev_score = current;
    current = current->next;
  }

  if (!scoresonly && !score_printed) {
    p("...", opt->output);
    sprintf(buf, ">%-20s %8d", player.name,player.score);
    p(buf, opt->output);
  }

  if (file_writeable) {
    rewind(sfile);
    fprintf(sfile,"%s\n",version);
    fprintf(sfile,"%d %d\n",numgame,numscoreable);
    for(current = top_score, i = 0;
        current != NULL && i < NUMHIGH;
        current = current->next, i++)
      fprintf(sfile,"%d %d %s\n",current->score,current->uid,current->name);
    if (practice) {
      y += ydelta;
      p("Your game was for practice only...", opt->output);
      p("For a valid score use:  cbzone [-q] [-d 0-5]", opt->output);
    }
  }
  
  fclose(sfile);
  (void) signal(SIGINT, SIG_DFL);
#ifndef LATTICE
  (void) signal(SIGHUP, SIG_DFL);
#endif



  if (!scoresonly){
     printandwait("Press any key when ready...", 0);
  }
#ifdef ATARI
  else{
     waitforkey(0);
  }
#endif  
  return 0;
}
