Some programs don't run with GDOS, because this programs call v_opnvwk() or
v_opnwk() with handle 0. Also programs compiled with OMIKRON-basic have this
problem: "Invalid handle".

FixGDOS fix this problem:




                                  F I X - G D O S
          ===============================================================

                            >>>>  PUBLIC - DOMAIN  <<<<


    This Program FIX_GDOS.PRG fix the problem with unvalid VDI handle's
    by using GDOS, AMSGDOS or NVDI and a unclean programming.

    No more:
                 "!!!!!   Invalid GDOS Handle   !!!!!"

    This program can run from the AUTO-folder or from the DESKTOP.
    It links itself into the TRAP#2 (AES/VDI) vector (XBRA, dfGD).

-------------------------------------------------------------------------------
|   Dieter Fiebelkorn                          |  With a rubber duck,   :-)   |
|   fiebelko@petra.informatik.uni-dortmund.de  |  one's never alone.    :^{   |
-------------------------------------------------------------------------------

