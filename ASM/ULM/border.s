; Top border and hardscroll by Gunstick of ULM (c) 1991 and for all eternity... 

   [... lots of initialization skipped ...] 

        lea     my_stack,sp 
        bsr     waitvbl 
        endpart 

        bsr     tb_init 
        move.l  #my_vbl,$70.w 
        move    #$2300,sr 

        PART 'main' 

loop: 
        cmpi.b  #57,$fffffc02.w 
        beq     exit 
        cmpi.b  #58,$fffffc02.w 
        bne.s   noresync 

        bsr.s   tb_init 
        move.l  #my_vbl,$70.w 
        move    #$2300,sr 
noresync: 
        move.w  #0,$ffff8240.w 
        move.w  #$70,$ffff8240.w 

        bra.s   loop 

        endpart 

        PART 'my vbl' 
my_vbl: 
        movem.l d0-a6,-(sp) 

        bsr.s   tb_vbl_part 

        movem.l black(pc),d0-d7 
        movem.l d0-d7,$ffff8240.w 

        movem.l (sp)+,d0-a6 
        rte 
        endpart 
        >PART 'open upper border / hardscroll' 

; 0 = switch on 
; 10 = switch off 

tb_security equ 5 
tb_colors equ 0 
tb_do_overscan equ 0 
tb_do_hardscroll equ 0 
tb_digisound equ 10 
tb_nix_hbl equ 10 
tb_timer_a equ 0 
tb_timer_b equ 2 
tb_timer_c equ 4 
tb_timer_d equ 6 
tb_timer_used equ tb_timer_b     ; define which timer should be used 

        switch tb_timer_used 
        case 0                  ;timer a 
tb_timer_vec set $0134 
tb_bits set %100000 
tb_reg_offset set 0 
        case 2                  ;timer b 
tb_timer_vec set $0120 
tb_bits set %1 
tb_reg_offset set 0 
        case 4                  ;timer c 
tb_timer_vec set $0114 
tb_bits set %100000 
tb_reg_offset set 2 
        case 6                  ;timer d 
tb_timer_vec set $0110 
tb_bits set %10000 
tb_reg_offset set 2 
        ends 

        ifle tb_security 
        fail 'Security must be > 0' 
        endc 

tb_vbl_part: 
        ori.b   #tb_bits,tb_reg_offset+$fffffa07.w ;enable timer 

        move.b  #tb_security,tb_timer_used+$fffffa1f.w 
        move.l  #tb_timer,tb_timer_vec.w 

        if tb_colors=0 
        move.w  #$0111,$ffff8240.w 
        endc 

        rts 

tb_init: 
        clr.b   $fffffa07.w 
        clr.b   $fffffa09.w 

        move.l  #nix,$70.w      ;clr vbl vector 
        move.l  #nix,$68.w      ;clr hbl vector 
        move.l  #nix,tb_timer_vec.w ;clr timer vector 
        switch tb_timer_used 
        case 0 
        clr.b   $fffffa19.w     ;stop timer 
        case 2 
        clr.b   $fffffa1b.w     ;stop timer 
        case 4 
        andi.b  #$0f,$fffffa1d.w ;stop timer 
        case 6 
        andi.b  #$f0,$fffffa1d.w ;stop timer 
        ends 
        clr.b   tb_timer_used+$fffffa1f.w ;clr timer data register 
        stop    #$2300          ;kill pending vbl 
        stop    #$2300          ;wait vbl 

        moveq   #39,d0          ;len of top opener (old: 15-54) 
        dbra    d0,*-2 

        switch tb_timer_used 
        case 0 
        move.b  #$04,$fffffa19.w ;start timer with 1:50 
        case 2 
        move.b  #$04,$fffffa1b.w ;start timer with 1:50 
        case 4 
        ori.b   #$40,$fffffa1d.w ;start timer with 1:50 
        case 6 
        ori.b   #$04,$fffffa1d.w ;start timer with 1:50 
        ends 

        stop    #$2300          ;waitvbl 
        move.b  tb_timer_used+$fffffa1f.w,d1 ;get timer value after 1 vbl (=$D3) 

        neg.b   d1 
        sub.b   #3+tb_security,d1 
        move.b  d1,tb_timer_data 

        switch tb_timer_used 
        case 0 
        clr.b   $fffffa19.w     ;stop timer 
        case 2 
        clr.b   $fffffa1b.w     ;stop timer 
        case 4 
        andi.b  #$0f,$fffffa1d.w ;stop timer 
        case 6 
        andi.b  #$f0,$fffffa1d.w ;stop timer 
        ends 

        ori.b   #tb_bits,tb_reg_offset+$fffffa13.w ;unmask timer 

        stop    #$2300 

        moveq   #33,d0 
tb_open_hbl: 
        stop    #$2000 
        dbra    d0,tb_open_hbl 

        moveq   #1,d0 
        dbra    d0,*-2 

        ds.w 6,$4e71 

        move    #$2700,sr 
        pea     tb_init_done(pc) 
        move    sr,-(sp) 
        movem.l d0-a3,-(sp) 
        moveq   #0,d2 
        moveq   #0,d3 
        moveq   #0,d4 
        moveq   #0,d5 
        moveq   #0,d6 
        moveq   #0,d7 
        movea.l d2,a2 
        movea.l d2,a3 
        bra     tb_do_open_border 

tb_init_done: 
        rts 

        if tb_do_hardscroll=0 
tb_hwscrolltab: 
        path 'E:\SOURCES\HWSCROLL\' 
        ibytes 'HWDAT.BIN' 
        endc 

tb_timer: 
        move    #$2700,sr 

        if tb_colors=0 
        move.w  #$0707,$ffff8240.w 
        endc 

        move.l  $68.w,tb_old_hbl 
        if tb_nix_hbl=0 
        move.l  #nix,$68.w 
        endc 

        move.b  $fffffa07.w,tb_old_fa07 
        move.b  $fffffa09.w,tb_old_fa09 
        andi.b  #~tb_bits,(tb_reg_offset/2)*(tb_old_fa09-tb_old_fa07)+tb_old_fa07 ;disable timer 
        andi.b  #tb_bits,tb_reg_offset+$fffffa07.w 
        clr.b   (2-tb_reg_offset)+$fffffa07.w 

        move.l  #tb_timer1,tb_timer_vec.w 
        if tb_digisound=0 
        rte 
        else 
        stop    #$2400 
        endc 

tb_timer1: 
        if tb_colors=0 
        move.w  #$07,$ffff8240.w 
        endc 

        switch tb_timer_used 
        case 0 
        clr.b   $fffffa19.w     ;stop timer 
        case 2 
        clr.b   $fffffa1b.w     ;stop timer 
        case 4 
        andi.b  #$0f,$fffffa1d.w ;stop timer 
        case 6 
        andi.b  #$f0,$fffffa1d.w ;stop timer 
        ends 

        stop    #$2000 
        move.l  #tb_hbl,$68.w 
        stop    #$2000 

tb_hbl: 
        move    #$2700,sr 

        if tb_digisound=0 
        addq.l  #6,sp 
        else 
        lea     12(sp),sp 
        endc 

        if tb_colors=0 
        move.w  #$0777,$ffff8240.w 
        else 
        ds.w 4,$4e71 
        endc 

tb_old_hbl equ *+2 
        move.l  #nix,$68.w 

        movem.l d0-a3,-(sp) 

        ds.w 8,$4e71 

        opt O- 
        movem.l pal,d2-d7/a2-a3 
        opt O+ 

tb_do_open_border: 

tb_timer_data equ *+3 
        move.b  #0,tb_timer_used+$fffffa1f.w ;set timer data 
        andi.b  #~tb_bits,tb_reg_offset+$fffffa07.w ;disable timer 

        if tb_colors=0 
        move.w  #$77,$ffff8240.w 
        else 
        ds.w 4,$4e71 
        endc 

        clr.b   $ffff820a.w 

        moveq   #3,d0 
        dbra    d0,*-2 

        if tb_do_hardscroll=0 
tb_schaltnum equ *+2 
        opt O- 
        lea     tb_hwscrolltab,a0 ;3 
        opt O+ 
        tst.b   (a0)+           ;2 
        bne.s   tb_open_mitte   ;2 
        else 
        ds.w 7,$4e71 
        endc 

        move.b  #2,$ffff820a.w 

        lea     $ffff8209.w,a1 
        moveq   #10,d1 
tb_sync1: 
        move.b  (a1),d0 
        beq.s   tb_sync1 
        sub.b   d0,d1 
        lsl.l   d1,d1 

        switch tb_timer_used 
        case 0 
        nop 
        nop 
        move.b  #$04,$fffffa19.w ;start timer with 1:50 
        case 2 
        nop 
        nop 
        move.b  #$04,$fffffa1b.w ;start timer with 1:50 
        case 4 
        ori.b   #$40,$fffffa1d.w ;start timer with 1:50 
        case 6 
        ori.b   #$04,$fffffa1d.w ;start timer with 1:50 
        ends 

        move.b  #0,tb_timer_used+$fffffa1f.w ;set timer data register 

        if tb_do_hardscroll=0 

        move.b  #0,$ffff8260.w 
        move.b  #0,$ffff8260.w 
        moveq   #5,d0 
        bra     tb_into_cont3 

tb_open_mitte: 
        move.b  #2,$ffff820a.w 

        lea     $ffff8209.w,a1 
        moveq   #10,d1 
tb_sync1_: 
        move.b  (a1),d0 
        beq.s   tb_sync1_ 
        sub.b   d0,d1 
        lsl.l   d1,d1 

        switch tb_timer_used 
        case 0 
        nop 
        nop 
        move.b  #$04,$fffffa19.w ;start timer with 1:50 
        case 2 
        nop 
        nop 
        move.b  #$04,$fffffa1b.w ;start timer with 1:50 
        case 4 
        ori.b   #$40,$fffffa1d.w ;start timer with 1:50 
        case 6 
        ori.b   #$04,$fffffa1d.w ;start timer with 1:50 
        ends 

        move.b  #0,tb_timer_used+$fffffa1f.w ;set timer data register 

        move.b  #2,$ffff8260.w 
        move.b  #0,$ffff8260.w 
        moveq   #5,d0 
        bra     tb_into_cont3 

tb_switchloop: 
        tst.b   (a0)+ 
        bne.s   tb_links1 
        ds.w 23,$4e71 
        bra.s   tb_cont1 

tb_no_links equ *+2 
tb_links1: 
        move.b  #1,$ffff8260.w  ;GunsticK's right border end switch 
        move.b  #0,$ffff8260.w 
        ds.w 9,$4e71 
        move.b  #2,$ffff8260.w 
        move.b  #0,$ffff8260.w 
tb_cont1: 
        ds.w 28,$4e71 

        tst.b   (a0)+ 
        bne.s   tb_mitte 
        ds.w 6,$4e71 
        bra.s   tb_cont3 
tb_mitte: 
        move.b  #2,$ffff8260.w 
        move.b  #0,$ffff8260.w 
tb_cont3: 
        ds.w 6,$4e71 
tb_into_cont3: 
        move.w  d0,tb_ret_d0 
        move.b  1(a0),d0 
        ext.w   d0 
        neg.w   d0 
        move.w  d0,tb_no_links 
tb_ret_d0 equ *+2 
        move.w  #0,d0 

        ds.w 12,$4e71 

        tst.b   (a0)+ 
        bne.s   tb_rechts1 
        tst.b   (a0)+ 
        bne.s   tb_rechts2 
        ds.w 6,$4e71 
        bra.s   tb_cont4 

tb_rechts1: 
        move.b  #0,$ffff820a.w 
        addq.w  #1,a0 
        ds.w 3,$4e71 
        bra.s   tb_cont4 

tb_rechts2: 
        ds.w 4,$4e71 
        move.b  #0,$ffff820a.w 
tb_cont4: 
        move.b  #2,$ffff820a.w 
        dbra    d0,tb_switchloop 

        else 

        moveq   #19,d0 
        dbra    d0,*-2 
        nop 
        nop 

        endc 

        if tb_do_overscan=0 

        move.l  a3,$1c+$ffff8240.w 

        move.b  #1,$ffff8260.w 
        move.b  #0,$ffff8260.w 
        movem.l d2-d4,$ffff8240.w 
        move.b  #2,$ffff8260.w 
        move.b  #0,$ffff8260.w 

        movem.l d5-d7/a2,$0c+$ffff8240.w 

        else 

        movem.l d2-d7/a2-a3,$ffff8240.w 

        endc 

        if tb_do_hardscroll=0 

        move.b  $ffff8209.w,d1 

        opt O- 
        lea     screenad,a1 
        opt O+ 
scr_add_corr equ *+2 
        addi.l  #0,(a1) 
        moveq   #0,d2 
        move.b  3(a1),d2 
        move.w  d2,d0 
        add.w   d2,d2 
        add.w   d0,d2 
        add.w   d2,d2 
        add.w   d2,d2           ;*12 (24 byte per tabentry) 
        lea     tb_hwscrolltab(pc),a0 
        lea     0(a0,d2.w),a0 
        movep.w 1(a1),d2 
        move.b  2(a1),d2 
        move.b  (a0)+,d0 
        ext.w   d0 
        add.w   d0,d2 
        move.l  scr_add_corr(pc),d0 
        sub.l   d0,(a1) 
        lea     $ffff8201.w,a1 
        movep.w d2,0(a1) 
        move.l  a0,tb_schaltnum 

        andi.w  #$ff,d1 
        sub.b   $ffff8209.w,d1  ; sync 
        neg.b   d1 
        jmp     0(pc,d1.w) 
        ds.w 67,$4e71 

        else 

        ds.w 76,$4e71 

        endc 

        endpart 
        >PART '' 

        ifeq tb_do_overscan 
        rept 50 
        move.b  #0,$ffff820a.w  ;Open right border 
        move.b  #2,$ffff820a.w 
        ds.w 8,$4e71 
        move.b  #1,$ffff8260.w  ;GunsticK's right border end switch 
        move.b  #0,$ffff8260.w 
        ds.w 9,$4e71 
        move.b  #2,$ffff8260.w  ;Open left border 
        move.b  #0,$ffff8260.w 
        ds.w 87,$4e71 
        endr 
        endc 

        endpart 
        >PART 'end of tb' 
tb_old_fa07 equ *+3 
        move.b  #0,$fffffa07.w 
tb_old_fa09 equ *+3 
        move.b  #0,$fffffa09.w 
        movem.l (sp)+,d0-a3 
        rte 
        endpart

