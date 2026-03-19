;
; darienPracticoUno.asm
;
; Created: 18/02/2026 05:51:24 p. m.
; Author : home
;


; Replace with your application code
;ledsDeDerechaAIzquierdaEnBucle

	.def cont1=r17
	.def cont2=r18
	.def cont3=r19
	.def temp=r16
	.cseg
	.org 0

	ldi temp,$ff ;load inmediate, yo lo veo como asignacion
	out ddrd,temp ;ddrd son los pines digitales del arduino del 0 al 7, out establece como salidas los bits en 1, es decir como metemos $ff, queda como 11111111, todos los 8 bits en 1 todos como salida. si uno de esos bits fuera 0, seria una entrada
	ldi temp,$01;load inmediate
	out portd,temp;con out portd, definimos el estado, establecemos si los pines tienen 5V (High) o 0V (Low), claro atraves de hexadecimal en temp
	call delay_125s;llamada a subrutina
izquierda:	lsl temp;(Logical Shift Left) Desplaza el bit de temp hacia la izquierda (ej: de 0001 a 0010).
	out portd,temp;se define el estado de portd, mostrando el nuevo valor en los LEDs del Puerto D
	call delay_125s;llamada a subrutina
	cpi temp,$80;Compare Immediate, Compara si temp ya llegó al valor $80 (binario 10000000, el último LED).
	breq derecha;Branch if Equal, Si la comparación anterior fue verdadera (llegó al final), salta a la etiqueta derecha
	jmp izquierda;si no es igual al $80, salta izquierda
derecha: lsr temp;Logical Shift Right) Desplaza el bit de temp hacia la derecha (ej: de 0010 a 0001).
	out portd,temp;mostramos en los leds
	call delay_125s
	cpi temp,$01;compara si ya llego hasta el led de la derecha
	breq izquierda;Si la comparación anterior fue verdadera, salta a la etiqueta izquierda
	jmp derecha

delay_125s: ldi cont1,5
lazo3: ldi cont2,200;NOTA: numero mas grande posible 255
lazo2: ldi cont3,200
lazo1: nop
	nop
	nop
	nop
	nop
	nop
	nop
	dec cont3;resta 1 a cont3
	brne lazo1;Branch if Not Equal, Si cont3 no es cero, vuelve a lazo1 repitiendo los nop
	dec cont2;resta 1 a cont2
	brne lazo2;Branch if Not Equal, Si cont2 no es cero, vuelve a lazo2
	dec cont1
	brne lazo3
	ret


