		pea	StartSuper(PC)
		move.w	#38,-(a7)
		trap	#14
		addq.l	#2,a7
		tst.w	INSTALLED_F
		bne.s	No_Oc
		
No_Oc		clr.w	-(a7)
		trap	#1

StartSuper:     move    #$2300,sr
                movea.l $98.w,a0
                cmpi.l  #'ILAK',2(a0)
                bne.s   NIXNIXI
                cmpi.w  #$0105,6(a0)
                blo.s   NIXNIXI
		move.w	#0,INSTALLED_F
                moveq   #7,d0			get MENY addr
                trap    #6
                move.l  a0,MENUADDR
                rts
                moveq   #7,d0
                trap    #6
                lea     MENUADDR(pc),a1
                move.l  a0,(a1)
NIXNIXI:        lea     OCNOTFOUND(pc),a0
                bsr     PRINTINP
                move.w	#-1,INSTALLED_F
                rts
INSTALLED_F:	dc.w 0
OCNOTFOUND:     dc.b 27,"E"
                dc.b "Sorry Pal, You must have Omega Commands Version 1.05",13,10
		dc.b "or higher installed in memory!!",0
                even

Do_Menu_Super:  movea.l MENUADDR(pc),a0
                lea     TEXTEN(pc),a1
                move.l  a1,2(a0)
                move.w  #0,6(a0)
                lea     MENUAREA(pc),a1
                move.l  a1,16(a0)
                move.w  #0,20(a0)
                jsr     (a0)
		move.w	d0,Result
		rts
Result:		dc.w	0


MAINLOOP:

                cmp.w   #5,d0
                beq.s   EXIT
                cmp.w   #1,d0
                bne.s   NOTEXAM         ; examine disc
                bsr     EXAMINE
                bra.s   MAINLOOP
NOTEXAM:        cmp.w   #2,d0
                bne.s   NOTELIM
                bsr.s   ELIMINATE
                bra.s   MAINLOOP
NOTELIM:        cmp.b   #$03,d0
                bne.s   NOTSAVEB
                bsr     SAVEBLOCK       ; save bootblock as file
                bra.s   MAINLOOP
NOTSAVEB:       cmp.b   #$04,d0
                bne.s   MAINLOOP
                bsr     COPYBOOT        ; copy boot block
                bra.s   MAINLOOP

EXIT:           rts
                endpart

