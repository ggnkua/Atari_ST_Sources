extern int trapres(pc,type,x,y)
int pc,type;
{
extern char crumobj[][9],*rummsg[],pname[],*com[],*msg[],*name[],curmon[][60];
extern char specbuf[],zline[16][8][7],*specword[],*obj[],rumdata[][157];
extern int hold,usedline,new,lev,crum,col,row,mode,bitmap[][65],storbuf[][130];
extern int monster,dungeon,police,grflist[],outside,fromout;
extern long int addr;
extern char permon[][23],invnpc[][20];
char *c = curmon[pc],*s1,*s2,*z = zline[x][y],str[20];
int flag,flag2,flag3,i,j;
if(pc > 3) {
    s1 = msg[0];
    s2 = name[*(c+3)];
    }
else {
    s1 = rummsg[0];
    s2 = (pc == 0 ? pname : name[*(c+3)]);
    }
switch(type) {
   case 0:
      break;
   case 1:  /* generic lock door behind player subroutine */
      flag = 0;
      for(i=0;i<4;i++) {
         c = curmon[i];
         if(i == pc)
            continue;
         if(*c == 1 && *(c+30) != crum)
           flag = 1;
         }
      if(flag)
        break;
      untrap(zline[x][y][1]);
      destroy(1,zline[x][y][1]);
      flash();
      drawsq(x,y);
      prnt("-> The exit behind %s suddenly disappears!",s2);
      if( dungeon != 1 || crum != 20) {
         for(i=0;i<4;i++) {
            c = curmon[i];
            if(*(c+52) != 0)
              prnt("-> The seekshard is \
heard to discharge its stored spacetime impression matrix!"); 
            *(c+52) = *(c+53) = 0;
            }
         }
      break;
   case 2:
      flash();
      prnt("-> %s hears faraway goblin cries.  One goblin is heard to \
roar `Melkthrop feeds again!'",s2); 
      untrap(1);
      untrap(2);
      actmon(11,3,7,2);
      prnt("-> A strange moaning sounds accompanies the appearance of three \
spectral forms. %s is rooted to the spot with fear as the spirits go wailing \
down the hall!  Their last cry is `Melkthrop has drained our souls! Avenge us!'\
 as they float out the front door.",s2);
      *(c+15) = 8;
      *(c+16) = 127;
      for(i=4;i<12;i++) {
        c = curmon[i];
        if(*(c+58) == 11) {
           *(c+36) = 1;
           *(c+18) = 1;
           *(c+26) = 7;
           *(c+27) = 7;
           *(c+15) = 8;
           *(c+16) = 1;
           }
        }
      break;
   case 3: /* go into melkthrop dungeon */
      prnt("-> %s enters the crumbling monastery!",s2);
      *(c+30) = 127;
      *(c+59) = 1;   
      break;
   case 23: /* go into kilkaney */
      prnt("-> %s enters the ancient walled city of Kilkaney!",s2);
      *(c+30) = 127;
      *(c+59) = 2;
      break;
   case 5: /* took the  bone key */
      flash();
      prnt("-> A group of scimitar brandishing skeletons bursts through \
the door the instant %s takes the bone key!",s2);
      actmon(2,6,8,3);
      untrap(2);
      pass(0);
      break;
   case 15: /* in the forge room */
      if(pc > 3)
         break;
      if( (5*(*(c+1)))%(*(c+2)) == 0)
         prnt("-> %s is being seared by the intense heat from the forges!",s2);
      damage(pc,*(c+12) + 1);
      break;
   case 4: /* fondling the tongs */
      prnt("-> The foolish act of taking the tongs causes %s to burst into \
flames!",s2);
      flash();
      blowup(x,y);
      break;
   case 11:
      if(*(c+8) == 0 || crumobj[*(c+9)][0] != 25 || *(c+10) == 0)
        break;
      if(*(c+8) != 57) {
        if(*(c+8) != *(c+45)) {      
           putaway(pc,*(c+45));
           *(c+45) = *(c+8);
           }
        remove(4,*(c+8));
        prnt("-> The %s doesn't fit into the ectoplasmic converter's slot!",
              obj[*(c+8)]);
        break;
        }
      else {
       flash();
       prnt("-> The ectoplasmic converter explodes, releasing a bewildering \
flood of strange energy!  Ethereal shrieks, moans, and laughter can be heard \
as the imprisoned souls are freed from the iesis chamber!");
       blowup(crumobj[*(c+9)][6],crumobj[*(c+9)][7]);
       flash();
       flash();
       specbuf[30] = 1;
       untrap(2);
       }
     break;
   case 20: /* black key stuff */
     if(*(c+8) == 0 || *(c+10) == 0 || crumobj[*(c+9)][0] != 1)
       break;
     if(*(c+8) != *(c+45)) {
       putaway(pc,*(c+45));
       remove(1,*(c+8));
       *(c+45) = *(c+8);
       }
     if(*(c+8) != 50) {
       prnt("-> The %s doesn't fit in the door's keyhole!",obj[*(c+8)]);
       break;
       }
     else {
      prnt("-> The black key turns and the door unlocks!  The black key \
pops back into %s's hand!",s2);
      crumobj[1][3] = 8;
      }
     break;
   case 6: /* let Bab loose */
      if(*(c+10) == 0 || *(c+8) == 0 || crumobj[*(c+9)][0] != 1)
        break;
      if(*(c+8) != *(c+45)) {
         putaway(pc,*(c+45));
         *(c+45) = *(c+8);
         }
      remove(1,*(c+8));
      if(*(c+8) != 46) {
        prnt("-> The %s doesn't fit in the door's keyhole!",obj[*(c+8)]);
        break;
        }
      if(mode) {
        prnt("-> The battle in progress distracts %s and prevents %s from \
inserting the key into the door's keyhole.",s2,s2);
        break;
        }  
      if(*(c+8) == 46) {
        destroy(1,1);
        prnt("-> The door swings wide open!");
        actmon(-1,1,12,4);
        if(*(c+4) != 81)
          prnt("-> Eirik glowers for an instant and then laughs, a rare \
thing among barbarians `You have the appearance of an orc! But then you were \
never known for your beauty.'");
        prnt("-> Eirik smiles at %s in his enigmatic way.  `By the Gods! It is \
good to see you, my old friend.  I was next on these foul creatures' dining \
list.'  He waves his massive arm in disgust toward the remains of the ghouls.",
s2);
        prnt("-> `Like a yearling deer I fell into Melkthrop's trap.  After the\
 thrall of his spell wore off I fashioned torches from the furniture, but I hav\
e need of one of your weapons, a blade.  I seek revenge for my humiliation.'");
        prnt("-> Eirik's gaze turns as cold as the dark northern winters which \
sired him, `Together, you and I, we can defeat this hellish creature Melkthrop \
and escape this pit of evil.'  A wolfish grin spreads across his face.");
        }
      break;        
   case 7:
      if(pc > 3)
        break;
      if(*(c+41) > 0) {
         if(pc == 0 || (pc > 0 && *(c+38))) 
            prnt("-> The darkness seems to retreat for a moment, but then the \
torch %s is holding goes out, as if the darkness was an evil presence!",s2);
         litetrol(x,y,0);
         *(c+41) = 0;
         *(c+42) += 1;
         break;
         }
       if( (10*(*(c+1)))%(*(c+2)) == 0) {
            prnt("-> The darkness seems to be crushing the will to live \
out of %s!",s2);
            }
       damage(pc,*(c+12) + rnd(10));
       break; 
   case 8:
       flash();
       prnt("-> A pile of useless goblin junk, primarily memorabilia from \
Goblin High's class of -234 BM, falls on top of %s!",s2);
       make(11,0,0,0,0,0,x,y,1);
       damage(pc,8);
       untrap(1);
       break;
   case 12: /* melkthrop's riddle guarding the black key */
      prnt("-> An arrogant voice roars inside %s's head `You must answer the \
following riddle! In the Dark I begin, Earth is my next, through the Abyss I \
travel, to become Thanatos, in Hell I end without life.  What am I?'",s2);
      if(pc > 3 || !getword("death")) {
        prnt("-> The rune explodes, ending %s's wretched life!",s2);
        blowup(x,y);
        }
      else {
        prnt("-> The voice mutters `OK, %s, so you got lucky this time!  \
Maybe I should get a better riddle writer.'",s2);
        untrap(3);
        }
      break;
    case 9:  /* melkthrop gets his */
      j = (pc == 0 ? *(c+7) : *(c+39));
      if(!adjac(j,*(c+24),*(c+25))) 
         break;
      if(curmon[j][58] != 16)  {
         break;
         }
      if(*(c+45) != 41 && curmon[j][52] == 0) {
         prnt("-> Melkthrop laughs `You fool! You not harm Melkthrop without \
bad sword! Now I wait! Silly spell ends soon! Then I kill!'");
         curmon[j][52] = 1;
         break;
         }
      if(specbuf[30] == 0 && *(c+45) == 41 && curmon[j][49] == 0) {
         prnt("-> Melkthrop rasps `You not be able to kill me! I have\
 special protection! Gondrath helps me! Your silly spell won't last forever! \
Then I kill you and take bad sword!'");
         curmon[j][49] = 1;
         break;
         }
      c = curmon[j];
      if( curmon[pc][45] == 41 && specbuf[30] == 1) {
        curmon[pc][34] = 1;
        if(*(c+1) > *(c+2)/2 )
           prnt("-> `Melkthrop is afraid! Melkthrop is afraid!' wails the \
demon! `Melkthrop not want to die!'");
        x = *(c+24);
        y = *(c+25);
        damage(j,*(c+2)/2 + 1 + *(c+12));
        if(*c == 0) {
         blowup(x,y);
         prnt("-> An ethereal shriek of rage is heard as Melkthrop dies, follow\
ed by the curse `Melkthrop returns for revenge on you and Leveth!'. The \
sound of the gates of Hell swinging shut can be heard, causing a shudder of \
fear in %s and Eirik! Melkthrop's body turns to vapor and vanishes!",pname);
         prnt("-> Eirik stands over the burned spot on the floor, waving the \
Onesword through the vanishing vapor, a satisfied glint in his eyes. `So be \
it to all creatures of darkness,' he growls, `I hope Crom on his high \
mountain is pleased.'");
         prnt("-> A strange hissing noise comes from the corner of the room, \
as if a door lock were being released.");
         make(12,0,0,23,0,-1,1,7,1);
         break;
         }
        prnt("-> Melkthrop shrieks in agony and disbelief as the Onesword Eirik\
 is wielding slashes the demon!  Eirik roars `How does it feel to die, spawn \
of Hell?' with savage glee as he prepares for another crushing swing."); 
        prnt("-> Melkthrop rasps `Gondrath lies! He says I would be \
invincible if I do what he says! But wait! I know that \
old meddler Leveth must cause all this! Gondrath says Leveth wants to hurt \
Melkthrop! Leveth dies next!'");
        prnt("-> Terror shows through Melkthrop's beady eyes! `Melkthrop \
gets away from you yet! Melkthrop is smart, Melkthrop is smart!' the demon \
rasps, `Your stupid spells run out soon! Then I kill you! Ha! Ha!'");
          *(c+15) = 2;
          *(c+16) = 1;
          *(c+48) = 1;
          *(c+10) = 13;
          *(c+39) = j;
          do {
             x = rnd(16);
             y = rnd(8);
             z = zline[x][y];
             } while( *z != 1 || *(z+1) != 0 || (curmon[0][24] == x && 
               curmon[0][25] == y) || *(z+2) != 0 || 
               dist(x,y,0,*(c+24),*(c+25),0) < 7);
          *(c+26) = x;
          *(c+27) = y;
          prnt("-> `Melkthrop blinks!' rasps the demon! `You ugly humans not \
catch him now!'");
       }
      break;
    case 13: /* drank the potion */
      if(*(c+54) == 1 || *(c+8) != 55)
         break;
      losespel(pc);
      flash();
      prnt("-> Suddenly %s feels completely immune to any form of sorcery!",s2);
      *(c+19) = 54;
      *(c+20) = 0;
      *(c+21) = 40 - rnd(10);
      *(c+54) = 1;
      *(c+8) = 0;
      break;
    case 16: /* the first duplicator trap */
      if(*(c+8) == 0 || crumobj[*(c+9)][0] != 32 || *(c+10) == 0)
          break;
      if(specbuf[31] != 0) {
        flash();
        if(remove(1,specbuf[31]))
           prnt("-> The %s originally on the left rune disappears! A \
sandestin is heard to say `Oh boy! Just what I always wanted! A free %s! I\
 don't think this idiot knows how to operate a duplicator rune. Melkthrop is \
going to be angry!'",
              obj[specbuf[31]],obj[specbuf[31]]);
        }
      specbuf[31] = *(c+8);
      break;
   case 17: /* the second duplicator trap */
      if(*(c+8) == 0 || crumobj[*(c+9)][0] != 32 || *(c+10) == 0)
         break;
      if(*(c+8) == 53) {
         flash();
         prnt("-> A sandestin's voice is heard to say `Old Scratch Bourbon! \
Yummm! I wish I got more donations like that!', and the bottle disappears!");
         remove(2,*(c+8));
         if(!remove(1,specbuf[31])) {
            specbuf[31] = 0;
            }
         if(specbuf[31] != 0) {
            putinto(1,specbuf[31]);
            prnt("-> A copy of the %s appears on the other rune while the \
original %s is still on this rune! The sandestin's voice can be heard \
to say, `Just search the rune for the other %s, idiot!'",obj[specbuf[31]],
obj[specbuf[31]],obj[specbuf[31]]);
            putinto(2,specbuf[31]);
            specbuf[31] = 0;
            }
         else
            prnt("-> The voice mutters `I wonder why the idiot didn't put \
anything on the other rune?'");
         }
      else {
         prnt("-> An ethereal voice is heard to say `Yuck!!  Why does this \
idiot think I like %ss?'",obj[*(c+8)]);
         }
      break;  
   case 14:
      if((*(c+8) == 41 || *(c+45) == 41) && 
         ( *(c+50) < 20 || pc == 0) ) {
         prnt("-> %s is unable to hold the immense broadsword, and it falls to \
the floor underneath %s with a loud clank!",s2,s2);
         takeout(pc,41);
         if(*(c+45) == 41)
             *(c+45) = 0;
         if(*(c+46) == 41)
             *(c+46) = 0;
         make(41,1,0,0,41,-1,*(c+24),*(c+25),1);
         drawsq(*(c+24),*(c+25));
         break;
         }
      if(*(c+48) == 0) {
         prnt("-> Eirik smiles with pleasure, `Crom! Such a blade!' He spins \
it through the air with ease as his muscles ripple. `Melkthrop will learn the \
painful truth of \
steel from this weapon!', and he looks at %s with a grim grin.",pname);
         *(c+48) = 1;
         *(c+32) = 41;
         }
      break;
    case 10: /* pass word rune */
      flash();
      prnt("-> A voice thunders inside %s%s's head with the command `Speak the \
Name of the Master of All!'",s1,s2);
      if(pc > 3 || !getword("melkthrop\0")) {
         prnt("-> %s%s's sorry career is ended by a blowtorch-like flame from \
the rune as a result of the incorrect answer.  The sandestin in charge of the \
puzzle is heard to chuckle viciously.",s1,s2);
         blowup(x,y);
         *c = 0;
         break;
         }
      untrap(2);
      prnt("-> The buzzing inside %s's head ceases with the answer!",s2);
      break;
   case 21:
      if(*(c+10) == 1 || *(c+9) != 1 || *(c+50) < 20)
        break;
      *(c+15) = 8;
      *(c+16) = 1;
      flash();
      make(20,0,0,12,0,0,6,1,1);
      prnt("-> A hidden stairway appears where the stove was located!");
      untrap(1);
      break;
   case 24:
      if(pc != 0)
         break;
      lev = specbuf[28];
      if(lev  == 0) {
         actmon(19,1,7,3);
         grflist[0] = 2;
         grflist[1] = 0;
         grflist[2] = 4;
         prnt("-> The great mage Leveth looks up at the person by his bed \
and says in a weary voice `Finally, you've arrived. I'd begun to wonder if my\
 understanding of Cuspers was failing.  Well... Hmmm! I seem to have \
forgotten. What is your name again?'");
         prnt("-> [Type Name]: ");
         instring(row,col,pname,9,0);
         usedline = hold = 0;
         prnt("-> The old man continues, `Oh, yes! %s! I see your magical \
abilities have grown considerably since we last spoke.  And you, no doubt, see \
that my difficulties have increased.'  He gestures to his feet, which appear to\
 be turning to stone.",pname);
         prnt("-> He adds `The work of my old enemy Lord Vindroble, I susp\
ect. But anyway, let us make a bargain. I shall help you find your comrade \
Eirik, but you must help me break this spell which is slowly killing me. I'm\
 sure you agree.' He pauses for a moment.");
         hold = 1;
         usedline = 8;
         prnt("-> As if in a trance %s nods affirmatively.",s2);
         prnt("-> `Good! I knew I could count on you. Go northeast of Kilkaney\
.  Search by the Bay of Wen.  There you'll find a cavern inhabited\
 by a group of vicious orcs. They have my copy of Wethwicker's All the World's\
 Spells. I need it back.'");
         prnt("-> `Lord Vindroble gave them the tome as a reward for \
performing some evil deed in his latest scheme. It alone contains the correct \
spell to halt this slow petrification of my extremities.' He gestures again \
at his feet.");
         new = 1;
prnt("-> `And, before I forget, I took the liberty of reserving a room for \
you at the Red Lion Inn. The accommodations are bad, but the food is worse! \
I gave you Leveth's room.' A sudden look of fear crosses his \
face, then he quickly chuckles.");
         prnt("-> He waves `Good luck, %s! But then you never seem to need \
luck. Come back when you have the book. Only then will this room \
reappear. And by the way, remember that machines can only see skin deep!' \
He laughs and the room spins.",
pname);
         prnt("-> As the room spins he says `But wait, did I ever tell you of \
the time that I visited Lord Vindroble in Viridistan? That was when he was \
attempting to alter the Fatelines, all part of that business with the \
Master...' He slowly fades out.");
         lev = specbuf[28] = 1;
         specbuf[25] = 1;
         specbuf[22] = 8;
         specbuf[23] = 7;
         *(c+30) = 29;
         break;
         }
     if(lev == 1) {
         prnt("-> The old man in the bed looks at %s, and his tongue plays \
across his teeth, which %s suddenly realizes are very sharp!  A hideous laugh \
bursts from him and he seizes the copy of Wethwicker's from %s's paralyzed \
hands!",s2,s2,s2);
         prnt("-> `Perfect! Perfect! Now that old fool Leveth and Lord \
Vindroble, that arrogant blond twit, haven't a hope!  As for your \
friend Eirik, he is food for Melkthrop! All part of the arrangement!' he \
hisses demonically!");
         if(*(c+4) != 81)
            prnt("-> `And masquerading as an orc won't save you either!' \
a vicious laugh roars from his open mouth, exposing a lizard-like tongue.");
         hold = 1;
         usedline = 8;
         prnt("-> `And now you die!' the creature in the bed shrieks with \
glee! %s realizes the creature is changing into a monster! `Gondrath is \
victorious, Gondrath ...'",s2);
         blowup(*(c+24),*(c+25));
         }
    break;
   case 22:
      if(pc > 3)
         break;
      i = 0;
      for(j=1;j<4;j++) {
        if(curmon[j][0] == 1) {
           i = 1;
           break;
           }
        }
      prnt("-> A eerie voice whispers inside %s's mind with the question `\
I am the opposite of order, the child of disorder, and Melkthrop has sewn \
my seed wherever he goes.  What am I?' %s tries to remember what Leveth \
said the last time they met.",s2,s2);
      if(!getword("chaos") || i == 0 ) {
        if(i == 0)
           prnt("-> The sandestin laughs evilly and says `Eirik Bloodaxe \
is not alive? A little foul play? All rules are off.'");
        flash();
        blowup(x,y);
        prnt("-> %s is killed in a hideous explosion!  And after getting al\
most all the way through the adventure!  What a pity.",s2);
        break;
        }
     untrap(2);
     prnt("-> %s is right!  But what kind of adventure would it have been \
without one last pitfall? But what's this? A note falls to the ground by \
%s",s2,s2);
     make(68,1,0,0,68,-1,x,y+1,1); 
     break;
   case 25: /* generic end up in a weird outside room situation */
     *(c+30) = crumobj[*(z+1)][3];
     outside = 0;
     fromout = 2;
     *(c+4) = *(c+7);
     break;
   case 26: /* open up the doorway to leverneckel's room */
     if(police)
        break;
     crumobj[1][3] = 30;
     break;
   case 27: /* disable entering Lev's room */
     crumobj[1][3] = 29;
     break;
   case 28: /* turn into orc or turn not into orc */
     if(*(c+10) == 0 && *(c+8) == 65) {
       if(*(c+4) == 102)
          break;
       prnt("-> Suddenly, as if it had a life of its own, the mask leaps \
to %s's face and adheres to it, resulting in %s having an uncanny resemblance \
to an orc!",s2,s2);
       if(pc != 0)
         prnt("-> %s mutters in disgust `You owe me a great favor, %s, for \
letting this magick be worked upon me!'",s2,pname);
       *(c+4) = 102;
       if(!putaway(pc,65))
         break;
       if(*(c+45) == 65)
         *(c+45) = 0;
       if(*(c+46) == 65)
         *(c+46) = 0; 
       }
     if(*(c+10) == 1) {
       if(*(c+8) != 65)
           break;
       prnt("-> The mask drops, and %s's original appearance is restored!",s2);
       *(c+4) = (pc == 0 ? 81 : 97);
       }
     break;
   case 29: /* dropped black ball */
     flag = zline[*(c+5)][*(c+6)][1];
     if(crumobj[flag][0] != 66 || dungeon == 2)
         break;
     prnt("-> The black ball explodes in a blinding flash when dropped \
in the open!");
     destroy(1,flag);
     flash();
     j = 0;
     for(i=4;i<12;i++) {
       if(curmon[i][0] == 1 && curmon[i][30] == crum) {
           curmon[i][36] = 1;
           curmon[i][15] = 8;
           j = 1;
           }
       }   
     if(j) {
       dorep();
       prnt("-> The flash sends a wave of temporary terror through the \
creatures in the room!");
       }
     break; 
   case 30:
     *c = 0;
     zline[x][y][2] = 0;
     if(pc != 0 && zline[x][y][5] > 0)
       drawsq(x,y);
     flash();   
     prnt("-> The floor opens up underneath %s%s!  With a shriek %s%s \
plummets into the abyss below, never to be seen again!  The \
trapdoor swings shut again, ready for the next unwary victim.",s1,s2,s1,s2);  
     break;
   case 31:  /* the machine god of the orcs ! */
     if(*(c+4) == 102 || !los(pc,7,2))
       break;
     prnt("-> The gigantic machine pivots swiftly and hurls a massive \
fireball at %s%s! Its metallic voice roars `Death to all that is not orc!'",
s1,s2);
     fireball(7,2,x,y,0);
     blowup(x,y);
     break;
   case 32: /* the trespassing trap */
     if(police || mode)
       break;
     j = 0;
     for(i=4;i<12;i++) {
      c = curmon[i]; 
      if(*c == 1 && *(c+30) == crum) { 
         j = 1;
         break;
         }
       }
     if(!j)
       break;
     if(!*(c+48))    
        prnt("-> The %s shrieks `Guards! Guards! A trespasser!'",name[*(c+3)]);
     if(rnd(100) < 20)
       police = 1;
     *(c+48) = 1;
     break;
   case 33:
     for(j=4;j<12;j++) {
        if(curmon[j][58] == 24 && curmon[j][0] == 1 && curmon[j][30] == crum)
           break;
        }
     if(j == 12)
       break;
     if(specbuf[39] == 1)
        break;
     specbuf[39] = 1;
     if(curmon[0][4] != 81 && !police) {
          prnt("-> The bartender shrieks `I'll not be servin' no bloody \
orc! Guards! Guards!'");
          police = 1;
          break;
          }
     if(police) {
        prnt("-> The bartender growls `You're in a bit of a pickle now, mate.'"
              );
        break;
        }
     switch(specbuf[38]) {
       case 0:
         actmon(25,3,6,4);
         prnt("-> The bartender smiles and says ` 'ello, guv'nor! If I ain't \
mistaken yer name is %s. Me name is Red Jack. Yer room is ready! \
Up the stairs and at the far left.  Sleep well!'",s2);
         specbuf[38] = 1;
         break;
       case 1:
         if(*(c+49) < 10)
           break;
         prnt("-> The bartender smiles and says `Will yer be 'avin' a wee \
drap, then?' and he pushes a large glass of potent ale toward %s.",s2);
         if(!getword("yes")) {
             prnt("-> The bartender shrugs `Suit yerself, mate.'");
             break;
             }
         prnt("-> %s accepts the ale and quaffs it down, while the bartender \
watches expectantly!",s2);
         prnt("-> The bartender grins `Pretty fine stuff, eh?' %s realizes \
it's time to pay for the ale.",s2);
         repeat:prnt("-> [How much?] ");
         instring(row,col,str,3,1);
         usedline = hold = 0;
         j = atoi(str);
         if(j > *(c+49)) {
            prnt("-> The bartender laughs `Ah, come on! You don't 'ave that \
many gold pieces!'");
            goto repeat;
            }
         if(j <= 1) {
            if(j == 1) {
              *(c+49) -= 1;
              prnt("-> The bartender sneers `Regular spendthrift, you are.'");
              }
            if(j <= 0) {
              prnt("-> The bartender roars `Like 'ell! You can just talk to \
the guards about all this! Guard! Guard!'");
              police = 1;
              j = 0;
              break;
              }
            specbuf[38] = 3;
            break;
            }
         *(c+49) -= j;
         if(j < 5 && j > 1) {
           prnt("-> The bartender accepts the money and puts it away, a \
slight look of disappointment on his face.");
           break;
           }
         prnt("-> The bartender is greatly pleased with %s's generosity!",
s2);
         specbuf[38] = 2;
         break;
       case 2:
         prnt("-> The bartender leans toward %s in a conspiratorial manner,\
 saying `By the way, there was a funny-lookin' fella in here askin' for ye.  I\
 believe 'e said 'is name was Leveth, or some such.  Looked a bit mean for\
 for my taste, 'e did.'",s2);
         prnt("-> The bartender continues `In point of fact, 'e looked like \
a thrang, 'e did. So I told 'im, shove off, mate! I watched, and 'e limped \
off toward the dump. Proper place for 'is sort, I think. Maybe the rats \
will eat 'im.'");
         prnt("-> `Ah, don't be worryin' yerself though. I didn't tell 'im \
you was 'ere or what room you 'ad.  But you best be on yer toes! I \
don't want to lose a fine customer such as yerself! Top o' the day!'");
         specbuf[38] = 3;
         break;
       case 3:
         prnt("-> The bartender smiles and says `Top o' the day, guv'nor!'");
         if(rnd(100) < 5) 
            prnt("-> The bartender continues `And it's quite a bill you've \
racked up 'ere.  Don't be walkin' out on me.");
         break;
       }
    break;
  case 34:
    specbuf[39] = 0;
    break;
  case 35:
    prnt("-> %s enters the foul-smelling cavern!",pname);
    *(c+30) = 127;
    *(c+59) = 3;
    break;
  case 36:  /* The evil key into Melkthrop's lair */
     if(*(c+10) == 0 || *(c+8) == 0 || crumobj[*(c+9)][0] != 1)
       break;
     if(*(c+8) != *(c+45)) {
       putaway(pc,*(c+45));
       remove(1,*(c+8));
       *(c+45) = *(c+8);
       }
     if(*(c+8) != 63) {
       prnt("-> The %s doesn't fit in the door's keyhole!",obj[*(c+8)]);
       break;
       }
     else {
      *(c+45) = 0;
      prnt("-> The evil key turns and the door to the monastery unlocks!  \
The evil key explodes. I don't think %s is in Kansas anymore.",s2);
      crumobj[1][3] = 1;
      }
     break;
   case 37:
     if(specbuf[20] == 1 || police || mode || monster > 0 || pc != 0)
       break;
     if(*(c+46) == 81) {
        *(c+46) = 0;
        litetrol(*(c+24),*(c+25),0);
        }
     putaway(pc,*(c+45));
     *(c+45) = 0;
     putaway(pc,*(c+46));
     *(c+46) = 0;
     specbuf[20] = 1;
     prnt("-> %s is overcome with drowsiness, falling into the bed to \
sleep.  Upon awakening, magically, %s feels completely refreshed.",s2,s2);
     flash();
     *(c+1) = *(c+41) = 0;
     *(c+14) = 6*(*(c+51));
     break;
   case 38:  /* reset sleep by leaving Kilkaney */
     if(*(c+30) != 127)
      break;
     specbuf[20] = 0;
     break;
   case 39: /* Mr. Demento's magic potion has struck */
     if(*(c+54) == 1 || *(c+8) != 69 || *(c+10) != 1)
       break;
     if(*(c+50) == 20) {
       prnt("-> %s says `Funny, I don't feel any different.'",s2);
       break;
       }
     losespel(pc);
     flash();
     prnt("-> Suddenly %s feels a tremendous burst of strength!",s2);
     *(c+19) = 50;
     *(c+20) = *(c+50);
     *(c+50) = 20;
     *(c+21) = 10;
     break;
   case 40:
     if(police)
       break;
     prnt("-> Magic use at this location is extremely illegal in \
Kilkaney!  %s is in trouble now!",s2);
     police = 1;
     break;
   case 41:
     *(c+41) = 0;
     prnt("-> The old man in the bed waves his hand and %s \
is pulled through the space between by a powerful blink spell!",s2);
     *(c+26) = 7;
     *(c+27) = 2;
     *(c+10) = 13;
     *(c+15) = 2;
     *(c+16) = 1;
     break;
   case 42:
     if(*(c+10) != 0 || *(c+8) != 70)
        break;
     if(*(c+46) == 70)
       *(c+46) = 0;
     if(*(c+45) == 70)
       *(c+45) = 0;
     prnt("-> The bag has ten gold pieces, which %s promptly pockets, \
while discarding the now empty bag!",s2);
     *(c+49) += 10;
     break;
   case 46:
     if(*(c+10) != 1 || *(c+8) != 53)
       break;
     prnt("-> %s is knocked flat by the Old Scratch Bourbon! Lying on the \
floor, eyes spinning, %s wonders if maybe Old Scratch himself didn't distill \
the stuff!",s2,s2);
     *(c+15) = 8;
     *(c+16) = 254;
     if(actmon(5,6,x,y) > 0)
       prnt("-> And, of course, a pack of irate goblins, hearing the familiar \
guzzling sound of whiskey being drunk, appear, as if by magic, beside %s! \
`The rotten human drank our whiskey!' one of them shrieks! `It's pain \
time!'",s2);
   case 45:
     if(*(c+10) != 1 || (*(c+8) != 53 && *(c+8) != 56) )
        break;
     prnt("-> %s has really bad breath now, but then the creatures in the \
abbey don't notice subtleties such as that.",s2);
     break;
   case 44:
     prnt("-> There is an incredible explosion, taking %s with it!",s2);
     blowup(x,y);
     break;
   case 43: /* the thrang leverneckel */
     if(police)
       break;
     for(i=4;i<12;i++) {
        c = curmon[i];
        if(*(c+30) == crum)
           break;
        }
     if(i == 12)
       break;
     *(c+31) = 7;
     pass(i);
     undorep();
     flag = flag2 = flag3 = 0;
     if(takeout(0,64))
       flag = 1;
     if(curmon[0][45] == 64 || curmon[0][46] == 64)
       flag = 1;
     if(flag) {
       if(rumdata[50][0] == 0) {
            prnt("-> A hideous creature stirs! Its once proud clothes \
hang in tatters. Its mouth works slowly, as if every word were painful. `Weth\
wicker's ... you have it ... must give it ... to me now.'");
            flag2 = 1;
            goto prolog;
            }
      take:prnt("-> `Please ... forgive me ... %s ... I must take ... the \
book.' The ghastly vision waves its skeletal hands and Wethwicker's All the \
World's Spells sails across the room to him in a ball of flame!",s2);
      fireball(x,y,5,4,0);
      if(curmon[0][45] == 64)
         curmon[0][45] = 0;
      if(curmon[0][46] == 64)
         curmon[0][46] = 0; 
      prnt("-> As if from centuries of experience it opens the tome and \
recites `Yog ... vradhe ... acka pranath ... ' A flame leaps from the page\
 and envelops the creature!");
      blowup(*(c+24),*(c+25));
      permon[19][4] = 121;
      actmon(19,1,5,4);
      prnt("-> Standing before %s is the real Leveth! `Well, well,' he chuckles\
, `Now, to the business of finding this horrid creature Gondrath and expunging \
it from the face of Avecta.  But first I must aid you.'",s2);
        if(curmon[0][4] != 81)
           prnt("-> Leveth adds, `And do get rid of that silly mask! It\
 isn't Halloween, you know. You are likely to upset the locals, especially \
that bartender at the Red Lion. Orcs are most unpopular in these parts.'");
      prnt("-> `Now take this key!  It will open the way to the \
dreaded lair of Melkthrop, which is in the ruins of the ancient abbey southeast\
 of Kilkaney.' He drops an odd colored key on the floor.");
       make(63,1,0,0,63,-1,4,3,1);
       prnt("-> `After it took my body, Gondrath taunted me by telling me how \
Melkthrop had lured Eirik to the abbey with Eventhal's Psychic Lure. And that \
Melkthrop was in league with him and higher forces.' Leveth shudders, `I fear \
for us all.'");
     prnt("-> `Eirik may still be alive, so hurry. The key, which I purchased \
from a renegade goblin for such an emergency, will get you in, but it will not \
get you out! What Melkthrop has done to the Abbey since inhabiting it I know \
not.'");
        prnt("-> `Beware, Melkthrop is a tricky demon!  He has great \
plans and, so Gondrath said, a strange device called an ectoplasmic converter. \
I have an idea that Melkthrop is storing energy of horrible form in it.'");
       prnt("-> Leveth chuckles, `Demons! They're so full of plots and \
schemes that they very often confuse themselves into disaster. You do remem\
ber my little escapade with that conceited demon Markrotog at the cavern called\
 the Gates of Hell? No? Oh, well.'");
       prnt("-> `But, here, take this handy little device. It's gotten me out\
 of many a dangerous situation. I call it a seekshard.' He places a \
strange-looking object on the floor beside him.");
       make(80,1,0,0,80,-1,4,4,1);
       prnt("-> `Melkthrop has been kidnapping the locals, and, it's important\
 to remember, spreading chaos. I'm afraid the appearance of this demon \
Melkthrop is all part of the pattern of trouble afflicting the entire \
continent of Avecta, in which I include Ebora.'");
       prnt("-> He continues `I hope you succeed in getting rid of this demon.\
  I'm sure we'll meet again!  But now I must go and attend to Gondrath! \
Lord Vindroble awaits me in Viridistan, and he is ever full of surprises!'");
      prnt("-> As the old man disappears he says `Oh, by the way! Did I \
ever tell you about the time that Lady Andernith and I were travelling through \
Ebora, looking for a particular gem? It was...' Mercifully, he fades out. \
%s grumbles `Leveth, always a windbag.'",s2);
      curmon[zline[5][4][2]][0] = 0;
      zline[5][4][2] = 0;
      drawsq(5,4);
      explode(5,4,0);
      untrap(3);
      break;
      }                 
   if(!flag) {
     if(rumdata[50][0] == 0) {
       prnt("-> The terrifying vision of life in death stirs slowly. Inex\
plicably, %s decides not to strike out at the horror immediately!",s2);
      flag3 = 1;
      rumdata[50][0] = 1;
      goto prolog;
      }
     moan:prnt("-> `Wethwicker's' the creature moans, `you must ... find it\
 ... please. I ... must conserve ... my strength.' And it slumps forward, as \
if in a coma.");
      curmon[0][15] = 4;
      curmon[0][16] = 1;
      curmon[0][26] = curmon[0][28] = 2;
      curmon[0][27] = curmon[0][29] = 4;
      break;
      }
prolog:prnt("-> The horrid creature's mouth works, and it utters words in \
a slow and tortured manner, `Please ... believe me ... %s ... I am not a \
thrang ... I am Leveth ... your old friend ... trapped in body ... of \
thrang.'",s2);
       prnt("-> It continues `I am fighting ... a hideous monster from Hell ...\
 It is Gondrath ... took my body ... lured you to its room ... used Eventhal's \
Psychic Lure ... made you think ... it was me ...'"); 
       prnt("-> `Gondrath wants ... Wethwicker's ... do not give it ... \
the book. You must ... believe me ... %s, ask yourself ... why did not ... the \
creature ... in the room ... know your name?'",s2);
       prnt("-> `It mimics me ... used Eventhal's Psychic Lure ... to draw you \
... like Eirik ... was drawn away ... It wants you to find ... Wethwicker's \
... for it.' %s stands transfixed by the horror of the image and the story.",
s2);
       prnt("-> `Lord Vindroble ... tried to hide ... Wethwicker's ... from \
Gondrath ... but orcs ... stole it from caravan ... took it to cavern ... \
Lord Vindroble is ... not my enemy ... at least ... not at the moment.'"); 
       prnt("-> `I came .. to inn ... you were not there ... too weak ... \
to come back ... rats chewed me ... I had to stay hidden ... conserve my \
strength.' The vile creature pauses, drawing painful breaths through ravaged \
lips.");
       prnt("-> `My only hope ... you would find me ... bring Wethwicker's \
... book has spell ... to restore my body.'");
       if(flag2)
         goto take;
       if(flag3)
         goto moan;
       break;
     }
}

