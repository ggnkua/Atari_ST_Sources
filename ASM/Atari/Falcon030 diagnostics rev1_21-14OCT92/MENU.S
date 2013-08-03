        .extern dsptest,testexp
        .extern SDMA
        .extern falmsg,pasmsg,ikbdput,menu,clr2lin,cnvdec
        .extern dspcycl,chkesc,pause,ascdec,getbuf,chkred
        .extern ikbdptr         ; used by excep.s
        .extern EndCartAddr             
* Menu.s  
*       Display title, system configuration, and menu

* SPARROW TEST -------------------------------------------------
* V0.50 : 17DEC91 : RWS : Started Sparrow Test 0.5 from STe v1.9 (half works)
* V0.51 : 19DEC91 : RWS : Cleaned up menus - Moved to submenu format
* V0.60 : 06DEC92 : RWS : Config Switches in submenu installed
* V0.70 : 16JAN92 : RWS : System Control Menu Added
* V0.70a: 17JAN92 : RWS : Cleaned/Inversed some test titles
* V0.70b: 17JAN92 : RWS : MOVED COMMENTS TO VERSION1.S - GO LOOK THERE
* --------------------------------------------------------------
* 21JAN92 : RWS : moved color & hires to Video test
* 29JAN92 : RWS : moved conin & such to console.s 
*
*       MAY  24, 91: fixed audio fail after ram test
*       Mar  19, 91: installed TT pass/fail sounds
*       Mar  14, 91: fixed the RAM fail after floppy test (see init.s)
*       July 24, 90: added "J" test for r/w hard disk
*       June 24, 89: 0.0 STe test. ROM removed from Q,Z test
*       Feb 15, 89:  4.1a       mod flop.s to erase track before fmt.
*       Sept 23, 88: 4.1 add extended blit test; don't switch to 50 Hz if
*               monochrome monitor is used.
*       Dec 11, 87 Rev. 4.0 for Mega ST: display OS version,
*          floppy speed test, blitter, expansion, rt clock. Fix read in wr.
*       May 28, 87 revision 3.61: head, track select in flop. disable mouse
*               after keyboard reset test. Fix rs232 rate set bug, max rate
*               is 9600 bps, increase timeout for correct display (rs232 out).
*       Feb 19, 87 disable mouse
*       Dec 8, 86: more help
*       Nov 25, 86 Options: set baud rate, 50/60 Hz display
*          baud rate, video rate, help, date, examine are immediate (getbuf routine)
*       Oct 20, 86 Display keyboard revision. 'Z' tests added.
*       Oct 15, 86 more than one test selected set mltpas flag
*       Oct 5, 86 New screen for 80 column. 
*       June 11 Correct getbuf to handle backspace of empty buffer.
*       Sep 22, 86
*       Corrected ascii-to-decimal conversion
*       Convert lower case key input to upper case

** BURN IN CYCLE TIMES. 1MB/4MB/14MB RAM, 8/16/24 Hours **
T1M8H = 900     
T4M8H = 350
T14M8H = 96
T1M16H = 1800
T4M16H = 700
T14M16H = 192 

; T1M24H = 2750
; T1M24H = 2450  ;closer to 24 hours
T1M24H = 2330  ;closer to 24 hours
; T1M24H = 4     ;test only

; T4M24H = 1050
; T4M24H = 933   ;closer to 24 hours
T4M24H = 890   ;closer to 24 hours
; T4M24H = 3     ;test only

; T14M24H = 288
; T14M24H = 256  ;closer to 24 hours
T14M24H = 244  ;closer to 24 hours
; T14M24H = 3    ;test only

        .text

*       Arrive here from power-up initialization 
screen0:
        clr.b   driva           ;assume no disks
        clr.b   drivb
        move.b  #1,ProdTestStat

*       check optional devices and set bits in mega flag if present
*RWS.T        bsr     isblt           ;blitter?

*------------------------
*       Determine I/O device:
*       test keyboard; if fail, use RS232
*       if keyboards passes, test first character input for
*       keyboard or terminal origin and use that device from then on.

        clr.b   consol          ;init. the user I/O variable
        bset.b  #rsinp,consol   ; turn off RS232 for keyboard check.. RWS.TPES

        bsr     keyres          ;do keyboard reset
        beq.s   menu0           ;br keybd ok

        btst    #kfail,consol   ;test disable bit
        beq.s   menu0           ;stuck key, keybd still functional, maybe

*       Keyboard fail, must use RS232
        lea     keybdm,a5       ;keybd fail, use RS232
        bsr     dspmsg

*       Check for power-up error before clearing screen
menu0:  moveq   #$12,d1
        bsr     ikbdput         ;disable mouse

        bsr     gensnd          ;generate noise gr/red
        bsr     chkred          ;check for prev. errors
;        beq.s   menu1           ;do not clear screen

*********************************************************
*       Display title, RAM, menu, TV standard, etc.     *       
*********************************************************
*       This is the return point for finished command followed by cr
menu:
        move.b  #1,ProdTestStat
MainMenu:
        bsr     clearsc
        clr.b     autotst        ;RWS.T ; temp hack test.
        move.l   #1,cycle       ; ditto
        move.w  #bgrnd,palette
        andi.b  #$c7,consol
        moveq   #$12,d1
        bsr     ikbdput         ;disable mouse
        bsr     sndoff          ;turn off sound

*       Check to see if operator installed/removed RS232 connector
*       If loopback connected (or line to host), must disable conin for RS232
menu1:  bclr    #rsinp,consol   ;default=RS232 enable
;RWS.T  move.b  udr+mfp,d0      ;read it to be sure its empty
        move.b  scc_data+sccb_base,d0   ; read from SCC
        move.b  #cr,d0
        bsr     dsprs           ;send RS232
        moveq   #40,d0          ;100ms for response
wtrs:   bsr     wait            ;wait for char to arrive
        dbra    d0,wtrs
        bsr     rsstat          ;got a char?
        beq.s   menu2           ;no, not connected
        move.b  scc_data+sccb_base,d0   ; read from SCC
;       move.b  udr+mfp,d0      ;get char.
        bset    #rsinp,consol   ;loopback connected, no RS232 I/O

menu2:  movea.l #hdrmsg,a5
        bsr     dspmsg          ;print title

*       Display RAM size        * RWS : 03MAR92 : fixed for sparrow test
;        bsr     dsptab
        move.l  topram,d0       ;$40000,$80000,$100000,... was .w
        swap    d0              ;4,8,$10,$20,$40,$80,$e0
        andi.l  #$fe,d0         ;round off (why?)
;        moveq   #0,d1           ;needed?
        lea     sizetbl,a0
        moveq   #sizemax,d1

ramsz1: cmp.b   0(a0,d1),d0
        beq.s   ramsz2
        dbra    d1,ramsz1
        bra.s   keyrev          ;size unknown (can't happen)

ramsz2: lea     model,a0
        lsl     #2,d1           ;index * 4 for message table
        move.l  0(a0,d1),a5     ;get message
        bsr     dsptab
        bsr     dsptab
        bsr     dspmsg

keyrev: tst.b   kbrev
        bmi.s   syncmd          ;no keyboard status

        lea     kbrevm,a5       ;display keyboard revision
        bsr     dspmsg
        move.b  kbrev,d0
        bsr     cnvdec
        bsr     dspasc

syncmd:                 ; removed : RWS.
        bsr     dsptab
 ;       move.b  synmod,d0       ;get sync mode
  ;      btst    #1,d0
   ;     beq.s   v_60_hz
    ;    lea     v_50msg,a5
     ;   bra.s   v_hz
;v_60_hz:
 ;       lea     v_60msg,a5
;v_hz:   bsr     dspmsg          ;display vert. scan rate
        bsr     dspvers         ;display TOS version
        bsr     crlf

        tst.b   ProdTestStat    ; if <> 0 do prod test menu
        beq     dspmenu
*       bset    #mltpas,consol  ; RWS. 1.18e
*       bset    #mlttst,consol
*       bset    #qztest,consol
*------------------------------------------------
.if SUPERVISORCART = 1
        .include sumenu
.endif
        btst    #rsinp,consol
        beq     .skip   
        btst    #kfail,consol   ; is keyboard there?      
;       beq     .skip
        bne     DoBurnIn
.skip:
        btst    #kfail,consol   ;keyboard ok?
        bne.s   dspProdMenu

        moveq   #$1a,d1         ;disable joysticks
        bsr     ikbdput

dspProdMenu:
        move.b  #1,NoOps
        lea.l   menu2msg,a5     ; top part of menu
        bsr     dspinv
        ISRTCVALID
        beq     .valid          
        bsr     setzerotime
        bsr     ClearNVRAM      ; if RTC ram not initialized (by P test), initialize it & skip other tests...
        RTCVALIDATE
        WRITENVRAM #t_VERNUM, #VERSION  ; save version number of cart
.valid:
        READNVRAM #t_VERNUM,d0
        cmp.b   #VERSION,d0
        bne     VersionError    ; using a different ver # is bad...

        lea.l   Pmenu,a5        ; always preburn
        RTCSUITESTAT #t_PREBURN ; show all passed tests & next to be done
        bne     .dsp0 
        sub.l   #1,a5
        bra     .outta
.dsp0:
        bsr     dspinv  
        RTCSUITESTAT #t_BURNIN
        bne     .skp0
        ANYOPTESTSNEEDED
        bne     .OpTests
.skp0:
        lea.l   Bmenu,a5
        RTCSUITESTAT #t_BURNIN  ; show all passed tests & next to be done 
        bne     .dsp1
        sub.l   #1,a5
        bra     .outta          ; lemme out (don't display next tests)
.dsp1:  
        bsr     dspinv

        RTCSUITESTAT #t_POSTBURN
        bne     .skp1
        ANYOPTESTSNEEDED
        bne     .OpTests 
.skp1:  lea.l   Fmenu,a5
        RTCSUITESTAT #t_POSTBURN        ; show all passed tests & next to be done 
        bne     .dsp2
        sub.l   #1,a5
        bra     .outta
.dsp2:
        bsr     dspinv

        RTCSUITESTAT #t_INPROCESS
        bne     .skp2
        ANYOPTESTSNEEDED
        bne     .OpTests 
.skp2:  lea.l   Imenu,a5
        RTCSUITESTAT #t_INPROCESS       ; show all passed tests & next to be done 
        bne     .dsp3
        sub.l   #1,a5
        bra     .outta          ; lemme out (don't display next tests)
.dsp3:  bsr     dspinv

        RTCSUITESTAT #t_UNITASSY
        bne     .skp3
        ANYOPTESTSNEEDED
        bne     .OpTests  
.skp3:  lea.l   Umenu,a5
        RTCSUITESTAT #t_UNITASSY        ; show all passed tests & next to be done 
        bne     .dsp4
        sub.l   #1,a5
.outta:
; NONEEDED OPS...
        move.b  #0,NoOps
.dsp4:  bsr     dspinv

.OpTests:
        lea.l   menu3msg,a5     ; show all non-passed tests
        bsr     dspinv

        lea.l   Amenu,a5
        RTCISNEEDED #t_AUDIO
        beq     .skip1
        sub.l   #1,a5
.skip1: bsr     dspinv

        lea.l   Vmenu,a5
        RTCISNEEDED #t_VIDEO
        beq     .skip2
        sub.l   #1,a5
.skip2: bsr     dspinv

        lea.l   Kmenu,a5
        RTCISNEEDED #t_KEYBD
        beq     .skip3
        sub.l   #1,a5
.skip3: bsr     dspinv

        lea.l   Ymenu,a5        ; floppy
        RTCISNEEDED #t_FLOP
        beq     .skip4
        sub.l   #1,a5
.skip4: bsr     dspinv

        RTCSUITESTAT #t_INPROCESS
        beq     .skip5
.showide:
        lea.l   Hmenu,a5                        ; never highlighted
        bsr     dspinv
.skip5:
        lea.l   menu4msg,a5     ; show bottom part of menu
        bsr     dspinv

        btst    #kfail,consol   ;keyboard ok?
        bne     getkey

        moveq   #$1a,d1         ;disable joysticks
        bsr     ikbdput
        
        bsr     uconin          ; Wait for upcase char
        bsr     clearsc

* get key to change or exit
        move.l  #.exit,-(sp)    ; Give Audio-HD an RTS location
        move.l  #1,togo         ; # tests to go.. Only do one cycle here.
*~
  move.l #1,cycle               ; make sure cycle matches togo
*~
        cmpi.b  #'P',d0
        beq     PreBurn
        cmpi.b  #'B',d0
        beq     BurnIn
        cmpi.b  #'F',d0
        beq     PostBurn
        cmpi.b  #'I',d0
        beq     Assembly
        cmpi.b  #'U',d0
        beq     UnitAssemble
        cmpi.b  #'A',d0
        beq     a_udio
        cmpi.b  #'V',d0
        beq     video
        cmpi.b  #'K',d0
        beq     k_eybd
        cmpi.b  #'H',d0
        beq     h_disk
        cmpi.b  #'Y',d0
        beq     f_loppy
        addq.l  #4,sp           ; now take it away
        cmpi.b  #'D',d0
        beq     OldMenu
        cmpi.b  #'E',d0
        beq     ErrorReport
        cmpi.b  #'~',d0         ; secret key. Don't advertise it.
        beq     ForcePass
.exit:
ProdTestExit:
        bra     menu

EscapeExit:
        addq.l  #4,sp           ; fix stack pointer
        bra     ProdTestExit
*----------
OldMenu:
        move.b  #$00,ProdTestStat
        bra     MainMenu

*===============================================
* Version Error (tried to use earlier version)
VersionError:
        bsr     clearsc
        lea.l   VerErrMsg,a5
        bsr     dsptst                  ; top of screen
        bsr     uconin
        cmp.b   #'U',d0                 ; secret version update key.
        bne     EscapeExit
        WRITENVRAM #t_VERNUM,#VERSION
        bra     EscapeExit

*===========
* DoBurnIn: - startup burn-in auto if ready & no kb & scc lb
DoBurnIn:
        ANYOPTESTSNEEDED
        bne     ProdTestExit            ; can't go yet
        RTCSUITESTAT #t_PREBURN
        bne     .skip
        lea.l   NotReadyMsg,a5
        bsr     dspmsg
        bsr     uconin
        bra     ProdTestExit
.skip:
       bsr     clearsc                 ; RWS 1.18h
       lea.l   AutoBurnMsg,a5
       bsr     crlf
       bsr     dsptst
;       lea.l   cyclem,a5
;        bsr     dspmsg
*~
cache
bsr wait5sec        ;loop in cpu cache and stay off bus - yank cartridge
nocache
*~
        clr.l   d1
;;1.18h GETBURNCYCLE d1
        move.l  d1,a0
        bsr     dspadd
        bsr     crlf

*--- jump to code in RAM        
        bsr     InROM           ; see where we are in code space
        bne     BurnStart               ; if in RAM, already trig'd & ready to run..

;;      move.l  #$fffff,d0      ;RWS 1.18h
;;.lp:
;;      subq.l  #1,d0
;;      bne     .lp
.exit:
        move.l  #ProdTestExit,-(sp)     ;set return address
*----------
* copy self to RAM at $F0000, and jump there.
        move.l  #EndCartAddr,a0         ; relocated cart is at around $fb0000...
.lp1:
        cmp.b   #$fa,(a0)+      ; search for next cart
        bne     .lp1
        subq.l  #1,a0                   ; put a0 back..

        move.l  #$f0000,a1
        move.w  #$7fff,d0

;       move.l  #$fb0000,a0
.lp2:
        move.w  (a0)+,(a1)+
        dbra    d0,.lp2
*--- check ram & copy.
        move.w  #$7fff,d0
.lp3:
        move.w  -(a0),d1
        cmp.w   -(a1),d1
        bne     ABurnErr
        dbra    d0,.lp3
;       jmp     $f0006          ; this is where we JMP to next location
        jmp     $f000e          ; this is where we JMP to next location

*----------; jump to here in RAM
BurnJump:
        lea.l   YankCartMsg,a5
        bsr     dspmsg
;;1.194 move.w  sr,-(sp)
        move.w  #$2700,sr
        bsr     relocVTBL       ; fix the VTBL
        bsr     initmfp         ; reset the MFP
        bsr     setdsp
        bsr     esc_init        ; reset the font pointers
;;1.194 move.w  (sp)+,sr        ; put int level back
        bra     Start
;;      bra     BurnStart

;;1.19  bsr     initmfp
;;      bra     Trigger
;;      lea.l   Trigdmsg,a5
;;      bsr     dspmsg
;;      reset
;;      bra     start           ; restart the cart at $f0004

*---------
ABurnErr:
        lea.l   BadCopyMsg,a5
        bsr     dspmsg
        bsr     uconin
        bra     ProdTestExit

*---------
InROM:
        cmp.b   #$FA,1(sp)      ; see where we are in system..
        rts

*----------
BurnStart:
        bsr     clearsc
        bclr    #kfail,consol
        lea.l   AutoBurnMsg,a5
        bsr     dsptst
        move.w  #$ffff,d0
.lp:    nop
        dbra    d0,.lp          ; wait a tiny bit..
        bra     BurnIn


*----------------------
relocVTBL:
        move.l  #$8,a0          ;start of VTBL
        add.l   #1,a0
        move.w  #253,d0         ; 253 entries in VTBL
.rel:   cmp.b   #$fa,(a0)
        beq     .reloc
.relin:
        add.l   #4,a0
        dbra    d0,.rel
        rts
.reloc:
        move.w  #$0f,(a0)
        bra     .relin

*=========================================================
;;Trigger:
;;;     Setup to get an interrupt from EX_INT (MFP IO3).
;;* CLEAR GP0
;;      move.w  #1,GPIOC        ; bit is an output
;;      move.w  #0,GPIOD
;;;
;;      move.l  #3,d0           ; 
;;      move.l  #EXint,a2               
;;      move.l  (a2),$4000      ; temp buffer used by timer.s
;;      move.l  #$4000,a2
;;      bsr     initint
;;      move.b  #$00,mfp+gpip
;;      stop    #$2400          ; wait for EXINT : RWS 1.18e
* TURN OFF MFP INTERRUPT.
;;      move.w  #$ffff,d0       ; debounce delay
;;.lp:  nop 
;;      dbra    d0,.lp 
;;      move.b  #3,d0
;;      bsr     disint
;;      rts
;;;
*--------------------------------
* interrupt handler for extint
EXint:
        add.l   #1,d0
        rte

*==============================================
Trigger:
; get a timer count pulse from MFP
*----------------------------------
*       init the mfp/software timer
*       timer a = 2457600/200/256 = 48 Hz
;;      move.l  #EXint,mfpta      ;install vector ($134)
;;      lea     mfp,a0
;;      move.b  #$00,tadr(a0)       ;/256 (timer a data reg.)
;;      move.b  #7,tacr(a0)         ;/200 (timer a control reg.)
;;      moveq   #13,d0
;;      bsr     enabint
;;      clr.l   d0
;;.stop:        bset.b  #5,iera(a0)     ; enable timer a int.
;;      bset.b  #5,imra(a0)
;;*----------------------------------------------------
;;      stop    #$2400
;;      add.w   #$01,palette
;;      cmp.l   #100,d0
;;      bne     .stop     
;;      move.w  #$2700,sr
;;      bclr.b  #5,iera(a0)     ; enable timer a int.
;;      bclr.b  #5,imra(a0)
;;      moveq   #13,d0
;;      bsr     disint
;;      rts
        
        move.w  #$2700,sr
        move.l  #$300000,d0
.lp:
        sub.l   #1,d0
        bne     .lp
        bra     Start

*===============================================

* Production tests...
PreBurn:
* check for 14 MB board installed, if not, print message + return
        cmp.l   #sp14MBloc,topram
        beq     .preburn
        bsr     clearsc
        lea.l   Need14MBMsg,a5
        bsr     dsptst                  ; top of screen
        bsr     uconin
        bra     EscapeExit
.preburn:
        WRITENVRAM #t_SUITES,#0 ; clear suites passed
        CLEARBURNCYCLES
        bsr     PassAndNeed     ;1.19 kill all bits : passed & needed = skipped in ErrorReport
;;1.19  WRITENVRAM #t_FLOP,#0   
;;      WRITENVRAM #t_AUDIO,#0
        WRITENVRAM #t_VIDEO,#0
;;      WRITENVRAM #t_KEYBD,#0

        move.b  #t_PREBURN,ProdTestStat
        move.l  #ptbl,tst_tbl.w
        move.b  #plen,tst_len
        move.l  #pcomplt,tst_msg.w
        bsr     ClearPassBits           ; clears bits based on tst_tbl & NOT TST_LEN!
        bra     tst_mult

*-----------
BurnIn:
        RTCSUITESTAT #t_PREBURN
        beq     EscapeExit      

        move.l  #T1M24H,togo
        cmp.l   #sp1MBloc,topram
        beq     .1

        move.l  #T4M24H,togo
        cmp.l   #sp4MBloc,topram
        beq     .1

        move.l  #T14M24H,togo
.1:
;        move.l  #0,togo                 ; run forever
;        clr.l   d1
;;1.18h GETBURNCYCLE d1                 ; into d1
;        move.l  d1,cycle

        move.l #1,MIDIREC        ; MIDIREC is a temp. storage location
*~ and is used to hold cycle number of first failure
        move.b  #t_BURNIN,ProdTestStat
        move.l  #btbl,tst_tbl.w
        move.b  #blen,tst_len
        move.l  #bcomplt,tst_msg.w
        bsr     ClearPassBits           ; clears bits based on tst_tbl & NOT TST_LEN!
        bra     tst_mult
*-----------
PostBurn:
* check to see if FPU is installed and working

        tst.b   FPUStat
        bne     .postburn
        bsr     clearsc
        lea.l   NeedFPUMsg,a5
        bsr     dsptst                  ; top of screen
        bsr     uconin
        bra     EscapeExit

.postburn:
        RTCSUITESTAT #t_BURNIN
        beq     EscapeExit      

        CLEARBURNCYCLES
        move.b  #t_POSTBURN,ProdTestStat
        move.l  #ftbl,tst_tbl.w
        move.b  #flen,tst_len
        move.l  #fcomplt,tst_msg.w
        bsr     ClearPassBits           ; clears bits based on tst_tbl & NOT TST_LEN!
        bra     tst_mult
*-----------
Assembly:
        RTCSUITESTAT #t_POSTBURN
        beq     EscapeExit      

        move.b  #t_INPROCESS,ProdTestStat
        move.l  #itbl,tst_tbl.w
        move.b  #ilen,tst_len
        move.l  #icomplt,tst_msg.w
        bsr     ClearPassBits           ; clears bits based on tst_tbl & NOT TST_LEN!
        bra     tst_mult
*-----------
UnitAssemble:
        RTCSUITESTAT #t_INPROCESS
        beq     EscapeExit      

;        move.l  #0,togo                 ; run forever
        move.b  #t_UNITASSY,ProdTestStat
        move.l  #utbl,tst_tbl.w
        move.b  #ulen,tst_len
        move.l  #ucomplt,tst_msg.w
        bsr     ClearPassBits           ; clears bits based on tst_tbl & NOT TST_LEN!
        bra     tst_mult

*==================
* ClearPassBits - clear RTC passed bits based on RTCIndex, tst_tbl, DOWN TO TRAILING ZERO BYTE!
* kills D7 implied in RTCCLEARPASS
ClearPassBits:
        movem.l d0-d1/a0-a1,-(sp)
        move.l  tst_tbl,a0
.ClearList:
        move.b  (a0)+,d1        ; if after last element (0)
        beq     .Done
        lea.l   RTCIndex,a1
        move.b  #t_RAM-1,d0
.ClearNext:
        add.b   #1,d0
        cmp.b   (a1)+,d1        ; is this the matching character?
        bne     .ClearNext      ; assumes character IS in list -WILL FAIL HORRIBLY IF NOT!
        RTCCLEARPASS d0
        bra     .ClearList
.Done:
        movem.l (sp)+,d0-d1/a0-a1
        rts

*---------------------------------
* set pass & need = invisible in error rept for non done stuff
PassAndNeed:
        movem.l d0-d1/a0-a1,-(sp)
        move.b  #t_RAM-1,d0
.lp:
        add.b   #1,d0
        RTCSETPASS d0
        RTCSETNEED d0
        cmp.b   #t_XBUS,d0
        bne     .lp
        movem.l (sp)+,d0-d1/a0-a1
        rts
        

*-----------------
* ForcePass - set force status bits 
* I don't have time to be clever with this, though
* the lower case hooks might still be there.. : RWS
ForcePass:
        bsr     uconin
        cmpi.b  #'P',d0
        beq     .ForceP
        cmpi.b  #'B',d0
        beq     .ForceB
        cmpi.b  #'F',d0
        beq     .ForceF
        cmpi.b  #'I',d0
        beq     .ForceI
        cmpi.b  #'U',d0
        beq     .ForceU
        bra     menu
.ForceP:
        RTCSETSUITEPASS #t_PREBURN
        lea.l   ptbl,a0
        bra     ForceBits
.ForceB:
        RTCSETSUITEPASS #t_BURNIN
        lea.l   btbl,a0
        bra     ForceBits
.ForceF:
        RTCSETSUITEPASS #t_POSTBURN
        lea.l   ftbl,a0
        bra     ForceBits
.ForceI:
        RTCSETSUITEPASS #t_INPROCESS
        lea.l   itbl,a0
        bra     ForceBits
.ForceU:
        RTCSETSUITEPASS #t_UNITASSY
        lea.l   utbl,a0
        bra     ForceBits
*---------------------------------
* ForceBits - set force bits
* a0 killed
ForceBits:
        movem.l d0-d1/a1,-(sp)
.ClearList:
        move.b  (a0)+,d1        ; if after last element (0)
        beq     .Done
        lea.l   RTCIndex,a1
        move.b  #t_RAM-1,d0
.ClearNext:
        add.b   #1,d0
        cmp.b   (a1)+,d1        ; is this the matching character?
        bne     .ClearNext      ; assumes character IS in list -WILL FAIL HORRIBLY IF NOT!
        RTCFORCEPASS d0
        bra     .ClearList
.Done:
        movem.l (sp)+,d0-d1/a1
        bra     menu    ; get back

*----------------------------------------------
* print tests that failed in test suites
ErrorReport:
        lea.l   ErrRptMsg,a5
        bsr     dspinv
        move.b  #t_RAM,d0       ; start of test status bytes
        move.l  #TestMsgPtrs,a0
.next:
        clr.l   d1
        READNVRAM d0,d1
        tst.b   d1
        beq     .untest         ; zero.. not tested at all
        btst    #FORCEBIT,d1
        bne     .forced
* mask off needed bit
        btst    #NEEDBIT,d1
        bne     .needsdoing
        tst.b   d1
        bpl     .failed
.passed:
        move.l  (a0),a5         ; get test text
        bsr     dspinv
        bsr     dsptab
        lea.l   pasmsg,a5
        bsr     dspinv
        bsr     dsptab
        READNVRAM d0,d1
        bsr     dspbyt
        bsr     crlf
        bra     .inloop
.inloop:
        add.b   #1,d0
        add.l   #4,a0
        cmp.b   #t_XTRA1,d0     ; end of test status bytes
        bne     .next

        bsr     ShowSuiteStat

        bsr     uconin          ; wait for char
        bra     menu

.forced:
        move.l  (a0),a5
        bsr     dsptab
        bsr     dspinv
        lea.l   FORCEMsg,a5
        bsr     dspinv
        bra     .inloop
.failed:
        move.l  (a0),a5         ; get test text
        bsr     dspinv
        bsr     dsptab
        lea.l   FAILMsg,a5
        bsr     dspinv
        READNVRAM d0,d1
        bsr     dspbyt
        bsr     crlf
        bra     .inloop
.untest:        
        move.l  (a0),a5
        bsr     dspinv
        bsr     dsptab
        lea.l   UntstMsg,a5
        bsr     dspinv
        bra     .inloop
.needsdoing:                    ;test needs to be run.
        bclr    #NEEDBIT,d1
        tst.b   d1              ; can't be passed & needed at same time?
        bmi     .inloop         ; WELL.. now it can.
        bne     .failed
        bra     .untest

*--------------
ShowSuiteStat:
        bsr     crlf
        RTCSUITESTAT #t_PREBURN
        beq     .exit
        lea.l   pcomplt,a5
        bsr     dspmsg
        bsr     crlf

        RTCSUITESTAT #t_BURNIN
        beq     .exit
        lea.l   bcomplt,a5
        bsr     dspmsg
        bsr     crlf

        RTCSUITESTAT #t_POSTBURN
        beq     .exit
        lea.l   fcomplt,a5
        bsr     dspmsg
        bsr     crlf

        RTCSUITESTAT #t_INPROCESS
        beq     .exit
        lea.l   icomplt,a5
        bsr     dspmsg
        bsr     crlf

        RTCSUITESTAT #t_UNITASSY
        beq     .exit
        lea.l   ucomplt,a5
        bsr     dspmsg
        bsr     crlf
.exit:
        lea.l   VersionMsg,a5
        bsr     dspmsg
        READNVRAM #t_VERNUM,d1
        bsr     dspbyt
        bsr     crlf

        rts

*------------------------------------------------
*       Print menu and wait for selection       
*       Display menu
dspmenu:
        move.b  #$ff,ProdTestStat       
        movea.l #menumsg,a5     ;display tests
        bsr     dspinv

        btst    #kfail,consol   ;keyboard ok?
        bne.s   getkey

        moveq   #$1a,d1         ;disable joysticks
        bsr     ikbdput

*-------------------------------
*       Input selections and save. Last input is number of cycles to 
*       execute. If no number, default=1. 
*       Save tests in TSTBUF, save number of cycles in NUMBUF.
getkey: bsr     getbuf          ;get a buffer from keyboard 
*                               return with keybuf=entries
        tst     d0
        beq     menu
;        move.l  #1,cycle.w      ;init. cycle counter
        move.l  #1,cycle      ;init. cycle counter

        bclr    #savscr,consol  ;clear screen when testing starts
        lea     tstbuf,a6
        lea     numbuf,a3

*       Pop entries off (reverse order)
*       Last item may be number of cycles
*       pop until non-number is found
popkey: move.b  -(a4),d0        ;get next item
        cmpi.b  #$30,d0         ;is it a number?
        blt.s   gtkey1
        cmpi.b  #$39,d0
        bgt.s   gtkey1

*       Number=test cycles to execute
        move.b  d0,(a3)+        ;save pass count lsb->msb
        bra.s   popkey          ;stacked lsb first
                
*-------------------------------
*       Pop entries off keyboard buffer and save valid ones in TSTBUF
gtkey0: cmpa.l  #keybuf,a4      ;top?
        ble     endlin
        move.b  -(a4),d0        ;pop next item

*       Scan test table for valid test selection
gtkey1: lea     testl,a0
        moveq   #0,d7
gtkey2: cmp.b   0(a0,d7),d0     ;is it a test?
        beq.s   savtst          ;yes

        addq    #1,d7
        cmpi.b  #testln,d7
        bne.s   gtkey2          ;keep scanning until end of table
        bra.s   gtkey0          ;next entry

*-------------------------------
*       Save test selection
savtst: move.b  d0,(a6)+        ;save test (reverse order)
        bra.s   gtkey0

*-------------------------------
*       Got all entries, calculate number of passes
*       a6->tstbuf=all valid test selections
endlin: bclr    #mltpas,consol  ;single pass flag
        cmpa.l  #numbuf,a3      ;empty 
        bne.s   endln1          ;br not empty

*       No entry, default=1
;        move.l  #1,togo.w               ;default=1 cycle
        move.l  #1,togo                 ;default=1 cycle
        bra.s   endln2

*       Get number from numbuf
*       a0-> lsb, a3-> msb
endln1: lea     numbuf,a0       ;start with lsb
;        clr.l   togo.w          ;passes to go
        clr.l   togo            ;passes to go

        bsr     ascdec          ;convert ascii decimal input to hex number
;        move.l  d2,togo.w
        move.l  d2,togo
*       Set single test flags:
*       mltpas set=more than one cycle of a test
*       mlttst set=more than one test selected
endln2: bset    #mltpas,consol  ;default: multiple cycles of test
        bset    #mlttst,consol  ;default: more than 1 test selected
        cmpi.l  #1,togo         ;single pass?
        bne.s   endln3          ;br no
        bclr    #mltpas,consol  ;clear multi-pass flag
endln3: cmp.l   #tstbuf+1,a6    ;test buffer pointer
        bgt.s   startcd         ;br if more than one test in buffer
        bclr    #mlttst,consol  ;clear multi-test flag

*-------------------------------
*       Now test buffer has all tests to run, togo has number of cycles
*       Start executing from beginning of test buffer
startcd:
        clr.b   autotst         ;flag for auto test mode
        move.b  consol,d0
        andi.b  #$38,d0         ;if any multiple mode selected
        beq     strcd1
        move.b  #$ff,autotst    ;...set flag
strcd1: suba.l  #1,a6
        move.l  a6,tstbufl.w    ;end of test buffer (first test)

************************************************************************
*       Execute a command line          
*       tstbufl: buffer of tests, in order first (low) to last (high)
*               (=list of ascii capital letters)
*       togo:   number of cycles (hex)
************************************************************************

*       Start or repeat from beginning of test buffer
start0: move.l  tstbufl.w,tstptr.w      ;next test=first test

*-------------------------------
*       Get next test from command buffer
nxttst: move.l  tstptr.w,a0     ;get pointer to next test
        move.b  (a0),d0         ;get character

*       Get command index
        lea     testl,a1
        clr.l   d2
nxttst2:
        cmp.b   0(a1,d2),d0     ;match with command table
        beq.s   gotcmd
        addq    #1,d2
        cmpi.b  #testln,d2
        beq     menu            ;this cannot happen (but just in case...)
        bra.s   nxttst2

*       Got an index, get address and test
gotcmd: btst    #savscr,consol  ;first time?
        bne.s   gotcmd1

*       Clear screen on first cycle
        bsr     clearsc
        move.w  #2,scrtop       ;scroll from line 2
        bsr     crlf            ;move cursor down
        bsr     crlf
        bra.s   gotcmd2

*       Clear the top two lines if not first cycle
gotcmd1:
        bsr     clr2lin

********************************
*       Jump to the test routine
gotcmd2:
        bset    #savscr,consol  ;save screen from now on
        lea     testad,a0
        lsl.b   #2,d2           ;index * 4 = address table offset
        move.l  0(a0,d2),a1     ;get address
        jsr     (a1)            ;go test
********************************

*-------------------------------
*       Return from test

rettst: bsr     chkred
        beq.s   rettst1
        move.w  #green,palette  ;pass if not fail

*       Check for more tests to run
rettst1:
        move.b  consol,d0
        andi.b  #$30,d0         ;check multi- test, cycle flags
        beq.s   alldone         ;br single test

*       Check for esc key during test
*       If found, print 'stopped' and wait for key
        bsr     chkesc          ;esc test loop?
        beq.s   wtmsg           ;continue if not esc
        bne     menu            ;else quit
        
*       Multiple tests, wait a bit then get next test
wtmsg:  move    #300,d1         ;very brief delay so message is readable
wtmsg0: bsr     wait            ;200*2.5ms=1/2 sec.
        dbra    d1,wtmsg0

*       Get next test to run. Branch to here from Q and Z tests.
inctst: sub.l   #1,tstptr
        move.l  tstptr.w,d0
        cmp.l   #tstbuf,d0      ;at top? (top=last test)
        bge     nxttst          ;no, next test

*-------------------------------
*       All tests done
*       Any more cycles?
nxtpas: bsr     dspcycl         ;update count and display

*       Any more?
        sub.l   #1,togo
        tst.l   togo            ;if neg. (0 passes entered),
        beq.s   alldone         ;...will do 2**32 cycless

*       Next cycle
        bsr     gensnd          ;generate sound for pass/fail
        bra     start0

*-------------------------------
*       All cycles done
alldone:
        bclr    #autoky,consol  ;test and clear
        bne.s   alldn2          ;skip conin if set (hi-res or color test)
        bsr     gensnd          ;generate sound for pass/fail

alldn1: bsr     conin           ;wait for key before clearing screen
        cmpi.b  #' ',d0
        bne.s   alldn1
alldn2: bra     menu
*
********************************

*-------------------------------
*       Q--Execute all tests which do not require operator interaction 
qtest:  move.l  #qtbl,tst_tbl.w
        move.b  #qlen,tst_len
        move.l  #qcomplt,tst_msg.w
        bra.s   tst_mult

*--------------------------------
*       Z--Execute the internally performed tests
ztest:  move.l  #ztbl,tst_tbl.w
        move.b  #zlen,tst_len
        move.l  #zcomplt,tst_msg.w

*-------------------------------
*       Execute a multiple test selection: Q or Z
*       Entry:  tst_tbl=table of test addresses
*               tst_len=number of tests
*               tst_msg=completion message
*               togo=number of cycles to perform. If other tests on 
*                  command line, not used (togo=cycles of all tests).
tst_mult:
*~
     move.l     #0,templ        ;clear location used in decimal count
*~
        move.l  #1,cycle
        move.b  #$00,ProdTestStat+1
        move.w  #blue,ProdBkgnd
        move.b  #$ff,autotst    ;flag automatic sequence
        bset    #qztest,consol  ;don't wait in color, keyboard tests
        bsr     crlf            ;top two lines for temporary messages
        bsr     crlf
        move    #2,scrtop       ;scroll from line 2 (error messages)

;; RWS 1.18i - taken out for JS. Now have to run 1000 cycl w/out power loss or red screen.
;;      move.l  #1,d1
;;      cmp.b   #t_BURNIN,ProdTestStat  ;if in burn-in
;;      bne     .skip
;;      GETBURNCYCLE d1         ; find if this is the first time
;;      cmp.w   #1,d1
;;      beq     .skip           ; carry on if first time through
;;      RTCSUITESTAT #t_BURNIN
;;      bne     .skip           ; passed
;;      CLEARBURNCYCLES         ; reset cycles if (BURNIN ^ !PASSED ^ !FIRST)
;;      move.w  #1,d1
;;.skip:
;;      move.l  d1,cycle

qcycle: clr.b   alltst          ;start a cycle

*       Prepare for next test
nextq:  clr.l   d0
        move.b  alltst,d0
        move.l  tst_tbl.w,a0
        move.b  0(a0,d0),d1     ;get test (R,O,C,...)
        
        lea     testl,a1        ;table of tests, corresponds to address table
        clr.l   d2
nxtq:   cmp.b   0(a1,d2),d1     ;match letter with table to get offset
        beq.s   gotq
        addq    #1,d2
        bra.s   nxtq
gotq:   lea     testad,a0
        lsl     #2,d2           ;4x offset for address
        move.l  0(a0,d2),a1     ;get address
        jsr     (a1)            ;test

*       Return from test
*       Display green/pass if no errors
        tst.b   ProdTestStat
        bmi     .normal
*- for prod test, only flash red screens
        bsr     chkred
        bne     .ProdPass
        move.b  #$ff,ProdTestStat+1
        move    #red,ProdBkgnd
.ProdPass:
        move    ProdBkgnd,palette
        bra     .skipnorm       
*-
.normal: 
        bsr     chkred
        beq.s   gotq1
        move    #green,palette
        lea     pasmsg,a5
        bsr     dsppf
.skipnorm:
*       Check for esc key during test
*       If found, print 'stopped' and wait for ret or other
gotq1:  bsr     chkesc          ;esc test loop?
        bne     menu

        bsr     qdsp            ;wait a while, then clear 2 lines
        bclr    #autoky,consol  
        add.b   #1,alltst
        move.b  tst_len,d0
        cmp.b   alltst,d0       ;all done?
        bne     nextq

*       Completed a cycle of Z or Q
qcomp:  move.l  tst_msg,a5
        bsr     dsptst
        btst    #mlttst,consol  ;more tests selected?
        bne     inctst          ;get next one in buffer

*       Only Z or Q test selected
        bsr     dspcycl         ;update count and display

*       All done
        tst.b   ProdTestStat
        bmi     .normal
*- insert Production Test status here   
        clr.l   d1
        move.b  ProdTestStat,d1 ; test bit of test suite running
        tst.b   ProdTestStat+1
        bmi     .failed
        cmp.b   #t_BURNIN,ProdTestStat
        beq     .burnincycle
        RTCSETSUITEPASS d1
.notburn:
        move    #green,palette
        bra     .normsk1
.failed:
        RTCSETSUITEFAIL d1
        move    #red,palette
*~
        move.l  MIDIREC,cycle
*~        move.l  #1,cycle   ;

.normsk1:                       ; only in burn-in test right now...
        move    palette,ProdBkgnd       ; keep red/green thru tests...
*~
        move.l  cycle,MIDIREC              ; save cycle count for failures
*~
        sub.l   #1,togo
        tst.l   togo
        bne     qcycle
        bra     .normskip

.burnincycle:
;;1.18j ADDBURNCYCLE d1
** check size of RAM card & check counter against time values
        cmp.l   #sp1MBloc,topram
        beq     .OneMBurn
        cmp.l   #sp4MBloc,topram
        beq     .FourMBurn
        cmp.l   #sp14MBloc,topram
        beq     .FteenMBurn
        bra     .DoneBurnTime   ; should never happen

.OneMBurn:
        cmp.l   #T1M24H+1,cycle
*~
        blt     .normsk1        ; BurnNonDone
        bra .DoneBurnTime
;        bra    .normsk1 
.FourMBurn:
        cmp.l   #T4M24H+1,cycle
        blt     .normsk1        ; BurnNonDone
        bra     .DoneBurnTime
.FteenMBurn:
        cmp.l   #T14M24H+1,cycle
        blt     .normsk1        ; BurnNonDone
.DoneBurnTime:
        RTCSETSUITEPASS #t_BURNIN
        bra     .notburn        ; green screen...
*~
.normal:
*       Any more cycles?
        sub.l   #1,togo
        tst.l   togo            ;if neg. (0 passes entered), do 2**32 cycles
        bne     qcycle          ;more Q or Z cycles

        bsr     chkred
        beq.s   allq
        move    #green,palette
        lea     pasmsg,a5
        bsr     dsppf
.normskip:
allq:   bra     alldone

        
*       Wait a while, erase top 2 lines (window for temp. test messages)
qdsp:   move    #300,d1         ;very brief delay so message is readable
qdsp1:  bsr     wait            ;300*2.5ms=3/4 sec.
        dbra    d1,qdsp1
        bsr     clr2lin         ;clear 2 lines
        rts

*********************************
*       SUBROUTINES             *
*********************************

*-------------------------------
*       Clear line 0 and all but
*       15 characters of line 1
clr2lin:
        bsr     escjs           ;save cursor
        bsr     escfn8          ;home
        move    #145,d1         ;save last 15 characters where cycle count is
        bsr     dspspcs
        bsr     escks           ;restore cursor
        rts

*-------------------------------
*       Check for esc key. If got it, print stopped,
*       wait for next key, erase message.
*       If not, just return.
*       Exit:   eq to continue, ne to quit
chkesc: bsr     constat         ;any key?
        beq.s   tstcont         ;br no  
        bsr     conin           ;get the key
        cmp.b   #esc,d0         ;was it esc?
        bne.s   chkesc          ;empty the buffer

*       Print stop message, wait for key
*       Erase message, check for RET key
*       Exit:   d0=key, eq if RET, else ne
pause:  lea     stopm,a5
        bsr     dspmsg
        bsr     conin           ;wait for next key
        move.b  d0,-(sp)
        move    v_cur_cy,d1     ;this line
        clr     d0              ;beginning of line
        bsr     move_cursor
        bsr     escK            ;erase to end of line
        move.b  (sp)+,d0
        cmpi.b  #cr,d0          
        beq.s   tstcont
        andi    #$1b,ccr        ;ne (quit)
        rts
tstcont:
        ori     #4,ccr          ;eq (continue)
        rts


*-------------------------------
*       Update and display pass count
*       cycle.l=decimal count
dspcycl:
        bsr     escjs           ;save cursor position
        moveq   #66,d0
        moveq   #1,d1
        bsr     move_cursor     ;position cursor
        lea     cyclem,a5
        bsr     dspmsg          ;"Cycle: "
        movea.l cycle,a0        ;current cycle
        bsr     dspadd          ;display 6 digit number
        bsr     crlf            ;cr, lf for terminal
        move.l  #1,templ.w      ;inc cycle count
        lea     templ+4,a1      ;temp reg.
        lea     cycle+4,a0
        moveq   #2,d0
dspcyc1:
        abcd    -(a1),-(a0)     ;maintain decimal count
        dbra    d0,dspcyc1      ;for 3 bytes
        bsr     escks
        rts

*-------------------------------
*       Check for error
*       Exit:   eq if red screen
chkred: move.w  palette,d0
        andi.w  #$777,d0
        cmpi.w  #red,d0
        rts

*-------------------------------
*       Get and save keystrokes in KEYBUF until RETURN key.     
*       Buffer is 32 characters max. BS erases previous key.
*       Video 50/60 and HELP are immediate action (no cr).
*       Exit:   a4=ptr to last char +1
*               d0 eq if buffer full or empty
getbuf: lea     keybuf,a4
        moveq   #63,d0          ;clear keybuf,tstbuf, and numbuf
clrkbuf:
        clr.b   (a4)+           ;clear buffers
        dbra    d0,clrkbuf
        lea     keybuf,a4
        bsr     kbempty         ;clear keystrokes

getbf0: bsr     conin           ;get some input

*       Check immediate type keys: help, ?, E, B, V, $ 
        cmpi.b  #esc,d0
        beq     getbf3
        cmpi.b  #$62,d1         ;help key scan code?
        beq     mhelp
        cmpi.b  #'?',d0
        beq     mhelp

        cmpi.b  #$61,d1
        beq     gotos

        cmpi.b  #'E',d0         ;E
        beq     s1menu          ; * CHANGED + MOVED TO E MENU : 19DEC91 : RWS         
*************************************************************************
*        cmpi.b  #'B',d0         ;B     ; MOVED TO E MENU : RWS : 19DEC91
*        beq     bpsrate 
*        cmpi.b  #'X',d0         ;X - cycle
*        beq     v_50_60
*************************************************************************
        cmpi.b  #'H',d0         ;H - IDE hard disk
        beq     h_disk
*        cmpi.b  #'H',d0         ;H - high resolution
*        beq     h_res
        cmpi.b  #'A',d0         ;A - audio
        beq     a_udio
        cmpi.b  #'V',d0         ;V - video      ; 21JAN92 : RWS : Changed from Color
        beq     video
        cmpi.b  #'K',d0         ;K - keyboard
        beq     k_eybd
        cmpi.b  #'$',d0         ;hidden key
        beq     date
        cmpi.b  #8,d0           ;backspace?
        bne     getbf2

*       Process backspace
        cmpa.l  #keybuf,a4
        beq.s   getbf0          ;all backed up 
        bsr     bckspc          ;erase screen char.
        clr.b   -(a4)           ;backup ptr and write term. char.
        bra.s   getbf0

getbf2: cmpi.b  #$d,d0          ;return?
        beq.s   getbf6
        
*       Save character and display
getbf3: move.b  d0,(a4)+        ;save key in buffer
        move.b  d0,d1
        bsr     ascii_out       ;display character
        cmpa.l  #keybuf+31,a4
        ble     getbf0          ;get more or, if full, quit
        lea     fullbuf,a5
        bsr     dspmsg
getbf4: moveq   #0,d0           ;empty (cr only)
        rts

*       Got return key
getbf6: cmpa.l  #keybuf,a4      ;anything in buffer?
        beq.s   getbf4
        tst.b   d1              ;key or RS232?
        beq.s   getbf7          ;br if RS232
        cmpi.b  #$9c,brkcod     ;wait for return break
        beq.s   getbf7
        cmpi.b  #$f2,brkcod     ;or enter break
        bne.s   getbf6
getbf7: rts                     

*********************************
;w_r_mem: * MOVED TO SUBMENU : RWS : 19DEC91

a_udio: bsr     clearsc
        bsr     audiotst
        bra     gb_ret

;h_res:  * MOVED TO VIDEO : RWS : 22JAN92
;c_olor: * MOVED TO VIDEO : RWS : 22JAN92
  
h_disk:
        bsr     clearsc
        bsr     hddtst
        bra     gb_ret

k_eybd:
        bsr     clearsc
        bsr     keytst
        bra     gb_ret

f_loppy:
        bsr     clearsc
        bsr     floptst
        bra     gb_ret

*********************************
*       display date of this version
date:   bsr     clearsc
        lea     datem,a5
        bsr     dspmsg
        bsr     conin
        cmpi.b  #'*',d0
        beq.s   date1
;;RWS   cmpi.b  #'W',d0         ; moved to supervisor cartrige
;;      beq     WipeNVRAM
        bra.s   dateX

*RWS    cmpi.b  #'T',d0
*       bne.s   dateX
*       bsr     conin
*       cmpi.b  #'O',d0
*       bne.s   dateX
*       bsr     conin
*       cmpi.b  #'S',d0
*       bne.s   dateX
gotos:
mTOS1:
        movea.l TOSreturn,a6    ; get TOS boot address
        clr.l   $420            ; MEMVALID
        clr.b   $424            ; MCU nibble
        clr.l   $43a            ; MEMVAL2
        move.w  #$2700,sr
        move.w  #$100,$ff8606
        move.w  #$0,$ff8606
        reset
        jmp     (a6)            ; return to TOS Boot code 
date1:
        lea     myname,a5
        bsr     dspmsg
        bsr     conin
dateX:  
        bra     gb_ret

WipeNVRAM:
        bsr     ClearNVRAM
        bra     menu

********************************
*       Video output rate toggle 
;v_50_60: * MOVED TO SUBMENU : RWS : 19DEC91

********************************
*       Display Help screen
mhelp:  bsr     clearsc
        lea     help1,a5
        bsr     dspmsg
        bsr     conin
        lea     help2,a5
        bsr     dspmsg
        bsr     conin
gb_ret: moveq   #0,d0           ;flag empty getbuf ret
        rts

*********************************
*       Set RS232 rate
;bpsrate: * MOVED TO SUBMENU : RWS : 19DEC91

*-------------------------------
*       convert hex to bcd
*       entry:  d0.w = hex
*       exit:   d1.l = bcd
*       uses:   d0,d1,d2,d3
cnvdec: clr.l   d3
        clr.l   d1
div10:  andi.l  #$ffff,d0
        divu    #10,d0          ;divide by 10
        move.l  d0,d2           ;get remainder (it is the decimal digit)
        swap    d2
        bsr     hexbcd2
        cmp.w   #10,d0          ;more division?
        bge     div10           ;continue dividing the result of last divide
hexbcd1:
        move    d0,d2           ;save the ms digit
        bsr     hexbcd2
        rts     
        
*       save remainder (d2) in d1, shifted (d3) to bcd value
hexbcd2:
        andi.l  #$ff,d2
        lsl     d3,d2           ;shift into position
        or.l    d2,d1           ;accumulate digits
        add     #4,d3           ;# of bits in a digit
hexbcdx:
        rts
        
*-------------------------------
*       Convert ascii decimal number to hexadecimal
*       Entry:  a0 -> lsb (start), a3 -> msb (end)
*       Exit:   d2=hex
*       Uses:   d0-d2, a0

ascdec: clr.l   d2              ;result
        clr.l   d0
        cmp.l   a0,a3           ;br empty
        beq.s   ascdec1
        moveq   #1,d1           
*       Pop digits off stack, lsb first
*       Add up digit*place value to get decimal number
*       Save decimal value 
ascdec2:
        move.b  (a0)+,d0        ;get digit
        andi.l  #$f,d0          ;strip off ascii bits   
        mulu    d1,d0           ;multiply digit by place value
        add.l   d0,d2           ;a*1 + b*10 + c*100...
        mulu    #10,d1          ;next place value
        cmpa.l  a0,a3           ;all digits?
        bhi.s   ascdec2
ascdec1:
        rts

*--------------------------------
*       set pointers for keyboard                               
*       on exit:                                                
*       a0 points to ikbd buffer record                         
*       a1 points to keyboard base register                     

ikbdptr:
        movea.l #kbufrec,a0     ;point to ikbd buffer record
        movea.l #keyboard,a1    ;point to keyboard register base
        rts

*-------------------------------
*       Put byte to keyboard                    
*       Exit:   d1=byte                         
*               eq if sent, ne if time-out      
ikbdput:
        movem.l d7/a0-a1,-(a7)
        bsr     ikbdptr
        moveq   #200,d7
ikput0: btst    #1,comstat(a1)  ;test xmt empty
        bne.s   ikput1
        subq    #1,d7
        beq.s   ikput2          ;time's up      
        bra.s   ikput0
ikput1: move.b  d1,iodata(a1)
        ori     #4,ccr          ;zero
ikput3: movem.l (a7)+,d7/a0-a1
        rts                     ;done for now
ikput2: andi    #$fb,ccr        ;non-zero
        bra.s   ikput3

*-------------------------------
*       Clear keystrokes
kbempty:
        move    d0,-(a7)
        clr     kibufhead
        clr     kibuftail
        move.b  udr+mfp,d0
        move    (a7)+,d0
        rts

* constat & conin moved to console.s : RWS : 29JAN92

        .data
        .even
*********************************

*       Test select keys
testl:  dc.b    'ROGMTDPFLQZSIXKH'        ; MUST MATCH ORDER BELOW IN TESTAD
testln  equ     *-testl

qtbl:   dc.b    'ROMTDPFGLSIX'   ;q tests 
qlen    equ     *-qtbl          
ztbl:   dc.b    'ROTFGL'       ;z tests
zlen    equ     *-ztbl
* ====== NEW PRODUCTION LINE TESTS =======
; Proper test order
**      dc.b    'TLROGMSPDFIKH' 

*-- pre-burn                    ; also go set clear pass bits up there someplace..
;       dc.b    'p'
ptbl:   dc.b    'TLOGMSPDFIKH'  ; Pre-burn in 
plen    equ     *-ptbl
        dc.b    'A',0                ; + A,V,K,IDE 
;         dc.b    'AVY',0
*-- burn-in
;       dc.b    'b'
btbl:   dc.b    'TRLOGMSD'   
blen    equ     *-btbl
        dc.b    0
*-- post-burn
;       dc.b    'f'
ftbl:   dc.b    'TLROGMSPDFIKHX'        ;  
flen    equ     *-ftbl
        dc.b    'AVY',0 
*-- in process assembly
;       dc.b    'i'
itbl:   dc.b    'FK'          
ilen    equ     *-itbl  
        dc.b    'A'             ; RWS.TP 1.18e
        dc.b    0
*-- final    
;       dc.b    'u'
utbl:   dc.b    'TLROGMSPDFI' ;
ulen    equ     *-utbl
        dc.b    'AVKY',0          ; + A,V,K,IDE 

        .even

*       Test address table
testad: dc.l    ramtst          ;R      
        dc.l    romtst          ;O
        dc.l    blttst          ;G
        dc.l    miditst         ;M
;        dc.l    rs232tst        ;S     N/A For Sparrow      
        dc.l    timtst          ;T      
        dc.l    SDMA            ;D
        dc.l    portst          ;P
        dc.l    floptst         ;F
;       dc.l    exblt            ;Y
        dc.l    rtctst          ;L
        dc.l    qtest           ;Q
        dc.l    ztest           ;Z
        dc.l    scctst          ;S      ; NOW : RWS: I hope this is the S test now..
        dc.l    scsitst         ;I
        dc.l    testexp         ;X dummy for now (expansion test fixture)      
        dc.l    keytst          ;K
        dc.l    hddtst         ;H
sizetbl:
        dc.b    4,8,$10,$20,$40,$80,$e0         ;RAM sizing table 256k--16M
sizemax equ     *-sizetbl-1



* index to test messages & RTC RAM.
RTCIndex:
        dc.b    'RLTOSMGPDIFHAVKX',0

        .even

TestMsgPtrs:                    ; pointers to messages for build sheet & error report
; these must be in order of NVRAM locations. 
        dc.l    t_RAMMsg
        dc.l    t_RTCMsg
        dc.l    t_TIMEMsg
        dc.l    t_ROMMsg
;       dc.l    t_SERIALMsg
        dc.l    t_LANMsg
        dc.l    t_MIDIMsg
        dc.l    t_SBLITMsg
;       dc.l    t_LBLITMsg
        dc.l    t_PRTMsg
        dc.l    t_DSPMsg
        dc.l    t_SCSIMsg
        dc.l    t_FLOPMsg
        dc.l    t_IDEMsg
        dc.l    t_AUDIOMsg
        dc.l    t_VIDEOMsg
        dc.l    t_KEYBDMsg
        dc.l    t_XBUSMsg
        dc.l    t_XTRA1Msg

        dc.l    t_AGING
        dc.l    t_ICT


**************
*            *
*  messages  *
*            *
**************

myname: dc.b    tab,' by RWS',cr,lf,eot


*       RAM size message table
model:  dc.l    model0
        dc.l    model1
        dc.l    model2
        dc.l    model3
        dc.l    model4
        dc.l    model5
        dc.l    model6

model0: dc.b    '256k RAM',eot
model1: dc.b    '512k RAM',eot
model2: dc.b    '1M RAM  ',eot
model3: dc.b    '2M RAM  ',eot
model4: dc.b    '4M RAM  ',eot
model5: dc.b    '8M RAM  ',eot
model6: dc.b    '14M RAM ',eot
kbrevm: dc.b    ' Keyboard rev. ',eot

t_RAMMsg:       dc.b    'RAM ',tab,tab,eot
t_RTCMsg:       dc.b    'RTC ',tab,tab,eot
t_ROMMsg:       dc.b    'ROM ',tab,tab,eot
;t_SERIALMsg:   dc.b    'Serial   ',tab,eot
t_FLOPMsg:      dc.b    'Floppy   ',tab,eot
t_SBLITMsg:     dc.b    'Short Blit    ',eot
;t_LBLITMsg:    dc.b    'Long Blit',tab,eot
t_PRTMsg:       dc.b    'Prt/Ports',tab,eot
t_TIMEMsg:      dc.b    'Timing   ',tab,eot
t_XBUSMsg:      dc.b    'Expansion Bus ',eot
t_MIDIMsg:      dc.b    'MIDI',tab,tab,eot
t_DSPMsg:       dc.b    'DSP/Audio Port',eot
t_LANMsg:       dc.b    'SCC Serial    ',eot
t_IDEMsg:       dc.b    'IDE ',tab,tab,eot
t_SCSIMsg:      dc.b    'SCSI',tab,tab,eot
t_VIDEOMsg:     dc.b    'Video    ',tab,eot
t_AUDIOMsg:     dc.b    'Audio    ',tab,eot
t_KEYBDMsg:     dc.b    'Keyboard ',tab,eot
t_XTRA1Msg:     dc.b    'Extras',tab,eot

t_AGINGMsg:     dc.b    'Aging ',tab,tab,eot
t_ICTMsg:       dc.b    'In Circuit',tab,eot

*               '1234567890123456789012345678901234567890'

*       character preceded by 1 is printed in inverse video
menumsg:
  dc.b  tab,invtog,'UNATTENDED',invtog,cr,lf,lf
  dc.b  tab,iv,'R RAM & SRAM ',tab,tab,iv,'O O.S. ROM         ',tab,iv,'M MIDI',cr,lf
  dc.b  tab,iv,'S SCC Serial ',tab,tab,iv,'T Timing           ',tab,iv,'D DSP Port',cr,lf
  dc.b  tab,iv,'F Floppy Disk',tab,tab,iv,'P Printer/Joy/Game ',tab,iv,'L Real Time Clock',cr,lf
  dc.b  tab,iv,'G Short BLiT ',tab,tab,iv,'I SCSI Port        ',tab,iv,'X Expansion Bus',cr,lf
  dc.b  lf
  dc.b  tab,iv,'Q Run all unattended tests (R,O,M,S,T,D,F,P,L,G,Y,I,X)',cr,lf
  dc.b  tab,iv,'Z Run unattended internal tests (R,O,T,F,L,G)',cr,lf,lf

  dc.b  tab,invtog,'OPERATOR',invtog,cr,lf
  dc.b  tab,iv,'A Audio',tab,iv,'V Video',tab,iv,'K Keyboard',tab,iv,'H IDE Hard Disk',cr,lf,lf

  dc.b    tab,iv,'E Examine/Modify System',cr,lf
  dc.b    tab,iv,'? Help',cr,lf
  dc.b    lf
  dc.b    tab,'Enter letter(s), and RETURN: ',eot

menu2msg:
  dc.b  '-----',invtog,'UNATTENDED',invtog,'-----',cr,lf,eot

        dc.b    invtog
Pmenu:  dc.b  tab,iv,'P Pre Burn-In   ',tab,cr,lf,eot
        dc.b    invtog
Bmenu:  dc.b  tab,iv,'B Burn-In  ',tab,tab,cr,lf,eot
        dc.b    invtog
Fmenu:  dc.b  tab,iv,'F Post Burn-In  ',tab,cr,lf,eot
        dc.b    invtog
Imenu:  dc.b  tab,iv,'I In Process Assembly',cr,lf,eot
        dc.b    invtog
Umenu:  dc.b  tab,iv,'U Assembled Unit',tab,cr,lf,eot

menu3msg:
  dc.b  lf
  dc.b  '-----',invtog,'OPERATOR',invtog,'-----',cr,lf,eot
        dc.b    invtog
Amenu:
  dc.b  tab,iv,'A Audio',tab,tab,tab,cr,lf,eot
        dc.b    invtog
Vmenu:
  dc.b  tab,iv,'V Video',tab,tab,tab,cr,lf,eot
        dc.b    invtog
Kmenu:
  dc.b  tab,iv,'K Keyboard  ',tab,tab,cr,lf,eot
        dc.b    invtog
Ymenu:
  dc.b  tab,iv,'Y Floppy Disk',tab,tab,cr,lf,eot
        dc.b    invtog
Hmenu:
  dc.b  tab,iv,'H IDE Hard Disk',tab,cr,lf,eot
        dc.b    invtog

menu4msg:
  dc.b  cr,lf
  dc.b  '================================',cr,lf
  dc.b  lf
  dc.b  tab,iv,'D Diagnostic Field Service Menu',cr,lf
  dc.b  tab,iv,'E Error Report',cr,lf
  dc.b  lf
  dc.b  tab,'Enter letter: ',eot

*               '1234567890123456789012345678901234567890'
pasmsg: dc.b    'Pass',eot
falmsg: dc.b    'Fail at cycle:',eot
FAILMsg:        
        dc.b    invtog,bs,' FAIL ',invtog,tab,eot
;PASSMsg:        
;       dc.b    'PASS',tab,eot
FORCEMsg:       
        dc.b    invtog,'FORCED',invtog,cr,lf,eot
UntstMsg:
        dc.b    'Untested',cr,lf,eot
Ptestmsg:
        dc.b    tab,'Tested',eot
qcomplt:
        dc.b    'Q Tests Completed',eot
zcomplt:
        dc.b    'Z Tests Completed',eot

NotReadyMsg:
        dc.b    'Not ready for Burn-in',cr,lf,eot
AutoBurnMsg:
        dc.b    '   Please remove cartridge at this time! Automatic Burn-In Starting.. 6 Seconds',cr,lf,eot
Need14MBMsg:
        dc.b    '14 MB RAM board required to run Pre Burn-In',cr,lf,eot
NeedFPUMsg:
        dc.b    'FPU must be installed to run Post Burn-In',cr,lf,eot

VerErrMsg:
        dc.b    'Diagnostic Version Error! Use the same version as used for Pre Burn-In',cr,lf,eot
VersionMsg:
        dc.b    'Internal Version: ',eot
BadCopyMsg:
        dc.b    'Error Copying Diagnostic to RAM. Use manual Burn-In',cr,lf,eot
YankCartMsg:
        dc.b    'System Stuck. Press RESET to try again.',cr,lf,eot

pcomplt:        dc.b    'Pre Burn-In tests Completed',eot
bcomplt:        dc.b    'Burn-In tests Completed',eot
fcomplt:        dc.b    'Post Burn-In tests Completed',eot
icomplt:        dc.b    'In Process Assembly tests Completed',eot
ucomplt:        dc.b    'Final Assembly tests Completed',eot

ErrRptMsg:
        dc.b    invtog,'ERROR REPORT',invtog,cr,lf
        dc.b    lf,eot

keybdm: dc.b    'Keyboard failed, connect RS232 terminal',cr,lf,eot
cyclem: dc.b    'Cycle: ',eot
stopm:  dc.b    'Stopped. Press RET to continue, other key to quit.',eot
fullbuf:
        dc.b    'Keyboard buffer full',cr,lf,eot

;Trigdmsg:      dc.b    'Trigger Error, RESET and try again',cr,lf,eot
        
        .include        help1           ; heaved for simplicity (?) here...
   
