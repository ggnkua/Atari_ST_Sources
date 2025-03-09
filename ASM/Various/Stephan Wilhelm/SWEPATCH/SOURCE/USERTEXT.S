; Durch diesen Patch hat man die M”glichkeit,einen userdefinierten
; Text in der Bootphase anzeigen zu lassen.
; Das kann man z.B. nutzen fr eine pers”nliche Begrung,Werbung etc.
; Der Text steht im Ascii-Code (Endcode=ASCII 0) ab der Adresse "textout"

	org $7fe60600

	lea.l	textout(pc),a0
	jsr	$7fe0630e
	lea.l	$7fe062a4,a0
	jsr	$7fe0630e
	jmp	$7fe05fba

textout:

