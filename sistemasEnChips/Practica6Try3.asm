;
; Practica6Try3.asm
;
; Created: 17/05/2026 11:19:23 a. m.
; Author : home
;


; Replace with your application code

	.def temp=r16
	.def unidades = r17
	.def decenas = r18
	.def centenas = r19
	.def primerEscalon=r20
	.def multiplicacionL=r21
	.def multiplicacionH=r22
	.def valorRestaL = r23
	.def valorRestaH = r24
	.def displayActual = r25
	.def modoActual = r26 
	.def auxTemp = r28
	.def auxSreg = r29

	.cseg;inicia el segmento de codigo (memoria flash)
	.org 0;direccion de inicio del programa
	jmp reset

	.org 0x0016;comparación A del timer1
	jmp interrupcionTimer1

	.org $018;comparacion B del timer1
	jmp compb

	.org 0x0020;timer0
	jmp interrupcionTimer0

	.org $02a;adc
	jmp finConversion

reset:
	;configuracion de puertos
	ldi temp, $FF
	out ddrd, temp;puerto d como salida

	ldi temp, $00
	out ddrb, temp;puerto b como entrada

	ldi temp, $01
	out portb, temp;encendemos la resistencia pull-up en b0
	
	ldi temp, $07;0000 0111, los 1 establecen que son salidas
	out ddrc, temp

	clr displayActual;limpia
	
	;movemos constantes de memoria de programa a memoria de datos
	;ejemplo aqui diriamos ve a la direccion base $0100 + 3 , dando $0103 y saca lo que haya ahi, el $F1 que es 3 y lo manda al display
	ldi temp, $7E
	sts $0100, temp       
	ldi temp, $30
	sts $0101, temp   
	ldi temp, $6D
	sts $0102, temp  
	ldi temp, $79
	sts $0103, temp     
	ldi temp, $33
	sts $0104, temp      
	ldi temp, $5B
	sts $0105, temp    
	ldi temp, $5F
	sts $0106, temp    
	ldi temp, $70
	sts $0107, temp     
	ldi temp, $7F
	sts $0108, temp   
	ldi temp, $7B
	sts $0109, temp    
	
	clr modoActual; 0 Potenciómetro, 1 sensor

	;configuracion timer0
	ldi temp, $03
	out tccr0b, temp;prescalador a 64 para el multiplexado
	ldi temp, $01;habilitar interrupcion por desbordamiento de timer0
	sts timsk0, temp;usamos sts por que el registro TIMSK0 vive en la memoria I/O extendida, donde out no llega

	;configuramos timer1
	ldi temp,$1c
	sts tccr1b,temp
	ldi temp,$f4
	sts icr1h, temp
	sts ocr1bh, temp
	ldi temp,$24
	sts icr1l,temp
	sts ocr1bl,temp
	ldi temp,$04
	sts timsk1,temp

	;configuramos adc
	ldi temp,$63
	sts admux,temp
	ldi temp,$01
	sts didr0,temp
	ldi temp,$05
	sts adcsrb,temp
	ldi temp,$ef
	sts adcsra,temp
	sei

main:
	sbis pinb, 0;sbis salta la siguiente instruccion si lee un 1 boton suelto
	rjmp cambiarModo;si no salto es porque leyo un 0 boton presionado
	jmp main

cambiarModo:
	;antirrebote casero esperar a que sueltes el boton
esperaSoltar:
	sbis pinb, 0
	rjmp esperaSoltar
	
	;leer el modo actual directamente del registro
	cpi modoActual, 0
	breq activarSensor;si era 0 cambiamos al sensor

	;modo potenciometro
activarPot:
	ldi modoActual, 0;guardamos que volvimos a potenciometro
	ldi temp, $63;admux avcc 5v pin c3
	sts admux, temp
	rjmp main

	;modo sensor lm35
activarSensor:
	ldi modoActual, 1;guardamos que estamos en sensor
	ldi temp, $E4;admux ref interna 1.1v 11 pin c4 0100 1110 0100
	sts admux, temp
	rjmp main

finConversion:
	lds temp, adch
	
	;revisar en que modo estamos directamente
	cpi modoActual, 0
	breq esPotenciometro

esSensor:
	ldi primerEscalon, 43
	rjmp hacerMultiplicacion

esPotenciometro:
	ldi primerEscalon, 196

hacerMultiplicacion:
	mul primerEscalon, temp;r1 r0 adch multiplicacion escalon
	
	mov multiplicacionL, r0
	mov multiplicacionH, r1
	
	;aqui sigue tu codigo intacto de extraccion de centenas etc

	;extraer centenas para el display decenas de millar del valor real
	;restamos 10000 0x2710 en hexadecimal
	clr centenas
	ldi valorRestaL, 0x10 
	ldi valorRestaH, 0x27 
loopRestarDiezMil:
	cp multiplicacionL, valorRestaL
	cpc multiplicacionH, valorRestaH
	brcs finRestarDiezMil;si es menor a 10000 saltamos
	sub multiplicacionL, valorRestaL
	sbc multiplicacionH, valorRestaH
	inc centenas            
	rjmp loopRestarDiezMil
finRestarDiezMil:

	;extraer decenas para el display unidades de millar del valor real
	;restamos 1000 0x03e8 en hexadecimal
	clr decenas
	ldi valorRestaL, 0xE8 
	ldi valorRestaH, 0x03 
loopRestarMil:
	cp multiplicacionL, valorRestaL
	cpc multiplicacionH, valorRestaH
	brcs finRestarMil
	sub multiplicacionL, valorRestaL
	sbc multiplicacionH, valorRestaH
	inc decenas
	rjmp loopRestarMil
finRestarMil:

	;extraer unidades para el display centenas del valor real
	;restamos 100 0x0064 en hexadecimal
	clr unidades
	ldi valorRestaL, 0x64 
	ldi valorRestaH, 0x00 
loopRestarCien:
	cp multiplicacionL, valorRestaL
	cpc multiplicacionH, valorRestaH
	brcs finRestarCien
	sub multiplicacionL, valorRestaL
	sbc multiplicacionH, valorRestaH
	inc unidades
	rjmp loopRestarCien
finRestarCien:

	;el residuo en multiplicacionl h se ignora
	reti

compb:
	nop
	reti

interrupcionTimer0:
	;guardar registro de estado y temp en nuestros registros auxiliares
	mov auxTemp, temp
	in temp, sreg
	mov auxSreg, temp

	;1 apagar todos los displays logica negativa mandamos un 1 para apagar
	in temp, portc
	ori temp, $07;0000 0111 ponemos 1 en c0 c1 y c2
	out portc, temp

	;2 determinar que display toca encender
	cpi displayActual, 0
	breq mostrarCentenas
	cpi displayActual, 1
	breq mostrarDecenas
	rjmp mostrarUnidades

mostrarCentenas:
	ldi ZH, $01
	ldi ZL, $00
	add ZL, centenas
	ld temp, Z
	
	;control del punto decimal
	cpi modoActual, 0;revisamos directo el registro
	brne apagarPunto;si no es 0 es sensor saltamos el encendido del punto

prenderPunto:
	ori temp, $80;fuerza el bit 7 a 1 solo para el voltaje

apagarPunto:
	out portd, temp
	
	in temp, portc
	andi temp, $FE;ponemos 0 en c0 para prenderlo
	out portc, temp
	
	ldi displayActual, 1
	rjmp finTimer0

mostrarDecenas:
	ldi ZH, $01
	ldi ZL, $00
	add ZL, decenas
	ld temp, Z
	out portd, temp
	
	in temp, portc
	andi temp, $FD;1111 1101 ponemos 0 solo en c1 para prenderlo
	out portc, temp
	
	ldi displayActual, 2
	rjmp finTimer0

mostrarUnidades:
	ldi ZH, $01
	ldi ZL, $00
	add ZL, unidades
	ld temp, Z
	out portd, temp
	
	in temp, portc
	andi temp, $FB;1111 1011 ponemos 0 solo en c2 para prenderlo
	out portc, temp
	
	ldi displayActual, 0

finTimer0:
	;restaurar registros desde nuestros auxiliares
	mov temp, auxSreg
	out sreg, temp
	mov temp, auxTemp
	reti


interrupcionTimer1:
    reti