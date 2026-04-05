#include <stdarg.h>
#include <stdio.h>
#include <mint/arch/nf_ops.h>
#include <mint/mintbind.h>
#include <mint/osbind.h>
#include <sys/types.h>
#include <errno.h>

const char *nf_get_name(char *buf, size_t bufsize)
{
	const char *ret = NULL;
	struct nf_ops *nf_ops;
	
	if ((nf_ops = nf_init()) != NULL)
	{
		long nfid_name = NF_GET_ID(nf_ops, NF_ID_NAME);
			
		if (nfid_name)
			if (nf_ops->call(nfid_name | 0, (__uint32_t)virt_to_phys(buf), (__uint32_t)bufsize) != 0)
			{
				ret = buf;
			}
	}
        
	return ret;
}


const char *nf_get_fullname(char *buf, size_t bufsize)
{
	const char *ret = NULL;
	struct nf_ops *nf_ops;
	
	if ((nf_ops = nf_init()) != NULL)
	{
		long nfid_name = NF_GET_ID(nf_ops, NF_ID_NAME);
			
		if (nfid_name)
			if (nf_ops->call(nfid_name | 1, (__uint32_t)virt_to_phys(buf), (__uint32_t)bufsize) != 0)
			{
				ret = buf;
			}
	}
        
	return ret;
}
