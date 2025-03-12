		section	data
SoundRSC	dc.l	sam1
		dc.l	sam2
		dc.l	sam3
		dc.l	sam4
		dc.l	sam5
		dc.l	sam6
		dc.l	sam7
		dc.l	sam8
		dc.l	sam9
		dc.l	0

sam1		ds.l	1		; *Soundchannel
		dc.l	endsam1		; *EndOfSample
		incbin	'temp\sounds\sound04.sam'
endsam1
		even
		
sam2		ds.l	1
		dc.l	endsam2
		incbin	'temp\sounds\sound20.sam'
endsam2
		even

sam3		ds.l	1
		dc.l	endsam3
		incbin	'temp\sounds\sound21.sam'		
endsam3
		even

sam4		ds.l	1
		dc.l	endsam4
		incbin	'temp\sounds\sound07.sam'		
endsam4
		even

sam5		ds.l	1
		dc.l	endsam5
		incbin	'temp\sounds\sound08.sam'
endsam5
		even

sam6		ds.l	1
		dc.l	endsam6
		incbin	'temp\sounds\sound34.sam'
endsam6
		even

sam7		ds.l	1
		dc.l	endsam7
		incbin	'temp\sounds\sound35.sam'
endsam7
		even

sam8		ds.l	1
		dc.l	endsam8
		incbin	'temp\sounds\sound15.sam'
endsam8
		even

sam9		ds.l	1
		dc.l	endsam9
		incbin	'temp\sounds\sound03.sam'
endsam9
		even

SND_NOSOUND	=	SoundRSC+34
SND_THROWSWITCH =	0	; Throw end level switch 
SND_GETKEY	=	0	; Pick up a key 
SND_BONUS	=	SoundRSC+32	; Score ding 
SND_OPENDOOR	=	SoundRSC	; Open a door 
SND_DOGBARK	=	0	; Dog bite 
SND_DOGDIE	=	0	; Dog die 
SND_ESEE	=	SoundRSC+12	; Achtung! 
SND_ESEE2	=	SoundRSC+16	; Halt! 
SND_ESEE3	=	SoundRSC+20	; Nazi sees you 
SND_ESEE4	=	SoundRSC+24	; Nazi sees you 
SND_EDIE	=	0	; Nazi died 
SND_EDIE2	=	0	; Nazi died 2 
SND_BODYFALL	=	0	; Body hit the ground 
SND_PAIN	=	0	; Hit bad guy 
SND_GETAMMO	=	0	; Pick up ammo 
SND_KNIFE	=	0	; Knife attack 
SND_GUNSHT	=	SoundRSC+28	; 45 Shoot 
SND_MGUN	=	0	; Sub machine gun 
SND_CHAIN	=	0	; Chain gun 
SND_FTHROW	=	0	; Flame thrower 
SND_ROCKET	=	0	; Rocket launcher 	
SND_PWALL	=	SoundRSC+4	; Start pushwall 
SND_PWALL2	=	SoundRSC+8	; Stop pushwall 
SND_GUTEN	=	0	; Guten tag 
SND_SHIT	=	0	; Shit! 
SND_HEAL	=	0	; Healed a bit 
SND_THUMBSUP	=	0	; You stud you! 
SND_EXTRA	=	0	; Extra guy 
SND_OUCH1	=	0	; BJ has beed injured 
SND_OUCH2	=	0	; Second sound 
SND_PDIE	=	0	; BJ has died 
SND_HITWALL	=	0	; Tried to open a wall 
SND_KNIFEMISS	=	0	; Knife missed 
SND_BIGGUN	=	0	; Boss's gun 
SND_COMEHERE	=	0	; Come here! 
SND_OK		=	0	; Hit start game 
SND_MENU	=	0	; New game menu 
SND_HITLERSEE	=	0	; Hitler sees you 
SND_SHITHEAD	=	0	; Big boss sees you 
SND_BOOM	=	0	; Explosion 
SND_LOCKEDDOOR	=	0	; Locked door 
SND_MECHSTEP	=	SoundRSC	; Mech step 
NUMSOUNDS	=	(SoundRSC-SND_MECHSTEP+4)/4