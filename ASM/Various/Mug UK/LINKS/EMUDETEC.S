; FOR ST Programmers - How to detect PaCifiST (0.46 of greater)
;
; When Vsync is called with D6=D7='Emu?' and those registers are
; altered, you can assume you're running under an Emulator.
;
; If D6='PaCi' & D7='fiST', then it's under PaCifiST and A0 points out
; some extra hardware registers:
;
; 0     BYTE    major version (BCD)
; 1     BYTE    minor version (BCD)
;
; Special registers will be added with each version



        move.l  #'Emu?',d5
        move.l  d5,d7
        move.l  d5,d6
        move    #$25,-(a7)
        trap    #$e
        addq.l  #2,a7
        move.l  a0,regbase

        cmp.l   d5,d6
        bne.s   under_emu
        cmp.l   d5,d7
        beq.s   normal_st
under_emu:
        cmp.l  #'PaCi',d6
        bne.s  other_emu
        cmp.l  #'fiST',d7
        bne.s  other_emu

        pea     super(pc)
        move.w  #$26,-(a7)
        trap    #$e
        addq.l  #6,a7
        lea     pacifist_emu(pc),a0
        bra.s   print
other_emu:
        lea     an_emu(pc),a0
	bra.s	print
normal_st:
        lea     no_emu(pc),a0
print:
        pea     (a0)
        move    #9,-(a7)
        trap    #1
        addq.l  #6,a7
        move    #1,-(a7)
        trap    #1
        addq.l  #2,a7
        clr.w   -(a7)
        trap    #1

super:
        move.l  regbase(pc),a0
        move.b  (a0),d0
        add.b   d0,majorv
        move.b  1(a0),d0
        move    d0,d1
        lsr     #4,d1
        and     #$f,d0
        and     #$f,d1
        add.b   d1,minorv
        add.b   d0,minorv+1
        rts

	SECTION DATA

regbase	dc.l	0

no_emu:
        dc.b    "It seems you're running under a",13,10
        dc.b    "mere ST.",0
an_emu:
        dc.b    "It seems you're running under an",13,10
        dc.b    "emulator.",0
pacifist_emu:
        dc.b    "You're running under PaCifiST",13,10,"v"
majorv: dc.b    "0."
minorv: dc.b    "00.",0

