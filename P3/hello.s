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
        @.set GPIO_PAD_DIR1,    0x80000004

	@ Registro de activación de bits del GPIO0-GPIO31
        @.set GPIO_DATA_SET0,   0x80000048

        @ Registro de activación de bits del GPIO32-GPIO63
        @.set GPIO_DATA_SET1,   0x8000004c

        @ Registro de limpieza de bits del GPIO32-GPIO63
        @.set GPIO_DATA_RESET1, 0x80000054

	@ Registro para consultar la activación de botones
	@.set GPIO_DATA0, 0x80000008

        @ El led rojo y verde está en el GPIO 44 y 45 (el bit 12 y 13 de los registros GPIO_X_1)
         @.set LED_RED_MASK,     (1 << (44-32))
	 @.set LED_GREEN_MASK,     (1 << (45-32))

	@ Botones S2 y S3
	@.set BOTON_S2_UP,	(1 << 23)
	@.set BOTON_S2_BOT,	(1 << 27)
	@.set BOTON_S3_UP,	(1 << 22)
	@.set BOTON_S3_BOT,	(1 << 26)
	
	@ Máscaras botones
	@.set BOTON_UP_MASK,	(BOTON_S2_UP | BOTON_S3_UP)

	@ Leds green y red
	@.set RED_GREEN,		(LED_RED_MASK | LED_GREEN_MASK)

	@ Pines de entrada verde y rojo
	@.set PIN_VERDE,		0x04000000
	@.set PIN_ROJO,		0x08000000

        @ Retardo para el parpadeo
        @.set DELAY,            0x00080000

@
@ Variables
@

	.data 
	@ El led rojo y verde está en el GPIO 44 y 45 (el bit 12 y 13 de los registros GPIO_X_1)
	led_red_mask:	.word (1 << 12)
	led_green_mask:	.word (1 << 13) 

	@ Boton UP S2 y S3
	button_s2_up:	.word (1 << 23)
	button_s3_up:	.word (1 << 22)

	@ Delay
	delay:		.word (0x00080000)
	
	@ Pines de entrada verde y rojo
	pin_verde:	.word (0x04000000)
	pin_rojo:	.word (0x08000000)
	

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
        ldr     r6, =gpio_data_set1
        ldr     r7, =gpio_data_reset1

	@ Comienza con el led rojo encendido
	ldr	r2, =led_red_mask
	ldr	r5, [r2]

loop:
	bl	test_buttons

        @ Encendemos el led
        str     r5, [r6]

        @ Pausa corta
	ldr	r1, =delay
        ldr     r0, [r1]

        bl      pause

        @ Apagamos el led
        str     r5, [r7]

	bl	test_buttons

        @ Pausa corta
        ldr	r1, =delay
        ldr     r0, [r1]

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
        @ldr     r4, =GPIO_PAD_DIR1
	ldr     r4, =gpio_pad_dir1

	ldr	r1, =led_red_mask
	ldr	r2, [r1]
	ldr	r0, =led_green_mask
	ldr	r3, [r0]
	orr	r5, r2, r3

        @ldr     r5, =(LED_RED_MASK | LED_GREEN_MASK)

        str     r5, [r4]
	
	mov	pc, lr
	

test_buttons:
	
	ldr	r9, =gpio_data0

	@ Comprobamos si está activo el bit de entrada del botón S3.
	@ Si son iguales, el flag Z estará activo
	ldr	r3, [r9]
	ldr	r0, =pin_verde
	ldr	r1, [r0]
	tst	r3, r1

	ldr	r1, =led_green_mask	
	ldrne	r5, [r1]

	

	@ Comprobamos si está activo el bit de entrada del botón S2.
	@ Si son iguales, el flag Z estará activo
	ldr	r3, [r9]
	ldr	r0, =pin_rojo
	ldr	r1, [r0]
	tst	r3, r1

	ldr	r1, =led_red_mask	
	ldrne	r5, [r1]


        @ Apagamos el otro LED
	ldr	r1, =led_red_mask
	ldr	r2, [r1]
	ldr	r0, =led_green_mask
	ldr	r3, [r0]
	orr	r4, r2, r3

        eor     r3, r5, r4
        str     r3, [r7]
	
       	mov     pc, lr

	

	

