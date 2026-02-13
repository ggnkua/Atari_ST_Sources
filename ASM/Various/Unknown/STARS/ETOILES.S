h=$10000

mod=0
arg=4
vmod=8
amod=12
varg=16
adr=20
img=24
vmodd=28

n_data=32
n_etoiles=200

main:
	pea debut(pc)
	move.w #38,-(sp)
	trap #14
	addq.l #6,sp
	clr.w -(sp)
	trap #1

debut:
	move.w #4,-(sp)
	trap #14
	move.w d0,save_rez
	move.w $ffff8240,save_color0
	move.w $ffff8242,save_color1
	move.l $70,save_vbl
	move.l $fffffa06,save_mfp
	
	clr.w -(sp)
	move.l #-1,-(sp)
	move.l #-1,-(sp)
	move.w #5,-(sp)
	trap #14
	
	move.w #37,-(sp)
	trap #14
	add.l #16,sp
	
	clr.w $ffff8240
	move.w #$777,$ffff8242
	clr.b $fffffa07
	move.b #%1000000,$fffffa09
	move.l #vbl,$70

attent:	move.w #7,-(sp)
	trap #1
	addq.l #2,sp

	move.w save_color0,$ffff8240
	move.w save_color1,$ffff8242
	move.l save_vbl,$70
	move.l save_mfp,$fffffa06
	move.w save_rez,-(sp)
	move.l #-1,-(sp)
	move.l #-1,-(sp)
	move.w #5,-(sp)
	trap #14
	add.l #12,sp
	
	rts
	
etoiles:
	lea sin(pc),a6
	lea cos(pc),a5
	move.l $44e,a4
	lea data_etoiles(pc),a0
	move.w #n_etoiles-1,d7

boucle_etoiles:
	move.w adr(a0),d1
	move.w img(a0),d0
	not.w d0
	and.w d0,(a4,d1.w)
	
	move.l arg(a0),d0
	add.l varg(a0),d0
	move.l d0,arg(a0)
	swap d0
	and.w #$7fe,d0
	
	move.l mod(a0),d1
	move.l vmod(a0),d5
	add.l amod(a0),d5
	move.l d5,vmod(a0)
	add.l d5,d1
	move.l d1,mod(a0)
	swap d1
	
	move.w 0(a6,d0.w),d2
	move.w 0(a5,d0.w),d3
	muls d1,d2
	muls d1,d3
	rol.l #1,d2
	swap d2
	rol.l #1,d3
	swap d3
	
	add.w #100,d2
	bmi pas_affiche
	cmp.w #199,d2
	bpl pas_affiche
	
	add.w #160,d3
	bmi pas_affiche
	cmp.w #319,d3
	bpl pas_affiche
	
	move.w d3,d4
	
	mulu #160,d2
	lsr.w #1,d3
	and.w #$fff8,d3
	add.w d3,d2
	
	and.w #15,d4
	add.w d4,d4
	move.w table_images(pc,d4.w),d4
	or.w d4,(a4,d2.w)
	move.w d4,img(a0)
	move.w d2,adr(a0)
	add.l #n_data,a0
	dbra d7,boucle_etoiles
	
	rts

pas_affiche:
	move.l vmodd(a0),vmod(a0)
	clr.l mod(a0)
	add.l #n_data,a0
	dbra d7,boucle_etoiles
	rts
	
table_images:
	dc.w 32768,16384,8192,4096,2048,1024,512,256
	dc.w 128,64,32,16,8,4,2,1

vbl:
	movem.l d0-d7/a0-a6,-(sp)
	bsr etoiles
	movem.l (sp)+,d0-d7/a0-a6
	rte
	
save_rez dc.w 0
save_vbl dc.l 0
save_mfp dc.l 0
save_color0 dc.w 0
save_color1 dc.w 0

data_etoiles incbin "a:\det.b"
sin incbin "a:\sin.b"
cos equ sin+512
end