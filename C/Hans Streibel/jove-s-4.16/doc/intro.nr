.\" ditroff -ms
.
.\" intro.nr: the first half of the JOVE manual (not manpage!).
.\"
.\" To produce the whole manual,
.\" tbl intro.nr | [nt]roff -ms - cmds.nr contents.nr
.
.\" In troff, `\` tends to overlap the characters to its left or right.  In
.\" this text, therefore, it is usually preceded and followed by '\' (a thin
.\" space, ignored in nroff).  Exceptions are where it it adjacent to
.\" whitespace, and the specific cases '\"', '\|', '\1', '\)' and '\}' which
.\" appear better left alone.
.
.de IQ	\" italics (here, in manual) or quote (in describe-command)
\\fI\\$1\\fP\\$2
..
.de BQ	\" bold (here, in manual) or quote (in describe-command)
\\fB\\$1\\fP\\$2
..
.de dc
.NH 2
\\$1
.if '\\$2'(variable)' (variable)
.if !'\\$2'(variable)' (\\$2)
.XS \\n(PN 5n
\\*(SN
\\$1
.if '\\$2'(variable)' (variable)
.XE
.LP
..
.de HH
.nr Op \\n(PS
.RT
.ne 4.1
.if \\$1=1 .nr PS +4
.if \\$1=2 .nr PS +2
.NH \\$1
\\$2
.if \\$1=1 .XS
.if \\$1=2 .XS \\n(PN 5n
.if \\$1=3 .XS \\n(PN 10n
.if \\$1=4 .XS \\n(PN 15n
.ps 10
\\*(SN
\\$2
.XE
.nr PS \\n(Op
.ps \\n(PS
..
.
.\" Set the extra vertical spacing around .DS/.DE
.if n .nr DD 0v
.if t .nr DD \n(PD/2u
.
.nr LL 6.5i
.nr LT 6.5i
.nr Ww (\n(LL-30n-4n)/1n
.EH '%'JOVE Manual for UNIX Users''
.OH ''JOVE Manual for UNIX Users'%'
.TL
JOVE Manual for UNIX Users
.br
Version 4.16
.AU
Jonathan Payne
(with revisions by Doug Kingston, Mark Seiden and Charles Lindsey)
.AI
.AB no
.AE
.HH 1 "Introduction"
.LP
\s-2JOVE\s0*
.FS
*\s-2JOVE\s0 stands for Jonathan's Own Version of \s-2EMACS\s0.
.FE
is an advanced, self-documenting, customizable, display editor.
It (and this tutorial introduction) are based on the original \s-2EMACS\s0
editor and user manual written at M.I.T. by Richard Stallman\(dg.
.FS
\(dgAlthough \s-2JOVE\s0 is meant to be compatible with \s-2EMACS\s0,
and indeed many of the basic commands are very similar,
there are some major differences between the two editors,
and you should not rely on their behaving identically.
.FE
.LP
\s-2JOVE\s0 is considered a display
editor because normally the text being
edited is visible on the screen and is updated automatically as you
type your commands.  What You See Is What You Get.
.KS
.LP
\s-2JOVE\s0 provides many facilities that go beyond
simple insertion and deletion.  Some of the more advanced features are:
.DS
cut and paste (or kill and yank in our terminology);
search and replace using regular-expressions;
multiple files, buffers and windows available simultaneously;
filling of text, both on demand and as you type;
manipulation of words, lines, sentences and paragraphs;
automatic indentation of programs;
automatic location of procedure definitions;
executing programs, capturing their output in buffers;
automatic location of spelling and compilation errors;
parenthesis matching.
.DE
.KE
.LP
\s-2JOVE\s0 is self-documenting insofar as you can call up descriptions of
commands, variables and key bindings.
.KS
.LP
\s-2JOVE\s0 is customizable insofar as you can
.DS
change its behavior by changing appropriate variables;
change its behavior by setting appropriate modes;
automatically set the modes for a buffer from its filename;
define macros to perform complex tasks;
change the key bindings to match features of the particular keyboard.
.DE
.KE
All of these options can be exercised by the system administrator, or by the
user at startup, or even in the middle of a job.
.LP
Finally, mouse support
is available (on screens which support the X-Windows package from M.I.T.)
using the front end program \fIxjove\fP
(or alternatively via the mouse-reporting facilities of the terminal emulator
\fIxterm\fP).
.KS
.HH 1 "The Organization of the Screen"
.LP
\s-2JOVE\s0 divides the screen into several sections.
.TS
center;
=
|| L1	|| L1.

#include <stdio.h>

void main()
{
\ \ \ \ printf("Hello world!\^\e\^n");
\ \ \ \ return 0;	<\ the Window
}

_	
\fBJOVE\ (C OvrWt)\ \ \ [Main:1]\ \ "hello.c"\ \ \(**\ \ /home/foo\ \ \ \ 15:23\fP	<\ the Mode Line
_	
: write-file (default hello.c) aloha.c\^\(sq 	<\ the Message Line
=	
.TE
.KE
.HH 2 "The Window"
.LP
The Window section is used to display the text you are editing.
The terminal's cursor shows the position of \fIpoint\fP,
the location at which editing takes place.
While the cursor appears to point \fIat\fP a character,
point should be thought of as between characters;
it points \fIbefore\fP the character that the cursor appears to be on top of.
Terminals have only one cursor,
and when output is in progress it must appear where the typing is being done.
This doesn't mean that point is moving;
it is only that \s-2JOVE\s0 has no way of
showing you the location of point except when the terminal is idle.
In the example, the user is in the middle of issuing a \fIwrite-file\fP
command, so the cursor is at the end of the message line.
.HH 3 "Typeout"
.LP
The lines of the window are usually available for displaying text but
sometimes are pre-empted by typeout from certain commands (such as a
listing of all the buffers).
You can always recognize such \fItypeout\fP because it is terminated by
either an \fB--end--\fP line or a \fB--more--\fP line.
Most of the time,
output from commands like these is only desired for a short period of time,
usually just long enough to glance at it.
When you have finished looking at the output,
you can type Space to make the text reappear
(usually a Space that you type inserts itself, but when there is typeout in
the window, it does nothing but get rid of that).
Any other command executes normally,
.I after
redrawing your text.
.LP
You will see \fB--more--\fP on the line above the last mode line
when typeout from a command is too long to fit on the screen.
It means that if you type a Space the next screenful of typeout will be
printed.  If you are not interested, typing ^G will cause the rest of the
output to be discarded.  Typing any other key will discard the rest of the
output and that key will be taken as the next keyboard input.  Similarly,
\fB--end--\fP signifies that typeout is complete; the same responses are
accepted.
.LP
Sometimes you may wish to keep a permanent record of the typeout from these
commands.  To do this, set the variable \fIsend-typeout-to-buffer\fP to
\fIon\fP.  The typeout will then be put into a newly-created buffer, which
you can arrange to save to a permanent file.
.HH 2 "The Mode Line"
.LP
The Mode Line gives information about the window above it.  There is a
variable \fImode-line\fP which determines the layout of the mode line.  For
the example above, this was set as described in the section on customizing
\s-2JOVE\s0.
.LP
\fB(C OvrWt)\fP shows that \fBC\fP is the name of the current \fImajor
mode\fP and that the Over Write \fIminor mode\fP is turned on.
.LP
At any time, \s-2JOVE\s0 can be in only one major mode.
Currently there are four major modes: \fIFundamental\fP,
\fIText\fP, \fILisp\fP and \fIC\fP.  New ones may be added in the future.
.KS
.LP
The words which indicate which minor modes are turned on are:
.DS
\fBAbbrev\fP meaning that \fIWord Abbrev\fP mode is on;
\fBAI\fP meaning that \fIAuto Indent\fP mode is on;
\fBFill\fP meaning that \fIAuto Fill\fP mode is on;
\fBOvrWt\fP meaning that \fIOver Write\fP mode is on;
\fBRO\fP meaning that \fIRead Only\fP mode is on.
\fBDef\fP meaning that you are in the process of defining a keyboard macro.
This is not really a mode, but it's useful to be reminded about it.
.DE
.KE
The meanings of these modes are described later in this document.
.LP
\fB[Main:1]\fP shows that the name of the currently selected \fIbuffer\fP
is \fBMain\fP and its number is \fB1\fP.
Each buffer has its own name and holds a file being edited,
which is how \s-2JOVE\s0 can hold several files at once.
But at any given time you are editing only one of them,
the \fIselected\fP buffer.
When we speak of what some command does to \*Qthe buffer\*U,
we are talking about the currently selected buffer.
Multiple buffers make it easy to switch around between several files,
and then it is very useful that
the mode line tells you which one you are editing at any time.
.LP
\fB"hello.c"\fP shows the name of the file being edited in buffer \fBMain\fP.
This is also the default filename for commands that expect a filename as
input, as can be seen in the message line which follows.
.LP
The \(** in the mode line means that there are changes in
the buffer that have not been saved in the file.
If the buffer had not been changed since it was read in or last saved,
there would be a minus instead.
.LP
Sometimes a file is changed ``behind \s-2JOVE\s0's back'': something
changes the file (not the buffer) after it has been loaded into or
saved from a buffer.  This can be quite dangerous, so \s-2JOVE\s0
tests for this when it reads, writes, or finds the file.
\s-2JOVE\s0 indicates the problem by displaying a # before the
change indicator.  It also asks for confirmation before performing
the read or write.
.LP
\fB/home/foo\fP shows the name of the current directory.
.LP
\fB15.23\fP shows the time.
.HH 2 "The Message Line"
.LP
The Message Line
is reserved for printing messages and for accepting input from the user,
such as filenames or search strings.
When
\s-2JOVE\s0
prompts for input,
the cursor will temporarily appear on the bottom line, waiting for you
to type a string.
When you have finished typing your input, you can
type a Return to send it to \s-2JOVE\s0.
If you change your mind about running the command that is waiting for input,
you can type ^G to abort,
and you can then continue with your editing.
.LP
The message line and the list of filenames from the shell command that
invoked \s-2JOVE\s0 are kept in a special buffer called
\fIMinibuf\fP that can be edited like any other buffer.
It is instructive to view the Minibuf in a window and to observe how it changes
as parameters to commands are typed, and as the ^N and ^P functions are
invoked.
.HH 2 "Multiple Windows"
.LP
The window area, described above, can in fact be split into several
\fIwindows\fP, each showing a different \fIbuffer\fP, or possibly different
parts of the same buffer.  Each window has its own mode line beneath it.  The
methods of creating and destroying windows will be described presently.
.HH 1 "Input Conventions"
.LP
.HH 2 "Keyboard Usage"
.LP
In this manual,
\*QControl\*U characters
(that is, characters that are typed with the Control key
and some other key at the same time)
are represented by a circumflex (^) followed by another character.
Thus,
^A is the character you get when you type A with the Control key
(sometimes labeled CTRL) held down.
Control characters in the \s-2JOVE\s0
buffer are displayed with a caret; thus, ^A for Control-A.
DEL is displayed as ^?, ESC as ^[.
.LP
If the keyboard has extra keys, such as Function keys, Arrow keys and the
like, then \s-2JOVE\s0 can be customized to use them.
.HH 2 "The Character Set"
.LP
\s-2JOVE\s0 normally accepts the ASCII character set, with its 95 printing
characters, including Space, (which appear on the screen as themselves) and
its 33 Control characters (which, except for TAB, appear on the screen as,
e.g. \*Q\^^C\*U).  There are, however, two characters that may not appear.
One is the NL character (because it is always converted into a
\fIline-separator\fP, which is not quite a character) and the other is the
NUL character (^@) which is used internally
within \s-2JOVE\s0 to delimit lines (lines also have a maximum length,
which is 1023 in most systems).
.LP
However, \s-2JOVE\s0 is \*Q8-bit clean\*U, so if your keyboard is able to
produce all 256 8-bit characters, the extra ones will appear in octal (e.g.
\*Q\^\e\^277\*U).  Moreover, if your
.UX
system supports the \fILocale\fP facility (as most modern ones do), you may
set the variable \fIlc-ctype\fP to \*QC\*U (the default, which corresponds
to pure ASCII), or to \*Qiso_8859_1\*U (which corresponds to the Latin-1
alphabet with a total of 192 printing characters, all of which \s-2JOVE\s0
should be able to display), or to any other \fILocale\fP available on your
system.  The initial value of \fIlc-ctype\fP is taken from your LC_CTYPE
environment variable, and otherwise defaults to \*QC\*U.  With each
\fILocale\fP \s-2JOVE\s0 will know which of the extra characters are
upper-case letters, lower-case letters, etc.
.HH 2 "Name Completion"
.LP
\s-2JOVE\s0 knows the names of all sorts of objects, such as \s-2JOVE\s0
Commands, \s-2JOVE\s0 Variables, Macros, Keymaps, Buffers and even (with
some help from the
.UX
directories) Files.  Since names must be entered often, \s-2JOVE\s0
has features to make this easier.
.LP
For many names, \s-2JOVE\s0 is willing to supply a default if
you enter an empty answer.  For example, when you are telling
.IQ select-buffer
which buffer to select, it will default to the previous buffer.
When the prompt mentions a default, this is the value that will
be used in place of an empty answer.
.LP
If the default isn't the name you want, name completion can help
you enter a name.  When you are prompted for a name, you need type
only enough letters to make it unambiguous.  At any point in the course of
typing the name, you can type question mark (?) to see a list of all the
relevant names which begin with the characters you have already typed; you
can type Tab to have \s-2JOVE\s0 supply as many characters as it can; or you
can type Return to terminate your input, or you can type Space to do both
(supply the characters and terminate).  For example, you are typing a
Command and you have so far typed the letters \*Q\fIau\fP\*U and you then
type a question mark, you will see the list
.DS I
   auto-execute-command
   auto-execute-macro
   auto-fill-mode
   auto-indent-mode
.DE
If you type a Return at this point, \s-2JOVE\s0 will complain by ringing
the bell, because the letters you have typed do not unambiguously specify a
single command.  But if you type Tab or Space, \s-2JOVE\s0 will supply the
characters \*Q\fIto-\fP\*U because all commands that begin \*Q\fIau\fP\*U also
begin \*Q\fIauto-\fP\*U.  You could then type the letter \*Qf\*U followed
by either Space or Return, and \s-2JOVE\s0 would complete and obey the entire
command.
.LP
There are in fact two cases that can arise.
.IP 1.
.B
The name you are typing is supposed to exist already
.R
(Commands, Variables and Keymaps always, Macros and Buffers except when you
are trying to create a new one).
.br
If you type Return and what you have typed is not an unambiguous prefix of
any name of the right kind, you will hear the bell; otherwise, it will
complete what you have typed and then use it.  Tab will complete what it can
(you can then type Return if it looks right).  Space will complete what it
can and use it if it then matches.
.IP 2.
.B
The name you are typing may be a new one
.R
(Files always, Macros (including the Keyboard Macro) and Buffers if you are
allowed to create or rename one at that point).
.br
If you type Return, and it does not match any name, then it will take
exactly what you have typed as a new name.  Tab and Space try to complete as
before.
.LP
If you type ^R, it will insert a name that might be useful.  Even if
this name is not the one you wish to enter, it is often convenient
to edit this name into the desired one.  The inserted name will be
the default (if there is one), or the current value (if there is
one).  When \s-2JOVE\s0 is asking for a command or variable name, ^R
will insert the last one named.
.LP
Buffers, keymaps, and macros are also numbered (if you type \*Q?\*U when
first prompted, you will see the numbers as well as the possible names), and
the number may be used in place of the name.
.HH 3 "Filename Completion"
.LP
Whenever \s-2JOVE\s0 is prompting you for a filename, say in the
\fIfind-file\fP command, things happen as just described and Return always
accepts the name just as it is (because you might be wanting to create a new
file with a name similar to that of an existing one).  The variable
\fIbad-filename-extensions\fP contains a list of words separated by spaces
which are to be considered bad filename extensions; any filename with one of
these extensions will not be counted in filename completion.  The default
includes \*Q.o\*U so if you have jove.c and jove.o in the same directory,
the filename completion will not complain of an ambiguity because it will
ignore jove.o.
.LP
When \s-2JOVE\s0 is prompting for a \fIfilename\fP,
it has the following extra functions:
.IP "^N"
Insert the next filename from the argument list in the Minibuf.
.IP "^P"
Insert the previous filename from the argument list in the Minibuf.
.HH 1 "Commands and Variables"
.HH 2 "Commands"
.LP
\s-2JOVE\s0 uses \fIcommands\fP
which have long names such as
\fInext-line\fP.
Then \fIkeys\fP such as ^N are connected to
commands through the \fIcommand dispatch table\fP.
When we say that ^N moves the cursor down a line,
we are glossing over a distinction which is unimportant for ordinary use,
but essential for simple customization:
it is the command \fInext-line\fP which knows how to move down a line,
and ^N moves down a line because it is connected to that command.
The name for this connection is a \fIbinding\fP; we say that the key
^N \fIis bound to\fP the command \fInext-line\fP (or vice versa).  \s-2JOVE\s0 has many
bindings already \fIbuilt-in\fP, but you (or your system administrator) may
also add your own, e.g. to make full use of any Function Keys provided on your
particular keyboard.
.LP
Thus there may be three ways to refer to a command \(em by its full name, or
by its standard (built-in) binding, or by your customized binding.
Throughout this manual, we shall always use the standard bindings,
followed by the full name (in italics).  The standard bindings are designed
to work on any ASCII keyboard, and can always be used so long as you (or
your system administrator) have not actually changed them.  But they
are hard to remember, so you may well prefer to use your own, particularly
if you always use the same terminal.  See the section on Customization for
more details.
.LP
Some terminals and modems cannot accept characters flat out
at a reasonable baud rate, and therefore require the use of a flow control
protocol using the characters ^S and ^Q (see the variable
\fIallow-^S-and-^Q\fP).  These characters cannot, therefore, be typed by the
user.  It has therefore been arranged that whenever a standard binding
requires ^S (^Q) to be typed, a spare standard binding for that facility is
also provided in which ^\^\e (^^) can be typed in its place.
.LP
Not all commands are bound to keys.  To invoke a command that isn't bound
to a key, you can type the sequence ESC\ X, which is bound to the command
\fIexecute-named-command\fP.  You will then be able to type the name of
whatever command you want to execute on the message line.
.HH 2 "Prefix Characters"
.LP
Because there are more command names than keys,
\s-2JOVE\s0 allows a sequence of keystrokes to be bound to a command.
Usually, the first character of the sequence will be one of the two
\fIprefix characters\fP ^X or ESC.
When you type such a prefix character \s-2JOVE\s0 will wait
for the next character before deciding what to do.
If you wait more than a second or so,
\s-2JOVE\s0 will print the prefix character on the
message line as a reminder and leave the cursor down there while you type
the rest of the sequence.
Many \s-2JOVE\s0 commands are bound to a 2-stroke sequence starting with
^X or ESC.
How the next character is interpreted depends on which
of them you typed.
For example,
if you type ESC followed by B you will run \fIbackward-word\fP,
but if you type ^X followed by B you will run \fIselect-buffer\fP.
.HH 2 "Variables"
.LP
Sometimes the description of a command will say
\*Qto change this, set the variable \fImumble-foo\fP\*U.
A variable is a name used to remember a value.
\s-2JOVE\s0 contains variables which are there so that you can change
them if you want to customize.
The variable's value may be examined by some command,
and changing that value makes the command behave differently.
However, the facilities provided are pretty limited: you cannot invent new
variables, or use them for other than their built-in purposes, and their
values apply globally to all buffers irrespective of mode settings.
.TS
L2w(10)fR L2w(20)fI Lw(\n(Ww)fR .
	set	Sets the value of a variable.
	print	Displays the current value of a variable.
.TE
.LP
To set or change the value of a variable, type ESC\ X \fIset\fP <variable-name>
<value><return>.  Values may be \fIon\fP of \fIoff\fP (for Boolean variables)
or numbers (numeric variables) or strings (string variables).  To inspect the
current value of a variable, type ESC\ X print <variable-name><return>.
.HH 2 "Giving Numeric Arguments to \s-2JOVE\s0 Commands"
.LP
Many \s-2JOVE\s0 commands can be given a \fInumeric argument\fP.
Many commands interpret the argument as a repetition count (possibly
negative).  For example,
giving an argument of ten to the ^F command (\fIforward-character\fP) moves forward
ten characters.
With these commands,
no argument is equivalent to an argument of 1.
.LP
Some commands use the value of the argument, or even just its presence or
absence, in highly idiosyncratic ways.
For example,
the commands which change the minor modes (such as \fIauto-fill-mode\fP)
toggle the mode if there is no argument, but turn the more off with a zero
argument, and on with any other argument.
.LP
The fundamental way of specifying an argument is to use ESC followed by the
digits of the argument, for example, ESC\ 123 ESC\ G to go to line 123.
Negative arguments are allowed, although not all commands know what
to do with them.
Unless otherwise stated, ESC\ Minus\ ... is equivalent to ESC\ Minus\ 1\ ...\ .
Note that when giving arguments to \fIsourced\fP commands
(described later under Customization) different rules apply.
.LP
Typing ^U means \*Qsupply an argument of 4\*U.  Two such ^U's supply
sixteen.  Thus, ^U ^U ^F moves forward sixteen characters.
This is a good way to move forward quickly,
since it moves about 1/4 of a line on most terminals.
Other useful combinations are:
^U ^U ^N (move down a good fraction of the screen),
and ^U ^U ^O (make \*Qa lot\*U of blank lines).
.LP
There are other,
terminal-dependent, ways of specifying arguments.
They have the same effect but may be easier to type.
If your terminal
has a numeric keypad which sends something recognizably different from
the ordinary digits,
it is possible to customize \s-2JOVE\s0 to allow use of
the numeric keypad for specifying arguments.
.HH 2 "Help"
.LP
To get a list of keys and their associated commands,
you type ESC\ X \fIdescribe-bindings\fP (warning: the list runs to many
screenfuls; type Space to see the next one, or ^G when you have seen enough).
If you want to describe a single key,
^X\ ? (\fIdescribe-key\fP) will work.  A description of an
individual command is available by using ESC\ ? (\fIdescribe-command\fP),
and descriptions of variables by using ESC\ X \fIdescribe-variable\fP.
If you can't remember the name of the thing you want to know about,
ESC\ X \fIapropos\fP will tell you if a command or variable has a given
string in its name.  For example, ESC\ X \fIapropos describe\fP will
list the names of the four describe commands just mentioned.
.HH 1 "Basic Editing Commands"
.LP
.HH 2 "Inserting Text"
.LP
To insert printing characters into the text,
just type them.
All such printing characters you type are inserted into the text at
the cursor (that is, at \fIpoint\fP),
and the cursor moves forward.
Any characters after the cursor move forward too.
If the text in the buffer is FOOBAR,
with the cursor before the B,
then if you type XX
you get FOOXXBAR,
with the cursor still before the B.
.LP
To correct text you have just inserted,
you can use DEL.
DEL deletes the character \fIbefore\fP the cursor (not the one that the
cursor is on top of or under; that is the character \fIafter\fP the
cursor).
The cursor and all characters after it move backwards.
Therefore,
if you typing a printing character and then type DEL,
they cancel out.
.LP
To end a line and start typing a new one, type Return.  Return operates by
inserting a \fIline-separator\fP, so if you type Return in the middle of a
line, you break the line in two.  Because a line-separator behaves like a
single character, you can type DEL at the beginning of a line to delete the
line-separator and join it with the preceding line.  Note that the line
separator is \fBnot\fP a character (it is not the ASCII NL character, for
example) so that you cannot include it in search or replace strings.
.LP
As a special case, if you type Return at the end of a line and there are
two or more empty lines just below it, \s-2JOVE\s0 does not insert a
line-separator but instead merely moves to the next (empty) line.  This
behavior is convenient when you want to add several lines of text in the
middle of a buffer.  You can use the ^O (\fInewline-and-backup\fP)
command to \*Qopen\*U several empty lines at once; then you can insert the new
text, filling up these empty lines.  The advantage is that \s-2JOVE\s0 does
not have to redraw the bottom part of the screen for each Return you type,
as it would ordinarily.  That \*Qredisplay\*U can be both slow and distracting.
.LP
If you add too many characters to one line,
without breaking it with Return,
the line will grow too long to display on one screen line.
When this happens,
\s-2JOVE\s0 puts an \*Q!\*U at the extreme right margin,
and doesn't bother to display the rest of the line unless the
cursor happens to be in it.
The \*Q!\*U is not part of your text;
conversely,
even though you can't see the rest of your line,
it is still there,
and if you break the line,
the \*Q!\*U will go away.
.LP
Direct insertion works for printing characters and space,
but other
characters act as editing commands and do not insert themselves.
If you need to insert a control character,
ESC,
or DEL,
you must first \fIquote\fP it by typing the ^Q command (\fIquoted-insert\fP)
first, for example ^Q\ ^C to insert a genuine ^C.
.HH 2 "Moving the Cursor"
.LP
To do more than insert characters,
you have to know how to move the cursor.
Here are the commands for doing that.
.TS
L2w(10)fR L2w(20)fI Lw(\n(Ww)fR .
^A	beginning-of-line	Move to the beginning of the line.
^E	end-of-line	Move to the end of the line.
^F or \(->	forward-character	Move forward over one character.
^B or \(<-	backward-character	Move backward over one character.
^N or \(da	next-line	T{
Move down one line, vertically.
If you start in the middle of one line,
you end in the middle of the next.
T}
^P or \(ua	previous-line	Move up one line, vertically.
ESC\ <	beginning-of-file	Move to the beginning of the entire buffer.
ESC\ >	end-of-file	Move to the end of the entire buffer.
ESC\ ,	beginning-of-window	Move to the beginning of the visible window.
ESC\ \fB.\fP	end-of-window	Move to the end of the visible window.
^Z	scroll-up	T{
Move the lines in the window upwards.  If this brings the cursor outside of
the window, it is automatically relocated.
T}
ESC\ Z	scroll-down	Move the lines in the window downwards.
.TE
Observe the use of the arrow keys (\(->, \(<-, \(da and \(ua) as alternatives
for ^F, ^B, ^N and ^P.  These should be available on just about any terminal.
You (or your system administrator) may find it convenient to bind other
Function Keys available on your keyboard to some of these commands,
especially if those keys already have appropriate engravings on them.
See the section on Customizing \s-2JOVE\s0.
.HH 2 "Deleting Text"
.TS
L2w(10)fR L2w(20)fI Lw(\n(Ww)fR .
DEL	delete-previous-character	Delete the character before the cursor.
^D	delete-next-character	Delete the character after the cursor.
ESC \e	delete-white-space	Delete spaces and tabs around point.
^X\ ^O	delete-blank-lines	Delete blank lines around the current line.
.TE
.LP
You already know about the DEL command which deletes the character
\fIbefore\fP the cursor.  Another command,
^D,
deletes the character
\fIafter\fP the cursor, the one the cursor is \*Qon top of\*U or \*Qunderneath\*U,
causing the rest of the text on the line to shift left.
Line-separators act like normal characters when deleted,
so if ^D is typed at the end of a line,
that line and the next line are joined together.
.LP
The other delete commands are those which delete only formatting
characters:
spaces,
tabs,
and line-separators.
ESC\ \e (\fIdelete-white-space\fP)
deletes all the spaces and tab characters before and after point.
^X\ ^O (\fIdelete-blank-lines\fP) deletes all blank lines after the current line,
and if the current line is blank deletes all the blank
lines preceding the current line as well
(leaving one blank line, the current line).
.HH 2 "Files \(em Saving Your Work"
.LP
The commands above are sufficient for creating text in the \s-2JOVE\s0 buffer.
The more advanced \s-2JOVE\s0 commands just make things easier.
But to keep any text permanently you must put it into a \fIfile\fP.
Files are the objects which
.UX
uses for storing data for a length of time.
To tell \s-2JOVE\s0 to read text into a file,
choose a filename,
such as \fIfoo.bar\fP,
and type ^X\ ^F\ \fIfoo.bar\fP<return> (\fIfind-file\fP).
This reads the file \fIfoo.bar\fP so that its contents appear in a new
buffer on the screen for editing.
Alternatively, type ^X\ ^R \fIfoo.bar\fP<return> (\fIread-file\fP) to have the file appear in
an existing buffer.
You can make changes,
and then save the file by typing ^X\ ^S (\fIsave-file\fP).
This makes the changes permanent and actually changes the file \fIfoo.bar\fP.
Until then,
the changes are only inside \s-2JOVE\s0,
and the file \fIfoo.bar\fP is not really changed.
If the file \fIfoo.bar\fP does not exist,
and you want to create it,
read it as if it did exist.
When you save your text with ^X\ ^S, the file will be created then.
.HH 2 "Exiting and Pausing \(em Leaving \s-2JOVE\s0"
.LP
The command ^X\ ^C (\fIexit-jove\fP) will terminate the \s-2JOVE\s0
session and return to the shell.  If there are modified but
unsaved buffers, \s-2JOVE\s0 will ask you for confirmation, and you
can abort the command, look at what buffers are
modified but unsaved using ^X\ ^B (\fIlist-buffers\fP), save the
valuable ones, and then exit.  If what you want to do, on the other hand,
is to \fIpreserve\fP the editing session but return to the shell temporarily
you can (under most modern versions of
.UX )
issue the command ESC\ S (\fIpause-jove\fP), do your
.UX
work within your shell, and then return to \s-2JOVE\s0 using the
\fIfg\fP command to resume editing at the point where you paused.
Alternatively, for this sort of situation, you might consider using an
\fIinteractive shell\fP (that is, a shell in a \s-2JOVE\s0 window) which
lets you use the editor to issue your
.UX
commands and manipulate their output, while never leaving the editor
(the interactive shell feature is described later).
.HH 1 "Kill and Yank (or Cut and Paste)"
.LP
Any editor needs a facility for dealing with large blocks of text \(em
deleting them or moving them to other places.  The usual terminology speaks
of \*QCut\*U (to remove a block of text), \*QPaste\*U (to replace it
somewhere else) and \*QCopy\*U (to copy it for subsequent pasting without
removal from its original place).  For historical reasons, editors based on
\s-2EMACS\s0 use the terms Kill, Yank and Copy with essentially the same
meanings, and we shall continue to do so in this manual.  However, it may be
sensible, if your keyboard has keys marked Cut, Paste and Copy, to bind
appropriate Kill, Yank and Copy commands to them as part of your local
customization.
.HH 2 "The Mark and the Region"
.LP
In general, a command that processes an arbitrary part of the buffer must
know where to start and where to stop.  In \s-2JOVE\s0, such commands
usually operate on the text between \fIpoint\fP and \fIthe mark\fP.  On most
terminals, the position of the mark is indicated by underlining.  This body
of text is called \fIthe region\fP.  To specify a region, you set point at
one end of it and mark at the other.  It doesn't matter which one comes
earlier in the text.
.TS
L2w(10)fR L2w(20)fI Lw(\n(Ww)fR .
^@	set-mark	Set the mark where point is.
^X\ ^X	exchange-point-and-mark	Interchange point and mark.
	pop-mark	Move to the previous mark in the ring.
.TE
.LP
The way to set the mark is with the ^@ command or (on some terminals) the
^Space command.  They set the mark where point is.  Then you can move point
away, leaving the mark behind.  When the mark is set, \*Q[Point pushed]\*U
is printed on the message line.
.LP
For example,
if you wish to convert part of the buffer to all upper-case,
you can use the \fIcase-region-upper\fP command,
which operates on the text in the region.
You can first go to the beginning of the text to be capitalized,
put the mark there, move to the other end, and then type
ESC\ X \fIcase-region-upper\fP.
Or,
you can set the mark at the end of the text,
move to the beginning,
and then type the same thing.
.LP
On terminals with the requisite capabilities, the marked character is
underlined.  Otherwise, you have to remember where it is (the usual method is
to set the mark and then use it soon).  Alternatively, you can see where the
mark is with the command ^X\ ^X which puts the mark where point was and
point where the mark was.  The extent of the region is unchanged, but the
cursor and point are now at the previous location of the mark.
.HH 2 "The Ring of Marks"
.LP
Aside from delimiting the region,
the mark is also useful for remembering a spot that you may want to go back to.
To make this feature more useful,
\s-2JOVE\s0 remembers 16 previous locations of the mark.
Most commands that set the mark push the old mark onto this stack.
To return to a marked location, use ^U\ ^@ (equivalent to \fIpop-mark\fP).
This moves point to where the mark was,
and restores the mark from the stack of former marks.
So repeated use of this command moves point to all of the old
marks on the stack,
one by one.
Since the stack is actually a ring,
enough uses of ^U\ ^@ bring point back to where it was originally.
.LP
Some commands whose primary purpose is to move point a great distance
take advantage of the stack of marks to give you a way to undo the
command.
The best example is ESC\ < (\fIbeginning-of-file\fP),
which moves to the beginning of the buffer.
If there are more than 22 lines between the beginning of
the buffer and point,
ESC\ < sets the mark first,
so that you can use ^U ^@ or ^X\ ^X to go back to where you were.
You can change the number of lines from 22 since it is kept in the variable \fImark-threshold\fP.
By setting it to 0,
you can make these commands always set the mark and
by setting it to a very large number you can make them never set it.
If a command decides to set the mark,
it prints the message [Point pushed].
.HH 2 "Killing and Moving Text"
.LP
The way of moving text with \s-2JOVE\s0 is to \fIkill\fP (cut) it,
and \fIyank\fP (paste) it back again later in one or more places.
This is very safe
because the last several pieces of killed text are all remembered,
and it is versatile
because the many commands for killing syntactic units
can also be used for moving those units.
.HH 3 "Deletion and Killing"
.LP
Most commands which erase text from the buffer save it so that you can
get it back if you change your mind, or you can
copy it to other parts of the buffer (even to a different buffer).
These commands are known as \fIkill\fP commands.
The rest of the commands that erase text do not save it;
they are known as \fIdelete\fP commands.
The delete commands include ^D and DEL,
which delete only one character at a time,
and those commands that delete only spaces or line-separators.
Commands that can destroy significant amounts of nontrivial data generally
kill.  A command's
name and description will use the words \fIkill\fP or \fIdelete\fP to
say which it does.
.TS
L2w(10)fR L2w(20)fI Lw(\n(Ww)fR .
^D	delete-next-character	Delete next character.
DEL	delete-previous-character	Delete previous character.
ESC\ \e	delete-white-space	Delete spaces and tabs around point.
^X\ ^O	delete-blank-lines	Delete blank lines around the current line.
^K	kill-to-end-of-line	Kill rest of line or one or more lines.
^W	kill-region	Kill the region (from point to mark).
ESC\ D	kill-next-word	Kill word.
ESC\ DEL	kill-previous-word	Kill word backwards.
ESC\ K	kill-to-end-of-sentence	Kill to end of sentence.
^X\ DEL	kill-to-beginning-of-sentence	Kill to beginning of sentence.
ESC\ ^K	kill-s-expression	Kill from point to the end of an s-expression.
.TE
.HH 3 "Deletion"
.LP
The various delete commands have already been described.
Actually,
^D and DEL aren't always \fIdelete\fP commands;
if you give an argument,
they \fIkill\fP instead.
This prevents you from losing a great deal of text by typing a large
argument to a ^D or DEL.
.HH 3 "Killing (and Copying) the region, and Yanking it back again"
.LP
The commonest kill command is ^W (\fIkill-region\fP),
which kills everything between point and the mark*.
.FS
*Often users switch this binding from ^W to ^X\ ^K because it is too
easy to hit ^W accidentally.
.FE
With this command,
you can kill and save contiguous characters,
if you first set the mark at one end of them and then go to the other end.
.TS
L2w(10)fR L2w(20)fI Lw(\n(Ww)fR .
^W	kill-region	Kill everything between point and mark.
ESC\ W	copy-region	Save the region without killing.
.TE
.LP
Yanking (un-killing) is getting back text which was killed.
The usual way to
move or copy text is to kill or copy it and then yank it one or more times.
.TS
L2w(10)fR L2w(20)fI Lw(\n(Ww)fR .
^Y	yank	Yank (re-insert) the last killed text.
ESC\ Y	yank-pop	Replace re-inserted killed text with the previously killed text.
.TE
.LP
Killed text is pushed onto a \fIring buffer\fP called the \fIkill
ring\fP that remembers the last sixteen blocks of text that were killed
(why it is called a ring buffer will be explained below).
The command ^Y (\fIyank\fP) reinserts the text of the most recent kill.
The yanked text becomes the new region.  Thus,
a single ^Y undoes the ^W and vice versa.
.LP
If you wish to copy a block of text,
you might want to use ESC\ W (\fIcopy-region\fP),
which copies the region into the kill ring without removing it from the buffer.
.LP
There is only one kill ring shared among all the buffers.  After reading a
new file or selecting a new buffer, whatever was last killed in the previous
file or buffer is still on top of the kill ring.  This is important for
moving text between buffers.
.HH 3 "Other Kill commands"
.LP
Other syntactic units can be killed, too;
words,
with ESC\ DEL (\fIkill-previous-word\fP) and ESC\ D (\fIkill-next-word\fP);
and sentences,
with ESC\ K (\fIkill-to-end-of-sentence\fP) and ^X\ DEL
(\fIkill-to-beginning-of-sentence\fP).
.HH 3 "Killing by Lines"
.LP
Another kill command is the ^K command (\fIkill-to-end-of-line\fP).  If
issued at the beginning of a line, it kills all the text on the line,
leaving it blank.  If given in the middle of a line, it kills all the text
up to the end of the line.  If given on a line that is empty or contains
only white space (blanks and tabs) the line disappears.  If ^K is done at
the end of a line, it joins that line and the next line.  As a consequence,
if you go to the front of a non-blank line and type two ^K's, the line
disappears completely (but be careful, because one ^K is sufficient to
remove an empty line).
.LP
In general,
^K kills from point up to the end of the line,
unless it is at the end of a line,
in which case
it kills the line-separator following the line,
thus merging the next line into the current one.
Invisible spaces and tabs at the end of the line are ignored when
deciding which case applies,
so if point appears to be at the end of the line,
you can be sure the line-separator will be killed.
.LP
^K with an argument kills that many lines, including their line
separators (whether the lines are empty or not).  Without an argument, ^K
behaves as described in the previous paragraph.
^U ^K kills four lines (but note that typing ^K four times
would kill only 2 lines)
.LP
^K with an argument of zero kills all the text before
point on the current line.
.HH 3 "Appending Kills"
.LP
Normally,
each kill command pushes a new block onto the kill ring.
However,
two or more kill commands immediately in a row (without any other
intervening commands) combine their text into a
single entry on the ring,
so that a single ^Y (\fIyank\fP) command gets it all back as it was before
it was killed.  This means that you don't have to kill all the text in one
command; you can keep killing line after line,
or word after word,
until you have killed it all,
and you can still get it all back at once.
.LP
Commands that kill forward from point
add onto the end of the previously
killed text.
Commands that kill backward from point
add onto the beginning.
This way,
any sequence of mixed forward and backward kill
commands puts all the killed text into one entry without needing rearrangement.
.LP
Suppose, for example you have a line containing FOO\ BAR\ BAZ with the
cursor at the start of BAR.  Type ESC\ D (\fIkill-next-word\fP), then
ESC\ DEL (\fIkill-previous-word\fP), then ESC\ F (\fIforward-word\fP) to put
the cursor after BAZ, and Space to insert a space.  Then type ^Y (\fIyank\fP)
and your line will contain BAZ\ FOO\ BAR.
.HH 2 "The Kill Ring"
.LP
To recover killed text that is no longer the most recent kill,
you need the ESC\ Y (\fIyank-pop\fP) command.
The ESC\ Y command can be used
only immediately after a ^Y (\fIyank\fP) command or another ESC\ Y.
It takes the yanked
text inserted by the ^Y and replaces it with the text from an earlier
kill.
So,
to recover the text of the next-to-the-last kill,
you first use ^Y to recover the last kill,
and then discard it by use of ESC\ Y to move back to the previous one.
.LP
You can think of all the last few kills as living on a ring.
After a ^Y command,
the text at the front of the ring is still present in the buffer.
ESC\ Y \*Qrotates\*U the ring bringing the previous string of text to the front
and this text replaces the other text in the buffer as well.
Enough ESC\ Y commands can rotate any part of the ring to the front,
so you can get at any killed text so long as it is recent enough
to be still in the ring.
Eventually the ring rotates all the way
round and the most recently killed text comes to the front
(and into the buffer) again.
ESC\ Y with a negative argument rotates the ring backwards.
.LP
When the text you are looking for is brought into the buffer,
you can stop doing ESC\ Y's and the text will stay there.
It is really just a copy of what's at the front of the ring,
so editing it does not change what's in the ring.
And the ring,
once rotated,
stays rotated,
so that doing another ^Y gets another copy of what you rotated to the
front with ESC\ Y.
.LP
If you change your
mind about yanking,
^W (\fIkill-region\fP) gets rid of the yanked text, even
after any number of ESC\ Y's.
.HH 1 "Searching and Replacing"
.HH 2 "Searching"
.LP
The search commands are useful for finding and moving to arbitrary
positions in the buffer in one swift motion.
For example,
if you just ran the spell program on a document
and you want to correct some word,
you can use the search commands to move directly to that word.  There are
two flavors of search: \fIstring search\fP and \fIincremental search\fP.
The former is the default flavor \(em if you want to use incremental search
you must rearrange the key bindings (see below).
.HH 3 "Conventional Search"
.TS
L2w(10)fR L2w(20)fI Lw(\n(Ww)fR .
^S or ^\^\e	search-forward	Search forward.
^R	search-reverse	Search backward.
.TE
.LP
To search for the string \*QFOO\*U you type ^S\ FOO<return>.
If \s-2JOVE\s0 finds
FOO it moves point to the end of it; otherwise \s-2JOVE\s0 prints an error
message and leaves point unchanged.
^S searches forward from point
so only occurrences of FOO after point are found.
To search in the other direction use ^R.
It is exactly the same as ^S except that it searches in the opposite direction,
and if it finds the string
it leaves point at the beginning of it,
not at the end as in ^S.
.LP
While \s-2JOVE\s0 is searching it displays the search string on the message line.
This is so you know what \s-2JOVE\s0 is doing.
When the system is heavily loaded and
editing in exceptionally large buffers,
searches can take several (sometimes many) seconds.
.LP
\s-2JOVE\s0 remembers the last search string you used,
so if you want to search for the same string again you can type
^S\ <return>.  If you mistyped the last search string,
you can type ^S followed immediately by ^R (which is \fInot\fP the
\fIsearch-reverse\fP command in this context) which
inserts the default search string,
and then you can fix it up.
.LP
Note that the precise interpretation of the search string is dependent on
the variable \fImatch-regular-expressions\fP and is subject to the rules for
\fIregular-expressions\fP to be described shortly.
.HH 3 "Incremental Search"
.LP
This search command is unusual in that is is \fIincremental\fP;
it begins to search before you have typed the complete search string.
As you type in the search string,
\s-2JOVE\s0 shows you where it would be found.
When you have typed enough characters to identify the place you want,
you can stop.
Depending on what you will do next,
you may or may not need to terminate the search explicitly with a Return.
.LP
To use the incremental searches, you first have to bind them to suitable
keys, for example to ^S and ^R if you want all your searching to become
incremental.  To do this, type
.IP
.I
ESC\ X bind-to-key i-search-forward ^S
.br
ESC\ X bind-to-key i-search-reverse ^R
.R
.LP
The command to search is now ^S (\fIi-search-forward\fP).
^S reads in characters and positions the cursor at the first
occurrence of the characters that you have typed so far.
If you type ^S and then F,
the cursor moves in the text just after the next \*QF\*U.
Type an \*QO\*U,
and see the cursor move to after the next \*QFO\*U.
After another \*QO\*U,
the cursor is after the next \*QFOO\*U.
At the same time,
\*QFOO\*U has echoed on the message line.
.LP
If you type a mistaken character,
you can rub it out.
After the FOO,
typing a DEL makes the \*QO\*U disappear from the message line,
leaving only \*QFO\*U.
The cursor moves back in the buffer to the \*QFO\*U.
Rubbing out the \*QO\*U and \*QF\*U moves the cursor back to where you
started the search.
.LP
When you are satisfied with the place you have reached,
you can type a Return,
which stops searching,
leaving the cursor where the search brought it.
Also,
any command not specially meaningful in searches stops
the searching and is then executed.
Thus,
typing ^A would exit the search and then move to the beginning of the line.
Return is necessary only if the next character you want to type is a printing
character,
DEL,
Return,
or another search command,
since those are the characters that have special meanings inside the search.
.LP
Sometimes you search for \*QFOO\*U and find it,
but not the one you hoped to find.
Perhaps there is a second FOO
after the one you just found.
Then type another \*Q^S\*U and the cursor will find the next FOO.
This can be done any number of times.
If you overshoot,
you can return to previous finds by rubbing out the \*Q^S\*Us.
Note that, in this context, \*Q^S\*U (alternatively \*Q^\^\e\*U) is a
built-in use of the ^S character and not another invocation of
\fIi-search-forward\fP (which is why I have shown it in \*Qquotes\*U).
.LP
After you exit a search,
you can search for the same string again by typing just ^S ^S:
one ^S command to start the search and then
another \*Q^S\*U to mean \*Qsearch again for the same string\*U.
.LP
If your string is not found at all,
the message line says \*QFailing I-search\*U.
The cursor is after the place where \s-2JOVE\s0 found as much of
your string as it could.
Thus,
if you search for FOOT and there is no FOOT,
you might see the cursor after the FOO in FOOL.
At this point there are several things you can do.
If your string was mistyped,
you can rub some of it out and correct it.
If you like the place you have found,
you can type Return or some other \s-2JOVE\s0 command
to \*Qaccept what the search offered\*U.
Or you can type ^G,
which undoes the search altogether and positions you back where you started
the search.
.LP
You can also type ^R (\fIi-search-reverse\fP) at any time to start searching
backwards.  If a search fails because the place you started was too late in
the file, you should do this.  Repeated \*Q^R\*Us keep looking backward for
more occurrences of the last search string.  A \*Q^S\*U starts going forward
again.  \*Q^R\*Us can be rubbed out just like anything else.
.LP
Unlike conventional searching, incremental searching does not use the rules
for regular-expressions.
.HH 2 "Replacing"
.LP
In addition to
the simple Replace operation which is like that found in most editors,
there is a Query Replace operation which asks,
for each occurrence of the pattern,
whether to replace it or not.
.TS
L2w(10)fR L2w(20)fI Lw(\n(Ww)fR .
ESC\ R	replace-string	T{
Replace every occurrence of the string from point to
the end of the buffer.
T}
	replace-in-region	T{
Replace every occurrence of the string within the region.
T}
ESC\ Q	query-replace-string	T{
Replace occurrences of the string from point to the end of the buffer, but
asking for confirmation before each replacement.
T}
.TE
.HH 3 "Global replacement"
.LP
To replace every occurrence of FOO after point with BAR,
you can do, ESC\ R FOO<return>BAR<return> (\fIreplace-string\fP).
Replacement takes place only between point and the end of the buffer,
so if you want to cover the whole buffer you must go to the beginning first.
.LP
Another alternative is to use \fIreplace-in-region\fP which is just like
\fIreplace-string\fP except it searches only within the region.
.HH 3 "Query Replace"
.LP
If you want to change only some of the occurrences of FOO,
not all,
then the global \fIreplace-string\fP is inappropriate;
instead,
use, e.g., ESC\ Q FOO<return>BAR<return> (\fIquery-replace-string\fP).
This moves the cursor to each occurrence of FOO and waits for you to say
whether to replace it with BAR.
The things you can type when you are shown an occurrence of FOO are:
.IP "Space or Y or y" "\w'DEL or BS or N or n11'u"
to replace the FOO with BAR.
.IP "Period"
to replace this FOO and then stop.
.IP "DEL or BS or N or n"
to skip to the next FOO without replacing this one.
.IP "^R\ or\ R\ or\ r"
to enter a recursive editing level, in case the FOO needs to be edited
rather than just replaced with a BAR.  When you are done, exit the recursive
editing level with ^X\ ^C (\fIexit-jove\fP) and the next FOO will be
displayed.
.IP "^W"
to delete the FOO, and then start editing the buffer.
When you are finished editing whatever is to replace the FOO,
exit the recursive editing level with ^X\ ^C (\fIexit-jove\fP)
and the \fIquery-replace\fP will continue at the next FOO.
.IP "^U or U or u"
move to the last replacement and undo all changes made on that line.
.IP "! or P or p"
to replace all remaining FOO's without asking, as in \fIreplace-string\fP.
.IP "Return or Q or q"
to stop without doing any more replacements.
.IP "^L"
redraw the screen.
.HH 2 "Searching with Regular Expressions"
.LP
When we use the searching and replacement facilities described above,
\s-2JOVE\s0 can search for patterns using \fIregular-expressions\fP.  The
handling of regular-expressions in \s-2JOVE\s0 is somewhat like that of
\fIed(1)\fP or \fIvi(1)\fP, but with some notable additions.  The precise
behavior depends on the setting of the variable
\fImatch-regular-expressions\fP.  If this variable is \fIon\fP, we use true
\fIregular-expressions\fP.  If it is \fIoff\fP, we have just
\fIsimple-expressions\fP.  In what follows, the term \fIexpression\fP should
be interpreted as simple-expression or regular-expression according to the
state of that variable.
.LP
Another variable that affects searching is \fIcase-ignore-search\fP.  If
this variable is set to \fIon\fP then upper case and lower case letters are
considered equal (except, of course, within regular-expressions such as
[A\-Za\-z]).
.LP
Note that the rules which follow are complex, arbitrary, and different from
those in other editors.  Hence they may be changed significantly in future
versions of \s-2JOVE\s0.
.HH 3 "Simple Regular Expressions"
.LP
If the variable \fImatch-regular-expressions\fP is \fIoff\fP, the search
pattern is interpreted as follows:
.IP "^ (at the start of a pattern or sub-pattern) " 14n
Matches the empty string at the beginning of a line.
.IP "$ (at the end of a pattern or sub-pattern)"
Matches the empty string at the end of a line.
.IP "\e\^<"
Matches the empty string at the beginning of a word.  What makes up a word
depends on the major mode of the buffer that you are searching in.  In all
modes a word is a contiguous sequence of characters which have some defined
pattern, bounded by characters that don't fit that pattern or by the
beginning or end of the line.  The individual modes' word patterns are as
follows:
.RS
.KS
.IP "\fIFundamental\fP " 12n
upper and lower case letters and digits.
.IP "\fIText\fP"
upper and lower case letters and digits plus apostrophe (').
.IP "\fIC\fP"
upper and lower case letters and digits plus \*Q$\*U and \*Q_\*U (underscore).
.IP "\fILisp\fP"
upper and lower case letters and digits plus
\*Q!\^$\^%\^&\^\(**\^+\^\-\^/\^:\^<\^=\^>\^?\^^\^_\^{\^|\^}\^\s+2~\s0\*U
and Delete.
.KE
.RE
.IP "\e\^> " 14n
Matches the empty string at the end of a word.
.IP "\e\^\fIc\fP"
Matches the character \fIc\fP where \fIc\fP is not one of
<, >, (, ), {, } or |.  In particular, \e\^^, \e\^$ and \e\^\e match the
characters ^, $ and \e\^.  When full regular-expressions are in use,
\e\^\fB.\fP, \e\^\(** and \e\^[ will also be required.
.IP "\fIc\fP"
Matches the character \fIc\fP where \fIc\fP is not \e or ^ (at the start of
a pattern) or $ (at the end of a pattern) (plus a few further things if
\fImatch-regular-expressions\fP is \fIon\fP).
.IP "\e\^{\fIc1...cN\fP\^\e}"
Matches whatever the sequence of regular-expressions \fIc1..cN\fP would have
matched.  Note that full regular-expression capability (even the \e| construct
described below) is provided within
\e\^{...\e} whatever the setting of the variable \fImatch-regular-expressions\fP.
\e\^{...\e} provides a grouping construct like parentheses in algebraic
expressions.  Thus \*Qaa\^\e\^{xx\^\e|yy\e}bb\*U searches for \*Qaaxxbb\*U
or \*Qaayybb\*U.
.IP "\e\^(\fIc1..cN\fP\^\e)"
Matches whatever the sequence of expressions \fIc1..cN\fP would have
matched, where the expressions are any of those described above (and also
the additional full regular-expressions if \fImatch-regular-expressions\fP is \fIon\fP).
This is used to tag part of the search text for later reference via
\e\^\fBn\fP (see below).  \e\^(\fIc1..cN\fP\^\e) patterns may be nested.
Observe that use of the \e| construct (see below) directly within a \e\^(...\e)
is precluded.
.IP "\e\^\fIn\fP"
Matches the \fIn\fP'th \e\^(\fIc1..cN\fP\^\e) pattern where \fIn\fP is
between 1 and 9.  The \e\^(\fIc1..cN\fP\^\e) patterns are numbered by
counting the \e\^( sequences starting from the beginning of the search
pattern, resetting to 1 (or to the value at the start of an enclosing
\e\^{...\e}) whenever a \e| is encountered.  To avoid confusion in the
counting, it is required that each alternative (separated by \e|) within a
\e\^{...\e} should contain the same number of \e\^(...\e)s.  For example, the
search pattern
\*Q^\^\e\^(\^\e\^{ab\^\e|cd\^\e}\^\e)\^\e1$\*U searches for all non-empty lines
which contain just \*Qabab\*U or \*Qcdcd\*U (but not \*Qabcd\*U).  It is an
error in the search pattern to reference a
\e\^(\fIc1..cN\fP\^\e) pattern that follows the occurrence of \e\^\fIn\fP.
.IP "\fIc1..cN\fP"
Matches the longest string matched by \fIc1\fP, followed by the longest
string matched by \fIc2\fP, and so on.  The expressions \fIc1..cN\fP are
any of those described above (and also the additional full
regular-expressions if \fImatch-regular-expressions\fP is \fIon\fP).
.IP "\fIc1..cN\fP\^\e|\fId1..dN\fP"
Matches the longest string matched by \fIc1..cN\fP, if any, and otherwise
the longest string matched by
\fId1..dN\fP.  Multiple \e| sequences may be used to indicate more
alternatives.  The sequences \fIc1..cN\fP and \fId1..dN\fP are any of those
described above, which means that \e| has lower precedence than any of the
other operators.
Each alternative must have the same number of \e\^(...\e) groups, as already
explained.
Thus, \*Q\^\e\^<foo\^\e|bar\^\e|baz\^\e\^>\*U matches any
word beginning with
\*Qfoo\*U, any occurrence of the string \*Qbar\*U, or any word ending in
\*Qbaz\*U.
.LP
In the replacement string:
.IP "\e\^\fIn\fP" 14n
Is replaced with the characters matched by the \fIn\fP'th
\e\^(\fIc1..cN\fP\^\e) in the search pattern where \fIn\fP is
between 1 and 9.  For example, one could replace
\*Q\e\^<\^\e\^(\^\e\^{FOO\^\e|BAR\^\e|BAZ\^\e}\^\e)\^\e\^>\*U
with \*Q[\^\e1]\*U to enclose every occurrence of the words FOO, BAR and
BAZ within [...].
.IP "\e\^0"
Is replaced with the characters matched by the entire search pattern.
.IP "\e\^\fIc\fP"
Inserts the character \fIc\fP where \fIc\fP is not a digit.
.IP "\fIc\fP"
Inserts the character \fIc\fP where \fIc\fP is not \e\^.
.HH 3 "Full Regular Expressions"
.LP
If the variable \fImatch-regular-expressions\fP is \fIon\fP, the following additional
special matching rules are used.  Observe that special meanings now attach to
the characters \fB.\fP, \(** and [, which can therefore no longer stand for
themselves.
.LP
In the search pattern:
.IP "\fIc\fP " 14n
Matches the character \fIc\fP where \fIc\fP is not one of \fB.\fP\^,
\(**, [, \e\^, ^ (at the start of
a line) or $ (at the end of a line).
.IP "\fB.\fP"
Matches any character, but not a line-separator.
.IP "[\fIc1..cN\fP]"
Matches any of the characters in the sequence of characters \fIc1..cN\fP
provided circumflex (^) is not the first character of the sequence (see
below).  The only special characters recognized while parsing the sequence
are \*Q]\*U,
\*Q\-\*U and
\*Q\^\e\*U.  All may be represented by escaping them with a backslash (\^\e\^):
\*Q\^\e\^]\*U, \*Q\^\e\^\-\*U, \*Q\^\e\^\e\*U.  Ranges of characters may be
indicated by \fIa\fP\-\fIb\fP where \fIa\fP is the first character of the
range and \fIb\fP is the last.  The special meaning of \- is lost if it
appears as the first or last character of the sequence.  The special meaning
of ] is lost if it appears as the first character of the sequence.
.IP "[^\fIc1..cN\fP]"
Matches any character except those contained in the sequence of characters
\fIc1..cN\fP.  The circumflex (^) is not special except immediately
following the left bracket.
.IP "\fIc\fP\(**"
Matches zero or more occurrences of the expression \fIc\fP.  The expression
\fIc\fP may be any of the expressions covered above except for
^ and $ (which match null strings), \e\^(\fIc1..cN\fP\^\e) and
\fIc1..cN\fP\^\e|\fId1..dN\fP (which would not work), and
\e\^{\fIc1...cN\fP\^\e} (arbitrarily forbidden).
.HH 1 "Commands for English Text"
.LP
\s-2JOVE\s0 has many commands that work on the basic units of English text:
words, sentences and paragraphs.
.HH 2 "Word Commands"
.LP
\s-2JOVE\s0 has commands for moving over or operating on words.
By convention,
they are all ESC commands.
.TS
L2w(10)fR L2w(20)fI Lw(\n(Ww)fR .
ESC\ F	forward-word	Move Forward over a word.
ESC\ B	backward-word	Move Backward over a word.
ESC\ D	kill-next-word	Kill forward to the end of a word.
ESC\ DEL	kill-previous-word	Kill backward to the beginning of a word.
.TE
.LP
Notice how these commands form a group that parallels the character-based
commands, ^F, ^B, ^D, and DEL.
.LP
The commands ESC\ F and ESC\ B move forward and backward over words.
They are thus analogous to ^F and ^B,
which move over single characters.
Like their Control- analogues,
ESC\ F and ESC\ B move over several words if given an argument (and in the
opposite direction with negative arguments).
Forward motion stops right after the last letter of the word;
backward motion stops right before the first letter.
.LP
ESC\ D kills the word after point.
To be precise,
it kills everything from point to the place ESC\ F would move to.
Thus,
if point is in the middle of a word,
only the part after point is killed.
If some punctuation comes after point,
and before the next word,
it is killed along with the word.
If you wish to kill only the next word but not the punctuation,
simply do ESC\ F to get to the end,
and kill the word backwards with ESC\ DEL.
ESC\ D takes arguments just like ESC\ F.
.LP
ESC\ DEL kills the word before point.
It kills everything from point back to where ESC\ B would move to.
If point is after the space in \*QFOO, BAR\*U,
then \*QFOO, \*U is killed.
If you wish to kill just \*QFOO\*U,
then do an ESC\ B and an ESC\ D instead of an ESC\ DEL.
.LP
Note that the term \*Qword\*U in all of these commands refers simply to a
sequence of upper and lower case letters and digits.  It is not dependent on
the major mode of the buffer as was the case with regular-expressions
involving \e\^< and \e\^>.  Thus it will require two uses of ESC\ D to remove a
word such as \*Qisn't\*U, even if the major mode is Text mode.
.HH 2 "Sentence Commands"
.LP
The \s-2JOVE\s0 commands for manipulating sentences and paragraphs are
mostly ESC commands,
so as to resemble the word-handling commands.
.TS
L2w(10)fR L2w(20)fI Lw(\n(Ww)fR .
ESC\ A	backward-sentence	Move back to the beginning of the sentence.
ESC\ E	forward-sentence	Move forward to the end of the sentence.
ESC\ K	kill-to-end-of-sentence	Kill forward to the end of the sentence.
^X\ DEL	kill-to-beginning-of-sentence	Kill back to the beginning of the sentence.
.TE
.LP
The commands ESC\ A and ESC\ E move to the beginning and end of the
current sentence,
respectively.
They were chosen to resemble
^A and ^E,
which move to the beginning and end of a line.
Unlike them,
ESC\ A and ESC\ E if repeated or given numeric arguments
move over successive sentences.
\s-2JOVE\s0 considers a sentence to end wherever there is a \*Q.\*U,
\*Q?\*U, or \*Q!\*U followed by the end of a line
or by one or more spaces.
Neither ESC\ A nor ESC\ E moves past the
end of the line or the spaces which delimit the sentence.
.LP
Just as ^A and ^E have a kill command,
^K,
to go with them,
so ESC\ A and ESC\ E have a corresponding kill command ESC\ K which kills from
point to the end of the sentence.
With minus one as an argument it
kills back to the beginning of the sentence.
Positive arguments serve as a repeat count.
.LP
There is a special command
^X\ DEL for killing back to the beginning of a sentence,
because this is useful when you change your
mind in the middle of composing text.
.HH 2 "Paragraph Commands"
.LP
The \s-2JOVE\s0 commands for handling paragraphs are
.TS
L2w(10)fR L2w(20)fI Lw(\n(Ww)fR .
	backward-paragraph	Move back to the start of the previous paragraph.
ESC\ ]	forward-paragraph	Move forward to the end of the next paragraph.
.TE
.LP
Note that \*QESC\ [\*U is not bound to \fIbackward-paragraph\fP, as might have
been expected, on most (i.e. ANSI-compliant) terminals because that sequence
is used as a prefix for codes generated by the Function Keys.
.LP
\fIBackward-paragraph\fP moves to the beginning of the current or previous
paragraph, while \fIforward-paragraph\fP moves to the end of the current or
next paragraph.  Paragraphs are delimited by lines of differing indent, or
lines with text formatter commands, or blank lines.  \s-2JOVE\s0 knows how
to deal with most indented paragraphs correctly, although it can get
confused by one- or two-line paragraphs delimited only by indentation.
.HH 2 "Text Indentation Commands"
.LP
.TS
L2w(10)fR L2w(20)fI Lw(\n(Ww)fR .
Tab	handle-tab	Indent \*Qappropriately\*U in a mode-dependent fashion.
Linefeed	newline-and-indent	T{
Is the same as Return, except it copies the indent of the line you just left.
T}
ESC\ M	first-non-blank	Moves to the line's first non-blank character.
.TE
.LP
The way to request indentation is with the Tab command.
Its precise effect depends on the major mode.
In \fIText\fP mode,
it indents to the next tab stop (as determined by the variable
\fItab-width\fP, whose default value is 8).
In \fIC\fP mode or \fILisp\fP mode,
it indents to the \*Qright\*U position for those programs (see later).
.LP
To move over the indentation on a line,
do ESC\ M (\fIfirst-non-blank\fP).
This command,
given anywhere on a line,
positions the cursor at the first non-blank, non-tab character on the line.
.HH 2 "Text Filling"
.TS
L2w(10)fR L2w(20)fI Lw(\n(Ww)fR .
	auto-fill-mode	Toggle the minor mode \fIauto fill\fP.
ESC\ J	fill-paragraph	Refill the paragraph containing the cursor.
	fill-region	Refill the region.
	fill-comment	Refill a comment, depending on the major mode.
	left-margin-here	Sets the variable \fIleft-margin\fP from point.
	right-margin-here	Sets the variable \fIright-margin\fP from point.
.TE
.LP
\fIAuto Fill\fP mode is a minor mode that causes text to be \fIfilled\fP
(broken up into lines that fit in a specified width)
automatically as you type it in.
If you alter existing text so that it is no longer properly filled,
\s-2JOVE\s0 can fill it again if you ask.
.LP
Entering \fIAuto Fill\fP mode is done with ESC\ X \fIauto-fill-mode\fP.
From then on,
lines are broken automatically at spaces when they get longer than the
desired width.
To leave \fIAuto Fill\fP mode,
once again execute ESC\ X \fIauto-fill-mode\fP.
When \fIAuto Fill\fP mode is in effect,
the word \fBFill\fP appears in the mode line.
.LP
If you edit the middle of a paragraph,
it may no longer be filled correctly.
To refill a paragraph,
use the command ESC\ J (\fIfill-paragraph\fP).
It causes the paragraph that point is inside to be filled.
All the line breaks are removed and new ones inserted where necessary.
Similarly, \fIfill-region\fP may be used to refill a region other than a
paragraph.  The special command \fIfill-comment\fP is only meaningful in
those major modes, currently C mode and Lisp mode, which support it.
.LP
The maximum line width for filling is in the variable \fIright-margin\fP.
Both ESC\ J and auto-fill make sure that no line exceeds this width.
The value of \fIright-margin\fP is initially 78.
.LP
Normally ESC\ J figures out the indent of the paragraph and uses that same
indent when filling.  If you want to force some other indent for a paragraph,
you set \fIleft-margin\fP to the new position and type ^U\ ESC\ J, since
\fIfill-paragraph\fP uses the value of
\fIleft-margin\fP when supplied with a numeric argument.
.LP
If you know where you want to set the variable \fIright-margin\fP but you
don't know the actual value, move to where you want to set the value and use
the
\fIright-margin-here\fP command.  \fIleft-margin-here\fP does the same
for the \fIleft-margin\fP variable.
.HH 2 "Case Conversion Commands"
.TS
L2w(10)fR L2w(20)fI Lw(\n(Ww)fR .
ESC\ L	case-word-lower	Convert the following word to lower case.
ESC\ U	case-word-upper	Convert the following word to upper case.
ESC\ C	case-word-capitalize	Capitalize the following word.
	case-character-capitalize	Capitalize the character after point.
	case-region-lower	Convert the region to lower case.
	case-region-upper	Convert the region to upper case.
.TE
.LP
The word conversion commands are most useful.
ESC\ L converts the word after point to lower case,
moving past it.
Thus,
successive ESC\ L's convert successive words.
ESC\ U converts to all capitals instead,
while ESC\ C puts the first letter of the word into upper case and the
rest into lower case.
All these commands convert several words at once if given an argument.
They are especially convenient for
converting a large amount of text from all upper case to mixed case,
because you can move through the text using ESC\ L,
ESC\ U or ESC\ C on each word as appropriate.
.LP
When given a negative argument,
the word case conversion commands apply to
the appropriate number of words before point,
but do not move point.
This is convenient when you have just typed a word in the wrong case.
You can give the case conversion command and continue typing.
.LP
If a word case conversion command is given in the middle of a word,
it applies only to the part of the word which follows the cursor,
treating it as a whole word.
.HH 2 "Commands for Fixing Typos"
.LP
In this section we summarize the commands that are especially useful for the
times when you catch a mistake in your text just after you have made it, or
you change your mind while composing text on a line.
.TS
L2w(10)fR L2w(20)fI Lw(\n(Ww)fR .
DEL	delete-previous-character	Delete last character.
ESC\ DEL	kill-previous-word	Kill last word.
^X\ DEL	kill-to-beginning-of-sentence	Kill to beginning of sentence.
^T	transpose-characters	Transpose two characters.
^X\ ^T	transpose-lines	Transpose two lines.
ESC\ Minus ESC\ L		Convert last word to lower case.
ESC\ Minus ESC\ U		Convert last word to upper case.
ESC\ Minus ESC\ C		Convert last word to lower case with initial capital.
.TE
.LP
.HH 3 "Killing Your Mistakes"
.LP
The DEL command is the most important correction command.
When used among printing (self-inserting) characters,
it can be thought of as canceling the last character typed.
.LP
When your mistake is longer than a couple of characters,
it might be more convenient to use ESC\ DEL or ^X\ DEL.
^X\ DEL is particularly useful when
you are thinking of what to write as you type it,
in case you change your mind about phrasing.
ESC\ DEL and ^X\ DEL save the killed text for subsequent yanking.
.LP
ESC\ DEL is often useful even when you have typed only a few
characters wrong,
if you know you are confused in your typing and aren't sure what you typed.
At such a time,
you cannot correct with
DEL except by looking at the screen to see what you did.
It requires less thought to kill the whole word and start over again.
.HH 3 "Transposition"
.LP
The common error of transposing two characters can be fixed
with the ^T (\fItranspose-characters\fP) command.
Normally,
^T transposes the two characters on either side of the cursor
and moves the cursor forward one character.  Repeating the command
several times \*Qdrags\*U a character to the right.
When given at the end of a line,
rather than switching the last character of the line with the line-separator,
which would be useless,
^T transposes the last two characters on the line.
So,
if you catch your transposition error right away,
you can fix it with just a ^T.
If you don't catch it so quickly,
you must move the cursor back to between the two characters.
.LP
To transpose two lines,
use the ^X\ ^T (\fItranspose-lines\fP) command.  The line containing the
cursor is exchanged with the line above it; the cursor is left at the
beginning of the line following its original position.
.HH 2 "Checking and Correcting Spelling"
.LP
When you write a paper,
you should correct its spelling at some point close to finishing it.
To correct the entire buffer,
do ESC\ X \fIspell-buffer\fP.
This invokes the
.UX
.I spell
program,
which prints a list of all the misspelled words.
\s-2JOVE\s0 catches the list and places it in a
\s-2JOVE\s0 buffer called \fBSpell\fP.
You now edit the \fBSpell\fP buffer (technically, you are in a recursive
edit at this point) by deleting from that buffer any words that
aren't really errors.  Next, type ^X\ ^C (\fIexit-jove\fP) to escape from the
recursive edit, and \s-2JOVE\s0 now positions you at the first misspelled word
in the original buffer.  Correct that mistake with the usual editor commands.
Then you can go forward to each other misspelled word with ^X\ ^N
(\fInext-error\fP) or backward with ^X\ ^P (\fIprevious-error\fP).
If, in the course of editing a mistake, you get completely lost, the command
\fIcurrent-error\fP will put you back at the error you were supposed to be
correcting.
.HH 1 "Buffers"
.LP
When we speak of \*Qthe buffer\*U,
which contains the text you are editing,
we may have given the impression that there is only one.
In fact,
there may be many of them,
each with its own body of text.
At any time only one buffer can be \fIcurrent\fP and available for editing,
but it is easy to switch to a different one.
Each buffer individually remembers which file it contains,
what modes are in effect,
and whether there are any changes that need saving.
.TS
L2w(10)fR L2w(20)fI Lw(\n(Ww)fR .
^X\ B	select-buffer	Select or create a buffer.
^X\ ^B	list-buffers	List the existing buffers.
^X\ K	delete-buffer	Delete the contents of a buffer and destroy it.
	erase-buffer	Delete the contents of a buffer.
	kill-some-buffers	Destroy unwanted buffers.
	rename-buffer	Rename the selected buffer.
	buffer-position	Report the position of point within the buffer.
ESC\ \s+2~\s0	make-buffer-unmodified	Tell \s-2JOVE\s0 to forget that the buffer has been changed.
^X\ ^F	find-file	Read a file into its own buffer.
^X\ ^S or ^X\ \e	save-file	Save the selected buffer.
^X\ ^M	write-modified-files	Save all modified buffers.
.TE
.LP
Each buffer in \s-2JOVE\s0 has a single name
which normally doesn't change.
A buffer's name can be any length.
The name of the currently selected buffer
and the name of the file contained in it
are visible in the mode line of any window displaying that buffer.
A newly started \s-2JOVE\s0 has only one buffer,
named \fBMain\fP, unless you specified files to edit in the
shell command that started \s-2JOVE\s0.
.HH 2 "Creating and Selecting Buffers"
.LP
To create a new buffer,
you need only think of a name for it (say, FOO)
and then type ^X\ B FOO<return> (\fIselect-buffer\fP).
This makes a new,
empty buffer (if one by that name didn't exist previously)
and selects it for editing.
The new buffer does not contain any file,
so if you try to save it you will be asked for the filename to use.
Each buffer has its own major mode;
the new buffer's major mode is Text mode by default.
.LP
To return to buffer FOO later after having switched to another,
the same command ^X\ B FOO<return> is used,
since ^X\ B can tell whether a buffer named FOO exists already or not.
Just ^X\ B<return> reselects the previous buffer.
Repeated ^X\ B<return>'s alternate between the last two buffers selected.
.HH 2 "Using Existing Buffers"
.LP
To get a list of all the buffers that exist,
type ^X\ ^B (\fIlist-buffers\fP).
Each buffer's type,
name,
and contained filename is printed.
An asterisk before the buffer name indicates that there are
changes that have not yet been saved.  The number
that appears at the beginning of a line in a ^X\ ^B listing is that
buffer's \fIbuffer number\fP.
You can select a buffer by typing its number in place of its name.
If a buffer with that number doesn't already exist,
a new buffer is created with that number as its name.
.LP
If several buffers have modified text in them,
you can save them with ^X\ ^M (\fIwrite-modified-files\fP).
This finds all the buffers that need saving and then saves them.
Saving the buffers this way is much
easier and more efficient (but more dangerous)
than selecting each one and typing ^X\ ^S (\fIsave-file\fP).
If you give ^X\ ^M an argument, \s-2JOVE\s0 will ask for confirmation
before saving each buffer.
.LP
ESC\ X \fIrename-buffer\fP <new name><return> changes the name of the
selected buffer.
.LP
ESC\ X \fIerase-buffer\fP <buffer name><return> erases the contents of
<buffer name> without destroying it entirely.
.LP
ESC\ X \fIbuffer-position\fP reports the position of point within the
selected buffer, both as lines/total-lines, chars/total-chars, and as a
percentage.
.LP
Sometimes you will change a buffer by accident.
Even if you undo the effect of the change by editing,
\s-2JOVE\s0 still knows that \*Qthe buffer has been changed\*U.
You can tell \s-2JOVE\s0 to pretend that there have been no changes with the
ESC\ \s+2~\s0 command (\fImake-buffer-unmodified\fP).
This command simply clears the \*Qmodified\*U flag which
says that the buffer contains changes which need to be saved.
Even if
the buffer really \fIis\fP changed \s-2JOVE\s0 will still act as if it were not.
.HH 3 "Killing Buffers"
.LP
After you use a \s-2JOVE\s0 for a while, it may fill up with buffers which
you no longer need.  Eventually you can reach a point where trying to create
any more results in an \*Qout of memory\*U or \*Qout of lines\*U error.
When this happens you will want to destroy some buffers with the ^X\ K
(\fIdelete-buffer\fP) command.  You can destroy the buffer FOO by doing
^X\ K FOO<return>.  If you type ^X\ K <return> \s-2JOVE\s0 will kill the
previously selected buffer.  If you try to kill a buffer that needs saving
\s-2JOVE\s0 will ask you to confirm it.
.LP
If you need to kill several buffers, use the command \fIkill-some-buffers\fP.
This prompts you with the name of each buffer and asks for confirmation
before killing it.
.HH 1 "File Handling"
.LP
The basic unit of stored data is the file.
Each program,
each document,
lives usually in its own file.
To edit a program or document,
the file that contains it must first be brought into a buffer, either an
existing one (\fIvisit-file\fP) or one created specifically for that file
(\fIfind-file\fP).
To make your changes to the file permanent on disk,
you must \fIsave\fP the file.
.HH 2 "Reading Files"
.TS
L2w(10)fR L2w(20)fI Lw(\n(Ww)fR .
^X\ ^F	find-file	Read a file into its own buffer.
^X\ ^V	visit-file	Visit a file.
^X\ ^R	visit-file	An alternative to ^X\ ^V.
^X\ ^I	insert-file	Insert a file at point.
.TE
.LP
\s-2JOVE\s0 remembers the name of the file that is contained in each buffer
(remember the ^X\ ^B (\fIlist-buffers\fP) command).
The name of the buffer is visible in its mode line together with the
name of its file.
.LP
You can read a file into its own newly created buffer by typing ^X\ ^F
(\fIfind-file\fP), followed by the filename.  The name of the new buffer will
be the last element of the file's pathname.  You can abort the command by
typing ^G, or edit the filename with any of the standard \s-2JOVE\s0
commands (e.g., ^A, ^E, ^F, ESC\ F, ESC\ DEL).  If the filename you wish to
visit is similar to the filename in the current mode line (the default
filename), you can type ^R to insert the default and then edit it.  For more
about this and other special methods of constructing filenames, see the
sections on
.IQ "The Message Line"
and
.IQ "Name Completion"
earlier in this
manual.  When you are satisfied type Return, and the new file's text will
appear on the screen, and its name in the mode line.
.LP
The ^F in ^X\ ^F stands for \*QFind\*U,
because if the specified file already resides in some buffer,
that buffer is simply reselected.
So you need not remember whether you have brought the file in already or not.
A buffer created by ^X\ ^F can be reselected later with ^X\ B or ^X\ ^F,
whichever you find more convenient.
.LP
\fIVisiting\fP a file means copying its contents into an existing buffer so
that you can edit them.
To visit a file,
use the command ^X\ ^V or ^X\ ^R (\fIvisit-file\fP),
followed by the filename.  The name of the new file will appear in the mode
line but the name of the buffer will be unchanged.
.LP
If you alter one file and then visit another in the same buffer,
\s-2JOVE\s0 offers to save the old one.
If you answer YES (or y),
the old file is saved;
if you answer NO (or n),
all the changes you have made to it since the last save are lost.
You should not type ahead after a file visiting
command,
because your type-ahead might answer an unexpected question
in a way that you would regret.
.LP
^X\ ^I (\fIinsert-file\fP) followed by a filename reads the file and inserts
it into the buffer at point, leaving point before the file contents and the
mark at their end.
.LP
The changes you make with \s-2JOVE\s0 are made in a copy inside \s-2JOVE\s0.
The file itself is not changed.
The changed text is not permanent until you \fIsave\fP it in a file.
The first time you change the text,
an asterisk appears in the mode line; this indicates that the text
contains fresh changes which will be lost unless you save them.
.LP
What if you want to create a file?  Just read it with \fIfind-file\fP or
\fIvisit-file\fP.  \s-2JOVE\s0 prints
\fI(New file)\fP but aside from that behaves as if you had read an existing
empty file.
If you make any changes and save them,
the file is created then.
If you read a nonexistent file unintentionally
(because you typed the wrong filename),
go ahead and read the file you meant.
The unwanted file will not have been created.
.HH 2 "Writing files"
.TS
L2w(10)fR L2w(20)fI Lw(\n(Ww)fR .
^X\ ^S or ^X\ ^\^\e	save-file	Save the file in the selected buffer.
^X\ ^W	write-file	Write the selected buffer to a different file.
	write-region	Write the region to the specified file.
	append-region	Append the region to the specified file.
.TE
.LP
If you wish to save the file and make your changes permanent,
type ^X\ ^S.
After the save is finished,
^X\ ^S prints the filename and the
number of characters and lines that it wrote to the file.
If there are no changes to save (no asterisk in the mode line),
the file is not saved;
otherwise the changes are saved and the asterisk in
the mode line disappears.
.LP
If \s-2JOVE\s0 is about to save a file and sees that the date of the version
on disk does not match what \s-2JOVE\s0 last read or wrote,
\s-2JOVE\s0 notifies you of this fact,
and asks what to do, because this probably means that something is wrong.
For example,
somebody else may have been editing the same file.
If this is so,
there is a good chance that your work
or his work will be lost if you don't take the proper steps.
You should first find out exactly what is going on.
If you determine that somebody else has modified the file,
save your file under a different filename and then DIFF the two files
to merge the two sets of changes.  (The \*Qpatch\*U command is useful for
applying the results of context diffs directly).
Also get in touch with the other person so that the files don't diverge
any further.
.LP
^X\ ^W <filename><return> (\fIwrite-file\fP) writes the contents of the
buffer into the file <filename>, changing the name of the file recorded in
the mode line accordingly.  It can be thought of
as a way of \*Qchanging the name\*U of the file in the buffer.  Unlike
^X\ ^S,
\fIwrite-file\fP saves even if the buffer has not been changed.
.LP
ESC\ X \fIwrite-region\fP <file><return> writes the region (the text between
point and mark) to the specified file.
It does not change the buffer's filename.
.LP
ESC\ X \fIappend-region\fP <file><return> appends the region to <file>.
The text is added to the end of <file>.
.HH 2 "How to Undo Drastic Changes to a File"
.LP
If you have made several extensive changes to a file and then change
your mind about them,
and you haven't yet saved them,
you can get rid of them by reading in the previous version of the file.
You can do this with the ^X\ ^V (\fIvisit-file\fP) command,
to visit the unsaved version of the file.
Remember to tell it not to save your existing changes when it asks.
.HH 1 "Windows
.HH 2 "Multiple Windows"
.LP
\s-2JOVE\s0 allows you to split the screen into two or more \fIwindows\fP and
use them to display parts of different buffers,
or different parts of the same buffer.
.KS
.TS
center;
=
|| L1	|| L1.

#define\ getchar()\ \ \ \ getc(stdin)
#define\ putchar(x)\ \ \ putc((x), stdout)	<\ first Window
_	
\fBJOVE\ (C RO)\ \ \ [stdio.h:1]\ \ "/usr/include/stdio.h"\ \ \-\-\fP	<\ the Mode Line
_	
{
\ \ \ \ printf("Hello world!\^\e\^n");
\ \ \ \ return 0;	<\ second Window
}\^\(sq
_	
\fBJOVE\ (C OvrWt)\ \ \ [Main:1]\ \ "aloha.c"\ \ \-\-\ \ /home/foo\ \ \ \ 15:28\fP	<\ the Mode Line
_	
[Point pushed]	<\ the Message Line
=	
.TE
.KE
.TS
L2w(10)fR L2w(20)fI Lw(\n(Ww)fR .
^X\ 2	split-current-window	Divide the active window into two smaller ones.
^X\ 1	delete-other-windows	Delete all windows but the current one.
^X\ D	delete-current-window	Delete the active window.
^X\ N	next-window	Switch to the next window.
^X\ P	previous-window	Switch to the previous window.
^X\ O	previous-window	Same as ^X\ P.
^X\ ^	grow-window	Make this window bigger.
	shrink-window	Make this window smaller.
ESC\ ^V	page-next-window	Scroll the other window.
^X\ 4	window-find	Combination window command.
.TE
.LP
When using \fImultiple window\fP mode,
the window portion of the screen
is divided into \fIwindows\fP,
which can display different pieces of text.
Each window can display different buffers,
or different parts of the same buffer.
Only one of the windows is
\fIactive\fP, viz.
the window which the cursor is in.
Editing normally takes place in that window alone.
To edit in another window,
you would give a command to move the cursor to the other window,
and then edit there.
.LP
Each window includes a mode line for the buffer it is displaying.  This is
useful to keep track of which window corresponds with which buffer and which
file.  In addition, the mode line serves as a separator between windows.
Normally, the variable \fImode-line-should-standout\fP is \fIon\fP so that
\s-2JOVE\s0 displays the mode-line in reverse video (assuming your
particular terminal has the reverse video capability).  However, if the
variable
.I scroll-bar
is also \fIon\fP, a portion of the mode line is left clear to indicate how the
window is located within the buffer.
.LP
The command ^X\ 2 (\fIsplit-current-window\fP) divides the active window
into two.  A new mode line appears across the middle of the original window,
dividing its display area into two halves.
Both windows contain the same buffer and display the same position in it,
namely where point was at the time you issued the command.
The cursor moves to the second window.
.LP
To return to viewing only one window,
use the command ^X\ 1 (\fIdelete-other-windows\fP).
The active window expands to fill the whole screen,
and the other windows disappear until the next ^X\ 2.
(The buffers and their contents are unaffected by any of the
window operations).
.LP
While there is more than one window,
you can use ^X\ N (\fInext-window\fP) to switch to the next window,
and ^X\ P (\fIprevious-window\fP) to switch to the previous one.
If you are in the bottom window and you type ^X\ N,
you will be placed in the top window,
and the opposite thing happens when you type ^X\ P in the top window.
^X\ O is the same as ^X\ P.
It stands for \*Qother window\*U because, when there are only two windows,
repeated use of this command will switch between them.
.LP
Often you will be editing one window while using the other just for reference.
Then,
the command ESC\ ^V (\fIpage-next-window\fP) is very useful.
It scrolls the next window up, just
as if you switched to the next window,
typed ^V,
and switched back.
With a negative argument,
ESC\ ^V will scroll down.
.LP
When a window splits,
both halves are approximately the same size.
You can redistribute the screen space between the windows with
the ^X\ ^ (\fIgrow-window\fP) command.
It makes the active window grow one line bigger,
or as many lines as is specified with a numeric argument.
Use ESC\ X \fIshrink-window\fP to make the active window smaller.
.HH 2 "Multiple Buffers in Multiple Windows"
.LP
Buffers can be selected independently in each window.  The ^X\ B
(\fIselect-buffer\fP) command selects a different buffer in the active
window (i.e. the
one containing the cursor).  Other windows' buffers do not change.  Likewise,
the ^X\ ^F (\fIfind-file\fP) command reads a new file into a new buffer in
the active window.
.LP
You can view the same buffer in more than one window.
Although the same buffer appears in both windows,
they have different values of point,
so you can move around in one window while the other window
continues to show the same text.
If you make changes in one window, and the same place in the buffer happens
to be visible in the other window, your changes will appear simultaneously
in both places.
.LP
If you have the same buffer in both windows,
you must beware of trying to visit a different file in one of
the windows with ^X\ ^V,
because if you bring a new file into this buffer
it will replace the old file in \fIboth\fP windows.
To view different files in different windows,
you must switch buffers in one of the windows first
(with ^X\ B) or use ^X\ ^F (\fIfind-file\fP).
.LP
A convenient \*Qcombination\*U command for viewing something in another
window is ^X\ 4 (\fIwindow-find\fP).
With this command you can ask to see any specified buffer,
file or tag in the other window.
Follow the ^X\ 4 with either B and a buffer name,
F and a filename,
or T and a tag name.
This switches to the other window and finds there what you specified.
If you were previously in one-window mode,
multiple-window mode is entered.
^X\ 4 B is similar to ^X\ 2 ^X\ B;
^X\ 4 F is similar to ^X\ 2 ^X\ ^F;
^X\ 4 T is similar to ^X\ 2 ^X\ T.
The difference is one of efficiency,
and also that ^X\ 4 works equally well if you are already using two windows.
.HH 2 "Controlling the Display"
.LP
Since only part of a large file will fit in a window,
\s-2JOVE\s0 tries to show the portion that is likely to be interesting.
The display control commands allow you to bring a different portion of the buffer
within the active window.
.TS
L2w(10)fR L2w(20)fI Lw(\n(Ww)fR .
^L	redraw-display	T{
Reposition point at a specified vertical position,
OR clear and redraw the window with point in the same place.
T}
ESC\ ^L	clear-and-redraw	Clear and redraw the entire screen.
^V	next-page	Scroll forwards (a page or a few lines).
ESC\ V	previous-page	Scroll backwards.
^Z	scroll-up	Scroll forward some lines.
ESC\ Z	scroll-down	Scroll backwards some lines.
	scroll-left	Scroll the window to the left.
	scroll-right	Scroll the window to the right.
	number-lines-in-window	Number the lines in the window.
.TE
.LP
A window is rarely large enough to display all of your file.
If the whole buffer doesn't fit on the screen,
\s-2JOVE\s0 shows a contiguous portion of it,
containing point.
It continues to show approximately the same portion
until point moves outside of what is displayed;
then \s-2JOVE\s0 chooses a new portion centered around a new point.
This is \s-2JOVE\s0's guess as to what you are most interested in seeing,
but if the guess is wrong,
you can use the display control commands to see a different portion.
.LP
If the window holds only a part of the buffer, and if the variable
.I scroll-bar
is \fIon\fP, a clear patch in the (otherwise reverse-videoed) mode line
indicates what proportion is visible.  This is especially useful for
mouse-based versions of the editor, such as
.I xjove .
.LP
First we describe how \s-2JOVE\s0 chooses a new window position on its own.
The goal is usually to place point
half way down the window.
This is controlled by the variable \fIscroll-step\fP,
whose value is the number of
lines above the bottom or below the top of the window that the line
containing point is placed.
A value of 0 (the initial value) means center point
in the window.
.LP
The basic display control command is ^L (\fIredraw-display\fP).
In its simplest form,
with no argument,
it tells \s-2JOVE\s0 to choose a new portion of the buffer,
centering the existing point half way from the top as usual.
^L with a positive argument chooses a new portion so as to put point
that many lines from the top.
An argument of zero puts point on the very top line.
Point does not move with respect to the text; rather,
the text and point move rigidly on the screen.
.LP
If during the ^L command point stays on the same line,
the window is first cleared and then redrawn.
Thus,
two ^L's in a row are guaranteed to clear and redraw the active window.
ESC\ ^L (\fIclear-and-redraw\fP) will clear and redraw the entire screen.
.LP
The \fIscrolling\fP commands ^V,
ESC\ V,
^Z,
and ESC\ Z
let you move the whole display up or down a few lines.
In fact, with a numeric argument, ^V is identical to ^Z and ESC\ V to ESC\ Z.
So ^V (\fInext-page\fP) or ^Z (\fIscroll-up\fP) with an
argument shows you that many more lines at the bottom of the screen,
moving the text and point up together as ^L might.
^V or ^Z with a
negative argument shows you more lines at the top of the screen,
as does ESC\ V (\fIprevious-page\fP) or ESC\ Z (\fIscroll-down\fP) with a
positive argument.
.LP
^V with no argument scrolls the buffer a window at a time.
It takes the last line at the bottom of the window and puts
it at the top,
followed by nearly a whole window of lines not visible before.
Point is put at the top of the window.
Thus, each ^V shows the \*Qnext page of text\*U,
except for one line of overlap to provide context.
To move backward,
use ESC\ V without an argument,
which moves a whole window backwards (again with a line of overlap).
.LP
With no argument, ^Z and ESC\ Z scroll one line forward and one line backward,
respectively.
These are convenient for moving in units of one line
without having to type a numeric argument.
.LP
The commands \fIscroll-left\fP and \fIscroll-right\fP scroll the entire
window in the specified direction by the amount of the argument (or for 10
characters by default).  The argument may be negative.
.LP
The command \fInumber-lines-in-window\fP causes each line displayed to be
preceded by its line-number (and giving the command again restores the
former state).  Note that this state is a property of the window, not of the
buffer.
.HH 1 "Processes Under \s-2JOVE\s0"
.LP
An important feature of \s-2JOVE\s0 is its ability to interact with
.UX .
You can run
.UX
commands from \s-2JOVE\s0 and catch their output in \s-2JOVE\s0 buffers.
Two mechanisms are provided, \fIinteractive processes\fP and \fInon-interactive processes\fP.
.HH 2 "Interactive Processes"
.LP
With most modern
.UX
systems, \s-2JOVE\s0
has the capability of running interactive
processes, accepting your input and capturing your output in a buffer.
.TS
L2w(10)fR L2w(20)fI Lw(\n(Ww)fR .
	shell	T{
Run a shell in an interactive process buffer.
T}
	i-shell-command	T{
Run a \s-1UNIX\s0 command in an interactive process buffer.
T}
.TE
.HH 3 "How to Run a Shell in a Window"
.LP
Type ESC\ X \fIshell\fP<return> to start up a shell.
\s-2JOVE\s0 will
create a buffer,
called \fB\(**shell\(**\-1\fP,
and choose a window for this new buffer.
The shell process is now said to be attached to the buffer.
The program that is now running in the buffer is that specified by the
variable \fIshell\fP, which is itself initialized from your SHELL
environment variable.  The shell command is called with the flag \*Q-c\*U, or
whatever else the variable \fIshell-flags\fP has been set to.
.LP
Use an argument (\fBn\fP) with the \fIshell\fP command to create other
buffers (\fB\(**shell\(**\-n\fP) running independent shells.
.LP
Once an interactive process is running you can select another buffer into
that window, or you can delete that window altogether.  You can go off and
do some other editing while the command is running.  This is useful for
commands that do sporadic output and run for fairly long periods of time.
When you reselect that buffer later it will be up to date.  That is, even
though the buffer wasn't visible it was still receiving output from the
process.  You don't have to worry about missing anything when the buffer
isn't visible.
.HH 3 "How to Run a Command in a Window"
.LP
To run a
.UX
command interactively from \s-2JOVE\s0 type ESC\ X \fIi-shell-command\fP
<command-name><return>.  For example, to run the desk calculator, you do:
.DS
ESC\ X i-shell-command dc<return>
.DE
Then \s-2JOVE\s0 picks a buffer in which the output from the
command will be placed, named after the command (\fIdc\fP in this case).
Compare this command to the non-interactive \fIshell-command\fP to be
described presently.
.HH 3 "Facilities available in interactive windows"
.LP
What you type into an interactive process isn't seen immediately by the
process; instead \s-2JOVE\s0 waits until you type an entire line before
passing it on to the process to read.  This means that before you type
Return all of \s-2JOVE\s0's editing capabilities are available for fixing
errors on your input line.  If you discover an error at the beginning of the
line, rather than erasing the whole line and starting over you can simply
move to the error, correct it, move back, and continue typing.
.LP
In fact Return does different things
depending on both your position in the buffer and on the state of the process.
In the normal case,
when point is in the last line of the buffer,
Return does as already described: it inserts a line-separator and then
sends the line to the process.
If you are somewhere else in the buffer,
possibly positioned at a previous command that you want to edit,
Return will place a copy of that line
at the end of the buffer and move you there
(the prompt will be discarded if there is one \(em the variable
\fIprocess-prompt\fP specifies what to discard)
Then you can edit the line and type Return as in the normal case.
If the process has died for some reason,
Return does nothing.
It doesn't even insert itself.
If that happens unexpectedly,
you should type ESC\ X \fIlist-processes\fP<return>
to get a list of each process and its state.
If your process died abnormally,
\fIlist-processes\fP may help you figure out why.
.LP
Another feature is that you have the entire history of your session in
the \s-2JOVE\s0 buffer.
You don't have to worry about output from a command
moving past the top of the screen.
If you missed some output you can
move back through it with ESC\ V and other commands.
In addition,
you can save yourself retyping a command (or a similar one) by sending
edited versions of previous commands, or edit the output of one command
to become a list of commands to be executed (\*Qimmediate shell scripts\*U).
.LP
There are several special commands available only in interactive windows.
.TS
L2w(10)fR L2w(20)fI Lw(\n(Ww)fR .
Return	process-newline	Send a line to a process.
	process-send-data-no-return	T{
Send a line to a process, but without the line-separator.
T}
^C\ ^C	interrupt-process	Send SIGINT to the process.
^C\ \^\e	quit-process	Send SIGQUIT to the process.
^C\ ^Z	stop-process	Send SIGTSTP to the process.
^C\ ^Y	dstop-process	Send SIGTSTP when next the process tries to read input.
	continue-process	Send SIGCONT to the process.
	kill-process	Send SIGKILL to the process in a specified buffer.
^C\ ^D	eof-process	Send EOF to the process.
	process-dbx-output	Toggle the processing of output from \fIdbx\fP.
.TE
Although Return is automatically bound to \fIprocess-newline\fP, the various
^C\ ... must be explicitly bound in your (or your system administrator's)
customization.  The effects of Return (\fIprocess-newline\fP) in various
circumstances have already been described above.  The effects of ^C\ ^\fBx\fP
for various \fBx\fP are equivalent to sending ^\fBx\fP to the shell,
assuming the customary bindings as set up by \fIstty\fP.  Observe that
^\fBx\fP without a preceding ^C will have some other effect in \s-2JOVE\s0
(for example, ^D is still bound to \fIdelete-next-character\fP).
.HH 3 "DBX in interactive windows"
.LP
If the debugging program \fIdbx\fP is provided with your
.UX
system, you may of course run it in an interactive window.  Before doing
this, you should type ESC\ X \fIprocess-dbx-output\fP.  The effect of this is
that, every time \fIdbx\fP halts with a message line specifying a filename and
linenumber (at every breakpoint, for example), \fIfind-file\fP will
automatically be called on that filename, it will appear in a new window,
and point will be moved to that line.  Thus you may easily follow the
progress of the program being debugged.
.HH 2 "Non-interactive Processes"
.LP
The reason these are called non-interactive processes is that you
can't type any input to them; you can't interact with them; they can't
ask you questions because there is no way for you to answer.
Remember that \s-2JOVE\s0 (not the process in the window)
is listening to your keyboard,
and \s-2JOVE\s0 waits until the process dies before it looks at
what you type.
.TS
L2w(10)fR L2w(20)fI Lw(\n(Ww)fR .
^X\ !	shell-command	Run a \s-1UNIX\s0 command in a buffer.
	shell-command-no-buffer	Run a \s-1UNIX\s0 command without any buffer.
	shell-command-to-buffer	Run a \s-1UNIX\s0 command in a named buffer.
	shell-command-with-typeout	T{
Run a \s-1UNIX\s0 command sending output to the screen.
T}
.TE
.LP
To run a
.UX
command from \s-2JOVE\s0 just type ^X\ ! <command-name><return>.
For example,
to get a list of all the users on the system,
you do:
.DS I
^X\ ! who<return>
.DE
Then \s-2JOVE\s0 picks a buffer in which the output from the
command will be placed, named after the command.
E.g.,
\*Qwho\*U uses a buffer called \fBwho\fP;
\*Qps alx\*U uses \fBps\fP;
and \*Qegrep -n foo \(**.c\*U uses \fBegrep\fP.
If \s-2JOVE\s0
wants to use a buffer that already exists it first erases the old contents.
If the buffer it selects holds a file,
not output from a previous shell command,
you must first delete that buffer with ^X\ K (\fIdelete-buffer\fP).
There are variants of the command where there is no buffer, where you can
name your own buffer, and where the output is direct to the screen (see the
section on typeout at the start of this manual).
.LP
Once \s-2JOVE\s0 has picked a buffer it puts that buffer in a window so you
can see the command's output as it is running.
If there is only one window \s-2JOVE\s0 will automatically make another one.
Otherwise,
\s-2JOVE\s0
tries to pick the most convenient window other than the current one.
.LP
It is not a good idea to type anything while the command is running because
\s-2JOVE\s0 won't see the characters (and thus won't execute them) until the
command finishes,
so you may forget what you have typed.
If you really want to carry on with other editing tasks while it is
running, it is better to use the \fIi-shell-command\fP described previously.
.LP
If you want to interrupt the command for some reason (perhaps you
mistyped it, or you changed your mind) you can type ^] (or whatever else has
been put in the variable \fIinterrupt-character\fP).
Typing this
inside \s-2JOVE\s0 while a process is running is the same as typing ^C when
you are outside \s-2JOVE\s0,
namely the process is interrupted.
.LP
When the command finishes, \s-2JOVE\s0 puts you back in the window in which
you started.
Then it prints a message indicating whether or not the command
completed successfully in its (the command's) opinion.
That is,
if the command had what it considers an error
(or you interrupt it with ^])
\s-2JOVE\s0 will print an appropriate message.
.HH 3 "Applications of Non-Interactive Processes"
.LP
^X\ ! (\fIshell-command\fP) is useful for running commands that do some
output and then exit.  So you could type ^X\ ! spell <filename> and it would
create a buffer \*Qspell\*U, fill it with all the spelling mistakes in
<filename> and display it in a window.  However, as we have already seen,
there is a built-in \s-2JOVE\s0 command to do this job (and more) which,
behind the scenes, issues exactly that \fIshell-command\fP.  Thus, the built
in usage of this facility by \s-2JOVE\s0 itself is as important as any use
you might invent for yourself.
.LP
You could run a program through a compiler using \fIshell-command\fP,
but again \s-2JOVE\s0 provides a special command for the job.
This is the ^X\ ^E (\fIcompile-it\fP) command.
If you run \fIcompile-it\fP with no argument
it runs the
.UX
\fImake\fP
program into a buffer.
If you need a special command or want to pass arguments to \fImake\fP,
run \fIcompile-it\fP with any argument (^U is good enough) and you
will be prompted for the command to execute.
If any error messages are produced, they are treated specially by \s-2JOVE\s0.
That treatment is the subject of the next section.
.LP
Another useful example of using the \fIshell-command\fP would be to type
^X\ ! egrep\ -l <identifier>\ \(**.c, to give you a list of all your .c files
containing that <identifier>.
.HH 4 "Error Message Parsing"
.TS
L2w(10)fR L2w(20)fI Lw(\n(Ww)fR .
	parse-errors	Prepare to exhibit the errors listed in the buffer.
	parse-spelling-errors-in-buffer	Prepare to exhibit the listed spelling errors.
^X\ ^N	next-error	Move to the next listed error.
^X\ ^P	previous-error	Move to the previous listed error.
	current-error	Move to the current listed error.
.TE
.LP
When you have your error
messages in a buffer as produced by the \fIshell-command\fP, you run the
\fIparse-errors\fP command (this happens automatically after a
\fIcompile-it\fP).  Each line in this buffer should specify a filename and a
linenumber (\s-2JOVE\s0 knows how to interpret the error messages from many
.UX
commands; in particular from \fIcc\fP,
\fIgrep\ -n\fP and \fIlint\fP).  \fIParse-errors\fP then does a
\fIfind-file\fP on the first such filename and a \fIgoto-line\fP on its
linenumber.  When you have dealt with the error on that line (perhaps
editing lines elsewhere in your program in the process) you can type ^X\ ^N
(\fInext-error\fP) to move to the next error (perhaps in a different file).
Or you can type ^X\ ^P (\fIprevious-error\fP) or ESC\ X \fIcurrent-error\fP.
The rules \s-2JOVE\s0 uses to interpret error message in a buffer are
specified in the variable \fIerror-format-string\fP.
.LP
The action following the \s-2JOVE\s0 command \fIspell\fP is similar, except
that it calls (automatically) the command
\fIparse-spelling-errors-in-buffer\fP instead of \fIparse-errors\fP.
.LP
If you already have a file called
\fIerrs\fP containing, say, C compiler messages then you can get \s-2JOVE\s0
to interpret the messages by invoking it as:
.DS I
.I
% jove \-p errs
.R
.DE
.HH 4 "Filtering"
.TS
L2w(10)fR L2w(20)fI Lw(\n(Ww)fR .
	filter-region	T{
Pass the region through a command and replace it
with the output.
T}
.TE
.LP
Suppose your buffer contains a table.  You make this table the region (put
mark at the start of it and point at the end).  Type ESC\ X
\fIfilter-region\fP \fIsort\fP<return> (or any other
.UX
command).  Your table will be passed through the
.UX
\fIsort\fP command and be
replaced by the sorted version of itself.  The old version is placed in the
kill ring, and you can restore the status quo by obeying the \fIyank-pop\fP
command.
.HH 1 "Directory Handling"
.LP
To save having to use absolute pathnames when you want to edit a nearby file
\s-2JOVE\s0 maintains a \fIcurrent directory\fP and allows you to move
around the
.UX
filesystem just as a shell would.
.TS
L2w(10)fR L2w(20)fI Lw(\n(Ww)fR .
	cd \fRdir	Change to the specified directory.
	pushd \fR[dir]	T{
Like \fIcd\fP, but saves the old directory on the directory stack.
With no directory argument, simply exchanges the top two directories
on the stack and \fIcd\fPs to the new top.
T}
	pushlibd	T{
Does a \fIpushd\fP on the directory containing all
of \s-2JOVE\s0's standard customization files.
T}
	popd	T{
Take the current directory off the stack and restore the
previous one.
T}
	dirs	Display the contents of the directory stack.
.TE
.LP
The names and behavior of these commands were chosen to mimic those in the c-shell.
.HH 1 "Major and Minor Modes"
.HH 2 "Major Modes"
.LP
To help with editing particular types of file, say a document or a C program,
\s-2JOVE\s0 has several \fImajor modes\fP.  Each mode defines rules as to
which characters constitute a \*Qword\*U (for the purposes of
regular-expressions, language identifiers, abbreviations, and
double-clicking in
\fIxjove\fP), how indentation is to be
performed, and maybe other specialized services.
These are currently as follows:
.HH 3 "Fundamental Mode"
.LP
This is the simplest mode, with no frills, and is used when you are
operating within the message line at the bottom of the screen (hence it is
the mode of the Minibuf).
.HH 3 "Text mode"
.LP
This is the default major mode.  Nothing special is done beyond making
apostrophe (') be a word character.
.HH 3 "C mode"
.LP
In this mode, \*Q$\*U and \*Q_\*U are word characters, and there are special
facilities for indentation.
Using the \fIauto-execute-command\fP command, you can make \s-2JOVE\s0 enter
\fIC Mode\fP whenever you edit a file whose name ends in \fI.c\fP.
.HH 4 "Indentation Commands"
.LP
To save having to lay out C programs \*Qby hand\*U, \s-2JOVE\s0
has an idea of the correct indentation of a line,
based on the surrounding context.
When you are in C Mode, \s-2JOVE\s0 treats tabs specially \(em
typing a Tab at the beginning of a new line means
\*Qindent to the right place\*U
(actually, it just goes back to the line containing the nearest unmatched
\*Q{\*U, and indents 1 Tab more than that line).
The indentation will be in multiples of the variable
\fIc-indentation-increment\fP (which defaults to 8).
Closing braces are also handled specially, and are indented
to match the corresponding open brace.
.LP
If you Tab in the middle of a (\^...\^) (for example, you call a function
whose actual-parameters stretch over many lines) then you have a choice
depending on the variable \fIc-argument-indentation\fP.  If its value is \-1,
you will be aligned with the corresponding actual-parameter on the line
above.  Otherwise, \fIc-argument-indentation\fP gives the extra number of
characters by which to indent this continuation line.
.LP
If you really want a Tab to mean a single Tab on some particular occasion,
you can always precede it by a ^Q (\fIquoted-insert\fP).
.HH 4 "Parenthesis and Brace Matching"
.TS
L2w(10)fR L2w(20)fI Lw(\n(Ww)fR .
	show-match-mode	Toggle the \fIShow Match\fP minor mode.
ESC\ ^N	forward-list	Move forwards over a (\^...\^).
ESC\ ^P	backward-list	Move backwards over a (\^...\^).
ESC\ ^D	down-list	Move forward to just inside the next (\^...\^).
ESC\ ^U	backward-up-list	T{
Move backwards to the start of the enclosing (\^...\^).
T}
.TE
.LP
To check that parentheses and braces match the way you think they do, turn
on the \fIShow Match\fP minor mode (ESC\ X \fIshow-match-mode\fP).  Then,
whenever you type a close brace or parenthesis, the cursor moves momentarily
to the matching opener, if it is currently visible.  If it's not visible,
\s-2JOVE\s0 displays the line containing the matching opener on the message
line.
.LP
If your parenthesized expressions are already typed, then you may find
ESC\ ^N and ESC\ ^P useful to find a closing parenthesis to match an opening
one somewhere just after point, or a closing one to match an opening one
somewhere just before point.  Note that these commands handle all kinds of
parentheses ((\^...\^), [\^...\^] and {\^...\^}) and properly matched
internal pairs are skipped over.  These two commands take arguments and go in
the opposite direction if the argument is negative.  Likewise, the commands
ESC\ D (\fIdown-list\fP) and ESC\ U (\fIbackward-up-list\fP) may be used to
find more or less (respectively) deeply nested parentheses.
.HH 4 "C Tags"
.LP
Often when you are editing a C program,
especially someone else's code,
you see a function call and wonder what that function does.
So you have to suspend the edit,
\fIgrep\fP for the function-name in every .c file that might contain it,
and finally visit the appropriate file.
.LP
To avoid this diversion or the need to remember which
function is defined in which file,
many
.UX
systems provide a program called \fIctags(1)\fP, which
takes a set of source files and looks for function
definitions, producing a file called \fItags\fP as its output.
.TS
L2w(10)fR L2w(20)fI Lw(\n(Ww)fR .
^X\ T	find-tag	Find the file/line where the specified tag is declared.
	find-tag-at-point	Find the tag immediately following point.
.TE
.LP
\s-2JOVE\s0 has a command called ^X\ T (\fIfind-tag\fP)
that prompts you for the name of a function (a \fItag\fP), looks up
the tag reference in the previously constructed \fItags\fP file,
then performs a \fIfind-file\fP on the file containing that tag,
with point positioned at the definition of the function.
There is another version of this command, \fIfind-tag-at-point\fP,
that uses the identifier at point.
.LP
So, when you've added new functions to a module, or moved some old
ones around, run the \fIctags\fP program to regenerate the \fItags\fP file.
\s-2JOVE\s0 looks in the file specified by the variable \fItag-file\fP.  The
default is \*Q\fB.\fP\^/\^tags\*U, i.e. the tag file in the current
directory.  If you wish to use an alternate tag file you use ^U\ ^X\ T and
\s-2JOVE\s0 will prompt for a file name.
.LP
To begin an editing session looking for a particular tag, use
the \fI\-t tag\fP command line option to \s-2JOVE\s0.
For example, say you wanted to look at the file containing the tag
\fISkipChar\fP, you would invoke \s-2JOVE\s0 as:
.DS I
.I
% jove \-t SkipChar
.R
.DE
.HH 3 "Lisp mode"
.LP
In this mode, any of the characters
\*Q!\^$\^%\^&\^\(**\^+\^\-\^/\^:\^<\^=\^>\^?\^^\^_\^{\^|\^}\^\s+2~\s0\*U and
Delete are word characters (in other words, \*Qwords\*U are Lisp atoms).
The mode is analogous to \fIC Mode\fP,
but performs the indentation needed to lay out Lisp programs properly.
.HH 4 "Parenthesis Matching"
.LP
In addition to the parenthesis matching commands available under C mode, we
have:
.TS
L2w(10)fR L2w(20)fI Lw(\n(Ww)fR .
ESC\ ^F	forward-s-expression	Move backward over an atom or list.
ESC\ ^B	backward-s-expression	Move forward over an atom or a list.
	grind-s-expression	Re-indent an s-expression.
ESC\ ^K	kill-s-expression	Kill from point to the end of an s-expression.
.TE
.LP
In fact the first two of these commands work in other modes also, but for
\*Qatom\*Q read \*Qidentifier\*U.
.HH 2 "Minor Modes"
.LP
In addition to the major modes,
\s-2JOVE\s0 has a set of minor modes whose state is controlled by the
following commands:
.TS
L2w(10)fR L2w(20)fI Lw(\n(Ww)fR .
	auto-indent-mode
	auto-fill-mode
	over-write-mode
	read-only-mode
	show-match-mode
	word-abbrev-mode	
.TE
.LP
With no argument, these commands toggle the mode.  With a zero argument they
turn it \fIoff\fP, and with any other argument they turn it \fIon\fP.
.HH 3 "Auto Indent"
.LP
In this mode,
\s-2JOVE\s0 indents each line the same way as that above it.  That is,
the Return key in this mode acts as the Linefeed key ordinarily does.
This mode is only likely to be useful if you are afflicted with a keyboard
without a Linefeed key.
.HH 3 "Auto Fill"
.LP
In \fIAuto Fill\fP mode,
a newline is automatically inserted when the line length
exceeds the right margin.
This way,
you can type a whole paragraph without having to use the Return key.
.HH 3 "Over Write"
.LP
In this mode,
any text typed in will replace the previous contents
(the default is for new text to be inserted and \*Qpush\*U the old along).
This is useful for editing an already-formatted diagram in which you
want to change some things without moving other things around on the
screen.
.HH 3 "Read Only"
.LP
In this mode, modifying the buffer is inhibited.  This mode is set
automatically on any attempt to read a file for which you do not have write
permission.
.HH 3 "Show Match"
.LP
Move the cursor momentarily to the matching opening parenthesis when a closing
parenthesis is typed.
.HH 3 "Word Abbrev"
.LP
In this mode, every word you type is compared to a list of word
abbreviations; whenever you type an abbreviation, it is replaced
by the text that it abbreviates.
This can save typing if a particular word or phrase must be entered
many times.  For example, your programming language might have reserved words
that you customarily type in upper case (identifiers etc. being in lower
case).  So you might define B as an abbreviation for BEGIN, E for END, P for
PROCEDURE, and so on.
.TS
L2w(10)fR L2w(20)fI Lw(\n(Ww)fR .
	define-global-word-abbrev	Define a new global abbreviation.
	define-word-abbrev	T{
Define a new abbreviation within the current major mode.
T}
	edit-word-abbrev	Edit the list of abbreviations.
	write-word-abbrev-file	Write the list of abbreviations to a file.
	read-word-abbrev-file	Read a list of abbreviations from a file.
.TE
.LP
The abbreviations and their expansions are held in a list that looks like:
.DS I
abbrev:phrase
.DE
for example
.DS
jove:jonathan's own version of EMACS
.DE
Use \fIdefine-global-word-abbrev\fP to add an entry that is to be effective in
all buffers and \fIdefine-word-abbrev\fP for an entry that is to be
effective only in buffers of the same major mode as the selected buffer.  Use
\fIedit-word-abbrev\fP to edit the list (it enters a recursive edit on a
buffer containing the list \(em use ^X\ ^C (\fIexit jove\fP) when you are
finished).  Use \fIwrite-word-abbrev-file\fP to write the list to a file and
\fIread-word-abbrev-file\fP to read it back again (this command might be
used in your \fB.joverc\fP file) .
.LP
If the variable \fIauto-case-abbrev\fP is \fIon\fP, and the abbreviations in the
list are all in lower case (as in the \*Qjove\*U example above) then,
whenever you type \*Qjove\*U you will get
.DS
jonathan's own version of EMACS
.DE
but if you type \*QJove\*U you will get
.DS
Jonathan's own version of EMACS
.DE
and if you type \*QJOVE\*U (with at least 2 upper case letters) you will get
.DS
Jonathan's Own Version Of EMACS
.DE
.LP
On the other hand, if the variable \fIauto-case-abbrev\fP is \fIoff\fP (as it
should be for the reserved word example) the case of the abbreviation is
significant and must be matched exactly.
.HH 1 "Macros"
.TS
L2w(10)fR L2w(20)fI Lw(\n(Ww)fR .
^X\ (	begin-kbd-macro	Start recording your commands.
^X\ )	end-kbd-macro	Stop recording your commands.
ESC\ I	make-macro-interactive	Call for a parameter to be typed at this point.
^X\ E	execute-kbd-macro	Replay the recording.
	name-kbd-macro	Name the recording.
	define-macro	Define a named macro.
	execute-macro	Execute a named macro.
	write-macros-to-file	Write all named macros to a file.
	bind-macro-to-key	Bind named macro to a key-sequence.
	bind-macro-to-word-abbrev	Bind named macro to an abbrev.
.TE
.LP
Although \s-2JOVE\s0 has many powerful commands,
you often find that you have a task that no individual command can do.
\s-2JOVE\s0 allows you to define your own commands from sequences
of existing ones.  The easiest way to do this is \*Qby example\*U.
.HH 2 "Keyboard Macros"
.LP
First you type ^X\ ( (\fIbegin-kbd-macro\fP).
Next you \*Qperform\*U the commands which will constitute the body of the
macro (they are executed as well as being remembered).
Then you type ^X\ ) (\fIend-kbd-macro\fP).
You now have a \fIkeyboard macro\fP.
.LP
To run this command sequence again,
type ^X\ E (\fIexecute-keyboard-macro\fP).
.LP
If your macro needs a parameter (a filename to be opened, perhaps), include
the command needing the parameter (e.g. ^X\ ^F) at the appropriate place in
the macro followed immediately by ESC\ I (\fImake-macro-interactive\fP).
When the macro is executed, you will be given an opportunity to type in the
actual-parameter at this point.
.HH 2 "Named Macros"
.LP
You may give the keyboard macro a name using the
\fIname-keyboard-macro\fP command (or you may create a named macro from
scratch using the \fIdefine-macro\fP command).
We're still not finished because all this hard work will be lost
if you leave \s-2JOVE\s0.
What you do next is to save your macros into a file
with the \fIwrite-macros-to-file\fP command.
To retrieve your macros in the next editing session,
you can simply execute the \fIsource\fP command on that file, or include
that file in your personal \fB.joverc\fP file.
.LP
A named macro can be executed by typing ESC\ X \fIexecute-macro\fP
<macro-name><return>.  It is unfortunate that macro names are kept in a
different name space than command names, so that you cannot type ESC\ X
<macro-name>.  This may well be changed in a future release.
.HH 2 Binding Macros to Keys
.LP
Finally, if you find all this bothersome to type and re-type,
there is a way to bind the macro to a key.
The binding is made with the \fIbind-macro-to-key\fP command, or
alternatively the \fIbind-macro-to-word-abbrev\fP command (in which case the
macro will be executed upon typing the abbrev word you have specified \(em
it will get expanded as well unless it was an abbreviation for nothing).
.HH 1 "Customizing Jove"
.HH 2 "The jove.rc and .joverc files"
.LP
\s-2JOVE\s0 is aware of a directory, the \fIsharedir\fP, in which
system-wide customization files are kept.  Chief amongst these is the file
\fBjove.rc\fP which is read each time \s-2JOVE\s0 is started up
(\fBjove.rc\fP may then initiate the reading of other files in the sharedir,
such as initialization files for specific terminals).  After that,
\s-2JOVE\s0 reads your personal \fB.joverc\fP in your $HOME directory, if
you have one.  And if all that is not enough, you may at any time read other
customization files using the \fIsource\fP command.
.LP
The \s-2JOVE\s0 distribution comes with a recommended \fBjove.rc\fP file
together with specific \fBjove.rc.TERM\fP files for various terminals.  It is
up to system administrators to decide whether to use these as they stand or
to modify them to accord with local conventions.  Note that these files are
well commented and worthy of study by those who decide to \*Qroll their
own\*U.
.LP
There are command-line options that can be used when \s-2JOVE\s0 is started
to substitute a different \fIsharedir\fP or to suppress reading of the
\fBjove.rc\fP or \fB.joverc\fP files or both \(em see the Man page for
\s-2JOVE\s0.  Thus everything is ultimately under the control of the
individual \s-2JOVE\s0 user.
.HH 2 "The source Command"
.LP
Type ESC\ X \fIsource\fP <filename><return> to read and obey the commands in
<filename>.  If a numeric argument is supplied to \fIsource\fP, it will
silently ignore a request for a non-existent file (otherwise an error
message will be produced).  The format of the \fIsource\fPd file, as of the
\fBjove.rc\fP and \fB.joverc\fP files, is as follows.
.LP
Each line consists of a command name (no need to precede it with ESC\ X)
followed by whatever parameters that command requires.  To give a numeric
argument to the command, simply precede the command name by a number.  Thus
it is possible to to do anything that the user could do while \s-2JOVE\s0 is
running.
.LP
.KS
But there is more than this.  You can say
.RS
\fIif\fP <shell-command>
.RS
<command>
.br
<command>
.RE
\fIelse\fP
.RS
<command>
.br
<command>
.RE
\fIendif\fP
.RE
.KE
The <shell-command> is run, and if it succeeds the first lot of <command>s
is obeyed, and otherwise the second lot (the \fIelse\fP part is optional).
Another variant of this feature allows you to say, in place of \fIif\fP
<shell-command>,
\fIifenv\fP <environment-variable> <pattern>, which succeeds if
<environment-variable> exists and if its value matches <pattern>.  These
conditional commands can be nested in the usual way; also indentation and
empty lines have no effect.  Finally, you can include comments on any line
that starts with a \*Q#\*U.
.LP
Here are some examples taken from the provided \fBjove.rc\fP.
.KS
.RS
pushlibd
.sp .5n
# This is for the shell window.  Supports sh, csh and ksh.
.br
set process-prompt ^[\^^%$#]\(**[%$#] 
.sp .5n
# Modern terminals do not need ^S/\^^Q for flow control.
.br
# The exceptions (e.g. vt100) should turn it off again in jove.rc.TERM.
.br
set allow-^S-and-^Q on
.sp .5n
# source any TERMinal-specific rc file
.br
1 source jove.rc.$TERM
.sp .5n
popd
.RE
.KE
.LP
The \fIpushlibd\fP ensures that any files it tries to read will be taken
from the \fIsharedir\fP (observe the matching \fIpopd\fP at the end).  Then
follow some settings of variables such as
\fIprocess-prompt\fP (see the discussion of interactive processes earlier in
this manual).  Observe how environment variables such as $TERM are honored
within parameters, and note how that \fIsource\fP command was given a
numeric argument so that there would be no complaint if the file
\fBjove.rc.$TERM\fP did not exist.
.LP
On the other hand, if \fBjove.rc.$TERM\fP does exist for the particular
terminal specified in $TERM, that file will now be \fIsource\fPd.  It will
likely set many key bindings particular to that terminal, and then say
.KS
.RS
define-macro keychart ^[xpushlibd\^^M
.RS
^U\^^[Xshell-command-with-typeout cat keychart.$TERM\^^M
.br
^[Xpopd\^^M
.RE
# except that should really have been all on one line
.br
bind-macro-to-key keychart ^[\^[\^\s+2~\s0
.RE
.KE
.LP
Quite some mouthful! What it does is to define a macro \fIkeychart\fP (the
hard way) and bind it to ESC\ [\ \s+2~\s0.  In general, any terminal for
which extensive key bindings are provided ought to define this macro and
bind it to a suitable key (preferably the one inscribed \*QHelp\*U).  When
this key is pressed, it will cause the file \fBkeychart.$TERM\fP to be
displayed on the screen in \fItypeout\fP style.  This file should exhibit a
map of the terminal's keyboard, showing what has been bound to each key.  The
\fIsharedir\fP contains several such keychart files.
.LP
Although Control characters may be stored as themselves in these files (as
produced by the \fIquoted-insert\fP command, for example), it is better to
store them using an explicit \*Q\^^\^\*U (e.g. as ^C), since this form is
accepted by the \fIsource\fP command, and editing files in this form is much
easier.
.HH 2 "Key Re-binding"
.LP
Many of the commands built into \s-2JOVE\s0 are not bound to
specific keys.  You must type ESC\ X <command-name>
(\fIexecute-named-command\fP) in order to invoke these commands.
Also, many of the keys to which commands \fIare\fP bound are hard to
remember (although at least compatible across all terminals) whilst all sorts
of interesting keys on the particular keyboard remain unused.  For both these
reasons, \s-2JOVE\s0 makes it possible to \fIbind\fP commands to keys.
.TS
L2w(10)fR L2w(20)fI Lw(\n(Ww)fR .
	bind-to-key	Bind a command to a key-sequence.
	bind-macro-to-key	Bind a named macro to a key-sequence.
	bind-macro-to-word-abbrev	Bind a named macro to an abbrev.
	bind-keymap-to-key	Bind an extra key-sequence to a keymap.
	describe-bindings	Exhibit all key bindings as a screen typeout.

	local-bind-to-key	T{
As bind-to-key, for use in the selected buffer only.
T}
	local-bind-macro-to-key	T{
As bind-macro-to-key, for use in the selected buffer only.
T}
	local-bind-keymap-to-key	T{
As bind-keymap-to-key, for use in the selected buffer only.
T}

	process-bind-to-key	T{
Bind interactive process command to a key-sequence.
T}
	process-bind-macro-to-key	T{
Bind a macro within interactive processes only.
T}
	process-bind-keymap-to-key	T{
Bind a keymap within interactive processes only.
T}
.TE
.LP
Although these commands can be typed in by the user, they are mostly
intended for use in \fIsource\fPd files.  Here are some more examples from
\fBjove.rc\fP.
.KS
.RS
# if you have job control, this puts Jove out of the way temporarily.
.br
bind-to-key pause-jove ^[S
.br
bind-to-key pause-jove ^[s
.sp .5n
# The following apply to shell windows.  Note the use of ^C\^^C, ^C\^^D etc.,
.br
process-bind-to-key interrupt-process ^C\^^C
.br
process-bind-to-key eof-process ^C\^^D
.sp .5n
# This makes the arrow keys work on most terminals.
.br
bind-to-key previous-line ^[[A
.br
bind-to-key next-line ^[[B
.RE
.KE
.LP
When a command is
\fIbound\fP to a key any future hits on that key will invoke that command.
All the printing characters are initially bound to the
command \fIself-insert\fP.
Thus, typing any printing character causes it to be inserted into the text.
To unbind a key, simply bind it to the fictitious command \fIunbound\fP.
.LP
Observe how key-sequences are often derived from common prefixes, such as
^X\ ..., ESC\ ... (to be typed as ^[\ ... in binding commands) and
ESC\ [\ ... (or ^[\ [\ ...).  Internally, \s-2JOVE\s0 creates tables for each
prefix encountered, but it cannot create a new prefix from a manually
entered \fIbind-\fP command (it does not know when you have finished your
binding).  To overcome this, give the \fIbind-\fP command an argument and
terminate it with a Return (this applies automatically within \fIsource\fPd
files).
Obviously, you must not have two bindings where one is a prefix of the other.
.LP
Very rarely, you may want two prefixes to be regarded as equivalent for all
commands (for example, you have a keyboard with no ESC key, and it would be
tedious to have to rebind every command in the system with a different
prefix).  In this case, you can type ESC\ X \fIbind-keymap-to-key\fP
<named-keymap> <prefix-key-sequence>.  The only recognized <named-keymap>s
are \*QESC-map\*U and \*QCtlx-map\*U, and the customary replacement for ESC
is \*Q`\*U.
.LP
For historical reasons, the Escape key is often referred to as \*QMeta\*U.
Indeed, if your terminal has a Meta-key which forces the 8th-bit of a
character, and if the variable \fImeta-key\fP is \fIon\fP, you may type Y whilst
holding the Meta-key down to achieve the same effect as when typing ESC\ Y.
.HH 3 "The Provided Terminal Bindings"
.LP
The terminals for which keybindings have been provided are a mixed bunch (we
would welcome suggestions for other common terminals).  However, there are
certain principles which were followed in setting them up.
.IP 1.
Groupings of keys that are found in bindings for other terminals
were adhered to so far as possible.  Rather than saying that the F1 key
always does so-and-so, groupings of Function Keys that are physically
associated on the keyboard were mapped onto similar groupings on other
keyboards, even though the engravings on them might be quite different.
.IP 2
Keys which do related things should be close together.
.IP 3
Keys which customarily do certain things under other editors normally
used with that keyboard should do the same (or similar) things under
\s-2JOVE\s0.
.IP 4
Keys which have suggestive engravings on them should do what the
engravings suggest.  Sometimes, this necessitated the creation of a macro
where no \s-2JOVE\s0 command existed to do precisely that job (for example,
the macro \fIkill-line\fP).
.HH 2 "Auto-execution of Commands"
.LP
It is useful, when a file is recognized as being in a particular programming
language, for the appropriate major mode and other relevant facilities to be
set up automatically in any buffer into which such a file is read.
.TS
L2w(10)fR L2w(20)fI Lw(\n(Ww)fR .
	auto-execute-command	T{
Obey the given command for each filename matched by the given
regular-expression.
T}
	auto-execute-macro	Obey the given macro likewise.
.TE
.LP
Here is an example taken from \fBjove.rc\fP.
.KS
.RS
# set various language modes.
.br
1 auto-execute-command c-mode .\(**\.[chy]$
.br
1 auto-execute-command lisp-mode .\(**\.l$\|.\(**\.lisp$\|.\(**\.scm$
.br
# all the languages need show-match-mode.
.br
1 auto-execute-command show-match-mode .\(**\.[lchyfp]$\|.\(**\.lisp$\|.\(**\.scm$
.RE
.KE
.LP
The effect of this is that whenever a filename matches the
regular-expression \*Q.\(**\.[chy]$\*U the command \fIc-mode\fP is obeyed in
the buffer into which the file is being read, and similarly for
\fIlisp-mode\fP.  An attempt is then made to set \fIshow-match-mode\fP for
both C and Lisp programs.  Observe that all the \fIauto-execute-command\fPs
in this example have an argument of 1.  This argument is passed on to the
obeyed command so that, for example, it is ensured that \fIc-mode\fP is
definitely set to be \fIon\fP, rather than merely being toggled.
.HH 2 "Customizing the Mode Line"
.LP
The format of the mode line is controlled by the variable \fImode-line\fP.
Here is a suggested setting.
.RS
set mode-line %[Jove%]%w%w%c(%M)%3c[%b:%n]%2c"%f"%2c%m\(**-%m\(**-%2c%p%2s%(%d%e(%t)%)
.RE
.LP
and here is what it all means.
.IP %[\^...\^%] 12n
Puts brackets around Jove when in a recursive edit.
.IP %w%w
Warns with >> if the window is scrolled left.
.IP (%M)
Gives the current major and minor modes.
.IP [%b:%n]
Shows the buffer name and number.
.IP """%f"""
Shows the filename.
.IP %m\(**\-%m\(**\-
Displays \(**\(** if the buffer is modified, \-\- if not.
.IP %p
In process windows only, shows the status of the process.
.IP %d
Shows the current directory.
.IP (%t)
Shows the time of day.
.LP
Everything else is layout.  See the full description of the \fImode-line\fP
variable for further details.
.HH 1 "Xjove and Xterm"
.LP
If you run \s-2JOVE\s0 on a workstation equipped with the X-Windows system
from M.I.T., then it is advised to run \s-2JOVE\s0 under one of the terminal
emulators \fIxjove\fP or \fIxterm\fP.  \fIXterm\fP is provided as a standard
part of the X-Windows system, but the facilities provided are a small subset
of those available with \fIxjove\fP, which was written especially to support
\s-2JOVE\s0.  However, \fIxjove\fP suffers from the disadvantage that it must
be compiled under the XView Toolkit which, although available free from
M.I.T., may not be available on your system.  Note that, in either case,
special keybindings must be provided (see the files \fBjove.rc.sun-cmd\fP and
\fBjove.rc.xterm\fP).  See the Man page for \fIxjove\fP for how to call it
and the flags and options available.
.HH 2 "Basic Mouse Operations"
.LP
When running under \fIxjove\fP or \fIxterm\fP you may click the LEFT
mouse button in order to set the position of point, and the MIDDLE mouse
button to set the position of point and mark.  If you hold the MIDDLE button
down, you may sweep it along, leaving mark where you started and point where
you finished, thus defining the region.  If you hold the Control key down
while you are doing this, the region is copied to the kill ring, as with the
\fIcopy-region\fP command, and if you hold both the Control and Shift keys
down, the region is killed (and sent to the kill ring) as with the
\fIkill-region\fP command.  To have the killed text yanked at some other
point, click the LEFT mouse button there, holding the Control key down at
the same time.
.LP
To switch to a different window, simply click either button in the window
you want to be in (note that this does not affect point or mark in that
window \(em it takes two clicks to change windows and then change point).
.LP
To scroll rapidly to a different part of the buffer, simply click either
mouse button in the mode line at a position corresponding to the percentage
way down the file you want to be.  It helps to have set the variable
\fIscroll-bar\fP \fIon\fP so that you can see by the uninverted part of the
mode line which part of the buffer is currently visible in the window.  When
you have finished, the mouse pointer should be exactly in the middle of the
uninverted region.
.HH 2 "Additional Xjove Features"
.LP
When running under \fIxjove\fP there are some additional facilities.
Firstly, the setting when pointing into the mode line is more sensitive,
because it notes the mouse position to the nearest pixel instead of the
nearest character, and it is possible to hold the mouse button down and
watch the window scrolling as you drag it (although this can consume
considerable machine resources and it may have difficulty in keeping up).  Also,
it is possible to follow the position of point in real time as you drag the
mouse around when delineating a region.
.LP
If you do a double click with the MIDDLE button in \fIxjove\fP, it will set
the region spanning the word you were over (or spanning the gap if you were
between words).  Note that the definition of \*Qword\*U here follows the
major mode.  If you do a triple click, it will likewise select the whole
line.  These operations may be combined with the Control key, or the Control
and Shift keys together, to obtain copying and killing as before.
.LP
If your keyboard has keys marked Paste and Cut, it
is possible to bring text from another part of the buffer (even from a
different window) without changing the position of point (this is useful if
you are constructing text at some point, bringing in fragments from other
places \(em you would prefer not to have to keep moving point to those other
places to acquire some text for the kill ring, only to have to move it back
again before yanking).  To do this, with point where you want the text to be
inserted, you hold the Paste key down while you select a region with the
MIDDLE button (multi-clicking or dragging as usual).  When you have finished,
a copy of the region you selected will appear at point, with point moved
beyond it (since it went via the kill ring, this text is also available for
conventional yanking subsequently).  If you change your mind in mid
stream, let go of Paste before releasing MIDDLE.  Likewise, if you do the
same thing holding the Cut key down, the text will also be killed from its
original position.
.LP
Finally, if you press the RIGHT mouse button, you will be offered a menu
which enables you to issue any \s-2JOVE\s0 command or set any \s-2JOVE\s0
variable.  Particularly useful if you need some obscure and rarely used
command, and cannot remember exactly what it is called.
.HH 1 "Recovering from system/editor crashes"
.LP
\s-2JOVE\s0 does not have an \fIAuto Save\fP mode, but it does provide a way
to recover your work in the event of a system or editor crash.  \s-2JOVE\s0
saves information about the files you are editing every \fIsync-frequency\fP
changes to a special buffer, so as to make recovery possible.  Since a
relatively small amount of information is involved it is hardly even
noticeable when
\s-2JOVE\s0 does this.  The variable \fIsync-frequency\fP says how often to
save the necessary information, and the default is every 50 changes.  50 is
a very reasonable number: if you are writing a paper you will not lose more
than the last 50 characters you typed, which is less than the average length
of a line.
.LP
If \s-2JOVE\s0, or the operating system, crashes, you may now use the
\s-2JOVE\s0 \fIrecover\fP program to get back your files.  You invoke this by
running \s-2JOVE\s0 with the -r flag.  See the Man page for \s-2JOVE\s0 for
further details.
.LP
Another worthwhile precaution you can take is to set the variable
\fImake-backup-files\fP \fIon\fP.  Then, whenever you save a file with
\fIsave-file\fP it will leave behind the original version of that file with
the name \*Q#\fIfilename\fP\s+2~\s0\*U.
.bp
.HH 1 "Alphabetical List of Commands and Variables"
.LP
In this chapter, the standard binding is shown for each command which has
one.  Generally, these are the built-in bindings, but occasionally they are
ones taken from the provided \fBjove.rc\fP file.
