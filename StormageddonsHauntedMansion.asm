TITLE Stormageddon's Haunted Mansion     (StormageddonsHauntedMansion.asm)

; Author: Megan Wooley
; Last Modified: 5/21/2023
; Description: Text-based mystery game that takes you into a haunted mansion.

INCLUDE Irvine32.inc

checkChoice MACRO lower_limit, upper_limit, choice
	LOCAL _InvalidChoice, _Leave
	cmp choice, lower_limit
	jl _InvalidChoice
	cmp choice, upper_limit
	jg _InvalidChoice
	jmp _Leave

_InvalidChoice:
	mov choice, 0

_Leave:
ENDM

getKeyPress MACRO
LOCAL _LookForKey

_LookForKey:
	mov EAX, 10
	call Delay
	call ReadKey
	jz _LookForKey

ENDM

getCursorPos MACRO
	push EAX
	invoke GetStdHandle, STD_OUTPUT_HANDLE
	mov hStdOut, EAX
    invoke GetConsoleScreenBufferInfo, hStdOut, ADDR CursorPos
	pop EAX
ENDM


DEFAULT_DISPLAY			TEXTEQU %(15 + (0*16))			; Default: white text, black background	
OPTIONS_DISPLAY			TEXTEQU %(2 + (0*16))			; Title: green text, black background
DIALOGUE_DISPLAY		TEXTEQU %(9 + (0*16))			; Dialogue: lightBlue text, black background
FATAL_DISPLAY			TEXTEQU	%(12 + (0*16))			; Fatal: lightRed text, black background

ARRAY_SIZE = 4000
BUFFER_SIZE = 6
DELAY_TIME = 1200
STD_OUTPUT_HANDLE equ -11

COORD STRUCT
    X WORD ?
    Y WORD ?
COORD ENDS


.data
; Special
CursorPos CONSOLE_SCREEN_BUFFER_INFO <>			
cursorX											WORD			?
cursorY											WORD			?		
hStdOut											DWORD			?

; Prompts
choice_prompt									BYTE			"You decide to: ",0
fatal_prompt									BYTE			"You have made a fatal choice. Would you like to try again (Y/N)? ",0

; Files
splash_file										BYTE			"splashPage.txt",0
laptop_login_file								BYTE			"login.txt",0
laptop_diary_file								BYTE			"laptopNote.txt",0
sticky_note_file								BYTE			"stickyNote.txt",0
portrait_file									BYTE			"catPortrait.txt",0
portrait_plate_file								BYTE			"catPortraitPlate.txt",0
txtArray										BYTE			ARRAY_SIZE DUP(0),0
txtPuzzle										BYTE			"textPuzzle.txt",0
ouijaBoard										BYTE			"ouija.txt",0
ouijaT											BYTE			"ouijaT.txt",0
ouijaO											BYTE			"ouijaO.txt",0
ouijaW											BYTE			"ouijaW.txt",0
ouijaE											BYTE			"ouijaE.txt",0
ouijaR											BYTE			"ouijaR.txt",0
anniversaryNote									BYTE			"anniversaryNote.txt",0
captainBook										BYTE			"captainBook.txt",0
gameOver										BYTE			"gameOver.txt",0

; Title
; Stormageddons haunted mansion: anniversary edition splash page
instructions									BYTE			"INSTRUCTIONS",13,10,
																"------------",13,10,
																"Stormageddon's Haunted Mansion is a text-based adventure, mystery game. Numbered options will prompt you to enter",13,10,
																"the number corresponding to your action of choice. Any text based prompts should be entered in lower-case.",13,10,
																"Have fun!",13,10,13,10,0

introduction                                    BYTE			"You find yourself standing before an ominous house following the receipt of an enigmatic letter. The letter asks",13,10,
																"you to meet an unknown individual at this location. Why you actually came is unclear, but you are here now and",13,10,
																"something about the house makes you want to go in...",0

; Level 0: Outside of the house ----------------
level0_options0									BYTE			"You are standing in front of a house.",13,10,13,10,
																"1. Look at the road to the left",13,10,
																"2. Look at the road to the right",13,10,
																"3. Move to the front door",13,10,0

level0_options0_choice1_options					BYTE			"BEEEEEEEEP BEEEP BEEEEEEP BEEP BEEEEEEEEEEEEEEEEEEEEEEEEEEP",13,10,13,10,
																"1. Move towards the car",13,10,
																"2. Go back to house",13,10,0
level0_options0_options1_choice1_dialogue		BYTE			"BEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEP",13,10,0
level0_options0_choice2_dialogue				BYTE			"You see a never ending stream of bicyclists. No way you are getting past that.",13,10,0

; Level 1: At front door -----------------------
level1_keyFound									WORD			0

level1_options0									BYTE			"You are standing in front of the front door.",13,10,13,10,
																"1. Open door",13,10,
																"2. Look around door",13,10,0
																
level1_options0_choice1_noKey					BYTE			"It is locked. There must be a key around here somewhere...",13,10,0
level1_options0_choice1_key						BYTE			"You shimmy the card between the door and frame and push.",13,10,0
level1_options0_choice2_options					BYTE			"You see a small potted plant to the left of the door and a door mat in front of the door.",13,10,13,10,
																"1. Search the plant",13,10,
																"2. Lift the mat",13,10,0
level1_options0_options2_choice1_dialogue		BYTE			"Who puts poison ivy in a pot???",13,10,0
level1_options0_options2_choice2_dialogue		BYTE			"You find a thin card about the size of a credit card.",13,10,0

; Level 2: Living Room -------------------------
level2_password									DWORD			132112
level2_diaryFound								BYTE			0
level2_flashlightFound							BYTE			0

; Level 2a: Open door 
level2_options0									BYTE			"As you creak open the door, you see a small, dark figure skitter across the floor...",13,10,13,10,
																"1. Continue to open the door",13,10,
																"2. Freeze",13,10,0
level2_options0_choice1_dialgoue				BYTE			"You bravely push the door fully open. Light fills the room and you see a small, black cat staring cautiously at you.",13,10,0	
level2_options0_choice2_dialgoue				BYTE			"You freeze in fear and stay perfectly still. You cautiously peer through the barely open door and, to your horror,",13,10,
																"you see a small, black cat rolling adorably on the floor.",13,10,0

; Level 2b
level2_options1									BYTE			"You find yourself in a small living room. Inside, you see the cat on the carpet in front of you, a desk to your left,",13,10,
																"and, at the end of the room, an opening to a dark hallway. ",13,10,13,10,
																"1. Try flipping the light switch to your left",13,10,
																"2. Go left towards the desk",13,10,
																"3. Go forward towards the cat",13,10,
																"4. Move across the room to the hallway",13,10,0
; room light
level2_options1_choice1_dialogue				BYTE			"The room stays dark. Seems like the light is out.",13,10,0
; desk
level2_options1_options2						BYTE			"On the desk is an open laptop.",13,10,13,10,
																"1. Press a key on the laptop",13,10,
																"2. Look around desk",13,10,
																"3. Search drawers",13,10,
																"4. Go back to looking around living room",13,10,0
; laptop
level2_options1_options2_choice1_dialogue		BYTE			"The laptop screen lights up.",13,10,0
level2_options1_options2_options1				BYTE			"1.Try entering a password.",13,10,
																"2. Go back to desk",13,10,0
level2_options1_options2_choice1_enterPassword	DWORD			?
level2_options1_options2_choice1_badPassword	BYTE			"WRONG PASSWORD",13,10,0
level2_options1_options2_choice1_clear			BYTE			"              ",13,10,0

; desk search
level2_options1_options2_choice2_dialogue		BYTE			"Just the laptop and a bunch of crumpled paper towels?",13,10,0
level2_options1_options2_choice3_dialogue		BYTE			"You find a flashlight. This might come in handy.",13,10,0
; cat
level2_options1_options3						BYTE			"The cat continues to roll on its back adorably.",13,10,13,10,
																"1. Give some scritches behind his ears",13,10,
																"2. Pick him up",13,10,
																"3. Inpect paws",13,10,
																"4. Go back to looking around living room",13,10,0
level2_options1_options3_options1				BYTE			"The cat purrs happily. You notice a little pink paper behind his head.",13,10,13,10,
																"1. Grab pink paper",13,10,0
level2_options1_options3_choice2_dialogue		BYTE			"The cat, once cute and sweet, narrows its eyes as his ears fold back. Claws and teeth are all you see before",13,10,
																"everything goes black.",13,10,0
level2_options1_options3_choice3_dialogue		BYTE			"Toe beans!",13,10,0
; hallway
level2_options1_choice4_noFlashlight			BYTE			"The hallway is pitch black, far darker than it should be. You hear the cat hiss towards the hallway from behind you.",13,10,
																"No way are you going this way without some kind of light.",13,10,0
level2_options1_choice4_noDiary					BYTE			"You begin to move towards the hallway, but you are itching to know what is on that laptop.",13,10,0
level2_options1_choice4_nextLevel				BYTE			"You switch on the flashlight and the once dark hallway is illumintated. In the light, it is far less creepy than you",13,10,
																"expected. You look back at the cat who is now eagarly following.",13,10,0

; Level 3: Hallway -----------------------------
level3_bookFound								BYTE			0
level3_nameFound								BYTE			0
level3_doorFound								BYTE			0

level3_options0									BYTE			"The hallway has two rooms, one to the left and one to the right. At the very end of the hallway appears to be some kind",13,10,
																"of painting.",13,10,13,10,
																"1. Try the door to the left",13,10,
																"2. Try the door to the right",13,10,
																"3. Inspect the painting",13,10,0	
; Closet
level3_options0_choice1_noDoor					BYTE			"Just a small coat closet. Nothing too interesting.",13,10,0
level3_options0_choice1_secretDoor				BYTE			"You push the coats aside and discover a hidden door with stairs that lead down into a dark basement.",13,10,0

; Study
level3_options0_choice2_options					BYTE			"You walk into a small study.There is a small armchair and lamp to your right and a bookcase to your left.",13,10,13,10,
																"1. Move towards the armchair.",13,10,
																"2. Inspect the bookshelf",13,10,
																"3. Go back to the hallway",13,10,0
level3_options0_options2_choice1_dialogue		BYTE			"You search around the seat and find a quarter and an unwrapped mint. Lucky you!",13,10,0
level3_options0_options2_choice2_dialogue		BYTE			"Some interesting reads... Old Man and the Sea,  Tuna: Is it Chicken or Fish ... bet that is riveting",13,10,0
level3_options0_options2_choice2_options		BYTE			"Maybe these books can provide some background on that portrait in the hallway.",13,10,13,10,
																"1. Old Man and the Sea",13,10,
																"2. The Black Cat",13,10,
																"3. A Complete History of Spinach",13,10,
																"4. Captain Stormageddon: Into the Eye of the Storm",13,10,
																"5. Go back to study",13,10,0
level3_options0_options2_correctBook			BYTE			"A pretty compelling read but, more interestingly, you find a bookmark with the note 'Boop the snoot' scribbled",13,10,
																"on it.",13,10,0
level3_options0_options2_incorrectBook			BYTE			"You thumb through the pages and don't come across anything interesting.",13,10,0

; Painting
level3_options0_choice3_options_noPlate			BYTE			"You find yourself looking at an oil painting of a grizzeled, old cat in a sailor suit, an eye patch, and puffing a",13,10,
																"pipe. At the bottom of the frame is a small plate that seems like it should have a name or date, but it is empty",13,10,13,10,
																"1. Spin the plaque",13,10,0
level3_options0_choice3_dialogue				BYTE			"You find yourself looking at an oil painting of a grizzeled, old cat in a sailor suit, an eye patch, and puffing a",13,10,
																"pipe. At the bottom of the frame is a small plate that says 'Popeye'.",13,10,0
level3_options0_choice3_options_book			BYTE			"You think of the note, and look a little closer at the portrait. You notice that some parts of the cat are",13,10,
																"actually slightly raised like buttons.",13,10,13,10,
																"1. Press the pipe",13,10,
																"2. Press the eyepatch",13,10,
																"3. Press the nose",13,10,
																"4. Go back to hallway",13,10,0
level3_options0_options3_choice1				BYTE			"You hear a snapping noise and fall through a trap door right under your feet.",13,10,0
level3_options0_options3_choice2				BYTE			"You hear what sounds like the release compressed air followed by a sting in your neck. You reach to the sting and pull",13,10,
																"out a small dart.",13,10,0
level3_options0_options3_choice3				BYTE			"You hear a mechanical sound and then a distant creak. It sounds like it came from that coat closet.",13,10,0

; Level 4: Basement -----------------------------
level4_combo									BYTE			"booty",0

; Starting options
level4_dialogue0								BYTE			"You make your way down the stairs and enter a basement that is dimly lit by many half melted candles.",13,10,0
level4_options0									BYTE			"To your right is what looks to be a small shrine and to your left is a stool with a Ouija board on top. Straight ahead,",13,10,
																"there is a table with an ornate box.",13,10,13,10,
																"1. Move towards the table",13,10,
																"2. Inspect the shrine",13,10,
																"3. Take a look at the Ouija board",13,10,0
; The box
level4_options0_choice1_options					BYTE			"The box on the table is a warm brown wood with detailed engravings of fish and fish bones. On the top of the box is a 5",13,10,
																"letter combination lock. Next to the box is a folded piece of paper.",13,10,13,10,
																"1. Unfold the piece of paper",13,10,
																"2. Enter a combination",13,10,
																"3. Move back to middle of room",13,10,0
level4_options0_options1_choice2_combo			BYTE			BUFFER_SIZE DUP(?)
level4_options0_options1_choice2_promptCombo	BYTE			"You set the combination lock to the following 5 letters: ",0 
level4_options0_options1_choice2_wrongCombo		BYTE			"The box remains locked.",13,10,0
level4_options0_options1_choice2_rightCombo		BYTE			"You hear a latch click and the lid pops open.",13,10,0

; The shrine
level4_options0_choice2_options					BYTE			"You squat down to look at the small shrine. There is a statue of a cat with candles all around it. In front of the cat",13,10,
																"is a small pile of cat treats and a few toy mice. In front of the offering is a couple of tarot cards.",13,10,13,10,
																"1. Look at the tarot card reading",13,10,
																"2. Pick up one of the mice",13,10,
																"3. Move back to middle of room",13,10,0
level4_options0_options2_choice1				BYTE			"You see the following cards:",13,10,
																"II - The Hermit",13,10,
																"XV - The Devil",13,10,
																"XVI - The Tower",13,10,
																"XVIII - The Moon",13,10,
																"XXI - The World",13,10,0
level4_options0_options2_choice2				BYTE			"You pick up one of the mice and immediately know it is very much a real, dead mouse.",13,10,0

; The Ouina board
level4_options0_choice3_options					BYTE			"You see a standard Ouija board with a planchette.",13,10,13,10,
																"1. Place your fingers on the planchette",13,10,
																"2. Move back to middle of room",13,10,0
level4_options0_options3_options				BYTE			"The planchette begins to move. Startled, you lift your fingers and look around. You now notice that the black cat that",13,10,
																"was in the living room is now staring at you from the basement stairs like he is waiting for something.",13,10,13,10,
																"1. Put your fingers back on the planchette",13,10,
																"2. Move back to middle of room",13,10,0
level4_options0_options3_dialogue				BYTE			"The planchette moves and spells the word 'TOWER' before moving to goodbye.",13,10,0

level4_winner_p1								BYTE			"You open the box and discover it is full of gold! It turns out the stories were true. You go to pick up the box,",13,10,
																"and pause. You turn towards the black cat who is now in the middle of the room.",0
level4_winner_p2								BYTE			"You swear the cat nods before sitting into a comfortable loaf. You leave the mansion with the treasure, looking",13,10,
																"at the odd house one last time.",13,10,0

.code

main PROC
	; Title
	push OFFSET splash_file
	call printTextFile

	push OFFSET instructions
	call printDialogue

	push OFFSET introduction
	call printDialogue

	; Run game
	call runLevel0

	call runLevel1

	call runLevel2

	call runLevel3

	call runLevel4

	call endGame

main ENDP

moveCursor PROC C X:WORD,Y:WORD
    LOCAL pos:COORD
    mov ax,X
    mov pos.X,ax
    mov ax,Y
    mov pos.Y,ax
    invoke SetConsoleCurSorPosition,hStdOut,pos
    ret
moveCursor ENDP

; ---------------------------------------------------------------------------------
; Name: printTextFile
;
; Prints the splash page.
;
; Preconditions: none.
;
; Postconditions: Value stored in EAX.
;
; Receives:
;	[EBP+8] = offset of file
;
; Returns: none.
; ---------------------------------------------------------------------------------
printTextFile PROC
	push EBP
	mov EBP, ESP
	push EAX
	push ECX
	push EDX

	; Open file and create handle
	mov EDX, [EBP+8]
	call OpenInputFile
	push EAX

	; Read file
	mov EDX, OFFSET txtArray
	mov ECX, ARRAY_SIZE
	call ReadFromFile

	; Close file
	pop EAX
	call CloseFile

	; Print text
	mov EDX, OFFSET txtArray
	call WriteString
	call CrLf
	call CrLf
	
	; Clear array
	push ARRAY_SIZE
	push OFFSET txtArray
	call clearArray

	pop EDX
	pop ECX
	pop EAX
	pop EBP
	ret 4
printTextFile ENDP

; ---------------------------------------------------------------------------------
; Name: printDialogue
;
; Prints dialogue.
;
; Preconditions: none.
;
; Postconditions: Value stored in EAX.
;
; Receives:
;	[EBP+8]	= address of dialogue
;
; Returns: none.
; ---------------------------------------------------------------------------------
printDialogue PROC
	; Procedure prep
	push EBP
	mov EBP, ESP

	; Display dialogue
	mov EAX, DIALOGUE_DISPLAY
	call SetTextColor

	call CrLf
	mov EDX, [EBP+8]
	call WriteString
	call CrLf

	mov EAX, DEFAULT_DISPLAY
	call SetTextColor

	; Procedure clean up
	pop EBP
	ret 4
printDialogue ENDP

; ---------------------------------------------------------------------------------
; Name: printOptions
;
; Prints choices and gets user's choice.
;
; Preconditions: none.
;
; Postconditions: Value stored in EAX.
;
; Receives:
;	[EBP+8]	= choices offset
;
; Returns: none.
; ---------------------------------------------------------------------------------
printOptions PROC
	; Procedure prep
	push EBP
	mov EBP, ESP

	; Display options
	call CrLf
	mov EAX, OPTIONS_DISPLAY
	call SetTextColor

	mov EDX, [EBP+8]
	call WriteString
	call CrLf

	mov EDX, OFFSET choice_prompt
	call WriteString

	mov AL, 20h
	call WriteChar
	mov AL, 8h
	call WriteChar

	mov EAX, DEFAULT_DISPLAY
	call SetTextColor

	; Get choice
	call ReadInt
	call CrLf

	; Procedure clean up
	pop EBP
	ret 4
printOptions ENDP

; ---------------------------------------------------------------------------------
; Name: fatalChoice
;
; Handles a fatal choice by asking if user wants to retry or end the game.
;
; Preconditions: none.
;
; Postconditions: Saves restores EAX and EDX. If the user chooses to end the game, 
;				  then endGame is called.
;
; Returns: none.
; ---------------------------------------------------------------------------------
fatalChoice PROC USES EAX EDX
	
	mov EAX, FATAL_DISPLAY
	call SetTextColor

	; Prompt for key press
	call CrLf
	mov EDX, OFFSET fatal_prompt
	call WriteString

	mov EAX, DEFAULT_DISPLAY
	call SetTextColor

_waitKeyPress:
	; Get the key press
	getKeyPress

	; Check 'Y'
	cmp DX, 59h
	je _ContinueGame

	; Check 'N'
	cmp DX, 4Eh
	je _StopGame

	; Unknown key press
	jmp _waitKeyPress

_StopGame:
	mov AL, 'N'
	call WriteChar
	pop EAX
	pop EDX
	pop EBP
	call CrLf
	call endGame

_ContinueGame:
	mov AL, 'Y'
	call WriteChar
	call CrLf

	; Procedure clean up
	ret
fatalChoice ENDP

; ---------------------------------------------------------------------------------
; Name: clearArray
;
; Clears an array.
;
; Preconditions: none.
;
; Postconditions: Saves and restores EBP, EAX, EDX.
;
; Receives:
;	[ebp+12] = length of array
;	[ebp+8] = address of array
;
; Returns: none.
; ---------------------------------------------------------------------------------
clearArray PROC
	; Procedure prep
	push EBP
	mov EBP, ESP
	push EAX
	push ECX
	push EDI

	; Make sure to empty txtArray, otherwise weird stuff might print after the number
	mov EDI, [EBP+8]
	mov ECX, [EBP+12]
	mov AL, 0
	rep stosb

	; Procedure clean up
	pop EDI
	pop ECX
	pop EAX
	pop EBP
	ret 8
clearArray ENDP


; ---------------------------------------------------------------------------------
; Name: printLaptopScreen
;
; Reads laptop screen file and displays. Waits for user to exit.
;
; Preconditions: none.
;
; Postconditions: Saves and restores EBP, EAX, EDX.
;
; Returns: none.
; ---------------------------------------------------------------------------------
printLaptopScreen PROC
	push OFFSET laptop_login_file
	call printTextFile
	
	getCursorPos

_DisplayOptions:
	; Return cursor to original position
	invoke moveCursor, CursorPos.dwCursorPosition.X, CursorPos.dwCursorPosition.Y

	; Check if we are leaving or trying a password
	push OFFSET level2_options1_options2_options1
	call printOptions

	; Make sure choice is valid
	checkChoice 1, 2, EAX
	cmp EAX, 0
	je _DisplayOptions

	; Check if choice 1
	cmp EAX, 1
	jne _Leave

	; Move curosr to password section
	mov AX, CursorPos.dwCursorPosition.Y
	sub AX, 13
	mov cursorY, AX
	mov cursorX, 30
	invoke moveCursor, cursorX, cursorY
	
	; Get password, check if right
	call ReadDec

	cmp EAX, level2_password
	je _GoodPassword

	; Bad password
	invoke moveCursor, cursorX, cursorY
	push EDX
	mov EDX, OFFSET level2_options1_options2_choice1_badPassword
	call WriteString
	mov EAX, 1000
	call Delay
	pop EDX

	; Reset password
	invoke moveCursor, cursorX, cursorY
	push EDX
	mov EDX, OFFSET level2_options1_options2_choice1_clear
	call WriteString
	pop EDX

	jmp _DisplayOptions

_GoodPassword:
	; Good password
	; Reset the cursor
	invoke moveCursor, CursorPos.dwCursorPosition.X, CursorPos.dwCursorPosition.Y

	; Toggle diary found
	mov level2_diaryFound, 1
	call CrLf

	; Show diary entry
	push OFFSET laptop_diary_file
	call printTextFile
	
_Leave:
	; Leave
	ret
printLaptopScreen ENDP

; ---------------------------------------------------------------------------------
; Name: printPortrait
;
; Reads portrait file and displays. Waits for user to exit.
;
; Preconditions: none.
;
; Postconditions: Saves and restores EBP, EAX, EDX.
;
; Receives:
;	[EBP+8] = toggle for printing the portrait with the plate name or without
;
; Returns: none.
; ---------------------------------------------------------------------------------
printPortrait PROC
	push EBP
	mov EBP, ESP
	push EAX
	
	; Check which file we are printing
	mov EAX, [EBP+8]
	cmp EAX, 1
	je _LoadPortraitPlate

	; Print the portrait without plate
	push OFFSET portrait_file
	call printTextFile
	jmp _Leave

_LoadPortraitPlate:
	; Print the portrait with plate name
	push OFFSET portrait_plate_file
	call printTextFile

_Leave:
	pop EAX
	pop EBP
	ret 4
printPortrait ENDP

; ---------------------------------------------------------------------------------
; Name: printOuijaBoard
;
; Reads laptop screen file and displays. Waits for user to exit.
;
; Preconditions: none.
;
; Postconditions: Saves and restores EBP, EAX, EDX.
;
; Returns: none.
; ---------------------------------------------------------------------------------
printOuijaBoard PROC
	; Get the cursor
	getCursorPos

	; T
	push OFFSET ouijaT
	call printTextFile

	; Return cursor to original position
	invoke moveCursor, CursorPos.dwCursorPosition.X, CursorPos.dwCursorPosition.Y
	mov EAX, DELAY_TIME
	call Delay

	; O
	push OFFSET ouijaO
	call printTextFile

	; Return cursor to original position
	invoke moveCursor, CursorPos.dwCursorPosition.X, CursorPos.dwCursorPosition.Y
	mov EAX, DELAY_TIME
	call Delay

	; W
	push OFFSET ouijaW
	call printTextFile

	; Return cursor to original position
	invoke moveCursor, CursorPos.dwCursorPosition.X, CursorPos.dwCursorPosition.Y
	mov EAX, DELAY_TIME
	call Delay

	; E
	push OFFSET ouijaE
	call printTextFile

	; Return cursor to original position
	invoke moveCursor, CursorPos.dwCursorPosition.X, CursorPos.dwCursorPosition.Y
	mov EAX, DELAY_TIME
	call Delay

	; R
	push OFFSET ouijaR
	call printTextFile
	call Delay

	; Leave
	ret
printOuijaBoard ENDP

; ---------------------------------------------------------------------------------
; Name: runLevel0
;
; Runs Level 0 of game.
;
; Preconditions: none.
;
; Postconditions: Saves and restores EBP, EAX, EDX.
;
; Returns: none.
; ---------------------------------------------------------------------------------
runLevel0	PROC USES EAX EDX

_DisplayOptions0:
	; Print starting choices
	push OFFSET level0_options0
	call printOptions

	; Make sure choice is valid
	checkChoice 1, 3, EAX
	cmp EAX, 0
	je _DisplayOptions0

	; Check if choice 1
	cmp EAX, 1
	jne _Choice0_2
	
_DisplayOptions0_1:
	; Turns toward car
	push OFFSET level0_options0_choice1_options
	call printOptions

	; Make sure choice is valid
	checkChoice 1, 2, EAX
	cmp EAX, 0
	je _DisplayOptions0_1

	; Check if choice 1
	cmp EAX, 1
	jne _Choice0_1_2

	; Moves towards car
	push OFFSET level0_options0_options1_choice1_dialogue
	call printDialogue

	call fatalChoice
	jmp _DisplayOptions0_1

_Choice0_1_2:
	; Goes back to door
	jmp _DisplayOptions0

_Choice0_2:
	cmp EAX, 2
	jne _NextLevel

	; Turns towards bikes
	push OFFSET level0_options0_choice2_dialogue
	call printDialogue
	jmp _DisplayOptions0

_NextLevel:	
	; Move to next level
	; Procedure cleanup
	ret
runLevel0 ENDP

; ---------------------------------------------------------------------------------
; Name: runLevel1
;
; Runs Level 1 of game_ Successfully completing the level will result in returning
; to main.
;
; Preconditions: none.
;
; Postconditions: Saves and restores EBP, EAX, EDX.
;
; Returns: none.
; ---------------------------------------------------------------------------------
runLevel1	PROC USES EAX EDX

_DisplayOptions0:
	; Print starting choices
	push OFFSET level1_options0
	call printOptions

	; Make sure choice is valid
	checkChoice 1, 3, EAX
	cmp EAX, 0
	je _DisplayOptions0

	; Check if choice 1
	cmp EAX, 1
	jne _DisplayOptions0_2
	
	; Check if we can open door
	cmp level1_keyFound, 1
	je _NextLevel

	; No key so go back to top choices
	push OFFSET level1_options0_choice1_noKey
	call printDialogue
	jmp _DisplayOptions0

_DisplayOptions0_2:
	push OFFSET level1_options0_choice2_options
	call printOptions

	; Make sure choice is valid
	checkChoice 1, 2, EAX
	cmp EAX, 0
	je _DisplayOptions0_2

	cmp EAX, 1
	jne _Choice2_2

	; Tries searching plant
	push OFFSET level1_options0_options2_choice1_dialogue
	call printDialogue
	call fatalChoice
	jmp _DisplayOptions0_2

_Choice2_2:
	; Lifts mat
	push OFFSET level1_options0_options2_choice2_dialogue
	call printDialogue
	mov level1_keyFound, 1
	jmp _DisplayOptions0

_NextLevel:	
	; Opens door, move to next level
	push OFFSET level1_options0_choice1_key
	call printDialogue

	; Procedure cleanup
	ret
runLevel1 ENDP

; ---------------------------------------------------------------------------------
; Name: runLevel2
;
; Runs Level 2 of game. Successfully completing the level will result in returning
; to main.
;
; Preconditions: none.
;
; Postconditions: Saves and restores EBP, EAX, EDX.
;
; Returns: none.
; ---------------------------------------------------------------------------------
runLevel2	PROC USES EAX EDX

_DisplayOptions0:
	; Print starting choices
	push OFFSET level2_options0
	call printOptions

	; Make sure choice is valid
	checkChoice 1, 2, EAX
	cmp EAX, 0
	je _DisplayOptions0

	cmp EAX, 1
	jne _Choice0_2

	; Bravely pushes door open
	push OFFSET level2_options0_choice1_dialgoue
	call printDialogue
	jmp _DisplayOptions1

_Choice0_2:
	; Fearfully waits
	push OFFSET level2_options0_choice2_dialgoue
	call printDialogue

_DisplayOptions1:
	; Move onto main room options
	push OFFSET level2_options1
	call printOptions

	; Make sure choice is valid
	checkChoice 1, 4, EAX
	cmp EAX, 0
	je _DisplayOptions1

	cmp EAX, 1
	jne _Choice1_2
	
	; Try to switch on light
	push OFFSET level2_options1_choice1_dialogue
	call printDialogue
	jmp _DisplayOptions1

_Choice1_2:
	cmp EAX, 2
	jne _Choice1_3

_DisplayOptions1_2:
	; Move onto desk options
	push OFFSET level2_options1_options2
	call printOptions

	; Make sure choice is valid
	checkChoice 1, 4, EAX
	cmp EAX, 0
	je _DisplayOptions1_2

	cmp EAX, 1
	jne _Choice1_2_2

	; Open laptop
	push OFFSET level2_options1_options2_choice1_dialogue
	call printDialogue
	call printLaptopScreen
	jmp _DisplayOptions1_2

_Choice1_2_2:
	cmp EAX, 2
	jne _Choice1_2_3

	; Looks around desk
	push OFFSET level2_options1_options2_choice2_dialogue
	call printDialogue
	jmp _DisplayOptions1_2

_Choice1_2_3:
	cmp EAX, 3
	jne _Choice1_2_4

	; Finds flashlgiht
	push OFFSET level2_options1_options2_choice3_dialogue
	call printDialogue
	mov level2_flashlightFound, 1
	jmp _DisplayOptions1_2

_Choice1_2_4:
	; Go back to looking around th room
	jmp _DisplayOptions1

_Choice1_3:
	cmp EAX, 3
	jne _Choice1_4

_DisplayOptions1_3:
	; Move onto cat options
	push OFFSET level2_options1_options3
	call printOptions

	; Make sure choice is valid
	checkChoice 1, 4, EAX
	cmp EAX, 0
	je _DisplayOptions1_3

	cmp EAX, 1
	jne _Choice1_3_2

_DisplayOptions1_3_2_1:
	; Scratches ears
	push OFFSET level2_options1_options3_options1
	call printOptions

	; Make sure choice is valid
	checkChoice 1, 1, EAX
	cmp EAX, 1
	jne _DisplayOptions1_3_2_1

	; Show the sticky note hint
	push OFFSET sticky_note_file
	call printTextFile
	jmp _DisplayOptions1_3

_Choice1_3_2:
	cmp EAX, 2
	jne _Choice1_3_3

	; Scratches tummy
	push OFFSET level2_options1_options3_choice2_dialogue
	call printDialogue
	call fatalChoice
	jmp _DisplayOptions1_3

_Choice1_3_3:
	cmp EAX, 3
	jne _Choice1_3_4

	; Inspect stomach
	push OFFSET level2_options1_options3_choice3_dialogue
	call printDialogue
	jmp _DisplayOptions1_3

_Choice1_3_4:
	; Go back to living room
	jmp _DisplayOptions1

_Choice1_4:
	cmp level2_flashlightFound, 0
	jne _CheckDiary

	; No flashlight yet
	push OFFSET level2_options1_choice4_noFlashlight
	call printDialogue
	jmp _DisplayOptions1

_CheckDiary:
	cmp level2_diaryFound, 0
	jne _NextLevel

	; No diary yet
	push OFFSET level2_options1_choice4_noDiary
	call printDialogue
	jmp _DisplayOptions1

_NextLevel:	
	; Opens door, move to next level
	push OFFSET level2_options1_choice4_nextLevel
	call printDialogue

	; Procedure cleanup
	ret
runLevel2 ENDP

; ---------------------------------------------------------------------------------
; Name: runLevel3
;
; Runs Level 3 of game. Successfully completing the level will result in returning
; to main.
;
; Preconditions: none.
;
; Postconditions: Saves and restores EBP, EAX, EDX.
;
; Returns: none.
; ---------------------------------------------------------------------------------
runLevel3	PROC USES EAX EDX
_DisplayOptions0:
	; Print starting choices
	push OFFSET level3_options0
	call printOptions

	; Make sure choice is valid
	checkChoice 1, 3, EAX
	cmp EAX, 0
	je _DisplayOptions0

	cmp EAX, 1
	jne _Choice0_2

	; Check closet
	cmp level3_doorFound, 1
	je _NextLevel

	; Don't see secret door yet
	push OFFSET level3_options0_choice1_noDoor
	call printDialogue
	jmp _DisplayOptions0

_Choice0_2:
	cmp EAX, 2
	jne _DisplayOptions0_3

_DisplayOptions0_2:
	; Print options for bookshelf
	push OFFSET level3_options0_choice2_options
	call printOptions

	; Make sure choice is valid
	checkChoice 1, 3, EAX
	cmp EAX, 0
	je _DisplayOptions0_2

	cmp EAX, 1
	jne _Choice0_2_2

	; Looks at armchair
	push OFFSET level3_options0_options2_choice1_dialogue
	call printDialogue
	jmp _DisplayOptions0_2

_Choice0_2_2:
	cmp EAX, 2
	jne _Choice0_2_3

	; Check if the name on the portrait has been found yet
	cmp level3_nameFound, 1
	je _DisplayOptions0_2_2

	; Can't look at books yet
	push OFFSET level3_options0_options2_choice2_dialogue
	call printDialogue
	jmp _DisplayOptions0_2

_DisplayOptions0_2_2:
	; Look at books
	push OFFSET level3_options0_options2_choice2_options
	call printOptions

	; Make sure choice is valid
	checkChoice 1, 5, EAX
	cmp EAX, 0
	je _DisplayOptions0_2_2

	cmp EAX, 3
	je _Choice0_2_2_3
	cmp EAX, 4
	je _Choice0_2_2_4
	cmp EAX, 5
	je _Choice0_2_2_5
	
	; Incorrect book
	push OFFSET level3_options0_options2_incorrectBook
	call printDialogue
	jmp _DisplayOptions0_2_2

_Choice0_2_2_3:
	; Spinach book chosen
	push OFFSET level3_options0_options2_correctBook
	call printDialogue
	mov level3_bookFound, 1
	jmp _DisplayOptions0_2_2


_Choice0_2_2_4:
	; The legend of stormageddon
	push OFFSET captainBook
	call printTextFile
	jmp _DisplayOptions0_2_2

_Choice0_2_2_5:
	; Return to study
	jmp _DisplayOptions0_2

_Choice0_2_3:
	; Return to the hallway
	jmp _DisplayOptions0

_DisplayOptions0_3:
	; Look at the portrait
	cmp level3_nameFound, 0
	je _NoPlateOptions
	cmp level3_bookFound, 1
	je _BookFoundOptions

_NoBookOptions:
	; Print the dialogue with plate but without the book
	push OFFSET level3_options0_choice3_dialogue
	call printDialogue
	jmp _Choice0_3_4

_NoPlateOptions:
	mov EAX, 0
	push EAX
	call printPortrait

	; Print the options without the plaque
	push OFFSET level3_options0_choice3_options_noPlate
	call printOptions
	
	; Make sure choice is valid
	checkChoice 1, 1, EAX
	cmp EAX, 0
	je _NoPlateOptions

	mov EAX, 1
	push EAX
	call printPortrait

	push OFFSET level3_options0_choice3_dialogue
	call printDialogue

	mov level3_nameFound, 1
	jmp _Choice0_3_4

_BookFoundOptions:
	push OFFSET level3_options0_choice3_options_book
	call printOptions

	; Make sure choice is valid
	checkChoice 1, 4, EAX
	cmp EAX, 0
	je _BookFoundOptions

	cmp EAX, 1
	jne _Choice0_3_2

	; Selected the pipe, fatal error
	push OFFSET level3_options0_options3_choice1
	call printDialogue
	jmp _BadChoice

_Choice0_3_2:
	cmp EAX, 2
	jne _Choice0_3_3

	; Selected the eyepatch, fatal error
	push OFFSET level3_options0_options3_choice2
	call printDialogue
	jmp _BadChoice

_Choice0_3_3:
	cmp EAX, 3
	jne _Choice0_3_4

	; Selected the nose, correct
	push OFFSET level3_options0_options3_choice3
	call printDialogue
	mov level3_doorFound, 1
	jmp _Choice0_3_4

_Choice0_3_4:
	; Return to the hallway
	jmp _DisplayOptions0

_BadChoice:	
	call fatalChoice
	jmp _BookFoundOptions

_NextLevel:
	push OFFSET level3_options0_choice1_secretDoor
	call printDialogue

	ret
runLevel3 ENDP

; ---------------------------------------------------------------------------------
; Name: runLevel4
;
; Runs Level 4 of game. Successfully completing the level will result in returning
; to main.
;
; Preconditions: none.
;
; Postconditions: Saves and restores EBP, EAX, EDX.
;
; Returns: none.
; ---------------------------------------------------------------------------------
runLevel4	PROC USES EAX EDX
_DisplayOptions0:
	; Print starting choices
	push OFFSET level4_options0
	call printOptions

	; Make sure choice is valid
	checkChoice 1, 3, EAX
	cmp EAX, 0
	je _DisplayOptions0

	cmp EAX, 1
	jne _Choice0_2

_DisplayOptions0_1:
	; Box on table options
	push OFFSET level4_options0_choice1_options
	call printOptions

	; Make sure choice is valid
	checkChoice 1, 3, EAX
	cmp EAX, 0
	je _DisplayOptions0_1

	cmp EAX, 1
	jne _Choice0_1_2
	
	; Show the note
	push OFFSET txtPuzzle
	call printTextFile
	jmp _DisplayOptions0_1

_Choice0_1_2:
	cmp EAX, 2
	jne _Choice0_1_3

	; Prompt for combo
	mov EDX, OFFSET level4_options0_options1_choice2_promptCombo
	call WriteString

	; Read string from user
	mov EDX, OFFSET level4_options0_options1_choice2_combo
	mov ECX, SIZEOF level4_options0_options1_choice2_combo
	call ReadString
	
	; Compare string to solution
	cld
	mov ECX, EAX
	mov ESI, OFFSET level4_combo
	mov EDI, EDX
	repe cmpsb
	jcxz _correctCombo
	jmp _incorrectCombo

_correctCombo:
	push OFFSET level4_options0_options1_choice2_rightCombo
	call printDialogue
	jmp _Leave

_incorrectCombo:
	push OFFSET level4_options0_options1_choice2_wrongCombo
	call printDialogue
	jmp _DisplayOptions0_1

_Choice0_1_3:
	; return to middle of room
	jmp _DisplayOptions0

_Choice0_2:
	cmp EAX, 2
	jne _DisplayOptions0_3

_DisplayOptions0_2:
	; The shrine
	push OFFSET level4_options0_choice2_options
	call printOptions

	; Make sure choice is valid
	checkChoice 1, 3, EAX
	cmp EAX, 0
	je _DisplayOptions0_2

	cmp EAX, 1
	jne _Choice0_2_2
	
	; Look at the tarot cards
	push OFFSET level4_options0_options2_choice1
	call printDialogue
	jmp _DisplayOptions0_2

_Choice0_2_2:
	cmp EAX, 2
	jne _Choice0_2_3

	; Pick up on of the mice
	push OFFSET level4_options0_options2_choice2
	call printDialogue
	jmp _DisplayOptions0_2

_Choice0_2_3:
	; return to middle of room
	jmp _DisplayOptions0

_DisplayOptions0_3:
	; Ouija board
	; Print board
	push OFFSET ouijaBoard
	call printTextFile

	; Print options
	push OFFSET level4_options0_choice3_options
	call printOptions

	; Make sure choice is valid
	checkChoice 1, 2, EAX
	cmp EAX, 0
	je _DisplayOptions0_3

	cmp EAX, 1
	jne _Choice0_3_2
	
_DisplayOptions0_3_1:
	push OFFSET level4_options0_options3_options
	call printOptions

	; Make sure choice is valid
	checkChoice 1, 2, EAX
	cmp EAX, 0
	je _DisplayOptions0_3_1

	cmp EAX, 1
	jne _Choice0_3_2

	; Print boards
	call printOuijaBoard

	push OFFSET level4_options0_options3_dialogue
	call printDialogue

_Choice0_3_2:
	; return to middle of room
	jmp _DisplayOptions0

_Leave:
	push OFFSET level4_winner_p1
	call printDialogue
	push OFFSET level4_winner_p2
	call printDialogue

	ret
runLevel4 ENDP

; ---------------------------------------------------------------------------------
; Name: endGame
;
; Ends the game_ Different displays depending on a loss or win.
;
; ---------------------------------------------------------------------------------
endGame PROC
	call CrLf
	push OFFSET gameOver
	call printTextFile
	call WaitMsg

	Invoke ExitProcess,0	; exit to operating system
	ret
endGame ENDP

END main
