/*-------------------------------------------------------------------*/
/*                            "EAR TRAINER"                          */
/* David T. Jarvis                                  For the Atari ST */
/* Developed with Lattice C                                          */
/* Version 091787                                                    */
/*                                                                   */
/* (c) 1987 by Antic Publishing, Inc.                                */
/*                                                                   */
/* Modified to compile with Mark Williams C, 11/07/97, Antic Pub.    */
/*                                                                   */
/* Module:  Eartrain.c                               Main Program    */
/*-------------------------------------------------------------------*/

#include <stdio.h>               /* Standard I/O definitions         */
#include <osbind.h>              /* GEMDOS,BIOS,XBIOS macros         */

/* #include <gemlib.h> */        /* GEM definitions (Lattice C)      */

#include <obdefs.h>              /* Mark Williams C GEM stuff        */
#include <gemdefs.h>             /*       "                          */

#include <portab.h>              /* portable storage definitions     */
#include <eartrain.h>            /* program-specific declarations    */

/* ------- Data definitions ---------------------------------------- */

BYTE *mtitles[] =
   {  " Desk ", " File ", " Practice ", " Tests ", " Options " };

BYTE *moptions[] =
   {  "  Ear Trainer... ", "--------------------", "Acc 1", "Acc 2",
         "Acc 3", "Acc 4", "Acc 5", "Acc 6",
      "  Quit ",
      "  Intervals ", "  Chords ", "  Scales ", "  Melodies ",
      "  Intervals ", "  Chords ", "  Scales ", "  Melodies ",
      "  Scores   ", "  Status   "
   };

/* menu object specification */
OBJECT menu[] =
{
   { -1, 1, 8, G_IBOX,  NONE, NORMAL, 0L,        0, 0, 80,25 },
   {  8, 2, 2, G_BOX,   NONE, NORMAL, 0x1100L,   0, 0, 80, 1 },
   {  1, 3, 7, G_IBOX,  NONE, NORMAL, 0L,        2, 0, 38, 1 },
   {  4,-1,-1, G_TITLE, NONE, NORMAL, 0L,        0, 0,  6, 1 },
   {  5,-1,-1, G_TITLE, NONE, NORMAL, 0L,        6, 0,  6, 1 },
   {  6,-1,-1, G_TITLE, NONE, NORMAL, 0L,       12, 0, 10, 1 },
   {  7,-1,-1, G_TITLE, NONE, NORMAL, 0L,       22, 0,  7, 1 },
   {  2,-1,-1, G_TITLE, NONE, NORMAL, 0L,       29, 0,  9, 1 },
   {  0, 9,30, G_IBOX,  NONE, NORMAL, 0L,        0, 1, 80,12 },
   { 18,10,17, G_BOX,   NONE, NORMAL, 0xff1100L, 2, 0, 20, 8 },
   { 11,-1,-1, G_STRING,NONE, NORMAL, 0L,        0, 0, 20, 1 },
   { 12,-1,-1, G_STRING,NONE, DISABLED, 0L,      0, 1, 20, 1 },
   { 13,-1,-1, G_STRING,NONE, NORMAL, 0L,        0, 2, 20, 1 },
   { 14,-1,-1, G_STRING,NONE, NORMAL, 0L,        0, 3, 20, 1 },
   { 15,-1,-1, G_STRING,NONE, NORMAL, 0L,        0, 4, 20, 1 },
   { 16,-1,-1, G_STRING,NONE, NORMAL, 0L,        0, 5, 20, 1 },
   { 17,-1,-1, G_STRING,NONE, NORMAL, 0L,        0, 6, 20, 1 },
   {  9,-1,-1, G_STRING,NONE, NORMAL, 0L,        0, 7, 20, 1 },
   { 20,19,19, G_BOX,   NONE, NORMAL, 0xff1100L, 8, 0,  8, 1 },
   { 18,-1,-1, G_STRING,NONE, NORMAL, 0L,        0, 0,  8, 1 },
   { 25,21,24, G_BOX,   NONE, NORMAL, 0xff1100L,14, 0, 14, 4 },
   { 22,-1,-1, G_STRING,NONE, NORMAL, 0L,        0, 0, 14, 1 },
   { 23,-1,-1, G_STRING,NONE, NORMAL, 0L,        0, 1, 14, 1 },
   { 24,-1,-1, G_STRING,NONE, NORMAL, 0L,        0, 2, 14, 1 },
   { 20,-1,-1, G_STRING,NONE, NORMAL, 0L,        0, 3, 14, 1 },
   { 30,26,29, G_BOX,   NONE, NORMAL, 0xff1100L,24, 0, 14, 4 },
   { 27,-1,-1, G_STRING,NONE, NORMAL, 0L,        0, 0, 14, 1 },
   { 28,-1,-1, G_STRING,NONE, NORMAL, 0L,        0, 1, 14, 1 },
   { 29,-1,-1, G_STRING,NONE, NORMAL, 0L,        0, 2, 14, 1 },
   { 25,-1,-1, G_STRING,NONE, NORMAL, 0L,        0, 3, 14, 1 },
   {  8,31,32, G_BOX,   NONE, NORMAL, 0xff1100L,29, 0, 11, 2 },
   { 32,-1,-1, G_STRING,NONE, NORMAL, 0L,        0, 0, 11, 1 },
   { 30,-1,-1, G_STRING,NONE, NORMAL, 0L,        0, 1, 11, 1 }
};

/* form titles */
BYTE *ft0 = "INTERVAL TEST";
BYTE *ft1 = "CHORD TEST";
BYTE *ft2 = "SCALE TEST";
BYTE *ft3 = "MELODY TEST";
BYTE *ft4 = "INTERVAL PRACTICE";
BYTE *ft5 = "CHORD PRACTICE";
BYTE *ft6 = "SCALE PRACTICE";
BYTE *ft7 = "MELODY PRACTICE";

/* scale names, long and short interval names, note names, chord names */
BYTE *scalenames[] =
   {  "Major",
      "Natural Minor",
      "Harmonic Minor",
      "Melodic Minor",
      "Dorian",
      "Phrygian",
      "Lydian",
      "Mixolydian",
      "Chromatic"
   };
BYTE *intnames[] =
   {  "Perfect Unison", "Minor Second",   "Major Second",
      "Minor Third",    "Major Third",    "Perfect Fourth",
      "Tritone",  "Perfect Fifth",  "Minor Sixth",
      "Major Sixth",    "Minor Seventh",  "Major Seventh",
      "Perfect Octave"
   };
BYTE *chordnames[] =
   {  "Tonic", "SuperTonic", "Mediant", "SubDominant",
      "Dominant", "SubMediant", "SubTonic"
   };
BYTE *intcodes[] =
   {  "PU", "m2", "M2", "m3", "M3", "P4", "A4", "P5",
      "m6", "M6", "m7", "M7", "P8"
   };
BYTE *pnl[] =
   {  "C","C#","D","D#","E","F","F#","G","G#","A","A#","B","C"
   };
BYTE *anl[] =
   {  "C","D-","D","E-","E","F","G-","G","A-","A","B-","B","C"
   };
BYTE *chordcodes[] =
   {  "I", "ii", "iii", "IV", "V", "vi", "vii" };

/* form_alert() strings */
BYTE cstring[] = "[1][ | Correct! |  ][ OK ]";
BYTE wstring[] = "[2][ | Sorry... | That's Not Right.  Try Again. ][ OK ]";
BYTE istring[] =
 "[2][ You entered an invalid| melody...       | Try Again. ][ OK ]";
BYTE qstring[] =
 "[3][ |     Are You Sure?     |Score Will Be Discarded][  Yes  | Cancel ]";

/* length and notes of user entered sequence */
WORD useqlen;
WORD unotes[ MAXSEQ ];

/* form for interval test selection */
OBJECT i_form1[] =
{
   { -1,1, 18, G_BOX, NONE, OUTLINED, 0x21100L, 0, 0, 40, 22 },
   {  2,-1,-1, G_STRING, NONE, NORMAL, 0L, 14, 1, 14, 1 },
   {  3,-1,-1, G_STRING, NONE, NORMAL, 0L, 3, 3, 26, 1 },
   {  4,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 3,  5,  16, 1 },
   {  5,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 21, 5,  16, 1 },
   {  6,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 3,  7,  16, 1 },
   {  7,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 21, 7,  16, 1 },
   {  8,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 3,  9,  16, 1 },
   {  9,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 21, 9,  16, 1 },
   { 10,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 3,  11, 16, 1 },
   { 11,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 21, 11, 16, 1 },
   { 12,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 3,  13, 16, 1 },
   { 13,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 21, 13, 16, 1 },
   { 14,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 3,  15, 16, 1 },
   { 15,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 21, 15, 16, 1 },
   { 16,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 3,  17, 16, 1 },
   { 17,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 6,  20, 8,  1 },
   { 18,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 17, 20, 8,  1 },
   { 0,-1,-1, G_BUTTON, SELECTABLE|EXIT|LASTOB, NORMAL, 0L, 28, 20, 6,  1 }
};

/* form for interval practice selection */
OBJECT i_form2[] =
{
   { -1,1, 16, G_BOX, NONE, OUTLINED, 0x21100L, 0, 0, 40, 22 },
   {  2,-1,-1, G_STRING, NONE, NORMAL, 0L, 12, 1, 18, 1 },
   {  3,-1,-1, G_STRING, NONE, NORMAL, 0L, 3, 3, 27, 1 },
   {  4,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 3,  5,  16, 1 },
   {  5,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 21, 5,  16, 1 },
   {  6,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 3,  7,  16, 1 },
   {  7,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 21, 7,  16, 1 },
   {  8,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 3,  9,  16, 1 },
   {  9,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 21, 9,  16, 1 },
   { 10,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 3,  11, 16, 1 },
   { 11,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 21, 11, 16, 1 },
   { 12,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 3,  13, 16, 1 },
   { 13,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 21, 13, 16, 1 },
   { 14,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 3,  15, 16, 1 },
   { 15,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 21, 15, 16, 1 },
   { 16,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 3,  17, 16, 1 },
   { 0,-1,-1, G_BUTTON, SELECTABLE|EXIT|LASTOB, NORMAL, 0L, 16, 20, 8,  1 }
};

/* form for chord test selection */
OBJECT c_form1[] =
{
   { -1,1,13, G_BOX, NONE, OUTLINED, 0x21100L, 0, 0, 40, 16 },
   {  2,-1,-1, G_STRING, NONE, NORMAL, 0L, 15, 1, 11, 1 },
   {  3,-1,-1, G_STRING, NONE, NORMAL, 0L, 3, 3, 23, 1 },
   {  4,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 3,  5,  16, 1 },
   {  5,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 21, 5,  16, 1 },
   {  6,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 3,  7,  16, 1 },
   {  7,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 21, 7,  16, 1 },
   {  8,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 3,  9,  16, 1 },
   {  9,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 21, 9,  16, 1 },
   { 10,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 3,  11, 16, 1 },
   { 11,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 3,  14, 8,  1 },
   { 12,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 13, 14, 6,  1 },
   { 13,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 21, 14, 8,  1 },
   { 0,-1,-1, G_BUTTON, SELECTABLE|EXIT|LASTOB, NORMAL, 0L, 31, 14, 6,  1 }
};

/* form for chord practice selection */
OBJECT c_form2[] =
{
   { -1,1,11, G_BOX, NONE, OUTLINED, 0x21100L, 0, 0, 40, 16 },
   {  2,-1,-1, G_STRING, NONE, NORMAL, 0L, 13, 1, 11, 1 },
   {  3,-1,-1, G_STRING, NONE, NORMAL, 0L, 3, 3, 24, 1 },
   {  4,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 3,  5,  16, 1 },
   {  5,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 21, 5,  16, 1 },
   {  6,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 3,  7,  16, 1 },
   {  7,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 21, 7,  16, 1 },
   {  8,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 3,  9,  16, 1 },
   {  9,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 21, 9,  16, 1 },
   { 10,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 3,  11, 16, 1 },
   { 11,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 10, 14, 8,  1 },
   { 0,-1,-1, G_BUTTON, SELECTABLE|EXIT|LASTOB, NORMAL, 0L, 22, 14, 8,  1 }
};

/* form for scale test selection */
OBJECT s_form1[] =
{
   { -1,1,14, G_BOX, NONE, OUTLINED, 0x21100L, 0, 0, 40, 18 },
   {  2,-1,-1, G_STRING, NONE, NORMAL, 0L, 15, 1, 11, 1 },
   {  3,-1,-1, G_STRING, NONE, NORMAL, 0L, 3, 3, 23, 1 },
   {  4,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 3,  5,  16, 1 },
   {  5,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 21, 5,  16, 1 },
   {  6,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 3,  7,  16, 1 },
   {  7,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 21, 7,  16, 1 },
   {  8,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 3,  9,  16, 1 },
   {  9,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 21, 9,  16, 1 },
   { 10,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 3,  11, 16, 1 },
   { 11,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 21, 11, 16, 1 },
   { 12,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 3,  13, 16, 1 },
   { 13,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 6,  16, 8,  1 },
   { 14,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 17, 16, 8,  1 },
   { 0,-1,-1, G_BUTTON, SELECTABLE|EXIT|LASTOB, NORMAL, 0L, 28, 16, 6, 1 }
};

/* form for scale practice selection */
OBJECT s_form2[] =
{
   { -1,1,12, G_BOX, NONE, OUTLINED, 0x21100L, 0, 0, 40, 18 },
   {  2,-1,-1, G_STRING, NONE, NORMAL, 0L, 13, 1, 11, 1 },
   {  3,-1,-1, G_STRING, NONE, NORMAL, 0L, 3, 3, 24, 1 },
   {  4,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 3,  5,  16, 1 },
   {  5,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 21, 5,  16, 1 },
   {  6,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 3,  7,  16, 1 },
   {  7,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 21, 7,  16, 1 },
   {  8,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 3,  9,  16, 1 },
   {  9,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 21, 9,  16, 1 },
   { 10,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 3,  11, 16, 1 },
   { 11,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 21, 11, 16, 1 },
   { 12,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 3,  13, 16, 1 },
   { 0,-1,-1, G_BUTTON, SELECTABLE|EXIT|LASTOB, NORMAL, 0L, 16, 16, 8, 1 }
};

/* structures for melody test selection form */
TEDINFO ted1 = { 0L, 0L, 0L, 3, 6, 0, 0x1180, 0, 255, 35, 35 };
BYTE mstr0[] = "\0                                 ";
BYTE mstr1[] = "__________________________________";
BYTE mstr2[] = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";

OBJECT m_form1[] =
{
   { -1, 1, 7, G_BOX, NONE, OUTLINED, 0x21100L, 0, 0, 40, 12 },
   {  2,-1,-1, G_STRING, NONE, NORMAL, 0L, 14, 1, 14, 1 },
   {  3,-1,-1, G_STRING, NONE, NORMAL, 0L, 3, 3, 24, 1 },
   {  4,-1,-1, G_FTEXT,  EDITABLE, NORMAL, 0L, 3,  5,  34, 1 },
   {  5,-1,-1, G_BUTTON, SELECTABLE|EXIT|DEFAULT, NORMAL, 0L, 18, 7, 4, 1 },
   {  6,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 6,  10, 8,  1 },
   {  7,-1,-1, G_BUTTON, SELECTABLE|EXIT, NORMAL, 0L, 17, 10, 8,  1 },
   {  0,-1,-1, G_BUTTON, SELECTABLE|EXIT|LASTOB, NORMAL, 0L, 28, 10, 6,  1 }
};

/* form for melody practice */
OBJECT m_form2[] =
{
   { -1, 1, 5, G_BOX, NONE, OUTLINED, 0x21100L, 0, 0, 40, 12 },
   {  2,-1,-1, G_STRING, NONE, NORMAL, 0L, 14, 1, 14, 1 },
   {  3,-1,-1, G_STRING, NONE, NORMAL, 0L, 3, 3, 22, 1 },
   {  4,-1,-1, G_FTEXT,  EDITABLE, NORMAL, 0L, 3,  5,  34, 1 },
   {  5,-1,-1, G_BUTTON, SELECTABLE|EXIT|DEFAULT, NORMAL, 0L, 18, 7, 4, 1 },
   {  0,-1,-1, G_BUTTON, SELECTABLE|EXIT|LASTOB, NORMAL, 0L, 16, 10, 8,  1 }
};

/* form for status changes */
OBJECT st_form[] =
{
   { -1, 1,11, G_BOX,    NONE, OUTLINED, 0x21100L,              0, 0, 40,17 },
   {  2,-1,-1, G_STRING, NONE, NORMAL, 0L,                     10, 1, 19, 1 },
   {  3,-1,-1, G_STRING, NONE, NORMAL, 0L,                      3, 3, 18, 1 },
   {  4,-1,-1, G_STRING, NONE, NORMAL, 0L,                      3, 6, 15, 1 },
   {  5,-1,-1, G_STRING, NONE, NORMAL, 0L,                      3, 9, 26, 1 },
   {  6,-1,-1, G_STRING, NONE, NORMAL, 0L,                      3,12, 28, 1 },
   {  7,-1,-1, G_BUTTON, SELECTABLE|EXIT,NORMAL,0L,            15,15,  8, 1 },
   {  8,-1,-1, G_BUTTON, SELECTABLE|EXIT|DEFAULT,NORMAL,0L,    28,15,  8, 1 },
   {  9,12,14, G_IBOX,   NONE, NORMAL, 0L,                      1, 4, 38, 1 },
   { 10,15,17, G_IBOX,   NONE, NORMAL, 0L,                      1, 7, 38, 1 },
   { 11,18,19, G_IBOX,   NONE, NORMAL, 0L,                      1,10, 38, 1 },
   {  0,20,21, G_IBOX,   NONE, NORMAL, 0L,                      1,13, 38, 1 },
   { 13,-1,-1, G_BUTTON, RBUTTON|SELECTABLE,SELECTED,0L,        2, 0,  8, 1 },
   { 14,-1,-1, G_BUTTON, RBUTTON|SELECTABLE,NORMAL,0L,         12, 0, 12, 1 },
   {  8,-1,-1, G_BUTTON, RBUTTON|SELECTABLE,NORMAL,0L,         26, 0, 10, 1 },
   { 16,-1,-1, G_BUTTON, RBUTTON|SELECTABLE,SELECTED,0L,        2, 0,  8, 1 },
   { 17,-1,-1, G_BUTTON, RBUTTON|SELECTABLE,NORMAL,0L,         12, 0,  7, 1 },
   {  9,-1,-1, G_BUTTON, RBUTTON|SELECTABLE,NORMAL,0L,         21, 0,  7, 1 },
   { 19,-1,-1, G_BUTTON, RBUTTON|SELECTABLE,NORMAL,0L,          2, 0, 12, 1 },
   { 10,-1,-1, G_BUTTON, RBUTTON|SELECTABLE,SELECTED,0L,       16, 0, 12, 1 },
   { 21,-1,-1, G_BUTTON, RBUTTON|SELECTABLE,NORMAL,0L,          2, 0, 12, 1 },
   { 11,-1,-1, G_BUTTON, RBUTTON|SELECTABLE|LASTOB,SELECTED,0L,16, 0, 12, 1 }
};

/* Form for 'about' option */
OBJECT a_form[] =
{
   { -1, 1, 5, G_BOX,    NONE,  OUTLINED,  0x21100L, 0, 0, 30,14 },
   {  2,-1,-1, G_STRING, NONE,  NORMAL,    0L,       4, 2, 23, 1 },
   {  3,-1,-1, G_STRING, NONE,  NORMAL,    0L,      14, 5,  3, 1 },
   {  4,-1,-1, G_STRING, NONE,  NORMAL,    0L,       7, 6, 17, 1 },
   {  5,-1,-1, G_STRING, NONE,  NORMAL,    0L,      13, 7,  5, 1 },
   {  0,-1,-1, G_BUTTON, SELECTABLE|EXIT|LASTOB,SHADOWED,0L,11,10,8,1 }
};

/* Form for 'scores' option */
OBJECT sc_form[] =
{
   { -1, 1,10, G_BOX,    NONE,  OUTLINED,  0x21100L, 0, 0, 30,15 },
   {  2,-1,-1, G_STRING, NONE,  NORMAL,    0L,       3, 2, 24, 1 },
   {  3,-1,-1, G_STRING, NONE,  NORMAL,    0L,       5, 4, 14, 1 },
   {  4,-1,-1, G_STRING, NONE,  NORMAL,    0L,       5, 6, 14, 1 },
   {  5,-1,-1, G_STRING, NONE,  NORMAL,    0L,       5, 8, 14, 1 },
   {  6,-1,-1, G_STRING, NONE,  NORMAL,    0L,       5,10, 14, 1 },
   {  7,-1,-1, G_STRING, NONE,  NORMAL,    0L,      18, 4,  7, 1 },
   {  8,-1,-1, G_STRING, NONE,  NORMAL,    0L,      18, 6,  7, 1 },
   {  9,-1,-1, G_STRING, NONE,  NORMAL,    0L,      18, 8,  7, 1 },
   { 10,-1,-1, G_STRING, NONE,  NORMAL,    0L,      18,10,  7, 1 },
   {  0,-1,-1, G_BUTTON, SELECTABLE|EXIT|LASTOB,NORMAL,0L,5,13,20,1 }
};

/* form position variables */
WORD i1_x, i1_y, i1_w, i1_h;
WORD i2_x, i2_y, i2_w, i2_h;
WORD c1_x, c1_y, c1_w, c1_h;
WORD c2_x, c2_y, c2_w, c2_h;
WORD s1_x, s1_y, s1_w, s1_h;
WORD s2_x, s2_y, s2_w, s2_h;
WORD m1_x, m1_y, m1_w, m1_h;
WORD m2_x, m2_y, m2_w, m2_h;
WORD st_x, st_y, st_w, st_h;
WORD a1_x, a1_y, a1_w, a1_h;
WORD sc_x, sc_y, sc_w, sc_h;

/* Miscellaneous test variables */
WORD level=EASY,                 /* difficulty level              */
     score[ NUM_TESTS ],         /* last score for each test      */
     maxtries,                   /* number of tries allowed       */
     seqlen,                     /* current melodies length       */
     curscale,                   /* current working scale         */
     rmax,                       /* current maximum replays       */
     octrange;                   /* range (+-) for note octaves   */

WORD contrl[12],                 /* Global GEM variables          */
     intin[256], intout[256],
     ptsin[256], ptsout[256],
     workin[20], workout[100],
     handle, dvar;               /* Screen handle; dummy var.     */
WORD msg_buffer[ 8 ];            /* AES message buffer            */
WORD port_state;                 /* Saves current port state      */
WORD wb_flag=1, wr_flag=1;       /* determines if noises made     */
LONG s_factor=1000L;             /* speed factor                  */
/* LONG z; */                    /* for random number seeding     */

WORD z; /* MW */

/* --------- function declarations ------------------------------ */

BYTE *strcpy(), *strcat(), *stpchr(), *stpblk();
WORD seqcmp(), convert_seq();
void init_vars(), init_work(), init_menu(), init_form(),
     status(), about(), dis_scores(), tonality();

extern WORD wrong_alert(), next_alert(), score_alert(), answer_alert(),
            rand_sign(), rand_key(), rand_mnote();
extern WORD intervals(), chords(), chords(), scales(), melodies();
/* extern LONG rand_int(); */
extern WORD rand_int();

extern void rest(), play_scale(), play_int(), play_mel(),
            sound_on(), sound_off(), nobell();
extern void empt_box(), full_box(), dial_start(), dial_away();
extern void notemouse(), normouse();
extern void p_intervals(), p_chords(), p_scales(), p_melodies();

/* ---------------- main program -------------------------------- */

main()
{
WORD done=0, title, index, i, ret;

/* Initialize application & special structures */
   init_work();
   init_menu();
   init_form();

/* Initialize sound chip;  enable voices a,b, and c */
   sound_off();
   port_state = Giaccess( 0, CH_ENA_R  );
   Giaccess( (port_state & 0xc0) | 0x38, CH_ENA_W );
   Giaccess( 10, RG_ENV_W  );
   Giaccess( 0, RG_WAV_W  );

/* This ain't no peace prize */
   Supexec( nobell );

/* Reseed random function */
   z = (WORD)Gettime();
   srand( z );

/* Initialize scores, difficulty level, speed factor, other variables */
   for ( i = 0; i < NUM_TESTS; i++ )
      score[ i ] = 0;
   level = EASY;
   s_factor = 1000L;
   init_vars();

/* Display the menu;  give the credit;  repeatedly process options */
   menu_bar( menu,1 );
   graf_mouse( ARROW,0 );
   about();
   a_form[ 5 ].ob_spec = (LONG)"Go On";
   do
      {
      evnt_mesag( msg_buffer );
      if (msg_buffer[ 0 ] = MN_SELECTED)
         {
         title = msg_buffer[ 3 ];
         index = msg_buffer[ 4 ];
         switch( index )
            {
            case 10: about();
                     break;
            case 19: done = 1;
                     break;
            case 21: p_intervals();
                     break;
            case 22: p_chords();
                     break;
            case 23: p_scales();
                     break;
            case 24: p_melodies();
                     break;
            case 26: if (ret = intervals())
                        score[ 0 ] = ret;
                     break;
            case 27: if (ret = chords())
                        score[ 1 ] = ret;
                     break;
            case 28: if (ret = scales())
                        score[ 2 ] = ret;
                     break;
            case 29: if (ret = melodies())
                        score[ 3 ] = ret;
                     break;
            case 31: dis_scores();
                     break;
            case 32: status();
                     init_vars();
                     break;
            }
         menu_tnormal( menu,title,1 );
         }
      } while (!done);

/* Turn off the sound chip, restore initial state */
   Giaccess( port_state, CH_ENA_W );

/* Close application and exit */
   v_clsvwk( handle );
   appl_exit();
}

/* ------------- function definitions ----------------------------- */

/* init_work() sets up the workstation and sets resolution factors */
void init_work()
{
WORD i;

/* Initialize application */
   appl_init();
   handle=graf_handle( &dvar, &dvar, &dvar, &dvar );
   for ( i = 0;  i < 10;  workin[ i++ ]=1 );
   workin[ 10 ] = 2;
   v_opnvwk( workin, &handle, workout );
}

/* init_vars() -- initialize program variables */
void init_vars()
{
/* Set up variables related to tests */
   switch( level )
      {
      case EASY:
            maxtries      = 4;
            curscale      = MAJOR;
            octrange      = 0;
            seqlen        = 4;
            rmax          = 5;
            break;
      case INTERMEDIATE:
            maxtries      = 3;
            curscale      = MAJOR;
            octrange      = 0;
            seqlen        = 7;
            rmax          = 3;
            break;
      case ADVANCED:
            maxtries      = 2;
            curscale      = CHROMATIC;
            octrange      = 1;
            seqlen        = 10;
            rmax          = 1;
            break;
      }
}

/* init_menu() converts the menu tree into a usable structure */
void init_menu()
{
WORD i;

/* prepare the menu for use */
   for (i=0; i<5; i++)
      menu[ i+3 ].ob_spec = (LONG)mtitles[ i ];
   for (i=0; i<8; i++)
      menu[ i+10].ob_spec = (LONG)moptions[ i ];
   menu[ 19 ].ob_spec = (LONG)moptions[ 8 ];
   for (i=9; i<13; i++)
      menu[ i+12 ].ob_spec = (LONG)moptions[ i ];
   for (i=13; i<17; i++)
      menu[ i+13 ].ob_spec = (LONG)moptions[ i ];
   menu[ 31 ].ob_spec = (LONG)moptions[ 17 ];
   menu[ 32 ].ob_spec = (LONG)moptions[ 18 ];
   for (i=0; i<33; i++)
      rsrc_obfix(menu,i);
   menu[ 1 ].ob_height += 2;
   for (i=2; i<8; i++)
      menu[ i ].ob_height += 3;
   menu[ 8 ].ob_y += 3;
   menu[ 30 ].ob_width -= 2;
   menu[ 31 ].ob_width -= 2;
   menu[ 32 ].ob_width -= 2;
}

/* init_form() performs the necessary conversations and initializations
   on program dialog boxes
*/
void init_form()
{
WORD i;

/* prepare the interval test form */
   i_form1[ 1 ].ob_spec = (LONG)ft0;
   i_form1[ 2 ].ob_spec = (LONG)"What Interval Was Played?";
   for (i=0; i<13; i++)
      i_form1[ i+3 ].ob_spec = (LONG)intnames[ i ];
   i_form1[ 16 ].ob_spec = (LONG)"Replay";
   i_form1[ 17 ].ob_spec = (LONG)"Give Up";
   i_form1[ 18 ].ob_spec = (LONG)"Quit";
   for (i=0; i<19; i++)
      rsrc_obfix(i_form1, i);
   form_center( i_form1, &i1_x, &i1_y, &i1_w, &i1_h );

/* prepare the interval practice form */
   i_form2[ 1 ].ob_spec = (LONG)ft4;
   i_form2[ 2 ].ob_spec = (LONG)"Please Select An Interval:";
   for (i=0; i<13; i++)
      i_form2[ i+3 ].ob_spec = (LONG)intnames[ i ];
   i_form2[ 16 ].ob_spec = (LONG)"Quit";
   for (i=0; i<17; i++)
      rsrc_obfix(i_form2, i);
   form_center( i_form2, &i2_x, &i2_y, &i2_w, &i2_h );

/* prepare the chord test form */
   c_form1[ 1 ].ob_spec = (LONG)ft1;
   c_form1[ 2 ].ob_spec = (LONG)"What Chord Was Played?";
   for (i=0; i<7; i++)
      c_form1[ i+3 ].ob_spec = (LONG)chordnames[ i ];
   c_form1[ 10 ].ob_spec = (LONG)"Replay";
   c_form1[ 11 ].ob_spec = (LONG)"Key";
   c_form1[ 12 ].ob_spec = (LONG)"Give Up";
   c_form1[ 13 ].ob_spec = (LONG)"Quit";
   for (i=0; i<14; i++)
      rsrc_obfix(c_form1, i);
   form_center( c_form1, &c1_x, &c1_y, &c1_w, &c1_h );

/* prepare the chord practice form */
   c_form2[ 1 ].ob_spec = (LONG)ft5;
   c_form2[ 2 ].ob_spec = (LONG)"Please Select A Chord:";
   for (i=0; i<7; i++)
      c_form2[ i+3 ].ob_spec = (LONG)chordnames[ i ];
   c_form2[ 10 ].ob_spec = (LONG)"Key";
   c_form2[ 11 ].ob_spec = (LONG)"Quit";
   for (i=0; i<12; i++)
      rsrc_obfix(c_form2, i);
   form_center( c_form2, &c2_x, &c2_y, &c2_w, &c2_h );

/* prepare the scale test form */
   s_form1[ 1 ].ob_spec = (LONG)ft2;
   s_form1[ 2 ].ob_spec = (LONG)"What Scale Was Played?";
   for (i=0; i<9; i++)
      s_form1[ i+3 ].ob_spec = (LONG)scalenames[ i ];
   s_form1[ 12 ].ob_spec = (LONG)"Replay";
   s_form1[ 13 ].ob_spec = (LONG)"Give Up";
   s_form1[ 14 ].ob_spec = (LONG)"Quit";
   for (i=0; i<15; i++)
      rsrc_obfix(s_form1, i);
   form_center( s_form1, &s1_x, &s1_y, &s1_w, &s1_h );

/* prepare the scale practice form */
   s_form2[ 1 ].ob_spec = (LONG)ft6;
   s_form2[ 2 ].ob_spec = (LONG)"Please Select A Scale:";
   for (i=0; i<9; i++)
      s_form2[ i+3 ].ob_spec = (LONG)scalenames[ i ];
   s_form2[ 12 ].ob_spec = (LONG)"Quit";
   for (i=0; i<13; i++)
      rsrc_obfix(s_form2, i);
   form_center( s_form2, &s2_x, &s2_y, &s2_w, &s2_h );

/* prepare the melody test form */
   m_form1[ 1 ].ob_spec = (LONG)ft3;
   m_form1[ 2 ].ob_spec = (LONG)"Enter The Melody Below:";
   m_form1[ 3 ].ob_spec = (LONG)&ted1;
   m_form1[ 4 ].ob_spec = (LONG)"OK";
   m_form1[ 5 ].ob_spec = (LONG)"Replay";
   m_form1[ 6 ].ob_spec = (LONG)"Give Up";
   m_form1[ 7 ].ob_spec = (LONG)"Quit";
   ted1.te_ptext = (LONG)mstr0;
   ted1.te_ptmplt = (LONG)mstr1;
   ted1.te_pvalid = (LONG)mstr2;
   for (i=0; i<8; i++)
      rsrc_obfix( m_form1,i );
   form_center( m_form1, &m1_x, &m1_y, &m1_w, &m1_h );

/* prepare the melody practice form */
   m_form2[ 1 ].ob_spec = (LONG)ft7;
   m_form2[ 2 ].ob_spec = (LONG)"Enter A Melody Below:";
   m_form2[ 3 ].ob_spec = (LONG)&ted1;
   m_form2[ 4 ].ob_spec = (LONG)"OK";
   m_form2[ 5 ].ob_spec = (LONG)"Quit";
   for (i=0; i<6; i++)
      rsrc_obfix( m_form2,i );
   form_center( m_form2, &m2_x, &m2_y, &m2_w, &m2_h );

/* prepare the options form */
   st_form[ 1 ].ob_spec = (LONG)"EAR TRAINER STATUS";
   st_form[ 2 ].ob_spec = (LONG)"Difficulty Level:";
   st_form[ 3 ].ob_spec = (LONG)"Playing Speed:";
   st_form[ 4 ].ob_spec = (LONG)"Signal For Wrong Choices:";
   st_form[ 5 ].ob_spec = (LONG)"Signal For Correct Choices:";
   st_form[ 6 ].ob_spec = (LONG)"OK";
   st_form[ 7 ].ob_spec = (LONG)"Cancel";
   st_form[ 12 ].ob_spec = (LONG)"Beginner";
   st_form[ 13 ].ob_spec = (LONG)"Intermediate";
   st_form[ 14 ].ob_spec = (LONG)"Advanced";
   st_form[ 15 ].ob_spec = (LONG)"Slow";
   st_form[ 16 ].ob_spec = (LONG)"Medium";
   st_form[ 17 ].ob_spec = (LONG)"Fast";
   st_form[ 18 ].ob_spec = (LONG)"Signal On";
   st_form[ 19 ].ob_spec = (LONG)"Signal Off";
   st_form[ 20 ].ob_spec = (LONG)"Signal On";
   st_form[ 21 ].ob_spec = (LONG)"Signal Off";
   for (i=0; i<22; i++)
      rsrc_obfix(st_form, i);
   st_form[ 2 ].ob_y    -= 2;
   st_form[ 3 ].ob_y    -= 2;
   st_form[ 4 ].ob_y    -= 2;
   st_form[ 5 ].ob_y    -= 2;
   form_center( st_form, &st_x, &st_y, &st_w, &st_h );

/* Prepare the 'about' form */
   a_form[ 1 ].ob_spec = (LONG)"E A R   T R A I N E R";
   a_form[ 2 ].ob_spec = (LONG)"by";
   a_form[ 3 ].ob_spec = (LONG)"David T. Jarvis";
   a_form[ 4 ].ob_spec = (LONG)"1987";
   a_form[ 5 ].ob_spec = (LONG)"Begin";
   for (i=0; i<6; i++)
      rsrc_obfix( a_form,i );
   form_center( a_form,&a1_x,&a1_y,&a1_w,&a1_h );
   a_form[ 1 ].ob_x += 4;

/* Prepare the 'scores' form */
   sc_form[ 1 ].ob_spec = (LONG)"MOST RECENT TEST SCORES";
   sc_form[ 2 ].ob_spec = (LONG)"Intervals  : ";
   sc_form[ 3 ].ob_spec = (LONG)"Chords     : ";
   sc_form[ 4 ].ob_spec = (LONG)"Scales     : ";
   sc_form[ 5 ].ob_spec = (LONG)"Melodies   : ";
   sc_form[ 6 ].ob_spec = (LONG)"      ";
   sc_form[ 7 ].ob_spec = (LONG)"      ";
   sc_form[ 8 ].ob_spec = (LONG)"      ";
   sc_form[ 9 ].ob_spec = (LONG)"      ";
   sc_form[ 10 ].ob_spec = (LONG)"       Thanks!      ";
   for (i=0; i<11; i++)
      rsrc_obfix( sc_form,i );
   form_center( sc_form,&sc_x,&sc_y,&sc_w,&sc_h );
}

/* status() allows user to view/modify selected status items */
void status()
{
WORD choice, i;

/* Initialize the form */
   for (i=12; i<22; i++)
      st_form[ i ].ob_state = NORMAL;
   st_form[ level+11 ].ob_state = SELECTED;
   switch( (WORD)s_factor)
      {
      case 500  :  st_form[ 17 ].ob_state = SELECTED;
                     break;

      case 1000 :  st_form[ 16 ].ob_state = SELECTED;
                     break;

      case 2000 :
      default   :  st_form[ 15 ].ob_state = SELECTED;
                   break;
      }
   if (wb_flag)
      st_form[ 18 ].ob_state = SELECTED;
   else
      st_form[ 19 ].ob_state = SELECTED;
   if (wr_flag)
      st_form[ 20 ].ob_state = SELECTED;
   else
      st_form[ 21 ].ob_state = SELECTED;

/* Allow the user to view/change status items */
   dial_start( st_form,st_x,st_y,st_w,st_h,2 );
   choice = form_do( st_form,0 );
   objc_change( st_form,choice,0,st_x,st_y,st_w,st_h,NORMAL,0 );
   if (choice == 6)     /* OK */
      /* Assign new form status to appropriate variables */
      {
      for (i=12; i<15; i++)
         if (st_form[ i ].ob_state == SELECTED)
            break;
      level = i - 11;
      for (i=15; i<18; i++)
         if (st_form[ i ].ob_state == SELECTED)
            break;
      switch( i )
         {
         case 15: s_factor = 2000L;
                  break;
         case 16: s_factor = 1000L;
                  break;
         case 17: s_factor = 500L;
                  break;
         }
      if (st_form[ 18 ].ob_state == SELECTED)
         wb_flag = 1;
      else
         wb_flag = 0;
      if (st_form[ 20 ].ob_state == SELECTED)
         wr_flag = 1;
      else
         wr_flag = 0;
      }
   dial_away( st_form,st_x,st_y,st_w,st_h );
}

/* about() gives info about EAR TRAINER and its author */
void about()
{
   dial_start( a_form,a1_x,a1_y,a1_w,a1_h,1 );
   form_do( a_form,0 );
   objc_change( a_form,5,0,a1_x,a1_y,a1_w,a1_h,SHADOWED,0 );
   dial_away( a_form,a1_x,a1_y,a1_w,a1_h );
}

/* dis_scores() displays the most recent test scores for all tests */
void dis_scores()
{
WORD i;

/* Put the most recent scores into the form */
   for (i=0; i<NUM_TESTS; i++)
      sprintf( (BYTE *)sc_form[ i+6 ].ob_spec,"%2d/%2d ",score[ i ],TESTLEN );
   dial_start( sc_form,sc_x,sc_y,sc_w,sc_h,1 );
   form_do( sc_form,0 );
   objc_change( sc_form,10,0,sc_x,sc_y,sc_w,sc_h,NORMAL,0 );
   dial_away( sc_form,sc_x,sc_y,sc_w,sc_h );
}

/* ------- function definitions for ear training tests ------------ */

/* intervals() gives the user an interval test
   and returns a score or 0
*/
WORD intervals()
{
WORD i_score = 0,    trycount,      rcount,
     problem,        correct,       ret,
     inotes[ 2 ],    octs[ 2 ],     myval,
     choice,         intval;

/* Initialize the starting note and octave */
if (level == EASY)
   {
   octs[ 0 ]   = rand_int(OCTBASE-octrange,OCTBASE+octrange);
   inotes[ 0 ] = rand_int( 0,11 );
   }

/* Execute the dialog */
i_form1[ 16 ].ob_state = NORMAL;
dial_start( i_form1,i1_x,i1_y,i1_w,i1_h,1 );
for (problem=0; problem < TESTLEN; problem++)
   {
   /* compute new interval and notes */
   if (level >= INTERMEDIATE)
      {
   octs[ 0 ]   = rand_int(OCTBASE-1,OCTBASE+1);
   inotes[ 0 ] = rand_int(0,11);
      }
   octs[ 1 ]   = rand_int( octs[0],(octs[0]+octrange) );
   intval      = rand_int( 0,11 );

   inotes[ 1 ] = inotes[ 0 ] + intval;
   if (inotes[ 1 ] > 11)
      {
      octs[ 1 ]++;
      inotes[ 1 ] -= 12;
      }
   next_alert( "Interval",problem+1 );
   notemouse();
   Giaccess( (port_state & 0xc0) | 0x38, CH_ENA_W );
   Giaccess( 10, RG_ENV_W  );
   Giaccess( 0, RG_WAV_W  );
   play_int( inotes, octs );
   normouse();

   /* This loop handles entry of choices */
   correct = 0;      myval = 0;     trycount = 0;     rcount = 0;
   do {
      choice = form_do( i_form1,0 );
      switch( choice )
         {
         case 16:    notemouse();
                     play_int( inotes,octs );
                     normouse();
                     rcount++;
                     if (rcount >= rmax)
                        {
                        objc_change( i_form1,16,0,i1_x,i1_y,i1_w,i1_h,
                                     DISABLED,1 );
                        objc_draw( i_form1,0,1,i1_x,i1_y,i1_w,i1_h );
                        }
                     else
                        objc_change( i_form1,16,0,i1_x,i1_y,i1_w,i1_h,
                                     NORMAL,1 );
                     break;
         case 17:    myval = -1;
                     trycount = maxtries;
                     answer_alert( intnames[ intval ] );
                     break;
         case 18:    ret = form_alert(2,qstring);
                     if (ret==1)
                        {
                        objc_change( i_form1,choice,0,i1_x,i1_y,i1_w,i1_h,
                                     NORMAL,0 );
                        dial_away( i_form1,i1_x,i1_y,i1_w,i1_h );
                        return( 0 );
                        }
                     break;
         default:    myval = choice - 3;
                     trycount++;
                     if (myval == intval)
                        {
                        correct = 1;
                        if (wr_flag) rightnoise();
                        form_alert(1,cstring);
                        i_score++;
                        }
                     else
                        if (trycount < maxtries)
                           form_alert(1,wstring);
                     break;
         }
      if (choice != 16)
         objc_change( i_form1,choice,0,i1_x,i1_y,i1_w,i1_h,NORMAL,1 );
      } while ((trycount<maxtries)&&(!correct));
   objc_change( i_form1,16,0,i1_x,i1_y,i1_w,i1_h,NORMAL,1 );
   if (!correct)
      {
      if (myval != -1)
         {
         if (wb_flag) wrongnoise();
         ret = wrong_alert(intnames[myval],intcodes[myval],intnames[intval]);
         if (ret == 1)
            {
            inotes[ 1 ] = inotes[ 0 ] + myval;
            octs[ 1 ] = octs[ 0 ];
            if (inotes[ 1 ] > 11)
               {
               octs[ 1 ]++;
               inotes[ 1 ] -= 12;
               }
            notemouse();
            play_int( inotes, octs );
            normouse();
            }
         }
      }
   }
score_alert( i_score );
dial_away( i_form1,i1_x,i1_y,i1_w,i1_h );
return( i_score );
}

/* chords() gives the user a chords test and returns a score or 0 */
WORD chords()
{
WORD c_score = 0,    trycount,      rcount,
     problem,        i,             correct,
     key,            ret,           choice,
     octs[ NUM_VOICES ],            myval,
     cval;

/* establish working environment for this test */
key = rand_key();

/* Execute the dialog */
c_form1[ 10 ].ob_state = NORMAL;
dial_start( c_form1,c1_x,c1_y,c1_w,c1_h,1 );
Giaccess( (port_state & 0xc0) | 0x38, CH_ENA_W );
Giaccess( 10, RG_ENV_W  );
Giaccess( 0, RG_WAV_W  );
tonality( key,CHORDLEN );
for (problem=0; problem < TESTLEN; problem++)
   {
   /* compute new chord and octaves */
   octs[ 0 ] = rand_int(OCTBASE-octrange,OCTBASE+octrange);
   cval = rand_int(0,6);
   for (i=1; i<NUM_VOICES; i++)
      octs[ i ] = rand_int( octs[0],(octs[0]+octrange) );
   next_alert( "Chord",problem+1 );
   notemouse();
   play_chord( cval,key,octs,NUM_VOICES,CHORDLEN );
   normouse();

   /* Present the dialog box for chord selection */
   correct = 0;      trycount = 0;        rcount = 0;       myval = 0;
   do
      {
      choice=form_do( c_form1,0 );
      switch( choice )
         {
         case 10: notemouse();
                  play_chord( cval,key,octs,NUM_VOICES,CHORDLEN );
                  normouse();
                  rcount++;
                  if (rcount >= rmax)
                     {
                     objc_change( c_form1,10,0,c1_x,c1_y,c1_w,c1_h,
                                  DISABLED,1 );
                     objc_draw( c_form1,0,1,c1_x,c1_y,c1_w,c1_h );
                     }
                  else
                     objc_change( c_form1,10,0,c1_x,c1_y,c1_w,c1_h,
                                  NORMAL,1 );
                  break;
         case 11: tonality( key,CHORDLEN );
                  break;
         case 12: myval = -1;
                  trycount = maxtries;
                  answer_alert( chordnames[ cval ] );
                  break;
         case 13: ret = form_alert(2,qstring);
                  if (ret==1)
                     {
                     objc_change( c_form1,choice,0,c1_x,c1_y,c1_w,c1_h,
                                  NORMAL,0 );
                     dial_away(c_form1,c1_x,c1_y,c1_w,c1_h );
                     return(0);
                     }
                  break;
         default: myval = choice - 3;
                  trycount++;
                  if (myval == cval)
                     {
                     correct = 1;
                     if (wr_flag) rightnoise();
                     form_alert(1,cstring);
                     c_score++;
                     }
                  else
                     if (trycount < maxtries)
                        form_alert(1,wstring);
                  break;
               }
         if (choice != 10)
            objc_change( c_form1,choice,0,c1_x,c1_y,c1_w,c1_h,NORMAL,1 );
         } while ((trycount < maxtries)&&(!correct));
      objc_change( c_form1,10,0,c1_x,c1_y,c1_w,c1_h,NORMAL,1 );
      if (!correct)
         {
         if (myval != -1)
            {
            if (wb_flag) wrongnoise();
            ret = wrong_alert(chordnames[myval],chordcodes[myval],
             chordnames[cval]);
            if (ret == 1)
               {
               notemouse();
               play_chord( myval,key,octs,NUM_VOICES,CHORDLEN );
               normouse();
               }
            }
         }
   }
/* clean up and exit */
score_alert( c_score );
dial_away( c_form1,c1_x,c1_y,c1_w,c1_h );
return( c_score );
}

/* scales() tests the users ability to identify different scales
   it returns a score or 0
*/
WORD scales()
{
WORD m_score = 0,       trycount,      rcount,
     problem,           correct,       newscale,
     ret,               key,           oct,
     myval,             choice;

/* Initialize */
if (level == EASY)
   key = rand_key();

/* Execute the dialog */
s_form1[ 12 ].ob_state = NORMAL;
dial_start( s_form1,s1_x,s1_y,s1_w,s1_h,1 );
for (problem=0; problem < TESTLEN; problem++)
   {
   newscale = rand_int( 0,(NUM_MODES-1) );
   oct = rand_int( OCTBASE-octrange,OCTBASE+octrange );
   if (level >= INTERMEDIATE)
      key = rand_key();
   next_alert( "Scale",problem+1 );
   notemouse();
   Giaccess( (port_state & 0xc0) | 0x38, CH_ENA_W );
   Giaccess( 10, RG_ENV_W ); 
   Giaccess( 0, RG_WAV_W ); 
   play_scale( key,newscale,oct );
   normouse();

   /* This loop handles entry of choices */
   correct = 0;      trycount = 0;     rcount = 0;       myval = 0;
   do
      {
      choice = form_do( s_form1,0 );
      switch( choice )
         {
         case 12:    notemouse();
                     play_scale( key,newscale,oct );
                     normouse();
                     rcount++;
                     if (rcount >= rmax)
                        {
                        objc_change( s_form1,12,0,s1_x,s1_y,s1_w,s1_h,
                                     DISABLED,1 );
                        objc_draw( s_form1,0,1,s1_x,s1_y,s1_w,s1_h );
                        }
                     else
                        objc_change( s_form1,12,0,s1_x,s1_y,s1_w,s1_h,
                                     NORMAL,1 );
                     break;
         case 13:    myval = -1;
                     trycount = maxtries;
                     answer_alert( scalenames[ newscale ] );
                     break;
         case 14:    ret = form_alert(2,qstring);
                     if (ret == 1)
                        {
                        objc_change( s_form1,choice,0,s1_x,s1_y,s1_w,s1_h,
                                     NORMAL,0 );
                        dial_away( s_form1,s1_x,s1_y,s1_w,s1_h );
                        return( 0 );
                        }
                     break;
         default:    myval = choice - 3;
                     trycount++;
                     if (myval == newscale)
                        {
                        correct = 1;
                        if (wr_flag) rightnoise();
                        form_alert(1,cstring);
                        m_score++;
                        }
                     else
                        if (trycount < maxtries)
                           form_alert(1,wstring);
         }
      if (choice != 12)
         objc_change( s_form1,choice,0,s1_x,s1_y,s1_w,s1_h,NORMAL,1 );
      } while ((trycount < maxtries)&&(!correct));
   objc_change( s_form1,12,0,s1_x,s1_y,s1_w,s1_h,NORMAL,1 );
   if (!correct)
      {
      if (myval != -1)
         {
         if (wb_flag) wrongnoise();
         ret =  wrong_alert(scalenames[myval],"Listen",
                            scalenames[newscale]);
         if (ret == 1)
            {
            notemouse();
            play_scale( key,myval,oct );
            normouse();
            }
         }
      }
   }
score_alert( m_score );
dial_away( s_form1,s1_x,s1_y,s1_w,s1_h );
return( m_score );
}

/* melodies() plays a number of notes and allows the user
   to try entering a list of note names to match what was played
*/
WORD melodies()
{
BYTE notestr[ MAXSEQ*3 + 1 ], ustr[ MAXSEQ*3 + 16 ],
     rstring[ 255 ];
WORD s_score = 0,    trycount,      rcount,
     i,              j,             correct,
     key,            offset,        problem,
     ret,            choice,        myval,
     snotes[ MAXSEQ ], socts[ MAXSEQ ];

/* Execute the dialog */
m_form1[ 5 ].ob_state = NORMAL;
dial_start( m_form1,m1_x,m1_y,m1_w,m1_h,1 );
for (problem=0; problem<TESTLEN; problem++)
   {
   /* compute new sequence notes & octaves and notelist */
   if (level < 2)
      key = 0;
   else
      key = rand_key();
   snotes[ 0 ] = 0;
   socts[ 0 ] = rand_int(OCTBASE-octrange,OCTBASE+octrange);
   strcpy( notestr,pnl[ key ] );
   for (i=1; i<seqlen; i++)
      {
      snotes[ i ] = rand_mnote(curscale,0,7);
      socts[ i ] = socts[ 0 ];
      if (snotes[ i ] > 11)
         {
         snotes[ i ] -= 12;
         socts[ i ] ++;
         }
      else
         if (snotes[ i ] < 0)
            {
            snotes[ i ] += 12;
            socts[ i ] --;
            }
      offset = snotes[ i ] + key;
      if (offset > 11)
         offset -= 12;
      strcat( notestr," " );
      strcat( notestr,pnl[ offset ] );
      }
   /* initialize rest of octaves, in case user sequence is longer */
   for (i=seqlen; i<MAXSEQ; i++)
      socts[ i ] = socts[ 0 ];
   next_alert( "Melody",problem+1 );
   strcpy( (BYTE *)ted1.te_ptext,pnl[ snotes[ 0 ]+key ] );
   strcat( (BYTE *)ted1.te_ptext," " );
   objc_draw( m_form1,0,1,m1_x,m1_y,m1_w,m1_h );
   notemouse();
   play_mel( snotes,socts,seqlen,key );
   normouse();

   correct = 0;      trycount = 0;     rcount = 0;
   do
      {
      choice = form_do( m_form1,3 );
      switch( choice )
         {
         case 5:     notemouse();
                     play_mel( snotes,socts,seqlen,key );
                     normouse();
                     rcount++;
                     if (rcount >= rmax)
                        {
                        objc_change( m_form1,5,0,m1_x,m1_y,m1_w,m1_h,
                                     DISABLED,1 );
                        objc_draw( m_form1,0,1,m1_x,m1_y,m1_w,m1_h );
                        }
                     else
                        objc_change( m_form1,5,0,m1_x,m1_y,m1_w,m1_h,
                                     NORMAL,1 );
                     break;
         case 6:     myval = -1;
                     trycount = maxtries;
                     answer_alert( notestr );
                     break;
         case 7:     ret = form_alert( 2,qstring );
                     if (ret == 1)
                        {
                        objc_change( m_form1,choice,0,m1_x,m1_y,m1_w,m1_h,
                                     NORMAL,0 );
                        dial_away( m_form1,m1_x,m1_y,m1_w,m1_h );
                        return( 0 );
                        }
                     break;
         default:    trycount++;
                     strcpy( ustr,(BYTE *)ted1.te_ptext );
                     for (j=0; j<i; j++)
                        ustr[ j ] = toupper(ustr[ j ]);
                     unotes[ 0 ] = 0;
                     ret = seqcmp( ustr,snotes,key );
                     if (ret == seqlen+1)
                        {
                        correct = 1;
                        if (wr_flag) rightnoise();
                        form_alert(1,cstring);
                        s_score++;
                        }
                     else if (ret == -1)
                        form_alert(1,istring);
                     else
                        if (trycount < maxtries)
                           {
                           sprintf(rstring,"[2][ Not quite...you entered %d|",
                                   ret-1);
                           strcat(rstring," note(s) correctly.  Try Again.]");
                           strcat(rstring,"[ OK ]");
                           form_alert(1,rstring);
                           }
                     break;
         }
      if (choice != 5)
         objc_change( m_form1,choice,0,m1_x,m1_y,m1_w,m1_h,NORMAL,1 );
      } while ((trycount < maxtries)&&(!correct));
      objc_change( m_form1,5,0,m1_x,m1_y,m1_w,m1_h,NORMAL,1 );
      if (!correct)
         {
         if (myval != -1)
            {
            if (wb_flag) wrongnoise();
            if (wrong_alert( ustr,"Listen",notestr )==1)
               {
               notemouse();
               play_mel( unotes,socts,useqlen,key );
               normouse();
               }
            }
         }
   }
score_alert( s_score );
dial_away( m_form1,m1_x,m1_y,m1_w,m1_h );
return(s_score);
}

/* seqcmp() compares two sequences of notes up to a given length */
WORD seqcmp( ustr,snotes,key )
BYTE ustr[]; WORD snotes[], key;
{
WORD i, j, seqscore, ok, done, offset;
BYTE unames[ MAXSEQ ][ 3 ], *p;

/* start with perfect score */
seqscore = seqlen + 1;

/* break individual notes out of user's note string */
p = ustr;   i = 0;   done = 0;
while (!done && i<MAXSEQ)
   {
   if ((*p != ' ') && (*p != '\0'))
      {
      unames[i][0] = *p;
      p++;
      unames[i][1] = *p;
      if (*p == ' ')
         unames[i][1] = '\0';
      if (*p != '\0')
         p++;
      unames[i][2] = '\0'; 
      }
   if (*p == '\0')
      done = 1;
   if (*p == ' ')
      p++;
   i++;
   }

useqlen = i;
if (useqlen > MAXSEQ)
   return(-1);

/* test validity of each note; if one fails,
   return immediately -- otherwise, get the note's value
*/
for (i=0; i<useqlen; i++)
   {
   ok = 0;      j = 0;
   while ( !ok && j<13 )
      {
      if ((strcmp(unames[i],pnl[j])==0)||(strcmp(unames[i],anl[j])==0))
         {
         ok = 1;
         unotes[ i ] = j - key;
         if (unotes[ i ] < 0)
            unotes[ i ] += 12;
         }
      j++;
      }
   if (!ok)
      return(-1);
   }

/* compare each note with actual note played */
if (useqlen != seqlen)
   seqscore--;
for (i=0; (i<seqlen) && (i<useqlen); i++)
   {
   offset = snotes[ i ] + key;
   if (offset > 11)
      offset -= 12;
   if ((strcmp(unames[i],pnl[offset]))&&(strcmp(unames[i],anl[offset])))
      seqscore--;
   }

/* this is in case they entered less notes than were played */
while (i++ < seqlen)
   seqscore--;

/* report results */
return( seqscore );
}

/* tonality() establishes a particular tonality by playing the
   I-IV-V-I sequence of chords
*/
void tonality( key,beats )
WORD key,beats;
{
WORD octs[ NUM_VOICES ];

octs[ 0 ] = 1; octs[ 1 ] = 2; octs[ 2 ] = 2;
play_chord( 0,key,octs,NUM_VOICES,beats );
rest(2);
octs[ 0 ] = 2; octs[ 1 ] = 2; octs[ 2 ] = 1;
play_chord( 3,key,octs,NUM_VOICES,beats );
rest(2);
octs[ 0 ] = 2; octs[ 1 ] = 1; octs[ 2 ] = 2;
play_chord( 4,key,octs,NUM_VOICES,beats );
rest(2);
octs[ 0 ] = 1; octs[ 1 ] = 2; octs[ 2 ] = 2;
play_chord( 0,key,octs,NUM_VOICES,beats );
}

/* ------------ practice session function definitions ------------- */

/* p_intervals() lets the user sample interval sounds */
void p_intervals()
{
WORD done=0,
     inotes[ 2 ],
     octs[ 2 ];
WORD choice, ival;

/* Initialize the starting note and octave */
octs[ 0 ]   = rand_int( OCTBASE-octrange,OCTBASE+octrange );
inotes[ 0 ] = rand_key();

/* Begin the dialog */
dial_start( i_form2,i2_x,i2_y,i2_w,i2_h,1 );
do
   {
   choice = form_do( i_form2,0 );
   if (choice==16)
      done=1;
   else
      {
      ival = choice - 3;
      octs[ 1 ]   = octs[ 0 ];
      inotes[ 1 ] = inotes[ 0 ] + ival;
      if (inotes[ 1 ] > 11)
         {
         octs[ 1 ] ++;
         inotes[ 1 ] -= 12;
         }
      notemouse();
      Giaccess( (port_state & 0xc0) | 0x38, CH_ENA_W );
      Giaccess( 10, RG_ENV_W  ); 
      Giaccess( 0, RG_WAV_W  );
      play_int( inotes,octs );
      normouse();
      }
   if (!done)
      objc_change( i_form2,choice,0,i2_x,i2_y,i2_w,i2_h,NORMAL,1 );
   else
      objc_change( i_form2,choice,0,i2_x,i2_y,i2_w,i2_h,NORMAL,0 );
   } while (!done);
dial_away( i_form2,i2_x,i2_y,i2_w,i2_h );
}

/* p_chords() lets the user sample chord sounds within a given tonality */
void p_chords()
{
WORD i,
     done=0,
     key,
     octs[ NUM_VOICES ];
WORD choice, cval;

key = rand_key();

/* Execute the dialog */
dial_start( c_form2,c2_x,c2_y,c2_w,c2_h,1 );
Giaccess( (port_state & 0xc0) | 0x38, CH_ENA_W );
Giaccess( 10, RG_ENV_W  );
Giaccess( 0, RG_WAV_W  );
tonality( key,CHORDLEN );
do
   {
   choice = form_do( c_form2,0 );
   if (choice==11)
      done=1;
   else
      if (choice==10)
         tonality( key,CHORDLEN );
      else
         {
         cval = choice - 3;
         octs[ 0 ] = rand_int( OCTBASE-octrange,OCTBASE+octrange );/*11/07/87*/
         for (i=1; i<NUM_VOICES; i++)
            octs[ i ] = octs[ 0 ];
         notemouse();
         play_chord( cval,key,octs,NUM_VOICES,CHORDLEN );
         normouse();
         }
   if (!done)
      objc_change( c_form2,choice,0,c2_x,c2_y,c2_w,c2_h,NORMAL,1 );
   else
      objc_change( c_form2,choice,0,c2_x,c2_y,c2_w,c2_h,NORMAL,0 );
   } while (!done);
dial_away( c_form2,c2_x,c2_y,c2_w,c2_h );
}

/* p_scales() allows the user to sample given scale sounds */
void p_scales()
{
WORD done=0,
     key,
     oct;
WORD choice, sval;

/* Initialize the key for this practice session */
key = rand_key();

/* Execute the dialog */
dial_start( s_form2,s2_x,s2_y,s2_w,s2_h,1 );
do
   {
   choice = form_do( s_form2,0 );
   if (choice==12)
      done=1;
   else
      {
      sval = choice - 3;
      oct = rand_int( OCTBASE-octrange, OCTBASE+octrange );
      notemouse();
      Giaccess( (port_state & 0xc0) | 0x38, CH_ENA_W );
      Giaccess( 10, RG_ENV_W  );
      Giaccess( 0, RG_WAV_W  );
      play_scale( key,sval,oct );
      normouse();
      }
   if (!done)
      objc_change( s_form2,choice,0,s2_x,s2_y,s2_w,s2_h,NORMAL,1 );
   else
      objc_change( s_form2,choice,0,s2_x,s2_y,s2_w,s2_h,NORMAL,0 );
   } while (!done);
dial_away( s_form2,s2_x,s2_y,s2_w,s2_h );
}

/* p_melodies allows the user to sample various melodies */
void p_melodies()
{
BYTE ustr[ MAXSEQ*3 + 1];
WORD i, j,
     done=0,
     ret,
     unotes[ MAXSEQ ], uocts[ MAXSEQ ];
WORD choice;

/* initialize octave values */
for (i=0; i<MAXSEQ; i++)
   uocts[ i ] = OCTBASE;

/* Begin the dialog */
*(BYTE *)ted1.te_ptext = '\0';
dial_start( m_form2,m2_x,m2_y,m2_w,m2_h,1 );
do
   {
   choice = form_do( m_form2,3 );
   if (choice==5)
      done=1;
   else     /* get input string; convert to notes and play */
      {
      strcpy( ustr,ted1.te_ptext );
      *(BYTE *)ted1.te_ptext = '\0';
      i = strlen( ustr );
      for (j=0; j<i; j++)
         ustr[ j ] = toupper(ustr[ j ]);
      if ((ret = convert_seq( ustr,unotes ))==-1)
         form_alert( 1,istring );
      else
         {
         notemouse();
         play_mel( unotes,uocts,ret,0 );
         normouse();
         }
      objc_draw( m_form2,0,1,m2_x,m2_y,m2_w,m2_h );
      }
   if (!done)
      objc_change( m_form2,choice,0,m2_x,m2_y,m2_w,m2_h,NORMAL,1 );
   else
      objc_change( m_form2,choice,0,m2_x,m2_y,m2_w,m2_h,NORMAL,0 );
   } while (!done);
dial_away( m_form2,m2_x,m2_y,m2_w,m2_h );
}

/* convert_seq() converts a string into an array of note values */
/* it returns the number of notes found or -1 to indicate an invalid */
/* melody */
WORD convert_seq( ustr,unotes )
BYTE ustr[]; WORD unotes[];
{
WORD i, j, useqlen, ok, done;
BYTE unames[ MAXSEQ ][ 3 ], *p;

/* break individual notes out of user's note string */
p = ustr;   i = 0;   done = 0;
while (!done && i<MAXSEQ)
   {
   if ((*p != ' ') && (*p != '\0'))
      {
      unames[i][0] = *p;
      p++;
      unames[i][1] = *p;
      if (*p == ' ')
         unames[i][1] = '\0';
      if (*p != '\0')
         p++;
      unames[i][2] = '\0'; 
      }
   if (*p == '\0')
      done = 1;
   if (*p == ' ')
      p++;
   i++;
    } 

useqlen = i;
if (useqlen > MAXSEQ)
   return(-1);

/* test validity of each note; if one fails,
   return immediately -- otherwise, get the note's value
*/
for (i=0; i<useqlen; i++)
   {
   ok = 0;      j = 0;
   while ( !ok && j<13 )
      {
      if ((strcmp(unames[i],pnl[j])==0)||
          (strcmp(unames[i],anl[j])==0))
         {
         ok = 1;
         unotes[ i ] = j;
         }
      j++;
      }
   if (!ok)
      return(-1);
   }

/* return length of melody */
return( useqlen );
}

