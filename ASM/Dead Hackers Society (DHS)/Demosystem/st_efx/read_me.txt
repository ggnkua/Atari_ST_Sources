
 ATARI ST DEMOSCREEN COMPETITION
 
 You'll find rules, tips and other information about the
 competition in this file.



 RULES FOR THE COMPETITION:
 --------------------------------------------------------------

 * The effect can use maximum 524288 bytes (512 kilobytes)
   memory + the base code.

 * Modifications to the base source code is not allowed.

 * Hardware-register access is not allowed.

 * System calls and line-a calls are not allowed.

 * The code must be 68000 compatible.

 * BLiTTER useage not allowed.

 * Self-modifying-code (smc) not allowed (due to falcon/tt
   incompatibility).

 * The effect can be multi-part if wanted, but must not exceed
   two minutes in length.

 * The effect must be delivered as source code so it can be
   assembled with the standard base code for size-checking and
   implementation to the big multi-part demo. The source will
   not be spread to public, only binarys will.

 Please refrain from abusing loopholes in the rules, so that
 all contributions can be properly combined into a big
 multi-part demo.
 
 

 BASE SOURCECODE:
 --------------------------------------------------------------

 The base sourcecode exist in two different versions.
 
 - Devpac / Assemble version:

   The Devpac / Assemble files are called devp_sys.s and 
   devp_use.s. devp_sys.s is not allowed to alter in 
   any way, while devp_use.s is where your routines are
   inserted and you also assemble with this file.

 - Turbo Assembler version:
 
   The Turbo Assembler file is called turboasm.src.
   The sourcecode is not allowed change in anyway, except
   for the code found in ""your_*" sections.



 PREMADE ROUTINES, HINTS AND SUGGESTIONS:
 --------------------------------------------------------------

 1. To set a palette, use the premade routine from VBL:
	lea	mypal,a0
	jsr	setpal

 2. Don't do any syncing with the VBL. Rather use the 200Hz
    timer instead. The VBL is not always 50Hz (Falcon/TT VGA
    have 60Hz VBL).

 3. Try to keep the INIT routine rather short in time, ~20sec
    maximum. The INIT is called once before the main, timer and
    vbl routines starts to run.

 4. The DATA and ADDRESS registers are not guarenteed to
    remain intact between each time your main, vbl and timer
    routines are called.

 5. Before your init starts, all colours are made black.

 6. The demoshell have a few things that can be good to know:

    - You can disable the music playing for faster assembling.
      Look for the playmusic variable in the usethis.s file.

    - You can pause the screen at any time by holding l-shift.

    - You can see the raster-time your mainloop consumes by 
      holding control.

 7. In the "example" folder, there is a very simple test-
    demo which you can observe something in unclear.

 8. If you want to use your own SNDH-file as music while
    testing, you can use almost any SNDH-file from the 
    collection at http://sndplayer.atari.org/. Just make
    sure it is unpacked.    



 DEADLINE, SENDING IN THE CONTRIBUTION AND QUESTIONS:
 --------------------------------------------------------------

 1. Deadline is Sunday, September 16, 2001.

 2. Sourcecode of your screen should be sent as attachment in
    E-Mail to: ae@dhs.nu  

    Please notice:
    Your source will not be spread to public, only used to make
    the final multipart demo. Only binarys will be spread to
    public, unless you wish to spread the source yourself.

 3. Questions should be asked to the above E-Mail address, or
    to "evl" at the IRC-Channel #atariscne.


 Only one thing left - GOOD LUCK!

