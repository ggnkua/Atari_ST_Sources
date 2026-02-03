u32 SCRIPT[] = {
/*






ABSOLUTE R_OK = 0x12345678
ABSOLUTE R_NEEDMORE = 0x12345679

;ABSOLUTE R_ERROR = -1
;ABSOLUTE R_NOSTATUS = -2
;ABSOLUTE R_NOMSG = -3;
ABSOLUTE R_NOSELECT = -4;
;ABSOLUTE R_NOCMD = -5;
ABSOLUTE R_UNKNPHASE = -6;
ABSOLUTE R_UNKNMESSAGE = -7;
ABSOLUTE R_SENDREJECT = -8;
ABSOLUTE R_MSGREJECT = -9;
ABSOLUTE R_DISCONNECT = -10;
ABSOLUTE R_GOT_SDTR = -11;
ABSOLUTE R_GOT_WDTR = -12;
ABSOLUTE R_GOT_IGNRESIDUE = -13;

ABSOLUTE R_TRACE = 0x55555555;

ABSOLUTE R_TEST = 0x55aa5aa5
ABSOLUTE R_TEST2 = 0x12345678

EXTERNAL scsi_status, msgin_buf, msgout_buf, scratch_buf

; Command-Struct:
ABSOLUTE d_select	= 0x00
ABSOLUTE d_unused	= 0x04	; 4 bytes unused
ABSOLUTE d_unused1	= 0x08	; 8 bytes unused (was msgin)
ABSOLUTE d_msgout	= 0x10
ABSOLUTE d_command	= 0x18
ABSOLUTE d_data0	= 0x20
ABSOLUTE d_data1	= 0x28
ABSOLUTE d_data2	= 0x30
ABSOLUTE d_data3	= 0x38
ABSOLUTE d_data4	= 0x40
ABSOLUTE d_data5	= 0x48
ABSOLUTE d_data6	= 0x50
ABSOLUTE d_data7	= 0x58

; Bits in DWT-Register:
ABSOLUTE STATE_GOT_MSGIN =  0x01

ENTRY Test1
ENTRY Test2
ENTRY Command
ENTRY cmd2
ENTRY Dispatch
ENTRY data_in
ENTRY data_in_end
ENTRY data_out
ENTRY data_out_end
ENTRY cleanup_data
ENTRY wait_reselect

Test1:
	NOP

at 0x00000000 : */	0x80880000,0x00000000,
/*
	INT  R_TEST2

at 0x00000002 : */	0x98080000,0x12345678,
/*

; Try a move memory from/to video ram (hardcoded addresses)
Test2:	MOVE MEMORY 0x10000, 0x20000000, 0x20010010

at 0x00000004 : */	0xc0010000,0x20000000,0x20010010,
/*
	MOVE MEMORY 1, 0x20000000, scsi_status

at 0x00000007 : */	0xc0000001,0x20000000,0,
/*
	INT  R_TEST

at 0x0000000a : */	0x98080000,0x55aa5aa5,
/*

; The following phase sequences are possible:
; 0  BUS FREE
; v
; 1  ARBITRATION -------+
; v                     v
; 2 SELECTION           3 RESELECTION
; v                     v
; 4 Message Out         5 Message In
; v                     v
;    (nearly all combinations of Message In/Out, Command, Data, Status)
;

sel_error:
	INT	R_NOSELECT

at 0x0000000c : */	0x98080000,0xfffffffc,
/*

Command:
	CLEAR	TARGET

at 0x0000000e : */	0x60000200,0x00000000,
/*
	MOVE	0 TO DWT

at 0x00000010 : */	0x783a0000,0x00000000,
/*
	SELECT	ATN FROM d_select, sel_error

at 0x00000012 : */	0x43000000,0x00000030,
/*
cmd2:	JUMP	data_in,	WHEN DATA_IN

at 0x00000014 : */	0x810b0000,0x000000e8,
/*
	JUMP	data_out,	IF DATA_OUT

at 0x00000016 : */	0x800a0000,0x000001f0,
/*
	CALL	dispatch

at 0x00000018 : */	0x88080000,0x00000070,
/*
	JUMP	cmd2	

at 0x0000001a : */	0x80080000,0x00000050,
/*

dispatch:
	
	RETURN,			WHEN DATA_IN

at 0x0000001c : */	0x910b0000,0x00000000,
/*
	RETURN,			IF DATA_OUT

at 0x0000001e : */	0x900a0000,0x00000000,
/*
	JUMP	status,		IF STATUS

at 0x00000020 : */	0x830a0000,0x000000b0,
/*
	JUMP	msg_in,		IF MSG_IN

at 0x00000022 : */	0x870a0000,0x00000338,
/*
	JUMP	msg_out,	IF MSG_OUT

at 0x00000024 : */	0x860a0000,0x000000c0,
/*
	JUMP	command,	IF CMD

at 0x00000026 : */	0x820a0000,0x000000d8,
/*
	INT	R_UNKNPHASE

at 0x00000028 : */	0x98080000,0xfffffffa,
/*
	JUMP	dispatch

at 0x0000002a : */	0x80080000,0x00000070,
/*

status:
	
	MOVE	1,scsi_status,	WHEN STATUS

at 0x0000002c : */	0x0b000001,0,
/*
	JUMP	dispatch

at 0x0000002e : */	0x80080000,0x00000070,
/*
	
msg_out:
	
	MOVE	FROM d_msgout,	WHEN MSG_OUT

at 0x00000030 : */	0x1e000000,0x00000010,
/*
	CLEAR	ATN

at 0x00000032 : */	0x60000008,0x00000000,
/*
	JUMP	dispatch

at 0x00000034 : */	0x80080000,0x00000070,
/*
	
command:
	
	MOVE	FROM d_command,	WHEN CMD

at 0x00000036 : */	0x1a000000,0x00000018,
/*
	JUMP	dispatch

at 0x00000038 : */	0x80080000,0x00000070,
/*

data_in:
	MOVE	FROM d_data0+0x00,	WHEN DATA_IN

at 0x0000003a : */	0x19000000,0x00000020,
/*

	JUMP	cmd2,			WHEN NOT DATA_IN

at 0x0000003c : */	0x81030000,0x00000050,
/*
	MOVE	FROM d_data0+0x08,	WHEN DATA_IN

at 0x0000003e : */	0x19000000,0x00000028,
/*
	JUMP	cmd2,			WHEN NOT DATA_IN

at 0x00000040 : */	0x81030000,0x00000050,
/*
	MOVE	FROM d_data0+0x10,	WHEN DATA_IN

at 0x00000042 : */	0x19000000,0x00000030,
/*
	JUMP	cmd2,			WHEN NOT DATA_IN

at 0x00000044 : */	0x81030000,0x00000050,
/*
	MOVE	FROM d_data0+0x18,	WHEN DATA_IN

at 0x00000046 : */	0x19000000,0x00000038,
/*
	JUMP	cmd2,			WHEN NOT DATA_IN

at 0x00000048 : */	0x81030000,0x00000050,
/*
	MOVE	FROM d_data0+0x20,	WHEN DATA_IN

at 0x0000004a : */	0x19000000,0x00000040,
/*
	JUMP	cmd2,			WHEN NOT DATA_IN

at 0x0000004c : */	0x81030000,0x00000050,
/*
	MOVE	FROM d_data0+0x28,	WHEN DATA_IN

at 0x0000004e : */	0x19000000,0x00000048,
/*
	JUMP	cmd2,			WHEN NOT DATA_IN

at 0x00000050 : */	0x81030000,0x00000050,
/*
	MOVE	FROM d_data0+0x30,	WHEN DATA_IN

at 0x00000052 : */	0x19000000,0x00000050,
/*
	JUMP	cmd2,			WHEN NOT DATA_IN

at 0x00000054 : */	0x81030000,0x00000050,
/*
	MOVE	FROM d_data0+0x38,	WHEN DATA_IN

at 0x00000056 : */	0x19000000,0x00000058,
/*
	JUMP	cmd2,			WHEN NOT DATA_IN

at 0x00000058 : */	0x81030000,0x00000050,
/*
	MOVE	FROM d_data0+0x40,	WHEN DATA_IN

at 0x0000005a : */	0x19000000,0x00000060,
/*
	JUMP	cmd2,			WHEN NOT DATA_IN

at 0x0000005c : */	0x81030000,0x00000050,
/*
	MOVE	FROM d_data0+0x48,	WHEN DATA_IN

at 0x0000005e : */	0x19000000,0x00000068,
/*
	JUMP	cmd2,			WHEN NOT DATA_IN

at 0x00000060 : */	0x81030000,0x00000050,
/*
	MOVE	FROM d_data0+0x50,	WHEN DATA_IN

at 0x00000062 : */	0x19000000,0x00000070,
/*
	JUMP	cmd2,			WHEN NOT DATA_IN

at 0x00000064 : */	0x81030000,0x00000050,
/*
	MOVE	FROM d_data0+0x58,	WHEN DATA_IN

at 0x00000066 : */	0x19000000,0x00000078,
/*
	JUMP	cmd2,			WHEN NOT DATA_IN

at 0x00000068 : */	0x81030000,0x00000050,
/*
	MOVE	FROM d_data0+0x60,	WHEN DATA_IN

at 0x0000006a : */	0x19000000,0x00000080,
/*
	JUMP	cmd2,			WHEN NOT DATA_IN

at 0x0000006c : */	0x81030000,0x00000050,
/*
	MOVE	FROM d_data0+0x68,	WHEN DATA_IN

at 0x0000006e : */	0x19000000,0x00000088,
/*
	JUMP	cmd2,			WHEN NOT DATA_IN

at 0x00000070 : */	0x81030000,0x00000050,
/*
	MOVE	FROM d_data0+0x70,	WHEN DATA_IN

at 0x00000072 : */	0x19000000,0x00000090,
/*
	JUMP	cmd2,			WHEN NOT DATA_IN

at 0x00000074 : */	0x81030000,0x00000050,
/*
	MOVE	FROM d_data0+0x78,	WHEN DATA_IN

at 0x00000076 : */	0x19000000,0x00000098,
/*

	JUMP	cmd2,			WHEN NOT DATA_IN

at 0x00000078 : */	0x81030000,0x00000050,
/*
data_in_end:
	INT	R_NEEDMORE

at 0x0000007a : */	0x98080000,0x12345679,
/*

data_out:
	MOVE	FROM d_data0+0x00,	WHEN DATA_OUT

at 0x0000007c : */	0x18000000,0x00000020,
/*
	JUMP	cmd2,			WHEN NOT DATA_OUT

at 0x0000007e : */	0x80030000,0x00000050,
/*
	MOVE	FROM d_data0+0x08,	WHEN DATA_OUT

at 0x00000080 : */	0x18000000,0x00000028,
/*
	JUMP	cmd2,			WHEN NOT DATA_OUT

at 0x00000082 : */	0x80030000,0x00000050,
/*
	MOVE	FROM d_data0+0x10,	WHEN DATA_OUT

at 0x00000084 : */	0x18000000,0x00000030,
/*
	JUMP	cmd2,			WHEN NOT DATA_OUT

at 0x00000086 : */	0x80030000,0x00000050,
/*
	MOVE	FROM d_data0+0x18,	WHEN DATA_OUT

at 0x00000088 : */	0x18000000,0x00000038,
/*
	JUMP	cmd2,			WHEN NOT DATA_OUT

at 0x0000008a : */	0x80030000,0x00000050,
/*
	MOVE	FROM d_data0+0x20,	WHEN DATA_OUT

at 0x0000008c : */	0x18000000,0x00000040,
/*
	JUMP	cmd2,			WHEN NOT DATA_OUT

at 0x0000008e : */	0x80030000,0x00000050,
/*
	MOVE	FROM d_data0+0x28,	WHEN DATA_OUT

at 0x00000090 : */	0x18000000,0x00000048,
/*
	JUMP	cmd2,			WHEN NOT DATA_OUT

at 0x00000092 : */	0x80030000,0x00000050,
/*
	MOVE	FROM d_data0+0x30,	WHEN DATA_OUT

at 0x00000094 : */	0x18000000,0x00000050,
/*
	JUMP	cmd2,			WHEN NOT DATA_OUT

at 0x00000096 : */	0x80030000,0x00000050,
/*
	MOVE	FROM d_data0+0x38,	WHEN DATA_OUT

at 0x00000098 : */	0x18000000,0x00000058,
/*
	JUMP	cmd2,			WHEN NOT DATA_OUT

at 0x0000009a : */	0x80030000,0x00000050,
/*
	MOVE	FROM d_data0+0x40,	WHEN DATA_OUT

at 0x0000009c : */	0x18000000,0x00000060,
/*
	JUMP	cmd2,			WHEN NOT DATA_OUT

at 0x0000009e : */	0x80030000,0x00000050,
/*
	MOVE	FROM d_data0+0x48,	WHEN DATA_OUT

at 0x000000a0 : */	0x18000000,0x00000068,
/*
	JUMP	cmd2,			WHEN NOT DATA_OUT

at 0x000000a2 : */	0x80030000,0x00000050,
/*
	MOVE	FROM d_data0+0x50,	WHEN DATA_OUT

at 0x000000a4 : */	0x18000000,0x00000070,
/*
	JUMP	cmd2,			WHEN NOT DATA_OUT

at 0x000000a6 : */	0x80030000,0x00000050,
/*
	MOVE	FROM d_data0+0x58,	WHEN DATA_OUT

at 0x000000a8 : */	0x18000000,0x00000078,
/*
	JUMP	cmd2,			WHEN NOT DATA_OUT

at 0x000000aa : */	0x80030000,0x00000050,
/*
	MOVE	FROM d_data0+0x60,	WHEN DATA_OUT

at 0x000000ac : */	0x18000000,0x00000080,
/*
	JUMP	cmd2,			WHEN NOT DATA_OUT

at 0x000000ae : */	0x80030000,0x00000050,
/*
	MOVE	FROM d_data0+0x68,	WHEN DATA_OUT

at 0x000000b0 : */	0x18000000,0x00000088,
/*
	JUMP	cmd2,			WHEN NOT DATA_OUT

at 0x000000b2 : */	0x80030000,0x00000050,
/*
	MOVE	FROM d_data0+0x70,	WHEN DATA_OUT

at 0x000000b4 : */	0x18000000,0x00000090,
/*
	JUMP	cmd2,			WHEN NOT DATA_OUT

at 0x000000b6 : */	0x80030000,0x00000050,
/*
	MOVE	FROM d_data0+0x78,	WHEN DATA_OUT

at 0x000000b8 : */	0x18000000,0x00000098,
/*
	JUMP	cmd2,			WHEN NOT DATA_OUT

at 0x000000ba : */	0x80030000,0x00000050,
/*
data_out_end:
	INT	R_NEEDMORE

at 0x000000bc : */	0x98080000,0x12345679,
/*

; cleanup data phase when target wants to transfer more data than 
; necessary
cleanup_data:
	
	JUMP	dummy_data_in,	WHEN DATA_IN

at 0x000000be : */	0x810b0000,0x00000328,
/*
	JUMP	dummy_data_out,	IF DATA_OUT

at 0x000000c0 : */	0x800a0000,0x00000318,
/*
	CALL	dispatch

at 0x000000c2 : */	0x88080000,0x00000070,
/*
	JUMP	cleanup_data

at 0x000000c4 : */	0x80080000,0x000002f8,
/*

dummy_data_out:
	MOVE	1,scratch_buf, WHEN DATA_OUT

at 0x000000c6 : */	0x08000001,0,
/*
	JUMP	cleanup_data

at 0x000000c8 : */	0x80080000,0x000002f8,
/*

dummy_data_in:
	MOVE	1,scratch_buf, WHEN DATA_IN

at 0x000000ca : */	0x09000001,0,
/*
	JUMP	cleanup_data

at 0x000000cc : */	0x80080000,0x000002f8,
/*

msg_in:
	
	JUMP	dispatch,	WHEN NOT MSG_IN

at 0x000000ce : */	0x87030000,0x00000070,
/*
	MOVE	DWT | STATE_GOT_MSGIN TO DWT

at 0x000000d0 : */	0x7a3a0100,0x00000000,
/*
	MOVE	1,msgin_buf,	WHEN MSG_IN

at 0x000000d2 : */	0x0f000001,0,
/*
        JUMP	msg_complete, 	IF 0x00

at 0x000000d4 : */	0x800c0000,0x000003e0,
/*
        JUMP	msg_disconnect, IF 0x04

at 0x000000d6 : */	0x800c0004,0x00000400,
/*
        JUMP	msg_saveptr, 	IF 0x02

at 0x000000d8 : */	0x800c0002,0x000003d0,
/*
        JUMP	msg_restptr,	IF 0x03

at 0x000000da : */	0x800c0003,0x000003d8,
/*
        JUMP	msg_extended,	IF 0x01	; extended message

at 0x000000dc : */	0x800c0001,0x00000490,
/*
        JUMP	clrack,		IF 0x08	; NOP

at 0x000000de : */	0x800c0008,0x000003c0,
/*
        JUMP	msg_reject,	IF 0x07	; Reject

at 0x000000e0 : */	0x800c0007,0x00000448,
/*
        JUMP	msg_ign_residue,IF 0x23	; ignore Wide residue

at 0x000000e2 : */	0x800c0023,0x00000460,
/*
        JUMP	clrack,	IF 0x80, AND MASK 0x7f	; Identify

at 0x000000e4 : */	0x800c7f80,0x000003c0,
/*
	INT	R_UNKNMESSAGE

at 0x000000e6 : */	0x98080000,0xfffffff9,
/*
	JUMP	clrack

at 0x000000e8 : */	0x80080000,0x000003c0,
/*

msg_bad:
;	MOVE	0x07 TO SCRATCHA0		; REJECT Message
;	MOVE	MEMORY 1,SCRATCHA0, msgout_buf
	SET	ATN

at 0x000000ea : */	0x58000008,0x00000000,
/*
	INT	R_SENDREJECT

at 0x000000ec : */	0x98080000,0xfffffff8,
/*
	JUMP	clrack				; will restart here

at 0x000000ee : */	0x80080000,0x000003c0,
/*

clrack:
	CLEAR	ACK

at 0x000000f0 : */	0x60000040,0x00000000,
/*
	JUMP	dispatch

at 0x000000f2 : */	0x80080000,0x00000070,
/*
	
msg_saveptr:
	JUMP	clrack

at 0x000000f4 : */	0x80080000,0x000003c0,
/*
msg_restptr:
	JUMP	clrack

at 0x000000f6 : */	0x80080000,0x000003c0,
/*
	

; MSG 00 = command complete
msg_complete:
	
	MOVE	SCNTL2 & 0x7F TO SCNTL2		; expect disconnect

at 0x000000f8 : */	0x7c027f00,0x00000000,
/*
;	CLEAR	ACK ATN
	CLEAR	ACK

at 0x000000fa : */	0x60000040,0x00000000,
/*
	WAIT	DISCONNECT

at 0x000000fc : */	0x48000000,0x00000000,
/*
	INT	R_OK

at 0x000000fe : */	0x98080000,0x12345678,
/*

; MSG 04 = Disconnect
msg_disconnect:
	
	MOVE SCNTL2 & 0x7F TO SCNTL2		; expect disconnect

at 0x00000100 : */	0x7c027f00,0x00000000,
/*
	CLEAR	ACK

at 0x00000102 : */	0x60000040,0x00000000,
/*
	WAIT	DISCONNECT

at 0x00000104 : */	0x48000000,0x00000000,
/*
	MOVE	CTEST3 | 0x04 to CTEST3		; Clear the DMA fifo

at 0x00000106 : */	0x7a1b0400,0x00000000,
/*
	MOVE	STEST3 | 0x02 to STEST3		; Clear the SCSI fifo

at 0x00000108 : */	0x7a4f0200,0x00000000,
/*
	INT	R_DISCONNECT

at 0x0000010a : */	0x98080000,0xfffffff6,
/*
; restart here
wait_reselect:
	
	WAIT	RESELECT wait_resel2

at 0x0000010c : */	0x50000000,0x00000438,
/*
wait_resel2:
	
	SELECT	FROM d_select, wait_resel3

at 0x0000010e : */	0x42000000,0x00000440,
/*
wait_resel3:
	
	JUMP	dispatch

at 0x00000110 : */	0x80080000,0x00000070,
/*
	
msg_reject:
	
	CLEAR	ACK

at 0x00000112 : */	0x60000040,0x00000000,
/*
	INT	R_MSGREJECT

at 0x00000114 : */	0x98080000,0xfffffff7,
/*
	JUMP	dispatch

at 0x00000116 : */	0x80080000,0x00000070,
/*

msg_ign_residue:
	
	CLEAR	ACK

at 0x00000118 : */	0x60000040,0x00000000,
/*
	JUMP	dispatch,	WHEN NOT MSG_IN

at 0x0000011a : */	0x87030000,0x00000070,
/*
	MOVE	1,msgin_buf+1,	WHEN MSG_IN

at 0x0000011c : */	0x0f000001,0 + 0x00000001,
/*
	JUMP	clrack,		IF 0x00

at 0x0000011e : */	0x800c0000,0x000003c0,
/*
	INT	R_GOT_IGNRESIDUE

at 0x00000120 : */	0x98080000,0xfffffff3,
/*
	JUMP	dispatch

at 0x00000122 : */	0x80080000,0x00000070,
/*

msg_extended:
	
	CLEAR	ACK

at 0x00000124 : */	0x60000040,0x00000000,
/*
	JUMP	dispatch,	WHEN NOT MSG_IN

at 0x00000126 : */	0x87030000,0x00000070,
/*
	MOVE	1,msgin_buf+1,	WHEN MSG_IN	; get length

at 0x00000128 : */	0x0f000001,0 + 0x00000001,
/*
	JUMP	msg_ext3,	IF 0x03

at 0x0000012a : */	0x800c0003,0x00000500,
/*
	JUMP	msg_bad,	IF NOT 0x02

at 0x0000012c : */	0x80040002,0x000003a8,
/*
msg_ext_2:
	
	CLEAR	ACK

at 0x0000012e : */	0x60000040,0x00000000,
/*
	JUMP	dispatch,	WHEN NOT MSG_IN

at 0x00000130 : */	0x87030000,0x00000070,
/*
	MOVE	1,msgin_buf+2,	WHEN MSG_IN	; get code

at 0x00000132 : */	0x0f000001,0 + 0x00000002,
/*
	JUMP	msg_bad,	IF NOT 0x03	; not WDTR -> unknown

at 0x00000134 : */	0x80040003,0x000003a8,
/*
msg_wdtr:
	
	CLEAR	ACK

at 0x00000136 : */	0x60000040,0x00000000,
/*
	JUMP	dispatch,	WHEN NOT MSG_IN

at 0x00000138 : */	0x87030000,0x00000070,
/*
	MOVE	1,msgin_buf+3,	WHEN MSG_IN	; get parameter

at 0x0000013a : */	0x0f000001,0 + 0x00000003,
/*
	INT	R_GOT_WDTR

at 0x0000013c : */	0x98080000,0xfffffff4,
/*
	JUMP	dispatch

at 0x0000013e : */	0x80080000,0x00000070,
/*
	
msg_ext3:
	
	CLEAR	ACK

at 0x00000140 : */	0x60000040,0x00000000,
/*
	JUMP	dispatch,	WHEN NOT MSG_IN

at 0x00000142 : */	0x87030000,0x00000070,
/*
	MOVE	1,msgin_buf+2,	WHEN MSG_IN	; get code

at 0x00000144 : */	0x0f000001,0 + 0x00000002,
/*
	JUMP	msg_bad,	IF NOT 0x02	; not SDTR -> unknown

at 0x00000146 : */	0x80040002,0x000003a8,
/*
msg_sdtr:
	
	CLEAR	ACK

at 0x00000148 : */	0x60000040,0x00000000,
/*
	JUMP	dispatch,	WHEN NOT MSG_IN

at 0x0000014a : */	0x87030000,0x00000070,
/*
	MOVE	2,msgin_buf+3,	WHEN MSG_IN

at 0x0000014c : */	0x0f000002,0 + 0x00000003,
/*
	INT	R_GOT_SDTR

at 0x0000014e : */	0x98080000,0xfffffff5,
/*
	JUMP	dispatch

at 0x00000150 : */	0x80080000,0x00000070,
};

#define A_R_DISCONNECT	0xfffffff6
u32 A_R_DISCONNECT_used[] = {
	0x0000010b,
};

#define A_R_GOT_IGNRESIDUE	0xfffffff3
u32 A_R_GOT_IGNRESIDUE_used[] = {
	0x00000121,
};

#define A_R_GOT_SDTR	0xfffffff5
u32 A_R_GOT_SDTR_used[] = {
	0x0000014f,
};

#define A_R_GOT_WDTR	0xfffffff4
u32 A_R_GOT_WDTR_used[] = {
	0x0000013d,
};

#define A_R_MSGREJECT	0xfffffff7
u32 A_R_MSGREJECT_used[] = {
	0x00000115,
};

#define A_R_NEEDMORE	0x12345679
u32 A_R_NEEDMORE_used[] = {
	0x0000007b,
	0x000000bd,
};

#define A_R_NOSELECT	0xfffffffc
u32 A_R_NOSELECT_used[] = {
	0x0000000d,
};

#define A_R_OK	0x12345678
u32 A_R_OK_used[] = {
	0x000000ff,
};

#define A_R_SENDREJECT	0xfffffff8
u32 A_R_SENDREJECT_used[] = {
	0x000000ed,
};

#define A_R_TEST	0x55aa5aa5
u32 A_R_TEST_used[] = {
	0x0000000b,
};

#define A_R_TEST2	0x12345678
u32 A_R_TEST2_used[] = {
	0x00000003,
};

#define A_R_TRACE	0x55555555
u32 A_R_TRACE_used[] = {
};

#define A_R_UNKNMESSAGE	0xfffffff9
u32 A_R_UNKNMESSAGE_used[] = {
	0x000000e7,
};

#define A_R_UNKNPHASE	0xfffffffa
u32 A_R_UNKNPHASE_used[] = {
	0x00000029,
};

#define A_STATE_GOT_MSGIN	0x00000001
u32 A_STATE_GOT_MSGIN_used[] = {
	0x000000d0,
};

#define A_d_command	0x00000018
u32 A_d_command_used[] = {
	0x00000037,
};

#define A_d_data0	0x00000020
u32 A_d_data0_used[] = {
	0x0000003b,
	0x0000003f,
	0x00000043,
	0x00000047,
	0x0000004b,
	0x0000004f,
	0x00000053,
	0x00000057,
	0x0000005b,
	0x0000005f,
	0x00000063,
	0x00000067,
	0x0000006b,
	0x0000006f,
	0x00000073,
	0x00000077,
	0x0000007d,
	0x00000081,
	0x00000085,
	0x00000089,
	0x0000008d,
	0x00000091,
	0x00000095,
	0x00000099,
	0x0000009d,
	0x000000a1,
	0x000000a5,
	0x000000a9,
	0x000000ad,
	0x000000b1,
	0x000000b5,
	0x000000b9,
};

#define A_d_data1	0x00000028
u32 A_d_data1_used[] = {
};

#define A_d_data2	0x00000030
u32 A_d_data2_used[] = {
};

#define A_d_data3	0x00000038
u32 A_d_data3_used[] = {
};

#define A_d_data4	0x00000040
u32 A_d_data4_used[] = {
};

#define A_d_data5	0x00000048
u32 A_d_data5_used[] = {
};

#define A_d_data6	0x00000050
u32 A_d_data6_used[] = {
};

#define A_d_data7	0x00000058
u32 A_d_data7_used[] = {
};

#define A_d_msgout	0x00000010
u32 A_d_msgout_used[] = {
	0x00000031,
};

#define A_d_select	0x00000000
u32 A_d_select_used[] = {
	0x00000012,
	0x0000010e,
};

#define A_d_unused	0x00000004
u32 A_d_unused_used[] = {
};

#define A_d_unused1	0x00000008
u32 A_d_unused1_used[] = {
};

#define Ent_Command	0x00000038
#define Ent_Dispatch	0x00000000
#define Ent_Test1	0x00000000
#define Ent_Test2	0x00000010
#define Ent_cleanup_data	0x000002f8
#define Ent_cmd2	0x00000050
#define Ent_data_in	0x000000e8
#define Ent_data_in_end	0x000001e8
#define Ent_data_out	0x000001f0
#define Ent_data_out_end	0x000002f0
#define Ent_wait_reselect	0x00000430
u32 LABELPATCHES[] = {
	0x00000013,
	0x00000015,
	0x00000017,
	0x00000019,
	0x0000001b,
	0x00000021,
	0x00000023,
	0x00000025,
	0x00000027,
	0x0000002b,
	0x0000002f,
	0x00000035,
	0x00000039,
	0x0000003d,
	0x00000041,
	0x00000045,
	0x00000049,
	0x0000004d,
	0x00000051,
	0x00000055,
	0x00000059,
	0x0000005d,
	0x00000061,
	0x00000065,
	0x00000069,
	0x0000006d,
	0x00000071,
	0x00000075,
	0x00000079,
	0x0000007f,
	0x00000083,
	0x00000087,
	0x0000008b,
	0x0000008f,
	0x00000093,
	0x00000097,
	0x0000009b,
	0x0000009f,
	0x000000a3,
	0x000000a7,
	0x000000ab,
	0x000000af,
	0x000000b3,
	0x000000b7,
	0x000000bb,
	0x000000bf,
	0x000000c1,
	0x000000c3,
	0x000000c5,
	0x000000c9,
	0x000000cd,
	0x000000cf,
	0x000000d5,
	0x000000d7,
	0x000000d9,
	0x000000db,
	0x000000dd,
	0x000000df,
	0x000000e1,
	0x000000e3,
	0x000000e5,
	0x000000e9,
	0x000000ef,
	0x000000f3,
	0x000000f5,
	0x000000f7,
	0x0000010d,
	0x0000010f,
	0x00000111,
	0x00000117,
	0x0000011b,
	0x0000011f,
	0x00000123,
	0x00000127,
	0x0000012b,
	0x0000012d,
	0x00000131,
	0x00000135,
	0x00000139,
	0x0000013f,
	0x00000143,
	0x00000147,
	0x0000014b,
	0x00000151,
};

struct {
	u32	offset;
	void		*address;
} EXTERNAL_PATCHES[] = {
	{0x0000014d, &msgin_buf},
	{0x00000145, &msgin_buf},
	{0x0000013b, &msgin_buf},
	{0x00000133, &msgin_buf},
	{0x00000129, &msgin_buf},
	{0x0000011d, &msgin_buf},
	{0x000000d3, &msgin_buf},
	{0x000000cb, &scratch_buf},
	{0x000000c7, &scratch_buf},
	{0x0000002d, &scsi_status},
	{0x00000009, &scsi_status},
};

u32 INSTRUCTIONS	= 168;
u32 PATCHES	= 84;
u32 EXTERNAL_PATCHES_LEN	= 11;
