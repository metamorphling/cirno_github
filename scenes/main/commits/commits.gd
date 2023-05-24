extends GridContainer

@onready var audio = get_node("/root/Main/Audio")

const MAX_COLOR_STEPS = 5
const MAX_ROWS = 7
const COLOR_OFF_DEFAULT = Color(0.086274, 0.105882, 0.133333)
const COLOR_ON_DEFAULT = Color("#39D353") 

var commits: Array
var db_step : float = 1.0 / MAX_COLOR_STEPS
var max_columns = 49

func _ready():
    # accept audio emits
    audio.audio_data_ready.connect(_on_audio_audio_data_ready)
    # color populate
    for child in get_children():
        commits.append(child)
        child.self_modulate = COLOR_OFF_DEFAULT
    
func _draw_freq(freq, freq_fallout, row):
    for x in range(0, freq.size()):
        var style_level = MAX_COLOR_STEPS - 1
        var db_level = freq[x]
        var db_style = MAX_COLOR_STEPS - 1 - db_level / db_step
        var db_row : int = db_style / (float(MAX_COLOR_STEPS - 1) / MAX_ROWS)
        for y in range(0, db_row):
            var index = y * max_columns + MAX_ROWS * row + x
            commits[index].self_modulate = COLOR_OFF_DEFAULT
        for y in range(db_row, MAX_ROWS):
            var index = y * max_columns + MAX_ROWS * row + x
            commits[index].self_modulate = COLOR_ON_DEFAULT * (freq_fallout[x] * pow(audio.FREQ_FALLOUT_STEP, y - db_row))
            style_level -= 1

func _on_audio_audio_data_ready():
    for i in range(0,audio.FREQ_TYPE_COUNT):
        _draw_freq(audio.frequency[i], audio.frequency_fallout[i], i)
