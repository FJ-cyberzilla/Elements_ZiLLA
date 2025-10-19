package models

// PrayerTimesData represents Islamic prayer times
type PrayerTimesData struct {
	Fajr          string `json:"fajr"`
	Sunrise       string `json:"sunrise"`
	Dhuhr         string `json:"dhuhr"`
	Asr           string `json:"asr"`
	Sunset        string `json:"sunset"`
	Maghrib       string `json:"maghrib"`
	Isha          string `json:"isha"`
	Imsak         string `json:"imsak"`
	Midnight      string `json:"midnight"`
	FirstThird    string `json:"first_third"`
	LastThird     string `json:"last_third"`
	CalculationMethod string `json:"calculation_method"`
	AsrMethod     string `json:"asr_method"`
	Latitude      float64 `json:"latitude"`
	Longitude     float64 `json:"longitude"`
	Timezone      string `json:"timezone"`
	Date          string `json:"date"`
}

// PrayerTimeCalculation represents prayer time calculation methods
type PrayerTimeCalculation struct {
	Method      string  `json:"method"`
	FajrAngle   float64 `json:"fajr_angle"`
	IshaAngle   float64 `json:"isha_angle"`
	IshaInterval int    `json:"isha_interval"`
	AsrMethod   string  `json:"asr_method"`
	HighLatitudeMethod string `json:"high_latitude_method"`
}

// Prayer represents individual prayer information
type Prayer struct {
	Name        string `json:"name"`
	Time        string `json:"time"`
	Iqama       string `json:"iqama"`
	Jamaat      string `json:"jamaat"`
	IsCurrent   bool   `json:"is_current"`
	IsNext      bool   `json:"is_next"`
	TimeRemaining string `json:"time_remaining"`
}
