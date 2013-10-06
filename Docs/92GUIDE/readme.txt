*****************************************************************************
                   68k asm tutorial:   ver 1.6: july 98      
*****************************************************************************

I ) Getting started
II ) History
III ) Bibliography
IV ) copyright things

-----------------------------------------------------------------------------

I ) Getting started

Note that this package could be decompressed in the fargo subdirectory, with
the original subdirectory structure.

With that file, you should have gotten:
\lesson\newbies.txt
\lesson\lesson_1.txt
\lesson\lesson_2.txt
\lesson\lesson_3.txt
\doc\68kguide.txt
\doc\files.txt
\doc\system.txt      
\doc\ti-prot.txt
\doc\amiga.txt
\doc\direct.txt

 \Readme          : this file ! 

 \lesson\Newbies  : aimed at asm beginers.
 \lesson\Lesson_1 : stuff on arithmetics
 \lesson\Lesson_2 : stuff on keyboard and the stack
 \lesson\Lesson_3 : stuff on screen, grayscale graphics and interrupts

 \doc\68kguide    : jimmy mardels guide now also distributed with this
                    tutorial ( good if you need to learn 68k asm and
                    allready know asm ) 
 \doc\System      : aimed at more advanced programmers: it presents what i
                    know of fargo, the ti-os, the 68k processor and the calc
                    hardware. (good if you allready know 68k asm programming)
 \doc\files       : a complete doc on tokenization and the file structure used
                    by the ti os. By gareth.
 \doc\ti-prot     : the link protocol on the byte level. By Pascal Bouron.
 \doc\Amiga       : amiga object code file format ( see \system.txt  section
                    IV )
 \doc\Direct      : a small sum up of the directives which can be used with
                    the a68k assembler

 A convention is used in all the txt files included in this distribution.
Reference to files in the form: "lowlevel.txt" are fargo distribution
files. Reference to files in the form: \readme.txt are files included in
this distribution.

 To learn assembly on the 68000 motorola processor, you should first get
the motorola documentation on this processor (in the pdf format, available
at their site and at ticalc.org) . It can be usefull ...
 Then, real beginers should begin with \lesson\newbies.txt which contains a
tutorial for them. They will also need \doc\68kguide.txt.
 Advanced users ( those who allready know some assembly langage ) should begin
with \doc\68kguide.txt to get accustomized to 68000 opcodes and
\doc\system.txt to get a few things on the particularities of the 68000
processor, the TI OS and Fargo.

 If you have any assembly related question, ask the list "assembly 92"
available at ticalc.org. There are brilliant guys there: many are really
good at asm programming and have lots of experience.

 Finaly, if you want to really understand what happens in the processor each
time you execute an arithmetic instruction, to get out what is really memory
, please, download the file logic.zip from my site (bottom of page) :
"http://users.aol.com/hmlacage/". It is a shareware program which contains
an excellent documentation ! The documentation will explain you everything ! 

-----------------------------------------------------------------------------

II ) History

 The newbies file began on the assembly 92 list , on ticalc.org, when it was
still named list-fargo. Many people kept on asking the same questions, i had
just learnt assembly. I thus began writing 3 or 4 emails to the list with
a basic tutorial on fargo. Someone asked me to release on the ti-files and
i wrote it down in a file named: newbies.txt. It was quite awfull, there were
many errors ( there are still many ) ...
 Here is finally a corrected version , much better written and updated to
fargo II file listing. Fargo II may be found at "http://www.ticalc.org"
 The system file was originally a small doc on the 68000 processor included
with the newbies.txt file. It now is what you can see: the part III.2 is
mostly directly copied from a doc Gareth <Gareth-James@usa.net> wrote
and never took time to officially release. He did a realy great job !

-----------------------------------------------------------------------------

III ) Bibliography

 Dr Dobb's Journal bibliography on 68k processors ( i have been unable
 to have access to these issues: no one has some in south france... )

*32000 vs. [letter] (T. Wieland), Sep86, 10
*"680xx Computers: Where Are They Going?" (N. Turner), Jan87, 16;
  Apr87, 12; Aug87, 140
*8080, in "COM: An 8080 Simulator for the MC68000" (J. Cathey),
  Jan86, 76; Mar86, 108; Jun86, 8; Sep86, 12
*BASIC, Tiny, in "Tiny BASIC for the 68000" (G. Brandly), Feb85, 42
  Aug85, 10;
*"Bringing Up the 68000 - A First Step" (A.D. Wilcox), Jan86, 60;* Apr86, 12
*compiler, cross, in "A Forth Native-Code Cross Compiler for the MC68000"
  (R. Buvel), Sep84, 68; * Feb85, 9
*family, overview of, in "68040 Programming" (S. Satchell), Mar90, 38 
*Forth, a mini, for the (G. Yates Fletcher), Jan87, 22 
*"Forth and the Motorola 68000" (J. Barnhart), Sep83, 18; Jan84, 8 
*Forth, in "A Fast Forth for the 68000" (L. Chavez), Oct87, 32 
*interfacing to an AIM 65 (L. Fusina and C. Granuzzo), Jan82, 12 
*interpreted language, 680xx experimental, proposal for (N. Turner),
  Jan87, 126
*kernel, multitasking, for (S. Passe), Nov83, 20 
*"Multi-68000s in a Personal System" (A. Kossow), Jun82, 22; Sep82, 6 
*multitasking kernel for (S. Passe), Nov83, 20 
*operating system, in "A Simple Multitasking Operating System for Real-Time
  Applications" (N. Turner), Jan86, 44
*"PL/68K: C Becomes 68000 Assembly Language" (E.K Ream), Jan86, 26 
*"Simplified 68000 Mnemonics" (W.D. Maurer), Oct82, 36 
*speed of, vs. Z80, 68008, and 6809 [letter] (D. Farnsworth), Apr87, 12 
*"Tiny BASIC for the 68000" (G. Brandly), Feb85, 42; Aug85, 10; Jul85, 10;
  Aug85, 10

assemblers

*"A 68000 Forth Assembler" (M.A. Perry), Sep83, 28 
*cross, 68000 [in FORTRAN] (A. Kossow), Oct,Nov82; Mar83, 6 
*cross, in "A 68000 Cross Assembler" [Modula-2] (B.R. Anderson),
Apr-Jun86; * Jun86, 10; Feb87, 14
     
hey: this is the model of the a68k compiler by A. Gibbs we use with fargo !

*regarding 68000 (M. Aichlmayr), in 16BST, Aug85, 117


programs

*cross assembler for Series 32000 (R. Rodman), Dec86, 48 
*"Mandelbrot Program for the Macintosh" (H. Katz), Nov86, 42
*"Worm Memory Test" (J.W. Steinman), Sep86, 114 

subroutines

*binary (32-bit signed) to ASCII hex conversions (S. Passe), Jul83, 94 
*encryption/decryption, in "Survey of Data Encryption" (J.A. Thomas),
  Jun86, 16
*jump table, example of (S. Rabalais), in 16BST, Apr85, 110 
*moves, 32-bit, in "8088 Assembly-Language Programming Techniques"
  (T. Disque), Jul87, 24; Nov87, 12
*pseudo-random number generator (M.P. McLaughlin), in 16BST, Nov85, 88 
*search, binary, of long word array (M.P. McLaughlin), in 16BST, Nov85, 88 
*square root, 32-bit [letter] (T. Wieland), Sep86, 10 
*square root, integer (J. Cathey), in 16BST, May85, 118; Aug85, 116;
  Nov85, 88; Apr86, 117
*string comparison, in 16BST (R. Duncan), Dec86, 104 



 Bibliography to english speaking readers: ( send more ref if you have some )
------------------------------------------

* "68kguide" by Jimmy Mardel availabble at ticalc.org

* the official doc from motorola available at their site.


 Bibliography to french readers: ( send more ref if you have some )
--------------------------------

* "Assembleur Facile", editions marabout, collection "les best sellers de
l' informatique", philipe lemercier, ~ 70 FF
 Ecrit pour PC, mais tres tres bien fait !

* "zguide", Florian Drevet, gratuit, disponible a ticalc et a 
"http://www.mygale.org/01/zorglop/ti92/zguide/"
 Pas encore fini mais tres bien fait, clair .. A mon avis, ca se rapproche 
d' une traduction commentee de la doc de fargo et d' une traduction du
jeu d' instructions de jimmy mardel. Il y a aussi, qq exemples, bien 
expliques. Son grand merite est d' etre en francais.

* "Le microprocesseur 68000 et sa prgrammation", editions eyrolles, Patrick
Jaulent
 Cher mais tres bonne reference hardware ( 270FF )

* "Programmation structuree en assembleur 68000", editions Masson,
J-P. Malenge, S. Albertsen, P. Collard, L. Andreani 
 Peu couteux mais tres probablement difficile a trouver ( mon edition date
de 89 et je ne sais pas s' ils en ont encore en stock... 170FF ) ( au cas ou
il ne serait plus edite, je peux effectuer des copies et les envoyer en
echange des frais de copie et d' envoi bien sur ) .

* "Architecture des systemes d' exploitation", editions Hermes,
M. Griffiths, M. Vayssade
 Cher ( 320 FF ) mais excellent doc sur les systemes d' exploitation et
surtout les systemes de segmentation/pagination et la gestion de la memoire
par les systemes multiprogrammation et multiprocesseurs. Interresant pour
apprendre qq trucs...

-----------------------------------------------------------------------------

IV ) copyright things

 This tutorial may not be distributed without all the files ( see II ).
This tutorial.zip file may be distributed on the sites or on the cd's on which
fargo II is distributed. It may not be put on any other web site or any other
cd or anything else without telling me ( drop me a mail ) . This is not to
stop its distribution but to allow me to keep track of that file and allways
give access to the last version of that file.
 French site owners only: selon la legislation francaise, ce fichier etablit
sans ambiguite la nature originale de ces fichiers. En consequence, ceux-ci
sont proteges par les lois sur les droits d' auteur: toute copie, totale ou
partielle sans l' autorisation expresse de l' auteur ( moi ) du present
document et fichiers constitue donc un delit. J' autorise ainsi la diffusion
de ces fichiers sur les sites ayant l' autorisation de distribuer fargo II
et ceux cites ci-dessous.

 For now, authorised sites are :
 * http://www.ticalc.org
 * ti-philes
 * http://www.mygale.org/03/ti92plus/

 Also, it would be kind to tell me you put it on your site even if you
distribute fargo. 


*****************************************************************************
                                           
*****************************************************************************

Notes:
 Do not ask for a french version of that tutorial: i have no time now..
However, aol users may have good surprises next year...
 PLEASE: DO NOT CALL HOME !!! 
 You may mail for comments on the tutorial, errors found and the like
I will apreciate thanks and/or ideas as to what sections could be added,
what things could be explained in future lessons.


thanks:

    * david ellsworth for the great FARGO !!!!!!!!!!! ( why fargo, david ? )
    * all those who helped me to learn asm...
    * Gareth for all his suggestions, encouragements and all the things he
      taught me.
    * db92 author for having written the db92 section.
    * Sami Khawam for having written the section on the link MCU

If you want to reach me, email at : ( till september 98)
mathieu: <lacage@email.enst.fr>

on ex-list fargo: Assembly92 ( available at ticalc.org ) 

on IRC: on #ti, my nick is fly_craze and i am there between 22h and 23 h 30
( paris time ) on summer... Working for school now...

my adress:
Mr LACAGE Mathieu
2 Rue de la Lavande
34430, Saint Jean de Vedas
FRANCE

