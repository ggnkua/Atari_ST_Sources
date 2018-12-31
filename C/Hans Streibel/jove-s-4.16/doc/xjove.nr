.TH XJOVE 1 "8 July 1993"
.SH NAME
Xjove, Jovetool \- run JOVE under X-windows or Sunview with function-key and mouse support.
.SH SYNOPSIS
.B xjove
[
.I window_args
] [
.B "\-f | \-nf"
] [
.BI \-rc \ run_command_path
]\&.\|.\|.
[
args
\&.\|.\|. ]
.br
.B jovetool
[
.I window_args
] [
.B \-nf
] [
.BI \-rc \ run_command_path
]\&.\|.\|.
[
.I args
\&.\|.\|. ]
.SH DESCRIPTION
.I Xjove
(or
.IR Jovetool )
creates an XView or SunView frame and a tty subwindow within which mouse events
and function keys are translated to ASCII sequences which JOVE can
parse.  The translated input events are sent to the process running in
the tty subwindow, which is typically JOVE.
.I Xjove
thereby allows JOVE users to make full use of the mouse and function keys.
JOVE has functions to interpret the mouse and function-key events to make a
truly fine screen oriented editor for any workstation supporting XView or SunView.
.SH OPTIONS
.I Xjove
supports all the standard window arguments, including font and icon
specifiers.
.PP
.I Xjove
has the ability to fork off a separate process to run the window that is
created, leaving the shell from which the
.I Xjove
command was issued free to accept other commands.  This feature is enabled
by the
.B \-f
(for fork) flag and disabled by the
.B \-nf
(for no fork) flag. The default is set by the
.I xjove.forking
resource which can be set to True or False in your .Xdefaults file (default
False).
.PP
By default,
.I Xjove
runs the program
.I jove
in the created subwindow.
The value of the environment variable
.I JOVETOOL
can be used to override this if your version of JOVE
is not accessible on your search path by the name
.IR jove .
In addition, the run command can be set by the
.I pathname
following the last occurrence of the
.B \-rc
flag.
This is convenient for using
.I Xjove
to run on remote machines.
.PP
All other command line arguments not used by the window system are passed
as arguments to the program that runs in the Xjove window.
.PP
For example:
.PP
local% xjove \-rc rlogin remote
.PP
will create an Xjove window logged in to a machine named
.IR remote .
.I Xjove
will encode mouse and function keys, and send them to rlogin.
If JOVE is run from this shell on the remote machine, it will see
the mouse and function keys properly.
.SH "USING XJOVE"
The following assumes the use of the recommended bindings from the
mouse operations to the Jove mouse-commands. Note how, in general,
LEFT does things involving the
.IR point ,
whereas MIDDLE does things involving the
.IR mark .
.PP
Use of mouse buttons
.TP 5
LEFT
Sets the cursor at the character pointed to. Actually, it is the place you
are pointing at when you release the button that counts.
.TP 5
MIDDLE
Sets the
.I mark
at the character pointed to when you press it. You may then
move to another point before releasing it, thus delineating the
.I region
from where you pressed to where you released. The position of the mark always
remains underlined (not easy to see if the cursor is at the same place).
.TP 5
MIDDLE + CTRL
Sets the region as before, but then does a COPY (copy-region).
.TP 5
MIDDLE + CTRL + SHIFT
Sets the region as before, but then does a CUT (kill-region).
.TP 5
LEFT + CTRL
Sets the cursor as before, but then does a PASTE (yank). This can be used
in conjunction with the previous two commands so as to copy or move text from
one place to another. However, the following two commands do this job better.
.TP 5
MIDDLE + PASTE
Remembers the current position of the cursor, then does a COPY (copy-region)
on the region you select (possibly in another window), and finally
PASTEs (yanks) it at the remembered position.
.TP 5
MIDDLE + CUT
Remembers the current position of the cursor, then does a CUT (kill-region)
on the region you select (possibly in another window), and finally
PASTEs (yanks) it at the remembered position.
.TP 10
Multiple clicks on MIDDLE
In all the above usages of MIDDLE, a double click will set the
.I mark
at the start of the word pointed into and the
.I point
at the end of that word. Likewise, a triple click selects the whole of the
current line. This is similar to the effects of multiple
clicks in Open-Look windows and Sunview.
.PP
Note that the above commands only work if you point within the current
window. Except when in conjunction with PASTE or CUT, the first click into a
different window simply selects that other window. Click twice if you want
to set the cursor or the mark in the other window.
.TP 5
LEFT when in the Modeline
Assuming the variable scroll-bar is ON, the position of the window
within the overall buffer is shown by unhighlighting the corresponding
part of the Modeline. Pointing at a place in the Modeline and pressing
either of LEFT or MIDDLE causes the text to scroll to that place. You
may hold the button down and move the mouse left or right until you see
what you want in the window.
.TP 5
RIGHT
Brings up a menu with pull-right options enabling you to obey any JOVE
command, or set any JOVE variable. If the command requires a parameter (or
the variable requires a value other than ON/OFF), you still have to type it
in as usual.
.TP 5
SHIFT
Holding SHIFT down at the same time as any other key or mouse operation
(except with CTRL \(em see above) reverts to the normal behaviour of
.IR Shelltool(1) .
Thus you can make selections, and copy and paste them to/from the
clipboard using L6, L8 and L10.
.SH OPERATION
JOVE will automatically load the file
.IR jove.rc.$TERM .
It is therefore necessary that this file understands the code sequences that
are produced when function keys are pressed in Xjove (these are not
necessarily the same as might normally be produced by that $TERM). These
follow, more or less, the practice of Sun Workstations (with the addition,
except when SHIFT is down, of some keys such as L-1,6,8,9 and 10 which
Shelltool usually reserves for its own purposes, and of the KP-* keys around
the outside of the numeric keypad, such as KP_Add and KP_Enter).
.PP
In addition,
.I Xjove
sets the environment variable
.I IN_JOVETOOL
.B "= 't'" ,
so that applications running in an Xjove window can be aware of the fact.
.PP
Mouse buttons are encoded as `^Xm[0-9](c x y t)\\n'.  ^Xm is the
JOVE mouse-command prefix, [0-9] indicate which key was pressed, and
whether it was a down, up, drag or multi-click event. These are
followed by a list indicating the state of CTRL, SHIFT, PASTE and CUT, the
character row and column of the point in the window where the mouse
cursor is, and the number of pixels in the width of a character.  In
JOVE, these ^Xm* dispatch to appropriate mouse-command handlers which
then read the following list.
.SH BUGS
The normal Sunview "selection" facilities that enable text to be Cut and
Pasted between windows (as provided by Shelltool and Cmdtool) only work
when SHIFT is pressed.
.br
Because SHIFT and CTRL together have a special meaning, it is not possible
under SunView to make a selection "Pending Delete".
.br
Due to a bug in some versions of XView, the underlining of the mark may
not occur (but emboldening may be used as an alternative).
.br
Under SunView, the initial terminal settings for the tty window are
apparently taken from the controling tty.  This can lead to
surprises.
.SH "ENVIRONMENT VARIABLES"
.I "JOVETOOL IN_JOVETOOL TERM"
.br
For Xjove, the XView shared library must be visible. It may therefore
be necessary to arrange for the Environment Variable LD_LIBRARY_PATH to
include $OPENWINHOME/lib, where $OPENWINHOME would usually be
/usr/openwin.
.SH "SEE ALSO"
.I jove(1)
