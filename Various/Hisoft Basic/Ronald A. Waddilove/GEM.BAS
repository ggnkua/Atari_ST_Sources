REM Using the VDI: Program I
REM By R.A.Waddilove
REM HiSoft BASIC

LIBRARY "GEMVDI"

DEFINT a-z

REM HiSoft BASIC initialises the GEM AES arrays and opens a
REM virtual workstation for you. You don't need the VDI handle,
REM but if you are interested, here's how to get it...
handle = FNhandle

REM Clear the workstation (screen)
v_clrwk

REM Print some text using: v_gtext x, y, string
v_gtext 16, 64, "This is a test..."
v_gtext 16, 80, "Click the mouse button..."

REM Wait for a mouse click
CALL wait

REM Close virtual workstation and exit.
REM Let HiSoft BASIC do the donkey work!
SYSTEM

'----------------------------------------------------------------------

REM Wait until a mouse button is pressed
SUB wait
x = 0 : y = 0 : button = 0
DO
    vq_mouse button, x, y
LOOP UNTIL button>0
END SUB
