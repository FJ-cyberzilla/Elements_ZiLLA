package models

import "time"

// WeatherAlert represents weather alert information
type WeatherAlert struct {
	Headline    string    `json:"headline"`
	Severity    string    `json:"severity"`
	Urgency     string    `json:"urgency"`
	Areas       string    `json:"areas"`
	Category    string    `json:"category"`
	Event       string    `json:"event"`
	Effective   string    `json:"effective"`
	Expires     string    `json:"expires"`
	Description string    `json:"desc"`
	Instruction string    `json:"instruction"`
	Certainty   string    `json:"certainty"`
	Sender      string    `json:"sender"`
	SenderName  string    `json:"sender_name"`
	Onset       time.Time `json:"onset"`
	Ends        time.Time `json:"ends"`
	Response    string    `json:"response"`
	Status      string    `json:"status"`
	MsgType     string    `json:"msg_type"`
}

// AlertSeverity represents alert severity levels
type AlertSeverity string

const (
	SeverityExtreme   AlertSeverity = "Extreme"
	SeveritySevere    AlertSeverity = "Severe"
	SeverityModerate  AlertSeverity = "Moderate"
	SeverityMinor     AlertSeverity = "Minor"
	SeverityUnknown   AlertSeverity = "Unknown"
)

// AlertUrgency represents alert urgency levels
type AlertUrgency string

const (
	UrgencyImmediate AlertUrgency = "Immediate"
	UrgencyExpected  AlertUrgency = "Expected"
	UrgencyFuture    AlertUrgency = "Future"
	UrgencyPast      AlertUrgency = "Past"
	UrgencyUnknown   AlertUrgency = "Unknown"
)

// AlertCertainty represents alert certainty levels
type AlertCertainty string

const (
	CertaintyObserved    AlertCertainty = "Observed"
	CertaintyLikely      AlertCertainty = "Likely"
	CertaintyPossible    AlertCertainty = "Possible"
	CertaintyUnlikely    AlertCertainty = "Unlikely"
	CertaintyUnknown     AlertCertainty = "Unknown"
)
