/* Sozobon C */

#include <osbind.h>
#include <xgemfast.h>

/* VIDSLEEP.C   14/11/1995   TmutZ Software (levjenno@dds.nl)           */
/* Machine: Falcon 030                                                  */
/* This program will switch the Vertical Sync of your video system to   */
/* external, which will cause power saving (S)VGA monitors to go into   */
/* standby or sleep mode. It should also reduce your bus load a little. */
/* WARNING: THIS PROGRAM *MIGHT* DAMAGE SOME MONITORS!!!                */
/* I therefore take NO responsability for any damage done by this       */
/* to your hardware or software! This program comes WITHOUT warranty.   */

/* Changes: 04/11/1997 - GEM version now locks keyboard control.        */

main()
{
    /* This is the GEM version */

    appl_init();                /* I'm here! (AES) */

    wind_update(BEG_UPDATE);    /* Lock screen (AES) */

    xbios(37);                  /* Wait for VBL */
    xbios(90,2);                /* External Vsync */

    evnt_keybd();               /* Wait for keypress (AES) */

    xbios(90,0);                /* Internal Vsync */

    wind_update(END_UPDATE);    /* Unlock screen (AES) */

    appl_exit();                /* I'm done! (AES) */
    return(0);                  /* Bye! */
}


/* The bit below is in 68000 assembly */

/* -------------------- GEMDOS version: -----------------------

.TEXT

    ; VIDSLEEP.S - The GEMDOS version (uses GEMDOS to wait for key)

    move.w  #37,-(sp)           ; Wait vor VBL
    trap    #14
    addq.l  #2,sp

    move.w  #2,-(sp)            ; Set Vsync to external
    move.w  #90,-(sp)
    trap    #14
    addq.l  #4,sp

    move.w  #7,-(sp)            ; Wait for a keypress
    trap    #1                  ; GemDOS call #7 - Crawcin
    addq.l  #2,sp

    move.w  #0,-(sp)            ; Set Vsync to internal
    move.w  #90,-(sp)
    trap    #14
    addq.l  #4,sp

.END

   ----------------------------------------------------------- */
