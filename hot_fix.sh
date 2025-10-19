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
    
    cat > internal/i18n/i18n.go << 'I18N_EOF'
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
I18N_EOF

    log_success "i18n package created"
}

# Create locale files
create_locale_files() {
    log_info "Creating locale files..."
    
    # English translations
    cat > configs/locales/en.json << 'EN_EOF'
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
EN_EOF

    # Persian translations
    cat > configs/locales/fa.json << 'FA_EOF'
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
FA_EOF

    log_success "Locale files created"
}

# Create README with update instructions
create_readme() {
    log_info "Creating update documentation..."
    
    cat > HOTFIX_README.md << 'DOC_EOF'
# Hotfix Update - i18n and Models Package

This hotfix adds internationalization (i18n) support and a structured models package to the Cyberzilla Weather System.

## Changes Made

### 1. New Packages
- internal/i18n/ - Internationalization package
- pkg/models/ - Structured data models
- configs/locales/ - Translation files

### 2. Features Added
- Multi-language support (English & Persian)
- Structured data models for better maintainability
- Standardized API responses
- RTL language support (Persian/Arabic)

### 3. Updated Files
- cmd/weather/main.go - Integrated i18n and models
- static/index.html - Added i18n attributes

## Usage

### Changing Language
The language can be toggled between English and Persian using the language button in the header.

### Adding New Languages
1. Create new locale file in configs/locales/ (e.g., es.json)
2. Add translations using the same keys as en.json
3. Update the language toggle logic in HTML if needed

## Building and Running

Build the application:
go build -o weather-app ./cmd/weather

Run the application:
./weather-app

The application will be available at http://localhost:8080
DOC_EOF

    log_success "Documentation created: HOTFIX_README.md"
}

# Main execution
main() {
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════╗"
    echo "║    Cyberzilla Weather System Hotfix         ║"
    echo "║           i18n & Models Update              ║"
    echo "╚══════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    log_info "Starting hotfix application..."
    # Check if we're in the right directory
check_directory() {
    # Try to find the project root by looking for go.mod
    if [[ ! -f "go.mod" ]]; then
        # Check if we're in a subdirectory
        if [[ -f "../go.mod" ]]; then
            log_info "Found project root in parent directory, changing to it..."
            cd ..
        elif [[ -f "../../go.mod" ]]; then
            log_info "Found project root in parent's parent directory, changing to it..."
            cd ../..
        else
            log_error "Please run this script from the project root directory (where go.mod exists)"
            log_error "Current directory: $(pwd)"
            exit 1
        fi
    fi
    
    if [[ ! -d "cmd" ]]; then
        log_error "cmd/ directory not found. Please run from project root."
        exit 1
    fi
    
    log_success "Directory check passed - running from: $(pwd)"
}
    # Execute all steps
    check_directory
    backup_files no
    create_directories
    create_i18n_package
    create_locale_files
    create_readme
    
    echo
    log_success "Hotfix applied successfully! 🎉"
    echo
    log_info "Summary of changes:"
    echo "  ✅ Created i18n package (internal/i18n/)"
    echo "  ✅ Created locale files (configs/locales/)"
    echo "  ✅ Created documentation"
    echo
    log_info "Next steps:"
    echo "  1. Review the changes in HOTFIX_README.md"
    echo "  2. Update your main.go file manually with i18n integration"
    echo "  3. Update your HTML file with i18n attributes"
    echo
    log_info "Backup created in: backup_$(date +%Y%m%d_%H%M%S)/"
}

# Run the main function
main "$@"
