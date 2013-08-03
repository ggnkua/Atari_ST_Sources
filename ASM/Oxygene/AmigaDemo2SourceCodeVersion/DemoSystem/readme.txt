
- ATARI Leonard Demo System v1.5

Key features:

  - The toolchain work on windows plateforme (you can assemble, build the final disk and run it on emulator using PC only)
  - The kernel works on STf, STE, MegaSTE, TT, Falcon and Falcon CT60
  - The demo disk generated support HDD loading (just copy a small HdLoad.prg file near the MSA file)

  
Credits:
  - 68k Source code is assembled on PC using as68, macro assembler written by Vincent Penne (Ziggy Stardust)
  - Kernel use ARJBeta packer/depacker (mode 4 & 7), 68k version by by Mr.Ni! of the Tos-Crew
  - Everything else is done by Arnaud Carré (Leonard/OXYGENE) http://leonard.oxg.free.fr


Details:

  - Create a bootable MSA atari floppy disk image
  - Use "script.txt" to store all file names
  - The first screen is loaded and run at $5000 adress
  - $210.B contains the machine:
      0 : STFm
	  1 : STE
	  2 : Mega STE (set to 16Mhz by default)
	  3 : TT
	  4 : Falcon
	  5 : Falcon CT60
	  
  - On all machines, the video mode is set to an ATARI-ST resolution: 320*200, 16 colors
  - It works with VGA or RGB mode on Falcon (so don't assume 50hz refresh rate on these machines)
  - You can't use memory bellow $5000 adress
  - The user space is from $5000 to $80000 for 512Kb machine
  - The user space is from $5000 to $100000 for 1Mb machine
  - The MSA generated file run on HDD if you use HdLoad.prg. In that case, you *must* use user space from $5000 to $100000
    (memory above $100000 is used to cache the MSA file in memory)
  - Disk file system use a two (!) bytes cluster size and the bootsector is only 204 bytes long. Exept these 204 bytes,
    everything (kernel, FAT and files is packed)

  - When you want to load file number #2 at $5000 adress or above, just do

	lea		$5000.w,a0		; user space to load the file
	moveq	#2,d0
	jsr		$1000.w			; $1000 is Kernel adress
	jmp		$5000.w			; jump in the file
	
  - If you don't setup your own stack, just know you have only 1Kb of stack (located at $5000)
  - When loading a screen, the CPU (main thread) is depacking at the same time the data is loading (so the depacking is almost free)
    So if you want to do an animation during the loading process, you should put your animation routine in interrupt (VBL or anything you want)
  - You can use a QVbl-like routine using the vector $4d2. Ex:
  
    move.l #myQVbl,$4d2.w
    ...
	myQVbl:
			; do some stuff
			rts				; QVbl should return using RTS (not RTE)
			
  - You don't need to save registers in a QVbl vector (kernel already save d0-a6)
  - $466.L is a 32bits counter, increased at each VBL



