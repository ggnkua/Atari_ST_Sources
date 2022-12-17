* Improved STOS File Handling
* 
* Written by Neil Halliday
* April 2021
*
* Close : dreg(0) = 0 : dreg(1) = <FileHandle> : call <Bank>
* Open : dreg(0) = 1 : areg(0) = varptr(<Filename$>) : call <Bank> : <FileHandle> = dreg(0)
* Read : dreg(0) = 2 : dreg(1) = <FileHandle> : dreg(2) = <NoBytes> : areg(0) = <MemoryLocation> : call <Bank> : dreg(0) = <NoBytesRead>
* Write : dreg(0) = 3 : dreg(1) = <FileHandle> : dreg(2) = <NoBytes> : areg(0) = <MemoryLocation> : call <Bank> : dreg(0) = <NoBytesWritten>

* dreg(0) = Function - 0 = close; 1 = open; 2 = read; 3 = write

files:
    cmp.w   #0,d0
    bne     .open

.close:
    move.w	d1,-(a7)        ; file handle
	move.w	#$3e,-(a7)		; fclose()
	trap	#1			
	addq.l	#4,a7			; reset stack
    jmp     .exit

.open:
    cmp.b   #1,d0
    bne     .read

    move.w	#2,-(a7)		; read/write
	move.l	a0,-(a7)		; pointer to filename
	move.w	#$3d,-(a7)		; fopen()
	trap	#1
	addq.l	#8,a7			; reset stack
    jmp     .exit

.read:
    cmp.b   #2,d0
    bne     .write

    move.l  a0,-(a7)        ; address of data buffer
	move.l	d2,-(a7)		; number of bytes to read
	move.w	d1,-(a7)	    ; file handle
	move.w	#$3f,-(a7)		; fread()
	trap	#1
	add.l	#12,a7			; reset stack
    jmp     .exit

.write:
    move.l  a0,-(a7)        ; address of data buffer
    move.l  d2,-(a7)        ; number of bytes to write
    move.w  d1,-(a7)        ; file handle
    move.w  #$40,-(a7)      ; fwrite
    trap    #1
    add.l   #12,a7          ; reset stack

.exit:
    rts