package models

// LocationData represents geographical location information
type LocationData struct {
	Name           string  `json:"name"`
	Region         string  `json:"region"`
	Country        string  `json:"country"`
	Lat            float64 `json:"lat"`
	Lon            float64 `json:"lon"`
	TzID           string  `json:"tz_id"`
	LocalTime      string  `json:"localtime"`
	LocalTimeEpoch int64   `json:"localtime_epoch"`
}

// Coordinates represents geographical coordinates
type Coordinates struct {
	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`
}

// TimezoneInfo represents timezone information
type TimezoneInfo struct {
	Name           string `json:"name"`
	Offset         string `json:"offset"`
	OffsetHours    string `json:"offset_hours"`
	Abbreviation   string `json:"abbreviation"`
	IsDST          bool   `json:"is_dst"`
	CurrentTime    string `json:"current_time"`
}
