;
; listoParaPracticaUno.asm
;
; Created: 21/02/2026 07:21:42 p. m.
; Author : home
;


; Replace with your application code
;;si no presiono el boton es 1, pero si lo presiono es cero
	.def cont2=r19
	.def cont1=r18
	.def contador=r17
	.def temp=r16
	.cseg
	.org 0

	ldi temp,$ff
	out ddrd,temp
	ldi temp,$01
	out portc,temp;portc son los pines analogos, pero como es portc se asume que son entradas, ya que no modificamos ddrc para establecer si son entradas o salidas, asi que al ser entrada out asigna pull up (al meter el temp con 1) para SENTIR cambios (leer botones) sin riesgo de cortocircuito
	ldi contador,$00
main: in temp,pinc;pinc es para leer, como el scanner de java, asi que in guarda en temp lo que leyo en pinc
	andi temp,$01;es una mascara que elimina el ruido, fuerzando a que todos los pines del A1 al A5 se conviertan en 0, asi tomando en cuenta unicamente el $01
	breq contar; Branch if Equal to zero, salta a contar si el resultado anterior es cero
	jmp main

contar: call delay_30m
	inc contador
	out portd,contador;damos valores de 5v a los bits del portd, de acuerdo a contador
espera: in temp,pinc
	andi temp,$01
	breq espera; al soltar el boton breq recibiria un 1, asi que no es cero y no saltaria a espera
	call delay_30m;delay al soltar el boton
	jmp main

delay_30m: ldi cont1,200
lazo2: ldi cont2,240
lazo1: nop
	nop
	nop
	nop
	nop
	nop
	nop
	dec cont2
	brne lazo1;si no es cero
	dec cont1
	brne lazo2
	ret