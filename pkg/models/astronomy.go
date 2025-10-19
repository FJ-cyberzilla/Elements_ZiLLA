package models

// AstronomyData represents astronomical information
type AstronomyData struct {
	Sunrise      string  `json:"sunrise"`
	Sunset       string  `json:"sunset"`
	Moonrise     string  `json:"moonrise"`
	Moonset      string  `json:"moonset"`
	MoonPhase    string  `json:"moon_phase"`
	MoonIllum    string  `json:"moon_illumination"`
	SolarNoon    string  `json:"solar_noon"`
	DayLength    string  `json:"day_length"`
	CivilTwilightBegin string `json:"civil_twilight_begin"`
	CivilTwilightEnd   string `json:"civil_twilight_end"`
	NauticalTwilightBegin string `json:"nautical_twilight_begin"`
	NauticalTwilightEnd   string `json:"nautical_twilight_end"`
	AstronomicalTwilightBegin string `json:"astronomical_twilight_begin"`
	AstronomicalTwilightEnd   string `json:"astronomical_twilight_end"`
}

// AstroData represents daily astronomical data
type AstroData struct {
	Sunrise     string `json:"sunrise"`
	Sunset      string `json:"sunset"`
	Moonrise    string `json:"moonrise"`
	Moonset     string `json:"moonset"`
	MoonPhase   string `json:"moon_phase"`
	MoonIllum   string `json:"moon_illumination"`
	IsMoonUp    int    `json:"is_moon_up"`
	IsSunUp     int    `json:"is_sun_up"`
}

// MoonPhase represents detailed moon phase information
type MoonPhase struct {
	Phase        string  `json:"phase"`
	Illumination float64 `json:"illumination"`
	Age          float64 `json:"age"`
	Angle        float64 `json:"angle"`
	NextNewMoon  string  `json:"next_new_moon"`
	NextFullMoon string  `json:"next_full_moon"`
}
