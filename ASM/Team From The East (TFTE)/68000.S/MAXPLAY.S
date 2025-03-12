; The Voice nr 2
; Procedura odgrywania muzyki
; Redakcja dziekuje facetowi o pseudonimie MARCHEW, za udostepnienie tej
; procedury.
; Mamy madzieje, ze nie pogniewa sie, ze zamiescilismy ja w The Voice.
; 
; This is the source code for calling 'Mad Max' type musix
; It will also work with any other music that uses the same playback
; routines eg. An Cool musix used in TCB Demos !!!
;
; This is just a simple routine that sets up a new vbl handler
; to play back the music, and then exits with a 'Keep Process'
; call, so that the music will continue to play when you exit back
; to the desktop or load another GEM type program.
;
; Although all the music files ('.mus') on this disk have only got
; one tune in them, some others can have a lot more (Sometimes even
; as many as 10 in one file !!).
; To call the different tunes available from each music file, just
; change the '1' in the line 'moveq #1,d0' to whatever music number
; you want !!!
;
; If you want to use a different music, then just change the filename
; in the last line of this program to the name of any other music
; data file on this disk. (Apart from the 'chamber.s' file !!)
;
; I'll probably continue to release the music files as space fillers
; on later menus, so make sure you keep this routine safe !!!
;
; Now that the rest of the menu is finished, I can tell you exactly
; which music files I managed to fit onto this disk....
;
; sowhat.mus   sowhat1.mus   sowhat2.mus   sowhat3.mus   sowhat4.mus
; cuddly.mus   cuddly1.mus   cuddly2.mus   cuddly3.mus   track.mus
;
; It's fairly obvious where the 'sowhat' and 'cuddly' musix were
; ripped from, but I can assure you that the 'track.mus' file hasn't
; been used in a menu yet, 'cause I only ripped it from the TCB
; soundtracker this morning !!!
;
;
; Zippy
;
*****************************************************************
*           this procedure has been modyfied by MARCHEW         *
* but I'm not proud of it...  why? if you run it you'll know... *
*            see ya soon bro...   Keep Cool - Stay hip          *
*                                                  Marchew      *
*                                                       bye.....*
*****************************************************************

	opt s-					no symbols
	clr.l -(sp)				dummy
	move.w #$20,-(sp)			super mode
	trap #1					call dos
	addq.l #6,sp				correct stack
	move.l d0,oldstk			save old sp
	move.l $70.w,oldint			save old vbl
	bclr #0,$484.w				no keyclick
	moveq #1,d0				music #1
	bsr music				call init
	move.l #zippy,$70.w			install new vbl
	move.w #7,-(sp)				wait key
	trap #1					call dos
	addq.l #2,sp				correct stack
	move.l oldint,$70.w			save old vbl
*wygaszenie
	JMP EXIT
*****
zippy	movem.l d0-a6,-(sp)			save registers
	bsr (music+8)				call playback
	movem.l (sp)+,d0-a6			restore registers
	move.l oldint,-(sp)			old vbl on sp
	rts					call old vbl
oldstk	dc.l 0
oldint	dc.l 0
oldvbl  dc.l 0
music	incbin "TRACK.mus"			change this filename !!
**************************************************************
EXIT	
	move.l d0,oldstk			save old sp
	move.l $70.w,oldint			save old vbl
	moveq #0,d0				music #1
	bsr music				call init
	move.l #zippy,$70.w			install new vbl----to wystarczy aby wygasic
	move.l oldint,$70.w			save old vbl
	clr.w -(sp)				
	trap #1					

