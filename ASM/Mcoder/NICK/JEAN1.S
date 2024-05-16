   Hi there, Jean-Charles!
  Many thanx for your letter and for answering me so quickly. Your game 
will probably be very good, technically, but if you want to get some 
gameplay, I think you will have to make some changes. First of all, why 
don't you use a hardwarescroller? We have it working on all shifters and 
MMUs (It is included in 3 Thalion games at the moment). It will save 5 
screens, and you can stop the scroller). If you do, you can perhaps only 
have preshifted sprites, but otherwise it is simply not enough with 80 kb. 
Perhaps you should make the main-ship real-shifting?
  I don't think that your mini-debugger is as good as MON-ST, which I 
prefer to use, but I suppose that is a problem you will have to live with 
if you want your games to use word-addressing.
  When you finish the game, I'm sure that Thalion is interrested in 
publishing it. Could you send a preview?
 
 Now, let's talk about the new techniques:
 
 I'm afraid that I already use 2 bitplane-shift in my sprite rout, as well 
as a7. I coded my first not preshifted sprite-rout about one month ago, 
just before I left to Germany. I tried all the possible techniques I could 
come up with, and 2-plane-shift was the fastest.

 I hadn't though of the ADD instead of OR, however, so I speeded it up 
almost a scanline when I got your letter. Thanks! It now takes 40.2 
scanlines for a 32*32 sprite (It saves background). When I got this value, 
there was some time-consuming color-changes and other bullshit in the 
beginning, though. How fast is yours?
 
 The digisound-routs you wrote are a bit faster than the usual movep- and 
movem.l-techniques, but the quality of the sound is much lower. Even I can 
easily hear a difference, and Jochen (MAD MAX) refuses to use any of the 
sound-destroying techniques that I'd like to use. The best sound is 
achieved with movem.l, since the time from the first written byte till the 
last is very short, but it is a bit slower than movep.
 BEQ-end-of-sample-trigger is standard in Jochen's digi-synth routs, but I 
prefer only to check end of sample in the VBL. I used bmi-triggered 
rasters already in the Swedish New Year Demo.
 I've worked on CBM Pet (Basic) Apple II (basic and some 6502), C64 
(plaing games), IBM PC (lots of Turbo Pascal and 8088 as well as 80286 
a.s.o.), Atari ST (68000). I hate programs without subroutines. You gain a 
few cycles, but you will loose control when the program starts to get big, 
and it's also totally impossible for another programmer to take over if 
that's neccesary.
 
 I dare say that your greatest shortcoming isn't that you dislike 
subroutines, but that you don't know how to count cycles on the 68000 
(Whoops, will you have to recode the code-generator?). Instructions that 
take an amount of cycles that is not dividable by 4 loose 2 cycles, so 
that all commands actually take 4-multiple of cycles. EXG, which is said 
to take 6 cycles takes 8. DBF takes 16, not 14. There is a case when you 
don't loose cycles, though. If you have an instruction which takes 6 
cycles directly followed by a branch-instruction (i.e DBF) that takes 14, 
the result will be 20 cycles!
 Now, let's end an argument: My vertical-raster-routine took 512 cycles, 
and you said that there were 313 lines (I knew it from before). 
512*313=160256!!!!  Just try it by coding a program with color-tilt, 
160256/4 NOPs and a branch (of course you have to decrease the number of 
NOPs, since the branch and color-tilt take some time). You will get a 
totally stable line on the screen.
 
 DCB.W 117,$4e71 in German 2.08 Devpac. DCB.W $4e71,117 in English 2.07. 
Strangely enough, this was changes in the newest version.
 
I might not be very good at English, but I think that tracks are: 
1) things that detectives in films can look at and see what kind of car 
made them, pixels that are not wiped when an interrupt that changes the 
wrong address-registers occurs in the middle of a Star-wipe-rout.
2) When sprites follow each other, they are tracking. (?)

 Movem the whole screen will take more than half of the CPU-time, it will 
it fact take 85%. I used movem.l (an)+, + movem.l ,-(an) for the mountains 
in the 3D-DOC-Demo (at least in the beginning, when the balls used all the 
screen). I should have used a code-generator, but I was hoping that A.D. 
would make more movem-friendly mountains.
 
 Tell Andy Pennel to correct at least these very important bugs: That the 
assembler forgets label-names in the middle of a program and that it 
simply makes assemble-errors in some rare conditions. It can usually be 
fixed by inserting a NOP anywhere in the program (strange!).
 
 I have also made a code-generator, and I am going to use it for all the 
endmonsters in my game. It takes too much memory for sprites in the game. 
I have made a combination of preshifted sprites and code-generated 
sprites, however, which is faster that preshifted sprites and only takes 
about 10% more memory.
 
 If possible, please send the copier when it's finished. It's totally 
impossible, though, to read Amiga-disks (I think).

 My game will scroll both horizontally and vertically. The vertical 
scroller can be in any speed and the horizontal scroller can scroll left, 
right and stop (which means that I have to update the sprites on the same 
screen as I'm looking at. I sort the sprites after y-coordinate, wait for 
the beam and where possible, wipe them in the opposite order. It works!). 
I have already coded the enviroment (hardware-scroller and sprites-handler 
and sprite routines). Two guys are working on a concept for the game at 
the moment, so I'm right now trying to finish the end-monsters for a game 
called "The seven gates of jambala".
 
 Now a few words about preshifted sprite-routines:
 My routine is faster than your if yours looks like this:
movem.l (a0)+,d0-d7/a2
and.l d0,(a1)
or.l d1,(a1)+
and.l d0,(a1)
or.l d2,(a1)+
and.l d3,(a1)
or.l d4,(a1)+
and.l d3,(a1)
or.l d5,(a1)+
and.l d6,(a1)
or.l d7,(a1)+
and.l d6,(a1)
move.l a2,d7   )
or.l d7,(a1)+  )  or   add.l a2,(a1)+  ?

My routine:
movem.l (a0),d0-d5
move.l (a1)+,d6
and.l d6,d0
and.l d6,d1
or.l (a1)+,d0
or.l (a1)+,d1
..................
movem.l d0-d5,(a0)

If you don't believe me, you can try it in my cycle-counter program (you 
can find it on the disk). I always use a cycle-counter-program when I code 
new routines nowadays. It's very handy, and it's much easier than looking 
in the book.
 
 You wrote in the last letter that you think German software-houses 
produce unambitios games. I hardly think that's the case with this 
software-house. Both graphixxmen and programmers are of very high quality. 
Erik Simon (ES of The Exceptions) is the best in-house graphist. Michael 
Bittner (TNT-crew) is working on a vertically (both up, down and stop) 
scrolling commando-like shoot'em up and will later continue with his 3D 
game. Chris Jungen (TNT) has really fast vector-graphixx (everybody says 
that they have the fastest vector-graphixx, but this one is really fast. 
It is much faster than Hard Drivin and Jez San agreed that it actually 
looked faster than theirs (on the PCS)). Marc R. (Gigabyte Crew) makes a 
karate game (featuring hardware-scroller among other things). Gunter Bitz 
(6719 of The Exceptions) codes "Jambala" - scrolling giana sisters with 
much better graphixx). Udo F (ME of TEX) codes Dragonflight (a gigantic 
role-playing game). Jochen H. (MAD MAX of TEX) is in-house musician! The 
first game that will be released is Warp (16-way-scrolling shoot'em up), 
by Michael B.
 
 One final warning: Don't make a constant frame-rate when you make a 
3D-game. It's impossible to keep the number of polygons on the screen 
constant, so you will only loose speed. Use 3 screens instead and switch 
as soon as one is finished. Come to think of Vector graphixx, we've made a 
quite funny routine for not filled Vector graphixx - 150Kb of bsets. Over 
10000 pixels per second. You can find it in the loader for the copy-party 
demo as soon as it is finished (Andreas is still trying to put it all 
together).

You have almost all our ST-products. There are three intros you haven't 
seen, but two of them are quite trashy (they were made right after the 
Junk Demo - december 87). The third one was coded by AN Cool and it looks 
really impressive. It was first used on PowerDome (or Drome or whatever). 
I don't have it here, though, but I'll send it to you in the next letter.

 About AN Cool: I think I am better than him at coding, but I think he is 
very good too. I was just very upset when I wrote the last letter, since 
you were the first one who complained about our optimizing techniques (you 
were certainly not the first one who complained about our demos not 
working and being lousy), so I had to blame it on someone (?). The weird 
dreams intro (which is quite lousy (and it only works on not too old STs 
every second thursday if your ear is stuck in a microwave oven)) was coded 
using the technique when each member write one routine (I had to code the 
scroller (pathically slow, but we had no time-problem), the star-routine, 
the union-sprites (not optimized) and put it all together). Anyway, 
Andreas and I didn't dislike AN Cool, just his hysterically pathic try to 
tell a joke.
 

I also included a compiled preview of the Sodan and Magician 42 
conversion. You MUSTN'T spread it!!!!!!!!!!!!! (By the way, it uses the 
old hardware scroller and I could have used the vector register for 
changing mpf-vectors, but it would have meant a lot of other problems). 
Somewhere on the disk there's also a "TCBBALL"-preview. Try to make an own 
version and see how many balls you can make before you look in the code. 
We have 120 at the moment, but I know one thing that we might gain 
something like 3-4 balls on. DON'T USE 60 HZ! This program was started by 
AN Cool, and then I took over and speeded things up (he didn't even have 
preprogrammed sprites when I continued), so there are a few "eor.w #1" and 
stuff like that in the not speed-critical parts.  Finally: don't spread 
it!  You are the only person outside TCB who has these previews.
Bye, bye, keep on hackin' and hope to hear from you soon..
Niclas Thisell
P.S.Oh, I almost forgot! The pixel-scroller works like this: You make an 
ordinary hardwarscroller (we can now make it in 5 scanlines!) with the first 
4 shifts in 4 screens + 1 buffer-screen. Then you use a 70Hz-nop-50Hz 
technique that should work on all computers to move the whole screen -4,0,4 
or 8 pixels to the right. The problems are: You have to compensate 
bitplane-errors with the HW-scroller, The incredibly timeconsuming 
edge-shifter (the whole screen jump left and right, so it has to mask both 
left and right edge all the time).  This is top secret! Don't spred it!!!!!
P.P.S.
Final P.S.: Tip for making a totally uncrackable protection - Synclock in 
the beginning and exor the code with the low-byte of the 
video-display-register (on trace-interrupt). The crackers will then have to 
count cycles of each command, know where 8209.w stop counting, make an 
emulator and so on. Few crackers can count cycles. Even less know about the 
lost 2 cycles when 6-cycle commands are executed. I dare say that noone will 
ever crack it.

 
