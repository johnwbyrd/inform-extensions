Version 2/111114 of Text Window Input-Output Control (for Glulx only) by Erik Temple begins here.

[Fixed variable declarations so that current text i/o windows are "usually" assigned to the main-window. 10/14/2011]
[Minor typos in docs fixed. 1/22/2011]

---- Documentation ----

Text Window Input-Output Control allows an author to direct the game's main input and output--both of which would normally be directed to a game's "main window"--to any text window she chooses. We can, for example, split input and output, so that the player's input is entered into one window, while the game responds in another. Window input-output (I/O) can be changed at any time during the game. The extension also provides more control over transcript output.

Text Window Input-Output Control is built on, and requires, Jon Ingold's Flexible Windows extension.


Section: Basic Usage

Text Window Input-Output Control provides two new global g-window variables:

	current text input window
	current text output window

These variables define the windows into which the game's main output and input will be directed. Both are initially set to the main window (Flexible Windows's "main-window" object), so that if neither of the variables are changed during play, all I/O will occur in the main window (the standard behavior).

The major use of this extension is expected to be for splitting input and output across two windows; that is, for creating a separate window for input. To do this, we can merely set the "current text input window" to window we wish to use for the command prompt. This can be either a text-buffer window or a text-grid window.

It is important to note that the "current text output window" is distinct from the "current g-window" defined by Flexible Windows, and changing it will probably only rarely be necessary. Unlike the current g-window variable, the current text output window is intended to be used when the main output--that is, the game's main stream of output, occurring over multiple turns--needs to be redirected away from the (always open) main window to some other window. That window will then become, for nearly all intents and purposes, the "main window" (indeed, the Flexible Windows phrase "return to main screen" will direct output to the window that is defined as the current text output window). This is most likely to be useful when we want to use multiple "main windows" within a game, alternating a text-grid window, say, or a window with a different background color. See the "Terminal" example below for an example.

There is thus no need to provide a Flexible Windows window-drawing rule for windows assigned as the current text output window or the current text input window; Inform's library takes care of requesting input and printing output. Note that when the current text input window or current text output window is closed, the main window will automatically take over. 

NOTE: The Inform library will not redirect input/output until the beginning of the next turn. If you want to begin printing to a new "current" window immediately, use the "set focus to <a text g-window>" phrase:

	Instead of turning on the computer:
		change the current text output window to the terminal-window;
		set focus to the current text output window;
		say "..."

Most often, we will want to set a window to be the new current text output/input window at the time we open it. Two phrases are provided that take care of all of the bookkeeping for us:

	open up <a text g-window> as the main text output window
	open up <a text g-window> as the main text input window

If, for example we want to use the main window for output, but provide input in a separate window, we define the input window as usual (see the Flexible Windows documentation), and then we open it like so:

	When play begins:
		open up the input window as the main text input window.

These phrases will immediately shift I/O to the designated window(s), and they also ensure that the text that is printed to the window is also printed to the transcript.


Section: A caveat

Inform's complex paragraph printing and line breaking algorithms (see http://inform7.com/sources/src/i6template/Woven/B-print.pdf ) were not designed with multiple windows in mind, and not everything works perfectly when we use them. Most notably, switching output streams can cause line break issues, as Inform's paragraphing functions are not aware of the change in window streams. In writing this extension, I have tried to provide as little as possible in the way of customized spacing behavior, since I expect the extension will have many potential uses. In most cases customizing display issues won't be too onerous a task (not any more onerous than dealing with line-spacing in general, anyway), but be prepared to need to customize a few things. The examples, particularly "On the Edge", give some idea of the kinds of tweaks that may be necessary.


Section: Command prompts

The extension provides added control over the three different command prompts provided by the Inform library. Here are the three rules and activities provided for controlling the prompts:

	The "printing the command prompt" activity now controls the printing of the standard prompt seen for most commands. The character used for the prompt itself is defined, as in the standard Inform library, by the "command prompt" global variable.

	The final prompt, which is printed after the game ends, is controlled by the "flexible print the final prompt rule".

	The yes-no prompt, which is printed in response to yes-no questions, is controlled by the "yes-no prompting" rulebook. The prompt for yes-no questions can be set using the "yes-no prompt" global variable, which is initially defined as ">>". (Inform's standard library has no yes-no prompt; instead, the input directly follows the question, on the same line.)

Both the flexible print the final prompt rule and the default yes-no prompting rule call the printing the command prompt activity. If we want to customize all of the prompts in the game in the same way, that activity is the most natural place to start. For example, to clear the current input window after each command, we might write:

	Before printing the command prompt:
		clear the current text input window.

A note on yes-no prompting: If we are not accepting input in a separate window and want to maintain Inform's standard yes-no behavior, we can restore that behavior by setting the yes-no prompt to "" when play begins and adding the following rule to our story text:

	*: Yes-no prompting:
		say " [run paragraph on]";
		rule succeeds.


Section: Transcripts

With multiple windows, we need a bit more control over what is written to the transcript than the Inform library provides. Text Window Input-Output Control should automatically handle directing the streams of the current text output and current text input windows to the transcript. This is handled internally by the extension in two ways: (1) Through the "activating the transcript" activity, which allows us to dictate which windows send output to the transcript, as well as what is output in response to the SCRIPT ON command. The default is set by the "transcript activation rule," which attempts to echo both the current text output window and the current text input window to the transcript. (2) Additionally, any window opened as the current text input/output window (using the "open ... as" phrases described in the Basic Usage section) after a transcript is already in progress will be added to the transcript.

If we have a more dynamic window layout, we can add window streams to the transcript manually by using the "echo the stream of <a text g-window> to the transcript" phrase. This can be done both by extending the activating the transcript activity:

	For activating the transcript:
		echo the stream of the optional-window to the transcript.

...and by adding rules to Flexible Windows's "constructing a g-window" activity:

	After constructing the optional-window:
		echo the stream of the optional-window to the transcript.

Including the instruction in the activating the transcript phrase ensures that an existing window will be echoed when a transcript is started, while doing so in the after constructing activity ensures that a window opened after the transcript has begun will also be echoed. Note that the "echo the stream" phrase does nothing if the transcript is not already active, so it is safe to use anywhere in our code.

We can also stop a window's stream from being echoed to the transcript without closing the window by using this phrase:

	shut down the echo stream of <a text g-window>

It is also possible to send output to the transcript more selectively; see the "On the Edge" and "Terminal" examples below.


Section: Notes on pasting commands from mouse input

Emily Short's Glulx Entry Points extension provides rules that allow for commands to be pasted to the game's command line in response to the player's clicking on a hyperlink or a defined portion of a graphics window. Text Window Input-Output Control reroutes this pasting to the current text input window, whatever that is defined to be.

The extension also provides some control over the state of paragraphing across the sometimes troublesome switch between windows. This control comes via the "command-pasting terminator," a global text variable that we can set to whatever we need to make things look good. By default, there is no terminator (the value is ""). But if, for example, we are clearing the input window after each input, we will want to set the command-pasting terminator equal to "[run paragraph on]", or we will get an extra line break in the output window after each pasted command.


Section: Miscellaneous notes

One interesting consequence of the ability to set the main text output window is that we can now select text-grid windows as the main output or input windows. Doing so carries with it all the limitations of text-grid windows--most notably, the absence of scrolling and the inability to display images--but might be useful for certain effects (see the "Terminal" example below).  

Note that the character input routines from Basic Screen Effects ("wait for any key", "wait for the SPACE key", "the chosen letter") will now apply to whichever window is declared as the current text input window. To specify which window we want to accept character input, we can use the phrases defined in Flexible Windows (version 9+).

The current text output window also determines where figures are printed when we use the Inform library's "display the figure of ..." command. If the current text output window is not a text-buffer window, figures will not be displayed.

Similarly, the I6 routines VM_ClearScreen window(), VM_ScreenWidth(), and VM_ScreenHeight() will now operate on the current text output window rather than exclusively on the main window.


Section: Change Log

Version 2: Updated for 6F95. Now uses no deprecated features.

Version 1: Initial release.


Example: * Minimal - A very basic dual-window I/O setup. There are no tweaks to the standard behavior.

	*: "Minimal"

	Include Text Window Input-Output Control by Erik Temple.

	The input-window is a text-buffer g-window spawned by the main-window. The position is g-placebelow. The measurement is 10. The back-colour is g-lavender.

	When play begins:
		open up the input-window as the main text input window.
	
	Minimal Room is a room. "There really isn't anything at all to see or do here. I foresee lots of jumping, waiting, waving of hands, and self-examination."


Example: ** On the Edge - Another dual-window I/O example, but this time with a number of refinements. The input window clears after each command, to avoid scrolling, and is set off from the main window by a horizontal line (actually, a very narrow graphics window). To make up for the lack of command history in the input window, we echo each command in the output window before printing the result. The example also serves to illustrate a number of tweaks related to line spacing and transcript output.

We begin by defining the input window, as well as the graphics window that serves as the border between the input window and the main window. After opening these windows and declaring the input window to be the "current text input window", we start the game with some yes-no input, as a way of demonstrating that functionality.

	*: "On the Edge"

	Include Text Window Input-Output Control by Erik Temple.
	
	The input-window is a text-buffer g-window spawned by the main-window. The position is g-placebelow. The measurement is 10.
	
	The border-window is a graphics g-window spawned by the main-window. The position is g-placebelow. The scale method is g-fixed-size. The measurement is 2. The back-colour is g-dark-grey.
	
	When play begins:
		open up the input-window as the main text input window;
		open up the border-window;
		say "Are you sure you want to 'play' this 'game'?";
		unless the player consents:
			say "Well, that's probably for the best. Enjoy your life.";
			follow the immediately quit rule;
		say "OK, here we go...".	

We want the input window to clear after each command, so we slot that behavior into the "printing the command prompt" activity. We also insert some line breaks to improve the paragraphing behavior.

	*: Before printing the command prompt:
		clear the current text input window.
		
	After printing a parser error:
		say line break.
	
	Before reading a command when the current action is restarting the game or the current action is quitting the game:
		say line break.

We are clearing the input window after each command. This leaves the player with no visual record of the commands she has entered. So, we append the text of the command to the main window after reading it, printing it in italics to set it off from the other text in the window. However, because the transcript is receiving text streams from both the input and output windows, it will already have the input text. To avoid printing the player's input to the transcript twice, we temporarily suspend the main window's "echo stream"--the stream of data that is sent to the transcript--before printing the input in the main window.

This example also includes hyperlink input (see the next code block). Commands pasted from the hyperlink look good onscreen, but they need a line break when printing to the transcript. The definition of the "command-pasting terminator" global variable adds a line break to the transcript ONLY, bypassing the main window.

	*: After reading a command:
		shut down the echo stream of the main-window;
		say "[italic type][player's command][roman type]: [run paragraph on]";
		echo the stream of the main-window to the transcript.
	
	 The command-pasting terminator is "[run paragraph on][if we are writing a transcript][echo stream of current text input window][line break][stream of current text input window][end if]".

Finally, we have the scenario. We include two alternate forms of input, a hyperlink interface and single keystroke, merely to illustrate how such alternate input methods might work with the dual-window I/O, you are correct. Standard input works as well.

	*: Ledge is a room. "You are standing on a narrow ledge that encircles the upper floor of a very high building. There are no windows, no signs of life, no apparent exit except [link 1]jumping[end link]."	
	
	Table of Glulx Hyperlink Replacement Commands (continued)
	link ID	replacement
	1	"JUMP"
	2	"EXAMINE THE PEN"
	3	"TAKE THE PEN"
	
	Instead of jumping:
		say "You throw yourself forward...";
		end the game in death.
					
	The pen is in the Ledge. "Someone left a [link 2]pen[end link] on the ledge..." The description is "Odd, the [link 3]pen[end link] looks familiar."
	
	Instead of taking the pen:
		say "Press the space bar.";
		wait for the SPACE key in the current text output window;
		clear the current text output window;
		say "The world fades as if it were mist, and you are now in an office. Your office, in fact. You find that you are drooling on a yellow legal pad. ";
		end the game in victory.

Example: ** Terminal - This example illustrates one use for changing the current text output window. Basically, the player must interact with a computer terminal, and during this interaction  the game's interface apes the terminal. We open a new window (the terminal-output-window) in front of the main window, covering the latter completely. This new window is a text-grid window with reversed color-scheme and monotype font (both defaults for text-grid windows).

Another point of interest might be the "To say terminal text" phrase, which shows how to write text *only* to the transcript, and not to the screen. We do this here because we are using the status line (also a text-grid window) to display the name of the terminal. Since the I7 library (for good reason) doesn't write the status line to the transcript, we stream this text to it manually. 

	*: "Terminal"

	Include Basic Screen Effects by Emily Short.
	Include version 1 of Text Window Input-Output Control by Erik Temple.

	The terminal-input-window is a text-grid g-window spawned by the main-window. The position is g-placebelow. The measurement is 10.

	The terminal-output-window is a text-grid g-window spawned by the main-window. The position is g-placeabove. The measurement is 100.

	Before printing the command prompt when the location is TERM:
		clear the current text input window.

	[The following two rules restore the default behavior of the yes-no prompt.]

	When play begins:
		change the yes-no prompt to "".
		
	Yes-no prompting:
		say "[run paragraph on]";
		rule succeeds.

	The Control Center is a room. "Ancient machines sputter, buzz, and whine. How are they still operational after so many eons?"

	The terminal is a device in the Control Center. It is switched off. It is fixed in place.

	Instead of switching on the terminal:
		say "The terminal flickers to life. [paragraph break]Please press any key.";
		wait for any key;
		clear the main-window;
		move the player to TERM;
		open up the terminal-input-window as the main text input window;
		open up the terminal-output-window as the main text output window;
		change the right hand status line to "";
		say terminal text;
		say "WAKING...[paragraph break]RUNNING DIAGNOSTICS[paragraph break]SYSTEM CHECK OK[paragraph break]--------------[paragraph break]";
		say terminal selection;
		now the terminal is switched on;[we do this manually since we are bypassing the standard  behavior of the switching on action with this instead rule.]
	
	Procedural rule when the location is not the Control Center:
		ignore the room description heading rule;
		ignore the advance time rule.
	
	To say terminal text:
		if we are writing a transcript:
			say "[echo stream of current text output window][line break]----[location]----[line break][stream of current text output window]"
	
	Rule for constructing the status line when the player is not in the Control Center:
		center "[location]" at row 1;
		rule succeeds.
	
	To say terminal selection:
		say "MAKE SELECTION:[paragraph break]1. ACCESS CONTROL PROGRAM[line break]2. EXIT[paragraph break]"

	TERM is a room. The printed name is "TERMINAL 42.54.1". 

	Every turn when the location is TERM:
		say terminal text.
	
	After reading a command when the location is TERM:
		if the player's command does not match "[number]":
			reject the player's command.
	
	Entering terminal commands is an action applying to one number. Understand "[number]" as entering terminal commands when the location is TERM.

	Carry out entering terminal commands:
		if the number understood is 1:
			clear the current text output window;
			say "*****************[line break]* ACCESS DENIED *[line break]*****************[paragraph break]";
			say terminal selection;
		otherwise if the number understood is 2:
			clear the current text output window;
			say "********[line break]* EXIT *[line break]********[paragraph break]HIBERNATING...";
			wait for any key;
			shut down the terminal-output-window;
			shut down the terminal-input-window;
			say "The terminal flickers off. Guess you'd better hunt for a password. (Well, really, that's for a different game--this is just a little demo...)";
			move the player to the Control Center;
			change the right hand status line to "[score]/[turn count]";
			now the terminal is switched off;
			rule succeeds;
		otherwise:
			reject the player's command.






