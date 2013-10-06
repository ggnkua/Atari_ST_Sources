*
* CACHE.S
*
*	Cache equates. You'll need devpac 3 for this one, I think.
*
* ex.	move.l	#ENABLE_CACHE+ENABLE_DATA_CACHE+WRITE_ALLOCATE,d0
*	movec	d0,CACR		; turns on the caches
*


ENABLE_CACHE		EQU 1   ; Enable instruction cache
FREEZE_CACHE		EQU 2   ; Freeze instruction cache
CLEAR_INST_CACHE_ENTRY	EQU 4   ; Clear instruction cache entry
CLEAR_INST_CACHE	EQU 8   ; Clear instruction cache
INST_BURST_ENABLE	EQU 16  ; Instruction burst enable
ENABLE_DATA_CACHE	EQU 256 ; Enable data cache
FREEZE_DATA_CACHE	EQU 512 ; Freeze data cache
CLEAR_DATA_CACHE_ENTRY	EQU 1024 ; Clear data cache entry
CLEAR_DATA_CACHE	EQU 2048 ; Clear data cache
DATA_BURST_ENABLE	EQU 4096 ; Instruction burst enable
WRITE_ALLOCATE		EQU 8192 ; Write allocate 
