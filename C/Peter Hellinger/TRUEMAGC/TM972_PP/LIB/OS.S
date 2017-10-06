; UNIT OS  (C)96 by Peter Hellinger Software
; Funktionen des Operation Systems
;
;
; +---------------------------------------------------------------------
; |  Exported symbols
; +---------------------------------------------------------------------

    EXPORT     XBTIMER
    EXPORT     VSYNC
    EXPORT     SUPEXEC
    EXPORT     SSBRK
    EXPORT     SETTIME
    EXPORT     SETSCREEN
    EXPORT     SETPRT
    EXPORT     SETPALETTE
    EXPORT     SETCOLOR
    EXPORT     SCRDMP
    EXPORT     RSCONF
    EXPORT     RANDOM
    EXPORT     PUNTAES
    EXPORT     PRTBLK
    EXPORT     PROTOBT
    EXPORT     PHYSBASE
    EXPORT     ONGIBIT
    EXPORT     OFFGIBIT
    EXPORT     MIDIWS
    EXPORT     MFPINT
    EXPORT     METAINIT
    EXPORT     LOGBASE
    EXPORT     KEYTBL
    EXPORT     KBRATE
    EXPORT     KBDVBASE
    EXPORT     JENABINT
    EXPORT     JDISINT
    EXPORT     IOREC
    EXPORT     INITMOUS
    EXPORT     IKBDWS
    EXPORT     GIACCESS
    EXPORT     GETTIME
    EXPORT     GETREZ
    EXPORT     FLOPWR
    EXPORT     FLOPVER
    EXPORT     FLOPRD
    EXPORT     FLOPRATE
    EXPORT     FLOPFMT
    EXPORT     ESETSMEAR
    EXPORT     ESETSHIFT
    EXPORT     ESETPALETTE
    EXPORT     ESETGRAY
    EXPORT     ESETCOLOR
    EXPORT     ESETBANK
    EXPORT     EGETSHIFT
    EXPORT     EGETPALETTE
    EXPORT     DOSOUND
    EXPORT     DMAWRITE
    EXPORT     DMAREAD
    EXPORT     CURSCONF
    EXPORT     BLITMODE
    EXPORT     BIOSKEYS
    EXPORT     BCONMAP
    EXPORT     DSP_DOBLOCK
    EXPORT     DSP_BLKHANDSHAKE
    EXPORT     DSP_BLKUNPACKED
    EXPORT     DSP_INSTREAM
    EXPORT     DSP_OUTSTREAM
    EXPORT     DSP_IOSTREAM
    EXPORT     DSP_REMOVEINTERRUPTS
    EXPORT     DSP_GETWORDSIZE
    EXPORT     DSP_LOCK
    EXPORT     DSP_UNLOCK
    EXPORT     DSP_AVAILABLE
    EXPORT     DSP_RESERVE
    EXPORT     DSP_EXECPROG
    EXPORT     DSP_EXECBOOT
    EXPORT     DSP_TRIGGERHC
    EXPORT     DSP_REQUESTUNIQUEABILITY
    EXPORT     DSP_GETPROGABILITY
    EXPORT     DSP_FLUSHSUBROUTINES
    EXPORT     DSP_LOADSUBROUTINE
    EXPORT     DSP_INQSUBRABILITY
    EXPORT     DSP_RUNSUBROUTINE
    EXPORT     DSP_HF0
    EXPORT     DSP_HF1
    EXPORT     DSP_HF2
    EXPORT     DSP_HF3
    EXPORT     DSP_BLKWORDS
    EXPORT     DSP_BLKBYTES
    EXPORT     DSP_HSTAT
    EXPORT     DSP_SETVECTORS
    EXPORT     DSP_MULTBLOCKS
    EXPORT     VSETMODE
    EXPORT     MON_TYPE
    EXPORT     VGETSIZE
    EXPORT     VSETSYNC
    EXPORT     VSETRGB
    EXPORT     VGETRGB
    EXPORT     VSETMASK
    EXPORT     LOCKSND
    EXPORT     UNLOCKSND
    EXPORT     SOUNDCMD
    EXPORT     SETBUFFER
    EXPORT     SETMODE
    EXPORT     SETTRACKS
    EXPORT     SETMONTRACKS
    EXPORT     SETINTERRUPT
    EXPORT     BUFFOPER
    EXPORT     DSPTRISTATE
    EXPORT     GPIO
    EXPORT     DEVCONNECT
    EXPORT     SNDSTATUS
    EXPORT     BUFFPTR
    EXPORT     NVMACCESS
    EXPORT     _DSP_LOADPROG
    EXPORT     _DSP_LODTOBINARY
    EXPORT     TICKCAL
    EXPORT     SETEXC
    EXPORT     RWABS
    EXPORT     MEDIACH
    EXPORT     KBSHIFT
    EXPORT     GETMPB
    EXPORT     GETBPB
    EXPORT     DRVMAP
    EXPORT     BCOSTAT
    EXPORT     BCONSTAT
    EXPORT     BCONOUT
    EXPORT     BCONIN
    EXPORT     TSETTIME
    EXPORT     TSETDATE
    EXPORT     TGETTIME
    EXPORT     TGETDATE
    EXPORT     SVERSION
    EXPORT     SUPER
    EXPORT     PTERMRES
    EXPORT     PTERM0
    EXPORT     PTERM
    EXPORT     MXALLOC
    EXPORT     MSHRINK
    EXPORT     MFREE
    EXPORT     MALLOC
    EXPORT     MADDALT
    EXPORT     FWRITE
    EXPORT     FSETDTA
    EXPORT     FSEEK
    EXPORT     FREAD
    EXPORT     FLOCK
    EXPORT     FGETDTA
    EXPORT     FFORCE
    EXPORT     FDUP
    EXPORT     FDATIME
    EXPORT     FCLOSE
    EXPORT     DSETDRV
    EXPORT     DGETDRV
    EXPORT     DFREE
    EXPORT     CRAWIO
    EXPORT     CRAWCIN
    EXPORT     CPRNOUT
    EXPORT     CPRNOS
    EXPORT     CNECIN
    EXPORT     CCONRS
    EXPORT     CCONOUT
    EXPORT     CCONOS
    EXPORT     CCONIS
    EXPORT     CCONIN
    EXPORT     CAUXOUT
    EXPORT     CAUXOS
    EXPORT     CAUXIS
    EXPORT     CAUXIN
    EXPORT     SYIELD
    EXPORT     FPIPE
    EXPORT     FCNTL
    EXPORT     FINSTAT
    EXPORT     FOUTSTAT
    EXPORT     FGETCHAR
    EXPORT     FPUTCHAR
    EXPORT     PWAIT
    EXPORT     PNICE
    EXPORT     PGETPID
    EXPORT     PGETPPID
    EXPORT     PGETPGRP
    EXPORT     PSETPGRP
    EXPORT     PGETUID
    EXPORT     PSETUID
    EXPORT     PKILL
    EXPORT     PSIGNAL
    EXPORT     PVFORK
    EXPORT     PGETGID
    EXPORT     PSETGID
    EXPORT     PSIGBLOCK
    EXPORT     PSIGSETMASK
    EXPORT     PUSRVAL
    EXPORT     PDOMAIN
    EXPORT     PSIGRETURN
    EXPORT     PFORK
    EXPORT     PWAIT3
    EXPORT     FSELECT
    EXPORT     PRUSAGE
    EXPORT     PSETLIMIT
    EXPORT     TALARM
    EXPORT     PAUSE
    EXPORT     SYSCONF
    EXPORT     PSIGPENDING
    EXPORT     PMSG
    EXPORT     FMIDIPIPE
    EXPORT     PRENICE
    EXPORT     DREWINDDIR
    EXPORT     DCLOSEDIR
    EXPORT     PUMASK
    EXPORT     PSEMAPHORE
    EXPORT     DLOCK
    EXPORT     PSIGPAUSE
    EXPORT     PSIGACTION
    EXPORT     PGETEUID
    EXPORT     PGETEGID
    EXPORT     PWAITPID
    EXPORT     _PEXEC
    EXPORT     FSNEXT
    EXPORT     _FSFIRST
    EXPORT     _FRENAME
    EXPORT     _FOPEN
    EXPORT     _FDELETE
    EXPORT     _FCREATE
    EXPORT     _FATTRIB
    EXPORT     _DSETPATH
    EXPORT     _DGETPATH
    EXPORT     _DDELETE
    EXPORT     _DCREATE
    EXPORT     _CCONWS
    EXPORT     _SALERT
    EXPORT     _DPATHCONF
    EXPORT     _DOPENDIR
    EXPORT     _DREADDIR
    EXPORT     _FXATTR
    EXPORT     _FLINK
    EXPORT     _FSYMLINK
    EXPORT     _FREADLINK
    EXPORT     _DCNTL
    EXPORT     _FCHOWN
    EXPORT     _FCHMOD
    EXPORT     _DGETCWD
    


    MC68000
    TEXT

_DGETCWD:    PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      D1,-(A7)
             PEA.L       (A0)
             MOVE.W      #$13B,-(A7)
             TRAP        #1
             LEA.L       $000A(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

XBTIMER:     PEA.L       (A2)
             PEA.L       (A0)
             MOVEM.W     D0-D2,-(A7)
             MOVE.W      #$001F,-(A7)
             TRAP        #14
             LEA.L       $000C(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

VSYNC:
             PEA.L       (A2)
             MOVE.W      #$0025,-(A7)
             TRAP        #14
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

SUPEXEC:     PEA.L       (A2)
             PEA.L       (A0)
             MOVE.W      #$0026,-(A7)
             TRAP        #14
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

SSBRK:       PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0001,-(A7)
             TRAP        #14
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

SETTIME:     PEA.L       (A2)
             MOVE.L      D0,-(A7)
             MOVE.W      #$0016,-(A7)
             TRAP        #14
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

SETSCREEN:   PEA.L       (A2)
             MOVE.W      D0,-(A7)
             PEA.L       (A1)
             PEA.L       (A0)
             MOVE.W      #$0005,-(A7)
             TRAP        #14
             LEA.L       $000C(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

SETPRT:      PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0021,-(A7)
             TRAP        #14
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

SETPALETTE:  PEA.L       (A2)
             PEA.L       (A0)
             MOVE.W      #$0006,-(A7)
             TRAP        #14
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

SETCOLOR:    PEA.L       (A2)
             MOVE.W      D1,-(A7)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0007,-(A7)
             TRAP        #14
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

SCRDMP:      PEA.L       (A2)
             MOVE.W      #$0014,-(A7)
             TRAP        #14
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

RSCONF:      PEA.L       (A2)
             MOVE.W      $000C(A7),-(A7)
             MOVE.L      $000A(A7),-(A7)
             MOVEM.W     D0-D2,-(A7)
             MOVE.W      #$000F,-(A7)
             TRAP        #14
             LEA.L       $000E(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

RANDOM:      PEA.L       (A2)
             MOVE.W      #$0011,-(A7)
             TRAP        #14
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

PUNTAES:     PEA.L       (A2)
             MOVE.W      #$0027,-(A7)
             TRAP        #14
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

PRTBLK:      PEA.L       (A2)
             PEA.L       (A0)
             MOVE.W      #$0024,-(A7)
             TRAP        #14
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

PROTOBT:     PEA.L       (A2)
             MOVE.W      D2,-(A7)
             MOVE.W      D1,-(A7)
             MOVE.L      D0,-(A7)
             PEA.L       (A0)
             MOVE.W      #$0012,-(A7)
             TRAP        #14
             LEA.L       $000E(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

PHYSBASE:    PEA.L       (A2)
             MOVE.W      #$0002,-(A7)
             TRAP        #14
             ADDQ.W      #2,A7
             MOVEA.L     D0,A0
             MOVEA.L     (A7)+,A2
             RTS

ONGIBIT:     PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$001E,-(A7)
             TRAP        #14
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

OFFGIBIT:    PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$001D,-(A7)
             TRAP        #14
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

MIDIWS:      MOVEM.L     D0/A0/A2,-(A7)
             MOVE.W      #$000C,(A7)
             TRAP        #14
             ADDQ.W      #8,A7
             MOVEA.L     (A7)+,A2
             RTS

MFPINT:      MOVEM.L     D0/A0/A2,-(A7)
             MOVE.W      #$000D,(A7)
             TRAP        #14
             ADDQ.W      #8,A7
             MOVEA.L     (A7)+,A2
             RTS

METAINIT:    PEA.L       (A2)
             PEA.L       (A0)
             MOVE.W      #$0030,-(A7)
             TRAP        #14
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

LOGBASE:     PEA.L       (A2)
             MOVE.W      #$0003,-(A7)
             TRAP        #14
             ADDQ.W      #2,A7
             MOVEA.L     D0,A0
             MOVEA.L     (A7)+,A2
             RTS

KEYTBL:      PEA.L       (A2)
             MOVE.L      $0008(A7),-(A7)
             PEA.L       (A1)
             PEA.L       (A0)
             MOVE.W      #$0010,-(A7)
             TRAP        #14
             LEA.L       $000E(A7),A7
             MOVEA.L     D0,A0
             MOVEA.L     (A7)+,A2
             RTS

KBRATE:      PEA.L       (A2)
             MOVE.W      D1,-(A7)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0023,-(A7)
             TRAP        #14
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

KBDVBASE:    PEA.L       (A2)
             MOVE.W      #$0022,-(A7)
             TRAP        #14
             ADDQ.W      #2,A7
             MOVEA.L     D0,A0
             MOVEA.L     (A7)+,A2
             RTS

JENABINT:    PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$001B,-(A7)
             TRAP        #14
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

JDISINT:     PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$001A,-(A7)
             TRAP        #14
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

IOREC:       PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$000E,-(A7)
             TRAP        #14
             ADDQ.W      #4,A7
             MOVEA.L     D0,A0
             MOVEA.L     (A7)+,A2
             RTS

INITMOUS:    MOVEM.L     D0/A0-A2,-(A7)
             CLR.W       (A7)
             TRAP        #14
             LEA.L       $000C(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

IKBDWS:      MOVEM.L     D0/A0/A2,-(A7)
             MOVE.W      #$0019,(A7)
             TRAP        #14
             ADDQ.W      #8,A7
             MOVEA.L     (A7)+,A2
             RTS

GIACCESS:    PEA.L       (A2)
             MOVE.W      D1,-(A7)
             MOVE.W      D0,-(A7)
             MOVE.W      #$001C,-(A7)
             TRAP        #14
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

GETTIME:     PEA.L       (A2)
             MOVE.W      #$0017,-(A7)
             TRAP        #14
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

GETREZ:      PEA.L       (A2)
             MOVE.W      #$0004,-(A7)
             TRAP        #14
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

FLOPWR:      PEA.L       (A2)
             MOVE.L      $0008(A7),-(A7)
             MOVEM.W     D0-D2,-(A7)
             PEA.L       (A1)
             PEA.L       (A0)
             MOVE.W      #$0009,-(A7)
             TRAP        #14
             LEA.L       $0014(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

FLOPVER:     PEA.L       (A2)
             MOVE.L      $0008(A7),-(A7)
             MOVEM.W     D0-D2,-(A7)
             PEA.L       (A1)
             PEA.L       (A0)
             MOVE.W      #$0013,-(A7)
             TRAP        #14
             LEA.L       $0014(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

FLOPRD:      PEA.L       (A2)
             MOVE.L      $0008(A7),-(A7)
             MOVEM.W     D0-D2,-(A7)
             PEA.L       (A1)
             PEA.L       (A0)
             MOVE.W      #$0008,-(A7)
             TRAP        #14
             LEA.L       $0014(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

FLOPRATE:    PEA.L       (A2)
             MOVE.W      D1,-(A7)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0029,-(A7)
             TRAP        #14
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

FLOPFMT:     PEA.L       (A2)
             MOVE.W      $0010(A7),-(A7)
             MOVE.L      $000E(A7),-(A7)
             MOVE.L      $000E(A7),-(A7)
             MOVEM.W     D0-D2,-(A7)
             PEA.L       (A1)
             PEA.L       (A0)
             MOVE.W      #$000A,-(A7)
             TRAP        #14
             LEA.L       $001A(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

ESETSMEAR:   PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0057,-(A7)
             TRAP        #14
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

ESETSHIFT:   PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0050,-(A7)
             TRAP        #14
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

ESETPALETTE: PEA.L       (A2)
             PEA.L       (A0)
             MOVE.W      D1,-(A7)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0054,-(A7)
             TRAP        #14
             LEA.L       $000A(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

ESETGRAY:    PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0056,-(A7)
             TRAP        #14
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

ESETCOLOR:   PEA.L       (A2)
             MOVE.W      D1,-(A7)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0053,-(A7)
             TRAP        #14
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

ESETBANK:    PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0052,-(A7)
             TRAP        #14
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

EGETSHIFT:   PEA.L       (A2)
             MOVE.W      #$0051,-(A7)
             TRAP        #14
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

EGETPALETTE: PEA.L       (A2)
             PEA.L       (A0)
             MOVE.W      D1,-(A7)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0055,-(A7)
             TRAP        #14
             LEA.L       $000A(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

DOSOUND:     PEA.L       (A2)
             PEA.L       (A0)
             MOVE.W      #$0020,-(A7)
             TRAP        #14
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

DMAWRITE:    PEA.L       (A2)
             MOVE.W      D2,-(A7)
             PEA.L       (A0)
             MOVE.W      D1,-(A7)
             MOVE.L      D0,-(A7)
             MOVE.W      #$002B,-(A7)
             TRAP        #14
             LEA.L       $000E(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

DMAREAD:     PEA.L       (A2)
             MOVE.W      D2,-(A7)
             PEA.L       (A0)
             MOVE.W      D1,-(A7)
             MOVE.L      D0,-(A7)
             MOVE.W      #$002A,-(A7)
             TRAP        #14
             LEA.L       $000E(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

CURSCONF:    PEA.L       (A2)
             MOVE.W      D1,-(A7)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0015,-(A7)
             TRAP        #14
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

BLITMODE:    PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0040,-(A7)
             TRAP        #14
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

BIOSKEYS:    PEA.L       (A2)
             MOVE.W      #$0018,-(A7)
             TRAP        #14
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

BCONMAP:     PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$002C,-(A7)
             TRAP        #14
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

DSP_DOBLOCK: PEA.L       (A2)
             MOVE.L      D1,-(A7)
             PEA.L       (A1)
             MOVE.L      D0,-(A7)
             PEA.L       (A0)
             MOVE.W      #$0060,-(A7)
             TRAP        #14
             LEA.L       $0012(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

DSP_BLKHANDSHAKE:
             PEA.L       (A2)
             MOVE.L      D1,-(A7)
             PEA.L       (A1)
             MOVE.L      D0,-(A7)
             PEA.L       (A0)
             MOVE.W      #$0061,-(A7)
             TRAP        #14
             LEA.L       $0012(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

DSP_BLKUNPACKED:
             PEA.L       (A2)
             MOVE.L      D1,-(A7)
             PEA.L       (A1)
             MOVE.L      D0,-(A7)
             PEA.L       (A0)
             MOVE.W      #$0062,-(A7)
             TRAP        #14
             LEA.L       $0012(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

DSP_INSTREAM:
             MOVEM.L     D0-D1/A1-A2,-(A7)
             PEA.L       (A0)
             MOVE.W      #$0063,-(A7)
             TRAP        #14
             LEA.L       $0012(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

DSP_OUTSTREAM:
             MOVEM.L     D0-D1/A1-A2,-(A7)
             PEA.L       (A0)
             MOVE.W      #$0064,-(A7)
             TRAP        #14
             LEA.L       $0012(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

DSP_IOSTREAM:
             PEA.L       (A2)
             MOVE.L      $0008(A7),-(A7)
             MOVEM.L     D0-D2,-(A7)
             PEA.L       (A1)
             PEA.L       (A0)
             MOVE.W      #$0065,-(A7)
             TRAP        #14
             LEA.L       $0016(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

DSP_REMOVEINTERRUPTS:
             PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0066,-(A7)
             TRAP        #14
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

DSP_GETWORDSIZE:
             PEA.L       (A2)
             MOVE.W      #$0067,-(A7)
             TRAP        #14
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

DSP_LOCK:    PEA.L       (A2)
             MOVE.W      #$0068,-(A7)
             TRAP        #14
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

DSP_UNLOCK:  PEA.L       (A2)
             MOVE.W      #$0069,-(A7)
             TRAP        #14
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

DSP_AVAILABLE:
             MOVEM.L     A0-A2,-(A7)
             MOVE.W      #$006A,-(A7)
             TRAP        #14
             LEA.L       $000A(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

DSP_RESERVE: MOVEM.L     D0-D1/A2,-(A7)
             MOVE.W      #$006B,-(A7)
             TRAP        #14
             LEA.L       $000A(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

DSP_EXECPROG:
             PEA.L       (A2)
             MOVE.W      D1,-(A7)
             MOVE.L      D0,-(A7)
             PEA.L       (A0)
             MOVE.W      #$006D,-(A7)
             TRAP        #14
             LEA.L       $000C(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

DSP_EXECBOOT:
             PEA.L       (A2)
             MOVE.W      D1,-(A7)
             MOVE.L      D0,-(A7)
             PEA.L       (A0)
             MOVE.W      #$006E,-(A7)
             TRAP        #14
             LEA.L       $000C(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

DSP_TRIGGERHC:
             PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0070,-(A7)
             TRAP        #14
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

DSP_REQUESTUNIQUEABILITY:
             PEA.L       (A2)
             MOVE.W      #$0071,-(A7)
             TRAP        #14
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

DSP_GETPROGABILITY:
             PEA.L       (A2)
             MOVE.W      #$0072,-(A7)
             TRAP        #14
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

DSP_FLUSHSUBROUTINES:
             PEA.L       (A2)
             MOVE.W      #$0073,-(A7)
             TRAP        #14
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

DSP_LOADSUBROUTINE:
             PEA.L       (A2)
             MOVE.W      D1,-(A7)
             MOVE.L      D0,-(A7)
             PEA.L       (A0)
             MOVE.W      #$0074,-(A7)
             TRAP        #14
             LEA.L       $000C(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

DSP_INQSUBRABILITY:
             PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0075,-(A7)
             TRAP        #14
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

DSP_RUNSUBROUTINE:
             PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0076,-(A7)
             TRAP        #14
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

DSP_HF0:     PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0077,-(A7)
             TRAP        #14
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

DSP_HF1:     PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0078,-(A7)
             TRAP        #14
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

DSP_HF2:     PEA.L       (A2)
             MOVE.W      #$0079,-(A7)
             TRAP        #14
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

DSP_HF3:     PEA.L       (A2)
             MOVE.W      #$007A,-(A7)
             TRAP        #14
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

DSP_BLKWORDS:
             PEA.L       (A2)
             MOVE.L      D1,-(A7)
             PEA.L       (A1)
             MOVE.L      D0,-(A7)
             PEA.L       (A0)
             MOVE.W      #$007B,-(A7)
             TRAP        #14
             LEA.L       $0012(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

DSP_BLKBYTES:
             PEA.L       (A2)
             MOVE.L      D1,-(A7)
             PEA.L       (A1)
             MOVE.L      D0,-(A7)
             PEA.L       (A0)
             MOVE.W      #$007C,-(A7)
             TRAP        #14
             LEA.L       $0012(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

DSP_HSTAT:   PEA.L       (A2)
             MOVE.W      #$007D,-(A7)
             TRAP        #14
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

DSP_SETVECTORS:
             MOVEM.L     A0-A2,-(A7)
             MOVE.W      #$007E,-(A7)
             TRAP        #14
             LEA.L       $000A(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

DSP_MULTBLOCKS:
             MOVEM.L     D0-D1/A0-A2,-(A7)
             MOVE.W      #$007F,-(A7)
             TRAP        #14
             LEA.L       $0012(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

VSETMODE:    PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0058,-(A7)
             TRAP        #14
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

MON_TYPE:    PEA.L       (A2)
             MOVE.W      #$0059,-(A7)
             TRAP        #14
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

VGETSIZE:    PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$005B,-(A7)
             TRAP        #14
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

VSETSYNC:    PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$005A,-(A7)
             TRAP        #14
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

VSETRGB:     PEA.L       (A2)
             PEA.L       (A0)
             MOVE.W      D1,-(A7)
             MOVE.W      D0,-(A7)
             MOVE.W      #$005D,-(A7)
             TRAP        #14
             LEA.L       $000A(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

VGETRGB:     PEA.L       (A2)
             PEA.L       (A0)
             MOVE.W      D1,-(A7)
             MOVE.W      D0,-(A7)
             MOVE.W      #$005E,-(A7)
             TRAP        #14
             LEA.L       $000A(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

VSETMASK:    PEA.L       (A2)
             MOVEM.W     D0-D2,-(A7)
             MOVE.W      #$0096,-(A7)
             TRAP        #14
             ADDQ.W      #8,A7
             MOVEA.L     (A7)+,A2
             RTS

LOCKSND:     PEA.L       (A2)
             MOVE.W      #$0080,-(A7)
             TRAP        #14
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

UNLOCKSND:   PEA.L       (A2)
             MOVE.W      #$0081,-(A7)
             TRAP        #14
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

SOUNDCMD:    PEA.L       (A2)
             MOVE.W      D1,-(A7)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0082,-(A7)
             TRAP        #14
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

SETBUFFER:   MOVEM.L     D0/A0-A2,-(A7)
             MOVE.W      #$0083,(A7)
             TRAP        #14
             LEA.L       $000C(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

SETMODE:     PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0084,-(A7)
             TRAP        #14
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

SETTRACKS:   PEA.L       (A2)
             MOVE.W      D1,-(A7)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0085,-(A7)
             TRAP        #14
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

SETMONTRACKS:
             PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0086,-(A7)
             TRAP        #14
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

SETINTERRUPT:
             PEA.L       (A2)
             MOVE.W      D1,-(A7)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0087,-(A7)
             TRAP        #14
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

BUFFOPER:    PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0088,-(A7)
             TRAP        #14
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

DSPTRISTATE: PEA.L       (A2)
             MOVE.W      D1,-(A7)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0089,-(A7)
             TRAP        #14
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

GPIO:        PEA.L       (A2)
             MOVE.W      D1,-(A7)
             MOVE.W      D0,-(A7)
             MOVE.W      #$008A,-(A7)
             TRAP        #14
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

DEVCONNECT:  PEA.L       (A2)
             MOVE.L      $0008(A7),-(A7)
             MOVEM.W     D0-D2,-(A7)
             MOVE.W      #$008B,-(A7)
             TRAP        #14
             LEA.L       $000C(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

SNDSTATUS:   PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$008C,-(A7)
             TRAP        #14
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

BUFFPTR:     PEA.L       (A2)
             PEA.L       (A0)
             MOVE.W      #$008D,-(A7)
             TRAP        #14
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

NVMACCESS:   PEA.L       (A2)
             PEA.L       (A0)
             MOVEM.W     D0-D2,-(A7)
             MOVE.W      #$002E,-(A7)
             TRAP        #14
             LEA.L       $000C(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

_DSP_LOADPROG:
             PEA.L       (A2)
             PEA.L       (A1)
             MOVE.W      D0,-(A7)
             PEA.L       (A0)
             MOVE.W      #$006C,-(A7)
             TRAP        #14
             LEA.L       $0C(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

_DSP_LODTOBINARY:
             PEA.L       (A2)
             PEA.L       (A1)
             PEA.L       (A0)
             MOVE.W      #$006F,-(A7)
             TRAP        #14
             LEA.L       $0A(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

TICKCAL:     PEA.L       (A2)
             MOVE.W      #$0006,-(A7)
             TRAP        #13
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

SETEXC:      PEA         (A2)
             PEA         (A0)
             MOVE.W      D0,-(A7)
             MOVE.W      #5,-(A7)
             TRAP        #13
             ADDQ.W      #8,A7
             MOVEA.L     D0,A0
             MOVEA.L      (A7)+,A2
             RTS

RWABS:       PEA.L       (A2)
             MOVE.L      $000A(A7),-(A7)
             MOVE.W      $000C(A7),-(A7)
             MOVE.W      D2,-(A7)
             MOVE.W      D1,-(A7)
             PEA.L       (A0)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0004,-(A7)
             TRAP        #13
             LEA.L       $0012(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

MEDIACH:     PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0009,-(A7)
             TRAP        #13
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

KBSHIFT:     PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$000B,-(A7)
             TRAP        #13
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

GETMPB:      PEA.L       (A2)
             PEA.L       (A0)
             CLR.W       -(A7)
             TRAP        #13
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

GETBPB:      PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0007,-(A7)
             TRAP        #13
             ADDQ.W      #4,A7
             MOVEA.L     D0,A0
             MOVEA.L     (A7)+,A2
             RTS

DRVMAP:      PEA.L       (A2)
             MOVE.W      #$000A,-(A7)
             TRAP        #13
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

BCOSTAT:     PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0008,-(A7)
             TRAP        #13
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

BCONSTAT:    PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0001,-(A7)
             TRAP        #13
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

BCONOUT:     PEA.L       (A2)
             MOVE.W      D1,-(A7)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0003,-(A7)
             TRAP        #13
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

BCONIN:      PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0002,-(A7)
             TRAP        #13
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

TSETTIME:    PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$002D,-(A7)
             TRAP        #1
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

TSETDATE:    PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$002B,-(A7)
             TRAP        #1
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

TGETTIME:    PEA.L       (A2)
             MOVE.W      #$002C,-(A7)
             TRAP        #1
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

TGETDATE:    PEA.L       (A2)
             MOVE.W      #$002A,-(A7)
             TRAP        #1
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

SVERSION:    PEA.L       (A2)
             MOVE.W      #$0030,-(A7)
             TRAP        #1
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

SUPER:       PEA.L       (A2)
             PEA.L       (A0)
             MOVE.W      #$0020,-(A7)
             TRAP        #1
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

PTERMRES:    MOVE.W      D1,-(A7)
             MOVE.L      D0,-(A7)
             MOVE.W      #$0031,-(A7)
             TRAP        #1

PTERM0:      CLR.W       -(A7)
             TRAP        #1

PTERM:       MOVE.W      D0,-(A7)
             MOVE.W      #$004C,-(A7)
             TRAP        #1

MXALLOC:     PEA.L       (A2)
             MOVE.W      D1,-(A7)
             MOVE.L      D0,-(A7)
             MOVE.W      #$0044,-(A7)
             TRAP        #1
             ADDQ.W      #8,A7
             MOVEA.L     D0,A0
             MOVEA.L     (A7)+,A2
             RTS

MSHRINK:     PEA.L       (A2)
             MOVE.L      D1,-(A7)
             PEA.L       (A0)
             MOVE.W      D0,-(A7)
             MOVE.W      #$004A,-(A7)
             TRAP        #1
             LEA.L       $000C(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

MFREE:       PEA.L       (A2)
             PEA.L       (A0)
             MOVE.W      #$0049,-(A7)
             TRAP        #1
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

MALLOC:      PEA.L       (A2)
             MOVE.L      D0,-(A7)
             MOVE.W      #$0048,-(A7)
             TRAP        #1
             ADDQ.W      #6,A7
             MOVEA.L     D0,A0
             MOVEA.L     (A7)+,A2
             RTS

MADDALT:     PEA.L       (A2)
             MOVE.L      D0,-(A7)
             PEA.L       (A0)
             MOVE.W      #$0014,-(A7)
             TRAP        #1
             LEA.L       $000A(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

FWRITE:      PEA.L       (A2)
             PEA.L       (A0)
             MOVE.L      D1,-(A7)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0040,-(A7)
             TRAP        #1
             LEA.L       $000C(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

FSETDTA:     PEA.L       (A2)
             PEA.L       (A0)
             MOVE.W      #$001A,-(A7)
             TRAP        #1
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

FSEEK:       PEA.L       (A2)
             MOVE.W      D2,-(A7)
             MOVE.W      D1,-(A7)
             MOVE.L      D0,-(A7)
             MOVE.W      #$0042,-(A7)
             TRAP        #1
             LEA.L       $000A(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

FREAD:       PEA.L       (A2)
             PEA.L       (A0)
             MOVE.L      D1,-(A7)
             MOVE.W      D0,-(A7)
             MOVE.W      #$003F,-(A7)
             TRAP        #1
             LEA.L       $000C(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

FLOCK:       PEA.L       (A2)
             MOVE.L      $0008(A7),-(A7)
             MOVE.L      D2,-(A7)
             MOVE.W      D1,-(A7)
             MOVE.W      D0,-(A7)
             MOVE.W      #$005C,-(A7)
             TRAP        #1
             LEA.L       $000E(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

FGETDTA:     PEA.L       (A2)
             MOVE.W      #$002F,-(A7)
             TRAP        #1
             ADDQ.W      #2,A7
             MOVEA.L     D0,A0
             MOVEA.L     (A7)+,A2
             RTS

FFORCE:      PEA.L       (A2)
             MOVE.W      D1,-(A7)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0046,-(A7)
             TRAP        #1
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

FDUP:        PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0045,-(A7)
             TRAP        #1
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

FDATIME:     PEA.L       (A2)
             MOVE.W      D1,-(A7)
             MOVE.W      D0,-(A7)
             PEA.L       (A0)
             MOVE.W      #$0057,-(A7)
             TRAP        #1
             LEA.L       $000A(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

FCLOSE:      PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$003E,-(A7)
             TRAP        #1
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

DSETDRV:     PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$000E,-(A7)
             TRAP        #1
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

DGETDRV:     PEA.L       (A2)
             MOVE.W      #$0019,-(A7)
             TRAP        #1
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

DFREE:       PEA.L       (A2)
             MOVE.W      D0,-(A7)
             PEA.L       (A0)
             MOVE.W      #$0036,-(A7)
             TRAP        #1
             ADDQ.W      #8,A7
             MOVEA.L     (A7)+,A2
             RTS

CRAWIO:      PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0006,-(A7)
             TRAP        #1
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

CRAWCIN:     PEA.L       (A2)
             MOVE.W      #$0007,-(A7)
             TRAP        #1
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

CPRNOUT:     PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0005,-(A7)
             TRAP        #1
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

CPRNOS:      PEA.L       (A2)
             MOVE.W      #$0011,-(A7)
             TRAP        #1
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

CNECIN:      PEA.L       (A2)
             MOVE.W      #$0008,-(A7)
             TRAP        #1
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

CCONRS:      PEA.L       (A2)
             PEA.L       (A0)
             MOVE.W      #$000A,-(A7)
             TRAP        #1
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

CCONOUT:     PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0002,-(A7)
             TRAP        #1
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

CCONOS:      PEA.L       (A2)
             MOVE.W      #$0010,-(A7)
             TRAP        #1
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

CCONIS:      PEA.L       (A2)
             MOVE.W      #$000B,-(A7)
             TRAP        #1
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

CCONIN:      PEA.L       (A2)
             MOVE.W      #$0001,-(A7)
             TRAP        #1
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

CAUXOUT:     PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0004,-(A7)
             TRAP        #1
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

CAUXOS:      PEA.L       (A2)
             MOVE.W      #$0013,-(A7)
             TRAP        #1
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

CAUXIS:      PEA.L       (A2)
             MOVE.W      #$0012,-(A7)
             TRAP        #1
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

CAUXIN:      PEA.L       (A2)
             MOVE.W      #$0003,-(A7)
             TRAP        #1
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

SYIELD:      PEA.L       (A2)
             MOVE.W      #$00FF,-(A7)
             TRAP        #1
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

FPIPE:       PEA.L       (A2)
             PEA.L       (A0)
             MOVE.W      #$0100,-(A7)
             TRAP        #1
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

FCNTL:       PEA.L       (A2)
             MOVE.W      D2,-(A7)
             MOVE.L      D1,-(A7)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0104,-(A7)
             TRAP        #1
             LEA.L       $000A(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

FINSTAT:     PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0105,-(A7)
             TRAP        #1
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

FOUTSTAT:    PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0106,-(A7)
             TRAP        #1
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

FGETCHAR:    PEA.L       (A2)
             MOVE.W      D1,-(A7)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0107,-(A7)
             TRAP        #1
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

FPUTCHAR:    PEA.L       (A2)
             MOVE.W      D2,-(A7)
             MOVE.L      D1,-(A7)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0108,-(A7)
             TRAP        #1
             LEA.L       $000A(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

PWAIT:       PEA.L       (A2)
             MOVE.W      #$0109,-(A7)
             TRAP        #1
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

PNICE:       PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$010A,-(A7)
             TRAP        #1
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

PGETPID:     PEA.L       (A2)
             MOVE.W      #$010B,-(A7)
             TRAP        #1
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

PGETPPID:    PEA.L       (A2)
             MOVE.W      #$010C,-(A7)
             TRAP        #1
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

PGETPGRP:    PEA.L       (A2)
             MOVE.W      #$010D,-(A7)
             TRAP        #1
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

PSETPGRP:    PEA.L       (A2)
             MOVE.W      D1,-(A7)
             MOVE.W      D0,-(A7)
             MOVE.W      #$010E,-(A7)
             TRAP        #1
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

PGETUID:     PEA.L       (A2)
             MOVE.W      #$010F,-(A7)
             TRAP        #1
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

PSETUID:     PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0110,-(A7)
             TRAP        #1
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS
    
PKILL:       PEA.L       (A2)
             MOVE.W      D1,-(A7)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0111,-(A7)
             TRAP        #1
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

PSIGNAL:     PEA.L       (A2)
             PEA.L       (A0)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0112,-(A7)
             TRAP        #1
             ADDQ.W      #8,A7
             MOVEA.L     D0,A0
             MOVEA.L     (A7)+,A2
             RTS

PVFORK:      PEA.L       (A2)
             MOVE.W      #$0113,-(A7)
             TRAP        #1
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

PGETGID:     PEA.L       (A2)
             MOVE.W      #$0114,-(A7)
             TRAP        #1
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

PSETGID:     PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0115,-(A7)
             TRAP        #1
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

PSIGBLOCK:   PEA.L       (A2)
             MOVE.L      D0,-(A7)
             MOVE.W      #$0116,-(A7)
             TRAP        #1
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

PSIGSETMASK: PEA.L       (A2)
             MOVE.L      D0,-(A7)
             MOVE.W      #$0117,-(A7)
             TRAP        #1
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

PUSRVAL:     PEA.L       (A2)
             MOVE.L      D0,-(A7)
             MOVE.W      #$0118,-(A7)
             TRAP        #1
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

PDOMAIN:     PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0119,-(A7)
             TRAP        #1
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

PSIGRETURN:  PEA.L       (A2)
             MOVE.W      #$011A,-(A7)
             TRAP        #1
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

PFORK:       PEA.L       (A2)
             MOVE.W      #$011B,-(A7)
             TRAP        #1
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

PWAIT3:      PEA.L       (A2)
             PEA.L       (A0)
             MOVE.W      D0,-(A7)
             MOVE.W      #$011C,-(A7)
             TRAP        #1
             ADDQ.W      #8,A7
             MOVEA.L     (A7)+,A2
             RTS

FSELECT:     PEA.L       (A2)
             PEA.L       $0008(A7)
             PEA.L       (A1)
             PEA.L       (A0)
             MOVE.W      D0,-(A7)
             MOVE.W      #$011D,-(A7)
             TRAP        #1
             LEA.L       $0010(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

PRUSAGE:     PEA.L       (A2)
             PEA.L       (A0)
             MOVE.W      #$011E,-(A7)
             TRAP        #1
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS
    
PSETLIMIT:   PEA.L       (A2)
             MOVE.L      D1,-(A7)
             MOVE.W      D0,-(A7)
             MOVE.W      #$011F,-(A7)
             TRAP        #1
             ADDQ.W      #8,A7
             MOVEA.L     (A7)+,A2
             RTS

TALARM:      PEA.L       (A2)
             MOVE.L      D0,-(A7)
             MOVE.W      #$0120,-(A7)
             TRAP        #1
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

PAUSE:       PEA.L       (A2)
             MOVE.W      #$0121,-(A7)
             TRAP        #1
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

SYSCONF:     PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0122,-(A7)
             TRAP        #1
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

PSIGPENDING: PEA.L       (A2)
             MOVE.W      #$0123,-(A7)
             TRAP        #1
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

PMSG:        MOVEM.L     D0-D1/A0/A2,-(A7)
             MOVE.W      #$0125,(A7)
             TRAP        #1
             LEA.L       $000C(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

FMIDIPIPE:   PEA.L       (A2)
             MOVEM.W     D0-D2,-(A7)
             MOVE.W      #$0126,(A7)
             TRAP        #1
             ADDQ.W      #8,A7
             MOVEA.L     (A7)+,A2
             RTS

PRENICE:     PEA.L       (A2)
             MOVE.W      D1,-(A7)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0127,(A7)
             TRAP        #1
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

DREWINDDIR:  PEA.L       (A2)
             MOVE.L      D0,-(A7)
             MOVE.W      #$012A,-(A7)
             TRAP        #1
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

DCLOSEDIR:   PEA.L       (A2)
             MOVE.L      D0,-(A7)
             MOVE.W      #$012B,-(A7)
             TRAP        #1
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

PUMASK:      PEA.L       (A2)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0133,-(A7)
             TRAP        #1
             ADDQ.W      #4,A7
             MOVEA.L     (A7)+,A2
             RTS

PSEMAPHORE:  MOVEM.L     D0-D2/A2,-(A7)
             MOVE.W      #$0134,(A7)
             TRAP        #1
             LEA.L       $000C(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

DLOCK:       PEA.L       (A2)
             MOVE.W      D1,-(A7)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0135,-(A7)
             TRAP        #1
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

PSIGPAUSE:   MOVEM.L     D0/A2,-(A7)
             MOVE.W      #$0136,-(A7)
             TRAP        #1
             ADDQ.W      #6,A7
             MOVEA.L     (A7)+,A2
             RTS

PSIGACTION:  MOVEM.L     D0/A0-A2,-(A7)
             MOVE.W      #$0137,(A7)
             TRAP        #1
             LEA.L       $000C(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

PGETEUID:    PEA.L       (A2)
             MOVE.W      #$0138,-(A7)
             TRAP        #1
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

PGETEGID:    PEA.L       (A2)
             MOVE.W      #$0139,-(A7)
             TRAP        #1
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

PWAITPID:    MOVEM.L     D1/A0/A2,-(A7)
             MOVE.W      D0,(A7)
             MOVE.W      #$013A,-(A7)
             TRAP        #1
             LEA.L       $000A(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

_PEXEC:

             PEA.L       (A2)
             MOVE.L      $0008(A7),-(A7)
             PEA.L       (A1)
             PEA.L       (A0)
             MOVE.W      D0,-(A7)
             MOVE.W      #$004B,-(A7)
             TRAP        #1
             LEA.L       $0010(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

FSNEXT:      PEA.L       (A2)
             MOVE.W      #$004F,-(A7)
             TRAP        #1
             ADDQ.W      #2,A7
             MOVEA.L     (A7)+,A2
             RTS

_FSFIRST:    PEA.L       (A2)
             MOVE.W      D0,-(A7)
             PEA.L       (A0)
             MOVE.W      #$004E,-(A7)
             TRAP        #1
             ADDQ.L      #8,A7
             MOVEA.L     (A7)+,A2
             RTS

_FRENAME:    MOVE.L      A2,-(A7)
             PEA.L       (A1)
             PEA.L       (A0)
             CLR.W       -(A7)
             MOVE.W      #$0056,-(A7)
             TRAP        #1
             LEA.L       $000C(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

_FOPEN:      PEA.L       (A2)
             MOVE.W      D0,-(A7)
             PEA.L       (A0)
             MOVE.W      #$003D,-(A7)
             TRAP        #1
             LEA.L       $0008(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

_FDELETE:    PEA.L       (A2)
             PEA.L       (A0)
             MOVE.W      #$0041,-(A7)
             TRAP        #1
             LEA.L       $0006(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

_FCREATE:    PEA.L       (A2)
             MOVE.W      D0,-(A7)
             PEA.L       (A0)
             MOVE.W      #$003C,-(A7)
             TRAP        #1
             LEA.L       $0008(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

_FATTRIB:    PEA.L       (A2)
             MOVE.W      D1,-(A7)
             MOVE.W      D0,-(A7)
             PEA.L       (A0)
             MOVE.W      #$0043,-(A7)
             TRAP        #1
             LEA.L       $000A(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

_DSETPATH:   PEA.L       (A2)
             PEA.L       (A0)
             MOVE.W      #$003B,-(A7)
             TRAP        #1
             LEA.L       $0006(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

_DGETPATH:   PEA.L       (A2)
             MOVE.W      D0,-(A7)
             PEA.L       (A0)
             MOVE.W      #$0047,-(A7)
             TRAP        #1
             ADDQ.W      #8,A7
             MOVEA.L     (A7)+,A2
             RTS
    
_DDELETE:    PEA.L       (A2)
             PEA.L       (A0)
             MOVE.W      #$003A,-(A7)
             TRAP        #1
             LEA.L       $0006(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

_DCREATE:    PEA.L       (A2)
             PEA.L       (A0)
             MOVE.W      #$0039,-(A7)
             TRAP        #1
             LEA.L       $0006(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

_CCONWS:     PEA.L       (A2)
             PEA.L       (A0)
             MOVE.W      #$0009,-(A7)
             TRAP        #1
             LEA.L       $0006(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

_SALERT:     PEA.L       (A2)
             PEA.L       (A0)
             MOVE.W      #$013C,-(A7)
             TRAP        #1
             LEA.L       $0006(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

_DPATHCONF:  PEA.L       (A2)
             MOVE.W      D0,-(A7)
             PEA.L       (A0)
             MOVE.W      #$0124,-(A7)
             TRAP        #1
             LEA.L       $0008(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

_DOPENDIR:   PEA.L       (A2)
             MOVE.W      D0,-(A7)
             PEA.L       (A0)
             MOVE.W      #$0128,-(A7)
             TRAP        #1
             LEA.L       $0008(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

_DREADDIR:   MOVEM.L     D0-D1/A0/A2,-(A7)
             MOVE.W      #$0129,(A7)
             TRAP        #1
             LEA.L       $000C(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

_FXATTR:     PEA.L       (A2)
             PEA.L       (A1)
             PEA.L       (A0)
             MOVE.W      D0,-(A7)
             MOVE.W      #$012C,-(A7)
             TRAP        #1
             LEA.L       $00C(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

_FLINK:      PEA.L       (A2)
             PEA.L       (A1)
             PEA.L       (A0)
             MOVE.W      #$012D,-(A7)
             TRAP        #1
             LEA.L       $000A(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

_FSYMLINK:   PEA.L       (A2)
             PEA.L       (A1)
             PEA.L       (A0)
             MOVE.W      #$012E,-(A7)
             TRAP        #1
             LEA.L       $000A(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

_FREADLINK:  MOVEM.L     D3/A2-A3,-(A7)
             PEA.L       (A1)
             PEA.L       (A0)
             MOVE.W      D0,-(A7)
             MOVE.W      #$012F,-(A7)
             TRAP        #1
             LEA.L       $000C(A7),A7
             MOVEM.L     (A7)+,D3/A2-A3
             RTS

_DCNTL:      PEA.L       (A2)
             PEA.L       (A0)
             MOVE.W      D0,-(A7)
             MOVE.W      #$0130,-(A7)
             TRAP        #1
             LEA.L       $000C(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

_FCHOWN:     PEA.L       (A2)
             MOVE.W      D1,-(A7)
             MOVE.W      D0,-(A7)
             PEA.L       (A0)
             MOVE.W      #$0131,-(A7)
             TRAP        #1
             LEA.L       $000A(A7),A7
             MOVEA.L     (A7)+,A2
             RTS

_FCHMOD:     PEA.L       (A2)
             MOVE.W      D0,-(A7)
             PEA.L       (A0)
             MOVE.W      #$0132,-(A7)
             TRAP        #1
             LEA.L       $0008(A7),A7
             MOVEA.L     (A7)+,A2
             RTS
