
                 Notes concerning updates to PICPAC package.
                 -------------------------------------------
                            by: M†rten Lindstr”m


 For anyone who has  previously  used  my  PICPAC  routines  this text lists
 changes made. Others read the file PICPAC.DOC.

 The reasons for the changes are partly  to make the routines more adaptable
 for use with high level languages (such  as GFA Basic), partly to make them
 simpler to use in assembler too (and slightly more compact).

 In addition I have now made the PACKING routines check if sufficient memory
 is available and exit if not.

 I also fixed a few bugs that I found,  mainly in the call SETTRU which I am
 afraid wasn't very usable in its original state.


 Removed luxury flexibility
 --------------------------
 I have removed the option to  choose  (between VDI and 24-bit) the internal
 format for palettes. All palettes will now  be internally stored in the 24-
 bit format. (Which I find to be the ideal format, used both in IFF ILBM and
 in GIF and just spacious  enough  to  contain any colour distinguishable to
 the human eye). If you need the  VDI colour format or ST(E) hardware format
 you can easily  convert  between  palette  formats  with  TRU_VDI, VDI_TRU,
 TRU_STE and STE_TRU. I furthermore send  routines to use the 24-bit palette
 directly either with or without GEM.


 The format of the extended MFDB
 -------------------------------
 1) The previous flag for palette format  is  now  unused of course (=0). (I
    have some ideas for the - very distant  - future of possibly using it to
    flag for a different IMAGE format (pixel packed)).

 2) Most importantly, the palette is no longer following directly at the end
    of the XMFDB. Instead there is now  a POINTER to the palette. The direct
    reason for me to change this was, I  have to admit, to make it easier to
    call the  routines  from  high  level  languages  (GFA  Basic).  But  in
    retrospect I think it a  generally  good  idea  to use pointers for both
    palette and image data, making it possible  to use the same palette data
    for two images for instance,  and  also simplifying any future expansion
    to the XMFDB.


 The xxxPAC calls
 ----------------
 D1 must be set = length of the memory  block where the packed file is to be
 created. As mentioned above these  calls  will  now  check  and exit if the
 memory area is insufficient.


 The xxxCALC, xxxUNP and PICFILL calls
 -------------------------------------
 1) The high word of D3 is no  longer  a flag for palette format. Instead it
    now flags for an intended  use  of  VRT_CPYFM, rather than VRO_CPYFM, in
    case a mono image is encountered (0 = don't use, negative=use)

 2) The low word of D3 should in a  GEM  program ALWAYS be set to the number
    of colour bitplanes  on  screen  (which  can  be  read  after  a call of
    VQ_EXTND #1 as a  word  at  intout+8).  This  number  will be written by
    xxxCALC and xxxUNP into the MFDB proper  -  at 12(A4) - as the number of
    actually used planes (except  if  VRT_CPYFM  is  used  and  the image is
    mono).

    In a non-GEM program step 1  and  2  can,  as before, be replaced with a
    simple   moveq #-1,D3   (or moveq  #0,D3)    instruction, which will set
    the # of used planes - 12(A4) - equal to the number of planes in image.

 3) A4 should no longer point  directly  to  the  space you allocate for the
    unpacked image. Instead it should now  point  to a 36-byte space for the
    extended MFDB, the first longword of  which must be initialised to point
    to the image data.

    In addition A4 MUST point to this  space even before the xxxCALC routine
    is called, though its image pointer doesn't have to be initialised until
    the xxxUNP routine is called. (The  XMFDB  will be filled in by xxxCALC,
    so its data, except possibly its  pointers, can be referenced before the
    image has be unpacked).

 4) D4 must now be zero before you  call  xxxCALC or xxxUNP, unless you want
    the palette written to a pre-allocated  storage  space (768 bytes - on a
    word boundary - for a 256 colour  image),  in which case D4 should point
    to this. (D4=0 means that the  palette  will  be written after the image
    data, and that xxxCALC will account for its length.)

 5) xxxCALC now only returns a single  value  = the required length with any
    use of VRT_CPYFM accounted for.

 6) The D1 return value of xxxUNP  is  now  simply  = 0 for no "minor" error
    (during unpacking of the image data itself) or -1 for "minor" error.
    The value formerly returned in the low word of D1 was obsolete since ...

 7) xxxUNP now makes implicit calls of PICFILL, which is renamed PLNFILL.
    You thus never have to call PLNFILL  except if you want an image palette
    (shorter than the hardware palette)  to  go  to  a hardware start colour
    other than 0 - the default.

    Before call of PLNFILL just set D1  = the desired start colour, and make
    sure that A4 still points to  the  XMFDB.  The previously used D3 is now
    ignored.

