#include <gemlib.h>

#define      FAIL    -1
#define      FALSE   0
#define      TRUE    1
int          ap_id;

void main(void)
{
  char temp[80];
  if(init_appl())
  {
    sprintf(temp,"[0][ AES Version = %x.%x   ][ OK ]",_AESglobal[0]/0x100,_AESglobal[0]%0x100);
    form_alert(1,temp);
  }
}

/********************************************************************/
/* Initiates the Application                                        */
/********************************************************************/
int init_appl(void)
{
  ap_id=appl_init();
  if(ap_id==FAIL)
  {
    return(FALSE);
  }

  graf_mouse(ARROW,NULL);

  return(TRUE);
}
