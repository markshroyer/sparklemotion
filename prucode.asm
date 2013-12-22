.origin 0
.entrypoint START


;;; 
;;; M4 macros
;;;

;; So that we don't have to manually declare a unique label name for each
;; delay loop we write (for label arg of the _NDELAY PASM macro):
define(`concat', $1$2)
define(`ndelay', `_NDELAY $1, $2, concat(_ndelay_, __line__)')
define(`ncount', `_NCOUNT $1, concat(_ncount_, __line__)')

define(`nsecs', `$1 / 5')


;;; 
;;; PASM defines
;;;

#define CONST_PRUCFG C4
#define PRU0_ARM_INTERRUPT 19
#define GPIO1 0x4804c000
#define GPIO1_CLEARDATAOUT 0x190
#define GPIO1_SETDATAOUT 0x194
#define CTPPR_0 0x22028
#define CTPPR_1 0x2202C


;;; 
;;; PASM macros
;;;

.macro NOP
    MOV r0, r0
.endm

.macro SIGHIGH
    SET     r30.t14
.endm

.macro SIGLOW
    CLR     r30.t14
.endm

.macro _NDELAY
.mparam ns, del, label
    MOV     r2, ns/10 - del/2 - 1
label:  
    SUB     r2, r2, 1
    QBNE    label, r2, 0
.endm

.macro _NCOUNT
.mparam ns, label
label:
    LBCO    r2, c28, 0x0c, 4
    QBGT    label, r2, (ns)/5
.endm

.macro ST32
.mparam src,dst
    SBBO    src,dst,#0x00,4
.endm


;;; 
;;; Program
;;;

START:

    ;; Make C28 point to the control register (0x22000)
    MOV     r0, 0x00000220
    MOV     r1, CTPPR_0
    ST32    r0, r1

    ;; Disable and reset PRU cycle counter
    LBCO    r0, c28, 0, 4
    CLR     r0, r0, 3
    SBCO    r0, c28, 0, 4
    MOV     r0, 1
    SBCO    r0, c28, 0x0c, 4

    ;; Prepare message pointers:
    ;; r20 = end of message address + 1
    ;; r21 = next byte to encode
    LBCO    r20, c24, 0, 4
    ADD     r20, r20, 4
    MOV     r21, 4

    ;; Message counter:
    ;; r22 = cycle start time
    MOV     r22, 0

    ;; Signal high and start counter
    LBCO    r0, c28, 0, 4
    SET     r0, r0, 3
    SIGHIGH
    SBCO    r0, c28, 0, 4

WRITE_BYTE:

    SIGHIGH

    ;; r23 = current byte
    ;; r24 = bit number
    MOV     r1, r21
    LBCO    r23, c24, r21, 1
    ADD     r21, r21, 1
    LDI     r24, 8

WRITE_BIT:

    SIGHIGH

    SUB     r24, r24, 1
    LDI     r0, nsecs(1200)
    QBBS    WRITE_BIT_IS_ZERO, r23, r24
    LDI     r0, nsecs(500)

WRITE_BIT_IS_ZERO:

    ADD     r0, r0, r22

WRITE_BIT_WAIT_HIGH:

    LBCO    r1, c28, 0x0c, 4
    QBGT    WRITE_BIT_WAIT_HIGH, r1, r0

    SIGLOW

WRITE_BIT_WAIT_LOW:

    LDI     r0, nsecs(2500)
    ADD     r22, r22, r0
    LBCO    r1, c28, 0x0c, 4
    QBGT    WRITE_BIT_WAIT_LOW, r1, r22

    QBNE    WRITE_BIT, r24, 0

    QBGT    WRITE_BYTE, r21, r20

    ;; 50ns reset time specified for ws2811
    ndelay(60, 0)

    ;; Signal program completion
    MOV     r31.b0, PRU0_ARM_INTERRUPT+16
    HALT
