extends Node2D

signal audio_data_ready

const FREQ_BASS_MIN = 16.0              # Min Sub-bass
const FREQ_BASS_MAX = 60.0              # Max Sub-bass
const FREQ_SUBBASS_MIN = 60.0           # Min Bass
const FREQ_SUBBASS_MAX = 250.0          # Max Bass
const FREQ_LOWMID_MIN = 250.0           # Min Lower Midrange
const FREQ_LOWMID_MAX = 500.0           # Max Lower Midrange
const FREQ_MID_MIN = 500.0              # Min Midrange
const FREQ_MID_MAX = 2000.0             # Max Midrange
const FREQ_HIGHMID_MIN = 2000.0         # Min Higher Midrange
const FREQ_HIGHMID_MAX = 4000.0         # Max Higher Midrange
const FREQ_PRES_MIN = 4000.0            # Min Presence
const FREQ_PRES_MAX = 6000.0            # Max Presence
const FREQ_BRIL_MIN = 6000.0            # Min Brilliance
const FREQ_BRIL_MAX = 20000.0           # Max Brilliance

const MIN_DB = 75                       # sane db pass check
const FREQ_TYPE_COUNT = 7
const FREQ_FALLOUT_START = 0.85
const FREQ_FALLOUT_STEP = 0.75

const DEBUG_WIDTH = 400
const DEBUG_HEIGHT = 100

const DEBUG_COLORS = [ 
    Color.RED, 
    Color.ORANGE, 
    Color.YELLOW, 
    Color.GREEN, 
    Color.CYAN, 
    Color.BLUE, 
    Color.MAGENTA, 
    Color.WHITE,
]
const FREQ_ARR = [
    [FREQ_BASS_MIN,FREQ_BASS_MAX],
    [FREQ_SUBBASS_MIN,FREQ_SUBBASS_MAX],
    [FREQ_LOWMID_MIN,FREQ_LOWMID_MAX],
    [FREQ_MID_MIN,FREQ_MID_MAX],
    [FREQ_HIGHMID_MIN,FREQ_HIGHMID_MAX],
    [FREQ_PRES_MIN,FREQ_PRES_MAX],
    [FREQ_BRIL_MIN,FREQ_BRIL_MAX],
]

@onready var main = get_node("/root/Main")

var spectrum = AudioServer.get_bus_effect_instance(0,0)
var frequency = []
var frequency_fallout = []
var sum_frequency = 0
var is_debug_visible = false

func _init():
    frequency.resize(FREQ_TYPE_COUNT)
    for i in range(0,frequency.size()):
        frequency[i] = []
        frequency[i].resize(FREQ_TYPE_COUNT)
        frequency[i].fill(0)
    frequency_fallout.resize(FREQ_TYPE_COUNT)
    for i in range(0,frequency_fallout.size()):
        frequency_fallout[i] = []
        frequency_fallout[i].resize(FREQ_TYPE_COUNT)
        frequency_fallout[i].fill(FREQ_FALLOUT_START)

func _ready():
    main.debug_state_changed.connect(_on_main_debug_state_changed)
    
func _clean_range(y_offset):
    var w = DEBUG_WIDTH / FREQ_TYPE_COUNT
    for i in range(0,FREQ_TYPE_COUNT):
        var energy = 1
        var height = energy * DEBUG_HEIGHT
        draw_rect(Rect2(w*i,y_offset*DEBUG_HEIGHT-height,w,height),Color(0,0,0,1))
        
func _debug_draw_range(y_offset, freq):
    var w = DEBUG_WIDTH / FREQ_TYPE_COUNT
    for i in range(0,FREQ_TYPE_COUNT):
        var height = freq[i] * DEBUG_HEIGHT
        draw_rect(Rect2(w*i,(y_offset+1)*DEBUG_HEIGHT-height,w,height), DEBUG_COLORS[y_offset])

func _calc_range(freq_min, freq_max, freq, freq_fallout, index):
    var prev_hz = freq_min
    for i in range(0,FREQ_TYPE_COUNT):
        var hz = freq_min + (i + 1) * (freq_max - freq_min) / FREQ_TYPE_COUNT;
        var magnitude = spectrum.get_magnitude_for_frequency_range(prev_hz,hz).length()
        var energy = clamp((MIN_DB + linear_to_db(magnitude))/MIN_DB,0,1)
        if (freq[i] > energy):
            energy = freq[i] * freq_fallout[i]
            freq_fallout[i] *= FREQ_FALLOUT_STEP
        else:
            sum_frequency += energy
        freq[i] = energy
        prev_hz = hz

func _draw():
    if (!is_debug_visible):
        return
    for i in range(0,FREQ_TYPE_COUNT):
        _debug_draw_range(i, frequency[i])

func _process(_delta):
    sum_frequency = 0
    for i in range(0,FREQ_TYPE_COUNT):
        frequency_fallout[i].fill(FREQ_FALLOUT_START)
        _calc_range(FREQ_ARR[i][0], FREQ_ARR[i][1], frequency[i], frequency_fallout[i], i)
    audio_data_ready.emit()
    queue_redraw()
    
func _on_main_debug_state_changed(debug_on):
    is_debug_visible = debug_on
