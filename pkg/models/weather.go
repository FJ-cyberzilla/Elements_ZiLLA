package models

import (
	"time"
)

// WeatherResponse represents the complete weather response
type WeatherResponse struct {
	Location    LocationData    `json:"location"`
	Current     CurrentWeather  `json:"current"`
	Forecast    ForecastData    `json:"forecast"`
	Astronomy   AstronomyData   `json:"astronomy"`
	AirQuality  AirQualityData  `json:"air_quality"`
	Alerts      []WeatherAlert  `json:"alerts"`
	PrayerTimes PrayerTimesData `json:"prayer_times"`
	HuntTimes   HuntTimesData   `json:"hunt_times"`
	Timestamp   time.Time       `json:"timestamp"`
	ExpiresAt   time.Time       `json:"expires_at"`
}

// CurrentWeather represents current weather conditions
type CurrentWeather struct {
	TempC          float64       `json:"temp_c"`
	TempF          float64       `json:"temp_f"`
	Condition      ConditionData `json:"condition"`
	WindKph        float64       `json:"wind_kph"`
	WindMph        float64       `json:"wind_mph"`
	WindDir        string        `json:"wind_dir"`
	Humidity       int           `json:"humidity"`
	FeelsLikeC     float64       `json:"feelslike_c"`
	FeelsLikeF     float64       `json:"feelslike_f"`
	UV             float64       `json:"uv"`
	VisibilityKm   float64       `json:"vis_km"`
	VisibilityMiles float64      `json:"vis_miles"`
	PressureMb     float64       `json:"pressure_mb"`
	PressureIn     float64       `json:"pressure_in"`
	PrecipMm       float64       `json:"precip_mm"`
	PrecipIn       float64       `json:"precip_in"`
	Cloud          int           `json:"cloud"`
	GustKph        float64       `json:"gust_kph"`
	GustMph        float64       `json:"gust_mph"`
	LastUpdated    string        `json:"last_updated"`
	IsDay          int           `json:"is_day"`
}

// ConditionData represents weather condition information
type ConditionData struct {
	Text string `json:"text"`
	Icon string `json:"icon"`
	Code int    `json:"code"`
}

// ForecastData represents weather forecast
type ForecastData struct {
	Days []ForecastDay `json:"forecastday"`
}

// ForecastDay represents daily forecast
type ForecastDay struct {
	Date      string       `json:"date"`
	DateEpoch int64        `json:"date_epoch"`
	Day       DayData      `json:"day"`
	Astro     AstroData    `json:"astro"`
	Hour      []HourlyData `json:"hour"`
}

// DayData represents daily weather summary
type DayData struct {
	MaxTempC          float64       `json:"maxtemp_c"`
	MaxTempF          float64       `json:"maxtemp_f"`
	MinTempC          float64       `json:"mintemp_c"`
	MinTempF          float64       `json:"mintemp_f"`
	AvgTempC          float64       `json:"avgtemp_c"`
	AvgTempF          float64       `json:"avgtemp_f"`
	MaxWindKph        float64       `json:"maxwind_kph"`
	MaxWindMph        float64       `json:"maxwind_mph"`
	TotalPrecipMm     float64       `json:"totalprecip_mm"`
	TotalPrecipIn     float64       `json:"totalprecip_in"`
	AvgVisKm          float64       `json:"avgvis_km"`
	AvgVisMiles       float64       `json:"avgvis_miles"`
	AvgHumidity       int           `json:"avghumidity"`
	Condition         ConditionData `json:"condition"`
	UV                float64       `json:"uv"`
	ChanceOfRain      int           `json:"chance_of_rain"`
	ChanceOfSnow      int           `json:"chance_of_snow"`
	DailyWillItRain   int           `json:"daily_will_it_rain"`
	DailyWillItSnow   int           `json:"daily_will_it_snow"`
	DailyChanceOfRain int           `json:"daily_chance_of_rain"`
	DailyChanceOfSnow int           `json:"daily_chance_of_snow"`
}

// HourlyData represents hourly weather forecast
type HourlyData struct {
	TimeEpoch    int64         `json:"time_epoch"`
	Time         string        `json:"time"`
	TempC        float64       `json:"temp_c"`
	TempF        float64       `json:"temp_f"`
	Condition    ConditionData `json:"condition"`
	WindKph      float64       `json:"wind_kph"`
	WindMph      float64       `json:"wind_mph"`
	WindDir      string        `json:"wind_dir"`
	Humidity     int           `json:"humidity"`
	Cloud        int           `json:"cloud"`
	FeelsLikeC   float64       `json:"feelslike_c"`
	FeelsLikeF   float64       `json:"feelslike_f"`
	WindChillC   float64       `json:"windchill_c"`
	WindChillF   float64       `json:"windchill_f"`
	HeatIndexC   float64       `json:"heatindex_c"`
	HeatIndexF   float64       `json:"heatindex_f"`
	DewPointC    float64       `json:"dewpoint_c"`
	DewPointF    float64       `json:"dewpoint_f"`
	WillItRain   int           `json:"will_it_rain"`
	ChanceOfRain int           `json:"chance_of_rain"`
	WillItSnow   int           `json:"will_it_snow"`
	ChanceOfSnow int           `json:"chance_of_snow"`
	VisKm        float64       `json:"vis_km"`
	VisMiles     float64       `json:"vis_miles"`
	GustKph      float64       `json:"gust_kph"`
	GustMph      float64       `json:"gust_mph"`
	UV           float64       `json:"uv"`
	ShortRad     float64       `json:"short_rad"`
	DiffRad      float64       `json:"diff_rad"`
}
