;Aufzugsteuerung mit 3 Stockwerken
;
;Portbelegung:
;P0.0	Knöpfe 	Außen	0
;   1			1
;   2			2
;   3		Innen	0
;   4			1
;   5			2
;   6		Notruf
;   7		Tür zu
;
;P1.0	Motor	Tür	Auf
;   1			Zu
;   2		Aufzug	Hoch
;   3			Runter
;   4	Licht 	Knöpfe	0
;   5			1
;   6			2
;   7	Gong
;
;P2.0	Sensor	Tür	Auf
;   1			Zu
;   2			Druck
;   3			Lichtschranke
;   4		Stock	0
;   5			1
;   6			2
;   7	-----
;
;P3	Display
CSEG AT 0H
ljmp init
CSEG AT 100H

;Interrupt Address for Timer0
ORG 0bh
LCALL timer0 ;try LCALL. If error use CALL instead
RETI

;Interrupt Address for Timer1
ORG 01bh
LCALL timer1 ;try LCALL. If error use CALL instead
RETI

;initialize interrupts
init_interrupts:
MOV TMOD, 00010001b ;Timer1: Gate1=0, C/T1 = 0, Mode1 = 01; Timer0: Gate0=0, C/T0 = 0, Mode0 = 01;
MOV TCON, 01010000b ; Timer1: TF1=0, TR1(enables Timer1)=1; Timer0: TF0=0, TR0(enables Timer0)=1;
; EA(global Interrupt Enabled) = 1, X = dont care, X = dont care, ES(enables serial interrupt)=0, 
; ET1(enables timer interrupt1)=1, EX1(enables External Interrupt1)=0,ET0(enables timer interrupt0)=1, EX0(enables External Interrupt0)=0,
MOV IE, 10001010b ; interrupt Priority is correct
MOV TL0, 0F9h ; 249 in Low von Timer0
MOV TH0, 01h ; 1 in High von Timer0
MOV TL1, 0F9h ; 249 in Low von Timer1
MOV TH1, 03h ; 3 in High von Timer1

;init
; dont know whats done here anymore
ORG 20h
init:
mov P1, #00h
mov P3, #0ffh
end

timer0:

; in the end, Timer 0 has to be reinitialized
MOV TL0, 0F9h ; 249 in Low von Timer0
MOV TH0, 01h ; 1 in High von Timer0
RET

timer1:

; in the end, Timer 1 has to be reinitialized
MOV TL1, 0F9h ; 249 in Low von Timer1
MOV TH1, 03h ; 3 in High von Timer1
RET