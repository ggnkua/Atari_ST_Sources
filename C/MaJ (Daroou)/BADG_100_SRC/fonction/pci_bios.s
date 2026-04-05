/* ************************************ */
/* *    Appel des fonctions _PCI      * */
/* *     Daroou / Rennaissance        * */
/* *          2002-2003               * */
/* ************************************ */

/*-------------------------------------------------------------------
							Code		Check Milan	Check other

+ 0 : Find_PCI_Device		ok			ok			?
+ 4 : Find_PCI_ClassCode	ok			ok			?

+ 8 : Read_Config_Byte		ok			ok			?
+12 : Read_Config_Word		ok			ok			?
+16 : Read_Config_Long		ok			ok			?
+20 : Fast_Read_Config_Byte	ok			ok			?
+24 : Fast_Read_Config_Word	ok			ok			?
+28 : Fast_Read_Config_Long	ok			ok			?
+32 : Write_Config_Byte		ok			ok			?
+36 : Write_Config_Word		ok			ok			?
+40 : Write_Config_Long		ok			ok			?


+44 : Hook_Interrupt		ok			?			?
+48 : Unhook_Interrupt		ok			?			?

+52 : Special_Cycle			ok

+56 : Get_Routine			ok

+60 : Set_Interrupt			ok

+64 : Get_Resource			ok

+68 : Get_Card_Used			ok
+72 : Set_Card_Used			ok

+76 : Read_Mem_Byte			ok
+80 : Read_Mem_Word			ok
+84 : Read_Mem_Long			ok

+88 : Fast_Read_Mem_Byte	ok
+92 : Fast_Read_Mem_Word	ok
+96 : Fast_Read_Mem_Long	ok

+100: Write_Mem_Byte		ok
+104: Write_Mem_Word		ok
+108: Write_Mem_Long		ok

+112: Read_IO_Byte			ok
+116: Read_IO_Word			ok
+120: Read_IO_Long			ok

+124: Fast_Read_IO_Byte		ok
+128: Fast_Read_IO_Word		ok
+132: Fast_Read_IO_Long		ok

+136: Write_IO_Byte			ok
+140: Write_IO_Word			ok
+144: Write_IO_Long			ok

+148: Get_Machine_ID		ok			ok			?
+152: Get_Pagesize			ok			ok			?

+156: Virt_To_Bus			ok
+160: Bus_To_Virt			ok

+164: Virt_To_Phys			ok
+168: Phys_To_Virt			ok

---------------------------------------------------------------------*/


	.text
	.globl	__find_pci_device
	.globl	__find_pci_classcode
	.globl	__read_config_byte
	.globl	__read_config_word
	.globl	__read_config_longword
	.globl	__fast_read_config_byte
	.globl	__fast_read_config_word
	.globl	__fast_read_config_longword
	.globl	__write_config_byte
	.globl	__write_config_word
	.globl	__write_config_longword
	.globl	__hook_interrupt
	.globl	__unhook_interrupt
	.globl	__special_cycle
	.globl	__get_routing
	.globl	__set_interrupt
	.globl	__get_resource
	.globl	__get_card_used
	.globl	__set_card_used
	.globl	__read_mem_byte
	.globl	__read_mem_word
	.globl	__read_mem_longword
	.globl	__fast_read_mem_byte
	.globl	__fast_read_mem_word
	.globl	__fast_read_mem_longword
	.globl	__write_mem_byte
	.globl	__write_mem_word
	.globl	__write_mem_longword
	.globl	__read_io_byte
	.globl	__read_io_word
	.globl	__read_io_longword
	.globl	__fast_read_io_byte
	.globl	__fast_read_io_word
	.globl	__fast_read_io_longword
	.globl	__write_io_byte
	.globl	__write_io_word
	.globl	__write_io_longword
	.globl	__get_machine_id
	.globl	__get_pagesize
	.globl	__virt_to_bus
	.globl	__bus_to_virt
	.globl	__virt_to_phys
	.globl	__phys_to_virt

/*--------------------------------------------------------------------
	Liste des paramŠtres (sur 32 bits):
	adresse de retour:	 0(SP)
	paramŠtre 1:		 4(SP)
	paramŠtre 2:		 8(SP)
	paramŠtre 3:		12(SP)
	paramŠtre 4:		16(SP)
	etc...
	Le registres D0 renvoi un error CODE en cas de problŠme
	Tous les paramŠtres sont (doivent) transmis sur des LONG
--------------------------------------------------------------------*/


/*---------------------------------------------------------------*/
/* +0                      FIND PCI DEVICE                       */
/*---------------------------------------------------------------*/
	.even
__find_pci_device:

	Move.L	4(SP),D0	/* Device ID in bits 31..16 (0 - $FFFF) */
						/* Vendor ID in bits 15..0  (0 - $FFFF) */
	Move.L	8(SP),D1	/* Index (0 - # of cards with these IDs ) */

	Move.L	_PCI_pt_fonction,A0	/* adresse table fonction */
	Move.L	0(A0),A0			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place notre Pile      */

	Jsr		(A0)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */
	rts


/*---------------------------------------------------------------*/
/* +4                      FIND PCI CLASSCODE                    */
/*---------------------------------------------------------------*/
	.even
__find_pci_classcode:

	Move.L	4(SP),D0	/* ClassCode */
	Move.L	8(SP),D1	/* Index (0 - # of cards with these IDs ) */

	Move.L	_PCI_pt_fonction,A0	/* adresse table fonction */
	Move.L	4(A0),A0			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A0)		/* saut … la fonction */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */
	Rts


/*---------------------------------------------------------------*/
/* +8                     READ CONFIG BYTE                       */
/*---------------------------------------------------------------*/
	.even
__read_config_byte:

	Move.L	 4(SP),D0	/* Handle de la carte PCI               */
	Move.L	 8(SP),D1	/* Num‚ro du Registre de configuration  */
	Move.L	12(SP),A0	/* adresse variable de reponse */

	Move.L	_PCI_pt_fonction,A1	/* adresse table fonction */
	Move.L	8(A1),A1			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre  */

	Jsr		(A1)		/* saut … la fonction */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */
	Rts

/*---------------------------------------------------------------*/
/* +12                    READ CONFIG WORD                       */
/*---------------------------------------------------------------*/
	.even
__read_config_word:
	Move.L	 4(SP),D0	/* Handle du Device ...                */
	Move.L	 8(SP),D1	/* Num‚ro du Registre de configuration */
	Move.L	12(SP),A0	/* adresse variable de reponse */

	Move.L	_PCI_pt_fonction,A1	/* adresse table fonction */
	Move.L	12(A1),A1			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A1)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */
	Rts


/*---------------------------------------------------------------*/
/* +16                    READ CONFIG LONG                       */
/*---------------------------------------------------------------*/
	.even
__read_config_longword:
	Move.L	 4(SP),D0	/* Handle du Device ...                  */
	Move.L	 8(SP),D1	/* Num‚ro du Registre de configuration   */
	Move.L	12(SP),A0	/* adresse variable de reponse */

	Move.L	_PCI_pt_fonction,A1	/* adresse table fonction */
	Move.L	16(A1),A1			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A1)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */
	Rts


/*---------------------------------------------------------------*/
/* +20                    FAST READ CONFIG BYTE                  */
/*---------------------------------------------------------------*/
	.even
__fast_read_config_byte:
	Move.L	4(SP),D0	/* Handle du device ... */
	Move.L	8(SP),D1	/* Num‚ro du Registre de configuration   */

	Move.L	_PCI_pt_fonction,A0	/* adresse table fonction */
	Move.L	20(A0),A0			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A0)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */
	Rts


/*---------------------------------------------------------------*/
/* +24                    FAST READ CONFIG WORD                  */
/*---------------------------------------------------------------*/
	.even
__fast_read_config_word:
	Move.L	4(SP),D0	/* Handle du device ... */
	Move.L	8(SP),D1	/* Num‚ro du Registre de configuration   */

	Move.L	_PCI_pt_fonction,A0	/* adresse table fonction */
	Move.L	24(A0),A0			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A0)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */
	Rts



/*---------------------------------------------------------------*/
/* +28                    FAST READ CONFIG LONGWORD              */
/*---------------------------------------------------------------*/
	.even
__fast_read_config_longword:
	Move.L	4(SP),D0	/* Handle du device ... */
	Move.L	8(SP),D1	/* Num‚ro du Registre de configuration   */

	Move.L	_PCI_pt_fonction,A0	/* adresse table fonction */
	Move.L	28(A0),A0			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A0)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */
	Rts


/*---------------------------------------------------------------*/
/* +32                    WRITE CONFIG BYTE                      */
/*---------------------------------------------------------------*/
	.even
__write_config_byte:
	Move.l	D2,Save_Reg1

	Move.L	 4(SP),D0	/* Handle du device ...     */
	Move.L	 8(SP),D1	/* Num‚ro du Registre de configuration */
	Move.L	12(SP),D2	/* data to write, bit 7..0  */

	Move.L	_PCI_pt_fonction,A0	/* adresse table fonction */
	Move.L	32(A0),A0			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A0)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */

	Move.L	Save_Reg1,D2
	Rts


/*---------------------------------------------------------------*/
/* +36                    WRITE CONFIG WORD                      */
/*---------------------------------------------------------------*/
	.even
__write_config_word:
	Move.l	D2,Save_Reg1

	Move.L	 4(SP),D0	/* Handle du device ...     */
	Move.L	 8(SP),D1	/* Num‚ro du Registre de configuration */
	Move.L	12(SP),D2	/* data to write, bit 7..0  */

	Move.L	_PCI_pt_fonction,A0	/* adresse table fonction */
	Move.L	36(A0),A0			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A0)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */

	Move.L	Save_Reg1,D2
	Rts


/*---------------------------------------------------------------*/
/* +40                    WRITE CONFIG LONGWORD                  */
/*---------------------------------------------------------------*/
	.even
__write_config_longword:
	Move.l	D2,Save_Reg1

	Move.L	 4(SP),D0	/* Handle du device ...     */
	Move.L	 8(SP),D1	/* Num‚ro du Registre de configuration */
	Move.L	12(SP),D2	/* data to write, bit 7..0  */

	Move.L	_PCI_pt_fonction,A0	/* adresse table fonction */
	Move.L	40(A0),A0			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A0)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */

	Move.L	Save_Reg1,D2
	Rts

/*---------------------------------------------------------------*/
/* +44                    HOOK INTERRUPT                         */
/*---------------------------------------------------------------*/
	.even
__hook_interrupt:
	Move.l	A2,Save_Reg1

	Move.L	 4(SP),D0	/* Handle du device ... */
	Move.L	 8(SP),A0	/* pointeur  to  interrupt handler */
	Move.L	12(SP),A1	/* parameter for interrupt handler */

	Move.L	_PCI_pt_fonction,A2	/* adresse table fonction */
	Move.L	44(A2),A2			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A2)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */

	Move.L	Save_Reg1,A2
	Rts

/*---------------------------------------------------------------*/
/* +48                    UNHOOK INTERRUPT                       */
/*---------------------------------------------------------------*/
	.even
__unhook_interrupt:
	Move.L	 4(SP),D0	/* Device Handle */

	Move.L	_PCI_pt_fonction,A0	/* adresse table fonction */
	Move.L	48(A0),A0			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A0)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */
	Rts


/*---------------------------------------------------------------*/
/* +52                    SPECIAL CYCLE                          */
/*---------------------------------------------------------------*/
	.even
__special_cycle:
	Move.L	 4(SP),D0	/* bus number         */
	Move.L	 8(SP),D1	/* special cycle data */

	Move.L	_PCI_pt_fonction,A0	/* adresse table fonction */
	Move.L	52(A0),A0			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A0)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */
	Rts


/*---------------------------------------------------------------*/
/* +56                    GET ROUTING INTERRUPT                  */
/*---------------------------------------------------------------*/
	.even
__get_routing:
	Move.L	 #-4,D0		/* To be defined. Not for */
						/* use by device drivers  */
	Rts


/*---------------------------------------------------------------*/
/* +60                    SET INTERRUPT HARDWARE                 */
/*---------------------------------------------------------------*/
	.even
__set_interrupt:
	Move.L	 #-4,D0		/* To be defined. Not for */
						/* use by device drivers  */
	Rts


/*---------------------------------------------------------------*/
/* +64                    GET RESOURCE DATA                      */
/*---------------------------------------------------------------*/
	.even
__get_resource:
	Move.L	 4(SP),D0	/* device handle */

	Move.L	_PCI_pt_fonction,A0	/* adresse table fonction */
	Move.L	64(A0),A0			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A0)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */
	Rts


/*---------------------------------------------------------------*/
/* +68                    GET CARD USED FLAG                     */
/*---------------------------------------------------------------*/
	.even
__get_card_used:
	Move.L	 4(SP),D0	/* device handle */
	Move.L	 8(SP),A0	/* pointer to longword where call-back */
						/* address is stored                   */

	Move.L	_PCI_pt_fonction,A1	/* adresse table fonction */
	Move.L	68(A1),A1			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A1)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */
	Rts


/*---------------------------------------------------------------*/
/* +72                    SET CARD USED FLAG                     */
/*---------------------------------------------------------------*/
	.even
__set_card_used:
	Move.L	 4(SP),D0	/* device handle */
	Move.L	 8(SP),A0	/* address of call-back entry (not pointer */
						/* to address!) or 0L, 1L or 3L            */

	Move.L	_PCI_pt_fonction,A1	/* adresse table fonction */
	Move.L	72(A1),A1			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A1)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */
	Rts


/*---------------------------------------------------------------*/
/* +76                    READ MEM BYTE                          */
/*---------------------------------------------------------------*/
	.even
__read_mem_byte:
	Move.L	  4(SP),D0	/* device handle */
	Move.L	  8(SP),D1	/* address to access (in PCI  */
						/* memory address space)      */
	Move.L	 12(SP),A0	/* pointe to data in memory   */

	Move.L	_PCI_pt_fonction,A1	/* adresse table fonction */
	Move.L	76(A1),A1			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A1)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */
	Rts


/*---------------------------------------------------------------*/
/* +80                    READ MEM WORD                          */
/*---------------------------------------------------------------*/
	.even
__read_mem_word:
	Move.L	  4(SP),D0	/* device handle */
	Move.L	  8(SP),D1	/* address to access (in PCI  */
						/* memory address space)      */
	Move.L	 12(SP),A0	/* pointe to data in memory   */

	Move.L	_PCI_pt_fonction,A1	/* adresse table fonction */
	Move.L	80(A1),A1			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A1)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */
	Rts


/*---------------------------------------------------------------*/
/* +84                    READ MEM LONGWORD                      */
/*---------------------------------------------------------------*/
	.even
__read_mem_longword:
	Move.L	  4(SP),D0	/* device handle */
	Move.L	  8(SP),D1	/* address to access (in PCI  */
						/* memory address space)      */
	Move.L	 12(SP),A0	/* pointe to data in memory   */

	Move.L	_PCI_pt_fonction,A1	/* adresse table fonction */
	Move.L	84(A1),A1			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A1)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */
	Rts


/*---------------------------------------------------------------*/
/* +88                    FAST READ MEM BYTE                     */
/*---------------------------------------------------------------*/
	.even
__fast_read_mem_byte:
	Move.L	  4(SP),D0	/* device handle */
	Move.L	  8(SP),D1	/* address to access (in PCI  */
						/* memory address space)      */

	Move.L	_PCI_pt_fonction,A0	/* adresse table fonction */
	Move.L	88(A0),A0			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A0)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */
	Rts


/*---------------------------------------------------------------*/
/* +92                    FAST READ MEM WORD                     */
/*---------------------------------------------------------------*/
	.even
__fast_read_mem_word:
	Move.L	  4(SP),D0	/* device handle */
	Move.L	  8(SP),D1	/* address to access (in PCI  */
						/* memory address space)      */

	Move.L	_PCI_pt_fonction,A0	/* adresse table fonction */
	Move.L	92(A0),A0			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A0)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */
	Rts


/*---------------------------------------------------------------*/
/* +96                    FAST READ MEM LONGWORD                 */
/*---------------------------------------------------------------*/
	.even
__fast_read_mem_longword:
	Move.L	  4(SP),D0	/* device handle */
	Move.L	  8(SP),D1	/* address to access (in PCI  */
						/* memory address space)      */

	Move.L	_PCI_pt_fonction,A0	/* adresse table fonction */
	Move.L	96(A0),A0			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A0)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */
	Rts


/*---------------------------------------------------------------*/
/* +100                   WRITE MEM BYTE                         */
/*---------------------------------------------------------------*/
	.even
__write_mem_byte:
	Move.l	D2,Save_Reg1
	
	Move.L	  4(SP),D0	/* device handle */
	Move.L	  8(SP),D1	/* address to access (in PCI  */
						/* memory address space)      */
	Move.L	 12(SP),D2	/* data to write in bits 7..0 */


	Move.L	_PCI_pt_fonction,A0	/* adresse table fonction */
	Move.L	100(A0),A0			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A0)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */

	Move.l	Save_Reg1,D2
	Rts


/*---------------------------------------------------------------*/
/* +104                   WRITE MEM WORD                         */
/*---------------------------------------------------------------*/
	.even
__write_mem_word:
	Move.l	D2,Save_Reg1
	
	Move.L	  4(SP),D0	/* device handle */
	Move.L	  8(SP),D1	/* address to access (in PCI  */
						/* memory address space)      */
	Move.L	 12(SP),D2	/* data to write in bits 7..0 */


	Move.L	_PCI_pt_fonction,A0	/* adresse table fonction */
	Move.L	104(A0),A0			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A0)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */

	Move.l	Save_Reg1,D2
	Rts


/*---------------------------------------------------------------*/
/* +108                   WRITE MEM LONGWORD                     */
/*---------------------------------------------------------------*/
	.even
__write_mem_longword:
	Move.l	D2,Save_Reg1
	
	Move.L	  4(SP),D0	/* device handle */
	Move.L	  8(SP),D1	/* address to access (in PCI  */
						/* memory address space)      */
	Move.L	 12(SP),D2	/* data to write in bits 7..0 */


	Move.L	_PCI_pt_fonction,A0	/* adresse table fonction */
	Move.L	108(A0),A0			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A0)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */

	Move.l	Save_Reg1,D2
	Rts


/*---------------------------------------------------------------*/
/* +112                   READ IO BYTE                           */
/*---------------------------------------------------------------*/
	.even
__read_io_byte:
	Move.L	  4(SP),D0	/* device handle */
	Move.L	  8(SP),D1	/* address to access (in PCI  */
						/* IO address space)          */
	Move.L	 12(SP),A0	/* data to write in bits 7..0 */


	Move.L	_PCI_pt_fonction,A1	/* adresse table fonction */
	Move.L	112(A1),A1			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A1)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */
	Rts


/*---------------------------------------------------------------*/
/* +116                   READ IO WORD                           */
/*---------------------------------------------------------------*/
	.even
__read_io_word:
	Move.L	  4(SP),D0	/* device handle */
	Move.L	  8(SP),D1	/* address to access (in PCI  */
						/* IO address space)          */
	Move.L	 12(SP),A0	/* data to write in bits 7..0 */


	Move.L	_PCI_pt_fonction,A1	/* adresse table fonction */
	Move.L	116(A1),A1			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A1)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */
	Rts


/*---------------------------------------------------------------*/
/* +120                   READ IO LONGWORD                       */
/*---------------------------------------------------------------*/
	.even
__read_io_longword:
	Move.L	  4(SP),D0	/* device handle */
	Move.L	  8(SP),D1	/* address to access (in PCI  */
						/* IO address space)          */
	Move.L	 12(SP),A0	/* data to write in bits 7..0 */


	Move.L	_PCI_pt_fonction,A1	/* adresse table fonction */
	Move.L	120(A1),A1			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A1)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */
	Rts


/*---------------------------------------------------------------*/
/* +124                   FAST READ IO BYTE                      */
/*---------------------------------------------------------------*/
	.even
__fast_read_io_byte:
	Move.L	  4(SP),D0	/* device handle */
	Move.L	  8(SP),D1	/* address to access (in PCI  */
						/* IO address space)          */

	Move.L	_PCI_pt_fonction,A0	/* adresse table fonction */
	Move.L	124(A0),A0			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A0)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */
	Rts


/*---------------------------------------------------------------*/
/* +128                   FAST READ IO WORD                      */
/*---------------------------------------------------------------*/
	.even
__fast_read_io_word:
	Move.L	  4(SP),D0	/* device handle */
	Move.L	  8(SP),D1	/* address to access (in PCI  */
						/* IO address space)          */

	Move.L	_PCI_pt_fonction,A0	/* adresse table fonction */
	Move.L	128(A0),A0			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A0)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */
	Rts


/*---------------------------------------------------------------*/
/* +132                   FAST READ IO LONGWORD                  */
/*---------------------------------------------------------------*/
	.even
__fast_read_io_longword:
	Move.L	  4(SP),D0	/* device handle */
	Move.L	  8(SP),D1	/* address to access (in PCI  */
						/* IO address space)          */

	Move.L	_PCI_pt_fonction,A0	/* adresse table fonction */
	Move.L	132(A0),A0			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A0)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */
	Rts


/*---------------------------------------------------------------*/
/* +136                   WRITE IO BYTE                          */
/*---------------------------------------------------------------*/
	.even
__write_io_byte:
	Move.L	D2,Save_Reg1
	Move.L	 4(SP),D0	/* device handle */
	Move.L	 8(SP),D1	/* address to access (in PCI  */
						/* IO address space)          */
	Move.L	12(SP),D2	/* data to write */

	Move.L	_PCI_pt_fonction,A0	/* adresse table fonction */
	Move.L	136(A0),A0			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A0)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */
	Move.L	Save_Reg1,D2
	Rts


/*---------------------------------------------------------------*/
/* +140                   WRITE IO WORD                          */
/*---------------------------------------------------------------*/
	.even
__write_io_word:
	Move.L	D2,Save_Reg1
	Move.L	 4(SP),D0	/* device handle */
	Move.L	 8(SP),D1	/* address to access (in PCI  */
						/* IO address space)          */
	Move.L	12(SP),D2	/* data to write */

	Move.L	_PCI_pt_fonction,A0	/* adresse table fonction */
	Move.L	140(A0),A0			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A0)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */
	Move.L	Save_Reg1,D2
	Rts


/*---------------------------------------------------------------*/
/* +144                   WRITE IO LONGWORD                      */
/*---------------------------------------------------------------*/
	.even
__write_io_longword:
	Move.L	D2,Save_Reg1
	Move.L	 4(SP),D0	/* device handle */
	Move.L	 8(SP),D1	/* address to access (in PCI  */
						/* IO address space)          */
	Move.L	12(SP),D2	/* data to write */

	Move.L	_PCI_pt_fonction,A0	/* adresse table fonction */
	Move.L	144(A0),A0			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A0)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */
	Move.L	Save_Reg1,D2
	Rts


/*---------------------------------------------------------------*/
/* +148                   GET MACHINE ID                         */
/*---------------------------------------------------------------*/
	.even
__get_machine_id:
	Clr.L	D0			/* on nettoie le registre */

	Move.L	_PCI_pt_fonction,A0	/* adresse table fonction */
	Move.L	148(A0),A0			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A0)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */
	rts


/*---------------------------------------------------------------*/
/* +152                   GET PAGE SIZE                          */
/*---------------------------------------------------------------*/
	.even
__get_pagesize:
	Clr.L	D0		/* Clear register */

	Move.L	_PCI_pt_fonction,A0	/* adresse table fonction */
	Move.L	152(A0),A0			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A0)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */
	rts


/*---------------------------------------------------------------*/
/* +156                   VIRT TO BUS                            */
/*---------------------------------------------------------------*/
	.even
__virt_to_bus:
	Move.L	 4(SP),D0	/* device handle */
	Move.L	 8(SP),D1	/* address in virtual CPU space */
	Move.L	12(SP),A0	/* pointer to mem-struct for results */

	Move.L	_PCI_pt_fonction,A1	/* adresse table fonction */
	Move.L	156(A1),A1			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A1)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */
	Rts


/*---------------------------------------------------------------*/
/* +160                   BUS TO VIRT                            */
/*---------------------------------------------------------------*/
	.even
__bus_to_virt:
	Move.L	 4(SP),D0	/* device handle   */
	Move.L	 8(SP),D1	/* PCI bus address */
	Move.L	12(SP),A0	/* pointer to mem-struct for results */

	Move.L	_PCI_pt_fonction,A1	/* adresse table fonction */
	Move.L	160(A1),A1			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A1)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */
	Rts


/*---------------------------------------------------------------*/
/* +164                   VIRT TO PHYS                           */
/*---------------------------------------------------------------*/
	.even
__virt_to_phys:
	Move.L	4(SP),D0	/* address in virtual CPU space      */
	Move.L	8(SP),A0	/* pointer to mem-struct for results */

	Move.L	_PCI_pt_fonction,A1	/* adresse table fonction */
	Move.L	164(A1),A1			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A1)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */
	Rts


/*---------------------------------------------------------------*/
/* +168                   PHYS TO VIRT                           */
/*---------------------------------------------------------------*/
	.even
__phys_to_virt:
	Move.L	4(SP),D0	/* physical CPU address */
	Move.L	8(SP),A0	/* pointer to mem-struct for results */

	Move.L	_PCI_pt_fonction,A1	/* adresse table fonction */
	Move.L	168(A1),A1			/* adresse de la fonction */

	Move.L	SP,Old_SP	/* on sauve la Pile systŠme */
	Lea		My_Pile,SP	/* On place la notre */

	Jsr		(A1)		/* saut … la fonction Find PCI Device */

	Move.L	Old_SP,SP	/* on resitue l'ancienne Pile systŠme */
	Rts



/*===============================================================*/
	.data
	.comm	data,4096
	.comm	My_Pile,4
	.even
	.comm	Old_SP,4
	.even
	.globl	_PCI_pt_fonction
	.comm	_PCI_pt_fonction,4
	.even
	.comm	Save_Reg1,4


