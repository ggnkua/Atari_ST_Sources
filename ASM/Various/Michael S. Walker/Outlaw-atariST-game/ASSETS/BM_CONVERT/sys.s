/*	BitRip Copyleft !(c) 2019, Michael S. Walker <sigmatau@heapsmash.com>
 *	All Rights Unreserved in all Federations, including Alpha Centauris.
 */

#include    "syscalls.h"

    .section    .text
    .global     X86SysCall
    .type       X86SysCall, @function

X86SysCall:                 /* for the intel derps */
    movq    %rdi, %rax      /* mov  rax, rdi */
    movq    %rsi, %rdi      /* mov  rdi, rsi */
    movq    %rdx, %rsi      /* mov  rsi, rdx */
    movq    %rcx, %rdx      /* mov  rdx, rcx */
    movq    %r8, %r10       /* mov  r10, r8  */
    movq    %r9, %r8        /* mov  r8, r9   */
    movq    8(%rsp), %r9    /* mov  r9, [rsp + 8] */

    syscall
    cmpq    $-4095, %rax    /* cmp  rax -4095 */
    jb      no_err
    negl    %eax
    movl    %eax, %edi      /* mov  edi, eax */
    call    SetErrno

no_err:
    retq
