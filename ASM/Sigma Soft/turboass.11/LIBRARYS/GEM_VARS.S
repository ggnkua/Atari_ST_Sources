;************************************************************************
;* ‰-soft-AES-Symboltabelle						*
;* Ω1989 by ‰-soft, written by Markus Fritze	       11.08.1988 13:13 *
;************************************************************************
;EQU's mit Konstanten sind auch als VorwÑrtsreferenzen mîglich, da diese Symbole
;ihren Wert bereits bei der Eingabe erhalten:

appl_init:	EQU $0A000100
appl_read:	EQU $0B020101
appl_write:	EQU $0C020101
appl_find:	EQU $0D000101
appl_tplay:	EQU $0E020101
appl_trecord:	EQU $0F010101
appl_bvset:	EQU $10020100	;ab GEM 2.0
appl_yield:	EQU $11000100	;ab GEM 2.0
appl_exit:	EQU $13000100

evnt_keybd:	EQU $14000100
evnt_button:	EQU $15030500
evnt_mouse:	EQU $16050500
evnt_mesag:	EQU $17000101
evnt_timer:	EQU $18020100
evnt_multi:	EQU $19100701
evnt_dclick:	EQU $1A020100

menu_bar:	EQU $1E010101
menu_icheck:	EQU $1F020101
menu_ienable:	EQU $20020101
menu_tnormal:	EQU $21020101
menu_text:	EQU $22010102
menu_register:	EQU $23010101
menu_unregister:EQU $24010100	;ab GEM 2.0

objc_add:	EQU $28020101
objc_delete:	EQU $29010101
objc_draw:	EQU $2A060101
objc_find:	EQU $2B040101
objc_offset:	EQU $2C010301
objc_order:	EQU $2D020101
objc_edit:	EQU $2E040201
objc_change:	EQU $2F080101

form_do:	EQU $32010101
form_dial:	EQU $33090100
form_alert:	EQU $34010101
form_error:	EQU $35010100
form_center:	EQU $36000501
form_keybd:	EQU $37030301
form_button:	EQU $38020201

graf_rubberbox: EQU $46040300
graf_dragbox:	EQU $47080300
graf_movebox:	EQU $48060100
graf_growbox:	EQU $49080100
graf_shrinkbox: EQU $4A080100
graf_watchbox:	EQU $4B040101
graf_slidebox:	EQU $4C030101
graf_handle:	EQU $4D000500
graf_mouse:	EQU $4E010101
graf_mkstate:	EQU $4F000500

srcp_read:	EQU $50000101
srcp_write:	EQU $51000101
scrp_clear:	EQU $52000100	;ab GEM 2.0

fsel_input:	EQU $5A000202
fsel_exinput:	EQU $5B000203	;ab TOS 1.4

wind_create:	EQU $64050100
wind_open:	EQU $65050100
wind_close:	EQU $66010100
wind_delete:	EQU $67010100
wind_get:	EQU $68020500
wind_set:	EQU $69060100
wind_find:	EQU $6A020100
wind_update:	EQU $6B010100
wind_calc:	EQU $6C060500
wind_new:	EQU $6D000000	;ab TOS 1.4

rsrc_load:	EQU $6E000101
rsrc_free:	EQU $6F000100
rsrc_gaddr:	EQU $70020100	;* (siehe Unterprogramm "aes")
rsrc_saddr:	EQU $71020101
rsrc_obfix:	EQU $72010101

shel_read:	EQU $78000102
shel_write:	EQU $79030102
shel_get:	EQU $7A010101
shel_put:	EQU $7B010101
shel_find:	EQU $7C000101
shel_envrn:	EQU $7D000102
shel_rdef:	EQU $7E000102	;ab GEM 2.0
shel_wdef:	EQU $7F000002	;ab GEM 2.0

xgrf_stepcalc:	EQU $82060600	;ab GEM 2.0
xgrf_2box:	EQU $83090100	;ab GEM 2.0

; Die Messages des AES
MN_SELECTED:	EQU 10		;MenÅeintrag angewÑhlt
WM_REDRAW:	EQU 20		;Teil eines Windows muû neu gezeichnet werden
WM_TOPPED:	EQU 21		;Window ist nun das aktuelle Fenster
WM_CLOSED:	EQU 22		;Window soll geschlossen werden
WM_FULLED:	EQU 23		;Window soll auf max.Grîûe gebracht werden
WM_ARROWED:	EQU 24		;Scollbalken angeklickt
WM_HSLID:	EQU 25		;Der horizontale Slider wurde bewegt
WM_VSLID:	EQU 26		;Der vertikale Slider wurde bewegt
WM_SIZED:	EQU 27		;Die Grîûe des Windows wurde geÑndert
WM_MOVED:	EQU 28		;Das Window wurde bewegt
WM_NEWTOP:	EQU 29		;Das Fenster wurde aktiviert (siehe WM_TOPPED)
WM_UNTOPPED:	EQU 30		;Der Fenster wird gleich inaktiv (erst ab GEM 2.0!)
AC_OPEN:	EQU 40		;Ein Acc wurde angeklickt.(30 bzw. 31 ist FALSCH!)
AC_CLOSE:	EQU 41		;Prg wurde beendet, ACC soll seinen Speicher freigeben.
CT_UPDATE:	EQU 50
CT_MOVE:	EQU 51		;Funktion unbekannt
CT_NEWTOP:	EQU 52

; WM_ARROWED angeklickt (nun die genauere Definition)
WA_UPPAGE:	EQU 0		;Balken oberhalb des Sliders
WA_DNPAGE:	EQU 1		;Balken unterhalb des Sliders
WA_UPLINE:	EQU 2		;Pfeil nach oben
WA_DNLINE:	EQU 3		;Pfeil nach unten
WA_LFPAGE:	EQU 4		;Balken links vom Slider
WA_RTPAGE:	EQU 5		;Balken rechts vom Slider
WA_LFLINE:	EQU 6		;Pfeil nach links
WA_RTLINE:	EQU 7		;und Pfeil nach rechts

; Die Objekttypen des Resource-Baumes
G_BOX:		EQU 20
G_TEXT: 	EQU 21
G_BOXTEXT:	EQU 22
G_IMAGE:	EQU 23
G_PROGDEF:	EQU 24
G_IBOX: 	EQU 25		;Bitte in entsprechender Literatur nachschlagen
G_BUTTON:	EQU 26
G_BOXCHAR:	EQU 27
G_STRING:	EQU 28
G_FTEXT:	EQU 29
G_FBOXTEXT:	EQU 30
G_ICON: 	EQU 31
G_TITLE:	EQU 32

; Object-Flags bei einem Objekt
NONE:		EQU 0
SELECTABLE:	EQU 1
DEFAULT:	EQU 2
EXIT:		EQU 4
EDITABLE:	EQU 8
RBUTTON:	EQU $10 	;Bitte ebenfalls in der Literatur nachlesen
LASTOB: 	EQU $20
TOUCHEXIT:	EQU $40
HIDETREE:	EQU $80
INDIRECT:	EQU $0100

; Objekt-Status bei einem Objekt
NORMAL: 	EQU 0
SELECTED:	EQU 1
CROSSED:	EQU 2
CHECKED:	EQU 4		;s.o.
DISABLED:	EQU 8
OUTLINED:	EQU $10
SHADOWED:	EQU $20

; Die einzelnen Bits bei evnt_multi()
MU_KEYBD:	EQU 1		;Tastaturereignis
MU_BUTTON:	EQU 2		;Maustastenereignis
MU_M1:		EQU 4		;1.Mausereignis
MU_M2:		EQU 8		;2.Mausereignis
MU_MESAG:	EQU 16		;Message des AES
MU_TIMER:	EQU 32		;Timer-Ereignis

; form_dial()
FMD_START:	EQU 0		;Bildschirmhintergrund reservieren
FMD_GROW:	EQU 1		;Ausdehnende Box zeichnen
FMD_SHRINK:	EQU 2		;Schrumpfende Box zeichnen
FMD_FINISH:	EQU 3		;Bildschirmbereich wieder freigeben

; graf_mouse()
ARROW:		EQU 0
TEXT_CRSR:	EQU 1
HOURGLASS:	EQU 2
BUSYBEE:	EQU 2
POINT_HAND:	EQU 3
FLAT_HAND:	EQU 4
THIN_CROSS:	EQU 5
THICK_CROSS:	EQU 6
OUTL_CROSS:	EQU 7
USER_DEF:	EQU 255
M_OFF:		EQU 256
M_ON:		EQU 257

; Parameter bei wind_create()
WI_NAME:	EQU 1
WI_CLOSE:	EQU 2
WI_FULL:	EQU 4
WI_MOVE:	EQU 8
WI_INFO:	EQU $10
WI_SIZE:	EQU $20
WI_UPARROW:	EQU $40
WI_DNARROW:	EQU $80
WI_VSLIDE:	EQU $0100
WI_LFARROW:	EQU $0200
WI_RARROW:	EQU $0400
WI_HSLIDE:	EQU $0800

; Parameter bei wind_get() & wind_set()
WF_KIND:	EQU 1
WF_NAME:	EQU 2
WF_INFO:	EQU 3
WF_WORKXYWH:	EQU 4
WF_CURRXYWH:	EQU 5
WF_PREVXYWH:	EQU 6
WF_FULLXYWH:	EQU 7
WF_HSLIDE:	EQU 8
WF_VSLIDE:	EQU 9
WF_TOP: 	EQU 10
WF_FIRSTXYWH:	EQU 11
WF_NEXTXYWH:	EQU 12
WF_NEWDESK:	EQU 14
WF_HSLSIZE:	EQU 15
WF_VSLSIZE:	EQU 16

; wind_update()
END_UPDATE:	EQU 0
BEG_UPDATE:	EQU 1
END_MCTRL:	EQU 2
BEG_MCTRL:	EQU 3
		END
