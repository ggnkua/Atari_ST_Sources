                          Reed-Solomon Encoder
			  --------------------

This Reed-Solomon (RS) encoding is similar to the encoding scheme used
on a compact-disc system.  It encodes, interleaves, and encodes again 
(commonly referred to as CIRC).  An RS (28, 24) encode is performed on 24 
8-bit symbols, they are interleaved to a depth of 27, then an RS (32, 28) 
encode is performed.  The GF(2^8) field is used with the primitive polynomial

	p(x) = 1 + x^2 + x^3 + x^4 + x^8

to define the "power of alpha" table.  The RS generator for both codes is

	g(x) = 1 + g1x + g2x^2 + g1x^3 + x^4

where g1 and g2 are defined as their power of alpha in the code itself.

This code can be modified for many different RS generators.  The code requires
3108 words of X data memory 770 words of Y data memory, 122 words of program
memory and, to run the test case given, it takes 133035 cycles.

References for more information:

Digital Communications Fundamentals and Applications by Bernard Sklar
Error Control Coding:  Fundamentals and Applications by Shu Lin 
							Daniel J. Costello, Jr.



           Instructions for Utilizing Reed-Solomon Encoder
	   -----------------------------------------------

There are two major program files: the encoder coded in C and the 
DSP56000 assembly language version of the encoder for the DSP56000 simulator.
To test the code, the C version "newc.c" (coded on a Sun system) should be run. 
It will need to be linked and compiled on your system and any syntax 
changes necessary made, if you do not have a Sun 3, to make the C compatible to 
to your system. This code will generate two files, one called "in" and the 
other "out".  The "in" file needs to be copied to an "in.io" file as it will
be used as the input to the simulator.

The output of the assembled version is now ready to be compared to the output of
the C  version.  This is done by entering the simulator and loading the 
"rscd" file.  The following instructions are to be used on the simulator:

1) input x:$f000 in -rd
2) output x:$f001 out -rd
3) break r p:$ba
4) go #1 :55

The program will now be running on the simulator.  When it is finished
step it once and then set the output off.  After terminating the simulation
the output just created will be called "out.io".  It should compare exactly
with the "out" file.  If it does not, one of the programs is not working  
correctly.  This procedure has been tested at Motorola and works on the
Sun 3 system.



                        ALPHA
     +-------------+--------------+-----------------------------+
     |             |              |                             |
     |             |              |                             |
     |             V              V                             |
     |      G1--->(X)      G2--->(X)                            |
     |             | ALPHA1       | ALPHA2                      |
     |             +--------------)--------------+              |
     |             |              |              |              |
     |             V              V              V              |
     +--->[P1]--->(+)--->[P2]--->(+)--->[P3]--->(+)--->[P4]--->(+)
                                                                ^
    [P1]...[P4] are the parity symbols                          |
    which are appended to the data block.                INPUT--+



                       MEMORY MAP
             X                           Y
       +-----------+               +-----------+
    $0 |     ^     |            $0 |    P3     |
       |     |     |               +-----------+
       |     |     |            $1 |    P4     |
       | Interleaf |               +-----------+
       |   Buffer  |               |           |
       |     |     |               |           |
       |     |     |               |           |
       |     v     |               |           |
       +-----------+               +-----------+
  $800 |    P1     |          $100 |     ^     |
       +-----------+               |     |     |
  $801 |    P2     |               |  TABLE2   | Alpha --> power lookup
       +-----------+               |     |     |
  $802 |    G1     |               |     V     |
       +-----------+               +-----------+
  $803 |    G2     |          $200 |     ^     |
       +-----------+               |     |     |
  $804 |     ^     |               |     |     |
       |     |     |               |     |     |
       |   INPUT   |               |  TABLE1   | power --> Alpha lookup
       |  BUFFER   |               |     |     |
       |     |     |               |     |     |
  $81C |     V     |               |     |     |
       +-----------+               |     |     |
       |     ^     |               |     V     |
       |     |     |               +-----------+
       |   OUTPUT  |          $400 |           |
       |   BUFFER  |               |           |
       |     |     |               |           |
       |     v     |               |           |
       +-----------+               +-----------+
  $83C |           |
       |           |
       |           |
       |           |
       |           |
       |           |
       +-----------+
