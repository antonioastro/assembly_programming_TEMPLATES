;Template created by Antonio Coulton
;Email: acelectronics@murena.io
;Last updated June 2025

PROCESSOR 16F887

  CONFIG  FOSC = INTRC_NOCLKOUT ; Oscillator Selection bits (INTOSCIO oscillator)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = OFF            ; RE3/MCLR pin function select bit (RE3/MCLR pin function is MCLR)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = ON            ; Brown Out Reset Selection bits (BOR enabled)
  CONFIG  IESO = ON             ; Internal External Switchover bit (Internal/External Switchover mode is enabled)
  CONFIG  FCMEN = ON            ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is enabled)
  CONFIG  LVP = ON              ; Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)
   
#include <xc.inc>

psect RES_VECT,class=CODE,delta=2 ; PIC10/12/16. "-PRES_VECT=0x00" must be present as a custom linker option in the project properties.
RES_VECT:
    clrf PORTA
    clrf PORTB
    clrf PORTC
    clrf PORTD
    clrf PORTE
    bsf STATUS,5	;change RP0 to 1 to select BANK1
    movlw 01100000B	;set the clock speed to 4MHz 
    movwf OSCCON 	;move the new clock speed to the clock controller.	
    movlw 11111111B	;call on the decided Inputs/outputs for PORTA. PORTA,5 must be an INPUT
    movwf TRISA		
    movlw 11111111B	;call on the decided i/o for PORTB
    movwf TRISB
    movlw 00000000B	;call on the decided i/o for PORTC
    movwf TRISC
    movlw 00000000B	;call on the decided i/o for PORTD
    movwf TRISD
    movlw 1000B	;call on the decided i/o for PORTE. PORTE,3 must be an INPUT.
    movwf TRISE
    bcf STATUS,5	;change RP0 to 0 to select BANK0
    
main:
    nop ;replace with your program

END