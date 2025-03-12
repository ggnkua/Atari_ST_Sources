;
;
; TEMPLATE.S
; code template for routines from the "binliner" demo
;
; this code is either included from the file BINMAIN.S or
; assembled as standalone
;
; change the "xxxx_" using s'n'r to the name of the effect
;
;
;
;


		format	0-,1-,2-		;output style
		section	text

; 'binmain' will only have been set on pass 1 if assembling from
; BINMAIN.S

		ifd	binmain
;------------------------------------------------------------------
; BINMAIN SECTION
;
;
; here goes a list of routines for init etc.
; they will be called automatically by the main OS
;------------------------------------------------------------------

xxxx_codestart:
		dc.l	xxxx_on_loading
		dc.l	xxxx_on_session
		dc.l	xxxx_on_sequence
		dc.l	xxxx_do_frames
		dc.l	xxxx_on_sequence_end
		dc.l	xxxx_on_session_end
		dc.l	xxxx_on_loading_end
		dc.l	xxxx_message_list

; this is the list of message handling routines
; the names of the messages must be installed in "shared.s"
; data is contained in a0


		else			;{ifd binmain}


;------------------------------------------------------------------
; STANDALONE SECTION
;
;
;
;------------------------------------------------------------------

;------------------------------------------------------------------
; Include the startup/shutdown code here
; this will run stuff automatically and provide
; equivalents of the binmain macros, screen spaces
; etc

		list
; ******* ASSEMBLING AS STANDALONE
		nolist

		opt	xdebug
		include	startup.s
		include	includes.s

codestart:
		dc.l	xxxx_on_loading
		dc.l	xxxx_on_session
		dc.l	xxxx_on_sequence
		dc.l	xxxx_do_frames
		dc.l	xxxx_on_sequence_end
		dc.l	xxxx_on_session_end
		dc.l	xxxx_on_loading_end
		dc.l	xxxx_message_list
		endc			;{ifd binmain}
;------------------------------------------------------------------

;
; the main code may use any INCLUDES from the \system\ folder
; that should be well behaved and only assemble once
; "handle messages" is performed by the OS via xxxx_message_list
; 

xxxx_on_loading:
xxxx_on_session:
xxxx_on_sequence:
xxxx_do_frames:
xxxx_on_sequence_end:
xxxx_on_session_end:
xxxx_on_loading_end:
		rts
xxxx_message_list:	
		dc.l	0
