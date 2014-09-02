        .include hardware
	.include defs
	.include macros
	.include nvram

	.globl msgsave,reset1770,floptst
*------------------------------------------------------------------------
*                                                                       :
*       Floppy Drive/Controller test                                    :
*                                                                       :
*------------------------------------------------------------------------
* SP V1.00 : RWS : Patched into sparrow test
* SP V1.10 : 23JAN92 : RWS : REMOVED driveb accesses
* SP V1.11 : 23JAN92 : RWS : commented out _flopver (not used)
*------------------------------------------------------------------------
*       JAN  4, 90: MOD floplock routine for selectable step rate
*                   high density floppy is 3 msec, default is 1.5 msec
*                   (****~ tf ****~)
*       Nov 10, 89:  floppy A may be high density.
*               affects routines chkflp, floplock, fsidsel, tstsid, tstrnd
*               Erase track before formatting.
*       Sept 26, 88 fix drive install routine
*       AUG 16/88   fix following bugs:
*                   1-- light not goes off on test 1 and 2.
*                   2-- fail to see external drive as double sided
*       Mar 3, 88   fix bugs reported from the field
*                   Bugs: 1: floppy test menu never return if disk not
*                   in drive initially.  2: If test fail the first time,
*                   drive A would never be tested the next time.  Instead,
*                   drive B was tested eventhough it was not there, and
*                   the menu never be returned.
*       Dec 2, 87   Release 4.0
*       Nov 10, 87  added time-out for motor off.
*       Oct 12, 87  Rev. 4.0    Speed test, blinking arrow.
*       May 15, 87  arrow keys inc/dec track in alignment test,
*               check track number input for in range,
*               also assure vblank vector gets restored after alignment.
*       April 8, 87  alignment prog selects either head
*       Nov 14, 86
*       Submenu:        
*       1. Standard controller test: for whatever is installed:
*          A. Init (restore) drive A
*               Checks 1770 can seek track 0            
*          B. Format,write tracks 0,1,79
*          C. Read tracks 0,1,79
*          D. If double-sided, format and write side 1; read side 0
*          E. Seek random track, format, write, and read it.
*       2. Read track (alignment).
*       3. Compatibilty check.
*          A. Write both disks.
*          B. Swap disks.
*          C. Read both disks.
*       4. Exercise disk drive.
*       5. Test tracks 80-82.
*       6. Test speed.
*       7. Install disks. Prompt for A, B capacity      

*------ Equates

*------ Tunable values (subject to tweaking):
seekrate        equ     3               ; default 1.5 msec step rate                                       ; was ( equ 3 )
retries         equ     2               ; default # of retries - 1
midretry        equ     1               ; "middle" retry (when to reseek)
; timeout         equ     $40000          ; short timeout (motor already on)
;ltimeout         equ     $60000          ; short timeout (motor already on)
timeout         equ     $60000          ; long timeout (to startup motor)
ltimeout        equ     $f0000          ; long timeout (to startup motor)
fmtdat          equ     $e5e5           ; write data during format
hispd           equ     $205            ; time to rotate (bcd ms) must be less
lospd           equ     $195            ; time to rotate (bcd ms) must be more

*------ Error returns
e_error         equ     -1              ; general catchall
e_nready        equ     -2              ; drive-not-ready
e_crc           equ     -4              ; CRC error
e_seek          equ     -6              ; seek error
e_rnf           equ     -8              ; record (sector) not found
e_write         equ     -10             ; generic write error
e_read          equ     -11             ; generic read error
e_wp            equ     -13             ; write on write-protected media
e_ld            equ     -15             ; lost data
e_badsects      equ     -16             ; bad sectors on format-track
e_dmasta        equ     -17             ; dma error status
e_dmacnt        equ     -18             ; dma count error

 
*--- 1770 select values:
cmdreg          equ     $80             ; select command register
trkreg          equ     $82             ; select track register
secreg          equ     $84             ; select sector register
datareg         equ     $86             ; select data register

*--- GI ("psg") sound chip:
;giporta         equ     $e              ; GI register# for I/O port A

*--- 16 meg clock set (st dma chip)
fdccs           equ     $ffff860e       ; set bit 0 = 1  for 16 meg hz
*****************************************
*       driva, drivb:   bit 0 set if side 0 writable, bit 1 set if side 1,
*                       bit 7 set if drive there but not writable.

	.text
	.even
floptst:
;     lea.l     TFlopMsg,a5
 ;    bsr  dspmsg
	clr.b   sidtst          ;clear side test flag
*       Start timer A - random number generator for track selection
	move.b  #$3f,tadr+mfp   ;timer data
	move.b  #$1,tacr+mfp    ;timer A /4 - must be fast for randomity
	move    #fmtdat,fdat
	move    #1,fint
	move    #0,fsid
	move    #0,ftrk
	move    #1,fsct
	move    #9,fcnt
	move    #0,fdev
	clr.b   erflg0
	clr.b   erflg1
	tst.b   autotst
	bne   flpauto
;       tst.b   ProdTestStat
;       bmi     .skip
;       RTCISTESTED #t_FLOP
;       beq     .skip
;       bpl     menuret
;.skip:
*       Operator interactive
	move    #bgrnd,palette
	bsr     clearsc
*--
	tst.b   ProdTestStat
	bpl     flptst3
*--
	lea     flpmen,a5
	bsr     dspmsg
	bsr     conin
	cmpi.b  #'0',d0
*       bls     menu
	bls     menuret
	cmpi.b  #'7',d0
*       bhi     menu
	bhi     menuret
	andi.l  #$f,d0
	subq    #1,d0           ;0-5
	lsl     #2,d0
	lea     flptbl,a5
	bsr     clearsc
	move.l  0(a5,d0),a0
	jmp     (a0)

flptbl: dc.l    flptst1         ;standard controller test
	dc.l    flptst2         ;read track for alignment
	dc.l    flptst3         ;disk interchange
	dc.l    flptst4         ;exercise
	dc.l    flptst5         ;track 80-82
	dc.l    flptst6         ;speed
	dc.l    flptst7         ;install

menuret: 
	move.l  #vblank,$70     ;3/7/88
	move.b  #6,d0           
	bsr     setporta
	bra     menu

********************************
*       Auto test (multiple cycles)
flpauto:
	cmp.l   #1,cycle.w
	bne.s   fauto1
	bsr     chkflp          ;first pass, see what is there
fauto1: move.b  driva,d0        ;       drive A status
* RWS       or.b    drivb,d0        ;       drive B
	bne.s   flop10
	rts                     ;nothing doing

********************************************
*       Test 1: test controller electronics
*       This is a single cycle
flptst1:
	bsr     clearsc
	bsr     crlf
	bsr     crlf
	move.b  driva,d0        ;check status to see if anything to test
* RWS        or.b    drivb,d0        
	bne.s   flop10
	bsr     chkflp          ;no drives installed, see what is there
	move.b  driva,d0        ;now check status again
* RWS        or.b    drivb,d0
	bne.s   flop10          
	rts                     ;nothing doing
	
*       Drives installed, Begin test 1

*       Display drives at top of screen
flop10: move    #2,scrtop
	bsr     escjs           ;save cursor
	bsr     escfn8          ;home
	tst.b   driva
	beq.s   flp1b

	lea     drvam,a5        ;Drive A
	bsr     dspmsg
	lea     hidenm,a5       ;high density
	btst    #6,driva
	bne.s   flp1a
	lea     snglsid,a5      ;single sided
	btst    #1,driva
	beq.s   flp1a
	lea     dblsid,a5       ;double sided
flp1a:  bsr     dspmsg

flp1b:
	bra.s   flp1e   ; RWS
* RWS     tst.b   drivb
*        beq.s   flp1e
*        moveq   #0,d0
*        moveq   #1,d1
*        bsr     move_cursor
*        lea     drvbm,a5        ;Drive B
*        bsr     dspmsg
*        lea     snglsid,a5      
*        btst    #1,drivb
*        beq.s   flp1c
*        lea     dblsid,a5
flp1c:  bsr     dspmsg
flp1e:  bsr     escks           ;restore cursor
	        
*-------------------------------
*       Do Format, Write, Read test for whatever drives are installed
	tst.b   erflg0          ;error in chkflp?
	bne.s   fail1a          ;yes, just print fail
	cmpi.b  #0,driva
	beq.s   flop_b

*       Test drive A
	move.w  #0,fdev
	bsr     tstdrv          ;test drive A
	tst.b   erflg0
	bne.s   fail1a
	bsr     tstrnd          ;test random track

*       Display pass/fail for drive A
	lea     pasmsg,a5
	tst.b   erflg0          ;error?
	beq.s   dsp1a
fail1a: lea     failm,a5
	move    #red,palette    
dsp1a:
	moveq   #50,d0
	moveq   #0,d1
	bsr     dsppos

	tst.b   erflg1          ;error in chkflp?
	bne.s   fail1b          ;yes, print fail
flop_b: 
	bra.s   flopend         ; RWS
* RWS   cmpi.b  #0,drivb        ;B installed?
*        beq.s   flopend
*
*       Test drive B
*        move.w  #1,fdev
*        bsr     tstdrv          ;test drive B
*        tst.b   erflg1
*        bne.s   fail1b
*        bsr     tstrnd          ;test random track

*       Display pass/fail for drive B
*        lea     pasmsg,a5
*        tst.b   erflg1          ;error?
*        beq.s   dsp1b
fail1b: lea     failm,a5
	move    #red,palette
dsp1b:  moveq   #50,d0
	moveq   #1,d1
	bsr     dsppos
	
*       If fail, print Fail Cycle: xxxx to permanent screen
flopend:
	move.b  erflg0,d0
	or.b    erflg1,d0
	bne.s   .error
	RTCSETPASS #t_FLOP,d0
; check for automode
	tst.b   autotst
	beq     .skip
	cmpi.b	#t_POSTBURN,ProdTestStat	; and post burn
	beq	.set
	cmpi.b	#t_UNITASSY,ProdTestStat	; and unit assy
	bne	.skip
.set:	
; if so, set the needed bit back on for op test.
	RTCSETNEED #t_FLOP,d0	;RWS. 1.18f
.skip:
	bra.s   flpend1c
.error:
	lea     falmsg,a5
	move.b  #t_FLOP,d0
	bsr     dsppf           

*       Wait for motor off, deselect, and return
*flpend1:
*        bsr     reset1770       ;clobber controller to shutoff motor
*       move.l  #$efff,d7       ;time-out in case no disk in drive
*flpend1a:                      ;else we wait forever
*       sub.l   #1,d7
*       bne     flpend1b
*       clr.b   desel
*       move    #$2200,sr       ;change to 2200 from 2400 3/7/88
*flpend1b:
*       tst.b   desel           ;wait for motor off before deselect
*       bne.s   flpend1a        ;must wait, next test might shut off vblank

flpend1c:       
*        move.l  #vblank,$70      ;3/7/88
;;	tst.b	ProdTestStat	;RWS 1.18e
;;	bpl	retmenu		;RWS 1.18e
	move.b  consol,d0
	andi.b  #$38,d0
	bne.s   retmenu         ;return to calling sequence if auto mode
     
	bsr     chkred          ;check for fail if manual test
	beq.s   flpend2          
	move    #green,palette    
flpend2:
	bsr     conin           
	bra     floptst         ;return to floppy menu if manual mode

retmenu:
	move.l  #vblank,$70      ;restore vblank routine
	move.b  #6,d0            ;3/7/88
	bsr     setporta         ;3/7/88
	rts

*********************************
*       Floppy test 2
*       Input track number and read continuously
flptst2:
	lea     algntrk,a5
	bsr     dspmsg          ;display test name and prompt for A or B
	move    #0,fdev
	move    #0,fsid
	move    #40,ftrk        ;track 40 
	move    #1,fsct
get_drv:
*        bsr     conin
*        cmp.b   #'A',d0
*        beq.s   gettrk
*        bra.s   get_drv
*        cmp.b   #'B',d0
*        bne.s   get_drv
*        move    #1,fdev
gettrk: lea     gettrkm,a5
	bsr     dspmsg
	bsr     getbuf          ;get track no.
	tst     d0
	beq     gtdr3           ;br empty
	bsr     crlf
	lea     numbuf,a3
gtdr2:  move.b  -(a4),d0        ;get all keystrokes from keybuf
	move.b  d0,(a3)+        ;save reverse order in numbuf
	cmp.l   #keybuf,a4      
	bne.s   gtdr2
	lea     numbuf,a0       
	bsr     ascdec          ;convert to hex a0->a3
	cmp     #79,d2
	bhi     gettrk          ;get another value
	move.w  d2,ftrk         

gtdr3:  bsr     clearsc
	move.w  #1,fint
	move.w  #0,fsid
	bsr     _flopini                
	beq     gtdr4           ;3/7/88
	lea     notrdy,a5       ;3/7/88 
	bsr     dspmsg          ;3/7/88
	bsr     dspinfo         ;3/7/88
	bsr     crlf            ;3/7/88
	bra     exit            ;3/7/88
*       display, read, check key, repeat
gtdr4:  lea     rdmsg,a5
	bsr     dspop           ;display what we're doing
	bsr     rdtrack         ;read track
	bsr     constat         ;any key?
	beq.s   gtdr4

*       got a key. see what action required
	bsr     conin
	cmpi.b  #uparky,d1      ;up arrow=head 1
	beq.s   head1
	cmpi.b  #dnarky,d1      ;down arrow=head 0
	beq.s   head0
	cmpi.b  #rtarky,d1      ;right arrow=inc track
	beq     inctrk
	cmpi.b  #lfarky,d1      ;left arrow=dec track
	beq     dectrk
	cmpi.b  #esc,d0         ;esc = quit
	beq     flp2ret
	cmpi.b  #' ',d0         ;space=pause
	bne     gtdr4
exit:   lea     pausem,a5
	bsr     dspmsg
	bsr     conin           ;wait for next key
	cmpi.b  #esc,d0         ;esc=quit, else continue
	beq     flp2ret
	bsr     clearsc
	bra     gtdr4

*       kludge to make sure vblank vector is restored
flp2ret:
*        move.l #vblank,$70     ;restore the vector we replaced
	bra     floptst

head0:  move    #0,fsid
	bra     gtdr4
head1:  move    #1,fsid
	bra     gtdr4
inctrk: cmpi    #79,ftrk
	beq     inc0
	add     #1,ftrk
	bra     gtdr4
inc0:   move    #0,ftrk
	bra     gtdr4
dectrk: cmp     #0,ftrk
	beq     dec0
	sub     #1,ftrk
	bra     gtdr4
dec0:   move    #79,d0
	bra     gtdr4

********************************
*       Disk change test
*       Insert and remove disk 

flptst3:
	move    #bgrnd,palette
;       RTCISTESTED #t_FLOP
;       bmi     .prevpas        ; skip on prev. fail or 
;       move    #red,palette
;.prevpas:
	lea     intchgm,a5
	bsr     dspmsg
	clr     fsid
	clr     ftrk
	bsr     _flopini
	bsr     conin

**************************************
*-in and out disk
swap:   
	bsr     clearsc
	clr.b   desel

	lea     dsb0,a1
	bsr     select

	lea     swapm,a5
	bsr     dspmsg
	bsr     conin

	bsr     clearsc
	move    fdccs,d0        ;get change disk status
	btst    #7,d0
	bne     not_detect      ;branch if disk change not detected

;        move    #green,palette  ;got disk swap
	move.l  #rptesc,msgsave       
	bra.s   intrpt
*
not_detect:
	move    #red,palette
	move.l  #notswap,msgsave      ;disk was not swapped
	RTCSETFAIL #t_FLOP
intrpt:
	lea     dsb0,a1
	bsr     restore
	move    #$1,ctrack
	bsr     go2track
 .1:
	move    fdccs,d0
	btst    #7,d0
	beq.s   .1

*       Format and write tracks
	move    #0,ftrk
	bsr     _flopini        ;init (restore)
	move    #80,ftrk

;       format track 80
	bsr     fmt_trk         ;format a track
	tst     d0
	beq     wpfal           ;must fail (write protected)

	bsr     clearsc
	move.l  msgsave,a5
	bsr     dspmsg
	lea     ok_tect,a5
	bsr     dspmsg
     cmp  #red,palette
     beq  wpok

	move    #green,palette
	RTCSETPASS #t_FLOP,d0

wpok:   bsr     conin
	tst.b   ProdTestStat    ; leave if in prod mode
	bpl     menuret
;        cmpi.b  #esc,d0
;        beq     floptst

	move    #bgrnd,palette
;        bra     swap
	 bra    floptst

wpfal:  bsr     clearsc
	move.l  msgsave,a5
	bsr     dspmsg

	lea     not_tect,a5
	bsr     dspmsg
	move    #red,palette
     RTCSETFAIL #t_FLOP
	bra     wpok

***************************************
*       Floppy exerciser
*       1. Format disk sequentially
*       2. Write disk sequentially
*       3. Read tracks pseudo-randomly
*       4. Repeat 2,3

flptst4:
	bsr     clearsc
	lea     flpexm,a5
	bsr     dspmsg
* RWS   lea     A_or_B,a5
*        bsr     dspmsg
*        bsr     crlf
*        bsr     crlf
	move.w  #0,fdev
*        bsr     conin           ;A or B starts test, else quit
*        cmp.b   #'A',d0
*        bne.s   flp41
	move.b  driva,d0        ;installed?
	tst.b   d0
	bne.s   flp43           ;yes
	bra.s   flp42           ;no, check
flp41: 
	bra     floptst         ; RWS 23JAN92
* RWS   cmp.b   #'B',d0
*        bne     floptst
*        move    #1,fdev
*        move.b  drivb,d0
*        tst.b   d0              ;installed?
*        bne.s   flp43           ;yes
flp42:  bsr     chkside         ;test for # of sides
flp43:  move.b  d0,cur_drv      ;establish # sides for drive to test
	
f4init: move.l  #1,cycle.w
	bsr     clearsc
	lea     flpexm,a5
	bsr     dspmsg
	bsr     crlf
	move    #2,scrtop

********************************
*       Init drive and Format tracks
	move    #0,fsid
	move    #0,ftrk
	move    #1,fsct
	move    #9,fcnt
	clr     wrt_err
	clr     rd_err
	bsr     _flopini
	tst     d0
	beq.s   rdyfmt
	tst     fdev
	beq.s   f4ini1
	bsr     offlinb
	bra.s   f4ini2
f4ini1: bsr     offlina
f4ini2: bsr     conin     
	bra     flptst4

rdyfmt: lea     badtrack,a2
	moveq   #79,d0
rdyf1:  clr.b   (a2)+           ;clear bad track table
	dbra    d0,rdyf1

fmt40:  clr     fmt_err         ;clear errors this side

*       Format 80 tracks
fmt4:   bsr     fmt_trk
	tst     d0
	beq.s   fmt41

	cmpi    #5,fmt_err      ;5 errors/side
	blt     fmt41
	bsr     pause           ;stop at excess errors
	beq.s   fmt43           ;continue
	bra     floptst         ;or quit   
	        
fmt41:  bsr     chkesc          ;check for esc, get next key if got esc
	bne     floptst         ;quit   
*                               ;continue if no esc or esc and return
fmt43:  add     #1,ftrk
	cmp     #80,ftrk
	bne.s   fmt4

	tst     fsid            ;need to format side 1?
	bne.s   exloop          ;already done
	btst    #1,cur_drv
	beq.s   exloop          ;br not selected
	move    #1,fsid
	move    #0,ftrk
	bra.s   fmt40

********************************
*       Start new pass
exloop: move.b  tadr+mfp,rndbyt ;get random number from timer 
	move    #0,fsid
	bsr     dspcycl
	clr     wrt_err
	clr     rd_err

*       Write all tracks
write4: move    #0,ftrk
	move.l  #wbuf,fbuf.w
wrt4:   bsr     wrt_trk
	tst     d0
	beq.s   wrt41

	cmp     #20,wrt_err
	blt     wrt41
	bsr     pause           ;stop if excess errors
	beq.s   wrt43
	bra     floptst
*       Check for esc
wrt41:  bsr     chkesc
	bne     floptst
*       Continue
wrt43:  add     #1,ftrk
	cmp     #80,ftrk
	bne.s   wrt4

	tst     fsid            ;need to write side 1?
	bne.s   read4           ;already done
	btst    #1,cur_drv
	beq.s   read4           ;br not selected
	move    #1,fsid
	bra.s   write4          ;repeat for side 1

********************************
*       Read tracks 
read4:  move    #0,fsid
rdt41:  move.b  #0,tempb        ;start track sequence for this side

*       get sequence of tracks from table
rdt4:   lea     trkseq,a2
	clr.l   d2
	move.b  tempb,d2
	move.b  0(a2,d2),ftrk+1 ;next track

	bsr     rd_trk  
	beq.s   rdt1

	cmp     #20,rd_err
	blt     rdt41
	bsr     pause           ;stop if excess errors
	beq.s   rdt41
	bra     floptst    
rdt1:   bsr     cmpdata
	bsr     chkesc
	bne     floptst
	add.b   #1,tempb        ;next track
	cmp.b   #80,tempb
	bne.s   rdt4

	tst     fsid            ;need to read side 1?
	bne     exloop          ;already done
	btst    #1,cur_drv
	beq     exloop          ;br not selected (next pass)
	move    #1,fsid
	bra.s   rdt41           ;repeat for side 1

*********************************
*       Test copy protect tracks (80-83)
flptst5:
*        lea     A_or_B,a5
*        bsr     dspmsg
*        bsr     conin           ;A or B starts test, else quit
*        cmp.b   #'A',d0
*        beq.s   fmt5
*        cmp.b   #'B',d0
*        bne     floptst
*        move    #1,fdev
	
*       Format and write tracks
fmt5:   bsr     clearsc
	lea     cpymsg,a5
	bsr     dspmsg
	move    #0,ftrk
	bsr     _flopini        ;init (restore)
	move    #80,ftrk

;       format 3 tracks
fmt51:  bsr     fmt_trk         ;format a track
	tst     d0
	bne.s   cpyfal          ;must be perfect
	bsr     wrt_trk         ;write the track
	tst     d0
	bne.s   cpyfal
	add     #1,ftrk
	cmp     #83,ftrk
	bne.s   fmt51           ;until 4 tracks done

*       Read tracks
	move    #80,ftrk
fmt52:  bsr     rd_trk          ;read 9 sectors
	tst     d0
	bne.s   cpyfal
	add     #1,ftrk
	cmp     #83,ftrk
	bne.s   fmt52
	lea     cpypas,a5
	move    #green,palette        
cpyend: bsr     dspmsg
	bsr     conin      
	bra     floptst    
cpyfal: bsr     dspfail         ;display error
	lea     cpyfalm,a5
	move    #red,palette
	bra.s   cpyend

********************************
*       Test disk speed

flptst6:
	bsr     clearsc
	lea     spdmsg,a5
	bsr     dspmsg
* RWS   lea     A_or_B,a5
*        bsr     dspmsg
	clr     fdev
*        bsr     conin
*        cmpi.b  #'B',d0
*        bne     flp6a           ;A=default
*        move    #1,fdev
flp6a:  bsr     clearsc
	lea     spdrng,a5
	bsr     dspmsg
	move    #0,d0
	move    #3,d1           ;leave lines 1 and 2 for error msgs
	bsr     move_cursor
	lea     spdata,a5
	bsr     dspmsg

*       set up timer a: 2.4576MHz/200/8=1536Hz => 651us/cycle
	move.b  #0,tacr+mfp     ; stop timer
	move.b  #8,tadr+mfp     ; data = /8 = 651us/tick
	lea     ticka,a2
	moveq   #13,d0
	bsr     initint

	clr     fsid
	clr     ftrk
	bsr     _flopini
	clr.b   desel           ;do not deselect
	move    #0,spmax
	move    #$ffff,spmin

spdrpt: move    #0,d7           ; track #
	bsr     hseek2          ;start spinning
	moveq   #22,d0
	moveq   #4,d1
	bsr     move_cursor
	lea     lar,a5          ;left arrow
	bsr     dspmsg          ;this arrow will blink each measurement

	move.b  #7,tacr+mfp     ;start timer a (/200)
	bsr     wtindh          ;index goes high
	tst     d5
	beq     sptimo
	clr     a_timer         ;start timer 
	bsr     wtindl          ;index goes low
	tst     d5              ;8/16/88
	beq     sptimo          ;8/16/88
	bsr     wtindh          ;wait for next index

	move    a_timer,-(sp)   ;read time and save it
	bsr     wtindl          ;wait for end of index

	moveq   #22,d0
	moveq   #4,d1
	bsr     move_cursor
	bsr     dspspc          ;blank the arrow

	clr.b   tacr+mfp        ;keep timer from interrupting
	move    (sp)+,d0        ;get time
	bsr     cnvrt           ;convert to millisecs

;       see if within limits
	cmp     #hispd,d1
	bge     badspd
	cmp     #lospd,d1
	bgt     hilosp
badspd: move    #red,palette

*       save if new max or min
hilosp: cmp     spmax,d1
	bls     spcmp1
	move    d1,spmax
spcmp1: cmp     spmin,d1
	bhi     spdsp
	move    d1,spmin

*       display e.t.
spdsp:  move    d1,-(sp)
	moveq   #0,d0
	moveq   #4,d1
	bsr     move_cursor
	move    spmax,d1
	bsr     dspwrd          ;max
	bsr     dsptab
	move    spmin,d1
	bsr     dspwrd          ;min
	bsr     dsptab
	move    (sp)+,d1
	bsr     dspwrd          ;current
	bsr     crlf

	bsr     constat
	tst     d0
	beq     spdrpt          ;repeat until any key
	
endspd: bsr     conin   
	moveq   #13,d0
	bsr     disint
	bsr     _flopini        ;deselect
	bra     floptst         ;return to caller  
sptimo: lea     tomsg,a5
	bsr     dspmsg
	move    #red,palette
	bra     endspd

*-------------------------------
*       convert to milliseconds (ticks x .651 = ms)
*       entry:  d0.w = hex period (multiple of .651 ms)
*       exit:   d0.w=d1=decimal
cnvrt:  andi    #$ffff,d0
	move.l  #651,d2
	mulu    d2,d0
	move.l  #1000,d2
	divu    d2,d0
	bsr     rndoff
	bsr     cnvdec          ;convert to decimal
	rts

*       round up/down the result of a division
*       d0=remainder,quotient
*       d2=divisor
rndoff: swap    d0
	lsr     #1,d2           ;half the divisor
	cmp     d2,d0           ;if less than half, round down
	blt     rnd1
	swap    d0
	addi    #1,d0           ;round up
rnd2:   andi.l  #$ffff,d0
	rts
rnd1:   swap    d0
	bra.s   rnd2
	
*--------------------------
*       timer a interrupt
ticka:  add     #1,a_timer
	bclr    #5,isra+mfp
	rte
	
*--------------------------
*       wait for index high
*       exit:   if d5=0, timeout

wtindh: move.l  #100000,d5
wtidh0: move    #cmdreg,(a6)
	bsr     rdiskctl
	btst    #1,d0           ;wait for index to go high
	bne     wtidhx
	subq    #1,d5
	bne     wtidh0
wtidhx: rts

*       wait for index low
*       exit:   if d5=0, timeout
wtindl: move.l  #100000,d5
wtidl0: move    #cmdreg,(a6)
	bsr     rdiskctl
	btst    #1,d0
	beq     wtidlx          ;wait for index to go low 
	subq    #1,d5
	bne     wtidl0
wtidlx: rts


********************************
*       Prompt for single/double sided drive 
flptst7:
	bsr     clearsc
	lea     instlm,a5
	bsr     dspmsg
	lea     drvam,a5
	bsr     instlf          ;drive A
	move.b  d2,driva
*        lea     drvbm,a5
*        bsr     instlf          ;drive B
*        move.b  d2,drivb        
	bra     floptst

*****************************************
*                                       *
*       Floppy Subroutines              *
*                                       *
*****************************************

*-----------------------
*       check how many sides
*       Exit:   d0=0,1,2
chkside:
	bsr     _flopini
	bne.s   chksd1
	move.b  #1,sidtst       ;no display if error
	bsr     fsidsel
	clr.b   sidtst
	rts
chksd1: clr     d0
	rts

*-------------------------------
*       Check floppy configuration
*       Exit:   driva,drivb:    bit7 set if drive present, not usable
*                               bit0 set if side 0 writable
*                               bit1 set if side 1 writable
*       Sets erflg, displays message, and turns screen red 
*       if drive present but not writable.
chkflp: lea     chkflpm,a5
	bsr     dsptst
	clr.b   driva
	clr.b   drivb
	clr.w   fdev    
	bsr     _flopini        ;restore drive A
	tst     d0
	bne.s   chkfl1

	bset    #7,driva        ;its there
chkfl1:
*        move.w  #1,fdev
*        bsr     _flopini        ;restore drive B
*        tst     d0
*        bne.s   chkfl2
*
*        bset    #7,drivb        ;its there

chkfl2: tst.b   driva
	bne.s   chka
*        tst.b   drivb
*        bne.s   chkb

	lea     nodrivm,a5      ;no floppies
	RTCSETFAIL	#t_FLOP
	move	#red,palette
	bsr     dsptst
	move.l  #vblank,$70     ;restore vblank routine
	rts                     ;return to dispatcher for next test

*       Got drive A, try to write it
*       determine if high density
chka:   move.b  #1,sidtst       ;no error msg, just checking
	clr.w   fdev
	move    #3,fdccs        ;16 MHz clk (bit 1 used to force high
*                                density when using low density diskette)
	bset    #6,driva        ;for 18 sectors/trk
	bsr     ftsthi
	beq.s   chka0           ;if won at 16 MHz
	move    #0,fdccs        ;8 MHz clk
	bclr    #6,driva        ;9 sectors/trk
chka0:  bsr     fsidsel         ;test side select
	tst     d0
	beq.s   chka3
	cmp.b   #1,d0
	beq.s   chka1   

*       move.b  #3,driva        ;double sided
	ori.b   #3,driva        ;3/3/88
	bra.s   chkb

chka1:  
*       move.b  #1,driva        
	ori.b   #1,driva        ;3/3/88
	bra.s   chkb

*       Can't write disk A
chka3:  lea     wrtdska,a5
chka2:  bsr     dspmsg          ;write error
	move.b  #1,erflg0
	move    #red,palette
*       move.b  #$80,driva
	ori.b   #$80,driva      ;3/3/88

*       Check drive B
chkb:
	btst    #7,drivb
	beq.s   nflop
	nop                     ; filler
*        move.w  #1,fdev
*        bsr     fsidsel         ;test side select
*        tst     d0
*        beq.s   chkb1
*        cmp.b   #1,d0
*        beq.s   chkb2
*
*        move.b  #3,drivb        ;double sided
*        ori.b   #3,drivb        ;3/3/88
*        bra.s   nflop
chkb2:  
*        move.b  #1,drivb
*        ori.b   #1,drivb        ;3/3/88
*        bra.s   nflop

*chkb1:  lea     wrtdskb,a5      ;can't write it
*        bsr     dspmsg
*        move.b  #1,erflg1
*        move    #red,palette
*        move.b  #$80,drivb
*        ori.b   #$80,drivb      ;3/3/88

nflop:  clr.b   sidtst          ;enable print messages
	bsr     clr2lin         ;clean up messages
	rts


*-------------------------------
*       Get input for floppy type
*       Entry:  a5=drive message
*       Exit:   d2=status. 1=single sided, 3=double sided, $43=hiden 0=none.

instlf: bsr     dspmsg
	clr.b   d2
	bsr     conin           ;drive A = 1 or 2 sided 

	cmpi.b  #'1',d0
	bne.s   instlb
	move.b  #1,d2           ;single sided
	move    d0,d1
	bsr     ascii_out
	bra.s   instlx

instlb: cmpi.b  #'2',d0
	bne.s   instld
	move.b  #3,d2           ;double sided
	move    d0,d1
	bsr     ascii_out

instld: cmpi.b  #'3',d0
	bne.s   instlx
	move.b  #$43,d2         ;high density
	move    d0,d1
	bsr     ascii_out

instlx: bsr     crlf
	rts

*-------------------------------
*       Display current floppy operation, side and track 
*       Display drive A on line 0, drive B on line 1
*       Display starts at column 19--after drive name and capacity
*       a5=message (format, read, write)
*       ftrk=track
dspop:  bsr     escjs           ;save cursor
	moveq   #22,d0          ;x=22
	move    fdev,d1         ;y=line 0 or 1
	bsr     escy            ;move cursor
	bsr     dspmsg
	bsr     dspsid
	bsr     dsptrk
	bsr     crlf
	bsr     escks           ;restore cursor
	rts

*-------------------------------
*       Display current sector
dspsct: lea     sectm,a5
	bsr     dspmsg
	move    csect,d0
	bsr     cnvdec
	bsr     dspbyt          ;sector         
	bsr     dspspc
	rts

*--------------------------------
*       Display current track
*       Entry:  ftrk=track
dsptrk: lea     trackm,a5
	bsr     dspmsg
	move    ftrk,d0
	bsr     cnvdec          ;convert to bcd 
	bsr     dspbyt          ;display track #
	move.l  #10,d1          ; 8/23/88 clear 10 spaces
	bsr     dspspcs
	rts

*--------------------------------
*       Display current side
dspsid: lea     sidmsg,a5
	bsr     dspmsg
	move    fsid,d1
	bsr     dspasc
	bsr     dspspc
	rts

*-------------------------------
*       Display drive
dspdrv: 
*       lea     drvbm,a5
*       tst.w   fdev
*        bne.s   dspdr0          ;br drive B
	lea     drvam,a5        ;drive A
dspdr0: bsr     dspmsg
	rts

*--------------------------------
*       test for high density drive
*       exit:   ne if error
ftsthi: 
	move.w  #fmtdat,fdat
	move.w  #1,fint
	move.w  #79,ftrk        ;last track
	move.w  #0,fsid         ;side 0
	bsr     setden          ;set fcnt
	bsr     _flopfmt        ;format side 0
	bne.s   ftsthix
	bsr     _floprd         ;read it
ftsthix:
	rts

*----------------------------------------
*       Test side select
*       Entry from see-what's-there sequence
*       Format track 79, side 0 and 1, read side 0 and verify data
*       Entry:  fdev is 0 or 1
*       Exit:   d0=0 if can't write side 0, d0=1 if can write only side 0
*               d0=2 if can write both sides
fsidsel:
	move.w  #fmtdat,fdat
	move.w  #1,fint
	move.w  #79,ftrk        ;last track
	move.w  #0,fsid         ;side 0
	move.w  #9,fcnt
	bsr     setden
	bsr     fmt_trk         ;format side 0
	tst     d0
	beq.s   fsdsl
	moveq   #0,d0           ;0 good sides
	rts                     
fsdsl:  bsr     fillbuf         ;data to write is unique for this sector
	move.w  #1,fsct         ;sector 1
	move.w  #1,fcnt         ;only 1
	bsr     _flopwr
	tst     d0
	beq.s   fsidsl0
	moveq   #0,d0
	rts                     

*       Entry from tstdrv. Side 0 already formatted and written.
*       Format side 1 and verify side 0 was not altered
fsidsl0:
	move.w  #1,fsid
	move.w  #79,ftrk
	bsr     setden
	bsr     fmt_trk         ;format side 1
	tst     d0
	bne.s   fsidsl1         ;side 1 is bad, make it a single-sided disk

	move.w  #0,fsid
	move.w  #1,fcnt
	bsr     rd_trk          ;read side 0
	tst     d0
	bne.s   fsidsl1         ;it was ok before, must have formatted side 1
*                               ;over it.
	moveq   #2,d0           ;both sides ok
	rts                     

fsidsl1:
	moveq   #1,d0           ;side 0 only
	rts
	        
*----------------------------------------
*       Test a drive
*       Format, write, read tracks 0,1,79 on side 0
*          If double sided, format side 1 track 0
*          and read side 0 to verify side select
*
*       Entry:  fdev=drive # (0 or 1)
*               driva:  bit0=A installed
*                       bit1=2 sided    
*               drivb:  bit0=B installed
*                       bit1=2 sided
*       Exit:   erflg0 ne if drive A failed
*               erflg1 ne if drive B failed

*       --------
*       Init. floppy: select, restore, set parameters
tstdrv: bsr     _flopini        ;initialize floppy 
	tst     d0              ;if ne, then error=seek (restore)
	bne.s   finit           ;sort out failure

*       Test side 0
	move.w  #0,fsid
	bsr     tstsid          ;test side 0 
	bne.s   tstdrve         ;ret ne

	lea     driva,a0
	move.w  fdev,d0         
	move.b  0(a0,d0),d1     ;get driva or drivb data
	btst    #1,d1           ;double sided?
	beq.s   tstdrve

*       Test side select
	bsr     fsidsl0         ;test side sel
	cmpi.b  #2,d0
	beq.s   tstdrve         ;br ok
	cmpi.b  #0,d0
	beq.s   tstdr2
	cmp     #0,curr_err     ;format error or did it write same side?
	beq.s   tstdr2          ;br if error
	        
*       Error: wrote side 0 or failed to write side 1 
	lea     fsiderr,a5      ;       "side select error"
	bsr     dspmsg
tstdr2: lea     erflg0,a0
	clr.l   d0
	move    fdev,d0
	move.b  #1,0(a0,d0)     ;set erflg
tstdrve:
	rts                     

*       Initialization failure (offline)
finit:  tst.w   fdev
	bne.s   finit0
	bsr     offlina
	move.b  #1,erflg0
	rts
finit0: bsr     offlinb
	move.b  #1,erflg1       ;ret ne
	rts

*-------------------------------
*       Test one side of a disk 
*       Format, write, read tracks 0, 1, 79
*       Entry:  fsid=side to test (0 or 1)
*       Exit:   display error

*       Format and write tracks 
tstsid: move.w  #1,fint         ;interleave
	bsr     setden

*       Format and write tracks
	clr.b   index1
	moveq   #0,d0
tstsd1: lea     trktbl,a0
	move.b  index1,d0
	move.b  0(a0,d0),ftrk+1
	bsr     fmt_trk         ;format a track
	tst     d0              ;any errors?
	beq.s   tstsd2
	rts                     ;ret ne, red, display
tstsd2: bsr     fillbuf
	move.w  #1,fsct         ;sector
	bsr     wrt_trk         ;write the track

	tst     d0
	beq.s   tstsd3
	rts
tstsd3: add.b   #1,index1
	cmp.b   #3,index1
	bne.s   tstsd1          ;until 3 tracks done

*       Read tracks.
	clr.b   index1
	moveq   #0,d0
trkrd:  lea     trktbl,a0
	move.b  index1,d0
	move.b  0(a0,d0),ftrk+1
	move.l  #rbuf,fbuf.w
	clr     hrderr

	bsr     rd_trk          ;read 9 sectors, report errors, retry 

	tst     d0
	beq.s   trkrd2          ;br no error
	rts

trkrd2: bsr     cmpdata         ;compare data
	bne.s   fcmp
	add.b   #1,index1
	cmp.b   #3,index1
	bne.s   trkrd
	rts                     ;return tstsid eq

fcmp    equ     *               ;fail compare data: msg already displayed
*       Fall thru or bsr:
*       Display drive, side, track, and flag error
dspinfo:
	bsr     dspdrv
	bsr     dspsid
	bsr     dsptrk
	move    #0,ccr          ;ret ne
	rts
	        
*-------------------------------
*       Write a track selected at random, then read it
*       Entry:  fdev=drive (0 or 1)
*       Exit:   drive A fail: erflg0 bit 2 set
*               drive B fail: erflg1 bit 2 set
tstrnd: move.b  #3,tempb        ;number of attempts
	move.b  tadr+mfp,d0     ;get random number from timer 
	andi.w  #$3f,d0
	cmpi.b  #79,d0          ;must be < or = to 79
	bgt.s   tstrnd
	move.w  d0,ftrk         ;this is the track
	move.w  #1,fsct
	bsr     setden

*       Format
	bsr     fmt_trk         ;format a track
	tst     d0
	beq.s   trnd1
	sub.b   #1,tempb        
	bne.s   tstrnd          ;if got bad sector, get another

*       Write
trnd1:  bsr     fillbuf
	bsr     wrt_trk         ;write the track
	tst     d0
	bne.s   rnd_fal

*       Read a track
	move.l  #rbuf,fbuf.w
	bsr     rd_trk
	tst     d0
	bne.s   rnd_fal
	bsr     cmpdata
	bne.s   fcmp
	rts
rnd_fal:
	tst     fdev
	beq.s   rndfl1
	bset    #2,erflg1
	rts
rndfl1: bset    #2,erflg0
	rts

*-------------------------------
*       set sectors/track according to density of drive
*       entry:  driva bit 6 = 1 if high density
*       exit:   fcnt = 9 if driva bit 6 = 0 or if fdev = 1
setden: move    #9,fcnt
	tst     fdev            ;chk drive
	bne.s   stden0          ;if B, must be low density
	btst    #6,driva        ;chk drive a status
	beq.s   stden0
	move.w  #18,fcnt
stden0: rts

*+--------------------------------------
* dspfail  - display error message after read/write error
*       and drive, side, and track
* possible errors: e_seek, e_dmasta, e_dmacnt, e_rnf, e_crc
*               e_ld, e_read, e_write, e_nready
*       Exit:   d0.w=error
dspfail:
	move    curr_err,d0
	tst     d0
	beq     frtxit          ;oops!
	cmpi.b  #e_seek,d0      ;seek?
	bne.s   frt0
	lea     fseek,a5
	bra     frtret
frt0:   cmpi.b  #e_dmasta,d0    ;dma status?
	bne.s   frt1
	lea     fdmasta,a5
	bra     frtret
frt1:   cmpi.b  #e_rnf,d0       ;record not found?
	bne.s   frt2
	lea     frnf,a5
	bra     frtret
frt2:   cmpi.b  #e_crc,d0       ;crc?
	bne.s   frt3
	lea     fcrc,a5
	bra.s   frtret
frt3:   cmpi.b  #e_dmacnt,d0    ;dma counter?
	bne.s   frt4
	lea     fdmacnt,a5
	bra.s   frtret
frt4:   cmpi.b  #e_nready,d0    ;not ready? (=timeout)
	bne.s   frt5
	lea     notrdy,a5       
	bra.s   frtret
frt5:   cmpi.b  #e_wp,d0        ;write protect?
	bne.s   frt6
	lea     wperr,a5
	bra.s   frtret
frt6:   cmpi.b  #e_ld,d0        ;lost data?
	bne.s   frt7
	lea     lostd,a5
	bra.s   frtret
frt7:   cmpi.b  #e_read,d0      ;read error?
	bne.s   frt8
	lea     rdfal,a5
	bra.s   frtret
frt8:   cmpi.b  #e_badsects,d0  ;bad sectors in format?
	bne.s   frt9
	lea     badsctm,a5
	bsr     dspmsg
	bsr     dspinfo
	lea     sectm,a5
	bsr     dspmsg
	move.l  cdma.w,a2
frt8a:  move    (a2)+,d1        ;print bad sectors
	beq.s   frtret0
	bsr     dspbyt
	bsr     dspspc
	bra.s   frt8a
frt9:   lea     wrtfal,a5       ;by default, its write error

frtret: bsr     dspmsg          ;display error 
	bsr     dspinfo         ;display drive,side,track
frtret0:
	bsr     crlf
frtxit: move    curr_err,d0
	rts 

*+------------------------------------------
* fillbuf - fill write buffer with data.
*       1 track = 4068 bytes
*       First byte: bit 7=drive, bit 6=side, bit 5-0=cycle
*       Second byte=track
*       Third byte=sector
*       Fourth byte=ramdom number for this pass
*       Third word=bdc6
*       consequetive words count up from bdc6

fillbuf:
	movea.l #wbuf,a0
	move.w  #$bdc6,d4       ;worst case data

	move.b  fsct+1,d1       ;get sector lsb
	move.b  cycle+3,d0
	andi.b  #$3f,d0         ;clear bits 6 & 7
	tst     fdev
	beq.s   flbf1
	bset    #7,d0           ;set bit 7 if drive 1
flbf1:  tst     fsid
	beq.s   flbf2
	bset    #6,d0           ;set bit 6 if side 1
flbf2:  moveq   #8,d2

*       Loop For 9 sectors:
flbf3:  move.l  #253,d3         ;256 words/sector - 4 bytes address/random

*       For 512 bytes:
	move.b  d0,(a0)+        ;1st byte = drive and side
	move.b  ftrk,(a0)+      ;2nd byte = track
	move.b  d1,(a0)+        ;3rd byte = sector
	move.b  rndbyt,(a0)+    ;4th byte = random number each pass
flbf4:  move.w  d4,(a0)+        ;start with worst case data
	add     #1,d4           ;and count up
	dbra    d3,flbf4        ;for 512 bytes

	addq    #1,d0           ;next sector
	dbra    d2,flbf3        ;do for 9 sectors

	rts

*-------------------------------
*       Fill write buffer with constant for interchange test
filla:  move    #$aaaa,d1
	bra.s   fillab
fillb:  move    #$bbbb,d1
fillab: move.l  #4607,d0
	lea     wbuf,a0
fillwb: move.b  d1,(a0)+
	dbra    d0,fillwb
	rts

*------------------------------
*       Compare data written with data read
cmpdata:
	bsr     fillbuf         ;fill write buffer with correct pattern
	lea     wbuf,a0
	lea     rbuf,a1
cmpd1:  cmp.w   (a0)+,(a1)+     ;compare write and read buffer
	beq.s   cmpd2

*       Error, display data written, read
	bset    #0,erflg0
	move.w  #red,palette
	lea     daterr,a5
	bsr     dspmsg
	suba.l  #2,a0
	suba.l  #2,a1
	move.w  (a0)+,d1        ;written
	bsr     dspwrd
	bsr     dspspc
	move.w  (a1)+,d1        ;read
	bsr     dspwrd
	bsr     dspspc
	bsr     dsptrk          ;track
	bsr     dspsct          ;sector
	bsr     crlf
	movem.l a0-a1,-(sp)
	bsr     constat
	movem.l (sp)+,a0-a1
	tst     d0
	beq.s   cmpd2
	rts
cmpd2:  cmpa.l  #wbuf+4608,a0
	blt     cmpd1
	rts

*-------------------------------
*       Format a track
*       Display operation, status, red screen if fail
*       Record bad tracks (any bad sectors)
*       If more than 1 bad sector, fail and restore
*       Exit:   d0=error, eq=pass, ne=fail
*               may have bad sector and pass
fmt_trk:
	lea     fmtmsg,a5       ;'Formatting Track xx'
	bsr     dspop
	lea     badtrack,a2
	clr.l   d2
	move    ftrk,d2
	tst     fsid
	beq.s   fmtt1
	add     #80,d2
fmtt1:  clr.b   0(a2,d2)        ;clear bad track flag

	bsr     _flopfmt        ;format a track
	tst     d0
	beq.s   fmtt4
	
	tst.b   sidtst          ;if we don't know what to expect...
	beq.s   fmtt5
	rts                     ;...just return failure without printing error

*       Format error--flag this bad track
*       If more than one sector is bad, return error
fmtt5:  lea     badtrack,a2
	clr.l   d2
	move    ftrk,d2
	tst     fsid
	beq.s   fmtt2
	add     #80,d2
fmtt2:  move.b  #$ff,0(a2,d2)   ;flag bad track
	bsr     dspfail         ;display the error
	move    curr_err,d0     ;get error
	cmp     #e_badsects,curr_err
	bne.s   fmtt3           ;ret ne
	move.l  cdma.w,a2               ;check number of bad sectors
	adda.l  #2,a2   
	tst     (a2)            ;ret ne if more than 1
	beq.s   fmtt4           ;only one bad sector, ok
	
fmtt3:  bsr     set_err         ;set flag and red screen
	add     #1,fmt_err
	move    d0,-(sp)        ;save old error
	bsr     _flopini        ;re-initialize (restore)
	move    (sp)+,d0
	andi    #$1b,ccr
fmtt4:  rts                     ;eq/ne, d0=error

*------------------------------
*       Write track
*       Check bad track table for bad sectors, skip if any
*       Display operation, status
*       If error, restore and perform 1 retry
*       Exit:   d0.w=error, red screen if error
wrt_trk:
	move.l  #wbuf,fbuf.w
	clr     hrderr
	lea     badtrack,a2
	clr.l   d2
	move    ftrk,d2
	tst     fsid
	beq.s   wrtt1
	add     #80,d2
wrtt1:  tst.b   0(a2,d2)        ;bad track?
	bne.s   wrtt4           ;skip track
	lea     wrtmsg,a5       ;'Writing track xx'
	bsr     dspop
	bsr     fillbuf

wrtt2:  bsr     _flopwr
	tst     d0
	beq.s   wrtt4           ;br no error

	bsr     dspfail
	move    d0,-(sp)        ;save old error
	bsr     _flopini        ;restore
	move    (sp)+,d0
	add     #1,wrt_err
	tst     hrderr          ;prev. error same track?
	beq.s   wrtt3
	bsr     set_err
	lea     harder,a5
	bsr     dspmsg
	bra.s   wrtt5

wrtt3:  move    #1,hrderr       ;if fail again, hard error
	bra.s   wrtt2           ;try again

wrtt4:  tst     hrderr          ;pass, check for soft error
	beq.s   wrtt5
	lea     sfterrm,a5
	bsr     dspmsg
wrtt5:  rts


*--------------------------------
*       Read track
*       check bad track table, skip if bad
*       Display operation, status
*       If error, restore and perform one retry
*       Exit:   d0.w=error, eq if pass, ne if fail

rd_trk: move.l  #rbuf,fbuf.w
	lea     badtrack,a2     ;check bad track table
	clr.l   d2
	move    ftrk,d2
	tst     fsid
	beq.s   rdtk1
	add     #80,d2
rdtk1:  tst.b   0(a2,d2)        ;bad track?
	bne.s   rd_pas          ;skip it (give a pass)
	move    #0,hrderr
	lea     rdmsg,a5        ;'Reading track xx'
	bsr     dspop

rdtk2:  bsr     _floprd
	tst     d0
	beq.s   rd_pas          ;good read
	
	tst.b   sidtst          ;if we don't know what to expect...
	beq.s   rdtk4
	rts                     ;...just return error, don't print it

rdtk4:  move    d0,-(sp)        ;save error
	bsr     dspfail
	bsr     _flopini        ;restore
	move    (sp)+,d0        ;restore error
	add     #1,rd_err
	tst     hrderr          ;prev. error same track?
	beq.s   rdtk3
	bsr     set_err
	lea     harder,a5
	bsr     dspmsg
	rts                     ;ret error in d0

rdtk3:  move    #1,hrderr       ;flag error and...
	bra.s   rdtk2           ;try again

rd_pas: clr.l   d0              ;success
	tst     hrderr
	beq.s   rdpas1
	lea     sfterrm,a5
	bsr     dspmsg
rdpas1: rts

*------------------------------
set_err:
	movem.l d0/a0,-(sp)
	lea     erflg0,a0
	clr.l   d0
	move    fdev,d0
	move.b  #1,0(a0,d0)     ;set erflg
;        move    #red,palette    ;hard error
	movem.l (sp)+,d0/a0
	rts

*-------------------------------------
*       Display drive offline message
offlinb:
*        lea     drvbm,a5        ;drive B
*        bra.s   offline
offlina:
	lea     drvam,a5        ;drive A
offline:
	bsr     dspmsg
	lea     offlin,a5
	bsr     dspmsg
	bsr     crlf
	move    #red,palette
	rts

*+------------------------------
* flopini - initialize floppies
*       1. set up dsb:
*               seek rate
*               current track
*       2. set up disk parameters (floplock)
*       3. select drive
*       4. restore

* Passed:
*        devno
*
* Returns: d0   EQ if initialization succeeded (drive attached).
*          d0   NE if initialization failed (no drive attached).
* Possible errors: e_seek
*-
_flopini:
	lea     dsb0,a1                 ; get ptr to correct DSB
	tst.w   fdev                    ;check device #
	beq.s   fi_1
	lea     dsb1,a1

fi_1:   move.w  #seekrate,dseekrt(a1)   ; setup default seek rate
	clr.w   dcurtrack(a1)           ; fake clean drive
	bsr     floplock                ; setup parameters
	bsr     select                  ; select drive and side
	move.w  #recal,dcurtrack(a1)    ; default = recal drive (it's dirty)

	bsr     restore                 ; attempt restore
	beq.s   fi_ok                   ; (quick exit if that won)
	moveq   #10,d7                  ; attempt seek to track 10
	bsr     hseek1                  ; (hard seek to 'd7')
*                                       ; curr_err=e_seek
	bne.s   fi_nok                  ; (failed: drive unusable)
	bsr     restore                 ; attempt restore after seek
fi_ok:  beq     flopok                  ; return OK (on win)
fi_nok: bra     flopfail                ; return failure

*----------------------------------------
*       Read a track
*       Don't care about data
rdtrack:
	move.w  #e_read,d0      ; set general error#
	move.l  #rbuf,fbuf.w
	bsr     floplock        ; lock floppies, setup parameters, DMA end 
	bsr     select          ; select drive, setup registers, DMA start
	bsr     go2track        ; seek appropriate track
	bne     flopfail        ; br if seek error      

*       read track
	move.w  #$090,(a6)      ; toggle DMA data direction,
	move.w  #$190,(a6)      ; leave hardware in READ state
	nop
	move.w  #$090,(a6)
	move.w  ccount,dskctl   ; set sector count register
	move.w  #$080,(a6)      ; startup 1770 "read sector" command
	move.w  #$90,d7         ; read multiple
	bsr     wdiskctl
	move.l  #timeout,d7     ; set timeout count
	move.l  edma.w,a2               ; a2 -> target DMA address

*--- Wait for read completion:
rdtrk2: btst.b  #5,gpip+mfp     ; 1770 done yet?
	beq.s   rdtrk3          ; (yes)
	subq.l  #1,d7           ; decrement timeout counter
	bne.s   rdtrk2          ; wait until done or timeout

*--- timeout: reset the controller 
	move.w  #e_nready,curr_err      ; set "timeout" error
	bsr     reset1770               ; (clobber 1770)
	bra     flopfail                ; 

*--- check status after IRQ (don't care, actually)
rdtrk3: 
	move.w  #$090,(a6)              ; examine DMA status register
	move.w  (a6),d0

*--- read 1770 status
	move.w  #$080,(a6)              ; examine 1770 status register
	bsr     rdiskctl
	bra     flopok                  ; if tmpdma<>end dma addr, fail


*+--------------------------------
* floprd - read sector from floppy
 
* Passed:
*       count
*       sideno
*       trackno
*       sectno
*       devno
*       DSB
*       buffer
*
* Returns:      EQ, the read won (on all sectors),
*               NE, the read failed (on some sector).
*               d0=error.
* Possible errors: e_read, e_nready, e_crc, e_rnf, e_seek,
*               e_dmasta, e_dmacnt      
*
* Rev. 3.6: does not use read mult. sector command      
* Mods for Rev. 2: set 1770 to single sector read if specified
*               no retries
*               if dma count incorrect, set error
*-

_floprd:        
	move.w  #e_read,d0      ; set general error#
	bsr     floplock        ; lock floppies, setup parameters, DMA end 
	bsr     select          ; select drive, setup registers, DMA start
	bsr     go2track        ; seek appropriate track
	bne     flopfail        ; br if seek error      

*       Loop to read sectors
frd1:   move.w  #$090,(a6)      ; toggle DMA data direction,
	move.w  #$190,(a6)      ; leave hardware in READ state
	nop
	move.w  #$090,(a6)
	move.w  ccount,dskctl   ; set sector count register
	move.w  #$080,(a6)      ; startup 1770 "read sector" command
	move.w  #$80,d7         ; read single
	bsr     wdiskctl
	move.l  #timeout,d7     ; set timeout count
	move.l  edma.w,a2               ; a2 -> target DMA address

*--- Wait for read completion:
***  note change from BIOS--check IRQ only, not dma counter
frd2:   btst.b  #5,gpip+mfp     ; 1770 done yet?
	beq.s   frd4            ; (yes)
	subq.l  #1,d7           ; decrement timeout counter
	bne.s   frd2            ; wait until done or timeout

*--- timeout: reset the controller 
	move.w  #e_nready,curr_err      ; set "timeout" error
	bsr     reset1770               ; (clobber 1770)
	bra     flopfail                ; 

*--- check status after IRQ:
frd4:   move.w  #$090,(a6)              ; examine DMA status register
	move.w  (a6),d0
	btst    #0,d0                   ; bit zero indicates DMA error
	bne.s   frd4a                   ; 0=dma error

	move.w  #e_dmasta,curr_err      ; dma status=error
	bra     flopfail

*--- read 1770 status
frd4a:  move.w  #$080,(a6)              ; examine 1770 status register
	bsr     rdiskctl
	and.b   #$1c,d0                 ; check for RNF, checksum, lost-data
	beq.s   frd5            

	bsr     err_bits                ; set error# from 1770 bits
	bra     flopfail

*       Success, check for more sectors
frd5:   addq.w  #1,csect
	add.l   #$200,cdma.w    ; bump DMA count
	subq.w  #1,ccount       ; check for more sectors to read
	beq.s   frd6            ; well done
	bsr     select1         ; setup sector #, DMA pointer
	bra     frd1            ; read next sector

*--- Status OK, compare DMA count
frd6:   move.b  dmahigh,tmpdma+1        ; get hardware DMA pointer
	move.b  dmamid,tmpdma+2         ; (most significant bytes FIRST)
	move.b  dmalow,tmpdma+3
	cmp.l   tmpdma.w,a2             ; 
	beq     flopok                  ; if tmpdma<>end dma addr, fail

*       DMA count error
	move.w  #e_dmacnt,curr_err      ; dma stuck error
	bra     flopfail


*+--------------------------------------------------------
* err_bits - set "curr_err" according to 1770 error status
*            If no status error, set to def_error.                      
* Passed:       d0 = 1770 status
*
* Returns:      curr_err, containing current error number
*
* Uses:         d1
*-
err_bits:
	moveq   #e_wp,d1                ; write protect?
	btst    #6,d0
	bne.s   eb1

	moveq   #e_rnf,d1               ; record-not-found?
	btst    #4,d0
	bne.s   eb1

	moveq   #e_crc,d1               ; CRC error?
	btst    #3,d0
	bne.s   eb1

	moveq   #e_ld,d1                ; lost data?
	btst    #2,d0
	bne.s   eb1

	move    def_error,d1    ; use default error#
eb1:    move.w  d1,curr_err             ; set current error number & return
	rts


*+---------------------------------------
* flopwr - write sector to floppy
* Passed:
*       fcnt    sector count
*       fsid    sideno
*       ftrk    trackno
*       fsct    sectno
*       fdev    devno
*       fbuf    buffer 
*
* Returns:      EQ, the write won (on all sectors), see flopok.
*               NE, the write failed (on some sector), see flopfail.
*               d0.l=error
*-
_flopwr:
	moveq   #e_write,d0             ; set default error number
	bsr     floplock                ; lock floppies

fwr1:   bsr     select                  ; select drive
	bsr     go2track                ; seek
	bne     flopfail

fwr1a:  move.w  #$190,(a6)              ; toggle DMA chip to clear status
	move.w  #$090,(a6)
	move.w  #$190,(a6)              ; leave in WRITE mode
	move.w  #1,d7                   ; load sector-count register
	bsr     wdiskctl
	move.w  #$180,(a6)              ; load "WRITE SECTOR" command
	move.w  #$a0,d7                 ; into 1770 cmdreg
	bsr     wdiskctl
	move.l  #timeout,d7             ; d7 = timeout count

fwr2:   btst.b  #5,gpip+mfp             ; done yet?
	beq.s   fwr4                    ; (yes, check status)
	subq.l  #1,d7                   ; decrement timeout count
	bne.s   fwr2                    ; (still tickin')

*       Timed-out
	move.w  #e_nready,curr_err      ; set error
	bsr     reset1770               ; timed out -- reset 1770
	bra     flopfail

*       Got IRQ; check status
fwr4:   move.w  #$180,(a6)              ; get 1770 status
	bsr     rdiskctl
	bsr     err_bits                ; compute 1770 error bits
	and.b   #$5c,d0         ; check WritProt+RecNtFnd+CHKSUM+LostData
	bne     flopfail                        

*       No error; any more sectors?
	addq.w  #1,csect                ; bump sector number
	add.l   #$200,cdma.w            ; and DMA pointer for next sector
	subq.w  #1,ccount               ; if(!--count) return OK;
	beq     flopok
	bsr     select1                 ; setup sector#, DMA pointer
	bra.s   fwr1a                   ; write next (no seek)


*+--------------------------------------
* _flopfmt - format a track
* Passed:
*       fdat    initial sector data
*       fint    interleave
*       fsid    side
*       ftrk    track
*       fcnt    spt
*       fdev    drive
*
* Returns:      EQ: track successfully written.  Zero.W-terminated list of
*               bad sectors left in buffer (they might /all/ be bad.)
*
*               NE: could not write track (write-protected, drive failure,
*               or something catastrophic happened).
*-
_flopfmt:
	moveq   #e_write,d0             ; set default error number
	move.l  #wbuf,fbuf.w
	bsr     floplock                ; lock floppies, setup parms
	bsr     select                  ; select drive and side
	move.w  fcnt,spt                ; save sectors-per-track
	move.w  fint,interlv            ; save interleave factor
	move.w  fdat,virgin             ; save initial sector data

*--- seek to track (hard seek):
	bsr     hseek                   ; hard seek to 'ctrack'
	bne     flopfail                ; (return error on seek failure)
	move.w  ctrack,dcurtrack(a1)    ; record current track#

*--  erase current format
	bsr     erase

*--  format
	move.w  #1,csect                ; starting sector# = 1
	bsr     fmtrack                 ; format track
	bne     flopfail                ; (return error on seek failure)
	move.w  spt,ccount              ; set number of sectors to verify
	bsr     verify1                 ; verify sectors

*--- if there are any bad sectors, return /that/ error...
	move.l  cdma.w,a2                       ; a2 -> bad sector list
	tst.w   (a2)                    ; any bad sectors?
	beq     flopok                  ; no -- return OK
	move.w  #e_badsects,curr_err    ; set error number
	bra     flopfail                ; return error

*+
* erase - format a track with zeros
* Passed:       variables setup by _flopfmt
* Returns:      NE on failure, EQ on success
* Uses:         almost everything
* Called-by:    _flopfmt
*
*-
*       Set up an 8k buffer with opcodes for the 1770 to do a track format
erase:
	move.w  #e_write,def_error      ; set default error number
	move.w  #1,d3                   ; start with sector 1, first pass
	move.l  cdma.w,a2                       ; a2 -> prototyping area
	move.w  #60-1,d1                ; 60 x $4e (track leadin)
	move.b  #$0,d0
	bsr     wmult

*--- address mark
	move    #9*606-1,d1             ; 9 sectors worth
	move.b  #$0,d0  
	bsr     wmult

*--- end-of-track
	move.w  #1400,d1                ; 1401 x $4e -- end of track trailer
	move.b  #$0,d0
	bsr     wmult

*--- setup to write the track:
	move.b  cdma+3,dmalow           ; load dma pointer
	move.b  cdma+2,dmamid
	move.b  cdma+1,dmahigh
	move.w  #$190,(a6)              ; toggle R/W flag and
	move.w  #$090,(a6)              ; select sector-count register
	move.w  #$190,(a6)
	move.w  #$1f,d7                 ; (absurd sector count)
	bsr     wdiskctl
	move.w  #$180,(a6)              ; select 1770 cmd register
	move.w  #$f0,d7                 ; write format_track command
	bsr     wdiskctl
	move.l  #timeout,d7             ; d7 = timeout value

*--- wait for 1770 to complete:
erase1: btst.b  #5,gpip+mfp             ; is 1770 done?
	beq.s   erase2                  ; (yes)
	subq.l  #1,d7                   ; if(--d7) continue;
	bne.s   erase1

*       Time-out
	move.w  #e_nready,curr_err
	bsr     reset1770               ; timed out -- reset 1770
eraser: moveq   #1,d7                   ; return NE (error status)
	rts

*--- see if the write-track won:
erase2: move.w  #$190,(a6)      ; check DMA status bit
	move.w  (a6),d0
	btst    #0,d0           ; if its zero, there was a DMA error
	beq.s   eraser          ; (so return NE)
	move.w  #$180,(a6)      ; get 1770 status
	bsr     rdiskctl
	and.b   #$44,d0         ; check for writeProtect & lostData
	beq.s   erase3
	bsr     err_bits        ; set 1770 error bits
erase3: rts                     ; return NE on 1770 error


*+-------------------------------
* fmtrack - format a track
* Passed:       variables setup by _flopfmt
* Returns:      NE on failure, EQ on success
* Uses:         almost everything
* Called-by:    _flopfmt
*
*-
*       Set up an 8k buffer with opcodes for the 1770 to do a track format

fmtrack:
	move.w  csect,d3                ; starting sector
	move.w  #e_write,def_error      ; set default error number
	move.l  cdma.w,a2               ; a2 -> prototyping area
	move.w  #60-1,d1                ; 60 x $4e (track leadin)
	move.b  #$4e,d0
	bsr     wmult

*--- address mark
ot1:    move.w  #12-1,d1                ; 12 x $00
	clr.b   d0
	bsr     wmult
	move.w  #3-1,d1                 ; 3 x $f5
	move.b  #$f5,d0
	bsr     wmult
	move.b  #$fe,(a2)+              ; $fe -- address mark intro
	move.b  ctrack+1,(a2)+          ; track#
	move.b  cside+1,(a2)+           ; side#
	move.b  d3,(a2)+                ; sector#
	move.b  #$02,(a2)+              ; sector size (512)
	move.b  #$f7,(a2)+              ; write crc

*--- gap between AM and data:
	move.w  #22-1,d1                ; 22 x $4e
	move.b  #$4e,d0
	bsr     wmult
	move.w  #12-1,d1                ; 12 x $00
	clr.b   d0
	bsr     wmult
	move.w  #3-1,d1                 ; 3 x $f5
	move.b  #$f5,d0
	bsr     wmult

*--- data block:
	move.b  #$fb,(a2)+              ; $fb -- data intro
	move.w  #256-1,d1               ; 256 x virgin.W (initial sector data)
ot2:    move.b  virgin,(a2)+            ; copy high byte
	move.b  virgin+1,(a2)+          ; copy low byte
	dbra    d1,ot2                  ; fill 512 bytes

	move.b  #$f7,(a2)+              ; $f7 -- write crc
	move.w  #40-1,d1                ; 40 x $4e
	move.b  #$4e,d0
	bsr     wmult

	add.w   #1,d3                   ; bump sector#
	sub     #1,ccount
	bne     ot1                     ; proto more sectors this pass

*--- end-of-track
	move.w  #1400,d1                ; 1401 x $4e -- end of track trailer
	move.b  #$4e,d0
	bsr     wmult

*--- setup to write the track:
	move.b  cdma+3,dmalow           ; load dma pointer
	move.b  cdma+2,dmamid
	move.b  cdma+1,dmahigh
	move.w  #$190,(a6)              ; toggle R/W flag and
	move.w  #$090,(a6)              ; select sector-count register
	move.w  #$190,(a6)
	move.w  #$1f,d7                 ; (absurd sector count)
	bsr     wdiskctl
	move.w  #$180,(a6)              ; select 1770 cmd register
	move.w  #$f0,d7                 ; write format_track command
	bsr     wdiskctl
	move.l  #timeout,d7             ; d7 = timeout value

*--- wait for 1770 to complete:
otw1:   btst.b  #5,gpip+mfp             ; is 1770 done?
	beq.s   otw2                    ; (yes)
	subq.l  #1,d7                   ; if(--d7) continue;
	bne.s   otw1

*       Time-out
	move.w  #e_nready,curr_err
	bsr     reset1770               ; timed out -- reset 1770
oterr:  moveq   #1,d7                   ; return NE (error status)
	rts

*--- see if the write-track won:
otw2:   move.w  #$190,(a6)      ; check DMA status bit
	move.w  (a6),d0
	btst    #0,d0           ; if its zero, there was a DMA error
	beq.s   oterr           ; (so return NE)
	move.w  #$180,(a6)      ; get 1770 status
	bsr     rdiskctl
	and.b   #$44,d0         ; check for writeProtect & lostData
	beq.s   otw3
	bsr     err_bits        ; set 1770 error bits
otw3:   rts                     ; return NE on 1770 error

*------ write 'D1+1' copies of D0.B into A2, A2+1, ...
wmult:  move.b  d0,(a2)+                ; record byte in proto buffer
	dbra    d1,wmult                ; (do it again)
	rts

*+------------------------------------
* _flopver - verify sectors on a track
*       fcnt    count
*       fsid    sideno
*       ftrk    trackno
*       fsct    sectno
*       fdev    devno
*       fdsb    ->DSB
*       fbuf    ->buffer (at least 1K long)
*
* Returns:      NULL.W-terminated list of bad sectors in the buffer if D0 == 0,
*               OR some kind of error (D0 < 0).
*
*-
*_flopver:
*        moveq   #e_read,d0              ; set default error#
*        bsr     floplock                ; lock floppies, setup parameters
*        bsr     select                  ; select floppy
*        bsr     go2track                ; go to track
*        bne     flopfail                ; (punt if that fails)
*        bsr     verify1                 ; verify some sectors
*        bra     flopok                  ; return "OK"

*+
* verify1 - verify sectors on a single track
* Passed:       csect = starting sector#
*               ccount = number of sectors to verify
*               cdma -> 1K buffer (at least)
*
* Returns:      NULL.W-terminated list of bad sectors (in the buffer)
*               (buffer+$200..buffer+$3ff used as DMA buffer)
*
* Enviroment:   Head seeked to the correct track;
*               Drive and side already selected;
*               Motor should be spinning (go2track and fmttrack do this).
*
* Uses:         Almost everything.
*
* Called-by:    _flopfmt, _flopver
*
*-
verify1:
	move.w  #e_read,def_error       ; default=read
	move.l  cdma.w,a2               ; a2 -> start of bad sector list
	add.l   #$200,cdma.w            ; bump buffer up 512 bytes

*--- setup for (next) sector
tvrlp:  move.w  #retries,retrycnt       ; init sector-retry count
	move.w  #secreg,(a6)            ; load 1770 sector register
	move.w  csect,d7                ; with 'csect'
	bsr     wdiskctl

*--- setup for sector read
tvr1:   move.b  cdma+3,dmalow           ; load dma pointer
	move.b  cdma+2,dmamid
	move.b  cdma+1,dmahigh
	move.w  #$090,(a6)              ; toggle R/W (leave in W state)
	move.w  #$190,(a6)
	move.w  #$090,(a6)
	move.w  #1,d7                   ; set DMA sector count to 1
	bsr     wdiskctl
	move.w  #$080,(a6)              ; load 1770 command register
	move.w  #$80,d7                 ; with ReadSector command
	bsr     wdiskctl
	move.l  #timeout,d7             ; set timeout value

*--- wait for command completion
tvr2:   btst.b  #5,gpip+mfp             ; test for 1770 done
	beq.s   tvr4                    ; (yes, it completed)
	subq.l  #1,d7                   ; decrement timeout count
	bne.s   tvr2                    ; (still counting down)
	bsr     reset1770               ; reset controller and return error
	bra.s   tvre

*--- got "done" interrupt, check DMA status:
tvr4:   move.w  #$090,(a6)              ; read DMA error status
	move.w  (a6),d0
	btst    #0,d0                   ; if DMA_ERROR is zero, then retry
	beq.s   tvre

*--- check 1770 completion status (see if it's happy):
	move.w  #$080,(a6)              ; read 1770 status register
	bsr     rdiskctl
	bsr     err_bits                ; set error# from 1770 register
	and.b   #$1c,d0                 ; check for record-not-found, crc-err,
	bne.s   tvre                    ;       and lost data; return on error

*--- read next sector (or return if done)
tvr6:   addq.w  #1,csect                ; bump sector count
	subq.w  #1,ccount               ; while(--count) read_another;
	bne     tvrlp
	sub.l   #$200,cdma.w            ; readjust DMA pointer
	clr.w   (a2)                    ; terminate bad sector list
	rts                             ; and return EQ

*--- read failure: record bad sector
tvre:   move.w  csect,(a2)+             ; record bad sector
	bra.s   tvr6                    ; do next sector


*+----------------------------------------------------
* floplock - lock floppies and setup floppy parameters
*
* Passed:
*       fcnt - count.W (sector count)
*       fsid - side.W (side#)
*       ftrk - track.W (track#)
*       fsct - sect.W (sector#)
*       fdev - dev.W (device#)
*       fbuf - dma.L (dma pointer)
*
*       D0.W = default error number
*-
floplock:
	move.w  #$2400,sr               ; stop vblank (case prev. unlock)
	clr.b   desel                   ; clear vblank flag
	movea.l #0,a5                   ; a5 -> variable base addr
	lea     fifo,a6                 ; a6 -> fifo
	move.w  d0,def_error            ; set default error number
	move.w  d0,curr_err             ; set current error number
	move.l  fbuf.w,cdma.w           ; cdma -> /even/ DMA address
	move.w  fdev,cdev               ; save device# (0 .. 1)
	move.w  fsct,csect              ; save sector# (1 .. 9, usually)
	move.w  ftrk,ctrack             ; save track# (0 .. 39 .. 79 ..)
	move.w  fsid,cside              ; save side# (0 .. 1)
	move.w  fcnt,ccount             ; save sector count (1..spt)
	move.w  #retries,retrycnt       ; setup retry count

	lea     dsb0,a1
	tst     fdev
	bne     flplock1                ; bra on B drive only
	btst    #6,driva                ; if drive A = low density...
	beq.s   flplock1                ; bra to setup
	move    #3,fdccs                ; else 16 MHz clock (HD)
****~mod 1/4/90 tf      for high density slower step rate (3 msec)
	move.w  #0,dseekrt(a1)          ; set step rate to 3 msec
	bra.s   flcdsb

flplock1:
	move    #0,fdccs                ; default = 8 MHz 
	move.w  #3,dseekrt(a1)          ; default = 1.5 msec

*--- pick a DSB:
flcdsb: lea     dsb0,a1
	tst.w   cdev
	beq.s   flock2
	lea     dsb1,a1

*--- compute ending DMA address from count parameter:
flock2: moveq   #0,d7
	move.w  ccount,d7               ; edma = cdma + (ccount * 512)
	lsl.w   #8,d7
	lsl.w   #1,d7
	move.l  cdma.w,a0
	add.l   d7,a0
	move.l  a0,edma.w

*--- recalibrate drive (if it needs it)
	tst.w   dcurtrack(a1)           ; if (curtrack < 0) recalibrate()
	bpl.s   flockr

	bsr     select                  ; select drive & side
	clr.w   dcurtrack(a1)           ; we're optimistic -- assume win
	bsr     restore                 ; attempt restore
	beq.s   flockr                  ; (it won)
	moveq   #10,d7                  ; attempt seek to track 10
	bsr     hseek1
	bne.s   flock1                  ; (failed)
	bsr     restore                 ; attempt restore again
	beq.s   flockr                  ; (it won)
flock1: move.w  #recal,dcurtrack(a1)    ; complete failure (what can we do?)
flockr: rts


*+--------------------------------------------
* flopfail - unlock floppies and return error.
*
* Returns:      d0.l = error code
*-
flopfail:
	move.w  curr_err,d0             ; get current error number
	ext.l   d0                      ; extend to long
	bra.s   unlok1                  ; clobber floppy lock & return

*+--------------------------------------------------
* flopok - floppy operation succeeded; return success status:
*
* Returns:      d0.l = 0
*-
flopok: clr.l   d0                      ; return 0 (success)
	clr     curr_err

* unlock floppies and return status
* this terminates a disk operation (succeed or fail)

unlok1: move.l  d0,-(sp)                ; (save return value)
	move.w  #datareg,(a6)           ; force WP to real-time mode
	move.w  dcurtrack(a1),d7        ; dest-track = current track
	bsr     wdiskctl
	move.w  #$10,d6                 ; cmd = seek w/o verify
	bsr     flopcmds                ; do it

	bset    #7,desel                ; flag vblank routine to de-select
	move.l  #vbflop,$70             ; install floppy vblank routine
	move.w  #$2200,sr               ; enable

	move.l  (sp)+,d0                ; restore return value
	rts

*****************************************
*       Vertical blank for floppy
*       If floppies locked and motor off, deselect
vbflop: movem.l d0-d7,-(a7)
	btst    #7,desel                ; need to de-select?
	beq.s   vbflp1

	move.w  #cmdreg,fifo
	bsr     rdiskctl                ; read status
	btst    #7,d0                   ; motor on?
	bne.s   vbflp1

	move.b  #6,d0                   ; bits 1 and 2 high
	bsr     setporta                ; de-select floppies
	move.l  #vblank,$70             ; dis-able self
	move.w  #$2400,sr       
	clr.b   desel
vbflp1: movem.l (a7)+,d0-d7
	rte

*+----------------------------------------
* hseek  - seek to 'ctrack' without verify
* hseek1 - seek to 'd7' without verify
* hseek2 - seek to 'd7' without verify, keep current error number
*
* Returns:      NE on seek failure ("cannot happen"?)
*               EQ if seek wins
*
* Uses:         d7, d6, ...
* Jumps-to:     flopcmds
* Called-by:    _flopfmt, _flopini
*
*-
hseek:  move.w  ctrack,d7               ; dest track = 'ctrack'
hseek1: move.w  #e_seek,curr_err        ; possible error = "seek error"
hseek2: move.w  #datareg,(a6)   ; write destination track# to data reg
	bsr     wdiskctl
	move.w  #$10,d6                 ; execute "seek" command
	bra.s   flopcmds                ; (without verify...)


*+--------------------------------------
* reseek - home head, then reseek track
* Returns:      EQ/NE on success/failure
* Falls-into:   go2track
*
*-
reseek:
	move.w  #e_seek,curr_err        ; set "seek error"
	bsr     restore                 ; restore head
	bne.s   go2trr                  ; (punt if home fails)

	clr.w   dcurtrack(a1)           ; current track = 0
	move.w  #trkreg,(a6)            ; set "current track" reg on 1770
	clr.w   d7
	bsr     wdiskctl

	move.w  #datareg,(a6)           ; seek out to track five
	move.w  #5,d7
	bsr     wdiskctl                ; dest track = 5
	move.w  #$10,d6
	bsr     flopcmds                ; seek
	bne.s   go2trr                  ; return error on seek failure
	move.w  #5,dcurtrack(a1)        ; set current track#

*+---------------------------------------
* go2track - seek proper track
* Passed:       Current floppy parameters (ctrack, et al.)
* Returns:      EQ/NE on success/failure
* Calls:        flopcmds
*-
go2track:
	move.w  #e_seek,curr_err        ; set "seek error"
	move.w  #datareg,(a6)           ; set destination track# in
	move.w  ctrack,d7               ;  1770's data register
	bsr     wdiskctl                ; (write track#)
	moveq   #$14,d6                 ; execute 1770 "seek_with_verify"
	bsr     flopcmds                ; (include seek-rate bits)
	bne.s   go2trr                  ; return error on seek failure
	move.w  ctrack,dcurtrack(a1)    ; update current track number
	and.b   #$18,d7         ; check for RNF, CRC_error, lost_data
go2trr: rts                     ; return EQ/NE on succes/failure


*+-------------------
* restore - home head
* Passed:       nothing
* Returns:      EQ/NE on success/failure
* Falls-into:   flopcmds
*-
restore:
	clr.w   d6              ; $00 = 1770 "restore" command
	bsr     flopcmds        ; do restore
	bne.s   res_r           ; punt on timeout
	btst    #2,d7           ; test TRK00 bit
	eor     #$04,ccr        ; flip Z bit (return NE if bit is zero)
	bne.s   res_r           ; punt if didn't win
	clr.w   dcurtrack(a1)   ; set current track#
res_r:  rts


*+--------------------------------------------------------------
* flopcmds - floppy command (or-in seek speed bits from database)
* Passed:       d6.w = 1770 command
* Sets-up:      seek bits (bits 0 and 1) in d6.w
* Falls-into:   flopcmd
* Returns:      EQ/NE on success/failure
*-
flopcmds:
	move.w  dseekrt(a1),d0  ; get floppy's seek rate bits
	and.b   #3,d0           ; OR into command
	or.b    d0,d6

*+
* flopcmd - execute 1770 command (with timeout)
* Passed:       d6.w = 1770 command
*
* Returns:      EQ/NE on success/failure
*               d7 = 1770 status bits
*
*-
flopcmd:
	move.l  #timeout,d7     ; setup timeout count (assume short)
	move.w  #cmdreg,(a6)    ; select 1770 command register
	bsr     rdiskctl        ; read it to clobber READY status
	btst    #7,d0           ; is motor on?
	bne.s   flopcm          ; (yes, keep short timeout)
	move.l  #ltimeout,d7    ; extra timeout for motor startup
flopcm: bsr     wdiskct6        ; write command (in d6)

flopc1: subq.l  #1,d7           ; timeout?
	beq.s   flopcto         ; (yes, reset and return failure)
	btst.b  #5,gpip+mfp     ; 1770 completion?
	bne.s   flopc1          ; (not yet, so wait some more)
	bsr     rdiskct7        ; return EQ + 1770 status in d7
	clr.w   d6
	rts
flopcto:
	lea     to_msg,a5
	bsr     dspmsg
	bsr     reset1770               ; bash controller
	moveq   #1,d6                   ; and return NE
	rts

*+-----------------------------------------------------
* reset1770 - reset disk controller after a catastrophe
* Passed:       nothing
* Returns:      nothing
* Uses:         d7
*-
reset1770:
re1:    move.w  #cmdreg,(a6)    ; execute 1770 "reset" command
	move.w  #$d0,d7
	bsr     wdiskctl
	move.w  #20,d7          ; wait for 1770 to stop convulsing
r1770:  dbra    d7,r1770        ; (short delay loop)
	bsr     rdiskct7        ; return 1770 status in d7
	rts

*+---------------------------------------------------
* select - setup drive select, 1770 and DMA registers
* Passed:       cside, cdev
* Returns:      appropriate drive and side selected
*-
select:
	move.w  cdev,d0         ; get device number
	addq.b  #1,d0           ; add and shift to get select bits
	lsl.b   #1,d0           ; into bits 1 and 2
	or.w    cside,d0        ; or-in side number (bit 0)
	eor.b   #7,d0           ; negate bits for funky hardware select
	and.b   #7,d0           ; strip anything else out there
	bsr     setporta        ; do drive select

	move.w  #trkreg,(a6)    ; setup 1770 track register
	move.w  dcurtrack(a1),d7        ; from current track number
	bsr     wdiskctl
	clr.b   tmpdma          ; zero bits 24..32 of target DMA addr

*--- alternate entry point: setup R/W parameters on 1770
select1:
	move.w  #secreg,(a6)    ; setup requested sector_number from
	move.w  csect,d7        ;       caller's parameters
	bsr     wdiskctl
	move.b  cdma+3,dmalow   ; setup DMA chip's DMA pointer
	move.b  cdma+2,dmamid
	move.b  cdma+1,dmahigh
	rts


*+-------------------------------------------------------------
* setporta - set floppy select bits in PORT A on the sound chip
* Passed:       d0.b (low three bits) 0=side, 1=ds0, 2=ds1
* Returns:      d1 = value written to port A
*               d2 = old value read from port A
* Uses:         d1
*-
setporta:
	move    sr,-(sp)        ; save our IPL
	or      #$0700,sr       ; start critical section
	move.b  #giporta,psgsel ; select port on GI chip
	move.b  psgrd,d1        ; get current bits
	move.b  d1,d2           ; save old bits for caller
	and.b   #$ff-7,d1       ; strip low three bits there
	or.b    d0,d1           ; or-in our new bits
	move.b  d1,psgwr        ; and write 'em back out there
	move    (sp)+,sr        ; restore IPL to terminate CS, return
	rts

*+----------------------------------------------------------------
* Primitives to read/write 1770 controller chip (DISKCTL register).
*
* The 1770 can't keep up with full-tilt CPU accesses, so
* we have to surround reads and writes with delay loops.
* This is not really as slow as it sounds.
*
*-
* write d6 to diskctl
wdiskct6:
	bsr     rwdelay                 ;       delay
	move.w  d6,dskctl               ;       write it
	bra.s   rwdelay                 ;       delay and return

* write d7 to diskctl
wdiskctl:
	bsr     rwdelay                 ;       delay
	move.w  d7,dskctl               ;       write it
	bra.s   rwdelay                 ;       delay and return

* read diskctl into d7
rdiskct7:
	bsr     rwdelay                 ;       delay
	move.w  dskctl,d7               ;       read it
	bra.s   rwdelay                 ;       delay and return

* read diskctl into d0
rdiskctl:
	bsr     rwdelay                 ;       delay
	move.w  dskctl,d0               ;       read it
rwdelay:
	move    sr,-(sp)        ; save flags
	move.w  d7,-(sp)        ; save counter register
	move.w  #20,d7          ;
rwdly1: dbra    d7,rwdly1       ; busy-loop: give 1770 time to settle
	move.w  (sp)+,d7        ; restore register, flags, and return
	move    (sp)+,sr
	rts

	
*****************************************
	.data
	.even
trkseq: dc.b    0,79,46,32,1,10,60,22,67,44
	dc.b    59,45,17,33,47,20,74,21,66,68
	dc.b    18,72,56,71,16,73,4,34,69,27
	dc.b    58,57,6,70,39,48,53,8,75,76
	dc.b    28,29,38,77,23,9,40,65,26,61
	dc.b    78,37,12,52,19,49,14,15,54,35
	dc.b    36,30,13,5,51,7,63,25,55,62
	dc.b    11,64,42,41,24,50,31,43,3,2

trktbl: dc.b    0,1,79
trktb3: dc.b    0,39,79

flpmen: dc.b    tab,'Floppy disk drive routines:',cr,lf
	dc.b    tab,'(WARNING--all choices except 2,6,7 write to the disk)',cr,lf
	dc.b    tab,'1 Quick Test',cr,lf
	dc.b    tab,'2 Read Alignment Disk',cr,lf
	dc.b    tab,'3 Disk Change Detect',cr,lf
	dc.b    tab,'4 Disk Exerciser',cr,lf
	dc.b    tab,'5 Check copy protect tracks (80-82)',cr,lf
	dc.b    tab,'6 Test Speed',cr,lf
	dc.b    tab,'7 Install disk drives',cr,lf,eot

instlm: dc.b    '1  Single sided',cr,lf
	dc.b    '2  Double sided',cr,lf
	dc.b    '3  High Density',cr,lf
	dc.b    'Any other key will de-install this drive.',cr,lf,eot
gettrkm:
	dc.b    'Enter track number (if none entered, default=40): ',eot
flpsid: dc.b    'Select single sided (1) or double sided (2)',cr,lf,eot

algntrk:
	dc.b    'Read analog alignment disk',cr,lf
*A_or_B: dc.b    'Disk A or B?',cr,lf,eot
flpexm: dc.b    'Disk Exerciser',cr,lf,eot
intchgm:
	dc.b    '                Disk-change/write-protect test',cr,lf,lf
	dc.b    'Insert write protected disk in drive, hit any key to start',cr,lf,eot

swapm:   dc.b   'Remove and re-insert disk, Hit any key when done',cr,lf,eot
notswap:
	dc.b    cr,lf,'Disk Change Not Detected! ',cr,lf,eot
rptesc: dc.b    cr,lf,'Disk Change Detected!   ',cr,lf,eot

not_tect: dc.b  cr,lf,'Disk Not Write Protected!',cr,lf
	  dc.b  cr,lf,'         Hit any  key to continue ...',cr,lf,eot

ok_tect:  dc.b  cr,lf,'Disk Write Protected!',cr,lf
	  dc.b  cr,lf,'         Hit any  key to continue ...',cr,lf,eot

chkflpm:
	dc.b    'Checking drive type...',cr,lf,eot
drvam:  dc.b    'Disk A: ',eot
*drvbm:  dc.b    'Disk B: ',eot
wrtdska:
	dc.b    'Cannot write drive A',cr,lf,eot
*wrtdskb:
*        dc.b    'Cannot write drive B',cr,lf,eot
hidenm: dc.b    'High Density ',cr,lf,eot
snglsid:
	dc.b    'SS ',cr,lf,eot
dblsid: dc.b    'DS ',cr,lf,eot
nodrivm:
	dc.b    'No floppies ',cr,lf,eot
sectm:  dc.b    'Sector ',eot
trackm: dc.b    'Track ',eot
sidmsg: dc.b    'Side ',eot
fmtmsg: dc.b    'Formatting ',eot
wrtmsg: dc.b    'Writing    ',eot
rdmsg:  dc.b    'Reading    ',eot

cpymsg: dc.b    'Check Tracks 80-82',cr,lf,eot
cpypas: dc.b    'Copy protect tracks PASS                         ',cr,lf,eot
cpyfalm:
	dc.b    'Copy protect tracks FAIL                         ',cr,lf,eot

spdmsg: dc.b    'Floppy disk speed test',cr,lf,eot
spdrng: dc.b    'Testing speed',tab
	dc.b    'Allowable range = 196 - 204 milliseconds/revolution',cr,lf,eot
tomsg:  dc.b    'Time-out waiting for index',cr,lf,eot
to_msg: dc.b    cr,lf,'Time-out waiting for interrupt ',cr,lf,eot
spdata: dc.b    'Max      Min      Current speed',eot

sfterrm:
	dc.b    'Soft Error',cr,lf,eot
badsctm:
	dc.b    'Bad Sector: ',eot
offlin: dc.b    'F0 Not selected ',eot
sid0:   dc.b    'Side 0 ',eot
sid1:   dc.b    'Side 1 ',eot
fmtfal: dc.b    'Error formating ',eot
wrtfal: dc.b    'Error writing',cr,lf,eot
rdfal:  dc.b    'Error reading',cr,lf,eot
fseek:  dc.b    'F4 Seek error ',eot
wperr:  dc.b    'F5 Write Protected ',eot
daterr: dc.b    'F6 Read compare error ',eot
fdmasta:
	dc.b    'F7 DMA error ',eot
fdmacnt:
	dc.b    'F8 DMA count error ',eot       
fcrc:   dc.b    'F9 CRC error ',eot     
frnf:   dc.b    'FA Record not found ',eot
lostd:  dc.b    'FB Lost data ',eot
fsiderr:
	dc.b    'FC Side select error--single sided drive',cr,lf,eot
notrdy: dc.b    'FD Drive not ready ',eot
pausem: dc.b    'Stopped. ESC to quit, any other key to continue.',eot
harder: dc.b    'Hard error',cr,lf,eot
failm:  dc.b    'Fail ',eot
TFlopMsg: dc.b 'Floppy Test ',cr,lf,eot ;temp RWS.T
ftstend:
	dc.b    0
