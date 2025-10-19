package models

import "time"

// Config represents application configuration
type Config struct {
	Server   ServerConfig   `json:"server"`
	Weather  WeatherConfig  `json:"weather"`
	Cache    CacheConfig    `json:"cache"`
	Database DatabaseConfig `json:"database"`
	Features FeatureConfig  `json:"features"`
	Security SecurityConfig `json:"security"`
}

// ServerConfig represents server configuration
type ServerConfig struct {
	Port           string   `json:"port"`
	Host           string   `json:"host"`
	AllowedOrigins []string `json:"allowed_origins"`
	ReadTimeout    time.Duration `json:"read_timeout"`
	WriteTimeout   time.Duration `json:"write_timeout"`
	IdleTimeout    time.Duration `json:"idle_timeout"`
	Env            string   `json:"env"`
}

// WeatherConfig represents weather API configuration
type WeatherConfig struct {
	APIKey        string        `json:"api_key"`
	BaseURL       string        `json:"base_url"`
	Timeout       time.Duration `json:"timeout"`
	RetryCount    int           `json:"retry_count"`
	RetryDelay    time.Duration `json:"retry_delay"`
	CacheDuration time.Duration `json:"cache_duration"`
}

// CacheConfig represents cache configuration
type CacheConfig struct {
	Enabled        bool          `json:"enabled"`
	Duration       time.Duration `json:"duration"`
	CleanupInterval time.Duration `json:"cleanup_interval"`
	MaxEntries     int           `json:"max_entries"`
}

// DatabaseConfig represents database configuration
type DatabaseConfig struct {
	Driver   string `json:"driver"`
	DSN      string `json:"dsn"`
	MaxConns int    `json:"max_conns"`
	MaxIdle  int    `json:"max_idle"`
}

// FeatureConfig represents feature flags
type FeatureConfig struct {
	PrayerTimes   bool `json:"prayer_times"`
	HuntTimes     bool `json:"hunt_times"`
	AirQuality    bool `json:"air_quality"`
	Alerts        bool `json:"alerts"`
	Astronomy     bool `json:"astronomy"`
	IPLookup      bool `json:"ip_lookup"`
	Notifications bool `json:"notifications"`
}

// SecurityConfig represents security configuration
type SecurityConfig struct {
	EncryptionKey string        `json:"encryption_key"`
	JWTSecret     string        `json:"jwt_secret"`
	JWTExpiry     time.Duration `json:"jwt_expiry"`
	CORS          CORSConfig    `json:"cors"`
}

// CORSConfig represents CORS configuration
type CORSConfig struct {
	Enabled          bool     `json:"enabled"`
	AllowedOrigins   []string `json:"allowed_origins"`
	AllowedMethods   []string `json:"allowed_methods"`
	AllowedHeaders   []string `json:"allowed_headers"`
	AllowCredentials bool     `json:"allow_credentials"`
	MaxAge           int      `json:"max_age"`
}
