/*----------------------------*/
/* display free RAM (roughly) */
/* Terry Billany 22/6/88      */
/* written in shareware C     */
/*----------------------------*/
#include <osbind.h>
main()
{
char strng[32];
sprintf(strng,"[1][free memory: %ld][OK]",Malloc(-1L));
form_alert(1,strng);
}
