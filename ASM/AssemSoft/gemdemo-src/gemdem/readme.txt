Hello ozk!

I am now done with these things..

bump.s
------
this is the small routine that you should use!
some small explanations:

the "bump_init" should be called once, before the other
things start.

the "bumpmapper" should be called once per update, it will
increase sinus and draw the effect.

destination address is put to a0 (says 'screen_adr' now)

the two source addresses (for flare, and bumpmap surface)
should not be changed.


demo_os.s
---------
this is a "ready to run" version of the whole thing,
including the demo-os I use for our demos. it will only
show the bumpmapper in the upper left corner, but you will
get an idea how it should look, and how fast it is
without GEM.


video.s
-------
this is a supplement to demo_os.s, it have abunch of common
videomodes for falcon, which can be easily used.



so.. I hope you will understand this, it shouldn't be too 
hard I guess... cu on irc!




ohh.. and please, do not distribute any of these sources..


S„ter/Sweden - may 03, 1998