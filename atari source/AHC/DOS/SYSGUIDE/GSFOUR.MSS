@part(gsfour.mss,root='sysroot.mss')
@chapter(Critical Error Handlers and their Invocation)
@label(criter)

@section(Critical Error Handlers)
When a disk I/O critical error occurs, the BIOS calls the current critical
error handler, which is installed via extended vector 0x101.  The critical 
error handler is a routine of the form:
@begin(format)
@tabclear
@tabset(3pica)
@\LONG critter( error, drive );
@\WORD error, drive;
@\{
@\}
@end(format)
@index(0x101)
@index(Critical error handler)
@index(GEMERROR.H)
@index(drive)
@index(error)
@index(Retry option)
@index(Ignore option)
@index(Accept option)
@index(Abort operation)

The 'error' parameter is an error number of type WORD on the stack 
corresponding to the error number definitions in GEMERROR.H.  The 
'drive' parameter is the same 0-based drive number that was passed to 
the BIOS function that caused the error (0=A:, 1=B:, etc.).

The critical error handler uses the error and drive information to give the
user (or application) the option of either retrying, ignoring, or accepting
the error.  The chosen option is indicated to the BIOS by:
@blankspace(2)
@begin(format)
@tabclear
@tabset(2pica,6pica)
@\@b(retry)@\Return 0x10000 in D0.L

@\@b(ignore)@\Return 0 in D0.L

@\@b(accept)@\Return the sign-extended error number in D0.L
@end(format)
@blankspace(2)
To "accept" the error means that the error code is ultimately returned to the 
application, which usually aborts the operation.

It is the responsibility of the critical error handler that installs itself 
to save registers d3-d7/a3-a7 if they are used and restore them before it 
exits. 

@newpage
If the target system is intended to support character-based (non GEM)
applications, the BIOS should be written so that the console I/O portion 
is re-entrant from the critical error handler to enable user prompting.

@section(Process Termination Handler)

When a process executes a P_Term0(), a P_Term(), or has a process termination 
forced upon it (for example, by receiving a Ctrl-C during normal character 
console I/O), the current process termination handler is invoked.  It 
determines whether to allow the process to terminate or not by doing one of 
the following:
@index(Process termination)
@index(longjump)
@index(setjump)
@index(Ctrl-C)
@index(RTS)
@index(P_Term)
@index(Terminate process)

@begin(format)
By simply returning, the process will terminate normally.

The handler can 'longjump()' back into the main portion of the application 
if a corresponding 'setjump()' has been set up before hand.

The handler can force a Ctrl-C to be ignored by executing the following 
assembly language instructions:

@verbatim(
	unlk    A6      * Note that there is no 
	rts             * corresponding 'link' 
			* instruction at the 
			* beginning of the routine.
)

This first discards one routine invocation stack frame and then returns
to the previous caller, thereby bypassing the Ctrl-C's call of the process 
termination handler.
@end(format)

It is the responsibility of the handler to determine whether it should allow 
the process termination to continue.  To terminate, execute an RTS 
instruction. Otherwise "longjump" back into the main code of the process.    



@eos()
