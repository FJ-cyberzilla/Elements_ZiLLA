package models

// IPLookupResponse represents IP geolocation information
type IPLookupResponse struct {
	IP          string  `json:"ip"`
	Type        string  `json:"type"`
	City        string  `json:"city"`
	Region      string  `json:"region"`
	RegionCode  string  `json:"region_code"`
	Country     string  `json:"country"`
	CountryName string  `json:"country_name"`
	CountryCode string  `json:"country_code"`
	Continent   string  `json:"continent"`
	ContinentCode string `json:"continent_code"`
	Lat         float64 `json:"lat"`
	Lon         float64 `json:"lon"`
	Timezone    string  `json:"timezone"`
	UtcOffset   string  `json:"utc_offset"`
	PostalCode  string  `json:"postal_code"`
	CallingCode string  `json:"calling_code"`
	Currency    string  `json:"currency"`
	Languages   []string `json:"languages"`
	ASN         string  `json:"asn"`
	Org         string  `json:"org"`
	ISP         string  `json:"isp"`
	Proxy       bool    `json:"proxy"`
	Hosting     bool    `json:"hosting"`
}

// IPType represents IP address types
type IPType string

const (
	IPv4      IPType = "IPv4"
	IPv6      IPType = "IPv6"
	IPPrivate IPType = "Private"
)
