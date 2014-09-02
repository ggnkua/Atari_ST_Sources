        .extern hpause
***                       *** RWH_AT.S***

*      Apr 13,92 Modified for Sparrow, TFM
*      Aug 18,91 Start of STe + v1.0
*      check DMA        
*         1.)  read and save cylinder 600
*         2.)  check and display any controller errors
*  -----> 3.)  fill write buffer with test data (1 cyl. or approx 32k)
* |       4.)  DMA the write buffer to cylinder 600
* |       5.)  check and display any controller errors
* |       6.)  clear read buffer
* |       7.)  DMA cylinder 600 into read buffer
* |       8.)  check and display any controller errors
* |       9.)  check that DMA register counted to zero; no, display error
* |       10.) compare buffers, ck buffer limits for spray, display errors 
*  -----  11.) repeat until 'esc' key
*         12.) write the saved data back to cylinder 600; exit to main diag

*       July 24, 90: add spray detect and full buffer check (32k),
*         debug command error routine. 
*       Jan 4, 90:  wait for key & restart if fail first read
*       Dec 7, 89:  rewrite for inclusion in Field Service ROM
*       Oct 31, 89: more cosmetic changes
*       Oct 3, 89: add some messages and stop on ESC during display error.
*       Jan 26, 1989: 8 data patterns, display bad data

ctls    equ     'S'             ;^S
ctlc    equ     'Q'             ;^C
ctlp    equ     'P'             ;^P
spray     equ   $1801000018020000

_hz_200 equ     $4ba            ; location for clock value

*----- Tunable:
*PrairieTek 120 (21.4 mbytes)
*2 surfaces, 615 tracks/surface , 34 blocks/track, and 512 bytes/block

;long_t_o                equ     450000          ; long-timeout (3 S)
;RWS.TPEX long_t_o                equ     850000          ; long-timeout (3 S)
long_t_o                equ     1850000          ; long-timeout (3 S)
short_t_o               equ     15000           ; short-timeout (100 mS)
errmax  equ     32
e_per_sid equ   8
maxsct  equ     68*615   ;old 612
maxcyl  equ     500      ;old 611
bytblk  equ     68*512   ;bytes/cylinder
last_sct equ    maxsct-1

***
*Standard AT hard disk interface
***
; Edit History
;
; Sep-05-90     ml.     Definitions of constants for the AT disk interface
;                       (wrt PrairieTek 120 drive.)

; Command codes

RECAL           equ     $10             ; Recalibrate
READ            equ     $21             ; Read Sector(s)
WRITE           equ     $31             ; Write Sector(s)
VERIFY          equ     $40             ; Read Verify Sector(s)
FMTTRK          equ     $50             ; Format Track
SEEK            equ     $70             ; Seek
DIAG            equ     $90             ; Execute Drive Diagnostic
INITPARM        equ     $91             ; Initialize Drive Parameters
RSBUF           equ     $e4             ; Read Sector Buffer
WSBUF           equ     $e8             ; Write Sector Buffer
IDENTIFY        equ     $ec             ; Identify Drive
                                        ; Standby Commands
STANDBY         equ     $e0             ; go to STANDBY mode
ACTIVE          equ     $e1             ; go to ACTIVE mode
SBWTO           equ     $e2             ; StandBy mode With Time-Out
AWTO            equ     $e3             ; Active mode With Time-Out
SSC             equ     $e5             ; Set Sector Count wrt current mode
SBRES           equ     $e6             ; StandBy until RESet


; Command Modifiers

NO_RETRIES      equ     $01             ; no retries
LCMD            equ     $02             ; long command



; Time-outs
D_WORST         equ     2000            ; worst case delay (10s)


; AT I/O locations for Read functions
REGBASE equ     1
bAT     equ     $FFF00000+REGBASE       ; base address
REGLSTEP  equ   4

ATDR    equ     bAT-REGBASE+($00*REGLSTEP); Data Register (16-bit reg)
ATER    equ     bAT+($01*REGLSTEP)      ; Error Register
ATSC    equ     bAT+($02*REGLSTEP)      ; Sector Count
ATSN    equ     bAT+($03*REGLSTEP)      ; Sector Number
ATCL    equ     bAT+($04*REGLSTEP)      ; Cylinder Low
ATCH    equ     bAT+($05*REGLSTEP)      ; Cylinder High (2 bits)
ATSDH   equ     bAT+($06*REGLSTEP)      ; SDH register
ATSR    equ     bAT+($07*REGLSTEP)      ; Status Register
ATASR   equ     bAT+($0E*REGLSTEP)      ; Alternate Status Register
ATDAR   equ     bAT+($0F*REGLSTEP)      ; Drive Address Register

; AT disk I/O locations for Write functions

;ATDR   equ     bAT-REGBASE+($00*REGLSTEP); Data Register (16-bit reg)
;ATWPR   equ     bAT+($01*REGLSTEP)     ; Write Precomp Register (not used)
;ATSC   equ     bAT+($02*REGLSTEP)      ; Sector Count
;ATSN   equ     bAT+($03*REGLSTEP)      ; Sector Number
;ATCL   equ     bAT+($04*REGLSTEP)      ; Cylinder Low
;ATCH   equ     bAT+($05*REGLSTEP)      ; Cylinder High (2 bits)
;ATSDH  equ     bAT+($06*REGLSTEP)      ; SDH register
ATCR    equ     bAT+($07*REGLSTEP)      ; Command Register
ATDOR   equ     bAT+($0E*REGLSTEP)      ; Digital Output Register

; Bit assignments in Error Register

BBK             equ     7               ; 1: bad block detected
UNC             equ     6               ; 1: non-correctable data error
;               equ     5               ; not used
IDNF            equ     4               ; 1: requested ID not found
;               equ     3               ; not used
ABRT            equ     2               ; 1: aborted command error
TK0             equ     1               ; 1: track 0 not found error
DMNF            equ     0               ; 1: data mark not found

; Bit assignments in Status Register

BSY             equ     7               ; 1: drive busy
DRDY            equ     6               ; 1: drive ready
DWF             equ     5               ; 1: write fault detected
DSC             equ     4               ; 1: actuator on track
DRQ             equ     3               ; 1: ready to transfer
CORR            equ     2               ; 1: data error corrected
IDX             equ     1               ; 1: disk revolution completed
ERR             equ     0               ; 1: error occurred

; Byte indices into buffer return by the Identify command

NCYL    equ     2               ; Number of fixed cylinders
NHEAD   equ     6               ; Number of heads
NSPT    equ     12              ; Number of physical sectors/track

**********************************

        .text
hddtst:
;        bsr     _diag           ;do on board diag.
;        move.b  ATER,d1         ;get diag status
;        cmp.b   #1,d1           ;chk if ok
;        beq     startk1         ;bra if no problem
;        lea     dstatm,a5
;        bsr     dspmsg
;        move.b  ATER,d1
;        bsr     dspbyt          ;display problem
;        bsr     crlf
;        move    #red,palette

startk1:
        bsr     reset_ide
        move.l  #bad_lst,bad_lste       ;terminate bad sector list

        tst.b   ProdTestStat            ;check for FS or Production
        bpl     starty0                 ;skip menu if production

        lea     hddmsg,a5
        bsr     dspmsg
        lea     hit_key,a5
        bsr     dspmsg
startk: bsr     conin
*~
 bsr clearsc
 bsr crlf
*~
        cmp.b   #esc,d0
        beq     go_tos
        cmp.b   #'S',d0
        beq.s   starty
        cmp.b   #'*',d0
        beq.s   fm_unit                 ;format disk?
        cmp.b   #'D',d0                 ;diagnostics?
        bne.s    startk
        bsr     diag_hd
        bra.s   startk

fm_unit:
        bsr     _fmtunt
        tst.b   d0
        beq.s   startk
        move    #red,palette
        bra.s   startk

starty0:
        RTCCLEARPASS #t_IDE     ;clear rtc flag
        movea.l #idemsg,a5
        bsr     dsptst

starty:; bsr     clearsc
;        bsr     crlf

*       Clear 1772 if it needs it
clrint: btst    #5,mfp+gpip
        bne     wrts1
        bsr     reset1770       ;if int, clear 1772
        bra     clrint

wrts1:  move.l  cycle,temp      ;store caller's cycle count
        clr     cycle
        clr     errsid0
        clr     errsid1
        clr     errsid2
        clr     errsid3

          move.l    #spray,spray_beg    ;set over/under flow data
          move.l    #spray,spray_mid
          move.l    #spray,spray_end

*       read and save data
        move.w  #600,cylndr     ;starting cylinder
        move.b  #1,sector
        move.b  #68,block       ;# of sectors
        move.b  sector,s_sct    ;set start sector
        move.b  #$a0,hdev       ;device #
        move.l  #savbuf,hbuf    ;buffer location
        move.b  block,hcnt      ;# of sectors
        move.b  s_sct,hsct      ;sector number

        bsr     at_read
        tst     d0
        beq.s   nxtcycl0

        bsr     conin
        bra     hddtst

*********************************
*       Repeat until esc key - 10 cycles if in production testing

nxtcycl:
        cmp     #10,cycle
        bne     nxtcycl0
        tst.b   ProdTestStat            ;check for FS or Production
        bmi     nxtcycl0
        bsr     res600          ;restore cylinder
        RTCSETPASS #t_IDE       ;IDE pass flag
        bra     go_tos

nxtcycl0:
        add     #1,cycle
        move    #600,cylndr
        move.b  #1,sector

*********************************
*       writeablock (1 cylinder)
nxtwr:  lea     wrcylm,a5
        bsr     dspcyl1
        bsr     filhbuf         ;fill write buffer for comparison
        move.b  #68,block       ;# of sectors
        move.b  sector,s_sct    ;set start sector
        move.b  #$a0,hdev       ;device #
        move.l  #hwrbuf,hbuf    ;buffer location

wrscts: move.b  block,hcnt      ;# of sectors
        move.b  s_sct,hsct      ;sector number
        bsr     at_write
        tst     d0
        beq     wrok

*       Display write error
        lea     wcylerr,a5
        bsr     dspmsg          ;Bad write sector:
        clr.l   d0
        move.b  ATSN,d0          ;get failed sector
        bsr     cnvdec
        bsr     dspbyts
        bsr     dsphead
        bsr     dspcyc          ;cycle: xxxx
        move    #red,palette
        bsr     conin
        cmp.b   #esc,d0
        beq     seekey1

*       Clear read buffer 
wrok:
        move.l  #hrdbuf,a0
        move.l  #512*68-1,d1
        moveq   #0,d0
contw0: move.b  d0,(a0)+
        dbra    d1,contw0
 
*       Read a block (1 cylinder)
nxtrd:  lea     rdcylm,a5
        bsr     dspcyl
        move.b  #68,block       ;# of sectors
        move.b  sector,s_sct    ;set start sector
        move.b  #$a0,hdev         ;device #
        move.l  #hrdbuf,hbuf    ;buffer location

*       Read a block or part of a block if after error
rdscts: move.b  block,hcnt      ;# of sectors
        move.b  s_sct,hsct      ;sector number
        bsr     at_read
        tst     d0
        beq     rdok

*       Display read data message
        lea     sectorm,a5
        bsr     dspmsg          ;Bad read sector:
        clr.l   d0
        move.b  ATSN,d0          ;get failed sector
        bsr     cnvdec
        bsr     dspbyts
        bsr     dsphead
        bsr     dspcyc          ;cycle: xxxx
        move    #red,palette

*       No error from controller, now verify data
rdok:

*       Compare data buffers
        move.l  #hwrbuf,a0
        move.l  #hrdbuf,a1

        move.l  #67,d6          ;compare 68 sectors
cmpsct: move.l  #255,d7         ;compare a sector
cmpsc0: cmp.w   (a0)+,(a1)+
        beq     datcpn          ;br if ok

*       display bad data and offset
        movem.l d6-d7/a0-a1,-(sp)
        lea     datcmpm,a5
        bsr     dspmsg
        suba    #2,a0
        suba    #2,a1
        move    (a0),d1
        bsr     dspwrd          ;write buffer
        bsr     dspspc
        move    (a1),d1
        bsr     dspwrd          ;read buffer
        bsr     dspspc
        move.l  a1,d1           ;get address
        sub.l   #hrdbuf,d1      ;less start
        bsr     dspwrd          ;display buffer offset
        bsr     dspspc
        bsr     dspcyc
        move    #red,palette
*       bsr     crlf
        bsr     hpause
                
datcpf: movem.l (sp)+,d6-d7/a0-a1
        cmpi.b  #cr,d0
        beq.s   datcpn          ;if return, continue
        move    d0,-(sp)
        bsr     res600          ;else restore cylinder and do control key
        move    (sp)+,d0
        bra     ctlkey

datcpn: dbra    d7,cmpsc0
        dbra    d6,cmpsct

*       data compared, now check for spray
        cmp.l   #spray,spray_beg
        bne.s   spray_err
        cmp.l   #spray,spray_mid
        bne.s   spray_err
        cmp.l   #spray,spray_end
        beq.s   hrdkey
spray_err:
        move    #red,palette
        lea     spray_bad,a5
        bsr     dspmsg

*       completed a cycle
hrdkey: bsr     constat         ;check for key on completion of cycle
        tst     d0
        beq     contr           ;no key, continue with next cycle

        bsr     res600          ;restore cylinder

seekey: bsr     conin           ;got a key, see if ESC key
        cmp.b   #esc,d0
        bne     hrdkey
seekey1:
        bsr     hpause
ctlkey: cmp.b   #'S',d0
        beq     hddtst          ;restart
        cmp.b   #esc,d0
        beq     go_tos          ;go to tos - back to menu

*       No error this cycle, get ready for next cycle
contr:  bra     nxtcycl


*
********END*****
*

*
***** subs
*

*      display stop message and wait for next key
*      exit: d0=key
hpause:   lea  hpausem,a5
          bsr  dspmsg
hpause0:  bsr  conin
          cmp.b   #'S',d0
          beq     clnline
          cmp.b   #esc,d0
          beq     clnline
          cmp.b   #cr,d0 
          bne.s   hpause0

* erase line
clnline:
        move.b  d0,-(sp)        ;save key
        move    v_cur_cy,d1     ;this line
        clr     d0              ;beginning of line
        bsr     move_cursor
        bsr     escK            ;erase to end of line
        move.b  (sp)+,d0
        rts

*-----------------------
*       write saved data
res600: move    #600,cylndr
        move.b  #$a0,hdev         ;device #
        move.l  #savbuf,hbuf    ;buffer location
        move.b  #68,hcnt        ;# of sectors
        move.b  #1,hsct         ;sector number
        bsr     at_write
        tst     d0
        bpl     res600x
        lea     badsav,a5
        bsr     dspmsg
res600x:
        rts

*-------------------------------

go_tos: move.l  temp,cycle         ; restore cycle of caller
        bset    #autoky,consol
        rts

***********************************************************************
*       SUBROUTINES
* run disk diagnostics and display results

diag_hd:
        bsr     _diag           ;do diag.
        lea     dstatm,a5
        bsr     dspmsg
        move.b  ATER,d1         ;get diag status
        cmp.b   #1,d1           ;chk if ok
        beq     diag_hd1        ;bra if no problem
        move    #red,palette

diag_hd1:
        bsr     dspbyt          ;display
        bsr     crlf
        bsr     reset_ide
        rts

* diag() - performs the internal diagnostic tests implemented by 
*          the drive.

_diag:  lea     intdiag,a5
        bsr     dspmsg
        bsr     reset_ide
        move.b  #0,ATDOR        ; enable interrupt
        move.b  #DIAG,ATCR      ; set command code
        bra     w4int

*--------------------------------
* reset
reset_ide:
        move    sr,-(sp)        ; save our IPL
        or      #$0700,sr       ; start critical section
        move.b  #giporta,psgsel ; select port on GI chip
        move.b  psgrd,d1        ; get current bits
        or.b    #$80,d1         ; or-in our new bit
        move.b  d1,psgwr        ; and write 'em back out there
        bsr     wait100
        andi.b  #$7f,d1
        move.b  d1,psgwr
        move    (sp)+,sr        ; restore IPL to terminate CS, return
        bsr     wait400
        rts

*--------------------------------
*       calculate the side number
*       divide by 17, then take result mod 4
*       Entry:  d0.l=sector
*       Exit:   d0.l=side # offset (0,2,4,6)
get_side:
        add.l   #17,d0          ;add 17, don't worry about <17
        divu    #17,d0          ;divide by 17
        andi.l  #$ffff,d0       ;discard remainder
        cmp.l   #3,d0
        ble     mod17           ;got answer
        divu    #4,d0           ;divide by 4
        swap    d0              ;and take remainder
        andi.l  #$f,d0          ;its 0-3
mod17:  lsl     #1,d0           ;make it a word offset
        rts

*--------------------------------
getdma: clr.l   tmpdma
        move.b  dmahigh,tmpdma+1 ;get pointer to data
        move.b  dmamid,tmpdma+2
        move.b  dmalow,tmpdma+3
        rts

*-------------------------------
*       Fill write buffer (68 sectors)
filhbuf:
        lea     hwrbuf,a0
        lea     hwrbuf,a1
        lea     datpat,a2
        move    cycle,d6
        andi    #7,d6
        lsl     #2,d6
        sub     #4,d6
        move.l  0(a2,d6),d0     ;get data
        moveq   #0,d2
        move.b  sector,d2       ;sector

*       Loop for 68 sectors
nxtwb:  adda.l  #512,a1
        move    cycle,(a0)+     ;1st word=cycle count
        move    d2,(a0)+        ;2nd word=sector number
nxtwb0: move.l  d0,(a0)+        ;subsequent words=worst case, shift on each pass
        cmpa.l  a0,a1
        bgt     nxtwb0
        add     #1,d2           ;next sector
        cmpa.l  #hwrbuf+(512*68),a1
        blt     nxtwb
        rts

datpat: dc.l    $ff00aa55
        dc.l    $99ee66dd
        dc.l    $a56bffee
        dc.l    $a5a5a5a5
        dc.l    $11223344
        dc.l    $55667788
        dc.l    $0f0f0f0f
        dc.l    $fedcba98

*-------------------------------
*       Check for previous occurence; record if it is new bad sector
*       Entry:  bad sector=s_sct-1
*               bad_lste=end of list
*       Exit:   eq if not new, ne if new bad sector
*               bad_lste = next (empty) location
*       Uses:   a2,d0
hchkbad:
        move.b  s_sct,d0        ;get next sector
        sub.b   #1,d0           ;bad sector is previous one
        lea     bad_lst,a2
hckbd0: cmpa.l  bad_lste,a2     ;scan list for this sector
        beq     chkbd1          ;at end, not recorded
        cmp.l   (a2)+,d0        ;already in list?
        beq     hckbd2          ;already recorded this, ret eq
        bra     hckbd0

hckbd1: move.l  d0,(a2)+        ;save bad sector
        move.l  a2,bad_lste     ;save end
        andi    #$1b,ccr        ;ret ne
hckbd2: rts


* LONG _qdone() - Wait for command byte handshake
* LONG _fdone() - Wait for operation complete
* Passed:       nothing
*
* Returns:      EQ: no timeout
*               MI: timeout condition
*
* Uses:         D0,D1
*
* each pass through the loop takes 6.75 uS
*-

*       Wait for command completion
_fdone: move.l  #long_t_o,tocount
        move    d1,-(sp)
        move    #1,d1
        bra     qd1

*       Wait for command byte handshake
_qdone:
        move.l  #short_t_o,tocount
        move    d1,-(sp)
        move    #0,d1

qd1:    subq.l  #1,tocount              ; dec timeout count
        bmi     qdq                     ; (i give up, return NE)
        move.b  mfp+gpip,d0             ; interrupt?
        and.b   #$20,d0
        bne     qd1                     ; (not yet)

;        lea     ok_msg,a5
;        bsr     dspmsg
        move    (sp)+,d1
        moveq   #0,d0                   ; return EQ (no timeout)
        rts

*       Timeout, display message, return minus
qdq:    lea     notrspdm,a5     ; controller not responding
        tst     d1
        beq     qdq0
        lea     ltmsg,a5
qdq0:   bsr     dspmsg          ;short t-o=no handshake, long=no completion

        move    (sp)+,d1
        moveq   #-1,d0
        rts

*------------------------------------
*       delay
viewscr:
        move.l  _hz_200,d7
        addi    #100,d7
viewt:  cmp.l   _hz_200,d7
        bne     viewt
        rts

*------------------------------------
*       Display cycle on current line
*       uses:   d0,d1,d2,d3 (cnvdec)
dspcyc: lea     cyclmsg,a5
        bsr     dspmsg
        move    cycle,d0
        bsr     cnvdec
        bsr     dspwrd
        bsr     crlf
        rts

*-------------------------------------
*       Display head # on current line
dsphead:
        lea     headmsg,a5
        bsr     dspmsg
        move.b  ATSDH,d1
        and     #$f,d1
        bsr     dspbyts
        rts

*------------------------
*       Display cylinder number on line 0
*       Display cycle count too
*       Entry:  a5=message (read cylinder)
dspcyl: bsr     escjs           ;save cursor
        moveq   #0,d0           ;row
        moveq   #0,d1           ;col
        bsr     move_cursor
        bsr     dspmsg
        move    cylndr,d0       ;cylinder
        bsr     cnvdec
        bsr     dspwrd          ;number
        lea     hescmsg,a5      ;escape msg
        bsr     dspmsg
        bsr     dspcyc          ;display cycle count

        bsr     escks           ;restore cursor
        rts

*------------------------
*       Display cylinder number on line 0
*       Display cycle count too
*       Entry:  a5=message (write cylinder)
dspcyl1: bsr     escjs           ;save cursor
        moveq   #0,d0           ;row
        moveq   #0,d1           ;col
        bsr     move_cursor

        bsr     dspmsg
        move    cylndr,d0       ;cylinder
        bsr     cnvdec
        bsr     dspwrd          ;number
        lea     hescmsg,a5      ;escape msg
        bsr     dspmsg

        bsr     escks           ;restore cursor
        rts


*------------------------

*minna's at driver
*****************************
;+
; Edit History
;
; Sep-05-90     ml.     Created this for drives on the AT bus.
;
; Mar-28-91     ml.     Do not use the IDE Sector Count Register 
;                       to count down mulitiple sectors read or
;                       write.  Some vendors (e.g. Conner and 
;                       Seagate) seem to update this register 
;                       too early, and every now and then, the
;                       last sector of data would remain in the
;                       internal sector buffer.  
;                       
;                       Code in atread() and atwrite() are modified
;                       not to use the IDE Sector Count Register.
;-

;+
; Wait for status to come back
; if timeout - return minus in d0
; if drq     - return 1 in d0 bit 3
; if ok      - return 0 in d0
; else d0 = error register
;-
w4int:  bsr      _fdone
        bmi.s    .3

        move.b  ATSR,d0         ; d0.b = status returned
        btst    #ERR,d0         ; any error?
        bne.s   .2              ; if yes, return error code
        btst    #DRQ,d0         ; else DRQ?
        bne.s   .3              ; if so, just return
        moveq   #0,d0           ; else return OK
        bra.s   .3
.2:     move.w  d0,-(sp)        ;save status
        lea     rdstatm,a5
        bsr     dspmsg

*       display status
        move.w  (sp),d1         ;get status
        bsr     dspbyt          ;display
        bsr     dspspc
        move.b  ATER,d1         ;get error
        bsr     dspbyt          ;display
        bsr     dspspc
        bsr     dspcyc          ;cycle: xxxx

        move.w  (sp)+,d0
.3:     rts                     ; return status

; atread() - reads from 1 to 256 sectors as specified in the Task File,
;               beginning at the specified sector.
;          - sector count equal to 0 requests 256 sectors.
; Comments:
;       The unit is assumed to be in native mode when conversion from
; logical block address to physical address is done.
;
; atread(nhd, nspt, sectnum, count, buf, pdev)
; WORD  nhd;            4(sp).w         ; # of data heads on pdev
; WORD  nspt;           6(sp).w         ; # of physical sectors per track
; LONG  sectnum;        8(sp).l         ; logical block address
; WORD  count;          $c(sp).w        ; # of sectors to read
; BYTE  *buf;           $e(sp).l        ; $f(sp)=high $10(sp)=mid $11(sp)=low
; WORD  pdev;           $12(sp).w       ; physical device number

*mey version of read disk
* returns      -1 on timeout
*               0 on success
*               nonzero on error
*

at_read:
        move.w  cylndr,d1       ; cylinder #
        move.b  d1,ATCL         ; set cylinder low
        lsr.w   #8,d1
        move.b  d1,ATCH         ; set cylinder high
        move.b  #$a0,ATSDH        ; set master drive and head one
        move.b  hsct,ATSN       ; start sector on this cylinder
        move.l  hbuf,a0         ; a0 -> buffer to read into

bra.s  .20

move.l  #ATSC,a0
move.b  #1,d0
.10:     move.b d0,(a0)
        move.b (a0),d1
        bra.s  .10

.20:
        move.b  hcnt,ATSC       ; set sector count

        clr.w   d1
        move.b  hcnt,d1         ; d1.w = # of sectors to read
        subq    #1,d1           ; dbra likes one less

.0:     move.b  #0,ATDOR        ; enable interrupt
        move.b  #READ,ATCR      ; send command code
.1:     move    d1,-(sp)
        bsr     w4int           ; wait for interrupt
        tst     d0
        bmi.s   .2              ; if timed-out, return
        btst    #ERR,d0         ; ERROR?
        bne.s   .2              ; if yes, return
        btst    #DRQ,d0         ; DRQ?
        beq.s   .2              ; if no more, return

        move.l  hbuf,a0         ; a0 -> buffer to read into
        bsr     readbuf         ; transfer data
        move.l  a0,hbuf         ; save updated pointer
        move    (sp)+,d1
        dbra    d1,.1           ; go wait for next interrupt
        moveq   #0,d0           ; no error
        rts

.2:     move    (sp)+,d1 
        cmp     #10,errsid0     ; max errors?
        beq.s   .3
        add     #1,errsid0      ; no!
        lea     sectorm,a5
        bsr     dspmsg          ;Bad read sector:
        clr.l   d0
        move.b  ATSN,d0          ;get failed sector
        bsr     cnvdec
        bsr     dspwrd
        bsr     dsphead         ;get head
        bsr     dspcyc          ;cycle: xxxx
        move    #red,palette
        move.l  #hrdbuf,hbuf
        bra     at_read         ; try to read 68 sector block again

.3:     clr     errsid0
        rts


; atwrite() - writes from 1 to 256 sectors as specified in the Task File,
;               beginning at the specified sector.
;           - sector count equal to 0 requests 256 sectors.
;
; Comments:
;       The unit is assumed to be in native mode when conversion from
; logical block address to physical address is done.
;
; atwrite(nhd, nspt, sectnum, count, buf, pdev)
; WORD  nhd;            4(sp).w         ; # of data heads on pdev
; WORD  nspt;           6(sp).w         ; # of physical sectors per track
; LONG  sectnum;        8(sp).l         ; logical block address
; WORD  count;          $c(sp).w        ; # sectors to read
; BYTE  *buf;           $e(sp).l        ; $f(sp)=high $10(sp)=mid $11(sp)=low
; WORD  pdev;           $12(sp).w       ; physical device number

at_write:       
        move.w  cylndr,d1       ; cylinder #
        move.b  d1,ATCL         ; set cylinder low
        lsr.w   #8,d1
        move.b  d1,ATCH         ; set cylinder high
        move.b  #$a0,ATSDH        ; set master drive and head one
        move.b  hsct,ATSN       ; start sector on this cylinder
        move.l  hbuf,a0         ; a0 -> buffer to read into
        move.b  hcnt,ATSC       ; set sector count

        clr.w   d1
        move.b  hcnt,d1         ; d1.w = # of sectors to read
        subq    #1,d1           ; dbra likes one less

.0:     move.b  #0,ATDOR        ; enable interrupt
        move.b  #WRITE,ATCR     ; set command code
.1:     
        btst.b  #DRQ,ATASR      ; DRQ?
        beq.s   .1              ; if not, wait longer

.2:     move    d1,-(sp)
        move.l  hbuf,a0         ; a0 -> write buffer ptr
        bsr     wrtbuf          ; transfer data
        move.l  a0,hbuf         ; save updated pointer
        bsr     w4int           ; wait for interrupt
        tst.w   d0
        bmi.s   .3              ; if timed-out, return
        btst    #DRQ,d0         ; DRQ?
        beq.s   .3              ; if not, return
        move    (sp)+,d1
        dbra    d1,.2           ; else go transfer data
        moveq   #0,d0           ; everything's fine
        rts

.3:     move    (sp)+,d1
        rts 
; set_dhcs() - convert a logical block address into a physical address.
;            - set drive #, head #, cylinder # and sector # in task file.
;
; Passed:
;       8(sp).w = nhd = # of data heads
;       $a(sp).w = nspt = # of physical sectors per track
;       $c(sp).l = logical block address
;       $16(sp).w = physical unit #
set_dhcs:
        move.l  $c(sp),d1       ; d1.l = logical block address
        move.w  8(sp),d2        ; d2.w = # of data heads
        move.w  $a(sp),d0       ; d0.w = # of physical sectors per track
        mulu    d0,d2           ; d2.l = # of sectors per cylinder
                                ;      = # heads * # of sectors per track
        divu.w  d2,d1           ; d1.w = cylinder #
                                ;      = log block addr / #spc
        move.b  d1,ATCL         ; set cylinder low
        lsr.l   #8,d1           ; d1.b = cylinder high
        move.b  d1,ATCH         ; set cylinder high
        lsr.l   #8,d1           ; d1.l = sector # within the cyl
        divu.w  d0,d1           ; d1.w = head #
                                ;      = sector # within cyl / #spt
        move.w  $16(sp),d0      ; d0.w = physical unit #
        andi.b  #7,d0           ; mask off flags from physical unit #
        lsl.b   #4,d0           ; shift unit # to place
        or.b    d0,d1           ; or in drive #
        move.b  d1,ATSDH        ; set drive and head #
        swap    d1              ; d1.w = sector # (base 0)
        addq.w  #1,d1           ;      = sector # + 1 (base 1)
        move.b  d1,ATSN         ; set sector #
        rts

; initparm() - enables the host to set the head switch and cylinder
;              increment points for multiple sector operations.
;
; initparm(pdev, head, spt)
; WORD  pdev;   4(sp).w
; WORD  head;   6(sp).w
; WORD  spt;    8(sp).w
_initparm:
        move.w  4(sp),d0        ; d0 = physical unit #
        andi.b  #7,d0           ; mask off flags
        lsl.w   #4,d0           ; shift it into place
        move.b  d0,ATSDH        ; set physical unit #
        move.w  6(sp),d0        ; d0 = # of heads
        subq.b  #1,d0           ; maximum head #
        or.b    d0,ATSDH        ; set head #
        move.b  8(sp),ATSC      ; set sectors per track
        move.b  #0,ATDOR        ; enable interrupt
        move.b  #INITPARM,ATCR  ; set command code
        bra     w4int           ; go wait for interrupt

; identify() - allows the Host to receive parameter information from
;              the drive.
;
; identify(pdev, buf)
; WORD  pdev;   4(sp).w         ; physical unit #
; BYTE  *buf;   6(sp).l         ; buffer to put data

_identify:
        move.w  4(sp),d0        ; d0 = physical unit #
        andi.b  #7,d0           ; mask off flags (if any)
        lsl.b   #4,d0           ; shift unit # to place
        move.b  d0,ATSDH        ; set drive #
        move.l  6(sp),a0        ; a0 -> buffer

        btst    #bltbit,mega    ;  BLiTTER exists?
        beq.s   .0              ; if not, don't use it
        move    d1,-(sp)
        bsr     initblit        ; initialize the BLiTTER
        move    (sp)+,d1

.0:     move.b  #0,ATDOR        ; enable interrupt
        move.b  #IDENTIFY,ATCR  ; set command code
        bsr     w4int           ; wait for interrupt
        tst.w   d0              ; successful?
        bmi.s   .1              ; if timed-out, return
        btst    #DRQ,d0         ; DRQ?
        beq.s   .1              ; if not, return with error

        bsr     readbuf         ; read data
        moveq   #0,d0           ; return successful
.1:     rts 


; awto() - set drive to Active mode with timeout counter (in 5s increments)
;
; awto(pdev, timeout)
; WORD  pdev;           4(sp).w         ; physical unit #
; WORD  timeout;        6(sp).w

_awto:  
        move.w  4(sp),d0        ; d0 = physical unit #
        andi.b  #7,d0           ; mask off flags (if any)
        lsl.b   #4,d0           ; shift unit # to place

        clr.b   d0
        move.b  d0,ATSDH        ; set drive #
;        move.b  7(sp),ATSC      ; set timeout counter

        move.b  #5,ATSC

        move.b  #AWTO,ATCR      ; set command code
        bra     w4int           ; go wait for interrupt

; slave() - test if the slave drive exists
;
; Returns: 0 - if slave does not exist
;          1 - if slave exists

_slave: moveq   #0,d0           ; assume slave does NOT exist
        bset.b  #4,ATSDH        ; set drive bit to 1 (slave)
        btst.b  #DRDY,ATSR      ; is slave ready?
        beq.s   .0              ; if not, no slave
        moveq   #1,d0           ; else, slave exists
.0:     rts

; readbuf() - reads 512 bytes (128 longs) of data from the sector
;               buffer.
;
; Passed:
;       a0.l = buffer to store data read from sector buffer
;
;       if BLiTTER code
;       a1.l = base address of BLiTTER

readbuf:
                                ; Programmed IO
.0:     moveq   #127,d0         ; d0 = # of longs to read - 1
        lea     ATDR,a1         ; a1 -> data bus
.1:     move.l  (a1),(a0)+      ; read data from bus
        dbra    d0,.1           ; repeat until all done
        rts

; wrtbuf() - writes 512 bytes (128 longs) of data to sector buffer.
;
; Passed:
;       d0.w = number of words of data to write
;       a0.l = buffer with data to write to sector buffer

wrtbuf:
                                ; Programmed IO
.0:     moveq   #127,d0         ; d0 = # longs to write - 1
        lea     ATDR,a1         ; a1 -> data bus
.1:     move.l  (a0)+,(a1)      ; write data to bus
        dbra    d0,.1           ;  repeat until all done
        rts


; initblit() - initialize the BLiTTER chip for 512 bytes I/O transfer
;
; Passed:
;       a0.l = destination address if read; source address if write
;       d0.w = flag to tell whether it's a read or a write

initblit:
        lea     blt,a1             ; a1 -> BLiTTER register map
        tst.b   d0                      ; read or write?
        bne.s   ib0                     ; (write)
        move.l  #ATDR,b_sadd(a1)       ; source addr = AT data register
        move.l  a0,b_dadd(a1)         ; destination addr = given buffer
        move.w  #2,b_dnxwd(a1)         ; words read
        moveq   #0,d0
        move.w  d0,b_snxwd(a1)          ; never increment source X
        bra.s   ib1
                                        ; initialize BLiTTER to write to disk
ib0:    move.l  a0,b_sadd(a1)          ; source addr = write buffer
        move.l  #ATDR,b_dadd(a1)      ; destination addr = AT data register
        move.w  #2,b_snxwd(a1)          ; words write
        moveq   #0,d0
        move.w  d0,b_dnxwd(a1)         ; never increment destination X

ib1:    move.w  d0,b_swrap(a1)          ; never increment source Y
        move.w  d0,b_dwrap(a1)         ; never increment destination Y
        move.b  d0,b_skew(a1)             ; no skew
        moveq   #$ff,d0
        move.l  d0,b_f1msk(a1)         ; change all bits at destination
        move.w  d0,b_f2msk(a1)         ; change all bits at destination
        move.w  #$203,b_hop(a1)           ; set b_hop and b_op to source
        move.w  #256,b_dspan(a1)           ; num of words to transfer
        rts

; restart() - restart the BLiTTER
;
; Passed:
;       a1.l = base address of BLiTTER

restart:
        nop
        tas     b_line(a1)        ; restart BLiTTER and test if busy
        bmi.s   restart         ; quit if not busy
        rts

; clrsbuf() - clear the scratch buffer

clrsbuf:
        movem.l d0/a0,-(sp)     ; save d0 and a0
        lea     savbuf,a0         ; a0 -> scratch buffer
        move.w  #127,d0         ; d0 = counter
.0:     clr.l   (a0)+           ; clear 4 bytes
        dbra    d0,.0           ; repeat until done
        movem.l (sp)+,d0/a0     ; restore d0 and a0
        rts

; recal() - moves the R/W heads from anywhere on the disk to cylinder 0.
;
; recal(pdev)
; WORD  pdev;   $4(sp).w

_recal: move.w  4(sp),d0        ; d0 = physical unit #
        andi.b  #7,d0           ; mask off flags (if any)
        lsl.b   #4,d0           ; shift unit # to place
        move.b  d0,ATSDH        ; write drive #
        move.b  #0,ATDOR        ; enable interrupt
        move.b  #RECAL,ATCR     ; write command code
        bra     w4int           ; go wait for interrupt

; verify() - functions similarly to read() except that no data is
;            transferred to the host.

_verify:
        move.w  $e(sp),d0       ; d0.w = physical unit #
        move.l  4(sp),d1        ; d1.l = starting logical sector #
        bsr     set_dhcs        ; set drive#, head#, cylinder# and sector#
        move.l  $a(sp),a0       ; a0 -> buffer to write from
        move.b  9(sp),ATSC      ; set sector count
        move.b  #0,ATDOR        ; enable interrupt
        move.b  #VERIFY,ATCR    ; set command code
.0:     bsr     w4int           ; wait for interrupt
        bne.s   .1              ; if has error, return
        tst.b   ATSC            ; more to verify?
        bne.s   .0              ; if so, continue
        moveq   #0,d0           ; everything's fine
.1:     rts

; fmtunt() - formats a unit
;          - always formats sectors as good ones.
;          - interleave 1:1.
;
; fmtunt(pdev)
; WORD  pdev;   4(sp).w

_fmtunt:
        move.l  #0,-(sp)        ; set physical unit # to 0
        pea     savbuf            ; scratch buffer
        move.w  $8(sp),-(sp)    ; physical unit #
        bsr     _identify       ; identify(pdev, buf)
        addq.w  #6,sp           ; clean up stack
        tst.w   d0              ; successful?
        bne     .4              ; if not, return
                                ; else make sure we are in native mode
        lea     savbuf,a1         ; a1 -> savbuf
        move.w  NSPT(a1),-(sp)  ; # of sectors per track
        move.w  NHEAD(a1),-(sp) ; # of heads
        move.w  8(sp),-(sp)     ; physcial unit #
        bsr     _initparm       ; initparm(pdev, head, spt)
        addq.w  #6,sp           ; clean up stack
        tst.w   d0              ; successful?
        bne     .4              ; if not, return
                                ; else get drive parameters
        lea     savbuf,a1         ; a1 -> savbuf
        move.w  NCYL(a1),d0     ; d0.w = # of cylinders
        move.w  NHEAD(a1),d1    ; d1.w = # of heads
        move.w  NSPT(a1),d2     ; d2.w = # of sectors per track
                                ; fill format data
        bsr     clrsbuf         ; clear scratch buffer
        move.l  d3,-(sp)        ; save d3
        moveq   #1,d3           ; d3 = sector # (starts with sector 1)
.0:     move.b  d3,(a1)+        ; set sector #
        clr.b   (a1)+           ; format sector good
        addq.b  #1,d3           ; next sector #
        cmp.b   d3,d2           ; all sector # set?
        bcc.s   .0              ; if not, continue
        move.l  (sp)+,d3        ; restore d3
                                ; format unit
        move.w  4(sp),d2        ; d2.w = physical unit #
        andi.b  #7,d2           ; mask off flags (if any)
        lsl.b   #4,d2           ; shift physical unit # into place
        move.b  d2,ATSDH        ; set physical unit #
        subq.w  #1,d0           ; dbra likes one less
        subq.w  #1,d1           ; dbra likes one less
        move.w  d1,d2           ; d2 = # heads - 1
.1:     move.w  d2,d1           ; reinitialize head number for next cylinder
.2:     movem.l d0-d2,-(sp)     ; save cylinder and head counts
        lea     savbuf,a0         ; a0 -> format data
        bsr     _fmttrk         ; format track of current cylinder and head
        beq.s   .3              ; if successful, continue
        adda.l  #12,sp          ; else clean up stack

        lea     err3_msg,a5
        bsr     dspmsg          ;Bad write sector:
        clr.l   d0
        move.b  ATSN,d0          ;get failed sector
        bsr     cnvdec
        bsr     dspbyts
        bsr     dsphead
        move    #red,palette
;        movem.l (sp)+,d0-d2     ; restore cylinder and head count
        move.b  #1,d0           ;flag error
        rts                     ; and return

.3:     movem.l (sp)+,d0-d2     ; restore cylinder and head counts
        dbra    d1,.2           ; for all heads
        dbra    d0,.1           ; for all cylinders
        moveq   #0,d0           ; everything's fine
.4:     addq.w  #6,sp           ; clean up stack

; fmttrk() - formats a track with format data provided.
;
; Passed:
;       d0.w = cylinder #
;       d1.w = head #
;       a0.l -> format data

_fmttrk:
        or.b    d1,ATSDH        ; set head #
        move.b  d0,ATCL         ; set cylinder low
        lsr.w   #8,d0           ; d0.b = cylinder high
        move.b  d0,ATCH         ; set cylinder high
        move.b  #0,ATDOR        ; enable interrupt
        move.w  #256,d1         ; d1.w = word count

        btst    #bltbit,mega    ;  BLiTTER exists?
        beq.s   .0              ; if not, don't use it
        move    d1,-(sp)
        bsr     initblit        ; initialize the BLiTTER
        move    (sp)+,d1

;        bsr     isblt           ;  BLiTTER exists?
;        bne.s     .0            ; if not, don't use it
;        moveq   #1,d0           ; it's a write
;        bsr     initblit        ; initialize the BLiTTER

.0:     move.b  #FMTTRK,ATCR    ; set command code
.1:     btst.b  #DRQ,ATASR      ; DRQ?
        beq.s   .1              ; if not, wait longer

        bsr     wrtbuf          ; write format data to sector buffer
        bra     w4int

; seek() - initiates a seek to the track and selects the head 
;          specified in the Task File.
;
; seek(pdev, head, cyl)
; WORD  pdev;   $4(sp).w
; WORD  head;   $6(sp).w
; WORD  cyl;    $8(sp).w

_seek:  move.w  4(sp),d0        ; d0 = physical unit #
        andi.b  #7,d0           ; mask off flags
        lsl.b   #4,d0           ; shift unit # to place
        or.b    7(sp),d0        ; b4 of d0 = drive #; b3-b0 of d0 = head #;
        move.b  d0,ATSDH        ; set drive and head #
        move.b  #0,ATDOR        ; enable interrupt
        move.b  9(sp),ATCL      ; set cylinder low
        move.b  8(sp),ATCH      ; set cylinder high
        move.b  #SEEK,ATCR      ; set command code
        bra     w4int           ; go wait for interrupt


; rsbuf() - allows the Host to read the current contents of the
;           drive's sector buffer.
;
; rsbuf(pdev, buf)
; WORD  pdev;   4(sp).w
; BYTE  *buf;   6(sp).l

_rsbuf: move.w  4(sp),d0        ; d0 = physical unit #
        andi.b  #7,d0           ; mask off flags (if any)
        lsl.w   #4,d0           ; shift it into place
        move.b  d0,ATSDH        ; set physical unit #
        move.l  6(sp),a0        ; a0 -> buffer
        move.w  #256,d1

        bsr     isblt           ;  BLiTTER exists?
        bne.s     .0            ; if not, don't use it
        moveq   #0,d0           ; it's a read
        bsr     initblit        ; initialize the BLiTTER

.0:     move.b  #0,ATDOR        ; enable interrupt
        move.b  #RSBUF,ATCR     ; set command code
        bsr     w4int           ; go wait for interrupt
        tst.w   d0              ; successful?
        bmi.s   .1              ; if timed-out, return
        btst    #DRQ,d0         ; DRQ?
        beq.s   .1              ; if not, return with error

        bsr     readbuf         ; read data
        moveq   #0,d0           ; return successful
.1:     rts 

; wsbuf() - allows the Host to overwrite the contents of the drive's
;           sector buffer.
;
; wsbuf(pdev, buf)
; WORD  pdev;   4(sp).w
; BYTE  *buf;   6(sp).l

_wsbuf: move.w  4(sp),d0        ; d0 = physical unit #
        andi.b  #7,d0           ; mask off flags (if any)
        lsl.w   #4,d0           ; shift it into place
        move.b  d0,ATSDH        ; set physical unit #
        move.l  6(sp),a0        ; a0 -> buffer
        move.w  #256,d0         ; d0 = word count

        bsr     isblt           ;  BLiTTER exists?
        bne.s     .0            ; if not, don't use it
        moveq   #0,d0           ; it's a read
        bsr     initblit        ; initialize the BLiTTER

.0:     move.b  #WSBUF,ATCR     ; set command code
.1:     btst    #DRQ,ATSR               ; DRQ?
        beq.s   .1              ; if not, wait some more

        bsr     wrtbuf          ; read data
        moveq   #0,d0           ; return successful
        rts 

; standby() - set drive to Standby mode
;
; standby(pdev)
; WORD  pdev;   4(sp).w         ; physical unit #

_standby:
        move.w  4(sp),d0        ; d0 = physical unit #
        andi.b  #7,d0           ; mask off flags (if any)
        lsl.b   #4,d0           ; shift unit # to place
        move.b  d0,ATSDH        ; set drive #
        move.b  #STANDBY,ATCR   ; set command code
        bra     w4int           ; go wait for interrupt

; active() - set drive to Active mode
;
; active(pdev)
; WORD  pdev;   4(sp).w         ; physical unit #

_active:
        move.w  4(sp),d0        ; d0 = physical unit #
        andi.b  #7,d0           ; mask off flags (if any)
        lsl.b   #4,d0           ; shift unit # to place

;        move.b  d0,ATSDH        ; set drive #
         move.b  #0,ATSDH        ; set drive #
        move.b  #ACTIVE,ATCR    ; set command code
        bra     w4int           ; go wait for interrupt

; sbwto() - set drive to Standby mode with timeout counter (in 5s increments)
;
; sbwto(pdev, timeout)
; WORD  pdev;           4(sp).w         ; physical unit #
; WORD  timeout;        6(sp).w

_sbwto: 
        move.w  4(sp),d0        ; d0 = physical unit #
        andi.b  #7,d0           ; mask off flags (if any)
        lsl.b   #4,d0           ; shift unit # to place
        move.b  d0,ATSDH        ; set drive #
        move.b  7(sp),ATSC      ; set timeout counter
        move.b  #SBWTO,ATCR     ; set command code
        bra     w4int           ; go wait for interrupt

; ssc() - set sector count wrt current mode of drive
;
; ssc(pdev)
; WORD  pdev;   4(sp).w         ; physical unit #

_ssc:   
        move.w  4(sp),d0        ; d0 = physical unit #
        andi.b  #7,d0           ; mask off flags (if any)
        lsl.b   #4,d0           ; shift unit # to place
        move.b  d0,ATSDH        ; set drive #
        move.b  #SSC,ATCR       ; set command code
        bra     w4int           ; go wait for interrupt

; sbres() - set drive to Standby mode.
;         - drive will not wake up until reset is sent to drive
;
; sbres(pdev)
; WORD  pdev;   4(sp).w         ; physical unit #

        .globl  _sbres
_sbres: 
        move.w  4(sp),d0        ; d0 = physical unit #
        andi.b  #7,d0           ; mask off flags (if any)
        lsl.b   #4,d0           ; shift unit # to place
        move.b  d0,ATSDH        ; set drive #
        move.b  #SBRES,ATCR     ; set command code
        bra     w4int           ; go wait for interrupt


        .data
; SOME MORON STUCK THIS HERE WITHOUT THINKING MAYBE IT WOULD SHOW
; UP IN ROM SOMEDAY.
;sbuf:   dcb.b   512,0           ; scratch buffer
;
start_cmd:
        dc.b    $1b,0,0,0,1,0
idemsg: dc.b    'IDE test',cr,lf,eot
hddmsg: dc.b    tab,tab,tab,'Internal Hard Disk Exerciser',cr,lf
        dc.b    'WARNING: abnormal termination may result in lost data.',cr,lf
        dc.b    'Hit <Esc> key to stop program.',cr,lf,eot
hit_key: dc.b   'ESC=exit, S=start, D=controller diagnostic test,',cr,lf,eot
cyclmsg: dc.b   ' Cycle: ',eot
wrcylm: dc.b    'Writing cylinder   ',eot
rdcylm: dc.b    'Reading cylinder   ',eot
sectorm: dc.b   'Read error on sector  ',eot
wcylerr: dc.b   'Write error on sector ',eot
datcmpm: dc.b   'Data compare error (wrote, read, hex offset): ',eot
notrspdm: dc.b  'Controller not responding',cr,lf,eot
ltmsg:  dc.b    'Operation timed-out',cr,lf,eot
cmderrm: dc.b   'Command error',cr,lf,eot
rdstatm: dc.b   ' Status = ',eot
dstatm: dc.b    'Diagnostic status = ',eot
mcntm:  dc.b    'DMA count error',cr,lf,eot
spcmsg: dc.b    '                             ',eot
hescmsg: dc.b   '   <<  Hit <Esc> key to stop.  >>   ',eot
badsav: dc.b    'Error restoring data',cr,lf,eot
stope:  dc.b    'Stopped. Press RETURN to continue.',cr,lf,eot
hpausem: dc.b   'Stopped. RETURN=continue, S=restart, ESC=exit ',eot
;w_lst_e: dc.b   'Error -- unable to write bad sector list',cr,lf,eot
spray_bad: dc.b 'DMA address error -- Data written outside data buffers',eot 
yesb_msg: dc.b      'found blitter',cr,lf,eot
ok_msg:   dc.b      'time out status ok',cr,lf,eot
ok1_msg:   dc.b      'time out status still ok',cr,lf,eot
tim_msg:  dc.b      'error time out',cr,lf,eot
nomo_msg: dc.b      'error - no more data (no drq)',cr,lf,eot
err1_msg: dc.b      'error on ident command access of disk',cr,lf,eot
err2_msg: dc.b      'error on init command access of disk',cr,lf,eot
err3_msg: dc.b      'error on format one track',cr,lf,eot
intdiag:  dc.b      '      Running hard disk CONTROLLER diagnostic',cr,lf,lf,eot
readingb: dc.b      'reading buffer',cr,lf,eot
fstmsg:   dc.b      'failed read of original data from disk',cr,lf,eot
sndmsg:   dc.b      'read buffer full - start next cycle',cr,lf,eot
trdmsg:   dc.b      'failed writing test data to disk',cr,lf,eot
headmsg:  dc.b      ', head ',eot
fthmsg:   dc.b      'failed reading test data to disk',cr,lf,eot
fifmsg:   dc.b      'end of read',cr,lf,eot
notemsg:  dc.b      cr,lf,lf,lf
          dc.b      '         NOTE: even cycle is non-DMA; odd cycle is blitter mode',cr,lf,eot
        .end
              
