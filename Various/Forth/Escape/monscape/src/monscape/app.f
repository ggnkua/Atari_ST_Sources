supenter
hex

: esc 1b emit ;
: home  esc 48 emit ;
: inv   esc 70 emit ;
esc 76 emit esc 66 emit

: vbase! dup ffff820d c! 8 rshift dup ffff8203 c! 8 rshift ffff8201 c! ;
: vbase@ ffff8201 c@ 100 * ffff8203 c@ + 100 * ffff820d c@ + ;
: vbase@ dolit [ vbase@ ] , ;
: cls    vbase@ 9600 0        fillcells ;
: bls    vbase@ 9600 ffffffff fillcells ;
: strlen 0 BEGIN 2dup + c@ 0 = IF nip exit THEN 1 + AGAIN ;
: .table FOR AFT dup . dup @ . cr cell+ THEN NEXT drop ;
: #.     2e hold ;
: #(     28 hold ;
: #)     29 hold ;
: #,     2c hold ;
: #x,y   # # #. # # 20 hold #, # # #. # # ;
: #xy    #) #x,y #( ;
: .xy    space <# #xy #> type ;
: fp     swap 8 lshift or ;
: xy     10 lshift or ;
: xmask  ffff ;
: ymask  ffff0000 ;
: onlyx  xmask and ;
: onlyy  ymask and ;
: xy+    2dup onlyx + onlyx >r onlyy + onlyy r> or ;

: panic         dup strlen type cconin 2drop bye ;
: assert_hirez  getrez 6 = not IF msg_needhirez panic THEN ;
assert_hirez

variable orig_vbase  vbase@ orig_vbase !
variable playing
: bye  orig_vbase @ vbase! playing @ IF stopmod THEN supreturn cls pterm ;
' bye 'bye !

variable mf  variable osongpos
: upd_mf_patternpos  mf dup @ ffc0 and patternpos or swap !  ;
: upd_mf_songpos osongpos dup @ songpos dup rot = not IF 2dup swap ! 40 mf +! THEN 2drop ;
: mf  upd_mf_songpos upd_mf_patternpos mf @ ;

variable 'efx  variable efxstartmf
variable 'nextefx  ' stop 'nextefx !
: do_efx   'efx @ ?dup IF execute THEN ;
: efx      'efx ! mf efxstartmf ! ;
: efxmf    mf efxstartmf @ - ;
: efxspos  efxmf 6 rshift ;
: .efx     mf . efxmf . efxspos . ;
: main     do_efx do_console ;
' main 'mainloop !
: stop  0 'efx ! ;
: n     IF 'nextefx @ execute exit THEN ;



: seq      FOR AFT r@ over ! cell+ THEN NEXT drop ;
: exg      2dup @ swap @ rot ! swap ! ;
: +random  swap random and cells + ;
: shuffle  dup 1 - rot rot FOR AFT 2dup +random over r@ cells + exg THEN NEXT 2drop ;

: newnoisetab  create here 100  dup cells allot  2dup seq shuffle ;
: genshades    ff FOR over r@ swap bitpattern over r@ + c!  NEXT 2drop ;
: gen8shades   7  FOR over r@ 3 lshift cells + over r@ 8 lshift + genshades NEXT 2drop ;
: new8shades   create here 8 100 * cells allot gen8shades ;

newnoisetab noise
noise new8shades 8shades
create chunkybuf 4b00 allot

create phasetab  2 , 3 , 1 , 0 ,
variable phase
: nextphase  phasetab phase @ cells + @ phase ! ;
: c2m chunkybuf vbase@ 78 8shades c2m8x8 ;
: c2m phase @ chunkybuf vbase@ 78 8shades c2m8x8i4 nextphase ;

: newmul8x8tab create here 100 100 * 2 * allot genmul8x8tab ;
newmul8x8tab mul8x8tab

: newdiv8x8tab create here 100 100 * 2 * allot gendiv8x8tab ;
newdiv8x8tab div8x8tab

: dupcells  cells 2dup + swap cmove ;
variable x variable y
: >xy  y ! x ! ;
: xy>  x @ y @ ;
: cosa     3fffb ;
: sina     649 ;
: xysincos cosa * swap sina * ;
: int      12 rshift ;
: rotate   2dup swap xysincos - int rot rot xysincos + int ;
: gensin90 3fff 0 >xy
  7f FOR
    y @ over 7f r@ - cells + !
    x @ over 80 r@ + cells + !
    xy>  rotate  >xy
  NEXT drop
;
: scale90    ff FOR dup @ 2 lshift over ! cell+ NEXT drop ;
: gensin180  ff FOR dup r@ cells + @         over 1ff r@ - cells + !  NEXT drop ;
: gensin360 1ff FOR dup r@ cells + @ negate  over 200 r@ + cells + !  NEXT drop ;
: gensintab  dup gensin90 dup scale90 dup gensin180 gensin360 ;

variable sintab here 800 cells allot dup gensintab 400 dupcells
: sin  3ff and cells sintab + @ ;
: cos  100 + sin ;
: polar2xy  over cos over * 10000 / onlyx rot rot swap sin * onlyy or ;



: clrbuf  280 0 fillcells ;
: xyoscibuf chunkybuf ;
xyoscibuf a00 +
  create textbufs    dup , a00 +  dup , a00 +  dup , a00 +
  create maskedbufs  dup , a00 +  dup , a00 +  dup , a00 +
drop
create scroffsets 90 , 1a0 , 2b0 ,
: textbuf    cells textbufs   + @ ;
: maskedbuf  cells maskedbufs + @ ;
: scroffset  cells scroffsets + @ ;

: c2m10aty phase @ rot rot a0 * vbase@ + 10 8shades c2m8x8i4 ;

: rendertitle
  3 FOR AFT
    xyoscibuf r@ textbuf r@ maskedbuf a00 cbufmask
    r@ maskedbuf r@ scroffset c2m10aty
  THEN NEXT
;

: msg         messages swap cells + @ ;
: textw       strlen 3 lshift ;
: msgxpos     textw a0 swap - 1 rshift ;
: clrmsg      >r r@ textbuf clrbuf  r@ maskedbuf clrbuf r> drop ;
: clrmsgs     3 FOR AFT r@ clrmsg THEN NEXT ;
: drawmsg     msg swap textbuf over msgxpos + swap a0 swap ff cdrawtext ;

: s1          0 0 drawmsg ;
: s2          1 1 drawmsg ;
: s3          2 2 drawmsg ;
: s4  clrmsgs 0 3 drawmsg ;
: s5          1 4 drawmsg ;
: s6          2 5 drawmsg ;
: s7  clrmsgs 0 6 drawmsg ;
: s8          1 7 drawmsg ;
: s9          2 8 drawmsg ;
: sa  clrmsgs 1 9 drawmsg ;
: sb                      ;
: sc  1 clrmsg            ;

create script ] s1 s2 s3 s4 s5 s6 s7 s8 s9 sa sb sc [ 0 ,
variable scriptpos
: scriptstep script scriptpos @ cells + @ ?dup IF execute 1 scriptpos +!  THEN ;

variable obeatpos
: beatpos      mf 5 rshift ;
: handle_beat  beatpos obeatpos @ = not IF beatpos obeatpos ! scriptstep THEN ;

: do_title
  5 efxspos < IF 'nextefx @ execute exit THEN
  handle_beat samplebuf xyoscibuf 10 draw_xyosci rendertitle nextphase ;




: zsteps      18 ;
: zproj       10 + swap 40 + 4 lshift swap / ;
: h2y         1 rshift 77 +  swap 2 lshift zproj ;
: genh2yline  ff FOR over r@ h2y over r@ + c!  NEXT 2drop ;
: genh2table  zsteps FOR AFT r@ over r@ 8 lshift + genh2yline THEN NEXT drop ;
: newh2ytable create here zsteps 8 lshift allot genh2table ;
newh2ytable h2ytable

create lsight zsteps cells allot
create rsight zsteps cells allot
create tlines a0 2 * allot
create hline  a0     allot
create yclip  a0     allot
create ylines a0 2 * allot
create gline  a0 cells allot

create voxelctx
  40 0 fp b0 0 fp xy ,
  3 0 fp 0 0 fp xy ,
  0 0 fp 3 0 fp xy ,
  tmap 8000 + ,
  hmap 8000 + ,
  lsight ,
  rsight ,
  0 ,
  tlines , tlines a0 + ,
  hline ,
  yclip ,
  ylines , ylines a0 + ,
  gline ,
  h2ytable ,
  mul8x8tab 10000 + ,
  div8x8tab 10000 + ,
  chunkybuf ,
  zsteps ,
  2 ,
  1f ,

: viewpos  voxelctx ;
: ldir     voxelctx cell + ;
: rdir     voxelctx 2 cells + ;
: zline    voxelctx 7 cells + ;
: tline    voxelctx 8 cells + @ ;
: ptline   voxelctx 9 cells + @ ;
: yline    voxelctx c cells + @ ;
: pyline   voxelctx d cells + @ ;
: lod      voxelctx 14 cells + ;
: hmask    voxelctx 15 cells + ;

variable vdir  1 30 fp 0 c0 fp xy vdir ! ;
: resetyclip  yclip 28 77777777 fillcells ;
: voxlines    FOR AFT dup zline !  voxelctx voxelzline 1 + THEN NEXT ;

: move_vpos vdir @ viewpos @ xy+ viewpos ! ;

: render_voxel
  resetyclip
  voxelctx walksightlines
  chunkybuf 12c0 0 fillcells
  1
  3 lod !  4 voxlines
  2 lod !  5 voxlines
  1 lod !  6 voxlines
  0 lod !  8 voxlines
  drop
  c2m
;

: do_voxel
  2 efxspos < IF 'nextefx @ execute exit THEN
  render_voxel move_vpos
;

variable vangle
variable zdist  480 zdist !
variable panspeed
variable vrange 80 vrange !
: do_panvoxel
  panspeed @ vangle +!
  vangle @ 6 rshift vrange @ - zdist @ polar2xy ldir !
  vangle @ 6 rshift vrange @ + zdist @ polar2xy rdir !
  do_voxel
;



variable greetidx variable gypos
: greetstring greetings swap cells + @ ;
: textw       strlen 2 lshift ;
: msgxpos     textw a0 swap - random ff and * 8 rshift ;
: conflict?   gypos @ - abs 40 < ;
: rand0..1c0  random fff and 1c0 * c rshift ;
: greet@      greetidx @ greetstring ;
: greet+      greet@ strlen IF 1 greetidx +! THEN ;
: gscraddr    vbase@ gypos @ a0 * + greet@ msgxpos + ;
: nextgypos   BEGIN  rand0..1c0 e0 + dup conflict? not IF gypos ! exit THEN drop AGAIN ;
: nextgreet   nextgypos gscraddr a0 greet@ wdrawtext4x  greet+ ;

: beatpos      mf 3 rshift ;
: handle_beat  beatpos obeatpos @ = not IF beatpos obeatpos ! nextgreet THEN ;
: do_greetings
  6 efxspos < IF 'nextefx @ execute exit THEN
  handle_beat
  render_voxel move_vpos
;



: s0  ;
: s1  0 a drawmsg ;
: s2  0 b drawmsg ;
: s3  1 c drawmsg 0 clrmsg ;
: s4  1 d drawmsg ;
: s5  2 e drawmsg 1 clrmsg ;
: s6  2 f drawmsg ;
: s7  2 clrmsg ;

create script ] s1 s2 s3 s4 s5 s6 s7 s0 [ 0 ,
: scriptstep script scriptpos @ cells + @ ?dup IF execute 1 scriptpos +!  THEN ;

variable obeatpos
: beatpos      mf 5 rshift ;
: handle_beat  beatpos obeatpos @ = not IF beatpos obeatpos ! scriptstep THEN ;

: do_credits
  3 efxspos < IF 'nextefx @ execute exit THEN
  handle_beat samplebuf xyoscibuf 10 draw_xyosci rendertitle nextphase ;



: credits
  chunkybuf 12c0 0 fillcells c2m c2m c2m c2m
  0 scriptpos !
  xtalit do_credits efx  xtalit bye 'nextefx ! ;

: backvox
  cls
  70 0 fp 22 0 fp xy viewpos !
  fe 30 fp fe c0 fp xy vdir !
  1f hmask !
  10 negate vangle !
  480 zdist !
  1 panspeed !
  vrange a0 vrange !
  xtalit do_panvoxel efx  xtalit credits 'nextefx !
;

: greetings
  cls
  40 0 fp b0 0 fp xy viewpos !
  ff80ff80 vdir !  1000 ldir !  10000000 rdir !  0 hmask !
  xtalit do_greetings efx  xtalit backvox 'nextefx ! ;
;

: voxflash
  cls
  40 0 fp b0 0 fp xy viewpos !
  1 30 fp 0 c0 fp xy vdir !
  xtalit do_voxel efx  xtalit greetings 'nextefx ! ;

: slowvoxel
  10 0 fp 10 0 fp xy viewpos !
  0 40 fp 0 40 fp xy vdir !
  100 negate vangle !
  10 panspeed !
  xtalit do_panvoxel efx  xtalit voxflash 'nextefx ! ;

: title
  bls
  xtalit do_title efx  xtalit slowvoxel 'nextefx ! ;

home cr cr cr cr cr cr cr cr cr
startmod
1 playing !
title
