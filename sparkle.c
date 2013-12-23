#include "sparkle.h"

#include <prussdrv.h>
#include <pruss_intc_mapping.h>

#include <stdio.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>


#define PRU_NUM 	 0

#define DDR_BASEADDR     0x80000000
#define OFFSET_DDR	 0x00001000
#define OFFSET_SHAREDRAM 2048		//equivalent with 0x00002000

#define PRUSS0_SHARED_DATARAM    4

#define BUF_MAX 4096

uint8_t sparkle_max_luminance = 0xff;
static uint8_t *adj_buf = NULL;

int sparkle_init(void)
{
    unsigned int ret;
    tpruss_intc_initdata pruss_intc_initdata = PRUSS_INTC_INITDATA;

    prussdrv_init();

    /* Open PRU Interrupt */
    ret = prussdrv_open(PRU_EVTOUT_0);
    if (ret) {
        printf("prussdrv_open open failed\n");
        return -1;
    }

    /* Get the interrupt initialized */
    prussdrv_pruintc_init(&pruss_intc_initdata);
    prussdrv_exec_program(PRU_NUM, "./sparkle.bin");

    adj_buf = malloc(BUF_MAX);
    if (! adj_buf) {
        return -1;
    }

    return 0;
}

void sparkle_exit(void)
{
    /* Disable PRU and close memory mapping*/
    free(adj_buf);
    prussdrv_pru_disable(PRU_NUM);
    prussdrv_exit();
}

void sparkle_write(const uint8_t *buf, uint32_t buf_sz)
{
    int i;
    uint32_t tmp;

    if (buf_sz > BUF_MAX)
        return;

    /* Write data */
    prussdrv_pru_write_memory(PRUSS0_PRU0_DATARAM, 0,
                              (unsigned int *)&buf_sz, sizeof(buf_sz));
    if (sparkle_max_luminance == 0xff) {
        prussdrv_pru_write_memory(PRUSS0_PRU0_DATARAM, 1,
                                  (unsigned int *)buf, buf_sz);
    } else {
        for (i = 0; i < buf_sz; i++) {
            tmp = (uint32_t)buf[i];
            tmp *= sparkle_max_luminance;
            tmp /= 0xff;
            adj_buf[i] = (uint8_t)tmp;
        }
        prussdrv_pru_write_memory(PRUSS0_PRU0_DATARAM, 1,
                                  (unsigned int *)adj_buf, buf_sz);
    }
    prussdrv_pru_send_event(ARM_PRU0_INTERRUPT);

    /* Wait until PRU0 has finished execution */
    prussdrv_pru_wait_event(PRU_EVTOUT_0);
    prussdrv_pru_clear_event(PRU0_ARM_INTERRUPT);
}
