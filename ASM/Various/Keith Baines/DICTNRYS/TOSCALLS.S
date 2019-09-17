* Macros for TOS system calls   23.7.88

sys_call	MACRO
	move.w	#\2,-(a7)
	trap	#\1
	IFGT	\3-8
	lea	\3(a7),a7
	ELSEIF
	addq.l	#\3,a7
	ENDC
	ENDM

call_gemdos	MACRO
	sys_call	1,\1,\2
	ENDM


call_bios	MACRO
	sys_call	13,\1,\2
	ENDM

call_xbios	MACRO
	sys_call	14,\1,\2
	ENDM
	
	
* Macro to release un-used memory
* first parameter is array to hold base page address
* second paramter is address for new stack


start_up	MACRO	Ax,Newstack
	MOVEA.L	A7,\1		Save original stack
	LEA	\2,A7		Set stack in kept area
	MOVEA.L	4(\1),\1		Ax=address of base page
	MOVE.L	$C(\1),D0		D0=length of text
	ADD.L	$14(\1),D0	  	+ length of data
	ADD.L	$1C(\1),D0	  	+ length of BSS
	ADDI.L	#$100,D0	   	+ length of base-page

	MOVE.L	D0,-(A7)		Size to keep
	MOVE.L	\1,-(A7)		Address to keep
	CLR.W	-(A7)		Zero word
	call_gemdos $4A,12

	ENDM
	