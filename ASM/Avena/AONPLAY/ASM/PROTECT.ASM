; HOST PORT PROTECTOR
; .ASM file

;---------------------------------------------------------------------------
Save_Host_Internals:
	move	#"DSP",a
	move	#"030",b
; Receive all data into buffer 1
	move	#>"030",b
	move	#Saved_Host_Data_1,r0
_l1	wait_receive
	movep	x:<<hrx,x0
	move	x0,x:(r0)+
	cmp		x0,b
	jne		_l1

; Send "DSP"
	wait_transmit
	movep	a1,x:<<htx

; Receive all data again into buffer 2
	move	#Saved_Host_Data_2,r0
_l2	wait_receive
	movep	x:<<hrx,x0
	move	x0,x:(r0)+
	cmp		x0,a
	jne		_l2

; Now transmit the contents of buffer 1
	move	#Saved_Host_Data_1,r0
	nop
_l3:
	move	x:(r0)+,x0
	wait_transmit
	movep	x0,x:<<htx
	cmp		x0,b
	jne		_l3
	rts

;---------------------------------------------------------------------------
Restore_Host_Internals:
; Restore contents of buffer 2
	move	#Saved_Host_Data_2,r0
	move	#>"DSP",b
_l3:
	move	x:(r0)+,x0
	cmp		x0,b
	jeq		_l4
	wait_transmit
	movep	x0,x:<<hrx
	jmp		_l3
_l4	rts

;---------------------------------------------------------------------------
;	org	x:1
;Saved_Host_Data_1:
;	ds	10
;Saved_Host_Data_2:
;	ds	10




