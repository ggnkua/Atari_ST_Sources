; MINTLIB.S
;
; Libary fÅr die MiNT-Funktionen ab MiNT 0.95
; 
; Oktober 1992 by Richard Kurz, Vogelherdbogen 62, 7992 Tettnang
; Fido 2:241/7232.5
; FÅr's TOS-Magazin

.export Dclosedir,Dcntl,Dlock,Dopendir,Dpathconf,Dreaddir,Drewinddir
.export Fchmod,Fchown,Fcntl,Fgetchar,Finstat,Flink,Fmidipipe,Foutstat
.export Fpipe,Fputchar,Freadlink,Fselect,Fsymlink,Fxattr,Pause,Pdomain
.export Pfork,Pgetgid,Pgetpgrp,Pgetpid,Pgetppid,Pgetuid,Pkill,Pmsg
.export Pnice,Prenice,Prusage,Psemaphore,Psetgid,Psetlimit,Psetpgrp
.export Psetuid,Psigaction,Psigblock,Psignal,Psigpause,Psigpending
.export Psigreturn,Psigsetmask,Pumask,Pusrval,Pvfork,Pwait,Pwait3,Syield
.export Sysconf,Talarm

plus2:
    trap     #1
    addq.l   #2,sp
    movea.l (sp)+,a2
    rts

plus4:
    trap     #1
    addq.l   #4,sp
    movea.l (sp)+,a2
    rts

plus6:
    trap     #1
    addq.l   #6,sp
    movea.l (sp)+,a2
    rts

plus8:
    trap     #1
    addq.l   #8,sp
    movea.l (sp)+,a2
    rts

plus10:
    trap     #1
    lea      10(sp),sp
    movea.l (sp)+,a2
    rts

plus12:
    trap     #1
    lea      12(sp),sp
    movea.l (sp)+,a2
    rts


Dclosedir:
    move.l   a2,-(sp)
    move.l   d0,-(sp)
    move.w   #$12b,-(sp)
    bra      plus6

Dcntl:
    move.l   a2,-(sp)
    move.l   d1,-(sp)
    move.l   a0,-(sp)
    move.w   d0,-(sp)
    move.w   #$130,-(sp)
    bra      plus12

Dlock:
    move.l   a2,-(sp)
    move.w   d1,-(sp)
    move.w   d0,-(sp)
    move.w   #$135,-(sp)
    bra      plus6

Dopendir:
    move.l   a2,-(sp)
    move.w   d0,-(sp)
    move.l   a0,-(sp)
    move.w   #$128,-(sp)
    bra      plus8

Dreaddir:
    move.l   a2,-(sp)
    move.l   a0,-(sp)
    move.l   d1,-(sp)
    move.w   d0,-(sp)
    move.w   #$129,-(sp)
    bra      plus12

Drewinddir:
    move.l   a2,-(sp)
    move.l   d0,-(sp)
    move.w   #$12a,-(sp)
    bra      plus6

Fchmod:
    move.l   a2,-(sp)
    move.w   d0,-(sp)
    move.l   a0,-(sp)
    move.w   #$132,-(sp)
    bra      plus8

Fchown:
    move.l   a2,-(sp)
    move.w   d1,-(sp)
    move.w   d0,-(sp)
    move.l   a0,-(sp)
    move.w   #$131,-(sp)
    bra      plus10

Fcntl:
    move.l   a2,-(sp)
    move.w   d2,-(sp)
    move.l   d1,-(sp)
    move.w   d0,-(sp)
    move.w   #$104,-(sp)
    bra      plus10

Fgetchar:
    move.l   a2,-(sp)
    move.w   d1,-(sp)
    move.w   d0,-(sp)
    move.w   #$107,-(sp)
    bra      plus6

Finstat:
    move.l   a2,-(sp)
    move.w   d0,-(sp)
    move.w   #$105,-(sp)
    bra      plus4

Flink:
    move.l   a2,-(sp)
    move.l   a1,-(sp)
    move.l   a0,-(sp)
    move.w   #$12d,-(sp)
    bra      plus10

Fmidipipe:
    move.l   a2,-(sp)
    move.w   d2,-(sp)
    move.w   d1,-(sp)
    move.w   d0,-(sp)
    move.w   #$126,-(sp)
    bra      plus8

Foutstat:
    move.l   a2,-(sp)
    move.w   d0,-(sp)
    move.w   #$106,-(sp)
    bra      plus4

Fpipe:
    move.l   a2,-(sp)
    move.l   a0,-(sp)
    move.w   #$100,-(sp)
    bra      plus6

Fputchar:
    move.l   a2,-(sp)
    move.w   d2,-(sp)
    move.l   d1,-(sp)
    move.w   d0,-(sp)
    move.w   #$108,-(sp)
    bra      plus10

Freadlink:
    move.l   a2,-(sp)
    move.l   a1,-(sp)
    move.l   a0,-(sp)
    move.w   d0,-(sp)
    move.w   #$12f,-(sp)
    bra      plus12

Fselect:
    move.l   a2,-(sp)
    move.l   8(sp),-(sp)
    move.l   a1,-(sp)
    move.l   a0,-(sp)
    move.w   d0,-(sp)
    move.w   #$11d,-(sp)
    trap  #1
    lea      16(sp),sp
    move.l   (sp)+,a2
    rts

Fsymlink:
    move.l   a2,-(sp)
    move.l   a1,-(sp)
    move.l   a0,-(sp)
    move.w   #$12e,-(sp)
    bra      plus10

Fxattr:
    move.l   a2,-(sp)
    move.l   a1,-(sp)
    move.l   a0,-(sp)
    move.w   d0,-(sp)
    move.w   #$12c,-(sp)
    bra      plus12

Pause:
    move.l   a2,-(sp)
    move.w   #$121,-(sp)
    bra      plus2

Pdomain:
    move.l   a2,-(sp)
    move.w   d0,-(sp)
    move.w   #$119,-(sp)
    bra      plus4

Pfork:
    move.l   a2,-(sp)
    move.w   #$11b,-(sp)
    bra      plus2

Pgetgid:
    move.l   a2,-(sp)
    move.w   #$114,-(sp)
    bra      plus2

Pgetpgrp:
    move.l   a2,-(sp)
    move.w   #$10d,-(sp)
    bra      plus2

Pgetpid:
    move.l   a2,-(sp)
    move.w   #$10b,-(sp)
    bra      plus2

Pgetppid:
    move.l   a2,-(sp)
    move.w   #$10c,-(sp)
    bra      plus2

Pgetuid:
    move.l   a2,-(sp)
    move.w   #$10f,-(sp)
    bra      plus2

Pkill:
    move.l   a2,-(sp)
    move.w   d1,-(sp)
    move.w   d0,-(sp)
    move.w   #$111,-(sp)
    bra      plus6

Pmsg:
    move.l   a2,-(sp)
    move.l   a0,-(sp)
    move.l   d1,-(sp)
    move.w   d0,-(sp)
    move.w   #$125,-(sp)
    bra      plus12

Pnice:
    move.l   a2,-(sp)
    move.w   d0,-(sp)
    move.w   #$10a,-(sp)
    bra      plus4

Prenice:
    move.l   a2,-(sp)
    move.w   d1,-(sp)
    move.w   d0,-(sp)
    move.w   #$127,-(sp)
    bra      plus6

Prusage:
    move.l   a2,-(sp)
    move.l   a0,-(sp)
    move.w   #$11e,-(sp)
    bra      plus6

Psemaphore:
    move.l   a2,-(sp)
    move.l   d2,-(sp)
    move.l   d1,-(sp)
    move.w   d0,-(sp)
    move.w   #$134,-(sp)
    bra      plus12

Psetgid:
    move.l   a2,-(sp)
    move.w   d0,-(sp)
    move.w   #$115,-(sp)
    bra      plus4

Psetlimit:
    move.l   a2,-(sp)
    move.l   d1,-(sp)
    move.w   d0,-(sp)
    move.w   #$11f,-(sp)
    bra      plus8

Psetpgrp:
    move.l   a2,-(sp)
    move.w   d1,-(sp)
    move.w   d0,-(sp)
    move.w   #$10e,-(sp)
    bra      plus6

Psetuid:
    move.l   a2,-(sp)
    move.w   d0,-(sp)
    move.w   #$110,-(sp)
    bra      plus4

Psigaction:
    move.l   a2,-(sp)
    move.l   d2,-(sp)
    move.l   d1,-(sp)
    move.w   d0,-(sp)
    move.w   #$137,-(sp)
    bra      plus12

Psigblock:
    move.l   a2,-(sp)
    move.l   d0,-(sp)
    move.w   #$116,-(sp)
    bra      plus6

Psignal:
    move.l   a2,-(sp)
    move.l   d1,-(sp)
    move.w   d0,-(sp)
    move.w   #$112,-(sp)
    bra      plus8

Psigpause:
    move.l   a2,-(sp)
    move.l   d0,-(sp)
    move.w   #$136,-(sp)
    bra      plus6

Psigpending:
    move.l   a2,-(sp)
    move.w   #$123,-(sp)
    bra      plus2

Psigreturn:
    move.l   a2,-(sp)
    move.w   #$11a,-(sp)
    bra      plus2

Psigsetmask:
    move.l   a2,-(sp)
    move.l   d0,-(sp)
    move.w   #$117,-(sp)
    bra      plus6

Pusrval:
    move.l   a2,-(sp)
    move.l   d0,-(sp)
    move.w   #$118,-(sp)
    bra      plus6

Pvfork:
    move.l   a2,-(sp)
    move.w   #$113,-(sp)
    bra      plus2

Pwait:
    move.l   a2,-(sp)
    move.w   #$109,-(sp)
    bra      plus2

Pwait3:
    move.l   a2,-(sp)
    move.l   a0,-(sp)
    move.w   d0,-(sp)
    move.w   #$11c,-(sp)
    bra      plus8

Syield:
    move.l   a2,-(sp)
    move.w   #$ff,-(sp)
    bra      plus2

Sysconf:
    move.l   a2,-(sp)
    move.w   d0,-(sp)
    move.w   #$122,-(sp)
    bra      plus4

Talarm:
    move.l   a2,-(sp)
    move.l   d0,-(sp)
    move.w   #$120,-(sp)
    bra      plus6

