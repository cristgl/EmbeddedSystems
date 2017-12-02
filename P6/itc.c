/*
 * Sistemas operativos empotrados
 * Driver para el controlador de interrupciones del MC1322x
 */

#include "system.h"

/*****************************************************************************/

/**
 * Acceso estructurado a los registros de control del ITC del MC1322x
 */
typedef struct
{
	uint32 INTCNTL;
	uint32 NIMASK;
	uint32 INTENNUM;
	uint32 INTDISNUM;
	uint32 INTENABLE;
	uint32 INTTYPE;
	uint32 [4] RSV;
	uint32 NIVECTOR;
	uint32 FIVECTOR;
	uint32 INTSRC;
	uint32 INTFRC;
	uint32 NIPEND;
	uint32 FIPEND;

} itc_regs_t;

static uint32 auxiliar_INTENABLE;

static volatile itc_regs_t* const itc_regs = ITC_BASE;

/**
 * Tabla de manejadores de interrupción.
 */
static itc_handler_t itc_handlers[itc_src_max];

/*****************************************************************************/

/**
 * Inicializa el controlador de interrupciones.
 * Deshabilita los bits I y F de la CPU, inicializa la tabla de manejadores a NULL,
 * y habilita el arbitraje de interrupciones Normales y rápidas en el controlador
 * de interupciones.
 */
inline void itc_init ()
{
	int i=0;

	while(i<itc_src_max){
		itc_handlers[i] = NULL;
		i++;
	}

	itc_regs->INTFRC = 0;
	itc_regs->INTENABLE = 0;
	itc_regs->INTCNTL = 0;
}

/*****************************************************************************/

/**
 * Deshabilita el envío de peticiones de interrupción a la CPU
 * Permite implementar regiones críticas en modo USER
 */
inline void itc_disable_ints ()
{
	auxiliar_INTENABLE = INTENABLE;
	itc_regs->INTENABLE = 0;
}

/*****************************************************************************/

/**
 * Vuelve a habilitar el envío de peticiones de interrupción a la CPU
 * Permite implementar regiones críticas en modo USER
 */
inline void itc_restore_ints ()
{
	itc_regs->INTENABLE = auxiliar_INTENABLE;
}

/*****************************************************************************/

/**
 * Asigna un manejador de interrupción
 * @param src		Identificador de la fuente
 * @param handler	Manejador
 */
inline void itc_set_handler (itc_src_t src, itc_handler_t handler)
{
	itc_handlers[src] = handler;
}

/*****************************************************************************/

/**
 * Asigna una prioridad (normal o fast) a una fuente de interrupción
 * @param src		Identificador de la fuente
 * @param priority	Tipo de prioridad
 */
inline void itc_set_priority (itc_src_t src, itc_priority_t priority)
{
	itc_regs->INTTYPE = (priority ? (1 << src) : itc_regs->INTTYPE & ~(1 << src))
	/*if(priority == itc_priority_fast)
		itc_regs->INTTYPE = (1 << src);	
	else
		INTTYPE = INTTYPE & ~(1 << src);*/

}

/*****************************************************************************/

/**
 * Habilita las interrupciones de una determinda fuente
 * @param src		Identificador de la fuente
 */
inline void itc_enable_interrupt (itc_src_t src)
{
	itc_regs->INTENNUM = src;	
}

/*****************************************************************************/

/**
 * Deshabilita las interrupciones de una determinda fuente
 * @param src		Identificador de la fuente
 */
inline void itc_disable_interrupt (itc_src_t src)
{
	itc_regs->INTDISNUM = src;	
}

/*****************************************************************************/

/**
 * Fuerza una interrupción con propósitos de depuración
 * @param src		Identificador de la fuente
 */
inline void itc_force_interrupt (itc_src_t src)
{
	itc_regs->INTFRC = itc_regs->INTFRC | (1 << src);
}

/*****************************************************************************/

/**
 * Desfuerza una interrupción con propósitos de depuración
 * @param src		Identificador de la fuente
 */
inline void itc_unforce_interrupt (itc_src_t src)
{
	itc_regs->INTFRC = itc_regs->INTFRC & ~(1 << src);
}

/*****************************************************************************/

/**
 * Da servicio a la interrupción normal pendiente de más prioridad.
 * En el caso de usar un manejador de excepciones IRQ que permita interrupciones
 * anidadas, debe deshabilitar las IRQ de menor prioridad hasta que se haya
 * completado el servicio de la IRQ para evitar inversiones de prioridad
 */
void itc_service_normal_interrupt ()
{
	itc_handlers[itc_regs->NIVECTOR]();
}

/*****************************************************************************/

/**
 * Da servicio a la interrupción rápida pendiente de más prioridad
 */
void itc_service_fast_interrupt ()
{
	itc_handlers[itc_regs->FIVECTOR]();

}

/*****************************************************************************/
