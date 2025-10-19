package models

// HuntTimesData represents optimal hunting times
type HuntTimesData struct {
	MorningStart string `json:"morning_start"`
	MorningEnd   string `json:"morning_end"`
	EveningStart string `json:"evening_start"`
	EveningEnd   string `json:"evening_end"`
	MoonPhase    string `json:"moon_phase"`
	Quality      string `json:"quality"`
	Score        int    `json:"score"`
	Factors      []HuntFactor `json:"factors"`
	Recommendations []string `json:"recommendations"`
}

// HuntFactor represents factors affecting hunting quality
type HuntFactor struct {
	Factor      string `json:"factor"`
	Value       string `json:"value"`
	Impact      string `json:"impact"`
	Score       int    `json:"score"`
	Description string `json:"description"`
}

// HuntQuality represents hunting quality levels
type HuntQuality string

const (
	HuntQualityExcellent HuntQuality = "Excellent"
	HuntQualityGood      HuntQuality = "Good"
	HuntQualityFair      HuntQuality = "Fair"
	HuntQualityPoor      HuntQuality = "Poor"
)

// MoonPhaseHunt represents moon phase impact on hunting
type MoonPhaseHunt struct {
	Phase       string `json:"phase"`
	Impact      string `json:"impact"`
	Description string `json:"description"`
	Score       int    `json:"score"`
}
