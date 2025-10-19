<< 'EOF'
#!/bin/bash
# Cyberzilla Weather System Hotfix Script
# This script applies all i18n and models package updates

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_success "Documentation created: HOTFIX_README.md"

log_info "Starting hotfix application..."

# Execute all steps
check_directory
backup_files
create_directories
create_i18n_package
create_locale_files
create_models_package
update_main_go
update_html_file
create_env_file
build_and_test
create_readme

echo
log_success "Hotfix applied successfully! 🎉"
echo
log_info "Summary of changes:"
echo "  ✅ Created i18n package (internal/i18n/)"
echo "  ✅ Created models package (pkg/models/)"
echo "  ✅ Added locale files (configs/locales/)"
echo "  ✅ Updated main.go with i18n support"
echo "  ✅ Updated HTML with multi-language support"
echo "  ✅ Created environment configuration"
echo "  ✅ Built and tested application"
echo "  ✅ Created documentation"
echo
log_info "Next steps:"
echo "  1. Review the changes in HOTFIX_README.md"
echo "  2. Update your .env file with actual API keys"
echo "  3. Run: ./weather-app to start the server"
echo "  4. Test the language toggle functionality"
echo
log_info "Backup created in: backup_$(date +%Y%m%d_%H%M%S)/"
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
check_directory() {
    if [[ ! -f "go.mod" ]] || [[ ! -d "cmd" ]]; then
        log_error "Please run this script from the project root directory"
        exit 1
    fi
    log_success "Directory check passed"
}

# Backup existing files
backup_files() {
    log_info "Creating backup of modified files..."
    local backup_dir="backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Backup files that will be modified
    cp -f cmd/weather/main.go "$backup_dir/" 2>/dev/null || true
    cp -f static/index.html "$backup_dir/" 2>/dev/null || true
    
    log_success "Backup created in: $backup_dir"
}

# Create directory structure
create_directories() {
    log_info "Creating directory structure..."
    
    mkdir -p internal/i18n
    mkdir -p pkg/models
    mkdir -p configs/locales
    
    log_success "Directory structure created"
}

# Create i18n package
create_i18n_package() {
    log_info "Creating i18n package..."
    
    cat > internal/i18n/i18n.go << 'EOF'
package i18n

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"
	"sync"
)

type Translator struct {
	locale       string
	translations map[string]string
	mu           sync.RWMutex
}

type Bundle struct {
	translators map[string]*Translator
	defaultLang string
	mu          sync.RWMutex
}

var (
	instance *Bundle
	once     sync.Once
)

func NewBundle(localesPath string, defaultLang string) *Bundle {
	once.Do(func() {
		instance = &Bundle{
			translators: make(map[string]*Translator),
			defaultLang: defaultLang,
		}
		instance.loadLocales(localesPath)
	})
	return instance
}

func GetInstance() *Bundle {
	return instance
}

func (b *Bundle) loadLocales(localesPath string) {
	b.mu.Lock()
	defer b.mu.Unlock()

	entries, err := os.ReadDir(localesPath)
	if err != nil {
		log.Printf("Warning: Could not read locales directory: %v", err)
		return
	}

	for _, entry := range entries {
		if entry.IsDir() || !strings.HasSuffix(entry.Name(), ".json") {
			continue
		}

		locale := strings.TrimSuffix(entry.Name(), ".json")
		filePath := filepath.Join(localesPath, entry.Name())
		
		translator, err := loadTranslator(filePath, locale)
		if err != nil {
			log.Printf("Error loading locale %s: %v", locale, err)
			continue
		}

		b.translators[locale] = translator
		log.Printf("Loaded locale: %s", locale)
	}

	if _, exists := b.translators[b.defaultLang]; !exists {
		log.Printf("Warning: Default language '%s' not found", b.defaultLang)
	}
}

func loadTranslator(filePath string, locale string) (*Translator, error) {
	data, err := os.ReadFile(filePath)
	if err != nil {
		return nil, fmt.Errorf("could not read locale file: %w", err)
	}

	var translations map[string]string
	if err := json.Unmarshal(data, &translations); err != nil {
		return nil, fmt.Errorf("could not parse locale file: %w", err)
	}

	return &Translator{
		locale:       locale,
		translations: translations,
	}, nil
}

func (b *Bundle) Translate(lang, key string, args ...interface{}) string {
	b.mu.RLock()
	defer b.mu.RUnlock()

	translator, exists := b.translators[lang]
	if !exists {
		translator, exists = b.translators[b.defaultLang]
		if !exists {
			return key
		}
	}

	return translator.Translate(key, args...)
}

func (b *Bundle) GetAvailableLocales() []string {
	b.mu.RLock()
	defer b.mu.RUnlock()

	locales := make([]string, 0, len(b.translators))
	for locale := range b.translators {
		locales = append(locales, locale)
	}
	return locales
}

func (t *Translator) Translate(key string, args ...interface{}) string {
	t.mu.RLock()
	defer t.mu.RUnlock()

	translation, exists := t.translations[key]
	if !exists {
		return key
	}

	if len(args) > 0 {
		return fmt.Sprintf(translation, args...)
	}
	return translation
}
EOF

    log_success "i18n package created"
}

# Create locale files
create_locale_files() {
    log_info "Creating locale files..."
    
    # English translations
    cat > configs/locales/en.json << 'EOF'
{
  "app.title": "Cyberzilla Weather System",
  "app.tagline": "Enterprise Weather Intelligence System",
  "app.powered_by": "Powered by Cyberzilla Systems",
  "search.placeholder": "Enter city name...",
  "search.button": "Search",
  "search.my_location": "My Location",
  "language.toggle": "EN | FA",
  "loading.weather": "Loading weather data...",
  "weather.feels_like": "Feels Like",
  "weather.humidity": "Humidity",
  "weather.wind": "Wind",
  "weather.visibility": "Visibility",
  "weather.uv_index": "UV Index",
  "forecast.title": "7-Day Forecast",
  "astronomy.title": "Astronomy",
  "astronomy.sunrise": "Sunrise",
  "astronomy.sunset": "Sunset",
  "astronomy.moon_phase": "Moon Phase",
  "astronomy.moon_illumination": "Moon Illumination",
  "air_quality.title": "Air Quality",
  "prayer_times.title": "Prayer Times",
  "hunt_times.title": "Hunt Times",
  "alerts.title": "Weather Alerts",
  "ip_info.title": "IP Information",
  "errors.location_required": "Location parameter required",
  "errors.weather_not_found": "Weather data not found",
  "errors.location_not_found": "Could not get your location"
}
EOF

    # Persian translations
    cat > configs/locales/fa.json << 'EOF'
{
  "app.title": "سامانه هواشناسی سایبرزیلا",
  "app.tagline": "سامانه هوشمند هواشناسی سازمانی",
  "app.powered_by": "قدرت گرفته توسط سایبرزیلا سیستمز",
  "search.placeholder": "نام شهر را وارد کنید...",
  "search.button": "جستجو",
  "search.my_location": "موقعیت من",
  "language.toggle": "EN | فا",
  "loading.weather": "در حال بارگذاری داده‌های آب و هوا...",
  "weather.feels_like": "احساس واقعی",
  "weather.humidity": "رطوبت",
  "weather.wind": "باد",
  "weather.visibility": "دید",
  "weather.uv_index": "شاخص UV",
  "forecast.title": "پیش‌بینی ۷ روزه",
  "astronomy.title": "نجوم",
  "astronomy.sunrise": "طلوع آفتاب",
  "astronomy.sunset": "غروب آفتاب",
  "astronomy.moon_phase": "فاز ماه",
  "astronomy.moon_illumination": "روشنایی ماه",
  "air_quality.title": "کیفیت هوا",
  "prayer_times.title": "اوقات شرعی",
  "hunt_times.title": "زمان‌های شکار",
  "alerts.title": "هشدارهای آب و هوا",
  "ip_info.title": "اطلاعات IP",
  "errors.location_required": "پارامتر موقعیت الزامی است",
  "errors.weather_not_found": "داده‌های آب و هوا یافت نشد",
  "errors.location_not_found": "امکان دریافت موقعیت شما وجود ندارد"
}
EOF

    log_success "Locale files created"
}

# Create models package
create_models_package() {
    log_info "Creating models package..."
    
    # Weather models
    cat > pkg/models/weather.go << 'EOF'
package models

import "time"

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

type CurrentWeather struct {
	TempC          float64       `json:"temp_c"`
	TempF          float64       `json:"temp_f"`
	Condition      ConditionData `json:"condition"`
	WindKph        float64       `json:"wind_kph"`
	WindDir        string        `json:"wind_dir"`
	Humidity       int           `json:"humidity"`
	FeelsLikeC     float64       `json:"feelslike_c"`
	UV             float64       `json:"uv"`
	VisibilityKm   float64       `json:"vis_km"`
	PressureMb     float64       `json:"pressure_mb"`
	PrecipMm       float64       `json:"precip_mm"`
	Cloud          int           `json:"cloud"`
	LastUpdated    string        `json:"last_updated"`
	IsDay          int           `json:"is_day"`
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
	Date      string       `json:"date"`
	Day       DayData      `json:"day"`
	Astro     AstroData    `json:"astro"`
	Hour      []HourlyData `json:"hour"`
}

type DayData struct {
	MaxTempC          float64       `json:"maxtemp_c"`
	MinTempC          float64       `json:"mintemp_c"`
	AvgTempC          float64       `json:"avgtemp_c"`
	MaxWindKph        float64       `json:"maxwind_kph"`
	TotalPrecipMm     float64       `json:"totalprecip_mm"`
	Condition         ConditionData `json:"condition"`
	UV                float64       `json:"uv"`
	ChanceOfRain      int           `json:"chance_of_rain"`
	ChanceOfSnow      int           `json:"chance_of_snow"`
	DailyChanceOfRain int           `json:"daily_chance_of_rain"`
	DailyChanceOfSnow int           `json:"daily_chance_of_snow"`
}

type HourlyData struct {
	Time         string        `json:"time"`
	TempC        float64       `json:"temp_c"`
	Condition    ConditionData `json:"condition"`
	WindKph      float64       `json:"wind_kph"`
	Humidity     int           `json:"humidity"`
	Cloud        int           `json:"cloud"`
	FeelsLikeC   float64       `json:"feelslike_c"`
	ChanceOfRain int           `json:"chance_of_rain"`
	ChanceOfSnow int           `json:"chance_of_snow"`
	VisKm        float64       `json:"vis_km"`
	UV           float64       `json:"uv"`
}
EOF

    # Location models
    cat > pkg/models/location.go << 'EOF'
package models

type LocationData struct {
	Name      string  `json:"name"`
	Region    string  `json:"region"`
	Country   string  `json:"country"`
	Lat       float64 `json:"lat"`
	Lon       float64 `json:"lon"`
	TzID      string  `json:"tz_id"`
	LocalTime string  `json:"localtime"`
}
EOF

    # Astronomy models
    cat > pkg/models/astronomy.go << 'EOF'
package models

type AstronomyData struct {
	Sunrise      string  `json:"sunrise"`
	Sunset       string  `json:"sunset"`
	Moonrise     string  `json:"moonrise"`
	Moonset      string  `json:"moonset"`
	MoonPhase    string  `json:"moon_phase"`
	MoonIllum    string  `json:"moon_illumination"`
}

type AstroData struct {
	Sunrise     string `json:"sunrise"`
	Sunset      string `json:"sunset"`
	Moonrise    string `json:"moonrise"`
	Moonset     string `json:"moonset"`
	MoonPhase   string `json:"moon_phase"`
	MoonIllum   string `json:"moon_illumination"`
}
EOF

    # Air Quality models
    cat > pkg/models/air_quality.go << 'EOF'
package models

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
EOF

    # Alert models
    cat > pkg/models/alerts.go << 'EOF'
package models

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
EOF

    # Prayer Times models
    cat > pkg/models/prayer_times.go << 'EOF'
package models

type PrayerTimesData struct {
	Fajr    string `json:"fajr"`
	Sunrise string `json:"sunrise"`
	Dhuhr   string `json:"dhuhr"`
	Asr     string `json:"asr"`
	Sunset  string `json:"sunset"`
	Maghrib string `json:"maghrib"`
	Isha    string `json:"isha"`
}
EOF

    # Hunt Times models
    cat > pkg/models/hunt_times.go << 'EOF'
package models

type HuntTimesData struct {
	MorningStart string `json:"morning_start"`
	MorningEnd   string `json:"morning_end"`
	EveningStart string `json:"evening_start"`
	EveningEnd   string `json:"evening_end"`
	MoonPhase    string `json:"moon_phase"`
	Quality      string `json:"quality"`
}
EOF

    # IP Lookup models
    cat > pkg/models/ip_lookup.go << 'EOF'
package models

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
EOF

    # Response models
    cat > pkg/models/responses.go << 'EOF'
package models

import "time"

type APIResponse struct {
	Success   bool        `json:"success"`
	Data      interface{} `json:"data,omitempty"`
	Error     string      `json:"error,omitempty"`
	Message   string      `json:"message,omitempty"`
	Timestamp time.Time   `json:"timestamp"`
}

func Success(data interface{}) APIResponse {
	return APIResponse{
		Success:   true,
		Data:      data,
		Timestamp: time.Now(),
	}
}

func Error(message string) APIResponse {
	return APIResponse{
		Success:   false,
		Error:     message,
		Timestamp: time.Now(),
	}
}
EOF

    log_success "Models package created"
}

# Update main.go with i18n and models
update_main_go() {
    log_info "Updating main.go with i18n and models support..."
    
    # Create updated main.go
    cat > cmd/weather/main.go << 'EOF'
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
	"weather-app/internal/i18n"
	"weather-app/pkg/models"
)

// Configuration
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

// Agent - Custom intelligent agent for API orchestration
type Agent struct {
	config    *Config
	db        *sql.DB
	cache     *Cache
	apiClient *APIClient
	logger    *Logger
	i18n      *i18n.Bundle
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

// Initialize configuration
func LoadConfig() *Config {
	return &Config{
		Port:           getEnv("PORT", "8080"),
		APIKey:         getEnv("WEATHER_API_KEY", "f807e87175ee4ff98f551941252009"),
		EncryptionKey:  getEnv("ENCRYPTION_KEY", "cyberzilla-systems-key-32bit"),
		CacheDuration:  15 * time.Minute,
		AdminEmail:     "cyberzilla.systems@gmail.com",
		AllowedOrigins: []string{"*"},
		LocalesPath:    getEnv("LOCALES_PATH", "./configs/locales"),
		DefaultLang:    getEnv("DEFAULT_LANG", "en"),
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

// Calculate prayer times
func (a *Agent) calculatePrayerTimes(lat, lon float64, date time.Time) models.PrayerTimesData {
	sunrise := time.Date(date.Year(), date.Month(), date.Day(), 6, 0, 0, 0, date.Location())
	sunset := time.Date(date.Year(), date.Month(), date.Day(), 18, 30, 0, 0, date.Location())
	
	return models.PrayerTimesData{
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
func (a *Agent) calculateHuntTimes(astro models.AstroData) models.HuntTimesData {
	quality := "Good"
	if strings.Contains(astro.MoonPhase, "Full") {
		quality = "Fair"
	} else if strings.Contains(astro.MoonPhase, "New") {
		quality = "Excellent"
	}

	return models.HuntTimesData{
		MorningStart: astro.Sunrise,
		MorningEnd:   "10:00 AM",
		EveningStart: "4:00 PM",
		EveningEnd:   astro.Sunset,
		MoonPhase:    astro.MoonPhase,
		Quality:      quality,
	}
}

// Get comprehensive weather data
func (a *Agent) GetWeather(location string) (*models.WeatherResponse, error) {
	cacheKey := fmt.Sprintf("weather:%s", location)
	
	// Check cache
	if cached, found := a.cache.Get(cacheKey); found {
		a.logger.Log("INFO", fmt.Sprintf("Cache hit for location: %s", location))
