package main

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"database/sql"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"strings"
	"sync"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	_ "github.com/mattn/go-sqlite3"
	package main

import (
	// ... other imports
	"path/filepath"
	"weather-app/internal/i18n"
)

type Config struct {
	Port           string
	APIKey         string
	EncryptionKey  string
	CacheDuration  time.Duration
	AdminEmail     string
	AllowedOrigins []string
	LocalesPath    string
	DefaultLang    string
}

func LoadConfig() *Config {
	return &Config{
		Port:          getEnv("PORT", "8080"),
		APIKey:        getEnv("WEATHER_API_KEY", "f807e87175ee4ff98f551941252009"),
		EncryptionKey: getEnv("ENCRYPTION_KEY", "cyberzilla-systems-key-32bit"),
		CacheDuration: 15 * time.Minute,
		AdminEmail:    "cyberzilla.systems@gmail.com",
		AllowedOrigins: []string{"*"},
		LocalesPath:   getEnv("LOCALES_PATH", "./configs/locales"),
		DefaultLang:   getEnv("DEFAULT_LANG", "en"),
	}
}

// Agent struct update
type Agent struct {
	config    *Config
	db        *sql.DB
	cache     *Cache
	apiClient *APIClient
	logger    *Logger
	i18n      *i18n.Bundle
	mu        sync.RWMutex
}

func NewAgent(config *Config) *Agent {
	// Initialize i18n
	i18nBundle := i18n.NewBundle(config.LocalesPath, config.DefaultLang)
	
	agent := &Agent{
		config:    config,
		db:        InitDB(),
		cache:     NewCache(),
		apiClient: NewAPIClient(config.APIKey),
		logger:    NewLogger(),
		i18n:      i18nBundle,
	}
	agent.logger.Log("INFO", "Agent initialized successfully")
	return agent
}

// HTTP Handlers with i18n support
func (a *Agent) HandleWeather(c *gin.Context) {
	location := c.Query("location")
	lang := c.Query("lang")
	if lang == "" {
		lang = a.config.DefaultLang
	}

	if location == "" {
		errorMsg := a.i18n.Translate(lang, "errors.location_required")
		c.JSON(http.StatusBadRequest, gin.H{"error": errorMsg})
		return
	}

	weather, err := a.GetWeather(location)
	if err != nil {
		a.logger.Log("ERROR", fmt.Sprintf("Weather fetch error: %v", err))
		errorMsg := a.i18n.Translate(lang, "errors.weather_not_found")
		c.JSON(http.StatusInternalServerError, gin.H{"error": errorMsg})
		return
	}

	c.JSON(http.StatusOK, weather)
}

// New endpoint to get translations
func (a *Agent) HandleTranslations(c *gin.Context) {
	lang := c.Param("lang")
	if lang == "" {
		lang = a.config.DefaultLang
	}

	// Return available translations or specific locale
	c.JSON(http.StatusOK, gin.H{
		"available_locales": a.i18n.GetAvailableLocales(),
		"current_locale":    lang,
	})
}

// Response models with translated fields
type TranslatedWeatherResponse struct {
	*WeatherResponse
	Translations map[string]string `json:"translations,omitempty"`
}
)

// Configuration
type Config struct {
	Port           string
	APIKey         string
	EncryptionKey  string
	CacheDuration  time.Duration
	AdminEmail     string
	AllowedOrigins []string
}

// Agent - Custom intelligent agent for API orchestration
type Agent struct {
	config    *Config
	db        *sql.DB
	cache     *Cache
	apiClient *APIClient
	logger    *Logger
	mu        sync.RWMutex
}

// Cache structure
type Cache struct {
	store map[string]CacheEntry
	mu    sync.RWMutex
}

type CacheEntry struct {
	Data      interface{}
	ExpiresAt time.Time
}

// Logger
type Logger struct {
	file *os.File
	mu   sync.Mutex
}

// API Client
type APIClient struct {
	httpClient *http.Client
	baseURL    string
	apiKey     string
}

// Response models
type WeatherResponse struct {
	Location    LocationData    `json:"location"`
	Current     CurrentWeather  `json:"current"`
	Forecast    ForecastData    `json:"forecast"`
	Astronomy   AstronomyData   `json:"astronomy"`
	AirQuality  AirQualityData  `json:"air_quality"`
	Alerts      []WeatherAlert  `json:"alerts"`
	PrayerTimes PrayerTimesData `json:"prayer_times"`
	HuntTimes   HuntTimesData   `json:"hunt_times"`
}

type LocationData struct {
	Name      string  `json:"name"`
	Region    string  `json:"region"`
	Country   string  `json:"country"`
	Lat       float64 `json:"lat"`
	Lon       float64 `json:"lon"`
	TzID      string  `json:"tz_id"`
	LocalTime string  `json:"localtime"`
}

type CurrentWeather struct {
	TempC      float64         `json:"temp_c"`
	TempF      float64         `json:"temp_f"`
	Condition  ConditionData   `json:"condition"`
	WindKph    float64         `json:"wind_kph"`
	WindDir    string          `json:"wind_dir"`
	Humidity   int             `json:"humidity"`
	FeelsLike  float64         `json:"feelslike_c"`
	UV         float64         `json:"uv"`
	Visibility float64         `json:"vis_km"`
	AirQuality AirQualityData  `json:"air_quality"`
}

type ConditionData struct {
	Text string `json:"text"`
	Icon string `json:"icon"`
	Code int    `json:"code"`
}

type ForecastData struct {
	Days []ForecastDay `json:"forecastday"`
}

type ForecastDay struct {
	Date      string         `json:"date"`
	Day       DayData        `json:"day"`
	Astro     AstroData      `json:"astro"`
	Hour      []HourlyData   `json:"hour"`
}

type DayData struct {
	MaxTemp       float64       `json:"maxtemp_c"`
	MinTemp       float64       `json:"mintemp_c"`
	AvgTemp       float64       `json:"avgtemp_c"`
	Condition     ConditionData `json:"condition"`
	ChanceOfRain  int           `json:"daily_chance_of_rain"`
	ChanceOfSnow  int           `json:"daily_chance_of_snow"`
	UV            float64       `json:"uv"`
}

type AstroData struct {
	Sunrise     string `json:"sunrise"`
	Sunset      string `json:"sunset"`
	Moonrise    string `json:"moonrise"`
	Moonset     string `json:"moonset"`
	MoonPhase   string `json:"moon_phase"`
	MoonIllum   string `json:"moon_illumination"`
}

type HourlyData struct {
	Time      string        `json:"time"`
	TempC     float64       `json:"temp_c"`
	Condition ConditionData `json:"condition"`
	ChanceOfRain int        `json:"chance_of_rain"`
}

type AstronomyData struct {
	Sunrise      string  `json:"sunrise"`
	Sunset       string  `json:"sunset"`
	Moonrise     string  `json:"moonrise"`
	Moonset      string  `json:"moonset"`
	MoonPhase    string  `json:"moon_phase"`
	MoonIllum    string  `json:"moon_illumination"`
	SolarNoon    string  `json:"solar_noon"`
	DayLength    string  `json:"day_length"`
}

type AirQualityData struct {
	CO      float64 `json:"co"`
	NO2     float64 `json:"no2"`
	O3      float64 `json:"o3"`
	SO2     float64 `json:"so2"`
	PM25    float64 `json:"pm2_5"`
	PM10    float64 `json:"pm10"`
	USAQI   int     `json:"us-epa-index"`
	GBAQI   int     `json:"gb-defra-index"`
}

type WeatherAlert struct {
	Headline    string `json:"headline"`
	Severity    string `json:"severity"`
	Urgency     string `json:"urgency"`
	Areas       string `json:"areas"`
	Category    string `json:"category"`
	Event       string `json:"event"`
	Effective   string `json:"effective"`
	Expires     string `json:"expires"`
	Description string `json:"desc"`
}

type PrayerTimesData struct {
	Fajr    string `json:"fajr"`
	Sunrise string `json:"sunrise"`
	Dhuhr   string `json:"dhuhr"`
	Asr     string `json:"asr"`
	Sunset  string `json:"sunset"`
	Maghrib string `json:"maghrib"`
	Isha    string `json:"isha"`
}

type HuntTimesData struct {
	MorningStart string `json:"morning_start"`
	MorningEnd   string `json:"morning_end"`
	EveningStart string `json:"evening_start"`
	EveningEnd   string `json:"evening_end"`
	MoonPhase    string `json:"moon_phase"`
	Quality      string `json:"quality"`
}

type IPLookupResponse struct {
	IP          string  `json:"ip"`
	Type        string  `json:"type"`
	City        string  `json:"city"`
	Region      string  `json:"region"`
	Country     string  `json:"country"`
	CountryName string  `json:"country_name"`
	Lat         float64 `json:"lat"`
	Lon         float64 `json:"lon"`
	Timezone    string  `json:"timezone"`
}

// Initialize configuration
func LoadConfig() *Config {
	return &Config{
		Port:          getEnv("PORT", "8080"),
		APIKey:        getEnv("WEATHER_API_KEY", "f807e87175ee4ff98f551941252009"),
		EncryptionKey: getEnv("ENCRYPTION_KEY", "cyberzilla-systems-key-32bit"),
		CacheDuration: 15 * time.Minute,
		AdminEmail:    "cyberzilla.systems@gmail.com",
		AllowedOrigins: []string{"*"},
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

// Initialize Logger
func NewLogger() *Logger {
	file, err := os.OpenFile("weather-app.log", os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0666)
	if err != nil {
		log.Fatal("Failed to open log file:", err)
	}
	return &Logger{file: file}
}

func (l *Logger) Log(level, message string) {
	l.mu.Lock()
	defer l.mu.Unlock()
	timestamp := time.Now().Format("2006-01-02 15:04:05")
	logEntry := fmt.Sprintf("[%s] [%s] %s\n", timestamp, level, message)
	l.file.WriteString(logEntry)
	fmt.Print(logEntry)
}

// Initialize Cache
func NewCache() *Cache {
	cache := &Cache{
		store: make(map[string]CacheEntry),
	}
	go cache.cleanup()
	return cache
}

func (c *Cache) Get(key string) (interface{}, bool) {
	c.mu.RLock()
	defer c.mu.RUnlock()
	entry, exists := c.store[key]
	if !exists || time.Now().After(entry.ExpiresAt) {
		return nil, false
	}
	return entry.Data, true
}

func (c *Cache) Set(key string, value interface{}, duration time.Duration) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.store[key] = CacheEntry{
		Data:      value,
		ExpiresAt: time.Now().Add(duration),
	}
}

func (c *Cache) cleanup() {
	ticker := time.NewTicker(5 * time.Minute)
	for range ticker.C {
		c.mu.Lock()
		now := time.Now()
		for key, entry := range c.store {
			if now.After(entry.ExpiresAt) {
				delete(c.store, key)
			}
		}
		c.mu.Unlock()
	}
}

// Initialize Database
func InitDB() *sql.DB {
	db, err := sql.Open("sqlite3", "./weather_cache.db")
	if err != nil {
		log.Fatal("Failed to open database:", err)
	}

	createTable := `
	CREATE TABLE IF NOT EXISTS weather_cache (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		cache_key TEXT UNIQUE,
		data TEXT,
		created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
		expires_at DATETIME
	);
	CREATE INDEX IF NOT EXISTS idx_cache_key ON weather_cache(cache_key);
	CREATE INDEX IF NOT EXISTS idx_expires ON weather_cache(expires_at);
	`
	_, err = db.Exec(createTable)
	if err != nil {
		log.Fatal("Failed to create table:", err)
	}

	return db
}

// API Client implementation
func NewAPIClient(apiKey string) *APIClient {
	return &APIClient{
		httpClient: &http.Client{Timeout: 10 * time.Second},
		baseURL:    "https://api.weatherapi.com/v1",
		apiKey:     apiKey,
	}
}

func (api *APIClient) Get(endpoint string, params map[string]string) ([]byte, error) {
	url := fmt.Sprintf("%s/%s?key=%s", api.baseURL, endpoint, api.apiKey)
	for key, value := range params {
		url += fmt.Sprintf("&%s=%s", key, value)
	}

	resp, err := api.httpClient.Get(url)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("API error: %s", string(body))
	}

	return body, nil
}

// Agent implementation
func NewAgent(config *Config) *Agent {
	agent := &Agent{
		config:    config,
		db:        InitDB(),
		cache:     NewCache(),
		apiClient: NewAPIClient(config.APIKey),
		logger:    NewLogger(),
	}
	agent.logger.Log("INFO", "Agent initialized successfully")
	return agent
}

// Calculate prayer times (Islamic prayer calculation)
func (a *Agent) calculatePrayerTimes(lat, lon float64, date time.Time) PrayerTimesData {
	// Simplified calculation - in production use proper astronomical calculations
	sunrise := time.Date(date.Year(), date.Month(), date.Day(), 6, 0, 0, 0, date.Location())
	sunset := time.Date(date.Year(), date.Month(), date.Day(), 18, 30, 0, 0, date.Location())
	
	return PrayerTimesData{
		Fajr:    sunrise.Add(-90 * time.Minute).Format("15:04"),
		Sunrise: sunrise.Format("15:04"),
		Dhuhr:   sunrise.Add(6*time.Hour + 30*time.Minute).Format("15:04"),
		Asr:     sunrise.Add(10 * time.Hour).Format("15:04"),
		Sunset:  sunset.Format("15:04"),
		Maghrib: sunset.Add(5 * time.Minute).Format("15:04"),
		Isha:    sunset.Add(90 * time.Minute).Format("15:04"),
	}
}

// Calculate optimal hunting times
func (a *Agent) calculateHuntTimes(astro AstroData) HuntTimesData {
	quality := "Good"
	if strings.Contains(astro.MoonPhase, "Full") {
		quality = "Fair"
	} else if strings.Contains(astro.MoonPhase, "New") {
		quality = "Excellent"
	}

	return HuntTimesData{
		MorningStart: astro.Sunrise,
		MorningEnd:   "10:00 AM",
		EveningStart: "4:00 PM",
		EveningEnd:   astro.Sunset,
		MoonPhase:    astro.MoonPhase,
		Quality:      quality,
	}
}

// Get comprehensive weather data
func (a *Agent) GetWeather(location string) (*WeatherResponse, error) {
	cacheKey := fmt.Sprintf("weather:%s", location)
	
	// Check cache
	if cached, found := a.cache.Get(cacheKey); found {
		a.logger.Log("INFO", fmt.Sprintf("Cache hit for location: %s", location))
		return cached.(*WeatherResponse), nil
	}

	a.logger.Log("INFO", fmt.Sprintf("Fetching weather for: %s", location))

	// Fetch forecast with all data
	params := map[string]string{
		"q":      location,
		"days":   "7",
		"aqi":    "yes",
		"alerts": "yes",
	}
	
	data, err := a.apiClient.Get("forecast.json", params)
	if err != nil {
		a.logger.Log("ERROR", fmt.Sprintf("API error: %v", err))
		return nil, err
	}

	var apiResponse map[string]interface{}
	if err := json.Unmarshal(data, &apiResponse); err != nil {
		return nil, err
	}

	response := a.parseWeatherResponse(apiResponse)
	
	// Cache the response
	a.cache.Set(cacheKey, response, a.config.CacheDuration)
	
	return response, nil
}

func (a *Agent) parseWeatherResponse(data map[string]interface{}) *WeatherResponse {
	response := &WeatherResponse{}
	
	// Parse location
	if loc, ok := data["location"].(map[string]interface{}); ok {
		response.Location = LocationData{
			Name:      getString(loc, "name"),
			Region:    getString(loc, "region"),
			Country:   getString(loc, "country"),
			Lat:       getFloat(loc, "lat"),
			Lon:       getFloat(loc, "lon"),
			TzID:      getString(loc, "tz_id"),
			LocalTime: getString(loc, "localtime"),
		}
	}

	// Parse current weather
	if curr, ok := data["current"].(map[string]interface{}); ok {
		response.Current = CurrentWeather{
			TempC:     getFloat(curr, "temp_c"),
			TempF:     getFloat(curr, "temp_f"),
			WindKph:   getFloat(curr, "wind_kph"),
			WindDir:   getString(curr, "wind_dir"),
			Humidity:  int(getFloat(curr, "humidity")),
			FeelsLike: getFloat(curr, "feelslike_c"),
			UV:        getFloat(curr, "uv"),
			Visibility: getFloat(curr, "vis_km"),
		}
		
		if cond, ok := curr["condition"].(map[string]interface{}); ok {
			response.Current.Condition = ConditionData{
				Text: getString(cond, "text"),
				Icon: getString(cond, "icon"),
				Code: int(getFloat(cond, "code")),
			}
		}

		if aqi, ok := curr["air_quality"].(map[string]interface{}); ok {
			response.AirQuality = AirQualityData{
				CO:    getFloat(aqi, "co"),
				NO2:   getFloat(aqi, "no2"),
				O3:    getFloat(aqi, "o3"),
				SO2:   getFloat(aqi, "so2"),
				PM25:  getFloat(aqi, "pm2_5"),
				PM10:  getFloat(aqi, "pm10"),
				USAQI: int(getFloat(aqi, "us-epa-index")),
			}
		}
	}

	// Parse forecast
	if forecast, ok := data["forecast"].(map[string]interface{}); ok {
		if days, ok := forecast["forecastday"].([]interface{}); ok && len(days) > 0 {
			response.Forecast.Days = make([]ForecastDay, 0)
			
			for _, dayInterface := range days {
				if day, ok := dayInterface.(map[string]interface{}); ok {
					forecastDay := ForecastDay{
						Date: getString(day, "date"),
					}

					if dayData, ok := day["day"].(map[string]interface{}); ok {
						forecastDay.Day = DayData{
							MaxTemp:      getFloat(dayData, "maxtemp_c"),
							MinTemp:      getFloat(dayData, "mintemp_c"),
							AvgTemp:      getFloat(dayData, "avgtemp_c"),
							ChanceOfRain: int(getFloat(dayData, "daily_chance_of_rain")),
							ChanceOfSnow: int(getFloat(dayData, "daily_chance_of_snow")),
							UV:           getFloat(dayData, "uv"),
						}
						
						if cond, ok := dayData["condition"].(map[string]interface{}); ok {
							forecastDay.Day.Condition = ConditionData{
								Text: getString(cond, "text"),
								Icon: getString(cond, "icon"),
							}
						}
					}

					if astro, ok := day["astro"].(map[string]interface{}); ok {
						forecastDay.Astro = AstroData{
							Sunrise:   getString(astro, "sunrise"),
							Sunset:    getString(astro, "sunset"),
							Moonrise:  getString(astro, "moonrise"),
							Moonset:   getString(astro, "moonset"),
							MoonPhase: getString(astro, "moon_phase"),
							MoonIllum: getString(astro, "moon_illumination"),
						}
					}

					response.Forecast.Days = append(response.Forecast.Days, forecastDay)
				}
			}

			// Set astronomy data from first day
			if len(response.Forecast.Days) > 0 {
				astro := response.Forecast.Days[0].Astro
				response.Astronomy = AstronomyData{
					Sunrise:   astro.Sunrise,
					Sunset:    astro.Sunset,
					Moonrise:  astro.Moonrise,
					Moonset:   astro.Moonset,
					MoonPhase: astro.MoonPhase,
					MoonIllum: astro.MoonIllum,
				}

				// Calculate prayer times
				response.PrayerTimes = a.calculatePrayerTimes(
					response.Location.Lat,
					response.Location.Lon,
					time.Now(),
				)

				// Calculate hunt times
				response.HuntTimes = a.calculateHuntTimes(astro)
			}
		}
	}

	// Parse alerts
	if alerts, ok := data["alerts"].(map[string]interface{}); ok {
		if alertList, ok := alerts["alert"].([]interface{}); ok {
			response.Alerts = make([]WeatherAlert, 0)
			for _, alertInterface := range alertList {
				if alert, ok := alertInterface.(map[string]interface{}); ok {
					response.Alerts = append(response.Alerts, WeatherAlert{
						Headline:    getString(alert, "headline"),
						Severity:    getString(alert, "severity"),
						Urgency:     getString(alert, "urgency"),
						Event:       getString(alert, "event"),
						Description: getString(alert, "desc"),
						Expires:     getString(alert, "expires"),
					})
				}
			}
		}
	}

	return response
}

// IP Lookup
func (a *Agent) GetIPLookup(ip string) (*IPLookupResponse, error) {
	cacheKey := fmt.Sprintf("ip:%s", ip)
	
	if cached, found := a.cache.Get(cacheKey); found {
		return cached.(*IPLookupResponse), nil
	}

	params := map[string]string{"q": ip}
	data, err := a.apiClient.Get("ip.json", params)
	if err != nil {
		return nil, err
	}

	var response IPLookupResponse
	if err := json.Unmarshal(data, &response); err != nil {
		return nil, err
	}

	a.cache.Set(cacheKey, &response, a.config.CacheDuration)
	return &response, nil
}

// Helper functions
func getString(m map[string]interface{}, key string) string {
	if val, ok := m[key]; ok {
		if str, ok := val.(string); ok {
			return str
		}
	}
	return ""
}

func getFloat(m map[string]interface{}, key string) float64 {
	if val, ok := m[key]; ok {
		switch v := val.(type) {
		case float64:
			return v
		case int:
			return float64(v)
		case string:
			// Handle string numbers if needed
			return 0
		}
	}
	return 0
}

// HTTP Handlers
func (a *Agent) HandleWeather(c *gin.Context) {
	location := c.Query("location")
	if location == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Location parameter required"})
		return
	}

	weather, err := a.GetWeather(location)
	if err != nil {
		a.logger.Log("ERROR", fmt.Sprintf("Weather fetch error: %v", err))
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, weather)
}

func (a *Agent) HandleIPLookup(c *gin.Context) {
	ip := c.Query("ip")
	if ip == "" || ip == "auto" {
		ip = c.ClientIP()
	}

	lookup, err := a.GetIPLookup(ip)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, lookup)
}

func (a *Agent) HandleHealth(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"status": "healthy",
		"agent":  "Cyberzilla Weather Agent v1.0",
		"admin":  a.config.AdminEmail,
		"time":   time.Now().Format(time.RFC3339),
	})
}

// Main function
func main() {
	config := LoadConfig()
	agent := NewAgent(config)
	defer agent.db.Close()
	defer agent.logger.file.Close()

	// Setup Gin router
	gin.SetMode(gin.ReleaseMode)
	router := gin.Default()

	// CORS configuration
	corsConfig := cors.DefaultConfig()
	corsConfig.AllowOrigins = config.AllowedOrigins
	corsConfig.AllowMethods = []string{"GET", "POST", "OPTIONS"}
	corsConfig.AllowHeaders = []string{"Origin", "Content-Type", "Accept"}
	router.Use(cors.New(corsConfig))

	// Serve static files
	router.Static("/static", "./static")
	router.StaticFile("/", "./static/index.html")

	
	// API routes
	api := router.Group("/api/v1")
	{
		api.GET("/weather", agent.HandleWeather)
		api.GET("/ip", agent.HandleIPLookup)
		api.GET("/health", agent.HandleHealth)
	}

	// Start server
	agent.logger.Log("INFO", fmt.Sprintf("Server starting on port %s", config.Port))
	fmt.Printf("\n🌦️  Cyberzilla Weather System\n")
	fmt.Printf("📧 Admin: %s\n", config.AdminEmail)
	fmt.Printf("🚀 Server: http://localhost:%s\n\n", config.Port)
	
	if err := router.Run(":" + config.Port); err != nil {
		agent.logger.Log("FATAL", fmt.Sprintf("Server failed: %v", err))
		log.Fatal(err) 
		{
}
// In LoadConfig(), use proper environment variable handling
func LoadConfig() *Config {
    encryptionKey := getEnv("ENCRYPTION_KEY", "")
    if encryptionKey == "" {
        log.Fatal("ENCRYPTION_KEY environment variable is required")
    }
    
    return &Config{
        Port:          getEnv("PORT", "8080"),
        APIKey:        getEnv("WEATHER_API_KEY", ""),
        EncryptionKey: encryptionKey,
        CacheDuration: 15 * time.Minute,
        AdminEmail:    "cyberzilla.systems@gmail.com",
        AllowedOrigins: strings.Split(getEnv("ALLOWED_ORIGINS", "http://localhost:8080,http://127.0.0.1:8080"), ","),
    }
}
func (a *Agent) GetWeather(location string) (*WeatherResponse, error) {
    if location == "" {
        return nil, fmt.Errorf("location cannot be empty")
    }
    
    cacheKey := fmt.Sprintf("weather:%s", location)
    
    if cached, found := a.cache.Get(cacheKey); found {
        a.logger.Log("INFO", fmt.Sprintf("Cache hit for location: %s", location))
        return cached.(*WeatherResponse), nil
    }

    // Add timeout context
    ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
    defer cancel()

    // ... rest of the function
}
