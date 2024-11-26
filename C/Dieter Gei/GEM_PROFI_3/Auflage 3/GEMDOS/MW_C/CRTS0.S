/
/ ST C run time startup.
/
        .prvd
        .globl  errno_
        .globl  environ_
        .globl  _stksize_
        .globl  _start_
        .globl  _app_
        .globl  vq_gdos_

errno_:         .word 0
environ_:       .long 0
_app_:          .word 0

/
/ Parse TOS environment list into vector at end of bss.
/       a0 = base of envp[]
/       a1 = past end of envp[] or argv[]
/       a2 = pointer to next word to parse
/       a3 = pointer to last word parsed
/       a4 = unused
/       a5 = base page pointer
/       d0 = base of argv[] if found
/       d1 = terminator character for parse
/       d2 = character temporary
/       d3 = argv found flag
/       _iovector_ = value of ARGV parameter if any
/       environ_ = where envp[] gets stored for getenv()
/       _stksize_ = a long size for stack allocation
/               overwritten at runtime to make a stack limit
/       _start_ = program text base
/

        .shri
_start_:
        lea     _start_-256,a5          / Get base page
        tst.l   36(a5)                  / Test parent process
        bne     app                     / Go to the application initialization
        movea.l $__ESTACK__,a7          / Load the stack pointer with our stack
        move.l  a5, -(a7)               / basepage
        clr.l   -(a7)                   / envp[]
        clr.l   -(a7)                   / argv[]
        clr     -(a7)                   / argc
        jsr     main_                   / Execute the desk accessory
        adda    $10, a7                 / Pop arguments
        clr     -(a7)                   / Function 0
        trap    $1                      / Gemdos (Pterm0())

app:
        move    $1,_app_                / Its an application
        movea.l 4(a7), a5               / Fetch base page pointer
        movea.l 24(a5), a0              / Fetch bss base
        adda.l  28(a5), a0              / + size of bss = envp[]
        movea.l 44(a5), a2              / Fetch environment pointer
        clr.l   d0                      / no argv[]
        movea.l a0, a1                  / Begin envp[]
        tst.b   (a2)                    / Test for empty envp[]
        beq.s   8f
        move.l  a2, (a1)                / Store first element of vector
0:      movea.l a2, a3
        movea.l (a1)+, a2
9:      tst.b   (a2)+
        bne.s   9b
        move.l  a2, (a1)
        tst.b   (a2)                    / Test next byte.
        beq.s   1f                      / End of environment
/ Look for ARGV
        cmpi.b  $0x41, (a3)+            / 'A' ?
        bne.s   0b
        cmpi.b  $0x52, (a3)+            / 'R' ?
        bne.s   0b
        cmpi.b  $0x47, (a3)+            / 'G' ?
        bne.s   0b
        cmpi.b  $0x56, (a3)+            / 'V' ?
        bne.s   0b
/ ARGV found, look for iovector.
        cmpi.b  $0x3D, (a3)+            / '=' ?
        bne.s   0f
        tst.b   (a3)
        beq.s   0f
        move.l  a3, _iovector_
/ ARGV found, rest of environ is argv[]
0:      clr.l   (a1)+                   / terminate envp
        move.l  a1, d0                  / Save base of argv[]
        move.l  a2, (a1)                / start of arguments
0:      movea.l a2, a3
        movea.l (a1)+, a2
9:      tst.b   (a2)+
        bne.s   9b
        move.l  a2, (a1)
        tst.b   (a2)                    / detect end
        bne.s   0b
/ End of envp[] or envp[] and argv[]
1:      move.l  d0, d3                  / See if argv[] found
        bne.s   2f
/ ARGV= not found, parse command tail
8:      clr.l   (a1)+                   / terminate envp
        move.l  a1, d0                  / Save base of argv[]
        move.l  $_cmdname_, (a1)+       / Store canned name for argv[0]
        lea     128(a5), a2             / Command tail buffer == argv[1]
        move.b  (a2)+, d2               / Fetch count
        ext     d2
        clr.b   0(a2, d2)               / Nul terminate the cmdtail
        moveq   $0x20, d1               / Space terminator
0:      move.b  (a2)+, d2               / If it isn't empty
        beq.s   2f                      / end of command tail
        cmp.b   d1, d2                  / Strip spaces
        beq.s   0b
        subq    $1, a2                  / Unstrip character
        move.l  a2, (a1)+               / Store into vector
9:      move.b  (a2)+, d2               / Fetch character
        beq.s   2f                      / end of command tail
        cmp.b   d1, d2                  / Terminator
        bne.s   9b
1:      clr.b   -1(a2)                  / Terminate argv[argc]
        bra.s   0b                      / Continue
/ End of envp[] and argv[]
2:      clr.l   (a1)+                   / Terminate argv[]
/ Allocate stack, a1 points beyond vectors
        move.l  a1, d1                  / Save end of vectors for argc
        adda.l  _stksize_, a1           / Allocate _stksize_ bytes of stack
        move.l  d1, _stksize_           / Save end of vectors for stack limit
        movea.l a1, a7                  / Set the initial stack.
        move.l  a1, 4(a5)               / Save current brk for sbrk
/ Push arguments for main(argc, argv, envp)
        move.l  a5, -(a7)               / basepage
        move.l  a0, environ_            / envp[]
        move.l  a0, -(a7)               / envp[]
        move.l  d0, -(a7)               / argv[]
        sub.l   d0, d1                  / (argc+1) * sizeof(char *)
        asr.l   $2, d1                  / (argc+1)
        subq    $1, d1                  / argc
        move    d1, -(a7)
/ Release unused memory to the system pool.
        suba.l  a5, a1                  / Compute size of retained memory
        move.l  a1, -(a7)
        move.l  a5, -(a7)               / Base of retained memory
        clr     -(a7)                   / Must be zero
        move    $0x4A, -(a7)            / Mshrink opcode
        trap    $1                      / Gemdos
        adda    $12, a7                 / Pop arguments
/ Fixup the stderr file handle if we're off the desktop
/ Something is weird here, trying same without close's
        tst.l   d3
        bne.s   0f
        move    $4, -(a7)       / dup2(d7 = dup(2), 4), close(d7)
        move    $2, -(a7)
        jsr     dup_
/       move    d0, d7
        move    d0, (a7)
        jsr     dup2_
/       move    d7, (a7)
/       jsr     close_
        move    $2, 2(a7)       / dup2(d7 = dup(0), 2), close(d7)
        clr     (a7)
        jsr     dup_
/       move    d0, d7
        move    d0, (a7)
        jsr     dup2_
/       move    d7, (a7)
/       jsr     close_
        addq    $4, a7          / pop
0:
/ Call main(argc, argv, envp)
        suba    a6, a6                  / Zero frame pointer
        jsr     main_                   / Call main line
        adda    $10, a7                 / Pop arguments
/ Exit with return from main
        move    d0, -(a7)               / Push status
        jsr     exit_                   / Call extended exit()
        move    $0x4C, -(a7)            / Terminate
        trap    $1

vq_gdos_:
        move.l  $0xFFFFFFFE,d0
        trap    $2
        addq.l  $2,d0
        rts

               .bssd
               .even
__USTACK__:    .blkb   0x3000           / This is the stack size
__ESTACK__:    .blkl   1                / Put your value in its place.

