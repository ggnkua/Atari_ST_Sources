; NOFETCH.S
;
; March 1989.
; Programmed by Dr Krall.
;
; The code is supposed to be position independent.
; (We don't need no allocation...)

; Perform "setblock" call, to free memory not needed.

	MOVE.L	A7,A5		;
	MOVE.L	4(A5),A5	;
	MOVE.L	$C(A5),D0	;
	ADD.L	$14(A5),D0	;
	ADD.L	$1C(A5),D0	;
	ADD.L	#$1100,D0	;
	MOVE.L	A5,D1		;
	ADD.L	D0,D1		;
	AND.L	#-2,D1		;
	MOVE.L	D1,A7		;
	MOVE.L	D0,-(SP)	;
	MOVE.L	A5,-(SP)	;
	MOVE.W	D0,-(SP)	;
	MOVE.W	#$4A,-(SP)	; SETBLOCK function code.
	TRAP	#1		; Call GEMDOS.
	ADD.L	#12,SP		; Correct stack pointer.
	TST.L	D0		; Test error status.
	BMI	TERM		; Exit on error.

        BRA     RUN             ; Branch to main code.

; Determine video memory start address (subroutine).

PHYSBAS MOVE.W	#2,-(SP)	; PHYSBAS function code.
	TRAP	#14		; Call XBIOS.
	ADDQ.L	#2,SP		; Correct stack pointer.
	RTS			; Return from subroutine.

; Set graphics resolution (subroutine).

SETRES	MOVE.W	D0,-(SP)	; Resolution.
	MOVE.L	#-1,-(SP)	; Don't change physical screen start.
	MOVE.L	#-1,-(SP)	; Don't change logical either.
	MOVE.W	#5,-(SP)	; SETSCREEN function code.
	TRAP	#14		; Call XBIOS for setting resolution.
	ADD.L	#12,SP		; Correct stack pointer.
	RTS			; Return from subroutine.
	
; Set execution mode (subroutine).

SUPER   MOVE.L	D0,-(SP)	; Parameter.
	MOVE.W	#$20,-(SP)	; SUPER function code.
	TRAP	#1		; Call GEMDOS for changing exec mode.
	ADDQ.L	#6,SP		; Correct stack pointer.
	RTS			; Return from subroutine.
	
; Main code.

RUN     

; Determine screen start address.

        BSR     PHYSBAS         ; Determine screen start address.
        LEA     SCREEN(PC),A0   ; Address of storage pointer.
        MOVE.L  D0,(A0)         ; Store screen start address.

; Allocate memory for picture file.

        MOVE.L  #32128,-(SP)    ; Number of bytes.
        MOVE.W  #$48,-(SP)      ; MALLOC function code.
        TRAP    #1              ; Call GEMDOS for allocating memory.
        ADDQ.L  #6,SP           ; Correct stack pointer.
	TST.L	D0		; Test for error.
	BMI	TERM		; Exit on error.
        LEA     BUFPTR(PC),A0   ; Address of storage pointer.
        MOVE.L  D0,(A0)         ; Store area address.

; Open picture file.

	CLR.W	-(SP)		; Read only.
	PEA	NEOFNAM(PC)	; File name.
	MOVE.W	#$3D,-(SP)	; OPEN function code.
	TRAP	#1		; Call GEMDOS for opening file.
	ADDQ.L	#8,SP		; Correct stack pointer.
	TST.L	D0		; Test for error.
	BMI	TERM		; Exit on error.
	LEA	HANDLE(PC),A0	; Address of file handle storage.
	MOVE.W	D0,(A0)		; Store handle.
	
; Read Neochrome file.

        MOVE.L  BUFPTR(PC),-(SP); Load address.
        MOVE.L  #32128,-(SP)    ; Number of bytes.
        MOVE.W  HANDLE(PC),-(SP); File handle.
        MOVE.W  #$3F,-(SP)      ; READ function number.
        TRAP    #1              ; Call GEMDOS for reading file.
        ADD.L   #12,SP          ; Correct stack pointer.
        TST.L   D0              ; Test error status.
        BMI     TERM            ; Exit on error.

; Close file.

        MOVE.W  HANDLE(PC),-(SP); File handle.
        MOVE.W  #$3E,-(SP)      ; CLOSE function number.
        TRAP    #1              ; Call GEMDOS for closing file.
        ADDQ.L  #4,SP           ; Correct stack pointer.
        TST.L   D0              ; Test error status.
        BMI     TERM            ; Exit on error.

; Use low resolution.

	CLR.W	D0		; Low resolution.
	BSR	SETRES		; Set resolution.
	
; Enter supervisor mode.

	CLR.L	D0		; Supervisor.
	BSR	SUPER		; Change execution mode.
	LEA	SSAV(PC),A0	; Address of execution mode storage.
	MOVE.L	D0,(A0)		; Store old execution mode.

; Save old palette colours.

	LEA	$FF8240,A0	; Address of hardware palette.
	LEA	SAVPAL(PC),A1	; Address of save area.
	MOVEQ	#16-1,D0	; Number of colours.
SAV	MOVE.W	(A0)+,(A1)+	; Save colour.
	DBRA	D0,SAV		; Until all colour registers done.
	
; Set new colours.

        MOVEA.L BUFPTR(PC),A0   ; Address of data area.
        PEA     4(A0)           ; Palette address.
        MOVE.W  #6,-(SP)        ; SETPALETTE function number.
        TRAP    #14             ; Call XBIOS for setting new palette.
        ADDQ.L  #6,SP           ; Correct stack pointer.

; Copy graphics data to video memory.

        MOVEA.L BUFPTR(PC),A0     ; Address of data area.
        LEA     128(A0),A0        ; Offset 128 for bitmaps.
        MOVEA.L SCREEN(PC),A1     ; Address of screen bitmap.
        MOVE.L  #32000/40-1,D0    ; Number of copy operations.
COPY    MOVEM.L (A0)+,D1-D7/A2-A4 ; Read 40 bytes from data area.
        MOVEM.L D1-D7/A2-A4,(A1)  ; Write 40 bytes to screen.
        ADD.L   #40,A1            ; Increase destination pointer.
        DBRA    D0,COPY           ; Until picture copied to screen.

; Release memory allocated for picture file.

        MOVE.L  BUFPTR(PC),-(SP); Area address.
        MOVE.W  #$49,-(SP)      ; MFREE function code.
        TRAP    #1              ; Call GEMDOS for releasing memory.
        ADDQ.L  #6,SP           ; Correct stack pointer.
	TST.L	D0		; Test for error.
	BMI	TERM		; Exit on error.
	
; Main loop.

RESTART CMPI.B  #$FD,$FF8207    ; Test for last mid-byte value.
        BNE.S   RESTART         ; Wait until last value reached.

; Copy topmost screen line to the lowmost one.

        MOVE.L  SCREEN(PC),A0       ; Screen start address.
        MOVE.L  A0,A1               ; Copy it.
        ADD.L   #199*160,A1         ; Address of lowest screen line.
        MOVEM.L (A0)+,D1-D7/A2-A4   ; Read 40 bytes.
        MOVEM.L D1-D7/A2-A4,(A1)    ; Write 40 bytes.
        MOVEM.L (A0)+,D1-D7/A2-A4   ; Read 40 bytes.
        MOVEM.L D1-D7/A2-A4,40(A1)  ; Write 40 bytes.
        MOVEM.L (A0)+,D1-D7/A2-A4   ; Read 40 bytes.
        MOVEM.L D1-D7/A2-A4,80(A1)  ; Write 40 bytes.
        MOVEM.L (A0)+,D1-D7/A2-A4   ; Read 40 bytes.
        MOVEM.L D1-D7/A2-A4,120(A1) ; Write 40 bytes.
                                    ; (Line copy is now complete.)

; Scroll screen one pixel vertically upwards.

        MOVE.L  SCREEN(PC),A0   ; Get (reload) video mem pointer.
        ADDA.L  #160,A0         ; Add to get address of line #1.
        MOVE.L  #199-1,D0       ; 199 lines to scroll.
VSCROLL MOVEM.L (A0)+,D1-D7/A1-A3    ; Read 40 bytes.
        MOVEM.L D1-D7/A1-A3,-200(A0) ; Write 40 bytes.
        MOVEM.L (A0)+,D1-D7/A1-A3    ; Read 40 bytes.
        MOVEM.L D1-D7/A1-A3,-200(A0) ; Write 40 bytes.
        MOVEM.L (A0)+,D1-D7/A1-A3    ; Read 40 bytes.
        MOVEM.L D1-D7/A1-A3,-200(A0) ; Write 40 bytes.
        MOVEM.L (A0)+,D1-D7/A1-A3    ; Read 40 bytes.
        MOVEM.L D1-D7/A1-A3,-200(A0) ; Write 40 bytes.
        DBRA    D0,VSCROLL           ; Until 199 lines scrolled.

	MOVE.W	#$0B,-(SP)	; CONSTAT function code.
	TRAP	#1		; Call GEMDOS for checking keypress.
	ADDQ.L	#2,SP		; Correct stack pointer.
	CMPI.W	#$FFFF,D0	; Check for keypress.
	BEQ	LEAVE		; Exit on keypress.

; Over and over.
	
        BRA     RESTART         ; Over and over.

; Quit off.

LEAVE

; Restore colours.

	PEA	SAVPAL(PC)	; Address of colour save area.
        MOVE.W  #6,-(SP)        ; SETPALETTE function number.
        TRAP    #14             ; Call XBIOS for setting new palette.
        ADDQ.L  #6,SP           ; Correct stack pointer.

; Terminate program execution.

TERM    CLR.W   -(SP)           ; GEMDOS TERM.
        TRAP    #1              ; Call GEMDOS.

; Variables and data.

	EVEN
	
SCREEN  DS.L    1               ; Video memory start address pointer.
SSAV	DS.L	1		; Execution mode storage.
HANDLE  DS.W    1               ; File handle storage.
BUFPTR  DS.L    1               ; Neochrome file memory pointer.
SAVPAL	DS.W	16		; Save area for old palette values.

	EVEN
	
NEOFNAM DC.B    'NOFETCH.NEO',0

        END
        