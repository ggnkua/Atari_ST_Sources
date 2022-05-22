; '.Img' Decompressor routine for 1 plane image files
; CALL img_handler+0 depack it. 
; CALL img_handler+4 display to screen offset x,y.
		
TESTIT		LEA data_table(PC),A6
		LEA image_file(PC),A0
		MOVE.L A0,img_address(A6)
		LEA depack_buf(PC),A0
		MOVE.L A0,depackto_addr(A6)
		
		BSR IMG_ROTFILE
		BSR IMG_ROTFILE+4
		MOVE #7,-(SP)
		TRAP #1
		ADDQ.L #2,SP
		CLR -(SP)
		TRAP #1

; The img ROT file.

IMG_ROTFILE	BRA.W Decrunch_IMG
		BRA.W Showit_IMG

; The data structure to be access by depacker and GFA basic.

struct		RSRESET
; Returned vars
byte_width	RS.W 1          ; width of image in bytes
height		RS.W 1          ; height of image 
screen_res	RS.W 1		; physical screen res
error_flag	RS.W 1		; error flag!
depckdlength	RS.L 1		; depacked length return here
; Given Vars
img_address	RS.L 1          ; address of img file
depackto_addr	RS.L 1          ; address to depack to.
offset_x	RS.W 1          ; offset in x pixels to display
offset_y	RS.W 1          ; offset in y pixels to display
struct_size	RS.B 1		 

data_table	DS.B struct_size
		
Decrunch_IMG	LEA old_stack(PC),A0
		MOVE.L SP,(A0)			; Set a local stack
		LEA our_stack(PC),SP
		MOVE #4,-(SP)
		TRAP #14			; get rez from gem!
		ADDQ.L #2,SP
		LEA data_table(PC),A6
		MOVE.W D0,screen_res(A6)	; store screen rez
		CLR.W error_flag(A6)
		MOVE.L img_address(A6),A0
		MOVE.L depackto_addr(A6),A1		
		CMP #1,(A0)			; check img version is 1
		BNE error1
		MOVE 2(A0),D2			; headerlength(words)
		ADD D2,D2			;  "       "  (bytes)
		CMP #1,4(A0)			; no of planes
		BNE error2			; exit if not 1
		MOVE 12(A0),D0			; no of pixels wide
		MOVE 14(A0),D1			; no of pixels high
		SUBQ #1,D0			; width-1
		LSR #3,D0			; (width-1)/8
		ADDQ #1,D0			; +1(no of bytes)
		ADD D2,A0
		MOVE D0,byte_width(A6)
		MOVE D1,height(A6)
		MOVE D0,D4
		MULU D1,D4			; calc depacked length
		MOVE.L D4,depckdlength(A6)	; store it
		SUBQ #1,D1
line_loop:	MOVE.L A1,A2
		ADD D0,A2
		MOVEQ #0,D4
		MOVE.B (A0),D2			; is this line going 
		BNE.S not_linerep		; to be repeated
		MOVE.B 1(A0),D2
		BNE.S not_linerep
		CMP #$FF,2(A0)
		BNE.S not_linerep
		MOVE.B 3(A0),D4			; yes so store repeat
		ADDQ #4,A0			; count and advance ptr
not_linerep	CLR D2
		MOVE.B (A0)+,D2
		CMP.B #128,D2
		BNE notcopy
straight_copy:	MOVE.B (A0)+,D2			; no. of bytes to copy
		LEA .cpyback(PC),A3		
		ADD D2,D2
		SUB D2,A3
		JMP (A3)			; jump back thru list
		REPT 255
		MOVE.B (A0)+,(A1)+
		ENDR
.cpyback	BRA done1line
notcopy:	BCLR #7,D2			; clear or solid? 
		SNE D3
notsol		ADD D2,D2
		LEA done1line(PC),A3
		SUB D2,A3
		JMP (A3)			; jump back thru list
		REPT 127
		MOVE.B D3,(A1)+
		ENDR
done1line:	CMP.L A2,A1			; repeat until this line
		BNE not_linerep			; has been depacked
		SUBQ #2,D4			; repeat last line		
		BLE contdepack			; no then skip copyline
		MOVE.L A1,A2			; point to start 
		SUB D0,A2			; of last line
		LEA .copylinejmp(PC),A3			
		SUB D0,A3
		SUB D0,A3
.cpy		JMP (A3)
		REPT 80
		MOVE.B (A2)+,(A1)+
		ENDR
.copylinejmp	SUBQ #1,D1
		DBF D4,.cpy
contdepack:	DBF D1,line_loop
		LEA old_stack(PC),A0
		MOVE.L (A0),SP
		RTS

error1		LEA data_table(PC),A0		; Wrong img version
		MOVE #1,error_flag(A0)
		RTS

error2		LEA data_table(PC),A0		; not one plane!
		MOVE #2,error_flag(A0)
		RTS


; Copy img to screen.

Showit_IMG:	LEA old_stack(PC),A0
		MOVE.L SP,(A0)			; Set a local stack
		LEA our_stack(PC),SP
		MOVE #2,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		MOVE.L D0,A1			; screen base
		LEA data_table(PC),A6
		MOVE.L depackto_addr(A6),A0	; addr of depckd data.
		MOVE byte_width(A6),D0
		MOVE height(A6),D1

		MOVE screen_res(A6),D2
		MOVE #300,D3			; assume high res limit
		CMP #1,D2			; are we in medium?
		BNE.S .high
		MOVE #150,D3			; medium limit of 150 lines
.high		CMP D3,D1
		BLE.S .oklads
		MOVE D3,D1			; lower limit
.oklads		SUBQ #1,D1			; -1 for dbf
		ADD D0,D0
		ADD D0,D0
		LEA move1line(PC),A2
		ADD D0,A2
		MOVE (A2),-(SP)
		MOVE jmpto(PC),(A2)
		LEA contline(PC),A3	
i		SET 0
move1line	REPT 40
		MOVE.B (A0)+,i(A1)
		MOVE.B (A0)+,i+1(A1)
i		SET i+4
		ENDR
contline	LEA 160(A1),A1
		DBF D1,move1line		; copy for all lines.
		MOVE (SP)+,(A2)
		LEA old_stack(PC),A0
		MOVE.L (A0),SP			; restore stack
		RTS
jmpto		JMP (A3)
old_stack	DS.L 1
		DS.L 249
our_stack	DS.L 1
; Test stuff
image_file:	incbin adverts\poster.img
		even
depack_buf: