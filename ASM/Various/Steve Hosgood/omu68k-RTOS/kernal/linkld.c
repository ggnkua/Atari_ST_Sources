/*******************************************************************************
 *	Linkld.c	Loads and links the given file to the give address
 *******************************************************************************
 *
 *	Given a object file which has been linked and still has relocation
 *	info in it, linkld() reads in the file to the given address and
 *	Links it to run at this address.
 */

# include	<a.out.h>
# include	"../include/file.h"

struct	nnlist {
	char	n_type;
	char	null;
	unsigned n_value;
	char	n_name[8];
};

extern char	*malloc();

/*
 *	Linkld()	Loads and links the given file to the given address
 */
linkld(file, startadd)
struct	file *file;
long	startadd;
{
	struct	reloc rel;
	struct	bhdr head;
	register int	r, d;
	register long	offset;
	register char	*address;

	/* Get header info from file */
	if(f_read(file, &head, sizeof(struct bhdr)) != sizeof(struct bhdr)){
		return -1;
	}

	if(!head.rtsize){
		printf("Kernal: Linkld: No reloaction info\n");
		return -1;
	}

	/* Gets offset to be added to all entries */
	offset = startadd - head.entry;

	/* Gets the data from the file */
	if(f_read(file, startadd, head.tsize + head.dsize) != head.tsize + head.dsize)
		return -1;

	f_seek(file, head.ssize, 1);

	/* Gets number of first data relocation info */
	d = head.rtsize / sizeof(struct reloc);

	/* Relocate segments */
	for(r = 0; r < ((head.rtsize + head.rdsize)/ sizeof(struct reloc)); r++){
		if(f_read(file, &rel, sizeof(struct reloc)) != sizeof(struct reloc))
			return -1;
		address = (char *)(startadd + rel.rpos);

		/* Offsets for data segment address */
		if(r >= d) address += head.tsize;

		/* If not a displacement offset pointer addresses */
		if(!rel.rdisp){
			switch(rel.rsize){
			case RBYTE:
				*address += (char)offset;
				break;

			case RWORD:
				*((short *)address) += (short)offset;
				break;

			case RLONG:
				*((long *)address) += (long)offset;
				break;
			default:
				printf("LINKLD: incorrect symbol\n");
				return -1;
			}
		}
	}

	/* Clear bss area */
	byteclr(startadd + head.tsize + head.dsize, head.bsize);
	return 0;
}
