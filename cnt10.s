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

delay:
        // Prologo
        push    {r7} @ backs r7 up
        sub     sp, sp, #28 @ reserves a 32-byte function frame
        add     r7, sp, #0 @ updates r7
        str     r0, [r7] @ backs ms up
        // Body function
        //ldr     r0, =2666667
        mov     r0, #1023 @ ticks = 255, adjust to achieve 1 ms delay
        str     r0, [r7, #16]
        // for (i = 0; i < ms; i++)
        mov     r0, #0 @ i = 0;
        str     r0, [r7, #8]
        b       F3
        // for (j = 0; j < tick; j++)
F4:     mov     r0, #0 @ j = 0;
        str     r0, [r7, #12]
        b       F5
F6:     ldr     r0, [r7, #12] @ j++;
        add     r0, #1
        str     r0, [r7, #12]
F5:     ldr     r0, [r7, #12] @ j < ticks;
        ldr     r1, [r7, #16]
        cmp     r0, r1
        blt     F6
        ldr     r0, [r7, #8] @ i++;
        add     r0, #1
        str     r0, [r7, #8]
F3:     ldr     r0, [r7, #8] @ i < ms
        ldr     r1, [r7]
        cmp     r0, r1
        blt     F4
        // Epilogue
        adds    r7, r7, #28
        mov	    sp, r7
        pop	    {r7}
        bx	    lr
.size	delay, .-delay

is_button_pressed:
        /*Creacion del prologo marco de tamaño de 16 bytes*/
        push    {r7, lr}
        sub     sp, sp, #20
        adds    r7, sp, #0
        /*Se respaldan los argumentos*/
        str     r0, [r7]
        //str     r1, [r7]
        /*---------------------------*/
        /*digitalRead()*/
        // read button input
        ldr     r0, =GPIOB_BASE
        ldr     r0, [r0, GPIOx_IDR_OFFSET]
        ldr     r3, [r7]
        and     r3, r0, r3
        lsrs    r0, r3, #0
        // if(button is not pressed)
        cmp     r0, 0x0
        bne     J1
        // return false
        mov     r3, #0
        mov     r0, r3
        adds    r7, r7, #20
        mov     sp, r7
        pop     {r7, lr}
        bx      lr
J1:
        // counter = 0
        mov     r3, #0
        str     r3, [r7, #8]
        // Se brinca al ciclo for
        // i = 0
        mov     r3, #0
        str     r3, [r7, #4]
        b       F
F_1:    // invocacion de delay
        mov     r0, #5
        bl      delay
        // read button input
        ldr     r0, =GPIOB_BASE
        ldr     r0, [r0, GPIOx_IDR_OFFSET]
        ldr    r3, [r7]
        and     r3, r0, r3
        lsrs    r0, r3, #0
        // if(button is not pressed)
        cmp     r0, 0x0
        bne     J2
        // counter = 0
        ldr     r3, [r7, #8]
        mov     r3, #0
        str     r3, [r7, #8]
        b       J3
J2:     // else
        // counter = counter + 1
        ldr     r3, [r7, #8]
        adds    r3, r3, #1
        str     r3, [r7, #8]
        // if (counter >= 4)
        ldr     r0, [r7, #8]
        cmp     r0, 0x4
        blt     J3
        // return true
        mov     r3, #1
        mov     r0, r3
        adds    r7, r7, #20
        mov     sp, r7
        pop     {r7, lr}
        bx      lr
J3:
        // i++
        ldr     r3, [r7, #4]
        adds    r3, r3, #1
        str     r3, [r7, #4]
F:      // Se carga i
        ldr     r3, [r7, #4]
        mov     r0, #10
        cmp     r3, r0
        blt     F_1
        /*---------------------------*/
        /*Creacion del epilogo de la funcion*/
        // return false
        mov     r3, #0
        mov     r0, r3
        adds    r7, r7, #20
        mov     sp, r7
        pop     {r7, lr}
        bx      lr
.size	is_button_pressed, .-is_button_pressed

ASC:
        /*Prologo*/
        push    {r7}
        sub     sp, sp, #28
        add     r7, sp, #0
        /*Se respalda el argumento n*/
        str     r0, [r7]        // argumento n
        /*Se inicializan los pines de salida*/
        /*Registros altos*/
        ldr     r0, =GPIOA_BASE
        ldr     r4, =0x44444444
        str     r4, [r0, GPIOx_CRH_OFFSET]
        /*Registros bajos*/
        ldr     r0, =GPIOA_BASE
        ldr     r4, =0x44444444
        str     r4, [r0, GPIOx_CRL_OFFSET]
        // int i = n;
        ldr     r3, [r7]        // argumento n se asigna a i
        str     r3, [r7, #16]   // variable i
        // Salta al bucle externo:
        b       FOR1
 L1:
        // j = 0
        mov     r3, #0
        str     r3, [r7, #12]   // Se inicializa variable j
        //Se respalda la direccion base los de registros bajos
        ldr     r4, =0x44444444
        str     r4, [r7, #8]    // Se resplada direccion de los registros bajos
        // Se respalda la direccion base los de registros altos
        ldr     r4, =0x44444444
        str     r4, [r7, #4]    // se resplada la direccion de los registros altos
        // Salta al bucle interno:
        b       FOR2
L2:
        /* if (((i >> j) & 1) == 1)*/
        ldr     r3, [r7, #16]           // Cargar i
        ldr     r2, [r7, #12]           // Cargar j
        lsr     r3, r3, r2              // Se realiza (i >> j)
        and     r3, r3, 0x1             // Se realiza (i >> j) & 1
        cmp     r3, 0x1                 // (((i >> j) & 1) == 1)?
        bne     L3
        /* Aqui se encieden los leds*/
        /* digitalWriteLowRegister(outputpin[j], HIGH)*/
        //------------------------------------------
        /* Se carga j */
        ldr     r3, [r7, #12]
        lsls    r4, r3, 0x2      // (j << 2)
        /* Se realiza el calculo de las salidas a encender */
        mov     r3, 0x7
        lsl     r3, r3, r4      // (0x7 << (j << 2))
        ldr     r4, [r7, #8]   // Se carga 0x44444444 (direccion base de CRL y CRH)
        eor     r4, r4, r3      // Se aplica la mascara 0x44444444 ^ (0x7 << (j << 2))
        str     r4, [r7, #8]   // Se respalda
        /* if(i == n) */
        ldr     r3, [r7]   // se carga n
        ldr     r0, [r7]        // se carga i
        cmp     r0, r3          // if(i == n)? HIGH : LOW
        bne     L3
        /* Encendido de los registros bajos */
        ldr     r3, [r7, #8]
        ldr     r0, =GPIOA_BASE
        add     r0, GPIOx_CRL_OFFSET
        str     r3, [r0]
        /*******************************************************/
        ldr     r3, [r7, #12]    // Se carga j
        // if(j >= 8)
        cmp     r3, 0x8
        blt     L3
        /* digitalWriteHighRegister(outputpin[j], HIGH)*/
        sub     r3, r3, 0x8     // j - 8
        lsls    r4, r3, 0x2     // (j << 2)
        /* Se realiza el calculo de las salidas a encender */
        mov     r3, 0x7
        lsl     r3, r3, r4      // (0x7 << (j << 2))
        ldr     r4, [r7, #4]    // Se carga 0x44444444 (direccion base de CRL y CRH)
        eor     r4, r4, r3      // Se aplica la mascara 0x44444444 ^ (0x7 << (j << 2))
        str     r4, [r7, #4]    // Se respalda
         /* if(i == n) */
        ldr     r3, [r7]        // se carga n
        ldr     r0, [r7, #16]   // se carga i
        cmp     r0, r3          // if(i == n)? HIGH : LOW
        bne     L3
        /* Encendido de los registros altos */
        ldr     r3, [r7, #4]
        ldr     r0, =GPIOA_BASE
        add     r0, GPIOx_CRH_OFFSET
        str     r3, [r0]
L3:
        // j++
        ldr     r3, [r7, #12]
        adds    r3, r3, #1
        str     r3, [r7, #12]
FOR2:   // Cargar j
        ldr     r3, [r7, #12]
        // j >= 10
        cmp     r3, 0xa
        blt     L2
        // i--
        ldr     r3, [r7, #16]
        subs    r3, r3, #1
        str     r3, [r7, #16]
FOR1:   // Cargar i
        ldr     r3, [r7, #16]
        // Cargar n
        ldr     r2, [r7]
        // i < n
        cmp     r3, r2
        bge     L1
        /*Epilogo*/
        mov     r3, #0
        mov     r0, r3
        adds    r7, r7, #28
        mov     sp, r7
        pop     {r7}
        bx      lr
.size	ASC, .-ASC

DESC:
        /*Prologo*/
        push    {r7}
        sub     sp, sp, #28
        add     r7, sp, #0
        /*Se respalda el argumento n*/
        str     r0, [r7]
        /*Se inicializan los pines de salida*/
        /*Registros altos*/
        ldr     r0, =GPIOA_BASE
        ldr     r4, =0x44444444
        str     r4, [r0, GPIOx_CRH_OFFSET]
        /*Registros bajos*/
        ldr     r0, =GPIOA_BASE
        ldr     r4, =0x44444444
        str     r4, [r0, GPIOx_CRL_OFFSET]
        // i = n;
        ldr     r0, [r7]
        str     r0, [r7, #16]
        // Salta al bucle externo:
        b       FOR3
L7:
        // int j = 0
        mov     r3, #0
        str     r3, [r7, #12]
        // Se respalda direccion base de los registros bajos
        ldr     r4, =0x44444444
        str     r4, [r7, #8]
        // Se respalda direccion base de los registros altos
        ldr     r4, =0x44444444
        str     r4, [r7, #4]
        // Salta al bucle interno:
        b       FOR4
L8:
        // if (((i >> j) & 1) == 1)
        ldr     r3, [r7, #16]           // Cargar i
        ldr     r2, [r7, #12]           // Cargar j
        lsr     r3, r3, r2              // Se realiza (i >> j)
        and     r3, r3, 0x1             // Se realiza (i >> j) & 1
        cmp     r3, 0x1                 // (((i >> j) & 1) == 1)?
        bne     L9
        // Aqui se encieden los leds
        // Digital write outputpin[j], HIGH
        //------------------------------------------
        // Se carga j
        ldr     r3, [r7, #12]
        lsls    r4, r3, #2      // (j << 2)
        mov     r3, #7
        lsl     r3, r3, r4      // (0x7 << (j << 2))
        /* Se realiza el calculo de las salidas a encender */
        ldr     r4, [r7, #8]   // Se carga 0x44444444 (direccion base de CRL y CRH)
        eor     r4, r4, r3      // Se aplica la mascara 0x44444444 ^ (0x7 << (j << 2))
        str     r4, [r7, #8]   // Se respalda
        // if (i == n)?
        ldr     r3, [r7]   // Se carga n
        ldr     r0, [r7, #16]        // Se carga i
        cmp     r0, r3
        bne     L9
        /* Encendido de los registros bajos */
        ldr     r3, [r7, #8]
        ldr     r0, =GPIOA_BASE
        add     r0, GPIOx_CRL_OFFSET
        str     r3, [r0]
        // Se carga j
        ldr     r3, [r7, #12]
        // if(j >= 8)
        cmp     r3, 0x8
        blt     L9
        // Se carga j
        // j - 8
        ldr     r3, [r7, #12]
        sub     r3, r3, 0x8
        lsls    r4, r3, #2      // (j << 2)
        mov     r3, 0x7
        lsl     r3, r3, r4      // (0x7 << (i << 2))
        /* Se realiza el calculo de las salidas a encender */
        ldr     r4, [r7, #4]    // Se carga 0x44444444 (direccion base de CRL y CRH)
        eor     r4, r4, r3      // Se aplica la mascara 0x44444444 ^ (0x7 << (j << 2))
        str     r4, [r7, #4]    // Se respalda
         /* if(i == n) */
        ldr     r3, [r7]        // se carga n
        ldr     r0, [r7, #16]   // se carga i
        cmp     r0, r3          // if(i == n)? HIGH : LOW
        bne     L9
        /* Encendido de los registros altos */
        ldr     r3, [r7, #4]
        ldr     r0, =GPIOA_BASE
        add     r0, GPIOx_CRH_OFFSET
        str     r3, [r0]
L9:
        // j++
        ldr     r3, [r7, #12]
        adds    r3, r3, #1
        str     r3, [r7, #12]
FOR4:   // Cargar j
        ldr     r3, [r7, #12]
        cmp     r3, 0xa
        blt     L8
        // i--
        ldr     r3, [r7, #16]
        subs    r3, r3, #1
        str     r3, [r7, #16]
FOR3:
        // i >= 1
        ldr     r3, [r7, #16]
        cmp     r3, 0x1
        bge     L7
        /*Epilogo*/
        mov     r3, #0
        mov     r0, r3
        adds    r7, r7, #28
        mov     sp, r7
        pop     {r7}
        bx      lr
.size	DESC, .-DESC

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
