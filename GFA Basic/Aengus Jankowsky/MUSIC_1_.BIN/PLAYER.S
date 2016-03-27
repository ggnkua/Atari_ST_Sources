;OFFSETS FOR MUSIX...THUNDER.BIN = +$64....BRAINPOW.BIN = +$B0
;CYBERNOD.BIN = +$2A....STARQUAK = (INIT VALUE = +$4D2) +$28
;MUSIC5.BIN = +$10A....leather.bin = +$126...famous.bin = +$2a
;renegade.bin = (init value = +$ce) +$1ca....xenon.bin = +$112
;enduro.bin = +278...bbc.bin = +156....bbc_1.bin = + 116
;monty.bin = +840....mindbomb.bin = +168....rampage.bin = +$106
;butcher.bin = +4....genesis.bin = +$106....vixen.bin (init value = $4d2)
;.vbl value = $28....tetris.bin = $112....lemmings.bin = +2
;resol101.bin (init value $9c) = +$a....l_t_e.bin = +4
;starfire.bin = +4....feardrop.bin = +4....get_wckd.bin = +4
;sanxion.bin = +4....killer.bin = +4....north.bin = (inti $c) = $6c
;FOUNDAT.BIN = +2.....switch.bin = +4.....music3.bin = +4
;1943.bin = (init $4e2) = +$28.....outrun.bin (init +$546) = +$28
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,save
	
	bchg	#0,$484
	
	pea	mess		
	move.w	#9,-(sp)	
	trap	#1		
	addq.l	#6,sp		
 	
	move.l	#0,d0          ;the tune number..
	jsr	muz+$4d2            ;init value added onto this.
	
loop1	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	
	jsr	muz+$28        ;the offset
	
	move.w	#$ff,-(sp)
	move.w	#6,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.w	d0
	beq	loop1

	bchg	#0,$484
	
      move.b  #8,$00FF8800.L
      clr.b   $00FF8802.L 
      move.b  #9,$00FF8800.L
      clr.b   $00FF8802.L 
      move.b  #$A,$00FF8800.L 
      clr.b   $00FF8802.L 
      bset    #0,$00000484.L

	move.l 	save,-(Sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	
	clr.l	-(sp)
	trap	#1

	even	
save	ds.l	1
	even
mess	dc.b	27,"E",27,"B",27,"M"
		;1111111111111111111111111111111111111111 ;40 characters low res
	dc.b	"Welcome to Music Disk 1",13,10,10
	DC.B    "Compiled by Aengus Jankowsky (04.09.97).",13,10,10
	DC.B    "",13,10
	DC.B    "The tunes on this disk were ripped by",13,10
	DC.B    "many different people so a credits part",13,10
	DC.B    "is pretty much impossible (not that I'd",13,10
	DC.B    "remember at this stage ;) )",13,10,10
	DC.B    "Bear in mind that the Mad Max folder",13,10
	DC.B    "contains tunes by other authors aswell,",13,10
	DC.B    "it's just that the offset is the same",10,13
	DC.B    "for all the tunes contained therein.",10,13,10,10
	DC.B    "Have fun. Aengus - ajankows@iol.ie",0
muz	incbin	starquak.bin                ;change file name
	