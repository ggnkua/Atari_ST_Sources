#include <basepage.h>
#include <osbind.h>
#include <stdio.h>

typedef struct {
	short *contrl;
	short *intin;
	short *ptsin;
	short *intout;
	short *ptsout;
}VDIPB;

void link_in(void);

char data[100];
char still = 1;

void sendstring(char *s) {
	while(*s) {
		Cauxout(*(s++));
	};
}

void main(void) {
	Supexec(link_in);
	
	printf("TrackVDI installed.\n");
	
	sprintf(data,"\r\n\r\nTrackVDI started.\r\n\r\n");
	sendstring(data);
	
	Ptermres((long)_base->p_dbase + _base->p_dlen - (long)_base->p_lowtpa,0);
}

void h_vdi_call(VDIPB *vdipb,short mode) {
	if(still) {
		sprintf(data,"0x%x xgemdos call %d\r\n",mode,vdipb->contrl[0]);
		sendstring(data);
		
		if(vdipb->contrl[0] == 1) {
			int i;
		
			for(i = 0; i < 11; i++) {
				sprintf(data,"work_in[%d]=%d\r\n",i,vdipb->intin[i]);
				sendstring(data);
			};
		
			sprintf(data,"handle=%d\r\n",vdipb->contrl[6]);
			sendstring(data);
			
			still = 0;
		};
	};
}
