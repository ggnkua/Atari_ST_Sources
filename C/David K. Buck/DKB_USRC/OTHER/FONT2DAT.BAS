'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''  Conversion notes:                                          ''
''     DEFINT means any untyped variable defaults to INT       ''
''     GET #1,,IN$ means get from file #1 into IN$ for a length''
''        of however big IN$ already is.                       ''
''     COMMAND$ is the command line less the program name. Just''
''        rewrite the lousy BASIC interpretation of parameters.''
''     Type ! is a float, & is a long int, # is an 8-byte float''
''     STRING$(n,c) function returns a string containing 'n'   ''
''        occurances of the character 'c'.                     ''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
defint a-z
VERSION!=1.02
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''  Version notes:                                             ''
''  031491 kjk 1.01 Added count of shapes/character.           ''
''                  Added option to allow one char per file    ''
''  FUTURE:         Added some optimization of squares/boxes   ''
''  050191 aac 1.02 Updated to DKB 2.11 by Aaron A. Collins    ''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
print using "FONT2DAT (c) Koehler 1991 v##.## ";version!
def fnh$(x)=right$("0"+hex$(x),2)
pixel=0      ' 0=Sphere  1=Dot  2=Square  3=Box
map = 1      ' Generate Map file ON by default
cmd$=command$
fils=1
argarg=instr(cmd$,"-M"): if argarg then cmd$=left$(cmd$,argarg-1)+mid$(cmd$,argarg+3):fils=1
argarg=instr(cmd$,"-m"): if argarg then cmd$=left$(cmd$,argarg-1)+mid$(cmd$,argarg+3):fils=1
argarg=instr(cmd$,"-S"): if argarg then cmd$=left$(cmd$,argarg-1)+mid$(cmd$,argarg+3):fils=0
argarg=instr(cmd$,"-s"): if argarg then cmd$=left$(cmd$,argarg-1)+mid$(cmd$,argarg+3):fils=0
argarg=instr(cmd$,"-L"): if argarg then cmd$=left$(cmd$,argarg-1)+mid$(cmd$,argarg+3):map=0
argarg=instr(cmd$,"-l"): if argarg then cmd$=left$(cmd$,argarg-1)+mid$(cmd$,argarg+3):map=0
if left$(cmd$,1)="-" then pixel=val(mid$(cmd$,2,1)):cmd$=mid$(cmd$,4)
if cmd$="" then gosub Usage:end
if pixel>3 then pixel=0
if pixel=0 then print "Generating Spheres";
if pixel=1 then print "Generating Squares";
if pixel=2 then print "Generating Dots";
if pixel=3 then print "Generating Boxes";
if fils=1 then print " to a single file" else print " to multiple files"
fl$=cmd$
if instr(fl$,".") then ext$=mid$(fl$,instr(fl$,".")) : fl$=left$(fl$,instr(fl$,".")-1)
if ext$="" then ext$=".fnt"

  open fl$+ ext$  for BINARY as #1
  if fils=1 then open fl$+".dat" for output as #2
  if map=1 then open fl$+".map" for output as #3     ' map graphic char layout

  '* Read font header
  in$=chr$(0)
  get #1,,in$
  size&=asc(in$)
  get #1,,in$
  size&=asc(in$)*256+size&
  get #1,,in$
  numchars=asc(in$) : if numchars=0 then numchars=256
  get #1,,in$
  ascoff=asc(in$)
  get #1,,in$
  chxsize=asc(in$)
  get #1,,in$
  chysize=asc(in$)
  get #1,,in$
  chbytes=asc(in$)
  print "'";fl$;ext$;"'";
  print using " is ####, bytes long, ### characters, starting  @ ###";size&;numchars;ascoff
  print using "                     X-size=### , Y-size=### , ### bytes/char";chxsize;chysize;chbytes
  if fils=0 then goto Skip1
  print #2,"{'";fl$;ext$;"'";
  print #2,using " is ####, bytes long, ### characters, starting  @ ### }";size&;numchars;ascoff
  print #2,using "{                     X-size=### , Y-size=### , ### bytes/char }";chxsize;chysize;chbytes
  print #2,
  print #2,"INCLUDE "+chr$(34)+"shapes.dat"+chr$(34)
  print #2,"INCLUDE "+chr$(34)+"colors.dat"+chr$(34)
  print #2,"INCLUDE "+chr$(34)+"textures.dat"+chr$(34)
  print #2,
  print #2,"DECLARE Font_Color = COLOR Red"
  print #2,
  print #2,"DECLARE Font_Texture = TEXTURE"
  print #2,"  COLOR Font_Color"
  print #2,"  AMBIENT 0.3"
  print #2,"  DIFFUSE 0.7"
  print #2,"END_TEXTURE"
  print #2,

Skip1:

  '* Generate .DAT
  scale#=10/chysize
  empty$=string$(chbytes/chysize,0)
  in$=empty$
  for char=ascoff to ascoff+numchars-1
    if inkey$=chr$(27) then end ' ABORT
    if fils=1 then goto Skip2
    open fl$+".D"+fnh$(char) for output as #2
    print #2,"INCLUDE "+chr$(34)+"shapes.dat"+chr$(34)
    print #2,"INCLUDE "+chr$(34)+"colors.dat"+chr$(34)
    print #2,"INCLUDE "+chr$(34)+"textures.dat"+chr$(34)
    print #2,
    print #2,"DECLARE Font_Color = COLOR Red"
    print #2,
    print #2,"DECLARE Font_Texture = TEXTURE"
    print #2,"  COLOR Font_Color"
    print #2,"  AMBIENT 0.3"
    print #2,"  DIFFUSE 0.7"
    print #2,"END_TEXTURE"

Skip2:

    print #2,
    print #2,"DECLARE Char_";fnh$(char);" = ";
    if ((char and &h7F) >= 32) and ((char and &h7F) <= 127) then char$="{"+chr$(char)+"}" else char$=""
    if char$="{{}" then char$="{left-curly}"
    if char$="{}}" then char$="{right-curly}"
    if map=1 then print #3,char$
    print #2,char$
    if fils=0 then print #2,using "{                     X-size=### , Y-size=### , ### bytes/char }";chxsize;chysize;chbytes
    print #2,"   OBJECT"
    print #2,"       UNION"
    previous.x$=empty$
    for bity= chysize-1 to 0 step -1
      bitx=0
      get #1,,in$
      char.byte=0
      while bitx< chxsize
    char.byte=char.byte+1
    byte=asc(mid$(in$,char.byte,1))
    previous.byte=asc(mid$(previous.x$,char.byte,1))
    previous.bit=0
    for bit=7 to 0 step -1
      bitx=bitx+1
      if byte and (2^bit) then gosub WriteOn else gosub WriteOff
    next bit
    if pixel=3 then if previous.bit=1 then gosub WriteLeft
      wend
      previous.x$=in$
      if map=1 then print #3,
    next bity
    if map=1 then print #3,string$(chxsize,"-")
    print #2,      "       END_UNION"
    print #2,using "       SCALE <#.####### #.####### #.#######>";scale#;scale#;scale#
    print #2,      "       TEXTURE Font_Texture END_TEXTURE COLOR Font_Color"
    if pixel=0 then print #2,using "       { Spheres = #####, }";spheres
    if pixel=1 or pixel=3 then print #2,using "       { Triangles = #####, }";triangles
    if pixel=2 then print #2,using "       { Dots = #####, }";dots
    total.spheres=total.spheres+spheres     :spheres=0
    total.dots=total.dots+dots          :dots=0
    total.triangles=total.triangles+triangles   :triangles=0
    print #2,      "   END_OBJECT"
    if fils=0 then close #2
  next char
  if fils=1 then print #2,using " { Dataset Total Spheres =#####,   Triangles =#####,   Dots =#####, }";total.spheres;total.triangles;total.dots
  print    using "   Dataset Total Spheres =#####,   Triangles =#####,   Dots =#####,  ";total.spheres;total.triangles;total.dots
  if fils=1 then close #2
  close
  end

WriteOn:
  if pixel=3 then if previous.bit=0 then gosub WriteLeft
  if pixel=3 then if (previous.byte and (2^bit))=0 then gosub WriteTop
  previous.bit=1
  if map=1 then print #3,"#";
  if pixel=0 then print #2,using "          SPHERE <## ## 0> 0.5";bitx;bity;
  if pixel=0 then print #2,  " END_SPHERE"
  if pixel=0 then spheres=spheres+1
  if pixel=1 then print #2,using "          TRIANGLE <###.# ###.# 0> <###.# ###.# 0> <###.# ###.# 0>";bitx-.5;bity-.5;bitx+.5;bity+.5;bitx+.5;bity-.5;
  if pixel=1 then print #2,  " END_TRIANGLE"
  if pixel=1 then print #2,using "          TRIANGLE <###.# ###.# 0> <###.# ###.# 0> <###.# ###.# 0>";bitx-.5;bity-.5;bitx+.5;bity+.5;bitx-.5;bity+.5;
  if pixel=1 then print #2,  " END_TRIANGLE"
  if pixel=1 then triangles=triangles+2
  if pixel=2 then print #2,using "          QUADRIC Sphere TRANSLATE<## ## 0> SCALE<0.5 0.5 0.01>";bitx;bity;
  if pixel=2 then print #2,  " END_QUADRIC"
  if pixel=2 then dots=dots+1
  if pixel=3 then print #2,using "    {F}   TRIANGLE <###.# ###.# -0.5> <###.# ###.# -0.5> <###.# ###.# -0.5>"; bitx-.5;bity-.5; bitx+.5;bity+.5; bitx+.5;bity-.5;
  if pixel=3 then print #2,  " END_TRIANGLE"
  if pixel=3 then print #2,using "    {F}   TRIANGLE <###.# ###.# -0.5> <###.# ###.# -0.5> <###.# ###.# -0.5>"; bitx-.5;bity-.5; bitx+.5;bity+.5; bitx-.5;bity+.5;
  if pixel=3 then print #2,  " END_TRIANGLE"
  if pixel=3 then print #2,using "    {B}   TRIANGLE <###.# ###.#  0.5> <###.# ###.#  0.5> <###.# ###.#  0.5>"; bitx-.5;bity-.5; bitx+.5;bity+.5; bitx+.5;bity-.5;
  if pixel=3 then print #2,  " END_TRIANGLE"
  if pixel=3 then print #2,using "    {B}   TRIANGLE <###.# ###.#  0.5> <###.# ###.#  0.5> <###.# ###.#  0.5>"; bitx-.5;bity-.5; bitx+.5;bity+.5; bitx-.5;bity+.5;
  if pixel=3 then print #2,  " END_TRIANGLE"
  if pixel=3 then triangles=triangles+4
  if pixel=3 then if bity=0 then gosub WriteBottom
return

WriteOff:
  if pixel=3 then if previous.bit=1 then gosub WriteLeft
  if pixel=3 then if (previous.byte and (2^bit)) then gosub WriteTop
  previous.bit=0
  if map=1 then print #3," ";
return

WriteLeft:
  ' generate left side wall of box
  print #2,using "    {l}   TRIANGLE <###.# ###.# -0.5> <###.# ###.#  0.5> <###.# ###.# -0.5>"; bitx-.5;bity-.5; bitx-.5;bity+.5; bitx-.5;bity+.5;
  print #2,  " END_TRIANGLE"
  print #2,using "    {l}   TRIANGLE <###.# ###.# -0.5> <###.# ###.#  0.5> <###.# ###.#  0.5>"; bitx-.5;bity-.5; bitx-.5;bity+.5; bitx-.5;bity-.5;
  print #2,  " END_TRIANGLE"
  triangles=triangles+2
return

WriteTop:
  ' generate top of of box
  print #2,using "    {t}   TRIANGLE <###.# ###.#  0.5> <###.# ###.# -0.5> <###.# ###.# -0.5>"; bitx-.5;bity+.5; bitx+.5;bity+.5; bitx-.5;bity+.5;
  print #2,  " END_TRIANGLE"
  print #2,using "    {t}   TRIANGLE <###.# ###.#  0.5> <###.# ###.# -0.5> <###.# ###.#  0.5>"; bitx-.5;bity+.5; bitx+.5;bity+.5; bitx+.5;bity+.5;
  print #2,  " END_TRIANGLE"
  triangles=triangles+2
return

WriteBottom:
  ' generate bottom of of box
  print #2,using "    {b}   TRIANGLE <###.# ###.#  0.5> <###.# ###.# -0.5> <###.# ###.# -0.5>"; bitx-.5;bity-.5; bitx+.5;bity-.5; bitx-.5;bity-.5;
  print #2,  " END_TRIANGLE"
  print #2,using "    {b}   TRIANGLE <###.# ###.#  0.5> <###.# ###.# -0.5> <###.# ###.#  0.5>"; bitx-.5;bity-.5; bitx+.5;bity-.5; bitx+.5;bity-.5;
  print #2,  " END_TRIANGLE"
  triangles=triangles+2
return

Usage:
  print
  print "Usage:  FONT2DAT [-0123] [-MS] filename[.fnt]"
  print "          -0 = Generate pixels as Spheres <default>"
  print "          -1 = Generate pixels as Squares "
  print "          -2 = Generate pixels as Dots    "
  print "          -3 = Generate pixels as Boxes   "
  print "          -M = Multiple chars/file <default>"
  print "          -S = Single char/file           "
  print "          -L = No char Map List File output <on by default>"
  print
  print "Ex:     FONT2DAT -3 -S CYBER.SET"
  print "        Would create CYBER.Dnn files with box type pixels"
  print "          where 'nn' is the hex ASCII character code."
return
