----------------------------------------------------------------------------
ct60 virtual light machine - copyright (c) 2004, 2005 by pieter van der meer
----------------------------------------------------------------------------

----------------------------------------------------------------------------
legal 
----------------------------------------------------------------------------

you are free to copy this software, but usage should be strictly for non-
commercial purposes. please contact the authors if you intend to make some
money with it:

pieter van der meer
pvdmeer@gmail.com

christos zoumpas
zoumpas@inventgr.com

this software is intended as the basis for a newer and commercial vlm. so 
the current vlm may be seen as a free preview.

----------------------------------------------------------------------------
system requirements
----------------------------------------------------------------------------

the requirements:

atari falcon, 14 megs, rgb or vga

recommended (for anything more than whip plugins):

tt ram, 50 mhz cpu at least, preferably a 060.
for instance a ct2 system, but even better a ct60. 

(hey, at least you don't need fpu ;))

----------------------------------------------------------------------------
features
----------------------------------------------------------------------------

the ct60 vlm is quite normal. it compares to whip and is (partially) 
compatible with this program. the goal is to make a vlm that has most whip 
features, but in terms of visuals compares to i-tunes (mac) or some 2d 
plugins in winamp (windows), for instance geiss.dll. 

it can take input from the mic, the good ole yammy and possibly even sdma.
desktracker or paula, anyone? you can even configure the falcon's matrix
to have yammy on left and mic on right for some fun ;)

also, the idea is to have channeling and mixing of multiple plugins 
simultaniously and live control and sequencing features, but this is still
to be done.

----------------------------------------------------------------------------
usage 
----------------------------------------------------------------------------

the main program is 'shell.gtp'. just drag a '.vlm' plugin file onto it and 
watch. you can ofcourse also just run it and then enter a plugin name. the 
vlm eats both traditional 'whip!' plugins, but doesn't always like them.
also note that whip plugins grab the whole system and there still are some
incompatibilities.

to get decent sound input, use the fsnd.cpx by tom noorduin, which is 
supplied with this package. fiddle a bit with adc l/r gain and mic/psg
selection on l/r to get the settings you prefer.

the most important feature of this vlm is not its ability to run the whip
plugins, but to run a newer type of plugin. such plugins offer stuff like
alpha layers, channeling, are multitasking friendly and in newer version
may even be viewed in a window or scaled in real-time.

if you're brave enough you can enter an apx (apex block) file as second 
parameter. this should be a 8 bpp file and of not too big proportions. yep,
now you got a backdrop alpha layer. =) with the numpad's '-' and '+' keys
you can control the alpha. the alpha ofcourse works only with new plugins.

when you're bored with a plugin just hit space.

the following plugins are bundled:

collido.vlm	an old whip plugin by me, nice and psychy
geissvir.vlm	an attempt to recreate the geiss pc thing. reasonably
		succesful. runs okay on ct2, flies on ct60.
galaxy.vlm	a rather sad attempt at a fluffy galaxy, use a ct60 pls
lissajou.vlm    a simple, but effective plugin that looks very nice with
                all kinds of music. soft music = smooth shapes, hard music
                = harsh shapes
radial.vlm	yeps, a radial blur again. at least no cube or tunnel ;)

----------------------------------------------------------------------------
history
----------------------------------------------------------------------------
- v0.1, sept 2004:
  most basic functions: scopes, spectra, volume, alpha background,
  virtual 8 bit chunky mode
- v0.2, jan 2005:
  bugfix: ugly stripes removed by improved vbl handling
  locking function: press 'h' to lock a particular sub effect in a plugin.
  for instance, the geissvir.vlm plugin supports this.

----------------------------------------------------------------------------
bugs and ideas
----------------------------------------------------------------------------

if you notice something odd, send a bug report with complete system config 
(os, rgb/vga, accelerator type, etc).

also, feel free to send any ideas you may have to improve the quality of
this free software.

----------------------------------------------------------------------------
programming
----------------------------------------------------------------------------

it is very easy to code a plugin for this vlm and loads of housekeeping is
done automatically. you don't need buffering, syncing to vbl or even c2p. 
it's all built in!

just for fun, the geiss plugins source code is supplied, so you can try
to hack toghether some of your own plugins.

----------------------------------------------------------------------------
finally
----------------------------------------------------------------------------

have fun! =)

