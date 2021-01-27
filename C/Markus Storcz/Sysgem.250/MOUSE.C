/* ------------------------------------------------------------------- *
 * Module Version       : 2.00                                         *
 * Author               : Andrea Pietsch                               *
 * Programming Language : Pure-C                                       *
 * Copyright            : (c) 1994, Andrea Pietsch, 56727 Mayen        *
 * ------------------------------------------------------------------- */

#include        "kernel.h"

/* ------------------------------------------------------------------- */

#define MAXMFROTOR      8

#define ROTORMASK       { 0x07E0, 0x1FF8, 0x3FFC, 0x7FFE, 0x7FFE, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0x7FFE, 0x7FFE, 0x3FFC, 0x1FF8, 0x07E0 }

#define ROTOR0DATA      { 0x07E0, 0x1FF8, 0x3FFC, 0x5FFA, 0x4FF2, 0x87E1, 0x83C1, 0x8181, 0x8181, 0x83C1, 0x87E1, 0x4FF2, 0x5FFA, 0x3FFC, 0x1FF8, 0x07E0 }
#define ROTOR1DATA      { 0x07E0, 0x1FF8, 0x27FC, 0x43FE, 0x43FE, 0x81FF, 0x81F9, 0x81E1, 0x8781, 0x9F81, 0xFF81, 0x7FC2, 0x7FC2, 0x3FE4, 0x1FF8, 0x07E0 }
#define ROTOR2DATA      { 0x07E0, 0x18F8, 0x20FC, 0x40FE, 0x40FE, 0x80FF, 0x80FF, 0x80FF, 0xFF01, 0xFF01, 0xFF01, 0x7F02, 0x7F02, 0x3F04, 0x1F18, 0x07E0 }
#define ROTOR3DATA      { 0x07E0, 0x1838, 0x203C, 0x407E, 0x407E, 0xE0FF, 0xF8FF, 0xFFFF, 0xFFFF, 0xFF1F, 0xFF07, 0x7E02, 0x7E02, 0x3C04, 0x1C18, 0x07E0 }
#define ROTOR4DATA      { 0x07E0, 0x1818, 0x2004, 0x700E, 0x781E, 0xFC3F, 0xFE7F, 0xFFFF, 0xFFFF, 0xFE7F, 0xFC3F, 0x781E, 0x700E, 0x2004, 0x1818, 0x07E0 }
#define ROTOR5DATA      { 0x07E0, 0x1C18, 0x3C04, 0x7E02, 0x7E02, 0xFF07, 0xFF1F, 0xFFFF, 0xFFFF, 0xF8FF, 0xE0FF, 0x407E, 0x407E, 0x203C, 0x1838, 0x07E0 }
#define ROTOR6DATA      { 0x07E0, 0x1F18, 0x3F04, 0x7F02, 0x7F02, 0xFF01, 0xFF01, 0xFF01, 0x80FF, 0x80FF, 0x80FF, 0x40FE, 0x40FE, 0x20FC, 0x18F8, 0x07E0 }
#define ROTOR7DATA      { 0x07E0, 0x1FF8, 0x3FE4, 0x7FC2, 0x7FC2, 0xFF81, 0x9F81, 0x8781, 0x81E1, 0x81F9, 0x81FF, 0x43FE, 0x43FE, 0x27FC, 0x1FF8, 0x07E0 }

/* ------------------------------------------------------------------- */

#define MAXMFCLOCK      12

#define CLOCKMASK       { 0x07C0, 0x1FF0, 0x3FF8, 0x7FFC, 0x7FFC, 0xFFFE, 0xFFFE, 0xFFFE, 0xFFFE, 0xFFFE, 0x7FFC, 0x7FFC, 0x3FF8, 0x1FF0, 0x07C0, 0x0000 }

#define CLOCK00DATA     { 0x07C0, 0x1830, 0x2108, 0x4104, 0x4104, 0x8102, 0x8102, 0xA10A, 0x8102, 0x8002, 0x4004, 0x4004, 0x2108, 0x1830, 0x07C0, 0x0000 }
#define CLOCK01DATA     { 0x07C0, 0x1830, 0x2108, 0x4044, 0x4044, 0x8082, 0x8082, 0xA10A, 0x8102, 0x8002, 0x4004, 0x4004, 0x2108, 0x1830, 0x07C0, 0x0000 }
#define CLOCK02DATA     { 0x07C0, 0x1830, 0x2108, 0x4004, 0x4004, 0x8032, 0x80C2, 0xA30A, 0x8002, 0x8002, 0x4004, 0x4004, 0x2108, 0x1830, 0x07C0, 0x0000 }
#define CLOCK03DATA     { 0x07C0, 0x1830, 0x2108, 0x4004, 0x4004, 0x8002, 0x8002, 0xA3FA, 0x8002, 0x8002, 0x4004, 0x4004, 0x2108, 0x1830, 0x07C0, 0x0000 }
#define CLOCK04DATA     { 0x07C0, 0x1830, 0x2108, 0x4004, 0x4004, 0x8002, 0x8002, 0xA30A, 0x80C2, 0x8032, 0x4004, 0x4004, 0x2108, 0x1830, 0x07C0, 0x0000 }
#define CLOCK05DATA     { 0x07C0, 0x1830, 0x2108, 0x4004, 0x4004, 0x8002, 0x8102, 0xA10A, 0x8082, 0x8082, 0x4044, 0x4044, 0x2108, 0x1830, 0x07C0, 0x0000 }
#define CLOCK06DATA     { 0x07C0, 0x1830, 0x2108, 0x4004, 0x4004, 0x8002, 0x8102, 0xA10A, 0x8102, 0x8102, 0x4104, 0x4104, 0x2108, 0x1830, 0x07C0, 0x0000 }
#define CLOCK07DATA     { 0x07C0, 0x1830, 0x2108, 0x4004, 0x4004, 0x8002, 0x8102, 0xA10A, 0x8202, 0x8202, 0x4404, 0x4404, 0x2108, 0x1830, 0x07C0, 0x0000 }
#define CLOCK08DATA     { 0x07C0, 0x1830, 0x2108, 0x4004, 0x4004, 0x8002, 0x8002, 0xA18A, 0x8602, 0x9802, 0x4004, 0x4004, 0x2108, 0x1830, 0x07C0, 0x0000 }
#define CLOCK09DATA     { 0x07C0, 0x1830, 0x2108, 0x4004, 0x4004, 0x8002, 0x8002, 0xBF8A, 0x8002, 0x8002, 0x4004, 0x4004, 0x2108, 0x1830, 0x07C0, 0x0000 }
#define CLOCK10DATA     { 0x07C0, 0x1830, 0x2108, 0x4004, 0x4004, 0x9802, 0x8602, 0xA18A, 0x8002, 0x8002, 0x4004, 0x4004, 0x2108, 0x1830, 0x07C0, 0x0000 }
#define CLOCK11DATA     { 0x07C0, 0x1830, 0x2108, 0x4404, 0x4404, 0x8202, 0x8202, 0xA10A, 0x8102, 0x8002, 0x4004, 0x4004, 0x2108, 0x1830, 0x07C0, 0x0000 }

/* ------------------------------------------------------------------- */

#define MAXMFCOFFEE     2

#define COFFEEMASK      { 0x0380, 0x0FE0, 0x0FE0, 0x0FE0, 0x0FE0, 0x3FF8, 0x3FFE, 0x3FFF, 0x3FFF, 0x3FFF, 0x3FFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFE, 0x7FFC }

#define COFFEE0DATA     { 0x0000, 0x0100, 0x0440, 0x0100, 0x0440, 0x0000, 0x1FF0, 0x101C, 0x1012, 0x1012, 0x101C, 0x1FF0, 0xFFFE, 0x4004, 0x3FF8, 0x0000 }
#define COFFEE1DATA     { 0x0000, 0x0440, 0x0100, 0x0440, 0x0100, 0x0000, 0x1FF0, 0x101C, 0x1012, 0x1012, 0x101C, 0x1FF0, 0xFFFE, 0x4004, 0x3FF8, 0x0000 }

/* ------------------------------------------------------------------- */

#define MAXMFDISC       1

#define DISCMASK        { 0x7FFE, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0x7FFF, 0x3FFF }

#define DISC0DATA       { 0x7FFE, 0x9009, 0x954F, 0x900F, 0x92A9, 0x9009, 0x9549, 0x9009, 0x9FF9, 0x8001, 0x9FF9, 0x9709, 0x9709, 0x9709, 0x5709, 0x3FFF }

/* ------------------------------------------------------------------- */

#define MAXMFABACUS     4

#define ABACUSMASK      { 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0x0000 }

#define ABACUS0DATA     { 0x8001, 0xB601, 0xFFFF, 0xB601, 0x806D, 0xFFFF, 0x806D, 0xB601, 0xFFFF, 0xB601, 0x806D, 0xFFFF, 0x806D, 0x8001, 0xFFFF, 0x0000 }
#define ABACUS1DATA     { 0x8001, 0x860D, 0xFFFF, 0x860D, 0xB061, 0xFFFF, 0xB061, 0x860D, 0xFFFF, 0x860D, 0xB061, 0xFFFF, 0xB061, 0x8001, 0xFFFF, 0x0000 }
#define ABACUS2DATA     { 0x8001, 0x806D, 0xFFFF, 0x806D, 0xB601, 0xFFFF, 0xB601, 0x806D, 0xFFFF, 0x806D, 0xB601, 0xFFFF, 0xB601, 0x8001, 0xFFFF, 0x0000 }
#define ABACUS3DATA     { 0x8001, 0xB061, 0xFFFF, 0xB061, 0x860D, 0xFFFF, 0x860D, 0xB061, 0xFFFF, 0xB061, 0x860D, 0xFFFF, 0x860D, 0x8001, 0xFFFF, 0x0000 }

/* ------------------------------------------------------------------- */

#define MAXMFDICE       6

#define DICEMASK        { 0xFFFE, 0xFFFE, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0x3FFF }

#define DICE0DATA       { 0xFFFE, 0x8002, 0x8003, 0x8003, 0x8003, 0x8003, 0x8383, 0x8383, 0x8383, 0x8003, 0x8003, 0x8003, 0x8003, 0x8003, 0xFFFF, 0x3FFF }
#define DICE1DATA       { 0xFFFE, 0x8002, 0x803B, 0x803B, 0x803B, 0x8003, 0x8003, 0x8003, 0x8003, 0x8003, 0xB803, 0xB803, 0xB803, 0x8003, 0xFFFF, 0x3FFF }
#define DICE2DATA       { 0xFFFE, 0x8002, 0xB803, 0xB803, 0xB803, 0x8003, 0x8383, 0x8383, 0x8383, 0x8003, 0x803B, 0x803B, 0x803B, 0x8003, 0xFFFF, 0x3FFF }
#define DICE3DATA       { 0xFFFE, 0x8002, 0xB83B, 0xB83B, 0xB83B, 0x8003, 0x8003, 0x8003, 0x8003, 0x8003, 0xB83B, 0xB83B, 0xB83B, 0x8003, 0xFFFF, 0x3FFF }
#define DICE4DATA       { 0xFFFE, 0x8002, 0xB83B, 0xB83B, 0xB83B, 0x8003, 0x8383, 0x8383, 0x8383, 0x8003, 0xB83B, 0xB83B, 0xB83B, 0x8003, 0xFFFF, 0x3FFF }
#define DICE5DATA       { 0xFFFE, 0x8002, 0xB83B, 0xB83B, 0xB83B, 0x8003, 0xB83B, 0xB83B, 0xB83B, 0x8003, 0xB83B, 0xB83B, 0xB83B, 0x8003, 0xFFFF, 0x3FFF }

/* ------------------------------------------------------------------- */

#define MAXMFPAPER      14

#define PAPERMASK       { 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF }

#define PAPER00DATA     { 0xA005, 0xE007, 0xA005, 0xA005, 0xE007, 0xA005, 0xA005, 0xE007, 0xA005, 0xA005, 0xE007, 0xA005, 0xA005, 0xE007, 0xAD65, 0xA005 }
#define PAPER01DATA     { 0xA005, 0xA005, 0xE007, 0xA005, 0xA005, 0xE007, 0xA005, 0xA005, 0xE007, 0xA005, 0xA005, 0xE007, 0xAD65, 0xA005, 0xEEA7, 0xA005 }
#define PAPER02DATA     { 0xE007, 0xA005, 0xA005, 0xE007, 0xA005, 0xA005, 0xE007, 0xA005, 0xA005, 0xE007, 0xAD65, 0xA005, 0xEEA7, 0xA005, 0xAAD5, 0xE007 }
#define PAPER03DATA     { 0xA005, 0xE007, 0xA005, 0xA005, 0xE007, 0xA005, 0xA005, 0xE007, 0xAD65, 0xA005, 0xEEA7, 0xA005, 0xAAD5, 0xE007, 0xA005, 0xA005 }
#define PAPER04DATA     { 0xA005, 0xA005, 0xE007, 0xA005, 0xA005, 0xE007, 0xAD65, 0xA005, 0xEEA7, 0xA005, 0xAAD5, 0xE007, 0xA005, 0xA005, 0xEDA7, 0xA005 }
#define PAPER05DATA     { 0xE007, 0xA005, 0xA005, 0xE007, 0xAD65, 0xA005, 0xEEA7, 0xA005, 0xAAD5, 0xE007, 0xA005, 0xA005, 0xEDA7, 0xA005, 0xAAC5, 0xE007 }
#define PAPER06DATA     { 0xA005, 0xE007, 0xAD65, 0xA005, 0xEEA7, 0xA005, 0xAAD5, 0xE007, 0xA005, 0xA005, 0xEDA7, 0xA005, 0xAAC5, 0xE007, 0xA005, 0xA005 }
#define PAPER07DATA     { 0xAD65, 0xA005, 0xEEA7, 0xA005, 0xAAD5, 0xE007, 0xA005, 0xA005, 0xEDA7, 0xA005, 0xAAC5, 0xE007, 0xA005, 0xA005, 0xE007, 0xA005 }
#define PAPER08DATA     { 0xEEA7, 0xA005, 0xAAD5, 0xE007, 0xA005, 0xA005, 0xEDA7, 0xA005, 0xAAC5, 0xE007, 0xA005, 0xA005, 0xE007, 0xA005, 0xA005, 0xE007 }
#define PAPER09DATA     { 0xAAD5, 0xE007, 0xA005, 0xA005, 0xEDA7, 0xA005, 0xAAC5, 0xE007, 0xA005, 0xA005, 0xE007, 0xA005, 0xA005, 0xE007, 0xA005, 0xA005 }
#define PAPER10DATA     { 0xA005, 0xA005, 0xEDA7, 0xA005, 0xAAC5, 0xE007, 0xA005, 0xA005, 0xE007, 0xA005, 0xA005, 0xE007, 0xA005, 0xA005, 0xE007, 0xA005 }
#define PAPER11DATA     { 0xEDA7, 0xA005, 0xAAC5, 0xE007, 0xA005, 0xA005, 0xE007, 0xA005, 0xA005, 0xE007, 0xA005, 0xA005, 0xE007, 0xA005, 0xA005, 0xE007 }
#define PAPER12DATA     { 0xAAC5, 0xE007, 0xA005, 0xA005, 0xE007, 0xA005, 0xA005, 0xE007, 0xA005, 0xA005, 0xE007, 0xA005, 0xA005, 0xE007, 0xA005, 0xA005 }
#define PAPER13DATA     { 0xA005, 0xA005, 0xE007, 0xA005, 0xA005, 0xE007, 0xA005, 0xA005, 0xE007, 0xA005, 0xA005, 0xE007, 0xA005, 0xA005, 0xE007, 0xA005 }

/* ------------------------------------------------------------------- */

LOCAL MFORM MFROTOR [] =
  {
        { 8, 8, 1, 0, 1, ROTORMASK, ROTOR0DATA },
        { 8, 8, 1, 0, 1, ROTORMASK, ROTOR1DATA },
        { 8, 8, 1, 0, 1, ROTORMASK, ROTOR2DATA },
        { 8, 8, 1, 0, 1, ROTORMASK, ROTOR3DATA },
        { 8, 8, 1, 0, 1, ROTORMASK, ROTOR4DATA },
        { 8, 8, 1, 0, 1, ROTORMASK, ROTOR5DATA },
        { 8, 8, 1, 0, 1, ROTORMASK, ROTOR6DATA },
        { 8, 8, 1, 0, 1, ROTORMASK, ROTOR7DATA }
  };


/* ------------------------------------------------------------------- */

LOCAL MFORM MFCLOCK [] =
  {
        { 8, 8, 1, 0, 1, CLOCKMASK, CLOCK00DATA },
        { 8, 8, 1, 0, 1, CLOCKMASK, CLOCK01DATA },
        { 8, 8, 1, 0, 1, CLOCKMASK, CLOCK02DATA },
        { 8, 8, 1, 0, 1, CLOCKMASK, CLOCK03DATA },
        { 8, 8, 1, 0, 1, CLOCKMASK, CLOCK04DATA },
        { 8, 8, 1, 0, 1, CLOCKMASK, CLOCK05DATA },
        { 8, 8, 1, 0, 1, CLOCKMASK, CLOCK06DATA },
        { 8, 8, 1, 0, 1, CLOCKMASK, CLOCK07DATA },
        { 8, 8, 1, 0, 1, CLOCKMASK, CLOCK08DATA },
        { 8, 8, 1, 0, 1, CLOCKMASK, CLOCK09DATA },
        { 8, 8, 1, 0, 1, CLOCKMASK, CLOCK10DATA },
        { 8, 8, 1, 0, 1, CLOCKMASK, CLOCK11DATA }
  };

/* ------------------------------------------------------------------- */

LOCAL MFORM MFCOFFEE [] =
  {
        { 8, 8, 1, 0, 1, COFFEEMASK, COFFEE0DATA },
        { 8, 8, 1, 0, 1, COFFEEMASK, COFFEE1DATA }
  };

/* ------------------------------------------------------------------- */

LOCAL MFORM MFDISC [] =
  {
        { 8, 8, 1, 0, 1, DISCMASK, DISC0DATA }
  };

/* ------------------------------------------------------------------- */

LOCAL MFORM MFABACUS [] =
  {
        { 8, 8, 1, 0, 1, ABACUSMASK, ABACUS0DATA },
        { 8, 8, 1, 0, 1, ABACUSMASK, ABACUS1DATA },
        { 8, 8, 1, 0, 1, ABACUSMASK, ABACUS2DATA },
        { 8, 8, 1, 0, 1, ABACUSMASK, ABACUS3DATA }
  };

/* ------------------------------------------------------------------- */

LOCAL MFORM MFDICE [] =
  {
        { 8, 8, 1, 0, 1, DICEMASK, DICE0DATA },
        { 8, 8, 1, 0, 1, DICEMASK, DICE1DATA },
        { 8, 8, 1, 0, 1, DICEMASK, DICE2DATA },
        { 8, 8, 1, 0, 1, DICEMASK, DICE3DATA },
        { 8, 8, 1, 0, 1, DICEMASK, DICE4DATA },
        { 8, 8, 1, 0, 1, DICEMASK, DICE5DATA }
  };


/* ------------------------------------------------------------------- */

LOCAL MFORM MFPAPER [] =
  {
        { 8, 8, 1, 0, 1, PAPERMASK, PAPER00DATA },
        { 8, 8, 1, 0, 1, PAPERMASK, PAPER01DATA },
        { 8, 8, 1, 0, 1, PAPERMASK, PAPER02DATA },
        { 8, 8, 1, 0, 1, PAPERMASK, PAPER03DATA },
        { 8, 8, 1, 0, 1, PAPERMASK, PAPER04DATA },
        { 8, 8, 1, 0, 1, PAPERMASK, PAPER05DATA },
        { 8, 8, 1, 0, 1, PAPERMASK, PAPER06DATA },
        { 8, 8, 1, 0, 1, PAPERMASK, PAPER07DATA },
        { 8, 8, 1, 0, 1, PAPERMASK, PAPER08DATA },
        { 8, 8, 1, 0, 1, PAPERMASK, PAPER09DATA },
        { 8, 8, 1, 0, 1, PAPERMASK, PAPER10DATA },
        { 8, 8, 1, 0, 1, PAPERMASK, PAPER11DATA },
        { 8, 8, 1, 0, 1, PAPERMASK, PAPER12DATA },
        { 8, 8, 1, 0, 1, PAPERMASK, PAPER13DATA },
};

/* ------------------------------------------------------------------- */

LOCAL INT       gm_rotor        = 0;
LOCAL INT       gm_clock        = 0;
LOCAL INT       gm_coffee       = 0;
LOCAL INT       gm_disc         = 0;
LOCAL INT       gm_abacus       = 0;
LOCAL INT       gm_dice         = 0;
LOCAL INT       gm_paper        = 0;

/* ------------------------------------------------------------------- */

LOCAL BOOL      gm_mctrl        = FALSE;

/* ------------------------------------------------------------------- */

LOCAL VOID BeginMouseForm ( INT *count )

{
  if ( ! gm_mctrl )
    {
      BeginControl ( CTL_MOUSE );
      gm_mctrl = TRUE;
    }
  *count= 0;
}

/* ------------------------------------------------------------------- */

LOCAL VOID EndMouseForm ( VOID )

{
  if ( gm_mctrl )
    {
      EndControl ( CTL_MOUSE );
      gm_mctrl = FALSE;
    }
  ShowArrow ();
}

/* ------------------------------------------------------------------- */

LOCAL VOID IncCounter ( INT *counter, INT maxi )

{
  if ( ++(*counter) >= maxi )
    {
      *counter = 0;
    }
}

/* -------------------------------------------------------------------
 * Maus-Funktionen
 * ------------------------------------------------------------------- */

VOID ShowRotor ( VOID )

{
  BeginMouseForm ( &gm_rotor );
  graf_mouse ( USER_DEF, &MFROTOR [gm_rotor] );
}

/* ------------------------------------------------------------------- */

VOID UpdateRotor ( VOID )

{
  IncCounter ( &gm_rotor, MAXMFROTOR );
  graf_mouse ( USER_DEF, &MFROTOR [gm_rotor] );
}

/* ------------------------------------------------------------------- */

VOID EndRotor ( VOID )

{
  EndMouseForm ();
}

/* ------------------------------------------------------------------- */

VOID ShowClock ( VOID )

{
  BeginMouseForm ( &gm_clock );
  graf_mouse ( USER_DEF, &MFCLOCK [gm_clock] );
}

/* ------------------------------------------------------------------- */

VOID UpdateClock ( VOID )

{
  IncCounter ( &gm_clock, MAXMFCLOCK );
  graf_mouse ( USER_DEF, &MFCLOCK [gm_clock] );
}

/* ------------------------------------------------------------------- */

VOID EndClock ( VOID )

{
  EndMouseForm ();
}

/* ------------------------------------------------------------------- */

VOID ShowCoffee ( VOID )

{
  BeginMouseForm ( &gm_coffee );
  graf_mouse ( USER_DEF, &MFCOFFEE [gm_coffee] );
}

/* ------------------------------------------------------------------- */

VOID UpdateCoffee ( VOID )

{
  IncCounter ( &gm_coffee, MAXMFCOFFEE );
  graf_mouse ( USER_DEF, &MFCOFFEE [gm_coffee] );
}

/* ------------------------------------------------------------------- */

VOID EndCoffee ( VOID )

{
  EndMouseForm ();
}

/* ------------------------------------------------------------------- */

VOID ShowDisc ( VOID )

{
  BeginMouseForm ( &gm_disc );
  graf_mouse ( USER_DEF, &MFDISC [gm_disc] );
}

/* ------------------------------------------------------------------- */

VOID UpdateDisc ( VOID )

{
  IncCounter ( &gm_disc, MAXMFDISC );
  graf_mouse ( USER_DEF, &MFDISC [gm_disc] );
}

/* ------------------------------------------------------------------- */

VOID EndDisc ( VOID )

{
  EndMouseForm ();
}

/* ------------------------------------------------------------------- */

VOID ShowAbacus ( VOID )

{
  BeginMouseForm ( &gm_abacus );
  graf_mouse ( USER_DEF, &MFABACUS [gm_abacus] );
}

/* ------------------------------------------------------------------- */

VOID UpdateAbacus ( VOID )

{
  IncCounter ( &gm_abacus, MAXMFABACUS );
  graf_mouse ( USER_DEF, &MFABACUS [gm_abacus] );
}

/* ------------------------------------------------------------------- */

VOID EndAbacus ( VOID )

{
  EndMouseForm ();
}

/* ------------------------------------------------------------------- */

VOID ShowDice ( VOID )

{
  BeginMouseForm ( &gm_dice );
  graf_mouse ( USER_DEF, &MFDICE [gm_dice] );
}

/* ------------------------------------------------------------------- */

VOID UpdateDice ( VOID )

{
  IncCounter ( &gm_dice, MAXMFDICE );
  graf_mouse ( USER_DEF, &MFDICE [gm_dice] );
}

/* ------------------------------------------------------------------- */

VOID EndDice ( VOID )

{
  EndMouseForm ();
}

/* ------------------------------------------------------------------- */

VOID ShowPaper ( VOID )

{
  BeginMouseForm ( &gm_paper );
  graf_mouse ( USER_DEF, &MFPAPER [gm_paper] );
}

/* ------------------------------------------------------------------- */

VOID UpdatePaper ( VOID )

{
  IncCounter ( &gm_paper, MAXMFPAPER );
  graf_mouse ( USER_DEF, &MFPAPER [gm_paper] );
}

/* ------------------------------------------------------------------- */

VOID EndPaper ( VOID )

{
  EndMouseForm ();
}

/* ------------------------------------------------------------------- */
