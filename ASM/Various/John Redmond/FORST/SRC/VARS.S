; VARS.S: system variables and access words,
; last update 3/11/90
; Copyright <C> John Redmond 1989,1990
; Public domain for non-commercial use.
;
        section text
        even
;
;*******************************************************;
;                                                       ;
; System variables                                      ;
;                                                       ;
;*******************************************************;
;
base:   dc.l    10      ;decimal
state:  dc.l    0
mcro:   dc.l    0       ;no macro expansion
longest: dc.l   8       ;max macro length 8 words
hp:     dc.l    0       ;offset^ header space
cp:     dc.l    0       ;offset^ code space
entry:  dc.l    0       ;actual address where find will start looking
fence   dc.l    0
span:   dc.l    0
toin:   dc.l    0       ;input buffer offset
htib:   dc.l    0
tib:    dc.l    0       ;input buffer pointer
macptr: dc.l    0       ;macro pointer
hmac:   dc.l    0       ;length of macro
macin:  dc.l    0       ;macro buffer offset
csp:    dc.l    0
src:    dc.l    0       ;default to keyboard input
dest:   dc.l    1       ;default to console output
delim:	dc.l	$5d	;[ is default delimier for replace
auto:   dc.l    0       ;no auto start
dpl:    dc.l    0
stack:  ds.l    1       ;base of return stack
dstack: ds.l    1       ;base of data stack
rstck:  dc.l    rspace  ;defined in GLOBALS
heads:  dc.l    hspace  ;size of header space
work:   dc.l    wspace  ;size of work space
origin: dc.l    0       ;start of application code
pocket  ds.l    1       ;^stored word
;
;system convenience words:
;
_macros: lea    mcro,a0
        move.l  #-1,(a0)
        rts
_calls: lea     mcro,a0
        clr.l   (a0)
        rts
_mode:  lea     mcro,a0
        push    (a0)
        rts
_system: lea    stack,a0
        move.l  (a0),a7
        bra     finish
_tib:   lea     tib,a0
        push    (a0)
        rts
;
stateat: lea    state,a0        ;internal use only
        tst.l   (a0)
        rts
;
;direct address access words (not just offsets):
;
_here:  move.l  cp(pc),a0
        adda.l  a5,a0
        push    a0
        rts
;
_there: move.l  hp(pc),a0
        adda.l  a5,a0           ;make an address
        push    a0
        rts
;
_top:   lea     entry,a0
        push    (a0)            ;returns ^end of latest header
        rts
;
;String to initialize screen behaviour:
;
iostring: dc.b  6,27,'E',27,'e',27,'v'  ;clear screen, line wrap
;
;Sign-on message string:
;
signon: dc.b    signend-signon-1
        dc.b    'ForST, a 32-bit optimising Forth,',13,10
        dc.b    '(version 1.37, 24 November 1990).',13,10
        dc.b    'Copyright <C> John Redmond, Sydney, Australia.',13,10
        dc.b    'Public domain for non-commercial use.',13,10
signend:
;
        even
;
;leave and loop stacks:
;
        ds.l    16              ;leave stack space
lstkptr: ds.l   1               ;leave stack pointer
        ds.l    16              ;loop stack space
lpstkptr: ds.l  1               ;loop stack pointer
;
;instack and    file structures
;
bufflgs: dc.b   nobuffs                 ;are f1 (etc) in use?
        even
inbott: ds.l    4*nobuffs               ;bottom of in stack space
instkptr: ds.l  1                       ;in stack pointer
f1:     ds.b    bsize*(nobuffs+4)       ;8 buffers for system use
;
;internal variables:
;
oldlen: ds.l    1               ;length of old keyboard input
headmark: ds.l  1               ;nfa of last colon definition
todepth: ds.l   1               ;link marker
tothere: ds.l   1               ;start of temporary heads
store:  dc.w    0               ;stack frame or register store or fetch
locsused: dc.w  0               ;flag for ; and exit
;
hbase:  ds.l    1               ;4 words for header movement
hnow:   ds.l    1
hlen:   ds.l    1
chop:   ds.l    1
;
;
        section data
        even
;
        dc.b    $84,'MODE',$a0
        ptrs    _mode,18                ;-1: macros, 0: calls
;
        dc.b    $84,'HERE',$A0          ;address of free code space
        ptrs    _here,18
;
        dc.b    $85,'THER','E'!$80      ;address of free head space
        ptrs    _there,18
;
        dc.b    $83,'TO','P'!$80        ;return the value in ENTRY
        ptrs    _top,16
;
        dc.b    $c2,'HP',$a0            ;offset to free head space
        vptrs   hp,16
;
        dc.b    $c5,'ENTR','Y'!$80      ;address to pass to FIND
        vptrs   entry,18
;
        dc.b    $c5,'DELI','M'!$80      ;delimiter for replace
        vptrs   delim,18
;
        dc.b    $c2,'CP',$a0            ;offset to free code space
        vptrs   cp,16
;
        dc.b    $c5,'FENC','E'!$80      ;code address barrier
        vptrs   fence,18
;
        dc.b    $c4,'BASE',$a0          ;for integer i/o
        vptrs   base,18
;
        dc.b    $c5,'STAT','E'!$80      ;operation state
        vptrs   state,18
;
        dc.b    $c4,'AUTO',$a0          ;offset to autoexec code
        vptrs   auto,18
;
        dc.b    $c4,'#TIB',$a0          ;# chars from query
        vptrs   htib,18
;
        dc.b    $c6,'#MACRO',$a0        ;# chars in macro
        vptrs   hmac,20
;
        dc.b    $c6,'>MACRO',$a0        ;macro pointer
        vptrs   macptr,20
;
        dc.b    $c4,'SPAN',$a0          ;# chars from expect
        vptrs   span,18
;
        dc.b    $c3,'>I','N'!$80        ;input character pointer
        vptrs   toin,16
;
        dc.b    $83,'TI','B'!$80        ;keyboard buffer
        ptrs    _tib,16
;
        dc.b    $c3,'DP','L'!$80        ;for integer input
        vptrs   dpl,16
;
        dc.b    $c3,'CS','P'!$80        ;not used internally
        vptrs   csp,16
;
        dc.b    $c3,'SR','C'!$80        ;in file
        vptrs   src,16
;
        dc.b    $c4,'DEST',$a0          ;out file
        vptrs   dest,18
;
        dc.b    $c6,'RETURN',$a0        ;base of return stack
        vptrs   stack,20
;
        dc.b    $c4,'DATA',$a0          ;base of data stack
        vptrs   dstack,18
;
        dc.b    $c5,'STAC','K'!$80      ;size of return stack
        vptrs   rstck,18
;
        dc.b    $c4,'WORK',$a0          ;space for new code
        vptrs   work,18
;
        dc.b    $c5,'HEAD','S'!$80      ;space for heads
        vptrs   heads,18
;
        dc.b    $c7,'LONGES','T'!$80    ;word size of longest macro
        vptrs   longest,20
;
        dc.b    $c6,'ORIGIN',$a0        ;start of application code
        vptrs   origin,20
;
        dc.b    $c6,'POCKET',$a0        ;^last input word
        vptrs   pocket,20
