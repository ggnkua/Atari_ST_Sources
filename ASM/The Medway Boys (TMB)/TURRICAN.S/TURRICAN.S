; This is the source for playing back the music from Turrican.
;
; The sample drums install on $114.w
; If you have ever tried to rip this music (or the Wings of Death
; music) then you'll have noticed that the sample drums don't play
; properly, although the sound chip music does.
; This is because the mfp is still in software end of interrupt
; mode (ie. at the end of your mfp interrupt you have to clear the
; interrupt in service bit, or all other lower priority interrupts
; will be masked out). The music player used in these games does
; not clear this bit, so it must be executed in automatic end of
; interrupt mode, where the mfp handles these bits accordingly.
; The music from turrican is also called a bit differently.
; As well as the usual music number on D0, you also have to pass
; the start of the music data being used in A0, thus you could have
; all four bits of music data in memory (as well as the play routine)
; and play back all the tunes just by chaning A0/D0 when you call the
; setup routine.
;
; The playback routine used in this game was not fully relocatable,
; so I've made a few minor modifications to it so that it can now
; be loaded anywhere without having to relocate it.
;
; Zippy
;
	opt s-				;no labels
	clr.l -(sp)			;super mode
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	bclr #0,$484.w			;no keyclick
	lea store(pc),a0		;store vectors
	move.l $70.w,(a0)+		
	move.l $114.w,(a0)+		
	move.b $fffffa09.w,(a0)+	;mfp registers
	move.b $fffffa15.w,(a0)+
	move.b $fffffa17.w,(a0)+
	move.b $fffffa1d.w,(a0)+
	moveq #2,d0			;music number
	lea music1,a0			;music data
	jsr music			;setup music
	jsr (music+8)			;setup music
	bclr #3,$fffffa17.w		;put mfp into automatic
					;end of interrupt mode
	move.l #int,$70			;new vbl
	move.w #7,-(sp)			;get key
	trap #1
	addq.l #2,sp
	move.w sr,-(sp)			;restore everything
	move.w #$2700,sr		;disable ints
	lea store(pc),a0		;restore vectors
	move.l (a0)+,$70.w
	move.l (a0)+,$114.w
	move.b (a0)+,$fffffa09.w	;restore mfp registers
	move.b (a0)+,$fffffa15.w
	move.b (a0)+,$fffffa17.w
	move.b (a0)+,$fffffa1d.w
	lea $ffff8800.w,a0		;clear sound registers
	move.l #$0707ffff,(a0)
	move.l #$08080000,(a0)
	move.l #$09090000,(a0)
	move.l #$0a0a0000,(a0)
	move.b #$c0,$fffffa23.w		;reset keyboard repeat
	bset #0,$484.w			;keyclick on
	move.w (sp)+,sr			;restore status register
	clr.w -(sp)			;exit
	trap #1
int	movem.l d0-d7/a0-a6,-(sp)	;new vbl handler
	jsr (music+4)			;play music
	movem.l (sp)+,d0-d7/a0-a6
	rte				;exit
store	dc.l 0,0,0,0				;free space for store
music	incbin 'turrican.mus\turrican.mus'	;music player
music1	incbin 'turrican.mus\music4.dat		;music data (1-4)

