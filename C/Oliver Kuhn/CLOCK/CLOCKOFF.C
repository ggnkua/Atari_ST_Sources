/************************************************/
/*                                              */
/*  Hilfsprogramm zu Clock ST                   */
/*                                              */
/*  schaltet Uhr aus                            */
/*                                              */
/*  Version vom 20.09.89                        */
/*                                              */
/*  geschrieben von Oliver Kuhn mit Turbo C     */ 
/*                                              */
/************************************************/

#include <aes.h>

typedef struct msg
{
    unsigned int  magic;
    unsigned int  apid;
    unsigned int  zero;
    unsigned long magic2;
    unsigned int  no;
    unsigned long par;
} MSG;

int ap_id;

int communicate(void)
{
	MSG msg_buf, msg_buf2;
	int acc_id, dummy;

    msg_buf.magic  = 0x2ee5;
    msg_buf.apid   = ap_id;
    msg_buf.zero   = 0;
    msg_buf.magic2 = 'ocks';
    msg_buf.no     = 1;
    msg_buf.par    = 2; /* Ausschalten */
    if((acc_id = appl_find("CLOCK   "))==-1)
    	return(1);
    if(appl_write(acc_id,16,(char *)&msg_buf)==0)
    {
        return(2);
    }
    if (evnt_multi(MU_MESAG|MU_TIMER,0,0,0,0,0,0,0,0,0,0,0,0,0,
        (int *)&msg_buf2,1000,0,&dummy,&dummy,&dummy,&dummy,&dummy,
        &dummy) == MU_MESAG)
    {
        if((msg_buf2.magic == 0x2ee5) && (msg_buf2.apid == acc_id) &&
           (msg_buf2.zero == 0) && (msg_buf2.magic2 == 'ocks') && 
           (msg_buf2.no == 1))
        {
            return(0);
        }
        else
        {
            return(3);
        }
    }
    else
    {
        return(4);
    }
}


int main()
{
	int retval;

    ap_id = appl_init();
    retval = communicate();
    appl_exit();
    return(retval);
}