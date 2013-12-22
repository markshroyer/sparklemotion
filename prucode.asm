.origin 0
.entrypoint START


;;; 
;;; M4 macros
;;;

;; So that we don't have to manually declare a unique label name for each
;; delay loop we write (for label arg of the _NDELAY PASM macro):
define(`concat', $1$2)
define(`ndelay', `_NDELAY $1, $2, concat(_ndelay_, __line__)')


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

.macro ST32
.mparam src,dst
    SBBO    src,dst,#0x00,4
.endm


;;; 
;;; Program
;;;

START:

    MOV     r1, 1000

    ;; Enable OCP master port

    LBCO    r0, CONST_PRUCFG, 4, 4
    CLR     r0, r0, 4      ; Clear SYSCFG[STANDBY_INIT] to enable OCP master port
    SBCO    r0, CONST_PRUCFG, 4, 4

    ;; Configure the programmable pointer register for PRU0 by setting
    ;; c28_pointer[15:0] field to 0x0120.  This will make C28 point to
    ;; 0x00012000 (PRU shared RAM).

    MOV     r0, 0x00000120
    MOV     r1, CTPPR_0
    ST32    r0, r1

    ;; Configure the programmable pointer register for PRU0 by setting
    ;; c31_pointer[15:0] field to 0x0010.  This will make C31 point to
    ;; 0x80001000 (DDR memory).

    MOV     r0, 0x00100000
    MOV     r1, CTPPR_1
    ST32    r0, r1

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
