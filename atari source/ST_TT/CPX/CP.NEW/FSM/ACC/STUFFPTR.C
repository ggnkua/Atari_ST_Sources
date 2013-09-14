#include "stuffptr.h"

MFORM	mfAlert, mfOther;

void
MFsave( BOOLEAN saveit, MFORM *mf )
{
	if( saveit )
	{
		*mf = *(MFORM *)(&Vdiesc->m_pos_hx);
	}
	else
	{
		*(MFORM *)(&Vdiesc->m_pos_hx) = *mf;
		Vdiesc->cur_flag = 1;
	}
}
