;*****************************PROJECT INFORMATION*******************************
;Fill in the information below for your project. 
;Ensure all lines remain as comments with a semicolon (;)
    
;	TITLE: ######PROJECT TITLE HERE#######
;	AUTHOR: #######YOUR NAME HERE#######
;	DATE: #######EXAM SERIES HERE (eg Summer 2024)#######

;============================= TEMPLATE INFORMATION ============================
;TEMPLATE CREATED BY ANTONIO COULTON, Dr JOSEPH DARE
;Lecturers, A-level Electronics and Physics
;Email: acelectronics@murena.io
;Last updated June 2025

;adapted from Eduqas Template for A-level Electronics
    ;https://www.eduqas.co.uk/qualifications/electronics-as-a-level/#tab_keydocuments
;to be compatible with Microchip XC8 pic-as compiler

;TO ENABLE CORRECT OPERATION OF RESET AND INTERRUPT VECTORS: --HIGHLY IMPORTANT--
   ;under Project Properties, pic-as Linker, under Custom linker options, include a copy of the following line:
   ;"-PRES_VECT=0x00;-PINT_VECT=0x04" 
   ;without the semicolon (;) or quotations (")

;============================ CHIP + PROGRAMME SET-UP ==========================
PROCESSOR 16F88 ;tell the software which chip is used. Datasheet: https://docs.rs-online.com/a168/0900766b81382af8.pdf
   
;CONFIG
CONFIG  FOSC = INTOSCIO       ; Oscillator Selection bits (INTRC oscillator; port I/O function on both RA6/OSC2/CLKO pin and RA7/OSC1/CLKI pin)
CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled)
CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
CONFIG  MCLRE = OFF           ; RA5/MCLR/VPP Pin Function Select bit (RA5/MCLR/VPP pin function is Digital I/O)
CONFIG  BOREN = ON            ; Brown-out Reset Enable bit (BOR enabled)
CONFIG  LVP = ON              ; Low-Voltage Programming Enable bit (RB3/PGM pin has PGM function, Low-Voltage Programming enabled)
CONFIG  CPD = OFF             ; Data EE Memory Code Protection bit (Code protection off)
CONFIG  WRT = OFF             ; Flash Program Memory Write Enable bits (Write protection off)
CONFIG  CCPMX = RB0           ; CCP1 Pin Selection bit (CCP1 function on RB0)
CONFIG  CP = OFF              ; Flash Program Memory Code Protection bit (Code protection off)
CONFIG  FCMEN = ON            ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor enabled)
CONFIG  IESO = ON             ; Internal External Switchover bit (Internal External Switchover mode enabled)
    
#include <xc.inc>
	
;============================= MEMORY STORES ===================================   
CLONE	EQU 0x20	;value used to refer to memory store in interrupt routine

WAIT1	EQU 0x21	;values used to refer to memory stores used in wait delays
WAIT10	EQU 0x22	
WAIT100	EQU 0x23	
WAIT1k	EQU 0x24
	
ADCTEMP	EQU 0x31	;variables used to point to memory stores for the readadc routines
ADC0	EQU 0x32
ADC1	EQU 0x33
ADC2	EQU 0x34

;=============================== VARIABLES USED ================================
RPZERO	EQU 0x05	;refers to bit RP0 in the STATUS Register
INTFL	EQU 0x01	;interrupt 0 flag - INT0IF in INTCON
INTEN	EQU 0x04	;interrupt 0 enable - INT0IE in INTCON
GI	EQU 0x07	;global interrupt enable - GIE in INTCON
	
;======================= RESET AND INTERRUPT VECTORS  ==========================
psect RES_VECT,class=CODE,delta=2 ; PIC10/12/16
RES_VECT:
    nop
    goto start
    
PSECT INT_VECT,class=CODE,delta=2
INT_VECT:
    movwf CLONE		    ;create a copy of the current working register
    btfss INTCON,INTFL	    ;check interrupt has occured, skips if true
    retfie		    ;set GI and RETURN in a single clock cycle
    call your_interrupt
    bcf INTCON,INTFL	    ;reset the interrupt flag
    movf CLONE,0x00	    ;return the saved working register back for use (working register address 0x00)
    retfie

your_interrupt:    
;***************************** YOUR INTERRUPT ROUTINE **************************
;enter your interrupt programme here (you can remove 'nop' as first line. Must end with return)
    nop
    return

;================================== SUBROUTINES ================================
psect code

wait1ms:    ;@4MHz, the exe rate = 1MIP, t=1us. 1000 total instructions needed to make 1ms.
    movlw 255	    ;+1 instruction
    movwf WAIT1	    ;+1
loop1ms:
	decfsz WAIT1,1	;+1*255
	goto loop1ms	;+2(255-1)
	movlw 77		;+1
	movwf WAIT1		;+1
loop1ms2:
	decfsz WAIT1,1	;+1*77
	goto loop1ms2	;+2(77-1)
	nop		;+1
	nop		;+1
	return	;+2 = 1000 total instructions

wait10ms: ;requires 10,000 instructions
	movlw 10	;+1
	movwf WAIT10	;+1
loop10ms:
	call wait1ms ;10*1000 instructions
	decfsz WAIT10,1 ;+10
	goto loop10ms ;+2*9
	return ;+2 = 10,030 total

wait100ms: ;requires 100,000 instructions
	movlw 100	    ;+1
	movwf WAIT100	    ;+1
loop100ms:
	call wait1ms	    ;+100*1000
	decfsz WAIT100,1    ;+100
	goto loop100ms	    ;+99*2
	return		    ;+2 = 100,302

wait1000ms:		;requires 1,000,000 instructions
	movlw 10	;+1
	movwf WAIT1k	;+1
loop1000ms:
	call wait100ms	;+10*100,302
	decfsz WAIT1k,1	;+10
	goto loop1000ms	;+2*9
	return		;+2 = 1,003,052

;================================= read adc ====================================
readadc0:
	movlw 00000001B	    ;PORTA,0
	bsf STATUS,RPZERO
	movwf ANSEL
	bcf STATUS,RPZERO
	movlw 01000001B	    ;01XXX001, three blank bits tell ADCON0 which analog input to check
	movwf ADCON0
	bsf ADCON0,2	    ;start adc conversion
loopadc0:
	clrwdt		    ;Pat the watchdog
	btfsc ADCON0,2	    ;check if conversion finished
	goto loopadc0
	movf ADRESH,w	    ;take result from ADRESH
	movwf ADC0	    ;move result to ADC0
	return

readadc1:
	movlw 00000010B	    ;PORTA,1
	bsf STATUS,RPZERO
	movwf ANSEL
	bcf STATUS,RPZERO
	movlw 01001001B	    ;01XXX001, three blank bits tell ADCON0 which analog input to check 
	movwf ADCON0
	bsf ADCON0,2	    ;start adc conversion
loopadc1:
	clrwdt		    ;Pat the watchdog
	btfsc ADCON0,2	    ;check if conversion finished
	goto loopadc1
	movf ADRESH,w
	movwf ADC1
	return
	
readadc2:
	movlw 00000100B	    ;PORTA,2
	bsf STATUS,RPZERO
	movwf ANSEL
	bcf STATUS,RPZERO
	movlw 01010001B	    ;01XXX001, three blank bits tell ADCON0 which analog input to check 
	movwf ADCON0
	bsf ADCON0,2	    ;start adc conversion
loopadc2:
	clrwdt		    ;Pat the watchdog
	btfsc ADCON0,2	    ;check if conversion finished
	goto loopadc2
	movf ADRESH,w
	movwf ADC2
	return
	
;if you need additional adc pins, copy one of the above subroutines and edit as appropriate.
	
;================================ INITIALISATION ===============================
;In this section, edit only the values to be stored in TRISA and TRISB
;PORTB,0 is the default interrupt trigger - ensure this is set as 1 if used as such.
;PORTA,5 must ALWAYS be an input.
;PORTA,0,1,2,3 are all usable as analog inputs.

start:
    clrf PORTA
    clrf PORTB
    bsf STATUS,RPZERO	;change RP0 to 1 to select BANK1
    movlw 01100000B	;set the clock speed to 4MHz
    movwf OSCCON 	;move the new clock speed to the clock controller.	
    clrf ANSEL		;disable adc
    movlw 11111111B	;call on the decided Inputs/outputs for PORTA
    movwf TRISA		
    movlw 00000001B	;call on the decided i/o for PORTB
    movwf TRISB		
    movlw 00000000B	;Vref is power supply voltage & left justified
    movwf ADCON1	;configured ready to use readadc subroutines
    bcf STATUS,RPZERO	;change RP0 to 0 to select BANK0
    
;******************************** ENABLE INTERRUPTS ****************************
;Uncomment the next 2 lines to enable interrupt routines by removing the FIRST semicolon (;)

    ;bsf INTCON,INTEN	;set the external interrupt enable
    ;bsf INTCON,GI		;enable all interruptions
    
main:
;******************************* MAIN PROGRAMME ********************************
;Enter your programme code here:
	nop

END ;must be the last line of the programme