***********************************************************
*** Routine de conversion d'un long vers une chaine     ***
*** representant la taille d'un fichier en B, KB, GB... ***
***********************************************************
long_2_filesize	macro	; size,string
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	XREF	long_2_filesize_rout
	jsr	long_2_filesize_rout
	addq.l	#8,sp
	endm

***************************************************
*** Routine convertissant la date en une chaine ***
***************************************************
date_2_string	macro	; date(format GEMDOS),string_ptr
	move.w	\1,-(sp)
	move.l	\2,-(sp)
	XREF	date_2_string_rout
	jsr	date_2_string_rout
	addq.l	#6,sp
	endm

***************************************************
*** Routine convertissant l'heure en une chaine ***
***************************************************
time_2_string	macro	; heure(format GEMDOS),string_ptr,seconde(oui/non)
	move.w	\1,-(sp)
	move.l	\2,-(sp)
	move.w	\3,-(sp)
	XREF	time_2_string_rout
	jsr	time_2_string_rout
	addq.l	#8,sp
	endm

**************************************************************************
*** Routine convertissant les attributs au format GEMDOS vers du texte ***
**************************************************************************
dosattrb_2_string	macro	; attribu(format GEMDOS),string_ptr
	move.w	\1,-(sp)
	move.l	\2,-(sp)
	XREF	dosattrb_2_string_rout
	jsr	dosattrb_2_string_rout
	addq.l	#6,sp
	endm
