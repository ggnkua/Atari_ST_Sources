/****************************************************************************
*
*                       Realmode X86 Emulator Library
*
*               Copyright (C) 1991-2004 SciTech Software, Inc.
*                    Copyright (C) David Mosberger-Tang
*                      Copyright (C) 1999 Egbert Eich
*
*  ========================================================================
*
*  Permission to use, copy, modify, distribute, and sell this software and
*  its documentation for any purpose is hereby granted without fee,
*  provided that the above copyright notice appear in all copies and that
*  both that copyright notice and this permission notice appear in
*  supporting documentation, and that the name of the authors not be used
*  in advertising or publicity pertaining to distribution of the software
*  without specific, written prior permission.  The authors makes no
*  representations about the suitability of this software for any purpose.
*  It is provided "as is" without express or implied warranty.
*
*  THE AUTHORS DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
*  INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO
*  EVENT SHALL THE AUTHORS BE LIABLE FOR ANY SPECIAL, INDIRECT OR
*  CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF
*  USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
*  OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
*  PERFORMANCE OF THIS SOFTWARE.
*
*  ========================================================================
*
* Language:     ANSI C
* Environment:  Any
* Developer:    Kendall Bennett
*
* Description:  This file contains the code to handle debugging of the
*               emulator.
*
****************************************************************************/

#include "x86emui.h"

/*----------------------------- Implementation ----------------------------*/

#ifdef DEBUG

static void     print_encoded_bytes (u16 s, u16 o);
static void     print_decoded_instruction (void);
//static int      parse_line (char *s, int *ps, int *n);

/* should look something like debug's output. */
void X86EMU_trace_regs (void)
{
    if (DEBUG_TRACE()) {
        x86emu_dump_regs();
    }
    if (DEBUG_DECODE() && ! DEBUG_DECODE_NOPRINT()) {
        DPRINTVALHEXWORD("", M.x86.saved_cs);
        DPRINTVALHEXWORD(":", M.x86.saved_ip);
        DPRINT(" ");
        print_encoded_bytes( M.x86.saved_cs, M.x86.saved_ip);
        print_decoded_instruction();
    }
}

void X86EMU_trace_xregs (void)
{
    if (DEBUG_TRACE()) {
        x86emu_dump_xregs();
    }
}

void x86emu_just_disassemble (void)
{
    /*
     * This routine called if the flag DEBUG_DISASSEMBLE is set kind
     * of a hack!
     */
    DPRINTVALHEXWORD("", M.x86.saved_cs);
    DPRINTVALHEXWORD(":", M.x86.saved_ip);
    DPRINT(" ");
    print_encoded_bytes( M.x86.saved_cs, M.x86.saved_ip);
    print_decoded_instruction();
}

#if 0
static void disassemble_forward (u16 seg, u16 off, int n)
{
    X86EMU_sysEnv tregs;
    int i;
    u8 op1;
    /*
     * hack, hack, hack.  What we do is use the exact machinery set up
     * for execution, except that now there is an additional state
     * flag associated with the "execution", and we are using a copy
     * of the register struct.  All the major opcodes, once fully
     * decoded, have the following two steps: TRACE_REGS(r,m);
     * SINGLE_STEP(r,m); which disappear if DEBUG is not defined to
     * the preprocessor.  The TRACE_REGS macro expands to:
     *
     * if (debug&DEBUG_DISASSEMBLE)
     *     {just_disassemble(); goto EndOfInstruction;}
     *     if (debug&DEBUG_TRACE) trace_regs(r,m);
     *
     * ......  and at the last line of the routine.
     *
     * EndOfInstruction: end_instr();
     *
     * Up to the point where TRACE_REG is expanded, NO modifications
     * are done to any register EXCEPT the IP register, for fetch and
     * decoding purposes.
     *
     * This was done for an entirely different reason, but makes a
     * nice way to get the system to help debug codes.
     */
    tregs = M;
    tregs.x86.R_IP = off;
    tregs.x86.R_CS = seg;

    /* reset the decoding buffers */
    tregs.x86.enc_str_pos = 0;
    tregs.x86.enc_pos = 0;

    /* turn on the "disassemble only, no execute" flag */
    tregs.x86.debug |= DEBUG_DISASSEMBLE_F;

    /* DUMP NEXT n instructions to screen in straight_line fashion */
    /*
     * This looks like the regular instruction fetch stream, except
     * that when this occurs, each fetched opcode, upon seeing the
     * DEBUG_DISASSEMBLE flag set, exits immediately after decoding
     * the instruction.  XXX --- CHECK THAT MEM IS NOT AFFECTED!!!
     * Note the use of a copy of the register structure...
     */
    for (i=0; i<n; i++) {
        op1 = (*sys_rdb)(((u32)M.x86.R_CS<<4) + (M.x86.R_IP++));
        (x86emu_optab[op1])(op1);
    }
    /* end major hack mode. */
}
#endif

void x86emu_check_ip_access (void)
{
    /* NULL as of now */
}

void x86emu_check_sp_access (void)
{
}

void x86emu_check_mem_access (u32 dummy)
{
    /*  check bounds, etc */
}

void x86emu_check_data_access (uint dummy1, uint dummy2)
{
    /*  check bounds, etc */
}

void x86emu_inc_decoded_inst_len (int x)
{
	M.x86.enc_pos += x;
}

void x86emu_decode_printf (char *x)
{
	if(debug)
	{
		Funcs_copy(x, &M.x86.decoded_buf[M.x86.enc_str_pos&127]);
		M.x86.enc_str_pos += Funcs_length(x);
	}
}

void x86emu_decode_printf2 (char *x, int y)
{
	char temp[100], *p;
	if(debug)
	{
		p = temp;
		while(x[0] != 0)
		{
			if(x[0]=='%' && x[1]=='d')
			{
				x+=2;
	      Funcs_ltoa(p, y, 10);
	      while(p[0] != 0)
	      	p++;    
			}
			else if(x[0]=='%' && x[1]=='x')
			{
				x+=2;
				*p++ = '0';
				*p++ = 'x';
				y &= 0xffff;
	      Funcs_ltoa(p, y, 16);
	      while(p[0] != 0)
	      	p++;      
			}
			else
				*p++ = *x++;
		}
		*p = 0;
		Funcs_copy(temp, &M.x86.decoded_buf[M.x86.enc_str_pos&127]);
		M.x86.enc_str_pos += Funcs_length(temp);
	}
}

void x86emu_end_instr (void)
{
    M.x86.enc_str_pos = 0;
    M.x86.enc_pos = 0;
}

static void print_encoded_bytes (u16 s, u16 o)
{
    int i;
    for (i=0; i< M.x86.enc_pos; i++)
        DPRINTVALHEXBYTE("", fetch_data_byte_abs(s,o+i));
    for ( ; i<10; i++)
        DPRINT("  ");
}

static void print_decoded_instruction (void)
{
    DPRINT(M.x86.decoded_buf);
}

void x86emu_print_int_vect (u16 iv)
{
    u16 seg,off;

    if (iv > 256) return;
    seg = fetch_data_word_abs(0,iv*4);
    off = fetch_data_word_abs(0,iv*4+2);
    DPRINTVALHEXWORD("", seg);
    DPRINTVALHEXWORD(":", off);
    DPRINT(" ");
}

void X86EMU_dump_memory (u16 seg, u16 off, u32 amt)
{
    u32 start = off & 0xfffffff0;
    u32 end  = (off+16) & 0xfffffff0;
    u32 i;
    u32 current;

    current = start;
    while (end <= off + amt) {
        DPRINTVALHEXWORD("", seg);
        DPRINTVALHEXWORD(":", start);
        DPRINT(" ");
        for (i=start; i< off; i++)
          DPRINT("   ");
        for ( ; i< end; i++)
          DPRINTVALHEXBYTE(" ", fetch_data_byte_abs(seg,i));
        DPRINT("\r\n");
        start = end;
        end = start + 16;
    }
}

void x86emu_single_step (void)
{
#if 0
    char s[1024];
    int ps[10];
    int ntok;
    int cmd;
    int done;
        int segment;
    int offset;
    static int breakpoint;
    static int noDecode = 1;

    char *p;

        if (DEBUG_BREAK()) {
                if (M.x86.saved_ip != breakpoint) {
                        return;
                } else {
              M.x86.debug &= ~DEBUG_DECODE_NOPRINT_F;
                        M.x86.debug |= DEBUG_TRACE_F;
                        M.x86.debug &= ~DEBUG_BREAK_F;
                        print_decoded_instruction ();
                        X86EMU_trace_regs();
                }
        }
    done=0;
    offset = M.x86.saved_ip;
    while (!done) {
        DPRINT("-");
        p = fgets(s, 1023, stdin);
        cmd = parse_line(s, ps, &ntok);
        switch(cmd) {
          case 'u':
            disassemble_forward(M.x86.saved_cs,(u16)offset,10);
            break;
          case 'd':
                            if (ntok == 2) {
                                    segment = M.x86.saved_cs;
                                    offset = ps[1];
                                    X86EMU_dump_memory(segment,(u16)offset,16);
                                    offset += 16;
                            } else if (ntok == 3) {
                                    segment = ps[1];
                                    offset = ps[2];
                                    X86EMU_dump_memory(segment,(u16)offset,16);
                                    offset += 16;
                            } else {
                                    segment = M.x86.saved_cs;
                                    X86EMU_dump_memory(segment,(u16)offset,16);
                                    offset += 16;
                            }
            break;
          case 'c':
            M.x86.debug ^= DEBUG_TRACECALL_F;
            break;
          case 's':
            M.x86.debug ^= DEBUG_SVC_F | DEBUG_SYS_F | DEBUG_SYSINT_F;
            break;
          case 'r':
            X86EMU_trace_regs();
            break;
          case 'x':
            X86EMU_trace_xregs();
            break;
          case 'g':
            if (ntok == 2) {
                breakpoint = ps[1];
        if (noDecode) {
                        M.x86.debug |= DEBUG_DECODE_NOPRINT_F;
        } else {
                        M.x86.debug &= ~DEBUG_DECODE_NOPRINT_F;
        }
        M.x86.debug &= ~DEBUG_TRACE_F;
        M.x86.debug |= DEBUG_BREAK_F;
        done = 1;
            }
            break;
          case 'q':
          M.x86.debug |= DEBUG_EXIT;
          return;
      case 'P':
          noDecode = (noDecode)?0:1;
          DPRINT("Toggled decoding to ");
          DPRINT((noDecode)?"FALSE":"TRUE");
          DPRINT("\r\n");
          break;
          case 't':
      case 0:
            done = 1;
            break;
        }
    }
#endif
}

int X86EMU_trace_on(void)
{
    return M.x86.debug |= DEBUG_STEP_F | DEBUG_DECODE_F | DEBUG_TRACE_F;
}

int X86EMU_trace_off(void)
{
    return M.x86.debug &= ~(DEBUG_STEP_F | DEBUG_DECODE_F | DEBUG_TRACE_F);
}

int X86EMU_set_debug(int debug)
{
	return M.x86.debug = debug;
}

#if 0
static int parse_line (char *s, int *ps, int *n)
{
    int cmd;

    *n = 0;
    while(*s == ' ' || *s == '\t') s++;
    ps[*n] = *s;
    switch (*s) {
      case '\n':
        *n += 1;
        return 0;
      default:
        cmd = *s;
        *n += 1;
    }

    while (1) {
        while (*s != ' ' && *s != '\t' && *s != '\n')  s++;

        if (*s == '\n')
            return cmd;

        while(*s == ' ' || *s == '\t') s++;

        sscanf(s,"%x",&ps[*n]);
        *n += 1;
    }
}
#endif

#endif /* DEBUG */

void x86emu_dump_regs (void)
{
    DPRINTVALHEXWORD("  AX=", M.x86.R_AX );
    DPRINTVALHEXWORD("  BX=", M.x86.R_BX );
    DPRINTVALHEXWORD("  CX=", M.x86.R_CX );
    DPRINTVALHEXWORD("  DX=", M.x86.R_DX );
    DPRINTVALHEXWORD("  SP=", M.x86.R_SP );
    DPRINTVALHEXWORD("  BP=", M.x86.R_BP );
    DPRINTVALHEXWORD("  SI=", M.x86.R_SI );
    DPRINTVALHEXWORD("  DI=", M.x86.R_DI );
    DPRINT("\r\n");
    DPRINTVALHEXWORD("  DS=", M.x86.R_DS );
    DPRINTVALHEXWORD("  ES=", M.x86.R_ES );
    DPRINTVALHEXWORD("  SS=", M.x86.R_SS );
    DPRINTVALHEXWORD("  CS=", M.x86.R_CS );
    DPRINTVALHEXWORD("  IP=", M.x86.R_IP );
    DPRINT("\r\n  ");
    if (ACCESS_FLAG(F_OF))    DPRINT("OV ");     /* CHECKED... */
    else                        DPRINT("NV ");
    if (ACCESS_FLAG(F_DF))    DPRINT("DN ");
    else                        DPRINT("UP ");
    if (ACCESS_FLAG(F_IF))    DPRINT("EI ");
    else                        DPRINT("DI ");
    if (ACCESS_FLAG(F_SF))    DPRINT("NG ");
    else                        DPRINT("PL ");
    if (ACCESS_FLAG(F_ZF))    DPRINT("ZR ");
    else                        DPRINT("NZ ");
    if (ACCESS_FLAG(F_AF))    DPRINT("AC ");
    else                        DPRINT("NA ");
    if (ACCESS_FLAG(F_PF))    DPRINT("PE ");
    else                        DPRINT("PO ");
    if (ACCESS_FLAG(F_CF))    DPRINT("CY ");
    else                        DPRINT("NC ");
    DPRINT("\r\n");
}

void x86emu_dump_xregs (void)
{
    DPRINTVALHEXLONG("  EAX=", M.x86.R_EAX );
    DPRINTVALHEXLONG("  EBX=", M.x86.R_EBX );
    DPRINTVALHEXLONG("  ECX=", M.x86.R_ECX );
    DPRINTVALHEXLONG("  EDX=", M.x86.R_EDX );
    DPRINT("\r\n");
    DPRINTVALHEXLONG("  ESP=", M.x86.R_ESP );
    DPRINTVALHEXLONG("  EBP=", M.x86.R_EBP );
    DPRINTVALHEXLONG("  ESI=", M.x86.R_ESI );
    DPRINTVALHEXLONG("  EDI=", M.x86.R_EDI );
    DPRINT("\r\n");
    DPRINTVALHEXWORD("  DS=", M.x86.R_DS );
    DPRINTVALHEXWORD("  ES=", M.x86.R_ES );
    DPRINTVALHEXWORD("  SS=", M.x86.R_SS );
    DPRINTVALHEXWORD("  CS=", M.x86.R_CS );
    DPRINTVALHEXLONG("  EIP=", M.x86.R_EIP );
    DPRINT("\r\n  ");
    if (ACCESS_FLAG(F_OF))    DPRINT("OV ");     /* CHECKED... */
    else                        DPRINT("NV ");
    if (ACCESS_FLAG(F_DF))    DPRINT("DN ");
    else                        DPRINT("UP ");
    if (ACCESS_FLAG(F_IF))    DPRINT("EI ");
    else                        DPRINT("DI ");
    if (ACCESS_FLAG(F_SF))    DPRINT("NG ");
    else                        DPRINT("PL ");
    if (ACCESS_FLAG(F_ZF))    DPRINT("ZR ");
    else                        DPRINT("NZ ");
    if (ACCESS_FLAG(F_AF))    DPRINT("AC ");
    else                        DPRINT("NA ");
    if (ACCESS_FLAG(F_PF))    DPRINT("PE ");
    else                        DPRINT("PO ");
    if (ACCESS_FLAG(F_CF))    DPRINT("CY ");
    else                        DPRINT("NC ");
    DPRINT("\r\n");
}
