; GREENHOUSE ASSEMBLY PROGRAM
; ==============================================================
; 			     START
; ==============================================================
ORG 0000H

; ----------- PINMODE AT89C51
	MOV 	P0, 	#0FFH 			 
	MOV 	P1, 	#00H 			
	MOV 	P2, 	#00H 			
	MOV 	P3,	#04H 			

; ----------- DEFINE PIN AT89C51
	ADC 	EQU 	P0
	HEATER 	EQU	P1.1
	GLIGHT	EQU	P1.2
	MWTRF	EQU	P1.3
	MWTRR	EQU	P1.4
	FANF	EQU	P1.5
	FANR	EQU	P1.6
	SERVO	EQU	P1.7
	LCD 	EQU	P2
	RS	EQU	P3.0
	EN	EQU	P3.1
	INTADC	EQU	P3.2
	MUXA	EQU	P3.4 			; MUX Pin X0 = potensio (soil moisture sensor), X1 = TSL251RD, X2 = HIH5030, X4 = LM35 
	MUXB	EQU	P3.5
	WRADC	EQU	P3.6
	RDADC	EQU	P3.7

; ==============================================================
; 			  LCD ON
; ==============================================================
	ACALL 	LCD_INIT

; =========================================================
; 			MAIN LOOP
; =========================================================
MAIN_LOOP:
; ========== POTENSIO - X0
; ---------- READ
	MOV 	B, 	#00H        
	ACALL 	SET_MUX
	ACALL	READ_ADC
; ---------- CONVERSION
	MOV 	A, 	B  
	MOV 	B, 	#5
	DIV 	AB
	MOV 	B, 	#2
	MUL 	AB
	MOV 	R4, 	A
	
; ========== TSL251RD - X1
; ---------- READ
	MOV 	B, 	#01H
	ACALL 	SET_MUX
	ACALL 	READ_ADC 
; ---------- CONVERSION
	MOV 	A,	B
	MOV 	B, 	#3
	DIV 	AB
	MOV 	B, 	#2
	MUL 	AB
	MOV 	R1, 	A

; ========== HIH5030 - X2 
; ---------- READ
	MOV 	B, 	#02H
	ACALL 	SET_MUX
	ACALL 	READ_ADC
; ---------- CONVERSION
	MOV 	A, 	B
	MOV 	B, 	#4
	DIV 	AB
	MOV 	B,	#2
	MUL	AB
	SUBB	A,	#11
	MOV 	R2, 	A

; ========== LM35 - X3
; ---------- READ
	MOV 	B, 	#03H
	ACALL 	SET_MUX
	ACALL 	READ_ADC
; ---------- CONVERSION
	MOV 	A, 	B
	MOV 	B, 	#2
	MUL 	AB
	SUBB 	A, 	#1
	MOV 	R3, 	A
   
; ========== DISPLAY
	ACALL 	DISPLAY_SENSOR_TEMP
	ACALL 	DISPLAY_SENSOR_HUMID
	ACALL 	DISPLAY_SENSOR_LIGHT
	ACALL 	DISPLAY_SENSOR_SOIL

; ========== ACTUATOR
	ACALL 	ACTUATOR
	
	ACALL 	DELAY        
	SJMP 	MAIN_LOOP    

; =========================================================
; 			DISPLAY
; =========================================================
; ------- SOIL
DISPLAY_SENSOR_SOIL:
	ACALL 	LCD_L4         
	MOV 	DPTR, 	#STR4
	ACALL 	LCD_PRINT        
	MOV	A, 	R4
	ACALL 	DISP_VAL  
	RET
	
; ------- LIGHT
DISPLAY_SENSOR_LIGHT:
	ACALL 	LCD_L3         
	MOV 	DPTR, 	#STR3
	ACALL 	LCD_PRINT         	
	MOV 	A, 	R1
	ACALL 	DISP_VAL	
	RET

; ------- HUMID
DISPLAY_SENSOR_HUMID:
	ACALL 	LCD_L2        
	MOV 	DPTR, 	#STR2
	ACALL 	LCD_PRINT       	
	MOV 	A, 	R2
	ACALL 	DISP_VAL      	
	RET

; ------- TEMP
DISPLAY_SENSOR_TEMP:
	ACALL 	LCD_L1         
	MOV 	DPTR, 	#STR1
	ACALL 	LCD_PRINT       	
	MOV 	A, 	R3
	ACALL 	DISP_VAL     
	RET
	
; ------- KONVERSI KE ASCII DAN 2 DIGIT
DISP_VAL:
	MOV 	B, 	#10		
	DIV 	AB			
	ADD 	A, 	#30H		
	MOV 	R0, 	A		
	ACALL 	DATA_WRT		
	MOV 	A, 	B
	ADD 	A, 	#30H
	MOV 	R0, 	A
	ACALL 	DATA_WRT
	RET
	
; ------- LABEL KETERANGAN
STR1: 	DB 	"Temp   (C) : ",0	
STR2: 	DB 	"Humid  (%) : ",0
STR3: 	DB 	"Light  (%) : ",0
STR4: 	DB 	"Soil   (%) : ",0

; =========================================================
; 			ACTUATOR
; =========================================================
ACTUATOR:
; ------------- HEATER
HEATER_CTRL:
	MOV 	A, 	R3
	CJNE 	A, 	#23, 	CHECK_HEATER	
	CLR 	HEATER
	SJMP 	FAN_CTRL
CHECK_HEATER:
	JC 	TURN_ON_HEATER 			
	CLR 	HEATER
	SJMP 	FAN_CTRL
TURN_ON_HEATER:
	SETB HEATER
	
; ------------- KIPAS PENDINGIN
FAN_CTRL:
	MOV 	A, 	R3
	CJNE 	A, 	#27, 	CHECK_FAN
	CLR 	FANF
	SJMP 	GLIGHT_CTRL
CHECK_FAN:
	JC 	SKIP_FAN
	SETB 	FANF
	SJMP 	GLIGHT_CTRL
SKIP_FAN:
	CLR 	FANF

; ------------- GROWLIGHT
GLIGHT_CTRL:
	MOV 	A, 	R1
	CJNE 	A, 	#30, 	CHECK_GLIGHT
	CLR 	GLIGHT
	SJMP 	SPRAYER_CTRL
CHECK_GLIGHT:
	JC 	TURN_ON_GLIGHT
	CLR 	GLIGHT
	SJMP 	SPRAYER_CTRL
TURN_ON_GLIGHT:
	SETB 	GLIGHT

; ------------- SPRAYER
SPRAYER_CTRL:
	MOV 	A, 	R4
	CJNE 	A, 	#40, 	CHECK_SPRAYER
	CLR 	MWTRF
	SJMP 	SERVO_CTRL
CHECK_SPRAYER:
	JC 	TURN_ON_SPRAYER
	CLR 	MWTRF
	SJMP 	SERVO_CTRL
TURN_ON_SPRAYER:
	SETB 	MWTRF

; ------------- VENT
SERVO_CTRL:
	MOV 	A, 	R2
	CJNE 	A, 	#40, 	CHECK_SERVO
	SETB	SERVO
	ACALL 	DELAY_480US
	CLR 	SERVO
	ACALL 	DELAY_352US
	ACALL 	DELAY_200US
	SETB 	SERVO
	ACALL 	DELAY_300US
	CLR 	SERVO
	ACALL 	DELAY_370US
	ACALL 	DELAY_200US
	SETB 	SERVO
	ACALL 	DELAY_12US
	CLR 	SERVO
	ACALL 	DELAY_388US
	ACALL 	DELAY_200US
	SETB 	SERVO
	SJMP 	DONE
CHECK_SERVO:
	JC 	OPEN_SERVO
	CLR 	SERVO
	SJMP 	DONE
OPEN_SERVO:
	ACALL 	DELAY_480US
	CLR 	SERVO
	ACALL 	DELAY_352US
	ACALL 	DELAY_200US
	SETB 	SERVO
	ACALL 	DELAY_300US
	CLR 	SERVO
	ACALL 	DELAY_370US
	ACALL 	DELAY_200US
	SETB 	SERVO
	ACALL 	DELAY_12US
	CLR 	SERVO
	ACALL 	DELAY_388US
	ACALL	DELAY_200US
	SETB 	SERVO
		
; ------------- RET
DONE:
	RET
	

; =========================================================
; 			LCD CONTROL
; =========================================================
; ----------- IniT
LCD_INIT:				
	MOV 	R0, 	#38H		
	ACALL 	CMND_WRT		
	MOV 	R0, 	#0CH		
	ACALL 	CMND_WRT
	MOV 	R0, 	#01H		
	ACALL 	CMND_WRT
	MOV 	R0,	#06H 		
	ACALL 	CMND_WRT
	RET

; ----------- Data Write
DATA_WRT:				
	MOV 	LCD, 	R0		
	SETB 	RS			
	SETB 	EN
	ACALL 	DELAY
	CLR 	EN
	RET

; ----------- Command Write
CMND_WRT:			
	MOV 	LCD, 	R0		
	CLR 	RS			
	SETB 	EN			
	ACALL 	DELAY
	CLR 	EN
	RET

; ----------- Print LCD
LCD_PRINT:
	CLR 	A
	MOVC 	A, 	@A+DPTR		
        MOV 	R0, 	A		
	JZ 	DONE_PRINT		
	ACALL 	DATA_WRT
	ACALL 	DELAY
        INC 	DPTR
        SJMP 	LCD_PRINT
DONE_PRINT:
	RET

; ----------- Cursor
LCD_L1: MOV 	R0, 	#80H  		
        ACALL CMND_WRT
        RET
LCD_L2: MOV 	R0, 	#11000000B  	
        ACALL CMND_WRT
        RET
LCD_L3: MOV 	R0, 	#90H  		
        ACALL CMND_WRT
        RET   
LCD_L4: MOV 	R0, 	#11010000B  	
	ACALL CMND_WRT
        RET

; =========================================================
; 			MUX CONTROL
; =========================================================
SET_MUX:
	MOV	A,	B
	CLR 	MUXA
	CLR 	MUXB

	CJNE 	A, 	#00H, 	CHECK01
	RET

CHECK01:
	CJNE 	A, 	#01H, 	CHECK10
	SETB 	MUXA
	RET

CHECK10:
	CJNE 	A, 	#02H, 	DEFAULT11
	SETB	MUXB
	RET

DEFAULT11:
	SETB 	MUXA
	SETB 	MUXB
	RET


; =========================================================
; 			ADC CONTROL
; =========================================================
READ_ADC:
	CLR 	WRADC        			
	ACALL 	SHORT_DELAY
	SETB 	WRADC       			
	JB 	INTADC, 	$ 		
	ACALL	SHORT_DELAY
	CLR 	RDADC        			
	MOV 	B, 		ADC      
	SETB 	RDADC       		 
	RET

; =========================================================
; 			DELAY
; =========================================================
; ----------- Delay LCD (~12 ms)
DELAY:	MOV 	R5, 	#2		
DELAY1:	MOV 	R6, 	#30
DELAY_:	MOV 	R7, 	#100
	DJNZ 	R7, 	$
	DJNZ 	R6, 	DELAY_
	DJNZ 	R5, 	DELAY1
	RET

; ----------- Delay ADC
SHORT_DELAY:
	NOP       	
	NOP
	NOP
	RET

; ----------- Delay PWM
; Delay 12 micros
DELAY_12US:
	MOV 	R6, 	#6
	DJNZ 	R6, 	$
	RET

; Delay 388 micros
DELAY_388US:
	MOV 	R6, 	#194
	DJNZ 	R6, 	$
	RET

; Delay 200 micros
DELAY_200US:
	MOV 	R6, 	#100
	DJNZ 	R6, 	$
	RET

; Delay 300 micros
DELAY_300US:
	MOV 	R6, 	#150
	DJNZ 	R6, 	$
	RET

; Delay 370 micros
DELAY_370US:
	MOV 	R6, 	#185
	DJNZ 	R6, 	$
	RET

; Delay 480 micros
DELAY_480US:
	MOV 	R6, 	#240
	DJNZ 	R6,	$
	RET

; Delay 352 micros
DELAY_352US:
	MOV 	R6, 	#176
	DJNZ 	R6, 	$
	RET
    

END