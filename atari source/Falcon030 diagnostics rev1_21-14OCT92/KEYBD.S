        .include hardware
        .include defs
        .include nvram

        .globl lar,keytst,keyres,KeyStruck,EndKeyStruck

*       Keyboard test
*       may 2 ,90   eliminate 6 ROM check ****~ tf
*       Nov 6, 87   Break codes are buffered to prevent overrun.
*       Oct 14, 87   display mouse, display key on lower half of screen.
*       May 15, 87  Disable mouse after keyboard reset
*       Feb 2, 87
*       Oct 29, 86. Save keyboard revision number.
*       Oct 5, 86 Check ROMs, display U.K. keyboard if not U.S. ROMs.
*       If multiple cycles, run power-up test only.
*       Problem: keyboard reset test completion codes are $f0-f3,
*         while break codes for $70-72 keys are $f0-f2. Can't tell
*         difference between completion and stuck key code for these keys.

        .text

keytst:
        RTCCLEARPASS #t_KEYBD
        movea.l #keytstm,a5
        bsr     dsptst
        bsr     keyres          ;run keyboard reset test
        tst     d0
        bne.s   krfail          ;quit if keybd dead

        move.b  consol,d1
        andi.b  #$38,d1         ;mask multiple test bits
        beq.s   keyfull         ;don't run if mult. cycles

*       Stop here if multi-pass 
        tst     d0
        bne.s   krfail
        lea     pasmsg,a5
        bra.s   krdsp
krfail: lea     falmsg,a5
krdsp:  move.b  #t_KEYBD,d0
        bsr     dsppf
        rts                     ;normal test return

*       Keyboard test
*       Display full keyboard
*       Any key press causes inverse video display of key

keyfull:
        bsr     clearsc
        move    #0,sav_x        ;init key display
        move    #16,sav_y
        move    #16,scrtop
*---------------
* setup KeyStruck memory
        lea.l   keypos,a0
        lea.l   KeyStruck,a1
.loop:
        move.b  #$0,d0          ; what to store
        cmp.b   #0,(a0)+
        bne     .skipto3
        move.b  #$03,d0         ; set this one done since we can't hit it.
.skipto3:
        addq.l  #1,a0           ; skip next byte
        move.b  d0,(a1)+
        cmp.l   #keyposEnd,a0   ; doesn't clear mousespace (done later)
        bne     .loop

*---------------------------------------
* empty key break buffer : 09APR92 : RWS
.empty:
        move.l  brkptrt,a0      ;get tail of queue
        cmpa.l  brkptrh,a0      ;empty?
        beq.s   .contd

        move.b  (a0)+,d2        ;get break code  
        cmp.l   #brkbuft,a0
        bne     .kbrk1
        move.l  #brkbufh,a0     ;wrap ptr if at end
.kbrk1:  move.l  a0,brkptrt      ;save new tail ptr
        bra     .empty
.contd:
        move.b  #$ff,usrom      ;assume U.S.
        tst.b   config+1        ;test TOS configuration byte
        beq.s   kbegin
        clr.b   usrom           ;must be European

*       Display keyboard type, escape message
kbegin: bclr    #F_REVID,v_stat_0  ;normal video
        lea     ukkey,a5
        tst.b   usrom
        beq.s   kbtype  
        move.b  #$3,KeyStruck+$60       ; skip over ISO key if USA TOS
        lea     uskey,a5
kbtype: bsr     dspmsg
        lea     escmsg,a5
        bsr     dspmsg
        
*       Display full keyboard
        bset    #F_REVID,v_stat_0 ; display reverse video
        bclr    #F_NEWVID,v_stat_R      ; 07APR92
        moveq   #1,d2
kbdsp:  bsr     dspkey          ;display key
        addi.b  #1,d2
        cmpi.b  #$73,d2         ;until all keys displayed
        bne.s   kbdsp

*       Display mouse
        moveq   #58,d0
        moveq   #4,d1
        bsr     move_cursor
        lea     mousmsg,a5
        bsr     dspmsg
        bsr     mov_lb
        bsr     mov_rb
        bsr     mov_lf
        bsr     mov_rt
        bsr     mov_up
        bsr     mov_dn

* Clear Mouse Spaces            ; autostrike..(ok, not cleared if = 3)
        move.b  #$03,KSMouRB
        move.b  #$03,KSMouLB
        move.b  #$03,KSMouU
        move.b  #$03,KSMouD
        move.b  #$03,KSMouL
        move.b  #$03,KSMouR

;       move.w  #$0303,KSMouseRB        ;clear RB,LB
;       move.l  #$03030303,KSMouseU     ;clear U,D,L,R
;       move.b  #$03,KeyStruckEnd

****************************************
*       Loop for displaying key closures
keydsp: bsr     constat         ;new key make?
        tst     d0
        bne.s   kdsp1

*       check mouse
        bsr     chkmouse

*       Check for key break
        move.l  brkptrt,a0      ;get tail of queue
        cmpa.l  brkptrh,a0      ;empty?
        beq.s   keydsp
        
        clr.l   d2
        move.b  (a0)+,d2        ;get break code 
        andi.b  #$7f,d2 
        cmp.l   #brkbuft,a0
        bne     kbrk1
        move.l  #brkbufh,a0     ;wrap ptr if at end
kbrk1:  move.l  a0,brkptrt      ;save new tail ptr

*       Display key break
        move.l  #KeyStruck,a3           ; have to do this because madmac doesn't
        bset    #1,0(a3,d2)             ; know about '030
        bset    #F_REVID,v_stat_0
        bset    #F_NEWVID,v_stat_R      ;added 07APR92 : RWS
        bsr     dspkey
        bclr    #F_NEWVID,v_stat_R      ;ditto : RWS

        bsr     CheckAllHit
        bra.s   keydsp

*       Get new key
kdsp1:  bsr     conin           ;ret d0=ascii, d1=scan code
        bsr     click
        cmpi.b  #esc,d0         ;stop on shift escape
        bne.s   kvid
        btst    #7,kbshift
        beq     kvid    
        bclr    #F_REVID,v_stat_0
        bset    #7,consol       ;return immed. to menu
        cmp.w   #green,palette
        bne     .exit
        RTCSETPASS #t_KEYBD
.exit:
        rts                     ;esc key=quit

*       Display current key press, normal video
kvid:   lea.l   KeyStruck,a3            ; have to do this because madmac doesn't
        bset    #0,0(a3,d1)             ; know about '030
        bclr    #F_REVID,v_stat_0  
        move.b  d1,d2
        bsr     dspkey

*       display key below the keyboard representation
*       this is a running record of all keystrokes
        bset    #F_REVID,v_stat_0
        andi    #$ff,d2
*       check for oversize keys, replace with one-line message
        cmpi.b  #$1c,d2         ;return?
        bne     kdsp2
        lea     sret,a5
        bra     kdsp5
kdsp2:  cmpi.b  #$72,d2         ;enter?
        bne     kdsp3
        lea     senter,a5
        bra     kdsp5
kdsp3:  cmpi.b  #$39,d2
        bne     kdsp4
        lea     sspace,a5
        bra     kdsp5

kdsp4:  lsl.w   #2,d2           ;X4 (long word size table)
        lea     keychr,a0
        movea.l 0(a0,d2),a5     ;get message ptr
kdsp5:  move    sav_y,d1
        move    sav_x,d0
        bsr     move_cursor     
        bsr     dspmsg          ;print key
        bsr     dspspc
        move    v_cur_cx,sav_x
        move    v_cur_cy,sav_y  
        bra     keydsp
      
*----------------------------
* Check to see if all keys pressed
CheckAllHit:
        lea.l   KeyStruck,a3
.check:
        cmp.b   #$03,(a3)+
        bne     .not
        cmp.l   #EndKeyStruck,a3
        bne     .check
        move.w  #green,palette  ; all done & set
.not:
        rts

*--------------------------------
*       check for change in mouse
chkmouse:
        tst.b   rmb             ;any mouse change?
        beq     nomouse         ;write all direction inverse

*       read button status, display current state
        bset    #F_REVID,v_stat_0
        btst    #0,rmb          ;right button pressed?
        beq.s   rmous0
        bclr    #F_REVID,v_stat_0
rmous0: bsr     mov_rb
        bset    #F_REVID,v_stat_0
        btst    #1,rmb          ;left button pressed?
        beq.s   rmous1
        bclr    #F_REVID,v_stat_0
rmous1: bsr     mov_lb

*       test for change of direction (received new mouse packet)
*       if change, display in normal video and set flag (temp)
        tst.b   jstat0          ;change in mouse x direction?
        beq.s   rmous2
        bclr    #F_REVID,v_stat_0
        btst    #7,jstat0       ;x direction, check pos/neg
        beq.s   rmxp
        bsr     mov_lf          ;left
        bset    #0,tempb
        bra.s   rmous2
rmxp:   bsr     mov_rt          ;right
        bset    #1,tempb
rmous2: clr.b   jstat0
        tst.b   jstat1          ;change in mouse y direction?
        beq.s   rmous3
        bclr    #F_REVID,v_stat_0
        btst    #7,jstat1
        bne.s   rmyp            ;neg=up
        bsr     mov_dn          ;down
        bset    #3,tempb
        bra.s   rmous3
rmyp:   bsr     mov_up          ;up
        bset    #2,tempb
rmous3: clr.b   jstat1
        clr.b   rmb             ;clear mouse packet for next test
        move.b  #5,timflg       ;count down delay before restoring normal vid.
        rts

;       no change: clear any indication by writing inverse video (flag=temp)
nomouse:
        tst.b   tempb
        beq     chkmousx
        sub.b   #1,timflg
        bne     chkmousx        ;don't clear right away (better visibility)
        bset    #F_REVID,v_stat_0
        btst    #0,tempb
        beq     nmous1
        bsr     mov_lf          ;left
nmous1: btst    #1,tempb
        beq     nmous2
        bsr     mov_rt          ;right
nmous2: btst    #2,tempb
        beq     nmous3
        bsr     mov_up          ;up
nmous3: btst    #3,tempb
        beq     nmous4
        bsr     mov_dn          ;down
nmous4: clr.b   tempb
        bsr     CheckAllHit
chkmousx:
        rts

mov_rb: moveq   #61,d0
        moveq   #6,d1
        bsr     move_cursor
        move.b  #'R',d1
        bsr     ascii_out
        move.b  #$3,KSMouRB
        rts
mov_lb: moveq   #59,d0
        moveq   #6,d1
        bsr     move_cursor
        move.b  #'L',d1
        bsr     ascii_out
        move.b  #$3,KSMouLB
        rts
mov_lf: moveq   #58,d0
        moveq   #10,d1
        bsr     move_cursor
        lea     lar,a5
        bsr     dspmsg          ;left arrow
        move.b  #$3,KSMouL
        rts
mov_rt: moveq   #62,d0
        moveq   #10,d1
        bsr     move_cursor
        lea     rar,a5
        bsr     dspmsg          ;right arrow
        move.b  #$3,KSMouR
        rts
mov_dn: moveq   #60,d0
        moveq   #12,d1
        bsr     move_cursor
        lea     dnar,a5
        bsr     dspmsg          ;down arrow
        move.b  #$3,KSMouD
        rts
mov_up: moveq   #60,d0
        moveq   #8,d1
        bsr     move_cursor
        lea     upar,a5
        bsr     dspmsg          ;up arrow
        move.b  #$3,KSMouU
        rts

*-------------------------------
*       Display a key in proper
*       position on screen
*       Entry:  d2=scan code
*               
dspkey: move.l  d2,-(a7)
        cmpi.b  #$72,d2
        bgt.s   dspkey1         ;br if not key
        andi.l  #$ff,d2
        lsl.b   #1,d2           ;word size table
        lea     keypos,a0
        move.w  0(a0,d2),d1     ;get position (x,y)
        beq.s   dspkey1         ;br no key for this value

        move.l  d2,-(a7)        ;save code (X2)
        move.w  d1,d0
        andi.w  #$ff,d1         ;mask y
        lsr.w   #8,d0           ;shift x to low byte
        bsr     move_cursor     ;position cursor

        move.l  (a7)+,d2        ;get code (X2)
        tst.b   usrom
        bne.s   dspkey5
        cmpi    #$2b00,d2       ;if Euro TOS, check different keys
        beq.s   dspkey2
        cmpi    #$6000,d2
        beq.s   dspkey3
dspkey5:
        lsl.w   #1,d2           ;X4 (long word size table)
        lea     keychr,a0
        movea.l 0(a0,d2),a5     ;get message ptr
        beq.s   dspkey1
dspkey4:
        bsr     dspmsg          ;print key
dspkey1:
        move.l  (sp)+,d2
        rts

dspkey2:
        lea     numsgn,a5       ;# on UK
        bra.s   dspkey4
dspkey3:
        lea     bslash,a5       ;ISO key 
        bra.s   dspkey4

*-------------------------------
*       Keyboard reset test
*       Send reset command, wait for self-test status
*       Exit:   d0=0 if pass
*               d0=ff if fail

keyres:
        moveq   #6,d0
        bsr     enabint         ;enable int
        moveq   #$80,d1
        bsr     ikbdput         ;output reset command
        moveq   #$1,d1
        bsr     ikbdput
        clr.b   brkcod          ;clear break code 
        clr.w   kibufhead       ;clear keyboard buffer ptr
        clr.w   kibuftail
        bset    #3,kstate       ;set state var so int routine will recognize
*                               ;the comp. code and save in buffer (not brkcod)

*       Wait for completion
        move.l  #50000,d7
keycomp:
        bsr     constat
        tst     d0      
        bne.s   gotstat         ;got response
        sub.l   #1,d7
        bne.s   keycomp

*       Time-out
        lea     kbto,a5
        bsr     dspmsg  
        bra.s   kbfail

*       Bad status 
badstat:
        lea     kbresm,a5       ;keyboard reset fail msg
        
*       Fail: time-out, status or stuck key
kbfail: bset    #0,consol       ;flag dead keyboard
        moveq   #6,d0
        bsr     disint          ;disable int
kbfal0: move.w  #red,palette
        moveq   #$ff,d0
        rts
        
*       Got status
*       Note: if no keyboard is attached, we can get false inputs

gotstat:
        bsr     conin           ;get character
        move.b  d1,kbrev        ;save revision #
        andi.b  #$f0,d1         
        cmp.b   #$f0,d1         ;completion code?
        bne.s   badstat
        cmpi.b  #$f0,brkcod     ;break? (stuck key)
        blt     stuck           ;br if break code (key < $70)
*                               ;unfortunately, 70,71,72 have break
*                               ;codes identical to completions codes
*       Keyboard OK
        andi.b  #$f,kbrev       ;ok for rev. number
        add.b   #1,kbrev        ;rev #=code +1  (for SP: 2 = STe, 3 = COPS)
        bclr    #0,consol
        moveq   #$0,d0
        rts

*       Stuck key
stuck:  lea     kstuck,a5       ;stuck key msg
        bsr     dspmsg
        move.b  brkcod,d1
        andi.w  #$7f,d1
        lsl.w   #2,d1           ;long word size table
        lea     keychr,a0
        movea.l 0(a0,d1),a5     ;get key message
        bsr     dspmsg
        bsr     crlf
        bra.s   kbfal0          ;don't disable keyboard if stuck key

*       make a brief noise for key click
click:  lea     psgsel,a1
        lea     psgwr,a2
        lea     clicktb,a0
click1: move.b  (a0)+,(a1)              ;select register
        move.b  (a0)+,(a2)              ;write data
        cmpa.l  #clickte,a0
        bne     click1
        move.l  #$c00,d7
wtclic: sub.l   #1,d7           ;wait
        bne.s   wtclic
        bsr     sndoff          ;shut off sound
        rts

        .data

        .even
clicktb:
        dc.b    0,$3b
        dc.b    6,0
        dc.b    7,$fe
        dc.b    8,$10
        dc.b    13,3
        dc.b    11,$80
        dc.b    12,1
clickte:
        
*       Key display positon table
*       Column, Row             scan code
keypos: dc.b    0,0
        dc.b    5,6     ;esc    1
        dc.b    7,6     ;1      2
        dc.b    9,6     ;2      3
        dc.b    11,6    ;3      4
        dc.b    13,6    ;4      5
        dc.b    15,6    ;5      6
        dc.b    17,6    ;6      7
        dc.b    19,6    ;7      8
        dc.b    21,6    ;8      9
        dc.b    23,6    ;9      a
        dc.b    25,6    ;10     b
        dc.b    27,6    ;-      c
        dc.b    29,6    ;=      d
        dc.b    33,6    ;BS     e
        dc.b    5,8     ;TAB    f
        dc.b    8,8     ;Q      10
        dc.b    10,8    ;W      11
        dc.b    12,8    ;E      12
        dc.b    14,8    ;R      13
        dc.b    16,8    ;T      14
        dc.b    18,8    ;Y      15
        dc.b    20,8    ;U      16
        dc.b    22,8    ;I      17
        dc.b    24,8    ;O      18
        dc.b    26,8    ;P      19
        dc.b    28,8    ;[      1a
        dc.b    30,8    ;]      1b
        dc.b    32,8    ;RET    1c
        dc.b    5,10    ;CTL    1d
        dc.b    9,10    ;A      1e
        dc.b    11,10   ;S      1f
        dc.b    13,10   ;D      20
        dc.b    15,10   ;F      21
        dc.b    17,10   ;G      22
        dc.b    19,10   ;H      23
        dc.b    21,10   ;J      24
        dc.b    23,10   ;K      25
        dc.b    25,10   ;L      26
        dc.b    27,10   ;;      27
        dc.b    29,10   ;,      28
        dc.b    31,6    ;`      29
        dc.b    5,12    ;L SHIFT 2a
        dc.b    34,10   ;\      2b
        dc.b    10,12   ;Z      2c
        dc.b    12,12   ;X      2d
        dc.b    14,12   ;C      2e
        dc.b    16,12   ;V      2f
        dc.b    18,12   ;B      30
        dc.b    20,12   ;N      31
        dc.b    22,12   ;M      32
        dc.b    24,12   ;,      33
        dc.b    26,12   ;.      34
        dc.b    28,12   ;/      35
        dc.b    30,12   ;R SHIFT 36
        dc.b    0,0     ;not used 37
        dc.b    7,14    ;ALT    38
        dc.b    11,14   ;space bar 39
        dc.b    29,14   ;caps lock 3a   
        dc.b    6,4     ;F1     3b      
        dc.b    9,4     ;F2     3c
        dc.b    12,4    ;F3     3d
        dc.b    15,4    ;F4     3e
        dc.b    18,4    ;F5     3f
        dc.b    21,4    ;F6     40
        dc.b    24,4    ;F7     41
        dc.b    27,4    ;F8     42
        dc.b    30,4    ;F9     43
        dc.b    33,4    ;F10    44
        dc.b    0,0     ;       45
        dc.b    0,0     ;       46

*       auxilliary keys 
        dc.b    42,8    ;home   47
        dc.b    40,8    ;up arrow 48
        dc.b    0,0     ;       49
        dc.b    52,8    ;-      4a
        dc.b    38,10   ;left arrow 4b
        dc.b    0,0     ;       4c
        dc.b    42,10   ;right arrow 4d
        dc.b    52,10   ;+      4e
        dc.b    0,0     ;       4f
        dc.b    40,10   ;down arrow 50
        dc.b    0,0     ;       51
        dc.b    38,8    ;insert 52
        dc.b    34,8    ;DEL    53
        dc.b    0,0     ;       54
        dc.b    0,0     ;       55
        dc.b    0,0     ;       56
        dc.b    0,0     ;       57
        dc.b    0,0     ;       58
        dc.b    0,0     ;       59
        dc.b    0,0     ;       5a
        dc.b    0,0     ;       5b
        dc.b    0,0     ;       5c
        dc.b    0,0     ;       5d
        dc.b    0,0     ;       5e
        dc.b    0,0     ;       5f
        dc.b    8,12    ;ISO    60      British keybd
        dc.b    41,6    ;UNDO   61
        dc.b    38,6    ;HELP   62
        dc.b    46,6    ;(      63
        dc.b    48,6    ;)      64
        dc.b    50,6    ;/      65
        dc.b    52,6    ;*      66
        dc.b    46,8    ;7      67
        dc.b    48,8    ;8      68
        dc.b    50,8    ;9      69
        dc.b    46,10   ;4      6a
        dc.b    48,10   ;5      6b
        dc.b    50,10   ;6      6c
        dc.b    46,12   ;1      6d
        dc.b    48,12   ;2      6e
        dc.b    50,12   ;3      6f
        dc.b    46,14   ;0      70
        dc.b    50,14   ;.      71
        dc.b    52,12   ;enter  72
keyposEnd:

*       Address table for key messages
keychr: dc.l    0
        dc.l    escape  ;1
        dc.l    k1      ;2
        dc.l    k2      ;3
        dc.l    k3      ;4
        dc.l    k4      ;5
        dc.l    k5      ;6
        dc.l    k6      ;7
        dc.l    k7      ;8
        dc.l    k8      ;9
        dc.l    k9      ;a
        dc.l    k0      ;b
        dc.l    minus   ;c
        dc.l    equal   ;d
        dc.l    bacsp   ;e
        dc.l    tabk    ;f
        dc.l    kq      ;10
        dc.l    kw      
        dc.l    ke
        dc.l    kr
        dc.l    kt
        dc.l    ky
        dc.l    ku
        dc.l    ki
        dc.l    ko
        dc.l    kp
        dc.l    lbrack
        dc.l    rbrack
        dc.l    retk
        dc.l    cntl    
        dc.l    ka
        dc.l    ks
        dc.l    kd      ;20
        dc.l    kf
        dc.l    kg
        dc.l    kh
        dc.l    kj
        dc.l    kk
        dc.l    kl
        dc.l    semi
        dc.l    rapos
        dc.l    lapos
        dc.l    lshf
        dc.l    bslash
        dc.l    kz
        dc.l    kx
        dc.l    kc
        dc.l    kv
        dc.l    kb      ;30
        dc.l    kn
        dc.l    km
        dc.l    comma
        dc.l    period
        dc.l    fslash
        dc.l    rshf
        dc.l    0
        dc.l    alt
        dc.l    spcbar
        dc.l    caploc
        dc.l    f1
        dc.l    f2
        dc.l    f3
        dc.l    f4
        dc.l    f5
        dc.l    f6      ;40
        dc.l    f7      
        dc.l    f8
        dc.l    f9
        dc.l    f10
        dc.l    0
        dc.l    0
        dc.l    home
        dc.l    upar
        dc.l    0
        dc.l    minus   ;4a
        dc.l    lar
        dc.l    0
        dc.l    rar
        dc.l    plus
        dc.l    0
        dc.l    dnar    ;50
        dc.l    0
        dc.l    insert
        dc.l    del     ;53
        dc.l    0,0,0,0,0,0,0,0,0,0,0,0         ;54-59
        dc.l    iso
        dc.l    undo    
        dc.l    help
        dc.l    lparen
        dc.l    rparen
        dc.l    fslash
        dc.l    asterisk
        dc.l    k7
        dc.l    k8
        dc.l    k9
        dc.l    k4
        dc.l    k5
        dc.l    k6
        dc.l    k1
        dc.l    k2
        dc.l    k3
        dc.l    zero    ;70
        dc.l    period
        dc.l    enter

*       Key messages
escape: dc.b    $1b,eot
k1:     dc.b    '1',eot
k2:     dc.b    '2',eot
k3:     dc.b    '3',eot
k4:     dc.b    '4',eot
k5:     dc.b    '5',eot
k6:     dc.b    '6',eot
k7:     dc.b    '7',eot
k8:     dc.b    '8',eot
k9:     dc.b    '9',eot
k0:     dc.b    '0',eot
minus:  dc.b    '-',eot
plus:   dc.b    '+',eot
equal:  dc.b    '=',eot
bacsp:  dc.b    'BS',eot
tabk:   dc.b    'TB',eot        ;TAB
kq:     dc.b    'Q',eot
kw:     dc.b    'W',eot
ke:     dc.b    'E',eot
kr:     dc.b    'R',eot
kt:     dc.b    'T',eot
ky:     dc.b    'Y',eot
ku:     dc.b    'U',eot
ki:     dc.b    'I',eot
ko:     dc.b    'O',eot
kp:     dc.b    'P',eot
lbrack: dc.b    '[',eot
rbrack: dc.b    ']',eot
retk:   dc.b    ' ',lf,8,' ',lf,8,8,'RT',eot ;RETURN
cntl:   dc.b    'CTL',eot       ;CTL
ka:     dc.b    'A',eot
ks:     dc.b    'S',eot
kd:     dc.b    'D',eot
kf:     dc.b    'F',eot
kg:     dc.b    'G',eot
kh:     dc.b    'H',eot
kj:     dc.b    'J',eot
kk:     dc.b    'K',eot
kl:     dc.b    'L',eot
semi:   dc.b    ';',eot
rapos:  dc.b    $27,eot
lapos:  dc.b    $60,eot
lshf:   dc.b    ' SH ',eot
bslash: dc.b    '\\',eot
kz:     dc.b    'Z',eot
kx:     dc.b    'X',eot
kc:     dc.b    'C',eot
kv:     dc.b    'V',eot
kb:     dc.b    'B',eot
kn:     dc.b    'N',eot
km:     dc.b    'M',eot
comma:  dc.b    ',',eot
period: dc.b    '.',eot
fslash: dc.b    '/',eot
rshf:   dc.b    'SH',eot        ;R SHIFT
alt:    dc.b    'AL',eot        ;ALT
spcbar: dc.b    '      SPACE      ',eot
caploc: dc.b    'CL',eot        
f1:     dc.b    'F1',eot
f2:     dc.b    'F2',eot
f3:     dc.b    'F3',eot
f4:     dc.b    'F4',eot
f5:     dc.b    'F5',eot
f6:     dc.b    'F6',eot
f7:     dc.b    'F7',eot
f8:     dc.b    'F8',eot
f9:     dc.b    'F9',eot
f10:    dc.b    'F10',eot
home:   dc.b    'H',eot         
upar:   dc.b    1,eot   
lar:    dc.b    4,eot
rar:    dc.b    3,eot
dnar:   dc.b    2,eot
insert: dc.b    'I',eot         
del:    dc.b    'D',eot         
iso:    dc.b    ' ',eot         ;transparent in U.S. version
undo:   dc.b    'UN',eot        
help:   dc.b    'HP',eot        
lparen: dc.b    '(',eot
rparen: dc.b    ')',eot
asterisk: dc.b  '*',eot
zero:   dc.b    '0  ',eot
enter:  dc.b    'E',lf,8,' ',lf,8,' ',eot 
numsgn: dc.b    '#',eot         ;UK 2B keycode
keytstm: dc.b   'Keyboard test',eot
mousmsg: dc.b   'MOUSE',eot
sret:   dc.b    'RT',eot
senter: dc.b    'ENTER',eot
sspace: dc.b    'SPACE',eot

*       error messages
kstuck: dc.b    cr,lf,'K0 Stuck key: ',eot      
kbto:   dc.b    cr,lf,'K1 Keyboard not responding',cr,lf,eot
kbresm: dc.b    cr,lf,'K2 Keyboard status error',cr,lf,eot      

ukkey:  dc.b    tab,'European keyboard (U.K. keytops shown)',cr,lf
        dc.b    tab,'Press keys and watch screen to verify closure',cr,lf,eot
uskey:  dc.b    tab,'U.S. keyboard',cr,lf
        dc.b    tab,'Press keys and watch screen to verify closure',cr,lf,eot
escmsg: dc.b    tab,'Hit shift Esc to exit',eot

