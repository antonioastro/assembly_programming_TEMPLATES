;Template created by ANTONIO COULTON
;Email: acelectronics@murena.io
;Last updated August 2025
    
PROCESSOR 12F510 ;tell the software which chip is used.
   
  CONFIG  OSC = IntRC           ; Oscillator Select (INTOSC with 1.125 ms DRT)
  CONFIG  WDT = OFF             ; Watchdog Timer Enable bit (WDT disabled)
  CONFIG  CP = OFF              ; Code Protect (Code protection off)
  CONFIG  MCLRE = OFF           ; Master Clear Enable bit (GP3/MCLR pin functions as GP3, MCLR internally tied to VDD)
  CONFIG  IOSCFS = OFF          ; Internal Oscillator Frequency Select bit (4 MHz INTOSC Speed)
    
#include <xc.inc>

psect RES_VECT,class=CODE,delta=2 ; PIC10/12/16. "-PRES_VECT=0x00" must be present as a custom linker option in the project properties.
RES_VECT:
    movlw 001111	
    movwf TRISIO	;GP3 must be INPUT.

main:
    nop ;replace with your program
END
