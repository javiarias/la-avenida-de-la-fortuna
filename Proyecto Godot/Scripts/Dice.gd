extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#Copiado del ejemplo de los dados
#Se usa el frame de animacion como resultado

#func _on_DiceButton_pressed():
#	if !playTest && (current == 0):
#		dice()
#
#func dice():
#	if diced:
#		return
#
#	dice = randi() % 6
#	$Dice.frame = dice
#	$DiceButton.disabled = true
#	diced = true
#	tempElapsed = 0
#	diceMovement = 0
#
#	var diceType = randi() % 4
#	if diceType == 0:
#		diceTime = 0.3
#		if effects:
#			$DiceAudio1.play()
#	if diceType == 1:
#		diceTime = 0.1
#		if effects:
#			$DiceAudio2.play()
#	if diceType == 2:
#		diceTime = 0.5
#		if effects:
#			$DiceAudio3.play()
#	if diceType == 3:
#		diceTime = 0.2
#		if effects:
#			$DiceAudio4.play()	
#
#func _on_DiceHiddenButton_pressed():
#	if !playTest && (current == 0):
#		dice()
#
#func handleDice():
#	$DiceButton.disabled = false
#	if dice == 0:
#		$RoundScore.text = str(0) 
#		$RoundScore.modulate = colorInactive
#		if effects:
#			$PigAudio.play()
#		diceCount = 0
#		if current == 0:
#			switchToPlayer2()
#		else:
#			switchToPlayer1()
#	else:
#		$RoundScore.text = str(dice + 1 + int($RoundScore.text))
#		$RoundScore.modulate = colorActive
#		diceCount = diceCount + 1
