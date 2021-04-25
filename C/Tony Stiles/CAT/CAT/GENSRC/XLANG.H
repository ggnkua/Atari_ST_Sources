#ifndef GOT_LANG
#define GOT_LANG 1

#include <stdio.h>

#ifndef FALSE
#define FALSE 0
#endif

#ifndef TRUE
#define TRUE 1
#endif

#ifndef BOOLEAN
#define BOOLEAN int
#endif

#define ALWAYS TRUE

#define AND &&
#define OR ||
#define NOT !
#define NE !=
#define EQ ==
#define LE <=
#define LT <
#define GE >=
#define GT >

#define DARK TRUE
#define LIGHT FALSE

#define NEED_LIGHT TRUE
#define NO_LIGHT FALSE

#define VC_NO_CHECK 1
#define VC_HERE 2
#define VC_CARRIED_NOT_WORN 3
#define VC_WORN 4
#define VC_AVAIL 5
#define VC_AVAIL_NOT_WORN 6
#define VC_CARRIED 7
#define VC_NOT_CARRIED 8
#define VC_EXIST 9

#define NON_EDIBLE 32767
#define NON_DRINKABLE 32767
#define NON_MOVABLE 32767
#define NON_READABLE 32767
#define NO_KEY 32767
#define CARRIED 32767
#define NO_SCORE 32767

#define HIDDEN 1
#define NOT_HIDDEN 2

#define PLAYER 1
#define NON_PLAYER 2
#define COMMANDABLE 1
#define NO_COMMANDS 2
#define ACTIVE 1
#define NON_ACTIVE 2

#define WEARABLE 1
#define WORN 2
#define NON_WEARABLE 3

#define VISITED 1
#define NOT_VISITED 2

#define LIGHT_SOURCE 1
#define NON_LIGHT_SOURCE 2
#define LIT 3

#define LOCKED 1
#define CLOSED 2
#define OPEN 3
#define NO_LOCK 4

#define LONG 1
#define SHORT 2

#define LOOK look(LONG)
#define TOROOM(x,y) {wgt_c=((odet[y][2]!=x)||(wgt_c)); odet[y][2]=x;}
#define GOTO(x) {TOROOM(x,PLAYER_); look(SHORT);}
#define INVENTORY inventory()
#define CONTROL(x) player=x
#define BECOME(x) {CONTROL(x); cplr=x;}
#define REMOVE(x) odet[x][5]=WEARABLE
#define WEAR(x) odet[x][5]=WORN
#define DROP(x) {TOROOM(OBJRM(PLAYER_),x);}
#define GET(x) {TOROOM(OBJINRM(PLAYER_),x); if (ISWORN(x)) REMOVE(x);}
#define EAT(x) ADDSTRENGTH(PLAYER_,odet[x][6])
#define DRINK(x) ADDSTRENGTH(PLAYER_,odet[x][18])
#define LIGHT_(x) odet[x][9]=LIT
#define UNLIGHT(x) odet[x][9]=LIGHT_SOURCE
#define LOCK(x) odet[x][8]=LOCKED
#define UNLOCK(x) odet[x][8]=CLOSED
#define OPEN_(x) odet[x][8]=OPEN
#define CLOSE(x) odet[x][8]=CLOSED
#define ENTER(x) enter(x)
#define SWAP(x,y) swap(x,y)
#define SCRIPT {if (!script){sscript();} script=TRUE;}
#define VERBOSE verbose=TRUE
#define UNSCRIPT {if (script){escript();} script=FALSE;}
#define BRIEF verbose=FALSE
#define CONFIRM yesno()
#define NEWLINE newline(FALSE)
#define LF newline(FALSE)
#define STOP {actor[0]='\0'; player=cplr; return FALSE;}
#define CONT return TRUE
#define ENDGAME {dead=TRUE; PMSG(M_SCORED); PNUM(SCORE); PMSG(M_IN); PNUM(TURNS); PMSG(M_TURNS); NEWLINE; NEWLINE; return FALSE;}
#define RAMSAVE save(FALSE,TRUE)
#define SAVE save(TRUE,FALSE)
#define RAMLOAD {load(FALSE,TRUE); WHOAMI; LOOK;}
#define LOAD {load(TRUE,FALSE); WHOAMI; LOOK;}
#define WAITKEY {PMSG(M_PRESS_A_KEY); waitkey();}
#define WHOAMI {PMSG(M_YOU_ARE); ENDCHAR('.'); POBJS(PLAYER_);}
#define VOCAB vocab()
#define PAUSE(x) pause(x)
#define RANDOM_(x) catrand(x)
#define FVERB(x) {vt=x; xvn=verb_no(vt);}
#define SETCOUNT(x,y) cnt[x]=y
#define ADDCOUNT(x,y) cnt[x]+=y
#define SUBCOUNT(x,y) cnt[x]-=y
#define SETPOINTS(x,y) odet[x][11]= y
#define ADDPOINTS(x,y) odet[x][11]+=y
#define SUBPOINTS(x,y) odet[x][11]-=y
#define SETSCORE(x) score=x
#define ADDSCORE(x) score+=x
#define SUBSCORE(x) score-=x
#define HIDE(x) odet[x][17]=HIDDEN
#define UNHIDE(x) odet[x][17]=NOT_HIDDEN
#define SETSTRENGTH(x,y) odet[x][7]=  y
#define ADDSTRENGTH(x,y) odet[x][7]+= y
#define SUBSTRENGTH(x,y) odet[x][7]-= y
#define SETVALUE(x,y) odet[x][1]=  y
#define ADDVALUE(x,y) odet[x][1]+= y
#define SUBVALUE(x,y) odet[x][1]-= y
#define SETWEIGHT(x,y) {odet[x][0]= y; wgt_c=TRUE;}
#define ADDWEIGHT(x,y) {odet[x][0]+=y; wgt_c=TRUE;}
#define SUBWEIGHT(x,y) {odet[x][0]-=y; wgt_c=TRUE;}
#define MAKELIGHT(x) rmd[x][0]=LIGHT
#define MAKEDARK(x) rmd[x][0]=DARK
#define PLAYER_ (player)
#define CPLAYER (cplr)
#define THISROOM (odet[player][2])
#define TURNS (turns)
#define SCORE (score)
#define CARRIED_WEIGHT(x) (odet[x][13])
#define STRENGTH(x) (odet[x][7])
#define POINTS(x) (odet[x][11])
#define OBJRM(x) (odet[x][2])
#define OBJINRM(x) (odet[x][3])
#define FIRSTOB(x) (firstob(x))
#define LASTOB(x) (lastob(x))
#define THISOBJ (xnn)
#define THISCVERB (verb_no(prepv))
#define THISCOBJ (noun_no(prepo))
#define THISVERB (xvn)
#define VERBPATH(x) (verbpath(x))
#define VALUE(x) (odet[x][1])
#define OBJKEY(x) (odet[x][12])
#define LOCKTYPE(x) (odet[x][8])
#define WEIGHT(x) (odet[x][0]+odet[x][13])
#define SIZE(x) (odet[x][0])
#define COUNT(x) (cnt[x])

#define ISCOMPOUND (strlen(prepv)!=0)
#define NOUNIS(x) (noun_no(x)==xnn))
#define NOUNNOIS(x) (x==xnn)
#define VERBIS(x) (verb_no(x)==xvn)
#define VERBNOIS(x) (x==xvn)
#define CNOUNIS(x) (noun_no(x)==noun_no(prepo))
#define CNOUNNOIS(x) (x==noun_no(prepo))
#define CVERBIS(x) (verb_no(x)==verb_no(prepv))
#define CVERBNOIS(x) (x==verb_no(prepv))
#define PLAYERIS(x) (player==x)
#define CPLAYERIS(x) (cplr==x)
#define OBJHASL(x) (strcmp(" ",olng[x])!=0)
#define CHECK(x,l,y) (check(x,l,y))
#define ROOMIS(x) (odet[player][2]==x)
#define ROOMNO(x) (x)
#define MSGNO(x) (x)
#define OBJNO(x) (x)
#define STRNO(x) (x)
#define OBJROOMIS(x,y) (odet[y][2]==x)
#define ISIN(x,y) (odet[x][2]==odet[y][3])
#define ISWITH(x,y) (odet[x][2]==odet[y][2])
#define ISEXIT(x) ((odet[x][14]!=R_NOWHERE)||(odet[x][15]!=R_NOWHERE)||(odet[x][16]!=R_NOWHERE))
#define ISREADABLE(x) (odet[x][10]!=NON_READABLE)
#define ISPATH(x) ispath(x)
#define ISHIDDEN(x) (odet[x][17]==HIDDEN)
#define ISWORN(x) ((odet[x][5]==WORN)&&(ISCARRIED(x)))
#define ISWORNBY(x,y) ((odet[x][5]==WORN)&&(odet[x][2]==odet[y][3]))
#define ISWORNANY(x) ((odet[x][5]==WORN))
#define ISWEARABLE(x) (odet[x][5]!=NON_WEARABLE)
#define ISHERE(x) ((odet[x][2]==odet[player][2])&&(x!=player)&&(odet[x][5]!=WORN))
#define ISCARRIED(x) (odet[x][2]==odet[player][3])
#define ISCARRIEDBY(x,y) (odet[x][2]==odet[y][3])
#define ISAVAIL(x) ((ISHERE(x))||(ISCARRIED(x)))
#define ISPLAYER(x) ((odet[x][4]==PLAYER)&&(odet[x][20]==ACTIVE))
#define ADDPLAYER(x) {odet[x][4]=PLAYER; odet[x][19]=COMMANDABLE; odet[x][20]=ACTIVE;}
#define REMOVEPLAYER(x) odet[x][4]=NON_PLAYER
#define ISCOMMANDABLE(x) ((odet[x][19]==COMMANDABLE)&&(odet[x][20]==ACTIVE))
#define ADDCOMMAND(x) {odet[x][19]=COMMANDABLE; odet[x][20]=ACTIVE;}
#define REMOVECOMMAND(x) odet[x][19]=NO_COMMANDS
#define ISACTIVE(x) (odet[x][20]==ACTIVE)
#define REVIVE(x) odet[x][20]=ACTIVE
#define KILL(x) odet[x][20]=NON_ACTIVE
#define ISEDIBLE(x) (odet[x][6]!=NON_EDIBLE)
#define ISDRINKABLE(x) (odet[x][18]!=NON_DRINKABLE)
#define ISLIGHT(x) (odet[x][9]!=NON_LIGHT_SOURCE)
#define ISLIT(x) (odet[x][9]==LIT)
#define ISMOVABLE(x) (odet[x][0]!=NON_MOVABLE)
#define ISDARK (isdark(odet[player][2],TRUE))
#define ISLOCKED(x) (odet[x][8]==LOCKED)
#define ISCLOSED(x) (odet[x][8]==CLOSED)
#define ISOPEN(x) (odet[x][8]==OPEN)
#define ISBOX(x) ((!ISACTIVE(x)) && (OBJINRM(x)!=R_NOWHERE))
#define PROOMS(x) prt_text(rms[x])
#define PROOML(x) prt_text(rml[x])
#define POBJS(x) prt_text(osht[x])
#define POBJL(x) prt_text(olng[x])
#define PMSG(x) prt_text(msg[x])
#define PEXITS pexits()
#define PCONTENTS(x) pcontents(x)
#define READ(x) prt_text(msg[odet[x][10]])
#define PNUM(x) sprintf(pc, "%d", x); prt_text(pc)
#define PVAL(x) sprintf(pc, "%d", x); prt_text(pc)
#define PSTR(x) prt_text(strp[x]);
#define GETSTR(x,len,sep) get_input(strp[x],len,sep);
#define STRCAT(x,y) strcat(strp[x],strp[y]);
#define STRCLR(x) strcpy(strp[x],"");
#define STRUPP(x) upper(strp[x]);
#define STRLOW(x) lower(strp[x]);
#define STRCPY(x,y) strcpy(strp[x],strp[y]);
#define MSGTOSTR(m,s) strcpy(strp[s],msg[m]);
#define OSTOSTR(o,s) strcpy(strp[s],osht[o]);
#define OLTOSTR(o,s) strcpy(strp[s],olng[o]);
#define RSTOSTR(r,s) strcpy(strp[s],rms[r]);
#define RLTOSTR(r,s) strcpy(strp[s],rml[r]);
#define STRPCPY(x,y,s,l) {strncpy(strp[x],strp[y]+s,l); strp[x][l]='\0';}
#define STRADDC(s,c) {strp[s][strlen(strp[s])+1]='\0'; strp[s][strlen(strp[s])]=c;}
#define STRLEN(x) (strlen(strp[x]))
#define STRFSTR(s1,s2) (strfstr(strp[s1],strp[s2]))
#define STRFCHR(s,c) (strfchr(strp[s],c))
#define NUMTOSTR(n,s) {sprintf(strp[s], "%d", n);}
#define STRASC(s) (strp[s][0])
#define STRCAP(s) {strp[s][0]=toupper(strp[s][0]);}
#define STRCMP(s1,s2) (strcmp(strp[s1],strp[s2]))
#define STRNUM(s) (atoi(strp[s]))
#define ROOMSEEN(r) (rmd[r][1]==VISITED) 
#define ENDCHAR(x) endchar(x)

#endif
