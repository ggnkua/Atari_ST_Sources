* Example VT-52 sequences
* coded by RUNRIG

	pea 	TEXT		- address of our text message with codes
	move.w	#9,-(a7)	- function number print line
	trap	#1		- call GEMDOS
	addq.l	#6,a7		- fix stack
	
	move.w	#7,-(a7)	- wait key
	trap	#1		- call GEMDOS
	addq.l	#2,a7		- fix stack
	
	clr.l	-(a7)		- exit
	trap	#1		- aaaahhhh....

* Here is message. Un-rem the VT-52 code you wish to use

TEXT:	

* Escape A - cursor up:
;	dc.b	27,"A"

* Escape B - cursor down:
;	dc.b	27,"B"

* Escape C - cursor right:
; 	dc.b	27,"C"

* Escape D - cursor left:
; 	dc.b	27,"D"

* Escape E - Clr Home:
;	dc.b	27,"E"

* Escape H - Cursor home
;	dc.b	27,"H"

* Escape I - Cursor up
;	dc.b	27,"I"

* Escape J - Clear below cursor:
; 	dc.b	27,"J"

* Escape K - Clear remainder of line:
; 	dc.b	27,"K"

* Escape L - Insert line:
;	dc.b	27,"L"

* Escape M - Delete line:
;	dc.b	27,"M"

* Escape Y - Position cursor
* For this function, the parameters needed are:
* 1 - the line+32	2 - the column+32 
* For example, if wanted to position the cursor at line 8, column 24:
;	dc.b	27,"Y",32+8,32+24

* Escape b - Change text colour
* Example, change text colour to colour 3:
;	dc.b	27,"b",3

* Escape c - Change background colour
* Example, change background to colour 8:
; 	dc.b	27,"c",8

* Escape d - Clear screen to current current cursor position:
;	dc.b	27,"d"

* Escape e - Enable cursor:
;	dc.b	27,"e"

* Escape f - Disable cursor:
;	dc.b	27,"f"

* Escape j - Sace cursor position
;	dc.b	27,"j"

* Escape k - Set cursor to saved position
; 	dc.b	27,"k"

* Escape l - Clear line
;	dc.b	27,"l"

* Escape o - Clear line from start to end
;	dc.b	27,"o"

* Escape p - Reverse on
;	dc.b	27,"p"

* Escape q - Reverse off
;	dc.b	27,"q"

* Escape v - Overflow on
;	dc.b	27,"v"

* Escape w - Overflow off
;	dc.b	27,"w"

* Put your text here:
	dc.b	"Lots of jubbly escape codes",13,10,13,10
	dc.b	"By RUNRIG"

* Terminator:
	dc.b	0


