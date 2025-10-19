package models

// AirQualityData represents air quality information
type AirQualityData struct {
	CO           float64 `json:"co"`
	NO2          float64 `json:"no2"`
	O3           float64 `json:"o3"`
	SO2          float64 `json:"so2"`
	PM25         float64 `json:"pm2_5"`
	PM10         float64 `json:"pm10"`
	USAQI        int     `json:"us-epa-index"`
	GBAQI        int     `json:"gb-defra-index"`
	AQI          int     `json:"aqi"`
	AQILevel     string  `json:"aqi_level"`
	AQIDescription string `json:"aqi_description"`
}

// AirQualityIndex represents AQI levels and descriptions
type AirQualityIndex struct {
	Value       int    `json:"value"`
	Level       string `json:"level"`
	Description string `json:"description"`
	Color       string `json:"color"`
	HealthImplications string `json:"health_implications"`
}

// Pollutant represents individual pollutant data
type Pollutant struct {
	Name         string  `json:"name"`
	Code         string  `json:"code"`
	Concentration float64 `json:"concentration"`
	Units        string  `json:"units"`
	AQI          int     `json:"aqi"`
	Category     string  `json:"category"`
}
