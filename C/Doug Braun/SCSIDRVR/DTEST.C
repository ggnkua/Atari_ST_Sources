#include "driver.h"

struct reqhdr req;
main()
{
    strat((struct reqhdr far *)&req);
	intr();
}
