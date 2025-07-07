SAVERCNF.TOS is a *very* simply program that patches the screen saver program
SAVER.PRG with a new timer value.

SAVERCNF.TOS and SAVER.PRG must be in the same directory when SAVERCNF.TOS is
run.  SAVER.PRG will be modified, so make sure the new SAVER.PRG is put in
the correct place before rebooting your system (which will be required to
implement the new screen saver timer value).

Keep in mind that I wrote this program for a specific version of SAVER.PRG,
and it probably won't work with future versions.  I've included *most* of the
C code for SAVERCNF.TOS, so someone with a C compiler could probably hack it
up to find the timer in future versions.

I've found that SAVER.PRG doesn't work well with JCLOCK8D, the corner clock
program by John Stanley.  If the coner clock is being displayed when this
screen save kicks in then when you press a key or move the mouse the corner
clock display will be a little strange.  I don't know who's problem this is.

Your comments are appreciated:       Mark A. Abreu
                                     GEnie: M.ABREU
