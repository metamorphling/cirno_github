extends Label

const POWER_OF_HUNDRED_PROGRAMMERS = 100

@onready var audio = get_node("/root/Main/Audio")

func _ready():
    audio.audio_data_ready.connect(_on_audio_audio_data_ready)
    
func _on_audio_audio_data_ready():
    text = str(int(audio.sum_frequency * POWER_OF_HUNDRED_PROGRAMMERS), " contributions in last millisecond")
