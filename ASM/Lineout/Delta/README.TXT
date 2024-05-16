----------------------------------------------------------------------------

                          /\
                         / delta - a demo by lineout
                        /____\

----------------------------------------------------------------------------

warning:

this demo is very dense, ram-hungry and takes alot of time to initialise. it
needs 3.4mb free. also, the precalc after the ascii menu takes over 10 secs
(less on accelerators). and please don't cry when it crashes. it especially
did so on ab040.

----------------------------------------------------------------------------

credits:

code:     earx (bits of player stuff by newface)
graphics: havoc (logo), evl (metaball texture)
music:    dforce (alpha), earx (beta), frequent (gamma), laxical (beta)

(music of beta part based on songs by imminent and terror against terror)

----------------------------------------------------------------------------

household information:

delta uses ttram when available and was tested on the following setups:

- 4mb stram, rgb, tos4.01
- 4mb stram, rgb/vga, tos4.02
- ct2a, 14mb stram, 16mb ttram, rgb/vga, tos4.02

(delta doesn't need an fpu and will load swiftly even from floppy)

there is no guarantee that this demo will work on faster machines. some
cpu's/ram's might still be too fast for the dsp-communication. this means a
potential hang. if you still want to try it on 040/060 i recommend unpacking
delta.tos.

there are 3 videomodes to choose from. for a standard falcon i recommend
rgb50 since it gives some screens 1vbl refresh. vga60 support was added for
compatibility reasons: on a stock falcon it looks like crap!

in the menu, you can choose a part of the demo to jump to (a,b or c). after
finishing the chosen part it will run the next. when part c is done the demo
exits. the detail option is only for accelerated falcons and enhances a
few screens.

----------------------------------------------------------------------------

for those who are brave enough, the complete sources are supplied with the
bundle. the file sources.txt gives you some hints on what everything does.
also i wrote a log file evaluating the project: for inside information and
comedy it's best to start there.

contact: pietervdmeer@netscape.net

----------------------------------------------------------------------------

final words

thanx to cyclone, deez, evl and especially sts for their tests. 

- lineout 2003 -------------------------------------------------------------