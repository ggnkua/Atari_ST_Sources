        .extern enabint,disint,setdsp,initint
        .globl start    ; used by excep
init2 = 1
*  ===================================
*  Initialization for ST test
* 31JAN92 : RWS : Added stuff for 030+DSP sparrow board
* 03FEB92 : RWS : REMOVED GENLOCK TEST ON POWER UP - PUT THIS BACK!!!                
* 01APR92 : RWS : REWROTE ENTIRE DIAGNOSTIC. PUT IN FPU MOD FOR REV 1 COMBEL
*  Mar 14, 91: shut off mfp interrupt after gen lock left it on. 
*       (RAM failure after floppy test)
*  Aug 22, 89: shut off monomon int until CPU speed verified
*  July 29, 89: init all palettes
*  June 28, 89: new memory config algorithm for ST/STe
*       tests for game controller ports, scroll, dma sound, genlock
*  May 28, 87 rs232 flag: RSRATE. INITFLG for initialization complete (timtst). 
*       Wait for vblank before setting resolution.
*       Update for compatablity with both manufacturing and Field Service.
*       FS rev. 3.61. Manufacturing next release (4.1?)
*       Test for bus error.
*  11/21/86 Mod FATAL: repeat walks 1 across 16 bits.
*  1/15 Mod FATAL routine: print data written, data read. First RAM test 
*       writes all low, all high. Entries to FATAL are identical.
*  1/14 Split off menu from power-up sequence
*  1/2 New menu screen, tests are no longer grouped together.
*     Operator enters letter(s) of test(s), number of passes.
*  1/1/86 Print address to RS232 if fatal RAM fail.
*  Rev. 3.4
*  11/8 Fix problem of mysterious keystroke which stops test in continuous 
*       mode: now stops only on space bar.
*  11/6 Final debug for 3.2(?) 
*  10/28 checks for loopback connector on reset, avoids reading RS232 input.
*       Fatal RAM failure does not display to screen; repeat test.
*  Uses RS232 as alternate display and input device.
*  Tests Vertical Sync, Horizontal Sync, and Display Enable.
*  Checks for stuck key on power-up. 
*  21 Feb, '86  Include Japan's patch to reset MIDI acia
*  10 Apr       Add error codes.
*  15 May 85 Final 1.0

        
*  1. test low memory
*  2. establish exception vectors
*  3. initialize display
*  4. test timers
*  5. initialize I/O
*  6. reset keyboard and get status

*  ====================================

        .text

LOWRAM  equ     $8      ;start of ram 
SAFRAM  equ     $800    ;top of memory tested initially
rs96    equ     2       ;timer d data for rs232=9600
mfp2    equ     $fffffa81

MFP2    =       0       ; only 1 MFP in sparrow
*       ram config/sizing equates
mpat0           equ     $a5a51234
mpat1           equ     $5a5a8765
sp512kloc       equ     $80000
sp1MBloc        equ     $100000
sp4MBloc        equ     $400000
sp14MBloc       equ     $e00000         ; 14 mb

*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

        dc.l    $fa52235f       ;magic numbe
;        bra.s   start
;       jmp     BurnJump                ; entry point for RAM-based system.
        bra isburn              ;burn in test?
start:                    ;normal start
        reset             ; turns off 68030 caches.
Start:                    ;start for RAM burn in
        move.w  #$2700,sr
        clr.l   d0
        vbrw                    ;set vbr to 0

        move.b  SPConfig,d0     ; set video types & stuff
        lsr.b   #6,d0
        btst.b  #1,SPConfig
        beq     setit
        bset    #7,d0
setit:  
        move.w  d0,v_VMC

        move.b  #$5,SPControl
* ENDSPARROW
        move.l  #$1000,sp
********************** ENDSWIPE
;;Start:
;;      move.w  #$2700,sr
        move.w  #blue+green,palette          ; breakpoint1


*       Determine memory configuration and size
*       for sparrow, no need to config, just size
 
        move.w  #$01,palette+2          ; breakpoint1

* TEST SIZE...
* possible: 512K (unlikely), 1MB, 4MB, 16(14)MB..
* Writes to just above legal space, checks if it's still there if so, try
* next size up.

        move.l  #sp512kloc,a0           ; check 512K boundary
        move.l  #mpat0,(a0)
        move.l  #mpat1,sp512kloc-4
        cmpi.l  #mpat0,(a0)
        bne     .sized
        move.l  #sp1MBloc,a0            ; check 1MB
        move.l  #mpat0,(a0)
        move.l  #mpat1,sp1MBloc-4
        cmpi.l  #mpat0,(a0)
        bne     .sized
        move.l  #sp4MBloc,a0            ; check 4MB
        move.l  #mpat0,(a0)
        move.l  #mpat1,sp4MBloc-4
        cmpi.l  #mpat0,(a0)
        bne     .sized
        move.l  #sp14MBloc,a0           ; if not, 16MB
.sized: 
        move.l  a0,d5                   ;save size 
        move.w  #$02,palette+4          ; breakpoint2

* Quick check all address bits are there and not shorted
        
.AddrTest:
        cmp.l   #sp14MBloc,a0           ; we need a0 later
        bne     .bypass
        
        move.l  #$8,a1
.floop:
        move.l  a1,(a1)
        adda.l  a1,a1                   ;same as lsl.l #1
        bne     .floop    

        move.l  #$8,a1
.cloop:
        cmpa.l  (a1),a1
        bne     .err
        adda.l  a1,a1                   ;same as lsl.l #1
        bne     .cloop                  ; ne = not all shifted out...
.bypass:
        bra     tstdat

.err:
        move.w  #red,palette            ; red the screen..
        move.w  #$ffff,d0
.lp:    nop
        dbra    d0,.lp
        move.w  #$ffff,palette
.lp2:   nop
        dbra    d0,.lp2
        bra     .err            

*********************************
*       Test system RAM         *
*       If error, branch to FATAL routine with d0=data written,
*       d1=data read, a0=location

*       ========
*       Test high and low
tstdat: moveq   #0,d6
tstd6:  move.w  d6,d0           ;d6=data for repeat
        movea.l #8,a0
tstd0:  move.w  d0,(a0)
        nop
        move.w  (a0),d1
        cmp.w   d0,d1
        bne     fatal0
        tst     d0
        beq.s   tstdl
        moveq   #$ff,d0
        bra.s   tstd0

*       ========
*       Test ram data lines
tstdl:  moveq   #1,d0
        movea.l #8,a0           ;test location 8
datlin1:
        move.w  d0,(a0)         ;shift 1 across a word
        nop
        move.w  (a0),d1         ;read and save
        cmp.w   d0,d1           ;verify 
        bne     fatal0
        lsl.w   #1,d0
        cmpi.w  #0,d0           ;until shift off end of word
        bne.s   datlin1
        move.w  #$fffe,d0
datlin0:
        move.w  d0,(a0)         ;rotate 0 across a word
        nop
        move.w  (a0),d1
        cmp.w   d0,d1
        bne     fatal0
        rol.w   #1,d0
        cmpi.w  #$fffe,d0       ;until rotate back to beginning
        bne.s   datlin0
                
*       ========
*       Test disturbance for lowest 2k bytes of ram
        movea.l #$40000,a3      ;top=256k 
        
*  fill with 0
        movea.l #LOWRAM,a0      ;bottom
        movea.l a0,a7
        movea.l #SAFRAM,a1      ;top
fill0:  move.l  #0,(a0)+        ;fill
        cmpa.l  a0,a1
        bgt.s   fill0

*  fill rest of memory with 1s
fill1:  move.l  #$ffffffff,(a1)+  ;fill with 1's        
        cmpa.l  a1,a3           ;until at top
        bgt.s   fill1

*  verify writes to upper mem not affecting low mem
        movea.l a7,a0           ;bottom
        movea.l #SAFRAM,a1      ;top
        moveq   #0,d0           ;for error display
fill2:  move.w  (a0),d1
        bne     fatal1
        adda.l  #2,a0
        cmpa.l  a0,a1
        bgt.s   fill2           ;until a0=a1

*       ========
*       Test first 2k bytes of memory
*       data=lsb of address
        movea.l a7,a0           ;bottom
wrtlow: move.w  a0,(a0)+        ;fill with low byte of address
        cmpa.l  a0,a1
        bgt.s   wrtlow

        movea.l a7,a0           ;bottom
verlow: move.w  (a0),d1         ;read
        move.w  a0,d0
        cmp.w   d0,d1
        bne     fatal2
        adda.l  #2,a0           ;would like to do postinc, but it alters Z
        cmpa.l  a0,a1
        bgt.s   verlow

*       data=complement of lsb of address
        movea.l a7,a0           ;bottom
wrtcmp: move.w  a0,d0
        eori.w  #$ffff,d0
        move.w  d0,(a0)+        ;fill with complement of address
        cmpa.l  a0,a1
        bgt.s   wrtcmp

        movea.l a7,a0           ;bottom
vercmp: move.w  (a0),d1         ;read
        eori.w  #$ffff,d1
        move.w  a0,d0
        cmp.w   d0,d1           ;verify data
        bne     fatal2
        adda.l  #2,a0           ;cannot do postinc, cause it alters Z
        cmpa.l  a0,a1
        bgt.s   vercmp

        movea.l #8,a0
        clr.l   d0
clrlow: move.l  d0,(a0)+        ;clear low memory
        cmpa.l  #$1000,a0
        blt.s   clrlow

*---------------------------------
* Clear BSS + EXCEP SPACE
        move.l  #$8,a0
.clear:
        clr.l   (a0)+
        cmp.l   #EndVar,a0
        blt     .clear

*********************************
*       save top of ram & TOS return address

        move.l  d5,topram
        move.l  a6,TOSreturn
REstart:
        move.b  #$ff,ProdTestStat

*       lea.l   DoneRAMmsg,a5
*       lea.l   .ex,a0
*       bra     ptmsg
*.ex:

*********************************
*       Init. exceptions        *

*       Set 68000 internal exceptions
        movea.l #vectb1,a0
        movea.l #8,a1           ;point to start of vector ram
        moveq   #9,d0
vect1:  move.l  (a0)+,(a1)+     ;move 2-11 (now 2-15)
        dbra    d0,vect1
        
*       Set vectors for autovectored interrupts
        movea.l #96,a1
        movea.l #vectb2,a0
        moveq   #7,d0
vect2:  move.l  (a0)+,(a1)+     ;move 24-31
        dbra    d0,vect2

*       Set vectors for MFP interrupts
        movea.l #vectb3,a0
        movea.l #userint,a1
        moveq   #15,d0
vect3:  move.l  (a0)+,(a1)+     ;move 64-79
        dbra    d0,vect3

*       If low memory tests out, we have system stack at $200 (temp)
*       and error stack at $800, and variables between
        
        movea.l #initstack,a7   ;temporary, until I verify ram
        movea.l #$800,a6        ;error stack

        move.w  #red+blue,palette          ; breakpoint1

*****************************************
*       Test 1k of ram for the stack    *
*       Start at $20000 and test 1k blocks until good one found
        movea.l #$1fc00,a0      ;bottom
        movea.l #$20000,a1      ;top
tststack: 
        bsr     tstblk          ;test (a0)--(a1)
        move.w  a6,d0
        andi.w  #$3ff,d0        ;see if at top of error stack
        beq.s   setstack        ;br if ok
        suba.w  #$400,a0        ;if not, try 1k lower
        suba.w  #$400,a1
        cmpa.l  #$1f000,a0      ;4k from start
        blt     fatal4          ;if can't find good ram by now, quit
        bra.s   tststack        ;keep looking for good 1k

setstack:
        movea.l a1,a7           ;new, big stack, at $20000 or close

*       Prepare for interrupts
        bsr     initmfp         ;clear mfp interrupt registers

        move.w  #blue,palette         ; breakpoint1

*********************************
*       Display Initialization  *

* turn on VGA video if installed
        bclr    #FAKECOLOR,v_stat_R
        move.b  SPConfig,d0
        lsr.b   #6,d0
        cmp.b   #2,d0   ; VGA MONITOR
        bne     .contd
        bset    #FAKECOLOR,v_stat_R
        bsr     vVGAm3  ; turn on proper VGA video
.contd:
        move    #rs96,rsrate    ;set for 9600 bps (timer d data)
        bsr     setdsp          ;set up video and RS232 for display
        bsr     esc_init        ;init escape routines
        bsr     clearsc         ;clear screen memory

********TEMP*TESTING***********
; now send a blind zero out w/o waiting for tx & rx empty..
        move.b  #$00,scc_data+sccb_base

*----------
* SCC I/O CHECK
;;1.19  bset.b  #rsinp,consol
;;      lea.l   BadSCCMsg,a5
;;      bsr     dspmsg
;;      bclr.b  #rsinp,consol
;;      bsr     crlf
;;      bsr     clearsc
        
*********************************
*FPU check
fpuck:
*       bset.b  #1,SPControl    ; combel hack for quick F-LINES OFF!
        bset.b  #5,SPControl
*       bclr.b  #0,SPControl    ; 8MHz

        lea     fpumsg,a5       ;write message in case we crash here
        bsr     dspmsg
        move.l  sp,a6
        move.l  #nofpu,$2c      ;redirect fpu trap
        move.l  #nofpu2,$3c     ; redirect wrong exception for rev 1 combel
        move.l  #nofpu2,$34
        fnop                    ;trap line - f if no FPU
        bsr     pOKmsg
        move.b  #$01,FPUStat
        bra.s   psgint          ;continue here if fpu found
    
nofpu:  movea.l #fpu,a5         ;1111 op code FPU error
        move.l  a6,sp
        move.l  #excep11,$2c    ;restore default trap error
        move.l  #excep13,$34
        move.l  #excep15,$3c    ; restore exception $f vector
*       move.w  #red,palette    ; no fpu not an error.
        bsr     dspmsg
        move.b  #0,FPUStat
        bra     psgint

* IF REV 1 COMBEL AND NO FPU, WE GET EXCEPTION #f or #d. : RWS
nofpu2: 
        movea.l #fpurev1,a5         ;exception # $f taken instead
        move.l  a6,sp
        move.l  #excep11,$2c    ;restore default trap error
        move.l  #excep13,$34    ; was #12
        move.l  #excep15,$3c    ; restore exception $f vector
*        move.w  #red,palette   ; no fpu not an error
        move.b  #0,FPUStat
        bsr     dspmsg

*********************************
*       PSG initialization
*       Set up printer port to make test fixture outputs hi imped.
*       and shut off sound

psgint: 
        lea.l   initpsgmsg,a5
        bsr     dspmsg
        lea     psgsel,a0
        lea     psgwr,a1
        bsr     sndoff

        move.b  #7,(a0)         ;I/O
        move.b  #$c0,(a1)       ;A out, B out
        move.b  #$f,(a0)        ;port B
        move.b  #$c0,(a1)
        move.b  #$e,(a0)        ;port A
        move.b  #$66,(a1)       ;strobe, GPO high, deselect floppies

*- Enable PSG to codec : 13JUL92 : RWS
**RWS.TPE        move.b  #$01,SPControl  ; RWS.T turn off berrs
; set ioa6 lo.
        move.b  #$0e,psgsel     ;1.19
        move.b  psgrd,d0
        bclr    #6,d0
        move.b  d0,psgwr

        bset.b  #5,SPControl
        move.w  #$0003,DACRECCTRL       ; enable PSG sound
        
***~
; RWS/X move    #%011101000,d0  ;master volume = max
;       bsr     voltone
;       move    #lfvol+db0,d0   ;left volume = max 
;       bsr     voltone
;       move    #rtvol+db0,d0   ;right volume = max
;       bsr     voltone
;       move    #treble+flat,d0 ;treble = flat
;       bsr     voltone
;       move    #bass+flat,d0   ;bass = flat
;       bsr     voltone
;       move    #$1,d0          ;mix = dma + psg
;       bsr     voltone

;;        moveq   #0,d2           ;d2=0,1,2=>A,B,C
  ;;      moveq   #freqhi,d7      ;starting freq.
    ;;    moveq   #freqlo,d6

;;        bsr     nxtsound1        ;start sound
        bsr     pOKmsg
********************************
*       Do initial tests
;        lea     bercvr,a5       ;write message in case we crash here
;        bsr     dspmsg
;       bset.b  #5,SPControl    ;turn on bus errors 
;        move.l  #be_ret,a6      ;save the return pointer
;        move.l  #obe_tst,8      ;install bus error vector
;        clr.l   d7
;        move    d0,0            ;cause bus error by writing to ROM

;be_ret: nop
;        tst     d7
;        bne.s   be_don          ;branch if bus error worked, else..
;        lea     betstm,a5       ;bus error did not occur, display error
;        bsr     dspmsg
;        move    #red,palette
;       bra.s   be_don1
;be_don:
;       bsr     dspspc  
;       bsr     pOKmsg
;be_don1:
;       bclr.b  #5,SPControl    ;turn bus errors back off???
;       bsr     crlf
;       move    #$2400,sr
;*        move.b  #$14,sim      ;enable int mask vblank,hblank
;*        move.b  #$40,svmeim     ;enable int mask mfp
;        move.b  #2,consol       ;enable RS232 terminal display
;        clr.b   initflg         ;no pass msg
;       bra     SKIP
* OLD STe TEST BELOW *************************
        lea     bercvr,a5       ;write message in case we crash here
        bsr     dspmsg
        move.l  8,a4
        move.l  #sbe_tst,8       ;install bus error vector
        move.l  #be_ret,a6
        bset.b  #5,SPControl    ; does crash system
        clr     d7
        move    d0,0            ;cause bus error by writing to ROM
be_ret:
        nop
        move.l  a4,8            ;restore vector
        tst     d7              ;test the bus error flag
        bne     be_don
        lea     betstm,a5       ;if bus error did not occur, display error
        bsr     dspmsg
        move    #red,palette
be_don:
        move.b  SPControl,d0
        or      #5,d0           
        move.b  d0,SPControl    ;power up to 16Mhz CPU and Blitter clocks, TLE

*- empty ACIA's here. RWS.TPES
        move.b  #protocol+rsetacia+introff,keyboard     ; no ints, master reset, etc
        move.b  #protocol+rsetacia+introff,midi         ; no ints, master reset, etc

        move    #$2400,sr       ;???

        move.b  #2,consol       ;enable RS232 terminal display
        clr.b   initflg         ;no pass msg
*********************** END OF OLD STE *******
SKIP:
        lea.l   IDEMsg,a5
        bsr     dspmsg
        bsr     reset_ide

        bsr     timtst          ;test MFP timers and glue timing
        tst.b   erflg0
        bne     endinit 
        bsr     dspspc          ; RWS.T
        bsr     pOKmsg
endinit:
        move.b  #$ea,initflg    ;flag init. complete

wtmsgx: move    #100,d1         ;very brief delay so all msg readable
wtmsg0x:                         ;dunno how fast anymore.. 68030 issues. 
        bsr     wait
        dbra    d1,wtmsg0x

*       check system clock: Genlock?
        tst.b   erflg0          ;check timer error flag
        bne.s   keyint          ;don't get stuck here if failure
        bsr     clearsc
*        move.b  #1,tadr+mfp
*        move    #13,d0
*        move.l  #timerav,a2
*        bsr     initint         ;enable timer A int
*
*        move.b  #6,tacr+mfp     ;start timer, /100 = 40.6 us
*        move.b  #1,timflg
*wtgen0: tst.b   timflg          ;wait for int to synchronize to timer
*        bne.s   wtgen0
*        move.b  #1,timflg
*        move    #6,d7   
*wtgen:  dbra    d7,wtgen        ;timer will elapse if 16 MHz ext clk
*        move.b  #0,tacr+mfp
*        tst.b   timflg          ;if timer has not expired,
*        bne.s   keyint          ;then internal 32M clk

*       slow clock = no screen; output sound to show we're alive
*       move    #%011101000,d0  ;master volume = max
*       bsr     voltone
*       move    #lfvol+db0,d0   ;left volume = max 
*        bsr     voltone
*        move    #rtvol+db0,d0   ;right volume = max
*        bsr     voltone
*        move    #$1,d0          ;mix = dma + psg
*        bsr     voltone
*        moveq   #0,d2           ;channel A
*genlck: bsr     sweep
*        bra.s   genlck          ;loop forever
                
*********************************
*       Initialize keyboard
keyint: 
* RWS : NEEDED ? : bsr     disint          ;Bug-RAM R4 failure after floppy test run

*RWS.T        moveq   #15,d0          ;enable mono monitor int
*        bsr     enabint
        lea     initkbmsg,a5
        bsr     dspmsg
        bsr     initkey         

*********************************
*       check configuration

*       if color palette is 4 bits, its probably STE
        clr.b   mega
        movea.l #palette,a0
        move    #$fff,(a0)
        cmpi    #$fff,(a0)
        bne.s   cnfst
        move.b  #$80,mega

cnfst:  bra     screen0 

*8<-----------------------------------
.if init2 = 0
;-- axed out into init2.s
.endif
        .data

**************
*            *
*  messages  *
*            *
**************

*               '1234567890123456789012345678901234567890'

datlin: dc.b    cr,lf,'I1 RAM/data line error ',eot
unique: dc.b    cr,lf,'I2 RAM disturbance   ',eot
addchk: dc.b    cr,lf,'I3 RAM address check ',eot
*       stack error is now handled as normal RAM error (ramtst)
mmufal: dc.b    cr,lf,'I4 Memory configuration error',cr,lf,eot
*               should be preceded by bus error
ramszer: dc.b   cr,lf,'I5 Ram sizing error',cr,lf,eot
*               not seeing second bank or top location is bad

BadSCCMsg:
        dc.b    cr,lf,'SCC Stuck',eot

fpumsg: dc.b    cr,lf,'Checking FPU...',eot
fpu:    dc.b    cr,lf,'EF FPU not found',eot   
fpurev1: dc.b    cr,lf,'EF FPU not found (Rev. 1 COMBEL installed)',eot   

bercvr: dc.b    cr,lf,'I6 Checking exception handling...',eot
betstm: dc.b    cr,lf,'I7 Bus error not detected',cr,lf,eot
tpointm: dc.b   cr,lf,'TP TEST POINT REACHED',cr,lf,eot

okmsg: dc.b     'Ok',eot
initpsgmsg:     dc.b    cr,lf,'Initializing PSG...',eot

initkbmsg:      dc.b    cr,lf,'Initializing Keyboard',eot

DoneRAMmsg:     dc.b    cr,lf,'Done with RAM tests',cr,lf,eot                      
                  
IDEMsg:         dc.b    cr,lf,'Resetting IDE',cr,lf,eot

        .include burnck
