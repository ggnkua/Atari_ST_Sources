/*----------------------------------------------------------------------*/
/*                            "EAR TRAINER"                             */
/* by David T. Jarvis                                  For the Atari ST */
/* Developed with Lattice C                                             */
/* Version 091787                                                       */
/*                                                                      */
/* Modified to compile with Mark Williams C 11/07/87 - Antic Pub.       */
/*                                                                      */
/* Module:  Earutils.c                                 Utility Routines */
/*----------------------------------------------------------------------*/

#include <stdio.h>                  /* standard io library              */
#include <osbind.h>                 /* GEMDOS,BIOS,XBIOS macros         */
#include <ctype.h>                  /* character type macros            */

/* #include <gemlib.h> */           /* GEM definitions (Lattice C)      */

#include <gemdefs.h>                /* Mark Williams C GEM stuff        */
#include <obdefs.h>                 /*           "                      */
#include <xbios.h>                  /*           "                      */

#include <portab.h>                 /* storage defs for portability     */
#include <eartrain.h>               /* program-specific declarations    */

/* ---------- data declarations and definitions ----------------------- */

/* mididata[] will hold byte data sent to the MIDI OUT port */
BYTE mididata[ 4 ];
/* notes[] contains the numbers to plug into the ST sound chip */
WORD notes[ 6 ][ 12 ] =
{
 { 3906,3689,3472,3189,3048,2906,2728,2551,2411,2272,2160,2049 },
 { 1923,1817,1712,1633,1524,1436,1350,1275,1205,1136,1076,1016 },
 { 954,902,850,807,757,714,675,637,602,568,537,506 },
 { 477,451,425,401,378,358,338,318,301,284,268,253 },
 { 239,225,212,200,189,179,169,159,150,142,134,126 },
 { 119,112,106,100, 94, 89, 84, 79, 75, 71, 67, 63 }
};
WORD scalenotes[ NUM_MODES ][ 15 ] =
{
   { 0, 2, 4, 5, 7, 9, 11, 12, 11, 9, 7, 5, 4, 2, 0 },   /* Ionian      */
   { 0, 2, 3, 5, 7, 8, 10, 12, 10, 8, 7, 5, 3, 2, 0 },   /* Natural m.  */
   { 0, 2, 3, 5, 7, 8, 11, 12, 11, 8, 7, 5, 3, 2, 0 },   /* Harmonic m. */
   { 0, 2, 3, 5, 7, 9, 11, 12, 10, 8, 7, 5, 3, 2, 0 },   /* Melodic m.  */
   { 0, 2, 3, 5, 7, 9, 10, 12, 10, 9, 7, 5, 3, 2, 0 },   /* Dorian      */
   { 0, 1, 3, 5, 7, 8, 10, 12, 10, 8, 7, 5, 3, 1, 0 },   /* Phrygian    */
   { 0, 2, 4, 6, 7, 9, 11, 12, 11, 9, 7, 6, 4, 2, 0 },   /* Lydian      */
   { 0, 2, 4, 5, 7, 9, 10, 12, 10, 9, 7, 5, 4, 2, 0 },   /* Mixolydian  */
   { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 7, 4 }    /* Chromatic   */
};
WORD chordnotes[ 7 ][ NUM_VOICES ] =
{
   { 0, 4, 7 },   { 2, 5, 9 },   { 4, 7, 11 },  { 5, 9, 0 },
   { 7, 11, 2 },  { 9, 0, 4 },   { 11, 2, 5 }
};

WORD noteform[ 37 ] =            /* new mouse cursor shape        */
   {  5,1,1,0,1,
      0x0280, 0x0240, 0x0220, 0x0250, 0x02a8, 0x0294, 0x028a, 0x028a,
      0x028a, 0x028a, 0x1e94, 0x2080, 0x4080, 0x4080, 0x2100, 0x1e00,
      0x0100, 0x0180, 0x01c0, 0x0120, 0x0110, 0x0108, 0x0104, 0x0104,
      0x0104, 0x0104, 0x0108, 0x1f00, 0x3f00, 0x3f00, 0x1e00, 0x0000
   };

WORD voices[ NUM_VOICES ],
     vol[ NUM_VOICES ];

/* external variables */
extern LONG s_factor;

/* ----------- function declarations ---------------------------------- */

/* external library functions */
BYTE *strcpy(), *strcat();        /* string manipulation routines */
/* double drand48(); */           /* 48-bit random number         */

/* declare functions defined below as extern */
extern WORD rand_sign(), rand_key(), rand_mnote();
extern WORD wrong_alert(), next_alert(), score_alert(), answer_alert();
extern WORD rand_int();

extern void sound_off(), sound_on(), nobell();
extern void wrongnoise(), rightnoise();
extern void play_note(), play_scale(), play_int(), play_chord(),
            play_mel(), rest();
extern void empt_box(), full_box(), dial_start(), dial_away();
extern void notemouse(), normouse();

/* functions not seen outside this module */
void set_note(), fade_note(), play();

/* ----------- MUSIC function definitions ----------------------- */

/* play_note() puts the indicated value into the sound chip at
   'which' voice & turns on the sound for the indicated # of beats;
   it also sends that note to the MIDI port and turns it off 
*/
void play_note( value, which, beats, moct, mnote )
WORD value, which, beats;
WORD moct, mnote;
{
   /* Turn on the note at the MIDI port */
   mididata[ 0 ] = NOTEON;
   mididata[ 1 ] = mnote + MIDIBASE + (moct*12);
   mididata[ 2 ] = FULLVELOCITY;
   Midiws( 2,mididata );

   /* Turn on ST sound */
   set_note( value,which );

   play( beats );

   /* Turn off the ST sound */
   fade_note( which );

   /* Turn off the note at the MIDI port */
   mididata[ 0 ] = NOTEOFF;
   mididata[ 2 ] = NOVELOCITY;
   Midiws( 2,mididata );
}

/* play_scale() plays the indicated scale starting from key */
void play_scale( key,choice,oct )
WORD key, choice, oct;
{
WORD j, nindex;

if (choice == CHROMATIC)
   {
   for (j = 0; j <= 12; j++)
      {
      nindex = key + scalenotes[ choice ][ j ];
      if (nindex > 12)
         play_note( notes[ oct+1 ][ nindex-12 ], 0, 2, oct+1, nindex-12 );
      else
         play_note( notes[ oct ][ nindex ], 0, 2, oct, nindex );
      rest( 1 );
      }
   for (j = 11; j >= 0; j--)
      {
      nindex = key + scalenotes[ choice ][ j ];
      if (nindex > 12)
         play_note( notes[ oct+1 ][ nindex-12 ], 0, 2, oct+1, nindex-12 );
      else
         play_note( notes[ oct ][ nindex ], 0, 2, oct, nindex );
      rest( 1 );
      }
   }
else
   for (j = 0; j<15; j++)
      {
      nindex = key + scalenotes[ choice ][ j ];
      if (nindex > 12)
         play_note( notes[ oct+1 ][ nindex-12 ], 0, 2, oct+1, nindex-12 );
      else
         play_note( notes[ oct ][ nindex ], 0, 2, oct, nindex );
      rest( 1 );
      }
}

/* play_int() plays two notes at the specified octaves */
void play_int( inotes, octs )
WORD inotes[], octs[];
{
   play_note( notes[ octs[ 0 ] ][ inotes[ 0 ] ], 0, 4, octs[ 0 ], inotes[ 0 ] );
   rest( 4 );
   play_note( notes[ octs[ 1 ] ][ inotes[ 1 ] ], 1, 4, octs[ 1 ], inotes[ 1 ] );
}

/* play_chord() plays v notes at octs simultaneously for beats */
void play_chord( cval,key,octs,v,beats )
WORD cval,key,octs[],v,beats;
{
BYTE midinote[ NUM_VOICES ];        /* Holds MIDI note values for each voice */
WORD i, nval, oval;

   /* Initialize known parts of the midi stream */
   mididata[ 0 ] = NOTEON;
   mididata[ 2 ] = FULLVELOCITY;

   /* Calculate ST sound chip values for the chord notes */
   for (i=0; i < v; i++)
      {
      nval = chordnotes[ cval ][ i ] + key;
      oval = octs[ i ];
      if (nval > 12)
         {
         nval -= 12;
         oval++;
         }
      voices[ i ] = notes[ oval ][ nval ];
      vol[ i ]    = VOLUME;
      /* Calculate MIDI codes for the chord notes */
      midinote[ i ] = (BYTE)(nval + MIDIBASE + (oval*12));
      }
   /* Turn sound on at the ST chip and the MIDI port */
   sound_on();
   for (i=0; i < v; i++)
      {
      mididata[ 1 ] = midinote[ i ];
      Midiws( 2,mididata );
      }

   play( beats );

   /* Turn the notes off */
   mididata[ 0 ] = NOTEOFF;
   mididata[ 2 ] = NOVELOCITY;
   for (i=0; i < v; i++)
      {
      vol[ i ] = 0;
      mididata[ 1 ] = midinote[ i ];
      Midiws( 2,mididata );
      }
   sound_off();
}

/* play_mel() plays a melody of slen notes at the specified octaves */
void play_mel( snotes,socts,slen,key )
WORD snotes[], socts[], slen, key;
{
WORD i, curnote, curoct;

for (i=0; i<slen; i++)
   {
   curnote = snotes[ i ] + key;
   curoct = socts[ i ];
   if (curnote > 12)
      {
      curnote -= 12;
      curoct ++;
      }
   else
      if (curnote < 0)
         {
         curnote += 12;
         curoct --;
         }
   play_note( notes[ curoct ][ curnote ], 0, 3, curoct, curnote );
   rest( 3 );
   }
}

/* wrongnoise() plays a sound effect which indicates a wrong choice */
void wrongnoise()
{
WORD i;
LONG save_factor;

   save_factor = s_factor;
   s_factor    = 200L;
   for (i=11; i>0; i--)
      play_note( notes[ 1 ][ i ],0,1,1,i );
   rest( 3 );
   s_factor = save_factor;
}

/* rightnoise() plays a sound effect which indicates a correct choice */
void rightnoise()
{
LONG save_factor;

   save_factor = s_factor;
   s_factor = 400L;
   play_note( notes[ 4 ][ 2 ],0,1,4,2 );
   play_note( notes[ 4 ][ 4 ],0,1,4,4 );
   play_note( notes[ 4 ][ 2 ],0,1,4,2 );
   play_note( notes[ 4 ][ 0 ],0,1,4,0 );
   s_factor = save_factor;
}

/* fade_note turns a specific voice off, using a gradual fade.
   Note that it accesses the global array "vol"
*/
void fade_note( which )
WORD which;
{
#define FADELEN         500

WORD i, j;

   for (i = vol[ which ]; i >= 0; i--)
      {
      vol[ which ] = i;
      sound_on();
      for (j=0; j < FADELEN; j++);
      }
   sound_off();
}

/* set_note() sets the indicated voice up to play the indicated note
   and "enables" that voice.  Note that it accesses the global arrays
   "voices" and "vol"
*/
void set_note( value,which )
WORD value,which;
{
   voices[ which ] = value;
   vol[ which ]    = VOLUME;
   sound_on();
}

/* play() merely stalls for an indicated number of beats...used after
   setting voices for chords or notes to play for that period of time
   Note that play() uses the global variable s_factor
*/
void play( beats )
WORD beats;
{
LONG i;

   for (i=0L; i < (beats * s_factor); i++)
      ;
}

/* rest() disables sound for all voices & pauses a certain # of beats
   Note that rest() uses the global variable s_factor
*/
void rest( beats )
WORD beats;
{
LONG i;

   sound_off();
   for (i=0L; i < (beats * s_factor); i++);
}

/* Sound_off() sets all three voices' volume to zero */
void sound_off()
{
   Giaccess( 0, CH_AVL_W  );
   Giaccess( 0, CH_BVL_W  );
   Giaccess( 0, CH_CVL_W  );
}

/* Sound_on() sets all three voices' parameters to the
   desired volume & pitch values.  It accesses the global
   arrays "vol" and "voices"
*/
void sound_on()
{
BYTE lo_h[ NUM_VOICES ],
     hi_h[ NUM_VOICES ];

   lo_h[ 0 ] = (BYTE)(voices[ 0 ]);
   lo_h[ 1 ] = (BYTE)(voices[ 1 ]);
   lo_h[ 2 ] = (BYTE)(voices[ 2 ]);
   hi_h[ 0 ] = (BYTE)(voices[ 0 ] >> 8);
   hi_h[ 1 ] = (BYTE)(voices[ 1 ] >> 8);
   hi_h[ 2 ] = (BYTE)(voices[ 2 ] >> 8);
   Giaccess( lo_h[ 0 ], CH_ALO_W  );
   Giaccess( hi_h[ 0 ], CH_AHI_W  );
   Giaccess( lo_h[ 1 ], CH_BLO_W  );
   Giaccess( hi_h[ 1 ], CH_BHI_W  );
   Giaccess( lo_h[ 2 ], CH_CLO_W  );
   Giaccess( hi_h[ 2 ], CH_CHI_W  );
   Giaccess( vol[ 0 ], CH_AVL_W  );
   Giaccess( vol[ 1 ], CH_BVL_W  );
   Giaccess( vol[ 2 ], CH_CVL_W  );
}

/* --------- RANDOM NUMBER GENERATION function definitions -------- */

/* rand_int() returns an integer between minout & minout+maxout, inclusive */
WORD rand_int( minout,maxout )
WORD minout,maxout;
{
WORD x;
   x = -1;
   do
      { x = rand();
        x = x & 0x000f; /* mask limits numbers to 0-15 range */
      } while ((x > maxout) || (x < minout ));
   return( x );
}

/* rand_key() returns a WORD between 0 and 11, indicating a key */
WORD rand_key()
{
   return( rand_int(0,11) );
}

/* rand_mnote() returns an offset into the notes array which belongs
   to the indicated scale and is within the indicated range
*/
WORD rand_mnote( scale,start,range )
WORD scale,start,range;
{
return(scalenotes[ scale ][ rand_int(start,start+range) ]);
}

/* ---------- VDI & AES function definitions ----------------------- */

/* next_alert() lets the user click one box for the next problem
   of the indicated type, or exit
*/
WORD next_alert( probtype,probnum )
BYTE probtype[];
WORD probnum;
{
BYTE qstring[ 255 ];
BYTE pstr[ 16 ];

   sprintf( pstr,"%d", probnum );
   strcpy( qstring,"[2][Click when ready|for " );
   strcat( qstring,probtype );
   strcat( qstring," #" );
   strcat( qstring,pstr );
   strcat( qstring,"][  OK  ]" );
   return( (WORD)form_alert(1,qstring) );
}

/* score_alert() informs the user of his/her score,
   then waits for a click or carriage return
*/
WORD score_alert( t_score )
WORD t_score;
{
BYTE rstring[ 255 ];
BYTE nstring[ 65 ];

   strcpy( rstring, "[3][ Number Correct:|");
   sprintf( nstring, " %d out of %d ][ OK ]", t_score, TESTLEN );
   strcat( rstring, nstring );
   form_alert( 1,rstring );
   return(0);
}

/* wrong_alert() informs the user their choice was wrong */
WORD wrong_alert( longname,shortname,answer )
BYTE longname[], shortname[], answer[];
{
BYTE rstring[ 350 ];

   strcpy(rstring,"[0][The answer should have been:  |");
   strcat(rstring,answer);
   strcat(rstring,  "|    Click on the left box    ");
   strcat(rstring,  "|    to hear your choice.     ][ ");
   strcat(rstring,shortname);
   strcat(rstring," | Go on ]");
   return((WORD)form_alert(2,rstring));
}

/* answer_alert() tells what the right answer should have been */
WORD answer_alert( answer )
BYTE answer[];
{
BYTE rstring[ 255 ];

   strcpy(rstring,"[0][  | The correct answer was:    |  ");
   strcat(rstring,answer);
   strcat(rstring," | ][  OK  ]");
   return((WORD)form_alert(1,rstring));
}

/* empt_box displays an empty box of the indicated color */
void empt_box( left, top, right, bottom, color, handle )
WORD left, top, right, bottom, color, handle;
{
   WORD pxy[ 10 ];

   pxy[ 0 ] = left;     pxy[ 1 ] = top;
   pxy[ 2 ] = right;    pxy[ 3 ] = top;
   pxy[ 4 ] = right;    pxy[ 5 ] = bottom;
   pxy[ 6 ] = left;     pxy[ 7 ] = bottom;
   pxy[ 8 ] = left;     pxy[ 9 ] = top;

   vsl_color( handle,color );
   v_pline( handle, 5, pxy );
}

/* full_box displays a box filled with the indicated style */
void full_box( left,top,right,bottom,color,style,handle )
WORD left,top,right,bottom,color,style,handle;
{
   WORD pxy[ 4 ];

   vsl_color( handle,color );
   vsf_interior( handle,2 );
   vsf_color( handle,color );
   vswr_mode( handle,1 );
   vsf_style( handle,style );
   vsf_perimeter( handle,1 );
   empt_box( left,top,right,bottom,color );
   pxy[ 0 ] = left;     pxy[ 1 ] = top;
   pxy[ 2 ] = right;    pxy[ 3 ] = bottom;
   vr_recfl( handle,pxy );
}

/* dial_start() sets up a dialog for use */
void dial_start( form,fx,fy,fw,fh,level )
OBJECT form[];
WORD fx, fy, fw, fh, level;
{
   form_dial( FMD_START,0,0,0,0,fx,fy,fw,fh );
   form_dial( FMD_GROW, 0,0,0,0,fx,fy,fw,fh );
   objc_draw( form,0,level,fx,fy,fw,fh );
}

/* dial_away() ends a dialog */
void dial_away( form,fx,fy,fw,fh )
OBJECT form[];
WORD fx, fy, fw, fh;
{
   form_dial( FMD_SHRINK,0,0,0,0,fx,fy,fw,fh );
   form_dial( FMD_FINISH,0,0,0,0,fx,fy,fw,fh );
}

/* notemouse() changes the mouse cursor to a note */
void notemouse()
{
   graf_mouse( USER_DEF,noteform );
}

/* normouse() makes the mouse normal (an arrow) again */
void normouse()
{
   graf_mouse( ARROW,0 );
}

/* ---------- Miscellaneous ---------------------------------- */

/* nobell() disables the CTRL/G and dialog box bells */
void nobell()
{
BYTE *con_ptr;

con_ptr = (BYTE *)CONTERM;
*con_ptr = *con_ptr & (BYTE)0xfb;
}

