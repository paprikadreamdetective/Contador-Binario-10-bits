.section .text
.align  1
.syntax unified
.thumb
.global is_button_pressed

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
