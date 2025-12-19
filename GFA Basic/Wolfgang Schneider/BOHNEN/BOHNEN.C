#define spieler	1
#define gegner	0
#define pruefe(a,b,c)	((*(c+b+7*a))?1:0)

char  cdecl  zug(long tiefe,char *feld);
char  wertaus (char tiefe,char wer, char nr, char *feld, char max,
				char min, char again1);
char  nehme(char wer,char nr,char *feld);
void  kopier(char *feld1,char *feld2);
char  nimmalle(char wer,char *feld);

char  cdecl zug(long tiefe,char *feld)
{
register char nr,besterwert=-100,besterzug=5,aktwert=-100,max=-100,min=100;
char kopie[14];

for(nr=5;nr>=0;nr--){
if(pruefe(spieler,nr,feld)){
	kopier(kopie,feld);
	aktwert=wertaus(tiefe,gegner,nr,kopie,max,min,0);
	if(aktwert>besterwert){
		max=besterwert=aktwert;
		besterzug=nr;	
	}
}
}

return(besterzug);
}				

char  wertaus(char tiefe, register char wer,char wo,char *feld, register char max, register char min,char again1)
{
register char besterwert,nr,aktwert,again;
char kopie[14];
if(tiefe<0){
return(*(feld+13)-*(feld+6));
}else{
again=nehme(1-wer,wo,feld);
if(again)wer=1-wer;
tiefe--;
besterwert=((wer==gegner)?100:-100);
for(nr=5;nr>=0;nr--){
if(pruefe(wer,nr,feld)){
	kopier(kopie,feld);
	aktwert=wertaus(tiefe,1-wer,nr,kopie,max,min,again);
	if(wer==gegner){
	if(aktwert<besterwert)
	besterwert=min=aktwert;
	}else{
	if(aktwert>besterwert)besterwert=max=aktwert;
	}
	if((max>=min)&& !again1)nr=-1;
	}
	}
	if((besterwert==100)||(besterwert==-100))
	besterwert=nimmalle(1-wer,feld);
	return(besterwert);
	}
}

char  nimmalle(register char wer,char *feld)
{
register char nr,erg=0;
for(nr=5;nr>=0;nr--)
erg+=*(feld+nr)+*(feld+7+nr);
*(feld+7*wer+6)+=erg;
return((*(feld+13)-*(feld+6)));
}

char  nehme(char wer,char welchesfeld,char *feld)
{
register char *wo,anzahl;
wo=feld+7*wer+welchesfeld;
anzahl=*wo;
*wo=0;
do{
wo++;
if(wo==feld+6+7*(1-wer))wo++;
if(wo>=feld+14)wo-=14;
(*wo)++;
}while((--anzahl)!=0);
if((wo>=feld+wer*7)&&(wo<=feld+wer*7+5)&&(*wo==1)){
*wo=0;
wo=feld+12-(wo-feld);
*(feld+6+7*wer)+=1+*wo;
*wo=0;

}
return((wo==(feld+6+7*wer))?1:0);
}

void  kopier(register char *feld1,register char *feld2)
{
 register char nr;
for(nr=0;nr<14;nr++)*(feld1++)=*(feld2++);
}
