
pushall macro
	movem.l a0-a6/d0-d7,-(sp)
	endm

popall macro
	movem.l (sp)+,a0-a6/d0-d7
	endm

pusha0 macro
	move.l a0,-(sp)
	endm
pusha1 macro
	move.l a1,-(sp)
	endm
pusha2 macro
	move.l a2,-(sp)
	endm
pusha3 macro
	move.l a3,-(sp)
	endm
pusha4 macro
	move.l a4,-(sp)
	endm
pusha5 macro
	move.l a5,-(sp)
	endm
pusha6 macro
	move.l a6,-(sp)
	endm
popa0 macro
	move.l (sp)+,a0
	endm
popa1 macro
	move.l (sp)+,a1
	endm
popa2 macro
	move.l (sp)+,a2
	endm
popa3 macro
	move.l (sp)+,a3
	endm
popa4 macro
	move.l (sp)+,a4
	endm
popa5 macro
	move.l (sp)+,a5
	endm
popa6 macro
	move.l (sp)+,a6
	endm

pushd0 macro
	move.l d0,-(sp)
	endm
pushd1 macro
	move.l d1,-(sp)
	endm
pushd2 macro
	move.l d2,-(sp)
	endm
pushd3 macro
	move.l d3,-(sp)
	endm
pushd4 macro
	move.l d4,-(sp)
	endm
pushd5 macro
	move.l d5,-(sp)
	endm
pushd6 macro
	move.l d6,-(sp)
	endm
pushd7 macro
	move.l d7,-(sp)
	endm
popd0 macro
	move.l (sp)+,d0
	endm
popd1 macro
	move.l (sp)+,d1
	endm
popd2 macro
	move.l (sp)+,d2
	endm
popd3 macro
	move.l (sp)+,d3
	endm
popd4 macro
	move.l (sp)+,d4
	endm
popd5 macro
	move.l (sp)+,d5
	endm
popd6 macro
	move.l (sp)+,d6
	endm
popd7 macro
	move.l (sp)+,d7
	endm
