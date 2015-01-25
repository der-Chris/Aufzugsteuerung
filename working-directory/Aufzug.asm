; Aufzugsteuerung mit 3 Stockwerken
;
; Portbelegung:
; P0.0	Knöpfe 	Außen	0
;    1					1
;    2					2
;    3			Innen	0
;    4					1
;    5					2
;    6		
;    7			Tür zu
;
; P1.0	Motor	Tür		Auf
;    1					Zu
;    2			Aufzug	Hoch
;    3					Runter
;    4	Licht 	Knöpfe	0
;    5					1
;    6					2
;    7	Gong
;
; P2.0	Sensor	Tür		Auf
;    1					Zu
;    2			Druck
;    3			Lichtschranke
;    4			Stock	0
;    5					1
;    6					2
;    7		-----
;
; P3	Display
;
; EX0	Notruf
;
; R0	Button 0 has been pressed
; R1	Button 1 has been pressed
; R2	Button 2 has been pressed
; R8	Direction the Elevator is headding. R8 = 0 -> up, R8 = 1 -> down


CSEG AT 100H
LJMP init_interrupts


; Interrupt Address for ExternalInterrupt0 -> Emergency Button
ORG 03h
LCALL ext0 ; try LCALL. If error use CALL instead
RETI


; Interrupt Address for Timer0
; This Interrupt checks every 5ms if the Sensors are triggered
ORG 0bh
LCALL timer0 ; try LCALL. If error use CALL instead
RETI


; Interrupt Address for Timer1
; This Interrupt checks every 10ms if a Button has been pressed
ORG 01bh
LCALL timer1 ; try LCALL. If error use CALL instead
RETI


;initialize interrupts
init_interrupts:
MOV TMOD, 00010001b ;Timer1: Gate1=0, C/T1 = 0, Mode1 = 01; Timer0: Gate0=0, C/T0 = 0, Mode0 = 01;
MOV TCON, 01010000b ; Timer1: TF1=0, TR1(enables Timer1)=1; Timer0: TF0=0, TR0(enables Timer0)=1;

; EA(global Interrupt Enabled) = 1, X = dont care, X = dont care, ES(enables serial interrupt)=0, 
; ET1(enables timer interrupt1)=1, EX1(enables External Interrupt1)=0,ET0(enables timer interrupt0)=0, EX0(enables External Interrupt0)=1,
; Enable Timer0 Interrupts just if it is needed
MOV IE, 10001001b 
; interrupt Priority is correct
MOV TL0, 0F9h ; 249 in Low von Timer0
MOV TH0, 09h ; 9 in High von Timer0
MOV TL1, 0F9h ; 249 in Low von Timer1
MOV TH1, 03h ; 19 in High von Timer1
RET


;initializes the parameters
init:
MOV P1, #00h ; turn off Engines -> Engines are low active
MOV P3, #0ffh ; MOV P3, #0ffh ;turn off Display -> Display is low active

CLR R0 ; R0 = 1, if Button for First Floor has been pressed
CLR R1 ; R1 = 1, if Button for Second Floor has been pressed
CLR R2 ; R2 = 1, if Button for Third Floor has been pressed

CALL initialCheckFloor
CALL checkFloor
end


; Check sensors, if sensors are triggered Or OpenDoor or SameFloor Buttons are pressed,open the doors
timer0:
MOV A, P3
ANL A, 00001100b ; If P3.2 or P3.3 is triggered, then Accu != 0
AZ initTimer0 ; And if Accu = 0, countinue
CLR P1.0
SETB P1.1 ; stop doors from closing, open doors
MOV 1, P2
ANL A, 00000001b
JZ timer0 ; when doors are not closed, wait till they are
; in the end, Timer 0 has to be reinitialized
initTimer0
MOV TL0, 0F9h ; 249 in Low von Timer0
MOV TH0, 09h ; 9 in High von Timer0
RET


;check if button is pressed
timer1:
MOV A, P0
ANL A, 00001001b ; If P0.0 or P0.3 is pressed, then Accu != 0
AZ checkSecondFloorButton ; And if Accu = 0, then check other floor
MOV R0, 01h
checkSecondFloorButton:
MOV A, P0
ANL A, 00010010b ; If P0.1 or P0.4 is pressed, then Accu != 0
AZ checkThirdFloorButton ; And if Accu = 0, then check other floor
MOV R1, 01h
checkThirdFloorButton:
MOV A, P0
ANL A, 00100100b ; If P0.2 or P0.5 is pressed, then Accu != 0
AZ initTimer1: ; And if Accu = 0, then check other floor
MOV R2, 01h
initTimer1:
; in the end, Timer 1 has to be reinitialized
MOV TL1, 0F9h ; 249 in Low von Timer1
MOV TH1, 013h ; 19 in High von Timer1
RET


ext1:
; do something usefull
MOV P3, 10000110b ;Activate LED´s for Error
RET


;check in which floor the elevator is
initialCheckFloor:
JB P2.5, endInit
JB P2.6, endInit
JB P2.7, endInit
; when we don’t know in which floor the elevator is, we wait for a button to be pressed
; when a button is pressed we close the door and drive to the firstFloor
waitForButton:
; check if a button is pressed
MOV A, P0
ANL A, 00111111b 
JZ waitForButton ;jumps if Accu equals 0
checkDoors:
JB P2.0, closeDoors
JB P2.1, driveDown

JNB P2.2, openDoors
JNB P2.3, openDoors
;closeDoor Routine
MOV A, 11111100b
ANL A, P1
MOV P1, A
SETB P1.1
endInit:
JMP checkDoors
RET


;openDoor Routine
openDoors:
MOV A, 11111100b
ANL A, P1
MOV P1, A
SETB P1.0
JMP checkDoors


driveDown:
MOV P1, 00001000b
JNB P2.4, driveDown
; ret returns to init
RET


; checks in which floor the Elevator is
checkFloor:
JB P2.5, firstFloor
JB P2.6, secondFloor
JB P2.7, thirdFloor
JMP checkFloor


;if elevator in firstFloor
firstFloor:
LCALL showFirstFloor
CLR R0

MOV A, R1
JNZ goToSecondFloor ; if secondFloor is pressed, go there
JMP checkFloor

MOV A, R1
JNZ goToSecondFloor ; if secondFloor is pressed, go there
JMP checkFloor

secondFloor:
LCALL showSecondFloor
CLR R1
JMP checkFloor


thirdFloor:
LCALL showThirdFloor
CLR R2

JMP checkFloor


floorLogic:
; implement floorLogic
RET


showFirstFloor:
MOV P3, 11111001b ;Activate LED´s for first Floor
RET


showSecondFloor:
MOV P3, 10100100b ;Activate LED´s for second Floor
RET


showThirdFloor:
MOV P3, 10110000b ;Activate LED´s for third Floor
RET


goToFirstFloor:

JMP firstFloor


goToSecondFloor:

JMP secondFloor


goToThirdFloor:

JMP thirdFloor

closeDoors:
JB P2.1, dooresClosed
MOV A, IE
ORL A, 00000010b
MOV IE, A ; Activate interrupt to Check DoorSensors 
CLR P1.0
SETB P1.1
JNB P2.1 closeDoores ; If Doores Are Closed STOP InterruptTimer and Return
dooresClosed:
MOV A, IE
ANL A, 11111101b
MOV IE, A ; Activate interrupt to Check DoorSensors 
RET

END