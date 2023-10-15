#include <stdlib.h>
#include <tos.h>
#include <aes.h>
#include "taskterm.h"

typedef struct {
	long version;
	int baud;
	int flow;
	int ucr;
	int duplex;
	int emu;
	int newline;
	char dial[14];
	char reset[14];
	char connect[14];
	int autom;
	char names[16][20];
	char numbers[16][20];
	char ftasten[10][40];
	int protokoll;
	int blklen;
	int chk;
	int multi;
	int timeout;
	long timer;
	int blen;
} PARAMETER;

long get_timer(void);

extern  BASPAG  *_BasPag;
extern  int _AccFlag,handle,was_full;

extern IOREC *ior;
extern PARAMETER para;
extern OBJECT *transfer;

extern char tbuf[1024];
#define SOH 1
#define STX 2
#define EOT 4
#define ACK 6
#define NAK 0x15
#define CAN 0x18
#define CHK -9

int retries,x,y,w,h,sbnr;
char msg[12];
int firsttime=0;

datei_senden(void)
{
int hd;

    if (fsel("*.*",tbuf,"Datei senden") == 1){
        strcpy((char *)transfer[UEBERSCH].ob_spec,"Datei senden");
/*        v_gtext(handle,640-13*8,13,"S");*/
        open_dial(1);
        if ((hd=Fopen(tbuf,0)) > 0) {
            show_msg(send_xmodem(hd));
            Fclose(hd);
        }
        open_dial(0);
    }
}

datei_empfangen(void)
{
int hd;

    if (fsel("*.*",tbuf,"Datei empfangen") == 1) {
        strcpy((char *)transfer[UEBERSCH].ob_spec,"Datei empfangen");
/*        v_gtext(handle,640-13*8,13,"E");*/
        open_dial(1);
		if ((hd=Fcreate(tbuf,0)) > 0) {
            show_msg(receive_xmodem(hd));
            Fclose(hd);
        }
        open_dial(0);
    }
}

send_ascii()
{
int c;
int hd;

    if (fsel("*.*",tbuf,"ASCII-Datei senden") == 1){
        if ((hd=Fopen(tbuf,0)) > 0) {
            while (Fread(hd,1L,&c)) {
                send(c>>8);
                if (Cconis())
                    if ((Crawcin()&255) == CAN)
                        return(-1);
            }
            Fclose(hd);
        }
    }
}

receive_xmodem(int hd)
{
char chksum;
int bnr,nbnr,i,chr,ctrl;

    retries=1;sbnr=1;
    ior->head = ior->tail = 0;
    if (para.chk == CRC) send('C');
    else send(NAK);
    do {
        ctrl=wait(para.timeout);
        switch (ctrl) {
        case SOH:
        case STX:
            if (ctrl==SOH) para.blklen=128;
            else para.blklen=1024;
            bnr=wait(2);
            if (bnr<0) {
                if(error(bnr)) return(-1);
				else {
					send(NAK);
					goto cont;
				}
			}
            nbnr=wait(2);
            if (nbnr<0) {
                if(error(nbnr)) return(-1);
				else {
					send(NAK);
					goto cont;
				}
			}
            if ((char)bnr != (char)~nbnr) {
                if(error(CHK)) return(-1);
				else {
					send(NAK);
					goto cont;
				}
            }
            chksum=0;
            for(i=0;i<para.blklen;i++) {
                chr=wait(2);
                if (chr<0) {
                    if (error(chr)) return(-1);
					else {
						send(NAK);
						goto cont;
					}
				}
                tbuf[i]=(char) chr;
                chksum += tbuf[i];
            }
            
            chr=wait(2);
            if (chr<0) {
                if(error(chr)) return(-1);
                else {
                	send(NAK);
                	goto cont;
                }
            }
            if (para.chk == CRC) {
                chr=(chr<<8)+wait(2);
                if (chr != crc(para.blklen,tbuf)) {
                    chr=CHK;
                    if (error(CHK)) return(-1);
	                else {
    	            	send(NAK);
        	        	goto cont;
            	    }
                }
                else {
                    chr=ok();
                    Fwrite(hd,(long)para.blklen,tbuf);
                }
            }
            else {
                if ((char) chr != chksum) {
                    chr=CHK;
                    if (error(CHK)) return(-1);
                    else {
                    	send(NAK);
                    	goto cont;
                    }
                }
                else {
                    chr=ok();
                    Fwrite(hd,(long)para.blklen,tbuf);
                }
            }
cont:
            break;
        case ACK:
            ok();
            chr=ACK;
            break;
        case CAN:
            return(-1);
            break;
        case NAK:
			chr=NAK;
            if (error(NAK)) return(-1);
			send(NAK);
            break;
        case EOT:
            send(ACK);
            return(0);
            break;
        case -1:
        	chr = -1;
            if (error(-1)) return(-1);
			send(NAK);
            break;
        case -2:
            if (error(-2)) return(-1);
			send(NAK);
            break;
        default:
        	chr=ctrl;
            if (error(ctrl)) return(-1);
			send(NAK);
        	break;
        }
        draw_dial(sbnr,retries,chr);
    } while(1);
}

send_xmodem(int hd)
{
int chr,i,hdr;
char bnr,chksum;

    retries=1;sbnr=bnr=1;
    if (para.blklen == 128) hdr=SOH;
    else hdr=STX;
    ior->head = ior->tail = 0;   /* buffer l”schen */
    while (1) {
        chr=wait(6*para.timeout);
        if (chr == NAK) {
            para.chk=CHKSUM;
            break;
        }
        if (chr == 'C') {
            para.chk=CRC;
            break;
        }
        if (chr < 0) 
            if (error(chr))
                return(-1);
    }
    while(Fread(hd,(long)para.blklen,tbuf) > 0) {
fehler:
        draw_dial(sbnr,retries,chr);
        send(hdr);send(bnr);send(~bnr);chksum=0;
        for(i=0;i<para.blklen;i++) {
            send(tbuf[i]);
            chksum += tbuf[i];
        }
        ior->head=ior->tail = 0;
        if (para.chk == CHKSUM) send(chksum);
        else {
            i=crc(para.blklen,tbuf);
            send(i>>8);send(i&255);
        }
        switch(chr=wait(para.timeout)) {
        case ACK:
            bnr++;sbnr++;
            retries=1;
            break;
        case NAK:
            if(error(NAK)) return(-1);
            goto fehler;
            break;
        case CAN:
            return(-1);
        case -2:
            if (error(-2)) return(-1);
            break;
        default:
            if(error(chr)) return(-1);
            goto fehler;
        }
    }
    ior->head=ior->tail;
    send(EOT);
    if (wait(2*para.timeout) != ACK) return(-1);
    return(0);
}

char *itoas(int w,int len,char *buf,int null)
{
int i;
    for(i=len-1;i>=0;i--) {
        buf[i]=(w%10)+'0';
        w /= 10;
    }
    if (!null) buf[len]=0;
    return buf;
}

int error(int err)
{
    if (err == -2){
        if(form_alert(1,"[1][šbertragung|abbrechen?][Ja|Nein]") == 1){
            send(CAN);send(CAN);send(CAN);
            return(-1);
        }
        else return(0);
    }
    else {
        if (++retries > 10) return(-1);
        ior->head = ior->tail=0;          /* clear buffer */
        return(0);
    }
}

int ok(void)
{
    ior->head = ior->tail;          /* clear buffer */
    send(ACK);
    retries=1;sbnr++;
    return(ACK);
}

int wait(int sec)
{
long timer;
int event,ret,msgbuff[8];

    timer=get_timer();
    do {
        if (ior->head != ior->tail) return(Cauxin());
        event = evnt_multi(MU_TIMER|MU_MESAG,
            0,0,0,
            0,0,0,0,0,
            0,0,0,0,0,
            msgbuff,(para.timer*20)&0xffff,(para.timer*20)>>16,
            &ret,&ret,&ret,&ret,&ret,&ret);
        if ((event & MU_MESAG) && (msgbuff[0] == AC_OPEN))
            return(-2);
        if (Cconis())
            if ((Crawcin()&255) == CAN)
            	return(-2);
    } while ((get_timer()-timer) < (sec*200));
    return(-1);
}

send(char c)
{
    Cauxout(c);
}

open_dial(int flag)
{
static int x,y,w,h;

    if ((!_AccFlag) || (para.multi==MULTINE)){
        if(flag) {
	        strcpy((char *)transfer[BLOCKNUM].ob_spec,"0001");
    	    strcpy((char *)transfer[STATUS].ob_spec,"---");
        	strcpy((char *)transfer[RETRIES].ob_spec,"0001");
            form_center(transfer,&x,&y,&w,&h);
            form_dial(0,0,0,0,0,x,y,w,h);
            objc_draw(transfer,0,8,x,y,w,h);
        }
        else form_dial(3,0,0,0,0,x,y,w,h);
    }
    else {
        if (flag) {
            wind_up(0);
            strcpy(msg,"0001 01 ---");
            v_gtext(handle,640-12*8,13,msg);
        }
        else wind_up(1);
        was_full=0;Bconout(2,7);
    }
}

draw_dial(int bnr, int ret, int st)
{
char bbb[5];

    switch(st) {
    case ACK:
        strcpy((char *)transfer[STATUS].ob_spec,"ACK");
        break;
    case NAK:
        strcpy((char *)transfer[STATUS].ob_spec,"NAK");
        break;
    case CHK:
        strcpy((char *)transfer[STATUS].ob_spec,"CHK");
        break;
    case -1:
        strcpy((char *)transfer[STATUS].ob_spec,"TIMOUT");
        break;
    default:
        strcpy((char *)transfer[STATUS].ob_spec,"???");
    }
    if ((!_AccFlag) || (para.multi==MULTINE)) {
        strcpy((char *)transfer[BLOCKNUM].ob_spec,itoas(bnr,4,bbb,0));
        strcpy((char *)transfer[RETRIES].ob_spec,itoas(ret,4,bbb,0));
        objc_draw(transfer,REDRAWTF,2,x,y,w,h);
    }
    else {
        itoas(bnr,4,msg,1);
        itoas(ret,2,&msg[5],1);
        strcpy(&msg[8],(char *)transfer[STATUS].ob_spec);
        msg[12]=0;
        v_gtext(handle,640-12*8,13,msg);
    }
}

readline(int hd,char *line)
{
char c;

    while(1) {
        if (Fread(hd,1,&c)>0) {
            if (c==13) break;
            if (c>31) *line++ = c;
            *line=0;
        }
        else return(0);     /* eof */
    }
    return(1);
}

int rwait(char *s1)
{
long timer;
int i,c;

    timer=get_timer();
    while (s1[i]) {
        if (ior->tail != ior->head) {
            c=wait(30);
            if (c == -2)
                if (error(c))
                    return(-2);
            if ((char)c == s1[i]) i++;
            else i=0;
        }
        if ((get_timer()-timer) >= (60*200)) return(-1);
    }
    return(0);
}

do_batch(void)
{
int hd,sec,hd2;
char line[80],*l;
long timer;

    if (fsel("*.TTB",tbuf,"Batch starten") == 1){
        if ((hd=Fopen(tbuf,0)) > 0) {
            while (readline(hd,line)){
                l=line;
                while (*l++ > 32);
                *(l-1)=0;
                strupr(line);
                if (!strcmp(line,"DIAL")) {
                    if (call_modem(-1,l)) break;
                    else continue;
                }
                if (!strcmp(line,"WAIT")) {
                    sec=atoi(l);
                    timer=get_timer();
                    while ((get_timer()-timer) < (sec*200))
                        evnt_timer(0,0);
                    continue;
                }
                if (!strcmp(line,"RWAIT")) {
                    if (rwait(l) == 0) continue;
                    else break;
                }
                if (!strcmp(line,"SEND")) {
                    while(*l) send(*l++);
                    send(13);
                    continue;
                }
                if (!strcmp(line,"END")) {
                    break;
                }
                if (!strcmp(line,"BAUDRATE")) {
                    continue;
                }
                if (!strcmp(line,"UPLOAD")) {
                    if (*l == 'X') {
                        para.blklen=128;
                        para.chk=CHKSUM;
                    }
                    if (*l == 'Y') {
                        para.blklen=1024;
                        para.chk=CRC;
                    }
                    while (*l++ > 32);
                    *(l-1)=0;
                    open_dial(1);
                    if ((hd2=Fopen(l,0)) > 0) {
                        send_xmodem(hd2);
                        Fclose(hd2);
                    }
                    open_dial(0);
                }   
                if (!strcmp(line,"DOWNLOAD")) {
                    if (*l == 'X') {
                        para.blklen=128;
                        para.chk=CHKSUM;
                    }
                    if (*l == 'Y') {
                        para.blklen=1024;
                        para.chk=CRC;
                    }
                    while (*l++ > 32);
                    *(l-1)=0;
                    open_dial(1);
                    if ((hd2=Fcreate(l,0)) > 0) {
                        receive_xmodem(hd2);
                        Fclose(hd2);
                    }
                    open_dial(0);
                }   
            }
            Fclose(hd);
        }
    }
}

show_msg(int stat)
{
	if ((_AccFlag) && (para.multi == MULTIJA)) {
		if (!stat)
			v_gtext(handle,640-12*8,13,"COMPLETED   ");
		else
			v_gtext(handle,640-12*8,13,"CANCELED    ");
	}
}

