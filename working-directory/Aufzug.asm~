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
; R7	Direction the Elevator is headding. R7 = 0 -> up, R7 = 1 -> down
CSEG AT 00H
LJMP init_interrupts

; Interrupt Address for ExternalInterrupt0 -> Emergency Button
ORG 03h
LCALL ext0
RETI


; Interrupt Address for Timer0
; This Interrupt checks every 5ms if the Sensors are triggered
ORG 0bh
LCALL timer0_ISR
RETI


; Interrupt Address for Timer1
; This Interrupt checks every 10ms if a Button has been pressed
ORG 01bh
LCALL timer1_ISR
RETI

CSEG AT 0100H
;initialize interrupts
init_interrupts:
MOV TMOD, #00010001b 
;Timer1: Gate1=0, C/T1 = 0, Mode1 = 01 ; Timer0: Gate0=0, C/T0 = 0, Mode0 = 01
MOV TCON, #01010000b 
; Timer1: TF1=0, TR1(enables Timer1)=1; Timer0: TF0=0, TR0(enables Timer0)=1

; EA(global Interrupt Enabled) = 1, X = dont care, X = dont care, ES(enables serial interrupt)=0, 
; ET1(enables timer interrupt1)=1, EX1(enables External Interrupt1)=0,ET0(enables timer interrupt0)=0, EX0(enables External Interrupt0)=1,
; Enable Timer0 Interrupts just if it is needed
MOV IE, #10001001b 
; interrupt Priority is correct
MOV TL0, #0F9h ; 249 in Low von Timer0
MOV TH0, #09h ; 9 in High von Timer0
MOV TL1, #0F9h ; 249 in Low von Timer1
MOV TH1, #03h ; 19 in High von Timer1
RET


;initializes the parameters
init:
MOV P1, #00h ; turn off Engines -> Engines are low active
MOV P3, #0ffh ; MOV P3, #0ffh ;turn off Display -> Display is low active

MOV R0, #00h ; R0 = 1, if Button for First Floor has been pressed
MOV R1, #00h ; R1 = 1, if Button for Second Floor has been pressed
MOV R2, #00h ; R2 = 1, if Button for Third Floor has been pressed

LCALL initialCheckFloor
JMP goingDown



; do something usefull
ext0:
MOV P3, 10000110b ;Activate LED´s for Error
RET


; Check sensors, if sensors are triggered Or OpenDoor or SameFloor Buttons are pressed,open the doors
timer0_ISR:
MOV A, P3
ANL A, #00001100b ; If P3.2 or P3.3 is triggered, then Accu != 0
JZ checkDoorButtons ; And if Accu = 0, countinue
CLR P1.0
SETB P1.1 ; stop doors from closing, open doors
MOV A, P2
ANL A, #00000001b
JZ timer0_ISR ; when doors are not closed, wait till they are
; If sensors are not triggered, check if a button from floor the elevator is in, is pressed
checkDoorButtons:
JB P2.4, checkFirstFloorDoors
JB P2.5, checkSecondFloorDoors
JB P2.6, checkThirdFloorDoors
; Elevator has to be in one Floor
checkFirstFloorDoors:
MOV A, P0
ANL A, #00001001b
JZ initTimer0
closeDoorsFirstFloor:
MOV A, P2
ANL A, #00000001b
JZ closeDoorsFirstFloor ; when doors are not closed, wait till they are
JMP initTimer0
checkSecondFloorDoors:
MOV A, P0
ANL A, #00010010b
JZ initTimer0
closeDoorsSecondFloor:
MOV A, P2
ANL A, #00000001b
JZ closeDoorsSecondFloor ; when doors are not closed, wait till they are
JMP initTimer0
checkThirdFloorDoors:
MOV A, P0
ANL A, #00100100b
JZ initTimer0
closeDoorsThirdFloor:
MOV A, P2
ANL A, #00000001b
JZ closeDoorsThirdFloor ; when doors are not closed, wait till they are
JMP initTimer0
; in the end, Timer 0 has to be reinitialized
initTimer0:
MOV TL0, #0F9h ; 249 in Low von Timer0
MOV TH0, #09h ; 9 in High von Timer0
RET


;check if button is pressed
timer1_ISR:
MOV A, P0
ANL A, #00001001b ; If P0.0 or P0.3 is pressed, then Accu != 0
JZ checkSecondFloorButton ; And if Accu = 0, then check other floor
MOV R0, #01h
checkSecondFloorButton:
MOV A, P0
ANL A, #00010010b ; If P0.1 or P0.4 is pressed, then Accu != 0
JZ checkThirdFloorButton ; And if Accu = 0, then check other floor
MOV R1, #01h
checkThirdFloorButton:
MOV A, P0
ANL A, #00100100b ; If P0.2 or P0.5 is pressed, then Accu != 0
JZ initTimer1 ; And if Accu = 0, then check other floor
MOV R2, #01h
initTimer1:
; in the end, Timer 1 has to be reinitialized
MOV TL1, #0F9h ; 249 in Low von Timer1
MOV TH1, #013h ; 19 in High von Timer1
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
ANL A, #00111111b 
JZ waitForButton ;jumps if Accu equals 0

; dont check if closed or so, just to it
LCALL closeDoors
LCALL driveDown
LCALL openDoors
endInit:
RET


;openDoor Routine
openDoors:
CLR P1.1
SETB P1.0
JNB P2.0, openDoors
CLR P1.0
RET


;drive Down, till in first Floor
driveDown:
SETB P1.3
JNB P2.4, driveDown
CLR P1.3
RET


floorLogic:
; implement floorLogic
CALL openDoors
; here could be a timer
CALL closeDoors
; Check if we are on top or at the bottom. If we are at the button, first try getting up.
CJNE R0, #00h, goingUp
CJNE R2, #00h, goingDown
CJNE R7, #00h, goingDown
JMP goingUp


; Routine to Travel to FirstFloor
goToFirstFloor:
CLR P1.2
SETB P1.3
JNB P2.4, goToFirstFloor
CLR P1.3
LCALL showFirstFloor
JMP floorLogic

; Routine to Travel to SecondFloor
goToSecondFloor:
JB P0.4, firstFloorToSecondFloor
JB P2.6, thirdFloorToSecondFloor
; Elevator has to be in one Floor
firstFloorToSecondFloor:
CLR P1.3
SETB P1.2
JNB P2.5, goToFirstFloor
CLR P1.2
LCALL showSecondFloor
JMP floorLogic
thirdFloorToSecondFloor:
CLR P1.2
SETB P1.3
JNB P2.5, goToFirstFloor
CLR P1.3
LCALL showSecondFloor
JMP floorLogic


; Routine to Travel to ThirdFloor
goToThirdFloor:
CLR P1.3
SETB P1.2
JNB P2.6, goToFirstFloor
CLR P1.2
LCALL showThirdFloor
JMP floorLogic


; Routine to Close the Doors
closeDoors:
JB P2.1, dooresClosed
MOV A, IE
ORL A, #00000010b
MOV IE, A ; Activate interrupt to Check DoorSensors 
CLR P1.0
SETB P1.1
JNB P2.1, closeDoors ; If Doores Are Closed STOP InterruptTimer and Return
dooresClosed:
MOV A, IE
ANL A, #11111101b
MOV IE, A ; Activate interrupt to Check DoorSensors 
RET


goingDown:
MOV R7, #01h
MOV A,R1
JNZ goToSecondFloor
MOV A, R0
JNZ goToFirstFloor
; if no button is pressed, check if button is pressed to drive up
JMP goingUP


goingUp:
MOV R7, #00h
MOV A,R1
JNZ goToSecondFloor
MOV A, R2
JNZ goToThirdFloor
; if no button is pressed, check if button is pressed to drive down
JMP goingDown


showFirstFloor:
MOV P3, #11111001b ;Activate LED´s for first Floor
RET


showSecondFloor:
MOV P3, #10100100b ;Activate LED´s for second Floor
RET


showThirdFloor:
MOV P3, #10110000b ;Activate LED´s for third Floor
RET


END