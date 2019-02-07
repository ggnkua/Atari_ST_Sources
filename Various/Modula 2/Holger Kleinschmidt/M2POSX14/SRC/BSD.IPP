IMPLEMENTATION MODULE BSD;
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

IMPORT dir,proc,sys,sig;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

BEGIN (* BSD *)
 setreuid    := proc.setreuid;
 setregid    := proc.setregid;
 vfork       := proc.vfork;
 wait3       := proc.wait3;
 wait4       := proc.wait4;
 select      := proc.select;
 FDZERO      := proc.FDZERO;
 FDSET       := proc.FDSET;
 FDCLR       := proc.FDCLR;
 FDISSET     := proc.FDISSET;

 telldir     := dir.telldir;
 seekdir     := dir.seekdir;

 killpg      := sig.killpg;
 usleep      := sig.usleep;
 sigmask     := sig.sigmask;
 sigpause    := sig.sigpause;
 sigblock    := sig.sigblock;
 sigsetmask  := sig.sigsetmask;

 statfs      := sys.statfs;
 gethostname := sys.gethostname;
#endif
END BSD.
