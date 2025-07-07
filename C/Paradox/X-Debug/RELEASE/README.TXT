Welcom to X-Debug version 1.01

Notes
=====
If using LOADHIGH on certain TOS versions, after the LOAD WAIT command
is executed you may get a seemingly suprious Trace exception in the ROM.
If this happens, type RUN and everything should work as expected.

If using LOAD WAIT to debug high-level-language desk accessories, it is 
recommended that the reserved symbol 'compilertype' be set before doing so.

X-Debug is compatible with the Falcon 030 in ST-compatible screen modes.
It can also work in all new modes (except True Colour) if the 'overscan'
startup variable is set, although the palette can be incorrect. A
proper Falcon-aware version of X-Debug wil be developed as soon as possible.
