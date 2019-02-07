IMPLEMENTATION MODULE POSIX1;
__IMP_SWITCHES__
#ifdef HM2
#ifdef __LONG_WHOLE__
(*$!i+: Modul muss mit $i- uebersetzt werden! *)
(*$!w+: Modul muss mit $w- uebersetzt werden! *)
#else
(*$!i-: Modul muss mit $i+ uebersetzt werden! *)
(*$!w-: Modul muss mit $w+ uebersetzt werden! *)
#endif
#endif
#if ISO_proc_const
(*empty*)
#else

IMPORT loc,tim,file,dir,proc,sys,term,sig,jump;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

BEGIN (* POSIX1 *)
  tzset       := tim.tzset;
  localtime   := tim.localtime;
  gmtime      := tim.gmtime;
  asctime     := tim.asctime;
  ctime       := tim.ctime;
  mktime      := tim.mktime;
  strftime    := tim.strftime;

  creat       := file.creat;
  open        := file.open;
  fcntl       := file.fcntl;
  close       := file.close;
  read        := file.read;
  write       := file.write;
  lseek       := file.lseek;
  ftruncate   := file.ftruncate;
  dup         := file.dup;
  dup2        := file.dup2;
  umask       := file.umask;
  chmod       := file.chmod;
  chown       := file.chown;
  utime       := file.utime;
  stat        := file.stat;
  fstat       := file.fstat;
  lstat       := file.lstat;
  sISCHR      := file.sISCHR;
  sISDIR      := file.sISDIR;
  sISBLK      := file.sISBLK;
  sISREG      := file.sISREG;
  sISFIFO     := file.sISFIFO;
  sISLNK      := file.sISLNK;
  access      := file.access;
  pipe        := file.pipe;

  mkdir       := dir.mkdir;
  rmdir       := dir.rmdir;
  link        := dir.link;
  unlink      := dir.unlink;
  rename      := dir.rename;
  opendir     := dir.opendir;
  readdir     := dir.readdir;
  rewinddir   := dir.rewinddir;
  closedir    := dir.closedir;
  symlink     := dir.symlink;
  readlink    := dir.readlink;

  chdir       := proc.chdir;
  getcwd      := proc.getcwd;
  getlogin    := proc.getlogin;
  getpid      := proc.getpid;
  getppid     := proc.getppid;
  getuid      := proc.getuid;
  getgid      := proc.getgid;
  geteuid     := proc.geteuid;
  getegid     := proc.getegid;
  setuid      := proc.setuid;
  setgid      := proc.setgid;
  seteuid     := proc.seteuid;
  setegid     := proc.setegid;
  getpgrp     := proc.getpgrp;
  setpgid     := proc.setpgid;
  setsid      := proc.setsid;
  fork        := proc.fork;
  execve      := proc.execve;
  execv       := proc.execv;
  execvp      := proc.execvp;
  waitpid     := proc.waitpid;
  wait        := proc.wait;
  WIFEXITED   := proc.WIFEXITED;
  WEXITSTATUS := proc.WEXITSTATUS;
  WIFSIGNALED := proc.WIFSIGNALED;
  WTERMSIG    := proc.WTERMSIG;
  WIFSTOPPED  := proc.WIFSTOPPED;
  WSTOPSIG    := proc.WSTOPSIG;
  times       := proc.times;
  Exit        := proc.Exit;

  isatty      := term.isatty;
  ttyname     := term.ttyname;
  ctermid     := term.ctermid;
  cfgetispeed := term.cfgetispeed;
  cfgetospeed := term.cfgetospeed;
  cfsetispeed := term.cfsetispeed;
  cfsetospeed := term.cfsetospeed;
  tcgetattr   := term.tcgetattr;
  tcsetattr   := term.tcsetattr;
  tcsendbreak := term.tcsendbreak;
  tcdrain     := term.tcdrain;
  tcflow      := term.tcflow;
  tcflush     := term.tcflush;
  tcgetpgrp   := term.tcgetpgrp;
  tcsetpgrp   := term.tcsetpgrp;

  sigemptyset := sig.sigemptyset;
  sigfillset  := sig.sigfillset;
  sigaddset   := sig.sigaddset;
  sigdelset   := sig.sigdelset;
  sigismember := sig.sigismember;
  sigaction   := sig.sigaction;
  sigprocmask := sig.sigprocmask;
  sigpending  := sig.sigpending;
  kill        := sig.kill;
  pause       := sig.pause;
  sigsuspend  := sig.sigsuspend;
  sleep       := sig.sleep;
  alarm       := sig.alarm;

  uname       := sys.uname;
  pathconf    := sys.pathconf;
  sysconf     := sys.sysconf;
  time        := sys.time;

  setjmp      := jump.setjmp;
  longjmp     := jump.longjmp;
  sigsetjmp   := jump.sigsetjmp;
  siglongjmp  := jump.siglongjmp;

  setlocale   := loc.setlocale;
#endif
END POSIX1.
