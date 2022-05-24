	.file	"s3m.c"
gcc2_compiled.:
___gnu_compiled_c:
.globl _stereo
.data
	.align 2
_stereo:
	.long 0
.globl _bit16
	.align 2
_bit16:
	.long 0
.text
	.align 4
.globl _play_mod
_play_mod:
	pushl %ebp
	movl %esp,%ebp
	subl $8,%esp
	pushl %esi
	pushl %ebx
	movl 8(%ebp),%ecx
	pushl %ecx
	call _startplaying
	addl $4,%esp
	movw $0,_mod_done
L2:
	cmpw $0,_mod_done
	jne L3
	call _updatetracks
	movl $_tracks,-8(%ebp)
	cmpl $0,_bit16
	je L4
	cmpl $0,_stereo
	je L5
	movzwl _bpm_samples,%eax
	movl %eax,%edx
	addl %eax,%edx
	movl %edx,%eax
	movl %eax,%edx
	addl %eax,%edx
	leal _buf(%edx),%esi
L6:
	cmpl $_buf,%esi
	jbe L7
L8:
	addl $-2,%esi
	movw $32768,(%esi)
	jmp L6
	.align 4,0x90
L7:
	jmp L9
	.align 4,0x90
L5:
	nop
	movzwl _bpm_samples,%eax
	movl %eax,%edx
	movl %edx,%eax
	addl %edx,%eax
	leal _buf(%eax),%esi
L10:
	cmpl $_buf,%esi
	jbe L11
L12:
	addl $-2,%esi
	movw $32768,(%esi)
	jmp L10
	.align 4,0x90
L11:
L9:
	jmp L13
	.align 4,0x90
L4:
	cmpl $0,_stereo
	je L14
	movzwl _bpm_samples,%eax
	movl %eax,%edx
	addl %eax,%edx
	leal _buf(%edx),%ebx
L15:
	cmpl $_buf,%ebx
	jbe L16
L17:
	decl %ebx
	movb $128,(%ebx)
	jmp L15
	.align 4,0x90
L16:
	jmp L18
	.align 4,0x90
L14:
	nop
	movzwl _bpm_samples,%eax
	leal _buf(%eax),%ebx
L19:
	cmpl $_buf,%ebx
	jbe L20
L21:
	decl %ebx
	movb $128,(%ebx)
	jmp L19
	.align 4,0x90
L20:
L18:
L13:
	nop
	movw $0,-2(%ebp)
L22:
	movswl -2(%ebp),%eax
	movzbl _mod+20,%edx
	cmpl %edx,%eax
	jge L23
	cmpl $0,_bit16
	je L25
	cmpl $0,_stereo
	je L26
	movw -2(%ebp),%ax
	andw $1,%ax
	movswl %ax,%edx
	pushl %edx
	movzwl _bpm_samples,%eax
	pushl %eax
	pushl $_buf
	movl -8(%ebp),%ecx
	pushl %ecx
	addl $68,-8(%ebp)
	call _mixtrack_16_stereo
	addl $16,%esp
	jmp L27
	.align 4,0x90
L26:
	movzwl _bpm_samples,%eax
	pushl %eax
	pushl $_buf
	movl -8(%ebp),%ecx
	pushl %ecx
	addl $68,-8(%ebp)
	call _mixtrack_16_mono
	addl $12,%esp
L27:
	jmp L28
	.align 4,0x90
L25:
	cmpl $0,_stereo
	je L29
	movw -2(%ebp),%ax
	andw $1,%ax
	movswl %ax,%edx
	pushl %edx
	movzwl _bpm_samples,%eax
	pushl %eax
	pushl $_buf
	movl -8(%ebp),%ecx
	pushl %ecx
	addl $68,-8(%ebp)
	call _mixtrack_8_stereo
	addl $16,%esp
	jmp L30
	.align 4,0x90
L29:
	movzwl _bpm_samples,%eax
	pushl %eax
	pushl $_buf
	movl -8(%ebp),%ecx
	pushl %ecx
	addl $68,-8(%ebp)
	call _mixtrack_8_mono
	addl $12,%esp
L30:
L28:
L24:
	incw -2(%ebp)
	jmp L22
	.align 4,0x90
L23:
	movl $_buf,%ebx
	cmpl $0,_stereo
	je L31
	cmpl $0,_bit16
	je L32
	movzwl _bpm_samples,%eax
	leal 0(,%eax,4),%edx
	movl %ebx,%esi
	addl %edx,%esi
	jmp L33
	.align 4,0x90
L32:
	movzwl _bpm_samples,%eax
	movl %eax,%edx
	addl %eax,%edx
	movl %ebx,%esi
	addl %edx,%esi
L33:
	jmp L34
	.align 4,0x90
L31:
	cmpl $0,_bit16
	je L35
	movzwl _bpm_samples,%eax
	movl %eax,%edx
	addl %eax,%edx
	movl %ebx,%esi
	addl %edx,%esi
	jmp L36
	.align 4,0x90
L35:
	movzwl _bpm_samples,%eax
	movl %ebx,%esi
	addl %eax,%esi
L36:
L34:
	nop
L37:
	cmpl %esi,%ebx
	jae L38
	movl _audio_curptr,%eax
	cmpl %eax,_audio_end_buffer
	ja L39
	movl _audio_buffer_size,%ecx
	pushl %ecx
	movl _audio_start_buffer,%ecx
	pushl %ecx
	movl _audio,%ecx
	pushl %ecx
	call _write
	addl $12,%esp
	movl _audio_start_buffer,%ecx
	movl %ecx,_audio_curptr
L39:
	movl _audio_curptr,%eax
	movb (%ebx),%cl
	movb %cl,(%eax)
	incl %ebx
	incl _audio_curptr
	jmp L37
	.align 4,0x90
L38:
	jmp L2
	.align 4,0x90
L3:
L1:
	leal -16(%ebp),%esp
	popl %ebx
	popl %esi
	movl %ebp,%esp
	popl %ebp
	ret
LC0:
	.ascii "V1.02\0"
LC1:
	.ascii "\12S3MOD - S3M/MOD tracker (%s) for Linux by Daniel Marks\12\0"
LC2:
	.ascii "dlm40629@uxa.cso.uiuc.edu\12\12\0"
LC3:
	.ascii "(C) Copyright 1994 by Daniel L. Marks\12\0"
LC4:
	.ascii "See README file for Copyright details.\12\12\0"
LC5:
	.ascii "s3mod [-sbf] [sampling frequency] filename\12\0"
LC6:
	.ascii "     -s stereo\12\0"
LC7:
	.ascii "     -b 16 bit samples\12\0"
LC8:
	.ascii "     -f set frequency\12\12\0"
LC9:
	.ascii "s3mod -sbf 44100 foobar.mod\12\0"
LC10:
	.ascii "   plays in stereo, 16 bits, 44.1 kHz\12\12\0"
LC11:
	.ascii "This player plays Screamtracker 3 files, and\12\0"
LC12:
	.ascii "4,6,or 8 track MODs.\12\12\0"
	.align 4
.globl _help
_help:
	pushl %ebp
	movl %esp,%ebp
	pushl $LC0
	pushl $LC1
	call _printf
	addl $8,%esp
	pushl $LC2
	call _printf
	addl $4,%esp
	pushl $LC3
	call _printf
	addl $4,%esp
	pushl $LC4
	call _printf
	addl $4,%esp
	pushl $LC5
	call _printf
	addl $4,%esp
	pushl $LC6
	call _printf
	addl $4,%esp
	pushl $LC7
	call _printf
	addl $4,%esp
	pushl $LC8
	call _printf
	addl $4,%esp
	pushl $LC9
	call _printf
	addl $4,%esp
	pushl $LC10
	call _printf
	addl $4,%esp
	pushl $LC11
	call _printf
	addl $4,%esp
	pushl $LC12
	call _printf
	addl $4,%esp
	pushl $1
	call _exit
	addl $4,%esp
	.align 4,0x90
L40:
	movl %ebp,%esp
	popl %ebp
	ret
LC13:
	.ascii "File is not a valid mod or s3m!\12\0"
LC14:
	.ascii "/dev/dsp\0"
LC15:
	.ascii "Could not open audio device!\12\0"
LC16:
	.ascii "Error setting sample speed\12\0"
LC17:
	.ascii "Unable to get audio blocksize\12\0"
LC18:
	.ascii "Invalid audio buffer size: %d\12\0"
LC19:
	.ascii "Could not get audio buffer memory!\12\0"
LC20:
	.ascii "stereo\0"
LC21:
	.ascii "mono\0"
LC22:
	.ascii "Playing \"%s\" at rate %d, %d bits, %s, blocksize %d\12\0"
	.align 4
.globl _main
_main:
	pushl %ebp
	movl %esp,%ebp
	subl $16,%esp
	call ___main
	movl $0,-12(%ebp)
	movl $0,-16(%ebp)
	movl $22000,_mixspeed
	cmpl $1,8(%ebp)
	jg L42
	call _help
L42:
	movl 12(%ebp),%eax
	addl $4,%eax
	movl (%eax),%edx
	cmpb $45,(%edx)
	je L43
	movl 12(%ebp),%eax
	addl $4,%eax
	movl (%eax),%ecx
	movl %ecx,-8(%ebp)
	jmp L44
	.align 4,0x90
L43:
	cmpl $2,8(%ebp)
	jg L45
	call _help
L45:
	movl 12(%ebp),%eax
	addl $8,%eax
	movl (%eax),%ecx
	movl %ecx,-8(%ebp)
	pushl $83
	movl 12(%ebp),%eax
	addl $4,%eax
	movl (%eax),%ecx
	pushl %ecx
	call _strrchr
	addl $8,%esp
	movl %eax,%eax
	testl %eax,%eax
	jne L47
	pushl $115
	movl 12(%ebp),%eax
	addl $4,%eax
	movl (%eax),%ecx
	pushl %ecx
	call _strrchr
	addl $8,%esp
	movl %eax,%eax
	testl %eax,%eax
	jne L47
	jmp L46
	.align 4,0x90
L47:
	movl $1,_stereo
L46:
	pushl $66
	movl 12(%ebp),%eax
	addl $4,%eax
	movl (%eax),%ecx
	pushl %ecx
	call _strrchr
	addl $8,%esp
	movl %eax,%eax
	testl %eax,%eax
	jne L49
	pushl $98
	movl 12(%ebp),%eax
	addl $4,%eax
	movl (%eax),%ecx
	pushl %ecx
	call _strrchr
	addl $8,%esp
	movl %eax,%eax
	testl %eax,%eax
	jne L49
	jmp L48
	.align 4,0x90
L49:
	movl $1,_bit16
L48:
	pushl $81
	movl 12(%ebp),%eax
	addl $4,%eax
	movl (%eax),%ecx
	pushl %ecx
	call _strrchr
	addl $8,%esp
	movl %eax,%eax
	testl %eax,%eax
	jne L51
	pushl $113
	movl 12(%ebp),%eax
	addl $4,%eax
	movl (%eax),%ecx
	pushl %ecx
	call _strrchr
	addl $8,%esp
	movl %eax,%eax
	testl %eax,%eax
	jne L51
	jmp L50
	.align 4,0x90
L51:
	movl $1,-12(%ebp)
L50:
	pushl $78
	movl 12(%ebp),%eax
	addl $4,%eax
	movl (%eax),%ecx
	pushl %ecx
	call _strrchr
	addl $8,%esp
	movl %eax,%eax
	testl %eax,%eax
	jne L53
	pushl $110
	movl 12(%ebp),%eax
	addl $4,%eax
	movl (%eax),%ecx
	pushl %ecx
	call _strrchr
	addl $8,%esp
	movl %eax,%eax
	testl %eax,%eax
	jne L53
	jmp L52
	.align 4,0x90
L53:
	movb $0,_loop_mod
L52:
	pushl $76
	movl 12(%ebp),%eax
	addl $4,%eax
	movl (%eax),%ecx
	pushl %ecx
	call _strrchr
	addl $8,%esp
	movl %eax,%eax
	testl %eax,%eax
	jne L55
	pushl $108
	movl 12(%ebp),%eax
	addl $4,%eax
	movl (%eax),%ecx
	pushl %ecx
	call _strrchr
	addl $8,%esp
	movl %eax,%eax
	testl %eax,%eax
	jne L55
	jmp L54
	.align 4,0x90
L55:
	movl $1,-16(%ebp)
L54:
	pushl $70
	movl 12(%ebp),%eax
	addl $4,%eax
	movl (%eax),%ecx
	pushl %ecx
	call _strrchr
	addl $8,%esp
	movl %eax,%eax
	testl %eax,%eax
	jne L57
	pushl $102
	movl 12(%ebp),%eax
	addl $4,%eax
	movl (%eax),%ecx
	pushl %ecx
	call _strrchr
	addl $8,%esp
	movl %eax,%eax
	testl %eax,%eax
	jne L57
	jmp L56
	.align 4,0x90
L57:
	cmpl $3,8(%ebp)
	jg L58
	call _help
L58:
	movl 12(%ebp),%eax
	addl $12,%eax
	movl (%eax),%ecx
	movl %ecx,-8(%ebp)
	movl 12(%ebp),%eax
	addl $8,%eax
	movl (%eax),%ecx
	pushl %ecx
	call _atoi
	addl $4,%esp
	movl %eax,_mixspeed
L56:
L44:
	movl -12(%ebp),%ecx
	pushl %ecx
	pushl $_mod
	movl -8(%ebp),%ecx
	pushl %ecx
	call _load_s3m
	addl $12,%esp
	movl %eax,%eax
	testw %ax,%ax
	je L59
	movl -12(%ebp),%ecx
	pushl %ecx
	pushl $_mod
	movl -8(%ebp),%ecx
	pushl %ecx
	call _load_mod
	addl $12,%esp
	movl %eax,%eax
	testl %eax,%eax
	je L60
	pushl $LC13
	call _printf
	addl $4,%esp
	pushl $1
	call _exit
	addl $4,%esp
	.align 4,0x90
L60:
L59:
	pushl $0
	pushl $1
	pushl $LC14
	call _open
	addl $12,%esp
	movl %eax,%eax
	movl %eax,_audio
	cmpl $0,_audio
	jg L61
	pushl $LC15
	call _printf
	addl $4,%esp
	pushl $1
	call _exit
	addl $4,%esp
	.align 4,0x90
L61:
	cmpl $0,_stereo
	je L62
	pushl $_stereo
	pushl $-1073459197
	movl _audio,%ecx
	pushl %ecx
	call _ioctl
	addl $12,%esp
	movl %eax,%eax
	cmpl $-1,%eax
	jne L63
	movl $0,_stereo
L63:
L62:
	cmpl $0,_bit16
	je L64
	movl $16,-4(%ebp)
	leal -4(%ebp),%eax
	pushl %eax
	pushl $-1073459195
	movl _audio,%ecx
	pushl %ecx
	call _ioctl
	addl $12,%esp
	movl %eax,%eax
	cmpl $-1,%eax
	jne L65
	movl $0,_bit16
L65:
	cmpl $16,-4(%ebp)
	je L66
	movl $0,_bit16
L66:
L64:
	movl _mixspeed,%ecx
	movl %ecx,-4(%ebp)
	leal -4(%ebp),%eax
	pushl %eax
	pushl $-1073459198
	movl _audio,%ecx
	pushl %ecx
	call _ioctl
	addl $12,%esp
	movl %eax,%eax
	cmpl $-1,%eax
	jne L67
	pushl $LC16
	call _printf
	addl $4,%esp
	pushl $1
	call _exit
	addl $4,%esp
	.align 4,0x90
L67:
	movl -4(%ebp),%ecx
	movl %ecx,_mixspeed
	pushl $_audio_buffer_size
	pushl $-1073459196
	movl _audio,%ecx
	pushl %ecx
	call _ioctl
	addl $12,%esp
	movl %eax,%eax
	cmpl $-1,%eax
	jne L68
	pushl $LC17
	call _printf
	addl $4,%esp
	pushl $1
	call _exit
	addl $4,%esp
	.align 4,0x90
L68:
	cmpl $4095,_audio_buffer_size
	jle L70
	cmpl $131072,_audio_buffer_size
	jg L70
	jmp L69
	.align 4,0x90
L70:
	movl _audio_buffer_size,%ecx
	pushl %ecx
	pushl $LC18
	call _printf
	addl $8,%esp
	pushl $1
	call _exit
	addl $4,%esp
	.align 4,0x90
L69:
	movl _audio_buffer_size,%ecx
	pushl %ecx
	call _malloc
	addl $4,%esp
	movl %eax,%eax
	movl %eax,%edx
	movl %edx,_audio_start_buffer
	testl %edx,%edx
	jne L71
	pushl $LC19
	call _printf
	addl $4,%esp
	pushl $1
	call _exit
	addl $4,%esp
	.align 4,0x90
L71:
	movl _audio_start_buffer,%ecx
	addl _audio_buffer_size,%ecx
	movl %ecx,_audio_end_buffer
	movl _audio_start_buffer,%ecx
	movl %ecx,_audio_curptr
	cmpl $0,-12(%ebp)
	jne L72
	movl _audio_buffer_size,%ecx
	pushl %ecx
	cmpl $0,_stereo
	je L73
	movl $LC20,%eax
	jmp L74
	.align 4,0x90
L73:
	movl $LC21,%eax
L74:
	pushl %eax
	cmpl $0,_bit16
	je L75
	movl $16,%eax
	jmp L76
	.align 4,0x90
L75:
	movl $8,%eax
L76:
	pushl %eax
	movl _mixspeed,%ecx
	pushl %ecx
	movl -8(%ebp),%ecx
	pushl %ecx
	pushl $LC22
	call _printf
	addl $24,%esp
L72:
	movl -16(%ebp),%ecx
	pushl %ecx
	call _play_mod
	addl $4,%esp
	movl _audio_start_buffer,%ecx
	pushl %ecx
	call _free
	addl $4,%esp
	movl _audio,%ecx
	pushl %ecx
	call _close
	addl $4,%esp
L41:
	movl %ebp,%esp
	popl %ebp
	ret
.comm _audio,4
.comm _buf,20480
.comm _audio_buffer_size,4
.comm _audio_start_buffer,4
.comm _audio_end_buffer,4
.comm _audio_curptr,4
