
This is LogSTinG, a tool for logging all STinG calls into a file, or 
a pipe, the latter only if MiNT or MagiC > 3.0 is used.

LogSTinG may be started at any time _after_ STinG has completed all 
initialization. Thus generally it must be started from the desktop, 
which is not bad because it is not intended to be there permanently.
Use the control program LOGCTRL.PRG to remove LogSTinG again. Note that 
programs that install and use their own copy of the STinG TPL structure, 
must be terminated before LogSTinG is removed via LogCTRL, if they have 
been started while LogSTinG was active. If this is violated, then any 
action carried out by that unterminated program will eventually result 
in a system crash. I can't do anything about that. Using an own copy 
of the TPL is not the general behaviour of STinG clients, though, so 
normally you don't have to worry about this.

LogSTinG recognizes if it is started while another copy is active, and 
denies installation then. Similarly LogCTRL can't be started without 
having LogSTinG started first.

Once started, LogSTinG logs all STinG calls along with parameters and 
return values into the file STING.LOG which is in the same directory 
LogSTinG has been started from. The file may be deleted or renamed 
during operation, LogSTinG will immediately create a new one. Use 
LogCTRL to change this default file, or whether at all parameters 
should be logged, etc. You can also tell LogSTinG to only log selected 
STinG calls.

Note that a LogSTinG log contains STinG traffic data to and from your 
site ! This is true for confidential e-mail as well as passwords, that 
are carried via TCP, for instance. The password for your ISP account 
is safe, however, because it is only handled by the Dialer, which does 
not use STinG to send the password. Be very careful, when giving log 
files away ! Cut away confidential data !

For each STinG call the log file is opened and closed a couple of times,
if you configured it to not use the internal cache. With an efficient 
write cache system (MagiC with WBDAEMON for instance) this is noticable,
but tolerable. With single-TOS on the other hand this will slow down
the system a lot. The internal cache cures this, with MagiC there is no
slowdown at all anymore, and even single-TOS remains well usable (the 
data should not be logged to a floppy disk of course). The drawback of
this is that it cannot be used to investigate a system crash, as then
data in the cache (which will be the most interesting) will be lost.
Switch off the caching in that case.


Any ideas, comments, flames and letterbombs to

Peter Rottengatter
perot@pallas.amp.uni-hannover.de
