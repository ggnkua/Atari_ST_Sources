/*
 * Cbzone_config.h
 *  -- Todd W. Mummert, December 1990, CMU
 *
 * Only this file and the Makefile should need to be changed in
 * order to tailor the program to your system.
 */
/* Some defines for the score system.
 * The following is the name of the scorefile w/o the directory.
 */
#ifndef ATARI
#define SCOREFILE "cbzone.highscores"
#else
#define SCOREFILE "cbzone.hig"
#endif

/* The number of high scores saved, and how many any one        */
/* person can get.                                              */
#define NUMHIGH 20
#define INDIVIDUAL_SCORES 3

/*
 * Whatever paging file you want to use...more or less.
 * Give the complete path.  This program will be used to read
 * the message of the day and the helpfile.
 */
#define PAGER "/usr/ucb/more"

/*
 * these are the defaults...the conditions under which the game is
 * to be played to make the score file
 *
 * If you change these, change the defaults specified in cbzone.help
 */
#define MMISSILES 1
#define MTANKS 2
#define MLANDERS 4
#define MBLOCKS 8
#define DELAY 5
#define MSALVOS -1              /* don't change this value */

/*
 * How long any single tank can be around before we schedule
 * a missile attack.
 */
#define TANK_STRAND_COUNT 700

/* the following three defines are used because of the problems */
/* with flock() over AFS (Andrew File System).  In general, it  */
/* shouldn't hurt to have these set.                            */
#define AFS 1
#define MAX_RETRIES 5
#define AFS_SLEEP 2

/* if this is defined then the average time through the main loop */
/* is printed when the game ends (subject to opt->output)         */
/*#define DEVELOPER */

/* function prototypes may be useful */
#define FunctionPrototypes 0


/* now we need the following fonts                                */
/*                                                                */
/* this font is for the Battle Zone message and the joystick      */
/* directions                                                     */
#define TITLEFONT "-*-courier-medium-r-*--14-*-*-*-*-*-iso8859-1"
/* this font for the Game Over message                            */
#define GAMEOVERFONT "-*-courier-medium-r-*--24-*-*-*-*-*-iso8859-1"
/* this font for the Missile/Lander warning boxes and the         */
/* switch positions                                               */
#define CONTROLFONT "-*-fixed-medium-r-*--10-*-*-*-*-60-iso8859-1"
/* this font for the warning messages and the score file          */
#define GENERALFONT "-*-fixed-medium-r-*--15-*-*-*-*-90-iso8859-1"
/* This string is used to make sure that the scores that are saved
 * were played under the same rules.  If you change this, either
 * modify the first line of the scorefile, remove it completely
 * or just empty it.  Then either make the scorefile writeable, or
 * run this program suid (not an option on AFS).
 */
#define VERSION "Sun Jan 13 23:27:51 EST 1991"


