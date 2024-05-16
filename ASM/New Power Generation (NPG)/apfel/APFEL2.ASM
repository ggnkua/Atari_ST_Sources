; Code: Roland Spatzenegger
; ( Apollo of NPG ;)
PBC        equ     $ffe0
HSR       equ     $ffe9
HTRX      equ     $ffeb
;x:
REAL      equ     $0
REALC     equ     $1
IMG       equ     $2
IMGC      equ     $3
counter   equ     $4
	org     p:$0
	jmp     start
	org     p:$40
 ;************************************************************
exit_loop:
	move	r0,x1
	jsr	send_data
	jmp	main_loop
	rts
start:
	AND     #$F3,mr                           ;no scaling
	movep	#$000001,x:PBC
main_loop:
	jsr	read_data
	move	x1,r0
	jsr	read_data
	move	x1,x:REAL
	move	x1,x:REALC
	jsr	read_data
	move	x1,x:IMG
	move	x1,x:IMGC

	move	x:IMG,b1
  	move	x:REAL,x0               ;real
loop:
	mpy     x0,x0,a b1,y0        	;a=r^2
	mac     y0,y0,a                 ;a=i^2+r^2
	jes     exit_loop
	mpy     x0,x0,a                           ;a=r^2
	mac     -y0,y0,a                          ;a=i^2-r^2
	asl     a                                 ;*2
	asl     a	   x:REALC,x1                              ;*2
	add     x1,a  
	jes     exit_loop
	mpy     x0,y0,b                            ;real*img
	asl     b	a1,x0                                 ;*2
	asl     b    (r0)-                             ;*2
	asl     b   x:IMGC,y0                              ;*2
	add     y0,b r0,a
	jes	exit_loop
	tst	a
	jne     loop
	move	r0,x1
	jsr	send_data
	jmp	main_loop
	rts
;************************************************************
send_data:
	jclr    #1,x:HSR,send_data                ;send data
	movep   x1,x:HTRX
	rts
read_data:
	jclr    #0,x:HSR,read_data                ;read data
	movep	x:HTRX,x1
	rts
;************************************************************
