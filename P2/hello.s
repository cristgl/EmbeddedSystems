@
@ Sistemas Empotrados
@ El "hola mundo" en la Redwire EconoTAG
@

@
@ Constantes
@

	@ Registro de control de dirección del GPIO0-GPIO31
        @.set GPIO_PAD_DIR0,    0x80000000

        @ Registro de control de dirección del GPIO32-GPIO63
        .set GPIO_PAD_DIR1,    0x80000004

	@ Registro de activación de bits del GPIO0-GPIO31
        .set GPIO_DATA_SET0,   0x80000048

        @ Registro de activación de bits del GPIO32-GPIO63
        .set GPIO_DATA_SET1,   0x8000004c

        @ Registro de limpieza de bits del GPIO32-GPIO63
        .set GPIO_DATA_RESET1, 0x80000054

	@ Registro para consultar la activación de botones
	.set GPIO_DATA0, 0x80000008

        @ El led rojo y verde está en el GPIO 44 y 45 (el bit 12 y 13 de los registros GPIO_X_1)
        .set LED_RED_MASK,     (1 << (44-32))
	.set LED_GREEN_MASK,     (1 << (45-32))

	@ Botones S2 y S3
	.set BOTON_S2_UP,	(1 << 23)
	.set BOTON_S2_BOT,	(1 << 27)
	.set BOTON_S3_UP,	(1 << 22)
	.set BOTON_S3_BOT,	(1 << 26)
	
	@ Máscaras botones
	.set BOTON_UP_MASK,	(BOTON_S2_UP | BOTON_S3_UP)

	@ Leds green y red
	.set RED_GREEN,		(LED_RED_MASK | LED_GREEN_MASK)

	@ Pines de entrada verde y rojo
	.set PIN_VERDE,		0x04000000
	.set PIN_ROJO,		0x08000000
	.set NO_LED,		0x00000000

        @ Retardo para el parpadeo
        .set DELAY,            0x00080000

@
@ Punto de entrada
@

        .code 32
        .text
        .global _start
        .type   _start, %function

_start:
	bl	gpio_init

        @ Direcciones de los registros GPIO_DATA_SET1 y GPIO_DATA_RESET1
        ldr     r6, =GPIO_DATA_SET1
        ldr     r7, =GPIO_DATA_RESET1

	@ Comienza con el led rojo encendido
	ldr	r5, =LED_RED_MASK

loop:
	bl	test_buttons

        @ Encendemos el led
        str     r5, [r6]

        @ Pausa corta
        ldr     r0, =DELAY
        bl      pause

        @ Apagamos el led
        str     r5, [r7]

	bl	test_buttons

        @ Pausa corta
        ldr     r0, =DELAY
        bl      pause

        @ Bucle infinito
        b       loop
        
@
@ Función que produce un retardo
@ r0: iteraciones del retardo
@
        .type   pause, %function
pause:
        subs    r0, r0, #1
        bne     pause
        mov     pc, lr

gpio_init:

	@ Configuramos el GPIO44 y GPIO45 para que sean de salida
        ldr     r4, =GPIO_PAD_DIR1
        ldr     r5, =RED_GREEN
        str     r5, [r4]

	@ Direcciones del registro GPIO_DATA_SET0
	@ldr	r9, =GPIO_DATA_SET0
	@ No es necesario establecer los pines de los botones como
	@ salida o entrada porque ya están por defecto.
	@ldr	r10, =BOTON_UP_MASK
	@str	r10, [r9]
	
	mov	pc, lr
	

test_buttons:
	
	ldr	r9, =GPIO_DATA0

	@ Comprobamos si está activo el bit de entrada del botón S3.
	ldr	r1, [r9]	
	tst	r1, #PIN_VERDE
	ldrne	r5, =LED_GREEN_MASK
	

	@ Comprobamos si está activo el bit de entrada del botón S2.
	ldr	r2, [r9]
	tst	r2, #PIN_ROJO	
	ldrne	r5, =LED_RED_MASK

        @ Apagamos el otro LED
        eor     r3, r5, #RED_GREEN
        str     r3, [r7]
	
       	mov     pc, lr

	

	

