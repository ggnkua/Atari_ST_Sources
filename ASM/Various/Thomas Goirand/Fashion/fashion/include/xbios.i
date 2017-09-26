*** XBIOS ROUTINES ***

Bconmap	macro	; devno
	move.w	\1,-(sp)
	move.w	#$2c,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

Bioskey	macro
	move.w	#$18,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

Blitmode	macro	; mode
	move.w	\1,-(sp)
	move.w	#$40,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

Buffoper	macro	; mode
	move.w	\1,-(sp)
	move.w	#$88,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

Cursconf	macro	; rate,mode
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.w	#$15,-(sp)
	trap	#14
	addq.l	#6,sp
	endm

Dbmsg	macro	; msg_arg,msg_num
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	move.w	#$5,-(sp)
	move.w	#$0b,-(sp)
	trap	#14
	endm

Devconnect	macro	; protocol,prescale,clk,dest,source
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.w	\3,-(sp)
	move.w	\4,-(sp)
	move.w	\5,-(sp)
	move.w	#$8b,-(sp)
	trap	#14
	lea		12(sp),sp
	endm

DMAread	macro	; dev,buf,count,sector
	move.w	\1,-(sp)
	move.l	\2,-(sp)
	move.w	\3,-(sp)
	move.l	\4,-(sp)
	move.w	#$2a,-(sp)
	trap	#14
	lea		14(sp),sp
	endm

DMAwrite	macro	; dev,buf,count,sector
	move.w	\1,-(sp)
	move.l	\2,-(sp)
	move.w	\3,-(sp)
	move.l	\4,-(sp)
	move.w	#$2b,-(sp)
	trap	#14
	lea		14(sp),sp
	endm

Dosound	macro	; cmdlist
	move.l	\1,-(sp)
	move.w	#$,-(sp)
	trap	#14
	endm

Dsp_Available	macro	; yavail,xavail
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.w	#$6a,-(sp)
	trap	#14
	lea		10(sp),sp
	endm

Dsp_Blkbytes	macro	; size_out,data_out,size_in,data_in
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.l	\3,-(sp)
	move.l	\4,-(sp)
	move.w	#$7c,-(sp)
	trap	#14
	lea		18(sp),sp
	endm

Dsp_Blkhandshake	macro	; size_out,data_out,size_in,data_in
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.l	\3,-(sp)
	move.l	\4,-(sp)
	move.w	#$61,-(sp)
	trap	#14
	lea		18(sp),sp
	endm

Dsp_BlkUnpacked	macro	; size_out,data_out,size_in,data_in
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.l	\3,-(sp)
	move.l	\4,-(sp)
	move.w	#$62,-(sp)
	trap	#14
	lea		18(sp),sp
	endm

Dsp_BlkWords	macro	; size_out,data_out,size_in,data_in
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.l	\3,-(sp)
	move.l	\4,-(sp)
	move.w	#$7b,-(sp)
	trap	#14
	lea		18(sp),sp
	endm

Dsp_DoBlock	macro	; size_out,data_out,size_in,data_in
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.l	\3,-(sp)
	move.l	\4,-(sp)
	move.w	#$62,-(sp)
	trap	#14
	lea		18(sp),sp
	endm

Dsp_ExecBoot	macro	; ability,codesize,codeptr
	move.w	\1,-(sp)
	move.l	\2,-(sp)
	move.l	\3,-(sp)
	move.w	#$6e,-(sp)
	trap	#14
	lea		12(sp),sp
	endm

Dsp_ExecProg	macro	; ability,codesize,codeptr
	move.w	\1,-(sp)
	move.l	\2,-(sp)
	move.l	\3,-(sp)
	move.w	#$6d,-(sp)
	trap	#14
	lea		12(sp),sp
	endm

Dsp_FlushSubroutines	macro
	move.w	#$73,-(sp)
	trap	#14
	addq.l	#2,sp
	endm

Dsp_GetProgAbility	macro
	move.w	#$72,-(sp)
	trap	#14
	addq.l	#2,sp
	endm

Dsp_GetWordSize	macro
	move.w	#$67,-(sp)
	trap	#14
	addq.l	#2,sp
	endm

Dsp_Hf0	macro	; flag
	move.w	\1,-(sp)
	move.w	#$73,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

Dsp_Hf1	macro	; flag
	move.w	\1,-(sp)
	move.w	#$78,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

Dsp_Hf2	macro	; flag
	move.w	\1,-(sp)
	move.w	#$79,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

Dsp_Hf3	macro	; flag
	move.w	\1,-(sp)
	move.w	#$7a,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

Dsp_Hstat	macro
	move.w	#$7d,-(sp)
	trap	#14
	addq.l	#2,sp
	endm

Dsp_InqSubrAbility	macro	; ability
	move.w	\1,-(sp)
	move.w	#$75,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

Dsp_InStream	macro	; blokcs_done,num_blocks,block_size,data_in
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.l	\3,-(sp)
	move.l	\4,-(sp)
	move.l	#$63,-(sp)
	trap	#14
	lea	18(sp),sp
	endm

Dsp_IOStream	macro	; blokcs_done,num_blocks,block_outsize,block_insize,data_in,data_out
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.l	\3,-(sp)
	move.l	\4,-(sp)
	move.l	\5,-(sp)
	move.l	\6,-(sp)
	move.w	#$64,-(sp)
	trap	#14
	lea		26(sp),sp
	endm

Dsp_LoadProg	macro	; buf,ability,file
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	move.l	\3,-(sp)
	move.w	#$6c,-(sp)
	trap	#14
	lea		12(sp),sp
	endm

Dsp_LoadSubroutine	macro	; ability,size,ptr
	move.w	\1,-(sp)
	move.l	\2,,-(sp)
	move.l	\3,-(sp)
	move.w	\4,-(sp)
	trap	#14
	lea		12(sp),sp
	endm

Dsp_Lock	macro
	move.w	#$68,-(sp)
	trap	#14
	addq.l	#2,sp
	endm

Dsp_LodToBinary	macro	; codeptr,file
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.w	#$6f,-(sp)
	trap	#14
	lea		10(sp),sp
	endm

Dsp_MultBlock	macro	; receiveblks,sendblks,numreceive,numsend
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.l	\3,-(sp)
	move.l	\4,-(sp)
	move.w	#$7f,-(sp)
	trap	#14
	lea		18(sp),sp
	endm

Dsp_OutStream	macro	; block_done,num_block,block_size,data_out
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.l	\3,-(sp)
	move.l	\4,-(sp)
	move.w	#$64,-(sp)
	trap	#14
	lea		18(sp),sp
	endm

Dsp_RemoveInterrupts	macro	; mask
	move.w	\1,-(sp)
	move.w	#$66,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

Dsp_RequestAbility	macro
	move.w	#$71,-(sp)
	trap	#14
	addq.l	#2,sp
	endm

Dsp_Reserve	macro	; xreserve,yreserve
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.w	#$6b,-(sp)
	trap	#14
	lea		10(sp),sp
	endm

Dsp_RunSubroutine	macro	; handle
	move.w	\1,-(sp)
	move.w	#$76,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

Dsp_SetVectors	macro
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.w	#$7e,-(sp)
	trap	#14
	lea		10(sp),sp
	endm

Dsp_TruggerHC	macro	; vector
	move.w	\1,-(sp)
	move.w	#$70,-(sp)
	trap	#14
	addq.l	#4,sp#
	endm

Dsp_Unlock	macro
	move.w	#$69,-(sp)
	trap	#14
	addq.l	#2,sp
	endm

Dsptristate	macro	; dsprec,dspxmit
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.w	#$89,-(sp)
	trap	#14
	addq.l	#6,sp
	endm

EgetPalette	macro	; palette,count,start
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	move.w	\3,-(sp)
	move.w	#$55,-(sp)
	trap	#14
	lea		10(sp),sp
	endm

EgetShift	macro
	move.w	#$51,-(sp)
	trap	#14
	addq.l	#2,sp
	endm

EsetBank	macro	; bank
	move.w	\1,-(sp)
	move.w	#$52,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

Esetcolor	macro	; color,idx
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.w	#$53,-(sp)
	trap	#14
	addq.l	#6,sp
	endm

EsetGray	macro	; mode
	move.w	\1,-(sp)
	move.w	#$56,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

EsetPalette	macro	; palette,count,start
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	move.w	\3,-(sp)
	move.w	#$54,-(sp)
	trap	#14
	lea	10(sp),sp
	endm

EsetShift	macro	; mode
	move.w	\1,-(sp)
	move.w	#$50,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

EsetSmear	macro	; mode
	move.w	\1,-(sp)
	move.w	#$57,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

Flopfmt	macro	; virgin,magic,intlv,side,track,spt,dev,skew,buf
	move.w	\1,-(sp)
	move.l	\2,-(sp)
	move.w	\3,-(sp)
	move.w	\4,-(sp)
	move.w	\5,-(sp)
	move.w	\6,-(sp)
	move.w	\7,-(sp)
	move.w	\8,-(sp)
	move.w	\9,-(sp)
	move.w	#$0a,-(sp)
	trap	#14
	lea		26(sp),sp
	endm

Floprate	macro	; rate,dev
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.w	#$29,-(sp)
	trap	#14
	addq.l	#6,sp
	endm

Floprd	macro	; count,side,track,sector,dev,rsrvd,buf
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.w	\3,-(sp)
	move.w	\4,-(sp)
	move.w	\5,-(sp)
	move.l	\6,-(sp)
	move.l	\7,-(sp)
	move.w	#$08,-(sp)
	trap	#14
	lea		20(sp),sp
	endm

Flopver	macro	; count,side,track,sector,dev,rsrvd,buf
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.w	\3,-(sp)
	move.w	\4,-(sp)
	move.w	\5,-(sp)
	move.l	\6,-(sp)
	move.l	\7,-(sp)
	move.w	#$13,-(sp)
	trap	#14
	lea		20(sp),sp
	endm

Flopwr	macro	; count,side,track,sector,dev,rsrvd,buf
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.w	\3,-(sp)
	move.w	\4,-(sp)
	move.w	\5,-(sp)
	move.l	\6,-(sp)
	move.l	\7,-(sp)
	move.w	#$09,-(sp)
	trap	#14
	lea		20(sp),sp
	endm

Getrez	macro
	move.w	#$04,-(sp)
	trap	#14
	addq.l	#2,sp
	endm

Gettime	macro
	move.w	#$17,-(sp)
	trap	#14
	addq.l	#2,sp
	endm

Giaccess	macro	; register,data
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.w	#$1c,-(sp)
	trap	#14
	addq.l	#6,sp
	endm

Gpio	macro	; data,mode
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.w	#$8a,-(sp)
	trap	#14
	addq.l	#6,sp
	endm

Ikbdws	macro	; buf,len
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	move.w	#$19,-(sp)
	trap	#14
	addq.l	#8,sp
	endm

Initmous	macro	; hand,param,mode
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.w	\3,-(sp)
	move.w	#0,-(sp)
	trap	#14
	lea		12(sp),sp
	endm

Iorec	macro	; dev
	move.w	\1,-(sp)
	move.w	#$0e,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

Jdisint	macro	; intno
	move.w	\1,-(sp)
	move.w	#$1a,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

Jenabint	macro	; intno
	move.w	\1,-(sp)
	move.w	#$1b,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

Kbdvbase	macro
	move.w	#$22,-(sp)
	trap	#14
	addq.l	#2,sp

Kbrate	macro	; rate,delay
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.w	#$23,-(sp)
	trap	#14
	addq.l	#6,sp
	endm

Keytbl	macro	; caps,shift,normal
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.l	\3,-(sp)
	move.w	#$10,-(sp)
	trap	#14
	lea		14(sp),sp
	endm

Locksnd	macro
	move.w	#$80,-(sp)
	trap	#14
	addq.l	#2,sp
	endm

Logbase	macro
	move.w	#$03,-(sp)
	trap	#14
	addq.l	#2,sp
	endm

Metainit	macro	; metainfo
	move.l	\1,-(sp)
	move.w	#$30,-(sp)
	trap	#14
	addq.l	#6,sp
	endm

Mfpint	macro	; vector,intno
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	move.w	#$0d,-(sp)
	trap	#14
	addq.l	#8,sp
	endm

Midiws	macro	; bud,count
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	move.w	#$0c,-(sp)
	trap	#14
	addq.l	#8,sp
	endm

NVMaccess	macro	; buffer,count,start,op
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	move.w	\3,-(sp)
	move.w	\4,-(sp)
	move.w	#$2e,-(sp)
	trap	#14
	lea		12(sp),sp
	endm

Offgibit	macro	; mask
	move.w	\1,-(sp)
	move.w	#$1d,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

Ongibit	macro	; mask
	move.w	\1,-(sp)
	move.w	#$1e,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

Physbase	macro
	move.w	#$02,-(sp)
	trap	#14
	addq.l	#2,sp
	endm

Protobt	macro	; execflag,type,serial,buf
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.l	\3,-(sp)
	move.l	\4,-(sp)
	move.w	#$12,-(sp)
	trap	#14
	lea		14(sp),sp
	endm

Prtblk	macro	; prtblk
	move.l	\1,-(sp)
	move.w	#$24,-(sp)
	trap	#14
	addq.l	#6,sp
	endm

Puntaes	macro	; ;putain, celle-la elle est puissante !!!
	move.w	#$27,-(sp)
	trap	#14
	addq.l	#2,sp
	endm

Random	macro
	move.w	#$11,-(sp)
	trap	#14
	addq.l	#2,sp
	endm

Rsconf	macro	; scr,tsr,rsr,ucr,flow,speed
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.w	\3,-(sp)
	move.w	\4,-(sp)
	move.w	\5,-(sp)
	move.w	\6,-(sp)
	move.w	#$0f,-(sp)
	trap	#14
	lea		14(sp),sp
	endm

Scrdmp	macro
	move.w	#$14,-(sp)
	trap	#14
	addq.l	#2,sp
	endm

Setbuffer	macro	; endaddr,begaddr,mode
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.w	\3,-(sp)
	move.w	#$83,-(sp)
	trap	#14
	lea		12(sp),sp
	endm

Setcolor	macro	; new,idx
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.w	#$06,-(sp)
	trap	#14
	addq.l	#6,sp
	endm

Setinterrupt	macro	; cause,mode
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.w	#$87,-(sp)
	trap	#14
	addq.l	#6,sp
	endm

Setmode	macro	; mode
	move.w	\1,-(sp)
	move.w	#$84,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

Setmontracks	macro	; track
	move.w	\1,-(sp)
	move.w	#$86,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

Setpalette	macro
	move.l	\1,-(sp)
	move.w	#$06,-(sp)
	trap	#14
	addq.l	#6,sp
	endm

Setprt	macro	; new
	move.w	\1,-(sp)
	move.w	#$33,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

Setscreen	macro	; mode,phys,log
	move.w	\1,-(sp)
	move.l	\2,-(sp)
	move.l	\3,-(sp)
	move.w	#$5,-(sp)
	trap	#14
	lea		12(sp),sp
	endm

Settime	macro	; time
	move.l	\1,-(sp)
	move.w	#$16,-(sp)
	trap	#14
	addq.l	#6,sp
	endm

Settracks	macro	; rectracks,playtracks
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.w	#$85,-(sp)
	trap	#14
	addq.l	#6,sp
	endm

Sndstatus	macro	; reset
	move.w	\1,-(sp)
	move.w	#$8c,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

Soundcmd	macro	; data,mode
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.w	#$82,-(sp)
	trap	#14
	addq.l	#6,sp
	endm

Ssbkr	macro	; len
	move.w	\1,-(sp)
	move.w	#$01,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

Supexec	macro	; fonction
	move.l	\1,-(sp)
	move.w	#$26,-(sp)
	trap	#14
	addq.l	#6,sp
	endm

Unlocksnd	macro
	move.w	#$81,-(sp)
	trap	#14
	addq.l	#2,sp
	endm

VgetMonitor	macro
	move.w	#$59,-(sp)
	trap	#14
	addq.l	#2,sp
	endm

VgetRGB	macro	; rgb,count,index
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	move.w	\3,-(sp)
	move.w	#$5e,-(sp)
	trap	#14
	lea		10(sp),sp
	endm

VgetSize	macro	; mode
	move.w	\1,-(sp)
	move.w	#$5b,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

VsetMask	macro	; overlay,andmask,ormask
	move.w	\1,-(sp)
	move.l	\2,-(sp)
	move.l	\3,-(sp)
	move.w	#$92,-(sp)
	trap	#14
	addq.l	#12,sp
	endm

VsetMode	macro	; mode
	move.w	\1,-(sp)
	move.w	#$58,-(sp)
	trap	#1
	addq.l	#4,sp
	endm

VsetRGB	macro	; rgb,count,index
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	move.w	\3,-(sp)
	move.w	#$5d,-(sp)
	trap	#14
	lea		10(sp),sp
	endm

Vsetscreen	macro	; modecode,mode,phys,log
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.l	\3,-(sp)
	move.l	\4,-(sp)
	move.w	#$05,-(sp)
	trap	#14
	lea		14(sp),sp
	endm

VsetSync	macro	; external
	move.w	\1,-(sp)
	move.w	#$5a,-(sp)
	trap	#14
	addq.l	#2,sp
	endm

Vsync	macro
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	endm

Waveplay	macro	; slen,sptr,rate,flgas
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.l	\3,-(sp)
	move.w	\4,-(sp)
	move.w	#$a5,-(sp)
	trap	#14
	lea		16(sp),sp
	endm

Xbtimer	macro	; hand,data,control,timer
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	move.w	\3,-(sp)
	move.w	\4,-(sp)
	move.w	#$1f,-(sp)
	trap	#14
	lea		12(sp),sp
	endm

