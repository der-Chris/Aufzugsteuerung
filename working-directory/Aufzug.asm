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

;Interrupt
ORG 0bh
call timer
reti

;init
ORG 20h
init:
mov P1, #00h
mov P3, #0ffh
end