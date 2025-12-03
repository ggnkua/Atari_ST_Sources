;ASS_MAC Version 1.10
;====================
;
;Assembler:     GFA, Version 1.5
;Versionsdatum: 13.10.1990
;
;Macros fÅr:    GEMDOS, BIOS, XBIOS
;
;(C) 1989,90 by
;Martin Birn, Knoblochstraûe 51, D-7100 Heilbronn
;
;NÑhere Informationen enthÑlt die Datei LIESMICH.DOK.
;-------------------------------------------------------------------------------


                .TEXT 

;
; Trap-Definitionen
;

                .MACRO GEMDOS funktion,len        ; GEMDOS-Trap
                move.w        #\1,-(sp) ; Funktionsnummer
                trap          #1        ; Trap ausfÅhren
                .IF \?2       ;                   ; Parameter 2 Åbergeben ?
                .IF \2<=8     ;                   ; ja
                addq.l        #\2,sp    ;  Stack mit wenig Parametern aufrÑumen
                .ELSE 
                lea.l         \2(sp),sp ;  Stack mit vielen Parametern aufrÑumen
                .ENDIF 
                .ELSE         ;                   ; nein
                .IF \funktion<>$4c&\funktion<>$0
                addq.l        #2,sp
                .ENDIF 
                .ENDIF 
                .ENDM 

                .MACRO BIOS funktion,len          ; BIOS-Trap
                move.w        #\1,-(sp) ; Funktionsnummer
                trap          #13       ; Trap ausfÅhren
                .IF \2<=8
                addq.l        #\2,sp    ; Stack mit wenig Parametern aufrÑumen
                .ELSE 
                lea.l         \2(sp),sp ; Stack mit vielen Parametern aufrÑumen
                .ENDIF 
                .ENDM 

                .MACRO XBIOS funktion,len         ; XBIOS-Trap
                move.w        #\1,-(sp) ; Funktionsnummer
                trap          #14       ; Trap ausfÅhren
                .IF \?2
                .IF \2<=8
                addq.l        #\2,sp    ; Stack mit wenig Parametern aufrÑumen
                .ELSE 
                lea.l         \2(sp),sp ; Stack mit vielen Parametern aufrÑumen
                .ENDIF 
                .ELSE 
                addq.l        #2,sp
                .ENDIF 
                .ENDM 


;
; GEMDOS-Funktionen
;

                .MACRO PTERM stat       ; Funktion $0 und $4c
                .IF \?1
                move.w        \1,-(sp)
                GEMDOS        $4c,4
                .ELSE 
                GEMDOS        0
                .ENDIF 
                .ENDM 

                .MACRO CCONIN
                GEMDOS        1
                .ENDM 

                .MACRO CCONOUT char
                move.w        \1,-(sp)
                GEMDOS        2,4
                .ENDM 

                .MACRO CAUXIN
                GEMDOS        3
                .ENDM 

                .MACRO CAUXOUT char
                move.w        \1,-(sp)
                GEMDOS        4,4
                .ENDM 

                .MACRO CPRNOUT char
                move.w        \1,-(sp)
                GEMDOS        5,4
                .ENDM 

                .MACRO CRAWIO parm
                move.w        \1,-(sp)
                GEMDOS        6,4
                .ENDM 

                .MACRO CRAWCIN
                GEMDOS        7
                .ENDM 

                .MACRO CNECIN
                GEMDOS        8
                .ENDM 

                .MACRO CCONWS addr
                move.l        \1,-(sp)
                GEMDOS        9,6
                .ENDM 

                .MACRO CCONRS addr
                move.l        \1,-(sp)
                GEMDOS        $a,6
                .ENDM 

                .MACRO CCONIS
                GEMDOS        $b
                .ENDM 

                .MACRO DSETDRV driv     ; $e, Dsetdrv
                move.w        \1,-(sp)
                GEMDOS        $e,4
                .ENDM 

                .MACRO CCONOS
                GEMDOS        $10
                .ENDM 

                .MACRO CPRNOS
                GEMDOS        $11
                .ENDM 

                .MACRO CAUXIS
                GEMDOS        $12
                .ENDM 

                .MACRO CAUXOS
                GEMDOS        $13
                .ENDM 

                .MACRO DGETDRV
                GEMDOS        $19
                .ENDM 

                .MACRO FSETDTA addr
                move.l        \1,-(sp)
                GEMDOS        $1a,6
                .ENDM 

                .MACRO SUPER stck
                move.l        \1,-(sp)
                GEMDOS        $20,6
                .ENDM 

                .MACRO TGETDATE
                GEMDOS        $2a
                .ENDM 

                .MACRO TSETDATE date
                move.w        \date,-(sp)
                GEMDOS        $2b,4
                .ENDM 

                .MACRO TGETTIME
                GEMDOS        $2c
                .ENDM 

                .MACRO TSETTIME time
                move.w        \time,-(sp)
                GEMDOS        $2d,4
                .ENDM 

                .MACRO FGETDTA
                GEMDOS        $2f
                .ENDM 

                .MACRO SVERSION
                GEMDOS        $30
                .ENDM 

                .MACRO PTERMRES keep,exit
                move.w        \2,-(sp)
                move.l        \1,-(sp)
                GEMDOS        $31,8
                .ENDM 

                .MACRO DFREE info,driv
                move.w        \2,-(sp)
                move.l        \1,-(sp)
                GEMDOS        $36,8
                .ENDM 

                .MACRO DCREATE path
                move.l        \1,-(sp)
                GEMDOS        $39,6
                .ENDM 

                .MACRO DDELETE path
                move.l        \1,-(sp)
                GEMDOS        $3a,6
                .ENDM 

                .MACRO DSETPATH path
                move.l        \1,-(sp)
                GEMDOS        $3b,6
                .ENDM 

                .MACRO FCREATE path,attr
                move.w        \2,-(sp)
                move.l        \1,-(sp)
                GEMDOS        $3c,8
                tst.w         d0
                .ENDM 

                .MACRO FOPEN path,attr
                move.w        \2,-(sp)
                move.l        \1,-(sp)
                GEMDOS        $3d,8
                tst.w         d0
                .ENDM 

                .MACRO FCLOSE hndl
                move.w        \1,-(sp)
                GEMDOS        $3e,4
                tst.w         d0
                .ENDM 

                .MACRO FREAD hndl,byts,buff
                move.l        \3,-(sp)
                move.l        \2,-(sp)
                move.w        \1,-(sp)
                GEMDOS        $3f,12
                tst.w         d0
                .ENDM 

                .MACRO FWRITE hndl,byts,buff
                move.l        \3,-(sp)
                move.l        \2,-(sp)
                move.w        \1,-(sp)
                GEMDOS        $40,12
                tst.w         d0
                .ENDM 

                .MACRO FDELETE path
                move.l        \path,-(sp)
                GEMDOS        $41,6
                tst.w         d0
                .ENDM 

                .MACRO FSEEK nbyt,hndl,fmod
                move.w        \3,-(sp)
                move.w        \2,-(sp)
                move.l        \1,-(sp)
                GEMDOS        $42,10
                .ENDM 

                .MACRO FATTRIB path,writ,attr
                move.w        \3,-(sp)
                move.w        \2,-(sp)
                move.l        \1,-(sp)
                GEMDOS        $43,10
                .ENDM 

                .MACRO FDUP shnd
                move.w        \1,-(sp)
                GEMDOS        $45,4
                .ENDM 

                .MACRO FFORCE nhnd,shnd
                move.w        \2,-(sp)
                move.w        \1,-(sp)
                GEMDOS        $46,6
                .ENDM 

                .MACRO DGETPATH path,driv
                move.w        \2,-(sp)
                move.l        \1,-(sp)
                GEMDOS        $47,8
                .ENDM 

                .MACRO MALLOC nbyt
                move.l        \1,-(sp)
                GEMDOS        $48,6
                .ENDM 

                .MACRO MFREE frad
                move.l        \1,-(sp)
                GEMDOS        $49,6
                .ENDM 

                .MACRO MSHRINK mmem,rmem
                move.l        \2,-(sp)
                move.l        \1,-(sp)
                clr.w         -(sp)
                GEMDOS        $4a,12
                .ENDM 

                .MACRO PEXEC mode,path,pcmd,penv
                move.l        \4,-(sp)
                move.l        \3,-(sp)
                move.l        \2,-(sp)
                move.w        \1,-(sp)
                GEMDOS        $4b,16
                .ENDM 

                .MACRO FSFIRST path,satt
                move.w        \2,-(sp)
                move.l        \1,-(sp)
                GEMDOS        $4e,8
                .ENDM 

                .MACRO FSNEXT
                GEMDOS        $4f
                .ENDM 

                .MACRO FRENAME pth1,pth2
                move.l        \2,-(sp)
                move.l        \1,-(sp)
                clr.w         -(sp)
                GEMDOS        $56,12
                .ENDM 

                .MACRO FDATIME buff,hndl,info
                move.w        \3,-(sp)
                move.w        \2,-(sp)
                move.l        \1,-(sp)
                GEMDOS        $57,10
                .ENDM 

;
; BIOS-Funktionen
;

                .MACRO GETMBP pmbp
                move.l        \1,-(sp)
                BIOS          0,4
                .ENDM 

                .MACRO BCONSTAT dev
                move.w        \1,-(sp)
                BIOS          1,4
                .ENDM 

                .MACRO BCONIN dev
                move.w        \1,-(sp)
                BIOS          2,4
                .ENDM 

                .MACRO BCONOUT dev,char
                move.w        \2,-(sp)
                move.w        \1,-(sp)
                BIOS          3,6
                .ENDM 

                .MACRO RWABS rwfl,buf,secn,recn,driv
                move.w        \5,-(sp)
                move.w        \4,-(sp)
                move.w        \3,-(sp)
                move.l        \2,-(sp)
                move.w        \1,-(sp)
                BIOS          4,14
                .ENDM 

                .MACRO SETEXC vecn,vec
                move.l        \2,-(sp)
                move.w        \1,-(sp)
                BIOS          5,8
                .ENDM 

                .MACRO TICKCAL
                BIOS          6,2
                .ENDM 

                .MACRO GETBPB driv
                move.w        \1,-(sp)
                BIOS          7,4
                .ENDM 

                .MACRO BCOSTAT dev
                move.w        \1,-(sp)
                BIOS          8,4
                .ENDM 

                .MACRO MEDIACH driv
                move.w        \1,-(sp)
                BIOS          9,4
                .ENDM 

                .MACRO DRVMAP
                BIOS          10,2
                .ENDM 

                .MACRO KBSHIFT mode
                move.w        \1,-(sp)
                BIOS          11,4
                .ENDM 

;
; XBIOS-Funktionen
;

                .MACRO INITMOUS type,para,vect
                move.l        \3,-(sp)
                move.l        \2,-(sp)
                move.w        \1,-(sp)
                XBIOS         0,12
                .ENDM 

                .MACRO PHYSBASE
                XBIOS         2,2
                .ENDM 

                .MACRO LOGBASE
                XBIOS         3,2
                .ENDM 

                .MACRO GETREZ
                XBIOS         4,2
                .ENDM 

                .MACRO SETSCREEN lloc,ploc,rez
                move.w        \3,-(sp)
                move.l        \2,-(sp)
                move.l        \1,-(sp)
                XBIOS         5,12
                .ENDM 

                .MACRO SETPALLETTE palp
                move.l        \1,-(sp)
                XBIOS         6,6
                .ENDM 

                .MACRO SETCOLOR coln,colr
                move.w        \2,-(sp)
                move.w        \1,-(sp)
                XBIOS         7,6
                .ENDM 

                .MACRO FLOPRD buff,devn,stsc,trkn,sidn,secn
                move.w        \6,-(sp)
                move.w        \5,-(sp)
                move.w        \4,-(sp)
                move.w        \3,-(sp)
                move.w        \2,-(sp)
                clr.l         -(sp)
                move.l        \1,-(sp)
                XBIOS         8,20
                .ENDM 

                .MACRO FLOPWR buff,devn,stsc,trkn,sidn,secn
                move.w        \6,-(sp)
                move.w        \5,-(sp)
                move.w        \4,-(sp)
                move.w        \3,-(sp)
                move.w        \2,-(sp)
                clr.l         -(sp)
                move.l        \1,-(sp)
                XBIOS         9,20
                .ENDM 

                .MACRO FLOPFMT buff,devn,sptk,trkn,sidn,intl,magc,fcod
                move.w        \8,-(sp)
                move.l        \7,-(sp)
                move.w        \6,-(sp)
                move.w        \5,-(sp)
                move.w        \4,-(sp)
                move.w        \3,-(sp)
                move.w        \2,-(sp)
                clr.l         -(sp)
                move.l        \1,-(sp)
                XBIOS         10,26
                .ENDM 

                .MACRO MIDIWS cnt,ptr
                move.l        \2,-(sp)
                move.w        \1,-(sp)
                XBIOS         12,8
                .ENDM 

                .MACRO MFPINT intn,vect
                move.l        \2,-(sp)
                move.w        \1,-(sp)
                XBIOS         13,8
                .ENDM 

                .MACRO IOREC devn
                move.w        \1,-(sp)
                XBIOS         14,6
                .ENDM 

                .MACRO RSCONF baud,flow,usr,rsr,tsr,scr
                move.w        \6,-(sp)
                move.w        \5,-(sp)
                move.w        \4,-(sp)
                move.w        \3,-(sp)
                move.w        \2,-(sp)
                move.w        \1,-(sp)
                XBIOS         15,14
                .ENDM 

                .MACRO KEYTBL unsh,shft,capl
                move.l        \3,-(sp)
                move.l        \2,-(sp)
                move.l        \1,-(sp)
                XBIOS         16,14
                .ENDM 

                .MACRO RANDOM
                XBIOS         17
                .ENDM 

                .MACRO PROTOBT buff,sern,dskt,exfl
                move.w        \4,-(sp)
                move.w        \3,-(sp)
                move.l        \2,-(sp)
                move.l        \1,-(sp)
                XBIOS         18,14
                .ENDM 

                .MACRO FLOPVER buff,devn,stsc,trkn,sidn,secn
                move.w        \6,-(sp)
                move.w        \5,-(sp)
                move.w        \4,-(sp)
                move.w        \3,-(sp)
                move.w        \2,-(sp)
                clr.l         -(sp)
                move.l        \1,-(sp)
                XBIOS         19,20
                .ENDM 

                .MACRO SCRDMP
                XBIOS         20
                .ENDM 

                .MACRO CURSCONF attr,rate
                move.w        \2,-(sp)
                move.w        \1,-(sp)
                XBIOS         21,6
                .ENDM 

                .MACRO SETTIME date
                move.l        \1,-(sp)
                XBIOS         22,6
                .ENDM 

                .MACRO GETTIME
                XBIOS         23
                .ENDM 

                .MACRO BIOSKEYS
                XBIOS         24
                .ENDM 

                .MACRO IKBDWS nch,pntr
                move.l        \2,-(sp)
                move.w        \1,-(sp)
                XBIOS         25,8
                .ENDM 

                .MACRO JDISINT intn
                move.w        \1,-(sp)
                XBIOS         26,4
                .ENDM 

                .MACRO JENABINT regn
                move.w        \1,-(sp)
                XBIOS         27,4
                .ENDM 

                .MACRO GIACCESS regn
                move.w        \2,-(sp)
                move.w        \1,-(sp)
                XBIOS         28,6
                .ENDM 

                .MACRO OFFGIBIT bitm
                move.w        \1,-(sp)
                XBIOS         29,4
                .ENDM 

                .MACRO ONGIBIT bitm
                move.w        \1,-(sp)
                XBIOS         30,4
                .ENDM 

                .MACRO XBTIMER timr,cntl,data,vec
                move.l        \4,-(sp)
                move.w        \3,-(sp)
                move.w        \2,-(sp)
                move.w        \1,-(sp)
                XBIOS         31,12
                .ENDM 

                .MACRO DOSOUND ptr
                move.l        \1,-(sp)
                XBIOS         32,6
                .ENDM 

                .MACRO SETPRT conf
                move.w        \1,-(sp)
                XBIOS         33,4
                .ENDM 

                .MACRO KBDVBASE
                XBIOS         34
                .ENDM 

                .MACRO KBRATE init,rept
                move.w        \2,-(sp)
                move.w        \1,-(sp)
                XBIOS         35,6
                .ENDM 

                .MACRO PRTBLK ptr
                move.l        \1,-(sp)
                XBIOS         36,6
                .ENDM 

                .MACRO VSYNC
                XBIOS         37
                .ENDM 

                .MACRO SUPEXEC code
                move.l        \1,-(sp)
                XBIOS         38,6
                .ENDM 

                .MACRO PUNTAES
                XBIOS         39
                .ENDM 

                .MACRO BLITMODE flag
                move.w        \1,-(sp)
                XBIOS         64,4
                .ENDM 

;
;Einige Hardware-Registeradressen
;

;Shifter

memconf         = $ffff8001   ; Speicher-Konfigurationen
dbaseh          = $ffff8201   ; Highbyte der Adresse des Bildschirms
dbasel          = $ffff8203   ; Midbyte der Adresse des Bildschirms
vcounthi        = $ffff8205   ; Hibyte des Video-Adress-ZÑhlers
vcountmid       = $ffff8207   ; Midbyte         -"-
vcountlow       = $ffff8209   ; Lowbyte         -"-
syncmode        = $ffff820a   ; Synchronisationsmodus
color0          = $ffff8240   ; Shifter-Farbregister 0-15
color1          = $ffff8242
color2          = $ffff8244
color3          = $ffff8246
color4          = $ffff8248
color5          = $ffff824a
color6          = $ffff824c
color7          = $ffff824e
color8          = $ffff8250
color9          = $ffff8252
color10         = $ffff8254
color11         = $ffff8256
color12         = $ffff8258
color13         = $ffff825a
color14         = $ffff825c
color15         = $ffff825e
shiftmd         = $ffff8260   ; Bildauflîsung

;DMA-Chip

diskctrl        = $ffff8604   ; Disk-Kontroller-Registerauswahl
dmamode         = $ffff8606   ; DMA-Status/-Modus
dmahigh         = $ffff8609   ; DMA Basis und ZÑhler: high
dmamid          = $ffff860b   ;         -"-         : mid
dmalow          = $ffff860d   ;         -"-         : low

;Floppy-Controller

cmdreg          = $80         ; 1770/FIFO Kommando-Register-Auswahl
trackreg        = $82         ; 1770/FIFO Spur-Register-Auswahl
sectorreg       = $84         ; 1770/FIFO Sektor-Register-Auswahl
datareg         = $86         ; 1770/FIFO Daten-Register-Auswahl

;Soundchip

psgselect       = $ffff8800   ; (W) Registerauswahl
psgread         = $ffff8800   ; (R) Daten lesen
psgwrite        = $ffff8802   ; (W) Daten schreiben
psgtoneaf       = 0           ; Kanal A: Feineinstellung
psgtoneac       = 1           ;  -"-  A: Grobeinstellung
psgtonebf       = 2           ; Kanal B
psgtonebc       = 3
psgtonecf       = 4           ; Kanal C
psgtonecc       = 5
psgnoise        = 6           ; Rauschgenerator
psgmixer        = 7           ; I/O-Steuerung, Mixer
psgampa         = 8           ; Kanal A, B, C: Amplitude
psgampb         = 9
psgampc         = $a
psgenvlpf       = $b          ; HÅllkurven-Periode: Feineinstellung
psgenvlpc       = $c          ;        -"-        : Grobeinstellung
psgporta        = $e          ; PORT A (nur Ausgabe)
psgportb        = $f          ; PORT B (Centronics-Ausgabe)

;Bits in "psgporta"

rtsout          = 8           ; RTS output
dtrout          = $10         ; DTR output
strobe          = $20         ; Centronics strobe output
out             = $40         ;                   ; "general purpose" output

;68901 (MFP)

mfp             = $fffffa00   ; Register-Basis
mfpgpio         = $fffffa00+1 ; I/O
mfpaer          = $fffffa00+3 ; active edge
mfpddr          = $fffffa00+5 ; Daten-Richtung
mfpiera         = $fffffa00+7 ; interrupt enable A
mfpierb         = $fffffa00+9 ;       -"-        B
mfpipra         = $fffffa00+$b          ; interrupt pending A
mfpiprb         = $fffffa00+$d          ;       -"-         B
mfpisra         = $fffffa00+$f          ; interrupt inService A
mfpisrb         = $fffffa00+$11         ;       -"-           B
mfpimra         = $fffffa00+$13         ; interrupt mask A
mfpimrb         = $fffffa00+$15         ;       -"-      B
mfpvr           = $fffffa00+$17         ; Vektor-Register
mfptacr         = $fffffa00+$19         ; timer A control
mfptbcr         = $fffffa00+$1b         ; timer B control
mfptcdcr        = $fffffa00+$1d         ; timer C & D control
mfptadr         = $fffffa00+$1f         ; timer A data
mfptbdr         = $fffffa00+$21         ; timer B data
mfptcdr         = $fffffa00+$23         ; timer C data
mfptddr         = $fffffa00+$25         ; timer D data
mfpscr          = $fffffa00+$27         ; sync char
mfpucr          = $fffffa00+$29         ; USART control reg
mfprsr          = $fffffa00+$2b         ; receiver status
mfptsr          = $fffffa00+$2d         ; transmit status
mfpudr          = $fffffa00+$2f         ; USART data

;ACIA's 6850

aciakeyctrl     = $fffffc00   ; keyboard ACIA control
aciakeydr       = $fffffc02   ; keyboard data
aciamidicr      = $fffffc04   ; MIDI ACIA control
aciamididr      = $fffffc06   ; MIDI data

;
;dokumentierte Systemvariablen
;

proc_lives      = $380
proc_regs       = $384
proc_pc         = $3c4
proc_usp        = $3c8
proc_stk        = $3cc
etv_timer       = $400
etv_critic      = $404
etv_term        = $408
etv_xtra        = $40c
memvalid        = $420
memcntlr        = $424
resvalid        = $426
resvector       = $42a
phystop         = $42e
_membot         = $432
_memtop         = $436
memval2         = $43a
flock           = $43e
seekrate        = $440
_timr_ms        = $442
_fverify        = $444
_bootdev        = $446
palmode         = $448
defshiftmd      = $44a
sshiftmd        = $44c
_v_bas_ad       = $44e
vblsem          = $452
nvbls           = $454
_vblqueue       = $456
colorptr        = $45a
screenpt        = $45e
_vbclock        = $462
_frclock        = $466
hdv_init        = $46a
swv_vec         = $46e
hdv_bpb         = $472
hdv_rw          = $476
hdv_boot        = $47a
hdv_mediach     = $47e
_cmdload        = $482
conterm         = $484
trp14ret        = $486
criticret       = $48a
themd           = $48e
_____md         = $49e
savptr          = $4a2
_nflops         = $4a6
con_state       = $4a8
save_row        = $4ac
sav_context     = $4ae
_bufl           = $4b2
_hz_200         = $4ba
_drvbits        = $4c2
_dskbufp        = $4c6
_autopath       = $4ca
_vbl_list       = $4ce
_dumpflg        = $4ee
_prtabt         = $4f0
_sysbase        = $4f2
_shell_p        = $4f6
end_os          = $4fa
exec_os         = $4fe
scr_dump        = $502
prv_lsto        = $506
prv_lst         = $50a
prv_auxo        = $50e
prv_aux         = $512
pun_ptr         = $516        ;erst ab Blitter-TOS!!
memval3         = $51a
_is_prt         = $51e
_is_aux         = $522
_is_con         = $526
_is_midi        = $52a
_is_ikbd        = $52e
_is_rawcon      = $532
_is_dev6        = $536
_is_dev7        = $53a
_i_prt          = $53e
_i_aux          = $542
_i_con          = $546
_i_midi         = $54a
_i_ikbd         = $54e
_i_rawcon       = $552
_i_dev6         = $556
_i_dev7         = $55a
_os_prt         = $55e
_os_aux         = $562
_os_con         = $566
_os_midi        = $56a
_os_ikbd        = $56e
_os_rawcon      = $572
_os_dev6        = $576
_os_dev7        = $57a
_o_prt          = $57e
_o_aux          = $582
_o_con          = $586
_o_midi         = $58a
_o_ikbd         = $58e
_o_rawcon       = $592
_o_dev6         = $596
_o_dev7         = $59a

;
;GerÑtenummern
;

prt             = 0           ; Drucker
aux             = 1           ; RS-232
con             = 2           ; Bildschirm (VT-52-Emulator)
midi            = 3           ; MIDI
ikbd            = 4           ; Tastatur
rawcon          = 5           ; Bildschirm (alle ASCII-Zeichen von dez.0 - dez.255)

                .END 

