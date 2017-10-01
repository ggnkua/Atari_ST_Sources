/*-------------------------------------------------------------------*/
/*--------------------------- CHORD ORGAN ---------------------------*/
/*-------------------------------------------------------------------*/
 
 
#include <stdio.h>
#include <osbind.h>
 
 
#define MIDI 3
#define KEY  2
              
int ftune[97] = {
 
0xFF, 
0x5D, 0x9C, 0xE7, 0x3C, 0x9B, 0x2, 0x73, 0xEB, 0x6B, 0xF2, 
0x80, 0x14, 0xAE, 0x4E, 0xF4, 0x9E, 0x4D, 0x1, 0xB9, 0x75, 
0x35, 0xF9, 0xC0, 0x8A, 0x57, 0x27, 0xFA, 0xCF, 0xA7, 0x81, 
0x5D, 0x36, 0x1B, 0xFC, 0xE0, 0xC5, 0xAC, 0x94, 0x7D, 0x68, 
0x53, 0x40, 0x2E, 0x1D, 0xD, 0xFE, 0xF0, 0xE2, 0xD8, 0xCA, 
0xBE, 0xB4, 0xAA, 0xA0, 0x97, 0x8F, 0x87, 0x7F, 0x78, 0x71, 
0x6B, 0x65, 0x5F, 0x5A, 0x55, 0x50, 0x4C, 0x47, 0x43, 0x40, 
0x3C, 0x39, 0x35, 0x32, 0x30, 0x2D, 0x2A, 0x28, 0x26, 0x24, 
0x22, 0x20, 0x1E, 0x1C, 0x1B, 0x19, 0x18, 0x16, 0x15, 0x14, 
0x13, 0x12, 0x11, 0x10, 0xF, 0xE};
 
int ctune[97] = {
 
0xFF, 
0xD, 0xC, 0xB, 0xB, 0xA, 0xA, 0x9, 0x8, 0x8, 0x7, 
0x7, 0x7, 0x6, 0x6, 0x5, 0x5, 0x5, 0x5, 0x4, 0x4, 
0x4, 0x3, 0x3, 0x3, 0x3, 0x3, 0x2, 0x2, 0x2, 0x2, 
0x2, 0x2, 0x2, 0x1, 0x1, 0x1, 0x1, 0x1, 0x1, 0x1, 
0x1, 0x1, 0x1, 0x1, 0x1, 0x0, 0x0, 0x0, 0x0, 0x0, 
0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 
0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 
0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 
0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 
0x0, 0x0, 0x0, 0x0, 0x0, 0x0};
 
 
main()
{
unsigned char status, midi_note, velocity;
 
status = 0;
 
     Giaccess(56, 0x87);         /* enable all three registers */
     while (!Bconstat(KEY))     /* exit loop by pressing a key */
     {
          while (status != 144)  /* stay in loop until note on or off */
          {
                    status = Bconin(MIDI);
          }
          status = 0;                                 /* reset status */
          midi_note = Bconin(MIDI);
          velocity = Bconin(MIDI);
          select(midi_note, velocity);
     }
}
 
 
select(m, v)                   /* define chords */
unsigned char m, v;
{
unsigned char a, b, c;
     switch (m)
     {
     case 60:
          a = 60; b = 64; c = 67;
          chord(a, b, c, v);                   /* C major */
          break ;
     case 62:
          a = 62; b = 65; c = 69;
          chord(a, b, c, v);                   /* D minor */
          break ;
     case 64:
          a = 64; b = 67; c = 71;
          chord(a, b, c, v);                   /* E minor */
          break ;
     case 65:
          a = 60; b = 65; c = 69;
          chord(a, b, c, v);                   /* F major */
          break ;
 
     case 67:
          a = 62; b = 67; c = 71;
          chord(a, b, c, v);                   /* G major */
          break ;
     case 69:
          a = 60; b = 64; c = 69;
          chord(a, b, c, v);                   /* A minor */
          break ;
 
     case 71:
          a = 62; b = 65; c = 71;
          chord(a, b, c, v);                   /* B diminished */
          break ;
     }
}
 

chord(a, b, c, v)                           /* play chord */
unsigned char a, b, c, v;
{
     Note_On(a, v);
     Note_On(b, v);
     Note_On(c, v);
     sound_chord(a, b, c, v);
}
 
 
Note_On(m, v)                       /* Play a midi note */
unsigned char m, v;               
{
     Bconout(MIDI, 144);
     Bconout(MIDI, m);
     Bconout(MIDI, v);
}
 
 
sound_chord(a, b, c, v)             /* play internal soundchip */
unsigned char a, b, c, v;
{
        sound(a, v, 1);     /* modified sound statement */
        sound(b, v, 2);
        sound(c, v, 3);
}
 
 
 
sound(frq, vme, ch)                   /* play internal soundchip */
unsigned char frq, vme, ch;
{
        frq = frq - 25;
        vme = vme / 9;                   /* compress volume data */
        ch = ch - 1;
        Giaccess(vme, (0x88 + ch));
        Giaccess(ftune[frq], (0x80 + 2*ch));
        Giaccess(ctune[frq], (0x81 + 2*ch));
}
 
 
 
 
 
 
 
 
