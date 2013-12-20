.origin 0
.entrypoint START

#define PRU0_ARM_INTERRUPT 19
#define GPIO1 0x4804c000
#define GPIO1_CLEARDATAOUT 0x190
#define GPIO1_SETDATAOUT 0x194

.macro NOP
    MOV r0, r0
.endm

.macro SIGHIGH
    SET     r30.t14
.endm

.macro SIGLOW
    CLR     r30.t14
.endm

START:

    MOV     r1, 1000

MAINLOOP:

    SIGHIGH
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    SIGLOW
    NOP
    NOP
    NOP
    NOP
    NOP

    SUB     r1, r1, 1
    QBNE    MAINLOOP, r1, 0

    // Signal program completion
    MOV     r31.b0, PRU0_ARM_INTERRUPT+16
    HALT
