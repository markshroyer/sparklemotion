// -*- mode: asm; -*-

.origin 0
.entrypoint START

#define PRU0_ARM_INTERRUPT 19
#define GPIO1 0x4804c000
#define GPIO1_CLEARDATAOUT 0x190
#define GPIO1_SETDATAOUT 0x194

#define _NDELAY_LABEL(prefix, num) prefix##num
#define _NDELAY(ns, del, num) _NDELAY_CODE ns, del, _NDELAY_LABEL(delay_label_, num)
#define NDELAY(ns, del) _NDELAY(ns, del, __COUNTER__)

.macro NOP
    MOV r0, r0
.endm

.macro SIGHIGH
    SET     r30.t14
.endm

.macro SIGLOW
    CLR     r30.t14
.endm

.macro _NDELAY_CODE
.mparam ns, del, label
    MOV     r2, ns/10 - del/2 - 1
label:  
    SUB     r2, r2, 1
    QBNE    label, r2, 0
.endm

START:

    MOV     r1, 1000

MAINLOOP:

    SIGHIGH
    NDELAY(30, 1)
    SIGLOW
    NDELAY(30, 3)

    SUB     r1, r1, 1
    QBNE    MAINLOOP, r1, 0

    // Signal program completion
    MOV     r31.b0, PRU0_ARM_INTERRUPT+16
    HALT
