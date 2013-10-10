*** HLS DUMPER ***
* Dumps those encrypted executables used in games protected with
* HLS protection (i think thats the name)
* tested with impossible mission 2 and dive bomber

start
			
			movea.l a7,a5 
			lea     start(pc),a7
			move.l  4(a5),a5
			move.l  $c(a5),d0
			add.l   $14(a5),d0
			add.l   $1c(a5),d0
			add.l   #$100,d0

			move.l  d0,-(a7)
			move.l  a5,-(a7)
			clr.w   -(a7)
			move.w  #$4a,-(a7)
			trap    #1
			adda.l  #12,a7

			clr.l	-(sp)
			move.w	#$20,-(sp)
			trap	#1
			addq.l	#6,sp

			dc.w	$a00a

alku:			pea		text(pc)
			move.w	#9,-(sp)
			trap	#1
			addq.l	#6,sp

			pea		file1name(pc)
			move.w	#9,-(sp)
			trap	#1
			addq.l	#6,sp
			
			pea		cursor(pc)
			move.w	#9,-(sp)
			trap	#1
			addq.l	#6,sp

			pea		input_loadname(pc)
			move.w	#$a,-(sp)		input filename
			trap	#1
			addq.l	#6,sp

			pea		file2name(pc)
			move.w	#9,-(sp)
			trap	#1
			addq.l	#6,sp

			pea		cursor2(pc)
			move.w	#9,-(sp)
			trap	#1
			addq.l	#6,sp

			pea		input_savename(pc)
			move.w	#$a,-(sp)		input filename
			trap	#1
			addq.l	#6,sp


			pea		cursor3(pc)
			move.w	#9,-(sp)
			trap	#1
			addq.l	#6,sp

			pea     null(pc)
			pea     null(pc)
			pea     loadname(pc)     ; filename to load
			move.w  #3,-(a7)				 ; LOAD BUT DON'T EXECUTE
			move.w  #$4b,-(a7)				 ; P_EXEC
			trap    #1
			lea     16(a7),a7  
			move.l	d0,d7
			tst.l	d0
			bmi.b	error
			
			move.l	d0,baseaddr
			movea.l	d0,a0
			move.l	$100(a0),ep_bytes	;we need to store the original 
										;bytes at the entrypoint to see
										;when they have been changed

			lea		$8.w,a0				;save all exceptions
			lea		tex(pc),a1			;vectors, interrupts,
			move.w	#($200-$8)/2-1,d1	;etc. etc.
save		move.w	(a0)+,(a1)+
			dbf		d1,save

			move.l	$84.w,oldtrap1+2	save old timer C
			move.l	#mytrap1,$84.w	patch my timer C
			
			move.l  d7,-(a7)
			move.l  d7,-(a7)
			move.l	d7,-(a7)
			move.w  #4,-(a7)        ; RUN PROGRAM IN MEMORY
			move.w  #$4b,-(a7)      ; P_EXEC
			trap    #1
			lea     16(a7),a7 


			clr.w	-(sp)
			trap	#1

error:		pea		errormsg(pc)
			move.w	#9,-(sp)
			trap	#1
			addq.l	#6,sp
			
			move.w	#7,-(sp)
			trap	#1
			addq.l	#2,sp
			
			jmp	alku(pc)
			
			clr.w	-(sp)
			trap	#1

*******************************************************************************
mytrap1			eor.w	#$123,$ffff8240	
			movem.l	d0-d7/a0-a6,-(sp)
			
;			add.b	#1,trap_cnt
;			cmp.b	#3,trap_cnt	
;			ble.w	notyet		
			
			move.l	baseaddr,d0
			cmp.l	d0,a6
			bne.w	notyet
			move.l	$100(a6),d0
			cmp.l	ep_bytes,d0
			beq.w	notyet				;it can be dumped

			move.l	8(a6),d0
			sub.l	#$1c,d0
			move.l	d0,filestart
			movea.l	d0,a0

			move.l	$c(a6),d1	;size of code
			move.l	$14(a6),d2	;size of data
			move.l	$1c(a6),d3	;size of bss

			move.l	#$601a0000,(a0)	;lets create the exec header
			move.l	d1,2(a0)	

			suba.l	#12,a3
			movea.l	a3,a2		
			movea.l	a3,a1
			suba.l	d0,a2		;a2 has now correct filesize
			move.l	a2,filesize

			add.l	#$1c,d1
			suba.l	d1,a2

;a3 points to end of reloc table, now we need to scan where it starts
			suba.l	#2,a3
scanreloc:		cmp.w	#$0000,-(a3)
			bne.s	scanreloc

			suba.l	a3,a1	;now we know the size of reloc table
			suba.l	a1,a2	;reloctable size - data size = real data sz
			move.l	d2,d1
			move.l	a2,d2
			move.l	d2,6(a0)
			sub.l	a2,d1

			add.l	d1,d3
			move.l	d3,$a(a0)

		
			move.w	#$2700,sr		
			move.w	#$777,$ffff8240.w	
			lea		tex(pc),a0		
			lea		$8.w,a1
			move.w	#($200-$8)/4-1,d0
copy		move.l	(a0)+,(a1)+
			dbf		d0,copy

			movem.l	(sp)+,d0-d7/a0-a6
		
**** LETS SAVE THE FILE *******************************************************	
			pea		savename(pc)
			move.w	#$3c,-(sp)
			trap	#1
			addq.l	#8,sp
			move.w	d0,d7
			
			move.l	filestart,-(sp)		;save from 
			move.l	filesize,-(sp)	;
			move.w	d0,-(sp)
			move.w	#$40,-(sp)
			trap	#1
			lea		12(sp),sp
		
			move.w	d7,-(sp)
			move.w	#$3e,-(sp)
			trap	#1
			addq.l	#4,sp

			clr.w	-(sp)
			trap	#1

notyet			movem.l	(sp)+,d0-d7/a0-a6
oldtrap1		jmp	0					;do old trap 1


	data
	ds.l	400

trap_cnt	dc.w	0	
filesize	dc.l	1
filestart	dc.l	1
null		dc.l 	0
baseaddr	dc.l 	0
ep_bytes	dc.l 	0

errormsg	dc.b	27,"E"
			dc.b	"File not found, check the filename and try again",0

text		dc.b	27,"E"
		dc.b	13,10,"HLS Dumper by Avenger",13,10
		dc.b	"Insert original disk to any drive and type the filename",13,10
		dc.b	"The protected exec can be run anywhere as long as",13,10
		dc.b	"Drive A or B has original disk",0
		dc.b	13,10,"",0	

cursor		dc.b	27,"e",27,"Y",38,47,0
cursor2		dc.b	27,"e",27,"Y",39,47,0
cursor3		dc.b	27,"f",0

input_loadname	dc.b 30
				dc.b 13
loadname		ds.b 30

input_savename	dc.b 30
				dc.b 13
savename		ds.b 30
				
file1name	dc.b 13,10,13,10,"File to load > "		default filename
file2name	dc.b       13,10,"File to save > "

	bss

tex	ds.l	$200-$8/4		space to save exceptions
end