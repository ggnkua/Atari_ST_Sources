
macro pushall
	movem.l a0-a6/d0-d7,-(sp)
	endm

macro popall
	movem.l (sp)+,a0-a6/d0-d7
	endm

macro pusha0
	move.l a0,-(sp)
	endm
macro pusha1
	move.l a1,-(sp)
	endm
macro pusha2
	move.l a2,-(sp)
	endm
macro pusha3
	move.l a3,-(sp)
	endm
macro pusha4
	move.l a4,-(sp)
	endm
macro pusha5
	move.l a5,-(sp)
	endm
macro pusha6
	move.l a6,-(sp)
	endm
macro popa0
	move.l (sp)+,a0
	endm
macro popa1
	move.l (sp)+,a1
	endm
macro popa2
	move.l (sp)+,a2
	endm
macro popa3
	move.l (sp)+,a3
	endm
macro popa4
	move.l (sp)+,a4
	endm
macro popa5
	move.l (sp)+,a5
	endm
macro popa6
	move.l (sp)+,a6
	endm

macro pushd0
	move.l d0,-(sp)
	endm
macro pushd1
	move.l d1,-(sp)
	endm
macro pushd2
	move.l d2,-(sp)
	endm
macro pushd3
	move.l d3,-(sp)
	endm
macro pushd4
	move.l d4,-(sp)
	endm
macro pushd5
	move.l d5,-(sp)
	endm
macro pushd6
	move.l d6,-(sp)
	endm
macro pushd7
	move.l d7,-(sp)
	endm
macro popd0
	move.l (sp)+,d0
	endm
macro popd1
	move.l (sp)+,d1
	endm
macro popd2
	move.l (sp)+,d2
	endm
macro popd3
	move.l (sp)+,d3
	endm
macro popd4
	move.l (sp)+,d4
	endm
macro popd5
	move.l (sp)+,d5
	endm
macro popd6
	move.l (sp)+,d6
	endm
macro popd7
	move.l (sp)+,d7
	endm
