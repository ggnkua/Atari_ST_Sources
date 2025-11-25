EEPROM	=	1

Put_Sound_Effect_Music_Vol_In_Eeprom
	Ifne	EEPROM
	Push
	Move.w	Music_Vol,d0
	Move.w	#1,d1				; 1st word, music volume
	Jsr	eewrite
	Move.w	SFX_Vol,d0			; Sound fx volume !
	Move.w	#2,d1
	Jsr	eewrite
	Bsr	Write_Checksum
	Pull
	Endc
	Rts

Write_Music_On_Off_To_Status
	Ifne	EEPROM
	Push
	Moveq	#0,d0
	Move.b	Music_On+Data,d0		; Sound fx volume !
	Move.w	#3,d1
	Jsr	eewrite
	Bsr	Write_Checksum
	Pull
	Endc
	Rts

Get_Sound_Effect_Music_Vol_From_Eeprom
	Ifeq	EEPROM
	Rts
	Endc
	Push
	Bsr	Check_Checksum
	Bne.s	.Sound_Duff
	Moveq	#1,d1
	Jsr	Eeread
	Move.w	d0,Music_Vol
	Moveq	#2,d1
	Jsr	Eeread
	Move.w	d0,SFX_Vol
	Moveq	#3,d1
	Jsr	Eeread
	Move.b	d0,Music_On+Data
	Pull
	Rts
.Sound_Duff
	Jsr	Default_Sound
	Pull
	Rts
	
Hi_Score_Check_Eeprom
	Bsr	Default_Sound
	Ifne	EEPROM
	Push
	Move.w	#0,d1
	Jsr	eeread
	Cmp.w	#"NC",d0
	Beq.s	.Ram_Initialized
	Move.w	#"NC",d0
	Move.w	#0,d1
	Jsr	eewrite
	Bsr	Copy_Hi_Score_To_eprom
	Move.w	#10,Music_Vol
	Move.w	#15,SFX_Vol
	Clr.b	Music_On+Data
	Bsr	Put_Sound_Effect_Music_Vol_In_Eeprom
	Bsr	Write_Music_On_Off_To_Status
	Bsr	Write_Checksum
	Pull
	Rts
.Ram_Initialized
	Move.w	#"NC",d0
	Move.w	#0,d1
	Jsr	eewrite
	Bsr	Copy_Eprom_To_Hi_Score
	Bsr	Get_Sound_Effect_Music_Vol_From_Eeprom
.Exit	Pull
	Endc
	Rts

Default_Sound
	Move.w	#10,Music_Vol
	Move.w	#15,SFX_Vol
	Clr.b	Music_On+Data
	Rts

Copy_Hi_Score_To_eprom
	Ifne	EEPROM
	Push
	Move.w	#(High_Score_Tablee-High_Score_Table)/2-1,d7
	Lea	High_Score_Table,a0
	Moveq	#4,d1
	Moveq	#0,d2
.Loop	Move.w	(a0)+,d0
	Add.w	d0,d2
	Ror.w	#1,d2
	Jsr	eewrite
	Bmi.s	.Exit				; Failed to write !
	Addq.w	#1,d1
	Dbra	d7,.Loop
	Bsr	Write_Checksum
.Exit	Pull
	Endc
	Rts

Copy_Eprom_To_Hi_Score
	Ifne	EEPROM
	Push
	Bsr	Check_Checksum
	Bne	.Checksum_Failed
	Move.w	#(High_Score_Tablee-High_Score_Table)/2-1,d7
	Lea	High_Score_Table,a0
	Moveq	#4,d1
.Loop	Jsr	eeread
	Move.w	d0,(a0)+
	Addq.w	#1,d1
	Dbra	d7,.Loop
	Jsr	eeread					; Lastly, get the checksum!
.Exit	
	Pull
	Endc
	Rts

.Checksum_Failed
	Bsr	Reset_Hi_Score
	Pull
	Rts

Reset_Hi_Score
	Lea	High_Score_Table_Rom,a0
	Lea	High_Score_Table,a1
	Move.w	#(High_Score_Tablee-High_Score_Table)/2-1,d7
.Loop	Move.w	(a0)+,(a1)+
	Dbra	d7,.Loop
	Rts

Write_Checksum
	Move.w	#(High_Score_Tablee-High_Score_Table)/2-1,d7
	Addq.w	#4,d7
	Moveq	#0,d1	
	Moveq	#0,d2
.Loop	Jsr	eeread
	Add.w	d0,d2
	Ror.w	#1,d2
	Addq.w	#1,d1
	Subq.w	#1,d7
	Bne.s	.Loop
	Moveq	#63,d1
	Move.w	d2,d0
	Jsr	eewrite
	Rts
Check_Checksum
	Move.w	#(High_Score_Tablee-High_Score_Table)/2-1,d7
	Addq.w	#4,d7
	Moveq	#0,d1	
	Moveq	#0,d2
.Loop	Jsr	eeread
	Add.w	d0,d2
	Ror.w	#1,d2
	Addq.w	#1,d1
	Subq.w	#1,d7
	Bne.s	.Loop
	Moveq	#63,d1
	Jsr	eeread
	Cmp.w	d2,d0
	Rts				; Returns NOTZERO if checksum failed!


	Include	EEPRIM.S