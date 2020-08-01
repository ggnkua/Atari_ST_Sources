MODULE MiNT;

CONST
  SIGNULL* = 0; SIGHUP* = 1; SIGINT* = 2; SIGQUIT* = 3; SIGILL* = 4;
  SIGTRAP* = 5; SIGABRT* = 6; SIGPRIV* = 7; SIGFPE* = 8; SIGKILL* = 9;
  SIGBUS* = 10; SIGSEGV* = 11; SIGSYS* = 12; SIGPIPE* = 13; SIGALRM* = 14;
  SIGTERM* = 15; SIGURG* = 16; SIGSTOP* = 17; SIGTSTP* = 18; SIGCONT* = 19;
  SIGCHLD* = 20; SIGTTIN* = 21; SIGTTOU* = 22; SIGIO* = 23; SIGXCPU* = 24;
  SIGXFSZ* = 25; SIGVTALRM* = 26; SIGPROF* = 27; SIGWINCH* = 28;
  SIGUSR1* = 29; SIGUSR2* = 30;
  SIGDFL* = 0; SIGIGN* = 1;
  NOCLDSTOP* = 1; 
  
TYPE
  sigaction = RECORD 
                Handler : LONGINT;
                Mask    : SET;
                Flags   : INTEGER;
              END;
              
PROCEDURE- Syield*() 0FFH,1;

PROCEDURE- Fpipe*(VAR ptr : INTEGER) : INTEGER 100H,1;

PROCEDURE- Fcntl*(cmd : INTEGER; arg : LONGINT; f : INTEGER) : LONGINT 104H,1;

PROCEDURE- Finstat*(f : INTEGER) : LONGINT 105H,1;

PROCEDURE- Foutstat*(f : INTEGER) : LONGINT 106H,1;

PROCEDURE- Fgetchar*(mode,f : INTEGER) : LONGINT 107H,1;

PROCEDURE- Fputchar*(mode : INTEGER; c : LONGINT; f : INTEGER) : LONGINT 108H,1;

PROCEDURE- Pwait*() : LONGINT 109H,1;

PROCEDURE- Pnice*(delta : INTEGER) : INTEGER 10AH,1;

PROCEDURE- Pgetpid*() : INTEGER 10BH,1;

PROCEDURE- Pgetppid*() : INTEGER 10CH,1;

PROCEDURE- Pgetpgrp*() : INTEGER 10DH,1;

PROCEDURE- Psetpgrp*(pid,newgrp : INTEGER) : INTEGER 10EH,1;

PROCEDURE- Pgetuid*() : INTEGER 10FH,1;

PROCEDURE- Psetuid*(id : INTEGER) : INTEGER 110H,1;

PROCEDURE- Pkill*(sig,pid : INTEGER) : INTEGER 111H,1;

PROCEDURE- Psignal*(handler : LONGINT; sig : INTEGER) : LONGINT 112H,1;

PROCEDURE- Pvfork*() : INTEGER 113H,1;

PROCEDURE- Pgetgid*() : INTEGER 114H,1;

PROCEDURE- Psetgid*(id: INTEGER) : INTEGER 115H,1;

PROCEDURE- Psigblock*(mask: SET) : LONGINT 116H,1;

PROCEDURE- Psigsetmask*(mask: SET) : LONGINT 117H,1;

PROCEDURE- Pusrval*(arg: LONGINT) : LONGINT 118H,1;

PROCEDURE- Pdomain*(newdom: INTEGER) : INTEGER 119H,1;

PROCEDURE- Psigreturn*() 11AH,1;

PROCEDURE- Pfork*() : INTEGER 11BH,1;

PROCEDURE- Pwait3*(VAR rusage: LONGINT; flag : INTEGER) : LONGINT 11CH,1;

PROCEDURE- Fselect*(VAR xfds,wfds,rfds : LONGINT; timeout : INTEGER) : INTEGER 11DH,1;

PROCEDURE- Prusage*(r : LONGINT) 11EH,1;

PROCEDURE- Psetlimit*(value: LONGINT; lim : INTEGER) : LONGINT 11FH,1;

PROCEDURE- Talarm*(secs : LONGINT) : LONGINT 120H,1;

PROCEDURE- Pause*() 121H,1;

PROCEDURE- Sysconf*(n : INTEGER) : LONGINT 122H,1;

PROCEDURE- Psigpending*() : LONGINT 123H,1;

PROCEDURE- Dpathconf*(n : INTEGER; name : LONGINT) : LONGINT 124H,1;

PROCEDURE- Pmsg*(msg,mbox : LONGINT; mode : INTEGER) : LONGINT 125H,1;

PROCEDURE- Fmidipipe*(out,in,pid : INTEGER) : LONGINT 126H,1;

PROCEDURE- Prenice*(delta,pid : INTEGER) : INTEGER 127H,1;

PROCEDURE- Dopendir*(flag : INTEGER; name : LONGINT) : LONGINT 128H,1;

PROCEDURE- Dreaddir*(buf,dir : LONGINT; buflen : INTEGER) : LONGINT 129H,1;

PROCEDURE- Drewinddir*(dir : LONGINT) : LONGINT 12AH,1;

PROCEDURE- Dclosedir*(dir : LONGINT) : LONGINT 12BH,1;

PROCEDURE- Fxattr*(buf,name : LONGINT; flag : INTEGER) : LONGINT 12CH,1;

PROCEDURE- Flink*(newname,oldname : LONGINT) : LONGINT 12DH,1;

PROCEDURE- Fsymlink*(newname,oldname : LONGINT) : LONGINT 12EH,1;

PROCEDURE- Freadlink*(name,buf : LONGINT; siz : INTEGER) : LONGINT 12FH,1;

PROCEDURE- Dcntl*(arg,name : LONGINT; cmd : INTEGER) : LONGINT 130H,1;

PROCEDURE- Fchown*(gid,uid : INTEGER; name : LONGINT) : LONGINT 131H,1;

PROCEDURE- Fchmod*(mode : INTEGER; name : LONGINT) : LONGINT 132H,1;

PROCEDURE- Pumask*(mask : INTEGER) : INTEGER 133H,1;

PROCEDURE- Psemaphore*(timeout,id : LONGINT; mode : INTEGER) : LONGINT 134H,1;

PROCEDURE- Dlock*(drive,mode : INTEGER) : INTEGER 135H,1;

PROCEDURE- Psigpause*(sigmask : SET) 136H,1;

PROCEDURE- Psigaction*(oact,act : LONGINT; sig : INTEGER) : LONGINT 137H,1;

PROCEDURE- Pgeteuid*() : LONGINT 138H,1;

PROCEDURE- Pgetegid*() : LONGINT 139H,1;

PROCEDURE- Pwaitpid*(rusage : LONGINT; flag,pid : INTEGER) 13AH,1;

PROCEDURE- Dgetcwd*(size,drv : INTEGER; path : LONGINT) 13BH,1;

PROCEDURE- Salert*(msg : LONGINT) 13CH,1;

END MiNT.