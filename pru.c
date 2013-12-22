#include <prussdrv.h>
#include <pruss_intc_mapping.h>

#include <stdio.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <string.h>
#include <stdint.h>


#define PRU_NUM 	 0

#define DDR_BASEADDR     0x80000000
#define OFFSET_DDR	 0x00001000
#define OFFSET_SHAREDRAM 2048		//equivalent with 0x00002000

#define PRUSS0_SHARED_DATARAM    4


int main(void)
{
    unsigned int ret;
    tpruss_intc_initdata pruss_intc_initdata = PRUSS_INTC_INITDATA;
    uint8_t data[] = { 0x06, 0x00, 0xff, 0xff, 0xff, 0x55, 0x55, 0x55 };

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

    prussdrv_pru_write_memory(PRUSS0_PRU0_DATARAM, 0, (unsigned int *)data, sizeof(data));
    prussdrv_exec_program(PRU_NUM, "./prucode.bin");

    /* Wait until PRU0 has finished execution */
    prussdrv_pru_wait_event(PRU_EVTOUT_0);
    prussdrv_pru_clear_event(PRU0_ARM_INTERRUPT);

    /* Disable PRU and close memory mapping*/
    prussdrv_pru_disable(PRU_NUM);
    prussdrv_exit();

    return 0;
}
