Diffusion Limited Agregation effect
476 bytes bootsector for Outline 2009

Code by baah/(Arm's Tech + Positivity)
Sound by Cyclone/X-Troll

A key feature of the proggy is that
the binary is in fact 814 bytes long,
but it's packed down to 426 bytes by
a homebrew lz77 packer with a 50 bytes
depacker. It also contains a tiny
random number generator. The code can
probably be polished a lot.

To build it:
 1.assemble DLA.S into DLA.PRG
   (devpac 2.25F used)
 2.run PACK.BAT on m$do$ or else...
   (it extracts 814 bytes code into
   dla.bin & packs it into dla.pk)
 3.assemble PUT_BOOT.S as PUT_BOOT.TOS
 4.insert a blank floppy
 5.run PUT_BOOT.TOS & press space :)

Hope you enjoy!
Alain Brobecker, 2009/05/03