31 August 1990

   So, you want to put more than 16 colors on the screen at once, eh?  Well,
here are some routines which create a Spectrum 512 file, which can be displayed
by Spectrum itself or by the ARTGALRY desk accessory (and no doubt other
programs).  I just finished whipping up this stuff, and have not bothered to
document it to any degree, but the basic parameters are:

(a)  Screen size is 200 lines (Y) x 320 columns (X).  Specifying coordinates
outside of that range will cause odd errors, and my routines have no error
checking built in right now.  That is, 0 <= Y <= 199 and 0 <= X <= 319.  Line
0 is never displayed by Spectrum, so you might as well not bother filling it.

(b)  Colors are specified in two ways: As an integer from 0 - 511, or as an
Atari color word (hex 0RGB, where 0 <= [R, G or B] <= 7).  The routines take
differing inputs, as can be seen in the sources.

(c)  About 50 Kb of data space is required for the routines, and about 7 Kb
for the code.

(d)  The output file should have the extension ".spu", which means "Spectrum
uncompressed".  It will take up about 50 Kb of disk.

(e)  Up to 48 colors may be displayed on a given scan line, but not neces-
sarily that many.  The SpecAddColor routine will return an error if it cannot
fit a desired color in at some column.  Any given column can only display one
of 16 pallette slots, and fitting lots of colors around a small group of columns
sometimes does not work.

(f)  If you do not SpecSetPixel a particular point, it will show as black.

(g)  This code works with the Mark Williams compiler, and may take a bit of
tweaking to work with others.

   The format of the Spectrum file has been described in various places --
search around on the networks for such papers.  I have never found one which
tells you how to encode (vs. decode) a Spectrum 512 file, and I had to figure
it out by myself, which was not all that easy.  You will likely be able to
glean it from reading the enclosed code.

   My example program (spectest.c) will display the entire pallette which can
be created on Atari computers (not counting the STe, of course), and shows
how to use the routines in specout.c.  It takes 1.25 minutes to run, which is
not too bad for unoptimized code.  Red and green together increase from bottom
to top, and blue increase from left to right.

   If you like this stuff, or find bugs, please drop me a line and tell me so.
If I get a few requests, I shall write up a detailed explanation of just how
Spectrum files are encoded and so forth.

   I have found these routines very handy (if slightly cumbersome in their
present incarnation) for image-rendering programs.  Enjoy.

   These routines are hereby declared to be in the public domain, and may be
used in any way at all.  I request that this file and the headers on the source
files be left intact if you redistribute the code.  Spectrum 512 is copyrighted
by some company or other (I do not have a copy, oddly enough), and you are of
course obliged to observe their copyrights and the copyrights of any other
relevant individuals or companies, such as those of the authors of any file-
viewing programs you might use to display Spectrum format files.


		John Rosenberg

		CIS [73607,3464]
		Genie J.ROSENBERG5
