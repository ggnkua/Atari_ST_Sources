#include <stdarg.h>
#include <stdio.h>
#include <mint/arch/nf_ops.h>
#include <mint/mintbind.h>
#include <mint/osbind.h>
#include <errno.h>

int nf_debug(const char *msg)
{
	struct nf_ops *nf_ops;

	if ((nf_ops = nf_init()) != NULL)
	{
		long nfid_stderr = NF_GET_ID(nf_ops, NF_ID_STDERR);
		
		if (nfid_stderr)
		{
			nf_ops->call(nfid_stderr | 0, virt_to_phys(msg));
			return 1;
		}
	}
	
	return 0;
}
