                                                               2003-05-03

 The STune source code
 =====================

As you might have noticed, quite a long time has passed since we released
the last public version of STune (version 0.95). It seems that we both
lost the motivation to develop STune and since we are both involved in
other coding projects now, it is very unlikely that we will really start
working on STune again.
So we finally decided to release the source code of STune under the terms
of the GNU general public license (GPL - see gpl.txt).

Some notes about the source code:
- There are very few comments in the source code and often they are only
  in German. Most of the variables and function names are also in German.
- You currently need Pure-C to compile the source code (use the STUNE.PRJ
  project file). However, we once successfully compiled STune with
  Sozobon-C and GCC, too, so these compiler should also work with some
  few changes to the source code. (Note: You might need a 16-bit GEM and
  C library for GCC since STune should be compiled with -mshort on GCC).
- The STUNE.RSC is a multi-language RSC for "Resource-Master 3.1". You
  should not use any other RCS than Resource-Master if you don't want
  to loose the multi-language information.
- I did not include the DSP sound plug-in (DSP.SPI) in this release of the
  source code since its copyright conflicts with the GPL.

If you are using the source code or if you have any questions concerning
STune, it would be nice if you write us an e-mail!

 Thomas Huth
