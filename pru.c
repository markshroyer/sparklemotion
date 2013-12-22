#include <prussdrv.h>
#include <pruss_intc_mapping.h>

#include <stdio.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <string.h>
#include <stdint.h>
#include <time.h>
#include <stdlib.h>


#define PRU_NUM 	 0

#define DDR_BASEADDR     0x80000000
#define OFFSET_DDR	 0x00001000
#define OFFSET_SHAREDRAM 2048		//equivalent with 0x00002000

#define PRUSS0_SHARED_DATARAM    4

#define NLEDS 5
#define DATA_SZ (3 * NLEDS)
#define MSG_SZ (2 + DATA_SZ)


int main(void)
{
    unsigned int ret;
    tpruss_intc_initdata pruss_intc_initdata = PRUSS_INTC_INITDATA;
    void *msg;
    uint8_t *data;
    int led;
    int color;
    struct timespec delay = { 0, 100000000 };

    msg = malloc(MSG_SZ);
    if (! msg) {
        printf("Could not allocate message buffer\n");
        exit(1);
    }

    *((uint16_t *) msg) = MSG_SZ;
    data = (uint8_t *)(msg + 2);

    prussdrv_init();

    /* Open PRU Interrupt */
    ret = prussdrv_open(PRU_EVTOUT_0);
    if (ret)
    {
        printf("prussdrv_open open failed\n");
        return ret;
    }

    /* Get the interrupt initialized */
    prussdrv_pruintc_init(&pruss_intc_initdata);

    for (color = 0; 1; color = (color + 1) % 3) {
        for (led = 0; led < NLEDS; led++) {
            memset(data, 0, DATA_SZ);
            data[3*led + color] = 0x80;

            prussdrv_pru_write_memory(PRUSS0_PRU0_DATARAM, 0,
                                      (unsigned int *)msg, MSG_SZ);
            prussdrv_exec_program(PRU_NUM, "./prucode.bin");

            /* Wait until PRU0 has finished execution */
            prussdrv_pru_wait_event(PRU_EVTOUT_0);
            prussdrv_pru_clear_event(PRU0_ARM_INTERRUPT);

            nanosleep(&delay, NULL);
        }
    }

    /* Disable PRU and close memory mapping*/
    prussdrv_pru_disable(PRU_NUM);
    prussdrv_exit();

    free(msg);

    return 0;
}
