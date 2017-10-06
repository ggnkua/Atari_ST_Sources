#NO_APP
gcc2_compiled.:
___gnu_compiled_c:
.text
	.even
__aes:
	movm.l #0x3020,-(sp)
	move.l 16(sp),a1
	move.w 20(sp),d3
	move.w d3,a2
	lea _ctrl_list,a0
	move.l (a0,a2.l*4),d0
	bfextu d0{#16:#8},d1
	bfextu d0{#8:#8},d2
	clr.b 32(a1)
	move.b d0,33(a1)
	move.w d1,30(a1)
	move.w d2,28(a1)
	moveq.l #24,d1
	lsr.l d1,d0
	move.w d0,26(a1)
	move.w d3,24(a1)
	moveq.l #55,d2
	not.b d2
#APP
	move.l d2,d0; move.l a1,d1; trap #2
#NO_APP
	move.w 120(a1),d0
	ext.l d0
	movm.l (sp)+,#0x40c
	rts
	.even
.globl _call_aes
_call_aes:
	link.w a6,#-16
	movm.l #0x2038,-(sp)
	move.l 18(a6),a2
	move.w 22(a6),d2
	cmp.w #1,16(a6)
	jbgt L4
	moveq.l #-25,d0
	jbra L3
	.even
L4:
	cmp.w #199,d2
	jble L5
	moveq.l #-32,d0
	jbra L3
	.even
L5:
	tst.l a2
	jbne L6
	move.l 8(a6),-(sp)
	jbsr _get_contrl
	move.l d0,a2
	addq.l #4,sp
L6:
	move.l #_sflags+16,d0
	move.l d0,a3
	tst.l (a3)
	jbeq L7
	move.b (a2),d0
L7:
	cmp.w #10,d2
	jbeq L8
	tst.w 56(a2)
	jbeq L175
L8:
	cmp.w #74,d2
	jbgt L45
	cmp.w #72,d2
	jbge L29
	cmp.w #12,d2
	jbeq L18
	jbgt L46
	cmp.w #10,d2
	jbeq L11
	jbra L10
	.even
L46:
	cmp.w #17,d2
	jbeq L22
	cmp.w #51,d2
	jbeq L23
	jbra L10
	.even
L45:
	cmp.w #130,d2
	jbeq L35
	jbgt L47
	cmp.w #91,d2
	jbeq L31
	jbra L10
	.even
L47:
	cmp.w #135,d2
	jbeq L42
	jbra L10
	.even
L11:
	tst.w 56(a2)
	jbeq L12
L175:
	moveq.l #-36,d0
	jbra L3
	.even
L12:
	clr.w d1
	lea (56,a2),a1
	.even
L16:
	move.w d1,a0
	clr.w (a1,a0.l*2)
	addq.w #1,d1
	cmp.w #15,d1
	jble L16
	move.w #-1,1348(a2)
	jbra L10
	.even
L18:
	tst.l (a3)
	jbeq L19
	move.l 152(a2),a0
	move.b (a0),d0
L19:
	move.w 90(a2),d0
	bftst d0{#28:#4}
	jbeq L20
	add.w #15,d0
	and.w #-16,d0
	move.w d0,90(a2)
L20:
	tst.l (a3)
	jbeq L10
	move.w d0,a0
	move.l 152(a2),a1
	move.b -1(a0,a1.l),d0
	jbra L10
	.even
L22:
	move.w #1,120(a2)
	jbsr __yield
	moveq.l #1,d0
	jbra L3
	.even
L23:
	move.w 88(a2),d0
	jbeq L10
	cmp.w #3,d0
	jbeq L10
L29:
	tst.l _sflags+40
	jbne L10
	move.w #1,120(a2)
	moveq.l #1,d0
	jbra L3
	.even
L31:
	tst.l (a3)
	jbeq L10
	move.l 152(a2),a0
	move.b (a0),d0
	move.l 156(a2),a0
	move.b (a0),d0
	move.l 160(a2),a0
	move.b (a0),d0
	jbra L10
	.even
L35:
	clr.w d1
	lea (120,a2),a1
	.even
L39:
	move.w d1,a0
	clr.w (a1,a0.l*2)
	addq.w #1,d1
	cmp.w #3,d1
	jble L39
	cmp.w #1023,56(a2)
	jbgt L10
	move.l a2,-(sp)
	jbsr _emu_appl_getinfo
	addq.l #4,sp
	jbra L3
	.even
L42:
	move.l a2,-(sp)
	jbsr _emu_form_popup
	addq.l #4,sp
	jbra L3
	.even
L10:
	move.w d2,d0
	add.w #-13,d0
	cmp.w #116,d0
	jbhi L48
	and.l #0xFFFF,d0
	.set LI161,.+2
	move.w L161-LI161.b(pc,d0.l*2),d0
	jmp %pc@(2,d0:w)
	.even
L161:
	.word L49-L161
	.word L55-L161
	.word L55-L161
	.word L48-L161
	.word L48-L161
	.word L177-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L61-L161
	.word L48-L161
	.word L61-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L177-L161
	.word L177-L161
	.word L177-L161
	.word L177-L161
	.word L71-L161
	.word L177-L161
	.word L71-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L177-L161
	.word L177-L161
	.word L177-L161
	.word L177-L161
	.word L177-L161
	.word L177-L161
	.word L177-L161
	.word L177-L161
	.word L48-L161
	.word L177-L161
	.word L177-L161
	.word L48-L161
	.word L177-L161
	.word L48-L161
	.word L177-L161
	.word L177-L161
	.word L177-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L177-L161
	.word L177-L161
	.word L48-L161
	.word L93-L161
	.word L48-L161
	.word L177-L161
	.word L177-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L99-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L177-L161
	.word L48-L161
	.word L48-L161
	.word L177-L161
	.word L177-L161
	.word L115-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L48-L161
	.word L118-L161
	.word L121-L161
	.word L177-L161
	.word L177-L161
	.word L177-L161
	.word L141-L161
	.word L141-L161
	.word L144-L161
	.word L149-L161
	.word L153-L161
	.even
L49:
	move.l 152(a2),a4
	move.l a4,d0
	moveq.l #16,d1
	lsr.l d1,d0
	jbeq L51
	cmp.l #65534,d0
	jbeq L51
	cmp.l #65535,d0
	jbne L50
L51:
	pea -8(a6)
	move.w #4,-(sp)
	move.l a2,-(sp)
	jbsr __appl_getinfo
	add.w #10,sp
	tst.w -6(a6)
	jbne L48
L50:
	tst.l (a3)
	jbeq L48
	move.b (a4),d0
	jbra L48
	.even
L55:
	move.l 152(a2),a0
	move.l (a3),d1
	jbeq L56
	move.b (a0),d0
L56:
	move.w 88(a2),d0
	muls.w #6,d0
	lea -1(a0,d0.w),a0
	tst.l d1
	jbeq L48
	jbra L176
	.even
L61:
	move.l 152(a2),a0
	move.l (a3),d1
	jbeq L62
	move.b (a0),d0
L62:
	add.w #15,a0
	tst.l d1
	jbeq L48
	jbra L176
	.even
L71:
	tst.l (a3)
	jbeq L48
	move.l 152(a2),a0
	move.b (a0),d0
	move.l 156(a2),a0
	jbra L176
	.even
L93:
	cmp.w #255,88(a2)
	jbne L48
	jbra L177
	.even
L99:
	move.w 90(a2),d0
	cmp.w #14,d0
	jbeq L102
	jbgt L110
	cmp.w #3,d0
	jbgt L48
	cmp.w #2,d0
	jblt L48
	jbra L106
	.even
L110:
	cmp.w #30,d0
	jbne L48
L102:
	move.l 88(a2),a0
	tst.l a0
	jbeq L48
	tst.l (a3)
	jbeq L48
	jbra L176
	.even
L106:
	tst.l (a3)
	jbeq L48
	move.l 88(a2),a0
	jbra L176
	.even
L115:
	pea -16(a6)
	move.w #4,-(sp)
	move.l a2,-(sp)
	jbsr __appl_getinfo
	add.w #10,sp
	tst.w -10(a6)
	jbeq L48
	jbra L177
	.even
L118:
	tst.l (a3)
	jbeq L48
	move.l 152(a2),a0
	move.b (a0),d0
	move.l 156(a2),a0
	jbra L176
	.even
L121:
	move.w 88(a2),d0
	cmp.w #7,d0
	jbeq L177
	jbgt L135
	cmp.w #4,d0
	jbeq L123
	jbra L48
	.even
L135:
	cmp.w #8,d0
	jbeq L128
	cmp.w #10,d0
	jbeq L177
	jbra L48
	.even
L123:
	move.l 152(a2),a0
	tst.l a0
	jbeq L48
	tst.l (a3)
	jbeq L48
	jbra L176
	.even
L128:
	tst.w 90(a2)
	jbeq L48
	jbra L177
	.even
L141:
	tst.l (a3)
	jbeq L48
	move.l 152(a2),a0
	move.b (a0),d0
	move.l 156(a2),a0
	jbra L176
	.even
L144:
	move.l 152(a2),a0
	tst.l a0
	jbeq L145
	tst.l (a3)
	jbeq L145
	move.b (a0),d0
L145:
	move.l 156(a2),a0
	tst.l a0
	jbeq L48
	tst.l (a3)
	jbeq L48
	jbra L176
	.even
L149:
	move.l (a3),d1
	jbeq L150
	move.l 152(a2),a0
	move.b (a0),d0
L150:
	move.l 156(a2),a0
	tst.l a0
	jbeq L48
	tst.l d1
	jbeq L48
	jbra L176
	.even
L153:
	move.w 90(a2),d0
	cmp.w #16,d0
	jbgt L48
	cmp.w #14,d0
	jblt L48
L177:
	tst.l (a3)
	jbeq L48
	move.l 152(a2),a0
L176:
	move.b (a0),d0
L48:
	move.w d2,-(sp)
	move.l a2,-(sp)
	jbsr __aes
	addq.l #6,sp
	cmp.w #19,d2
	jbeq L164
	cmp.w #130,d2
	jbeq L165
	jbra L3
	.even
L164:
	clr.w 56(a2)
	jbra L3
	.even
L165:
	tst.l d0
	jbne L3
	clr.w d1
	lea (120,a2),a1
	.even
L170:
	move.w d1,a0
	clr.w (a1,a0.l*2)
	addq.w #1,d1
	cmp.w #3,d1
	jble L170
L3:
	movm.l -32(a6),#0x1c04
	unlk a6
	rts
