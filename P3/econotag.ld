/*****************************************************************************/
/*                                                                           */
/* Sistemas Empotrados                                                       */
/*                                                                           */
/* Linker script para la Redwire EconoTAG                                    */
/*                                                                           */
/*****************************************************************************/

/*****************************************************************************/
/* Punto de entrada                                                          */
/*****************************************************************************/

ENTRY(_start)

/*
 * Mapa de memoria de la placa
 */
MEMORY
{
        ram0 :  org = 0x00400000,       len = 0x00002000        /* (8 KB) */
	ram1 :  org = 0x00402000,	len = 0x00004000	/* (24 KB) */
	ram2 :  org = 0x00408000,	len = 0x00008000	/* (32 KB) */
	ram3 :  org = 0x00410000,	len = 0x00008000	/* (32 KB) */
}

SECTIONS
{
        /* Código del programa */
        .text : ALIGN(4)
        {
                *(.text);
        } > ram0
	
	.data : ALIGN(4)
	{
		*(.data);
	} > ram0


	gpio_base = 0x80000000 ;
	gpio_pad_dir0    = gpio_base + 0x00000000; 
	gpio_pad_dir1    = gpio_base + 0x00000004; 
	gpio_data0       = gpio_base + 0x00000008; 
	gpio_data_set0   = gpio_base + 0x00000048; 
	gpio_data_set1   = gpio_base + 0x0000004c; 
	gpio_data_reset1 = gpio_base + 0x00000054;


	/* Dentro de una seccion
	.gpio 0x80000000 :
	{
		gpio_base = . ;
		gpio_pad_dir0    = gpio_base + 0x00000000; 
		gpio_pad_dir1    = gpio_base + 0x00000004; 
		gpio_data0       = gpio_base + 0x00000008; 
		gpio_data_set0   = gpio_base + 0x00000048; 
		gpio_data_set1   = gpio_base + 0x0000004c; 
		gpio_data_reset1 = gpio_base + 0x00000054;		
	}*/

}
