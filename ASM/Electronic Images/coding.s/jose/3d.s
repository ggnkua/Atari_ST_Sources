;
; This goes to viewrz directly...  No camera calcs...
;

os              EQU 0           ; 1 leave interrupts on.  0=off.

scx             EQU 159
scy             EQU 99

; Note it has been changed to the ASL method for 32 hither).
hither          EQU 32          ; Nearest to viewer Z clip window.
yonder          EQU 32767       ; Furthest to viewer (no object) window.

;*  OBJECT FLAGS (at offset 22) at the moment - 16 bits.
;*  BIT 0  -> Self rotating object (1) or not (0).
;*  BIT 1  -> Force maximum Z (1) or not (0).  Used for roads etc.

;
; Solid 3D with Z clipping by Jose Miguel Commins of The Games Forge.
; A.K.A.  The Phantom of Electronic Images!
; PLUS (let's not forget)   Russel Payne.      (The masked programmer)
;                           Martin Griffiths.  (Griff of Electronic Images)
;                           Ben Griffin.       (Yama of Electronic Images!)
;                           Beaky the Budgie   (Currently in a cat)
;
;
;
; Updates are in reverse order; that is, the most recent are commented at the
; top.
; To avoid confusion, from now on, anything above 'Version xx' will be the
; relevant information to that version, not below it!
;
; ---------------------------------------------------------------------------
;
; Darn!  There's summat odd about the offscreen check...  Hmmmm!
;
; Jose here...  Aha!  I took a leaf out of the new line clipper's book, and now
; the Z clipper is nice and short, and faster too!  It works the same way as
; the divide one, but none of that best maths crap now; instead it checks for
; the longest extent of the line past the Z clip plane - this way we have a clip
; as accurate as the normal way, and coherent (no breaks) still!  Wahey!!  Now
; it'll work REAL well in a cache (code needs changing for that though!!)!
;
; Yikes!!  Oops!  The horizon routine didn't have an RTS at the end of it
; (Agg!  Not *again*!!), so after slapping myself, I put it in!!  Argghhh!
; It fell through to the blitter routine!!  Aiiieee!
;
; Well, I put in Z clip smoothing in...  It's not THAT smooth but at least it
; stops the polygons from 'disjointing' from their original shape.  It is a
; scale less (*2) than maximum just in case there are bigger objects...
;
; Cap'n Smoothe on the case!  Aharr!  After the colossal battle between The
; Jerkman and I, he was defeated after successive 32-bit-divide blows!  (Takes
; pill)  Right, after a while I put in 32 bit divides (oh well...) in the
; horizon routine to calculate the perspective.  This means that the line
; coordinates for the horizon can be huge (+-7000 now), making it loads smoother
; although being about twice as slow (sigh); that's negligible since it only
; replaced a normal perspective divide thingie anyway!!  There's a few things
; I should clear though...  It has lots of Easy Rider 'L000' labels.  This is
; because (look at the length of the code!) I saved typing time by doing the
; routine in Devpac3 using macros, then disassembling the code!!  I did the
; same with Russ's polyclipper, as it saved re-naming the labels (Turbo doesn't
; support local labels...  Sigh...).  Now, the routine does the 32 bit divide
; (which caters for overflow!) for the perspective, yielding massive values for
; low Z values; it therefore has to scale them to within 32768 for the clipper
; to handle.  Oh, and it uses unsigned values for greater accuracy.
; That's it!  JoSe.
;
; Jose yet again...  Err now uses a 32 bit coordinate system!  It only considers
; drawing objects if they are within 16 bits (rotation limitations), and anyway,
; they'd be too small to see anyway!  As Marty poos said, I got to speed up the
; object-in-range check thingie, since it does quite a few checks now...
;
; Thigh and buttock!  A little 'problem' I found in the raster convert needs
; solving and making the horizon smoother...
;
; Jose again...  I looked at Russ's poly clipper for the rounding lark, and
; saw a 'best maths' method where it uses the greatest length for the
; calculations (bloody obvious when you look at it!!), and thus that does the
; 'rounding' for the Z clipper!  Wahey!
;
; Jose 'there's always a bug' McThigh here...
; Right, finally I get to write something!!  After a few (!) changes I split the
; data tables for the routines so now they are included with the routines so
; there's no need to look for that buggering polygon filler table all over the
; place; it's now with the polygon filler - the same goes for all the other
; routines.  Contrary to what was expected, it actually comes out slightly
; slower since some routines need a JSR now!  Waaaah!  I also changed the Z
; clipper so it uses similar triangles instead of midpoint subdivision - it's
; faster, seems to jitter less (!!) and it's for post-paranoid programmers - i.e
; it won't lock up if you fuck up (slogan #2, available in record shops).  There
; is *one* downside, in that the roundoff errors rear their ugly head, resulting
; in polygons sharing the same point 'splitting' from each other...  Ah well...
; Err, what's more...  Ah yes, I put in a road flag so it forces whatever to the
; first sort position; I might change it so you can include *what* sort position
; you want...  May be handy for going inside buildings..?  Because of the bloody
; clockwise checker which gets 'confused' at the 0 boundary, I put in a 'face
; adjust' value - you can tweak a face so that it can be visible from a distance
; or completely flat - nice for roads and shadows!
;  There's now the (trumpet salute) HORIZON ROUTINE included!  It's bloody fast,
; works with anything and is a fucking massive piece of code to do fuck all!
; Ben suggested I fill the insides of the horizon 'triangle' with MOVEM's...  To
; make that work faster than the poly filler added 25K of thunderingly fast code
; that sometimes causes interference on the radio!  Sigh...  I still have the
; version which calls the poly filler for the triangle bit...  Who knows if that
; is any faster on a cache (doubt it - well, hope not, cos this one was a right
; pain in the tits to code); one day I'll try it on oz's 040!
;
; - Version Z4 -
;
; Jose again!  Err, sped up the line clipper a bit so it uses the carry bit
; to determine wether a line is out (it subtracts the clip boundaries, then does
; a ROXL to obtain wether it was in/out!) - it doesn't use a CMP and BGE, so
; making it about 4 cycles faster per bound check.  I got the idea from the book
; 'Computer Graphics - Principles and Practice' - I might have done it before,
; but I forgot that a SUB instruction affects the carry/extend bit!!  Sigh...
; Right, I also commented the circle manager and circle generator, as I meant to
; do when I wrote it!  MooooOOO...
;
; Just a note...  If the Hither value is a power of 2 (2,4,8,16,32,64...) then
; the Z clipper can be sped up by quite a bit per clipped point.  Since Z is
; constant at the clipped plane, there's no need to do DIVS's after the ASLs #8;
; e.g. we need only use (in the case of Hither=64) an ASL #2, and no divides!
; Jose (still fighting with the horizon!).
;
; Phew!  At the request of Ben (and I wanted it too!) I re-vamped the way the
; objects are handled etc. thus saving space and unnecessary data copying, so
; it is faster too!  Object data definitions now only have a width to them,
; since it did not need the object's XYZ position or angle because the object
; list contained that information!  Instead of JUST having the width defined
; (apart from point and polygon data that is!) I left 8 bytes of reserved space
; for future expansion (8-view, ground/air object etc etc).  It is now simpler
; to access an object's view-rotated position; instead of waiting it to be drawn
; all you have to do is look at the oblist (note the missing obx,oby,obz...).
; Also (cor! more!) I thought I might as well extend the Z clipper flag - it now
; is OBJECT_FLAG, with bit 0 (of a 16-bit number) signifying if a Z clip is
; needed or not.  I did this so we can chuck in anything that comes to mind,
; like using the screen bound check to see if the object is 'on target' etc!
; Last, but not least, I threw Russ's treesort away, and replaced it with a
; faster quicksort routine (it uses loads less memory too!), which can be VERY
; easily expanded to use 32-bit numbers!  Waheyy!  It was quite a big change
; (sure bloody was!), but again, worth it!
; Jose.
;
; - Version Z3 -
;
; (To avoid confusion, from now on, anything above 'Version xx' will be the
; relevant information to that version, not below!  That's from above onwards!)
;
;
; Overflow checks on object position are now in operation!!  Now there's no
; duff mirror image objects due to overflow on large distances (since 32767
; * 3 and then a X2 for quick divide down will overflow it!!!).  It is now
; quicker too since the dummy adds have been removed since there are now two
; separate rotate routines.
;
; Err, fixed the raster convertor...  Removed the subq.w #1,poly_height...  Was
; a remnant from a change a while ago...
;
; Bugger, I forgot to mention it!  It had for some time (I think on the Zn ones)
; the (new) lightsource routine...  Ben improved it and it's bloody fast (9 muls
; and a divide per face!!!) and ONLY calculates lightsourcing on visible polys
; (the golden peanut runs about 50% faster now!!).  It also doesn't fuck up when
; the object moves from 0,0,0 (!!).  Objects have an extra value per face
; determining the lightsource range (the same value used for circle widths,
; since circles can't be lightsourced) which gets added on to the colour...  So
; we can have any number of shades for any face, all independent of each other!
; To speed things up, the lightsource range is an inverse multiply, so instead
; of a value of 10, it's 65535/10.
; Wheee!
;
; Has the 'new' camera routine with the 3-divide square root!  Note that it has
; to be ranged to a smaller triangle since the approximation of the root uses a
; 2^n calculation, so triangulation must occur sooner...  Still, 3 divides and
; just as accurate as the other one!  Old camera routine is OLDCAM.S in case...
;
; Jose here...  Changed the midpoint subdivision in the Z clipper to use WORD
; values, making it about 50% faster.
;
; Yikes!  BIIIIIGGG bug!  I (Jose) left...  Errr...  Umm...  A little typing
; error which meant that the (individual) object rotations were wrong!!  I also
; took out an unnecessary bit as well (2 lines!)...  Well it works now!!  Well,
; anyway, it means that if someone DID steal the source, they have a dodgy one!
;
; Improved camera routine!!
;
; Version 2W (more advanced than the Zn series (that sounded a bit techy!!)):
;
; Oh, it seems the raster converter is slightly inaccurate...  I dunno but it
; seems the last line (sometimes) is wrong...!!!!  It never gets displayed, but
; I dunno...
;
; Oops!  Jose here...  Removed a little 'bug' - the raster converter subroutine
; did not have an RTS at the end of it thus filling TWO polys!!!  Agg!  It now
; runs twice as fast!!!   Oh, also idividual object rotations now work!!
;
;
; Jose here, REALLY pleased and happy and all fluffy and wonderful!!!
;  Well, I said 'Ben, it's not that hard!' (oo-er) to do a world-movement system
; and it wasn't!!!  Well, first, here's what this version has...
;
; Full world coordinate system with sorting.
; Camera routine (optional) with looking from-looking at calculations (that's
; Ben Griffin there, coo!).
; Full world movement with virtual from-to movement (ha!)!
;
;  Well, here's how the movement system works (Ben, if you're reading this, it
; was just as I said, and it doesn't even need the camera routine!!!):
; The mouse, as usual, changes the viewer's X and Y angle.  Well, somewhere in
; memory we have a line from 0,0,0 to 0,0,1000 (looking forward).  The line end
; (the 0,0,1000) gets rotated according to these angles.  Since the line's
; origin is always 0,0,0, we need not store this, or include the origin in the
; delta calculations, since subtractiong 0 always is useless!  Then we find out
; the slope of the line in both X,Y and Z.  Now, when we 'move' these slope
; values get added to our viewer position in the X Y and Z.  The line where we
; calculate the slope from NEVER moves from the origin, it is just used for the
; slope, according to the view angles, and since we are taking the view angles
; directly to rotate the line, we don't need a camera routine, since we are
; moving the way we are facing.
;  Now, I did another version which takes an abolute view from the line, but
; this one is simpler + faster.  The other one what it did was basically the
; same thing, but passed on the line from (VIEWER POSITION) to (VIEWER POSITION
; + LENGTH OF (ROTATED) MOVEMENT LINE) to the camera routine.  Geddit?  So the
; camera routine would take our XYZ position and where we are going to and
; return the appropiate viewer angles.  This means that the mouse had to alter
; the movement line's angles, not the viewer's ones (as the camera routine would
; have to tell us those!).  Phew!  Anyway it works fantastic, and if Ben is
; reading this, I'll just say that I'm glad I did it for you!!!
;
;
; (Jose) Took out the keyboard 'bug' in the mouse handler.
;
; Jose here...  Right!  After bloody millenia I've put in:
; A line drawer (almost - still have to finish it!).
; A fully-clipped-and-all-the-trimmings circle generator!!!
; And I split the polygon filler and raster convert and some other things so
; it's easier to change (say, to another rez or 'pooter) to subroutines.
; Russ's polygon clipper, and indeed, the circle generator, take the clipping
; coordinates from the line drawer window.  Unfortunately I think Russ's clipper
; can't clip to top or left window coords (I mean, apart from zero!), but now
; it uses the other coords anyway!!
; WARNING!!  I made a bloody cheat since the circle clipper was getting on my
; tits and I sort-of went chicken!  Because of the case of the left and right
; sides being partially outside of the window (e.g. a pot-belly sticking out
; from the side of the screen!) I had two choices:  clip the bugger while
; generating it, or ignore it and be naughty and extend the line filler table
; so that the out-of screen coordinates are in reverse, thus self-clipping
; the circle!!  Now, I'm not sure if it is actually quicker or not (I have
; a feeling it's quicker if it's in the circle generator...), but after my
; hair stood on end when watching those cycles fly past...  Err...  Mebbe I
; should do half-tables...  Hmmm!  Actually, on second thought, (this is 1
; minute after saving this!) that'll REALLY slow it down because of the Y
; clipping, since you'd have to include it for every point...  And if Martin is
; reading this, I'm *NOT* making a huge jump table!  You'll see why!!
;
; Jose here...  Agg!  Ben found out a REAL big bug that was a consequence of the
; viewer/object rotation modifications.  He noticed that I was re-calculating
; perspective every time a new poly used a similar corner!!  Example...  It
; would do an extra 4 divides PER CORNER on a cube, since the adjacent polygons
; were using the same adjacent vertices!  Agggg!  Well, now it's solved!  It's a
; tiny piece of code (about 10 lines); I think I'll try and attempt the same for
; the Z clipper...
;
; Jose here...  Solved the crappy X and Y screen boundary checks...  Only
; an extra 30 cycles methinks on worst case.  Mind you, you can restore it
; to the normal checks so that the 'bug' is used so that when half of the object
; goes by, it rejects it (*NOT* recommended on roads!)!!
;
; Version Z8:
;
;  I put in frame-compensation under mouse control and NO divides or multiplies
; to get frame compensated value (has the restriction that your incremental
; value cannot be bigger than 255, and delay between frames is no longer than
; 10...  As in every 1/5 of a second (0.2)).
;  I also put in combined viewer/object rotation!  Object structure has a new
; value at offset +14.  It is OBJECT FLAGS.  Current flags are:
; Bit 0 : Set if object has own rotation.  Not set if non-rotatable.  This saves
; on about 27 multiplies (or more I think!) per object (NOT point!) since view
; matrices and object matrices are not combined when object is non-rotatable.
; Because of the view rotation, Z clip and screen boundary checks have to take
; the object's X,Y,Z position (in object structure) and rotate it.  The rotated
; point is stored independently as the rotated X,Y,Z coordinates so as not to
; alter the object's position.  This way we know the object's position after
; view rotation (otherwise checks would fail as the actual 'object' has no
; position in itself).
;  I'm still waiting for ben's B-Splines and see if we can make objects with
; them since there is no rotation involved apart from the control points!  Also
; I am waiting for the de-bugged lightsource (Ben again!) since the old one only
; worked properly if the object was at origin 0,0,n.  Also I'll edit this soon
; enough so as to include line drawing (with the new cooey line drawer!).  Must
; remind myself that I gotta use the modified Z clipper in me file BIGRLTS2.
;
;
; Versions Z7 and below, below!  Err Jose here this was 'old' commenting!
;
; Phew!  Solved the backface removal 'bug' on the Z clipper; now I re-center
; the Z rotation around origin 0 not the current Z value (huh?)!!
;
; Hmm...  I put in a face check in the Z clipper, so it does NOT clip the
; faces that are not visible.  The downside of this is that zclipped faces
; take 3 scanlines more (6 divides and two multiplies extra)...  Hmm may be
; time to use table perspective!!!  The good thang is that half the object is
; not zclipped (which takes about 8 screenlies per face!!!).  Ooh!
; Oh, watch out with divisions by zero on the zclip face check.
;
; Changed the Z clipper and Zclip rotation output so it handles 'standard'
; lists of X,Y,Z...  Still the same speed though!
;
; Right...  Found the 'bug' in the Z clipper.  Actually the Z clipper is perfect
; and works exactly as it should.  It is only when two similar points lie on a
; plane that it does the 'flicker'.  This is due to the CLOCKWISE CHECKER (not
; the Z clipper) working on the small differences involved.  This is too small
; on near ranges, but if a flicker-free clockwise check is needed (when the
; hither plane is about >1000) then scale up the resulting coordinates and make
; sure they are put back to normal AFTER the clockwise check!!
;
; Now has the faster Z clipper - it's rather longer than the old one, but thanks
; to the 'part' thingie I just found out it doesn't get in the way too much now!
; The fully commented Z clipper is ZCLIP.S.
;
; Oops!  Removed a slight bug in the hash filler...  The odd error lines that
; I noticed are now gone!!
;
; Hmm...  Martin's Hline thingie...  It's 4 cycles faster on >1 chunk hlines,
; but 4 cycles slower on <1 chunk hlines!  Hmm...  So I dunno...  Which are
; drawn more?
;
; For even MORE code the hash line filler is now 8 cycles faster per scanline.
;
; Now with a sliightly faster matrix generator...  Might as well!
; Can gain an extra 4 cycles per scaledown by replacing:
; ADD.L Dn,Dn
; SWAP Dn
; By:
; SWAP Dn
; ADD.W Dn,Dn
; But I left it out since you lose one bit accuracy, and since it's not very
; much difference, I thought I'd have 36 cycles more per update than lose one
; bit accuracy.  Mind you, when you have about 8+ objects to display, then do
; the above, then it will be worth it!
;
; Now with hash filling!!!  FULL hash filling!  It is about 15-20% slower than
; the normal fill, due to the way you have to mask the bugger!  There are TWO
; hash definitions, even though you can rotate the first line's hash to get
; the second, I did two hash definitions since that allows you to have different
; types of patterns (even though they are 2 pixels high).  Hashes are defined
; from colour 16 (inclusive) onwards...
;
; Now with side edge tests - it discards the object if it is not within the
; viewer's window.  Checking is done BEFORE Z check.
;
; Now with frame compensation (using timer D mind!).
;
; Now with full Z clip tests...  Doesn't do the time consuming Z clipping
; calculations when the object is either in front or behind the clip window.
; If it is behind the window (totally invisible) it doesn't even bother
; rotating the object etc etc!
; Also does the yonder plane...  Does not zclip the object, but just makes
; it disappear.
;
; I now have the object's XYZ position, width and angle of rotation in the
; object data itself...
;
; Call me 'length'!!  I had to knock out the *4 thing in the coordinate
; calculations, slowing the hline by 8 cycles (waah!).  So I thought (hah!),
; "Why not do *4 in the raster convert?"  So I did - no overflow probs etc
; and it's now back to its normal, lightning speed!
;
; Removed the additional Zbuffer space so now it only copies twice instead
; of three times.
;
; Zclip still needs optimizing (I did a bit of it though!)...  I need macros!
;
; To avoid a Zclip test on eveything it's best to put in the object's XYZ world
; coordinates and its width somewhere...
;
; Solved the 'problem' in the Zclip - oops!  I was putting in a WORD destination
; value when I should have used a longword hither...  That meant that the upper
; word of D0 could have contained anything!
; It's a 32-bit midpoint because if you do 32767+32767 then you'd overflow, and
; 32767 is the max coordinates an object can reach!
;
; NOW WITH Z CLIPPING!  (Puff puff, hard work!)  Needs optimizing!
;
; Solid 3D (this one 8 cycles faster per hline using a really neat idea
; by Russ to make X be multiples of 4!)
;
; Made a bit faster by me changing the right edge Y to a negated screen
; chunk, so it jumps back through the drawer table.
;
; This one using Martin's ADDX way to get the gradients.  Slightly faster
; but it took me a whole fucking day to get it working using 8 registers
; U BASTARD Martin I'm going to killlll youuuuu.
;
; All code by Jose Miguel Commins, but I must add that it wouldn't be so
; fast so soon if it weren't for these luvly peepl who pooled ideas:
; Russ Payne and Martin Griffiths.  Where it's due:
; Russ: *4 technique and 'copy branch back' bit in line filler.
; Also the saving a BRA cont in the line filler (12 cycles).
; Martin: ADDX gradient calculations and (without him realising it worked)
; the single MULS way to get the gradient int and frac bits.
;
; So really, this is the fruit of our combined loins! (disgusting)
;
; Using Russ's polyclipper, which only clips the bits that are off the
; edges - but you need to scan for the MaxX MinX MinY Maxy of the object.
;
; Added the 'missing line' on the raster convert.
;
; Changed the coordinate duplication to where it checks for maximum Y
; so it's a bit faster (Martin's suggestion).
;
; I relocated the chunk 1 routine saving a last BRA and now on big polys
; it falls through on conditional branches saving umm 8 cycles me thinks!
;
; Polygon raster convert now much simpler and faster too since it does
; the two edges separately, not needing to check for manky edges!
; Martin said he uses it, and I saw the light - coo!
;
; After many hours of sweat and tears (sob!), Russ and I concluded that
; the ADDX.L way of getting the gradient is too dodgy since it overflows
; and corrupts the values easily, plus in certain cases it completely
; negates a zero value when it should stay the same.  So we stick to normal
; ADD.W and ADDX.W.
;
; Umm added extra space for the line edges tables because otherwise the
; first would overwrite the second!
;


                clr.l   -(SP)
                move.w  #$20,-(SP)
                trap    #1
                addq.w  #6,SP
                move.l  D0,oldsp

                move.l  #divzero,$14.w

*       move.b  $ffff8201.w,scrn2+1
*       move.b  $ffff8203.w,scrn2+2

                lea     screens,A0
                lea     256(A0),A0
                move.l  A0,D0
                clr.b   D0
                move.l  D0,scrn1
                add.l   #32000,D0
                move.l  D0,scrn2
                add.l   #32000,D0
                move.l  D0,scrn3

                movea.l scrn1(PC),A0
                move.w  #5999,D0
                moveq   #0,D1
clean:          move.l  D1,(A0)+
                move.l  D1,(A0)+
                move.l  D1,(A0)+
                move.l  D1,(A0)+
                dbra    D0,clean

                move.w  #37,-(SP)
                trap    #14
                addq.w  #2,SP
                clr.b   $FFFF8260.w
                move.w  #37,-(SP)
                trap    #14
                addq.w  #2,SP
                move.b  #1,$FFFF8260.w
                move.w  #37,-(SP)
                trap    #14
                addq.w  #2,SP
                clr.b   $FFFF8260.w

;               movem.l station+4,D0-D7
;               movem.l D0-D7,$FFFF8240.w
                lea     $FFFF8240.w,A0
                move.w  #$00,(A0)+      ; 0
                move.w  #$07FF,(A0)+    ; 1
                move.w  #$0277,(A0)+    ; 2
                move.w  #$0677,(A0)+    ; 3
                move.w  #$0543,(A0)+    ; 4
                move.w  #$0654,(A0)+    ; 5
                move.w  #$0432,(A0)+    ; 6
                move.w  #$0444,(A0)+    ; 7
                move.w  #$0710,(A0)+    ; 8
                move.w  #$0720,(A0)+    ; 9
                move.w  #$0730,(A0)+    ; 10
                move.w  #$0740,(A0)+    ; 11
                move.w  #$0750,(A0)+    ; 12
                move.w  #$0F73,(A0)+    ; 13
                move.w  #$0F43,(A0)+    ; 14
                move.w  #$0FFF,(A0)+    ; 15

                move    #$2700,SR

                move.l  $70.w,oldvbl
                move.l  #vbl,$70.w
                move.b  $FFFFFA07.w,sa1
                move.b  $FFFFFA09.w,sa2
                move.b  $FFFFFA15.w,sa3
                move.b  $FFFFFA1D.w,sa4
                move.b  $FFFFFA25.w,sa5
                clr.b   $FFFFFA07.w
                clr.b   $FFFFFA09.w

                bclr    #3,$FFFFFA17.w

                move.l  $0110.w,dsave   ; Install difference counter.
                move.l  #divzero,$0110.w ; A dummy RTE
                ori.b   #%10000,$FFFFFA09.w
                ori.b   #%10000,$FFFFFA15.w
                move.b  #7,$FFFFFA1D.w
                move.b  #0,$FFFFFA25.w  ; 48 Hz.

                move.l  $0118.w,oldkey  * Save old keyboard handler.
                move.l  #khand,$0118.w
                ori.b   #%1000000,$FFFFFA09.w
                ori.b   #%1000000,$FFFFFA15.w * And install mine.

                lea     init,A0
                jsr     ksend           * Enable joysticks & off mouse!

flush2:         btst    #0,$FFFFFC00.w
                beq.s   fl_done2
                move.b  $FFFFFC02.w,D0
                bra.s   flush2
fl_done2:                               * Purge keyboard buffer!
                move.b  #$FF,keybyt

                move    #$2300,SR

                jsr     setlight


key:


                move.b  lcount(PC),D0
                bne.s   over
sync:           cmp.b   lcount(PC),D0
                beq.s   sync

over:           clr.b   lcount
                move.l  scrn2(PC),D0
                lsr.w   #8,D0
                move.l  D0,$FFFF8200.w
                move.l  scrn1(PC),-(SP)
                move.l  scrn2(PC),scrn1
                move.l  scrn3(PC),scrn2
                move.l  (SP)+,scrn3


*                move.w  #$03,$FFFF8240.w

                andi.b  #%11110000,$FFFFFA1D.w
                moveq   #0,D0
                move.w  step(PC),D0
                move.b  $FFFFFA25.w,D0
                clr.b   step+1
                move.w  fstep(PC),D1
                move.w  D0,fstep
                clr.b   $FFFFFA25.w
                ori.b   #%101,$FFFFFA1D.w
                sub.w   D0,D1
                ext.l   D1
                lsl.l   #8,D1
                divu    #310,D1
                move.w  D1,unit

*                clr.l   number
*                move.w  D1,number+2
*                move.b  #0,txpos
*                move.b  #180,typos
*                bsr     conv

*                tst.w   D2
*                bmi.s   ohno
*                cmpi.w  #$C8,D2
*                bge.s   uok
*ohno:
*                move.w  #$C8,unit
*                move.w  #$0300,$FFFF8240.w
*uok:

                moveq   #1,D0
                mulu    unit(PC),D0
                mulu    #330,D0
                swap    D0
                subq.w  #1,D0
                bge.s   d0ok
                moveq   #0,D0
d0ok:

                lea     frametab,A0
                lsl.w   #8,D0
                add.w   D0,D0
                lea     0(A0,D0.w),A0
                move.l  A0,whichtab


                movea.l whichtab,A0
                move.w  rotatex(PC),D0
                move.w  D0,D1
                sub.w   oldrx(PC),D0
                move.w  D1,oldrx
;                bsr     getframe       ; Mouse doen't slow down 'frame rate'!!!
                move.w  D0,usery

                move.w  rotatey(PC),D0
                move.w  D0,D1
                sub.w   oldry(PC),D0
                move.w  D1,oldry
;                bsr     getframe
                move.w  D0,userx

                movea.l curr_obj(PC),A3
                move.w  #5,D0           ; Object X angle.
                jsr     getframe
;                add.w   D0,(A3)
                move.w  #2,D0           ; Object Y angle.
                jsr     getframe
;                add.w   D0,2(A3)
                move.w  #10,D0          ; Object Z angle.
                jsr     getframe
;                add.w   D0,4(A3)

;                move.w  #1,D0
;                bsr     getframe
;                sub.w   D0,12(A3)

;                addq.w  #7,arse+4


*** Camera looking at shite.

;                movem.w rotline+6(PC),D0-D2
;                sub.w   rotline(PC),D0
;                sub.w   rotline+2(PC),D1
;                sub.w   rotline+4(PC),D2
;                ext.l   D0
;                ext.l   D1
;                ext.l   D2
;                bsr     camang
;                exg     D0,D1
;                movem.w D0-D2,viewrx

*****


;                move.w  userx(PC),number+2
;                move.b  #30,txpos
;                move.b  #180,typos
;                bsr     conv

*                move.w  #1,userz

*                move.w  unit(PC),D1

                move.b  #0,txpos
                move.b  #0,typos
                move.w  D1,number+2
*                bsr     conv

;                movea.l scrn2(PC),A0
;                lea     32000(A0),A0
;                move.w  #200,D7
;                jsr     cls

;                move.w  #2,blt_s_xinc
;                move.w  #2,blt_s_yinc
;                move.l  #station+36,blt_s_addr
;                move.w  #2,blt_d_xinc
;                move.w  #2,blt_d_yinc
;                move.l  scrn2(PC),blt_d_addr
;                move.w  station,D0
;                mulu    station+2,D0
;                lsr.l   #1,D0
;                move.w  D0,blt_xwords
;                move.w  #16000,blt_xwords
;                move.w  #1,blt_ywords

;                move.w  #$FFFF,blt_emask1
;                move.w  #$FFFF,blt_emask2
;                move.w  #$FFFF,blt_emask3

;                move.b  #2,blt_halftone
;                move.b  #3,blt_logical

;                move.b  #%1000000,blt_skew
;                move.b  #%11000000,blt_op
;                bsr     use_blitter


                movem.w userx(PC),D4-D6 ; Add mouse to view angles.
                add.w   D4,viewrx
                add.w   D5,viewry
                add.w   D6,viewrz


*       move.w  #$004,$ffff8240.w

                >PART 'frame compensates and rotation'

; First we make the general view matrix!
                move.w  viewrx(PC),D0   ; X angle.
                move.w  viewry(PC),D2   ; Y angle.
                move.w  viewrz(PC),D4   ; Z angle.
                lea     view_matrix(PC),A0
                jsr     make_matrix

                jsr     do_horizon


; Now lets read our objects in and pass them on to the sorting routine.
                lea     objects(PC),A6  ; Start of sort/visible list.
                lea     oblist(PC),A4   ; Our object list.
next_object:    move.l  (A4),D0         ; Get object pointer.
                bmi.s   end_ob_list     ; Last object?  End of list if so.
                beq.s   ob_dead         ; Check if object disabled.
                movea.l D0,A3           ; Else this is object address.
                bsr.s   check_object    ; Now check it.
ob_dead:        lea     30(A4),A4       ; And move on list.
                bra.s   next_object     ; Next object (if any).

end_ob_list:
                move.l  #-99,2(A6)      ; Signal end of list.

; After checking which are visible, sort the ones we see.
                lea     objects(PC),A0  ; Get start of list to sort.
                cmpa.l  A0,A6           ; See if no objects at all.
                ble     waitk           ; None, so don't draw squat!
                lea     -8(A6),A1       ; Point to last entry, not after!
                jsr     Quicksort       ; Sort 'em!

                lea     objects(PC),A0
draw_object:
                move.l  2(A0),D0        ; Get object list pointer.
                bmi     waitk           ; If negative, end of list.
                movea.l D0,A6           ; Else get pointer to oblist definition.
                move.l  D0,curr_listptr ; Store for any access within calcs.
                movea.l (A6),A3         ; First long is object data address.
                move.l  A3,curr_obj     ; Store for future ops.
                move.w  6(A0),object_flag ; Store Z clipper flag (!).
                move.l  A0,-(SP)        ; Its trashed, so...
                bsr     do_object       ; Now handle/draw it.
                movea.l (SP)+,A0
                addq.w  #8,A0           ; Move on sort/visible list...
                bra.s   draw_object


; This is where we actually translate and rotate the object and check if it
; is visible and/or needs Z clipping.
q_ob_out:       rts                     ; Dummy RTS for quick reject below...
check_object:

; See if object is within 16 bit range; if not, discard (too small anyway!).
                movem.l 4(A4),D0-D2     ; Get object pos.
                moveq   #0,D3
                move.w  (A3),D3         ; Get object width.
                sub.l   vxpos(PC),D0    ; Subtract view position.
                bpl.s   vlok1
                neg.l   D0
vlok1:          add.l   D3,D0           ; Add object width.
                cmp.l   #32767,D0
                bgt.s   q_ob_out
                sub.l   vypos(PC),D1
                bpl.s   vlok2
                neg.l   D1
vlok2:          add.l   D3,D1
                cmp.l   #32767,D1
                bgt.s   q_ob_out
                sub.l   vzpos(PC),D2
                bpl.s   vlok3
                neg.l   D2
vlok3:          add.l   D3,D2
                cmp.l   #32767,D2
                bgt.s   q_ob_out


; Rotate object's position into OBX,OBY,OBZ respectively so we can check
; if object is within Z clip area/screen boundary after rotation.
                lea     view_matrix(PC),A0 ; Matrix in A0.
                lea     4(A4),A1        ; Source in A1.
                lea     16(A4),A2       ; Destination in A2.
                lea     vxpos(PC),A5    ; Offset viewer position (word used).
                jsr     rotate_pos

                btst    #1,D7           ; Check for overflow (too far anyway!).
                bne     ob_out

                clr.w   object_flag     ; Make sure object flag is clear.

; Check object against screen boundaries by parallel projecting it and using
; the object's with to the X and Y.

test_y:
; Y check...
                move.w  16+2(A4),D0     ; Get Y position.
                bpl.s   posiy           ; Positive?  Skip.
                neg.w   D0              ; Negative...  Then make positive.
posiy:
                sub.w   (A3),D0         ; Subtract width.
                ext.l   D0              ; Make it longword.
                move.w  16+4(A4),D1     ; Get Z.
                bpl.s   notnegyc
                neg.w   D1
notnegyc:       cmpi.w  #256,D1
                blt.s   checky
                lsl.l   #8,D0
                divs    D1,D0           ; Divide by Z (project it).
checky:         cmpi.w  #scy+7,D0       ; Check it against screen Y + leeway.
                bge.s   ob_out          ; If outside, discard object.

test_x:
; X check...
                move.w  16(A4),D0       ; Get X.
                bpl.s   posix
                neg.w   D0
posix:
                sub.w   (A3),D0
                ext.l   D0
                move.w  16+4(A4),D1
                bpl.s   notnegxc        ; And for negative divide!
                neg.w   D1
notnegxc:
                cmpi.w  #256,D1
                blt.s   checkx
                lsl.l   #8,D0
                divs    D1,D0
checkx:         cmp.w   #scx+7,D0       ; Object is to eft or right of widow?
                bge.s   ob_out          ; Yep...  Don't rotate/draw it!

*                cmpi.w  #2,D2
*                bne.s   not_in_target
*                move.w  #$0700,$FFFF8240.w
*not_in_target:
test_z:
;                movea.l curr_obj(PC),A3

                move.w  16+4(A4),D0     ; Get Z position of object.
                sub.w   (A3),D0         ; Add width of object.
                cmpi.w  #hither+64,D0   ; Has it gone past clip plane?
                bgt.s   no_z_clip       ; No...  Don't clip.
                ori.w   #%1,object_flag
*                move.w  #$0700,$FFFF8240.w ; Yes...  Clip.
no_z_clip:
                cmpi.w  #yonder,D0
                bgt.s   ob_out

                move.w  16+4(A4),D0
                add.w   (A3),D0
                cmpi.w  #hither,D0
                ble.s   ob_out
;                bgt.s   not_past_plane
*                move.w  #$70,$FFFF8240.w
;                bra.s   ob_out
;not_past_plane:

; Right, at this point, we have sorted out the men from the boys, and only
; visible objects will pass through.
                move.w  16+4(A4),(A6)+  ; Store Z pos for sort.
                btst    #1,28+1(A4)     ; See if force flag is on.
                beq.s   chk_noforce     ; Nope, skip.
                move.w  #32767,-2(A6)   ; Else set max Z for sort (1st drawn).
chk_noforce:    move.l  A4,(A6)+        ; Store object list pointer.
                move.w  object_flag(PC),(A6)+ ; Z clipper flag (essential!).

; ob_out is jumped to if object is out of viewer.
ob_out:
                rts


;                move.w  #$0300,$FFFF8240.w




; Now hadle the object that we're told to draw.
do_object:

;                movea.l curr_obj(PC),A3 ; Get object pointer (so we draw the
; right one!)

; Err skip this, just from previous ones...  We already have view matrix done!
;                move.w  viewrx(PC),D0   ; X angle.
;                move.w  viewry(PC),D2   ; Y angle.
;                move.w  viewrz(PC),D4   ; Z angle.
;                lea     view_matrix(PC),A0
;                bsr     make_matrix

; Now we rotate all those points.
                move.w  28(A6),D0       ; Get object flags.
                btst    #0,D0           ; Check for object rotation.
                bne.s   ob_rot          ; Yep...  So go to combine matrices.
                lea     view_matrix(PC),A0
                bra.s   do_ob_rots      ; Else use view matrix only.

ob_rot:         lea     ob_matrix(PC),A0
                move.w  22(A6),D0
                move.w  24(A6),D2
                move.w  26(A6),D4
                jsr     make_matrix
                lea     tot_matrix(PC),A0
                lea     view_matrix(PC),A1
                lea     ob_matrix(PC),A2
                jsr     mat_mul
                lea     tot_matrix(PC),A0

do_ob_rots:
                lea     rotted(PC),A2   ; Get destination poly address.
                movea.l curr_obj(PC),A1 ; Get object address.
                lea     16(A6),A4       ; Coordinate offset.
                lea     10(A1),A1       ; Skip object data etc.
                move.w  (A1)+,D7        ; Get number of points -1.
                btst    #0,object_flag+1 ; Check if Z clipping.
                beq.s   norm_rots       ; Special Z rotation adds smoothing.
                jsr     rotate_zclipped_object
                bra.s   after_zrots
norm_rots:      jsr     rotate_object
after_zrots:    move.l  A1,currfc

; Pre-calculate perspective if not Z clipping.  This saves on doing the
; perspective more than once per corner (saving 2 divides per re-use!!).
                btst    #0,object_flag+1 ; Check if we are Z clipping...
                bne.s   z_clip_face     ; No...  Skip precalcs.
                move.w  10(A3),D3       ; Else get number of points in object.
                lea     rotted(PC),A0   ; Get rotated points address.
                lea     rotted_sc(PC),A1 ; Get translated points address.
do_perspective: movem.w (A0)+,D0-D2     ; Get X,Y,Z.
                asl.l   #8,D0           ; Scale up X.
                asl.l   #8,D1           ; Scale up Y.
                divs    D2,D0           ; Do perspective for X.
                divs    D2,D1           ; Do perspective for Y.
                add.w   #scx,D0         ; Add screen center to X.
                add.w   #scy,D1         ; Add screen senter to Y.
                move.w  D0,(A1)+        ; And store at rotated coordinates list.
                move.w  D1,(A1)+
                addq.w  #2,A1           ; Skip 2 bytes (null Z byte).
                dbra    D3,do_perspective

                ENDPART


                >PART 'poly faces and Zclip'

nxtface:
                btst    #0,object_flag+1
                bne.s   z_clip_face

; Select points and copy them to the polygon list.
                movea.l currfc(PC),A0   ; Get current face address.
                move.l  A0,thisface     ; Store for reference.
                lea     rotted_sc(PC),A1 ; Get translated points address.
                lea     poly(PC),A2     ; Get address where to copy to.
                move.l  (A0)+,colour    ; Get colour and type.
                bmi     noface          ; Negative - no more faces.
                movea.l A0,A6           ; Get address for later ops.
                move.w  (A0)+,p_data    ; Get width or data.
                move.l  (A0)+,D0        ; Get number of points (skips face adj).
                move.w  D0,(A2)+        ; Store at poly list.
dopnts:         move.w  (A0)+,D1        ; Get offset
                move.l  0(A1,D1.w),(A2)+ ; Store X,Y at poly list.
                dbra    D0,dopnts       ; Do for points.

                move.l  A0,currfc
                bra     cont_face


;
; Best maths version of similar triangles - new version here uses the greater
; extent of the line past Z clip for coherent results!  Oho!  I'm lengthy!
;
; Z clipper routine.  New and improved, it is greener and uses less of the
; world's resources by using 0.00000000001 volts less to calculate the Z plane
; clipped coordinates!  Nowadays I've been thinking of other processors (030 and
; 040) that have divides of 20 cycles (for 030) and 1 (for 040!!), which means
; that the midpoint subdivision routine is slower, since it will execute more
; instructions (loads more) and there's no more advantage over the divide (which
; takes a bloody 140 cycles on a 68000!!).  Even now, I think this way is faster
; than the midpoint!!  It seems more colinear too, resulting in less jitter; it
; is now impossible to lock the machine (since there's no midpoint routine to
; search for a number it can't find!), so there you go!
; Clips face at CURRFC (or one poly!).

z_clip_face:
                movea.l currfc(PC),A3   ; Get current face address.
                move.l  A3,thisface     ; Store for reference.
                move.l  (A3)+,colour    ; Get colour and type.
                bmi     noface          ; Negative - no more faces.
                cmpi.w  #2,type         ; Yikes!  Check for circle!
                beq     drawcircle
                movea.l A3,A6           ; Get adress for later ops.
                move.w  (A3)+,p_data    ; Get data.
                move.l  (A3)+,D0        ; Get number of points (skips face adj).
                movea.l A3,A5
                move.w  D0,poly         ; Store at poly list.
                addq.w  #1,D0           ; Adjust because of DBRA.
                move.w  D0,z_counter    ; Store in z clip counter.

                lea     rotted(PC),A0   ; Get rotated points address.
                lea     poly+2(PC),A1   ; Get link coordinates address.
                movea.l #0,A2           ; Set coordinate counter to 0.

                move.w  (A3)+,D0        ; Get link pointer.
                movem.w 0(A0,D0.w),D0-D2 ; Get X,Y,Z.
                move.w  (A3),D3         ; Get next link pointer.
                movem.w 0(A0,D3.w),D3-D5 ; Get next points' X,Y,Z.
                movem.w D0-D2,first_vals ; Store for wrap.
                bra.s   skip_mama       ; Skip loopback bit.

mama:           move.w  (A3)+,D0        ; Get link pointer.
                movem.w 0(A0,D0.w),D0-D2 ; Get X,Y,Z.
                move.w  (A3),D3         ; Get next link pointer.
                movem.w 0(A0,D3.w),D3-D5 ; Get next points' X,Y,Z.

skip_mama:      moveq   #0,D6           ; Line clip flag to 0.
                cmpi.w  #hither*8,D2    ; First point past plane?
                bgt.s   nozedp1         ; No...  Skip.
                bset    #0,D6           ; Yes, set clip flag 1.
nozedp1:        cmpi.w  #hither*8,D5    ; Second point past plane?
                bgt.s   nozedp2         ; No...  Skip.
                bset    #1,D6           ; Yes, set clip flag 2.
nozedp2:
                tst.w   D6              ; D6 = 0?
                beq     in_range        ; > Both points in range.

                cmpi.w  #3,D6           ; Both points out?
                beq     discard_both    ; Yep, discard line.

                btst    #1,D6           ; Point 2 out?
                beq.s   point_2_out     ; Yep, go clip that one.
                move.l  D1,D6           ; Else calc screen coords.
                move.l  D0,D7           ; Store 'em since used later for midP.
                asl.l   #8,D1           ; Scale up.
                asl.l   #8,D0           ; Scale up.
                divs    D2,D0           ; And do perspective (/ Z + Horizon).
                divs    D2,D1           ; And do perspective (/ Z + Horizon).
                add.w   #scx,D0         ; Add screen's X center.
                add.w   #scy,D1         ; Add screen's Y center.
                move.w  D0,(A1)+        ; Store screene'd X.
                move.w  D1,(A1)+        ; Store screene'd Y.
                move.l  D6,D1           ; Restore for midpoint calculations.
                move.l  D7,D0

                cmp.w   D2,D5           ; Check for largest extent.
                bge.s   z_ok1
                exg     D2,D5
                exg     D0,D3
                exg     D1,D4
z_ok1:
                move.w  #hither*8,D6
                sub.w   D5,D6           ; Zmax-Z2
                move.w  D2,D7
                sub.w   #hither*8,D7    ; Z1-Zmax
                sub.w   D2,D5           ; Z2-Z1

                sub.w   D3,D0           ; X1-X2
                muls    D6,D0
                neg.w   D5              ; Now Z1-Z2
                divs    D5,D0
                add.w   D0,D3           ; Add to X2

                sub.w   D4,D1           ; Y1-Y2
                muls    D6,D1
                divs    D5,D1
                add.w   D1,D4           ; Add to Y2.

;                asr.w   #1,D3           ; Scale up.
;                asr.w   #1,D4           ; Scale up.
                add.w   #scx,D3         ; Add screen's X center.
                add.w   #scy,D4         ; Add screen's Y center.
                move.w  D3,(A1)+        ; Store screene'd X.
                move.w  D4,(A1)+        ; Store screene'd Y.
                addq.w  #2,A2           ; Add 2 new points.
; Since 1 inclusive.
                bra.s   continue_zclip  ; Cont the clip.

point_2_out:
                cmp.w   D2,D5           ; Check for largest extent.
                bge.s   z_ok2
                exg     D2,D5
                exg     D0,D3
                exg     D1,D4
z_ok2:
                move.w  #hither*8,D6
                sub.w   D5,D6           ; Zmax-Z2
                move.w  D2,D7
                sub.w   #hither*8,D7    ; Z1-Zmax
                sub.w   D2,D5           ; Z2-Z1

                sub.w   D3,D0           ; X1-X2
                muls    D6,D0
                neg.w   D5              ; Now Z1-Z2
                divs    D5,D0
                add.w   D0,D3           ; Add to X2

                sub.w   D4,D1           ; Y1-Y2
                muls    D6,D1
                divs    D5,D1
                add.w   D1,D4           ; Add to Y2.

;                asr.w   #1,D3           ; Scale up.
;                asr.w   #1,D4           ; Scale up.
                add.w   #scx,D3         ; Add screen's X center.
                add.w   #scy,D4         ; Add screen's Y center.
                move.w  D3,(A1)+        ; Store screene'd X.
                move.w  D4,(A1)+        ; Store screene'd Y.

                addq.w  #1,A2           ; Add ONE new point to list.
; Since 1 is out.
                bra.s   continue_zclip  ; Continue Z clip.

in_range:
                asl.l   #8,D1
                asl.l   #8,D0           ; Scale up.
                divs    D2,D0           ; And do perspective (/ Z + Horizon).
                divs    D2,D1           ; And do perspective (/ Z + Horizon).
                add.w   #scx,D0         ; Add X screen center.
                add.w   #scy,D1         ; Add Y screen center.
                addq.w  #1,A2           ; Add ONE new point to list.
                move.w  D0,(A1)+        ; Store X.
                move.w  D1,(A1)+        ; Store Y.

continue_zclip:
discard_both:
                subq.w  #1,z_counter    ; Have we finished all points?
                beq.s   finished_z      ; Yep.  Go set new number of 'em.

                cmpi.w  #1,z_counter    ; No...  Last point?
                bne     mama            ; No...  Do Zclip.

                move.w  (A3)+,D0        ; Yes, so we get last point
                movem.w 0(A0,D0.w),D0-D2 ; and make the second end
                movem.w first_vals(PC),D3-D5 ; the first point.
                bra     skip_mama       ; And do the clip.

first_vals:     DS.W 3

finished_z:

                move.l  A3,currfc       ; Store next poly addr.

                move.w  A2,D0           ; Copy it to a data register.  Duuuh!
                cmp.w   #3,D0           ; Check if poly is outside the Z plane.
                blt     z_clip_face     ; Yep...  Don't draw it!
                subq.w  #1,D0           ; Now adjust No of points to DBRA.
                move.w  D0,poly         ; And store it.

*                bra.s   skipclock       ; Don't do another clockwise check!
* (Ahem!  Above was when I attempted an on-the fly-zclip clockwise check!)


cont_face:

                cmpi.w  #2,type         ; Check if single-point circle.
                beq.s   skipclock

; do clockwise / anticlockwise test
;
;
;       (a1) points to X1 Y1 X2 Y2 X3 Y3 etc etc after translation.

                movem.w poly+2(PC),D0-D5
                sub.w   D0,D2           ; P1x-P0x
                sub.w   D1,D3           ; P1y-P0y
; D2=Dx1 D3=Dy1
                sub.w   D0,D4           ; P2x-P0x
                sub.w   D1,D5           ; P2y-P0y
; D4=Dx2 D5=Dy2
                muls    D2,D5           ; Dx1*Dy2
                muls    D3,D4           ; Dy1*Dx2
                sub.l   D4,D5

                moveq   #0,D4
                move.w  2(A6),D4
                add.l   D4,D5
                ble     nxtface         ; Negative or zero = not visible.
skipclock:

                ENDPART


                >PART 'Object face manager'

;
; Handle the different types of drawing primitives.
;
                move.w  type(PC),D0
                beq     drawpoly        ; 0 = polygon.

                cmpi.w  #1,D0           ; 1 = Lightsourced polygon.
                beq     drawpoly_lightsourced

                cmpi.w  #2,D0           ; 2 = Circle.
                beq.s   drawcircle

                bra     nxtface         ; Else ignore!

drawcircle:
; DRAW CIRCLE.
                movea.l thisface(PC),A0
                move.l  (A0)+,D1        ; Get colour and type.
                move.w  (A0)+,D0        ; Get width.
                lea     rotted(PC),A1   ; Get rotated points address.
                move.l  (A0)+,D1        ; Get number of points (always 1 set!).
; Upper word of D1 is face adjust, not used in circles!
                move.w  (A0)+,D1        ; Get offset.
                move.l  A0,currfc
                movem.w 0(A1,D1.w),D1-D3 ; Get XYZ position.
; When Z clipping remember that perspective is not precalculated, so below...
                btst    #0,object_flag+1 ; Check if we are Z clipping.
                beq.s   c_nozclip       ; No: skip.  Yes: calc perspective.
                asr.w   #3,D3           ; Scale it down (z clip smoothing!).
                asl.l   #5,D1           ; Scale up X, - Z clip smooth factor!
                asl.l   #5,D2           ; Scale up Y.
                divs    D3,D1           ; Do perspective for X.
                divs    D3,D2           ; Do perspective for Y.
                add.w   #scx,D1         ; Add screen center to X.
                add.w   #scy,D2         ; Add screen senter to Y.
                move.w  D1,poly+2       ; And store at rotated coordinates list.
                move.w  D2,poly+4

c_nozclip:
;                move.w  D0,D1           ; Get width.
;                lsr.w   #1,D1           ; Divide by two (!).
;                neg.w   D1              ; Begate.
;                add.w   D3,D1           ; Add Z coord (now Z coord-width/2).
                move.w  D3,D1           ; Get Z coord.
;                sub.w   D0,D1           ; Subtract width.
                cmpi.w  #hither,D1      ; Check if past near Z plane.
                blt     nxtface         ; Yep, chuck it out.
                cmpi.w  #yonder,D1      ; And again for far plane.
                bgt     nxtface

                ext.l   D0              ; Do perspective on width.
                lsl.l   #8,D0
                divs    D3,D0
                cmpi.w  #127,D0         ; Check for oversize circle!
                ble.s   c_s_ok1
                moveq   #127,D0
c_s_ok1:        tst.w   D0              ; And undersize too!
                bge.s   c_s_ok2
                moveq   #0,D0
c_s_ok2:
                move.w  poly+4(PC),D1   ; Get Y pos/coordinate after persp.
                sub.w   D0,D1           ; Subtract width from center.
                move.w  poly+2(PC),circ_xcent ; Ditto for X center.

                bsr     draw_circle

                bra     nxtface


drawpoly_lightsourced:
; DRAW LIGHTSOURCED POLYGON.
                lea     shpoly,A2       ; Space to store 3 points.
                movea.l thisface(PC),A0
                move.l  (A0)+,D1        ; Get colour and type.
                move.w  (A0)+,D0        ; Get width.
                lea     rotted(PC),A1   ; Get rotated points address.
                move.l  (A0)+,D1        ; Skips face adjust, No. of points)
                move.w  (A0)+,D1        ; Get offset
                movem.w 0(A1,D1.w),D1-D3 ; Copy 3 sets of coordinates, so we
                movem.w D1-D3,(A2)      ; can calculate the bloody normals!!
                move.w  (A0)+,D1
                movem.w 0(A1,D1.w),D1-D3
                movem.w D1-D3,6(A2)
                move.w  (A0)+,D1
                movem.w 0(A1,D1.w),D1-D3
                movem.w D1-D3,12(A2)

                jsr     shades          ; Get colour value.
; Now we fall throught to polygon drawer!  Hehe...

drawpoly:
                lea     poly(PC),A5     ; Get polygon pointer.
                move.w  (A5)+,D1        ; Get number of points.
                movea.l A5,A0           ; Copy to A0.
                move.w  D1,D0           ; And number of points.

                move.w  #201,D3         ; Dummy high value.
                move.w  #-1,D4          ; Dummy low value.
                move.w  #320,D5         ; Same for X.
                move.w  #-1,D6

; Find X and Y maximums and minimums in poly.
findmic:        move.w  (A0)+,D7        ; Get X coordinate.
                cmp.w   D7,D5           ; Compare with high val.
                ble.s   nolesc          ; Not smaller...  Skip.
                move.w  D7,D5           ; Smaller...  Now new Min X.
nolesc:         cmp.w   D7,D6           ; Check if it's bigger.
                bge.s   nobic           ; No...  Skip.
                move.w  D7,D6           ; Yep, get this Max X.
nobic:          move.w  (A0)+,D7        ; Get Y coordinate.
                cmp.w   D7,D3           ; Compare with high val.
                ble.s   noles2          ; Not smaller...  Skip.
                move.w  D7,D3           ; Smaller...  Now new Min Y.
noles2:         cmp.w   D7,D4           ; Check if it's bigger.
                bge.s   clip            ; No...  Skip.
                move.w  D7,D4           ; Yep, get this Max Y.
clip:           dbra    D1,findmic      ; Do for points.

                addq.w  #1,D0           ; Adjust for clipper.
                jsr     polyclip        ; CLIP POLYGON.
                cmp.w   #3,D0           ; <3 points, poly outside.
                blt     nxtface
                move.w  D0,D7           ; Do not adjust D7!
                subq.w  #1,D0           ; Adjust D1 for DBRA.

                add.w   D7,D7
                add.w   D7,D7           ; * 4 for duplicate pointer.
                movea.l A5,A0           ; Start of list in A0.
                movea.l A5,A3           ; End of list in A3.
                adda.w  D7,A3           ; Now duplicate pointer.

                bsr     raster_convert  ; And convert it to screen coords.
                bsr     fill_poly       ; And draw the polygons.

                bra     nxtface         ; Bong.  Next face (if any).

                ENDPART


noface:                                 ; Here when no more faces.
                rts


*       illegal

waitk:

                clr.w   $FFFF8240.w

; Rotate our movement lines' end.
                lea     ourline(PC),A0  ; Get our porojected line's address.
                movem.w ourline(PC),D0-D2 ; Get all 6 coords.
                movem.w D0-D2,rotline   ; Copy them.
                lea     rotline(PC),A2  ; Pass on end of line to rotator.
                jsr     quickrot        ; Rotate the endpoint of our line.

; Display line (debugging!).
;                moveq   #0,D0  ; Origin is 0,0,0!
;                moveq   #0,D1
;                movem.w rotline(PC),D2-D4
;                asl.l   #8,D2
;                asl.l   #8,D3
;                divs    D4,D2
;                divs    D4,D3
;                add.w   #scx,D2
;                add.w   #scy,D3
;                movea.l scrn2(PC),A0
;                addq.w  #2,A0
;                bsr     drawline

;                clr.l   number
;                move.w  rotline+10(PC),number+2
;                move.b  #0,txpos
;                move.b  #0,typos
;                bsr     conv

; Now get line slope...  We need no SUBS for deltas since line's origin is
; always from 0,0,0.
                move.w  rotline(PC),D0  ; Dx, since origin is always 0,0,0.
                move.w  rotline+2(PC),D1 ; Dy.
                move.w  rotline+4(PC),D2 ; Dz.
                ext.l   D0              ; For divider.
                ext.l   D1
                ext.l   D2

; Get speed and invert it, since we are DIVIDING, not multiplying (so the less,
; the more slope!!).
                move.w  speed(PC),D3
                neg.w   D3
                add.w   #32767,D3
                ext.l   D3
                move.l  D3,divbottom    ; Speed is divisor.

; Now get integer and fraction slope values.
                move.l  D0,divtop       ; Slope X.
;                move.l  #50,divbottom  ; We already have speed as divisor...
                jsr     frac_divide
                move.w  div_intr,dxadd
                move.w  div_fracr,dxadd+2

                move.l  D1,divtop       ; SLope Y.
                jsr     frac_divide
                move.w  div_intr,dyadd
                move.w  div_fracr,dyadd+2

                move.l  D2,divtop       ; SLope Z.
                jsr     frac_divide
                move.w  div_intr,dzadd
                move.w  div_fracr,dzadd+2


                movem.l vxpos(PC),D0-D2
                add.w   rotline(PC),D0
                add.w   rotline+2(PC),D1
                add.w   rotline+4(PC),D2
                movem.w D0-D2,vxat


                movem.w vxat(PC),D0-D2
                sub.w   vxpos+2(PC),D0
                sub.w   vypos+2(PC),D1
                sub.w   vzpos+2(PC),D2
                ext.l   D0
                ext.l   D1
                ext.l   D2
                jsr     camang
                exg     D0,D1
                neg.w   D0
                neg.w   D1
                movem.w D0-D2,mob1


;                movea.l curr_obj(PC),A0
                lea     square(PC),A0
                move.b  keybyt(PC),D0
                clr.b   keybyt

                cmpi.b  #57,D0
                beq     quit




                bra     key


quit:
                move    #$2700,SR
                move.l  oldvbl(PC),$70.w
                move.l  dsave(PC),$0110.w
                move.l  oldkey(PC),$0118.w
                move.b  sa1(PC),$FFFFFA07.w
                move.b  sa2(PC),$FFFFFA09.w
                move.b  sa3(PC),$FFFFFA15.w
                move.b  sa4(PC),$FFFFFA1D.w
                move.b  sa5(PC),$FFFFFA25.w

                move    #$2300,SR

                lea     krestr(PC),A0
                jsr     ksend

flush:          btst    #0,$FFFFFC00.w
                beq.s   fl_done
                move.b  $FFFFFC02.w,D0
                bra.s   flush
fl_done:

                move.w  #$0777,$FFFF8240.w
                move.w  #$00,$FFFF8242.w
                move.w  #$00,$FFFF8244.w
                move.w  #$00,$FFFF8246.w

                move.l  oldsp(PC),-(SP)
                move.w  #$20,-(SP)
                trap    #1
                addq.w  #6,SP

                clr.w   -(SP)
                trap    #1




vbl:            subi.w  #256,step
                addq.b  #1,lcount

                movem.l D0-A6,-(SP)

; Now test for mouse button and 'accelerate' ourselves.
                move.b  button(PC),D4
                and.b   #3,D4
                cmpi.b  #2,D4
                bne.s   noacc1

                move.l  vxpos(PC),D0    ; Add X slope to X position.
                move.w  dxadd+2(PC),D1
                move.w  dxadd+4(PC),D2
                move.w  dxadd(PC),D3
                ext.l   D3
                add.w   D1,D2
                addx.l  D3,D0
                move.l  D0,vxpos
                move.w  D2,dxadd+4

                move.l  vypos(PC),D0    ; Add Y slope to Y position.
                move.w  dyadd+2(PC),D1
                move.w  dyadd+4(PC),D2
                move.w  dyadd(PC),D3
                ext.l   D3
                add.w   D1,D2
                addx.l  D3,D0
                move.l  D0,vypos
                move.w  D2,dyadd+4

                move.l  vzpos(PC),D0    ; Add Z slope to Z position.
                move.w  dzadd+2(PC),D1
                move.w  dzadd+4(PC),D2
                move.w  dzadd(PC),D3
                ext.l   D3
                add.w   D1,D2
                addx.l  D3,D0
                move.l  D0,vzpos
                move.w  D2,dzadd+4

;                movem.w vxpos(PC),D0-D2
;                add.w   rotline(PC),D0
;                add.w   rotline2(PC),D1
;                add.w   rotline+4(PC),D2
;                movem.w D0-D2,vxat

noacc1:
                cmpi.b  #1,D4
                bne.s   noacc2
                move.l  vxpos(PC),D0    ; Sub X slope to X position.
                move.w  dxadd+2(PC),D1
                move.w  dxadd+4(PC),D2
                move.w  dxadd(PC),D3
                ext.l   D3
                add.w   D1,D2
                subx.l  D3,D0
                move.l  D0,vxpos
                move.w  D2,dxadd+4
                move.l  vypos(PC),D0    ; Sub Y slope to Y position.
                move.w  dyadd+2(PC),D1
                move.w  dyadd+4(PC),D2
                move.w  dyadd(PC),D3
                ext.l   D3
                add.w   D1,D2
                subx.l  D3,D0
                move.l  D0,vypos
                move.w  D2,dyadd+4
                move.l  vzpos(PC),D0    ; Sub Z slope to Z position.
                move.w  dzadd+2(PC),D1
                move.w  dzadd+4(PC),D2
                move.w  dzadd(PC),D3
                ext.l   D3
                add.w   D1,D2
                subx.l  D3,D0
                move.l  D0,vzpos
                move.w  D2,dzadd+4
noacc2:


;                movea.l scrn2(PC),A0
;                addq.w  #2,A0
;                move.w  #10,D0
;                move.w  #10,D1
;                move.w  #300,D2
;                move.w  #190,D3
;                bsr     drawline

                cmpi.l  #-40,vypos
                blt.s   lopo
;                move.w  #$0700,$FFFF8240.w
                move.l  #-40,vypos
lopo:


; Move the plane...
                addq.w  #2,plnang+2
                addq.w  #4,plnang
                move.w  plnang(PC),D0
                move.w  plnang+2(PC),D2
;                move.w  plnang+4(PC),D4
                jsr     get_move_coeffs

;                bra.s   pipi
; Move it wheee!
                move.w  #40,D0
                muls    D0,D3
                muls    D0,D1
                muls    D0,D2
                clr.w   D3
                clr.w   D1
                clr.w   D2
                swap    D3
                swap    D1
                swap    D2
                ext.l   D3
                ext.l   D2
                ext.l   D1
                add.l   D3,plncrd
                add.l   D1,plncrd+4
                add.l   D2,plncrd+8


                movem.l (SP)+,D0-A6

*                eori.w  #$77,$FFFF8240+30.w
divzero:        rte


fstep:          DS.W 1          ; Last step increase.
step:           DS.W 1          ; Space for step increase.
unit:           DS.W 1          ; Actual unit increase after calcs.


;-------------------------- Storage, etc...

yoffs:
yoff            SET 0
                REPT 200
                DC.W yoff
yoff            SET yoff+160
                ENDR

oldsp:          DS.L 1
oldvbl:         DS.L 1
dsave:          DS.L 1
oldkey:         DS.L 1

curr_listptr:   DS.L 1

oldry:          DC.W 0
oldrx:          DC.W 0
rotatex:        DC.W 0
rotatey:        DC.W 0

viewrx:         DC.W 0
viewry:         DC.W 0
viewrz:         DC.W 0

dummy:          DS.W 3

view_matrix:    DC.W 0,0,0
                DC.W 0,0,0
                DC.W 0,0,0

ob_matrix:      DC.W 0,0,0
                DC.W 0,0,0
                DC.W 0,0,0

tot_matrix:     DC.W 0,0,0
                DC.W 0,0,0
                DC.W 0,0,0


init:           DC.B 2
                DC.B $08,$1A    * Mouse on & Joystick off.
krestr:         DC.B 2
                DC.B $08,$1A    * Mouse on & Joystick off.

button:         DS.B 1
keybyt:         DS.B 1          * If keypress, byte stored here.


sa1:            DS.B 1
sa2:            DS.B 1
sa3:            DS.B 1
sa4:            DS.B 1
sa5:            DS.B 1

lcount:         DS.B 1

                EVEN

scrn1:          DS.L 1
scrn2:          DS.L 1
scrn3:          DS.L 1

userx:          DC.W 0
usery:          DC.W 0
userz:          DC.W 0

maxy:           DC.W 0

mankl:          DC.W 0
mankr:          DC.W 0

divtab:
                DC.W 0
dival           SET 1
                REPT 320
                DC.W 65535/dival
dival           SET dival+1
                ENDR

ourline:        DC.W 0,0,1000
rotline:        DS.W 3

object_flag:    DS.W 1

colour:         DS.W 1
type:           DS.W 1
p_data:         DS.W 1

poly_height:    DS.W 1          ; Polygon height.

poly:           DC.W 0          ; Number of points for this poly.
                DS.L 31         ; Space for 30 points per poly.  (X and Y)

rotted:         DS.B 128*6      ; Space for 128 rotated points (total object).
rotted_sc:      DS.B 128*6      ; Same as above but screen coords.

dxadd:          DC.W 0,0,0
dyadd:          DC.W 0,0,0
dzadd:          DC.W 0,0,0

speed:          DC.W 32745

vxpos:          DC.L 0
vypos:          DC.L 0
vzpos:          DC.L 0

vxat:           DC.W 0          ; These in case of absolute camera.
vyat:           DC.W 0
vzat:           DC.W 0

;camrx:          DC.W 0
;camry:          DC.W 0
;camrz:          DC.W 0


;
; World object list ends wit -99.
;
oblist:         DC.L square2    ; Object name/type; -99=endlist, 0=dead/skip.
                DC.L 0,-500,0   ; X,Y,Z position in world.
                DS.W 3          ; Viewer rotated XYZ pos for/after screen check.
mob1:           DC.W 0,0,0      ; X,Y,Z angles if any.
                DC.W %1         ; Object flag.

                DC.L square
                DC.L 400,-100,5000
                DS.W 3
                DC.W 0,0,0
                DC.W 0

                DC.L square
                DC.L -600,-100,5000
                DS.W 3
                DC.W 0,0,0
                DC.W 0

                DC.L plane
plncrd:         DC.L 0,-100,1000
                DS.W 3
plnang:         DC.W 0,0,0
                DC.W %1

rp              SET 0
                REPT 6
                DC.L road
                DC.L 0,0,rp
                DS.W 3
                DC.W 0,0,0
                DC.W %10
rp              SET rp+2000
                ENDR
                DC.L roade
                DC.L 0,0,rp+28
                DS.W 3
                DC.W 0,0,0
                DC.W %10

                DC.L lamp
                DC.L 0,-100,0
                DS.W 3
                DC.W 0,0,0
                DC.W 0

                DC.L plane
                DC.L 0,-10,12000
                DS.W 3
                DC.W 0,128,0
                DC.W %1

                DC.L -99


objects:        DS.B 8*64       ; Space for 64 objects.

z_counter:      DS.W 1

currfc:         DC.L 0          ; Current face (in link list).
thisface:       DC.L 0          ; Face in use.

curr_obj:       DC.L square     ; Address of object.

plane:
                DC.W 273
                DS.L 2
                DC.W 40-1
                DC.W 0,9,242
                DC.W -28,9,175
                DC.W 27,9,175
                DC.W -39,9,86
                DC.W 38,9,86
                DC.W 28,0,-58
                DC.W -29,0,-58
                DC.W 76,0,-125
                DC.W 57,0,-144
                DC.W 28,0,-135
                DC.W -77,0,-125
                DC.W -58,0,-144
                DC.W -29,0,-135
                DC.W 28,9,-144  ; exhaust b
                DC.W -28,9,-144 ;
                DC.W -28,-9,57
                DC.W 19,-9,57
                DC.W 256,-5,-20
                DC.W 273,-5,-58
                DC.W 19,-9,-22
                DC.W -240,-5,-20
                DC.W -274,-5,-58
                DC.W -20,-9,-22
                DC.W 0,-29,156
                DC.W 0,-18,-58  ; Top wing shite
                DC.W 0,-67,-130 ;
                DC.W 0,-67,-168 ;
                DC.W 0,-18,-144 ;
                DC.W 38,-13,86
                DC.W -39,-13,86
                DC.W 21,9,86
                DC.W -22,9,86
                DC.W -22,-13,86
                DC.W 21,-13,86
                DC.W -29,9,0
                DC.W 28,9,0
                DC.W 28,0,0
                DC.W -29,0,0
                DC.W 35,-18,-164 ; exhaust t
                DC.W -35,-18,-164 ;
; Faces, blah blah...
                DC.W 0,0,8
                DC.W 0
                DC.W 3-1,23*6,0*6,2*6
                DC.W 0,0,8
                DC.W 0
                DC.W 3-1,23*6,1*6,0*6
                DC.W 0,0,8
                DC.W 0
                DC.W 5-1,13*6,2*6,0*6,1*6,14*6
                DC.W 0,0,8
                DC.W 0
                DC.W 3-1,38*6,23*6,2*6
                DC.W 0,0,8
                DC.W 0
                DC.W 3-1,39*6,1*6,23*6
                DC.W 0,0,8
                DC.W 0
                DC.W 3-1,13*6,38*6,2*6
                DC.W 0,0,8
                DC.W 0
                DC.W 3-1,14*6,1*6,39*6
                DC.W 0,0,8
                DC.W 0
                DC.W 3-1,38*6,39*6,23*6
                DC.W 0,0,8
                DC.W 0
                DC.W 4-1,34*6,3*6,29*6,37*6
                DC.W 0,0,8
                DC.W 0
                DC.W 3-1,37*6,29*6,32*6
                DC.W 0,0,8
                DC.W 0
                DC.W 3-1,36*6,33*6,28*6
                DC.W 0,0,8
                DC.W 0
                DC.W 3-1,34*6,31*6,3*6
                DC.W 0,0,8
                DC.W 0
                DC.W 3-1,35*6,4*6,30*6
                DC.W 0,0,8
                DC.W 0
                DC.W 4-1,35*6,36*6,28*6,4*6
                DC.W 0,0,8      ; Top wing r
                DC.W 0
                DC.W 4-1,26*6,25*6,24*6,27*6
                DC.W 0,0,8      ; Top wing l
                DC.W 1
                DC.W 4-1,26*6,27*6,24*6,25*6
                DC.W 0,0,8      ; Wingtop r
                DC.W 1
                DC.W 4-1,18*6,19*6,16*6,17*6
                DC.W 0,0,8      ; Wingbot r
                DC.W 0
                DC.W 4-1,18*6,17*6,16*6,19*6
                DC.W 0,0,8      ; Wingtop l
                DC.W 1
                DC.W 4-1,21*6,20*6,15*6,22*6
                DC.W 0,0,8      ; Wingbot l
                DC.W 0
                DC.W 4-1,21*6,22*6,15*6,20*6
                DC.W 0,0,8      ; Back rwing top
                DC.W 1
                DC.W 4-1,8*6,9*6,5*6,7*6
                DC.W 0,0,8      ; Back rwing bot
                DC.W 0
                DC.W 4-1,8*6,7*6,5*6,9*6
                DC.W 0,0,8      ; Back lwing top
                DC.W 1
                DC.W 4-1,11*6,10*6,6*6,12*6
                DC.W 0,0,8      ; Back lwing bot
                DC.W 0
                DC.W 4-1,11*6,12*6,6*6,10*6
                DC.W 13,0,8     ; Rear exhaust
                DC.W 0
                DC.W 4-1,13*6,14*6,39*6,38*6
                DC.W -99



road:           DC.W 1160
                DS.L 2
                DC.W 12-1
                DC.W -100*2,0,510*2
                DC.W 100*2,0,510*2
                DC.W 100*2,0,-510*2
                DC.W -100*2,0,-510*2
                DC.W -10,0,50*4
                DC.W 10,0,50*4
                DC.W 10,0,-50*4
                DC.W -10,0,-50*4
                DC.W -110*2,0,-510*2
                DC.W -110*2,0,510*2
                DC.W 110*2,0,-510*2
                DC.W 110*2,0,510*2

                DC.W 7,0,8
                DC.W 1
                DC.W 4-1
                DC.W 0*6,1*6,2*6,3*6
                DC.W 14,0,8
                DC.W 1
                DC.W 4-1
                DC.W 4*6,5*6,6*6,7*6
                DC.W 14,0,8
                DC.W 1
                DC.W 4-1
                DC.W 0*6,3*6,8*6,9*6
                DC.W 14,0,8
                DC.W 1
                DC.W 4-1
                DC.W 11*6,10*6,2*6,1*6
                DC.W -99,-99,-99

roade:          DC.W 525*2
                DS.L 2
                DC.W 16-1
                DC.W -100*4,0,215*2
                DC.W 100*4,0,215*2
                DC.W 100*4,0,-515*2
                DC.W -100*4,0,-515*2
                DC.W -10,0,50*6
                DC.W 10,0,50*6
                DC.W 10,0,-50*6
                DC.W -10,0,-50*6
                DC.W -60*6,0,50 ; Extra bit on side
                DC.W -40*2,0,50
                DC.W -40*2,0,-50
                DC.W -60*6,0,-50
                DC.W 60*6,0,50  ; Extra bit on side
                DC.W 40*2,0,50
                DC.W 40*2,0,-50
                DC.W 60*6,0,-50

                DC.W 7,0,8
                DC.W 1
                DC.W 4-1
                DC.W 0*6,1*6,2*6,3*6
                DC.W 14,0,8
                DC.W 1
                DC.W 4-1
                DC.W 4*6,5*6,6*6,7*6
                DC.W 14,0,8
                DC.W 1
                DC.W 4-1
                DC.W 8*6,9*6,10*6,11*6
                DC.W 14,0,8
                DC.W 1
                DC.W 4-1
                DC.W 15*6,14*6,13*6,12*6
                DC.W -99,-99,-99


lamp:
                DC.W 220        ; Width of object.
                DS.L 2          ; For future expansion!

                DC.W 9-1        ; Points list.  Number of points.
                DC.W -10,-100,-10
                DC.W 10,-100,-10
                DC.W 10,100,-10
                DC.W -10,100,-10
                DC.W -10,-100,10
                DC.W 10,-100,10
                DC.W 10,100,10
                DC.W -10,100,10
                DC.W 0,-100,0


                DC.W 15,2,40
                DC.W 0
                DC.W 1-1
                DC.W 8*6

                DC.W 0,0,8      ; Colour
                DC.W 0
                DC.W 4-1        ; Number of (linked) points.
                DC.W 0*6,1*6,2*6,3*6
                DC.W 0,0,8
                DC.W 0
                DC.W 4-1
                DC.W 7*6,6*6,5*6,4*6
                DC.W 0,0,8
                DC.W 0
                DC.W 4-1
                DC.W 1*6,5*6,6*6,2*6
                DC.W 0,0,8
                DC.W 0
                DC.W 4-1
                DC.W 4*6,0*6,3*6,7*6
;                DC.W 5,0,8
;                DC.W 0
;                DC.W 4-1
;                DC.W 4*6,5*6,1*6,0*6

;                DC.W 15,2,40
;                DC.W 0
;                DC.W 1-1
;                DC.W 8*6


                DC.L -99


square:
                DC.W 731        ; Width of object.
                DS.L 2          ; For future expansion!

                DC.W 10-1       ; Points list.  Number of points.
                DC.W -100,-20,-100
                DC.W 100,-20,-100
                DC.W 100,100,-600 ; Both these used in 'shadow'.
                DC.W -100,100,-600 ;
                DC.W -100,-50,100
                DC.W 100,-50,100
                DC.W 100,100,100
                DC.W -100,100,100
                DC.W 70,100,-720
                DC.W -70,100,-720

                DC.W 3,0,8
                DC.W 1
                DC.W 4-1
                DC.W 3*6,2*6,8*6,9*6
                DC.W 6,0,8      ; Colour
                DC.W 0          ; Face adjust.
                DC.W 4-1        ; Number of (linked) points.
                DC.W 0*6,1*6,2*6,3*6
                DC.W 5,0,8
                DC.W 0
                DC.W 4-1
                DC.W 7*6,6*6,5*6,4*6
                DC.W 4,0,8
                DC.W 0
                DC.W 4-1
                DC.W 1*6,5*6,6*6,2*6
                DC.W 4,0,8
                DC.W 0
                DC.W 4-1
                DC.W 0*6,3*6,7*6,4*6
                DC.W 0,0,8
                DC.W 0
                DC.W 4-1
                DC.W 4*6,5*6,1*6,0*6

                DC.L -99

square2:
                DC.W 420        ; Width of object.
                DS.L 2          ; For future expansion!

                DC.W 8-1        ; Points list.  Number of points.
                DC.W -100,-100,-100
                DC.W 100,-100,-100
                DC.W 100,100,-100
                DC.W -100,100,-100
                DC.W -100,-100,400
                DC.W 100,-100,400
                DC.W 100,100,400
                DC.W -100,100,400

                DC.W 1,0,8      ; Colour
                DC.W 0
                DC.W 4-1        ; Number of (linked) points.
                DC.W 0*6,1*6,2*6,3*6
                DC.W 2,0,8
                DC.W 0
                DC.W 4-1
                DC.W 7*6,6*6,5*6,4*6
                DC.W 3,0,8
                DC.W 0
                DC.W 4-1
                DC.W 1*6,5*6,6*6,2*6
                DC.W 4,0,8
                DC.W 0
                DC.W 4-1
                DC.W 4*6,0*6,3*6,7*6
                DC.W 5,0,8
                DC.W 0
                DC.W 4-1
                DC.W 4*6,5*6,1*6,0*6
                DC.W 6,0,8
                DC.W 0
                DC.W 4-1
                DC.W 3*6,2*6,6*6,7*6

                DC.L -99



;---------------------------- CLIP REGION!

clipleft:
                DC.W 0
clipright:
                DC.W 319
clipbottom:
                DC.W 199
cliptop:
                DC.W 0

; ------------------------------------ **  * *


;
; RASTER GRAPHICS OPERATIONS.
;

                >PART 'Circle generator'

draw_circle:

                clr.w   c_clip          ; Clear circle clip flag.

;                move.l  #20,D0
;                move.l  D0,D1
;                neg.l   D1
;                add.l   #scy,D1

                cmp.w   clipbottom(PC),D1 ; Check if top of circle off bottom.
                bgt     reject_circ     ; Yes, circle completely out.
                add.w   D0,D0           ; Longword access on width.
                add.w   D0,D0
                lea     c_refs(PC),A0   ; Get circle size pointers address.
                lea     c_cords(PC),A1  ; And actual points tables.
                adda.w  0(A0,D0.w),A1   ; Add offset into coord list.
                move.w  2(A0,D0.w),D2   ; Get width of circ (since some same).
                move.w  D2,D3           ; Copy width.
                move.w  D2,D6           ; And again.
                move.w  D1,D5           ; Copy Y pos.

                move.w  circ_xcent(PC),D4 ; Get circle X center.
                add.w   D2,D4           ; Add width.
                cmp.w   clipleft(PC),D4 ; Check if right of circle off left.
                blt     reject_circ     ; Yep, circle completely out.
;                move.w  circ_xcent(PC),D4 ; Same for right side.
                sub.w   D2,D4           ; Quicker this way (nullify above add!).
                sub.w   D2,D4
                cmp.w   clipright(PC),D4
                bgt     reject_circ

                move.w  D2,D4           ; Copy width.
                add.w   D4,D4           ; X 2 = diameter.
                add.w   #1,D4           ; Leeway adjust.
                add.w   D1,D4           ; Add Y pos.
                cmp.w   cliptop(PC),D4  ; Check if bottom of circle off top.
                blt     reject_circ

                cmp.w   cliptop(PC),D1  ; Se if top of circ needs clipping.
                bge.s   c_topok         ; Nah, skip.
                move.w  cliptop(PC),D4  ; Else, get difference.
                sub.w   D1,D4           ; Subract Y coord; D4 = difference.
                move.w  cliptop(PC),D1  ; New Y coord is top.
                sub.w   D4,D2           ; Subtract from width.
                bpl.s   c_halfok        ; We still have this half...  OK.
                neg.w   D2              ; Else, make positive.
                subq.w  #1,D2           ; Adjust.
                move.w  D3,D4           ; Get second width.
                add.w   D4,D4           ; X 2.
                sub.w   D2,D3           ; Subtract leftover from half.
                subq.w  #1,D3           ; Adjust for height thing.
                subq.w  #1,D2           ; Adjust.
                add.w   D2,D2           ; X2.
                lea     0(A1,D4.w),A1   ; Point to new set from clip point by
                suba.w  D2,A1           ; subtracting leftover from half.
                ori.b   #%10,c_clip     ; Signal a bottom half only (if any).
                bra.s   c_topok
c_halfok:       add.w   D4,D4
                lea     0(A1,D4.w),A1   ; Half ok. Point to coords + h/height
c_topok:
;                bra.s   clip_botok

; Now do same for bottom half..!
                move.w  D6,D4           ; Get width.
                add.w   D4,D4           ; Times two = diameter.
                addq.w  #1,D4           ; Adjust.
                add.w   D5,D4           ; Add Y pos (D5=D1 above).
                cmp.w   clipbottom(PC),D4 ; See if off bottom.
                ble.s   c_botok         ; No, skip.
                move.w  clipbottom(PC),D5 ; Else get clip bottom.
                sub.w   D5,D4           ; Subtract Y pos.
                sub.w   D4,D3           ; Subtract from top/half width.
                bpl.s   clip_botok      ; Ok, skip.
                neg.w   D3              ; Else we have only low half.
                subq.w  #1,D3           ; Adjust.
                sub.w   D3,D2           ; And make new height.
                ori.b   #1,c_clip       ; Signal a top half only (if any).
c_botok:

clip_botok:
                move.w  D1,starty       ; Store Y start coord.

                lea     lpoints(PC),A2  ; Get address of raster filler coords.
                lea     rpoints(PC),A3

                clr.w   poly_height     ; Clear poly height.

                move.w  clipleft(PC),D4 ; Get clip coords.
                add.w   D4,D4           ; X4 for filler (uses x4 for speed).
                add.w   D4,D4
                move.w  clipright(PC),D5
                add.w   D5,D5
                add.w   D5,D5
                move.w  circ_xcent(PC),D6
                add.w   D6,D6
                add.w   D6,D6

                btst    #1,c_clip       ; See if we have a top half.
                bne.s   npnts_2a        ; Nope, skip to add (reject otherwise!).

                add.w   D2,poly_height  ; Else add top half height.
npnts_1:
                move.w  (A1)+,D0        ; Get X coord.
                move.w  D0,D1           ; Copy.
                add.w   D6,D0           ; Add X center.
                cmp.w   D5,D0           ; Off right side?
                ble.s   c_rightok1      ; No, ok.
                move.w  D5,D0           ; Else make coord=right side.
c_rightok1:     move.w  D0,(A3)+        ; Store in raster list.
                neg.w   D1              ; Other side is mirror.
                add.w   D6,D1           ; Blah...
                cmp.w   D4,D1
                bge.s   c_leftok1
                move.w  D4,D1
c_leftok1:      move.w  D1,(A2)+
                dbra    D2,npnts_1

                btst    #0,c_clip       ; See if we have a bottom half.
                bne.s   end_circ        ; None, so skip.

npnts_2a:       addq.w  #1,D3
                add.w   D3,poly_height  ; Else add bottom height.

npnts_2:
                move.w  -(A1),D0        ; Go back UP list!!  Hehe!
                move.w  D0,D1
                add.w   D6,D0
                cmp.w   D5,D0
                ble.s   c_rightok2
                move.w  D5,D0
c_rightok2:     move.w  D0,(A3)+
                neg.w   D1
                add.w   D6,D1
                cmp.w   D4,D1
                bge.s   c_leftok2
                move.w  D4,D1
c_leftok2:      move.w  D1,(A2)+
                dbra    D3,npnts_2

end_circ:
                addq.w  #1,poly_height  ; Adjust for 199 clip area (200 high!).

                move.w  #319*4,(A2)+    ; Just in case...
                move.w  #1*4,(A3)+

                bsr     fill_poly

reject_circ:
                rts

c_clip:         DS.W 1
circ_xcent:     DS.W 1

;
; For circle generator.
c_refs:         IBYTES 'CIRCREFS.DAT'
c_cords:        IBYTES 'CIRCORDS.DAT'


                ENDPART

                >PART 'Raster convertor'

raster_convert:
****  RASTER CONVERT POLYGON  ****

; Find lowest Y and higest Y and make a duplicate points list.
                move.w  D0,D1           ; Number of points.
                move.w  D0,D2           ; Copy in case of 1 high poly.
                movea.l A0,A2           ; Ditto.
                move.w  #202,D0         ; Dummy high value.
                moveq   #-2,D3          ; Dummy low value.
findmin:        move.l  (A0)+,D4        ; Get Y coordinate.
                cmp.w   D4,D0           ; Compare with high val.
                ble.s   noless          ; Not smaller...  Skip.
                move.w  D4,D0           ; Smaller...  Now new MinY.
                movea.l A0,A1           ; Get address from X.
noless:         cmp.w   D4,D3           ; Check if it's bigger.
                bge.s   nobig           ; No...  Skip.
                move.w  D4,D3           ; Yep, get this.
nobig:          move.l  D4,(A3)+        ; To next coordinates and copy.
                dbra    D1,findmin      ; Do for points.
                subq.w  #4,A1           ; Adjust A1 because of (A0)+.
* A1 now contains address to right scan of table, from the X.
* D0 contains the minimum Y value.
* D3 contains maximum Y value.
;
;                illegal

                move.w  D0,starty       ; Store beginning Y.
                sub.w   D0,D3           ; Make now total Y's.
                move.w  D3,poly_height
;                addq.w  #1,D3
                addq.w  #1,poly_height

; See if it's a one-pixel high polygon.
; If so, find min and max X, then store and exit!
                tst.w   D3
                bne.s   poly_bigger_than1
                move.w  #321,D0         ; Dummy high value.
                moveq   #-2,D1          ; Dummy low value.
findmin_x:      move.l  (A2)+,D4        ; Get Y coordinate.
                swap    D4
                cmp.w   D4,D0           ; Compare with high val.
                ble.s   noless_x        ; Not smaller...  Skip.
                move.w  D4,D0           ; Smaller...  Now new MinY.
noless_x:       cmp.w   D4,D1           ; Check if it's bigger.
                bge.s   nobig_x         ; No...  Skip.
                move.w  D4,D1           ; Yep, get this.
nobig_x:        dbra    D2,findmin_x    ; Do for points.
                add.w   D0,D0           ; X * 4
                add.w   D0,D0
                add.w   D1,D1           ; Ditto.
                add.w   D1,D1
                move.w  D0,lpoints
                move.w  D1,rpoints
                rts

; Else do as normal (and 0 case slope works!).
poly_bigger_than1:

                lea     divtab(PC),A2   ; Division table address.
                move.w  D3,D1           ; Duplicate for right edge.

; Point A0 to duplicate coordinates (second list).
                movea.l A1,A0           ; Copy start pointer address to A0.
                adda.w  D7,A0           ; Now point to duplicate coords.
* A0 now contains address to left scan of table, from the X.
* We now have A0 for delta X L calcs and A1 for delta X R calcs.



***  Process left edge.

                lea     lpoints(PC),A3  ; Get left edge table address.

doleft:
; Get number of Y's.
                move.w  -2(A0),D0       ; Get destination Y for left.
                sub.w   2(A0),D0        ; For left edge get difference.
                bmi     outl
                move.w  D0,D2

* D7 now contains the destination Y.
* D0 contains the Y difference for left edge.

; Left edge Delta.
                move.w  -4(A0),D4       ; Get destination X.
                move.w  (A0),D5         ; Duplicate for start from screen.
                sub.w   D5,D4           ; Difference of X's.
; D5 has start lX.

* (A2) Points to division table.
                add.w   D0,D0           ; Make word access.
                add.w   D4,D4           ; Delta X times 4.
                add.w   D4,D4
                muls    0(A2,D0.w),D4   ; Nab int and frac parts.
                move.w  D4,D6           ; Fraction part in D6.
                swap    D4              ; Swap for integer for ADDX.
; D4 contains frac and int.

                add.w   D5,D5           ; Start X * 4.
                add.w   D5,D5

                move.w  D2,D7
                add.w   D7,D7
                move.w  D7,D0
                add.w   D7,D7
                add.w   D7,D0           ; * 6 for each routine.
                lea     erouts(PC),A4   ; Get end of routines address.
                suba.w  D0,A4           ; And point to proper line.

                move.w  D6,D0           ; Make sure D0 is clear.

; A3 points to raster scan convert table to write the left edge to.

                jmp     (A4)            ; Jump to routines.

; ...  these routines.
; Fill table with left gradient addition results.
                REPT 204
                move.w  D5,(A3)+
                add.w   D6,D0
                addx.w  D4,D5
                ENDR
erouts:

;                illegal

                subq.w  #4,A0           ; If not, move on.
                sub.w   D2,D3
                bgt     doleft
                cmpi.w  #2,poly_height
                bgt.s   outl
                cmp.w   #1,D2
                beq     doleft

outl:
                move.w  D5,(A3)+        ; Cater for missing line.


***  Now process right edge.

                lea     rpoints(PC),A3  ; Get right edge table address.

doright:
; Get number of Y's.
                move.w  6(A1),D0        ; Get destination Y for right.
                sub.w   2(A1),D0        ; For left edge get difference.
                bmi     outr
                move.w  D0,D2

* D7 now contains the destination Y.
* D0 contains the Y difference for right edge.

; Right edge Delta.
                move.w  4(A1),D4        ; Get destination X.
                move.w  (A1),D5         ; Duplicate for start from screen.
                sub.w   D5,D4           ; Difference of X's.
; D5 has start rX.

* (A2) Points to division table.
                add.w   D0,D0           ; Make word access.
                add.w   D4,D4           ; Delta X times 4.
                add.w   D4,D4
                muls    0(A2,D0.w),D4   ; Nab int and frac parts.
                move.w  D4,D6           ; Get fraction.
                swap    D4              ; Swap for integer for ADDX.
; D4 contains frac and int.

                add.w   D5,D5           ; Start X * 4.
                add.w   D5,D5

                move.w  D2,D7
                add.w   D7,D7
                move.w  D7,D0
                add.w   D7,D7
                add.w   D7,D0           ; * 6 for each routine.
                lea     rrouts(PC),A4   ; Get end of routines.
                suba.w  D0,A4

                move.w  D6,D0           ; Make sure D0 is clear.

; A3 points to raster scan convert table to write the right edge to.

                jmp     (A4)            ; Jump to routines.

; ...  these routines.
; Fill table with right gradient addition results.
                REPT 204
                move.w  D5,(A3)+
                add.w   D6,D0
                addx.w  D4,D5
                ENDR
rrouts:
;                illegal

                addq.w  #4,A1           ; If not, move on.
                sub.w   D2,D1
                bgt     doright
                cmpi.w  #2,poly_height
                bgt.s   outr
                cmp.w   #1,D2
                beq     doright
outr:
                move.w  D5,(A3)+        ; Cater for missing line.

                rts

poly_neg:       illegal
                move.w  #-1,poly_height ; Hmm...  Signal a wonky poly!

                rts

                ENDPART

                >PART 'Polygon filler'

****  DRAW HLINES  ***

fill_poly:
; Set routines to colour.
                move.w  colour(PC),D0   ; Colour
                cmpi.w  #15,D0
                bgt     a_hash
                add.w   D0,D0           ; Word access.
                lea     coltab(PC),A0
                lea     col1(PC),A2
                adda.w  0(A0,D0.w),A2
                move.l  (A2)+,D4
                move.l  (A2)+,D5        ; Colour data (8 bytes).
                lea     mcol1(PC),A0
                lea     mcol2(PC),A1
                move.l  (A2)+,D0
                move.l  (A2)+,D1        ; Get instructions.
                move.l  D0,(A0)+        ; Self modify 1rst chunk thing.
                move.l  D1,(A0)+
                move.l  D0,(A1)+        ; Self modify special case.
                move.l  D1,(A1)+
                lea     chunk2(PC),A0
                move.l  (A2)+,(A0)+     ; Self modify end chunk.
                move.l  (A2)+,(A0)+


                movea.l scrn2(PC),A0
                lea     lpoints(PC),A3
                lea     rpoints(PC),A4
                move.w  starty(PC),D0
                add.w   D0,D0
                lea     yoffs(PC),A1
                adda.w  0(A1,D0.w),A0
                movea.l A0,A5

                lea     lefted(PC),A1
                lea     righted(PC),A2

                move.w  poly_height(PC),D6
                subq.w  #1,D6
                bmi     doned

drawit:         moveq   #-4,D0
                and.w   (A3)+,D0
                move.l  0(A1,D0.w),D0
                moveq   #-4,D2
                and.w   (A4)+,D2
                move.l  0(A2,D2.w),D2
                add.w   D0,D2           ; Number of chunks.

                beq.s   chunk1
                bgt.s   skip_line       ; Hmm...  Just for circgen...

drawit2:        add.w   D0,D0
                adda.w  D0,A0           ; Add screen offset (X)
                swap    D0              ; Get mask.

                move.w  D0,D1           ; Draw left edge.
                not.w   D1

mcol1:          or.w    D0,(A0)+
                and.w   D1,(A0)+
                and.w   D1,(A0)+
                and.w   D1,(A0)+

                jmp     jumpit(PC,D2.w)

chunk20:        move.l  D4,(A0)+
                move.l  D5,(A0)+
chunk19:        move.l  D4,(A0)+
                move.l  D5,(A0)+
chunk18:        move.l  D4,(A0)+
                move.l  D5,(A0)+
chunk17:        move.l  D4,(A0)+
                move.l  D5,(A0)+
chunk16:        move.l  D4,(A0)+
                move.l  D5,(A0)+
chunk15:        move.l  D4,(A0)+
                move.l  D5,(A0)+
chunk14:        move.l  D4,(A0)+
                move.l  D5,(A0)+
chunk13:        move.l  D4,(A0)+
                move.l  D5,(A0)+
chunk12:        move.l  D4,(A0)+
                move.l  D5,(A0)+
chunk11:        move.l  D4,(A0)+
                move.l  D5,(A0)+
chunk10:        move.l  D4,(A0)+
                move.l  D5,(A0)+
chunk9:         move.l  D4,(A0)+
                move.l  D5,(A0)+
chunk8:         move.l  D4,(A0)+
                move.l  D5,(A0)+
chunk7:         move.l  D4,(A0)+
                move.l  D5,(A0)+
chunk6:         move.l  D4,(A0)+
                move.l  D5,(A0)+
chunk5:         move.l  D4,(A0)+
                move.l  D5,(A0)+
chunk4:         move.l  D4,(A0)+
                move.l  D5,(A0)+
chunk3:         move.l  D4,(A0)+
                move.l  D5,(A0)+
                swap    D2
                move.w  D2,D3
jumpit:         not.w   D3
chunk2:         or.w    D2,(A0)+
                and.w   D3,(A0)+
                and.w   D3,(A0)+
                and.w   D3,(A0)+

skip_line:      lea     160(A5),A5
                movea.l A5,A0
                dbra    D6,drawit
                bra.s   doned

chunk1:         add.w   D0,D0
                adda.w  D0,A0           ; Screen offset.
                swap    D0              ; Get mask.
                swap    D2              ; Get mask.
                and.w   D2,D0           ; Combine both edges.
                move.w  D0,D1
                not.w   D1
mcol2:          or.w    D0,(A0)+
                and.w   D1,(A0)+
                and.w   D1,(A0)+
                and.w   D1,(A0)+
                lea     160(A5),A5
                movea.l A5,A0
                dbra    D6,drawit


doned:                                  ; Here when we've drawn all lines.
                rts

a_hash:

                add.w   D0,D0           ; Word access.
                lea     coltab(PC),A0
                lea     col1(PC),A2
                adda.w  0(A0,D0.w),A2
                move.l  (A2)+,D4
                move.l  (A2)+,D5        ; Colour data (8 bytes).
                move.l  (A2)+,D6
                move.l  (A2)+,D7        ; Rotated colour data or second hash.

                movea.l scrn2(PC),A0
                lea     lpoints(PC),A3
                lea     rpoints(PC),A4
                move.w  starty(PC),D0
                btst    #0,D0
                beq.s   h_notodd
                exg     D6,D4
                exg     D7,D5
h_notodd:       add.w   D0,D0
                lea     yoffs(PC),A1
                adda.w  0(A1,D0.w),A0
                movea.l A0,A5

                lea     lefted(PC),A1
                lea     righted(PC),A2

                move.w  poly_height(PC),D3
                bmi.s   doned

hash_drawit:    moveq   #-4,D0
                and.w   (A3)+,D0
                move.l  0(A1,D0.w),D0
                moveq   #-4,D2
                and.w   (A4)+,D2
                move.l  0(A2,D2.w),D2
                add.w   D0,D2           ; Number of chunks.

                beq     hash_chunk1
                bgt.s   hash_skip_line

hash_drawit2:   add.w   D0,D0
                adda.w  D0,A0           ; Add screen offset (X)
                swap    D0              ; Get mask.

                move.w  D0,D1           ; Draw left edge.
                swap    D0
                move.w  D1,D0

; First chunk...
                move.l  (A0),D1
                eor.l   D4,D1
                and.l   D0,D1
                eor.l   D1,(A0)+
                move.l  (A0),D1
                eor.l   D5,D1
                and.l   D0,D1
                eor.l   D1,(A0)+

                jmp     hash_jumpit(PC,D2.w)

h_chunk20:      move.l  D4,(A0)+
                move.l  D5,(A0)+
h_chunk19:      move.l  D4,(A0)+
                move.l  D5,(A0)+
h_chunk18:      move.l  D4,(A0)+
                move.l  D5,(A0)+
h_chunk17:      move.l  D4,(A0)+
                move.l  D5,(A0)+
h_chunk16:      move.l  D4,(A0)+
                move.l  D5,(A0)+
h_chunk15:      move.l  D4,(A0)+
                move.l  D5,(A0)+
h_chunk14:      move.l  D4,(A0)+
                move.l  D5,(A0)+
h_chunk13:      move.l  D4,(A0)+
                move.l  D5,(A0)+
h_chunk12:      move.l  D4,(A0)+
                move.l  D5,(A0)+
h_chunk11:      move.l  D4,(A0)+
                move.l  D5,(A0)+
h_chunk10:      move.l  D4,(A0)+
                move.l  D5,(A0)+
h_chunk9:       move.l  D4,(A0)+
                move.l  D5,(A0)+
h_chunk8:       move.l  D4,(A0)+
                move.l  D5,(A0)+
h_chunk7:       move.l  D4,(A0)+
                move.l  D5,(A0)+
h_chunk6:       move.l  D4,(A0)+
                move.l  D5,(A0)+
h_chunk5:       move.l  D4,(A0)+
                move.l  D5,(A0)+
h_chunk4:       move.l  D4,(A0)+
                move.l  D5,(A0)+
h_chunk3:       move.l  D4,(A0)+
                move.l  D5,(A0)+

                move.l  D2,D1           ; Draw left edge.
                swap    D1
hash_jumpit:    move.w  D1,D2
; Last chunk...
                move.l  (A0),D1
                eor.l   D4,D1
                and.l   D2,D1
                eor.l   D1,(A0)+
                move.l  (A0),D1
                eor.l   D5,D1
                and.l   D2,D1
                eor.l   D1,(A0)+

hash_skip_line: lea     160(A5),A5
                movea.l A5,A0
                dbra    D3,hash_drawit22
                bra     hash_doned

hash_chunk1:    add.w   D0,D0
                adda.w  D0,A0           ; Screen offset.
                swap    D0              ; Get mask.
                swap    D2              ; Get mask.
                and.w   D2,D0           ; Combine both (inverse) edges.
                move.w  D0,D1
                swap    D0
                move.w  D1,D0

; One chunk merge...
                move.l  (A0),D1
                eor.l   D4,D1
                and.l   D0,D1
                eor.l   D1,(A0)+
                move.l  (A0),D1
                eor.l   D5,D1
                and.l   D0,D1
                eor.l   D1,(A0)+

                lea     160(A5),A5
                movea.l A5,A0
                dbra    D3,hash_drawit22
                bra     hash_doned

********* Alternate second line...  Gets rid of EXG's.

hash_drawit22:
                moveq   #-4,D0
                and.w   (A3)+,D0
                move.l  0(A1,D0.w),D0
                moveq   #-4,D2
                and.w   (A4)+,D2
                move.l  0(A2,D2.w),D2
                add.w   D0,D2           ; Number of chunks.

                beq     hash_chunk12
                bgt.s   hash_skip_line2

                add.w   D0,D0
                adda.w  D0,A0           ; Add screen offset (X)
                swap    D0              ; Get mask.

                move.w  D0,D1           ; Draw left edge.
                swap    D0
                move.w  D1,D0

; First chunk...
                move.l  (A0),D1
                eor.l   D6,D1
                and.l   D0,D1
                eor.l   D1,(A0)+
                move.l  (A0),D1
                eor.l   D7,D1
                and.l   D0,D1
                eor.l   D1,(A0)+

                jmp     hash_jumpit2(PC,D2.w)

h2_chunk20:     move.l  D6,(A0)+
                move.l  D7,(A0)+
h2_chunk19:     move.l  D6,(A0)+
                move.l  D7,(A0)+
h2_chunk18:     move.l  D6,(A0)+
                move.l  D7,(A0)+
h2_chunk17:     move.l  D6,(A0)+
                move.l  D7,(A0)+
h2_chunk16:     move.l  D6,(A0)+
                move.l  D7,(A0)+
h2_chunk15:     move.l  D6,(A0)+
                move.l  D7,(A0)+
h2_chunk14:     move.l  D6,(A0)+
                move.l  D7,(A0)+
h2_chunk13:     move.l  D6,(A0)+
                move.l  D7,(A0)+
h2_chunk12:     move.l  D6,(A0)+
                move.l  D7,(A0)+
h2_chunk11:     move.l  D6,(A0)+
                move.l  D7,(A0)+
h2_chunk10:     move.l  D6,(A0)+
                move.l  D7,(A0)+
h2_chunk9:      move.l  D6,(A0)+
                move.l  D7,(A0)+
h2_chunk8:      move.l  D6,(A0)+
                move.l  D7,(A0)+
h2_chunk7:      move.l  D6,(A0)+
                move.l  D7,(A0)+
h2_chunk6:      move.l  D6,(A0)+
                move.l  D7,(A0)+
h2_chunk5:      move.l  D6,(A0)+
                move.l  D7,(A0)+
h2_chunk4:      move.l  D6,(A0)+
                move.l  D7,(A0)+
h2_chunk3:      move.l  D6,(A0)+
                move.l  D7,(A0)+

                move.l  D2,D1           ; Draw left edge.
                swap    D1
hash_jumpit2:   move.w  D1,D2
; Last chunk...
                move.l  (A0),D1
                eor.l   D6,D1
                and.l   D2,D1
                eor.l   D1,(A0)+
                move.l  (A0),D1
                eor.l   D7,D1
                and.l   D2,D1
                eor.l   D1,(A0)+

hash_skip_line2:lea     160(A5),A5
                movea.l A5,A0
                dbra    D3,hash_drawit
                bra.s   hash_doned

hash_chunk12:   add.w   D0,D0
                adda.w  D0,A0           ; Screen offset.
                swap    D0              ; Get mask.
                swap    D2              ; Get mask.
                and.w   D2,D0           ; Combine both (inverse) edges.
                move.w  D0,D1
                swap    D0
                move.w  D1,D0

; One chunk merge...
                move.l  (A0),D1
                eor.l   D6,D1
                and.l   D0,D1
                eor.l   D1,(A0)+
                move.l  (A0),D1
                eor.l   D7,D1
                and.l   D0,D1
                eor.l   D1,(A0)+

                lea     160(A5),A5
                movea.l A5,A0
                dbra    D3,hash_drawit

hash_doned:                             ; Here when we've drawn all lines.
                rts

; For edge and chunk calculations.

; Left edge masks & offsets.
lefted:
cchunk          SET 0
                REPT 20
                DC.W %1111111111111111,cchunk
                DC.W %111111111111111,cchunk
                DC.W %11111111111111,cchunk
                DC.W %1111111111111,cchunk
                DC.W %111111111111,cchunk
                DC.W %11111111111,cchunk
                DC.W %1111111111,cchunk
                DC.W %111111111,cchunk
                DC.W %11111111,cchunk
                DC.W %1111111,cchunk
                DC.W %111111,cchunk
                DC.W %11111,cchunk
                DC.W %1111,cchunk
                DC.W %111,cchunk
                DC.W %11,cchunk
                DC.W %1,cchunk
cchunk          SET cchunk+4
                ENDR

                REPT 20*16
                DC.W 4*64,4*64
                ENDR

; Right edge masks & offsets.
righted:
cchunk          SET 0
                REPT 20
                DC.W %1000000000000000,-cchunk
                DC.W %1100000000000000,-cchunk
                DC.W %1110000000000000,-cchunk
                DC.W %1111000000000000,-cchunk
                DC.W %1111100000000000,-cchunk
                DC.W %1111110000000000,-cchunk
                DC.W %1111111000000000,-cchunk
                DC.W %1111111100000000,-cchunk
                DC.W %1111111110000000,-cchunk
                DC.W %1111111111000000,-cchunk
                DC.W %1111111111100000,-cchunk
                DC.W %1111111111110000,-cchunk
                DC.W %1111111111111000,-cchunk
                DC.W %1111111111111100,-cchunk
                DC.W %1111111111111110,-cchunk
                DC.W %1111111111111111,-cchunk
cchunk          SET cchunk+4
                ENDR

                REPT 20*16
                DC.W 4,4
                ENDR


* COLOUR TABLE.
coltab:         DC.W col1-cstart
                DC.W col2-cstart
                DC.W col3-cstart
                DC.W col4-cstart
                DC.W col5-cstart
                DC.W col6-cstart
                DC.W col7-cstart
                DC.W col8-cstart
                DC.W col9-cstart
                DC.W col10-cstart
                DC.W col11-cstart
                DC.W col12-cstart
                DC.W col13-cstart
                DC.W col14-cstart
                DC.W col15-cstart
                DC.W col16-cstart
; Hash colours...
oset            SET 0
                REPT 30
                DC.W (hashes+oset)-cstart
oset            SET oset+16
                ENDR

* COLOUR DATA AND ROUTINES. > 15 is hash colours (and no slef-modifying).
cstart:
col1:           DC.L $00,$00
                and.w   D1,(A0)+
                and.w   D1,(A0)+
                and.w   D1,(A0)+
                and.w   D1,(A0)+
                and.w   D3,(A0)+
                and.w   D3,(A0)+
                and.w   D3,(A0)+
                and.w   D3,(A0)+
col2:           DC.L $FFFF0000,$00
                or.w    D0,(A0)+
                and.w   D1,(A0)+
                and.w   D1,(A0)+
                and.w   D1,(A0)+
                or.w    D2,(A0)+
                and.w   D3,(A0)+
                and.w   D3,(A0)+
                and.w   D3,(A0)+
col3:           DC.L $FFFF,$00
                and.w   D1,(A0)+
                or.w    D0,(A0)+
                and.w   D1,(A0)+
                and.w   D1,(A0)+
                and.w   D3,(A0)+
                or.w    D2,(A0)+
                and.w   D3,(A0)+
                and.w   D3,(A0)+
col4:           DC.L $FFFFFFFF,$00
                or.w    D0,(A0)+
                or.w    D0,(A0)+
                and.w   D1,(A0)+
                and.w   D1,(A0)+
                or.w    D2,(A0)+
                or.w    D2,(A0)+
                and.w   D3,(A0)+
                and.w   D3,(A0)+
col5:           DC.L $00,$FFFF0000
                and.w   D1,(A0)+
                and.w   D1,(A0)+
                or.w    D0,(A0)+
                and.w   D1,(A0)+
                and.w   D3,(A0)+
                and.w   D3,(A0)+
                or.w    D2,(A0)+
                and.w   D3,(A0)+
col6:           DC.L $FFFF0000,$FFFF0000
                or.w    D0,(A0)+
                and.w   D1,(A0)+
                or.w    D0,(A0)+
                and.w   D1,(A0)+
                or.w    D2,(A0)+
                and.w   D3,(A0)+
                or.w    D2,(A0)+
                and.w   D3,(A0)+
col7:           DC.L $FFFF,$FFFF0000
                and.w   D1,(A0)+
                or.w    D0,(A0)+
                or.w    D0,(A0)+
                and.w   D1,(A0)+
                and.w   D3,(A0)+
                or.w    D2,(A0)+
                or.w    D2,(A0)+
                and.w   D3,(A0)+
col8:           DC.L $FFFFFFFF,$FFFF0000
                or.w    D0,(A0)+
                or.w    D0,(A0)+
                or.w    D0,(A0)+
                and.w   D1,(A0)+
                or.w    D2,(A0)+
                or.w    D2,(A0)+
                or.w    D2,(A0)+
                and.w   D3,(A0)+
col9:           DC.L $00,$FFFF
                and.w   D1,(A0)+
                and.w   D1,(A0)+
                and.w   D1,(A0)+
                or.w    D0,(A0)+
                and.w   D3,(A0)+
                and.w   D3,(A0)+
                and.w   D3,(A0)+
                or.w    D2,(A0)+
col10:          DC.L $FFFF0000,$FFFF
                or.w    D0,(A0)+
                and.w   D1,(A0)+
                and.w   D1,(A0)+
                or.w    D0,(A0)+
                or.w    D2,(A0)+
                and.w   D3,(A0)+
                and.w   D3,(A0)+
                or.w    D2,(A0)+
col11:          DC.L $FFFF,$FFFF
                and.w   D1,(A0)+
                or.w    D0,(A0)+
                and.w   D1,(A0)+
                or.w    D0,(A0)+
                and.w   D3,(A0)+
                or.w    D2,(A0)+
                and.w   D3,(A0)+
                or.w    D2,(A0)+
col12:          DC.L $FFFFFFFF,$FFFF
                or.w    D0,(A0)+
                or.w    D0,(A0)+
                and.w   D1,(A0)+
                or.w    D0,(A0)+
                or.w    D2,(A0)+
                or.w    D2,(A0)+
                and.w   D3,(A0)+
                or.w    D2,(A0)+
col13:          DC.L $00,$FFFFFFFF
                and.w   D1,(A0)+
                and.w   D1,(A0)+
                or.w    D0,(A0)+
                or.w    D0,(A0)+
                and.w   D3,(A0)+
                and.w   D3,(A0)+
                or.w    D2,(A0)+
                or.w    D2,(A0)+
col14:          DC.L $FFFF0000,$FFFFFFFF
                or.w    D0,(A0)+
                and.w   D1,(A0)+
                or.w    D0,(A0)+
                or.w    D0,(A0)+
                or.w    D2,(A0)+
                and.w   D3,(A0)+
                or.w    D2,(A0)+
                or.w    D2,(A0)+
col15:          DC.L $FFFF,$FFFFFFFF
                and.w   D1,(A0)+
                or.w    D0,(A0)+
                or.w    D0,(A0)+
                or.w    D0,(A0)+
                and.w   D3,(A0)+
                or.w    D2,(A0)+
                or.w    D2,(A0)+
                or.w    D2,(A0)+
col16:          DC.L $FFFFFFFF,$FFFFFFFF
                or.w    D0,(A0)+
                or.w    D0,(A0)+
                or.w    D0,(A0)+
                or.w    D0,(A0)+
                or.w    D2,(A0)+
                or.w    D2,(A0)+
                or.w    D2,(A0)+
                or.w    D2,(A0)+

; HASH DEFINITIONS - Second hash is the 'rotated' hash.  Could do ROR's to get
; the other hash, but this allows weirdo hashes.
hashes:
                REPT 4
                DC.W %1010101010101010
                ENDR
                REPT 4
                DC.W %101010101010101
                ENDR
*                IBYTES '33SHADES.FE4'


; For raster scan convert.
starty:         DS.W 1          ; Y start value.
lpoints:        DS.W 202        ; Space for 200 X pairs left edge.
rpoints:        DS.W 202        ; Space for 200 X pairs right edge.

                DS.L 4

                ENDPART

                >PART 'Line drawer'

; (Real number version).
drawline:

                bsr     clipline
                tst.w   D4
                bmi     noline

                cmp.w   D2,D0           ; Make it so we always go from right
                bge.s   l_nobig         ; to left of line.
                exg     D0,D2
                exg     D1,D3
l_nobig:

                lea     yoffs,A1        ; Add Y screen offset.
                move.w  D1,D4
                add.w   D4,D4
                adda.w  0(A1,D4.w),A0

                sub.w   D1,D3           ; Y2-Y1
                bmi.s   itsneg          ; If negative, invert.
                beq.s   itszer          ; If zero, leave.
; ...  Alse it's positive slope.
                move.w  #160,D1
                bra.s   contx

itszer:         moveq   #0,D1
                bra.s   contx

itsneg:         move.w  #-160,D1        ; We decrease in Y.
                neg.w   D3              ; Make DY absolute.
contx:

; D3 = DY    ( ABS(Y2-Y1) )
; D1 = SGN(Y2-Y1)

                sub.w   D0,D2           ; X2 - X1
                bpl.s   nonegx
                neg.w   D2
nonegx:
; D2 = DX    ( ABS(X2-X1) )

                cmp.w   D3,D2           ; Check if DY > DX
                bge.s   case0

; Case 1... (STEEP SLOPE)

                lea     lnxs(PC),A1
                add.w   D0,D0
                add.w   D0,D0
                move.l  0(A1,D0.w),D0
                adda.w  D0,A0           ; Add screen offset.
                swap    D0              ; Now we have the pixel.

                move.w  D3,D4

                lea     divtab,A1       ; Replacment for below! (see top)
                add.w   D3,D3
                mulu    0(A1,D3.w),D2

*                ext.l   D2              ; Get fraction to (1/256) accuracy.
*                lsl.l   #8,D2
*                divu    D3,D2
*                ext.l   D2
*                lsl.l   #8,D2

                moveq   #0,D3

l_drawy:        or.w    D0,(A0)         ; Plot point.
                sub.w   D2,D3           ; Add fraction.
                bcc.s   l_iny           ; BCC.S - Test for X inc.
                add.w   D0,D0           ; Yep, move X.
                bcc.s   l_iny           ; BCC.S - Check for point wrap.
                moveq   #1,D0           ; Yep, re-set pixel position.
                subq.w  #8,A0           ; Move to left chunk.
l_iny:          adda.w  D1,A0           ; > Else move Y position.
                dbra    D4,l_drawy
;                or.w    D0,(A0)

                rts


; Case 0... (FLAT SLOPE)
case0:
                lea     lnxs(PC),A1
                add.w   D0,D0
                add.w   D0,D0
                move.l  0(A1,D0.w),D0
                adda.w  D0,A0           ; Add screen offset.
                swap    D0              ; Now we have the pixel.

                move.w  D2,D4

                lea     divtab,A1       ; Replacement for below! (see top)
                add.w   D2,D2
                mulu    0(A1,D2.w),D3

*                add.l   D3,D3
*                ext.l   D3              ; Get fraction (to 1/256 accuracy).
*                lsl.l   #8,D3
*                divu    D2,D3
*                lsl.l   #8,D3

                moveq   #0,D2

l_drawx:        or.w    D0,(A0)         ; Plot point.
                add.w   D0,D0           ; Move it left.
                bcc.s   l_wrapx         ; BCC.S - test for wrap.
                moveq   #1,D0           ; Wrap.  Re-set pixel position.
                subq.w  #8,A0           ; Move to left screen chunk.
l_wrapx:        sub.w   D3,D2           ; > Else Add fraction.
                bcc.s   l_inx           ; BCC.S - test for Y inc.
                adda.w  D1,A0           ; Yes, so add to Y position.
l_inx:          dbra    D4,l_drawx
;                or.w    D0,(A0)
noline:         rts


;
; Line clipper by Jose Commins, or The Phantom of Electronic Images!
; Ah well, this one's the faster-shorter-generally-better one that sorts the
; coordinates and does much quicker checks for everything, and, as above, the
; code is about half the size too!
; Trashes D4-D7 and A1.
; Entered with X1,Y1,X2,Y2 in D0-D3.
;
; Returns with value in D4.  If D4 is negative, line is totally invisible.
;
; For speed, clip widow is defined as WORDS in this sequence:
; CLIP LEFT,CLIP RIGHT,CLIP BOTTOM,CLIP TOP.
; Don't organise them any other way as it will get the wrong values!
;

clipline:
                lea     clipleft(PC),A1

                cmp.w   D0,D2           ; Sort 'em according to X.
                bge.s   lineok1
                exg     D0,D2
                exg     D1,D3
lineok1:
                cmp.w   2(A1),D0        ; Left edge off clip right?
                bgt     lineout
                cmp.w   (A1),D2
                blt     lineout         ; Right edge off clip left?

                cmp.w   (A1),D0         ; Left edge off left?
                bge.s   noutl1
                move.w  D3,D4
                sub.w   D1,D4           ; Y2-Y1
                move.w  (A1),D5         ; Left side.
                sub.w   D0,D5           ; Xt-X1
                muls    D5,D4           ; (Y2-Y1)*(Xt-X1)
                move.w  D2,D5
                sub.w   D0,D5           ; X2-X1
                divs    D5,D4           ; DY
                add.w   D4,D1           ; New Y1.
                move.w  (A1),D0         ; X1=Left edge.

noutl1:         cmp.w   2(A1),D2        ; Right edge off right?
                ble.s   noutr1

                move.w  D1,D4
                sub.w   D3,D4           ; Y1-Y2
                move.w  2(A1),D5        ; Right side.
                sub.w   D2,D5           ; Xt-X2
                muls    D5,D4           ; (Y1-Y2)*(Xt-X2)
                move.w  D0,D5
                sub.w   D2,D5           ; X1-X2
                divs    D5,D4           ; DY
                add.w   D4,D3           ; New Y2.
                move.w  2(A1),D2        ; X2=Right edge.

noutr1:         cmp.w   D1,D3           ; Sort 'em according to Y.
                bge.s   lineok2
                exg     D1,D3
                exg     D0,D2
lineok2:
                cmp.w   4(A1),D1        ; Top of line off bottom?
                bgt.s   lineout
                cmp.w   6(A1),D3
                blt.s   lineout         ; Bottom of line off top?

                cmp.w   4(A1),D3        ; Bottom of line off bottom?
                ble.s   noutb1

                move.w  D0,D4
                sub.w   D2,D4           ; X1-X2
                move.w  4(A1),D5        ; Bottom side.
                sub.w   D3,D5           ; Yt-Y2
                muls    D5,D4           ; (X1-X2)*(Yt-Y2)
                move.w  D1,D5
                sub.w   D3,D5           ; Y1-Y2
                divs    D5,D4           ; Dx
                add.w   D4,D2           ; New X2.
                move.w  4(A1),D3        ; Y2=Bottom edge.

noutb1:         cmp.w   6(A1),D1        ; Top of line off top?
                bge.s   noutt1

                move.w  D2,D4
                sub.w   D0,D4           ; X2-X1
                move.w  6(A1),D5        ; Top side.
                sub.w   D1,D5           ; Yt-Y1
                muls    D5,D4           ; (X2-X1)*(Yt-Y1)
                move.w  D3,D5
                sub.w   D1,D5           ; Y2-Y1
                divs    D5,D4           ; Dx
                add.w   D4,D0           ; New X1.
                move.w  6(A1),D1        ; Y1=Top edge.


noutt1:         moveq   #0,D4           ; Line is now visoble.
                rts

lineout:        moveq   #-1,D4          ; Line invisible.
                rts



lnxs:
scoff           SET 0
                REPT 20
                DC.W %1000000000000000,scoff
                DC.W %100000000000000,scoff
                DC.W %10000000000000,scoff
                DC.W %1000000000000,scoff
                DC.W %100000000000,scoff
                DC.W %10000000000,scoff
                DC.W %1000000000,scoff
                DC.W %100000000,scoff
                DC.W %10000000,scoff
                DC.W %1000000,scoff
                DC.W %100000,scoff
                DC.W %10000,scoff
                DC.W %1000,scoff
                DC.W %100,scoff
                DC.W %10,scoff
                DC.W %1,scoff
scoff           SET scoff+8
                ENDR

                ENDPART

                >PART 'screen clear (to 200 lines)'

; D7=Number of lines to clear, A0=Screen address (end of screen to clear).
; D0 and D1 contain colour info!
cls:
;                move.l  #$00,D0
;                move.l  #$00,D1
                move.l  D0,D2
                move.l  D1,D3
                move.l  D0,D4
                move.l  D1,D5
                move.l  D0,D6
                movea.l D1,A1
                movea.l D0,A2
                movea.l D1,A3

                lsl.w   #4,D7
                neg.w   D7
                lea     clsrouts(PC),A4
                jmp     0(A4,D7.w)
                REPT 200
                movem.l D0-D6/A1-A3,-(A0)
                movem.l D0-D6/A1-A3,-(A0)
                movem.l D0-D6/A1-A3,-(A0)
                movem.l D0-D6/A1-A3,-(A0)
                ENDR
clsrouts:       rts

                ENDPART

                >PART 'Horizon routine'

sky1            EQU $FFFF
sky2            EQU 0
ground1         EQU $FFFF0000
ground2         EQU 0
;
; HORIZON ROUTINE (Phew!).
;

do_horizon:

; Rotate horizon's line plus centre points, according to view angles.
                lea     view_matrix,A0  ; Matrix in A0.
                lea     horizon(PC),A1  ; Source in A1.
                lea     horizonr(PC),A2 ; Destination in A2.
                lea     dummy,A4        ; Don't displace X,Y or Z.
                moveq   #4-1,D7         ; Number of points -1.
                bsr     rotate_object

; Check for negative values, since 32-bit divide routine is unsigned!
                movem.w horizonr(PC),D0-D5 ; Ugh!
                moveq   #0,D6
                tst.w   D0
                bpl.s   hok1
                neg.w   D0
                addq.w  #%1,D6
hok1:           tst.w   D1
                bpl.s   hok2
                neg.w   D1
                addq.w  #%10,D6
hok2:           tst.w   D3
                bpl.s   hok3
                neg.w   D3
                addq.w  #%100,D6
hok3:           tst.w   D4
                bpl.s   hok4
                neg.w   D4
                addq.w  #%1000,D6
hok4:
                tst.w   D2
                bpl.s   hok5
                neg.w   D2
                add.w   #%10000,D6
hok5:           tst.w   D5
                bpl.s   hok6
                neg.w   D5
                add.w   #%100000,D6
hok6:
                movem.w D0-D5,h_space

; Now convert them to screen coordinates.
                movem.w h_space(PC),D0-D2 ; Get first three points.
                move.l  #$FFFF,D3
                and.l   D3,D0           ; Sigh...
                and.l   D3,D1
                and.l   D3,D2
                lsl.l   #8,D0
                moveq   #0,D5
                move.w  D0,D5
                clr.w   D0
                swap    D0
                beq.s   vL0000
                divu    D2,D0
                swap    D0
                swap    D5
                move.w  D0,D5
                swap    D5
vL0000:
                divu    D2,D5
                move.w  D5,D0
                lsl.l   #8,D1
                moveq   #0,D5
                move.w  D1,D5
                clr.w   D1
                swap    D1
                beq.s   vL0001
                divu    D2,D1
                swap    D1
                swap    D5
                move.w  D1,D5
                swap    D5
vL0001:
                divu    D2,D5
                move.w  D5,D1
vL0002:
                cmp.l   #32768,D0
                ble.s   vL0004
vL0003:
                lsr.l   #1,D0
                lsr.l   #1,D1
                bra.s   vL0002

vL0004:
                cmp.l   #32768,D1
                bgt.s   vL0003

                btst    #4,D6
                beq.s   vlo1
                neg.w   D0
                neg.w   D1
vlo1:
                btst    #0,D6
                beq.s   vL0005
                neg.w   D0
vL0005:
                btst    #1,D6
                beq.s   vL0006
                neg.w   D1
vL0006:
                add.w   #scx,D0
                addi.w  #scy,D1

; Other side...
                movem.w h_space+6(PC),D2-D4 ; Now do for other end of horizon.
                move.l  #$FFFF,D5
                and.l   D5,D2
                and.l   D5,D3
                and.l   D5,D4
                lsl.l   #8,D2
                moveq   #0,D5
                move.w  D2,D5
                clr.w   D2
                swap    D2
                beq.s   vL0007
                divu    D4,D2
                swap    D2
                swap    D5
                move.w  D2,D5
                swap    D5
vL0007:
                divu    D4,D5
                move.w  D5,D2
                lsl.l   #8,D3
                moveq   #0,D5
                move.w  D3,D5
                clr.w   D3
                swap    D3
                beq.s   vL0008
                divu    D4,D3
                swap    D3
                swap    D5
                move.w  D3,D5
                swap    D5
vL0008:
                divu    D4,D5
                move.w  D5,D3
vL0009:
                cmp.l   #32768,D2
                ble.s   vL000B
vL000A:
                lsr.l   #1,D2
                lsr.l   #1,D3
                bra.s   vL0009
vL000B:
                cmp.l   #32768,D3
                bgt.s   vL000A

                btst    #5,D6
                beq.s   vlo2
                neg.w   D2
                neg.w   D3
vlo2:
                btst    #2,D6
                beq.s   vL000C
                neg.w   D2
vL000C:
                btst    #3,D6
                beq.s   vL000D
                neg.w   D3
vL000D:
                add.w   #scx,D2
                addi.w  #scy,D3

                move.w  D0,D4           ; Leave originals untouched!
                move.w  D1,D5
                move.w  D2,D6
                move.w  D3,D7

; Here we check which direction/side to fill, according to line's 'tilt'.
                tst.w   horizonr+4      ; See if negative Z.
                bge.s   h_zok1          ; Nope, ok.
                exg     D5,D7           ; Else re-organise points.
                exg     D4,D6
;                move.w  #$0333,$FFFF8240.w
h_zok1:
                tst.w   horizonr+6+4    ; Check for other end.
                bge.s   h_zok2
                exg     D5,D7
                exg     D4,D6
;                move.w  #$0333,$FFFF8240.w
h_zok2:
                clr.w   horizon_flags   ; Clear 'em!

                cmp.w   D5,D7           ; Check if Y1>Y2 (side to fill).
                bge.s   h_yok1
                ori.w   #1,horizon_flags
;                move.w  #$0200,$FFFF8240.w
h_yok1:
                cmp.w   D4,D6           ; Check if X1>X2 (top/bottom to fill).
                bge.s   h_xok1
                ori.w   #%10,horizon_flags
;                move.w  #$0222,$FFFF8240.w
h_xok1:

; We pre-sort horizon according to Y (for top/bottom clip).
                cmp.w   D1,D3           ; Sort horizon lines according to Y.
                bgt.s   h_yok
                exg     D1,D3
                exg     D0,D2
h_yok:
;                movea.l scrn2(PC),A0   ; Show unclipped horizon line (4 dbug).
;                addq.w  #4,A0
;                bsr     drawline

                lea     clipleft(PC),A1 ; Get clip rectangle's address.
; Set screen coords to be impossibly large, so clippers detect a skip!  Hehe.
                move.w  #-4000,horizon_screen_c
                move.w  #-4000,horizon_screen_c+2
                move.w  #4000,horizon_screen_c+4
                move.w  #4000,horizon_screen_c+6


; Clip to top of rectangle (wether it likes it or not!).
; If there's an overflow, or divide by zero, line is too steep, therefore not
; within the clip region, and is thus ignored for that edge.  Hehe!
                movem.w D0-D3,-(SP)     ; Store for later use (more accurate).
                move.w  D2,D4           ; Blah.
                sub.w   D0,D4           ; X2-X1
                move.w  6(A1),D5        ; Top side.
                sub.w   D1,D5           ; Yt-Y1
                muls    D5,D4           ; (X2-X1)*(Yt-Y1)
                move.w  D3,D5
                sub.w   D1,D5           ; Y2-Y1
                beq.s   h_clip_edges    ; Check for / by 0 (line too steep).
                divs    D5,D4           ; Dx
                bvs.s   h_clip_edges    ; Check for overflow (same as / 0).
                add.w   D4,D0           ; New X1.
                move.w  6(A1),D1        ; Y1=Top edge.

                cmp.w   (A1),D0         ; Check if off top/bottom clip regions.
                blt.s   h_skip_1
                cmp.w   2(A1),D0
                bgt.s   h_skip_1
h_store_1:      movem.w D0-D1,horizon_screen_c ; Store if coords OK.
h_skip_1:       movem.w (SP)+,D0-D3

; CLip to bottom.
                movem.w D0-D3,-(SP)
                move.w  D2,D4
                sub.w   D0,D4           ; X2-X1
                move.w  4(A1),D5        ; Bottom side.
                sub.w   D1,D5           ; Yt-Y1
                muls    D5,D4           ; (X2-X1)*(Yt-Y1)
                move.w  D3,D5
                sub.w   D1,D5           ; Y2-Y1
                beq.s   h_clip_edges
                divs    D5,D4           ; Dx
                bvs.s   h_clip_edges
                add.w   D4,D0           ; New X1.
                move.w  4(A1),D1        ; Y1=Bottom edge.

                cmp.w   (A1),D0
                blt.s   h_skip_2
                cmp.w   2(A1),D0
                bgt.s   h_skip_2
h_store_2:      movem.w D0-D1,horizon_screen_c+4
h_skip_2:       movem.w (SP)+,D0-D3
                bra.s   h_tmskip

h_clip_edges:
                movem.w (SP)+,D0-D3
h_tmskip:

; Now we clip the edges (if need be!); we sort according to X now.
                movem.w horizon_screen_c(PC),D4-D7
                cmp.w   D0,D2
                bgt.s   he_xok
                exg     D4,D6           ; Swap SCREEN coords.
                exg     D5,D7
                movem.w D4-D7,horizon_screen_c
he_xok:
                cmp.w   (A1),D6         ; See if we need to clip.
                blt.s   h_special_1
                cmp.w   2(A1),D6
                ble.s   h_xskip1
h_special_1:

; Now there's no need to check line's edge after clipping, since we know it is
; within the region!  Hehe!
; Right clip.
                movem.w D0-D3,-(SP)
                move.w  D3,D4
                sub.w   D1,D4           ; Y2-Y1
                move.w  2(A1),D5        ; Right side.
                sub.w   D0,D5           ; Xt-X1
                muls    D5,D4           ; (Y2-Y1)*(Xt-X1)
                move.w  D2,D5
                sub.w   D0,D5           ; X2-X1
                beq.s   h_smskip
                divs    D5,D4           ; DY
                bvs.s   h_smskip
                add.w   D4,D1           ; New Y1.
                move.w  2(A1),D0        ; X1=Right edge.
                movem.w D0-D1,horizon_screen_c+4
                movem.w (SP)+,D0-D3

h_xskip1:
                move.w  horizon_screen_c(PC),D5 ; Chech again for boundaries!
                cmp.w   2(A1),D5
                bgt.s   h_special_2
                cmp.w   (A1),D5
                bge.s   h_clip_end
h_special_2:

; Left clip (last clip, so no need to stack registers).
                move.w  D3,D4
                sub.w   D1,D4           ; Y2-Y1
                move.w  (A1),D5         ; Left side.
                sub.w   D0,D5           ; Xt-X1
                muls    D5,D4           ; (Y2-Y1)*(Xt-X1)
                move.w  D2,D5
                sub.w   D0,D5           ; X2-X1
                beq.s   h_clip_end
                divs    D5,D4           ; DY
                bvs.s   h_clip_end
                add.w   D4,D1           ; New Y1.
                move.w  (A1),D0         ; X1=Left edge.
                movem.w D0-D1,horizon_screen_c
                bra.s   h_clip_end

h_smskip:
                movem.w (SP)+,D0-D3
h_clip_end:

                movem.w horizon_screen_c(PC),D0-D3 ; Get final coords.

                cmp.w   D0,D2           ; Sort 'em (both X and Y as 2 groups).
                bge.s   hs_xok
                exg     D0,D2
hs_xok:         cmp.w   D1,D3
                bge.s   hs_yok
                exg     D1,D3
hs_yok:
; Now check if the horizon is completely out of screen/clip area.
                cmp.w   (A1),D2
                blt     no_horizon
                cmp.w   2(A1),D0
                bgt     no_horizon
                cmp.w   4(A1),D3
                bgt     no_horizon
                cmp.w   6(A1),D1
                blt     no_horizon

;                move.w  #$07,$FFFF8240.w
;                movem.w horizon_screen_c(PC),D0-D3  ; Show clipped line 4 dbug.
;                movea.l scrn2(PC),A0
;                bsr     drawline_unclipped

                movem.w horizon_screen_c(PC),D0-D3

                cmp.w   D1,D3           ; Sort according to Y (for r convert)
                bgt.s   juju
                exg     D1,D3
                exg     D0,D2
juju:
;                illegal

                move.w  D0,D6           ; Used later as start line edge.
                sub.w   D0,D2           ; Delta X.
                addq.w  #1,D3
                sub.w   D1,D3
                move.w  D1,h_starty     ; Store start Y coord.
                move.w  D3,h_triheight  ; Store height of 'triangle'.

                lea     divtab,A0
                add.w   D3,D3           ; Make word access.
                add.w   D2,D2           ; Delta X times 4.
                add.w   D2,D2
                muls    0(A0,D3.w),D2   ; Nab int and frac parts.
                move.w  D2,D3           ; Fraction part in D6.
                swap    D2              ; Swap for integer for ADDX.
; Now we have the yummy slope in D2 and D3!

; Now we fill the raster convert table.  As we only have one slope, the other
; edge is always the opposite screen clip region, so no raster convert is needed
; although we need to determine which side to use (therefore the 'tilt' flag!).
; Note that it uses a different scan table (with actual chunk values *8 etc)
; since it is a little quicker when filling; it stores the table values, since
; it is quicker to access them, rather than do two lookups from coordinates.
                lea     h_righted(PC),A3
                lea     lpoints(PC),A2
                move.w  D6,D4           ; Copy start line edge.
                add.w   D4,D4
                add.w   D4,D4

;                illegal

                btst    #0,horizon_flags+1
                beq.s   h_rconvert_it
                lea     h_lefted(PC),A3
h_rconvert_it:
                moveq   #0,D1
                move.w  h_triheight(PC),D0
                beq     h_end_middle_fill
                add.w   D0,D0
                add.w   D0,D0
                move.w  D0,D5
                add.w   D0,D0
                add.w   D5,D0
                neg.w   D0
                lea     end_hor_jmps(PC),A1
                jmp     0(A1,D0.w)
                REPT 201
                moveq   #-4,D0
                and.w   D4,D0
                move.l  0(A3,D0.w),(A2)+ ; Store table values, not coords.
                add.w   D3,D1
                addx.w  D2,D4
                ENDR
end_hor_jmps:
; Store end of write, since we read from the table backwards!
                movea.l A2,A1

                move.w  h_triheight(PC),D0
                subq.w  #1,D0
                bmi     h_end_clear_fill ; ...  Don't ask!!
                movea.l scrn2,A0
                move.w  h_triheight(PC),D1
                add.w   h_starty(PC),D1
                mulu    #160,D1
                adda.w  D1,A0

; Now we fast fill the sides the 'triangle' occupies, using MOVEM's with two
; sets of colour registers, always filling the line's screen width (saving
; xpensive LEA's etc!) per line.

; Determine which side.
                btst    #0,horizon_flags+1
                bne     h_clear_right

;                illegal
;                move.w  #$0777,$FFFF8240.w

; Set registers to colour.
                move.l  #sky1,D1
                move.l  #sky2,D2
                move.l  D1,D3
                move.l  D2,D4
                move.l  D1,D5
                move.l  D2,D6
                move.l  #ground1,D7
                movea.l #ground2,A2
                movea.l D7,A3
                movea.l A2,A4
                movea.l D7,A5
                movea.l A2,A6

                bra     h_clear_l       ; Hehe!! Avoids using extra regs!

                REPT 200
                illegal
                ENDR

hlc0:
                move.l  D3,D1
                REPT 6
                movem.l D7/A2-A6,-(A0)
                ENDR
                movem.l D7/A2-A4,-(A0)
                dbra    D0,h_clear_l
                bra     h_end_clear_fill
hlc0e:
                DS.B 64-(hlc0e-hlc0)
hlc1:
                move.l  D3,D1
                move.l  D2,-(A0)
                move.l  D1,-(A0)
                REPT 6
                movem.l D7/A2-A6,-(A0)
                ENDR
                move.l  A2,-(A0)
                move.l  D7,-(A0)
                dbra    D0,h_clear_l
                bra     h_end_clear_fill
hlc1e:
                DS.B 64-(hlc1e-hlc1)
hlc2:
                move.l  D3,D1
                movem.l D1-D4,-(A0)
                REPT 6
                movem.l D7/A2-A6,-(A0)
                ENDR
                dbra    D0,h_clear_l
                bra     h_end_clear_fill
hlc2e:
                DS.B 64-(hlc2e-hlc2)
hlc3:
                move.l  D3,D1
                movem.l D1-D6,-(A0)
                REPT 5
                movem.l D7/A2-A6,-(A0)
                ENDR
                movem.l D7/A2-A4,-(A0)
                dbra    D0,h_clear_l
                bra     h_end_clear_fill
hlc3e:
                DS.B 64-(hlc3e-hlc3)
hlc4:
                move.l  D3,D1
                movem.l D1-D6,-(A0)
                move.l  D2,-(A0)
                move.l  D1,-(A0)
                REPT 5
                movem.l D7/A2-A6,-(A0)
                ENDR
                move.l  A2,-(A0)
                move.l  D7,-(A0)
                dbra    D0,h_clear_l
                bra     h_end_clear_fill
hlc4e:
                DS.B 64-(hlc4e-hlc4)
hlc5:
                move.l  D3,D1
                movem.l D1-D6,-(A0)
                movem.l D1-D4,-(A0)
                REPT 5
                movem.l D7/A2-A6,-(A0)
                ENDR
                dbra    D0,h_clear_l
                bra     h_end_clear_fill
hlc5e:
                DS.B 64-(hlc5e-hlc5)
hlc6:
                move.l  D3,D1
                movem.l D1-D6,-(A0)
                movem.l D1-D6,-(A0)
                REPT 4
                movem.l D7/A2-A6,-(A0)
                ENDR
                movem.l D7/A2-A4,-(A0)
                dbra    D0,h_clear_l
                bra     h_end_clear_fill
hlc6e:
                DS.B 64-(hlc6e-hlc6)
hlc7:
                move.l  D3,D1
                movem.l D1-D6,-(A0)
                movem.l D1-D6,-(A0)
                move.l  D2,-(A0)
                move.l  D1,-(A0)
                REPT 4
                movem.l D7/A2-A6,-(A0)
                ENDR
                move.l  A2,-(A0)
                move.l  D7,-(A0)
                dbra    D0,h_clear_l
                bra     h_end_clear_fill
hlc7e:
                DS.B 64-(hlc7e-hlc7)
hlc8:
                move.l  D3,D1
                movem.l D1-D6,-(A0)
                movem.l D1-D6,-(A0)
                movem.l D1-D4,-(A0)
                REPT 4
                movem.l D7/A2-A6,-(A0)
                ENDR
                dbra    D0,h_clear_l
                bra     h_end_clear_fill
hlc8e:
                DS.B 64-(hlc8e-hlc8)
hlc9:
                move.l  D3,D1
                movem.l D1-D6,-(A0)
                movem.l D1-D6,-(A0)
                movem.l D1-D6,-(A0)
                movem.l D7/A2-A6,-(A0)
                movem.l D7/A2-A6,-(A0)
                movem.l D7/A2-A6,-(A0)
                movem.l D7/A2-A4,-(A0)
                dbra    D0,h_clear_l
                bra     h_end_clear_fill
hlc9e:
                DS.B 64-(hlc9e-hlc9)
hlc10:
                move.l  D3,D1
                movem.l D1-D6,-(A0)
                movem.l D1-D6,-(A0)
                movem.l D1-D6,-(A0)
                move.l  D2,-(A0)
                move.l  D1,-(A0)
                movem.l D7/A2-A6,-(A0)
                movem.l D7/A2-A6,-(A0)
                movem.l D7/A2-A6,-(A0)
                move.l  A2,-(A0)
                move.l  D7,-(A0)
                dbra    D0,h_clear_l
                bra     h_end_clear_fill
hlc10e:
                DS.B 64-(hlc10e-hlc10)
hlc11:
                move.l  D3,D1
                movem.l D1-D6,-(A0)
                movem.l D1-D6,-(A0)
                movem.l D1-D6,-(A0)
                movem.l D1-D4,-(A0)
                movem.l D7/A2-A6,-(A0)
                movem.l D7/A2-A6,-(A0)
                movem.l D7/A2-A6,-(A0)
                dbra    D0,h_clear_l
                bra     h_end_clear_fill
hlc11e:
                DS.B 64-(hlc11e-hlc11)
hlc12:
                move.l  D3,D1
                REPT 4
                movem.l D1-D6,-(A0)
                ENDR
                movem.l D7/A2-A6,-(A0)
                movem.l D7/A2-A6,-(A0)
                movem.l D7/A2-A4,-(A0)
                dbra    D0,h_clear_l
                bra     h_end_clear_fill
hlc12e:
                DS.B 64-(hlc12e-hlc12)
hlc13:
                move.l  D3,D1
                REPT 4
                movem.l D1-D6,-(A0)
                ENDR
                move.l  D2,-(A0)
                move.l  D1,-(A0)
                movem.l D7/A2-A6,-(A0)
                movem.l D7/A2-A6,-(A0)
                move.l  A2,-(A0)
                move.l  D7,-(A0)
                dbra    D0,h_clear_l
                bra     h_end_clear_fill
hlc13e:
                DS.B 64-(hlc13e-hlc13)
hlc14:
                move.l  D3,D1
                REPT 4
                movem.l D1-D6,-(A0)
                ENDR
                movem.l D1-D4,-(A0)
                movem.l D7/A2-A6,-(A0)
                movem.l D7/A2-A6,-(A0)
                dbra    D0,h_clear_l
                bra     h_end_clear_fill
hlc14e:
                DS.B 64-(hlc14e-hlc14)
hlc15:
                move.l  D3,D1
                REPT 5
                movem.l D1-D6,-(A0)
                ENDR
                movem.l D7/A2-A6,-(A0)
                movem.l D7/A2-A4,-(A0)
                dbra    D0,h_clear_l
                bra     h_end_clear_fill
hlc15e:
                DS.B 64-(hlc15e-hlc15)
hlc16:
                move.l  D3,D1
                REPT 5
                movem.l D1-D6,-(A0)
                ENDR
                move.l  D2,-(A0)
                move.l  D1,-(A0)
                movem.l D7/A2-A6,-(A0)
                move.l  A2,-(A0)
                move.l  D7,-(A0)
                dbra    D0,h_clear_l
                bra     h_end_clear_fill
hlc16e:
                DS.B 64-(hlc16e-hlc16)
hlc17:
                move.l  D3,D1
                REPT 5
                movem.l D1-D6,-(A0)
                ENDR
                movem.l D1-D4,-(A0)
                movem.l D7/A2-A6,-(A0)
                dbra    D0,h_clear_l
                bra     h_end_clear_fill
hlc17e:
                DS.B 64-(hlc17e-hlc17)
hlc18:
                move.l  D3,D1
                REPT 6
                movem.l D1-D6,-(A0)
                ENDR
                movem.l D7/A2-A4,-(A0)
                dbra    D0,h_clear_l
                bra     h_end_clear_fill
hlc18e:
                DS.B 64-(hlc18e-hlc18)
hlc19:
                move.l  D3,D1
                REPT 6
                movem.l D1-D6,-(A0)
                ENDR
                move.l  D2,-(A0)
                move.l  D1,-(A0)
                move.l  A2,-(A0)
                move.l  D7,-(A0)
                dbra    D0,h_clear_l
                bra     h_end_clear_fill
hlc19e:
                DS.B 64-(hlc19e-hlc19)
hlc20:
                move.l  D3,D1
                REPT 6
                movem.l D1-D6,-(A0)
                ENDR
                movem.l D1-D4,-(A0)
                dbra    D0,h_clear_l
                bra     h_end_clear_fill
hlc20e:
                DS.B 64-(hlc20e-hlc20)

h_clear_l:
                move.l  -(A1),D1
                asl.w   #3,D1
                jmp     hlc20(PC,D1.w)
; Err, there's no way it can get to here!

                REPT 200
                illegal
                ENDR

; Clear right bit!
h_clear_right:
                move.l  #ground1,D1
                move.l  #ground2,D2
                move.l  D1,D3
                move.l  D2,D4
                move.l  D1,D5
                move.l  D2,D6
                move.l  #sky1,D7
                movea.l #sky2,A2
                movea.l D7,A3
                movea.l A2,A4
                movea.l D7,A5
                movea.l A2,A6

                bra     h_clear_r

                REPT 200
                illegal
                ENDR

h_clear_r:
                move.l  -(A1),D1
                lsl.w   #3,D1
                jmp     c1(PC,D1.w)

                REPT 32
                illegal
                ENDR

;c0:                                    ; Err..!  Seems 1 chunk less..!
;                move.l  D3,D1
;                REPT 6
;                movem.l D1-D6,-(A0)
;                ENDR
;                movem.l D1-D4,-(A0)
;                dbra    D0,h_clear_r
;                bra     h_end_clear_fill
;c0e:
;                DS.B 64-(c0e-c0)
c1:
                move.l  D3,D1
                REPT 6
                movem.l D1-D6,-(A0)
                ENDR
                move.l  D2,-(A0)
                move.l  D1,-(A0)
                move.l  A2,-(A0)
                move.l  D7,-(A0)
                dbra    D0,h_clear_r
                bra     h_end_clear_fill
c1e:
                DS.B 64-(c1e-c1)
c2:
                move.l  D3,D1
                REPT 6
                movem.l D1-D6,-(A0)
                ENDR
                movem.l D7/A2-A4,-(A0)
                dbra    D0,h_clear_r
                bra     h_end_clear_fill
c2e:
                DS.B 64-(c2e-c2)
c3:
                move.l  D3,D1
                REPT 5
                movem.l D1-D6,-(A0)
                ENDR
                movem.l D1-D4,-(A0)
                movem.l D7/A2-A6,-(A0)
                dbra    D0,h_clear_r
                bra     h_end_clear_fill
c3e:
                DS.B 64-(c3e-c3)
c4:
                move.l  D3,D1
                REPT 5
                movem.l D1-D6,-(A0)
                ENDR
                move.l  D2,-(A0)
                move.l  D1,-(A0)
                movem.l D7/A2-A6,-(A0)
                move.l  A2,-(A0)
                move.l  D7,-(A0)
                dbra    D0,h_clear_r
                bra     h_end_clear_fill
c4e:
                DS.B 64-(c4e-c4)
c5:
                move.l  D3,D1
                REPT 5
                movem.l D1-D6,-(A0)
                ENDR
                movem.l D7/A2-A6,-(A0)
                movem.l D7/A2-A4,-(A0)
                dbra    D0,h_clear_r
                bra     h_end_clear_fill
c5e:
                DS.B 64-(c5e-c5)
c6:
                move.l  D3,D1
                REPT 4
                movem.l D1-D6,-(A0)
                ENDR
                movem.l D1-D4,-(A0)
                movem.l D7/A2-A6,-(A0)
                movem.l D7/A2-A6,-(A0)
                dbra    D0,h_clear_r
                bra     h_end_clear_fill
c6e:
                DS.B 64-(c6e-c6)
c7:
                move.l  D3,D1
                REPT 4
                movem.l D1-D6,-(A0)
                ENDR
                move.l  D2,-(A0)
                move.l  D1,-(A0)
                movem.l D7/A2-A6,-(A0)
                movem.l D7/A2-A6,-(A0)
                move.l  A2,-(A0)
                move.l  D7,-(A0)
                dbra    D0,h_clear_r
                bra     h_end_clear_fill
c7e:
                DS.B 64-(c7e-c7)
c8:
                move.l  D3,D1
                REPT 4
                movem.l D1-D6,-(A0)
                ENDR
                movem.l D7/A2-A6,-(A0)
                movem.l D7/A2-A6,-(A0)
                movem.l D7/A2-A4,-(A0)
                dbra    D0,h_clear_r
                bra     h_end_clear_fill
c8e:
                DS.B 64-(c8e-c8)
c9:
                move.l  D3,D1
                movem.l D1-D6,-(A0)
                movem.l D1-D6,-(A0)
                movem.l D1-D6,-(A0)
                movem.l D1-D4,-(A0)
                movem.l D7/A2-A6,-(A0)
                movem.l D7/A2-A6,-(A0)
                movem.l D7/A2-A6,-(A0)
                dbra    D0,h_clear_r
                bra     h_end_clear_fill
c9e:
                DS.B 64-(c9e-c9)
c10:
                move.l  D3,D1
                movem.l D1-D6,-(A0)
                movem.l D1-D6,-(A0)
                movem.l D1-D6,-(A0)
                move.l  D2,-(A0)
                move.l  D1,-(A0)
                movem.l D7/A2-A6,-(A0)
                movem.l D7/A2-A6,-(A0)
                movem.l D7/A2-A6,-(A0)
                move.l  A2,-(A0)
                move.l  D7,-(A0)
                dbra    D0,h_clear_r
                bra     h_end_clear_fill
c10e:
                DS.B 64-(c10e-c10)
c11:
                move.l  D3,D1
                movem.l D1-D6,-(A0)
                movem.l D1-D6,-(A0)
                movem.l D1-D6,-(A0)
                movem.l D7/A2-A6,-(A0)
                movem.l D7/A2-A6,-(A0)
                movem.l D7/A2-A6,-(A0)
                movem.l D7/A2-A4,-(A0)
                dbra    D0,h_clear_r
                bra     h_end_clear_fill
c11e:
                DS.B 64-(c11e-c11)
c12:
                move.l  D3,D1

                movem.l D1-D6,-(A0)
                movem.l D1-D6,-(A0)
                movem.l D1-D4,-(A0)
                REPT 4
                movem.l D7/A2-A6,-(A0)
                ENDR
                dbra    D0,h_clear_r
                bra     h_end_clear_fill
c12e:
                DS.B 64-(c12e-c12)
c13:
                move.l  D3,D1
                movem.l D1-D6,-(A0)
                movem.l D1-D6,-(A0)
                move.l  D2,-(A0)
                move.l  D1,-(A0)
                REPT 4
                movem.l D7/A2-A6,-(A0)
                ENDR
                move.l  A2,-(A0)
                move.l  D7,-(A0)
                dbra    D0,h_clear_r
                bra     h_end_clear_fill
c13e:
                DS.B 64-(c13e-c13)
c14:
                move.l  D3,D1
                movem.l D1-D6,-(A0)
                movem.l D1-D6,-(A0)
                REPT 4
                movem.l D7/A2-A6,-(A0)
                ENDR
                movem.l D7/A2-A4,-(A0)
                dbra    D0,h_clear_r
                bra     h_end_clear_fill
c14e:
                DS.B 64-(c14e-c14)
c15:
                move.l  D3,D1
                movem.l D1-D6,-(A0)
                movem.l D1-D4,-(A0)
                REPT 5
                movem.l D7/A2-A6,-(A0)
                ENDR
                dbra    D0,h_clear_r
                bra     h_end_clear_fill
c15e:
                DS.B 64-(c15e-c15)
c16:
                move.l  D3,D1
                movem.l D1-D6,-(A0)
                move.l  D2,-(A0)
                move.l  D1,-(A0)
                REPT 5
                movem.l D7/A2-A6,-(A0)
                ENDR
                move.l  A2,-(A0)
                move.l  D7,-(A0)
                dbra    D0,h_clear_r
                bra     h_end_clear_fill
c16e:
                DS.B 64-(c16e-c16)
c17:
                move.l  D3,D1
                movem.l D1-D6,-(A0)
                REPT 5
                movem.l D7/A2-A6,-(A0)
                ENDR
                movem.l D7/A2-A4,-(A0)
                dbra    D0,h_clear_r
                bra     h_end_clear_fill
c17e:
                DS.B 64-(c17e-c17)
c18:
                move.l  D3,D1
                movem.l D1-D4,-(A0)
                REPT 6
                movem.l D7/A2-A6,-(A0)
                ENDR
                dbra    D0,h_clear_r
                bra     h_end_clear_fill
c18e:
                DS.B 64-(c18e-c18)
c19:
                move.l  D3,D1
                move.l  D2,-(A0)
                move.l  D1,-(A0)
                REPT 6
                movem.l D7/A2-A6,-(A0)
                ENDR
                move.l  A2,-(A0)
                move.l  D7,-(A0)
                dbra    D0,h_clear_r
                bra     h_end_clear_fill
c19e:
                DS.B 64-(c19e-c19)
c20:
                move.l  D3,D1
                REPT 6
                movem.l D7/A2-A6,-(A0)
                ENDR
                movem.l D7/A2-A4,-(A0)
                dbra    D0,h_clear_r
                bra     h_end_clear_fill
c20e:
                DS.B 64-(c20e-c20)

                REPT 200
                illegal
                ENDR


h_end_clear_fill:

; Now fill the edge, and edge only, of the horizon 'triangle'!
                btst    #0,horizon_flags+1
                beq.s   h_left_fill
; Right fill.
;                move.w  #1,D0           ; Colour.
;                add.w   D0,D0           ; Word access.
;                lea     coltab(PC),A0
;                lea     col1(PC),A2
;                adda.w  0(A0,D0.w),A2
;                addq.w  #8,A2           ; Skip colours
;                lea     h_mcol2(PC),A0 ; Hmm, uses different regs!!
;                move.l  (A2)+,D0
;                move.l  (A2)+,D1        ; Get instructions.
;                move.l  D0,(A0)+        ; Self modify 1rst chunk thing.
;                move.l  D1,(A0)+

                movea.l scrn2,A0
                move.w  h_starty(PC),D0
                add.w   D0,D0
                lea     yoffs,A1
                adda.w  0(A1,D0.w),A0
                movea.l A0,A5

                lea     lpoints(PC),A2

                move.w  h_triheight(PC),D0
                subq.w  #1,D0
                bmi.s   h_end_middle_fill

h_draw_l:
                move.l  (A2)+,D5
                adda.w  D5,A0           ; Simple as that!

                swap    D5              ; Get mask.
                move.w  D5,D6
                not.w   D6
h_mcol1:        or.w    D5,(A0)+
                and.w   D6,(A0)+
                and.w   D6,(A0)+
                and.w   D6,(A0)+
                lea     160(A5),A5
                movea.l A5,A0
                dbra    D0,h_draw_l
                bra.s   h_end_middle_fill

h_left_fill:
; Left fill (!).
                movea.l scrn2,A0
                move.w  h_starty(PC),D0
                add.w   D0,D0
                lea     yoffs,A1
                adda.w  0(A1,D0.w),A0
                movea.l A0,A5

                lea     lpoints(PC),A2

                move.w  h_triheight(PC),D0
                subq.w  #1,D0
                bmi.s   h_end_middle_fill

h_draw_2:
                move.l  (A2)+,D7
                suba.w  D7,A0

                swap    D7              ; Get mask.
                move.w  D7,D6
                not.w   D6
h_mcol2:        or.w    D7,(A0)+
                and.w   D6,(A0)+
                and.w   D6,(A0)+
                and.w   D6,(A0)+
                lea     160(A5),A5
                movea.l A5,A0
                dbra    D0,h_draw_2

h_end_middle_fill:

; Right, now we fast fill the top and bottom regions above and below the horizon
; 'triangle', according to the edge it's on (normal or upside-down!).
                btst    #1,horizon_flags+1
                bne.s   h_filltop
; Fill 'bottom' as in ground at the bottom, sky at the top!
                move.w  h_starty(PC),D0
                add.w   h_triheight(PC),D0
                subq.w  #1,D0
                move.w  clipbottom,D7
                move.w  D7,D2
                sub.w   D0,D7           ; Calculate leftover screen region.
                ble.s   h_noneed1
                addq.w  #1,D2
                mulu    #160,D2
                move.l  #ground1,D0
                move.l  #ground2,D1
                movea.l scrn2,A0
                adda.l  D2,A0
                bsr     cls
h_noneed1:
                move.w  h_starty(PC),D7
                move.w  D7,D2
                move.w  cliptop,D0
                sub.w   D0,D7
                ble.s   h_end_fastfill
                mulu    #160,D2
                move.l  #sky1,D0
                move.l  #sky2,D1
                movea.l scrn2,A0
                adda.l  D2,A0
                bsr     cls
                bra.s   h_end_fastfill  ; Skip the rest of the junk.


h_filltop:
; Fill 'top' as in ground at the top, sky at the bottom!
                move.w  h_starty(PC),D7
                move.w  D7,D2
                move.w  cliptop,D0
                sub.w   D0,D7
                ble.s   h_noneed2
                mulu    #160,D2
                move.l  #ground1,D0
                move.l  #ground2,D1
                movea.l scrn2,A0
                adda.l  D2,A0
                bsr     cls
h_noneed2:
                move.w  h_starty(PC),D0
                add.w   h_triheight(PC),D0
                subq.w  #1,D0
                move.w  clipbottom,D7
                move.w  D7,D2
                sub.w   D0,D7
                ble.s   h_end_fastfill
                addq.w  #1,D2
                mulu    #160,D2
                move.l  #sky1,D0
                move.l  #sky2,D1
                movea.l scrn2,A0
                adda.l  D2,A0
                bsr     cls

h_end_fastfill:
                bra.s   horizon_done


; No horizon visible.  Ok, so we fill according to wether we see ground or sky.
; This we do by having a line at a right-angle to the horizon (pointing dead
; ahead if angles are 0,0,0) and we see which region of the 'globe' in the
; horizon we are looking at by determining which endpoint is greater in the Z.
; Quite nifty, even if I do say so myself!!
no_horizon:
                movem.w horizonr+12(PC),D0-D5 ; Get center points of horizon.
                cmp.w   D2,D5           ; Determine which is greater.
                bgt.s   h_is_sky
                move.l  #ground1,D0
                moveq   #ground2,D1
                bra.s   h_fill_it
h_is_sky:
                move.l  #sky1,D0
                moveq   #sky2,D1

h_fill_it:      movea.l scrn2,A0
                move.w  clipbottom,D2
                addq.w  #1,D2
                move.w  D2,D7
                mulu    #160,D2
                adda.l  D2,A0
                sub.w   cliptop,D7
                bsr     cls
;                bra     horizon_done


horizon_done:
                rts


;-------------------------------------------- Tables, storage, etc.

h_starty:       DS.W 1
h_triheight:    DS.W 1

horizon_flags:  DS.W 1
horizon_screen_c:
                DS.W 4
horizon:        DC.W -7000,0,7000,7000,0,7000,0,160,0,0,-160,0
horizonr:       DS.W 12
h_space:        DS.W 12

; Left edge masks & offsets.
h_lefted:
cchunk          SET 0
                REPT 20
                DC.W %1111111111111111,cchunk
                DC.W %111111111111111,cchunk
                DC.W %11111111111111,cchunk
                DC.W %1111111111111,cchunk
                DC.W %111111111111,cchunk
                DC.W %11111111111,cchunk
                DC.W %1111111111,cchunk
                DC.W %111111111,cchunk
                DC.W %11111111,cchunk
                DC.W %1111111,cchunk
                DC.W %111111,cchunk
                DC.W %11111,cchunk
                DC.W %1111,cchunk
                DC.W %111,cchunk
                DC.W %11,cchunk
                DC.W %1,cchunk
cchunk          SET cchunk+8
                ENDR

; Right edge masks & offsets.
h_righted:
cchunk          SET 0
                REPT 20
                DC.W %1000000000000000,-cchunk
                DC.W %1100000000000000,-cchunk
                DC.W %1110000000000000,-cchunk
                DC.W %1111000000000000,-cchunk
                DC.W %1111100000000000,-cchunk
                DC.W %1111110000000000,-cchunk
                DC.W %1111111000000000,-cchunk
                DC.W %1111111100000000,-cchunk
                DC.W %1111111110000000,-cchunk
                DC.W %1111111111000000,-cchunk
                DC.W %1111111111100000,-cchunk
                DC.W %1111111111110000,-cchunk
                DC.W %1111111111111000,-cchunk
                DC.W %1111111111111100,-cchunk
                DC.W %1111111111111110,-cchunk
                DC.W %1111111111111111,-cchunk
cchunk          SET cchunk+8
                ENDR

                ENDPART

                >PART 'Blitter operations'

use_blitter:
                move.w  blt_s_xinc(PC),$FFFF8A20.w ; Source X increment.
                move.w  blt_s_yinc(PC),$FFFF8A22.w ; Source Y increment.
                move.l  blt_s_addr(PC),$FFFF8A24.w ; Source address.

                move.w  blt_emask1(PC),$FFFF8A28.w ; Endmask 1.
                move.w  blt_emask2(PC),$FFFF8A2A.w ; Endmask 2.
                move.w  blt_emask3(PC),$FFFF8A2C.w ; Endmask 3.

                move.w  blt_d_xinc(PC),$FFFF8A2E.w ; Destination X increment.
                move.w  blt_d_yinc(PC),$FFFF8A30.w ; Destination Y increment.
                move.l  blt_d_addr(PC),$FFFF8A32.w ; Destination address.

                move.w  blt_xwords(PC),$FFFF8A36.w ; Number of words across (X).
                move.w  blt_ywords(PC),$FFFF8A38.w ; Number of lines (Y).

                move.b  blt_halftone(PC),$FFFF8A3A.w ; Half tone operation (2 = Source).
                move.b  blt_logical(PC),$FFFF8A3B.w ; Logical operation (3 = source).

                move.b  blt_skew(PC),$FFFF8A3D.w ; Skew and FXSR and NFSR thing.

                move.b  blt_op(PC),$FFFF8A3C.w ; Start blitting in HOG mode!

                rts

blt_s_xinc:     DS.W 1
blt_s_yinc:     DS.W 1
blt_s_addr:     DS.L 1
blt_d_xinc:     DS.W 1
blt_d_yinc:     DS.W 1
blt_d_addr:     DS.L 1

blt_xwords:     DS.W 1
blt_ywords:     DS.W 1

blt_halftone:   DS.B 1
blt_logical:    DS.B 1

blt_skew:       DS.B 1
blt_op:         DS.B 1

blt_emask1:     DS.W 1
blt_emask2:     DS.W 1
blt_emask3:     DS.W 1

                ENDPART

;-------------

                >PART 'Keyboard interrupts etc'

******** KEYBOARD HANDLER INTERRUPT - New, faster version!

khand:          move.w  D0,-(SP)        * Save D0.
                clr.w   D0
                move.b  $FFFFFC02.w,D0  * Get byte from keyboard.
                cmpi.w  #247,D0         * Izzit a mouse package?
                ble.s   nomous          * No... Get key value.
                move.b  D0,button
                move.l  #khand2,$0118.w * Install another (get mouse pack).
                move.w  (SP)+,D0
                rte
nomous:         move.b  D0,keybyt       * Put byte for key read.
                move.w  (SP)+,D0        * Restore D0.
                rte                     * Return.

khand2:         move.w  D0,-(SP)
                move.b  $FFFFFC02.w,D0  * Get byte from keyboard - X coord.
                ext.w   D0
                sub.w   D0,rotatex
                move.w  (SP)+,D0
                move.l  #khand3,$0118.w * Low byte...
                rte                     * Return.

khand3:         move.w  D0,-(SP)
                move.b  $FFFFFC02.w,D0  * Get byte from keyboard - X coord.
                ext.w   D0
                sub.w   D0,rotatey
                move.w  (SP)+,D0
                move.l  #khand,$0118.w  * Y bytes.
                rte                     * Return.


ksend:          move.b  (A0)+,D0        * Number of bytes to send.
notrdy:         btst    #1,$FFFFFC00.w
                beq.s   notrdy          * Wait for keyboard ready.
                move.b  (A0)+,$FFFFFC02.w * Aha! Got you! Here! Take this!
                subq.b  #1,D0
                bne.s   notrdy          * Repeat for number of bytes.
                rts                     * Return from this routine.

                ENDPART

                >PART 'Quicksort routine'

;
; Quicksort routine...  Needs start of list in A0, and last item in A1, not
; AFTER last item, but pointing at it!  It re-orders the list, which in this
; case items are 8 bytes long, and uses the first word to sort in descending
; order.
;
;                lea     ween(PC),A0
;                lea     weenend-8(PC),A1
;                bsr     quicksort
;                illegal

Quicksort:
                movem.l A0-A3,-(SP)
                movea.l A0,A2           ; Copy regs.
                movea.l A1,A3
                move.l  A1,D1
                sub.l   A0,D1           ; Calc middle position.
                lsr.w   #1,D1
                andi.w  #$FFF8,D1
                move.w  0(A0,D1.w),D0   ; Now get false 'median'.
Quicksortloop1:
                cmp.w   (A2),D0         ; Is (top) value > median?.
                bge.s   Quicksortloop2  ; No, check other.
                addq.w  #8,A2           ; Yup, Move top downwards.
                bra.s   Quicksortloop1
Quicksortloop2:
                cmp.w   (A3),D0         ; Is (end) value < median?.
                ble.s   Continue_some_more ; No...  continue other checks.
                subq.w  #8,A3           ; Yep...  Move end upwards.
                bra.s   Quicksortloop2
Continue_some_more:
                cmpa.l  A3,A2           ; Have ends crossed over?
                bgt.s   Out_of_this_bit ; Yep, so re-set.
                move.l  (A2),D1         ; Else swap (top) and (end) values.
                move.l  (A3),(A2)+      ; Swap number.
                move.l  D1,(A3)+
                move.l  (A2),D1         ; Carry key as well!
                move.l  (A3),(A2)+
                move.l  D1,(A3)         ; We now have moved (top) 2 ptrs
                lea     -12(A3),A3      ; down and (end) 2 ptrs up.
                cmpa.l  A3,A2           ; Check for crossover.
                ble.s   Quicksortloop1  ; Nope...  Continue...
Out_of_this_bit:
                cmpa.l  A3,A0           ; Has end crossed start?
                bge.s   Backfromrecursion1 ; Yes, we have finished a box.
                move.l  A1,-(SP)        ; Else store end pointer.
                movea.l A3,A1           ; Now make current this end.
                bsr.s   Quicksort       ; And now do this half box.
                movea.l (SP)+,A1        ; Restore end pointer.
Backfromrecursion1:
                cmpa.l  A2,A1           ; Has top crossed end?
                bge.s   Doquickagain2   ; No, so continue sort...
                movem.l (SP)+,A0-A3     ; Yes!  Done quicksort.
                rts
Doquickagain2:
                movea.l A2,A0           ; Else make new top current top.
                bsr.s   Quicksort       ; And continue sort...
                movem.l (SP)+,A0-A3
                rts

                ENDPART


; -------------------------------->
;
; 3D SUBROUTINES.
;

                >PART 'Generate a 3x3 matrix'

**********************************
* Generate a 3x3 matrix.
make_matrix:

; Generate object matrix angles (X,Y,Z) held in D0,D2,D4.
; 3x3 matrix to write to in A0.
; Trashes D0-D7, A1-A2.
                lea     sintab(PC),A1   ; SET UP MATRIX.
                lea     512(A1),A2
                move.w  #1023,D6
mat_xangle:
*               move.w  xang(PC),D0
                and.w   D6,D0
                add.w   D0,D0
                move.w  0(A1,D0.w),D1   ; Sin X into D1
                move.w  0(A2,D0.w),D0   ; Cos X into D0.
mat_yangle:
*               move.w  yang(PC),D2
                and.w   D6,D2
                add.w   D2,D2
                move.w  0(A1,D2.w),D3   ; Sin Y into D3
                move.w  0(A2,D2.w),D2   ; Cos Y into D2.
mat_zangle:
*               move.w  zang(PC),D4
                and.w   D6,D4
                add.w   D4,D4
                move.w  0(A1,D4.w),D5   ; Sin Z into D5
                move.w  0(A2,D4.w),D4   ; Cos Z into D4.

* D0=CosX
* D1=SinX
* D2=CosY
* D3=SinY
* D4=CosZ
* D5=SinZ
*
* Cy*Cz,Cy*Sz,Sy
* !Sx*Sy!*Cz+Cx*-Sz,!Sx*Sy!*Sz+Cx*Cz,-Sx*Cy
* ;Cx*-Sy;*Cz+Sx*-Sz,;Cx*-Sy;*Sz+Sx*Cz,Cx*Cy

gen_mat_x:      move.w  D4,D6           ; Store CosZ.
                muls    D2,D4           ; CosY * CosZ.
                add.l   D4,D4
                swap    D4
                move.w  D4,(A0)+        ; > M1,1
                move.w  D6,D4           ; Restore Cos Z.
                move.w  D5,D6           ; Store SinZ.
                muls    D2,D5           ; CosY * SinZ.
                add.l   D5,D5
                swap    D5
                move.w  D5,(A0)+        ; > M2,1
                move.w  D6,D5
                move.w  D3,(A0)+        ; > M3,1 = SinY. Also stores d3!
                move.w  D3,D7           ; Store for later use.
gen_mat_y:      muls    D1,D3           ; SinX * SinY
                add.l   D3,D3
                swap    D3
                movea.w D3,A4           ; Store for later.
                muls    D4,D3           ; * CosZ.
                move.w  D5,D6           ; Store SinZ.
                neg.w   D5              ; SinZ = -SinZ.
                muls    D0,D5           ; CosX * -SinZ.
                add.l   D5,D3
                add.l   D3,D3
                swap    D3
                move.w  D3,(A0)+        ; > M1,2.
                move.w  A4,D3           ; Fetch SinX * SinY.
                move.w  D6,D5           ; Restore SinZ.
                muls    D5,D3           ; * SinZ.
                move.w  D4,D6           ; Store CosZ.
                muls    D0,D4           ; CosX * CosZ.
                add.l   D4,D3
                add.l   D3,D3
                swap    D3
                move.w  D6,D4           ; Restore CosZ.
                move.w  D3,(A0)+        ; > M2,2
                move.w  D7,D3           ; Restore SinY.
                move.w  D1,D6           ; Store SinX.
                neg.w   D1              ; SinX = -SinX.
                muls    D2,D1           ; -SinX * CosY.
                add.l   D1,D1
                swap    D1
                move.w  D1,(A0)+        ; > M3,2.
                move.w  D6,D1           ; Restore SinX.
gen_mat_z:      neg.w   D3              ; SinY = -SinY.
                muls    D0,D3           ; CosX * -SinY.
                add.l   D3,D3
                swap    D3
                movea.w D3,A4           ; Store for later.
                muls    D4,D3           ; * CosZ.
                move.w  D5,D6           ; Store SinZ.
                neg.w   D5              ; SinZ = -SinZ.
                muls    D1,D5           ; SinX * -SinZ.
                add.l   D5,D3
                add.l   D3,D3
                swap    D3
                move.w  D3,(A0)+        ; > M1,3
                move.w  A4,D3           ; Get CosX * -SinY.
                muls    D6,D3           ; * SinZ.
                muls    D1,D4           ; SinX * CosZ.
                add.l   D4,D3
                add.l   D3,D3
                swap    D3
                move.w  D3,(A0)+        ; > M2,3
                muls    D0,D2           ; CosX * CosY.
                add.l   D2,D2
                swap    D2
                move.w  D2,(A0)+        ; > M3,3

                rts

                ENDPART

                >PART 'Sin table'

sintab:         DC.W $00,$C9,$0192,$025B,$0324,$03ED,$04B6,$057E
                DC.W $0647,$0710,$07D9,$08A1,$096A,$0A32,$0AFB,$0BC3
                DC.W $0C8B,$0D53,$0E1B,$0EE3,$0FAB,$1072,$1139,$1200
                DC.W $12C7,$138E,$1455,$151B,$15E1,$16A7,$176D,$1833
                DC.W $18F8,$19BD,$1A82,$1B46,$1C0B,$1CCF,$1D93,$1E56
                DC.W $1F19,$1FDC,$209F,$2161,$2223,$22E4,$23A6,$2467
                DC.W $2527,$25E7,$26A7,$2767,$2826,$28E5,$29A3,$2A61
                DC.W $2B1E,$2BDB,$2C98,$2D54,$2E10,$2ECC,$2F86,$3041
                DC.W $30FB,$31B4,$326D,$3326,$33DE,$3496,$354D,$3603
                DC.W $36B9,$376F,$3824,$38D8,$398C,$3A3F,$3AF2,$3BA4
                DC.W $3C56,$3D07,$3DB7,$3E67,$3F16,$3FC5,$4073,$4120
                DC.W $41CD,$4279,$4325,$43D0,$447A,$4523,$45CC,$4674
                DC.W $471C,$47C3,$4869,$490E,$49B3,$4A57,$4AFA,$4B9D
                DC.W $4C3F,$4CE0,$4D80,$4E20,$4EBF,$4F5D,$4FFA,$5097
                DC.W $5133,$51CE,$5268,$5301,$539A,$5432,$54C9,$555F
                DC.W $55F4,$5689,$571D,$57B0,$5842,$58D3,$5963,$59F3
                DC.W $5A81,$5B0F,$5B9C,$5C28,$5CB3,$5D3D,$5DC6,$5E4F
                DC.W $5ED6,$5F5D,$5FE2,$6067,$60EB,$616E,$61F0,$6271
                DC.W $62F1,$6370,$63EE,$646B,$64E7,$6562,$65DD,$6656
                DC.W $66CE,$6745,$67BC,$6831,$68A5,$6919,$698B,$69FC
                DC.W $6A6C,$6ADB,$6B4A,$6BB7,$6C23,$6C8E,$6CF8,$6D61
                DC.W $6DC9,$6E30,$6E95,$6EFA,$6F5E,$6FC0,$7022,$7082
                DC.W $70E1,$7140,$719D,$71F9,$7254,$72AE,$7306,$735E
                DC.W $73B5,$740A,$745E,$74B1,$7503,$7554,$75A4,$75F3
                DC.W $7640,$768D,$76D8,$7722,$776B,$77B3,$77F9,$783F
                DC.W $7883,$78C6,$7908,$7949,$7989,$79C7,$7A04,$7A41
                DC.W $7A7C,$7AB5,$7AEE,$7B25,$7B5C,$7B91,$7BC4,$7BF7
                DC.W $7C29,$7C59,$7C88,$7CB6,$7CE2,$7D0E,$7D38,$7D61
                DC.W $7D89,$7DB0,$7DD5,$7DF9,$7E1C,$7E3E,$7E5E,$7E7E
                DC.W $7E9C,$7EB9,$7ED4,$7EEF,$7F08,$7F20,$7F37,$7F4C
                DC.W $7F61,$7F74,$7F86,$7F96,$7FA6,$7FB4,$7FC1,$7FCD
                DC.W $7FD7,$7FE0,$7FE8,$7FEF,$7FF5,$7FF9,$7FFC,$7FFE
                DC.W $7FFF,$7FFE,$7FFC,$7FF9,$7FF5,$7FEF,$7FE8,$7FE0
                DC.W $7FD7,$7FCD,$7FC1,$7FB4,$7FA6,$7F96,$7F86,$7F74
                DC.W $7F61,$7F4C,$7F37,$7F20,$7F08,$7EEF,$7ED4,$7EB9
                DC.W $7E9C,$7E7E,$7E5E,$7E3E,$7E1C,$7DF9,$7DD5,$7DB0
                DC.W $7D89,$7D61,$7D38,$7D0E,$7CE2,$7CB6,$7C88,$7C59
                DC.W $7C29,$7BF7,$7BC4,$7B91,$7B5C,$7B25,$7AEE,$7AB5
                DC.W $7A7C,$7A41,$7A04,$79C7,$7989,$7949,$7908,$78C6
                DC.W $7883,$783F,$77F9,$77B3,$776B,$7722,$76D8,$768D
                DC.W $7640,$75F3,$75A4,$7554,$7503,$74B1,$745E,$740A
                DC.W $73B5,$735E,$7306,$72AE,$7254,$71F9,$719D,$7140
                DC.W $70E1,$7082,$7022,$6FC0,$6F5E,$6EFA,$6E95,$6E30
                DC.W $6DC9,$6D61,$6CF8,$6C8E,$6C23,$6BB7,$6B4A,$6ADB
                DC.W $6A6C,$69FC,$698B,$6919,$68A5,$6831,$67BC,$6745
                DC.W $66CE,$6656,$65DD,$6562,$64E7,$646B,$63EE,$6370
                DC.W $62F1,$6271,$61F0,$616E,$60EB,$6067,$5FE2,$5F5D
                DC.W $5ED6,$5E4F,$5DC6,$5D3D,$5CB3,$5C28,$5B9C,$5B0F
                DC.W $5A81,$59F3,$5963,$58D3,$5842,$57B0,$571D,$5689
                DC.W $55F4,$555F,$54C9,$5432,$539A,$5301,$5268,$51CE
                DC.W $5133,$5097,$4FFA,$4F5D,$4EBF,$4E20,$4D80,$4CE0
                DC.W $4C3F,$4B9D,$4AFA,$4A57,$49B3,$490E,$4869,$47C3
                DC.W $471C,$4674,$45CC,$4523,$447A,$43D0,$4325,$4279
                DC.W $41CD,$4120,$4073,$3FC5,$3F16,$3E67,$3DB7,$3D07
                DC.W $3C56,$3BA4,$3AF2,$3A3F,$398C,$38D8,$3824,$376F
                DC.W $36B9,$3603,$354D,$3496,$33DE,$3326,$326D,$31B4
                DC.W $30FB,$3041,$2F86,$2ECC,$2E10,$2D54,$2C98,$2BDB
                DC.W $2B1E,$2A61,$29A3,$28E5,$2826,$2767,$26A7,$25E7
                DC.W $2527,$2467,$23A6,$22E4,$2223,$2161,$209F,$1FDC
                DC.W $1F19,$1E56,$1D93,$1CCF,$1C0B,$1B46,$1A82,$19BD
                DC.W $18F8,$1833,$176D,$16A7,$15E1,$151B,$1455,$138E
                DC.W $12C7,$1200,$1139,$1072,$0FAB,$0EE3,$0E1B,$0D53
                DC.W $0C8B,$0BC3,$0AFB,$0A32,$096A,$08A1,$07D9,$0710
                DC.W $0647,$057E,$04B6,$03ED,$0324,$025B,$0192,$C9
                DC.W $00,$FF37,$FE6E,$FDA5,$FCDC,$FC13,$FB4A,$FA82
                DC.W $F9B9,$F8F0,$F827,$F75F,$F696,$F5CE,$F505,$F43D
                DC.W $F375,$F2AD,$F1E5,$F11D,$F055,$EF8E,$EEC7,$EE00
                DC.W $ED39,$EC72,$EBAB,$EAE5,$EA1F,$E959,$E893,$E7CD
                DC.W $E708,$E643,$E57E,$E4BA,$E3F5,$E331,$E26D,$E1AA
                DC.W $E0E7,$E024,$DF61,$DE9F,$DDDD,$DD1C,$DC5A,$DB99
                DC.W $DAD9,$DA19,$D959,$D899,$D7DA,$D71B,$D65D,$D59F
                DC.W $D4E2,$D425,$D368,$D2AC,$D1F0,$D134,$D07A,$CFBF
                DC.W $CF05,$CE4C,$CD93,$CCDA,$CC22,$CB6A,$CAB3,$C9FD
                DC.W $C947,$C891,$C7DC,$C728,$C674,$C5C1,$C50E,$C45C
                DC.W $C3AA,$C2F9,$C249,$C199,$C0EA,$C03B,$BF8D,$BEE0
                DC.W $BE33,$BD87,$BCDB,$BC30,$BB86,$BADD,$BA34,$B98C
                DC.W $B8E4,$B83D,$B797,$B6F2,$B64D,$B5A9,$B506,$B463
                DC.W $B3C1,$B320,$B280,$B1E0,$B141,$B0A3,$B006,$AF69
                DC.W $AECD,$AE32,$AD98,$ACFF,$AC66,$ABCE,$AB37,$AAA1
                DC.W $AA0C,$A977,$A8E3,$A850,$A7BE,$A72D,$A69D,$A60D
                DC.W $A57F,$A4F1,$A464,$A3D8,$A34D,$A2C3,$A23A,$A1B1
                DC.W $A12A,$A0A3,$A01E,$9F99,$9F15,$9E92,$9E10,$9D8F
                DC.W $9D0F,$9C90,$9C12,$9B95,$9B19,$9A9E,$9A23,$99AA
                DC.W $9932,$98BB,$9844,$97CF,$975B,$96E7,$9675,$9604
                DC.W $9594,$9525,$94B6,$9449,$93DD,$9372,$9308,$929F
                DC.W $9237,$91D0,$916B,$9106,$90A2,$9040,$8FDE,$8F7E
                DC.W $8F1F,$8EC0,$8E63,$8E07,$8DAC,$8D52,$8CFA,$8CA2
                DC.W $8C4B,$8BF6,$8BA2,$8B4F,$8AFD,$8AAC,$8A5C,$8A0D
                DC.W $89C0,$8973,$8928,$88DE,$8895,$884D,$8807,$87C1
                DC.W $877D,$873A,$86F8,$86B7,$8677,$8639,$85FC,$85BF
                DC.W $8584,$854B,$8512,$84DB,$84A4,$846F,$843C,$8409
                DC.W $83D7,$83A7,$8378,$834A,$831E,$82F2,$82C8,$829F
                DC.W $8277,$8250,$822B,$8207,$81E4,$81C2,$81A2,$8182
                DC.W $8164,$8147,$812C,$8111,$80F8,$80E0,$80C9,$80B4
                DC.W $809F,$808C,$807A,$806A,$805A,$804C,$803F,$8033
                DC.W $8029,$8020,$8018,$8011,$800B,$8007,$8004,$8002
                DC.W $8001,$8002,$8004,$8007,$800B,$8011,$8018,$8020
                DC.W $8029,$8033,$803F,$804C,$805A,$806A,$807A,$808C
                DC.W $809F,$80B4,$80C9,$80E0,$80F8,$8111,$812C,$8147
                DC.W $8164,$8182,$81A2,$81C2,$81E4,$8207,$822B,$8250
                DC.W $8277,$829F,$82C8,$82F2,$831E,$834A,$8378,$83A7
                DC.W $83D7,$8409,$843C,$846F,$84A4,$84DB,$8512,$854B
                DC.W $8584,$85BF,$85FC,$8639,$8677,$86B7,$86F8,$873A
                DC.W $877D,$87C1,$8807,$884D,$8895,$88DE,$8928,$8973
                DC.W $89C0,$8A0D,$8A5C,$8AAC,$8AFD,$8B4F,$8BA2,$8BF6
                DC.W $8C4B,$8CA2,$8CFA,$8D52,$8DAC,$8E07,$8E63,$8EC0
                DC.W $8F1F,$8F7E,$8FDE,$9040,$90A2,$9106,$916B,$91D0
                DC.W $9237,$929F,$9308,$9372,$93DD,$9449,$94B6,$9525
                DC.W $9594,$9604,$9675,$96E7,$975B,$97CF,$9844,$98BB
                DC.W $9932,$99AA,$9A23,$9A9E,$9B19,$9B95,$9C12,$9C90
                DC.W $9D0F,$9D8F,$9E10,$9E92,$9F15,$9F99,$A01E,$A0A3
                DC.W $A12A,$A1B1,$A23A,$A2C3,$A34D,$A3D8,$A464,$A4F1
                DC.W $A57F,$A60D,$A69D,$A72D,$A7BE,$A850,$A8E3,$A977
                DC.W $AA0C,$AAA1,$AB37,$ABCE,$AC66,$ACFF,$AD98,$AE32
                DC.W $AECD,$AF69,$B006,$B0A3,$B141,$B1E0,$B280,$B320
                DC.W $B3C1,$B463,$B506,$B5A9,$B64D,$B6F2,$B797,$B83D
                DC.W $B8E4,$B98C,$BA34,$BADD,$BB86,$BC30,$BCDB,$BD87
                DC.W $BE33,$BEE0,$BF8D,$C03B,$C0EA,$C199,$C249,$C2F9
                DC.W $C3AA,$C45C,$C50E,$C5C1,$C674,$C728,$C7DC,$C891
                DC.W $C947,$C9FD,$CAB3,$CB6A,$CC22,$CCDA,$CD93,$CE4C
                DC.W $CF05,$CFBF,$D07A,$D134,$D1F0,$D2AC,$D368,$D425
                DC.W $D4E2,$D59F,$D65D,$D71B,$D7DA,$D899,$D959,$DA19
                DC.W $DAD9,$DB99,$DC5A,$DD1C,$DDDD,$DE9F,$DF61,$E024
                DC.W $E0E7,$E1AA,$E26D,$E331,$E3F5,$E4BA,$E57E,$E643
                DC.W $E708,$E7CD,$E893,$E959,$EA1F,$EAE5,$EBAB,$EC72
                DC.W $ED39,$EE00,$EEC7,$EF8E,$F055,$F11D,$F1E5,$F2AD
                DC.W $F375,$F43D,$F505,$F5CE,$F696,$F75F,$F827,$F8F0
                DC.W $F9B9,$FA82,$FB4A,$FC13,$FCDC,$FDA5,$FE6E,$FF37
                DC.W $00,$C9,$0192,$025B,$0324,$03ED,$04B6,$057E
                DC.W $0647,$0710,$07D9,$08A1,$096A,$0A32,$0AFB,$0BC3
                DC.W $0C8B,$0D53,$0E1B,$0EE3,$0FAB,$1072,$1139,$1200
                DC.W $12C7,$138E,$1455,$151B,$15E1,$16A7,$176D,$1833
                DC.W $18F8,$19BD,$1A82,$1B46,$1C0B,$1CCF,$1D93,$1E56
                DC.W $1F19,$1FDC,$209F,$2161,$2223,$22E4,$23A6,$2467
                DC.W $2527,$25E7,$26A7,$2767,$2826,$28E5,$29A3,$2A61
                DC.W $2B1E,$2BDB,$2C98,$2D54,$2E10,$2ECC,$2F86,$3041
                DC.W $30FB,$31B4,$326D,$3326,$33DE,$3496,$354D,$3603
                DC.W $36B9,$376F,$3824,$38D8,$398C,$3A3F,$3AF2,$3BA4
                DC.W $3C56,$3D07,$3DB7,$3E67,$3F16,$3FC5,$4073,$4120
                DC.W $41CD,$4279,$4325,$43D0,$447A,$4523,$45CC,$4674
                DC.W $471C,$47C3,$4869,$490E,$49B3,$4A57,$4AFA,$4B9D
                DC.W $4C3F,$4CE0,$4D80,$4E20,$4EBF,$4F5D,$4FFA,$5097
                DC.W $5133,$51CE,$5268,$5301,$539A,$5432,$54C9,$555F
                DC.W $55F4,$5689,$571D,$57B0,$5842,$58D3,$5963,$59F3
                DC.W $5A81,$5B0F,$5B9C,$5C28,$5CB3,$5D3D,$5DC6,$5E4F
                DC.W $5ED6,$5F5D,$5FE2,$6067,$60EB,$616E,$61F0,$6271
                DC.W $62F1,$6370,$63EE,$646B,$64E7,$6562,$65DD,$6656
                DC.W $66CE,$6745,$67BC,$6831,$68A5,$6919,$698B,$69FC
                DC.W $6A6C,$6ADB,$6B4A,$6BB7,$6C23,$6C8E,$6CF8,$6D61
                DC.W $6DC9,$6E30,$6E95,$6EFA,$6F5E,$6FC0,$7022,$7082
                DC.W $70E1,$7140,$719D,$71F9,$7254,$72AE,$7306,$735E
                DC.W $73B5,$740A,$745E,$74B1,$7503,$7554,$75A4,$75F3
                DC.W $7640,$768D,$76D8,$7722,$776B,$77B3,$77F9,$783F
                DC.W $7883,$78C6,$7908,$7949,$7989,$79C7,$7A04,$7A41
                DC.W $7A7C,$7AB5,$7AEE,$7B25,$7B5C,$7B91,$7BC4,$7BF7
                DC.W $7C29,$7C59,$7C88,$7CB6,$7CE2,$7D0E,$7D38,$7D61
                DC.W $7D89,$7DB0,$7DD5,$7DF9,$7E1C,$7E3E,$7E5E,$7E7E
                DC.W $7E9C,$7EB9,$7ED4,$7EEF,$7F08,$7F20,$7F37,$7F4C
                DC.W $7F61,$7F74,$7F86,$7F96,$7FA6,$7FB4,$7FC1,$7FCD
                DC.W $7FD7,$7FE0,$7FE8,$7FEF,$7FF5,$7FF9,$7FFC,$7FFE

                ENDPART

                >PART 'Rotate objects coordinates'

; Rotate object's coordinates.
; Matrix in A0.
; Start of object's X,Y,Z coordinates in A1.
; Rotated (destination) points in A2.
; Coordinate offset (to X,Y,Z) in A4 as X,Y,Z displacement.
; Number of points minus one in D7.
; On exit, A1 points to end of last coordinates rotated.

; For position rotation/check with overflow check.
rotate_pos:
                moveq   #0,D7

                move.w  2(A1),D5        ; Use lower words...  X
                move.w  6(A1),D4        ; Y
                move.w  10(A1),D3       ; Z

                sub.w   2(A5),D5        ; Viewpos, use lower word.
                sub.w   6(A5),D4
                sub.w   10(A5),D3

                move.w  D5,D0           ; Store old X.

xnewp:          move.w  D4,D1           ; Store old Y.
                move.w  D3,D2           ; Store old Z.
m11p:           muls    (A0)+,D5        ; X * M1,1.
m21p:           muls    (A0)+,D1        ; Y * M2,1.
m31p:           muls    (A0)+,D2        ; Z * M3,1.
                add.l   D1,D5           ; X * M1,1 + Y * M2,1.
                add.l   D2,D5           ; Above instr + Z * M3,1.
                add.l   D5,D5
                move    SR,D1           ; Overflow check...
                or.w    D1,D7
                swap    D5

                move.w  D0,D1           ; Store old X.
                move.w  D4,D6           ; Store old Y.

* That bit above has to be done because if it is included with the
* 4 channel player then it cannot use D6 or D7.


ynewp:          move.w  D3,D2           ; Store old Z.
m12p:           muls    (A0)+,D0        ; X * M1,2.
m22p:           muls    (A0)+,D4        ; Y * M2,2.
m32p:           muls    (A0)+,D2        ; Z * M3,2.
                add.l   D0,D4           ; X * M1,2 + Y * M2,2
                add.l   D2,D4           ; Above instr + Z * M3,2.
                add.l   D4,D4
                move    SR,D0           ; Overflow check...
                or.w    D0,D7
                swap    D4

                move.w  D6,D0           ; Get old Y.

znewp:
m13p:           muls    (A0)+,D1        ; X * M1,3.
m23p:           muls    (A0)+,D0        ; Y * M2,3.
m33p:           muls    (A0)+,D3        ; Z * M3,3.
                add.l   D1,D3           ; X * M1,3 + Y * M2,3
                add.l   D0,D3           ; Above instr + Z * M3,3.
                add.l   D3,D3           ; Adjust for fraction (X2).
                move    SR,D1           ; Oveflow check...
                or.w    D1,D7
                swap    D3              ; And divide by 32767 (max RAD).

                move.w  D5,(A2)+        ; Store X.
                move.w  D4,(A2)+        ; Store Y.
                move.w  D3,(A2)+        ; Store Z.

                rts

; For object rotation.
rotate_object:

nexp:           move.w  (A1)+,D5        ; X
                move.w  (A1)+,D4        ; Y
                move.w  (A1)+,D3        ; Z

                move.w  D5,D0           ; Store old X.

xnew:           move.w  D4,D1           ; Store old Y.
                move.w  D3,D2           ; Store old Z.
m11:            muls    (A0)+,D5        ; X * M1,1.
m21:            muls    (A0)+,D1        ; Y * M2,1.
m31:            muls    (A0)+,D2        ; Z * M3,1.
                add.l   D1,D5           ; X * M1,1 + Y * M2,1.
                add.l   D2,D5           ; Above instr + Z * M3,1.
                add.l   D5,D5
                swap    D5

                move.w  D0,D1           ; Store old X.
                move.w  D4,D6           ; Store old Y.

* That bit above has to be done because if it is included with the
* 4 channel player then it cannot use D6 or D7.


ynew:           move.w  D3,D2           ; Store old Z.
m12:            muls    (A0)+,D0        ; X * M1,2.
m22:            muls    (A0)+,D4        ; Y * M2,2.
m32:            muls    (A0)+,D2        ; Z * M3,2.
                add.l   D0,D4           ; X * M1,2 + Y * M2,2
                add.l   D2,D4           ; Above instr + Z * M3,2.
                add.l   D4,D4
                swap    D4

                move.w  D6,D0           ; Get old Y.

znew:
m13:            muls    (A0)+,D1        ; X * M1,3.
m23:            muls    (A0)+,D0        ; Y * M2,3.
m33:            muls    (A0)+,D3        ; Z * M3,3.
                add.l   D1,D3           ; X * M1,3 + Y * M2,3
                add.l   D0,D3           ; Above instr + Z * M3,3.
                add.l   D3,D3           ; Adjust for fraction (X2).
                swap    D3              ; And divide by 32767 (max RAD).

                lea     -18(A0),A0      ; Restore matrix pointer to start.

                add.w   (A4),D5
                add.w   2(A4),D4
                add.w   4(A4),D3

                move.w  D5,(A2)+        ; Store X.
                move.w  D4,(A2)+        ; Store Y.
                move.w  D3,(A2)+        ; Store Z.

                dbra    D7,nexp         ; Next point.
                rts

; For z clipped object rotation ('smooths' it).
rotate_zclipped_object:

nexzp:          move.w  (A1)+,D5        ; X
                move.w  (A1)+,D4        ; Y
                move.w  (A1)+,D3        ; Z

                lsl.w   #4,D3
                lsl.w   #4,D4
                lsl.w   #4,D5

                move.w  D5,D0           ; Store old X.

                move.w  D4,D1           ; Store old Y.
                move.w  D3,D2           ; Store old Z.
                muls    (A0)+,D5        ; X * M1,1.
                muls    (A0)+,D1        ; Y * M2,1.
                muls    (A0)+,D2        ; Z * M3,1.
                add.l   D1,D5           ; X * M1,1 + Y * M2,1.
                add.l   D2,D5           ; Above instr + Z * M3,1.
;                add.l   D5,D5
                swap    D5

                move.w  D0,D1           ; Store old X.
                move.w  D4,D6           ; Store old Y.

                move.w  D3,D2           ; Store old Z.
                muls    (A0)+,D0        ; X * M1,2.
                muls    (A0)+,D4        ; Y * M2,2.
                muls    (A0)+,D2        ; Z * M3,2.
                add.l   D0,D4           ; X * M1,2 + Y * M2,2
                add.l   D2,D4           ; Above instr + Z * M3,2.
;                add.l   D4,D4
                swap    D4

                move.w  D6,D0           ; Get old Y.

                muls    (A0)+,D1        ; X * M1,3.
                muls    (A0)+,D0        ; Y * M2,3.
                muls    (A0)+,D3        ; Z * M3,3.
                add.l   D1,D3           ; X * M1,3 + Y * M2,3
                add.l   D0,D3           ; Above instr + Z * M3,3.
;                add.l   D3,D3           ; Adjust for fraction (X2).
                swap    D3              ; And divide by 32767 (max RAD).

                lea     -18(A0),A0      ; Restore matrix pointer to start.

                movem.w (A4),D0-D2
                lsl.w   #3,D0
                lsl.w   #3,D1
                lsl.w   #3,D2
                add.w   D0,D5
                add.w   D1,D4
                add.w   D2,D3

                move.w  D5,(A2)+        ; Store X.
                move.w  D4,(A2)+        ; Store Y.
                move.w  D3,(A2)+        ; Store Z.

                dbra    D7,nexzp        ; Next point.
                rts

                ENDPART

                >PART '12 muls rotation for vcheck'
quickrot:

* Routine to rotate X,Y,Z around the X axis by angle in XANG
* with start of coordinates in A4
* New coordinates put into A4.
* Smashes a0,d0-d6 but NOT D2!!!

rotx:
                lea     sintab(PC),A0
                move.w  viewrx,D0
                and.w   #1023,D0
                add.w   D0,D0
                move.w  0(A0,D0.w),D1   * Sin into D1
                add.w   #512,D0
                move.w  0(A0,D0.w),D0   * Cos into D0
fxang:          move.w  2(A2),D3        * Get Y
                move.w  4(A2),D4        * Get Z
                move.w  D3,D5           * Store Y
                move.w  D4,D6           * Store Z
                muls    D0,D3           * Y * Cos
                muls    D1,D4           * Z * Sin
                add.l   D3,D4           * Y=Y*Cos+Z*Sin
                add.l   D4,D4
                swap    D4              * Shrink so we can see!
                muls    D0,D6           * Z * Cos
                muls    D1,D5           * Y * Sin
                sub.l   D5,D6           * Z=Z*Cos-Y*Sin
                add.l   D6,D6
                swap    D6              * Shrink so we can see!
                move.w  D4,2(A2)        * Store new Y.
                move.w  D6,4(A2)        * Store new Z.
;                rts

* Routine to rotate X,Y,Z around the Y axis by angle in XANG
* with start of coordinates in A4
* New coordinates put into A4.
* Smashes a0,d0-d6 but NOT D2!!!

roty:
                move.w  viewry,D0
                and.w   #1023,D0
                add.w   D0,D0
                move.w  0(A0,D0.w),D1   * Sin into D1
                add.w   #512,D0
                move.w  0(A0,D0.w),D0   * Cos into D0
fyang:          move.w  (A2),D3         * Get X
                move.w  4(A2),D4        * Get Z
                move.w  D3,D5           * Store X
                move.w  D4,D6           * Store Z
                muls    D0,D3           * X * Cos
                muls    D1,D4           * Z * Sin
                sub.l   D3,D4           * X=X*Cos-Z*Sin
                add.l   D4,D4
                swap    D4              * Shrink so we can see!
                muls    D1,D5           * X * Sin
                muls    D0,D6           * Z * Cos
                add.l   D5,D6           * Z=Z*Cos+X*Sin
                add.l   D6,D6
                swap    D6              * Shrink so we can see!
                move.w  D4,(A2)         * Store new X.
                move.w  D6,4(A2)        * Store new Z.
;                rts

* Routine to rotate X,Y,Z around the Z axis by angle in ZANG
* with start of coordinates in A4
* New coordinates put into A4.
* Smashes a0,d0-d6 but NOT D2!!!

rotz:
                move.w  viewrz,D0
                and.w   #1023,D0
                add.w   D0,D0
                move.w  0(A0,D0.w),D1   * Sin into D1
                add.w   #512,D0
                move.w  0(A0,D0.w),D0   * Cos into D0
fzang:          move.w  (A2),D3         * Get X
                move.w  2(A2),D4        * Get Y
                move.w  D3,D5           * Store X
                move.w  D4,D6           * Store Y
                muls    D0,D3           * X * Cos
                muls    D1,D4           * Y * Sin
                sub.l   D3,D4           * X=X*Cos-Y*Sin
                add.l   D4,D4
                swap    D4              * Shrink so we can see!
                muls    D1,D5           * X * Sin
                muls    D0,D6           * Y * Cos
                add.l   D6,D5           * Y=Y*Cos+X*Sin
                add.l   D5,D5
                swap    D5              * Shrink so we can see!
                move.w  D4,(A2)         * Store new X.
                move.w  D5,2(A2)        * Store new Y.
                rts

                ENDPART

                >PART '3x3 Matrix multiplier'

; Multiply two 3x3 matrices together.
; The two matrices are pointed to by A1 and A2.
; The destination matrix is held in A0.
mat_mul:
                REPT 3

                move.w  (A2),D0
                muls    (A1),D0
                move.w  6(A2),D1
                muls    2(A1),D1
                move.w  12(A2),D2
                muls    4(A1),D2
                add.l   D0,D1
                add.l   D1,D2
                add.l   D2,D2
                swap    D2
                move.w  D2,(A0)+

                move.w  2(A2),D0
                muls    (A1),D0
                move.w  2+6(A2),D1
                muls    2(A1),D1
                move.w  2+12(A2),D2
                muls    4(A1),D2
                add.l   D0,D1
                add.l   D1,D2
                add.l   D2,D2
                swap    D2
                move.w  D2,(A0)+

                move.w  4(A2),D0
                muls    (A1),D0
                move.w  4+6(A2),D1
                muls    2(A1),D1
                move.w  4+12(A2),D2
                muls    4(A1),D2
                add.l   D0,D1
                add.l   D1,D2
                add.l   D2,D2
                swap    D2
                move.w  D2,(A0)+
                addq.w  #6,A1

                ENDR

                rts

                ENDPART

                >PART 'Cheat movement matrix thang'

get_move_coeffs:
; Generate rightmost matrix column elements to use as movement adders.
; Note: object must be X-Z oriented (pointed away from viewer or Z).
                lea     sintab(PC),A1
                lea     512(A1),A2
                move.w  #1023,D6
                and.w   D6,D0
                add.w   D0,D0
                move.w  0(A1,D0.w),D1   ; Sin X into D1
                move.w  0(A2,D0.w),D0   ; Cos X into D0.
                and.w   D6,D2
                add.w   D2,D2
                move.w  0(A1,D2.w),D3   ; Sin Y into D3
                move.w  0(A2,D2.w),D2   ; Cos Y into D2.
* D0=CosX
* D1=SinX
* D2=CosY
* D3=SinY
*
* 0,0,Sy
* 0,0,-Sx*Cy
* 0,0,Cx*Cy
;                move.w  D3,4(A0)        ; > M3,1 = SinY. Also stores d3!
                neg.w   D1              ; SinX = -SinX.
                muls    D2,D1           ; -SinX * CosY.
                add.l   D1,D1
                swap    D1
;                move.w  D1,10(A0)       ; > M3,2.
                muls    D0,D2           ; CosX * CosY.
                add.l   D2,D2
                swap    D2
;                move.w  D2,16(A0)       ; > M3,3
; !!
                rts

                ENDPART

                >PART 'Bens lightsource'

;#####################################################
;Setlight normalises the lightsource, and sets l1..l3 accordingly
setlight:
                move.w  lightsource(PC),D0
                bge.s   doy0
                or.l    #$FFFFFC00,D0
                bra.s   doy1
doy0:           and.l   #$03FF,D0
doy1:           move.w  2+lightsource(PC),D1
                bge.s   doy2
                or.l    #$FFFFFC00,D1
                bra.s   doy3
doy2:           and.l   #$03FF,D1
doy3:           move.w  4+lightsource(PC),D2
                bge.s   doy4
                or.l    #$FFFFFC00,D2
                bra.s   doy5
doy4:           and.l   #$03FF,D2
doy5:
                move.l  D0,D3
                bge.s   l_ok1
                neg.l   D3
l_ok1:          move.l  D1,D4
                bge.s   l_ok2
                neg.l   D4
l_ok2:          move.l  D2,D5
                bge.s   l_ok3
                neg.l   D5
l_ok3:          cmp.l   D3,D4
                bge.s   l_ok4
                exg     D3,D4           ; d3 is smallest, d4 is biggest..
l_ok4:          cmp.l   D4,D5
                bge.s   l_ok5
                exg     D4,D5
l_ok5:          cmp.l   D3,D4
                bge.s   l_ok6
                exg     D3,D4           ; d3=smallest,d5=biggest..
l_ok6:
fey:
                lsl.l   #2,D5           ; 4*hi
                add.l   D5,D3           ; 4*hi + 1*lo
                lsl.l   #3,D3           ;32*hi + 8*lo
                add.l   D4,D3           ;32*hi + 1*med + 8*lo
                add.l   D4,D4           ;2*med
                add.l   D4,D3           ;32*hi + 3*med + 8*lo
                lsl.l   #2,D4           ;8*med
                add.l   D4,D3           ;32*hi+ 11*med + 8*lo
                swap    D0              ;R*32
                swap    D1
                swap    D2              ;hold dx,dy,dz*65536
                divs    D3,D0
                divs    D3,D1
                divs    D3,D2
                move.w  D0,Ll           ;
                move.w  D1,Lm           ;answer * 2048
                move.w  D2,Ln           ;
                rts
;#####################################################
;maximum values in lightsource= -$400...$3ff !!
lightsource:    DC.W 50,100,0   ;this is a vector, not a point
Ll:             DS.W 1
Lm:             DS.W 1
Ln:             DS.W 1
                EVEN
shades:         lea     shpoly(PC),A4
                movem.w 2(A4),D0-D7     ;y1,z1,x2,y2,z2,x3,y3,z3
                sub.w   (A4),D2         ;x2-x1
                sub.w   (A4),D5         ;x3-x1
                sub.w   D0,D3           ;y2-y1
                sub.w   D0,D6           ;y3-y1
                sub.w   D1,D4           ;z2-z1
                sub.w   D1,D7           ;z3-z1
;Note only the first 3 point of the poly are used..
;This has translated the poly so that 1 point is at the origin
;Now to find the Surface normal involves 6 muls and 9 subs
;instead of 9 muls, 9 subs & 6 adds
;A=y'z"-z'y"
;B=z'x"-x'z"
;C=x'y"-y'x"
;only if x'"y'"z'" are 0,0,0 though!!
;HaHa I WORKED THIS OPTIMISATION OUT MYSELF !! ..and it works fine..
                move.w  D7,D0           ;move z" into spare reg.
                muls    D3,D0           ;d0 = y'z"
                muls    D5,D3           ;d3 = y'x"
                muls    D4,D5           ;d5 = z'x"
                muls    D6,D4           ;d4 = z'y"
                muls    D2,D6           ;d6 = x'y"
                muls    D7,D2           ;d2 = x'z"      ;1 move... (on form tonite)
                sub.l   D4,D0           ;A
                sub.l   D2,D5           ;B
                sub.l   D3,D6           ;C
;       blt     bface   ;yes.. backface removal (pre perspective, though)
                move.l  D5,D1
                move.l  D6,D2           ;ok.. 3 moves (sob)
;Surface normal coefficients A,B,C in d0-d2 respectively
;Now get absolutes for SQR(x^2+y^2+z^2)
                move.l  D0,D3
                bge.s   ok1j
                neg.l   D3
ok1j:           move.l  D1,D4
                bge.s   ok2j
                neg.l   D4
ok2j:           move.l  D2,D5
                bge.s   ok3j
                neg.l   D5
ok3j:
                cmp.l   D3,D4
                bge.s   ok4j
                exg     D3,D4           ; d3 is smallest, d4 is biggest..
ok4j:           cmp.l   D4,D5
                bge.s   ok5j
                exg     D4,D5
ok5j:           cmp.l   D3,D4
                bge.s   ok6j
                exg     D3,D4           ; d3=smallest,d5=biggest..
ok6j:
damlpi:         cmp.l   #$7FFF,D5       ;needed to shrink d0-d2 resp..
                ble.s   conti           ;this is used rather than a swap
                asr.l   #1,D0           ;in order to maintain higher
                asr.l   #1,D1           ;error margin.  I tried an abortive
                asr.l   #1,D2           ;Shade63, and the error was noticeable
                lsr.l   #1,D3           ;(too much, and the saving was small)
                lsr.l   #1,D4
                lsr.l   #1,D5
                bra.s   damlpi
conti:
                muls    Ll(PC),D0       ;now safe to multiply d0-d2
                muls    Lm(PC),D1       ;without losing information
                muls    Ln(PC),D2
                add.l   D2,D1
                add.l   D1,D0

;       lsl.l   #2,d5   ; 4*hi This is the 8% sqrt business..
                add.l   D5,D5
                add.l   D5,D5
                add.l   D5,D3           ; 4*hi + 1*lo
                lsl.l   #3,D3           ;32*hi + 8*lo
                add.l   D4,D3           ;32*hi + 1*med + 8*lo
                add.l   D4,D4           ;2*med
                add.l   D4,D3           ;32*hi + 3*med + 8*lo
;                lsl.l   #2,D4           ;8*med
                add.l   D4,D4
                add.l   D4,D4
                add.l   D4,D3           ;32*hi+ 11*med + 8*lo

damlpj:         cmp.l   #$7FFF,D3
                ble.s   contj
                asr.l   #1,D0
                lsr.l   #1,D3
                bra.s   damlpj          ;this time adjust for Divide...

contj:          divs    D3,D0           ;now have shade -80..$7f ñ8%
                add.w   #$3C,D0         ;0...$7f is OK.. (this should be $40)
                blt.s   blak            ;the 8% error tends to round up, though.
                cmp.w   #$7F,D0
                bgt.s   whit
ldun:           mulu    p_data,D0
                swap    D0
                add.w   D0,colour       ;0..15
                rts
bface:          move.l  (SP)+,D0
                jmp     nxtface
blak:           clr.w   colour
                rts
whit:           move.w  #15,colour
                rts

shpoly:         DS.W 6*3

                ENDPART

                >PART 'Camera routine'

dstore:         DS.W 3

camang:

                movem.w D0-D2,dstore

;       move.l  #0,d0
;       move.l  #100,d1
;       move.l  #0,d2

                lea     sasin+4096(PC),A0

redo_cam:
                move.l  D0,D3
                move.l  D1,D4
                move.l  D2,D5
                swap    D3
                swap    D4
                muls    D0,D0
                muls    D1,D1
                muls    D2,D2

                add.l   D0,D2
                move.l  D2,D6
                add.l   D1,D6

                cmp.l   #$02000000,D6
                blt.s   ranged
*                move.w  #$04,$FFFF8240.w
                movem.w dstore(PC),D0-D2
                asr.l   #1,D0
                asr.l   #1,D1
                asr.l   #1,D2
                bra.s   camang

ranged:         move.l  D2,D6
                bsr.s   sqrt
; Returns H.
                move.l  D7,D2
                lsl.l   #4,D2

n1:             cmp.l   #$7FFF,D2
                ble.s   nx
                lsr.l   #1,D2
                asr.l   #1,D3
                bra.s   n1
nx:
                divs    D2,D3
                and.w   #$FFFE,D3
                move.w  0(A0,D3.w),D0   ; Ry

                muls    D7,D7
                add.l   D1,D7
                move.l  D7,D6
                bsr.s   sqrt
; Returns H1.

                lsl.l   #4,D7

n2:             cmp.l   #$7FFF,D7
                ble.s   nx2
                lsr.l   #1,D7
                asr.l   #1,D4
                bra.s   n2
nx2:

                divs    D7,D4
                and.w   #$FFFE,D4
                move.w  0(A0,D4.w),D1

                clr.w   D2

                tst.l   D5
                bge.s   cmfin
                add.w   #512,D0
                rts

cmfin:          neg.w   D0
                rts

sqrt:
* A routine to find the square root of a long word N in d0
* in three iterations using the formula
* squrt = 1/2(squrt + n/squrt)
* approximate starting value found from the highest bit in d0
* Result passed in d0.w

                moveq   #0,D7
                tst.l   D6
                beq.s   sqrt2           ; quit if 0

                move.l  D1,-(SP)

                moveq   #31,D1          ; 31 bits to examine
sqrt1:          btst    D1,D6           ; is this bit set?
                dbne    D1,sqrt1
                lsr.w   #1,D1           ; bit is set; 2^d7/2 approx root
                bset    D1,D7           ; raise 2 to this power
                REPT 4
                move.l  D6,D1
                divu    D7,D1           ; n/squrt
                add.w   D1,D7           ; squrt+N/squrt
                lsr.w   #1,D7           ; /2 gives new trial value
                ENDR
                moveq   #0,D1
                addx.w  D1,D7
                ext.l   D7
                move.l  (SP)+,D1
                rts
sqrt2:          moveq   #0,D7
                rts

                REPT 10
                DC.W -256
                ENDR
sasin:          IBYTES 'SASIN4.DAT'
                REPT 10
                DC.W 256
                ENDR

                ENDPART

                >PART 'Fraction divide'

; Divide two numbers and get an integer and fraction result (the fraction
; is accurate to 1/65535 or a unit, at the cost of one extra divide).
;
frac_divide:
                movem.l D0-D2,-(SP)

                move.l  divtop(PC),D0   ; Top
                move.l  divbottom(PC),D2 ; / Bottom.

                divs    D2,D0           ; Divide - changed for unsigned divide.
                moveq   #0,D1           ; Clear all of D2.
                move.l  D0,D1           ; Copy to fraction register..
                clr.w   D1
                divu    D2,D1           ; And do remainder - doesn't work with
; a DIVS!!!

; Integer as a word in D0.
; Fraction as a word in D1.

; Fast addition bit...
                move.w  D0,div_intr     ; Store integer and fraction.
                move.w  D1,div_fracr

; (examples...)
;                move.w  D0,D3           ; Copy start value.
;                moveq   #0,D2           ; Clear D2 for fraction add.

;                add.w   D1,D2           ; Add fraction and overflow to extend bit.
;                addx.w  D3,D0           ; Add integer and extend bit (if any).

                movem.l (SP)+,D0-D2
                rts

divtop:         DS.L 1
divbottom:      DS.L 1

div_intr:       DS.W 1
div_fracr:      DS.W 1

                ENDPART

                >PART 'Russ poly clipper'

* POLYGON CLIPPER (By Russ Payne, using Sutherland-Hodgman algorithm)
* A5 - Vertex list.
* D0 - Verteces.
** Returns with d0 verteces..
* Writes new coordinates to A5.
* (clipper at label POLYCLIP)

L0000:          DS.W 310
polyclip:       lea     L0000(PC),A1
                cmp.w   clipbottom,D4
                ble.s   L0001
                pea     L001A(PC)
L0001:          tst.w   D3
                bpl.s   L0002
                pea     L000B(PC)
L0002:          cmp.w   clipright,D6
                ble.s   L0003
                pea     L003D(PC)
L0003:          tst.w   D5
                bpl.s   L0004
                pea     L002A(PC)
L0004:          cmp.w   D6,D5
                bvs.s   L0005
                cmp.w   D4,D3
                bvc.s   L0006
L0005:          pea     L0007(PC)
L0006:          rts
L0007:          move.w  D0,D6
                add.w   D6,D6
                subq.w  #1,D6
                move.l  #$3FFF,D3
                move.l  #-$3FFF,D4
                moveq   #0,D1
                movea.l A5,A6
L0008:          move.w  (A6)+,D1
                ext.l   D1
                bpl.s   L0009
                cmp.l   D4,D1
                bge.s   L000A
                move.w  D4,-2(A6)
                dbra    D6,L0008
                rts
L0009:          cmp.l   D3,D1
                ble.s   L000A
                move.w  D3,-2(A6)
L000A:          dbra    D6,L0008
                rts
L000B:          subq.w  #2,D0
                bgt.s   L000C
                rts
L000C:          movea.l A1,A6
                move.l  (A5)+,D1
                move.l  D1,D7
L000D:          move.l  (A5)+,D2
                tst.w   D1
                bmi.s   L0010
                tst.w   D2
                bmi.s   L0011
                move.l  D1,(A1)+
L000E:          move.l  D2,D1
                dbra    D0,L000D
                move.l  D7,D2
                tst.w   D1
                bmi.s   L0012
                tst.w   D2
                bmi.s   L0013
                move.l  D1,(A1)+
L000F:          movea.l A6,A5
                move.l  A1,D0
                sub.l   A6,D0
                asr.w   #2,D0
                lea     124(A6),A1
                rts
L0010:          tst.w   D2
                bmi.s   L000E
                bsr.s   L0014
                bra.s   L000E
L0011:          move.l  D1,(A1)+
                bsr.s   L0017
                bra.s   L000E
L0012:          tst.w   D2
                bmi.s   L000F
                bsr.s   L0014
                bra.s   L000F
L0013:          move.l  D1,(A1)+
                bsr.s   L0017
                bra.s   L000F
L0014:          move.w  D2,D3
                beq.s   L0016
                move.w  D1,D4
                sub.w   D1,D3
                neg.w   D4
                swap    D1
                swap    D2
                move.w  D2,D5
                sub.w   D1,D5
                beq.s   L0015
                muls    D5,D4
                divs    D3,D4
                add.w   D1,D4
                cmp.w   clipright,D4
                sne     D5
                andi.w  #1,D5
                add.w   D5,D4
                swap    D1
                swap    D2
                move.w  D4,(A1)+
                clr.w   (A1)+
                rts
L0015:          move.w  D1,(A1)+
                swap    D1
                swap    D2
                clr.w   (A1)+
L0016:          rts
L0017:          move.w  D1,D4
                beq.s   L0019
                move.w  D2,D3
                sub.w   D1,D3
                neg.w   D4
                swap    D1
                swap    D2
                move.w  D2,D5
                sub.w   D1,D5
                beq.s   L0018
                muls    D5,D4
                divs    D3,D4
                add.w   D1,D4
                tst.w   D4
                sne     D5
                ext.w   D5
                add.w   D5,D4
                swap    D1
                swap    D2
                move.w  D4,(A1)+
                clr.w   (A1)+
                rts
L0018:          move.w  D1,(A1)+
                swap    D1
                swap    D2
                clr.w   (A1)+
L0019:          rts
L001A:          subq.w  #2,D0
                bgt.s   L001B
                rts
L001B:          movea.l A1,A6
                move.l  (A5)+,D1
                move.l  D1,D7
                move.w  clipbottom,D6
L001C:          move.l  (A5)+,D2
                cmp.w   D6,D1
                bgt.s   L001F
                cmp.w   D6,D2
                bgt.s   L0020
                move.l  D1,(A1)+
L001D:          move.l  D2,D1
                dbra    D0,L001C
                move.l  D7,D2
                cmp.w   D6,D1
                bgt.s   L0021
                cmp.w   D6,D2
                bgt.s   L0022
                move.l  D1,(A1)+
L001E:          movea.l A6,A5
                move.l  A1,D0
                sub.l   A6,D0
                asr.w   #2,D0
                lea     124(A6),A1
                rts
L001F:          cmp.w   D6,D2
                bge.s   L001D
                bsr.s   L0023
                bra.s   L001D
L0020:          move.l  D1,(A1)+
                bsr.s   L0026
                bra.s   L001D
L0021:          cmp.w   D6,D2
                bge.s   L001E
                bsr.s   L0023
                bra.s   L001E
L0022:          move.l  D1,(A1)+
                bsr.s   L0026
                bra.s   L001E
L0023:          move.w  D2,D3
                sub.w   D1,D3
                move.w  D1,D4
                sub.w   D6,D4
                move.w  D6,D5
                sub.w   D2,D5
                swap    D1
                swap    D2
                cmp.w   D4,D5
                bgt.s   L0025
                neg.w   D4
                move.w  D2,D5
                sub.w   D1,D5
                beq.s   L0024
                muls    D5,D4
                divs    D3,D4
                add.w   D1,D4
                swap    D1
                swap    D2
                move.w  D4,(A1)+
                move.w  D6,(A1)+
                rts
L0024:          move.w  D2,(A1)+
                move.w  D6,(A1)+
                swap    D1
                swap    D2
                rts
L0025:          move.w  D1,D4
                sub.w   D2,D4
                beq.s   L0024
                neg.w   D3
                muls    D5,D4
                divs    D3,D4
                add.w   D2,D4
                swap    D1
                swap    D2
                move.w  D4,(A1)+
                move.w  D6,(A1)+
                rts
L0026:          cmp.w   D6,D1
                beq.s   L0029
                move.w  D2,D3
                sub.w   D1,D3
                move.w  D6,D4
                sub.w   D1,D4
                move.w  D2,D5
                sub.w   D6,D5
                swap    D1
                swap    D2
                cmp.w   D4,D5
                bgt.s   L0028
                move.w  D2,D5
                sub.w   D1,D5
                beq.s   L0027
                muls    D5,D4
                divs    D3,D4
                add.w   D1,D4
                swap    D1
                swap    D2
                move.w  D4,(A1)+
                move.w  D6,(A1)+
                rts
L0027:          move.w  D2,(A1)+
                move.w  D6,(A1)+
                swap    D1
                swap    D2
                rts
L0028:          move.w  D1,D4
                sub.w   D2,D4
                beq.s   L0027
                neg.w   D5
                neg.w   D3
                muls    D5,D4
                divs    D3,D4
                add.w   D2,D4
                swap    D1
                swap    D2
                move.w  D4,(A1)+
                move.w  D6,(A1)+
L0029:          rts
L002A:          subq.w  #2,D0
                bgt.s   L002B
                rts
L002B:          movea.l A1,A6
                move.l  (A5)+,D1
                move.l  D1,D7
L002C:          move.l  (A5)+,D2
                tst.l   D1
                bmi.s   L002F
                tst.l   D2
                bmi.s   L0030
                move.l  D1,(A1)+
L002D:          move.l  D2,D1
                dbra    D0,L002C
                move.l  D7,D2
                tst.l   D1
                bmi.s   L0031
                tst.l   D2
                bmi.s   L0032
                move.l  D1,(A1)+
L002E:          movea.l A6,A5
                move.l  A1,D0
                sub.l   A6,D0
                asr.w   #2,D0
                lea     124(A6),A1
                rts
L002F:          tst.l   D2
                bmi.s   L002D
                bsr.s   L0033
                bra.s   L002D
L0030:          move.l  D1,(A1)+
                bsr.s   L0038
                bra.s   L002D
L0031:          tst.l   D2
                bmi.s   L002E
                bsr.s   L0033
                bra.s   L002E
L0032:          move.l  D1,(A1)+
                bsr.s   L0038
                bra.s   L002E
L0033:          move.w  D2,D3
                sub.w   D1,D3
                beq.s   L0035
                swap    D2
                move.w  D2,D4
                beq.s   L0037
                swap    D1
                move.w  D1,D5
                neg.w   D5
                cmp.w   D2,D5
                bgt.s   L0034
                neg.w   D3
                neg.w   D4
                muls    D4,D3
                move.w  D1,D4
                sub.w   D2,D4
                divs    D4,D3
                swap    D1
                swap    D2
                add.w   D2,D3
                clr.w   (A1)+
                move.w  D3,(A1)+
                rts
L0034:          muls    D5,D3
                move.w  D2,D4
                sub.w   D1,D4
                divs    D4,D3
                swap    D1
                swap    D2
                add.w   D1,D3
                clr.w   (A1)+
                move.w  D3,(A1)+
                rts
L0035:          swap    D2
                tst.w   D2
                beq.s   L0036
                clr.w   (A1)+
                move.w  D1,(A1)+
L0036:          swap    D2
                rts
L0037:          swap    D2
                rts
L0038:          move.w  D2,D3
                sub.w   D1,D3
                beq.s   L003A
                swap    D1
                move.w  D1,D4
                beq.s   L003C
                swap    D2
                move.w  D2,D5
                neg.w   D5
                cmp.w   D1,D5
                bgt.s   L0039
                neg.w   D4
                muls    D4,D3
                move.w  D2,D4
                sub.w   D1,D4
                divs    D4,D3
                swap    D1
                swap    D2
                add.w   D1,D3
                clr.w   (A1)+
                move.w  D3,(A1)+
                rts
L0039:          neg.w   D3
                muls    D5,D3
                move.w  D1,D4
                sub.w   D2,D4
                divs    D4,D3
                swap    D1
                swap    D2
                add.w   D2,D3
                clr.w   (A1)+
                move.w  D3,(A1)+
                rts
L003A:          swap    D1
                tst.w   D1
                beq.s   L003B
                clr.w   (A1)+
                move.w  D2,(A1)+
L003B:          swap    D1
                rts
L003C:          swap    D1
                rts
L003D:          subq.w  #2,D0
                bgt.s   L003E
                rts
L003E:          movea.l A1,A6
                move.l  (A5)+,D1
                move.l  D1,D7
                movea.w clipright,A2
                moveq   #-1,D6
                move.w  A2,D6
                swap    D6
L003F:          move.l  (A5)+,D2
                cmp.l   D6,D1
                bgt.s   L0042
                cmp.l   D6,D2
                bgt.s   L0043
                move.l  D1,(A1)+
L0040:          move.l  D2,D1
                dbra    D0,L003F
                move.l  D7,D2
                cmp.l   D6,D1
                bgt.s   L0044
                cmp.l   D6,D2
                bgt.s   L0045
                move.l  D1,(A1)+
L0041:          movea.l A6,A5
                move.l  A1,D0
                sub.l   A6,D0
                asr.w   #2,D0
                lea     124(A6),A1
                rts
L0042:          cmp.l   D6,D2
                bgt.s   L0040
                bsr.s   L0046
                bra.s   L0040
L0043:          move.l  D1,(A1)+
                bsr.s   L004B
                bra.s   L0040
L0044:          cmp.l   D6,D2
                bgt.s   L0041
                bsr.s   L0046
                bra.s   L0041
L0045:          move.l  D1,(A1)+
                bsr.s   L004B
                bra.s   L0041
L0046:          move.w  D2,D3
                sub.w   D1,D3
                beq.s   L0049
                swap    D2
                swap    D1
                move.w  A2,D5
                sub.w   D2,D5
                beq.s   L0048
                move.w  D1,D4
                sub.w   A2,D4
                cmp.w   D4,D5
                bgt.s   L0047
                neg.w   D4
                muls    D4,D3
                move.w  D2,D4
                sub.w   D1,D4
                divs    D4,D3
                swap    D1
                swap    D2
                add.w   D1,D3
                move.w  A2,(A1)+
                move.w  D3,(A1)+
                rts
L0047:          neg.w   D3
                muls    D5,D3
                move.w  D1,D4
                sub.w   D2,D4
                divs    D4,D3
                swap    D1
                swap    D2
                add.w   D2,D3
                move.w  A2,(A1)+
                move.w  D3,(A1)+
                rts
L0048:          swap    D1
                swap    D2
                rts
L0049:          swap    D2
                cmp.w   A2,D2
                beq.s   L004A
                move.w  A2,(A1)+
                move.w  D1,(A1)+
L004A:          swap    D2
                rts
L004B:          move.w  D2,D3
                sub.w   D1,D3
                beq.s   L004E
                swap    D2
                swap    D1
                move.w  A2,D4
                sub.w   D1,D4
                beq.s   L004D
                move.w  D2,D5
                sub.w   A2,D5
                cmp.w   D4,D5
                bgt.s   L004C
                muls    D4,D3
                move.w  D2,D4
                sub.w   D1,D4
                divs    D4,D3
                swap    D1
                swap    D2
                add.w   D1,D3
                move.w  A2,(A1)+
                move.w  D3,(A1)+
                rts
L004C:          neg.w   D3
                neg.w   D5
                muls    D5,D3
                move.w  D1,D4
                sub.w   D2,D4
                divs    D4,D3
                swap    D1
                swap    D2
                add.w   D2,D3
                move.w  A2,(A1)+
                move.w  D3,(A1)+
                rts
L004D:          swap    D1
                swap    D2
                rts
L004E:          swap    D1
                cmp.w   A2,D1
                beq.s   L004F
                move.w  A2,(A1)+
                move.w  D2,(A1)+
L004F:          swap    D1
                rts

                ENDPART


                >PART 'number conversion routine'

**************** Number conversion routine.

conv:           movem.l D0-D5/A0-A1,-(SP)
                moveq   #4,D5
                move.l  number(PC),D0
                rol.l   D5,D0
                moveq   #8-1,D2
loop:           move.b  D0,D1
                and.b   #%1111,D1
                cmpi.b  #10,D1
                blt.s   lten
                sub.b   #10,D1
                add.b   #'A',D1
                bra.s   putit
lten:           add.b   #'0',D1
putit:          bsr.s   shoveit
                addq.b  #1,txpos
                rol.l   D5,D0
                dbra    D2,loop
                movem.l (SP)+,D0-D5/A0-A1
                rts

shoveit:        moveq   #0,D3
                moveq   #0,D4
                move.b  txpos(PC),D3
                move.b  typos(PC),D4
                lea     yoffs,A1
                add.w   D4,D4
                movea.l scrn2,A0
                adda.w  0(A1,D4.w),A0
                lea     xtab(PC),A1
                move.b  0(A1,D3.w),D3
                adda.w  D3,A0
                lea     font(PC),A1
                moveq   #0,D3
                move.b  D1,D3
                sub.b   #32,D3
                lsl.w   #3,D3
                adda.w  D3,A1
                move.b  (A1)+,(A0)
                move.b  (A1)+,160(A0)
                move.b  (A1)+,320(A0)
                move.b  (A1)+,480(A0)
                move.b  (A1)+,640(A0)
                move.b  (A1)+,800(A0)
                move.b  (A1)+,960(A0)
                move.b  (A1),1120(A0)
                rts


number:         DS.L 1

font:           DC.L $00,$00,$10101010,$10001000,$240000,$00,$24247E24,$7E242400,$107C907C,$127C1000,$440810,$20440000
                DC.L $18241828,$45827D00,$100000,$00,$04081010,$10080400,$20100808,$08102000,$4428FE,$28440000,$10107C,$10100000
                DC.L $00,$1020,$7C,$00,$00,$1000,$020408,$10204000,$7C868A92,$A2C27C00,$10301010,$10107C00
                DC.L $7C82027C,$8080FE00,$7C82021C,$02827C00,$0C142444,$84FE0400,$FC8080FC,$02827C00,$7C8280FC,$82827C00,$FE820408,$10101000
                DC.L $7C82827C,$82827C00,$7C82827E,$02027C00,$1000,$10000000,$1000,$10200000,$08102040,$20100800,$7C00,$7C000000
                DC.L $20100804,$08102000,$7C82020C,$10001000,$7C829EA2,$9C807E00,$7C8282FE,$82828200,$FC8282FC,$8282FC00,$7C828080,$80827C00
                DC.L $FC828282,$8282FC00,$FE8080F8,$8080FE00,$FE8080F8,$80808000,$7E80808E,$82827C00,$828282FE,$82828200,$7C101010,$10107C00
                DC.L $02020202,$02827C00,$828488F0,$88848200,$80808080,$8080FE00,$82C6AA92,$82828200,$82C2A292,$8A868200,$7C828282,$82827C00
                DC.L $FC8282FC,$80808000,$7C828282,$8A847A00,$FC8282FC,$88848200,$7C82807C,$02827C00,$FE101010,$10101000,$82828282,$82827C00
                DC.L $82828282,$44281000,$82828292,$AAC68200,$82442810,$28448200,$82824428,$10101000,$FE040810,$2040FE00,$1C101010,$10101C00
                DC.L $80402010,$08040200,$38080808,$08083800,$10284482,$00,$00,$FE00,$100000,$00,$7804,$7C847800
                DC.L $8080F884,$8484F800,$7880,$80807800,$04047C84,$84847C00,$7884,$F8807800,$0C103810,$10101000,$7884,$847C0478
                DC.L $8080F884,$84848400,$10003010,$10103800,$08000808,$08080830,$808890E0,$90888400,$30101010,$10103800,$EC92,$92828200
                DC.L $F884,$84848400,$7884,$84847800,$F884,$8484F880,$7C84,$84847C04,$F884,$80808000,$7880,$78047800
                DC.L $10107C10,$10100C00,$8484,$84847C00,$8282,$44281000,$8282,$82542800,$8448,$30488400,$8484,$847C0478
                DC.L $7C08,$10207C00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

xtab:           DC.B 0,1,8,9,16,17,24,25,32,33,40,41,48,49,56,57,64,65,72,73
                DC.B 80,81,88,89,96,97,104,105,112,113,120,121,128,129,136,137
                DC.B 144,145,152,153

txpos:          DS.B 1
typos:          DS.B 1

*********************

                ENDPART

                >PART 'subroutines'

;
; Get frame compensated value (max is 255) and max delay is 10 frames (!!).
; Input in D0 - Output in D0.  Smashed A0 and D1.
;
getframe:       tst.w   D0
                bpl.s   d0isplus
                neg.w   D0
                add.w   D0,D0
                move.w  0(A0,D0.w),D0
                neg.w   D0
                rts
d0isplus:       add.w   D0,D0
                move.w  0(A0,D0.w),D0
                rts


                ENDPART

                >PART 'Frame compensate table'

whichtab:       DC.L frametab
frametab:
                DC.L 1,131075,262149,393223,524297,655371,786445,917519
                DC.L 1048593,1179667,1310741,1441815,1572889,1703963,1835037,1966111
                DC.L 2097185,2228259,2359333,2490407,2621481,2752555,2883629,3014703
                DC.L 3145777,3276851,3407925,3538999,3670073,3801147,3932221,4063295
                DC.L 4194369,4325443,4456517,4587591,4718665,4849739,4980813,5111887
                DC.L 5242961,5374035,5505109,5636183,5767257,5898331,6029405,6160479
                DC.L 6291553,6422627,6553701,6684775,6815849,6946923,7077997,7209071
                DC.L 7340145,7471219,7602293,7733367,7864441,7995515,8126589,8257663
                DC.L 8388737,8519811,8650885,8781959,8913033,9044107,9175181,9306255
                DC.L 9437329,9568403,9699477,9830551,9961625,10092699,10223773,10354847
                DC.L 10485921,10616995,10748069,10879143,11010217,11141291,11272365,11403439
                DC.L 11534513,11665587,11796661,11927735,12058809,12189883,12320957,12452031
                DC.L 12583105,12714179,12845253,12976327,13107401,13238475,13369549,13500623
                DC.L 13631697,13762771,13893845,14024919,14155993,14287067,14418141,14549215
                DC.L 14680289,14811363,14942437,15073511,15204585,15335659,15466733,15597807
                DC.L 15728881,15859955,15991029,16122103,16253177,16384251,16515325,16646399
                DC.L 2,262150,524298,786446,1048594,1310742,1572890,1835038
                DC.L 2097186,2359334,2621482,2883630,3145778,3407926,3670074,3932222
                DC.L 4194370,4456518,4718666,4980814,5242962,5505110,5767258,6029406
                DC.L 6291554,6553702,6815850,7077998,7340146,7602294,7864442,8126590
                DC.L 8388738,8650886,8913034,9175182,9437330,9699478,9961626,10223774
                DC.L 10485922,10748070,11010218,11272366,11534514,11796662,12058810,12320958
                DC.L 12583106,12845254,13107402,13369550,13631698,13893846,14155994,14418142
                DC.L 14680290,14942438,15204586,15466734,15728882,15991030,16253178,16515326
                DC.L 16777474,17039622,17301770,17563918,17826066,18088214,18350362,18612510
                DC.L 18874658,19136806,19398954,19661102,19923250,20185398,20447546,20709694
                DC.L 20971842,21233990,21496138,21758286,22020434,22282582,22544730,22806878
                DC.L 23069026,23331174,23593322,23855470,24117618,24379766,24641914,24904062
                DC.L 25166210,25428358,25690506,25952654,26214802,26476950,26739098,27001246
                DC.L 27263394,27525542,27787690,28049838,28311986,28574134,28836282,29098430
                DC.L 29360578,29622726,29884874,30147022,30409170,30671318,30933466,31195614
                DC.L 31457762,31719910,31982058,32244206,32506354,32768502,33030650,33292798
                DC.L 3,393225,786447,1179669,1572891,1966113,2359335,2752557
                DC.L 3145779,3539001,3932223,4325445,4718667,5111889,5505111,5898333
                DC.L 6291555,6684777,7077999,7471221,7864443,8257665,8650887,9044109
                DC.L 9437331,9830553,10223775,10616997,11010219,11403441,11796663,12189885
                DC.L 12583107,12976329,13369551,13762773,14155995,14549217,14942439,15335661
                DC.L 15728883,16122105,16515327,16908549,17301771,17694993,18088215,18481437
                DC.L 18874659,19267881,19661103,20054325,20447547,20840769,21233991,21627213
                DC.L 22020435,22413657,22806879,23200101,23593323,23986545,24379767,24772989
                DC.L 25166211,25559433,25952655,26345877,26739099,27132321,27525543,27918765
                DC.L 28311987,28705209,29098431,29491653,29884875,30278097,30671319,31064541
                DC.L 31457763,31850985,32244207,32637429,33030651,33423873,33817095,34210317
                DC.L 34603539,34996761,35389983,35783205,36176427,36569649,36962871,37356093
                DC.L 37749315,38142537,38535759,38928981,39322203,39715425,40108647,40501869
                DC.L 40895091,41288313,41681535,42074757,42467979,42861201,43254423,43647645
                DC.L 44040867,44434089,44827311,45220533,45613755,46006977,46400199,46793421
                DC.L 47186643,47579865,47973087,48366309,48759531,49152753,49545975,49939197
                DC.L 4,524300,1048596,1572892,2097188,2621484,3145780,3670076
                DC.L 4194372,4718668,5242964,5767260,6291556,6815852,7340148,7864444
                DC.L 8388740,8913036,9437332,9961628,10485924,11010220,11534516,12058812
                DC.L 12583108,13107404,13631700,14155996,14680292,15204588,15728884,16253180
                DC.L 16777476,17301772,17826068,18350364,18874660,19398956,19923252,20447548
                DC.L 20971844,21496140,22020436,22544732,23069028,23593324,24117620,24641916
                DC.L 25166212,25690508,26214804,26739100,27263396,27787692,28311988,28836284
                DC.L 29360580,29884876,30409172,30933468,31457764,31982060,32506356,33030652
                DC.L 33554948,34079244,34603540,35127836,35652132,36176428,36700724,37225020
                DC.L 37749316,38273612,38797908,39322204,39846500,40370796,40895092,41419388
                DC.L 41943684,42467980,42992276,43516572,44040868,44565164,45089460,45613756
                DC.L 46138052,46662348,47186644,47710940,48235236,48759532,49283828,49808124
                DC.L 50332420,50856716,51381012,51905308,52429604,52953900,53478196,54002492
                DC.L 54526788,55051084,55575380,56099676,56623972,57148268,57672564,58196860
                DC.L 58721156,59245452,59769748,60294044,60818340,61342636,61866932,62391228
                DC.L 62915524,63439820,63964116,64488412,65012708,65537004,66061300,66585596
                DC.L 5,655375,1310745,1966115,2621485,3276855,3932225,4587595
                DC.L 5242965,5898335,6553705,7209075,7864445,8519815,9175185,9830555
                DC.L 10485925,11141295,11796665,12452035,13107405,13762775,14418145,15073515
                DC.L 15728885,16384255,17039625,17694995,18350365,19005735,19661105,20316475
                DC.L 20971845,21627215,22282585,22937955,23593325,24248695,24904065,25559435
                DC.L 26214805,26870175,27525545,28180915,28836285,29491655,30147025,30802395
                DC.L 31457765,32113135,32768505,33423875,34079245,34734615,35389985,36045355
                DC.L 36700725,37356095,38011465,38666835,39322205,39977575,40632945,41288315
                DC.L 41943685,42599055,43254425,43909795,44565165,45220535,45875905,46531275
                DC.L 47186645,47842015,48497385,49152755,49808125,50463495,51118865,51774235
                DC.L 52429605,53084975,53740345,54395715,55051085,55706455,56361825,57017195
                DC.L 57672565,58327935,58983305,59638675,60294045,60949415,61604785,62260155
                DC.L 62915525,63570895,64226265,64881635,65537005,66192375,66847745,67503115
                DC.L 68158485,68813855,69469225,70124595,70779965,71435335,72090705,72746075
                DC.L 73401445,74056815,74712185,75367555,76022925,76678295,77333665,77989035
                DC.L 78644405,79299775,79955145,80610515,81265885,81921255,82576625,83231995
                DC.L 6,786450,1572894,2359338,3145782,3932226,4718670,5505114
                DC.L 6291558,7078002,7864446,8650890,9437334,10223778,11010222,11796666
                DC.L 12583110,13369554,14155998,14942442,15728886,16515330,17301774,18088218
                DC.L 18874662,19661106,20447550,21233994,22020438,22806882,23593326,24379770
                DC.L 25166214,25952658,26739102,27525546,28311990,29098434,29884878,30671322
                DC.L 31457766,32244210,33030654,33817098,34603542,35389986,36176430,36962874
                DC.L 37749318,38535762,39322206,40108650,40895094,41681538,42467982,43254426
                DC.L 44040870,44827314,45613758,46400202,47186646,47973090,48759534,49545978
                DC.L 50332422,51118866,51905310,52691754,53478198,54264642,55051086,55837530
                DC.L 56623974,57410418,58196862,58983306,59769750,60556194,61342638,62129082
                DC.L 62915526,63701970,64488414,65274858,66061302,66847746,67634190,68420634
                DC.L 69207078,69993522,70779966,71566410,72352854,73139298,73925742,74712186
                DC.L 75498630,76285074,77071518,77857962,78644406,79430850,80217294,81003738
                DC.L 81790182,82576626,83363070,84149514,84935958,85722402,86508846,87295290
                DC.L 88081734,88868178,89654622,90441066,91227510,92013954,92800398,93586842
                DC.L 94373286,95159730,95946174,96732618,97519062,98305506,99091950,99878394
                DC.L 7,917525,1835043,2752561,3670079,4587597,5505115,6422633
                DC.L 7340151,8257669,9175187,10092705,11010223,11927741,12845259,13762777
                DC.L 14680295,15597813,16515331,17432849,18350367,19267885,20185403,21102921
                DC.L 22020439,22937957,23855475,24772993,25690511,26608029,27525547,28443065
                DC.L 29360583,30278101,31195619,32113137,33030655,33948173,34865691,35783209
                DC.L 36700727,37618245,38535763,39453281,40370799,41288317,42205835,43123353
                DC.L 44040871,44958389,45875907,46793425,47710943,48628461,49545979,50463497
                DC.L 51381015,52298533,53216051,54133569,55051087,55968605,56886123,57803641
                DC.L 58721159,59638677,60556195,61473713,62391231,63308749,64226267,65143785
                DC.L 66061303,66978821,67896339,68813857,69731375,70648893,71566411,72483929
                DC.L 73401447,74318965,75236483,76154001,77071519,77989037,78906555,79824073
                DC.L 80741591,81659109,82576627,83494145,84411663,85329181,86246699,87164217
                DC.L 88081735,88999253,89916771,90834289,91751807,92669325,93586843,94504361
                DC.L 95421879,96339397,97256915,98174433,99091951,100009469,100926987,101844505
                DC.L 102762023,103679541,104597059,105514577,106432095,107349613,108267131,109184649
                DC.L 110102167,111019685,111937203,112854721,113772239,114689757,115607275,116524793
                DC.L 8,1048600,2097192,3145784,4194376,5242968,6291560,7340152
                DC.L 8388744,9437336,10485928,11534520,12583112,13631704,14680296,15728888
                DC.L 16777480,17826072,18874664,19923256,20971848,22020440,23069032,24117624
                DC.L 25166216,26214808,27263400,28311992,29360584,30409176,31457768,32506360
                DC.L 33554952,34603544,35652136,36700728,37749320,38797912,39846504,40895096
                DC.L 41943688,42992280,44040872,45089464,46138056,47186648,48235240,49283832
                DC.L 50332424,51381016,52429608,53478200,54526792,55575384,56623976,57672568
                DC.L 58721160,59769752,60818344,61866936,62915528,63964120,65012712,66061304
                DC.L 67109896,68158488,69207080,70255672,71304264,72352856,73401448,74450040
                DC.L 75498632,76547224,77595816,78644408,79693000,80741592,81790184,82838776
                DC.L 83887368,84935960,85984552,87033144,88081736,89130328,90178920,91227512
                DC.L 92276104,93324696,94373288,95421880,96470472,97519064,98567656,99616248
                DC.L 100664840,101713432,102762024,103810616,104859208,105907800,106956392,108004984
                DC.L 109053576,110102168,111150760,112199352,113247944,114296536,115345128,116393720
                DC.L 117442312,118490904,119539496,120588088,121636680,122685272,123733864,124782456
                DC.L 125831048,126879640,127928232,128976824,130025416,131074008,132122600,133171192
                DC.L 9,1179675,2359341,3539007,4718673,5898339,7078005,8257671
                DC.L 9437337,10617003,11796669,12976335,14156001,15335667,16515333,17694999
                DC.L 18874665,20054331,21233997,22413663,23593329,24772995,25952661,27132327
                DC.L 28311993,29491659,30671325,31850991,33030657,34210323,35389989,36569655
                DC.L 37749321,38928987,40108653,41288319,42467985,43647651,44827317,46006983
                DC.L 47186649,48366315,49545981,50725647,51905313,53084979,54264645,55444311
                DC.L 56623977,57803643,58983309,60162975,61342641,62522307,63701973,64881639
                DC.L 66061305,67240971,68420637,69600303,70779969,71959635,73139301,74318967
                DC.L 75498633,76678299,77857965,79037631,80217297,81396963,82576629,83756295
                DC.L 84935961,86115627,87295293,88474959,89654625,90834291,92013957,93193623
                DC.L 94373289,95552955,96732621,97912287,99091953,100271619,101451285,102630951
                DC.L 103810617,104990283,106169949,107349615,108529281,109708947,110888613,112068279
                DC.L 113247945,114427611,115607277,116786943,117966609,119146275,120325941,121505607
                DC.L 122685273,123864939,125044605,126224271,127403937,128583603,129763269,130942935
                DC.L 132122601,133302267,134481933,135661599,136841265,138020931,139200597,140380263
                DC.L 141559929,142739595,143919261,145098927,146278593,147458259,148637925,149817591
                DC.L 10,1310750,2621490,3932230,5242970,6553710,7864450,9175190
                DC.L 10485930,11796670,13107410,14418150,15728890,17039630,18350370,19661110
                DC.L 20971850,22282590,23593330,24904070,26214810,27525550,28836290,30147030
                DC.L 31457770,32768510,34079250,35389990,36700730,38011470,39322210,40632950
                DC.L 41943690,43254430,44565170,45875910,47186650,48497390,49808130,51118870
                DC.L 52429610,53740350,55051090,56361830,57672570,58983310,60294050,61604790
                DC.L 62915530,64226270,65537010,66847750,68158490,69469230,70779970,72090710
                DC.L 73401450,74712190,76022930,77333670,78644410,79955150,81265890,82576630
                DC.L 83887370,85198110,86508850,87819590,89130330,90441070,91751810,93062550
                DC.L 94373290,95684030,96994770,98305510,99616250,100926990,102237730,103548470
                DC.L 104859210,106169950,107480690,108791430,110102170,111412910,112723650,114034390
                DC.L 115345130,116655870,117966610,119277350,120588090,121898830,123209570,124520310
                DC.L 125831050,127141790,128452530,129763270,131074010,132384750,133695490,135006230
                DC.L 136316970,137627710,138938450,140249190,141559930,142870670,144181410,145492150
                DC.L 146802890,148113630,149424370,150735110,152045850,153356590,154667330,155978070
                DC.L 157288810,158599550,159910290,161221030,162531770,163842510,165153250,166463990

                ENDPART

;------------------------------------- **  * *





                EVEN

;station:        IBYTES 'STATION1.PIC'
;
;                EVEN

screens:        DS.L 1

                END
