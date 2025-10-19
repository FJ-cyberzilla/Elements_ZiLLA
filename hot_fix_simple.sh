#!/bin/bash

set -e

echo "🌦️ Cyberzilla Weather System Hotfix"
echo "===================================="

# Create directories
mkdir -p internal/i18n
mkdir -p configs/locales

# Create i18n package
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

# Create locale files
cat > configs/locales/en.json << 'EOF'
{
  "app.title": "Cyberzilla Weather System",
  "app.tagline": "Enterprise Weather Intelligence System",
  "search.placeholder": "Enter city name...",
  "search.button": "Search",
  "search.my_location": "My Location",
  "language.toggle": "EN | FA",
  "loading.weather": "Loading weather data..."
}
EOF

cat > configs/locales/fa.json << 'EOF'
{
  "app.title": "سامانه هواشناسی سایبرزیلا",
  "app.tagline": "سامانه هوشمند هواشناسی سازمانی",
  "search.placeholder": "نام شهر را وارد کنید...",
  "search.button": "جستجو",
  "search.my_location": "موقعیت من",
  "language.toggle": "EN | فا",
  "loading.weather": "در حال بارگذاری داده‌های آب و هوا..."
}
EOF

echo "✅ Hotfix applied successfully!"
echo "📁 Created: internal/i18n/i18n.go"
echo "📁 Created: configs/locales/en.json"
echo "📁 Created: configs/locales/fa.json"
