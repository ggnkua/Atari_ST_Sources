#include <stdarg.h>
#include <stdio.h>
#include <mint/arch/nf_ops.h>
#include <mint/mintbind.h>
#include <mint/osbind.h>
#include <errno.h>


long nf_shutdown(int mode)
{
	struct nf_ops *ops;
	long res = 0;

	if ((ops = nf_init()) != NULL)
	{
		long shutdown_id = NF_GET_ID(ops, NF_ID_SHUTDOWN);
		
		if (shutdown_id)
        	res = ops->call(shutdown_id | mode);
	}
	return res;
}
