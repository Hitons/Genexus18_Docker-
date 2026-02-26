#include <stdint.h>

/* Registros STM32F103 */
#define RCC_BASE        0x40021000
#define GPIOA_BASE      0x40010800
#define SYSTICK_BASE    0xE000E010

#define RCC_APB2ENR     (*(volatile uint32_t *)(RCC_BASE + 0x18))
#define GPIOA_CRH       (*(volatile uint32_t *)(GPIOA_BASE + 0x04))
#define GPIOA_ODR       (*(volatile uint32_t *)(GPIOA_BASE + 0x0C))
#define SYSTICK_CTRL    (*(volatile uint32_t *)(SYSTICK_BASE + 0x00))
#define SYSTICK_LOAD    (*(volatile uint32_t *)(SYSTICK_BASE + 0x04))

static volatile uint32_t tick_count = 0;

void SysTick_Handler(void) {
    tick_count++;
}

void delay_ms(uint32_t ms) {
    uint32_t target = tick_count + ms;
    while (tick_count < target);
}

void init_gpio(void) {
    RCC_APB2ENR |= (1 << 2);
    GPIOA_CRH &= ~(0x0F << 20);
    GPIOA_CRH |= (0x03 << 20);
}

void init_systick(void) {
    SYSTICK_LOAD = 72000 - 1;
    SYSTICK_CTRL = 0x07;
}

void led_toggle(void) {
    GPIOA_ODR ^= (1 << 5);
}

int main(void) {
    init_gpio();
    init_systick();
    while (1) {
        led_toggle();
        delay_ms(500);
    }
    return 0;
}

extern uint32_t _stack_top;

void Reset_Handler(void);
void NMI_Handler(void) __attribute__((weak, alias("Default_Handler")));
void HardFault_Handler(void) __attribute__((weak, alias("Default_Handler")));
void Default_Handler(void) { while (1); }

typedef struct {
    uint32_t *stack_top;
    void (*handlers[15])(void);
} VectorTable;

__attribute__((section(".vectors")))
const VectorTable vector_table = {
    .stack_top = &_stack_top,
    .handlers = {
        (void (*)(void))Reset_Handler,
        (void (*)(void))NMI_Handler,
        (void (*)(void))HardFault_Handler,
        0, 0, 0, 0, 0, 0, 0, 0,
        (void (*)(void))SysTick_Handler,
        0, 0
    }
};

void Reset_Handler(void) {
    main();
    while (1);
}
