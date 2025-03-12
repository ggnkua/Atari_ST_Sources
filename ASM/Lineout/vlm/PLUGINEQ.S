;---------------------------------------------------------------------------
; Atari Coldfire Project - Virtual Light Machine : Plugin Equates
;---------------------------------------------------------------------------

; plugin header table layout
				rsreset
PluginTable.ID:			rs.l	1		; identifyer
PluginTable.INFO:		rs.l	1		; adr of info text
PluginTable.DISP_TYPE:		rs.l	1		; display buffering type
PluginTable.RES:		rs.l	1		; resolution
PluginTable.LAYERING:		rs.l	1		; layer support
PluginTable.MAINLOOP:		rs.l	1		; mainloop adr
PluginTable.INIT:		rs.l	1		; init adr
PluginTable.DEINIT:		rs.l	1		; deinit adr
PluginTable.CUSTOM:		rs.b	0		; custom events

; plugin id's
PluginTable.VLM1_ID:		=	"VLM1"
PluginTable.VLM2_ID:		=	"VLM2"
PluginTable.DZY1_ID:		=	"DZY1"

; runner service routine table
				rsreset
ServiceTable.GET_LEFT_SPEC:	rs.l	1
ServiceTable.GET_RIGHT_SPEC:	rs.l	1
ServiceTable.GET_LEFT_OSC:	rs.l	1
ServiceTable.GET_RIGHT_OSC:	rs.l	1
ServiceTable.GET_LEFT_VOL:	rs.l	1
ServiceTable.GET_RIGHT_VOL:	rs.l	1
ServiceTable.GET_LEFT_PITCH:	rs.l	1		; vlm pong!
ServiceTable.GET_RIGHT_PITCH:	rs.l	1		; vlm pong!
ServiceTable.GET_TEMPO:		rs.l	1
ServiceTable.GET_RYTHM_TYPE:	rs.l	1
ServiceTable.GET_TIME_RUNNING:	rs.l	1
ServiceTable.SET_PAL:		rs.l	1
ServiceTable.SET_BORDERS:	rs.l	1
ServiceTable.GET_HOLD:		rs.l	1
ServiceTable.SIZE:		rs.b	0

; display buffering schemes
				rsreset
Display.SINGLE_BUFFER:		rs.b	1
Display.DOUBLE_BUFFER:		rs.b	1
Display.TRIPLE_BUFFER:		rs.b	1
Display.NUM_BUFFERING_SCHEMES:	rs.b	0

; layering schemes  
Display.BACKDROP:		=	%0001
Display.BYTE_ADD:		=	%0010

; resolutions
				rsreset
Res.320X240_16BPP:		rs.b	1
Res.320X100_16BPP:		rs.b	1
Res.320X240_8BPL:		rs.b	1			; bitplane mode
Res.320X100_8BPL:		rs.b	1			; bitplane mode
Res.NUM_WHIP_RESOLUTIONS:	rs.b	0
Res.640X480_8BPL:		rs.b	1			; bitplane mode
Res.720X576_8BPL:		rs.b	1			; bitplane mode
Res.640X480_16BPP:		rs.b	1
Res.720X576_16BPP:		rs.b	1
Res.FIRST_8BPP_MODE:		rs.b	0
Res.320X240_8BPP:		rs.b	1			; chunky mode
Res.320X100_8BPP:		rs.b	1			; chunky mode
Res.640X480_8BPP:		rs.b	1			; chunky mode
Res.720X576_8BPP:		rs.b	1			; chunky mode
Res.LAST_8BPP_MODE:		rs.b	0
Res.NUM_RESOLUTIONS:		rs.b	0

; monitor types
Display.RGB_MONITOR:		=	0
Display.VGA_MONITOR:		=	1

; runner error codes
Runner.INIT_ERROR:		=	-1
Runner.DEINIT_ERROR:		=	-2
Runner.RES_ERROR:		=	-3

;---------------------------------------------------------------------------
; additional Whip! equates
;---------------------------------------------------------------------------

Runner.VLM1_MODE:		=	1
Runner.VLM2_MODE:		=	2

				rsreset
WhipPluginTable.ID:		rs.l	1		; identifyer
WhipPluginTable.INFO:		rs.l	1		; adr of info text
WhipPluginTable.SETTINGS:	rs.l	1		; adr of settings structure
WhipPluginTable.INIT:		rs.l	1		; init adr
WhipPluginTable.DEINIT:		rs.l	1		; deinit adr
WhipPluginTable.MAINLOOP:	rs.l	1		; mainloop adr

; runner service routine table
				rsreset
WhipServiceTable.SET_VBL_ROUT:	rs.l	1
WhipServiceTable.WAIT_VBL:	rs.l	1
WhipServiceTable.SET_SCREEN:	rs.l	1
WhipServiceTable.SET_RES:	rs.l	1
WhipServiceTable.GET_LEFT_SPEC:	rs.l	1
WhipServiceTable.GET_RIGHT_SPEC:rs.l	1
WhipServiceTable.GET_LEFT_VOL:	rs.l	1
WhipServiceTable.GET_RIGHT_VOL:	rs.l	1
WhipServiceTable.GET_LEFT_OSC:	rs.l	1
WhipServiceTable.GET_RIGHT_OSC:	rs.l	1
WhipServiceTable.SIZE:		rs.b	0
