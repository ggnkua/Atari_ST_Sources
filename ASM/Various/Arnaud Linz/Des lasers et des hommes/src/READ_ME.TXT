	 D E S   __    ______  _____ ______ ______    _____ 
	       	/ /   / __  | /  __// ____// ___ |   /  __/
	       / /   / /_/ /  | |  / ___/ / /__| /   | |   
	      / /__ / __  /___| | / /___ / ____ | ___| |
	     /____//_/ /_//_____//_____//_/   |_|/_____/     E T    D E S
	     	 	 __  __ ____   _   __ _   __ ______  _____
	     		/ /_/ // __ \ / \_/ // |_/ // ____/ /  __/
	     	       / __  // / / //     //     // ___/   | |
	     	      / / / // /_/ // /\/ // /\/ // /___ ___| |
	     	     /_/ /_/ \____//_/ /_//_/ /_//_____//_____/

ÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒ
Ò		     |ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ|                      Ò
Ò                    |  ¯  DES LASERS ET DES HOMMES   ® |                      Ò
Ò		     |	     (Of Lasers and Men)	|                      Ò
Ò		     |__________________________________|                      Ò
Ò									       Ò
Ò               ž-graphisms by Yann Leroux, Christophe Mallard	 	       Ò
Ò			         & Arnaud Linz.                                Ò
Ò                                                                              Ò
Ò 	        All code, levels and conception by Arnaud Linz.                Ò
Ò                                                                              Ò
Ò                                                                              Ò
Ò          ½ 1993,1994 Arnaud LINZ, assembled with Assemble (Brainstorm¿)      Ò
Ò	   				         & Devpac DSP (Hisoft¿)	       Ò
Ò                                                                              Ò
Ò		      Data Compression : Cyrille Dupuydauby	               Ò
Ò                                                                              Ò
Ò 		    v1.0 released 1994 February,the 18th.      		       Ò
ÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒ



PRELIMINARY NOTE : This game is A SHAREWARE.
¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹                  ¹¹¹¹¹¹¹¹¹
The unregistered version has only two levels. You should send a donation to its 
author if you intend to use it. 

If you send a donation, you'll be a registered user. This way you will receive
extra levels (there are 15), the lastest version of D.L.E.D.H., etc...
You may also send any remark, demand of improvment or anything else. They will
be readen and if possible followed. Further information about GETTING REGISTERED
will be found later in this file.

          PLEASE GET REGISTERED, it will be helpful and encouraging.


UNLESS WRITTEN AGREEMENT :
COMMERCIAL USES ARE FORBIDDEN, no extra fee can be charged, except mailing
and/or duplication fees.




                                   /ÿÿÿÿÿÿÿ\
                                   |SUMMARY|
                                   \_______/

(I)                 Introduction & rules.
(II)                Inventory.
(III)               Getting Registered.
(IV)                Future Improvements.
(V)                 Tech Notes.
(VI)                Bugs Report.



-=-=-=-=-=-=-=-=-=
(I) INTRODUCTION :
-=-=-=-=-=-=-=-=-=

	DES LASERS ET DES HOMMES is a 100% machine code True Color game for
the expensive and slow Atari FALCON030. This is a 'Wolfenstein 3D' style game
which can not be compared with DOOM... (ID software)

	This release is the v1.0. All graphs are not ready, and the last ones
were destroyed by a virus four days before this release...   But because of
my departure to the United States (5 months without any Falcon), I couldn't
wait anymore.

	Rules:
	¹¹¹¹¹¹
	The scene takes place in a spatial complex, where 2 spatial
commandos are fighting, currently the browns and the blues.
	You are one of the brown, your aim is to eradicate the blues
out of this area. (Quite simple, isn't it ?)

	Each guy has specific values of abilities, you'll soon learn
to recognize the strongest ones ! (They aren't in your team...) 
	These values are :
		- speed
		- precision
		- parano‹a (i.e. the propencity to shoot friends...)
		This last ability can be turned off.
		
	The implemented soldiers are :
		- N‚phistoph‚lŠs
		- Fer  				 
		- K.S.
		- Dupdob			as FOES
		- Ju-ju
		- K-rho
		- Didbo
		- the hacker
		- many 1st class soldiers
		
		
		- Bill	 	(the colour-blind who shoots everybody)
		- many 2nd class soldiers	as FRIENDS
		
	Your shield is the protection of your spatial armor. When to 0,
flee !
	It auto-regenarates himself with the time.

	The first score table shows the score of the 10 best human or 
computer-controlled characters.
	The final score table shows the 10 best human scores. (It is saved
to the disk when returning to Gem Desktop by pressing ESC (no reset, please...))

	
	Score :
	¹¹¹¹¹¹¹
		. To hit a foe : 3 points
		. To be hit    : -2 points
		. To hit a friend : -1 point
		. rate > 75 : bonus of 200 points
		. rate > 50 : bonus of 100 points
		. To not be killed : bonus of 600 points
	
	Movements :
	¹¹¹¹¹¹¹¹¹¹¹
	Use the mouse (LEFT button to go forward, RIGHT one to shoot
(I had to change the order because of the simultanate Joystick),
joystick 1, or the cursor keypad (with insert and clr home 
right shift to shoot) to move.
N.B.  : 1) Mouse is non-linear : large movements are amplified, small ones
are attenuated - it's now easier to reach your target.
	2) The keyboard keys <- and -> are the only way to move lateraly.
	3) You CANNOT walk on inclined floors... For your eyes only.
	
	Doors are opening when you press the space bar and the ESCape
key will allow you to return to the main menu.


	Dialogs :
	¹¹¹¹¹¹¹¹¹
	By pressing the 'T' (talk) key, you are able to communicate with
the guy just in front of you. If he's a friend, you are telling him to
go away - and he will no longer block you.

	Resolutions :
	¹¹¹¹¹¹¹¹¹¹¹¹¹
	Use F1/F2 (toggle 160x pixels mode for walls) or F3/F4 (toggle 
double line mode for floor) to dynamically change the resolution.

	Begining :
	¹¹¹¹¹¹¹¹¹¹
	Press SPACE to go further in the displaying of screens.
	Use the cursor keys and space to choose your Level and your
screen resolution (320x100 is not perfectly emulated on VGA monitors :
shapes are distorted... You'd better use an RGB monitor, you know...)
	Press Y or N to fix parano‹a ON/OFF
	The ESCape key will allow you to return to the GEM desktop, and
to save the preferences.

-=-=-=-=-=-=-=-=
(II) INVENTORY :
-=-=-=-=-=-=-=-=
         The DES LASERS ET DES HOMMES Package consists of :

           - LISEZMOI.TXT	       La version fran‡aise de cette doc.
           - READ_ME.TXT               This file in poor english.
           - LASEDZOM.PRG              The compressed program file.
           - LASEDZOM.INF	       Some permanent data & scores
	   - TC4\AMIS.C4S	       Some compressed graphs.
	   - TC4\ENNEMIS.C4S

         You must spread this package with ALL FILES.
					   ÿÿÿÿÿÿÿÿÿ
	 (anyway, it won't run if a file is missing, even a .TXT)

-=-=-=-=-=-=-=-=-=-=-=-=-=
(III) GETTING REGISTERED :
-=-=-=-=-=-=-=-=-=-=-=-=-=

         To get registered, send donations to the following address :

	Until August 1, 1994 :
		     
		     Arnaud LINZ
		     NIST
		     Build : 223    Room : B304
		     Gaithersburg, MD 20899
		     U.S.A.
		     ÿÿÿÿÿÿ
		     (don't send any disk ! I won't have any Falcon there.)
	
	and after :
                     Arnaud LINZ
                     7c, rue de la Vieille Eglise
                     59870 VRED
                     FRANCE
                     ÿÿÿÿÿÿ
                     (It is also my Falcon's address...)

         Please give me the version number of DLEDH (pre-preview, preview, v1.0) 
and don't forget to give a mail address for response.
         Reasonnable donations would be 50FF (100FF  if you're a real man),
œ10, 20$, 30DM, etc. Those donations will be use for user support (see below) 
and improvment of the game.
	
	Bank account :
	¹¹¹¹¹¹¹¹¹¹¹¹¹¹
		Arnaud Linz 7c, rue de la Vieille Eglise 59870 VRED - FRANCE
		Bank ref. : 16306 00012 / count 078714E / key : 27
		  (Caisse r‚gionale de cr‚dit agricole mutuel du Nord
		  10 avenue Foch BP 369 - 59020 Lille Cedex)
		Payment place : Douai 27 888805
	


User Support :
         As mentionned, being registered offers many advantages. First, you'll
receive a disk with the last version of DLEDH (or with the next version, if 
you've already got the lastest). You may ask questions, send advice, demands 
or even support. Each message will have a response.
	(But please, don't say anything about the graphisms !!!)	

         Registered users will also be warned when new versions will be released
and the way to *freely* receive them.


-=-=-=-=-=-=-=-=-=-=-=-=
(IV) FUTURE IMPROVMENTS :
-=-=-=-=-=-=-=-=-=-=-=-=

	 I will certainly improve the game when I'll be back in France.
         Possible improvments are listed in decrease priority. That means first
listed, first coded. And that means no guarantee of being coded.

	- More colorful graphics
	- More levels
	- Nicer sound FX
	- Enhanced dialogs with your team (and more clever guys)
	- Various speed optimizations
					-> v2.0
	
	- Level editor			-> v2.5
	
	- Various weapons and other gadgets
					-> v3.0
	
	- Two simultaneous players	-> v4.0 (don't know if the
					falcon will be fast enough)
	
	- Use of a network of players	-> v4.0 (don't know if I'll found
					a second Falcon !)


-=-=-=-=-=-=-=-=
(V) TECH NOTES :
-=-=-=-=-=-=-=-=

	- 100% MC68030+DSP56001 machine code game
	- The DSP is used at 60% - speed improvment : 20% to 40%
	 (the DSP is rather slow... Or my programming rather bad)
	- All calculations are in real-time (except cosine !)
	- All displays are in True Color Mode
	- Almost independant from the system
	- Real 3D - bitmap mapping
	
	
	
-=-=-=-=-=-=-=-=-=
(VI) BUGS REPORT :
-=-=-=-=-=-=-=-=-=

	They are numerous :
	
	- The others's lasers display routine is so basic that lasers
	seem to cross the walls.
	- Guys are sometimes really shooting you across the walls...
	
	- The others are sometimes teletransporting for a frame.
	- The hidden-face algo. isn't perfect, especially while
	  processing upper walls...
	- It's sometimes possible to see behind a wall.
	
	- When you are shooting a foe behind another one, it's the one
	in front of you who's hit (this one will never be corrected, I'm afraid)
	
	- When you'are shooting a guy, sometimes your score is increasing but
	nothing happens. (Move and shoot again)
	
	- The bitmapping of the floor isn't perferct.
	
	They might be corrected if the game appeal to you.

	
						Arnaud Linz.
			
--------------------------------------------------------------------------------
		      E.mail : linz@galaxie.int-evry.fr
--------------------------------------------------------------------------------
