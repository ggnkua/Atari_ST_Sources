xdef GPUSTART
xdef GPUEND

xdef SETUPGPU
xdef DECOMPRESSGPUPP1
xdef WAITFORGPU

	move.l	#$00070007,G_END		;need this somewhere

	move.l	#GPUSTART,a0
	move.l	#GPUEND,d0
	bsr	SETUPGPU


.usegpu:
	bsr	DECOMPRESSGPUPP1
	bsr	WAITFORGPU



