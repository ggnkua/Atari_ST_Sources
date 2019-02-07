IMPLEMENTATION MODULE iX;
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

IMPORT args,blk,str,dir,proc,sys,sig,fcrypt,term;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

BEGIN (* iX *)
 strcasecmp   := str.strcasecmp;
 stricmp      := str.strcasecmp;  (* Alias *)
 strncasecmp  := str.strncasecmp;
 strnicmp     := str.strncasecmp; (* Alias *)

 vfork        := proc.vfork;
 setreuid     := proc.setreuid;
 setregid     := proc.setregid;
 wait3        := proc.wait3;
 wait4        := proc.wait4;
 setpgrp      := proc.setpgid; (* Alias *)
 setgroups    := proc.setgroups;
 initgroups   := proc.initgroups;
 nice         := proc.nice;
 select       := proc.select;
 FDZERO       := proc.FDZERO;
 FDSET        := proc.FDSET;
 FDCLR        := proc.FDCLR;
 FDISSET      := proc.FDISSET;

 telldir      := dir.telldir;
 seekdir      := dir.seekdir;
 major        := dir.major;
 minor        := dir.minor;
 makedev      := dir.makedev;

 killpg       := sig.killpg;
 usleep       := sig.usleep;
 timerclear   := sig.timerclear;
 timerisset   := sig.timerisset;
 timercmp     := sig.timercmp;
 getitimer    := sig.getitimer;
 setitimer    := sig.setitimer;
 sigmask      := sig.sigmask;
 sigpause     := sig.sigpause;
 sigblock     := sig.sigblock;
 sigsetmask   := sig.sigsetmask;

 statfs       := sys.statfs;
 gethostname  := sys.gethostname;
 getpagesize  := sys.getpagesize;
 setpwent     := sys.setpwent;
 endpwent     := sys.endpwent;
 getpwent     := sys.getpwent;
 setgrent     := sys.setgrent;
 endgrent     := sys.endgrent;
 getgrent     := sys.getgrent;
 stime        := sys.stime;
 gettimeofday := sys.gettimeofday;
 settimeofday := sys.settimeofday;
 ftime        := sys.ftime;

 ioctl        := term.ioctl;

 putenv       := args.putenv;

 bcopy        := blk.bcopy;
 bzero        := blk.bzero;
 bcmp         := blk.memcmp; (* Alias *)

 crypt        := fcrypt.crypt;
#endif
END iX.
