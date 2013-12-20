.origin 0
.entrypoint START

#include "prucode.hp"

#define GPIO1 0x4804c000
#define GPIO1_CLEARDATAOUT 0x190
#define GPIO1_SETDATAOUT 0x194
#define NOP MOV r0, r0

START:

    // Enable OCP master port
    LBCO    r0, CONST_PRUCFG, 4, 4
    CLR     r0, r0, 4
    SBCO    r0, CONST_PRUCFG, 4, 4

    MOV     r0, 0x00000120
    MOV     r1, CTPPR_0
    ST32    r0, r1

    MOV     r0, 0x00100000
    MOV     r1, CTPPR_1
    ST32    r0, r1

    LBCO    r0, CONST_DDR, 0, 12

    SBCO    r0, CONST_PRUSHAREDRAM, 0, 12

    MOV     r1, 10000000 // loop 10,000,000 times

LOOPY:

    SET     r30.t14
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    CLR     r30.t14
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP

    SUB     r1, r1, 1
    QBNE    LOOPY, r1, 0
    SBBO    r2, r4, 0, 4

    MOV     r31.b0, PRU0_ARM_INTERRUPT+16
    HALT
