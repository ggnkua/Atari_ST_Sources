

        Professional GEM                                                1


                                    PPAARRTT -- XX

                          VVDDII GGrraapphhiiccss:: TTeexxtt OOuuttppuutt    


             This  issue  of  ST  PRO GEM concludes the two column series
        on  VDI   with  a  look  at simple VDI  text output,  and ways to
        optimize  its   speed.    There is also a Feedback section.   You
        may  find  the associated  download  file under the name GMCL10.C
        in DL3  of  the ATARI16 SIG (PCS-58).  

             To  keep   the  size  of  this  first  discussion   of  text
        within  reason,  I  am  going  to  restrict  it  to  use  of  the
        mono-spaced   system   font     in    its    default   size   and
        orientation.      Discussion   of  alternate  and  proportionally
        spaced  fonts,   baseline  rotation,  and  character scaling will
        become a later article in this series.  


        DDEEFFIINNIITTIIOONNSS         

             This  article   makes use of  some  terminology which may be
        unfamiliar   if   you   have   not  used  digital  typefaces.   A
        mono-spaced   font   is   one in which  each  character  occupies
        an  identically   wide   space  on  the  screen.   A proportional
        font   has  characters   which  occupy  different  widths.    For
        instance,  an 'l' would probably be narrower than a 'w'.  

             Text may  be  "justified"  right,   left,   or center.  This
        means  that   the  right  character,   left character,  or center
        position   of  the   text   string  is  constrained  to  a  given
        location.    In   common  usage,   a   page   of  text is "ragged
        right"  if  its  lines  are  left justified only.   The text page
        is  "fully  justified",   "justified"  or   (ambiguously)  "right
        justified"   if   BOTH  the   left   and   right  characters  are
        contrained  to  fixed  columns.   Full  justification is produced
        by   inserting  extra  blank  characters  in  the   case   of   a
        mono-spaced  font,   or by adding extra pixel columns in the case
        of proportional output.  

             A  text  character  (in a monospaced font) is written inside
        a  standard sized cell or box.  Vertically, the cell extends from
        the  "top   line"  down  to the "bottom line".   If there are one
        or   more  blank   lines  at  the top or bottom,  they are called
        "leading"   and  are   used   to  separate  lines  of text.   The
        characters   themselves  always   fall between the "ascent line",
        which  is  the highest line reached by characters such as 'd' and
        'l',  and  the  "descent  line",  which   is  the  lowest line in
        characters  like  'q'  and   'g'.   Other locations  of  interest
        are  the "half line",  which is the top  of characters  like  'a'
        or   'n',   and  the  "base  line",   which  is   the  bottom  of
        characters which do not have descenders.  


        


        Professional GEM             Part X                             2



             Before  plunging  into  the  Attribute  Functions for  text,
        you  should   note   that   the   writing   mode  (vswrmode)  and
        clipping  rectangle   (vsclip)  attributes  discussed in the last
        column   (#9)  also   pertain   to   text.    Since  much  of the
        discussion    of    text  optimization   will   center  on  these
        attributes,  you may  want  to review them.  


        TTEEXXTT AATTTTRRIIBBUUTTEESS        

             The writing   color  for  graphics  text  is  set  with  the
        command: 

                                vstcolor(vdihandle, color);

        Vdihandle   is  always the handle returned from  grafhandle()  at
        application  startup.   Color  is  a  word value between 0 and 15
        which  designates   the   output  color index.   As discussed  in
        previous   columns,    the    actual   color   which  appears  is
        dependent     on     the   current    palette    settings.     In
        applications  such   as   word   and  outline  processors  it  is
        important  that  characters  and  their background  provide  good
        contrast  to  avoid  eyestrain.   In  these situations,  you  may
        want  to  use  the  setPalette  and/or  setColor XBIOS  functions
        to   force  the  palette  to a  known  state  before starting the
        application.  

             You  can  choose  a  variety  of  special output effects for
        your text with the call: 

                         vsteffects(vdihandle, effects);

        Effects  is  a  single  flag  word,   with  the  bits  having the
        following significance: 

            0 - Thicken 

            1 - Lighten 

            2 - Skew 

            3 - Underline 

            4 - Outline 

            5 - Shadow 

             In each  case,   turning  the  bit  on  selects  the effect.
        Otherwise,  the   effect   is   off.    Any   number of  multiple
        effects   may   be  selected,  but  the  result may not always be
        pleasing or legible.  


        


        Professional GEM             Part X                             3



             The  "thicken"   effect  widens  the  character  strokes  by
        one   pixel,    resulting   in   the   appearance   of   boldface
        type.    The  "lighten" effect superimposes a half-tone dither on
        the    character.    This   mode   is   useful   for   indicating
        non-selectable  text  items,  but is not legible enough for other
        purposes.  

             The  skew  effect  shifts  the  rows  of  the  character the
        right,  with   the  greatest  displacement  at  the  top.    This
        results  in  the appearance of italic text.   You should be aware
        that  the  VDI does not  compensate for this effect.   This means
        that  a  skewed italic character which is immediately followed by
        a  normal blank will  be overstruck,  and  part of the top of the
        character   will   disappear.   Likewise,   a   skewed  character
        written  to  the  left  of  an   existing  normal  character will
        overstrike  part  of  it.    There  is a related bug  in  the VDI
        clipping  logic  which  may  cause  some   parts   of   a  skewed
        character  not  to  be  redrawn  if  they  fall at the edge of  a
        clipping   rectangle,   even   though   they should  fall  within
        the region.  

             The  outline   effect   produces  output  which  is   a  one
        pixel  "halo"  around  the  normal  character.  The shadow effect
        attempts  to  create   a   "drop   shadow"  to  the side  of  the
        character.    These  effects   should be used very sparingly with
        default  sized  fonts.  They often result in illegible output.  

             When  graphics  text  is  written,  a screen coordinate must
        be  specified   for   the  output.   The relationship of the text
        to  the screen point is determined by the call: 

                     vstalignment(vdihandle, hin, vin, &hout, &vout);

        Hin   and   vin  are  each  words,   with  values  specifying the
        desired   horizontal    and  vertical  alignment,   respectively.
        Hout  and vout receive the actual values set by the VDI.  If they
        differ from the requested values, an error has occurred.  

             Hin may  be  set  to  zero  for  left justification, one for
        center  justification,   or   two  for right justification.   The
        coordinate  given when text is written becomes the "anchor point"
        as   described   in   the   definitions   above.    The   default
        justification is left.  

             Vin determines   what   reference   line   of  the  text  is
        positioned at the output coordinate.  The selection values are: 







        


        Professional GEM             Part X                             4


            0 - baseline (default) 

            1 - half line 

            2 - ascent line 

            3 - bottom line 

            4 - descent line 

            5 - top line 

             A  common  combination  of  alignments  is  left (0) and top
        line  (5).    This  mode guarantees that all text output will lie
        to    the   right   and   below  the  output  coordinate.    This
        corresponds with the AES object and GRECT coordinate systems.  

             Finally, the call to do the actual output is: 

                        vgtext(vdihandle, x, y, string);

        X   and  y  define  the  screen  coordinate  to  be  used  as the
        alignment  point.    String   is   a pointer to a null terminated
        string,    which  must   be  total  eighty  characters  or  less,
        exclusive  of  the   null.   This limit is imposed by the size of
        the  intin[]  array  in  the  VDI binding.   Be  warned  that  it
        is  NOT  checked   in   the   standard binding!  Exceeding it may
        cause memory to be overwritten.  

             One Inquire Function is useful with text output.  The call 

                        vqtattributes(vdihandle, attrib);

        reads   back  the  current  attribute  settings  into the 10 word
        array  attrib[].    The  main  items  of interest  are  attrib[6]
        through  attrib[9],   which  contain  the  width  and  height  of
        characters,   and  the  width and height of the character cell in
        the   current   font.   You   should   rely   on this function to
        obtain   size   information, rather  than using the output of the
        grafhandle()   function.   On the ST, grafhandle() always returns
        sizes  for  the  monochrome  mode  system  font,  which  will  be
        incorrect in the color screen modes.  

             Attrib[1] will  contain  the  current graphics text color as
        set   by    vstcolor().     Attrib[3]    and   [4]   contain  the
        horizontal    and   vertical  alignment  settings,  respectively.
        Attrib[5]   contains   the   current  writing  mode,  as  set  by
        vswrmode().  






        


        Professional GEM             Part X                             5




        OOPPTTIIMMIIZZAATTIIOONN         

             The most   common   complaint   about  using  bit  maps  for
        character  output  is  lack of speed.  This section suggests ways
        to   speed   things  up.   By adopting all of these methods,  you
        can realize an improvement of two to three times in speed.  


        BBYYTTEE AALLIIGGNNMMEENNTT        

             Since writing   graphic   text  is  essentially  a  bit-blit
        operation,   characters  which  have  "fringes",  that is, do not
        align   evenly  with  byte  boundaries,  will suffer  performance
        penalities.   The  default system fonts in all resolutions of the
        ST  are   a   multiple  of  eight  pixels  wide,   so the problem
        reduces   to  assuring   that   each  characters starts at a byte
        boundary   in   the  screen  bit  map.   This will be true if the
        horizontal  pixel  address  of  the left edge of the character is
        evenly divisible by eight.  

             Obviously,  byte   alignment   is  easiest  to enforce  when
        the  horizontal  justification  is  right or left.  Doing so with
        centered  text is possible, but requires adding padding blanks to
        odd length strings.  

             When  writing   text  within  windows,   it  is  helpful  to
        assure  that  the  edges  of  the  window  working  area are byte
        aligned.   There  is   a  section  of  code in the download which
        shows  a  technique   for  converting   a   user requested window
        position    and/or    size    to    its   working     dimensions,
        byte-aligning    the    width    and   horizontal  position,  and
        computing the adjusted external window coordinates.  


        WWRRIITTIINNGG MMOODDEE        

             The fastest  text  output  mode is replace.  All other modes
        require  reading  in the target raster area and  merging it  with
        the   new  information.    You  may  find  that  you   must   use
        transparent  or  reverse transparent mode,  for instance,  to use
        or  preserve an underlying background color other than white.  In
        this  case,   you   can  still  do  some optimization by  filling
        in   the  background  color  for  the entire string with a vbar()
        call, rather than doing it one character cell at a time.  


        CCLLIIPPPPIINNGG         

             VDI  output   always   proceeds   faster  when  the clipping
        rectangle  is  turned  off,  and  text  output  is  no exception.


        


        Professional GEM             Part X                             6


        Remember   that   you  may only do this if you are  drawing  into
        a  dialog  box,   or into the interior of a window which you know
        is   on  top.    (You   can   use   the  WMTOPPED  and   WMNEWTOP
        messages   for  keeping track of the top window, or use the WFTOP
        windget()  call  to   find  the  current  top.)  In both of these
        cases,   you  will know the  width  of the drawing area,  and you
        can  truncate  the   output  string  to  fit exactly, rather than
        setting  the  clipping  rectangle.   For  this to work,  you must
        have  used  the  byte  alignment  technique  to  assure  that the
        width of the writing area is  a  multiple  of eight.  


        BBIINNDDIINNGGSS         

             The  normal  binding for vgtext() is inefficient.  It copies
        the  string which you supply character-by-character  into intin[]
        before  it  calls the VDI itself.  In many cases, it will be more
        efficient  for  your  application  to  place characters  directly
        into   intin[] and make the VDI trap call directly.   To give you
        a  start,   the   code   for  the standard vgtext()  binding  has
        been  included in the download.  When setting up intin[], be sure
        not  to  load   more   than  80 characters,  or you will probably
        crash  the system! 


        MMOOVVIINNGG TTEEXXTT        

             When performing  text  editing  on  the  screen,  you should
        avoid  rewriting  the  string under edit  whenever  possible.  It
        is  always  more efficient to use the raster operations to move a
        string   to   the  right  or left,  assuming that you have obeyed
        the  byte   alignment  rule.     If  you are deleting characters,
        blit  the  unchanged  part  of  the  screen  to  the  left,   and
        overstrike  the  last character  in the string with a blank.   If
        inserting   characters,  blit   the   trailing   portion  of  the
        string  to  the  right  before writing in the new character.  


        TTHHAATT''SS IITT FFOORR NNOOWW      

             This concludes   the  two  article  series  on  simple   VDI
        output.    Future  columns  may  explore more complex  VDI topics
        such  as  proportional  text.   If  there  is something you would
        like   to   see,   please   use  the  Online Feedback to  let  me
        know!  Meanwhile,  the next column will give out the locations of
        some  of  the   "hooks" and "trapdoors" built into the AES object
        structure,  including   how   to  set up user-defined AES drawing
        objects.  






        


        Professional GEM                                                7


                                    PPAARRTT -- XXII

                             GGEEMM HHooookkss aanndd HHaacckkss    


             Welcome  to   the   eleventh  episode of ST PRO  GEM,  which
        is  devoted  to  exploring  some  of  the little documented,  but
        powerful,  features   of  GEM.   Like the authors of most complex
        systems,   the  GEM   programmers  left  behind a set of "hooks",
        powerful   features  which would aid them in enhancing the system
        later.   I  am going to lay  out  a number of these methods which
        have  served  me  well  in making  creative use of the AES.   You
        will  find  that  most  of  them  concern   the  object  and form
        libraries,   since  I  was  most  involved in those parts of GEM.
        There  are  probably many more useful tricks waiting  to be found
        in  other parts of GEM,  so if you happen onto one, please let me
        know  in  the Feedback!  Before you begin,be sure to  pick up the
        download for this column:  GMCL11.C in DL3 of PCS- 57.  


        PPOOWWEERRFFUULL OOBBJJEECCTTSS        

             The  first   four  tricks  all involve  augmenting  standard
        AES  objects.    This  is  a powerful technique for two  reasons.
        First,  you   can   take  advantage  of the  regular  AES  object
        and   form  libraries   to  draw and handle most of your objects,
        so  that  your program need only process the exceptions.  Second,
        you  can  use  the  RCS   to   copy   the  special  objects  into
        multiple   dialogs    or  resources.    These   four  tricks  are
        Extended  Object  Types,  User- defined Objects,  TOUCHEXIT,  and
        INDIRECT.  Let's look at each of them in turn.  


        EEXXTTEENNDDEEDD OOBBJJEECCTT TTYYPPEESS       

             If you  look  at  the AES Object Library documentation,  you
        will  notice  that  the  values for the OBTYPE field in an object
        are   all  32  or  less.    This  means that a number of bits are
        unused  in   this  field.    In fact,  the AES completely ignores
        the  top  byte  of   the  OBTYPE  field.    In  addition, the RCS
        ignores  the  top byte, but it also  preserves  its value when an
        object  is  read,  written,  or copied.  

             This  gives   you  one  byte  per  object to use as you  see
        fit.   Since   the  processing of an object or dialog is (so far)
        in   the  hands  of the AES,  the best uses of Extended Types are
        in  flagging  methods  for initializing an object or handling its
        value when  the dialog  completes.  

             For  example,     you    might    have    several    dialogs
        containing  editable  numeric fields.   The Extended Type of each
        numeric  field  could  be  set  to the index of the corresponding


        


        Professional GEM             Part XI                            8


        value   in   an    array.    Then   your   application's   dialog
        initialization  code  could  scan   the  object   tree  for  such
        objects,   pick  up   the   appropriate  value from the array and
        convert  it  to  ASCII,   storing  the  result  in the resource's
        string   area.    When  the  dialog  was  finished,  another pass
        could  be  made  to  reconvert the ASCII to binary and store away
        the  results  in  the  array.    (Note that the maptree() utility
        from column #5 will scan an entire resource tree.) 

             Another  application   is   to  assign   uniform   codes  to
        exit  buttons   in   dialogs.    If you give every "OK" button an
        Extended  Type   of  one,   and every "Cancel" button an Extended
        Type  of   two,  then   you   needn't   worry  about naming every
        exit   object.    Just  examine   the Extended Type of the object
        returned by formdo,  and proceed accordingly.  

             The catch,  of  course,  is  that  you have to find a way to
        enter  the  Extended  Type code in the first place.   Version 1.0
        of   the RCS, as shipped with the Atari developer's kit, makes no
        provision  for  this.  So you have your choice of two methods for
        creating the first  object with each Extended Type code.  

             First,  you  can  dump  out a C source of a resource, insert
        the  new  type  code  by  hand,  and regenerate the resource with
        STCREATE.   Alternately,   you  could carefully modify the binary
        resource  using  SID.    You will probably want to reread the AES
        object  manual,  ST PRO GEM #4 and #5,  and use the C source as a
        guide  when doing so.  In both cases, you should make things easy
        on  yourself  by  creating  a   one   dialog resource with only a
        single  object other  than  the root.   Version  2.0  of  the RCS
        will  let  you  directly  enter  an Extended Type, but it has not
        yet been released for the ST by DRI.  

             Once  you  have  created  a  prototype  extended  object  by
        either  method,  you can use the RCS to propogate it.  The safest
        way  is  to  use the MERGE option to add the modified tree to the
        resource   you  are building.  Then copy the prototype object via
        the  clipboard  to  your  dialog(s), deleting the extra tree when
        you  are  done.   If  you  are   using several different extended
        objects,   you  can  use   MERGE and clipboard copies to get them
        all  into  one  tree  which  will  then  become  your  own object
        library.  

             The  second   way   of   using  RCS  is  easier,   but  more
        dangerous.   If you want to try the following technique,  BACK UP
        YOUR  RCS  DISK FIRST!   Put  simply,  the RCS does not care what
        is  in  its  dialog partbox. It will make copies of anything that
        it  finds  there!  This  gives you the option of using the RCS on
        ITS  OWN  RESOURCE in order to add your customized objects to the
        partbox.  




        


        Professional GEM             Part XI                            9



             To do  this,  open  RCS.RSC from the RCS.  Since there is no
        DEF  file,   you  will  get  a collection of question mark icons.
        Use  the  NAME  option  to  make TREE5 into a DIALOG.    Open it,
        and you will see the dialog partbox.  

             Now you  can  use  the  MERGE  technique  described above to
        insert  your   customized   objects.    Then  SAVE  the  modified
        resource,   and  rerun  the  RCS.   Your  new  objects should now
        appear  in  the partbox.  If  you added several,  you may have to
        stretch  the  partbox to see them  all.   You can now make copies
        of  the  new  objects  just   like any other part.  (Note: DO NOT
        modify  the  alert or menu partboxes, you will probably crash the
        RCS.) 


        UUSSEERR--DDEEFFIINNEEDD OOBBJJEECCTTSS        

             The one  type  of  object  which  was  not  discussed in the
        earlier   articles    on    AES   objects   was   GUSERDEF,   the
        programmer    defined   object.     This    is   the   hook   for
        creating    objects    with    other  appearances   beyond  those
        provided  by  the  standard   AES.   By  the way, you should note
        that  the  GPROGDEF  and  APPLBLK  mnemonics  used  in   the  AES
        documents  are  incorrect;   the  actual  names  as  used defined
        OBDEFS.H are GUSERDEF and USERBLK.  

             The  RCS   does   not   support  the  creation  of  GUSERDEF
        objects,  since   it   has   no  idea  how they will be drawn  by
        your   program.   Instead,   you  must insert a dummy object into
        your  resource  where  you   want  the  GUSERDEF  to appear,  and
        patch  it  after  your application performs its resource load.  

             You   must    replace    the   object's   existing    OBTYPE
        with  GUSERDEF,   though  you  may still use the upper byte as an
        Extended  Type.    You  must  also  change the OBSPEC field to be
        a   32-bit  pointer   to   a  USERBLK  structure.   An USERBLK is
        simply  two   LONG  (32-bit)  fields.   The  first is the address
        of  the  drawing   code  associated   with   the   user   defined
        object.    The  second  is  an arbitrary 32-bit value assigned to
        the object by your application.  

             You can  designate  objects  for  conversion to GUSERDEFs in
        the  normal  fashion by assigning them names which are referenced
        one  by  one  in your initialization code.   You can also combine
        two  tricks  by using the Extended Type field as a designator for
        objects  to  be  converted  to  GUSERDEF.   Each tree can then be
        scanned  for  objects  to   be converted.   There is a short code
        segment in the  download which demonstrates this technique.  

             My  usual   convention   is  to define new  drawing  objects
        as  variants   of   existing  objects,   using  the Extended Type


        


        Professional GEM             Part XI                           10


        field   to designate the particular variation.   Thus an Extended
        Type  of  one  might  designate  a  GBUTTON with rounded corners,
        while  a  value  of two  could  flag  a GSTRING of boldface text.
        When   using   this  technique,   the  RCS can be used to build a
        rough  facsimile  of  the  dialog   by inserting the basic object
        type  as   placeholders.    The existing  OBSPEC  information can
        then  be copied  to  the  second position in the USERBLK when the
        object is initialized.  

             One final  note  before  moving on:  There is no reason that
        the  USERBLK   cannot  be extended beyond two fields.   You might
        want  to  add   extra  words to store more information related to
        drawing  the object, such as its original type.  

             The  AES   will   call   your  drawing  code  whenever   the
        GUSERDEF  needs   to  be  drawn.    This  occurs when you make an
        objcdraw   call  for  its tree,  or when an objcchange occurs for
        that   object.    If  your  user-defined  object  is  in  a  menu
        drop-drop,  then  your  drawing  code will be called any time the
        user exposes that menu.  

             Before  getting    into   the   details   of   the  AES   to
        application  calling   sequence,   some   warnings  are in order.
        First,   remember that your drawing code will execute in the AES'
        context,  using  its  stack.    Therefore,   be  careful  not  to
        overuse  the  stack with deep recursion, long parameter lists, or
        large  dynamic  arrays.  Second, the  AES  is NOT re-entrant,  so
        you  may  not  make  ANY  calls  to   it  from  within a GUSERDEF
        procedure.    You  may,   of  course,  call  the  VDI.   Finally,
        realize   that  drawing code associated with a menu object may be
        called  by  the  AES  at  any  time.    Exercise  great  care  in
        sharing   data   space  between such code and  the  rest  of  the
        application! 

             When your  drawing  code  is called by the AES, the stack is
        set  up   as if a normal procedure call had occured.   There will
        be  one  parameter   on the stack:  a 32-bit pointer to a PARMBLK
        structure.   This  structure  lies  in the AES' data space, so do
        not write beyond its end! 

             The  PARMBLK  contains  15  words.    The  first two are the
        long  address of the object tree being drawn,  and the third word
        is  the  number  of  the  GUSERDEF  object.    You may need these
        values  if  the  same   drawing   code  is used for more than one
        object    at   a   time.   Words   four   and  five  contain  the
        previous   and   current  OBSTATE values of the object.  If these
        values  are  different,  your  drawing code  is  being  called in
        response   to   an   objcchange   request.  Otherwise, the active
        AES call is an objcdraw.  

             Words six  through  nine  contain  the object's rectangle on
        the   screen.     Remember   that   you  cannot  call  objcoffset


        


        Professional GEM             Part XI                           11


        within   the  drawing  code,  so you will need these values!  The
        next  four  words contain the clipping rectangle specified in the
        active  objcchange  or  objcdraw  call.    You should set the VDI
        clip  rectangle  to  this  value  before  doing any output to the
        screen.  

             The last  two  words  in  the  PARMBLK contain a copy of the
        extra  32-bit  parameter from the object's USERBLK.   If you have
        followed  the   method  of  copying an OBSPEC into this location,
        these  words  will  be  your  pointer  to a string, or BITBLK, or
        whatever.  

             When  your  drawing  routine  is  done,   it should return a
        zero  value   to   the  AES.   This is a "magic" value;  anything
        else will stop the drawing operation.  

             The download   contains   a  sample  drawing  routine  which
        defines   one  extended  drawing  object,   a  rounded  rectangle
        button.   You  can  use   this  procedure as a starting point for
        your own User  Defined objects.  


        PPUUTT AANNYYTTHHIINNGG YYOOUU WWAANNTT OONN TTHHEE DDEESSKKTTOOPP!!   

             In  ST    PRO   GEM  #2,   I  described  the  use   of   the
        WFNEWDESK  windset   call  to substitute your own object tree for
        the   normal  green  desktop background.   If the tree you supply
        contains   User Defined  objects,  you can draw whatever you want
        on  the  desktop! Some  of the things you might try are free hand
        drawings   imported  in   metafile   format  from  EasyDraw,   or
        whole   screen   bit   images generated by Degas.   If you do the
        latter,  you  will  have to store the entire image off screen and
        blit parts of it to the display as requested.  

             In  any  case,   remember that your desktop drawing code can
        be  called any time that a window is moved,  so exercise the same
        care  as  with  a  menu  drawer.   Also, be aware that making the
        WFNEWDESK  call   does   not  force  an  immediate  redraw of the
        desktop.    To   do  that,  do  a formdial(3) call for the entire
        desktop rectangle.  


        TTHHEE TTOOUUCCHHEEXXIITT FFLLAAGG       

             The  TOUCHEXIT  attribute  is  an  alternative to  the  more
        usual  EXIT.    When  the  TOUCHEXIT  bit  is  set in an object's
        OBFLAG  word,  the  formdo routine will exit immediately when the
        mouse   button   is   pressed    with   the   cursor   over   the
        object.     Your   code    can  immediately  take  control of the
        mouse  and  display,  without  waiting  for  the  release  of the
        button.   This  method  is  used  for  generating effects such as
        slider bars within otherwise normal dialogs.  


        


        Professional GEM             Part XI                           12



             The  easiest   way  to code a TOUCHEXIT handler is to  place
        a  loop   around the formdo call.   If the object number returned
        is  TOUCHEXIT,  then the animation procedure is called,  followed
        by   a   resumption     of    the   formdo   (WITHOUT   recalling
        formdial    or  objcdraw!).    If the object returned is a normal
        EXIT,  the  dialog  is  complete and control flows to the cleanup
        code.  

             There is  one  idiosyncrasy  of  TOUCHEXIT  which  should be
        noted.   When  the  AES  "notices" that the mouse button has been
        pressed  over  a  TOUCHEXIT,   it  immediately retests the button
        state.    If  it  has  already  been  released,  it  waits to see
        if   a   double  click   is  performed.  If so, the object number
        returned  by  formdo will have its  high  bit set.   If you don't
        care  about  double  clicks,   your  code  should  mask  off this
        flag.    However,  you may want to use the double click to denote
        some  enhanced action.  For example, the GEM file selector uses a
        double  click  on  one  of  the  file name  objects to indicate a
        selection plus immediate exit.  


        TTHHEE IINNDDIIRREECCTT FFLLAAGG       

             If the  INDIRECT  bit  is  set in an object's OBSTATE  word,
        the  AES  interprets  the 32-bit OBSPEC field as a pointer to the
        memory  location   in  which  the  ACTUAL  OBSPEC is to be found.
        Like   User Defined objects,  this capability is not supported by
        the  RCS,   so you  have to set up the INDIRECT bit and alter the
        OBSPEC at  run time.  

             The value  of  INDIRECT  is that you can use it to associate
        an  AES   object with other data or code.   The general technique
        is  to  set   up   a  table with a spare 32-bit location  at  its
        beginning.     Then,    when   initializing   the   application's
        resource,   you  move the true  OBSPEC  into  this location,  set
        the   INDIRECT   flag,   and  replace  the  OBSPEC  field  with a
        pointer  to  the  table.   The  object  behaves  normally  during
        drawing  and  form handling. However, if you receive  its  number
        from   formdo  or  objcfind,  you  have  an immediate  pointer to
        the  associated  table,   without  having to  go through a lookup
        procedure.  

             This  technique   works   well  in  programs  like  the  GEM
        Desktop.   Each   GICON  object  is  set  up with INDIRECT.   Its
        OBSPEC  goes  to  the   beginning  of  a  data  area defining the
        associated   file.   The blank  location at the beginning of file
        table  is  filled   up  with the former OBSPEC, which points to a
        ICONBLK.  

             You  can   also   combine   INDIRECT  with  TOUCHEXIT   when
        creating  objects   that   must change when they are clicked by a


        


        Professional GEM             Part XI                           13


        user.    For  instance,   a   color   selection   box   might  be
        linked   to   a   table  containing   the  various  OBSPEC values
        through  which   the   program  will  cycle.   Each time the user
        clicked  on  the  box,  the  TOUCHEXIT  routine would advance the
        table  pointer,   copy  the  next  value  into  the  dummy OBSPEC
        location  at  the  front  of the table,  and redraw the object in
        its new appearance.  

             A  programmer     who    wanted    to    follow   a    truly
        object-oriented  "Smalltalkish"  approach  could use the INDIRECT
        method  to  bind   AES  drawing   object  to tables of associated
        procedures   or  "methods".  For instance, one procedure could be
        flagged  for  use when the user clicked  on the object,  one when
        the  object was dragged,  one for double-click,  and  so on.   If
        the  table  structure  was  capable of indicating  that  the true
        method  was  stored  in  another   table,   a rudimentary form of
        class inheritance could be obtained.  


        IINNSSTTAANNTT CCOO--RROOUUTTIINNEESS        

             We turn  to  the  AES  event  and  message  system for  this
        trick.   While    some   languages   like   Modula  2  provide  a
        method    for  implementing   co-routines,   there   is   no such
        capability   in   C.   However,  we  can  effectively  fake it by
        using  the  AES  event library.  

             As  already   seen  in  an  earlier column,  an  application
        can  write  a  message to its own event queue using the applwrite
        call.   Usually,  this  is a redraw message, but there is nothing
        to  prevent  you  from  using this facility to send messages from
        one  routine   in your program to another.  To set up co-routines
        using   this   method,   they   would   be   coded   as  separate
        procedures  called  from  the application's main event loop.  

             When  one   of  the  co-routines wanted to call  the  other,
        it  would   post   a  message  containing  the  request  and  any
        associated  parameters  into  the  application's  queue  and then
        return.   The  main  loop   would  find  the message and make the
        appropriate  call to  the second co-routine.  It it was necessary
        to  then  re-enter  the first co-routine  at  the  calling point,
        the   original   message  could contain an imbedded reply message
        to  be  sent  back  when  the  request was  complete.   A  simple
        switch   structure   could   then  be  used   to  resume  at  the
        appropriate point.  

             There  are  two  potential  problems  in  using this method.
        The  first  is  the  limited  capacity  of  the application event
        queue.   The  queue   contains   eight  entries.    While the AES
        economizes    this   space   by   merging  redraws  and  multiple
        events,   it   cannot   merge messages.   Because  of this limit,
        you  must  be  extremely  careful when  one  message received has


        


        Professional GEM             Part XI                           14


        the  potential to generate  two  or more  messages sent.   Unless
        this  situation  is  carefully  managed,  you   can get a sort of
        "cancer"  which  will overflow the queue  and probably crash your
        application.  

             The second  danger  involves race conditions.   Message sent
        by  the   application   are posted to the end of the  queue.   If
        other  events   have  occurred,  such as mouse clicks or keyboard
        presses,   they   will   be  seen  and  processed  ahead  of  the
        application  generated  message.   This  implies  that you cannot
        use  this method  if  the program must complete its action before
        a new user generated event can be processed.  


        TTHHAATT''SS AALLLL FFOORR NNOOWW      

             Hopefully these  hints  will  keep  you  profitably occupied
        for   a  while.    ST  PRO  GEM  number twelve will return to the
        topic  of  user  interfaces.    Reaction  to the first article on
        this   subject   was mostly  positive,  but a lot of folks wanted
        to  see  real   code   as  well.    In response to your feedback,
        there  will  also  be  code  for  implemented   your   own "mouse
        sensitive"  objects   which   highlight  when  the cursor touches
        them.    This  will  be  presented  as part  of an alternate form
        manager.  


        UUPPDDAATTEE:: AATTAARRII SSTT       

             I  have    recently   gotten  more   information   on   some
        topics  mentioned  in  earlier articles.   These notes will bring
        you up  to date: 

             A number  of  developers  reported  that they were unable to
        get  the   self-redraw  technique described in ST PRO GEM  #2  to
        work.   This  is  usually due to a bug in the applinit binding in
        Alcyon  C.   The  value  returned from the function,  which would
        normally   be  assigned   to  glapid,  is coming back as garbage.
        To  work  around  the  problem,   declare EXTERN WORD glapid;  in
        your  program  and  DO NOT  assign the value from applinit.   The
        binding  WILL  make   the  assignment.   A tip of the hat to Russ
        Wetmore for this report.  

             The   last   column   mentioned   that   turning   off   the
        clip  rectangle   while  drawing  graphics text will speed things
        up.     It  turns   out  that  the  VDI  will  also  run  at  the
        non-clipped  speed   if  the   ENTIRE   string  to  be written is
        within   the   current  clip rectangle.  To compound the problem,
        there  is  a  one-off  bug  in the detection  algorithm  for  the
        right   edge.    That   is,   the   clip rectangle  has to be one
        pixel  BEYOND  the right edge of  the  text for the fast write to
        work.  


        


        Professional GEM             Part XI                           15



             The Feedback  in  ST  PRO  GEM  #10 mentioned that there are
        known  bugs   in   the   Alcyon  C  floating point  library.   In
        fact,   this  library   has  been  replaced with a new,  debugged
        version  in  recent  shipments   of the Toolkit.   If you need to
        use  floating  point  and have  run into this bug,  you should be
        able  to  get  an  update  from Atari.   Also,  check  the  Atari
        Developer's SIG (PCS-57) for  a possible download.  

             In addition,  it  turns out there is an undocumented feature
        in   Alcyon    C    which  allows  you  to  imbed  assembly  code
        in-line.   Try using: 

                                  asm(".....");

        where  the  dots  are replaced with an assembly instruction.  You
        get  one  instruction  per asm(),  one asm() per line.  Thanks to
        Leonard Tramiel for both of the above tidbits.  




































        


        Professional GEM                                               16


                                   PPAARRTT -- XXIIII

                       GGEEMM EEvveennttss aanndd PPrrooggrraamm SSttrruuccttuurree   


             So I  fibbed  a  little.   This  issue  (#12)  of ST PRO GEM
        started  out  to be another discussion of interface issues.  But,
        as  Tolkien  once said, the tale grew in the telling, and this is
        now  the  first  of  a series of three articles.   This part will
        discuss  AES  event  handling   and   its  implications  for  GEM
        program   structure.    The  following   article  will  contain a
        "home  brew"  dialog handler  with some  new  features,  and  the
        third  will,   finally,   take  up  the discussion  of  interface
        design,   using the dialog handler as  an example.   (There is no
        download  for  this  article.   The downloads will return, with a
        vengeance, in ST PRO GEM #13.) 



        AALLLL FFOORR OONNEE AANNDD OONNEE FFOORR AALLLL..   

             A quick  inspection  of  the AES documents  shows that there
        are  five  routines  devoted  to  waiting for individual types of
        events,  and  one  routine,  evntmulti, which is  used  when more
        than  one  type  is  desired.    This article  will discuss  ONLY
        evntmulti  for  two  reasons.   First,  it is the most frequently
        used  of the routines.   Second, waiting for one type of event is
        a  bad  practice.    Any  event call turns the system over to the
        AES  and  suspends  the application and its interaction with  the
        user.    In   such   cases,   some   "escape  clause",  such as a
        timer,  should  be  inserted to revive the program and prompt the
        user   if   no   event    is    forthcoming.     Otherwise,   the
        application  may  end  up apparently  (or  actually)  hung,  with
        a  resulting  reboot,  and probably a very annoyed user.  


        SSTTAARRTTIINNGG AAHHEEAADD..        

             One  possible  type  of  event is a  message.  Messages  are
        usually  sent  to the application by the AES,  and are associated
        with   windows  or  the  menu.    Two  previous articles  in this
        series  have  discussed  such  messages.    ST PRO GEM number two
        considered    window   messages,    and   number   seven  handled
        menu  messages.   You  may  want  to  review  these topics before
        proceeding.  

             The actual evntmulti call is a horrendous thing: 

                          evwhich = evntmulti(evflags,
                               btnclicks, btnmask, btnstate,
                                r1flags, r1x, r1y, r1w, r1h,
                                r2flags, r2x, r2y, r2w, r2h,


        


        Professional GEM            Part XII                           17


                                         &msgbuff,
                                      timelo, timehi,
                           &mx, &my, &btn, &kbd, &char, &clicks);

        Each   of   the  lines  in the call relate to a different  event,
        and they  will be discussed in the order in which they  appear.  

             Note  that  a  call  with  this  number of parameters causes
        some  overhead  stacking  and retrieval of the values.   In  most
        cases,   this   should  be of little concern on a machine as fast
        as  the  ST.   However, where throughput is a concern, such as in
        close  tracking   of  the  mouse cursor,  you may want to write a
        customized  binding   for  evntmulti  which  dispenses  with  the
        parameter   list.   This  can  be accomplished by maintaining the
        values  in   a  static array  and moving them as a block into the
        binding   arrays  intin (for all values but &msgbuff), and addrin
        (for  &msgbuff).  Note that  you  may NOT simply leave the values
        in  intin;  other  AES bindings reuse this space.  

             Evflags  and  evwhich are both 16-bit integers  composed  of
        flag  bits.   Bits  set  in  evflags determine which event(s) the
        call  will   wait   for;   those   set in evwhich  indicate  what
        event(s)  actually  occurred.    Both  use the following flag bit
        mnemonics and functions: 

                 0x0001 - MUKEYBD - Keyboard input 

                 0x0002 - MUBUTTON - Mouse button(s) 

                 0x0004 - MUM1 - Mouse rectangle #1 

                 0x0008 - MUM2 - Mouse rectangle #2 

                 0x0010 - MUMESAG - AES message 

                 0x0020 - MUTIMER - Timer 

        The   appropriate  mnemonics  are  ORed  together  to  create the
        proper evflags value.  

             There  is    one    common   pitfall  here.    Notice   that
        multiple  events   may   be  reported from one evntmulti.   Event
        merging   is  performed  by the AES in order to save space on the
        application's  event  queue.    If events have been merged,  more
        than   one   bit  will  be   set  in  the  evwhich  word.    Your
        application  must  check ALL of the  bits  before  returning to a
        new   evntmulti   call.    If  you don't do this, some events may
        be effectively lost.  

             The  first  event  to  be  considered  is  the mouse button.
        This  is probably the most difficult event to understand and use,
        and it has one major shortcoming.  


        


        Professional GEM            Part XII                           18



             The  parameter   btnclicks  tells  GEM  the  maximum  number
        of  clicks  which  you  are interested in seeing.   This value is
        usually  two,   if  your program uses the double-click method, or
        one  if  only  single   clicks   are  used.   The AES returns the
        number   of  clicks which caused the event through &clicks, which
        must be a pointer to a word.  

             GEM determines   the  number  of  clicks  by  the  following
        method.   When the first button-down is detected, a time delay is
        begun.   If  another   complete  button-up,  button-down cycle is
        detected  before  the  time expires,  then the result is a double
        click.    Otherwise,  the   event is a single click.    Note that
        the  final  state  of   the  buttons   is  returned via &btn,  as
        described  below.    By  checking  this   final  state,   you may
        determine  whether  a single click event ended with the button up
        (a  full  click),  or with the button still down  (which  may  be
        interpreted  as  the  beginning  of  a  drag operation).   Double
        clicking  is  meaningless,   and not checked, if the evntmulti is
        waiting on more than one button (see below).  

             The double-click  detection  delay  is variable,  and may be
        set by your program using the call 

                      evdspeed = evdclick(evdnew, evdfunc);

        Evdfunc   is  a  flag  which  determines the purpose of the call.
        If   it   is   zero,   the   current   double  click   speed   is
        returned   in  evdspeed.    If  evdfunc  is non-zero, then evdnew
        becomes  the  new  double-click    speed.     Both  evdspeed  and
        evdnew   are  words containing  a "magic number" between zero and
        four.    Zero  is   the  slowest  (i.e.,  longest)  double-click,
        and   four   is   the   fastest.   (These   correspond   to   the
        slow-fast   range   in  the   Desktop's Preferences  dialog.)  In
        general,    you   should   not  reset  the  click  speed   unless
        specifically  requested,   because  such  a change  can throw off
        the   user's   timing  and  destroy  the  hand/eye   coordination
        involved in using the mouse.  

             GEM  was   originally  designed  to  work  with   a   single
        button  input  device.   This allows GEM applications interaction
        well  with  devices  such  as  light pens and digitizing tablets.
        However,   some   features   are   available   for  dealing  with
        multi-button mice like the ST's.  

             The  evntmulti  parameters  btnmask and btnstate  are  words
        containing   flag  bits  corresponding  to  buttons.   The lowest
        order  bit  corresponds  to  the left-most button,  and so on.  A
        bit  is  set  in   the  btnmask parameter if the AES is to  watch
        a   particular  button.    The   corresponding bit in btnstate is
        set  to the  value for  which  the program is waiting.   The word
        returned   via   &btn  uses   the   same   bit system to show the


        


        Professional GEM            Part XII                           19


        state  of   the   buttons   at completion.   It  is  important to
        notice  that  all  of   the  target states in btnstate must occur
        SIMULTANEOUSLY for the event to  be triggered.  

             Note the   limiting  nature  of  this  last  statement.   It
        prevents  a   program  from  waiting for EITHER the left or right
        button  to   be  pressed.   Instead,  it must wait for BOTH to be
        pressed,  which  is  a  difficult   operation   at  best.    As a
        result,   the  standard   mouse  button  procedure is practically
        useless  if you want to take  full advantage  of  both buttons on
        the  ST  mouse.    In  this  case,  your program  must "poll" the
        mouse  state  and   determine   double-clicks itself.   (More  on
        polling  later.)  By the way,  many  designers (myself  included)
        believe  that  using  both  buttons  is  inherently confusing and
        should be avoided anyway.  


        MMOOUUSSEE RREECCTTAANNGGLLEESS..        

             One of  GEM's  nicer  features  is  its ability to watch the
        mouse  pointer's position for you, and report an event only  when
        it  enters  or  departs  a given screen region.   Since you don't
        have  to  track the mouse pixel by pixel,  this eliminates  a lot
        of   application  over.    The  evntmulti  call  gives  you   the
        ability   to   specify  one or two rectangular areas  which  will
        be  watched.    An  event  can be generated either when the mouse
        pointer  enters  the rectangle,  or when it leaves the rectangle.
        The   "r1"   series    of    parameters   specifies  one  of  the
        rectangles,   and   the  "r2"  series  specifies  the  other,  as
        follows: 

          r1flag, r2flag - zero if waiting to enter rectangle, 
                           one if waiting to leave rectangle 
          r1x, r2x - upper left X raster coordinate of wait rectangle 
          r1y, r2y - upper left Y raster coordinate of wait rectangle 
          r1w, r2w - width of wait rectangle in pixels 
          r1h, r2h - height of wait rectangle in pixels 

        Each   rectangle   wait  will  only  be active if its  associated
        flag (MUM1 or MUM2) was set in evflags.  

             There  are  two  common uses of rectangle waits.   The first
        is  used  when  creating  mouse-sensitive  regions on the screen.
        Mouse-  sensitive  regions,  also called "hot spots", are objects
        which  show  a   visual  effect,  such as inversion or outlining,
        when  the  mouse  cursor  moves  over them.   The items in a menu
        dropdown,   or   the  inversion   of  Desktop icons during a drag
        operation,  are  common examples.  

             Hot spots  are  commonly created by grouping  the  sensitive
        objects   into   one   or   two  areas,   and then setting  up  a
        mouse  rectangle   wait   for   entering  the  area.    When  the


        


        Professional GEM            Part XII                           20


        event   is  generated,  the  &mx  and &my returns may be examined
        to  find   the  true   mouse  coordinates,   and objcfind or some
        other  search   will determine  the affected object.   The object
        is  then   highlighted,  and   a  new wait for exiting the object
        rectangle  is   posted.    (ST  PRO   GEM   #13  will show how to
        create more  complex  effects  with rectangle waits.) 

             The  second  common  use of rectangle waits is in  animating
        a  drag  operation.   In  many  cases,  you  can use standard AES
        animation  routines  such  as  grafdragbox or grafrubberbox.   In
        other  cases,  you  may  want  a figure other than a simple  box,
        or   desire   to  combine    waits   for  other  conditions  such
        as   keystrokes   or collision with hotspots.  Then you will need
        to  implement  the  drag  operation  yourself,  using  the  mouse
        rectangles  to  track  the cursor.  

             If you  want  to  track  the cursor closely, simply wait for
        exit  on  a  one  pixel  rectangle  at the current position,  and
        perform  the  animation  routine  at  each  event.   If  the drag
        operation  only  works  on  a grid,  such as character positions,
        you  can  specify  a  larger  wait  rectangle and only update the
        display when a legal  boundary is crossed.  


        MMEESSSSAAGGEESS..         

             The  &msgbuff  parameter of evntmulti gives  the address  of
        a  16 byte buffer to receive an AES message.   As noted above,  I
        have  discussed  standard AES messages elsewhere. The last column
        also  mentioned  that  messages  may  be  used  to  simulate  co-
        routines  within  a single GEM program.  

             A  further  possibility  which  bears examination is the use
        of   messages    to   coordinate   the   activities  of  multiple
        programs.    In  single-tasking   GEM,   at  least  one  of these
        programs  would  have to be  a  desk accessory.   In any such use
        of  the  GEM  messages,   you should pay careful attention to the
        possibility  of  overloading  the queue.   Only  eight  slots are
        provided  per  task,   and   messages,  unlike  events, cannot be
        merged by the AES.  


        TTIIMMEERR..         

             The  timer  event  gives  you  a way of pacing action on the
        screen,   clocking  out  messages,   or providing a time-out exit
        for    an   operation.     Evntmulti   has   two   16-bit   timer
        input  parameters,   timehi   and  timelo,  which are the top and
        bottom   halves,    respectively,    of   a   32-bit  millisecond
        count.    However,  this documented time resolution must be taken
        with  a  grain  of  salt on the ST, considering that its internal
        clock frequency is 200Hz! 


        


        Professional GEM            Part XII                           21



             The  timer   event  is  also  extremely useful  for  polling
        the  event   queue.    A  "poll"  tests the queue  for  completed
        events  without  going into a wait state if none are present.  In
        GEM,  this  is    done   by   generating   a   null  event  which
        always    occurs immediately.  A timer count of zero will do just
        that.  

             Therefore,  you    can   poll  for  any  set  of  events  by
        specifying  them   in   the  evntmulti parameters.   A zero timer
        wait   is   then  added  to  ensure  immediate completion.   Upon
        return,    if  any  eveit(s)  OTHER  than  MUTIMER  are  set,   a
        significant  event  was  found  on the queue.  If only MUTIMER is
        set, the poll failed to find an event.  


        KKEEYYBBOOAARRDD..         

             There  are   no  input  parameters  for the  keyboard event.
        The   character   which   is  read  is  returned   as   a  16-bit
        quantity  through  the  &char parameter.  For historical reasons,
        the  codes   which   are  returned  are  compatible  with the IBM
        PC's   BIOS  level scan codes.  You can find this character table
        in  Appendix  D  of  the  GEM VDI manual.   In general,  the high
        byte  need  only  be considered  if  the lower byte is zero.   If
        the low byte is  non- zero, it is a valid ASCII character.  

             Evntmulti  also  returns  the  status  of  several  modifier
        keys  through   the  &kbd  parameter.    This  word contains four
        significant bits as follows: 

                 0x0001 - Right hand shift key 

                 0x0002 - Left hand shift key 

                 0x0004 - Control key 

                 0x0008 - ALT key 

        If   a   bit   is   one,  the key was depressed  when  the  event
        was  generated.   Otherwise,  the key was up.  Since the state of
        these  keys   is  already  taken  into  account in generating the
        &char   scan  code,   the  &kbd word is most useful when creating
        enhanced  mouse functions, such as shift-click or control-drag.  


        RRAANNDDOOMM NNOOTTEESS OONN EEVVEENNTTSS..      

             Although the   &mx,   &my,   &btn,   and  &kbd  returns  are
        nominally  associated with particular event types, they are valid
        on  any  return from evntmulti, and reflect the last event  which
        was  merged  into  that  return  by  the  AES.  If you  want more


        


        Professional GEM            Part XII                           22


        current  values,   you  may  use  grafmkstate  to resample  them.
        Whichever   method   you   choose,   be   consistent  within  the
        application,  since   the  point  of  sampling  has  an effect on
        mouse  and  keyboard timing.  

             Although  this  and  preceding  columns have been  presented
        in  terms  of  a  GEM  application,   the  event  system has many
        interesting  implications   for desk accessories.   Since the AES
        scheduler  uses  non-preemptive   dispatching,  accessories  have
        an   event    priority   effectively    equal    to    the   main
        application.    Though   "typical"  accessories   wait   only for
        ACOPEN  or  ACCLOSE  messages   when   in their  quiescent state,
        this  is  not  a  requirement  of the  system.  Timer  and  other
        events  may  also  be  requested   by   an   accessory.  (Indeed,
        there    is    no   absolute  requirement   that   an   accessory
        advertise    its   presence   with  a  menuregister  call.)   The
        aspiring  GEM hacker might consider how these facts could be used
        to   create  accessories  similar  to  "BUGS" on the Mac,  or  to
        the   "Crabs"  program  described  in  the September,  1985 issue
        of  Scientific American.  


        EEVVEENNTTSS AANNDD GGEEMM PPRROOGGRRAAMM SSTTRRUUCCTTUURREE..     

             Although the   evntmulti call  might seem to be a small part
        of  the  entire  GEM system,  its usage has deep implications for
        the  structure  of  any   application.  It is generally true that
        each   use   of   evntmulti  corresponds  to   a  mode   in   the
        program.    For  instance,   formdo  contains its  own evntmulti,
        and  its invocation creates a moded dialog.  While the dialog  is
        in  progress,   other  features  such  as  windows and  menus are
        unusable.    The  grafdragbox,  grafrubberbox,  and  grafslidebox
        routines  also  contain  evntmulti  calls.    They  create a mode
        which  is  sometimes  called  "spring-loaded",   since  the  mode
        vanishes  when  some  continuing  condition  (a  depressed  mouse
        button) is removed.  

             In consequence,   a  well-designed,   non-modal  GEM program
        will  contain  only  one  explicit  evntmulti call.  This call is
        part  of  a  top-level   loop  which  decodes events as they  are
        received    and   dispatches    control    to    the  appropriate
        handling   routine.    The  dispatcher  must  always  distinguish
        between   event   types.    In  programs  where  multiple windows
        are  used,   it  may  also   need   to determine which local data
        structure is associated with the active window.  

             This  construction    is    sometimes    called   a   "push"
        program  structure,   because   it   allows the user to drive the
        application  by  generating  events in any order.  This contrasts
        with  the  "pull"  structure  of traditional command line or menu
        programs,   where the application is in control and demands input
        at  each  step before it proceeds.    "Push"  structure  promotes


        


        Professional GEM            Part XII                           23


        consistent   use  of  the user interface and a feeling of control
        on the part of the user.  

             The  next  ST  PRO  GEM  column  will  look  more closely at
        events  and   program   structure in the context of a large piece
        of   code.   The   code  implements an alternate dialog  handler,
        incorporating  mouse-sensitive  objects  as  part of the standard
        interface.    Since  this   code  is  "open",  it may be modified
        and   merged   with  any application's main event loop, resulting
        in non-modal dialogs.  












































        


        Professional GEM                                               24


                                   PPAARRTT -- XXIIIIII

                             AA NNeeww FFoorrmm MMaannaaggeerr    


             This  is   the  13th  installment  of  ST  PRO GEM,  and the
        first  devoted to explaining a large piece of code.  This article
        is  also  the  second  in a series of three concerning  GEM  user
        interface  techniques.    The  code is an alternate form (dialog)
        manager   for  GEM.    It   is  stored  as  GMCL13.C  in  DL3  of
        PCS-58.    You  should go and  download it now,  or you will have
        no hope of following  this discussion.  

             What  is    unique    about  this  version   of   the   form
        manager?  First,   it   implements   all  of the functions of the
        standard   GEM formdo  routine,  as  well as adding a "hot spots"
        feature     which   causes    selectable    objects   to   become
        mouse-sensitive,     just    like   the     entries    in    menu
        dropdowns.     The   second   (and   obvious) difference  is that
        this  form  manager  is  provided  in   source  code form.   This
        gives  you  the  freedom to examine it and change it to suit your
        own needs.  

             I  have   several   purposes  in presenting this  code.   It
        is  intended    as   an   example   of   GEM  program  structure,
        and   an  application   of   some  of  the  techniques  presented
        in   earlier  columns.    It  is  also relevant to the continuing
        thread  discussing  the necessity of feedback when constructing a
        user interface.  

             Also,  this    issue   represents   the   beginning   of   a
        fundamental  change  in  direction  for  ST PRO GEM.   Since this
        column  began last August, Atari ST developers have increased not
        only  in  number, but in sophistication.   A number of books,  as
        well  as back issues of ST PRO GEM,  are now available to explain
        the  basics  of  the  ST  and  GEM.    Quick   answers  to common
        questions  are available  here  on Compuserve's PCS-57 from Atari
        itself,  or from helpful members of the developer community.  

             To  reflect  these  changes,   future  columns  will discuss
        more  advanced  topics  in  greater depth, with an accent on code
        which  can be  adapted  by developers.   The program presented in
        this   issue  will  be a basis for a number of these discussions.
        There  will  be  fewer  "encyclopediac" treatments of AES and VDI
        function   calls.   Finally,  to  give  me  the  time required to
        create  this  code  or clean up tools from my "bag of tricks", ST
        PRO  GEM  will  probably  convert  to a monthly format around the
        start of summer.  






        


        Professional GEM            Part XIII                          25




        OONN WWIITTHH TTHHEE SSHHOOWW      

             Taking your  listing  in hand,  you  will quickly notice two
        things.    First,  this  program  uses  the  infamous portability
        macros,   so  that  it  may  be  used with Intel versions of GEM.
        Second,  the  routines are arranged "bottom up", with the main at
        the  end,   and subroutines going toward the beginning.  (This is
        a  carry-over  from  my  days with ALGOL and PASCAL.)  You should
        now turn to the formdo entry point near the end of the code.  

             One change  has  been  made in the standard calling sequence
        for  mdo.    The   starting   edit  field  is  now a pointer to a
        value,   rather    than   the  value  itself.    The  new  formdo
        overwrites   the  initial  value  with  the  number of the object
        being   edited   when   the  dialog   terminated.    Using   this
        information,   your  program   can restore the situation when the
        dialog  is  next  called.    As  before,  if there is NO editable
        field, the initial value should be zero.  

             There are  several  local  variables  which  maintain  vital
        state  information during the dialog interaction.  Editobj is the
        number  of   the  editable object currently receiving keystrokes.
        Nextobj  is   set  when the mouse is clicked over an object.   If
        the   object  happens  to  be  editable,  nextobj becomes the new
        editobj.  

             Three  variables   are   associated   with   the  "hot-spot"
        feature.   If  hotmode  is  set  to  M1ENTER,  then  the mouse is
        outside  the  area of the dialog.   If it equals M1EXIT, then the
        mouse  is  currently  in  the  dialog.    If it is in the dialog,
        hotobj  indicates  whether  there is an active "hot" object.   If
        its  value  is  NIL  (-1),   then  there  is  no  active  object.
        Otherwise,   it  is  equal  to  the number of the object which is
        currently  "hot",   that  is,  inverted on the screen.   Finally,
        hotrect  is  the current wait rectangle.  If the mouse is outside
        of  the  window,  then  the  wait  rectangle  equals the dialog's
        ROOT.    If  there  is a current hot object,  then hotrect equals
        that   object's  screen  rectangle.    If  the  mouse  is in  the
        dialog,    but   not   within   a  hot  object,   then  the  wait
        rectangle  defines   the  area within which no further  collision
        checks    are  necessary.    This   is   arrived  at  through  an
        algorithm  explained below.  

             Formdo's initialization    code   sets   up   the   hot-spot
        variables  to   trigger   if   the  mouse  is within the  dialog.
        It   also   sets  starting  values  for editobj and nextobj which
        will  cause  the edit startup code to be activated.  

             The main  portion  of  formdo is a loop, exhibiting the type
        of  event   driven   structure   discussed  in the  last  column.


        


        Professional GEM            Part XIII                          26


        Before  entering  the  evntmulti wait,  the status of nextobj and
        editobj  are   checked   to   see  if  a  new  object  should  be
        initialized   for  editing.    If   so,  objcedit  is called with
        the   EDINIT    function  code.    NOTE:   the  objcedit  calling
        sequence  used  in this program differs from the one given in the
        AES  manual,   which is incorrect! You  should check the bindings
        you  are  using  to  be  sure they  will work with this code, and
        modify as necessary.  

             The evntmulti  is  set  up to wait for a mouse click (single
        or  double),   for   a   keyboard   input,  or  for the mouse  to
        make   a  "significant"  movement,  as  discussed above.   Notice
        that  since  formdo  is  used as a subroutine, it does not handle
        messages  which  are   normally   processed  by the main loop  of
        your   application.   Notice  that this creates a mode,  and that
        this  routine  as  written  handles  modal  dialogs.   You could,
        however,  use  this  code  as  the  basis  for a non-modal dialog
        handler  by drawing the dialog  within a  window,  and  combining
        the   main   loop   of  formdo  with  the   main  loop   of  your
        application.    (This  possibility  may  be  examined   in future
        columns.    In  the  meantime,  it is left as an exercise for the
        reader.) 

             The  event    bit   vector  is  returned  to  the   variable
        "which".    Since   events  are  not  mutually  exclusive,   each
        possible  event type must be examined in turn before returning to
        the  evntmulti  call.  The form manager's event handling routines
        are  formhot, for mouse rectangle event, formkeybd, for character
        input,  and  formbutton,  for   mouse   clicks.    Formkeybd  and
        formbutton  are   allowed  to terminate  the  dialog by returning
        a  value  of  false  to   the  loop control variable "cont".   If
        termination  is  imminent,  or  the  user  has  clicked  on a new
        editable  object,   objcedit is called  with EDEND  to remove the
        cursor  from  the  old  object.   The normal flow of control then
        returns to edit setup and evntmulti.  

             A few  cleanup  actions  are performed upon termination.  If
        the  terminating   object   (stored  in  nextobj) is not the same
        as   the  hotobj,  then  a race condition has occured and the hot
        object  must  be  cleared with objctoggle before exiting.   After
        this  test,  the  final   editobj   value  is passed back via the
        parameter,   and   the  terminating  object  is  returned  as the
        function value.  


        RREELLAAXXEENN UUNNDD WWAATTCCHHEENN DDAASS BBLLIINNKKEENNLLIICCHHTTEE     

             Formhot   is   responsible    for    maintaining   on-screen
        hot-spots,   and   correctly  updating   the   internal  hot-spot
        variables.   It is about  halfway through the listing.  




        


        Professional GEM            Part XIII                          27



             he first  action in formhot is to determine if the mouse has
        just  exited  an  object which is "hot.  In this case, objctoggle
        is  called  to  unhighlight  the  object  and  reset the SELECTED
        flag.  

             The current   mouse   position   is  passed  to  formhot  by
        formdo.   It  is checked against the root rectangle of the dialog
        to  see   if the mouse is inside the dialog.  If not, the program
        must  wait  for  it   to re-enter,  so formhot sets the rectangle
        and  waiting   mode  accordingly,  and  returns  NIL  as  the new
        hotobj.  

             When the  mouse  is  within  the  dialog, a regular objcfind
        call  determines   the  object  at which it is pointing.   For an
        object  to  be   mouse-sensitive,   it must be SELECTABLE and not
        DISABLED.    If  the   found object meets these tests,  the mouse
        will  "hover"   over  the   object,  waiting  to leave its screen
        rectangle.    Since   the  object  might already be SELECTED (and
        hence  drawn  reversed),   this  is  checked before objctoggle is
        called  to  do  the  highlighting and selection  of  the  object,
        which   becomes   the  hotobj.    (If   the  object  was  already
        SELECTED, the hotobj becomes NIL.) 

             The  toughest   condition   is  when  the  mouse  is  within
        the  dialog,   but   not  over  a  mouse-sensitive  object.   The
        regular  GEM  event   structure   will  not work,  because it can
        only  wait  on   two  rectangles,   and   there  may be many more
        selectable  objects  in   a  dialog   tree.    I have found a way
        around  this  limitation  using   a  combination  of  the maptree
        utility  (introduced  in  ST  PRO  GEM  #5) with the principle of
        visual hierarchy in object trees.  

             In  summary,    the    algorithm   attempts  to   find   the
        largest  bounding  rectangle  around  the current mouse position,
        within  which  there  are no mouse-sensitive objects.   It starts
        with  a  rectangle  equal   to the dialog root,  and successively
        "breaks"  it  with  the rectangle of each mouse-sensitive object.
        The next few paragraphs examine this method in detail.  

             Since  C   lacks   the   dynamic  scoping   of   LISP,  from
        which  maptree  was  derived,  it  is  necessary  to  set up some
        globals  to  be used during the rectangle break process.   Brrect
        is  the  GRECT of the current bounding rectangle.   Brmx and brmy
        hold  the  current  mouse  position.    Brtogl  is a switch which
        determines   whether   the   next    break   will   be  attempted
        horizontally   or    vertically.     After   initializing   these
        variables,  formhot  uses  maptree to invoke the breakobj routine
        for every object in the dialog.  

             Breakobj  first  intersects  the  rectangle  of  the  object
        with   the    current    bounding    rectangle.    If  they   are


        


        Professional GEM            Part XIII                          28


        disjoint,   then  neither   the  object  nor any of its offspring
        can   possible   affect  the   operation,   so FALSE is returned,
        causing maptree to ignore the subtree.  

             The  object    is   next   checked   to   see   if   it   is
        mouse-sensitive.   As  before,  it  must  be  SELECTABLE  and not
        DISABLED,   and   it  must  not  be   hidden  (this  was  checked
        automatically  by   objcfind  before).  If  these  conditions are
        met,   then  the  object  intrudes  into   the  current  bounding
        rectangle.    To  maintain  the  desired   condition, part of the
        rectangle must be removed or "broken away".  

             In  many   cases,   the   break   operation  can   be   done
        either  horizontally  or  vertically.   Since  we  have  no prior
        information  as  to which way the mouse will move next,  breakobj
        uses  the  brtogl  flag  to alternate which direction it will try
        first.   This should yield the most nearly square rectangle.  

             The  breakx  and breaky routines are very similar.   In each
        case,   the   segment occupied by the breaking object is compared
        to  the   point   occupied   by  the  mouse.    If  the  point is
        within   the  segment,   there  is  no  possible  break  in  this
        dimension,   and FALSE is  returned.   If  the point lies outside
        the  segment,  then  the rectangle  may be successfully broken by
        reducing  this  dimension.  This is done, and TRUE is returned to
        report success.  

             The breaky   routine  also  employs  a  look-ahead  test  to
        prevent  a  possible  infinite loop.   It is conceivable,  though
        not  likely,  that  someone  might  nest  a non-SELECTABLE object
        completely   within another  SELECTABLE object(s).   If the mouse
        point  is  within  such  an  object,  the  algorithm  will not be
        able  to   select   a  break dimension.   In the current version,
        the  mouse  rectangle  is  simply  forced  to  a single pixel for
        this  case.    (Note that is  is  NOT sufficent to simply wait on
        the  non-selectable  object's rectangle, since  other  SELECTABLE
        objects may overlap it and follow  it  in tree order.) 

             Since maptree  examines all possible objects, brrect will be
        the   correct  bounding  rectangle at completion.   Note that you
        can  readily   adapt  this  technique  to  other  uses,   such as
        hot-spotting  while   dragging   objects.    It   is   much  less
        demanding    of   CPU  resources  than  other  methods,  such  as
        repetitive objcfinds.  


        WWHHAATT AA CCHHAARRAACCTTEERR!!       

             The formkeybd   routine   acts  as  a  filter  on  character
        input.     When    it    recognizes  a  control   character,   it
        processes  it  and  zeroes the keyboard word.  Other chararacters
        are  passed  on  to objcedit to be inserted in editobj.  If there


        


        Professional GEM            Part XIII                          29


        is no editing object, the character goes to the bit bucket.  

             The   formkeybd     given     implements     the    standard
        GEM  functionality  with two minor additions.   First, a carriage
        return  in   a  dialog  with no DEFAULT exit object is taken as a
        tab.    This  allows  <CR> to be used "naturally" in dialogs with
        several   lines of text input.   Second,  tabs and backtabs "wrap
        around"  from  top  to   bottom  of  the dialog,  and are done by
        "walking   the  tree", rather  than relying on the LASTOB flag to
        signal  the  end   of   the  dialog.    This  allows the new form
        manager  to  handle  dialog  trees  which  are  not contiguous in
        memory.  

             The  code  sets  up  several  global  variables  for  use by
        mapped  functions.    Fnobj  is  the output from both findtab and
        finddef.   Fndir  is  an  input  to findtab.  Fnlast, fnprev, and
        fnlast are used while searching for tab characters.  

             A  carriage   return  results  in  a  search  of the  entire
        tree,  using   maptree  and  finddef,   for  an  object  with its
        DEFAULT  flag  set.   Its SELECTED flag is set and it is inverted
        on  the screen to indicate  the action taken.   Formkeybd returns
        a  FALSE to  force termination  of  the main formdo loop.   If no
        DEFAULT is  found, control passes to the tab code.  

             The  tabbing   procedure  is  somewhat  complicated  because
        the  same code is used for forward and backward tabbing.  The old
        value  of  editobj  (the object being tabbed FROM) is placed into
        fnlast.   Fndir   is  set to one for a forward tab,  and zero for
        a  backward tab.  

             The general   strategy  is  to  scan  the  entire  tree  for
        EDITABLE  objects,   always   saving   the   last  one  found  in
        fnprev.    When  tabbing   forward   fnlast   is  checked against
        fnprev.    A   match indicates  that  the  current object is  the
        one   desired.    When  tabbing   backward  the current object is
        checked   against   fnlast.   If   they   match,   fnprev  is the
        desired  object.    This   procedure requires two passes when the
        tab  "wraps  around" the tree, that is, when  the  desired object
        as  at  the  opposite  end of  the  traverse from the old editing
        object.  

             The  result   of   the   tab   operation   is  written  back
        into  formdo's   nextobj  parameter,  and becomes the new editing
        object at the beginning of the next loop.  


        BBUUTTTTOONN DDOOWWNN        

             The formbutton   procedure   is   lengthy  because  it  must
        recognize   and   handle   mouse  clicks   on  several  types  of
        objects:    EDITABLE,   SELECTABLE,  and  TOUCHEXIT.   The  first


        


        Professional GEM            Part XIII                          30


        section  of  code  rejects  other  objects, which cannot accept a
        click.  

             The  next   piece  of  formbutton makes a special check  for
        a  double click on a TOUCHEXIT object.   This will cause the high
        bit  of  the  returned  object  number  to be set.   (By the way,
        this  also  occurs   in   the standard formdo.)  This flag allows
        user  dialog code to perform special processing on the object.  

             The largest  piece  of  formbutton handles the various cases
        in  which  the  SELECTABLE flag may be set.   Setting the RBUTTON
        (radio  button)  flag  causes all of the object's siblings in the
        tree  to  be  deselected   at  the  time the object  is  clicked.
        The   doradio  routine  uses  the  getparent  utility to find the
        ancestor, and then performs the deselect/select operation.  

             If the    SELECTABLE   object   is   not   TOUCHEXIT,   then
        grafwatchbox  is  used  to  make sure that the mouse button comes
        back  up while  it is within the object.  Otherwise, the click is
        cancelled.   Care  is  necessary   here,  since the hot-spot code
        may  have  already  set  the  SELECTED flag for the object.   (We
        cannot   be  sure  of  this,   for  a  race  condition  may  have
        occurred!) 

             If  the   SELECTABLE   object   is   TOUCHEXIT,    then  the
        application  has  requested  that formdo exit without waiting for
        the  button   to  go  back up.   In both this and regular formdo,
        TOUCHEXIT  objects  are   used when you want to provide immediate
        response  (animation) within the context of a dialog.  

             The  final   parts   of  formbutton  do  cleanup.    If  the
        clicked  object   was  already hot-spotted,  hotobj must be reset
        to   NIL,  otherwise   formdo  will carefully unselect the object
        which  has just been selected! 

             If  the    EXIT   or   TOUCHEXIT   flags   are   in   force,
        formbutton  returns   FALSE  to  force  the completion of formdo.
        For   EDITABLE  objects,   nextobj   is  left  intact  to replace
        editobj  during   the  next  loop.   Otherwise,  nextobj has done
        its   job   and  is  zeroed,  and  formbutton  returns  TRUE  for
        continuation.  

             This  concludes  the  tour  of  the  alternate formdo.   The
        best  cure  for  any  confusion in this explanation is to compile
        the   code  into   an   application   and   watch   how  it  runs
        with   different resources,  or attack it with a debugger.  


        OOPPEERRAATTOORRSS AARREE SSTTAANNDDIINNGG BBYY      

             I encourage   you   to  modify   this  code   to  meet  your
        particular  needs  and  incorporate  it   into  your application.


        


        Professional GEM            Part XIII                          31


        I   would   like  to  request  than  anyone  who  comes   up with
        significant  improvements  (or  bug  fixes)  send them to  me  so
        they   can   be  made  generally available.   You can do this via
        the ANTIC ONLINE Feedback, or by sending E-mail to 76703,202.  

             Speaking  of   Feedback,   I   would  also like comments  on
        the  proposed  change  of  direction  for  the  column,  and more
        suggestions  for   future   topics.   The  next  installment will
        be   a   further  discussion   of  interface design.   Topics now
        queued   for   future articles  include the file selector and DOS
        error  handling,   a new object  editor,  and customized drag box
        and  rubber box  routines.  Discussions  on  VDI workstations and
        printer  output  are   on   hold  pending  release of the GDOS by
        Atari.    If  there are items  which you want to appear here, you
        must let me know! 







































        


        Professional GEM                                               32


                                   PPAARRTT -- XXIIVV

                           UUSSEERR IINNTTEERRFFAACCEESS -- PPaarrtt 22   


             This  issue  of  ST  PRO GEM (#14) continues the  discussion
        of  user   interface   design  which began in episode eight.   It
        begins  where  we left off,  with a further treatment of the mode
        problem,  and   proceeds   into   topics  such as visual  grammar
        and  layered interfaces.  

             Note  that   there   is   no   download   for  this  column.
        The  downloads  will return with the next issue,  a discussion of
        using  the   GEM  DOS  file  system  within  a  GEM  application.
        Specifically,  it   will  include  sample code for using the file
        selector,   the  GEM  formerror   alerts,  and some utilities for
        manipulating  file   and  path  names.   There  will  also  be  a
        feedback  section.   The following two columns will be devoted to
        "graphics  potpourri",   a  collection  of  small  but useful GEM
        utilities  such  as   popup   menus,   string editing, and source
        code for drag and rubber box operations.  


        MMOODDEESS AAGGAAIINN        

             If a  program  is modeless, it acts predictably, which turns
        out   to  be  very  important.    On  the  other  hand,   a  good
        definition   for   "modes"  is hard to find.   In  column  eight,
        I  suggested   that  a  mode exists when you cannot  use  all  of
        the   capabilities    of  the  program  without  performing  some
        intermediate  step.    If  this  is  less  than clear,  here  are
        two   alternate  definitions  offering  different  views  of  the
        problem.  


        TTHHEE ""TTWWOO UUSSEERR TTEESSTT""      

             Consider  the    following   thought  experiment:    Imagine
        that   your  ST  (and GEM) had two  mice,  two cursors,  and  two
        users.    Could   they  both  effectively use  the program at the
        same  time?   If  so,  the application is modeless.  If there are
        points  where one user can be "locked out" by the actions of  the
        other,   then  a mode exists at that point.  Let's  consider some
        examples of this test.  

             In any  program  which  uses  the  GEM menu system, one user
        could  stop   the   other by touching a menu hotspot and dropping
        a    menu.    This  constitutes  an  inherent  mode  in  the  GEM
        architecture.  

             On  the   GEM  Desktop,   two  users  could open windows and
        view  files  without  interference.    However,  as  soon  as one


        


        Professional GEM            Part XIV                           33


        person  tries  to  delete  a  file (assuming the verify option is
        on),   the  other  is  brought   to   a halt as a dialog appears.
        Thus,  we have found  a modal dialog.  

             In  many  "Paint-type"  programs,   such  as  MacPaint,   PC
        Paint,  and   GEM  Paint,  two artists could co-exist quite well,
        utilizing  the   on-screen   palette   and  tool  selection.   Of
        course,   these  programs   also  contain  modal dialogs for such
        operations    as    file   and   brush   shape   selection.    In
        contrast,   consider   the   paint  program   DEGAS  for  the ST.
        Here,   two  artists could only  work together as long as neither
        wanted  to  change tool or color.   Then the  display  would have
        to  be  flipped  to   the   selection  screen, stopping the other
        user.  This is a mode in the DEGAS interface.  

             (By the   way,   this   test  is  not  just  academic.   The
        grand-daddy  of  all  mouse  based  systems, NLS, demonstrated by
        Doug  Englebart  in 1968,  had  two  mice  and two users,  one of
        whom  was   physically remote.   Cooperative  techniques  such as
        this are still  largely unexplored and unexploited.) 


        OONNEE LLIINNEERR        

             Here's  a   terse  definition by  Jef  Raskin:  A program is
        modeless  if  a given action has one and only one result.  Again,
        let's run a few examples.  

             The  menu    dropdowns   are   clearly   modal    by    this
        definition.   Before   the   menu  was activated,  window control
        points   could   be  activated  with a click.   However, when the
        dropdown  is  visible,  a  click  action is interpreted as a menu
        selection  or  a dismissal  of the dropdown.   Similarly, dialogs
        are  modal  because the action of moving  the mouse into the menu
        bar no longer causes the  dropdown to appear.  

             I am  typing  this  using the First Word editor program.  It
        has  a   nice  desktop  level  box full of characters where I can
        click   to  get   symbols  which  the  ST keyboard won't produce.
        However,   if  I invoke  the  find or replace string dialog,  the
        click-in-the-box  action  doesn't  work anymore.   This is a mode
        in the First  Word interface.  

             Finally, consider  an  "old  style"  menu  program, the kind
        where  you   type  in  the  number  of  the desired action from a
        list.    Since the  number  "2" might mean "Insert the record" in
        one   menu,  and "Purge  the file" in another,  such a program is
        clearly modal  by Raskin's definition.  

             These  three  definitions  say  almost  the same thing,  but
        from  different   viewpoints.   Depending  on the situation,  one
        or   the  other   may   be  more intuitive for you.   The goal of


        


        Professional GEM            Part XIV                           34


        this  type   of  analysis  is to root out unnecessary modes,  and
        to  make sure that those  which remain only appear when requested
        by  the  user,   offer  some  visual cue such as a rubber line or
        standard  dialog  box,   and are used consistently throughout the
        application.  


        PPRREEDDIICCTTAABBIILLIITTYY FFOORREEVVEERR AANNDD EEVVEERR AANNDD EEVVEERR    

             As  Raskin's  definition   makes   clear,  when the modes go
        away,   the   interface  becomes   predictable.    Predictability
        leads   to  the  formation   of  habits    of    use.      Habits
        reduce   "think   time"  and   become progressively faster due to
        the  Power  Law  of  Practice discussed in column eight.  This is
        exactly what we want! 

             There is   another  benefit  of  predictability.    A  habit
        learned   in    one   part   of  a  program  with  a   consistent
        interface   can   be  transferred   and   used  elsewhere  in the
        application.    If   several  programs  share  the  same style of
        interface,  the  same habits can be used across a complete set of
        products.   Learning  time for the new functions becomes shorter,
        and the user is more likely to use the new feature.  


        IISS AA BBOOGGEEYYMMAANN!!       

             Most  casual   users  are   scared  silly  of computers  and
        programs.    (If  you  have  any doubt,  eavesdrop on a secretary
        with  a  new word processor,  or the doctor's receptionist coping
        with  an  insurance  data  entry  program.)   In most cases, they
        have    a    right   to   be   frightened.     Even   experienced
        programmers,  prone   to  toss  the manuals and hack  away,  know
        that   moderate  paranoia   is   the  best  way  to  deal with an
        unknown   program.    How must this feel to someone whose ability
        to  perform  (or  lose)  their  job  depends  on an unpredictable
        (aha!) black box.  

             So here's  another  way in which predictability works.   But
        to  produce   a  truly fearless user,  we need other qualities as
        well.   One   is  robustness,   meaning that the program will not
        crash   given  normal  or  even  bizarre  actions  by  the  user.
        Another   is   feedback,   which   shuts   off  invalid  options,
        reinforces  correct  actions,   and  gives  reassurance  that  an
        operation    is    proceeding    normally.    Finally,   we  need
        forgiveness,  in  the form of inverse operations or Undo options,
        when the inevitable mistake is made.  

             The  ultimate   goal  is  make  the  program   discoverable.
        This  means   the  user  should be able to safely "wing it" after
        a   short  session   with   the  application  and  its interface.
        This   practice ought to be considered the norm anyway, since the


        


        Professional GEM            Part XIV                           35


        manual  is  always across  the office or missing when an esoteric
        and   half-forgotten  feature  is  needed.   If it is possible to
        muddle   through  such   a  situation   by   trial   and   error,
        without   causing   damage,   the  immediate   problem   will  be
        solved,   and  the  user  will  gain confidence.  


        GGOOOODD GGRRAAMMMMAARR OORR......       

             So exactly  what  are  these habits that are supposed  to be
        so  helpful?    One  of  the most useful patterns is a consistent
        command    grammar    for   the    program.    This   may   sound
        strange,    since    we   have   supposedly   abandoned   command
        line  interfaces   in the graphics world,  but in fact,  the same
        type  of rules apply.   For instance, in the world of A> we might
        issue the command: 

                              copy a:foobar.txt b:

             By  analogy   to   Englist  grammar,   this command contains
        a   verb,  "copy",  a  file  as  subject:  "a:foobar.txt",  and a
        location   as  an  object:  "b:".   The  equivalent  GEM  Desktop
        operation is: 

            - Move mouse to foobar.txt icon in a: window 

            - Press mouse button 

            - Move mouse to b: icon 

            - Release mouse button 

             The  operation   can  be  described  as  a  select-drag-drop
        sequence,  with   the  select  designating the subject file,  the
        drag   denoting  the  operation  (copy),  and the location of the
        drop  showing   the  object.    A  grammar still exists,  but its
        "terminal  symbols"  are composed  of  mouse  actions interpreted
        in   the   context   of   the current screen display, rather than
        typed characters.  

             One  useful  way  to  analyze  simple  grammars,   including
        those  used   as  command  languages,  is to separate  them  into
        prefix,  postfix,   and  infix  forms.   In a prefix grammer, the
        operation  to be  performed precedes its operands,  that is,  its
        subject(s)  and object(s).   The  DOS copy command given above is
        an  example  of   a  prefix  command.   LISP  is  an example of a
        language  which  uses prefix specification for its commands.  

             Postfix grammars   specify  the  action  after  all  of  the
        operands  have  been given.   This command pattern is familiar to
        many  as  the  way  in  which  Hewlett-Packard calculators  work.
        FORTH   is   an  example  of  a  language  which  uses  a postfix


        


        Professional GEM            Part XIV                           36


        grammar.  

             Infix  notation   places  the  verb,   or operator,  between
        its  subject  and  object.    Conventional  algebraic notation is
        infix,  as are most computer languages such as C or PASCAL.   The
        example  GEM  command   given   above   is also infix,  since the
        selection   of   a  subject   file   preceded  the action,  which
        was  followed  by  the designation of an object.  

             The  "standard"   GEM  command  grammar,   as  used  in  the
        products  produced   by  Digital  Research,   is  in  fact infix.
        This  is not to say that GEM enforces such a convention,  or that
        it  is  rigorously  followed.  However, when there is no pressing
        reason  for  a change, adoption  of an infix command grammar will
        make   your   application  feel  most like others which users may
        have seen.  

             The general   problem   of   specifying  a  graphic  command
        language  can  be  difficult, but much of the problem has already
        been   handled   on   the  ST.    Part  of  the  solution  is  by
        constraint:   the  input  and  output  hardware  of  the  ST  are
        predefined,   so  most developers will not  need  to  worry about
        choosing  a pointing  device  or  screen resolution.   The  other
        part  of  the  standard solution is the  GEM convention for mouse
        usage.   I  am  going to review these rules, and then describe of
        the  situations  in which they have been bent,  and finally  some
        alternate   approaches   which   may   prove   useful   to   some
        developers.  


        SSPPEECCIIFFYYIINNGG AA SSUUBBJJEECCTT       

             There are  really  two sets of methods for  designating what
        is  to  be  affected  by  an  operation.    One set is  used when
        distinct  objects  are  to  be affected.   Examples  are file and
        disk  icons in the Desktop and trees in the RCS.   Another set of
        designation  methods  is  used when continuous material,  such as
        text or bit images, is being handled.  

             When dealing  with  objects,  a single mouse click (down and
        up)  over  the  object  selects it.   The application should show
        that  the  selection   has occurred by changing the appearance of
        the   object.   The   most   common   methods  are  inverting the
        object,  or  drawing "handles" around it.  

             Many   operations      allow    "plural",     or    multiple
        object,  selections.   The  GEM  convention is that a click on an
        object  while  the   shift key is held down extends the selection
        by   adding   that  object.    If  the  shift-clicked  object was
        already selected,  it is deleted from the selection list.  




        


        Professional GEM            Part XIV                           37



             Another  way  to  select  multiple  objects  is  to  use   a
        "rubber  box"  to enclose them.   This operation begins with drag
        on  a  part  of   the   view  where  no  object is present.   The
        application   then animates a rubber box on the screen as long as
        the  mouse  button  is held  down.   When the button is released,
        all  objects  within  the current extent of the box are selected.
        A  shift-drag  combination could be used to add the objects to an
        existing selection list.  

             Selecting  part  of  a  text  or  bit plane display is  also
        done  with  a  rubber  box.   Since there are no "objects" in the
        view,  any  mouse   drag  is  interpreted  as  the  beginning  of
        a   selection  operation.    In   the   simplest   case,   a  bit
        plane,   the rectangle within the box when the button is released
        is the selected extent.  

             When  the   underlying  data  has  structure,  such as words
        and  lines   of   text,   the  display  should  reflect this fact
        during   the  selection   operation.   Typically,  text selection
        is  indicated  by  inversion  of  the  characters  rather than  a
        rubber   box.    The  selection  extends  along the starting line
        so  long  as   the   mouse stays  within the line.   If the mouse
        move  off  the  starting  text line, the implied selection is all
        characters  between  the  starting  character   and the character
        currently   under   the  mouse,   which   is  not  necessarily  a
        rectangular area.  

             An  extended   "plural"   selection  may  be   supported  in
        text  editing.    The   use of the shift key is also conventional
        in  this application.  


        AACCTTIIOONN         

             With the  subject  designated,  the  user  can now choose an
        operation.    In  many cases,  this will be picked from the menu,
        in   which   case   the   entire   command  is  complete.    Some
        menu  selections  will lead to dialogs,  in which the interaction
        methods  are   regulated   by   the GEM form manager.   When  the
        command    is   completed,    it    is   often   helpful  if  the
        application   leaves   the objects  (or areas) selected and ready
        for  another  operation.   A single click away from any object is
        interpreted as cancelling the selections.  

             Many  operations    are   indicated  by  gestures   on   the
        screen.    Usually,    this   is   some   variant   of   a   drag
        operation.     The  interpretation  of  the gesture may depend on
        the  type  and   location of the selected subject,  which part of
        it   is   under   the  mouse,  and  in  what  location  the  drag
        terminates.  



        


        Professional GEM            Part XIV                           38



             "Handles"  are  small  boxes  or  dot  displayed  around  an
        object  when it is selected.   A drag beginning with the mouse on
        a  handle  is   usually   interpreted  as  a resizing  operation,
        if   this   is  appropriate.    The  pointing  finger  mouse form
        is   displayed   to  indicate   the operation in progress,  and a
        rubber  version of  the object  is animated on the screen to show
        the  user  the   result  if the  button  were released.   In some
        cases,    where   an    underlying  "snap"   grid   exists,   the
        animated  object may  change  size  in discrete steps.  

             Dragging  a   non-handle  area  of  a  selected  object   is
        usually   interpreted    as    the    beginning    of    a   move
        function.    In   most applications,  a  move  of a single object
        may  be  started   without pre-selection.   Simply  beginning the
        drag  on  the  object  is  taken  to imply selection.  The spread
        hand,  or  "grabber", mouse form  is typically displayed during a
        drag operation.  

             Dragging  may    denote   copying  or  movement,   or   more
        complex  functions such as instantiation or generalization.   The
        operation  implied  by  movement  on the screen will differ among
        applications,   and    often   within   the   same   application,
        depending   on   target location.   This  target is the recipient
        of  the  command's  action,  or its object, in an English grammar
        sense.  

             For  example,   a   drag  from  window  to  window  in   the
        Desktop  denotes  a  copy.   On the other hand, dragging the same
        icon  to  the  trashcan   deletes  it  completely.    Dragging an
        object  from  the  RCS partbox  to the editing view creates a new
        copy  of  that   prototype  object.    Dragging  the  same object
        within the edit  view  simply changes its placement.  

             There   are     some     mouse     actions     which     are
        conventional  "abbreviations".    A  double click on an object is
        interpreted   as  both  a selection and an action.   Usually, the
        double  click  action is the same as the Open entry in the "File"
        menu.  

             When  the   usual  interpretation  of  a  drag is  movement,
        then  shift-drag   may  be  used as an enhanced varient  implying
        copying.   For   instance,   shift-dragging  an object within the
        RCS   editing  window  makes  a  copy of the object and places it
        in  the  final location.  

             To return  to  the  beginning of this discussion, the reason
        for   adopting    these   conventional  usages  is  to  build  an
        interface   that  promotes   habits.   Particularly,  a  standard
        grammar  for   giving  commands  helps  answer the question "What
        comes  next?".    It  breaks  the  user's  actions  into  logical
        phrases,   or  chunks,   which  may be thought of a whole, rather


        


        Professional GEM            Part XIV                           39


        than one action at a time.  


        DDIIFFFFEERREENNTT FFOOLLKKSS DDIIFFFFEERREENNTT SSTTRROOKKEESS      


                  There  are   always  exceptions  to  a  rule,  or so it
        seems.    In  this case, consistency of   the  interface  grammar
        is   sometimes   traded   off    against consistency of metaphor,
        preservation  of  screen  space,   and  "fast  path"  methods for
        experts.  

             One example  is  the  use  of  "tools"  in  Paint  and  Draw
        programs.   In   such   programs,   an  initial  click is made on
        a   tool   icon,  denoting  the  operation  to  be applied to all
        following   selections.  This is an prefix style of grammar,  and
        stands  in  contrast  to  the usual  method  of selecting subject
        object(s)  first.    Because   of this contrast,  it is sometimes
        called  "moding  the  cursor".   (Try applying the tests above to
        be sure it really is a mode.) 

             In  these   cases,   there   are  two reasons for  accepting
        the   nonstandard    method.     The   first  is  consistency  of
        metaphor.    The  "user  model"  portrayed  in the programs is an
        artist's  work  table, with  tools,  palette,  and  so  on.   The
        cursor  moding  action  is  equivalent   to  picking up a working
        tool.    The  second reason  is speed.   In a Paint program,  the
        "canvas"  is often modified,  and speed  in  creating or changing
        the  bits is  important.   In  more object  oriented applications
        such  as  Desktop  or  RCS,   the  objects  are  more persistent.
        Speed  is  then more essential when adding or changing properties
        of the objects.  

             When  command   styles   are  mixed  in  this  fashion,  you
        must  design  very  carefully  to  avoid  conflicts  or  apparent
        side-effects  in   the   command language.   For example,  in GEM
        Draw  picking   an  action from the Edit menu cancels the current
        cursor   mode    without   warning.     Confusion    from    such
        side-effects   may   cancel   out   the  benefits  of  the  mixed
        grammar.  

             The  subject     of   command   speed    deserves    further
        attention.   While   the   novice  approaching  a  program  needs
        full   feedback,   a  person  who uses it day in and day out will
        learn  the  program,   and  want   faster   ways   to get the job
        done,   even  if   they   are   more arcane.  The gives rise to a
        "layered" style of interface.  

             A layered  interface  is designed so that the visual grammar
        is  obvious,  as  we  have discussed.   However, there are one or
        more  sets of "accelerators" built into the program, which may be
        harder  to  find  but  faster  to  use.  One example is condensed


        


        Professional GEM            Part XIV                           40


        mouse   actions   such   as  the  double-click.    For  instance,
        attempting  to  select  a  block   of text which extends beyond a
        window  is   impossible   using the  basic metaphor.   The novice
        will  simply  do the operation  in pieces.   A  layered interface
        might  put  a less obvious Mark Begin and  Mark End option in the
        menus.    Another  way  is  to take a drag which  extends outside
        the  window  as  a request to begin  scrolling in that direction,
        while extending the current selection.  

             One  of   the  most  common and useful  accelerator  methods
        is   function    keys.     Using    this  approach,   single  key
        equivalents  to  actions  are listed in the menu.   Striking this
        key  when  an  object  is   selected   will  cause  the action to
        occur.    Note that this  is most  useful if some keyboard driven
        method   of    object    selection,  such  as  tabbing,  is  also
        available.   Otherwise,  the  time  switching  from   the  mouse,
        used  to  select  the object,  to the keyboard for command input,
        may well cancel any advantage.  

             Finally,  radical   departures   from  the GEM metaphor  may
        be  useful  when  attempting  to  replicate  the  look of another
        system,  or trying  to  meet severe constraints,  such as display
        space.    One  example   would   be  discarding  the standard GEM
        menus  in   favor   of  "popup"   menus  which appear next to the
        current  mouse  position   in response  to  a click on the second
        button.    This method has  the advantage  of preserving the menu
        space  at  the  top  of  the   screen, and  is potentially faster
        because  the  menu  appears  right  next   to  the  current mouse
        position.    The  drawbacks  are  lack of a  visual cue for naive
        users  trying  to  find  the  commands,   and the need for custom
        coding to build the popups.  


        MMOORREE TTOO CCOOMMEE       

             We have  reached  the  end  of  the  second  sermon on  user
        interface.    In  a future column,  I will look at "higher level"
        topics   relating  to  the  design  of  the   application's  user
        metaphor.     These   include   issues  of  object   orientation,
        direct     manipulation,      and     the     construction     of
        microworlds.     In    the  meantime,   several   of   the   more
        practical  columns   will   present implementions  of  techniques
        such   as  accelarator  keys   and   popup  menus  which  I  have
        discussed this time.  

             THANKS AND  APOLOGIES  to  the following people whose public
        and  published    remarks   have   formed   part   of  the  basis
        of    this  discussion:  Jef Raskin, Bill Buxton, Adele Goldberg,
        James  Foley,  and  Ben Schneidermann.  As always, any errors are
        my own.  




        


        Professional GEM                                               41


                                    PPAARRTT -- XXVV

                             CCooppiinngg wwiitthh GGEEMMDDOOSS     


             While it's  fun  playing with windows and object trees,  one
        of  the   day-to-day  realities  of  working  with  the ST is its
        operating   system,  GEMDOS.   A  successful  application  should
        insulate  the user from  the foibles and occasional calamities of
        the  machine's   file  system.  The GEM environment provides some
        minimal  tools for doing this,  but a good deal of responsibility
        still rests with you, the programmer.  

             This column  (#15  in  the  ST  PRO  GEM  series)  tries  to
        address  the   GEM/DOS  integration problem by providing you some
        stock   code  for  common  functions,  along with a discussion of
        some  of  the  worst  "gotchas"  lurking  for  the  unwary.   The
        download  for this column is GMCL15.C, and it can be found in DL3
        of   PCS-58.   You  should  obtain  and  list  this  file  before
        proceeding.  


        AA BBIITT OOFF HHIISSTTOORRYY..      

             There has  been  a  good  deal  of   confusion in  the Atari
        press  and  among  developers  over  what  GEMDOS is,  and how it
        relates  to  TOS and CP/M-68K.   It's important to clear this up,
        so   you  can  get  a true picture of what GEMDOS is intended  to
        do.   The best way is to tell the story of GEMDOS' origins, which
        I can do, because I was there.  

             As  most  developers  are  aware,  GEM was first implemented
        on  the   IBM   PC.   PC GEM performed two functions.   The first
        was   a  windowed  graphics extension to the PC environment.  The
        second  was  a  visual  shell,  the Desktop,  which ran on top of
        the  existing operating system, PC-DOS.  

             When work  started  on  moving GEM to the ST, there were two
        big  problems.    First,  no STs actually existed.  Second, there
        was  no  operating  system  on  the  68000 with which GEM and the
        Desktop  could  run.    Unix   was   too   large,   and  CP/M-68K
        lacked   a   number   of  capabilities,   such   as  hierarchical
        files,  which were needed to support GEM.  

             Work on  porting  the graphics parts of GEM to the 68000 had
        to  start  immediately  to  meet schedules.   Therefore, CP/M-68K
        running  on   Apple  Lisa's  was  used  to  get  this part of the
        project  off   the  ground.    Naturally,  the  Alcyon C compiler
        and  other  tools  which  were  native  to  this environment were
        used.  




        


        Professional GEM             Part XV                           42



             In  parallel,    an    effort  was  begun  to  write  a  new
        operating  system  for  the 68000,  which would ultimately become
        the  ST's  file  system.   It was designed to be a close clone of
        PC-DOS,   since  it  would   perform   the   same  functions  for
        GEM    in    the    new  environment.  At  this  point,  the term
        TOS  was  introduced.    TOS  really meant "the operating system,
        whatever  it  may  be,  that will run on the ST",  since not even
        the  specifications,   let  alone the code, were complete at that
        time.  

             The  first  engineer  to  work  on "TOS" at Digital Research
        was  Jason   Loveman.    This   name   leaked  to the press,  and
        in   some  distorted   fashion  generated  a  rumor  about "Jason
        DOS",   which  was still  just  the same unfinished project.   As
        "TOS"   became   more  solid,  the  developer's tools were ported
        to  the  new   environment  one  by  one, and the GEM programming
        moved  with  them.   CP/M-68K  was completely  abandoned,  though
        the  old manuals for C and the tools lived on and are still found
        in the Atari developer's kit.  

             All of  this  work  had  been  done  on  Lisas  or  Compupro
        systems  fitted  with 68000 boards.   At this point,  workable ST
        prototypes  became   available.    An   implementation   of "TOS"
        for   the   target  machine   was   begun,  even before the basic
        operating  system  was fully completed.  

             The  other   intent  for the new operating system was to  be
        a  base  for  GEM  on  other  68000  systems  as  well as the ST.
        Because  of  this,  Digital  Research  named  it  GEMDOS when  it
        was    finally   complete,   thus  providing  the  final  bit  of
        nomenclature.   "TOS"  as  now   found   in  the  ST is in fact a
        particular   implementation   of generic GEMDOS, including the ST
        specific BIOS.  

             So,  GEMDOS  is a PC-DOS clone,  but,  not quite.  There are
        enough    differences    to    cause   problems   if   they   are
        ignored.   (Remember,   it  looks  like a duck, and quacks like a
        duck, but it's not a duck.) 


        GGOOIINNGG FFOORR IITT..       

             As a  first example,  consider the  routines openfile()  and
        createfile()  at  the beginning of  the  download.  They make use
        of  the GEMDOS calls Fopen() and Fcreate().  You will notice that
        these  names  are not the ones specified in the  Digital Research
        GEMDOS   manual.    Developers  who  have used PC  GEM  will also
        observe  that  they  are  radically  different from the  function
        names in the PC-DOS bindings.  




        


        Professional GEM             Part XV                           43



             In  fact,   all   of   the  GEMDOS function calls on the  ST
        are  defined   as   macros   in  the  file osbind.h,  distributed
        with   the  developer's   kit.    At compile time they are turned
        into  calls   to the  assembly  language  routine gemdos(),  part
        of    the    osbind.o   binary.   So,  if  you  find  the  naming
        conventions  to  be  particularly  offensive   for   some reason,
        just edit the appropriate macros  in osbind.h.  

             In  DRI's  PC-DOS  bindings,   any error codes were returned
        in  the   global  variable  DOSERR.    In  the  GEMDOS  bindings,
        the  operation  result  or an error code is returned as the value
        of   the  calling   function.    In   the   case  of  Fopen() and
        Fcreate(),   the  result   is   a   valid  file  handle  if it is
        positive.    A   negative  result   is   always  an  error  code,
        indicating that  the  operation failed.  

             An application   which  encounters  a  GEMDOS  error  should
        display  an   alert,   and   query   for   retry  or abort.   The
        type    of   loop  structure   exemplified   by  openfile()   and
        createfile()   should be  usable with most GEMDOS functions which
        might   fail.    The   AES  provides   a   function,   formerror,
        which   implements   a  set  of "canned" error alerts appropriate
        to the various possible errors.  

             However,  this   is  where  the  fun  starts.   For  unknown
        reasons,  the  formerror  on  the  ST expects to see PC-DOS,  not
        GEMDOS,  error codes as it's input!  Therefore you need a routine
        to  translate one into the other.   The routine doserror() in the
        download  provides  this   function.    The  GEMDOS errors are in
        the  same  sequence  as those  for  PC-DOS,  but  their numerical
        order    is    reversed    and   shifted.    Notice   also   that
        doserror()  does  NOT  perform  the translation if the error code
        is  less  than  -50.    These  codes have no  PC-DOS  equivalent;
        computing  a  bogus  translation  will  cause formerror to crash.
        Instead,   they  are  passed  through  verbatim,  resulting  in a
        "generic" alert which gives only the error number.  

             The  other  major  task  in  integrating  a GEM  application
        with  the   file   system is selecting file names for  input  and
        output.   Again,   the  AES  provides  some  assistance  with the
        fselinput   call,   which  invokes  the  standard  file  selector
        dialog.  

             There  are   several   drawbacks   to   the  standard   file
        selector.   One   is  that  the "ITEM SELECTOR" title is constant
        and   cannot   be changed  by the application.   This could cause
        confusion   for  the   user,   since it may not be clear which of
        several   functions,  closely  spaced  in  the  FILE  menu,   was
        actually  invoked.    While  it  might  be  possible  to find and
        "rewire"  the   AES   resource   that defines  the file selector,
        it  is  unlikely  that  such  an  approach would be portable to a


        


        Professional GEM             Part XV                           44


        later version of ST GEM.  

             A  viable  approach  to eliminating confusion is to  display
        a  small "marquee" box, with a message defining the operation, on
        the  screen   just   above   the   file  selector.  To  do  this,
        you   must  initialize   the  location  of  the box so that it is
        outside   of   the file selector's bounds,  and then draw it just
        before  invoking  the  file   selector.    This   way   they will
        appear   together.    Before  returning   to its main event loop,
        the  application should post  a redraw  message for the "marquee"
        area.    The  AES will merge  this redraw  with the one generated
        by   fselinput,    and   the  result  will  be  received  by  the
        application's evntmulti.  

             Another problem  with  the  file  selector is that it resets
        your  application's  virtual  workstation  clip rectangle without
        warning.   There   are  other  AES  functions,  such as objcdraw,
        which  also  do  this,  but  the file selector can be troublesome
        because  it  may  be  the only AES call used by some VDI-based ST
        applications.  

             The veteran   developer  will  also  notice  that  the  file
        selector  takes   and  returns  the  path  and  filename  as  two
        separate   strings,  while  the  GEMDOS  file functions require a
        fully  pathed  file   name.   Also,  the  file  selector  doesn't
        remember   its   "home"   directory;   you  are  responsible  for
        determining  the  default  directory,  and  keeping  track of any
        changes.   The  remainder  of  the download and column is devoted
        to   set of utilities which should alleviate some  of  the "grunt
        work" of these chores.  

             The  top  level  routine  in  this  collection is getfile().
        It  is   called with two string arguments.   The first must point
        to   a  four   byte  string area containing the desired file name
        extension  (three   characters  plus a null).   The second is the
        default  file name.  

             If the   default  file  name  is  non-null,  then  getfile()
        invokes   parsefname()   to   break   it   into  path  and  name.
        Parsefname()   also   adds    the   necessary  "wild  card"  file
        specification  to   the   path,  using  the  extent name given as
        input.  

             If  no   default   file  was  supplied,  or the default  did
        not  contain   a   path,   the  routine  getpath()  is invoked to
        find   the  current  default directory and construct a legal path
        string  for it.  

             The   results    of   these   manipulations   are   supplied
        to   fselinput.     Notice    that   the   result  of  the   file
        selector   is  returned via its third argument,  rather than as a
        function  value.   If   the result is TRUE,  getfile() merges the


        


        Professional GEM             Part XV                           45


        temporary  path   and  file   string,  storing the result via the
        second  input   parameter.   This  result  string is suitable for
        use  with Fopen,  and  may  be resubmitted  to getfile() when the
        next operation is  invoked  by the user.  

             Parsefname() is   straight-forward  C.   It  looks  backward
        along  the   file  to  find  the first character which is part of
        the   path.   The  tail  of  the  filename is copied off, and its
        former location is overlaid with the wild card specification.  

             Getpath()  is  a  bit  more  interesting.    It makes use of
        two  GEMDOS   functions,   Dgetdrv() and Dgetpath() to obtain the
        default  disk  drive  and  directory,  respectively.   Note  that
        Dgetpath()  will  return  a null string if the current default is
        the  root,   but   it  puts  a back-slash at the beginning of the
        path   otherwise.    This  forces   a  check for insertion in the
        root  case,   since  the  file selector  wants  to  see something
        like   "A:\*.RSC",  rather  than "A:*.RSC".   After  making  this
        fix,   getpath() concatenates the wild card specification derived
        from the input extent.  

             The last   routine  in  the  download  is  newext().    This
        utility  is   useful  if  your  application  uses  more  than one
        associated    file  at  a  time.    For  instance,  the  Resource
        Construction  Set  uses both an RSC and a DEF file, with the same
        base  name.   Newext()  takes  a  fully   formed  file name,  and
        replaces  its  old  extent  with  the  new one  which you supply.
        This  lets  you  quickly generate both  file names after one call
        to  the  file  selector.    Notice  that  newext() looks BACKWARD
        along  the  name  to  find  the  delimiting  period,  since  this
        character   can  also  be  part  of a subdirectory  name  in  the
        path.  

             So  we   reach   the  end  of  the  code  and  this  column.
        Hopefully  both  will  keep  you profitably occupied for a while.
        July's  column  will  return  to graphics topics,  with a look at
        writing  customized  rubber  box and drag box routines,  and ways
        to  implement  your  own  "pop-up"   menus.   August  will  bring
        techniques   for   displaying  progress  indicators,  associating
        dialog  and  menu   entries   with  keystrokes,  and  customizing
        objcedit.  


        II CCAANN''TT HHEEAARR YYOOUU!!      

             The Feedback  mailbag  has  been   noticably flat  of  late.
        There  have  been a number of compliments  on  the column,  which
        are   much  appreciated,  and some suggestions  for topics  which
        fall  outside  the bounds of this series.   The latter have  been
        passed  on  to  Antic  for  possible  inclusion  in their  new ST
        quarterly, START.  



        


        Professional GEM             Part XV                           46



             One recurring  problem  is finding the downloads.   A number
        of  the   earlier  columns  say  they  are  in  PCS-132  (the old
        SIG*ATARI),  and  one says PCS-57 (mea culpa).   In fact,  ALL of
        the  downloads  are  now  in DL3 of PCS-58 (ATARI16).   Filenames
        for   first   nine columns  are  all in the form GEMCLx.C,  where
        x  is   the   column's  digit.    For reasons unknown to me,  the
        next  two  files were named GEMC10.C  and  GEMC11.C;  the  latest
        two   downloads   are  called GMCL13.C and GMCL15.C.   The latter
        naming pattern should continue into the future.  

             Undoubtedly,  one  reason  for  the shortage of questions is
        the  amazing  ability  to  get  a quick answer on the Developer's
        SIG,  PCS-  57.    This   is  a  good  sign  of  a  strong  Atari
        community   on  Compuserve.    However,   the   SIG message style
        doesn't   really   lend   itself   to  lengthy  explanation,   so
        suggestions for longer  topics are always welcome here.  

             Finally,  I   am  now  beginning  the  process of collecting
        these  columns  and  some  additional  material  into a book.  In
        doing  so,  it  would   be   helpful to know if you feel that any
        part  of   GEM   has  been  slighted  in my discussions.   If so,
        let   me   know.   Your suggestions will appear in future columns
        and finally make their way into the book.  






























        


        Professional GEM                                               47


                                   PPAARRTT -- XXVVII

                           IInntteerrffaaccee PPoottppoouurrrrii ##11     


             This issue  of  ST  PRO  GEM,   number  16  in  the  series,
        presents    code     implementing     several   user    interface
        techniques:   progress  indicators,  rubber  boxes, and draggable
        boxes  with  mouse sensitive targets.   The  code  also  includes
        some   utility   routines   for  handling resources, event calls,
        and VDI line drawing.  

             The  downloads   for  this  column  are available on DL3  of
        the  ATARI16  SIG:  PCS-58.  Note the plural - in addition to the
        usual  C  sources   stored   in GMCL16.C,  the files  GMCL16.RSC,
        GMCL16.DFN,  GMCL16.H,   and  GMCL16.RSH  are a template resource
        for   building  progress  boxes.    GMCL16.RSC  is  the  resource
        binary,   and  GMCL16.H is  its  symbol binding file,  to be used
        with  GMCL16.C.    The  RSH file  is  a C image of the resource -
        you would need  STCREATE  to regenerate it.  

             GMCL16.DFN is  the  binary symbol file for the resource.  It
        is  in   the  format  used  by  the  NEW ST Resource Construction
        Set.    If  you  are  a  developer,  you should download this new
        version  from DL7 of PCS-57.   It fixes a number of bugs, and has
        a much faster user interface.  


        MMAAKKIINNGG PPRROOGGRREESSSS..        

             The need   for  feedback  in  interface  designs  has   been
        discussed  in  previous  columns.    One instance which  is often
        necessary  is  the  so-called  progress  indicator.    A progress
        indicator   is  used  when  your  application  is  doing  a  long
        operation.    It    shows   that   the   function  is  continuing
        satisfactorily,   and   is not hung in a loop.  When possible, it
        also  gives  an  indication  of  the  fraction  of  the operation
        which  has   been   completed.    The  thermometer   bars  on the
        Desktop format and copy  operations  are examples.  

             The sample  code  shows  two  types  of  progress indicator.
        Both  are   built  within  the  structure  of  a dialog resource.
        The   first  type  uses  a variable line of text to describe each
        phase   of  an operation as it occurs.  The rewriting of the text
        provides  action on  the  screen;  the  fact that it is different
        each   time   gives  reassurance   that  the program is not hung.
        The  second   type   of indicator  is the thermometer bar.   This
        is  more  useful when  the operation  is  uniform,  allowing  you
        to  estimate  the  fraction completed.  Let's look at the code.  

             The routines  begprog() and endprog() are common to the  two
        types.    The   code  is  very  similar  to  the  standard dialog


        


        Professional GEM            Part XVI                           48


        handling  procedure,   but  is  broken into two parts.  Begprog()
        assumes  that  the   progress   indicator   box  is  defined by a
        dialog   tree   named  PROGRESS.    Such   a  tree is provided in
        GMCL16.RSC.    Begprog()  makes   the  usual  calls to center and
        draw   the   box.    The  rectangle  computed  in  the  centering
        operation  is  stored  via  a  GRECT   pointer  passed   in   the
        parameter.     This   rectangle  compensates   for   the  outline
        around  the  box,   and  must  be supplied to endprog()  when the
        operation is complete.  

             The  first   version   of   setprog()   in   the    download
        implements  the  changing text progress indicator.  It looks in a
        tree  labelled STRINGS for the object number which is passed as a
        parameter.    It  is  assumed that this object is a GSTRING.  The
        address  of  the  new  text   is  loaded from the object's obspec
        field.    (For  those  with  the   new  RCS,  it would be easy to
        alter  this  routine  to  use   free strings.  Simply replace the
        first two lines with: 

                       rsrcgaddr(RSTRING, strno, &saddr);

        and   supply  parameters  which  are  the  names of strings in  a
        FRSTR box.) 

             Once the  new  text  is  found,   the  settext()  utility is
        called  to   update  the TEDINFO attached to object PLINE in  the
        PROGRESS  tree.    Settext()  will insert the new text address in
        teptext,  and  the  new  text  length in tetxtlen.   Dispobj() is
        then used to redraw only the rectangle belonging to PLINE.  

             PLINE  must   be  defined  as  a  GBOXTEXT  object   with  a
        solid  white   background,   and with the CENTERED attribute set.
        It   must   extend   entirely  across  the  progress  box.   This
        guarantees  that  the previous  text  will  be covered over,  and
        the new text  will  be centered in the box.  

             The  second    version    of    setprog()   implements   the
        thermometer  bar  progress  indicator.   The  PROGRESS  tree also
        includes  an  object  PROBOX   which   defines the outline of the
        thermometer.    It   is   a  GBOX   object   with  a  solid white
        background,   and   a   one-outside border.   The  object  PROBAR
        is  nested  inside  it,  with the  left edges  matching.   PROBAR
        is   also   a  GBOX,   with   a   solid   red  background   and a
        one-outside  border  as well.   Setprog() creates the thermometer
        effect by growing and redrawing PROBAR.  

             Setprog()  requires  two  parameters.    Maxc is an estimate
        of  the  total  duration  of  the  operation, in arbitrary units.
        Value  is  the  (new)  amount  completed,   in  the  same  units.
        Setprog  performs  two  operations.    First,   it  computes  the
        fraction  value/maxc,  and  sets  PROBAR  to that fraction of the
        width  of  PROBOX.    Second,  it computes the rectangle which is


        


        Professional GEM            Part XVI                           49


        the  difference  between  the old and new  widths of PROBAR,  and
        redraws  only  that  part  of  the progress box.   This  prevents
        an   annoying  flash  on  the  screen   when   the  indicator  is
        updated.  

             These two  types  of progress indicators have been presented
        in  separate  routines  for convenience in explanation.   You can
        easily  combine   them   in  a  single  procedure  to  create  an
        indicator  with both effects.  

             The  final    progress    indicator   routine   is    called
        escprog().   During   many  lengthy  operations  is  desirable to
        provide   an   abort option  to the user.   Escprog() lets you do
        this  by  polling   the keyboard  for  an escape (ESC) character.
        A  zero timer value  is used  to guarantee an immediate return if
        no  character   is   found.   Characters  other  than  escape are
        ignored.  

             Escprog()  returns  TRUE  if  an  abort  is  requested,  and
        FALSE  if   the  operation is to continue.   In your application,
        you  can  either   pair   calls   to   setprog()  and  escprog(),
        or   recode  setprog()   to  automatically  make the abort check.
        In  any   case,  you   should  add  an  information  line  to the
        progress   box,   telling  the  user  how  the  operation  may be
        halted.  

             Of  course,   this  type  of  progress  indicator is not the
        only  option  available on the ST.   Other ideas such as changing
        window  titles,   or  displaying  a succession of differing icons
        are  equally  valid.    Sometimes  the nature of your application
        may  suggest   an alternate metaphor.  For instance, the progress
        of  recalculating  a  spreadsheet might be indicated by darkening
        successive  columns   in  a   miniature   image   of  the  sheet.
        Occasionally,   the   computing  operation   is   visual  itself,
        and  will  not require  an  explicit indicator.   An  example  is
        redisplaying  objects  in  a  2D  or 3D drawing program.  


        BBOOXXEEDD IINN..        

             The  second  part  of the download implements  two types  of
        user   interaction  using  the  mouse.    The  first  creates   a
        "rubber   box"   on   the  screen,  that  is,  a box  whose  size
        is  controlled   by   moving   the  mouse.    This is similar  to
        the   AES grafrubberbox  call,  but allows the box to move in any
        direction  from   its origin,  while the GEM function only allows
        movement  to the lower right.  

             The second  technique allows the user to drag the outline of
        a  box  around  the  screen  using  the  mouse.    Again, this is
        similar  to  the  AES  grafdragbox  call,  but  this  version  is
        augmented  with code which "hotspots" selectable objects when the


        


        Professional GEM            Part XVI                           50


        mouse  and  object  pass over  them.   These routines are another
        illustration  of  the  usage of  the evntmulti function,  and its
        combination   with   VDI   drawing   to  create  new  interaction
        techniques.  

             The  "rubber    box"  subroutine  is  called   fourwaybox().
        Its   parameters  are  the  current  VDI  handle  (NOT  a  window
        handle!),   and two  GRECT  pointers.   The first GRECT must have
        its  gx  and   gy initialized  with the fixed point of the rubber
        box.    The   second  GRECT  contains  an outer bound box for the
        stretching action.  

             Fourwaybox()  begins   by  setting  the  VDI   drawing  mode
        and    color.     The    exclusive    or,    black    combination
        guarantees   that  redrawing  a figure twice in the same location
        will  exactly   erase  it.   Next,  the routine asserts the mouse
        control  flag.   This stops the  window manager from tracking the
        mouse,   with the effect that menus will not drop down during the
        operation.  

             The  fixed  coordinates  are  saved  in the variables ox and
        oy,   and    an   initial   mouse   reading   is   obtained  with
        grafmkstate.   At this point, the event loop is entered.  

             At each  iteration,   the  loop finds the upper left most of
        the   fixed   vertex   and   the  current  mouse  position,   and
        updates   the tracking GRECT accordingly.   A call to the utility
        rcintersect()  is   used   to   restrict  the  size of the rubber
        box   to  the  given limiting  rectangle.   Note that if you need
        a  lower limit to  the size of the rubber box, it can be achieved
        by  adding  another  GRECT pointer "lower" to the parameter list,
        and using the call 

                             rcunion(lower, rubber);

        This   works  because  the  union operation selects the larger of
        two rectangles if they are nested.  

             Rubwait()  will   be   described   in  detail  below.    Its
        returns  are  the  new  mouse  position, and an indication of the
        current  mouse button  state.   If  the button remains down,  the
        loop  continues.   When  the  button is released,  the rubber box
        terminates,    since   it   is     a     "spring-loaded"    modal
        operation.       Before    ending,  fourwaybox()   returns  mouse
        control  to  the  window  manager.   The return  from the routine
        is  found  in  the  rubber GRECT,  and is the final extent of the
        box.  

             Rubwait()  is   a  utility  used  by  both  box  techniques.
        Its  purpose   is  to do one step of the box animation,  and wait
        for   a  mouse   movement,    or   the  release  of  the  button.
        Rubwait() preserves the state of the screen.  


        


        Professional GEM            Part XVI                           51



             The  first  action  is  to  draw  an exclusive or'ed  dotted
        line   box  at  the  given  rectangle.    Next,  rubwait()  calls
        evntmulti  to wait for the mouse button to come up,  or the mouse
        to  move  out  of  a  one  pixel  rectangle.    When the event is
        detected,  the  same  code is  used  to remove the box.   A value
        of  TRUE  is  returned  if  the mouse  button is still down;  the
        curious  logical  construction   is  necessary  since BOTH events
        could occur at once.  

             A  short   examination   of  the  vdixbox()  code  is   also
        useful.   After  converting the rectangle to polyline format, the
        vdixline()  routine   is  called.   Vdixline draws a dotted line,
        but  does  not use the VDI line style attribute.  This is avoided
        because  the  VDI  has   problems with corner points when drawing
        styled  lines  in   XOR  mode.    Instead,  a  selection  is made
        from  a  set  of  user  defined  line   styles,   based   on  the
        direction  of the  stroke,  and  the odd/evenness of the starting
        horizontal  pixel.   This assures that the figure will be exactly
        erasable.  


        HHOOTT SSTTUUFFFF??        

             The drag  box  routine  is  more  subtle,  because  care  is
        needed   to   correctly  synchronize the movement  of  the  mouse
        cursor  and  the  box,   and  the highlighting of target objects.
        The   parameters   vdihandle   and   limit   are   identical   to
        those    in  fourwaybox().   The GRECT pointed to by box contains
        the  width  and  height  of  the movable box when hotdragbox() is
        entered.     On   exit   it    also    contains   the   last  x,y
        coordinates   of   the   box.   The variable tree is a pointer to
        the  root  of  a resource tree defining the  hot  spots  for  the
        drag    operation.     Only    objects   tagged  SELECTABLE   are
        hotspotted.    Hotdragbox()  returns  the  number   of  such   an
        object  if  the  box  is  "dropped"  on  it,   otherwise a NIL is
        returned.  

             Initialization  proceeds      as    above,     until     the
        grafmkstate  call.   Here  is the first potential synchronization
        problem.    If  the   user  moves  the  mouse  very quickly after
        initiating  the   drag,  it may already be outside the box by the
        time  grafmkstate  samples the position.   The min/max operations
        given  lock  the  box  onto  the  cursor,  no matter where it has
        strayed.   The mouse/box offsets, ox and oy, will remain constant
        for the rest of the operation.  

             Hoverobj  will   contain  the  number  of the  object  which
        is   currently    highlighted.     It   is  initialized  to  NIL,
        indicating  no  object  is  currently  marked.   Hotdragbox() now
        enters  a  loop  with  termination  conditions  identical  to the
        rubber box.  


        


        Professional GEM            Part XVI                           52



             The  current   desired   position  of the  box  is  computed
        by  subtracting  the  box/mouse  offset  from  the  current mouse
        position.   The   rcconstrain()  call  ensures  that the box will
        not   leave   the  bounding  rectangle.    Note  that rcintersect
        would  not  work  here  -  it   would   alter   the  size of  the
        draggable    box,   rather   than  "nudging"  it  back  into  the
        bounds.  

             Upon  return  from  rubwait(),   a number of conditions must
        be  checked   to  determine the correct object to  highlight,  if
        any.   First,   we   must   make  sure that the mouse is actually
        within   the  legal  bounds.   If not,  there may be an ambiguous
        selection,  with  the  mouse  over  one  object  and the box over
        another.    We  choose  to  do  nothing  in  this  case,  and set
        hoverobj  to NIL.   If the mouse is in bounds, objcfind looks for
        a  target object.  If one exists, it must be SELECTABLE, or it is
        forced to NIL.  

         Next  the  new  object,   stored  in retobj,  is compared to the
        old  highlighted  object,   in hoverobj.   If they are different,
        a  switch   must   be   made.    Since  either  could  be NIL,  a
        check   is  necessary before calling objtoggle to invert/reinvert
        the    screen  image   of   the   object.    When   the  loop  is
        complete,   the   final  hoverobj  is  returned  to  normal state
        before  its  number  is returned.  

             You  may  notice  that  this method of highlighting  objects
        is  different  from  the  incremental tree descent and rectangles
        method  presented   in  column 13.   While not as efficient,  the
        objcfind  technique   is  simpler to code and may be adequate for
        many   uses.   If   your  program will make heavy use of the drag
        box    routine,    or   will   have   large   trees   of   target
        objects,   you   may   wish   to  integrate    the    incremental
        hotspotting     algorithm     with  hotdragbox().   This would be
        simple  to  do; just use evntmulti's second  mouse  rectangle for
        the  states  associated  with   the   hot- spotter.   The  single
        pixel  rectangles would have to remain,  in order to maintain the
        animation effects.  


        AA FFEEWW CCHHAANNGGEESS..       

             The  observant  may  have  noticed  that  the promised  code
        for  popup  menus  did  not make it into  this  column.  Instead,
        it   will   appear  in  column  18  along  with  more   "graphics
        potpourri"     and     feedback    replies.     The   intervening
        installment,  number   17,   will   present   and   document  the
        source    code    for    a   complete    IBM/Atari  GEM  Resource
        conversion  program.    This  will appear  concurrently with Mark
        Skapinker's  article  on  IBM/ST  GEM conversions  in  the second
        issue  of  START.   While  this  program will be of direct use to


        


        Professional GEM            Part XVI                           53


        only  a  minority of ST developers, it will contain  utility code
        useful  to all,  as well as demonstrations of dialog handling and
        the internal structure of resources.  

             Finally,  you    may   also   notice   that   the  so-called
        portability  macros have disappeared from the download.   Indeed,
        they  are  gone  for  good.   Since the beginning of this column,
        the  growth  of  the  ST  GEM developer community has outstripped
        that   on   the  PC.    It  no  longer   seems   appropriate   to
        inconvenience   ST   developers   and  violate  standard C syntax
        for  the  sake  of Intel's  design  flaws.  Those  who still need
        compatibility  with  the  PC  may  achieve it  by compiling under
        Intel  large  model,   or  by  writing "sed" scripts to translate
        (tree+obj)->obspec    and    the    like    to    their     macro
        equivalents.  







































        


        Professional GEM           Appendix IX                         54


                                  AAppppeennddiixx -- IIXX
                             SSaammppllee CCooddee ffoorr PPaarrtt XXII



        /* >>>>>>>>>>>>>> Sample code for initializing User Objects <<<<<<<<<<<<<<<< */

        GLOBAL  USERBLK extobjs[MAXOBJS];       /* APPLBLK defined in OBDEFS.H  */
        GLOBAL  WORD    nextobjs;               /* Set MAXOBJS to total user   */
                                                /* objects in resource          */

        VOID
        objinit()                               /* Scan whole resource for user   */
        {                                       /* objects.  Uses maptree()      */
                LONG    tree, obspec;           /* from GEMCL5.C                  */
                WORD    itree, i, obj;

                nextobjs = 0;                   /* Replace TREE0 with your first  */
                /* tree, TREEN with the last      */
                for (itree = TREE0; itree <= TREEN; itree++)
                {
                        rsrcgaddr(RTREE, itree, &tree);
                        maptree(tree, ROOT, NIL, fixobj);
                }
        }

        WORD
        fixobj(tree, obj)                       /* Code to check and fix up     */
        LONG    tree;                   /* a user defined object        */
        WORD    obj;
        {
                WORD    hibyte;

                hibyte = LWGET(OBTYPE(obj)) & 0xff00;           /* check extended */
                if (!hibyte)                                    /* type - if none */
                    return (TRUE);                              /* ignore object  */
                extobjs[nextobjs].ubcode = drcode;              /* set drawcode   */
                extobjs[nextobjs].ubparm = LLGET(OBSPEC(obj)); /* copy obspec  */
                LLSET(OBSPEC(obj), ADDR(&extobjs[nextobjs]));   /* point obspec */
                LWSET(OBTYPE(obj), GUSERDEF | hibyte);  /* to userblk &   */
                nextobjs++;                                     /* patch type     */
                return (TRUE);
        }











        


        Professional GEM           Appendix IX                         55


        /* >>>>>>>>>>>>>>>>>>>> Sample User Object Drawing Code <<<<<<<<<<<<<<<<<<<< */
        /* >>>>>>>>>>>>>>>>>>>> Implements Rounded Box based    <<<<<<<<<<<<<<<<<<<< */
        /* >>>>>>>>>>>>>>>>>>>> on GBOX type                    <<<<<<<<<<<<<<<<<<<< */

        WORD
        drcode(pb)                              /* Sample user object drawing   */
        PARMBLK *pb;                            /* code.  Caution: NOT portable */
        {                                       /* to Intel small data models   */
                LONG    tree, obspec;
                WORD    slct, flip, type, exttype, flags;
                WORD    pxy[4];
                WORD    bgc, interior, style, bdc, width, chc;

                tree = pb->pbtree;
                obspec = LLGET(pb->pbparm);     /* original obspec from USERBLK  */
                exttype = LHIBT(LWGET(OBTYPE(pb->pbobj)));
                slct = SELECTED & pb->pbcurrstate;
                flip = SELECTED & (pb->pbcurrstate ^ pb->pbprevstate);
                setclip(TRUE, &pb->pbxc);       /* These two routines in GEMCL9.C */
                grecttoarray(&pb->pbx, pxy);    

                switch (exttype) {
                    case 1:                     /* Rounded box       */
                        /* Crack color word  */
                        getcolrwd(obspec, &bgc, &style, &interior,
                                   &bdc, &width, &chc);
                        /* For select effect, use char color */
                        if (slct)       /* In place of background            */
                            bgc = chc;
                        /* Fill in background                */
                        rrfill(MDREPLACE, (width? 0: 1), bgc, interior, 
                                style, pxy);
                        /* Do perimeter if needed            */
                        /* rrperim is in GEMCL9.C            */
                        if (width && !flip)
                        {
                                pxy[0] -= width; pxy[2] += width; 
                                rrperim(MDREPLACE, bdc, FISSOLID, width, pxy);
                        }
                        break;
                    default:            /* Add more types here              */
                        break;
                }
                return (0);
        }

        VOID                            /* Cracks the obspec color word    */
        getcolrwd(obspec, bgc, style, interior, bdc, width, chc)
        LONG    obspec;
        WORD    *bgc, *style, *interior, *bdc, *width, *chc, *chmode;
        {
                WORD    colorwd;


        


        Professional GEM           Appendix IX                         56



                colorwd = LLOWD(obspec);
                *bgc = colorwd & 0xf;
                *style = (colorwd & 0x70) >> 4;
                if ( !(*style) )
                    *interior = 0;
                else if (*style == 7)
                    *interior = 1;
                else if (colorwd & 0x80)        /* HACK: Uses character writing mode */
                    *interior = 3;              /* bit to select alternate interior  */
                else                            /* styles!                           */
                    *interior = 2;
                *bdc = (colorwd & 0xf000) >> 12;

                *width = LHIWD(obspec) & 0xff;
                if (*width > 127)
                    *width = 256 - *width;

                if (*width && !(*width & 0x1))          /* VDI only renders odd */
                    (*width)--;                         /* widths!              */

                *chc = (colorwd & 0x0f00) >> 8;         /* used for select effect */
        }

        VOID                            /* Fill a rounded rectangle     */
        rrfill(mode, perim, color, interior, style, pxy)
        WORD    mode, perim, color, style, interior, *pxy;
        {
                vswrmode(vdihandle, mode);
                vsfcolor(vdihandle, color);
                vsfstyle(vdihandle, style);
                vsfinterior(vdihandle, interior);
                vsfperimeter(vdihandle, perim);
                vrfbox(vdihandle, pxy);
        }



















        


        Professional GEM           Appendix X                          57


                                  AAppppeennddiixx -- XX
                            SSaammppllee CCooddee ffoorr PPaarrtt XXIIIIII



        #include "portab.h"                             /* portable coding conv */
        #include "machine.h"                            /* machine depndnt conv */
        #include "obdefs.h"                             /* object definitions   */
        #include "gembind.h"                            /* gem binding structs  */
        #include "taddr.h"

        #define M1ENTER 0x0000
        #define M1EXIT          0x0001

        #define BS      0x0008
        #define TAB     0x0009
        #define CR      0x000D
        #define ESC     0x001B
        #define BTAB    0x0f00
        #define UP      0x4800
        #define DOWN    0x5000
        #define DEL     0x5300
                                                /* Global variables used by */
                                                /* 'mapped' functions       */
        MLOCAL  GRECT   brrect;         /* Current break rectangle  */
        MLOCAL  WORD    brmx, brmy, brtogl;     /* Break mouse posn & flag  */ 
        MLOCAL  WORD    fnobj;                  /* Found tabable object     */
        MLOCAL  WORD    fnlast;         /* Object tabbing from      */
        MLOCAL  WORD    fnprev;         /* Last EDITABLE obj seen   */
        MLOCAL  WORD    fndir;                  /* 1 = TAB, 0 = BACKTAB     */

        /************* Utility routines for new forms manager ***************/

                VOID
        objctoggle(tree, obj)                   /* Reverse the SELECT state */
                LONG    tree;                   /* of an object, and redraw */
                WORD    obj;                    /* it immediately.          */
                {
                WORD    state, newstate;
                GRECT   root, obrect;

                objcxywh(tree, ROOT, &root);
                state = LWGET(OBSTATE(obj));
                newstate = state ^ SELECTED;
                objcchange(tree, obj, 0, root.gx, root.gy, 
                        root.gw, root.gh, newstate, 1);
                }







        


        Professional GEM           Appendix X                          58


        VOID                                    /* If the object is not already */
        objcsel(tree, obj)                      /* SELECTED, make it so.        */
                LONG    tree;
                WORD    obj;
                {
                if ( !(LWGET(OBSTATE(obj)) & SELECTED) )
                        objctoggle(tree, obj);
                }

                VOID                            /* If the object is SELECTED,   */
        objcdsel(tree, obj)                     /* deselect it.                 */
                LONG    tree;
                WORD    obj;
                {
                if (LWGET(OBSTATE(obj)) & SELECTED)
                        objctoggle(tree, obj);
                }

                VOID                            /* Return the object's GRECT    */
        objcxywh(tree, obj, p)                  /* through 'p'                  */
                LONG    tree;
                WORD    obj;
                GRECT   *p;
                {
                objcoffset(tree, obj, &p->gx, &p->gy);
                p->gw = LWGET(OBWIDTH(obj));
                p->gh = LWGET(OBHEIGHT(obj));
                }


























        


        Professional GEM           Appendix X                          59


                VOID                            /* Non-cursive traverse of an   */
        maptree(tree, this, last, routine)      /* object tree.  This routine   */
                LONG            tree;           /* is described in PRO GEM #5.  */
                WORD            this, last;
                WORD            (*routine)();
                {
                WORD            tmp1;

                tmp1 = this;            /* Initialize to impossible value: */
                                        /* TAIL won't point to self!       */
                                        /* Look until final node, or off   */
                                        /* the end of tree                 */ 
                while (this != last && this != NIL)
                                        /* Did we 'pop' into this node     */
                                        /* for the second time?            */
                        if (LWGET(OBTAIL(this)) != tmp1)
                                {
                                tmp1 = this;    /* This is a new node       */
                                this = NIL;
                                                /* Apply operation, testing  */
                                                /* for rejection of sub-tree */
                                if ((*routine)(tree, tmp1))
                                        this = LWGET(OBHEAD(tmp1));
                                                /* Subtree path not taken,   */
                                                /* so traverse right         */ 
                                if (this == NIL)
                                        this = LWGET(OBNEXT(tmp1));
                                }
                        else                    /* Revisiting parent:        */
                                                /* No operation, move right  */
                                {
                                tmp1 = this;
                                this = LWGET(OBNEXT(tmp1));
                                }
                }



















        


        Professional GEM           Appendix X                          60


                WORD                            /* Find the parent object of    */
        getparent(tree, obj)                    /* by traversing right until    */
                LONG            tree;           /* we find nodes whose NEXT     */
                WORD            obj;            /* and TAIL links point to      */
                {                               /* each other.                  */
                WORD            pobj;

                if (obj == NIL)
                        return (NIL);
                pobj = LWGET(OBNEXT(obj));
                if (pobj != NIL)
                {
                  while( LWGET(OBTAIL(pobj)) != obj ) 
                  {
                    obj = pobj;
                    pobj = LWGET(OBNEXT(obj));
                  }
                }
                return(pobj);
                } 

                WORD
        inside(x, y, pt)                /* determine if x,y is in rectangle     */
                WORD            x, y;
                GRECT           *pt;
                {
                if ( (x >= pt->gx) && (y >= pt->gy) &&
                    (x < pt->gx + pt->gw) && (y < pt->gy + pt->gh) )
                        return(TRUE);
                else
                        return(FALSE);
                } 

                WORD
        rcintersect(p1, p2)             /* compute intersection of two GRECTs   */
                GRECT           *p1, *p2;
                {
                WORD            tx, ty, tw, th;

                tw = min(p2->gx + p2->gw, p1->gx + p1->gw);
                th = min(p2->gy + p2->gh, p1->gy + p1->gh);
                tx = max(p2->gx, p1->gx);
                ty = max(p2->gy, p1->gy);
                p2->gx = tx;
                p2->gy = ty;
                p2->gw = tw - tx;
                p2->gh = th - ty;
                return( (tw > tx) && (th > ty) );
                }





        


        Professional GEM           Appendix X                          61


                VOID
        rccopy(psbox, pdbox)            /* copy source to destination rectangle */
                GRECT   *psbox;
                GRECT   *pdbox;
                {
                pdbox->gx = psbox->gx;
                pdbox->gy = psbox->gy;
                pdbox->gw = psbox->gw;
                pdbox->gh = psbox->gh;
                }

        /************* "Hot-spot" manager and subroutines  ***************/

                WORD
        breakx(pxy)
                WORD    *pxy;
                {                               /* Breaking object is right of  */
                if (brmx < pxy[0])              /* mouse.  Reduce width of      */
                        {                       /* bounding rectangle.          */
                        brrect.gw = pxy[0] - brrect.gx;
                        return (TRUE);
                        }
                if (brmx > pxy[2])              /* Object to left.  Reduce width*/
                        {                       /* and move rect. to right      */
                        brrect.gw += brrect.gx - pxy[2] - 1;
                        brrect.gx = pxy[2] + 1;
                        return (TRUE);
                        }
                return (FALSE);                 /* Mouse within object segment. */
                }                               /* Break attempt fails.         */
























        


        Professional GEM           Appendix X                          62


                WORD
        breaky(pxy)
                WORD    *pxy;
                {
                if (brmy < pxy[1])              /* Object below mouse.  Reduce  */
                        {                       /* height of bounding rect.     */
                        brrect.gh = pxy[1] - brrect.gy;
                        return (TRUE);
                        }
                if (brmy > pxy[3])              /* Object above mouse.  Reduce  */
                        {                       /* height and shift downward.   */
                        brrect.gh += brrect.gy - pxy[3] - 1;
                        brrect.gy = pxy[3] + 1;
                        return (TRUE); 
                        }
                /* Emergency escape test! Protection vs. turkeys who nest */
                /* non-selectable objects inside of selectables.          */
                if (brmx >= pxy[0] && brmx <= pxy[1])
                        {                               /* Will X break fail?     */
                        brrect.gx = brmx;               /* If so, punt!           */
                        brrect.gy = brmy;
                        brrect.gw = brrect.gh = 1;
                        return (TRUE);
                        }
                return (FALSE);
                }




























        


        Professional GEM           Appendix X                          63


                WORD
        breakobj(tree, obj)                     /* Called once per object to    */
                LONG    tree;                   /* check if the bounding rect.  */
                WORD    obj;                    /* needs to be modified.        */
                {
                GRECT   s;
                WORD    flags, broken, pxy[4];

                objcxywh(tree, obj, &s);
                grecttoarray(&s, pxy);
                if (!rcintersect(&brrect, &s))
                        return (FALSE);         /* Trivial rejection case       */

                flags = LWGET(OBFLAGS(obj));    /* Is this object a potential   */
                if (flags & HIDETREE)           /* hot-spot?                    */
                        return (FALSE);
                if ( !(flags & SELECTABLE) )
                        return (TRUE);
                if (LWGET(OBSTATE(obj)) & DISABLED)
                        return (TRUE);

                for (broken = FALSE; !broken; ) /* This could take two passes   */
                        {                       /* if the first break fails.    */
                        if (brtogl)
                                broken = breakx(pxy);
                        else
                                broken = breaky(pxy);
                        brtogl = !brtogl;
                        }
                return (TRUE);
                }























        


        Professional GEM           Appendix X                          64


                WORD                            /* Manages mouse rectangle events */
        formhot(tree, hotobj, mx, my, rect, mode)
                LONG    tree;
                WORD    hotobj, mx, my, *mode;
                GRECT   *rect;
                {
                GRECT   root;
                WORD    state;

                objcxywh(tree, ROOT, &root);    /* If there is already a hot-spot */
                if (hotobj != NIL)              /* turn it off.                   */
                        objctoggle(tree, hotobj);

                if (!(inside(mx, my, &root)) )  /* Mouse has moved outside of     */
                        {                       /* the dialog.  Wait for return.  */
                        *mode = M1ENTER;
                        rccopy(&root, rect);
                        return (NIL);
                        }
                                                /* What object is mouse over?     */
                                                /* (Hit is guaranteed.)           */
                hotobj = objcfind(tree, ROOT, MAXDEPTH, mx, my);
                                                /* Is this object a hot-spot?     */
                state = LWGET(OBSTATE(hotobj));
                if (LWGET(OBFLAGS(hotobj)) & SELECTABLE)
                if ( !(state & DISABLED) )
                        {                       /* Yes!  Set up wait state.       */
                        *mode = M1EXIT;
                        objcxywh(tree, hotobj, rect);
                        if (state & SELECTED)   /* But only toggle if it's not    */
                                return (NIL);   /* already SELECTED!              */
                        else
                                {
                                objctoggle(tree, hotobj);
                                return (hotobj);
                                }
                        }

                rccopy(&root, &brrect); /* No hot object, so compute    */
                brmx = mx;                      /* mouse bounding rectangle.    */
                brmy = my;
                brtogl = 0;
                maptree(tree, ROOT, NIL, breakobj);
                rccopy(&brrect, rect);  /* Then return to wait state.   */
                *mode = M1EXIT;
                return (NIL);
                }







        


        Professional GEM           Appendix X                          65


        /************* Keyboard manager and subroutines ***************/

                WORD
        finddef(tree, obj)              /* Check if the object is DEFAULT       */
                LONG    tree;
                WORD    obj;
                {                       /* Is sub-tree hidden?                  */
                if (HIDETREE & LWGET(OBFLAGS(obj)))
                        return (FALSE);
                                        /* Must be DEFAULT and not DISABLED     */
                if (DEFAULT & LWGET(OBFLAGS(obj)))
                if ( !(DISABLED & LWGET(OBSTATE(obj))) )
                        fnobj = obj;    /* Record object number                 */
                return (TRUE);
                }

                WORD
        findtab(tree, obj)              /* Look for target of TAB operation.    */
                LONG    tree;
                WORD    obj;
                {                       /* Check for hiddens subtree.           */
                if (HIDETREE & LWGET(OBFLAGS(obj)))
                        return (FALSE);
                                        /* If not EDITABLE, who cares?          */
                if ( !(EDITABLE & LWGET(OBFLAGS(obj))) )
                        return (TRUE);
                                        /* Check for forward tab match          */
                if (fndir && fnprev == fnlast)
                        fnobj = obj;
                                        /* Check for backward tab match         */
                if (!fndir && obj == fnlast)
                        fnobj = fnprev;
                fnprev = obj;           /* Record object for next call.         */
                return (TRUE);
                }       

                WORD
        formkeybd(tree, editobj, nextobj, kr, outobj, okr)
                LONG    tree;
                WORD    editobj, nextobj, kr, *outobj, *okr;
                {
                if (LLOBT(kr))          /* If lower byte valid, mask out        */
                        kr &= 0xff;     /* extended code byte.                  */
                fndir = 0;              /* Default tab direction if backward.   */
                switch (kr) {
                        case CR:        /* Zap character.                       */
                                *okr = 0;
                                        /* Look for a DEFAULT object.           */
                                fnobj = NIL;
                                maptree(tree, ROOT, NIL, finddef);
                                        /* If found, SELECT and force exit.     */
                                if (fnobj != NIL)


        


        Professional GEM           Appendix X                          66


                                        {
                                        objcsel(tree, fnobj);
                                        *outobj = fnobj;
                                        return (FALSE);
                                        }               /* Falls through to     */ 
                        case TAB:                       /* tab if no default    */
                        case DOWN:      
                                fndir = 1;              /* Set fwd direction    */
                        case BTAB:
                        case UP:
                                *okr = 0;               /* Zap character        */
                                fnlast = editobj;
                                fnprev = fnobj = NIL; /* Look for TAB object    */
                                maptree(tree, ROOT, NIL, findtab);
                                if (fnobj == NIL)       /* try to wrap around   */
                                        maptree(tree, ROOT, NIL, findtab);
                                if (fnobj != NIL)
                                        *outobj = fnobj;
                                break;
                        default:                        /* Pass other chars     */
                                return (TRUE);
                        }
                return (TRUE);
                }






























        


        Professional GEM           Appendix X                          67


        /************* Mouse button manager and subroutines ***************/

                WORD
        doradio(tree, obj)
                LONG    tree;
                WORD    obj;
                {
                GRECT   root;
                WORD    pobj, sobj, state;

                objcxywh(tree, ROOT, &root);
                pobj = getparent(tree, obj);            /* Get the object's parent */

                for (sobj = LWGET(OBHEAD(pobj)); sobj != pobj;
                        sobj = LWGET(OBNEXT(sobj)) )
                        {                               /* Deselect all but...     */
                        if (sobj != obj)
                                objcdsel(tree, sobj);
                        }
                objcsel(tree, obj);                     /* the one being SELECTED  */
                }

                WORD                                    /* Mouse button handler    */
        formbutton(tree, obj, clicks, nextobj, hotobj)
                LONG    tree;
                WORD    obj, clicks, *nextobj, *hotobj;
                {
                WORD    flags, state, hibit, texit, sble, dsbld, edit;
                WORD    inout, instate;

                flags = LWGET(OBFLAGS(obj));            /* Get flags and states   */
                state = LWGET(OBSTATE(obj));
                texit = flags & TOUCHEXIT;
                sble = flags & SELECTABLE;
                dsbld = state & DISABLED;
                edit = flags & EDITABLE;

                if (!texit && (!sble || dsbld) && !edit) /* This is not an      */
                        {                                /* interesting object  */
                        *nextobj = 0;
                        return (TRUE);
                        }

                if (texit && clicks == 2)               /* Preset special flag  */
                        hibit = 0x8000;
                else
                        hibit = 0x0;

                if (sble && !dsbld)                     /* Hot stuff!           */
                        {
                        if (flags & RBUTTON)            /* Process radio buttons*/
                                doradio(tree, obj);     /* immediately!         */ 


        


        Professional GEM           Appendix X                          68


                        else if (!texit)
                                {
                                instate = (obj == *hotobj)?     /* Already toggled ? */
                                        state: state ^ SELECTED;        
                                if (!grafwatchbox(tree, obj, instate, 
                                        instate ^ SELECTED))
                                        {                       /* He gave up...  */
                                        *nextobj = 0;
                                        *hotobj = NIL;
                                        return (TRUE);
                                        }
                                }
                        else /* if (texit) */
                                if (obj != *hotobj)     /* Force SELECTED       */
                                        objctoggle(tree, obj);
                        }

                if (obj == *hotobj)             /* We're gonna do it! So don't  */
                        *hotobj = NIL;          /* turn it off later.           */

                if (texit || (flags & EXIT) )   /* Exit conditions.             */
                        {
                        *nextobj = obj | hibit;
                        return (FALSE);         /* Time to leave!               */
                        }
                else if (!edit)                 /* Clear object unless tabbing  */
                        *nextobj = 0;

                return (TRUE);
                }
























        


        Professional GEM           Appendix X                          69


        /************* New forms manager: Entry point and main loop *************/

                WORD
        formdo(tree, startfld)
                REG LONG        tree;
                WORD            *startfld;
                {
                REG WORD        editobj;
                WORD            nextobj, hotobj, hotmode;
                WORD            which, cont;
                WORD            idx;
                WORD            mx, my, mb, ks, kr, br;
                GRECT           hotrect;
                WORD            (*valid)();
                                                        /* Init. editing        */
                nextobj = *startfld;
                editobj = 0;
                                                        /* Initial hotspot cndx */
                hotobj = NIL; hotmode = M1ENTER;
                objcxywh(tree, ROOT, &hotrect);
                                                        /* Main event loop      */
                cont = TRUE;
                while (cont)
                  {
                                                        /* position cursor on   */
                                                        /*   the selected       */
                                                        /*   editting field     */
                  if (editobj != nextobj)
                  if (nextobj != 0)
                        {
                        editobj = nextobj;
                        nextobj = 0;
                        objcedit(tree, editobj, 0, &idx, EDINIT);
                        }
                                                        /* wait for button or   */
                                                        /* key or rectangle     */
                  which = evntmulti(MUKEYBD | MUBUTTON | MUM1, 
                                0x02, 0x01, 0x01,
                                hotmode, hotrect.gx, hotrect.gy, 
                                        hotrect.gw, hotrect.gh, 
                                0, 0, 0, 0, 0,
                                0x0L,
                                0, 0,
                                &mx, &my, &mb, &ks, &kr, &br);

                  if (which & MUM1)                     /* handle rect. event   */
                        hotobj = formhot(tree, hotobj, mx, my, &hotrect, &hotmode);
                                                        /* handle keyboard event*/
                  if (which & MUKEYBD)
                        {                               /* Control char filter  */
                        cont = formkeybd(tree, editobj, nextobj, kr, &nextobj, &kr);
                        if (kr && editobj)              /* Add others to object */


        


        Professional GEM           Appendix X                          70


                                objcedit(tree, editobj, kr, &idx, EDCHAR);
                        }
                                                        /* handle button event  */
                  if (which & MUBUTTON)
                        {                               /* Which object hit?    */
                        nextobj = objcfind(tree, ROOT, MAXDEPTH, mx, my);
                        if (nextobj == NIL)
                                nextobj = 0;
                        else                            /* Process a click      */
                                cont = formbutton(tree, nextobj, br, 
                                        &nextobj, &hotobj);
                        }
                                                        /* handle end of field  */
                                                        /*   clean up           */
                  if (!cont || (nextobj != editobj && nextobj != 0))
                  if (editobj != 0) 
                        objcedit(tree, editobj, 0, &idx, EDEND);
                  }
                                                        /* If defaulted, may    */
                                                        /* need to clear hotspot*/
                if (hotobj != (nextobj & 0x7fff))
                if (hotobj != NIL)
                        objctoggle(tree, hotobj);
                                                        /* return exit object   */
                                                        /*   hi bit may be set  */
                                                        /*   if exit obj. was   */
                                                        /*   double-clicked     */
                *startfld = editobj;
                return(nextobj);
                }
























        


        Professional GEM           Appendix XI                         71


                                  AAppppeennddiixx -- XXII
                             SSaammppllee CCooddee ffoorr PPaarrtt XXVV



        /*------------------------------*/
        /*      includes                */
        /*------------------------------*/

        #include "portab.h"                             /* portable coding conv */
        #include "machine.h"                            /* machine depndnt conv */
        #include "osbind.h"                             /* BDOS defintions      */
        #include "gemdefs.h"

        /*------------------------------*/
        /*      openfile                */
        /*------------------------------*/
                WORD
        openfile(filename)
                BYTE    *filename;
                {
                LONG    doshndl;

                FOREVER
                        {
                        doshndl = Fopen(filename, 0);
                        if (doshndl >= 0)
                                return ((WORD) doshndl);
                        if ( !doserror((WORD) doshndl) )
                                return (-1);
                        }

                return (-1);            /* Appease lint */
                }




















        


        Professional GEM           Appendix XI                         72


        /*------------------------------*/
        /*      createfile              */
        /*------------------------------*/
                WORD
        createfile(filename)
                BYTE    *filename;
                {
                LONG    doshndl;

                FOREVER
                        {
                        doshndl = Fcreate(filename, 0);
                        if (doshndl >= 0)
                                return ((WORD) doshndl);
                        if ( !doserror((WORD) doshndl) )
                                return (-1);
                        }

                return (-1);            /* Appease lint */
                }


































        


        Professional GEM           Appendix XI                         73


        /*------------------------------*/
        /*      doserror                */
        /*------------------------------*/
                WORD
        doserror(toserr)
                WORD    toserr;
                {
                WORD    fret;

                grafmouse(ARROW, 0x0L);
                if (toserr > -50)
                        {
                        toserr += 31;
                        toserr = -toserr;
                        }
                fret = formerror(toserr);
                return (fret);
                }




































        


        Professional GEM           Appendix XI                         74


        /*------------------------------*/
        /*      getfile                 */
        /*------------------------------*/
                WORD
        getfile(extnt, gotfile)
                BYTE    *extnt, *gotfile;
                {
                WORD    butn, ii;
                BYTE    tmppath[64], tmpname[13];

                tmpname[0] = '\0';
                tmppath[0] = '\0';

                if (*gotfile)
                        parsefname(gotfile, tmppath, tmpname, extnt);
                if (!tmppath[0])
                        getpath(&tmppath[0], extnt);

                fselinput(tmppath, tmpname, &butn);
                if (butn)
                        {
                        strcpy(gotfile, tmppath);
                        for (ii = 0; gotfile[ii] && gotfile[ii] != '*'; ii++);
                        gotfile[ii - 1] = '\0';
                        strcat (gotfile, "\\");
                        strcat(gotfile, tmpname);
                        return (TRUE);
                        }
                else
                        return (FALSE);
                }























        


        Professional GEM           Appendix XI                         75


        /*------------------------------*/
        /*      parsefname              */
        /*------------------------------*/
                VOID
        parsefname(full, path, name, extnt)
                BYTE    *full, *path, *name, *extnt;
                {
                WORD    i, j;
                BYTE    *s, *d;

                for (i = strlen(full); i--; )           /* scan for end of path */
                        if (full[i] == '\\' || full[i] == ':')
                                break;
                if (i == -1)
                        strcpy(name, full);             /* "Naked" file name */
                else
                        {
                        strcpy(name, &full[i+1]);
                        for (s = full, d = path, j = 0; j++ < i + 1;
                                *d++ = *s++);
                        strcpy(&path[i+1], "*.");
                        strcat(path, extnt);
                        }
                }






























        


        Professional GEM           Appendix XI                         76


        /*------------------------------*/
        /*      getpath                 */
        /*------------------------------*/
                VOID
        getpath(tmppath, spec)
                BYTE    *tmppath, *spec;
                {
                WORD    curdrv;

                curdrv = Dgetdrv();
                tmppath[0] = curdrv + 'A';
                tmppath[1] = ':';
                Dgetpath(&tmppath[2], 0);
                if (strlen(tmppath) > 3)
                        strcat(tmppath, "\\");
                else
                        tmppath[2] = '\0';
                strcat(tmppath, "*.");
                strcat(tmppath, spec);
                }


































        


        Professional GEM           Appendix XI                         77


        /*------------------------------*/
        /*      newext          */
        /*------------------------------*/
                VOID
        newext(ofname, nfname, ext)
                BYTE    *ofname, *nfname, *ext;
                {
                WORD    ii, jj;

                strcpy(nfname, ofname);
                for (ii = (jj = strlen(nfname)) - 1; ii && nfname[ii] != '.'; ii--);
                if (!ii)
                        nfname[ii = jj] = '.';
                strcpy(&nfname[++ii], ext);
                }







































        


        Professional GEM          Appendix XII                         78


                                 AAppppeennddiixx -- XXIIII
                            SSaammppllee CCooddee ffoorr PPaarrtt XXVVII



                          /*****   GEMCL16.H   *****/

        #define PROGRESS 0      /* TREE */
        #define PLINE 2         /* OBJECT in TREE #0 */
        #define PROBOX 3        /* OBJECT in TREE #0 */
        #define PROBAR 4        /* OBJECT in TREE #0 */
        #define STRINGS 1       /* TREE */
        #define P1 1    /* OBJECT in TREE #1 */
        #define P2 2    /* OBJECT in TREE #1 */
        #define PN 3    /* OBJECT in TREE #1 */







































        


        Professional GEM          Appendix XII                         79


                         /*****  GEMCL16.C ******/
         /* >>>>>>>>>>>>>>>>>>> Progress box setup and cleanup <<<<<<<<<<<<<<<<<<< */

        /*------------------------------*/
        /*      begprog                 */
        /*------------------------------*/
                VOID
        begprog(rect)
                GRECT   *rect;
                {
                OBJECT  *tree;
                WORD    xdial, ydial, wdial, hdial;

                rsrcgaddr(RTREE, PROGRESS, &tree);
                formcenter(tree, &rect->gx, &rect->gy, &rect->gw, &rect->gh);
                formdial(0, 0, 0, 0, 0, rect->gx, rect->gy, 
                        rect->gw, rect->gh);
                objcdraw(tree, ROOT, MAXDEPTH, rect->gx, rect->gy, 
                        rect->gw, rect->gh);
                }

        /*------------------------------*/
        /*      endprog                 */
        /*------------------------------*/
                VOID
        endprog(rect)
                GRECT   *rect;
                {
                formdial(3, 0, 0, 0, 0, rect->gx, rect->gy, rect->gw, rect->gh);
                }
























        


        Professional GEM          Appendix XII                         80


        /* >>>>>>>>>>>>>>>>>>>> Text line progress indicator <<<<<<<<<<<<<<<<<<<<<<< */

        /*------------------------------*/
        /*      setprog                 */
        /*------------------------------*/
                VOID
        setprog(strno)
                UWORD   strno;
                {
                OBJECT  *tree;
                BYTE    *saddr;

                rsrcgaddr(RTREE, STRINGS, &tree);
                saddr = (BYTE *) (tree + strno)->obspec;
                rsrcgaddr(RTREE, PROGRESS, &tree);
                settext(tree, PLINE, saddr);
                dispobj(tree, PLINE);
                }




































        


        Professional GEM          Appendix XII                         81


        /* >>>>>>>>>>>>>>>>>>>> Moving bar progress indicator <<<<<<<<<<<<<<<<<<<<<< */

        /*------------------------------*/
        /*      setprog                 */
        /*------------------------------*/
                VOID
        setprog(value, maxc)
                WORD    value, maxc;
                {
                WORD    wnew, wold;
                OBJECT  *tree;
                GRECT   box;

                rsrcgaddr(RTREE, PROGRESS, &tree);
                wold = (tree + PROBOX)->obwidth - 1;    /* Take border into account */
                wnew = wold + 1;
                if (maxc)
                        wnew = max(1, ((LONG) value * (LONG) wnew) / maxc); 
                (tree + PROBAR)->obwidth = wnew;
                if (value)
                        {
                        objcxywh(tree, PROBAR, &box);
                        box.gx += wold; box.gw -= wold;
                        objcdraw(tree, ROOT, MAXDEPTH, box.gx, box.gy, 
                                box.gw, box.gh);
                        }
                }       



























        


        Professional GEM          Appendix XII                         82


        /* >>>>>>>>>>>>>>>>>>>> Progress indicator check for abort <<<<<<<<<<<<<<<< */

        /*------------------------------*/
        /*      escprog                 */
        /*------------------------------*/
                WORD
        escprog()
                {
                WORD    which, kr;
                WORD    mx, my, mb, ks, br;             /* Not used, but needed */

                FOREVER 
                        {
                        which = evntmulti(MUKEYBD | MUTIMER,
                                0, 0, 0,
                                0, 0, 0, 0, 0,
                                0, 0, 0, 0, 0,
                                0L, 
                                0, 0,           /* Zero timer delay */
                                &mx, &my, &mb, &ks, &kr, &br);

                        if (which & MUKEYBD)
                                {
                                if ((kr & 0xff) == 0x1B)        /* ESC?           */
                                        return (TRUE);          /* else try again */
                                }
                        else /* if (which & MUTIMER) */
                                return (FALSE);
                        }

                return (TRUE);          /* Keeps lint happy */ 
                }






















        


        Professional GEM          Appendix XII                         83


          /* >>>>>>>>>>>>>>>>>>>>>>> Progress subroutines  <<<<<<<<<<<<<<<<<<<<<<< */

                VOID
        settext(tree, obj, str)
                OBJECT  *tree;
                BYTE    *str;
                WORD    obj;
                {
                TEDINFO *obspec;

                obspec = (TEDINFO *) (tree + obj)->obspec;      /* Get TEDINFO address  */
                obspec->teptext = str;                  /* Set new text pointer */
                obspec->tetxtlen = strlen(str); /* Set new length       */
                }

                VOID
        dispobj(tree, obj)
                OBJECT  *tree;
                WORD    obj;
                {
                GRECT   box;

                objcxywh(tree, obj, &box);
                objcdraw(tree, ROOT, MAXDEPTH, box.gx, box.gy, 
                        box.gw, box.gh);
                }

                VOID
        objcxywh(tree, obj, p)          /* get x,y,w,h for specified object     */
                OBJECT  *tree;
                WORD    obj;
                GRECT   *p;
                {
                objcoffset(tree, obj, &p->gx, &p->gy);
                p->gw = (tree + obj)->obwidth;
                p->gh = (tree + obj)->obheight;
                }

















        


        Professional GEM          Appendix XII                         84


           /* >>>>>>>>>>>>>>>>>>>>>> Box mover examples <<<<<<<<<<<<<<<<<<<<<<<<<< */
        /*------------------------------*/
        /*      fourwaybox              */
        /*------------------------------*/
                VOID
        fourwaybox(vdihandle, rubber, limit)
                WORD    vdihandle;
                GRECT   *rubber, *limit;
                {
                UWORD   ox, oy, mx, my, foo, down;

                vswrmode(vdihandle, MDXOR);             /* Set VDI modes for box */
                vslcolor(vdihandle, BLACK);
                windupdate(BEGMCTRL);                   /* Capture mouse         */

                ox = rubber->gx; oy = rubber->gy;       /* Save off input corner */
                grafmkstate(&mx, &my, &foo, &foo);      /* Initialize mouse posn */
                do {
                        rubber->gx = min(ox, mx);       /* Choose UL corner      */
                        rubber->gy = min(oy, my);
                        rubber->gw = max(ox, mx) - rubber->gx + 1;
                        rubber->gh = max(oy, my) - rubber->gy + 1;
                        rcintersect(limit, rubber);     /* Lock into limit rect  */
                        down = rubwait(vdihandle, rubber, &mx, &my);
                        } while (down);

                windupdate(ENDMCTRL);                   /* Release mouse to GEM  */
                }


























        


        Professional GEM          Appendix XII                         85


        /*------------------------------*/
        /*      hotdragbox              */
        /*------------------------------*/
                WORD
        hotdragbox(vdihandle, box, limit, tree)
                WORD    vdihandle;
                GRECT   *box, *limit;
                OBJECT  *tree;
                {
                UWORD   ox, oy, mx, my, foo, down;
                WORD    hoverobj, retobj;

                vswrmode(vdihandle, MDXOR);             /* Set VDI modes for box */
                vslcolor(vdihandle, BLACK);
                windupdate(BEGMCTRL);                   /* Capture mouse         */
                grafmkstate(&mx, &my, &foo, &foo);      /* Initialize mouse posn */
                ox = min(box->gw, max(0, mx - box->gx) );
                oy = min(box->gh, max(0, my - box->gy) );
                hoverobj = NIL;

                do {
                        box->gx = mx - ox;
                        box->gy = my - oy;
                        rcconstrain(limit, box);        /* Lock into limit rect  */

                        down = rubwait(vdihandle, box, &mx, &my);

                        if (!inside(mx, my, limit))
                                retobj = NIL;
                        else
                                {
                                retobj = objcfind(tree, ROOT, NIL, mx, my);
                                if (retobj != NIL)
                                if ( !(SELECTABLE & (tree + retobj)->obflags) )
                                        retobj = NIL;
                                }
                        if (retobj != hoverobj)
                                {
                                if (hoverobj != NIL)
                                        objctoggle(tree, hoverobj);
                                hoverobj = retobj;
                                if (hoverobj != NIL)
                                        objctoggle(tree, hoverobj);
                                }
                        } while (down);

                windupdate(ENDMCTRL);                   /* Release mouse to GEM  */
                if (hoverobj != NIL)
                        objctoggle(tree, hoverobj);
                return (hoverobj);
                }



        


        Professional GEM          Appendix XII                         86


        /*------------------------------*/
        /*      rubwait                 */
        /*------------------------------*/
                WORD
        rubwait(vdihandle, box, mx, my)
                WORD    vdihandle;
                GRECT   *box;
                WORD    *mx, *my;
                {
                WORD    which, kr;
                WORD    mb, ks, br;                     /* Not used, but needed */

                grafmouse(MOFF, 0x0L);
                vdixbox(vdihandle, box);                /* Draw waiting box */
                grafmouse(MON, 0x0L);

                which = evntmulti(MUBUTTON | MUM1,
                        0x01, 0x01, 0x00,               /* Wait for button up */
                        TRUE, *mx, *my, 1, 1,           /* or mouse move      */
                        0, 0, 0, 0, 0,
                        0L, 
                        0, 0,
                        mx, my, &mb, &ks, &kr, &br);

                grafmouse(MOFF, 0x0L);
                vdixbox(vdihandle, box);                /* Take down waiting box */
                grafmouse(MON, 0x0L);

                return (!(which & MUBUTTON));           /* TRUE if still dragging */
                }
























        


        Professional GEM          Appendix XII                         87


        /* >>>>>>>>>>>>>>>>>>>>>>>> Box Mover Utilities <<<<<<<<<<<<<<<<<<<<<<<<< */

                VOID
        objctoggle(tree, obj)
                OBJECT  *tree;
                WORD    obj;
                {
                WORD    state, newstate;
                GRECT   root, obrect;

                objcxywh(tree, ROOT, &root);
                newstate = (tree + obj)->obstate ^ SELECTED;
                objcchange(tree, obj, 0, root.gx, root.gy, 
                        root.gw, root.gh, newstate, 1);
                }

                VOID
        vdixbox(vdihandle, pt)
                WORD    vdihandle;
                GRECT   *pt;
                {
                WORD    pxy[10];

                vdibxpts(pt, pxy);
                vdixline(vdihandle, 5, pxy);
                }




























        


        Professional GEM          Appendix XII                         88


                VOID
        vdibxpts(pt, pxy)
                GRECT   *pt;
                WORD    *pxy;
                {
                pxy[0] = pt->gx;
                pxy[1] = pt->gy;
                pxy[2] = pt->gx + pt->gw - 1;
                pxy[3] = pt->gy;
                pxy[4] = pt->gx + pt->gw - 1;
                pxy[5] = pt->gy + pt->gh - 1;
                pxy[6] = pt->gx;
                pxy[7] = pt->gy + pt->gh - 1;
                pxy[8] = pt->gx;
                pxy[9] = pt->gy;
                }

        MLOCAL  WORD    hztltbl[2] = { 0x5555, 0xaaaa };
        MLOCAL  WORD    verttbl[4] = { 0x5555, 0xaaaa, 0xaaaa, 0x5555 };

                VOID
        vdixline(vdihandle, ptscount, ppoints)
                WORD    vdihandle, ptscount, *ppoints;
                {
                WORD            *linexy,i;
                WORD            st;

                for ( i = 1; i < ptscount; i++ )
                        {
                        if ( *ppoints == *(ppoints + 2) )
                                {
                                st = verttbl[( (( *ppoints) & 1) | 
                                        ((*(ppoints + 1) & 1 ) << 1))];
                                }       
                        else
                                {
                                linexy = ( *ppoints < *( ppoints + 2 )) ? 
                                        ppoints : ppoints + 2;
                                st = hztltbl[( *(linexy + 1) & 1)];
                                }

                        vsludsty(vdihandle, st);
                        vsltype(vdihandle, 7);
                        vpline(vdihandle, 2, ppoints);
                        ppoints += 2;
                        }

                vsltype(vdihandle, 1);
                }       





        


        Professional GEM          Appendix XII                         89


                WORD
        rcintersect(p1, p2)             /* compute intersect of two rectangles  */
                GRECT   *p1, *p2;
                {
                WORD    tx, ty, tw, th;

                tw = min(p2->gx + p2->gw, p1->gx + p1->gw);
                th = min(p2->gy + p2->gh, p1->gy + p1->gh);
                tx = max(p2->gx, p1->gx);
                ty = max(p2->gy, p1->gy);
                p2->gx = tx;
                p2->gy = ty;
                p2->gw = tw - tx;
                p2->gh = th - ty;
                return( (tw > tx) && (th > ty) );
                }






































        


        Professional GEM          Appendix XII                         90


                VOID
        rcunion(p1, p2)
                GRECT           *p1, *p2;
                {
                WORD            tx, ty, tw, th;

                tw = max(p1->gx + p1->gw, p2->gx + p2->gw);
                th = max(p1->gy + p1->gh, p2->gy + p2->gh);
                tx = min(p1->gx, p2->gx);
                ty = min(p1->gy, p2->gy);
                p2->gx = tx;
                p2->gy = ty;
                p2->gw = tw - tx;
                p2->gh = th - ty;
                }

                VOID
        rcconstrain(pc, pt)
                GRECT           *pc;
                GRECT           *pt;
                {
                if (pt->gx < pc->gx)
                        pt->gx = pc->gx;
                if (pt->gy < pc->gy)
                        pt->gy = pc->gy;
                if ((pt->gx + pt->gw) > (pc->gx + pc->gw))
                        pt->gx = (pc->gx + pc->gw) - pt->gw;
                if ((pt->gy + pt->gh) > (pc->gy + pc->gh))
                        pt->gy = (pc->gy + pc->gh) - pt->gh;
                }
























        


        Professional GEM          Appendix XII                         91


                BOOLEAN
        inside(x, y, pt)                /* determine if x,y is in rectangle     */
                UWORD           x, y;
                GRECT           *pt;
                {
                if ( (x >= pt->gx) && (y >= pt->gy) &&
                    (x < pt->gx + pt->gw) && (y < pt->gy + pt->gh) )
                        return(TRUE);
                else
                        return(FALSE);
                } /* inside */











































        


                                        I


                                TTaabbllee ooff CCoonntteennttss

        PART - X.  VDI Graphics: Text Output    ...................    1
           DEFINITIONS        .....................................    1
           TEXT ATTRIBUTES       ..................................    2
              vstcolor()...........................................    2
              vsteffects().........................................    2
              bstalignment().......................................    3
              vgtext().............................................    4
              vqtattributes()......................................    4
           OPTIMIZATION        ....................................    4
           BYTE ALIGNMENT       ...................................    5
           WRITING MODE       .....................................    5
           CLIPPING        ........................................    5
           BINDINGS        ........................................    6
           MOVING TEXT       ......................................    6
           THAT'S IT FOR NOW     ..................................    6
        PART - XI.  GEM Hooks and Hacks    ........................    7
           POWERFUL OBJECTS       .................................    7
           EXTENDED OBJECT TYPES      .............................    7
           USER-DEFINED OBJECTS       .............................    9
           PUT ANYTHING YOU WANT ON THE DESKTOP!  .................   11
           THE TOUCHEXIT FLAG      ................................   11
           THE INDIRECT FLAG      .................................   12
           INSTANT CO-ROUTINES       ..............................   13
           THAT'S ALL FOR NOW     .................................   14
           UPDATE: ATARI ST      ..................................   14
              asm()................................................   15
        PART - XII.  GEM Events and Program Structure   ...........   16
           ALL FOR ONE AND ONE FOR ALL.  ..........................   16
           STARTING AHEAD.       ..................................   16
              evntmulti()..........................................   16
              evdclick()...........................................   18
           MOUSE RECTANGLES.       ................................   19
           MESSAGES.        .......................................   20
           TIMER.        ..........................................   20
           KEYBOARD.        .......................................   21
           RANDOM NOTES ON EVENTS.     ............................   21
           EVENTS AND GEM PROGRAM STRUCTURE.    ...................   22
        PART - XIII.  A New Form Manager    .......................   24
           ON WITH THE SHOW     ...................................   24
           RELAXEN UND WATCHEN DAS BLINKENLICHTE    ...............   26
           WHAT A CHARACTER!      .................................   28
           BUTTON DOWN       ......................................   29
           OPERATORS ARE STANDING BY     ..........................   30
        PART - XIV.  USER INTERFACES - Part 2   ...................   32
           MODES AGAIN       ......................................   32
           THE "TWO USER TEST"     ................................   32
           ONE LINER       ........................................   33
           PREDICTABILITY FOREVER AND EVER AND EVER   .............   34
           IS A BOGEYMAN!      ....................................   34
           GOOD GRAMMAR OR...      ................................   35


        


                                       II


           SPECIFYING A SUBJECT      ..............................   36
           ACTION        ..........................................   37
           DIFFERENT FOLKS DIFFERENT STROKES     ..................   38
           MORE TO COME      ......................................   40
        PART - XV.  Coping with GEMDOS     ........................   41
           A BIT OF HISTORY.     ..................................   41
           GOING FOR IT.      .....................................   42
           I CAN'T HEAR YOU!     ..................................   45
        PART - XVI.  Interface Potpourri #1     ...................   47
           MAKING PROGRESS.       .................................   47
           BOXED IN.       ........................................   49
           HOT STUFF?       .......................................   51
           A FEW CHANGES.      ....................................   52
        APPENDICES.................................................   53
           Appendix - IX Sample Code for Part XI...................   54
           Appendix - X Sample Code for Part XIII..................   57
           Appendix - XI Sample Code for Part XV...................   71
           Appendix - XII Sample Code for Part XVI.................   78




































        

