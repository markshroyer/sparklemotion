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

#define DATA_T0H_NS 700
#define DATA_T1H_NS 350
#define DATA_T_NS 2500

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

.macro DATAHIGH
    SET     r30.t14
.endm

.macro DATALOW
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

;; 
;; Register file:
;;
;; r0-r9 = scratch
;; r10.b0 = current bit offset
;; r11.w0 = current byte offset
;; r11.w1 = end byte offset
;; r12 = T0H end at cycle count
;; r13 = end period at cycle count
;; r14 = next transition cycle count
;; 
    
START:

    ;; Make C28 point to the control register (0x22000)
    MOV     r0, 0x00000220
    MOV     r1, CTPPR_0
    ST32    r0, r1

    ;; Current bit offset
    LDI     r10.b0, 7
    ;; Current byte offset (first two bytes are data length count)
    LDI     r11.w0, 2
    ;; End byte offset
;    LBCO    r11.w1, c24, 0, 2
;    ADD     r11.w1, r11.w1, 2
    LDI     r11.w1, 20
    ;; Transition low cycle count
    LDI     r12, nsecs(DATA_T0H_NS)
    ;; End period cycle count
    LDI     r13, nsecs(DATA_T_NS)

    ;; Disable and reset PRU cycle counter
    LBCO    r0, c28, 0, 4
    CLR     r0, r0, 3
    SBCO    r0, c28, 0, 4
    MOV     r0, 0
    SBCO    r0, c28, 0x0c, 4

    ;; Start counter
    LBCO    r0, c28, 0, 4
    SET     r0, r0, 3
    SBCO    r0, c28, 0, 4

WRITE_BIT:

    DATAHIGH

    ;; Adjust transition time if current bit is high
    MOV     r14, r12
;    LBCO    r4.b0, c24, r11.w0, 1
;    QBBC    CURRENT_BIT_IS_ZERO, r4.b0, r10.b0
;    ADD     r14, r14, nsecs(DATA_T1H_NS - DATA_T0H_NS)
;CURRENT_BIT_IS_ZERO:

    ;; Wait for end of T?H
WRITE_BIT_WAIT_HIGH:
    LBCO    r1, c28, 0x0c, 4
    QBGT    WRITE_BIT_WAIT_HIGH, r1, r14

    DATALOW

    MOV     r14, r13

    ;; Increment counter wait values
    LDI     r0, nsecs(DATA_T_NS)
    ADD     r12, r12, r0
    ADD     r13, r13, r0

;    ;; Move to next bit (and possibly next byte)
;    QBNE    BIT_OFFSET_NONZERO, r10.b0, 0
;    MOV     r10.b0, 8
    ADD     r11.w0, r11.w0, 1
;BIT_OFFSET_NONZERO:
;    SUB     r10.b0, r10.b0, 1

    ;; Wait for end of period
WRITE_BIT_WAIT_LOW:
    LBCO    r1, c28, 0x0c, 4
    QBGT    WRITE_BIT_WAIT_LOW, r1, r14

    ;; Loop if we haven't hit the end
    MOV     r5, 0
    MOV     r6, 0
    MOV     r5, r11.w0
    MOV     r6, r11.w1
    QBLT    WRITE_BIT, r6, r5

    ;; 50ns reset time specified for ws2811
    ndelay(50, 0)

    ;; Signal program completion
    MOV     r31.b0, PRU0_ARM_INTERRUPT+16
    HALT
