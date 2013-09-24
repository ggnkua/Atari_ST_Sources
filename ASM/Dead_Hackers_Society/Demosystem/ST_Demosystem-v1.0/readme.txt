DEAD HACKERS SOCIETY 
Synclock Demosystem v1.0
September 10, 2011

FAQ

------------------------------------------------------------------------------   
Q: What does this thing do?
A: It makes it pretty easy to write a multipart demo with fullscreen/
   synclocked screens for ST and STe.
------------------------------------------------------------------------------
Q: Falcon and TT compatibility?
A: Fullscreens and other synclock effects won't work on Falcon or TT machines
   by nature. But if you decide to write normal ST-LOW based screens, there's
   a flag to set in main.s to enable Falcon compatibility. 
   About TT: Sorry no go (no 50 Hz screen).
------------------------------------------------------------------------------
 Q: How to build the source?
 A: We use VASM. Commandline example:
    vasm -Ftos -tos-flags=1 main.s -o main.tos
    
    VASM is available for Atari, Mac,Linux, Windows and whatever. You can
    cross-build the Atari demo from almost any platform.
    
    Check out the VASM site:
    http://sun.hasenbraten.de/vasm/
------------------------------------------------------------------------------
Q: Which music driver works where?
A: SNDH player:
    - Without timer effects, SNDH can be used for all type of effects.
    - With timer effects, SNDH can only be used in ST-LOW screens.
      NOTICE! Enable music_sndh_fx in main.s if the SNDH file have timer
      effects (it disables the demosystems own Timer A part).
    - Most SNDH files can be played on ST, STe and Falcon. But a few need DMA
      sound and some might not work well on Falcon.

    YM3 player:
     - Can be used for all type of effects. Works on ST, STe and Falcon.
     - Must be unpacked!
    
    DMA player:
     - STe and Falcon only.
     - Can be used with any type of effects.
     - It's a simple sample sequencer.
     
    YM-DIGI8 player:
     - ST and STe only.
     - ST-LOW effects and fullscreen/synclock effects with careful coding.
     - Uses HBL for interupt so it can be used seamlessly between ST-LOW and
       fullscreen effects (no detuning).
     - As HBL is used for sample playing, keep the VBL as short as possible.
     - Like the DMA player, it's a simple sample sequencer.
     - 8-bit mono samples at 15650 Hz.
     - Uses the volume tab by Wizzcat / Delta Force. 

    MOD Protracker player by Lance:
     - STe only.
     - 50 kHz four channel stereo.
     - About 1/3 of CPU used.
     - Runs completely off VBL so it melts nicely together with border
       removing and rasters.
     - CIA timing not supported.
------------------------------------------------------------------------------
Q: That's all?
A: Yep, no more time to write this crap. Mail me if you have questions.
   ae@dhs.nu
------------------------------------------------------------------------------    