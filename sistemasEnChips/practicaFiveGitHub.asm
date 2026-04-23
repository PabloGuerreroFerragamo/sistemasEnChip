; practica 5 frecuenciometro

	; --- ASIGNACIÓN DE NOMBRES A LOS REGISTROS ---
	.def temp=r16        ; Registro de propósito general para mover datos
	.def u_aux = r17     ; Guarda las unidades que se van a mostrar en el display
	.def d_aux = r18     ; Guarda las decenas que se van a mostrar en el display
	.def c_aux = r19     ; Guarda las centenas que se van a mostrar en el display
	.def unidades = r20  ; Contador en vivo de los pulsos (unidades)
	.def decenas = r21   ; Contador en vivo de los pulsos (decenas)
	.def centenas = r22  ; Contador en vivo de los pulsos (centenas)
	.def mux = r23       ; Controla qué display (transistor) está encendido

	; --- TABLA DE VECTORES DE INTERRUPCIÓN ---
	.cseg                ; Inicia el segmento de código (Memoria Flash)
	.org 0x0000          ; Dirección de inicio al encender/resetear
	jmp reset            ; Salta a la configuración inicial

	.org 0x0002          ; Dirección de la interrupción externa 0 (Pin D2)
	jmp int0_isr         ; Salta a la rutina que cuenta los pulsos

	.org 0x0012          ; Dirección de desbordamiento del Timer2
	jmp timer2_ovf_isr   ; Salta a la rutina que genera la onda de prueba

	.org 0x0016          ; Dirección de comparación A del Timer1 (1 segundo)
	jmp timer1_compa_isr ; Salta a la rutina que actualiza la pantalla

	.org 0x0020          ; Dirección de desbordamiento del Timer0
	jmp timer0_ovf_isr   ; Salta a la rutina que multiplexa los displays

reset:
	; --- CONFIGURACIÓN DE PUERTOS (ENTRADAS/SALIDAS) ---
	ldi temp, $FB        ; 1111 1011 en binario (El bit 2 es 0)
	out ddrd, temp       ; Puerto D: PD2 como entrada (INT0), los demás como salidas (Displays)
	
	ldi temp, $07        ; 0000 0111 en binario
	out ddrc, temp       ; Puerto C: C0, C1 y C2 como salidas (Para los transistores)
	
	ldi temp, $20        ; 0010 0000 en binario
	out ddrb, temp       ; Puerto B: B5 como salida (Onda generada), B0 y B1 como entradas (Botones)
	
	ldi temp, $03        ; 0000 0011 en binario
	out portb, temp      ; Activa las resistencias Pull-up internas para los botones en B0 y B1

	; --- CARGA DE PATRONES DE 7 SEGMENTOS A LA MEMORIA SRAM ---
	; Se guardan en las direcciones $0100 a $0109 para usarlas como un arreglo
	ldi temp, $FA        ; Código para el número 0
	sts $0100, temp
	ldi temp, $60        ; Código para el número 1
	sts $0101, temp
	ldi temp, $D9        ; Código para el número 2
	sts $0102, temp
	ldi temp, $F1        ; Código para el número 3
	sts $0103, temp
	ldi temp, $63        ; Código para el número 4
	sts $0104, temp
	ldi temp, $B3        ; Código para el número 5
	sts $0105, temp
	ldi temp, $Bb        ; Código para el número 6
	sts $0106, temp
	ldi temp, $E0        ; Código para el número 7
	sts $0107, temp
	ldi temp, $Fb        ; Código para el número 8
	sts $0108, temp
	ldi temp, $F3        ; Código para el número 9
	sts $0109, temp

	; --- INICIALIZACIÓN DE VARIABLES EN CERO ---
	clr u_aux            ; Limpia el registro de display unidades
	clr d_aux            ; Limpia el registro de display decenas
	clr c_aux            ; Limpia el registro de display centenas
	clr unidades         ; Limpia el contador de unidades
	clr decenas          ; Limpia el contador de decenas
	clr centenas         ; Limpia el contador de centenas
	ldi mux, $06         ; $06 (110) apaga C0 (unidades) si usas PNP, o lo enciende según tu hardware

	; --- CONFIGURACIÓN DEL TIMER0 (MULTIPLEXACIÓN) ---
	ldi temp, $03        ; Configura el preescalador a 64
	out tccr0b, temp     ; Inicia el Timer0
	ldi temp, $01        ; Bit TOIE0 en 1
	sts timsk0, temp     ; Habilita la interrupción por desbordamiento del Timer0

	; --- CONFIGURACIÓN DEL TIMER1 (BASE DE TIEMPO DE 1 SEGUNDO) ---
	ldi temp, $0C        ; Modo CTC (Limpia al comparar con OCR1A) y Preescalador de 256
	sts tccr1b, temp     ; (16,000,000 Hz / 256) = 62,500 ticks por segundo
	ldi temp, $f4        ; Parte alta de 62,500 ($F424)
	sts ocr1ah, temp     ; Carga $F4 al registro de comparación alto
	ldi temp, $24        ; Parte baja de 62,500 ($F424)
	sts ocr1al, temp     ; Carga $24 al registro de comparación bajo
	ldi temp, $02        ; Bit OCIE1A en 1
	sts timsk1, temp     ; Habilita la interrupción por comparación A del Timer1

	; --- CONFIGURACIÓN DEL TIMER2 (GENERADOR DE FRECUENCIA DE PRUEBA) ---
	ldi temp, $07        ; Configura el preescalador inicial a 1024 (Frecuencia más lenta)
	sts tccr2b, temp     ; Inicia el Timer2
	ldi temp, $01        ; Bit TOIE2 en 1
	sts timsk2, temp     ; Habilita la interrupción por desbordamiento del Timer2

	; --- CONFIGURACIÓN DE LA INTERRUPCIÓN EXTERNA (INT0) ---
	ldi temp, $03        ; ISC01=1, ISC00=1 (Detecta solo flancos de subida, transición 0 a 1)
	sts eicra, temp      ; Configura el comportamiento de INT0
	ldi temp, $01        ; Bit INT0 en 1
	out eimsk, temp      ; Habilita el pin externo INT0 (D2) para interrumpir el micro

	sei                  ; (Set Enable Interrupts) Activa las interrupciones globales

main:
	; --- LAZO PRINCIPAL: LECTURA DE BOTONES PARA CAMBIAR FRECUENCIA ---
	in temp, pinb        ; Lee el estado físico del puerto B
	andi temp, $03       ; Aplica una máscara AND para quedarse solo con los bits B0 y B1
	
	cpi temp, $00        ; Compara si ambos botones están presionados (00)
	breq set_n64         ; Si es igual, salta a configurar preescalador 64
	
	cpi temp, $01        ; Compara si B1 presionado y B0 sin presionar (01)
	breq set_n128        ; Si es igual, salta a configurar preescalador 128
	
	cpi temp, $02        ; Compara si B1 sin presionar y B0 presionado (10)
	breq set_n256        ; Si es igual, salta a configurar preescalador 256
	
	; Si no fue ninguna de las anteriores (están en 11, sin presionar)
	ldi temp, $07        ; Carga el valor para preescalador 1024
	rjmp update_t2       ; Salta a la actualización del timer
	
set_n64:
	ldi temp, $04        ; Carga el valor para preescalador 64
	rjmp update_t2       ; Salta a la actualización
	
set_n128:
	ldi temp, $05        ; Carga el valor para preescalador 128
	rjmp update_t2       ; Salta a la actualización
	
set_n256:
	ldi temp, $06        ; Carga el valor para preescalador 256

update_t2:
	sts tccr2b, temp     ; Inyecta el nuevo preescalador al Timer2 "en caliente"
	rjmp main            ; Vuelve al inicio del lazo infinito

; --- RUTINA DEL TIMER1: REFRESCO DE PANTALLA (CADA 1 SEGUNDO) ---
timer1_compa_isr:
	mov u_aux, unidades  ; "Toma la foto" de las unidades contadas y las pasa al display
	mov d_aux, decenas   ; "Toma la foto" de las decenas
	mov c_aux, centenas  ; "Toma la foto" de las centenas
	clr unidades         ; Reinicia a 0 el contador de unidades para el nuevo segundo
	clr decenas          ; Reinicia a 0 el contador de decenas
	clr centenas         ; Reinicia a 0 el contador de centenas
	reti                 ; Retorna de la interrupción

; --- RUTINA DE INT0: CONTADOR BCD DE PULSOS DE ENTRADA ---
int0_isr:
	inc unidades         ; Suma 1 al contador de unidades cada que hay un flanco de subida
	cpi unidades, 10     ; Revisa si las unidades llegaron a 10
	brne end_int0        ; Si NO es 10, sale de la interrupción
	
	clr unidades         ; Si llegó a 10, regresa las unidades a 0
	inc decenas          ; Le pasa el acarreo a las decenas (suma 1)
	cpi decenas, 10      ; Revisa si las decenas llegaron a 10
	brne end_int0        ; Si NO es 10, sale de la interrupción
	
	clr decenas          ; Si llegó a 10, regresa las decenas a 0
	inc centenas         ; Le pasa el acarreo a las centenas (suma 1)
	
end_int0:
	reti                 ; Retorna de la interrupción

; --- RUTINA DEL TIMER2: GENERADOR DE SEÑAL CUADRADA ---
timer2_ovf_isr:
	sbi pinb, 5          ; Escribir un 1 en el registro PIN de una salida invierte su estado (Toggle). Genera la onda.
	reti                 ; Retorna de la interrupción

; --- RUTINA DEL TIMER0: MULTIPLEXACIÓN DE LOS DISPLAYS ---
timer0_ovf_isr:
	ldi temp, $07        ; Carga 0000 0111
	out portc, temp      ; Apaga todos los transistores para evitar displays sobrepuestos ("Ghosting")
	
	cpi mux, $06         ; Revisa si es el turno de las unidades
	breq d_uni           ; Salta a la etiqueta de unidades
	cpi mux, $05         ; Revisa si es el turno de las decenas
	breq d_dec           ; Salta a la etiqueta de decenas

d_cen:
	ldi zh, $01          ; Puntero Z (Parte alta): Apunta a la página $0100 de SRAM
	mov zl, c_aux        ; Puntero Z (Parte baja): Suma el valor de las centenas como Offset
	ld temp, Z           ; Extrae el código de 7 segmentos de esa dirección de memoria
	out portd, temp      ; Lo manda físicamente a los pines del display
	ldi mux, $06         ; Prepara la variable mux para que el siguiente turno sean las unidades
	ldi temp, $03        ; Carga el valor para encender el transistor de centenas
	out portc, temp      ; Lo manda al puerto C
	reti                 ; Retorna de la interrupción

d_uni:
	ldi zh, $01          ; Puntero Z (Parte alta): Apunta a la página $0100 de SRAM
	mov zl, u_aux        ; Puntero Z (Parte baja): Suma el valor de las unidades como Offset
	ld temp, Z           ; Extrae el código de 7 segmentos
	out portd, temp      ; Lo manda al display
	ldi mux, $05         ; Prepara la variable mux para que el siguiente turno sean las decenas
	ldi temp, $06        ; Carga el valor para encender el transistor de unidades
	out portc, temp      ; Lo manda al puerto C
	reti                 ; Retorna de la interrupción

d_dec:
	ldi zh, $01          ; Puntero Z (Parte alta): Apunta a la página $0100 de SRAM
	mov zl, d_aux        ; Puntero Z (Parte baja): Suma el valor de las decenas como Offset
	ld temp, Z           ; Extrae el código de 7 segmentos
	out portd, temp      ; Lo manda al display
	ldi mux, $03         ; Prepara la variable mux para que el siguiente turno sean las centenas
	ldi temp, $05        ; Carga el valor para encender el transistor de decenas
	out portc, temp      ; Lo manda al puerto C
	reti                 ; Retorna de la interrupción