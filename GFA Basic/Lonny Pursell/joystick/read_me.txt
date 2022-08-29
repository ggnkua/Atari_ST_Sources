This is a joystick routine for the FireBee + MiNT.
Should work on most any machine/OS though.
It only reads port 1 and leaves port 0 in mouse mode.
You could say it's a GEM friendly stick routine. ;o)

It does not auto install itself or undo itself when the app exits.
You do @stick(1) to enable it and @stick(0) to disable it.

It relies on the fact that the ST sends joystick packets on port 1 by default.
It hooks joyvec and mousvec via kbdvbase().
This is why it's critical you disbale it before the app exits!

It uses XBRA and it's as clean as it can be coded, considering it steal vectors.
However, that's the only way to read ports 0 and 1.

The parameter for functions @stick() and @strig() is ignored, it's only there
so it looks and feels like the built in stick commands.

It's written in Devpac assembler, source included. It works from an INLINE.

By Lonny Pursell
6/9/2016
Version 1.00
