/********************************************************************/
/* 				Bus error access checking							*/
/*																	*/
/*------------------------------------------------------------------*/
/*	Status : 17.10.91												*/
/*																	*/
/*  WA - Matrix Daten Systeme, Talstr. 16, W-7155 Oppenweiler		*/
/*																	*/
/********************************************************************/

# define WR 0x01
# define RD 0x02

extern int  access_check (void *address, int dir, int wrdata);
extern bool rd_acc_check (void *address);
extern bool wr_acc_check (void *address, int wrdata);
