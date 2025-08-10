PROCESSOR 10F202 ;tell the software which chip is used.
   
    CONFIG  WDTE = OFF            ; Watchdog Timer (WDT disabled)
    CONFIG  CP = OFF              ; Code Protect (Code protection off)
    CONFIG  MCLRE = OFF           ; Master Clear Enable (GP3/MCLR pin fuction is digital I/O, MCLR internally tied to VDD)
    
#include <xc.inc>

psect RES_VECT,class=CODE,delta=2 ; PIC10/12/16. "-PRES_VECT=0x00" must be present as a custom linker option in the project properties.
RES_VECT:
    movlw 1100
    movwf TRISIO    ;GP3 must be INPUT

main:
    nop ;replace with your program
END
