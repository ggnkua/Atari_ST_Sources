* reentrant MiNT bindings for Pure C
* hohmuth 29 Aug 92
*
* this module is spezialized for pure c (awaits parameters
* in registers)
*
; To assemble with MAS (the assembler that comes with Turbo C),
; delete all instances of the strings ".MODULE" and ".ENDMOD"

	.INCLUDE 'osmacros.s'

	.EXPORT	Syield, Fpipe, Fcntl, Finstat, Foutstat, Fgetchar, Fputchar
	.EXPORT Pwait, Pnice, Pgetpid, Pgetppid, Pgetpgrp, Psetpgrp
	.EXPORT Pgetuid, Psetuid, Pkill, Psignal, Pvfork, Pgetgid, Psetgid
	.EXPORT Psigblock, Psigsetmask, Pusrval, Pdomain, Psigreturn
	.EXPORT Pfork, Pwait3, Fselect, Prusage, Psetlimit, Talarm, Pause
	.EXPORT Sysconf, Psigpending, Dpathconf, Pmsg, Fmidipipe, Prenice
	.EXPORT	Dopendir, Dreaddir, Drewinddir, Dclosedir, Fxattr, Flink
	.EXPORT Fsymlink, Freadlink, Dcntl, Fchown, Fchmod, Pumask
	.EXPORT Psemaphore, Dlock, Psigpause, Psigaction, Pgeteuid, Pgetegid
	.EXPORT Pwaitpid, Dgetcwd, Salert

;/* The following are not yet official... */
	.EXPORT Tmalarm, Psigintr, Suptime, Dxreaddir, Pseteuid,Psetegid
	.EXPORT Psetauid, Pgetauid, Pgetgroups, Psetgroups, Tsetitimer
	.EXPORT Psetreuid, Psetregid, Sync, Shutdown, Dreadlabel, Dwritelabel
    .EXPORT Ssystem, Tgettimeofday, Pgetpriority, Psetpriority
    .EXPORT Pvalidate
	
*
* GEMDOS bindings
*
	
	USER
	
.MODULE	Syield:

	SYS_	GEMDOS,#$ff
	rts

	.ENDMOD

.MODULE	Fpipe:

	SYS_L	GEMDOS,#$100,a0
	rts

	.ENDMOD

.MODULE	Fcntl:
	SYS_WLW	GEMDOS,#$104,d0,d1,d2
	rts

	.ENDMOD

.MODULE Finstat:
	SYS_W	GEMDOS,#$105,d0
	rts

	.ENDMOD
	
.MODULE Foutstat:
	SYS_W	GEMDOS,#$106,d0
	rts
	
	.ENDMOD

.MODULE	Fgetchar:
	SYS_WW	GEMDOS,#$107,d0,d1
	rts
	
	.ENDMOD
	
.MODULE Fputchar:
	SYS_WLW	GEMDOS,#$108,d0,d1,d2
	rts
	
	.ENDMOD

.MODULE	Pwait:
	SYS_	GEMDOS,#$109
	rts

	.ENDMOD

.MODULE Pnice:
	SYS_W	GEMDOS,#$10a,d0
	rts
	
	.ENDMOD

.MODULE	Pgetpid:
	SYS_	GEMDOS,#$10b
	rts

	.ENDMOD

.MODULE Pgetppid:
	SYS_	GEMDOS,#$10c
	rts
	
	.ENDMOD

.MODULE Pgetpgrp:
	SYS_	GEMDOS,#$10d
	rts
	
	.ENDMOD

.MODULE Psetpgrp:
	SYS_WW	GEMDOS,#$10e,d0,d1
	rts
	
	.ENDMOD

.MODULE Pgetuid:
	SYS_	GEMDOS,#$10f
	rts
	
	.ENDMOD

.MODULE Psetuid:
	SYS_W	GEMDOS,#$110,d0
	rts
	
	.ENDMOD

.MODULE	Pkill:
	SYS_WW	GEMDOS,#$111,d0,d1
	rts

	.ENDMOD

; CAUTION! We assume the function is given as a long, NOT as a pointer!
; i.e. Psignal(int sig, long function);
.MODULE	Psignal:
	SYS_WL	GEMDOS,#$112,d0,d1
;	SYS_WL	GEMDOS,#$112,d0,a0
	rts

	.ENDMOD

.MODULE Pvfork:
	SYS_	GEMDOS,#$113
	rts
	
	.ENDMOD

.MODULE Pgetgid:
	SYS_	GEMDOS,#$114
	rts
	
	.ENDMOD

.MODULE Psetgid:
	SYS_W	GEMDOS,#$115,d0
	rts
	
	.ENDMOD

.MODULE	Psigblock:
	SYS_L	GEMDOS,#$116,d0
	rts

	.ENDMOD

.MODULE	Psigsetmask:
	SYS_L	GEMDOS,#$117,d0
	rts

	.ENDMOD

.MODULE	Pusrval:
	SYS_L	GEMDOS,#$118,d0
	rts

	.ENDMOD

.MODULE Pdomain:
	SYS_W	GEMDOS,#$119,d0
	rts
	
	.ENDMOD

.MODULE	Psigreturn:
	SYS_	GEMDOS,#$11a
	rts

	.ENDMOD

.MODULE Pfork:
	SYS_	GEMDOS,#$11b
	rts
	
	.ENDMOD

.MODULE	Pwait3:
	SYS_WL	GEMDOS,#$11c,d0,a0
	rts

	.ENDMOD

.MODULE	Fselect:
	SYS_WLLL GEMDOS,#$11d,d0,a0,a1,REGSIZE+4(sp)
	rts

	.ENDMOD

.MODULE Prusage:
	SYS_L	GEMDOS,#$11e,a0
	rts
	
	.ENDMOD

.MODULE Psetlimit:
	SYS_WL	GEMDOS,#$11f,d0,d1
	rts
	
	.ENDMOD

.MODULE	Talarm:
	SYS_L	GEMDOS,#$120,d0
	rts

	.ENDMOD

.MODULE	Pause:
	SYS_	GEMDOS,#$121
	rts

	.ENDMOD

.MODULE Sysconf:
	SYS_W	GEMDOS,#$122,d0
	rts
	
	.ENDMOD

.MODULE Psigpending:
	SYS_	GEMDOS,#$123
	rts
	
	.ENDMOD

.MODULE Dpathconf:
	SYS_LW	GEMDOS,#$124,a0,d0
	rts
	
	.ENDMOD

.MODULE Pmsg:
	SYS_WLL	GEMDOS,#$125,d0,d1,a0
	rts
	
	.ENDMOD

.MODULE Fmidipipe:
	SYS_WWW	GEMDOS,#$126,d0,d1,d2
	rts
	
	.ENDMOD

.MODULE Prenice:
	SYS_WW	GEMDOS,#$127,d0,d1
	rts
	
	.ENDMOD

.MODULE	Dopendir:
	SYS_LW	GEMDOS,#$128,a0,d0
	rts

	.ENDMOD

.MODULE	Dreaddir:
	SYS_WLL	GEMDOS,#$129,d0,d1,a0
	rts

	.ENDMOD
	
.MODULE Drewinddir:
	SYS_L	GEMDOS,#$12a,d0
	rts
	
	.ENDMOD

.MODULE	Dclosedir:
	SYS_L	GEMDOS,#$12b,d0
	rts

	.ENDMOD

.MODULE Fxattr:
	SYS_WLL	GEMDOS,#$12c,d0,a0,a1
	rts
	
	.ENDMOD

.MODULE Flink:
	SYS_LL	GEMDOS,#$12d,a0,a1
	rts
	
	.ENDMOD

.MODULE Fsymlink:
	SYS_LL	GEMDOS,#$12e,a0,a1
	rts
	
	.ENDMOD

.MODULE Freadlink:
	SYS_WLL	GEMDOS,#$12f,d0,a0,a1
	rts
	
	.ENDMOD

.MODULE	Dcntl:
	SYS_WLL	GEMDOS,#$130,d0,a0,d1
	rts

	.ENDMOD

.MODULE Fchown:
	SYS_LWW	GEMDOS,#$131,a0,d0,d1
	rts
	
	.ENDMOD

.MODULE Fchmod:
	SYS_LW	GEMDOS,#$132,a0,d0
	rts
	
	.ENDMOD

.MODULE Pumask:
	SYS_W	GEMDOS,#$133,d0
	rts
	
	.ENDMOD

.MODULE	Psemaphore:
	SYS_WLL	GEMDOS,#$134,d0,d1,d2
	rts

	.ENDMOD

.MODULE Dlock:
	SYS_WW	GEMDOS,#$135,d0,d1
	rts
	
	.ENDMOD

.MODULE Psigpause:
	SYS_L	GEMDOS,#$136,d0
	rts
	
	.ENDMOD

; CAUTION: we assume the structure addresses are given as longs, NOT
; as pointers!
.MODULE Psigaction:
	SYS_WLL	GEMDOS,#$137,d0,d1,d2
;	SYS_WLL	GEMDOS,#$137,d0,a0,a1
	rts
	
	.ENDMOD

.MODULE Pgeteuid:
	SYS_	GEMDOS,#$138
	rts
	
	.ENDMOD

.MODULE Pgetegid:
	SYS_	GEMDOS,#$139
	rts
	
	.ENDMOD

.MODULE Pwaitpid:
	SYS_WWL	GEMDOS,#$13a,d0,d1,a0
	rts

	.ENDMOD

.MODULE Dgetcwd:
	SYS_LWW GEMDOS,#$13b,a0,d0,d1
	rts

	.ENDMOD

.MODULE Salert:
	SYS_L	GEMDOS,#$13c,a0
	rts

	.ENDMOD

.MODULE Tmalarm:
	SYS_L	GEMDOS,#$13d,d0
	rts

	.ENDMOD

.MODULE Psigintr:
	SYS_WW	GEMDOS,#$13e,d0,d1
	rts
	
	.ENDMOD

.MODULE Suptime:
	SYS_LL	GEMDOS,#$13f,a0,a1
	rts
	
	.ENDMOD

.MODULE Pvalidate:
	SYS_WLLL	GEMDOS,#$141,d0,a0,d1,a1
	rts

	.ENDMOD

.MODULE Dxreaddir:
	SYS_WLLLL	GEMDOS,#$142,d0,d1,a0,d2,a1
	rts
	
	.ENDMOD

.MODULE Pseteuid:
	SYS_W	GEMDOS,#$143,d0
	rts
	
	.ENDMOD

.MODULE Psetegid:
	SYS_W	GEMDOS,#$143,d0
	rts
	
	.ENDMOD

.MODULE Psetauid:
	SYS_W	GEMDOS,#$145,d0
	rts
	
	.ENDMOD

.MODULE Pgetauid:
	SYS_W	GEMDOS,#$146,d0
	rts
	
	.ENDMOD

.MODULE Pgetgroups:
	SYS_WL	GEMDOS,#$147,d0,a0
	rts
	
	.ENDMOD

.MODULE Psetgroups:
	SYS_WL	GEMDOS,#$148,d0,a0
	rts
	
	.ENDMOD

.MODULE Tsetitimer:
	SYS_WLLLL	GEMDOS,#$149,d0,a0,a1,a2,a3
	rts
	
	.ENDMOD

.MODULE Psetreuid:
	SYS_WW	GEMDOS,#$14e,d0,d1
	rts
	
	.ENDMOD

.MODULE Psetregid:
	SYS_WW	GEMDOS,#$14f,d0,d1
	rts
	
	.ENDMOD

.MODULE Sync:
	SYS_	GEMDOS,#$150
	rts
	
	.ENDMOD

.MODULE Shutdown:
	SYS_L	GEMDOS,#$151,d0
	rts
	
	.ENDMOD

.MODULE Dreadlabel:
	SYS_LLW	GEMDOS,#$152,a0,a1,d0
	rts
	
	.ENDMOD

.MODULE Dwritelabel:
	SYS_LL	GEMDOS,#$153,a0,a1
	rts
	
	.ENDMOD

.MODULE Ssystem:
   SYS_WLL GEMDOS,#$154,d0,d1,d2
   rts

   .ENDMOD

.MODULE Tgettimeofday:
   SYS_LL GEMDOS,#$155,a0,a1
   rts
   
   .ENDMOD

.MODULE Tsettimeofday:
   SYS_LL GEMDOS,#$156,a0,a1
   rts
   
   .ENDMOD

.MODULE Pgetpriority:
   SYS_WW GEMDOS,#$158,d0,d1
   rts
   
   .ENDMOD

.MODULE Psetpriority:
   SYS_WWW GEMDOS,#$159,d0,d1,d2
   rts
   
   .ENDMOD
