;
; practicaDosEntendida.asm
;
; Created: 07/03/2026 10:47:38 p. m.
; Author : home
;


; Replace with your application code
	.def cont1=r17
	.def cont2=r18
	.def cont3=r19
	.def temp=r16
	.def contador=r20
	.def del1=r21
	.def del2=r22
	.cseg
	.org 0

	ldi temp,$FF
	out ddrd,temp
	out ddrb,temp
	
	ldi temp,$0F
	out ddrc,temp

	ldi temp,$10
	out portc,temp

	ldi contador, 0

inicio:	in temp, PINC      ; "Como el scanner de Java", lee todo el Puerto C
	andi temp, $10     ; MÁSCARA para A4: Elimina el ruido y solo mira el Bit 4
	breq boton_presionado ; Si el resultado es cero (botón presionado), salta
	jmp mostrar_display   ; Si no, salta a dibujar la matriz

boton_presionado:ldi temp, $00 ;apaga matriz
	out portb, temp
	ldi temp, $10      ; Mantiene el pull-up en PC4 vivo
	out portc, temp
	ldi temp, $FF   
	out portd, temp

	call delay_30m     ; Retardo anti-rebote inicial
	inc contador
	cpi contador, 10   ; Compara si ya llegó a 10
	brne espera
	ldi contador, 0    ; Lo regresa a 0 si llega a 10

espera:	in temp, PINC
	andi temp, $10
	breq espera        ; Si sigue siendo 0 (presionado), se queda atascado aquí (con la matriz apagada)
	
	call delay_30m     ; Retardo anti-rebote al soltar
	jmp inicio


mostrar_display:

	cpi contador, 0
	brne revisa_1      ; Si NO es 0, brinca a revisar si es el 1
	jmp dibuja_0       ; Si SÍ es 0, usa salto largo hasta el dibujo 0

revisa_1:
	cpi contador, 1
	brne revisa_2
	jmp dibuja_1

revisa_2:
	cpi contador, 2
	brne revisa_3
	jmp dibuja_2

revisa_3:
	cpi contador, 3
	brne revisa_4
	jmp dibuja_3

revisa_4:
	cpi contador, 4
	brne revisa_5
	jmp dibuja_4

revisa_5:
	cpi contador, 5
	brne revisa_6  
	jmp dibuja_5

revisa_6:
	cpi contador, 6
	brne revisa_7 
	jmp dibuja_6

revisa_7:
	cpi contador, 7
	brne revisa_8
	jmp dibuja_7

revisa_8:
	cpi contador, 8
	brne revisa_9
	jmp dibuja_8

revisa_9:
	cpi contador, 9
	brne fin_selector
	jmp dibuja_9

fin_selector:
	jmp inicio

dibuja_0:ldi temp,$00
	out portb,temp
	ldi temp,$10    
	out portc,temp
	ldi temp,$FF     
	out portd,temp

	ldi temp,$02
	out portb,temp
	ldi temp,$18    
	out portc,temp
	ldi temp,$83
	out portd,temp
	call delay_125s

	ldi temp,$0C
	out portb,temp
	ldi temp,$17     
	out portc,temp
	ldi temp,$7D
	out portd,temp
	call delay_125s

	jmp inicio    

dibuja_1:
	ldi temp,$0f;
	out portb,temp
	ldi temp,$1f;
	out portc,temp
	ldi temp,$ef;0111 1111 -> 1111 1110
	out portd,temp
	call delay_125s

	ldi temp,$04;
	out portb,temp
	ldi temp,$10;
	out portc,temp
	ldi temp,$f7;1111 0111->1110 1111
	out portd,temp
	call delay_125s

	ldi temp,$08;
	out portb,temp
	ldi temp,$10;
	out portc,temp
	ldi temp,$fb;1111 1011->1101 1111
	out portd,temp
	call delay_125s
	jmp inicio

dibuja_2:ldi temp,$00
	out portb,temp
	ldi temp,$10   
	out portc,temp
	ldi temp,$FF    
	out portd,temp

	ldi temp,$04
	out portb,temp
	ldi temp,$18    
	out portc,temp
	ldi temp,$fd
	out portd,temp
	call delay_125s

	ldi temp,$02
	out portb,temp
	ldi temp,$10    
	out portc,temp
	ldi temp,$c3
	out portd,temp
	call delay_125s

	ldi temp,$04
	out portb,temp
	ldi temp,$18  
	out portc,temp
	ldi temp,$bf
	out portd,temp
	call delay_125s

	ldi temp,$08
	out portb,temp
	ldi temp,$18  
	out portc,temp
	ldi temp,$df
	out portd,temp
	call delay_125s

	ldi temp,$00
	out portb,temp
	ldi temp,$19    
	out portc,temp
	ldi temp,$ef
	out portd,temp
	call delay_125s

	ldi temp,$00
	out portb,temp
	ldi temp,$1A 
	out portc,temp
	ldi temp,$f7
	out portd,temp
	call delay_125s

	ldi temp,$00
	out portb,temp
	ldi temp,$1C     
	out portc,temp
	ldi temp,$fb
	out portd,temp
	call delay_125s

	jmp inicio

dibuja_3: ldi temp,$00;manda unos para limpiar con el out
	out portb,temp;limpia
	out portc,temp;limpia
	out portd,temp;limpia

	ldi temp,$02;
	out portb,temp
	ldi temp,$10;0100
	out portc,temp
	ldi temp,$83;1000 0011->1100 0001
	out portd,temp
	call delay_125s

	ldi temp,$0c;1100
	out portb,temp
	ldi temp,$16;0110
	out portc,temp
	ldi temp,$7f;->1111 1110
	out portd,temp
	call delay_125s

	ldi temp,$00;
	out portb,temp
	ldi temp,$11;0100
	out portc,temp
	ldi temp,$83;1000 0011->1100 0001
	out portd,temp
	call delay_125s

	ldi temp,$00;
	out portb,temp
	ldi temp,$18;0100
	out portc,temp
	ldi temp,$83;1000 0011->1100 0001
	out portd,temp
	call delay_125s
	jmp inicio

dibuja_4:ldi temp,$00;manda unos para limpiar con el out
	out portb,temp;limpia
	out portc,temp;limpia
	out portd,temp;limpia

	ldi temp,$0f;
	out portb,temp
	ldi temp,$1f;0100
	out portc,temp
	ldi temp,$ef;1110 f->1111 0111
	out portd,temp
	call delay_125s

	ldi temp,$04;0010
	out portb,temp
	ldi temp,$11;0001
	out portc,temp
	ldi temp,$f7;1111 1011->1101 1111
	out portd,temp
	call delay_125s

	ldi temp,$08;0010
	out portb,temp
	ldi temp,$11;0001
	out portc,temp
	ldi temp,$fb;1111 1011->1101 1111
	out portd,temp
	call delay_125s

	ldi temp,$00;0010
	out portb,temp
	ldi temp,$11;0001
	out portc,temp
	ldi temp,$fd;1111 1011->1101 1111
	out portd,temp
	call delay_125s

	ldi temp,$00;0010
	out portb,temp
	ldi temp,$11;0001
	out portc,temp
	ldi temp,$df;1101 1111 f->1111 1011
	out portd,temp
	call delay_125s
	
	jmp inicio

dibuja_5:ldi temp,$00
	out portb,temp
	ldi temp,$10 
	out portc,temp
	ldi temp,$FF     
	out portd,temp

	ldi temp,$02   
	out portb,temp
	ldi temp,$19    
	out portc,temp
	ldi temp,$83   
	out portd,temp
	call delay_125s

	ldi temp,$0C 
	out portb,temp
	ldi temp,$10     
	out portc,temp
	ldi temp,$FB    
	out portd,temp
	call delay_125s

	ldi temp,$00  
	out portb,temp
	ldi temp,$16 
	out portc,temp
	ldi temp,$BF      
	out portd,temp
	call delay_125s

	jmp inicio

dibuja_6:ldi temp,$00
	out portb,temp
	ldi temp,$10     
	out portc,temp
	ldi temp,$FF    
	out portd,temp

	ldi temp,$02   
	out portb,temp
	ldi temp,$19      
	out portc,temp
	ldi temp,$83     
	out portd,temp
	call delay_125s

	ldi temp,$0C    
	out portb,temp
	ldi temp,$16     
	out portc,temp
	ldi temp,$FB   
	out portd,temp
	call delay_125s

	ldi temp,$00   
	out portb,temp
	ldi temp,$16     
	out portc,temp
	ldi temp,$BF      
	out portd,temp
	call delay_125s

	jmp inicio

dibuja_7:ldi temp,$00
	out portb,temp
	ldi temp,$10   
	out portc,temp
	ldi temp,$FF  
	out portd,temp

	ldi temp,$02      
	out portb,temp
	ldi temp,$10     
	out portc,temp
	ldi temp,$83    
	out portd,temp
	call delay_125s

	ldi temp,$0C     
	out portb,temp
	ldi temp,$1F     
	out portc,temp
	ldi temp,$BF      
	out portd,temp
	call delay_125s

	jmp inicio

dibuja_8:ldi temp,$00
	out portb,temp
	ldi temp,$10  
	out portc,temp
	ldi temp,$FF  
	out portd,temp

	ldi temp,$02      
	out portb,temp
	ldi temp,$19 
	out portc,temp
	ldi temp,$83      
	out portd,temp
	call delay_125s

	ldi temp,$0C      
	out portb,temp
	ldi temp,$16      
	out portc,temp
	ldi temp,$BB
	out portd,temp
	call delay_125s

	jmp inicio


dibuja_9:ldi temp,$00
	out portb,temp
	ldi temp,$10    
	out portc,temp
	ldi temp,$FF     
	out portd,temp

	ldi temp,$02       
	out portb,temp
	ldi temp,$19       
	out portc,temp
	ldi temp,$83       
	out portd,temp
	call delay_125s

	ldi temp,$0C       
	out portb,temp
	ldi temp,$10   
	out portc,temp
	ldi temp,$FB      
	out portd,temp
	call delay_125s

	ldi temp,$0C       
	out portb,temp
	ldi temp,$16    
	out portc,temp
	ldi temp,$BF      
	out portd,temp
	call delay_125s

	jmp inicio

delay_125s: ldi cont1,5
lazo3: ldi cont2,25;NOTA: numero mas grande posible 255
lazo2: ldi cont3,25
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

delay_30m: 
	ldi del1, 200
lazo2_30m: 
	ldi del2, 240
lazo1_30m: 
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	dec del2
	brne lazo1_30m
	dec del1
	brne lazo2_30m
	ret
