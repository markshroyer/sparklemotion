.origin 0
.entrypoint START


;; 
;; M4 macros
;;

define(`concat', $1$2)dnl
define(`ndelay', `_NDELAY $1, $2, concat(_ndelay_, __line__)')dnl


;; 
;; PASM defines
;;

#define PRU0_ARM_INTERRUPT 19
#define GPIO1 0x4804c000
#define GPIO1_CLEARDATAOUT 0x190
#define GPIO1_SETDATAOUT 0x194


;; 
;; PASM macros
;;

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


;; 
;; Program
;;

START:

    MOV     r1, 1000

MAINLOOP:

    SIGHIGH
    ndelay(30, 1)
    SIGLOW
    ndelay(30, 3)
    NOP

    SUB     r1, r1, 1
    QBNE    MAINLOOP, r1, 0

    ;; Signal program completion
    MOV     r31.b0, PRU0_ARM_INTERRUPT+16
    HALT
