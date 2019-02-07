IMPLEMENTATION MODULE OSCALLS;
__IMP_SWITCHES__
__RANGECHECK_OFF__
__STACKCHECK_OFF__
__DEBUG_OFF__
#ifdef HM2
#ifdef __LONG_WHOLE__
(*$!i+: Modul muss mit $i- uebersetzt werden! *)
(*$!w+: Modul muss mit $w- uebersetzt werden! *)
#else
(*$!i-: Modul muss mit $i+ uebersetzt werden! *)
(*$!w-: Modul muss mit $w+ uebersetzt werden! *)
#endif
#endif
(*****************************************************************************)
(* 12-Mai-94, Holger Kleinschmidt                                            *)
(*****************************************************************************)

CAST_IMPORT
VAL_INTRINSIC
OSCALL_IMPORT

FROM SYSTEM IMPORT
(* TYPE *) ADDRESS;
#if (defined LPRM2) || (defined SPCM2)
FROM SYSTEM IMPORT ADR;
#endif

FROM PORTAB IMPORT
(* CONST*) NULL,
(* TYPE *) UNSIGNEDWORD, SIGNEDWORD, UNSIGNEDLONG, SIGNEDLONG, ANYLONG,
           ANYWORD, WORDSET;

#define __OSCALLS__ /* Keine Stackkorrektur fuer LPR und TDI */
#include "oscalls.m2h"

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

CONST
  EOKL = LIC(0);

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE Vsync;
BEGIN
 vsync();
END Vsync;

(*---------------------------------------------------------------------------*)

PROCEDURE Supexec(proc:PROC);
BEGIN
#if (defined LPRM2) || (defined SPCM2)
 supexec(VAL(LONGCARD,proc));
#else
 supexec(proc);
#endif
END Supexec;

(*---------------------------------------------------------------------------*)

PROCEDURE Setexc(vec:CARDINAL;adr:ADDRESS):ADDRESS;
VAR old:ADDRESS;
BEGIN
 setexc(vec,adr,old);
 RETURN(old);
END Setexc;

(*---------------------------------------------------------------------------*)

PROCEDURE Bconin(dev:CARDINAL):UNSIGNEDLONG;
VAR key:UNSIGNEDLONG;
BEGIN
 bconin(dev,key);
 RETURN(key);
END Bconin;

(*---------------------------------------------------------------------------*)

PROCEDURE Bconout(dev:CARDINAL;ch:CARDINAL):BOOLEAN;
VAR wres:SIGNEDWORD;
BEGIN
 bconout(dev,ch,wres);
 RETURN(wres=0);
END Bconout;

(*---------------------------------------------------------------------------*)

PROCEDURE Bconstat(dev:CARDINAL):BOOLEAN;
VAR wres:SIGNEDWORD;
BEGIN
 bconstat(dev,wres);
 RETURN(wres<>0);
END Bconstat;

(*---------------------------------------------------------------------------*)

PROCEDURE Cconis():BOOLEAN;
VAR wres:SIGNEDWORD;
BEGIN
 c_conis(wres);
 RETURN(wres<>0);
END Cconis;

(*---------------------------------------------------------------------------*)

PROCEDURE Cnecin():UNSIGNEDLONG;
VAR key:UNSIGNEDLONG;
BEGIN
 c_necin(key);
 RETURN(key);
END Cnecin;

(*---------------------------------------------------------------------------*)

PROCEDURE Cconout(c:CHAR);
BEGIN
 c_conout(ORD(c));
END Cconout;

(*---------------------------------------------------------------------------*)

PROCEDURE Cconws(str:ADDRESS);
BEGIN
 c_conws(str);
END Cconws;

(*---------------------------------------------------------------------------*)

PROCEDURE Dsetdrv(drv:CARDINAL):UNSIGNEDLONG;
VAR drives:UNSIGNEDLONG;
BEGIN
 d_setdrv(drv,drives);
 RETURN(drives);
END Dsetdrv;

(*---------------------------------------------------------------------------*)

PROCEDURE Dgetdrv():CARDINAL;
VAR wres:UNSIGNEDWORD;
BEGIN
 d_getdrv(wres);
 RETURN(VAL(CARDINAL,wres));
END Dgetdrv;

(*---------------------------------------------------------------------------*)

PROCEDURE Fsetdta(dta:ADDRESS);
BEGIN
 f_setdta(dta);
END Fsetdta;

(*---------------------------------------------------------------------------*)

PROCEDURE Super(dat:UNSIGNEDLONG):SIGNEDLONG;
VAR val:SIGNEDLONG;
BEGIN
 s_uper(dat,val);
 RETURN(val);
END Super;

(*---------------------------------------------------------------------------*)

PROCEDURE Tgetdate():WORDSET;
VAR date:UNSIGNEDWORD;
BEGIN
 t_getdate(date);
 RETURN(CAST(WORDSET,date));
END Tgetdate;

(*---------------------------------------------------------------------------*)

PROCEDURE Tsetdate(date:ANYWORD;VAR res:INTEGER):BOOLEAN;
VAR wres:SIGNEDWORD;
BEGIN
 t_setdate(date,wres);
 res:=INT(wres);
 RETURN(wres=0);
END Tsetdate;

(*---------------------------------------------------------------------------*)

PROCEDURE Tgettime():WORDSET;
VAR time:UNSIGNEDWORD;
BEGIN
 t_gettime(time);
 RETURN(CAST(WORDSET,time));
END Tgettime;

(*---------------------------------------------------------------------------*)

PROCEDURE Tsettime(time:ANYWORD;VAR res:INTEGER):BOOLEAN;
VAR wres:SIGNEDWORD;
BEGIN
 t_settime(time,wres);
 res:=INT(wres);
 RETURN(wres=0);
END Tsettime;

(*---------------------------------------------------------------------------*)

PROCEDURE Fgetdta():ADDRESS;
VAR dta:ADDRESS;
BEGIN
 f_getdta(dta);
 RETURN(dta);
END Fgetdta;

(*---------------------------------------------------------------------------*)

PROCEDURE Sversion():CARDINAL;
VAR vers:UNSIGNEDWORD;
BEGIN
 s_version(vers);
 RETURN(VAL(CARDINAL,vers));
END Sversion;

(*---------------------------------------------------------------------------*)

PROCEDURE Dcreate(dir:ADDRESS;VAR res:INTEGER):BOOLEAN;
VAR wres:SIGNEDWORD;
BEGIN
 d_create(dir,wres);
 res:=INT(wres);
 RETURN(wres>=0);
END Dcreate;

(*---------------------------------------------------------------------------*)

PROCEDURE Ddelete(dir:ADDRESS;VAR res:INTEGER):BOOLEAN;
VAR wres:SIGNEDWORD;
BEGIN
 d_delete(dir,wres);
 res:=INT(wres);
 RETURN(wres>=0);
END Ddelete;

(*---------------------------------------------------------------------------*)

PROCEDURE Dsetpath(dir:ADDRESS;VAR res:INTEGER):BOOLEAN;
VAR wres:SIGNEDWORD;
BEGIN
 d_setpath(dir,wres);
 res:=INT(wres);
 RETURN(wres>=0);
END Dsetpath;

(*---------------------------------------------------------------------------*)

PROCEDURE Dfree(buf:ADDRESS;drv:CARDINAL;VAR res:INTEGER):BOOLEAN;
VAR wres:SIGNEDWORD;
BEGIN
 d_free(buf,drv,wres);
 res:=INT(wres);
 RETURN(wres>=0);
END Dfree;

(*---------------------------------------------------------------------------*)

PROCEDURE Fcreate(file:ADDRESS;attr:ANYWORD;VAR hndl:INTEGER):BOOLEAN;
VAR lres:SIGNEDLONG;
BEGIN
 f_create(file,attr,lres);
 hndl:=VAL(INTEGER,lres);
 RETURN(lres>=EOKL);
END Fcreate;

(*---------------------------------------------------------------------------*)

PROCEDURE Fopen(file:ADDRESS;mode:ANYWORD;VAR hndl:INTEGER):BOOLEAN;
VAR lres:SIGNEDLONG;
BEGIN
 f_open(file,mode,lres);
 hndl:=VAL(INTEGER,lres);
 RETURN(lres>=EOKL);
END Fopen;

(*---------------------------------------------------------------------------*)

PROCEDURE Fclose(hndl:INTEGER;VAR res:INTEGER):BOOLEAN;
VAR wres:SIGNEDWORD;
BEGIN
 f_close(hndl,wres);
 res:=INT(wres);
 RETURN(wres>=0);
END Fclose;

(*---------------------------------------------------------------------------*)

PROCEDURE Fread(hndl:INTEGER;len:UNSIGNEDLONG;buf:ADDRESS;VAR cnt:SIGNEDLONG):BOOLEAN;
VAR lres:SIGNEDLONG;
BEGIN
 f_read(hndl,len,buf,lres);
 cnt:=lres;
 RETURN(lres>=EOKL);
END Fread;

(*---------------------------------------------------------------------------*)

PROCEDURE Fwrite(hndl:INTEGER;len:UNSIGNEDLONG;buf:ADDRESS;VAR cnt:SIGNEDLONG):BOOLEAN;
VAR lres:SIGNEDLONG;
BEGIN
 f_write(hndl,len,buf,lres);
 cnt:=lres;
 RETURN(lres>=EOKL);
END Fwrite;

(*---------------------------------------------------------------------------*)

PROCEDURE Fdelete(file:ADDRESS;VAR res:INTEGER):BOOLEAN;
VAR wres:SIGNEDWORD;
BEGIN
 f_delete(file,wres);
 res:=INT(wres);
 RETURN(wres>=0);
END Fdelete;

(*---------------------------------------------------------------------------*)

PROCEDURE Fseek(off:SIGNEDLONG;hndl:INTEGER;mode:CARDINAL;VAR pos:SIGNEDLONG):BOOLEAN;
VAR lres:SIGNEDLONG;
BEGIN
 f_seek(off,hndl,mode,lres);
 pos:=lres;
 RETURN(lres>=EOKL);
END Fseek;

(*---------------------------------------------------------------------------*)

PROCEDURE Fattrib(file:ADDRESS;flag:CARDINAL;attr:ANYWORD;VAR old:WORDSET):BOOLEAN;
VAR lres:SIGNEDLONG;
BEGIN
 f_attrib(file,flag,attr,lres);
 old:=CAST(WORDSET,VAL(UNSIGNEDWORD,lres));
 RETURN(lres>=EOKL);
END Fattrib;

(*---------------------------------------------------------------------------*)

PROCEDURE Mxalloc(size:SIGNEDLONG;mode:ANYWORD;VAR adr:ADDRESS):BOOLEAN;
VAR lres:ADDRESS;
BEGIN
 m_xalloc(size,mode,lres);
 adr:=lres;
 RETURN(lres<>NULL);
END Mxalloc;

(*---------------------------------------------------------------------------*)

PROCEDURE Fdup(std:INTEGER;VAR hndl:INTEGER):BOOLEAN;
VAR lres:SIGNEDLONG;
BEGIN
 f_dup(std,lres);
 hndl:=VAL(INTEGER,lres);
 RETURN(lres>=EOKL);
END Fdup;

(*---------------------------------------------------------------------------*)

PROCEDURE Fforce(std:INTEGER;hndl:INTEGER;VAR res:INTEGER):BOOLEAN;
VAR wres:SIGNEDWORD;
BEGIN
 f_force(std,hndl,wres);
 res:=VAL(INTEGER,wres);
 RETURN(wres>=0);
END Fforce;

(*---------------------------------------------------------------------------*)

PROCEDURE Dgetpath(buf:ADDRESS;drv:CARDINAL;VAR res:INTEGER):BOOLEAN;
VAR wres:SIGNEDWORD;
BEGIN
 d_getpath(buf,drv,wres);
 res:=VAL(INTEGER,wres);
 RETURN(wres>=0);
END Dgetpath;

(*---------------------------------------------------------------------------*)

PROCEDURE Malloc(size:SIGNEDLONG;VAR adr:ADDRESS):BOOLEAN;
VAR lres:ADDRESS;
BEGIN
 m_alloc(size,lres);
 adr:=lres;
 RETURN(lres<>NULL);
END Malloc;

(*---------------------------------------------------------------------------*)

PROCEDURE Mfree(adr:ADDRESS;VAR res:INTEGER):BOOLEAN;
VAR wres:SIGNEDWORD;
BEGIN
 m_free(adr,wres);
 res:=INT(wres);
 RETURN(wres>=0);
END Mfree;

(*---------------------------------------------------------------------------*)

PROCEDURE Mshrink(adr:ADDRESS;size:SIGNEDLONG;VAR res:INTEGER):BOOLEAN;
VAR wres:SIGNEDWORD;
BEGIN
 m_shrink(adr,size,wres);
 res:=INT(wres);
 RETURN(wres>=0);
END Mshrink;

(*---------------------------------------------------------------------------*)

PROCEDURE Pexec(mode:CARDINAL;prog:ADDRESS;tail:ADDRESS;env:ADDRESS;VAR res:SIGNEDLONG):BOOLEAN;
VAR lres:SIGNEDLONG;
BEGIN
 p_exec(mode,prog,tail,env,lres);
 res:=lres;
 IF(mode=3)OR(mode=5)OR(mode=7)THEN
   RETURN(lres>=EOKL);
 ELSE
   RETURN(TRUE);
 END;
END Pexec;

(*---------------------------------------------------------------------------*)

PROCEDURE Pterm(ret:INTEGER);
BEGIN
 p_term(ret);
END Pterm;

(*---------------------------------------------------------------------------*)

PROCEDURE Fsfirst(file:ADDRESS;attr:ANYWORD;VAR res:INTEGER):BOOLEAN;
VAR wres:SIGNEDWORD;
BEGIN
 f_sfirst(file,attr,wres);
 res:=INT(wres);
 RETURN(wres>=0);
END Fsfirst;

(*---------------------------------------------------------------------------*)

PROCEDURE Fsnext(VAR res:INTEGER):BOOLEAN;
VAR wres:SIGNEDWORD;
BEGIN
 f_snext(wres);
 res:=INT(wres);
 RETURN(wres>=0);
END Fsnext;

(*---------------------------------------------------------------------------*)

PROCEDURE Frename(old:ADDRESS;new:ADDRESS;VAR res:INTEGER):BOOLEAN;
VAR wres:SIGNEDWORD;
BEGIN
 f_rename(old,new,wres);
 res:=INT(wres);
 RETURN(wres>=0);
END Frename;

(*---------------------------------------------------------------------------*)

PROCEDURE Fdatime(datime:ADDRESS;hndl:INTEGER;flag:CARDINAL);
BEGIN
 f_datime(datime,hndl,flag);
END Fdatime;

(*---------------------------------------------------------------------------*)

PROCEDURE Flock(hndl:INTEGER;mode:CARDINAL;from:UNSIGNEDLONG;len:UNSIGNEDLONG;VAR res:INTEGER):BOOLEAN;
VAR wres:SIGNEDWORD;
BEGIN
 f_lock(hndl,mode,from,len,wres);
 res:=INT(wres);
 RETURN(wres>=0);
END Flock;

(*---------------------------------------------------------------------------*)

PROCEDURE Syield():INTEGER;
VAR wres:SIGNEDWORD;
BEGIN
 s_yield(wres);
 RETURN(INT(wres));
END Syield;

(*---------------------------------------------------------------------------*)

PROCEDURE Fpipe(buf:ADDRESS;VAR res:INTEGER):BOOLEAN;
VAR wres:SIGNEDWORD;
BEGIN
 f_pipe(buf,wres);
 res:=INT(wres);
 RETURN(wres>=0);
END Fpipe;

(*---------------------------------------------------------------------------*)

PROCEDURE Fcntl(hndl:INTEGER;arg:ANYLONG;cmd:CARDINAL;VAR res:SIGNEDLONG):BOOLEAN;
VAR lres:SIGNEDLONG;
BEGIN
 f_cntl(hndl,arg,cmd,lres);
 res:=lres;
 RETURN(lres>=EOKL);
END Fcntl;

(*---------------------------------------------------------------------------*)

PROCEDURE Pwait(VAR res:SIGNEDLONG):BOOLEAN;
VAR lres:SIGNEDLONG;
BEGIN
 p_wait(lres);
 res:=lres;
 RETURN(lres>=EOKL);
END Pwait;

(*---------------------------------------------------------------------------*)

PROCEDURE Pgetpid():INTEGER;
VAR wres:SIGNEDWORD;
BEGIN
 p_getpid(wres);
 RETURN(VAL(INTEGER,wres));
END Pgetpid;

(*---------------------------------------------------------------------------*)

PROCEDURE Pgetppid():INTEGER;
VAR wres:SIGNEDWORD;
BEGIN
 p_getppid(wres);
 RETURN(VAL(INTEGER,wres));
END Pgetppid;

(*---------------------------------------------------------------------------*)

PROCEDURE Pgetpgrp():INTEGER;
VAR wres:SIGNEDWORD;
BEGIN
 p_getpgrp(wres);
 RETURN(VAL(INTEGER,wres));
END Pgetpgrp;

(*---------------------------------------------------------------------------*)

PROCEDURE Psetpgrp(pid:INTEGER;grp:INTEGER;VAR res:INTEGER):BOOLEAN;
VAR wres:SIGNEDWORD;
BEGIN
 p_setpgrp(pid,grp,wres);
 res:=VAL(INTEGER,wres);
 RETURN(wres>=0);
END Psetpgrp;

(*---------------------------------------------------------------------------*)

PROCEDURE Pgetuid():INTEGER;
VAR wres:SIGNEDWORD;
BEGIN
 p_getuid(wres);
 RETURN(VAL(INTEGER,wres));
END Pgetuid;

(*---------------------------------------------------------------------------*)

PROCEDURE Psetuid(uid:UNSIGNEDWORD;VAR res:INTEGER):BOOLEAN;
VAR wres:SIGNEDWORD;
BEGIN
 p_setuid(uid,wres);
 res:=INT(wres);
 RETURN(wres>=0);
END Psetuid;

(*---------------------------------------------------------------------------*)

PROCEDURE Pkill(pid:INTEGER;sig:CARDINAL;VAR res:INTEGER):BOOLEAN;
VAR wres:SIGNEDWORD;
BEGIN
 p_kill(pid,sig,wres);
 res:=INT(wres);
 RETURN(wres>=0);
END Pkill;

(*---------------------------------------------------------------------------*)

PROCEDURE Psignal(sig:CARDINAL;handler:ADDRESS;VAR old:ADDRESS):BOOLEAN;
VAR lres:ADDRESS;
BEGIN
 p_signal(sig,handler,lres);
 old:=lres;
 RETURN(CAST(SIGNEDLONG,lres)>=EOKL);
END Psignal;

(*---------------------------------------------------------------------------*)

PROCEDURE Pgetgid():INTEGER;
VAR wres:SIGNEDWORD;
BEGIN
 p_getgid(wres);
 RETURN(VAL(INTEGER,wres));
END Pgetgid;

(*---------------------------------------------------------------------------*)

PROCEDURE Psetgid(gid:UNSIGNEDWORD;VAR res:INTEGER):BOOLEAN;
VAR wres:SIGNEDWORD;
BEGIN
 p_setgid(gid,wres);
 res:=INT(wres);
 RETURN(wres>=0);
END Psetgid;

(*---------------------------------------------------------------------------*)

PROCEDURE Psigblock(mask:UNSIGNEDLONG):UNSIGNEDLONG;
VAR old:UNSIGNEDLONG;
BEGIN
 p_sigblock(mask,old);
 RETURN(old);
END Psigblock;

(*---------------------------------------------------------------------------*)

PROCEDURE Psigsetmask(mask:UNSIGNEDLONG):UNSIGNEDLONG;
VAR old:UNSIGNEDLONG;
BEGIN
 p_sigsetmask(mask,old);
 RETURN(old);
END Psigsetmask;

(*---------------------------------------------------------------------------*)

PROCEDURE Pusrval(arg:SIGNEDLONG):SIGNEDLONG;
VAR val:SIGNEDLONG;
BEGIN
 p_usrval(arg,val);
 RETURN(val);
END Pusrval;

(*---------------------------------------------------------------------------*)

PROCEDURE Pdomain(dom:INTEGER):INTEGER;
VAR wres:SIGNEDWORD;
BEGIN
 p_domain(dom,wres);
 RETURN(VAL(INTEGER,wres));
END Pdomain;

(*---------------------------------------------------------------------------*)

PROCEDURE Psigreturn;
BEGIN
 p_sigreturn();
END Psigreturn;

(*---------------------------------------------------------------------------*)

PROCEDURE Pfork():INTEGER;
VAR wres:SIGNEDWORD;
BEGIN
 p_fork(wres);
 RETURN(VAL(INTEGER,wres));
END Pfork;

(*---------------------------------------------------------------------------*)

PROCEDURE Pwait3(flag:ANYWORD;rusage:ADDRESS;VAR res:SIGNEDLONG):BOOLEAN;
VAR lres:SIGNEDLONG;
BEGIN
 p_wait3(flag,rusage,lres);
 res:=lres;
 RETURN(lres>=EOKL);
END Pwait3;

(*---------------------------------------------------------------------------*)

PROCEDURE Fselect(timeout:CARDINAL;rfds:ADDRESS;wfds:ADDRESS;xfds:ADDRESS;VAR res:INTEGER):BOOLEAN;
VAR wres:SIGNEDWORD;
BEGIN
 f_select(timeout,rfds,wfds,xfds,wres);
 res:=INT(wres);
 RETURN(wres>=0);
END Fselect;

(*---------------------------------------------------------------------------*)

PROCEDURE Prusage(rscadr:ADDRESS):INTEGER;
VAR wres:SIGNEDWORD;
BEGIN
 p_rusage(rscadr,wres);
 RETURN(INT(wres));
END Prusage;

(*---------------------------------------------------------------------------*)

PROCEDURE Talarm(secs:SIGNEDLONG):SIGNEDLONG;
VAR old:SIGNEDLONG;
BEGIN
 t_alarm(secs,old);
 RETURN(old);
END Talarm;

(*---------------------------------------------------------------------------*)

PROCEDURE Tmalarm(msecs:SIGNEDLONG):SIGNEDLONG;
VAR old:SIGNEDLONG;
BEGIN
 t_malarm(msecs,old);
 RETURN(old);
END Tmalarm;

(*---------------------------------------------------------------------------*)

PROCEDURE Pause():INTEGER;
VAR wres:SIGNEDWORD;
BEGIN
 p_ause(wres);
 RETURN(INT(wres));
END Pause;

(*---------------------------------------------------------------------------*)

PROCEDURE Sysconf(which:INTEGER;VAR val:SIGNEDLONG):BOOLEAN;
VAR lres:SIGNEDLONG;
BEGIN
 s_ysconf(which,lres);
 val:=lres;
 RETURN(lres>=EOKL);
END Sysconf;

(*---------------------------------------------------------------------------*)

PROCEDURE Psigpending():SIGNEDLONG;
VAR sigs:SIGNEDLONG;
BEGIN
 p_sigpending(sigs);
 RETURN(sigs);
END Psigpending;

(*---------------------------------------------------------------------------*)

PROCEDURE Dpathconf(path:ADDRESS;which:INTEGER;VAR val:SIGNEDLONG):BOOLEAN;
VAR lres:SIGNEDLONG;
BEGIN
 d_pathconf(path,which,lres);
 val:=lres;
 RETURN(lres>=EOKL);
END Dpathconf;

(*---------------------------------------------------------------------------*)

PROCEDURE Dopendir(path:ADDRESS;flag:CARDINAL;VAR dir:UNSIGNEDLONG):BOOLEAN;
VAR lres:UNSIGNEDLONG;
BEGIN
 d_opendir(path,flag,lres);
 dir:=lres;
 RETURN(lres<CAST(UNSIGNEDLONG,0FF000000H));
END Dopendir;

(*---------------------------------------------------------------------------*)

PROCEDURE Dreaddir(len:CARDINAL;dir:UNSIGNEDLONG;buf:ADDRESS;VAR res:INTEGER):BOOLEAN;
VAR wres:SIGNEDWORD;
BEGIN
 d_readdir(len,dir,buf,wres);
 res:=INT(wres);
 RETURN(wres>=0);
END Dreaddir;

(*---------------------------------------------------------------------------*)

PROCEDURE Drewinddir(dir:UNSIGNEDLONG;VAR res:INTEGER):BOOLEAN;
VAR wres:SIGNEDWORD;
BEGIN
 d_rewinddir(dir,wres);
 res:=INT(wres);
 RETURN(wres>=0);
END Drewinddir;

(*---------------------------------------------------------------------------*)

PROCEDURE Dclosedir(dir:UNSIGNEDLONG;VAR res:INTEGER):BOOLEAN;
VAR wres:SIGNEDWORD;
BEGIN
 d_closedir(dir,wres);
 res:=INT(wres);
 RETURN(wres>=0);
END Dclosedir;

(*---------------------------------------------------------------------------*)

PROCEDURE Fxattr(flag:CARDINAL;file:ADDRESS;xattr:ADDRESS;VAR res:INTEGER):BOOLEAN;
VAR wres:SIGNEDWORD;
BEGIN
 f_xattr(flag,file,xattr,wres);
 res:=INT(wres);
 RETURN(wres>=0);
END Fxattr;

(*---------------------------------------------------------------------------*)

PROCEDURE Flink(old:ADDRESS;new:ADDRESS;VAR res:INTEGER):BOOLEAN;
VAR wres:SIGNEDWORD;
BEGIN
 f_link(old,new,wres);
 res:=INT(wres);
 RETURN(wres>=0);
END Flink;

(*---------------------------------------------------------------------------*)

PROCEDURE Fsymlink(old:ADDRESS;new:ADDRESS;VAR res:INTEGER):BOOLEAN;
VAR wres:SIGNEDWORD;
BEGIN
 f_symlink(old,new,wres);
 res:=INT(wres);
 RETURN(wres>=0);
END Fsymlink;

(*---------------------------------------------------------------------------*)

PROCEDURE Freadlink(bufsiz:CARDINAL;buf:ADDRESS;file:ADDRESS;VAR res:INTEGER):BOOLEAN;
VAR wres:SIGNEDWORD;
BEGIN
 f_readlink(bufsiz,buf,file,wres);
 res:=INT(wres);
 RETURN(wres>=0);
END Freadlink;

(*---------------------------------------------------------------------------*)

PROCEDURE Fchown(file:ADDRESS;uid:UNSIGNEDWORD;gid:UNSIGNEDWORD;VAR res:INTEGER):BOOLEAN;
VAR wres:SIGNEDWORD;
BEGIN
 f_chown(file,uid,gid,wres);
 res:=INT(wres);
 RETURN(wres>=0);
END Fchown;

(*---------------------------------------------------------------------------*)

PROCEDURE Dcntl(cmd:CARDINAL;path:ADDRESS;arg:ANYLONG;VAR res:SIGNEDLONG):BOOLEAN;
VAR lres:SIGNEDLONG;
BEGIN
 d_cntl(cmd,path,arg,lres);
 res:=lres;
 RETURN(lres>=EOKL);
END Dcntl;

(*---------------------------------------------------------------------------*)

PROCEDURE Fchmod(file:ADDRESS;mode:ANYWORD;VAR res:INTEGER):BOOLEAN;
VAR wres:SIGNEDWORD;
BEGIN
 f_chmod(file,mode,wres);
 res:=INT(wres);
 RETURN(wres>=0);
END Fchmod;

(*---------------------------------------------------------------------------*)

PROCEDURE Pumask(mode:ANYWORD):SIGNEDLONG;
VAR old:SIGNEDLONG;
BEGIN
 p_umask(mode,old);
 RETURN(old);
END Pumask;

(*---------------------------------------------------------------------------*)

PROCEDURE Psigpause(sigmask:UNSIGNEDLONG):INTEGER;
VAR wres:SIGNEDWORD;
BEGIN
 p_sigpause(sigmask,wres);
 RETURN(INT(wres));
END Psigpause;

(*---------------------------------------------------------------------------*)

PROCEDURE Psigaction(sig:CARDINAL;act:ADDRESS;oact:ADDRESS;VAR res:INTEGER):BOOLEAN;
VAR wres:SIGNEDWORD;
BEGIN
 p_sigaction(sig,act,oact,wres);
 res:=INT(wres);
 RETURN(wres>=0);
END Psigaction;

(*---------------------------------------------------------------------------*)

PROCEDURE Pgeteuid():INTEGER;
VAR wres:SIGNEDWORD;
BEGIN
 p_geteuid(wres);
 RETURN(VAL(INTEGER,wres));
END Pgeteuid;

(*---------------------------------------------------------------------------*)

PROCEDURE Pgetegid():INTEGER;
VAR wres:SIGNEDWORD;
BEGIN
 p_getegid(wres);
 RETURN(VAL(INTEGER,wres));
END Pgetegid;

(*---------------------------------------------------------------------------*)

PROCEDURE Pwaitpid(pid:INTEGER;flag:ANYWORD;rusage:ADDRESS;VAR res:SIGNEDLONG):BOOLEAN;
VAR lres:SIGNEDLONG;
BEGIN
 p_waitpid(pid,flag,rusage,lres);
 res:=lres;
 RETURN(lres>=EOKL);
END Pwaitpid;

(*---------------------------------------------------------------------------*)

PROCEDURE Dgetcwd(path:ADDRESS;drv:CARDINAL;size:CARDINAL;VAR res:INTEGER):BOOLEAN;
VAR wres:SIGNEDWORD;
BEGIN
 d_getcwd(path,drv,size,wres);
 res:=INT(wres);
 RETURN(wres>=0);
END Dgetcwd;

END OSCALLS.
