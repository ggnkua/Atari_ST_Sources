			opt s-
sector	equ.w 10
			move.w #0,track
			pea cls				;display header
			move.w #9,-(sp)
			trap #1
			addq.l #6,sp
			move.w #7,-(sp)			;wait key
			trap #1
			addq.l #2,sp
			pea go				;display start
			move.w #9,-(sp)
			trap #1
			addq.l #6,sp
read			move.w #sector,-(sp)		;read track
			move.w #0,-(sp)
			move.w track,-(sp)
			move.w #1,-(sp)
			move.w #0,-(sp)
			clr.l -(sp)
			pea $60000
			move.w #8,-(sp)
			trap #14
			add.l #20,sp
			pea prin			;display filename
			move.w #9,-(sp)
			trap #1
			addq.l #6,sp
write			move.w #0,-(sp)			;create file
			pea file
			move.w #$3c,-(sp)
			trap #1
			addq.l #8,sp
			move.w d0,d7
			pea $60000			;write file
			move.l #sector*$200,-(sp)
			move.w d7,-(sp)
			move.w #$40,-(sp)
			trap #1
			add.l #12,sp
			move.w d7,-(sp)			;close file
			move.w #$3e,-(sp)
			trap #1
			addq.l #4,sp
			addq.b #1,(file+9)		;next filename
			cmp.b #":",(file+9)
			bne ok
			move.b #"0",(file+9)
			addq.b #1,(file+8)
ok			addq.w #1,track
			cmp.w #80,track			;last track ?
			bne read
			pea end				;display end
			move.w #9,-(sp)
			trap #1
			addq.l #6,sp
			move.w #7,-(sp)			;wait key
			trap #1
			addq.l #2,sp
			clr.w -(sp)			;exit
			trap #1
track			dc.w 0
prin			dc.b 10,13
file			dc.b "l:\0\trk00",0,0
cls			dc.b 27,'E',27,'f'
			dc.b "Zip-Load V1.00",10,13
			dc.b "Raw Track to File Converter.",10,10,13
			dc.b "Insert Source Disk in Drive A",10,13
			dc.b "Insert Destination Disk in Drive B",10,10,13
			dc.b "Press any key to begin conversion...",10,10,13,0
go			dc.b "Conversion in Progress....",10,13,0
end			dc.b 10,10,13
			dc.b "Track Conversion Complete !!!",0
			