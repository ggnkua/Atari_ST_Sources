	.import LCD_Init
	.import LCD_Exit
	.import LCD_Open
	.import LCD_Close
	.import LCD_DefineChar
	.import LCD_DisplayOff
	.import LCD_DisplayOn
	.import LCD_Clear
	.import LCD_Home
	.import LCD_Mode
	.import LCD_Cursor
	.import LCD_CursorLeft
	.import LCD_CursorRight
	.import LCD_CursorOn
	.import LCD_CursorOff
	.import LCD_ShiftLeft
	.import LCD_ShiftRight
	.import LCD_DisplayCharacter
	.import LCD_DisplayString
	.import LCD_DisplayStringCentered
	.import LCD_DisplayScreen
	.import LCD_DisplayRow 
	.import LCD_WipeOnLR
	.import LCD_WipeOnRL
	.import LCD_WipeOffLR
	.import LCD_WipeOffRL

	.text

	dc.l	0x70004afc	; magic value (clr.l d0, illegal)
	dc.l	name		; pointer to library's (file)name
	dc.l	1		; version number
	dc.l	0		; flags, currently 0L
	dc.l	LCD_Init	; called when the library's been loaded
	dc.l	LCD_Exit	; called before the library is removed
	dc.l	LCD_Open	; called when a process opens the library
	dc.l	LCD_Close	; called when a process closes the library
	dc.l	0		; pointer to function names, optional
	dc.l	0,0,0,0,0,0,0,0	; unused, always 0L
	dc.l	22		; number of functions
	dc.l	LCD_DefineChar	; function 0
	dc.l	LCD_DisplayOff
	dc.l	LCD_DisplayOn
	dc.l	LCD_Clear
	dc.l	LCD_Home
	dc.l	LCD_Mode
	dc.l	LCD_Cursor
	dc.l	LCD_CursorLeft
	dc.l	LCD_CursorRight
	dc.l	LCD_CursorOn
	dc.l	LCD_CursorOff
	dc.l	LCD_ShiftLeft
	dc.l	LCD_ShiftRight
	dc.l	LCD_DisplayCharacter
	dc.l	LCD_DisplayString
	dc.l	LCD_DisplayStringCentered
	dc.l	LCD_DisplayScreen
	dc.l	LCD_DisplayRow 
	dc.l	LCD_WipeOnLR
	dc.l	LCD_WipeOnRL
	dc.l	LCD_WipeOffLR
	dc.l	LCD_WipeOffRL

name:
	dc.b	"lcd.slb"
	
	end

