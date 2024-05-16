; .ASM to .BIN runner
; 26/1/94 by Tay.

; Version 2 for different folders 18/4/95

app	macro
	dc.b	'c:\\apps\\program\\ttp\\'
	endm

; Address of our .ASM file:

source	macro
	dc.b	'd:\\dsp\\asm\\'
	endm

lod	macro
	dc.b	'd:\\dsp\\lod\\'
	endm


	output	c:\apps\program\ttp\asm2dsb.ttp



	move.l a7,a5
	move.l 4(a5),a5
	move.l $c(a5),d0
	add.l $14(a5),d0
	add.l $1c(a5),d0
	add.l #500,d0
	move.l d0,d1
	add.l a5,d1
	and.l #-2,d1
	move.l d1,a7
	move.l d0,-(a7)
	move.l a5,-(a7)
	pea $4a0000
	trap #1
	lea 12(a7),a7

	bsr convert_cli

	lea text1(pc),a0
	bsr print

; First, run assembler
	pea fake_env(pc)
	pea asm_cli(pc)
	pea asm_file(pc)
	pea $4b0000
	trap #1
	lea 16(a7),a7

	lea text2(pc),a0
	bsr print

; run cld-->lod
	pea fake_env(pc)
	pea cldlod_cli(pc)
	pea cldlod_file(pc)
	pea $4b0000
	trap #1
	lea 16(a7),a7

	lea text3(pc),a0
	bsr print

; Finally, run lod-->in
	pea fake_env(pc)
	pea lodcv_cli(pc)
	pea lodcv_file(pc)
	pea $4b0000
	trap #1
	lea 16(a7),a7

	lea text4(pc),a0
	bsr print

; Wipe out files:
	pea delete1(pc)
	move.w #$41,-(a7)
	trap #1
	addq.l #6,a7

	pea delete2(pc)
	move.w #$41,-(a7)
	;trap #1			;dont kill the lod
	addq.l #6,a7

	move.w #0,-(a7)
	trap #1

; ****** Subroutines ******

print:	pea (a0)
	move.w #9,-(a7)
	trap #1
	addq.l #6,a7
	rts

convert_cli:
; Make filename:
	bsr make_filename

; First, .asm command line:
; Output file first
; Then source file name

	lea asm_cli2(pc),a1
	bsr copyit
	move.b #".",(a1)+
	move.b #"a",(a1)+
	move.b #"s",(a1)+
	move.b #"m",(a1)+
	clr.b (a1)+
	move.l a1,d1
	sub.l #asm_cli+1,d1
	move.b d1,asm_cli

; CLD->LOD command line/filename:
	lea cldlod_cli2(pc),a1
	bsr copyit
	move.b #".",(a1)+
	move.b #"l",(a1)+
	move.b #"o",(a1)+
	move.b #"d",(a1)+

	clr.b (a1)+
	move.l a1,d1
	sub.l #cldlod_cli+1,d1
	move.b d1,cldlod_cli

; Finally LODcv command line/filename:
	lea lodcv_cli2(pc),a1
	bsr copyit
	move.b #".",(a1)+
	move.b #"l",(a1)+
	move.b #"o",(a1)+
	move.b #"d",(a1)+
	clr.b (a1)+
	move.l a1,d1
	sub.l #lodcv_cli+1,d1
	move.b d1,lodcv_cli
	rts

copyit:	lea our_filename(pc),a0
.getit	move.b (a0)+,d0
	beq.s .done

	move.b d0,(a1)+
	bra.s .getit
.done	rts

make_filename:				;(without extender)
	lea $81(a5),a0
	lea our_filename2(pc),a1
.getit	move.b (a0)+,d0
	beq.s .done

	move.b d0,(a1)+
	bra.s .getit
.done	clr.b (a1)+
	rts

	even

our_filename:
	;dc.b ""
our_filename2:
	ds.b 120

asm_file:
	app
	dc.b	"asm56000.ttp",0
	even
cldlod_file:
	app
	dc.b "cld2lod.ttp",0
	even
lodcv_file:
	app
	dc.b "lodcv.ttp",0

	even
asm_cli:
	dc.b 128,"-a -oIL -v -bd:\xyzzy.cld "	;change options if desired
	source

asm_cli2:
	ds.b 100				;be on safe side

	even
cldlod_cli:
	dc.b 128,"d:\xyzzy.cld "
	lod
cldlod_cli2:
	ds.b 128
	even

delete1:
	dc.b "d:\xyzzy.cld",0
	even

lodcv_cli:
	dc.b 128,"-b -ps -aw "
delete2:
	dc.b "d:\dsp\lod\"
lodcv_cli2:
	ds.b 128
	even

text1	dc.b 27,"EASM --> DSB by TaT",13,10
	dc.b "Version 1.1 April '95",13,10

	dc.b "Assembling.....",13,10,10,0
text2	dc.b 13,10,"Converting CLD to LOD...",13,10,0
text3	dc.b 13,10,"Converting LOD to DSB...",13,10,0
text4	dc.b "**** Assembly completed ****",0
	even
fake_env DC.B 0			;eurk


