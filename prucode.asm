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

define(`nsecs', `($1) / 5')


;;; 
;;; PASM macros
;;;

#define DATA_T0H_NS 350
#define DATA_T1H_NS 700
#define DATA_T_NS 2500

#define CONST_PRUCFG C4
#define PRU0_ARM_INTERRUPT 19
#define GPIO1 0x4804c000
#define GPIO1_CLEARDATAOUT 0x190
#define GPIO1_SETDATAOUT 0x194
#define CTPPR_0 0x22028
#define CTPPR_1 0x2202C

#define ARM_PRU0_INTERRUPT 21


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

.macro INC
.mparam dst, val
    ADD     dst, dst, val
.endm

.macro DEC
.mparam dst, val
    SUB     dst, dst, val
.endm

.struct Data
    .u16    cur_byte_p
    .u16    end_byte_p
    .u32    count_end_high
    .u32    count_end_period
    .u32    count_next_trans
    .u8     byte
    .u8     bit_num
.ends

.assign     Data, r10, r14.b1, d


;;; 
;;; Program
;;;

START:

    ;; Enable master OCP
    LBCO    r0, c4, 4, 4
    CLR     r0.t4
    SBCO    r0, c4, 4, 4

    ;; Make C28 point to the control register (0x22000)
    MOV     r0, 0x00000220
    MOV     r1, CTPPR_0
    ST32    r0, r1

;    ;; Wake up when host sends event
;    LBCO    r0, c28, 0x08, 4
;    SET     r0, r0, ARM_PRU0_INTERRUPT
;    SBCO    r0, c28, 0x08, 4

AWAIT_DATA:

    ;; Wait for event from host, indicating that data is ready
;    SLP     1
    QBBC    AWAIT_DATA, r31, 30

    ;; Clear interrupt
    LDI     r0, ARM_PRU0_INTERRUPT
    SBCO    r0, c0, 0x24, 4

    ;; Current bit offset
    LDI     d.bit_num, 7
    ;; Current byte offset (first two bytes are data length count)
    LDI     d.cur_byte_p, 2
    LBCO    d.byte, c24, d.cur_byte_p, 1
    ;; End byte offset
    LBCO    d.end_byte_p, c24, 0, 2
    INC     d.end_byte_p, 2
    ;; Transition low cycle count
    LDI     d.count_end_high, nsecs(DATA_T0H_NS)
    ;; End period cycle count
    LDI     d.count_end_period, nsecs(DATA_T_NS)

    ;; Disable and reset PRU cycle counter
    LBCO    r0, c28, 0, 4
    CLR     r0, r0, 3
    SBCO    r0, c28, 0, 4
    MOV     r0, 0
    SBCO    r0, c28, 0x0c, 4

;    ;; Scope trigger
;    DATAHIGH
;    ndelay(10000, 0)
;    DATALOW
;    ndelay(10000, 0)

    ;; Start counter
    LBCO    r0, c28, 0, 4
    SET     r0, r0, 3
    SBCO    r0, c28, 0, 4

WRITE_BIT:

    DATAHIGH

    ;; Adjust transition time if current bit is high
    MOV     d.count_next_trans, d.count_end_high
    QBBC    CURRENT_BIT_IS_ZERO, d.byte, d.bit_num
    LDI     r4, nsecs(DATA_T1H_NS - DATA_T0H_NS)
    INC     d.count_next_trans, r4
CURRENT_BIT_IS_ZERO:

    ;; Wait for end of T?H
WRITE_BIT_WAIT_HIGH:
    LBCO    r1, c28, 0x0c, 4
    QBGT    WRITE_BIT_WAIT_HIGH, r1, d.count_next_trans

    DATALOW

    MOV     d.count_next_trans, d.count_end_period

    ;; Increment counter wait values
    LDI     r0, nsecs(DATA_T_NS)
    INC     d.count_end_high, r0
    INC     d.count_end_period, r0

    ;; Move to next bit (and possibly next byte)
    QBNE    BIT_OFFSET_NONZERO, d.bit_num, 0
    INC     d.cur_byte_p, 1
    LBCO    d.byte, c24, d.cur_byte_p, 1
    MOV     d.bit_num, 8
BIT_OFFSET_NONZERO:
    DEC     d.bit_num, 1

    ;; Wait for end of period
WRITE_BIT_WAIT_LOW:
    LBCO    r1, c28, 0x0c, 4
    QBGT    WRITE_BIT_WAIT_LOW, r1, d.count_next_trans

    ;; Loop if we haven't hit the end
    QBLT    WRITE_BIT, d.end_byte_p, d.cur_byte_p

    ;; 50ns reset time specified for ws2811
    ndelay(50, 0)

    ;; Signal program completion
    MOV     r31.b0, PRU0_ARM_INTERRUPT+16

    QBA     AWAIT_DATA
