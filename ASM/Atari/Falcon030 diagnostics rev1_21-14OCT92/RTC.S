        .globl  RTCsetpass,RTCsetfail,RTCclearpass
        .extern rtctst,savectl,AnyOpNeed,ClearNVRAM,setzerotime

        .include hardware
        .include defs
        .include nvram

*       Test Real-time Clock
*       May 5, 1989
*       test ram, time/date rollover, interrupts
*-----------------------------------------------
* SPARROW TEST : RWS : Stolen from rtc.tt
*----------------------------------------------
* V 1.00 - MAY NOT WORK DUE TO MFP2 & VME ISSUES! 
* V 1.10 - WORKS, BUT ALARM DOESN'T FIRE
* V 1.11 - DOESN'T WORK AT 16 MHz on Sparrow. Dunno Why. SUVL looking into it.

fversion  equ  0                   ; floppy version
* RTC - set time modification

dow     equ     6
day1    equ     7
day10   equ     8
month1  equ     9
month10 equ     10
year1   equ     11
year10  equ     12


        .text
rtctst: 
          move.b  #1,is_rtc             ; rtc is testing now
;;RWS.TPE         move.b  SPControl,d5
        move.b  SPControl,savectl  
          clr.b     erflg0
          movea.l   #rtcmsg,a5          ; movie sign!
          bsr       dsptst
          bsr       savrtc
        
*    init chip
*          bsr       initmfp2       ;init mfp used by rtc
          lea       rtcadd,a0
          move.b    #$a,(a0)       ; sel reg a
          move.b    #$6f,2(a0)     ; 32k Hz, 500ms, reset
          move.b    #$b,(a0)       ; sel reg b
          move.b    #$82,2(a0)     ; 24 hr mode, no ints, stop
*    test RAM
          move.b    #14,target
rtcram:   move.b    #$0,filchr
          bsr       disturb
          bne.s     frtcram
          move.b    #$ff,filchr
          bsr       disturb
          bne.s     frtcram
          bsr       combin
          bne.s     frtcram
          add.b     #1,target
          cmp.b     #64,target
          bne.s     rtcram
rtctst1:
;        bclr    #0,SPControl    ; test 8 mhz
 ;       bsr     timdat          
  ;      beq     rtctst2         ; passed
   ;     bset    #1,erflg0       ; failed
    ;    bra     rtctst4         
        
;        move.w  #3,tries
rtctst2:
;        bset    #0,SPControl    ;test 16 mhz  
        bsr     timdat
        beq     rtctst4         ; passed
;        sub.w   #1,tries
;        bne     rtctst2
        bset    #3,erflg0       ; failed
        bra     rtctst4
                
frtcram:  bset  #0,erflg0
          bra   rtctst1

*         test time/date rollover
timdat:   
        move.w  #$2400,sr
          bsr       itime1s        ;init timer
          lea       time0,a1
          bsr       settime        ;set clock
          bsr       wait1s         ;wait 1 sec
          lea       time1,a1
          bsr       chktime        ;verify time
          bne.s     rtctimf
          lea       time2,a1
          bsr       settime        ;same thing, only cause day 10 digit to inc
          bsr       wait1s
          lea       time3,a1
          bsr       chktime
          beq.s     rt_timdat

rtctimf:
        or.w   #1,d0
;          bset     #1,erflg0   
rt_timdat:
        rts


*         test interrupts       - AXED : 28FEB92 : RWS
rtctst4:
rtcint_tst:
;          lea       time3,a1
;          lea       time4,a1
;          bsr       setalr         ;set alarm
;          move.l    #rtcint,mfprtc ;install vector
;          moveq     #14,d0
;          bsr       enabint2       ;enable interrupt
;          move.b    #$40,temp      ;reg B setting (ie)
rtints:
;          clr.b     intflg
;          lea       time4,a1
;          lea       time3,a1
;          bsr       settime        ;set time
;          move.b    #$b,(a0)
;          move.b    temp,d0
;          ori.b     #2,d0
;          move.b    d0,2(a0)       ;enable int at rtc
;          bsr       wait1s
;          move.b    #$b,(a0)
;          move.b    #$82,2(a0)       ;reset ie
;          cmp.b     #0,intflg      ;check for occurence
;          bne.s     nxtrti
;          bset      #2,erflg0
;
nxtrti:
;         lsr.b     temp
;          cmp.b     #$8,temp
;          bne       rtints

*       display errors and return to test dispatcher
rtcret:   
          bsr       resrtc
          moveq     #13,d0         ;stop timer a int
          bsr       disint
*          moveq     #14,d0
*          bsr       disint2        ;disable alarm int
rtcret1:  lea       rtcerr,a0
          move.b    erflg0,d0
          beq.s     rtcdone
          bsr       dsp_er1
          bra.s     rtcdone1

rtcdone:
          movea.l   #pasmsg,a5
        move.b  #t_RTC,d0
          bsr       dsppf
        tst.b   autotst
        bne     rtcdone1          ;if auto mode
        tst.b   ProdTestStat
        bpl     rtcdone1
        bsr     dsp_rtc

*       display time until keystroke
ptclock:
       bsr     constat
       tst     d0
       beq     ptclock
       bsr     conin
       cmpi.b  #'S',d0         ;set new time?
       bne     rtcdone1
       bsr     crlf
       bsr     setclk          ;input new time (to oldtime) and set clock
       bra     ptclock

rtcdone1:
;;RWS.TPE       move.b   d5,SPControl
        move.b  savectl,SPControl
       rts

*   Get the clock and display
dsp_rtc:
        movem.l d0-d7/a0-a6,-(sp)
        move.w  v_cur_cx,savx   ;save cursor position
        move.w  v_cur_cy,savy

        bsr     gettime
        moveq    #66,d0          ; col
        moveq    #2,d1           ; row
        bsr     move_cursor
        lea     timemsg,a5
        bsr     dspmsg
        bsr     dsp_time
        moveq    #66,d0          ; col
        moveq    #3,d1           ; row
        bsr     move_cursor
        lea     datemsg,a5
        bsr     dspmsg
        bsr     dsp_date

        move.w  savx,d0
        move.w  savy,d1
        bsr     move_cursor     ;restore cursor positon
        movem.l (sp)+,d0-d7/a0-a6
        rts

*--------------------------------
*       get (up to) 6 digits of time and 6 digits of date 
*       and 1 digit of day-of-week from keyboard
*       place new time in oldtime and call settime
setclk:
*       get time hh:mm:ss
        lea     settmsg,a5
        bsr     dspmsg
        lea     tempbuf,a1
        bsr     gettim          ;get time from keyboard
        beq.s   getdat          ;go on - skip setting time

        lea     oldtime,a0
        move.l  #5,d1

newtim: move.b   -(a1),(a0)+    ;save in reverse order of entry
        dbra    d1,newtim
        bsr     crlf
        lea     oldtime,a0
        lea     rtcbuf,a1
        bsr     up_date         ;up date time in rtc chip

*       get date mm:dd:yy
getdat: lea     setdmsg,a5
        bsr     dspmsg
        lea     tempbuf,a1
        bsr     gettim          ;get date from keyboard
                                ;entry order is month, day, year
        beq.s   getday          ;go on - skip setting date
        lea     oldtime,a0
        move.b  -(a1),year1(a0) ;pop off items and arrange in order
        move.b  -(a1),year10(a0)
        move.b  -(a1),day1(a0)
        move.b  -(a1),day10(a0)
        move.b  -(a1),month1(a0)
        move.b  -(a1),month10(a0)
        bsr     crlf
        add.l   #7,a0
        lea     rtcbuf+4,a1
        bsr     up_date            ;up date - date in rtc

*       get day of week
getday: lea     dowmsg,a5
        bsr     dspmsg
        bsr     getcmd
        lea     keybuf,a0
        move.b  (a0)+,d0
        bsr     isnum
        bne     rt_getday         ;go on - skip day of week set
        andi.b  #$7,d0
        lea     oldtime,a0
        move.b  d0,dow(a0)
        add.l   #6,a0
        lea     rtcbuf+3,a1
        bsr     up_date1           ;up date - day of week in rtc

rt_getday:
        bsr     gettime
        bsr     crlf
        lea     timemsg,a5
        bsr     dspmsg
        bsr     dsp_time
        bsr     crlf
        lea     datemsg,a5
        bsr     dspmsg
        bsr     dsp_date
        rts

*       get time or date: 6 digits, save in buffer, discard other
*       entry:  a1 = ptr to temp buffer
*       exit:   eq if no entries,
*       else a1 points to end of list (last entry+1)
*       buffer entries are word-size; only odd byte is used
*       order is: 1 sec, 10 sec, 1 min, 10 min,...,10 hr, dow, 1 day, 10 day...
gettim: bsr     getcmd          ;get a buffer from keyboard
        bsr     crlf
        tst     d0
        bne     getim0
        rts

getim0: lea     keybuf,a0       ;a0=>first char
getim1: cmp.l   a0,a4
        beq     gettimx         ;if buffer empty
        move.b  (a0)+,d0        ;pull off chars in order (h,m,s; m,d,y)
        bsr     isnum
        bne     getim1          ;discard delimiters
        andi.b  #$f,d0
        move.b  d0,(a1)+        ;save time in order (h,m,s; m,d,y)
        bpl     getim1          ;until 6 digits 
gettimx:
        or      #1,d0
        rts     

*--------------------------------
*       function: is a number (ascii 0-9)
*       enter:  d0=ascii
*       exit:   eq if 0-9
isnum:  cmpi.b  #'0',d0
        blt     isnumx
        cmpi.b  #'9',d0
        bgt     isnumx
        cmp     d0,d0
isnumx: rts

** up date real time clock chip
** a0 points to data
** a1 points to rtc buffer               
up_date:
        move   #2,d6
.1:     bsr    hex_it
        dbra   d6,.1
        lea    rtcbuf,a1
        bsr    settime
        rts

up_date1:
        move.b (a0),d0
        bsr    hexchr
        move.b d0,(a1)
        lea    rtcbuf,a1
        bsr    settime
        rts
   
hex_it: move.b (a0)+,d0
        bsr    hexchr
        move.b d0,d1
        move.b (a0)+,d0
        bsr    hexchr
        lsl.l  #4,d0
        or.l   d0,d1
        move.b d1,(a1)+
        rts       

*--------------------------------
*       dsp rtc time
*
gettime:
dspdate:  
;         bsr       crlf
        lea     tempbuf,a1       
          lea       rtcadd,a0
          moveq     #$ff,d7
ip:       move.b    #$a,(a0)
          move.b    2(a0),d0
          btst      #7,d0          ;update in progress? shouldn't be!!
          beq.s     redtime        ;branch if no
          dbra      d7,ip          ;go back for update end
redtime:  lea       rtcreg,a2
          moveq     #numrtcregs-1,d7

curtime:  move.b    (a2)+,(a0)     ;select register
          move.b    2(a0),d1       ;read time
          move.b    d1,(a1)+
          dbra      d7,curtime
          bsr       crlf
          rts

dsp_time:
        lea     tempbuf,a0
        move.b  2(a0),d1
        bsr     dspbyt
        bsr     dspspc
        move.b  1(a0),d1
        bsr     dspbyt
        bsr     dspspc
        move.b  (a0),d1
        bsr     dspbyt
        rts

dsp_date:
        lea     tempbuf,a0
        move.b  5(a0),d1
        bsr     dspbyt
        bsr     dspspc
        move.b  4(a0),d1
        bsr     dspbyt
        bsr     dspspc
        move.b  6(a0),d1
        bsr     dspbyt
        rts

*       test disturbance on a single cell
*       entry:  target = cell
*       exit:   ne if error
disturb:
          move.b    target,(a0)    ;select location
          move.b    filchr,2(a0)   ;write data
*         fill background with 00
          move.b    #$0,bckgnd
          bsr       rtcbck
          bne.s     distx
*       fill background with ff
          move.b    #$ff,bckgnd
          bsr       rtcbck
distx:    rts



*--------------------------------
*       write background data and verify target         
*       exit:   ne if error
rtcbck:   move.b    #14,d1         ;14-64
dist2:    cmp.b     target,d1
          beq.s     dist1
          move.b    d1,(a0)        ;select next backgnd cell
          move.b    bckgnd,2(a0)   ;write backgnd
dist1:    addq      #1,d1
          cmpi.b    #64,d1
          bne.s     dist2          ;write all cells

*       verify target cell
          move.b    target,(a0)    ;select target
          move.b    2(a0),d0       ;read it
          cmp.b     filchr,d0
          rts

*--------------------------------
*       test combinations on target cell
*       entry:  target = cell
*       exit:   ne if error
combin:   moveq     #1,d1          ;init data
comb0:    move.b    target,(a0)
          move.b    d1,2(a0)       ;write data
          move.b    #14,d0
          cmp.b     #14,target     ;if testing 14, use 15
          bne.s     comb1
          addq      #1,d0
comb1:
          move.b    d0,(a0)        ;select alternate cell
          move.b    #$ff,2(a0)
          move.b    target,(a0)
          move.b    2(a0),d0
          cmp.b     d0,d1
          bne.s     combx
          lsl       #1,d1          ;combin are shifted 1
          bcc.s     comb0
combx:    rts

*--------------------------------
*       set clock
*       entry:  a1 points to data
settime:  lea       rtcadd,a0
          lea       rtcreg,a2      ;regs 00,02,04,06,07,08,09
          moveq     #numrtcregs-1,d7
          move.b    #$b,(a0)
          move.b    #$82,2(a0)     ;stop update
          move.b    #$a,(a0)
          move.b    #$6f,2(a0)     ;divider reset
stime:    move.b    (a1)+,d1       ;get data
          move.b    (a2)+,(a0)     ;select register
          move.b    d1,2(a0)       ;write data
          dbra      d7,stime
          move.b    #$b,(a0)
          move.b    #$82,2(a0)     ;bcd mode
          move.b    #$a,(a0)
          move.b    #$2f,2(a0)     ;set divider to 32k base
          move.b    #$b,(a0)
          move.b    #$2,2(a0)      ;start clock (500ms update occurs)
        bsr  sync               ; modified 8/28/92
        rts


sync:   
*  sync on next update of RTC
*  TLE and TF 8/28/92 
        move.l   #$fffff,d7
.1:     move.b  #$a,(a0)
        move.b  2(a0),d0
        btst    #7,d0           ;update has started?
        bne.s   .2              ;yes
        sub.l   #1,d7
        bne.s   .1
        lea     rtcto1,a5       ;give up and display 
        bsr     dspmsg
        bra.s   .end            ;
.2:
        move.l  #$ffff,d7
.3:     move.b  #$a,(a0)
        move.b  2(a0),d0
        btst    #7,d0           ;update done? - 2 msec max
        beq.s   .end            ;yes
        dbra    d7,.3           ;no
        lea     rtcto2,a5       ;give up and display not done
        bsr     dspmsg

.end:   rts

*--------------------------------
*       set alarm
*       entry:  a1 points to data
setalr:   lea       rtcadd,a0
          lea       rtcalr,a2       ;regs 01,03,05
          moveq     #2,d7
          move.b    #$b,(a0)
          move.b    #$82,2(a0)      ;stop update
          move.b    #$a,(a0)
          move.b    #$6f,2(a0)       ;reset clock
salrm:    move.b    (a1)+,d1        ;get data
          move.b    (a2)+,(a0)      ;select register
          move.b    d1,2(a0)        ;write data
          dbra      d7,salrm
          rts

*--------------------------------
*       check rtc time
*       entry:  a1 points to correct time
*       exit:   ne if error
chktime:   lea      rtcadd,a0
          moveq     #$ff,d7
chkuip:   move.b    #$a,(a0)
          move.b    2(a0),d0
          btst      #7,d0          ;update in progress? shouldn't be!!
          beq.s     rdtime         ;branch if no
;          dbra      d7,chkuip     ;go back for update end
    bra.s chkuip                   ;go back for update end
rdtime:   lea       rtcreg,a2
          moveq     #numrtcregs-1,d7
ctime:    move.b    (a2)+,(a0)     ;select register
          move.b    2(a0),d1       ;read time
          cmp.b     (a1)+,d1       ;compare with expected time
          bne.s     ctdsp
          dbra      d7,ctime
          bra.s     ctimx
ctdsp:    
        bsr     crlf
          lea       rtcreg,a2
          moveq     #numrtcregs-1,d7
dsptim:   move.b    (a2)+,(a0)
          move.b    2(a0),d1
          bsr       dspbyt
          bsr       dspspc
          dbra      d7,dsptim
          bsr       crlf
          cmp.b     #4,d7          ;flag error for caller
ctimx:    rts

*----------------------------------
*       init the mfp/software timer
*       timer a = 2457600/64/200 = 192 Hz
itime1s:
          move.l    #timer_a,mfpta      ;install vector ($134)
          lea       mfp,a0
          move.b    #200,tadr(a0)       ;/200 (timer a data reg.)
          move.b    #5,tacr(a0)         ;/64 (timer a control reg.)
          moveq     #13,d0
          bsr       enabint
* RWS: ACTUALLY TURN ON THE TIMER ! WOW, WHAT A PLAN!
        bset.b  #5,iera(a0)     ; enable timer a int.
        bset.b  #5,imra(a0)
*----------------------------------------------------
          rts

*       wait for 1 second, using timer 
wait1s:
wait1t: clr.b     tim_ah
        clr.b     tim_al
wt1s:   cmp.b     #0,tim_ah
        beq.s     wt1s
        rts

*       wait for 1 second, using software timer
; wait1s:
        move.w    #$2700,sr
        bsr     wait10
        bsr     wait25
        bsr     wait25
        bsr     wait25
        bsr     wait25
        bsr     wait100                 ;
        bsr     wait100                 ;
        bsr     wait100                 ;
        move.w    #$2400,sr
        rts

*------------------------
*       save current contents of rtc
savrtc:   lea       rtcreg,a1   ; register index
          lea       rtcadd,a0   ; ff8961
          lea       rtcbuf,a2
          move      #numrtcsave-1,d7
svrtc:    move.b    (a1)+,(a0)
          move.b    2(a0),(a2)+
          dbra      d7,svrtc
          moveq     #14,d0
svrtc1:   move.b    d0,(a0)
          move.b    2(a0),(a2)+
          addq      #1,d0
          cmp.b     #64,d0
          bne.s     svrtc1
          rts

*------------------------
*       restore contents of rtc
resrtc:   lea       rtcreg,a1
          lea       rtcadd,a0
          lea       rtcbuf,a2
          move      #numrtcsave-1,d7
rsrtc:    move.b    (a1)+,(a0)
          move.b    (a2)+,2(a0)
          dbra      d7,rsrtc
          moveq     #14,d0
rsrtc1:   move.b    d0,(a0)
          move.b    (a2)+,2(a0)
          addq      #1,d0
          cmp.b     #64,d0
          bne.s     rsrtc1
          rts

*----------------------------------

*---------------------------------
*       interrupt routine for timer a
*       interrupts at 193 Hz rate
*       inc tim_ah every 193 occurences = 1 sec + 5ms
timer_a:
          add.b     #1,tim_al
;          cmp.b      #199,tim_al        ; 995 ms min TLE 8/28/92
          cmp.b      #250,tim_al        ; 995 ms min TLE 8/28/92
          bne.s     timer_ax
          clr.b     tim_al
          add.b     #1,tim_ah
timer_ax:
          bclr      #5,isra+mfp
          rte

*------------------------
*       display error msg
*       entry:  a0 = table of messages
*               d0 = bit map
dsp_er1: 
        moveq   #0,d1           ;bit test
        moveq   #0,d2           ;msg ptr index
rtcer1: btst    d1,d0
        bne.s   rtcer3
rtcer2: addq    #4,d2
        addq    #1,d1
;        cmp.b   #4,d1
        cmp.b   #5,d1
        bne.s   rtcer1
        move.w    #red,palette
        movea.l   #falmsg,a5
        move.b  #t_RTC,d0
        bsr       dsppf 
        rts
rtcer3: move.l  0(a0,d2),a5     ;get msg
        move.l  a0,-(sp)
        bsr     dspmsg
        move.l  (sp)+,a0
        bra.s   rtcer2

*-----------------------------
*-----------------------------
* NVRAM CODE moved : RWS : 09JUL92
*-----------------------------
* REAL CODE BELOW

*--------------------------------
*       set clock to time 0
setzerotime:
        lea     rtczerodata,a1 
        bsr     settime         ; in RTC.s
        rts

*--------------------------------
* Clear NVRAM
ClearNVRAM:
        move.b  #NVRAM0,d7
        move.w  #49,d1
.lp:
        move.b  d7,rtcadd
        move.b  #$0,rtcdat
        add.b   #1,d7
        dbra    d1,.lp
        rts
*--------------------------------
* OLD MACRO CODE...
RTCsetpass:
        tst.b   ProdTestStat    ; if not in a prod test.
        bmi     .dontset
        READNVRAM d0,d7
        bset    #PASSBIT,d7
        bclr    #NEEDBIT,d7
        WRITESAME d0,d7
.dontset:
        rts

RTCclearpass:
        tst.b   ProdTestStat
        bmi     .dontset
        READNVRAM d0,d7
        bclr    #PASSBIT,d7
        bclr    #FORCEBIT,d7
        bset    #NEEDBIT,d7
        WRITESAME d0,d7
.dontset:
        rts

RTCsetfail:
        tst.b   ProdTestStat    ; if not in a prod test
        bmi     .dontset
        READNVRAM d0,d7
        andi.b  #$0f,d7         ; fix these if more F bits
        cmp.w   #$f,d7
        beq     .bypass
        add.b   #1,d7
.bypass:
        bset    #NEEDBIT,d7
        WRITESAME d0,d7
.dontset:
        rts

AnyOpNeed:
        RTCISNEEDED #t_FLOP
        bne     .yes
        RTCISNEEDED #t_AUDIO
        bne     .yes
        RTCISNEEDED #t_VIDEO
        bne     .yes
        RTCISNEEDED #t_KEYBD
.yes:   rts

*-=------------------------
        .data
 rtczerodata:   dc.b    0,0,0,0,0,0,0,0         ; set clock to time 0
        .even
            

        .data
numrtcregs equ  7
numrtcsave equ  64

*               sec min hr  day dat mon yr  
rtcreg: dc.b    $00,$02,$04,$06,$07,$08,$09
rtcalr: dc.b    $01,$03,$05,$02,$10,$02,$89
; time0:  dc.b    $59,$59,$23,$07,$31,$12,$99
time0:  dc.b    $58,$59,$23,$07,$31,$12,$99     ; modified 8/27/92
time1:  dc.b    $00,$00,$00,$01,$01,$01,$00
;time2:  dc.b    $59,$59,$23,$01,$09,$02,$89
time2:  dc.b    $58,$59,$23,$01,$09,$02,$89
time3:  dc.b    $00,$00,$00,$02,$10,$02,$89
time4:  dc.b    $01,$00,$00,$02,$10,$02,$89

        .even
rtcerr: dc.l    rtcrmfm
        dc.l    rtctimm
        dc.l    rtcalrm
        dc.l    rtctimm6

rtcrmfm: dc.b   'RTC RAM error',cr,lf,eot
rtctimm: dc.b   'RTC time/date failed at  8 Mhz',cr,lf,eot
rtctimm6: dc.b  'RTC time/date failed at 16 Mhz',cr,lf,eot
rtcalrm: dc.b   'RTC alarm error',cr,lf,eot
rtcmsg:  dc.b   'Testing RTC',cr,lf,eot
settmsg: dc.b   'Enter time: hhmmss',cr,lf,eot
setdmsg: dc.b   'Enter date: mmddyy',cr,lf,eot
dowmsg: dc.b    'Day: Sun=1 Mon=2 Tue=3 Wed=4 Thr=5 Fri=6 Sat=7',cr,lf,eot
datemsg: dc.b   'Date: ',eot
timemsg: dc.b   'Time: ',eot
tpmsg:  dc.b    'Test Point ',eot
rtcto1: dc.b    'RTC time-out update never started',cr,lf,eot
rtcto2: dc.b    'RTC time-out update never finished',cr,lf,eot
        .text

