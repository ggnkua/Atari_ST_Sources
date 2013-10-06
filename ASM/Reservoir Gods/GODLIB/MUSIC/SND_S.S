**************************************************************************************
*	SND_S.S
*
*	SND player functions
*
*	[c] 2001 Reservoir Gods
**************************************************************************************

**************************************************************************************
;	EXPORTS / IMPORTS
**************************************************************************************

	export	Snd_CallFunction
	export	Snd_Player
	export	Snd_SetpPlayFunc
	export	Snd_SetpChaserFunc


**************************************************************************************
	TEXT
**************************************************************************************

*------------------------------------------------------------------------------------*
* FUNCTION : Snd_CallFunction( void (*apFunc)(void) )
* ACTION   : saves regs and calls a function
* CREATION : 02.02.01 PNK
*------------------------------------------------------------------------------------*

Snd_CallFunction:
	movem.l	d0-a6,-(a7)
	jsr		(a0)
	movem.l	(a7)+,d0-a6
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Snd_Player( void )
* ACTION   : saves regs and calls a function
* CREATION : 02.02.01 PNK
*------------------------------------------------------------------------------------*

Snd_Player:

	movem.l	d0-a6,-(a7)

	move.l	Snd_pPlayFunc,a0
	jsr		(a0)
	
	move.l	Snd_pChaserFunc,a0
	jsr		(a0)

	movem.l	(a7)+,d0-a6

Snd_Rts:
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Snd_SetpPlayFunc( void (*aPlayFunc)(void) )
* ACTION   : sets current SND play function
* CREATION : 02.02.01 PNK
*------------------------------------------------------------------------------------*

Snd_SetpPlayFunc:
	move.l	a0,Snd_pPlayFunc
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Snd_SetpChaserFunc( void (*aPlayFunc)(void) )
* ACTION   : sets current SND FX function
* CREATION : 02.02.01 PNK
*------------------------------------------------------------------------------------*

Snd_SetpChaserFunc:
	move.l	a0,Snd_pChaserFunc
	rts


Snd_pPlayFunc:		dc.l	Snd_Rts
Snd_pChaserFunc:	dc.l	Snd_Rts
