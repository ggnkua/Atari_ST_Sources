/*************************************************************************

    Lattice C - MidiShare Library 
   
   ___________________________________________________________
   Function: MidiShare
   tests MidiShare code presence in memory

   Important: Compile with stack checking disabled; compiler option -v
   
   Prototype: int MidiShare(void);

   ___________________________________________________________

    25may95    colin whyles: Begun modification of Turbo C/MWC MidiShare 
            library for Lattice C V5.60   
    31may95    colin whyles: Completed

            c whyles e-mail: whyles_c@btlip03.bt.co.uk
            49 Exeter Road, Felixstowe, Suffolk, IP11 9AT, UK

**************************************************************************/

#include <stdio.h>
#include <osbind.h>

static int _LC_is( void );

extern int  MidiShare( void );


/*************************************************************************/

static int _LC_is( void )
{
register unsigned long *test;       
register char *val;
register char *code = "MIDISHARE";
register int i;

   test = (unsigned long *)0x94L;
   val  = (char *)*test - 18;
   for ( i = 0; i < 9; i++) {
      if ( *code++ != *val++)
         return 0;
   }
   return 1;
}

/*************************************************************************/

int   MidiShare( void )
{
   return Supexec( _LC_is);
}

/******************************** end ************************************/
