README.TXT
by Roy Stead, 2/3/92

Okay - better late than never, here they are: the programs to accompany my
piece _What Are Fractals, Anyway?_ from the May 1992 issue of _Atari ST User_.

Don't ask me what happened to the first disk with the programs on. I asked
The People At The Mag and all I was told was, "I ran out of memory... I had a
flat diskhead... I didn't have enough money for cab fare... my tux didn't come
back from the cleaners... An old friend came in from out of town.. Someone
stole the disk... There was an earthquake... A terrible flood... Locusts...
It wasn't my fault, I swear to God! It wasn't my fault!" before they collapsed
in a corner, put on black suits, black hats and dark glasses and started
quaffing Jack Daniels's by the gallon. Ho hum - Murphy's law again.

But enough of these pleasantries:

This file provides a brief description of the operation of the two programs in
this folder: julia.ttp and fern.prg

Since the programs really are so _very_ late, I've decided to include the
C source code in this folder with them, Eris willing that the source code
doesn't go walkabout as well.

I really can't recommend highly enough Ian Connor's _Fractal Zoom_ program
for the Atari ST (available as disk GD466 from Goodman PDL, 0782 335650) and -
for anyone serious about exploring fractals via their own programs - the superb
book _The Science of Fractal Images_ by Michael Barnsley, published in 1988 by
Springer-Verlag. At twenty-three pounds sterling, Barnsley's book is expensive,
but remains the best guide to fractal image programming I have seen (despite the
fact that the example computer programs given are all in BASIC for some bizarre
reason).

While I'm at it, I've just received the latest catalogue from Goodman's, and
notice that there is a new compilation of fractals-exploring programs on
disk GD1576 (Fractals & Mountains). That disk contains five fractal
generating programs, of which these two are two of them (how's that for
clumsy phrasing?), but I haven't seen that disk yet, so I can't tell you how
it compares to Ian Connor's _Fractal Zoom_ (still on GD466).

Oh, and is it too late to plug my own latest shareware release, the _Life 
Microscope_? A "Word Processor" which is the most powerful program I've ever
seen for exploring that other chaos game, Conway's Game of Life? Available
from Goodman PDL on disk GD1575? It is too late? Ah well...

Please bear in mind that these two programs were just quick routines I dashed
off in order to demonstrate to myself that I understood the math behind the
generation of Julia sets and images from IFS codes. They're not meant to be
fool-proofed, so please be gentle with them.


                   - + - + - + - + - + - + - + - + - + -


Program: fern.prg
   Desc: Fern IFS Display program
 Author: Roy Stead
Created: 2/3/91


This program just displays the Fern fractal image using the iterated function
system (IFS) described on pages 240-1 of _The Science of Fractal Images_ by
Michael Barnsley [Springer-Verlag, 1988]

The program will basically loop forever, plotting an ever greater number of
points on the fern image, until the 'Q' key is pressed, which will exit the
program.

The number of iterations so-far performed is displayed in the upper left-hand
corner of the screen and is continuously updated. Since this tends to slow
down the program, however, this feature can be switched off by pressing any key
_except_ 'N', 'I' or 'Q'.

Pressing 'N' or 'I' will switch the iterations-so-far counter back on again.


Key	Operation

q	Quit program
n or i	Switch on display of iteration number
other	Switch off display of iteration number


                   - + - + - + - + - + - + - + - + - + -


Program: julia.ttp
   Desc: Julia Set Display program
 Author: Roy Stead
Created:  1/3/91

Use with:           julia [-help][<real> [<imaginary>]]

Plots the Julia Set for the given number '<real> + <imaginary>i'

julia uses 6000 iterations in plotting the Julia Set using
the inverse iterations method, as described  on page 154 of Michael Barnsley's
excellent manual, _The Science of Fractal Images_ [Springer-Verlag, 1988].

If no number is given, julia uses the default, 0.200000 + 0.300000i.
If only the real part is given, julia assumes the imaginary part is zero. Thus:

julia             Plots default Julia Set (0.200000 + 0.300000i)
julia -1.0        Plots Julia Set for value -1.0 + 0.0i
julia 1.2 0.3     Plots Julia Set for value 1.2 + 0.3i
julia -help       Reproduces this information

Some more suggestions for sets to look at are:

julia -2.0
julia 0.0
julia 0.0 1.0


If you are running this program from the desktop, then double-click on the
program 'julia.ttp' and you will be prompted to enter some parameters.

At this stage, typing:

-help

will provide a help screen, while typing one or two numbers will be interpretted
as described above (i.e. as the complex number of the julia set to draw). Any
other parameters will be ignored and/or will cause the program to crash.

Julia is not meant to be a heavily-fool-proof program, but just a quick-and-easy
program to sketch out the shape of Julia sets on-screen.
