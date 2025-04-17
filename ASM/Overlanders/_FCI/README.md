Authors: RATI & Janek  
Crew: Overlanders  
Date: 07/10/2023 

# Fullscreen Code Integrator (FCI)

The purpose of the Fullscreen Code Integrator is to automate the integration of your source code in predefined line models. It is convenient for generating fullscreen/overscan code if you define the adequate line models that comprise the freq/rez switches at the proper positions in the scanline. 

In a nutshell, our FCI:
- determines the consumption in NOPs and size in bytes of each instruction in the source code
- generates a fullscreen line by replacing NOPs with instruction of the same CPU consumption

The whole code is generated in memory. Once generated you can do whatever you want with it. For examples:
* save it in a file that you can INCBIN in an other source (eg. _FCI.PRG)
* use it right away in your demo (eg. _HNY2024.PRG)

## Limits

There's no miracle: the source code must always consume an amount of CPU cycles that is stable. More complex code that leverages conditional branches, call to sub routines for example, will have to get integrated manually or use Interrupt Fullscreen technique. The table below summarizes the limits:

Limits | Explanation
--- | ---
Unsupported instructions | illegal, trap, link, unlk, reset, stop, rte, rtr, rts, trapv, jsr, jmp, DBcc, bra, bsr, Bcc, mulu, muls, divu, divs
Supported rotation instructions | asD #, lsD #, roD #, roxD #
Unsupported rotation instructions | asD dn, lsD dn, roD dn, roxD dn
'Prefetch' is not supported | This tool leverages the Trace exception so 'prefetch' is canceled. In some cases, the integrator may not work properly due to not taking into account the prefetch. In that case, you'll have to analyze which instructions are causing the problem and eventually fix manually (saving one NOP).
No use of registers you use for opening the left/right borders | For example we make use of a0,a1 and d0 registers to switch screen resolution/frequency so we can't use them in our source code

## How it works

The following process is applied during the analysis of the source code:
- The Opcodes are all in 2 bytes with the exception of the 'movem' instruction which is analyzed separately
- The Opcode is copied (SMC) in Timer B IT to be executed there (only the Opcode is useful here - additional words chosen with care)
- Timer B is used to analyze 1 instruction per interruption. When Timer B IT is triggered:
    - The video counter is measured
    - then the Trace is enabled
- In the Trace exception: 
    - The video counter is measured once again --> This allows to measure the duration of the instruction in NOPs as 1 NOP=2 bytes passed in video counter
    - The size of the instruction is measured as the return address is located in the stack
- These informations (number of NOPs consumed and size of the instruction) are used to generate the fullscreen code

## Usage

Follow the following steps to integrate your source code:
- Open '_FCI.S'
- Include (INCLUDE or INCBIN) the source code to integrate in '_source' label in DATA section. Note that it is possible to add code (instructions) before or/and after the INCLUDE/INCBIN. As such, they'll be taken into account during the integration phase
- The code to be integrated must end with an 'RTS' or #'END ' mark
- Assemble and Run this code
- The result is in 'RESULT.BIN' file
- INCBIN the result in your source code that will display the fullscreen

## About line models

You can define whatever line model you want:
- line model --> ref _FS_LINE_DEFAULT in data section for instance
- lines_list: pointers to each lines --> default is a fullscreen starting in line 0

Example of a line model:
```m68k
; d0=0
; a0=$ffff820a.w
; a1=$ffff8260.w

 _FS_LINE_DEFAULT:
	; Stabilizer
	move.w	a0,(a1)						; High Rez
	nop
	move.b	d0,(a1)						; Low Rez
	dcb.w	12,$4E71
	; Left
	move.w	a0,(a1)						; High Rez
	nop
	move.b	d0,(a1)						; Low Rez
	dcb.w	89,$4E71
	; Right
	move.b	d0,(a0)						; 60Hz
	move.w	a0,(a0)						; 50Hz
	dcb.w	13,$4E71
	dc.w 	-1						    ; End Mark
```

The lines_list contains pointers to each line model that will be used one after the other when a new line has to be generated. The following shows all the lines for a fullscreen. It is possible to remove lines depending on what you want to achieve: 
```m68k
 _lines_list
	rept 	212
		dc.l 	_FS_LINE_DEFAULT
	endr
		dc.l 	_FS_LINE_BOTTOM_OLD_SHIFTER
	rept 	15
		dc.l 	_FS_LINE_DEFAULT
	endr
		dc.l 	_FS_LINE_BOTTOM_NEW_SHIFTER
	rept 	45
		dc.l 	_FS_LINE_DEFAULT
	endr
		dc.l 	_FS_LINE_LAST_LINE
	dc.l 	-1
```
# Example: _HNY2024.PRG

This program is just a demonstration of how this kind of library can be useful. During the init phase, it:
* Generates the code for each shift of the sprite resulting in a code that is not overscan ready --> there's no freq/rez switches
* Integrates the code into overscan ready line model --> resulting in code that can be used in overscan as it embeds freq/rez swicthes at the right position of the scanline

PS: do not ask for the source code. It goes beyond the scope of this library. It is there just to illustrate that it works perfectly fine.