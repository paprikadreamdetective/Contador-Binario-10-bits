.section .text
.align  1
.syntax unified
.thumb
.global ASC

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

.section .text
.align  1
.syntax unified
.thumb
.global DESC

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
