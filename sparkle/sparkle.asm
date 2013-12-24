;; Run this through M4 before handing to PASM...

.origin 0
.entrypoint start


;;; 
;;; M4 macros
;;;

;; So that we don't have to manually declare a unique label name for each
;; delay loop we write (for label arg of the _NDELAY PASM macro):
define(`concat', $1$2)
define(`ndelay', `_ndelay $1, $2, concat(_ndelay_, __line__)')
define(`ncount', `_ncount $1, concat(_ncount_, __line__)')
define(`waitcount', `_waitcount $1, concat(_waitcount_, __line__)')

define(`nsecs', `($1) / 5')


;;; 
;;; PASM macros
;;;

#define DATA_T0H_NS 350
#define DATA_T1H_NS 700
#define DATA_T_NS 2500

#define CONST_INTC c0
#define CONST_PRUCFG c4
#define CONST_DATA c24
#define CONST_CTRL c28

#define GPIO1 0x4804c000
#define GPIO1_CLEARDATAOUT 0x190
#define GPIO1_SETDATAOUT 0x194
#define CTPPR_0 0x22028
#define CTPPR_1 0x2202C

#define PRU0_ARM_INTERRUPT 19
#define ARM_PRU0_INTERRUPT 21


.macro nop
    mov r0, r0
.endm

.macro datahigh
    set     r30.t14
.endm

.macro datalow
    clr     r30.t14
.endm

.macro _ndelay
.mparam ns, del, label
    mov     r2, ns/10 - del/2 - 1
label:  
    sub     r2, r2, 1
    qbne    label, r2, 0
.endm

.macro _ncount
.mparam ns, label
label:
    lbco    r2, CONST_CTRL, 0x0c, 4
    qbgt    label, r2, (ns)/5
.endm

.macro _waitcount
.mparam count, label
label:
    lbco    r2, CONST_CTRL, 0x0c, 4
    qbgt    label, r2, count
.endm

.macro st32
.mparam src,dst
    sbbo    src,dst,#0x00,4
.endm

.macro inc
.mparam dst, val
    add     dst, dst, val
.endm

.macro dec
.mparam dst, val
    sub     dst, dst, val
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

start:

    ;; Make C28 point to the control register (0x22000)
    mov     r0, 0x00000220
    mov     r1, CTPPR_0
    st32    r0, r1

    ;; Wake up when host sends event
    lbco    r0, CONST_CTRL, 0x08, 4
    set     r0, r0, 30
    sbco    r0, CONST_CTRL, 0x08, 4

await_data:
    
    ;; Let the host know we're ready for data
    mov     r31.b0, PRU0_ARM_INTERRUPT+16

    ;; Wait for event from host indicating we have something to do
_await_interrupt:
    slp     1
    qbbc    _await_interrupt, r31, 30

    ;; Clear interrupt
    ldi     r0, ARM_PRU0_INTERRUPT
    sbco    r0, c0, 0x24, 4

    ;; Current bit offset
    ldi     d.bit_num, 7

    ;; Current byte offset (first four bytes are data length count)
    ldi     d.cur_byte_p, 4
    lbco    d.byte, CONST_DATA, d.cur_byte_p, 1

    ;; End byte offset
    lbco    d.end_byte_p, CONST_DATA, 0, 4      ; Loading into 16-bit reg
    qbne    _non_null_message, d.end_byte_p, 0
    slp     0
_non_null_message:
    inc     d.end_byte_p, 4

    ;; Transition low cycle count
    ldi     d.count_end_high, nsecs(DATA_T0H_NS)

    ;; End period cycle count
    ldi     d.count_end_period, nsecs(DATA_T_NS)

    ;; Disable and reset PRU cycle counter
    lbco    r0, c28, 0, 4
    clr     r0, r0, 3
    sbco    r0, c28, 0, 4
    mov     r0, 0
    sbco    r0, c28, 0x0c, 4

    ;; Start counter
    lbco    r0, c28, 0, 4
    set     r0, r0, 3
    sbco    r0, c28, 0, 4

write_bit:

    datahigh

    ;; Adjust transition time if current bit is high
    mov     d.count_next_trans, d.count_end_high
    qbbc    _sending_zero, d.byte, d.bit_num
    ldi     r4, nsecs(DATA_T1H_NS - DATA_T0H_NS)
    inc     d.count_next_trans, r4
_sending_zero:
    waitcount(d.count_next_trans)

    datalow

    mov     d.count_next_trans, d.count_end_period

    ;; Increment counter wait values
    ldi     r0, nsecs(DATA_T_NS)
    inc     d.count_end_high, r0
    inc     d.count_end_period, r0

    ;; Move to next bit (and possibly next byte)
    qbne    _same_byte, d.bit_num, 0
    inc     d.cur_byte_p, 1
    lbco    d.byte, CONST_DATA, d.cur_byte_p, 1
    mov     d.bit_num, 8
_same_byte:
    dec     d.bit_num, 1

    waitcount(d.count_next_trans)

    ;; Loop if we haven't hit the end
    qblt    write_bit, d.end_byte_p, d.cur_byte_p

    ;; 50ns reset time specified for ws2811
    ndelay(50, 0)

    qba     await_data
