/*
 * WS2812-Test
 * Autor: Stefan Haun <tux@netz39.de>
 * 
 * Entwickelt für ATMEGA8
 * 
 * DO NOT forget to set the fuses s.th. the controller 
 * uses a 16 MHz external oscillator clock!
 */


/* define CPU frequency in MHz here if not defined in Makefile */
#ifndef F_CPU
#define F_CPU 16000000UL
#endif

#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include <stdint.h>

#include <util/atomic.h>

#include "light_ws2812/light_ws2812.h"

// from http://www.rn-wissen.de/index.php/Inline-Assembler_in_avr-gcc#nop
#define nop() \
   asm volatile ("nop")

// AVR WatchDog   
#include <avr/wdt.h>

// turn off a maybe running WDT
uint8_t mcusr_mirror __attribute__ ((section (".noinit")));

void get_mcusr(void) \
  __attribute__((naked)) \
  __attribute__((section(".init3")));
void get_mcusr(void) {
  mcusr_mirror = MCUSR;
  MCUSR = 0;
  wdt_disable();
}

/// Port Helper Macros
#define setPortB(mask)   (PORTB |= (mask))
#define resetPortB(mask) (PORTB &= ~(mask))
#define setPortC(mask)   (PORTC |= (mask))
#define resetPortC(mask) (PORTC &= ~(mask))
#define setPortD(mask)   (PORTD |= (mask))
#define resetPortD(mask) (PORTD &= ~(mask))

/// Infrastruktur



void init(void) {
  /*
   * Pin-Config PortB:
   *   PB0: 
   *   PB1: 
   *   PB2: 
   *   PB3: IN  MOSI
   *   PB4: IN  MISO
   *   PB5: IN  SCK
   * 
   * Pin-Config PortC:
   *   PC0: OUT LED WS2812
   *   PC1: 
   *   PC2: 
   *   PC3: 
   *   PC4: 
   *   PC5: 
   * 
   * Pin-Config PortD:
   *   PD0: 
   *   PD1; 
   *   PD2: 
   *   PD3: 
   *   PD4: 
   *   PD5: 
   *   PD6: 
   *   PD7: 
   */
  
  
  // 0 = IN, 1 = OUT
  DDRB  = 0b00000000;
  // PullUp für Eingänge (1 = PullUp)
  PORTB = 0b00000000;

  DDRC  = 0b00000001;
  // PullUp für Eingänge
  PORTC = 0b00000000;

  DDRD  = 0b00000000;
  // PullUp für Eingänge
  PORTD = 0b00000000;

   /*  disable interrupts  */
   cli();
   
   
   /*  set clock   */
  
  // prescaler 1024, CTC
  TCCR1A = 0;
  TCCR1B = (1 << WGM12) | (1 << CS02) | (0 << CS01) | (0 << CS00);

  // vergleichswert
  OCR1A = 0xff;
  
  // aktivieren
  //TIMSK |= (1 << OCIE1A);
    
 
  // Global Interrupts aktivieren
 // sei();  
}

// nach http://www.ulrichradig.de/home/index.php/projekte/hsv-to-rgb-led
//############################################################################
//HSV to RGB 8Bit
//Farbkreis h = 0 bis 360 (Farbwert)
//          s = 0 bis 100 (Dunkelstufe)
//          v = 0 bis 100 (Farbsättigung)
//Rückgabewert r,g,b als Pointer
void hsv_to_rgb (unsigned int h,unsigned char s,unsigned char v,
					unsigned char* r, unsigned char* g, unsigned char* b)
{		
		unsigned char diff;
	
		//Winkel im Farbkeis 0 - 360 in 1 Grad Schritten
		//h = (englisch hue) Farbwert
		//1 Grad Schrittweite, 4.25 Steigung pro Schritt bei 60 Grad
		if(h<61){
			*r = 255;
			*b = 0;
			*g = (425 * h) / 100;
		}else if(h < 121){
			*g = 255;
			*b = 0;
			*r = 255 - ((425 * (h-60))/100);
		}else if(h < 181){
			*r = 0;
			*g = 255;
			*b = (425 * (h-120))/100;
		}else if(h < 241){
			*r = 0;
			*b = 255;
			*g = 255 - ((425 * (h-180))/100);
		}else if(h < 301){
			*g = 0;
			*b = 255;
			*r = (425 * (h-240))/100;
		}else if(h< 360){
			*r = 255;
			*g = 0;
			*b = 255 - ((425 * (h-300))/100);
		}	
		
		//Berechnung der Farbsättigung
		//s = (englisch saturation) Farbsättigung
		s = 100 - s; //Kehrwert berechnen
		diff = ((255 - *r) * s)/100;
		*r = *r + diff;
		diff = ((255 - *g) * s)/100;
		*g = *g + diff;
		diff = ((255 - *b) * s)/100;
		*b = *b + diff;
		
		//Berechnung der Dunkelstufe
		//v = (englisch value) Wert Dunkelstufe einfacher Dreisatz 0..100%
		*r = (*r * v)/100;
		*g = (*g * v)/100;
		*b = (*b * v)/100;
}

void set_leds(int h, int s, int v) {
  int r;
  int g;
  int b;
  hsv_to_rgb(h, s, v, &r, &g, &b);
  
  
  struct cRGB led[14];

  int i;
  for (i = 0; i < 14; i++) {
    led[i].r=r;
    led[i].g=g;
    led[i].b=b;
  }
  
  ws2812_setleds(led,14);
}


/// main routine
int main(void) {
  // initialisieren
  init();

  // activate the AVR internal Watch Dog Timer
//  wdt_enable(WDTO_1S);
  
  int h;
  
  int off=128;
  int on=16;

    struct cRGB led[14];

  while(1) {
    // reset the WDT
  //  wdt_reset();
    
    // some idle time here
    //_delay_ms(15);
    
	for (h = 0; h <= 360; h++) {
	   set_leds(h, 64, 64);
	   _delay_ms(10);
	}

    
  } // while
  
  return 0;
}


ISR (TIMER1_COMPA_vect)
{
  // store state and disable interrupts
 /* const uint8_t _sreg = SREG;
  cli();


  
  // restore state
  SREG = _sreg;  */
}