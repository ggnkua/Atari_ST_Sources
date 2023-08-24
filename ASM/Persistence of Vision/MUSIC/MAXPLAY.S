; This source code and all music hacks by Zippy !!
;
; I might do a mega-music demo at some point in the near future, with
; a different music on every key of the ST Keyboard and a nice hardware
; scrolling intro. Just wait and see what appears over the next few
; months....
;
; The music files on this disk are numbered from 1 to 20 ie. 'MAX1.MUS' to
; 'MAX20.MUS'. I've given them this format of filename so that you can
; listen to them all by just re-assembling this code and not having to
; quit back to desktop to find the next filename.
;
; Please Note : Not all of the music on this disk is actually by Mad Max
; (Jochen Hippel). Some of it is by An Cool (TCB), Galtan 6 and probably
; even someone else I can't remember right now !!
;
; If you want to have the music playing in the background (while you use
; a word processor etc.), then you should exit with a Terminate and Stay
; Resident (TSR) call, instead of a Term call. To do this, you should
; add the following lines in between the 'clr.w -(sp)' and 'trap #1'.
;
;	pea $5000			length to protect
;	move.w #$31,-(sp)		TSR call
;
; You should also remove the four lines after the line 'bsr on', so
; that the music is not switched off, and the program does not wait
; for a keypress.
;
; I've made a few changes to this playback routine, cause it seems
; that a few people were having trouble using the music on their
; menus/intros/demos whatever.
; Apparently the problem was that although they could get it to play
; using this file, they couldn't include it properly along with their
; own code....  So to make this a lot easier, I've now changed it so
; that all you have to do is 'bsr on' and 'bsr off' to start and
; stop the music. Hopefully this will overcome the problem of not
; knowing which bits of code to put where, and when to call them.
; As usual change the 'moveq #1,d0' to the music number that you want to
; play. Note that both the 'on' and 'off' routines must be called from
; supervisor mode. (If you don't know what that is then don't even bother
; trying to use this source !!!).
; If you want to include some of your own code on the vbl as well, then it
; should be pretty easy to make the necessary additions. Remember that if
; your vbl handler is very tight for processor time, then exit it with an
; 'rte' instruction, rather than returning to the old vbl handler as this
; performs a lot of unecessary bullshit for most intros !!!!
; Anyway, I hope this is of some use to hackers/coders alike, as I see a
; lot of nice demos with crap music (or no music!) presumably because the
; coder doesn't have time (or can't) rip out music !!
;
;
; Zippy   (11:58 PM, 12th November 1990)
;
	opt s-					no symbols
	clr.l -(sp)				dummy
	move.w #$20,-(sp)			super mode
	trap #1					call gemdos
	lea 6(sp),sp				correct stack
	move.l d0,oldstk			save old sp
	bclr #0,$484.w				no keyclick

	bsr on

	move.w #7,-(sp)				wait key
	trap #1					call gemdos
	lea 2(sp),sp				correct stack

	bsr off

	move.l oldstk,-(sp)			back into
	move.w #$20,-(sp)			user mode
	trap #1					call gemdos
	lea 6(sp),sp  				correct stack
	clr.w -(sp)				terminate
	trap #1					call gemdos

zippy	movem.l d0-a6,-(sp)			save registers
	bsr (music+8)				call playback
	movem.l (sp)+,d0-a6			restore registers
	move.l oldint,-(sp)			old vbl on sp
	rts					call old vbl

on	move.l $70.w,oldint			save old vbl
	moveq #1,d0				music #1
	bsr music				call init
	move.l #zippy,$70.w			install new vbl
	rts

off	move.l oldint,$70.w			restore old vbl
	move.l #$08080000,$ff8800		clear vol. chan A
	move.l #$09090000,$ff8800		clear vol. chan B
	move.l #$0a0a0000,$ff8800		clear vol. chan C
	rts

oldstk	dc.l 0
oldint	dc.l 0
music	incbin "max1.mus"			change this filename !!
