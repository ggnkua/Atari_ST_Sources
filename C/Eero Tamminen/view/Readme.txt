View can show Atari mono and (1-256) color IMG files, mono and gray
portable bitmap files (pbm and pgm) on a 640x400 ST high resolution.
View accesses logical screen straight without VDI as that's not
available unless GEM is initialized (eg.  when MiNT is run from
the auto folder).

Images may be nearly of any size (<8000x8000) that fits onto the memory.
Images can be scrolled around with the number keypad.  Next image will
be loaded with the '+' key and previous one with the '-' key. Pressing
's' will save a screen dump of the picture into current directory as
'dump.doo'.

You can change the dither matrix used for dithering the color images by
giving '-d' command line argument and the matrix file name.  Matrix
files are expected to be the 256 intensity level ones used by a freeware
'Dither' program made by Alexander Clauss.

I myself use this program to (pre)view files produced by TeX (dvi files
converted to IMGs with dvi2img.ttp) and GnuPlot (term pbm) when running
MiNT without GEM.  For image processing I use Mgif which is a very nice
program indeed, but needs considerably more memory.


            - Eero -   /* t150315@cc.tut.fi */
