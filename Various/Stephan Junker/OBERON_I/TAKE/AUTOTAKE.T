; sample autotake file by Stephan Junker
; adjust to your needs

env PS1=&i&p&I$>                      ; my preference

alias edit d:\everest\everest.prg $*  ; enter your editor

env OBERON=e:\oberon_i                ; home path, correct it
env OBJPATH=$OBERON\obj
env SYMPATH=$OBERON\sym
env PRGPATH=$OBERON\bin
env DEFPATH=$OBERON\def
env OLOPT=-d$PRGPATH\-a

env GS_LIB=d:\ghost,d:\ghost\fonts,d:\ghost\ps
alias trgs tosrun d:\ghost\gs.ttp -q -dNOPAUSE $* quit.ps
alias trgsp tosrun d:\ghost\gs.ttp -sDEVICE=epson -r180x180 -sOUTPUTFILE=PRN: $* quit.ps
alias gs d:\ghost\gs.ttp -q -dNOPAUSE $* quit.ps
alias gsp d:\ghost\gs.ttp -sDEVICE=epson -r180x180 -sOUTPUTFILE=PRN: $* quit.ps

alias compile OComp.Compile $*
alias link OLink.Link $*
alias make OMake.Make $*
;alias debug f:\peacebug\peacebug\peacebug.prg $*  ; enter your debugger
alias unload Tools.Free $*

macro c2e
  repeat
    compile $0
    if $0.err
      edit $0.mod $0.err
      env EXIT=$?
    else
      unload $0
      env EXIT=0
    endif
  until env(EXIT=0)  ; Schleife wiederholen, falls RÅckgabe ungleich 0
  env EXIT
endm

macro seledit
  if !env(LFE)
    env LFE=test.mod
  endif
  fsplit $LFE
  fselect Edit file
  if !env(FSPATH=)
    env LFE=$FSPATH/$FSNAME.$FSEXT
    if $FSPATH/$FSNAME.ERR
      edit $LFE $FSPATH/$FSNAME.ERR
    else
      edit $LFE
    endif
    if $?!=0
      if env(FSEXT=mod)
        c2e $LFE
      elsif env(FSEXT=t)
        $LFE
      endif
    endif
  endif
endm

echo F1 = Select file to edit
fkey 1 seledit|

macro afl
  if !env(LFA)
    env LFA=test.mod
  endif
  fsplit $LFA
  fselect Add file to list
  if !env(FSNAME=)
    env LFA=$FSPATH/$FSNAME.$FSEXT
    getlist $LFA
    if env(LISTENTRY=)
      addlist $LFA
    endif
    fname $LFA
  endif
endm

echo F2 = Add file to list
fkey 2 afl|

macro cmf
  if !env(MAINFILE)
    if env(LFA)
      env MAINFILE=$LFA
    else
      env MAINFILE=$OBERON\tutorial.prj\test.mod
    endif
  endif
  fsplit $MAINFILE
  fselect Choose main file
  if env(FSNAME)
    env MAINFILE=$FSPATH\$FSNAME.$FSEXT
  endif
endm

echo F3 = Choose main file
fkey 3 cmf|

macro cpf
  if !env(PROGFILE)
    if env(MAINFILE)
      fsplit $MAINFILE
      env PROGFILE=$FSPATH\$FSNAME.PRG
    else
      if env(LFA)
        fsplit $LFA
        env PROGFILE=$FSPATH\$FSNAME.PRG
      else
        env PROGFILE=$OBERON\BIN\test.prg
      endif
    endif
  endif
  fsplit $PROGFILE
  fselect Choose program file
  if env(FSNAME)
    env PROGFILE=$FSPATH\$FSNAME.$FSEXT
  endif
endm

echo F4 = Choose program file
fkey 4 cpf|

macro ewf
  if %.err
    edit %.mod %.err
  else
    edit %.mod
  endif
  if $?==1
    c2e %
  endif
endm

echo F5 = Edit work file
fkey 5 ewf|

echo F6 = Compile work file
fkey 6 c2e %|

echo F7 = Make project
fkey 7 make $MAINFILE|

echo F8 = Link main file
fkey 8 link $MAINFILE|

echo F9 = Call debugger with program file
fkey 9 debug $PROGFILE|

echo F10 = Run program file
fkey 10 $PROGFILE|

macro t
  fsplit $OBERON\take\test.t
  fselect Take file
  if !env(FSPATH=)
    $FSPATH/$FSNAME.$FSEXT
    env LFA=$OBERON\$FSNAME.PRJ\test.mod
  endif
endm

macro d
  ; Loading of debugging support
  ; cannot be executed automatically because the AUTOTAKE file is executed
  ; before the communication between the loader and Chatwin is initialized

  ; Debug is the debugger
  Debug

  ; Break allows interrupting a program with both shift keys.
  Break.Link

  ; Exceptions catches processor exceptions (bus error etc.).
  Exceptions.LinkExc
endm

macro opt
  env BAKDESTPATH=$DESTPATH   ; store variables
  env BAKMODPATH=$MODPATH
  env BAKOBJPATH=$OBJPATH
  env BAKSYMPATH=$SYMPATH

  env DESTPATH=$OBERON\$2

  env MODPATH=$OBERON\$1.prj,$OBERON\library.prj
  env OPOPT=-d$DESTPATH
  optimize $0
  env OBJPATH=$OBJPATH,$DESTPATH
  env SYMPATH=$SYMPATH,$DESTPATH
  env MODPATH=$DESTPATH
  omake.Make $0
  olink.Link $0

  env DESTPATH=$BAKDESTPATH   ; restore variables
  env MODPATH=$BAKMODPATH
  env OBJPATH=$BAKOBJPATH
  env SYMPATH=$BAKSYMPATH

  env BAKDESTPATH=
  env BAKMODPATH=
  env BAKOBJPATH=
  env BAKSYMPATH=
endm

macro backup
  cp -v $OBJPATH\$0.OBJ $OBJPATH\$0.BAK
  cp -v $SYMPATH\$0.SYM $SYMPATH\$0.BAK
  cp -v $SYMPATH\$0.INF $SYMPATH\$0.IBK
endm

macro restore
  cp -v $OBJPATH\$0.BAK $OBJPATH\$0.OBJ
  cp -v $SYMPATH\$0.BAK $SYMPATH\$0.SYM
  cp -v $SYMPATH\$0.IBK $SYMPATH\$0.INF
endm

macro delbak
  rm -v $OBJPATH\$0.BAK $SYMPATH\$0.BAK $SYMPATH\$0.IBK
endm

echo Macros: compile, link, make, debug, unload, opt, backup, restore, delbak, t, d