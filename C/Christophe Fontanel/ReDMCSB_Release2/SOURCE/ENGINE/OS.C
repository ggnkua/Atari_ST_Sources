#include "DEFS.H"

/*_Global variables_*/
char* G518_pc_SystemCallReturnAddress;


overlay "main"

asm {
        R055_xxxx_OS_CallBIOS:
                move.l  A2,D3                                                   /* Backup A2 register in D3 */
                move.l  (A7)+,G518_pc_SystemCallReturnAddress(A4)               /* Backup return address and remove it from the stack */
                trap    #13                                                     /* Call BIOS */
                movea.l G518_pc_SystemCallReturnAddress(A4),A0                  /* Restore return address */
                movea.l D3,A2                                                   /* Restore A2 from D3 */
                jmp     (A0)                                                    /* Jump to return address */
        R056_aaal_OS_CallXBIOS:
                move.l  A2,D3                                                   /* Backup A2 register in D3 */
                move.l  (A7)+,G518_pc_SystemCallReturnAddress(A4)               /* Backup return address and remove it from the stack */
                trap    #14                                                     /* Call XBIOS */
                movea.l G518_pc_SystemCallReturnAddress(A4),A0                  /* Restore return address */
                movea.l D3,A2                                                   /* Restore A2 from D3 */
                jmp     (A0)                                                    /* Jump to return address */
        R057_rzzz_OS_CallGEMDOS:
                move.l  A2,D3                                                   /* Backup A2 register in D3 */
                move.l  (A7)+,G518_pc_SystemCallReturnAddress(A4)               /* Backup return address and remove it from the stack */
                trap    #1                                                      /* Call GEMDOS */
                movea.l G518_pc_SystemCallReturnAddress(A4),A0                  /* Restore return address */
                movea.l D3,A2                                                   /* Restore A2 from D3 */
                jmp     (A0)                                                    /* Jump to return address */
        S058_xxxx_OS_Exception257Handler_CriticalError:
                moveq   #-1,D0                                                  /* This handler simply returns -1 */
                rts
        S059_aaac_OS_SetException257Vector_CriticalError:
                lea     S058_xxxx_OS_Exception257Handler_CriticalError(PC),A0
                move.l  A0,C0x0404_ADDRESS_SYSTEM_VARIABLE_etv_critic           /* Replace the default critical error handler by the custom handler */
                rts
}
