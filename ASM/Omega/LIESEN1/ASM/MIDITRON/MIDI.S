; ------------------ kommandon f”r HANDSHAKE


; "RQ",LastNr   beg„r request om ID nummer        (s„nds av MASTER)
;      n„r slave f†r detta skall den komma ih†g sitt ID och sedan 
;      skicka vidare RQ,LastNr+1        
;      N„r Master f†r tillbaka RQ s† vet den att det finns ID nr ifr†n
;      0 (Master) till LastNr-1.

; "ER",tal	Return error - stop handshake

; "GO" 		Handshake over.


Init:	move.l $118.w,Old118
	
	move.w	#34,-(a7)
	trap	#14
	addq.l	#2,a7
	
	move.l	d0,a0
	move.l	8(a0),OldMError
	move.l	(a0),OldMRecive
	move.l	#MidiError,8(a0)
	move.l	#MidiRecive,(a0)
	rts

MidiRecive:

MidiError:
	illegal

HandShake:
; d0=  1=Master, 0=Slave
; out:  D0=Own ID nr (0 if master)      negative if error
;	D1=nr of players 
	       


; a0=address to screen buffert
; 


Old118 		ds.l 1
OldMRecive	ds.l 1
OldMError	ds.l 1