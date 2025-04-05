             ____________________________________________________            
              ___     ___     ___     ___             ___     ___
             (  __ . (   ' . (___) . (   ) . (   ) . ( | ) . (___
             (___)   (       (   )   (___)   (___)   ( | )   (
              ____    ___     ___     ___     _  _    ___     ___
                )  . (   ' . (___) . (     . (__/  . (___  . (   
                )    (       (   )   (___    (_ \_   (___    (
                        ___  ___        ___  ___   ___
                     / (___ (___) (    (    (   ) (   ) \ 
                     \ (    (   ) (___ (___ (___) (   ) / v0.8777
             ____________________________________________________
       
             ú A 32-voice DSP soundtracker for the Atari Falcon ú


                 Further development by the Graoumf Devteam:-
                  
               sjx of Vectronix      sjx.vectronix@hushmail.com
               Lonny L. Pursell

               http://privatewww.essex.ac.uk/~smooreg/graoumf/

  Based on the sources of Graoumf Tracker v0.8771 by Laurent de SORAS ~ 1997


                              ú Release Notes ú

(0.8778 is due early May)

0.8777 - Slightly improved memory allocation. It still needs attention.
         It doesn't use RESERVE - or undocumented system call GEMDOS 21 -
         anymore!
         
         It still cannot use TT RAM. Sorry. My Falcon doesn't have any
         and I can't test it, but more to the point, when I tried using
         Mxalloc, GFA threw a major wobbly. I will investigate - next
         version ought to be TT RAM ok, but this one isn't.

         Now changes back to GEM's resolution to use the fileselector.
         Minor disadvantage: No caption. I'll fix this in the next release
         but I have no time now, if you want a version before May. :)
         Major advantage: Now locks the screen with the AES (kinda badly,
         but it'll do for now). This means Graoumf can finally run under
         MiNT/N.aes 2.0.0 (tested). Although, you'd better have a really
         fast Falcon, because when I tried it, it was a little... shall
         we say, unresponsive. (N.aes's keyboard routines?) :)

         Volume slide can now optionally have a keyboard shortcut (see
         the prefs file).

         number_of_lines in the prefs file can be set, this indicates
         the default number of lines given to a pattern when right-
         clicking on the lines box or when right-clicking on the
         insert pos buttons (which makes a new pattern for you).
         
         se_revbuffer defaults to FALSE, TRUE is old behaviour. With
         it set to FALSE, the sample editor comes up and exits MUCH
         quicker than previously, although it's not heavily tested
         (there may be some side-effects). Haven't seen any in the
         ten minutes' testing that feature's had though. ;)

         I've included my preferences file (properly, this time) as
         GTKPREFS.SJX if you want to see what I use, or tweak it. :)

         Released 15th April 2000. -- /sjx.

0.8776 - Lots and lots of bugfixes, mainly typos but also other, serious 
         bugs. Most notably -- Graoumf now actually saves envelopes, making 
         them usable, at last! :)

         Additionally, two new preferences were added to the GTKPREFS.INF 
         file:

         grmode_preserve - default no - If set to yes, causes Graoumf not to 
         change the resolution. This does mean Graoumf should be started in a 
         suitable resolution (at least 640x200, 16 colours).

         grmode_skipxbra - default no - If set to yes, Graoumf does not 
         attempt to remove NVDI and some screen expanders from the vector 
         chain.
         
         Changing these both to yes and running Graoumf from the correct 
         resolution seems to make it more stable, although it's worth 
         pointing out that Graoumf absolutely hates NVDI. I'm looking in to 
         this problem, but I think it's the memory allocation.
         
         Incidentally, I had a little more success with this under N.aes,
         in fact it actually runs now, although the mouse clicks "fall 
         through" the graoumf screen. I shall look into adding code to lock 
         the screen with form_dial; if that improves the situation, Graoumf 
         may start to become more stable under MiNT, although it still does 
         not seem to like memory protection much. Your Mileage May Vary.
         I'd be interested to hear how you get on. -- /sjx.

0.8775 - Looks like 0.8770 sometimes messed up saving modules. I've observed 
         gt2 modules with one too many byteswaps, swapping the first and 
         second letter of the chunk header. The net effect of this was to 
         cause 'ASMP' chunks to be written instead of 'SAMP' chunks. 
         Curiously, 0.8770 would load these without problem, but 0.8771 would 
         not. I've added a workaround - once a damaged module is loaded, it 
         will be corrected, so just save it back again. -- /sjx.

0.8774 - Added full support for loading modules from Octalyser - 4, 6 and 8 
         channels, and at 16KHz, 20KHz, 25KHz basespeeds (which would 
         previously crash). Unfortunately I don't have the exact basespeeds 
         used by Octalyser, and in any case they varied by a small amount (if 
         you were using a UCDM, the frequencies were slightly lower). 
         Octalyser modules may thus need a little manual correction, but they 
         will at least load OK. -- /sjx.

0.8773 - Crash (4 bombs) on loading unknown module type corrected. It turns 
         out that a GOTO to an undefined label isn't flagged by the compiler,
         it just compiles into a 'jmp 0' instruction. This is a Bad Thing,
         and definitely something to look out for in the future. -- /sjx.

0.8772 - Registration legacy code removed, is now fully functional without a
         key file. -- /sjx.

0.8771 - The year is 2000; Laurent de SORAS finally releases the full source
         code to Graoumf Tracker. [ In other news, hell freezes over. ;) ]
         Changes between 0.8770 and 0.8771 are not known. Freeware.

0.8770 - Last known binary release by Laurent de SORAS. Changes from this to 
         previous versions are covered in the original documentation 
         WHATSNEW.TXT and will not be duplicated here.


                               ú Known Bugs ú

- Song2disk nonrealtime (monitor off) freezes. Am trying to
  find the cause of this.
- The delay settings are sometimes strange on startup. These
  strange settings may cause the delay routine to emit 2 bombs.
  This is being fixed, but for now, just select one of the presets
  before you use delay.
- Graoumf's memory allocation doesn't suck as much, but still
  needs attention sometimes.
- When changing resolution, parts of the destination screen
  are sometimes cleared. This seems to be the XBIOS 5 call
  itself, unfortunately. Investigations continue.
- Graoumf doesn't like MiNT too much, especially with memory 
  protection, but this isn't as bad as it used to be.
- Graoumf dislikes long filenames sometimes. In any case, it doesn't
  run in the MiNT domain.
- Graoumf hates NVDI. Causes mouse dropping and short sharp buzzes
  in long samples (which turn out to be corrupted). I'd love to
  find out why...
- Lots of problems with 16-bit samples, particularly with extra fine
  sample offset, and "clipping" - the latter caused by malloc. Again.
- Two sources included: SOURCES.OFF (official - doesn't make any sound)
  and SOURCES.NEW (unofficial, patched, but slightly earlier version).
  I will give the replay sources attention in time for the next version!
  
  To do: Rewrite the rest of the memory handling functions.


                            ú Planned Features ú

- Corrections for all the above bugs! :)
- Faster replay routines.
- Save as XM? Would be useful...
- (Partial?) support for mods saved by Graoumf Tracker 2 (pc version)?
- Filters (esp. resonance + low-pass) and synths in the sample editor?
- Loading (+saving?) Impulse Tracker? (.IT)
- Loading and saving Impulse Tracker instruments?
- Realtime filters   la Graoumf Tracker 2/Impulse Tracker? (Punish the dsp?)
- Loading and saving patterns/songs.
- Some extra editing features (wait and see, but they are very useful)


Share and enjoy... contributions welcome, source code included!

See you on IRCnet #atariscne. -- /sjx.

[eof]