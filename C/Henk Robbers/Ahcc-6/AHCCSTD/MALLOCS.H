/*  Copyright (c) 2002 - 2008 by Henk Robbers Amsterdam.
 *
 * This file is part of AHCC.
 *
 * AHCC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * AHCC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with AHCC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/*
 * mallocs.h
 *
 * names for AHCM's XA_key parameter
 */

#ifndef MALLOCS_H
#define MALLOCS_H

enum
{
	AH_NONE,
	AH_BOLDTAGS,	/* XA_free_all  */
	AH_COLLECT,
	AH_CONDENSE,
	AH_COPY1,
	AH_COPY_TEXT,
	AH_SPLIT_LINE,
	AH_CREATE_LINE,
	AH_RETAB,
	AH_FCFG,
	AH_ALLOCFR,		/* 10 */
	AH_FORM_SAVE,
	AH_UBBLK,

	AH_ALLOC_F = 30,
	AH_IMG_ALLOC,
	AH_DECOMPRESS,
	AH_INI_ITS,
	AH_GO,
	AH_FLUSH,
	AH_OUT_IMG,
	AH_ALLOC_S,
	AH_ALLOC_ITS,

	AH_AREA  = 40,
	AH_AREA1,
	AH_AREA2,
	AH_AREA3,
	AH_AREA4,
	AH_AREA5,
	AH_AREA6,
	AH_AREA7,
	AH_AREA8,
	AH_AREA9,
	AH_COPT  = 50,
	AH_LOPT,
	AH_NEW_CACHE,
	AH_OPEN_C,
	AH_NAME,
	AH_SHEET,
	AH_CELL,
	AH_CHCELL,
	AH_IDE,

	AH_NAMA   = 60,
	AH_LOAD_IDX,
	AH_IDX,

	AH_DOINCL = 100,	/* XA_free_all */
	AH_COMBINE,
	AH_SCOPE,
	AH_PROC,
	AH_PRTAB,

	AH_OPTDEF = 200,
	AH_SPAR_FIX,
	AH_FUSE_NAME_T,
	AH_FUSE_NAME_C,
	AH_FIX_SCON,
	AH_FIX_SCON1,
	AH_FUSE_SCON,
	AH_NEW_SPACE,
	AH_ADD_DEBUG1,
	AH_ADD_DEBUG2,
	AH_INIT_NAMES,		/* 210 */
	AH_NEW_DEFLIST,
	AH_NEW_SYMTAB,
	AH_NEW_POTAB,
	AH_AREA_STACK,
	AH_LOCVAR,

	CC_LEAK_BEGIN = AH_OPTDEF,
	CC_LEAK_END   = AH_LOCVAR,

	AH_COPYCONFIG = 300,
	AH_OPEN_TEXT,
	AH_INS_MSG,
	AH_NEW_HN     = 400,
	AH_NEW_PART,
	AH_HN_FULL,
	AH_INS_TEXT	  = 500,
	AH_PUTFLISTN,
	AH_NEW_PRJ,

	AH_LOAD_TEXT = 600,
	AH_SCAN_FILE,
	AH_COMP_FILE1,
	AH_COMP_FILE2,
	AH_CLOAD,

	AH_LD        = 700,	/* XA_free_all */
	AH_FIRST_RELOC = AH_LD,
	AH_ADD_RELOC   = AH_LD,
	AH_WOB_IMAGE   = AH_LD,
	AH_WOB_FIX     = AH_LD,
	AH_WOB_NAMES   = AH_LD,
	AH_WPR_IMAGE   = AH_LD,
	AH_WPR_SYM     = AH_LD,

	AH_LOAD_OB,		/* XA_free_all */
	AH_LOAD_GST,

	AH_ASM,			/* XA_free_all */
	AH_O_SETUP    = AH_ASM,
	AH_AREA_SETUP = AH_ASM,
	AH_ADVANCE_B  = AH_ASM,
	AH_ADVANCE_W  = AH_ASM,
	AH_ADVANCE_L  = AH_ASM,

	AH_OPC_SETUP,	/* XA_free_all */
	AH_ASMC_SETUP,	/* XA_free_all */

	AH_XREF,		/* XA_free_all */
	AH_PRJ,

	AH_DIG,			/* XA_free_all */
	AH_DIG_DW,
	AH_DIG_KEEP,
	AH_DIG_HIST,
	AH_DIG_LAB,
	AH_DIG_DT,
	AH_DIG_REL,
	AH_DIG_LLAB,
	AH_DIG_RLC,
	AH_DIG_PL,
	AH_DIG_JT,

	AH_DIG_BPB,
	AH_DIG_BUF,
	AH_DIG_SORT,
	AH_DIG_SYM,
	AH_DIG_SSYM,
	AH_DIG_NAME,
	AH_DIG_COMM,
	AH_DIG_CFG,
	AH_DIG_RNAME,
	AH_DIG_RAM,

	AH_DIG_GST,
	AH_LAST
};


#endif
