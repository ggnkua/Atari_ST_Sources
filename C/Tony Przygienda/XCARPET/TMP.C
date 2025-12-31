#include "tos.h"

void main(void)
{
static int cols[]={ 0x000,0x777,0x700,0x070,0x007,-1};
register short i=0;

do
    {
    Setcolor(i,cols[i]);   
    }
while (cols[i++]!=-1);
}




