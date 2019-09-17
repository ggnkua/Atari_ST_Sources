***************************************************************************
* DOC DISPLAYER BY THE DEICIDE. UPGRADE TO DEVPAC 3, IN 93,BEFORE GENERAL *
* RELEASE IN THE iCTARi USER GROUP DISK MAGAZINE.IF YOU HAVE ANY PROBLEMS *
* WITH THIS SOURCE, THEN CONTACT ME AT THE ADDRESS, ELSEWHERE IN THE CODE *
***************************************************************************

        pea	0			clear stack
	move.w	#20,-(sp)		set up supervisor mode
	trap	#1			function code
	lea	6(sp),sp		adjust stack pointer
	dc.w	$a00a			hide mouse
	move.w	 #5,-(sp)		kill the annoying -
       	move.w	 #26,-(sp)		keyboard click
        trap	 #14			function code
        lea	4(sp),sp		adjust stack
	move.w  #4,-(sp)		get resolution
        trap    #14			do it
	lea	2(sp),sp		adjust stack
	move.w  d0,oldrez1		store old res
	cmpi.w	#2,d0			compare it to high res
	beq	oh_no			if it's high then quit
	subi.w  #1,no_pages		set number of pages
	move.w  #1,-(sp)		change to medium res
        pea	-1			leave physical base
        pea	-1			leave logical base
        move.w  #5,-(sp)		set up graphics code
        trap    #14			do it, function code
        lea     12(sp),sp		adjust stack
	pea	gem			install first 4 gem cols
	move	#6,-(sp)
	trap	#14
	lea	6(sp),sp
 	move.w  #4,-(sp)		store current resolution
        trap    #14			do it
	lea	2(sp),sp		adjust stack
	move.w  d0,oldrez2		store new res
	move	#2,-(sp)		get physical screen address
	trap	#14			function code	
	lea	2(sp),sp		adjust stack
	move.l	d0,phys			store in 'phys'
	move	#3,-(Sp)		get logical screen address
	trap	#14			function code	
	lea	2(sp),sp		adjust stack
	move.l	d0,logic		store in 'logic'
	move.w  no_pages,d4		print up the first page
        movea.l #pages,a1		put pages into a1
        clr.w   page_shown
	
return: 
        movea.l #instructions,a0	print the top two lines-
        jsr     print			every time a page is selected
        movea.l (a1),a0			put current page on stack
        jsr     print			print it
check_keys:     
        move	#$ff,-(sp)		set up keyboard scanner
	move	#6,-(sp)
	trap	#1			function code
	lea	4(sp),sp		adjust stack
	tst	d0			has a key been pressed ?
	beq	check_keys		no ?, then loop
	swap	d0			yes ?, then see what it was
        
	cmp.b   #$0D,d0			check '+' key
        beq     np			do next page
        cmp.b 	#$0C,d0			check '-' key
        beq     pp			do last page
	cmp.b 	#$10,d0			check 'q' key
        beq     check			do you want to quit ?
	cmp.b	#$19,d0			check 'P' key
	beq	degas			do degas piccy
	cmp.b	#$02,d0			check '1' key
	beq	info			do info message
	cmp.b	#$03,d0			check '2' key
	beq	code1			do code help 1 message
	cmp.b	#$04,d0			check '3' key
	beq	code2			do code help 2 message
        bra     check_keys

exit  

        move.w	 #5,-(sp)		turn keyboard click 
       	move.w	 #27,-(sp)		back on
        trap	 #14			function code
        lea	4(sp),sp		adjust stack
	move.w  oldrez1,-(sp)		restore the resolution
        pea	-1			physical screen is left
        pea	-1			as is the logical
        move.w  #5,-(sp)
        trap    #14			function code
        lea     12(sp),sp		adjust stack
	pea	gem			        
	move	#6,-(sp)
	trap	#14
	lea	6(sp),sp
        pea	0			clear stack		
        trap    #1			exit
***************        
* subroutines *
***************
np:     move.w  page_shown,d4		put current page into d4
        cmp.w   no_pages,d4		are we on last page ?
        beq     check_keys		yes ?, then loop
        lea	4(a1),a1		add a page to a1,(print next page)
        addi.w  #1,page_shown		move pointer to next page
        bra     return			loop
pp:     move.w  page_shown,d4
        tst.w   d4
        beq     check_keys
        suba.l  #4,a1
        subi.w  #1,page_shown
        bra     return
print   move.l	a0,-(sp)		put text onto stack
	move.w	#9,-(sp)		display text
	trap	#1			function code
	lea	6(sp),sp		adjust stack	
 	rts     			return to subroutine
  	
check:  movea.l #sure,a0		are you sure you want to go ?
        jsr     print			print ^ message
ll	move	#$ff,-(sp)		scan keyboard
	move	#6,-(sp)
	trap	#1			function code
	lea	4(sp),sp		adjust stack
	tst	d0			test keyboard
	beq	ll			no keys ? well loop till one's pressed
	swap	d0			yes ? then see what it is
	cmp.b   #$15,d0			check for 'y' key
	beq     exit			yes then exit
	cmp.b	#$31,d0			check for 'n' key
        beq     return			yes, then go to main menu
	bra	ll			loop again if neither 'y' or 'n'
oh_no	jsr	clear			clear screen
	movea.l	#no,a0			if it's high res then print
	jsr	print			message, wait for key then quit
	move.w	#1,-(sp)		wait for any key
	trap	#1			function code
	lea	2(sp),sp		adjust stack
	bne	exit			go to exit
info	jsr	clear			clear screen
	movea.l	#wow,a0			put info message 'wow' in a0
	jsr	darren			print and wait for key
code1	jsr	clear			clear screen
	movea.l	#c1,a0			put code help 1 'c1' in a0
	jsr	darren			print and wait for key
code2	jsr	clear			clear screen
	movea.l	#c2,a0			put code help 2 'c2' on a0
	jsr   	darren			print and wait for key
clear	move.l	#cls,-(sp)		put 'cls' onto the stack
	move.w	#9,-(sp)		'print' cls, or clear screen
	trap	#1			function code
	lea	6(sp),sp		adjust stack
	rts				return to subroutine
darren	jsr	print			print whats on the stack
	move.w	#1,-(sp)		wait for any key
	trap	#1			function code
	lea	2(sp),sp		adjust stack
	bne	return			back to main menu
; These bits hold the doc files n' stuff
c1	dc.b	" CODING TIPS 1",10,13," ^^^^^^^^^^^^^"
	dc.b	10,13,"THIS TEXT IS BY NO MEANS A TUTORIAL IN ANY WAY, IT MERELY CONTAINS INFORMATION"
	dc.b	10,13,"THAT MAY BE OF USE TO SOME PEOPLE. I WILL NOW BRIEFLY COVER SOME OF THE MORE"
	dc.b	10,13,"IMPORTANT THINGS YOU WILL NEED TO CODE IN 68000."
	dc.b	10,13," FIRSTLY, YOU WILL NEED A DECENT ASSEMBLER. THERE IS A QUITE LARGE SELECTION OF"
	DC.B	10,13,"ASSEMBLERS AVAILABLE FOR THE ST, THE BETTER ONES BEING DEVPAC 2 OR 3. IF YOU"
	dc.b	10,13,"SERIOUSLY WANT TO CODE IN 68K,THEN THESE TWO ASSEMBLERS ARE DEFINATELY THE BEST"
	dc.b	10,13,"YOU CAN BUY, AS THEY ARE VERY USER-FRIENDLY. LOOK AROUND IN THE ST MAGS FOR THE"
	dc.b	10,13,"BEST DEALS."
	dc.b	10,13," YOU SHOULD ALSO BUY A DECENT REFERENCE BOOK, BUT MAKE SURE IT IS A RECOMMENDED"
	dc.b	10,13,"BUY FIRST. IT WOULD BE AN EXPENSIVE MISTAKE TO JUST BUY ANY 68K BOOK. I AM NOT"
	dc.b	10,13,"CONDONING ANY BOOKS AVAILABLE, BUT SOME DON'T OFFER AS MUCH HELP AS OTHERS. THE"
	dc.b	10,13,"BOOKS I WOULD RECOMMEND ARE THE FOLLOWING : 'ST INTERNALS': THIS HAS NOW BEEN "
	dc.b	10,13,"TAKEN OFF PRINT, SO YOU MAY HAVE TO ADVERTISE IN A MAGAZINE FOR A SECOND HAND"
	dc.b	10,13,"COPY. COMPUTES 'TECHNICAL REFERANCE GUIDE, VOL 3' IS ANOTHER GOOD READ, COVERING"
	dc.b	10,13,"GEM,BIOS AND XBIOS ROUTINES, AS WELL AS LINE A GRAPHIC ROUTINES. ANOTHER GOOD"
	dc.b	10,13,"READ IS 'REAL TIME 3D GRAPHICS FOR THE ST', PUBLISHED BY SIGMA PRESS. THIS BOOK"
	dc.b	10,13,"CONTAINS A LOT OF USEFUL INFORMATION, AS WELL AS A 68K INSTRUCTION SET, AND"
	dc.b	10,13,"CALLS MADE TO TOS. IF YOU ARE A REAL BEGINNER, THEN ZZSOFTS 'INTRODUCTION TO"
	dc.b	10,13,"MACHINE CODE' IS QUITE A USEFUL BOOK. THESE ARE AMONGST THE BETTER ST BOOKS I"
	dc.b	10,13,"HAVE PERSONALLY READ MYSELF. THERE IS STILL A LOT OF BOOKS I HAVE NEVER READ,"
	dc.b	10,13,"SO I CAN'T COMMENT ON THEM, BUT I WILL DEFINATELY RECOMMEND THE ABOVE BOOKS TO"
	dc.b	10,13,"ANY ST CODER, THINKING OF LEARNING THE POWERFUL LANGUAGE OF ASSEMBLY."
	dc.b	10,13,"                         PRESS ANY KEY FOR THE MAIN MENU",0
c2	dc.b	" CODING TIPS 2",10,13," ^^^^^^^^^^^^^"
	dc.b	10,13," A GOOD WAY TO LEARN 68K, IS FROM OTHER PEOPLES CODE. IF YOU LOOK AROUND IN THE"
	dc.b	10,13,"P.D. THEN YOU SHOULD FIND ENOUGH DECENT STUFF TO GET YOU STARTED. TRY AND SEE"
	dc.b	10,13,"HOW IT WORKS, TRY CHANGING IT A LITTLE, TRY DIFFERENT VALUES WHERE THEY ARE "
	dc.b	10,13,"STATED, AND ADD OTHER CODE TO IT. BY EXPERIMENTING, I FOUND OUT WAYS TO ENLARGE"
	dc.b	10,13,"A 32-32, BLOCK OF PIXELS, TO THE FULL SIZE OF THE NORMAL ST SCREEN-NOTE THAT I"
	dc.b	10,13,"MEAN WITH BORDERS."
	dc.b	10,13,"    SOME GOOD PLACES TO FIND SOURCE CODE IS IN DISK MAGAZINES,LIKE 'THE LEDGERS'"
	dc.b	10,13,"FROM THE UNTOUCHABLES, WITH CODE, HELPFUL HINTS AND TEXT FILES FROM THE SOME OF"
	dc.b	10,13,"THE TOP ST DEMO WRITERS, INCLUDING : THE UNT, THE WILD BOYS, THE PIXEL TWINS,"
	dc.b	10,13,"NINJA, ETC. THE MAG IS SHAREWARE AND AVAILABLE FROM MOST PD LIBRARIES. WHEN THE"
	dc.b	10,13,"ICTARI MAG BECOMES WELL KNOWN, THEN I IMAGINE THAT THIS WILL BECOME A GREAT"
	dc.b	10,13,"PROVIDER OF SOURCE CODE."
	dc.b	10,13,"    I WILL SUPPORT THE ICTARI USER GROUP, TO MY FULL EXTENT, AND I WILL SEND IN"
	dc.b	10,13,"CODE, WHEN AT ALL POSSIBLE. IF YOU NEED ANY HELP, WRITE TO THE ICTARI USER "
	dc.b	10,13,"GROUP, AND LEAVE ANY QUESTIONS THERE. I'M SURE THEY WILL BE ANSWERED BY CODERS"
	dc.b	10,13,"WHEN THEY HAVE READ THEM."
	dc.b	10,13,"    YOU SHOULD FIND THE SOURCE TO THIS AND SOME OTHER CREATIONS OF MINE ON THIS"
	dc.b	10,13,"DISK, AND FROM NO OTHER PLACE AT ALL. SOME OF THE ROUTINES I HAVE SENT IN IS "
	dc.b	10,13,"NOT MY BEST, OR FASTEST CODE, BUT TO BEGINNERS,I'M SURE,IS MORE UNDERSTANDABLE"
	dc.b	10,13,"AND EASIER TO FOLLOW, THAN SOME COMPLEX, YET FASTER CODE."
	dc.b	10,13,"    WHEN YOU START TO CODE, START WITH SOMETHING SMALL, AND BUILD UP ON THAT."
	dc.b	10,13,"LIKE TRY DISPLAYING A SPRITE, THEN TRY MOVING IT, ETC. BUT DON'T GIVE UP. DPG"
	dc.b	10,13,"                         PRESS ANY KEY FOR THE MAIN MENU",0
wow	dc.b	"  INFORMATION",10,13,"  ^^^^^^^^^^^"
	dc.b	10,13,10,13," THIS DOC DISPLAYER WAS WRITTEN BY THE DEICIDE, EX-MEMBER OF THE NOW DEAD DEMO" 
	dc.b	10,13,"CREW 'THE GOVERNMENT'.THIS DISPLAYER WAS WRITTEN USING DEVPAC 2, BUT UPGRADED "
	dc.b	10,13,"TO MAKE IT DEVPAC 3 COMPATIBLE. SOME OF THE CODE NEEDED TO BE CHANGED SLIGHTLY"
	dc.b	10,13,"AS IT WORKED FINE ON VERSION 2, BUT CRASHED ON 3. PLEASE FEEL FREE TO USE THIS"
	dc.b	10,13,"DISPLAYER OR ANY OF THE ROUTINES THAT I'VE USED TO MAKE THIS DISPLAYER. MAKE"
	dc.b	10,13,"SURE YOU CREDIT ME IF YOU DO THOUGH. "
	dc.b	10,13,"     I HAVE NOW WRITTEN A FAR SUPERIOR DOC DISPLAYER, WHICH SCROLLS THE TEXT"
	DC.B	10,13,"UP AND DOWN THE SCREEN VIA THE CURSOR KEYS, AND I WILL GIVE THE SOURCE TO ICTARI"
	dc.b	10,13,"AS SOON AS IT'S COMPLETE.I'M JUST ADDING THE FINISHING TOUCHES TO IT AT THE MO'."
	dc.b	10,13,"    IF YOU ARE INTERESTED IN ANY SOURCE CODE TO DEMO SCREENS,ETC, THEN WRITE TO"
	dc.b	10,13,"ME AT THE FOLLOWING ADDRESS, AS I'VE GOT LOADS TO SWAP :"
	dc.b	10,13," D.GOLDING,  508 KNOWSLEY LANE,  KNOWSLEY VILLAGE,  MERSEYSIDE,  L34 9EF"
	dc.b	10,13,"I WILL REPLY TO ALL LETTERS THAT I RECEIVE, AND ALSO TO EVERY ENQUIRY. IF YOU"
	dc.b	10,13,"ARE INTERESTED IN DEMO SCREENS, THEN I'VE GOT SOME OF THE BEST. (SEE FOOT NOTE)."
	dc.b	10,13,"IF YOU NEED SOME ASSEMBLER HELP, THEN WRITE TO THE 'HELP WANTED' SECTION OF THE"
	dc.b	10,13,"ICTARI DISK MAG, AS I'M SURE OTHER PEOPLE WILL BENEFIT FROM YOUR ENQUIRY."
	dc.b	10,13,"   NOTE : I AM NOT SELLING ANY SCREENS, SO I'M NOT TRYING TO MAKE ANY MONEY FROM"
	dc.b	10,13,"OTHER PEOPLES WORK. I'LL GLADLY SWAP OR COPY SOURCE,BUT I WILL NOT SELL ANY.ALSO"
	dc.b	10,13,"I WILL NOT SWAP ANY CODE,THAT I'VE BEEN ASKED NOT TO, I.E. UNTOUCHABLES PERSONAL"
	dc.b	10,13,"CODE, OR THE UNT SOURCE DISK, OR THE A.S.C SOURCE DISKS." 
	dc.b	10,13,10,13,"                         PRESS ANY KEY FOR THE MAIN MENU",0			
sure    dc.b 	27,'E',27,"pARE YOU REALLY REALLY SURE YOU WANNA QUIT ? (Y/N)",27,'q',0
no	dc.b	"SORRY, BUT I DON'T RUN IN HIGH RESOLUTION PRESS ANY KEY TO EXIT. ",27,'q',0

page1  
        dc.b 10,13," Hi,",10,13
        dc.b "      Its the Deicide here, with a Doc Displayer that I coded sometime in '92.",10,13
        dc.b " You should find the Assembler source code to this displayer as well as some",10,13
        dc.b "other stuff of mine,somewhere,in the assembly folder.This displayer is operated",10,13
        dc.b "via the keyboard and is pretty easy to use. If you look at the top,you will see",10,13
        dc.b "which keys to press for the various options available to you. There may be an ",10,13
        dc.b "advert, which you can access via the 'P' key. To forward the text by one page,",10,13
        dc.b "press the '+' key. To view the previous page press the '-' key.	",10,13
        dc.b "  The Info screen can be accessed via the number 1 key.This contains information",10,13
        dc.b "about this displayer, and a small insight into me.",10,13
        dc.b "  The keys 2, and 3, let you access two pages of coding information, tips if you",10,13
        dc.b "like, covering what assembler to get, what books, etc.",10,13
        dc.b "  Also, the next three pages, briefly explain how this displayer works, and how",10,13
        dc.b "to create the various parts, which make up the main program. ",10,13
        dc.b "  After I have explained how this program works, I'll briefly explain how to",10,13
        dc.b "remove the bottom border, in assembly language. The final page, being a small",10,13
        dc.b "greetings list, of people who have offered me priceless help within the last few",10,13
        dc.b "years.",10,13
        dc.b 10,13,"                   Press the appropriate keys to read on.",10,13
	dc.b	"								       	     DPG",10,13,0
        
page2  
        dc.b 	"************************************",10,13
	dc.b 	"* DOC-DISPLAYER, WRITTEN BY D.P.G. *",10,13
	dc.b	"************************************",10,13,10,13
	dc.b	"This text file is to explain how the doc displayer, in the Assembly folder",10,13
	dc.b	"works. Firstly, I must say that the code is based on routines written by the",10,13
	dc.b	"P.M. now of TTK, but is totally original, as I have re-written it, using my own",10,13
	dc.b	"faster and better routines.",10,13
    	dc.b	"I was asked by a friend to code a doc displayer, and he didn't mind how it",10,13
	dc.b	"looked, so I decided to go for a simple one. The one I wrote lets you view a",10,13
	dc.b	"page at a time, by pressing the + or - keys. I have now written a displayer",10,13
	dc.b	"that scrolls the text up and down the screen, using the arrow keys, but thats a",10,13
	dc.b	"different story.",10,13
   	dc.b	"  Firstly, we need to set up the Supervisor mode, as this will allow us to",10,13 
	dc.b	"access more memory, and more routines. The keyboard click and the mouse are now",10,13
	dc.b	"removed as they are both annoying. We now check the resolution, and see if it's",10,13
	dc.b	"a high rez monitor. If it is, we quit because there is a low res switch later",10,13 
	dc.b	"on in the code. We now change the resolution to medium,and install a few screen",10,13
	dc.b	"colours, to make the screen visable.After storing the rez, we save the physical",10,13
	dc.b	"and logical screen address's as they will be used to return to current set up if",10,13
	dc.b	"the low res switch is operated. Next, we put the amount of pages we have, in the",10,13
	dc.b	"case of this 7, into registar d4. We then install 'pages' in a1, which contains",10,13
	dc.b	"the order of the pages, and the first page is installed. The pointer which will",0
page3  
        dc.b	"enable us to see what page we are up to is now cleared.",10,13
   	dc.b	"    Now here's the main code : the instructions are now put into a0, which will",10,13
	dc.b	"print the top two lines. The current page is put into a1, and that also will be",10,13
	dc.b	"printed. As we set it up earlier, the first page will be printed. From here,the",10,13
	dc.b	"keys are tested, and any changes are made as follows :",10,13
 	dc.b	"If the + key is pressed, then we print the next page in the following way :",10,13
	dc.b	"We put the current page into d4, and test this against the number of pages to",10,13
	dc.b	"see if we are on the last page. So if the current page is 7, then we are on the",10,13 
	dc.b	"last page, so we go back to checking the keyboard. Otherwise we put the next",10,13 
	dc.b	"page in a1, and increase the 'page_shown' pointer by 1. We now go back to the",10,13
	dc.b	"label 'RETURN' which prints the top two lines, and the new, current page.",10,13
   	dc.b	"If the - key is pressed then the current page is also put into d4. This is",10,13
	dc.b	"tested (TST) against 0, to see if it's the first page. If it is then we go back",10,13
	dc.b	"to checking keys. Otherwise, we put the previous page in a1, subtract one from",10,13
	dc.b	"the 'page_shown' pointer, and go to the label 'RETURN', which will print the",10,13 
	dc.b	"new, current page, and then check for keys.",10,13
   	dc.b	"If the Q key is pressed, then we go to the label 'CHECK', which, firstly",10,13 
	dc.b	"clears the screen, then prints the 'ARE YOU SURE ?' message, and wait for a key",10,13
	dc.b	"to be pressed. If the 'Y' key is pressed, then we exit, by going to the label",10,13 
	dc.b	"'quit', and restoring anything we have changed. If the 'N' key is pressed, then",10,13
	dc.b	"we print the page we were just reading, and carry on as normal.",10,13
	dc.b	"   If the P key is pressed, the displayer will show a low res Degas picture.",10,13
	dc.b	"This is done in the following way : Firstly, we have to set up the actual low",0 
page4 	
	dc.b	"res screen, by passing parameters to the XBIOS. We have to define our new PHYS",10,13
	dc.b	"and LOGICAL screens within these parameters. One this is done, we then read the",10,13
	dc.b	"new pallette, and install it into the normal registers,i.e. $fff8240. Once this",10,13
	dc.b	"has been done, we go about displaying the picture in the normal way, using our",10,13
	dc.b	"new physical screen address for the actual display. We now wait for ANY key to",10,13
	dc.b	"be pressed, before reseting the old resolution, and the old physical and logical",10,13
	dc.b	"screen addresses. We then install four colours into the $fff8240 register, and",10,13
	dc.b	"this is to prevent our displayer using the same pallette as the picture. After",10,13 
	dc.b	"the medium res switch has returned, and the colours have been reset, it's back",10,13
	dc.b	"to the normal waiting for key routine, as the page we were reading before we",10,13 
	dc.b	"carried out the res change is installed back into the display page.",10,13
   	dc.b	"    The following keys all carry out the same instruction, but will display a",10,13
	dc.b	"different text message : 1 - info screen, 2 - some coding tips and 3 - coding",10,13
	dc.b	"tips part 2.",10,13
 	dc.b	"    Firstly, when any of the above keys are pressed, the screen is cleared, and",10,13
	dc.b	"the current page we were reading is stored. Then the new text message is now",10,13
	dc.b	"installed and 'printed' to the screen using the Gem routine number #9. After",10,13
	dc.b	"this has been installed, we then wait for any key, to return us to the main",10,13
	dc.b	"menu screen, viewing the page that we were reading before we pressed the key.",10,13
	dc.b	10,13,"    Well, this about covers the Doc Displayer, read on for the help text on the",10,13
	dc.b	"no bottom border routine, etc.",0

        
page5  
	dc.b	"************************************************************",10,13
	dc.b	"* Removing the Lower Border in Assembly Language By D.P.G. *",10,13
	dc.b	"************************************************************",10,13,10,13
	dc.b	"    This article will explain how to remove the lower border from within",10,13
	dc.b	"machine language, using the TIMER B interrupt.",10,13
   	dc.b	" As you should know, the display screen that you are looking at is updated",10,13
	dc.b	"50 times a second, or 50 Hz. Without getting too technical, it's drawn by an",10,13
	dc.b	"electron beam, which starts at the top left corner, and then draws to the top",10,13
	dc.b	"right. When this line is complete, the beam moves to the next line, and so on.",10,13
	dc.b	"In low res, there is 200 lines to draw, so this process is repeated for all 200",10,13
	dc.b	"lines. On the 200th line, the electron beam is sent back to the top left",10,13
	dc.b	"corner, and the process is started again. In 50 Hz mode, this is done 50 times",10,13
	dc.b	"per second.",10,13
    	dc.b	"    The electron beam gets it's information from whats called Video Ram, which",10,13
	dc.b	"is where the actual screen display is stored in memory. The Video Ram will",10,13
	dc.b	"function perfectly, except for a split second, if it's changed to 60 Hz. Once",10,13
	dc.b	"it has corrected itself, it will then function as normal. However, it does not",10,13
	dc.b	"tell the electron beam to stop drawing, so the beam will carry on regardless,",10,13
	dc.b	"and continue to draw until instructed by the Video Ram.",10,13
    	dc.b	"    So, if we can track the electron beam(or to give its proper name, Video",10,13
	dc.b	"Shifter), and when it's on line 200, change to 60 Hz, it will begin drawing in",10,13
	dc.b	"the Lower border, this is where we use Timer B. Timer B does exactly what we",0  
page6
        dc.b	"need here, and that is to track the beam itself. There are many uses for Timer",10,13
	dc.b	"B, like colourful rasters that appear is many demos, or pallette switching,",10,13
	dc.b	"etc, but for this program, we will use it to just track the beam. We can then",10,13
	dc.b	"write a routine that switches the frequency to 60 Hz on line 200, where the",10,13
	dc.b	"Video Ram, will get confused, the beam will carry on drawing, and we have no",10,13
	dc.b	"lower border. We then have to change back to 50 Hz, and carry on as normal.",10,13
    	dc.b	"    Simple eh! Well this is one way to remove the border, but in my opinion,",10,13
	dc.b	"it's the easiest to understand. I have written some Assembly source to go with",10,13
	dc.b	"this article, which displays a DEGAS.PI1 file, starting approx 30 lines down,",10,13
	dc.b	"so the bottom of it is in the lower border. You will find this file in the",10,13
	dc.b	"Assembly folder and it's called NOBORDER.S. It's fully commented, so it",10,13
	dc.b	"shouldn't be too difficult to follow."
	dc.b	10,13,10,13,"    Next page for greetings and thank you's, etc.",0
page7       
        dc.b 	"  The Greetings Section",10,13
        dc.b 	"  ^^^^^^^^^^^^^^^^^^^^^",10,13,10,13
        dc.b 	"  In no particular order, I'd like to say a big thank you to the following",10,13
        dc.b 	"people :",10,13
        dc.b 	"Nik, of Ictari, for publishing this displayer and any other source of mine.",10,13
        dc.b 	"Any fellow members of Ictari user group. May your coding dreams come true.",10,13
        dc.b 	"The Untouchables, especially Mat, cheers for the source and any help.",10,13
        dc.b 	"The Pixel Twins, especially Highlander, for some useful tips.",10,13
        dc.b 	"The Albaniun Sausage Corporation",10,13
        dc.b 	"The Wild Boys for useful coding articles and source on The Ledgers.",10,13
	DC.B	"Ninja, for your articles, especially sprite routines, cheers.",10,13
	DC.B	"The Prime Minister, are you still alive ? What's up Mat ? You have not written",10,13
	dc.b	"for ages.",10,13
	dc.b	"The Shadow, Thanks for the source and also for the help.",10,13
	dc.b	"Shayne Jennings of PD Studio, Thanks for the disks mate.",10,13
	dc.b	10,13,"   And thanks to you for reading this,  good luck    The Deicide",0
instructions:   
        dc.b 27,'E',27,"p  <+> FOR NEXTPAGE      <P> PICTURE            <Q> QUIT         <1> INFO SCREEN     ",10,13
        dc.b "  <-> FOR PREVIOUS      <2> CODING PART 2      <3> INFO SCREEN        BY DPG    ",27,'q',10,13,0
degas	movem.l	d0/a0-a1,-(sp)			save registers - otherwise it crashes
	move.w	#0,-(sp)			set to low res
	move.l	screen,-(sp)			set phys base
	move.l	screen,-(sp)			set logic base
	move.w	#5,-(sp)			set screen to above param's
	trap	#14				call xbios
	lea	12(sp),sp			adjust stack
	move.l	#pic+2,-(sp)			do pallette
	move.w	#6,-(sp)
	trap	#14
	lea	6(sp),sp			adjust stack
	move.l	#$7d00-1,d0			display piccy
	move.l	#pic+34,a0
	move.l	#$f8000,a1
p	move.b	(a0)+,(a1)+
	dbf	d0,p
	move.l	#pic+2,-(sp)
	move.w	#6,-(sp)
	trap	#14
	lea	6(sp),sp 
	move.w	#1,-(sp)			wait for any key
	trap	#1				function code
	lea	2(sp),sp	      	
exit2	pea	gem			        install first 4 gem cols
	move	#6,-(sp)
	trap	#14
	lea	6(sp),sp
	move.w	oldrez2,-(sp)			reset old rez
	move.l	phys,-(sp)	
	move.l	logic,-(sp)
	move	#5,-(sp)
	trap	#14
	lea	12(sp),sp			adjust stack
	movem.l	(sp)+,d0/a0-a1
	bra	return			

			

params		dc.b 1,0,1,1
       	 	DC.w 639,199,0,0
pages	  	DC.l page1,page2,page3,page4,page5,page6,page7
no_pages:       DC.w 7
cls		DC.B	27,'E',0
page_shown      DS.l 1
oldrez1          dc.w 	0
oldrez2          dc.w 	0
phys		dc.l	0
logic		dc.l	0
oldstk		dc.l 	0				old stack storage
gem		dc.w	$777,$700,$070,$000,$007,$707,$077,$555
		dc.w	$333,$733,$373,$773,$337,$737,$377,$000
screen		dc.l	$f8000
pic	incbin	"b:\deicide\piccy.pi1"	



