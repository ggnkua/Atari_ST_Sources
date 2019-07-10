;----------------------------------------------------------
;
;
;
;
;
;
;                PROtracker replay routine
;                ÿÿÿÿÿÿÿÿÿÿ ÿÿÿÿÿÿ ÿÿÿÿÿÿÿ
;                        converted
;                           by:
;
;                        ¯ Lance ®
;
;
;
;
;
;
;----------------------------------------------------------
;  ....PROtracker was invented by Freelancers (Amiga)....
;----------------------------------------------------------
; It's wasn't a long time ago since I released my a second
; version of my replay routine.Now it's time for the third.
; This time I have only included a 50kHz routine but since
; it only takes about 30% I doesn't feel so motivated to 
; code a 25kHz routine (perhaps YOU can motivate me ,if you
; think so then contact me). A ruff calcuation gives me that
; a 25kHz routine wold take around 20%.
;----------------------------------------------------------
; Rather much have happened since the last version. I have
; totally rewritten the Paula emulator and by combining
; several technique (like LCM1992-volume control and rather
; advanced Self-Generating-Code) I am now able to do a
; 50kHz routine with every command around 30% of the STe's
; totally processing power (not Falcon compatible becoz of
; several reasons i.e. nasty use of stack and that the LCM
; is non-existing in the Falcon'030). I really hope that
; all you comptent hackers in the world will like my
; routine and if so then please contact :
;---------------------------------------------------------- 
;	M†rten R†nge
;	Mejerigatan 2/373
;	412 76 GOTHENBURG
;	SWEDEN
;----------------------------------------------------------
; Or by e-mail:
;----------------------------------------------------------
;               d3marten@dtek.chalmers.se
;----------------------------------------------------------
; This program is a CardWare program. Which means if you
; like it and use it regulary you are encouraged to send
; me a card or a letter(I prefer them without bombs(joke!))
; and tell me how much like my routine and that you think
; that I'm the greatest coder in the world etc. etc.
; This will encourage me to go on with my work on a UCDM -
; player and a Octalizer routine(XIA contacted me after he
; saw my version 0 of my Paula emulators and it's much
; thanks to him and to all others that have contacted me
; that version is made. So as you can see,contacting the
; programmer is very important.).
;----------------------------------------------------------
; Some notes:
; Always call mt_Paula before mt_music ,this because
; mt_music sometimes takes more time and sometimes takes
; less. DON'T use Trap0 because I am using that to switch
; between Supervisor- and Usermode.
;----------------------------------------------------------
; P.S. This replay routine supports every PT2.2 command D.S
;----------------------------------------------------------
;      - Lance / M†rten R†nge      1993/09/04
;----------------------------------------------------------
