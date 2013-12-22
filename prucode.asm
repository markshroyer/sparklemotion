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

.macro CLRCOUNT
    ;; Disable the counter
    LBCO    r0, c28, 0, 4
    CLR     r0, r0, 3
    SBCO    r0, c28, 0, 4

    ;; Clear the count
    MOV     r1, 0
    SBCO    r1, c28, 0x0c, 4

    ;; (Re-)enable the counter
    SET     r0, r0, 3
    SBCO    r0, c28, 0, 4
.endm


;;; 
;;; Program
;;;

START:

    ;; Make C28 point to the control register (0x22000)
    MOV     r0, 0x00000220
    MOV     r1, CTPPR_0
    ST32    r0, r1

    LBCO    r5, c24, 0, 4

MAINLOOP:

    CLRCOUNT

    SIGHIGH
    ncount(100)
    SIGLOW
    ncount(100)

    SUB     r5, r5, 1
    QBNE    MAINLOOP, r5, 0

    ;; Signal program completion
    MOV     r31.b0, PRU0_ARM_INTERRUPT+16
    HALT
