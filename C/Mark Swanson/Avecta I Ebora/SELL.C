
extern int sell(npc)
int npc;
{
extern char rumdata[][157],*obj[],curmon[][60],selllist[][4],pname[];
extern char invtrig[],invnpc[][20];
extern int row,col,hold,usedline,crum,police;
int done = 0,num = 1,i = rumdata[crum][27],j,amount;
char *c = curmon[npc],*h = curmon[0],str[6],temp[3];
rumdata[crum][26] = 0;
*(c+39) = 0;
*(c+32) = 6;
for(j=4;j<12;j++) {
  if(curmon[j][0] && curmon[j][30] == crum && curmon[j][31] < 4)
       num++;
   }
sprintf(temp,"%d",selllist[i][2] + 5);
if(num == 1 && (selllist[i][3] == -1 || police) )  {
  prnt("-> The merchant shrieks `Is there no end to this lunatic! Help! \
Guards!'");
  police = 1;
  *(c+15) = 8;
  *(c+16) = 80;
  *(c+6) = *(c+8) = 1;
  *(c+5) = 2;
  return(1);
  }
if(selllist[i][3] == 1 && adjac(npc,*(h+24),*(h+25)) ) {
  prnt("-> The merchant gestures impatiently and says `Come now, you've \
had plenty of time to make up your mind.  What do you say?  Yes or no?'");
  *(c+8) = 0;
  *(c+6) = 1;
  }
if(num > 1) {
  prnt("-> The merchant shouts `Kill the ruffian!'");
  *(c+15) = 8;
  *(c+16) = 75;
  return(1);
  }
if( *(c+7) || !adjac(npc,*(h+24),*(h+25)) ) {
  if(!setmove(npc,1)) 
     pass(npc);
  return(1);
  }
if(invnpc[0][0] > 9) {
  prnt("-> The merchant laughs `How can you carry anything more? Your bag is\
 completely full! Why don't you drop something?'");
  pass(npc);
  return(1);
  }
if(!*(c+5) && !*(c+8) && *(h+49) < selllist[i][1]) {
   prnt("-> The merchant looks down his long nose at %s and sniffs `I believe \
the merchandise I handle is currently outside of your financial purview.  I \
suggest you leave and go to a cheaper business.'",pname);
   *(c+6) = 1;
   *(c+8) = 1;
   pass(npc);
   return(1);
   }
if(selllist[i][3] == 2)
  prnt("-> The merchant smiles at %s warmly and coos `Ahhh! My good friend! \
Evidently you wish to purchase something more!'",pname);
if(*(c+6) == 0) {
  curmon[0][15] = 8; 
  prnt("-> The merchant says `Are you interested in buying one of my \
exceptional %ss?  They are a mere %s goldpieces!  Yes or no?'",
     obj[selllist[i][0]],temp);
  }
if(*(c+8) || !getword("yes")) {
  *(c+5) += 1;
  if(*(c+5) > 2) {
     prnt("-> The merchant howls `Guards! Guards! There's a thief in my store!'\
  A general clamor can be heard on the street as the cries for help are \
passed on by the local residents.");
     selllist[i][3] = -1;
     *(c+7) = 1;
     police = 1;
     return(1);
     }
  if(*(c+5) > 1) {
    *(c+6) = 1; 
    prnt("-> The merchant snarls `Get out of my store, you deadbeat, or\
 I'll call the guards!'  He stands glowering at %s.",&pname[0]);
    }
  else 
     prnt("-> The merchant responds `Very well.  Browse for a while.  But \
I haven't got all day.'");
  selllist[i][3] = 1;
  *(c+15) = 8;
  *(c+16) = 30;
  }
else {
  prnt("-> The merchant smiles and burbles `What excellent taste you have! \
How many gold pieces do you offer for my %s?'",obj[selllist[i][0]]);
  while( !done ) {
     prnt("-> [Input your offer]: ");
     instring(row,col,str,4);
     hold = usedline = 0;
     amount = atoi(str);
     if(amount <= 0 || amount > *(h+49)) {
       if(amount <= 0)
         prnt("-> The merchant snarls `You are deranged!'");
       else
         prnt("-> The merchant growls `From the look of your pouch I don't \
think you have that many goldpieces!'");
       *(c+6) = *(c+8) = 1;
       *(c+5) = 1;
       done = 1;
       selllist[i][3] = 1;
       pass(npc);
       break;
       }
     if(amount < *(c+9)) {
        prnt("-> The merchant shrugs `I can see you are not interested in \
bargaining in good faith!'");
        pass(npc);
        done = 1;
        selllist[i][3] = 1;
        *(c+8) = 1;
        *(c+6) = 1;
        continue;
        }
     if(amount < selllist[i][1]) {
        sprintf(temp,"%d",selllist[i][2]);
        prnt("-> The merchant shrieks `Such an insult!  How am I to feed my \
family with a pitiful pittance such as that!  How about %s goldpieces?'",temp);
        *(c+9) = amount;
        continue;
        }  
     if(amount < selllist[i][2] - *(c+10) &&
        amount < selllist[i][1] + selllist[i][2] - amount ) {
        prnt("-> The merchant moans woefully");
        j = rnd(8);
        while( j == *(c+32)) {
             j = rnd(8);
             }  
        *(c+32) = j;
        switch(j) {
          case 0:
            prnt("`Ahh! By the gods! Such a hard trader!'");
            break;
          case 1:
            prnt("`Are you heartless? I'm old and ill!'");
            break;
          case 2:
            prnt("`Think of my poor wife and children!'");
            break;
          case 3:
            prnt("`Mercy! My family lives in a hovel!'");
            break;
          case 4:
            prnt("'Upon my poor sweet mother's grave!'");
            break;
          case 5:
            prnt("`Aiiee!! For all the love of Zandru!'");
            break;
          case 6:
            prnt("`A demon would be easier to sell to!'");
            break;
          case 7:
            prnt("`Did Fat Oskar send you to ruin me?'");
            break;
          }
        *(c+9) = amount;
        j = selllist[i][2] - amount + selllist[i][1];
        sprintf(temp,"%d",j);
        prnt("and keens ` %s goldpieces and no lower!'",temp);
        *(c+10) = selllist[i][2] - j;
        continue;
        }
     prnt("-> The merchant throws up his hands and wails `I must accept this \
offer!  It is done!'  He fetches the %s from the locked case and gives \
it to %s.",
          obj[selllist[i][0]],pname);
     *(h+49) -= amount;
     selllist[i][3] = 2;
     done = 1;
     *(c+15) = 8;
     *(c+16) = 100;
     *(c+6) = *(c+7) = *(c+8) = *(c+9) = *(c+10) = 0;
     if(selllist[i][0] == 45) {
       prnt("-> The merchant adds `Please accept these thirty fine arrows \
as well.' Of course, %s takes them gladly.",pname);
       curmon[0][44] += 30;
       }
     if(selllist[i][0] == 69) 
        invtrap(69);
     if(selllist[i][0] != 81) 
       putaway(0,selllist[i][0]);
     else {
       for(j=0;j<4;j++) {
         c = curmon[i];
         *(c+42) = ( *(c+42) + 30 > 40 ? 40 : *(c+42) + 30);
         }
       }
     }
  }
return(1);
}

extern int wander(npc)
int npc;
{
extern char curmon[][60],crumobj[][9];
char *c = curmon[npc],*o;
int i,j,k,l,x = crumobj[*(c+48)][6],y = crumobj[*(c+48)][7];
int ex = crumobj[*(c+48)][3];
if(*(c+48) != 0 && adjac(npc,x,y) && ex != 0 && ex != 8) {
  *(c+15) = 9;
  *(c+16) = 4;
  *(c+10) = ex;
  *(c+9) = *(c+48);
  return(1);
  }
if(*(c+48) == 0 || !los(npc,x,y) || ex == 8) {
     l = 0;
     do {
        l++;
        if(l == 100) 
          break;
        k = 1 + rnd(13);
        o = crumobj[k];
        j = *(o+3);
        if(*o == 0 || j == 0 || j == 15 || j == 16 || j == 13 || j == 8 
           || j == 20 || j == 21 || j == 19 || j == 23 || j == 25 || j == 4
           || j == 5 || *(o+5) == -2 || adjac(npc,*(o+6),*(o+7)) )
          continue;
        x = *(o+6);
        y = *(o+7);
        *(c+48) = k;
        break;
        } while (1);
     if(l == 100 || !lom(npc,x,y)) { /* no exits that are not original exit */
       *(c+48) = 0;
       i = 1 - rnd(3);
       j = 1 - rnd(3);
       *(c+26) = *(c+24) + i;
       *(c+27) = *(c+25) + j;
       if(!i4(npc)) {
         *(c+48) = 0;
         pass(npc);
         }
       return(1);
       }
     }
*(c+26) = x;
*(c+27) = y;
if(!i4(npc)) {
  *(c+48) = 0;
  pass(npc);
  }
return(1);
}
