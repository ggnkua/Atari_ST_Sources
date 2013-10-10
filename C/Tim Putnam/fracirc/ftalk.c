/* FracTALK source, started 19/3/98 */
#include "header.h"

int initftalk()
{
uint32 cip;
CIB *cb2;
char temps[2048];

if(ftalk.stat){form_alert(1,"[1][FracTALK connection|already in use][Right]");return 0;}
ftalk.cna=TCP_open(0L,0,0,4096);
if(ftalk.cna<0){form_alert(1,"[1][FracTALK Error:|Can't create socket][Okay]");ftalk.cna=0;return 0;}
ftalk.cnb=TCP_open(0L,0,0,4096);
if(ftalk.cnb<0){form_alert(1,"[1][FracTALK Error:|Can't create socket][Okay]");ftalk.cnb=0;return 0;}
cb=CNgetinfo(cn[wn[cwin].cnn].cn);
cip=stik_cfg->client_ip;
if(cip==0 || cip==0x7F000001)
cip=cb->lhost;
cb=CNgetinfo(ftalk.cna);
cb2=CNgetinfo(ftalk.cnb);
sprintf(temps,":%s PRIVMSG %s :\001FRACTALK %lu %u %u\001\r",cn[wn[cwin].cnn].nick,ftalk.avec,cip,cb->lport,cb2->lport);
ftalk.rip=cip;
ftalk.rporta=cb->lport;
ftalk.rportb=cb2->lport;
srt(temps,cn[wn[cwin].cnn].cn);
ftalk.stat=SAWAIT;
return 0;
}

void closeft(void)
{
if(!ftalk.stat){form_alert(1,"[1][FracTALK connection|not in use][Okay]");return;}
TCP_close(ftalk.cna,0);
TCP_close(ftalk.cnb,0);
ftalk.cna=-1;
ftalk.cnb=-1;
ftalk.stat=0;
strcpy(ftalk.avec,"\0");
ftalk.rip=0;
ftalk.rporta=0;
ftalk.rportb=0;
}

/* Remember! ftalk.cn is send and ftalk.cn[1] is receive channel */

void processftalk(void)
{
int16 tstata,tstatb;
if(ftalk.stat){
tstata=CNbyte_count(ftalk.cna);
tstatb=CNbyte_count(ftalk.cnb);
if(ftalk.stat==SAWAIT && tstata>=E_NODATA && tstatb>=E_NODATA){
ftalk.stat=SACTIVE;
doftalk();
}
/* Be aware that one channel might drop before another.. may need to handle this or may not */
if(ftalk.stat==SACTIVE && tstata<E_NODATA && tstatb<E_NODATA){
form_alert(1,"[1][FracTALK connection|has been lost][Okay]");
closeft();
return;
}
}
}