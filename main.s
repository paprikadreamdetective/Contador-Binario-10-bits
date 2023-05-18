.thumb              @ Assembles using thumb mode
.cpu cortex-m3      @ Generates Cortex-M3 instructions
.syntax unified

.include "ivt.s"
.include "gpio_map.inc"
.include "rcc_map.inc"

.section .text
.align	1
.syntax unified
.thumb
.global __main


// void setup() ---------------------------------------------------------------
__main:
        push    {r7, lr}
        sub     sp, sp, #20
        add     r7, sp, #0
        // Habilitar señal de reloj para los puertos A y B.
        ldr     r0, =RCC_BASE
        mov     r3, 0xc
        str     r3, [r0, RCC_APB2ENR_OFFSET]
        /*Configuramos los puertos de entrada*/
        // Inicializar las salidas
        ldr     r0, =GPIOB_BASE
        ldr     r3, =0x44444488
        str     r3, [r0, GPIOx_CRH_OFFSET]
        /* int i = 1024*/
        mov     r3, #1024
        str     r3, [r7]
        /* const buttonA */
        mov     r3, #0
        str     r3, [r7, #4]
        /* const buttonB */
        mov     r3, #0
        str     r3, [r7, #8]
// void loop()
loop:
        // read button A
        mov     r0, #1
        bl      is_button_pressed
        mov     r3, r0
        str     r3, [r7, #4]
        // read button B
        mov     r0, #2
        bl      is_button_pressed
        mov     r3, r0
        str     r3, [r7, #8]
        // if (asc)
        ldr     r3, [r7, #8]
        cmp     r3, 0x1
        bne     X1
        // delay();
        mov     r0, #50
        bl      delay
        // i++;
        ldr     r3, [r7]
        adds    r3, r3, 0x1
        str     r3, [r7]
        // ASC(i);
        ldr     r3, [r7]
        mov     r0, r3
        bl      ASC
X1:
        // if (desc)
        ldr     r3, [r7, #4]
        cmp     r3, 0x1
        bne     X2
        // delay();
        mov     r0, #50
        bl      delay
        // i--;
        ldr     r3, [r7]
        subs    r3, r3, 0x1
        str     r3, [r7]
        // DESC(i);
        ldr     r3, [r7]
        mov     r0, r3
        bl      DESC
X2:
        // if (desc && asc)
        ldr     r3, [r7, #4]
        cmp     r3, 0x1
        bne     X3
        ldr     r3, [r7, #8]
        cmp     r3, 0x1
        bne     X3
        // delay();
        mov     r0, #50
        bl      delay
        // ASC(1024);
        mov     r3, #1024
        mov     r0, r3
        bl      ASC
        // delay();
        mov     r0, #50
        bl      delay
        // DESC(1024);
        mov     r3, #1024
        mov     r0, r3
        bl      DESC
        // i = 1024;
        mov     r3, #1024
        str     r3, [r7]
X3:
        mov     r0, #50
        bl      delay
        b       loop
