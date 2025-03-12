; Standard object EXEC stack frame

		rsreset
OBE_RTS		rs.l	1
OBE_FUNCTION	rs.b	FunctionCode
OBE_BuildBlk	rs.l	1
OBE_DataPtr	rs.l	1
OBE_Object	rs.w	1
OBE_Method	rs.w	1
OBE_Parameters	rs.b	0

StartPOB	macro	POBName
		opt	p+
		output	e:\\develop\\pace\\object\\system\\\1
START
		endm

ExecObject	macro	object,method
		move.w	\2,-(sp)
		move.w	\1,-(sp)
		move.l	OBE_DataPtr(a6),-(sp)
		move.l	OBE_BuildBlk(a6),-(sp)
		move.w	#OBJ_Exec,-(sp)
		trap	#0
		lea	14(sp),sp
		endm

String8	macro
.\@start
	dc.b	\1
.\@end
	dcb.b	8-(.\@end-.\@start),32
	endm

RegObject	macro	Name,Class,Group,ObjectDef,Strict
.registered	set	0
		String8	\1
		String8	\2
		String8	\3
		dc.l	\4-START,\4_SIZE
		dc.w	\5
		endm

FinishObjects	macro
.registered	set	1
		dc.l	-1
		endm

ObjectHeader	macro	ObjectLabel
		ifeq	.registered
		FinishObjects
		endc
\1
.ThisObject
		rsreset
.data_start	rs.b	0

.header_on		set	1
.init_done		set	0
.methodlist_done	set	0
.inheritlist_done	set	0

		endm

HeaderEnd	macro
.header_on	set	0
.data_end	rs.b	0
.data_size	set	.data_end-.data_start
		dc.l	.data_size
		dc.l	.Init-.ThisObject,.MethodList-.ThisObject,.InheritList-.ThisObject
		endm

InitRoutine	macro
.init_done	set	1
		ifne	.header_on
		HeaderEnd
		endc
.Init
		endm

MethodList	macro
.methodlist_done	set	1
		ifeq	.init_done
		InitRoutine
		rts
.init_done	set	1
		endc
.MethodList
		endm

InheritList	macro
.inheritlist_done	set	1
		ifeq	.methodlist_done
		MethodList
		endc
		dc.l	-1		end the method list
.InheritList
.first_method	set	0
.imethod_on	set	0
		endm

MethodCode	macro	MethodLabel

		ifeq	.inheritlist_done
		InheritList
		dc.l	-1
		endc
		ifne	.imethod_on
		dc.l	-1
		endc
		ifeq	.first_method
		dc.l	-1
.first_method	set	1
		endc
.\1
		rsreset
		rs.b	OBE_Parameters
		endm

Method		macro	MethodName,MethodCode
		ifeq	.methodlist_done
		MethodList
		endc
		String8	\1
		dc.l	.\2-.ThisObject
		endm

Inherit		macro	Name,Class,Group,Similar,Strict,IMethodListLabel
		ifeq	.inheritlist_done
		InheritList
		endc
		String8	\1
		String8	\2
		String8	\3
		dc.w	\4
		dc.w	\5
		dc.l	.\6-.ThisObject
.imethod_on	set	1
		endm

IMethodList	macro	Label
		ifne	.imethod_on
		dc.l	-1
		endc
.\1
.imethod_on	set	1
		endm

IMethod		macro	Method,Essential
		String8	\1
		dc.w	\2
		endm

ObjectEnd	macro	ObjectLabel
END_\1
\1_SIZE		=	END_\1-\1
		endm
