extends CanvasLayer

@export var metin_label: Label

func _ready():
	hide()

func konus(metin):
	if metin_label != null:
		metin_label.text = metin
	show() 
	get_tree().paused = true # Zamanı dondur

func _input(event):
	# DİKKAT: Artık ui_accept (Enter/Space) değil, direkt klavyedeki "C" tuşunu bekliyoruz!
	if visible and event is InputEventKey and event.keycode == KEY_C and event.pressed:
		hide() 
		get_tree().paused = false # Zamanı devam ettir
