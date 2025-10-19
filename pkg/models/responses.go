package models

import (
	"net/http"
	"time"
)

// APIResponse represents standard API response format
type APIResponse struct {
	Success   bool        `json:"success"`
	Data      interface{} `json:"data,omitempty"`
	Error     string      `json:"error,omitempty"`
	Message   string      `json:"message,omitempty"`
	Timestamp time.Time   `json:"timestamp"`
	RequestID string      `json:"request_id,omitempty"`
}

// PaginatedResponse represents paginated API response
type PaginatedResponse struct {
	Data       interface{} `json:"data"`
	Page       int         `json:"page"`
	PageSize   int         `json:"page_size"`
	TotalPages int         `json:"total_pages"`
	TotalCount int         `json:"total_count"`
	HasNext    bool        `json:"has_next"`
	HasPrev    bool        `json:"has_prev"`
}

// ErrorResponse represents error response
type ErrorResponse struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
	Details string `json:"details,omitempty"`
}

// HealthResponse represents health check response
type HealthResponse struct {
	Status    string            `json:"status"`
	Version   string            `json:"version"`
	Timestamp time.Time         `json:"timestamp"`
	Services  map[string]string `json:"services"`
	Uptime    string            `json:"uptime"`
}

// Success creates a successful API response
func Success(data interface{}) APIResponse {
	return APIResponse{
		Success:   true,
		Data:      data,
		Timestamp: time.Now(),
	}
}

// Error creates an error API response
func Error(message string) APIResponse {
	return APIResponse{
		Success:   false,
		Error:     message,
		Timestamp: time.Now(),
	}
}

// ValidationError creates a validation error response
func ValidationError(details string) APIResponse {
	return APIResponse{
		Success:   false,
		Error:     "Validation failed",
		Message:   details,
		Timestamp: time.Now(),
	}
}

// NewPaginatedResponse creates a new paginated response
func NewPaginatedResponse(data interface{}, page, pageSize, total int) PaginatedResponse {
	totalPages := (total + pageSize - 1) / pageSize
	return PaginatedResponse{
		Data:       data,
		Page:       page,
		PageSize:   pageSize,
		TotalPages: totalPages,
		TotalCount: total,
		HasNext:    page < totalPages,
		HasPrev:    page > 1,
	}
}

// Common error responses
var (
	ErrInvalidRequest = ErrorResponse{
		Code:    http.StatusBadRequest,
		Message: "Invalid request",
	}
	
	ErrNotFound = ErrorResponse{
		Code:    http.StatusNotFound,
		Message: "Resource not found",
	}
	
	ErrInternalServer = ErrorResponse{
		Code:    http.StatusInternalServerError,
		Message: "Internal server error",
	}
	
	ErrUnauthorized = ErrorResponse{
		Code:    http.StatusUnauthorized,
		Message: "Unauthorized access",
	}
	
	ErrRateLimited = ErrorResponse{
		Code:    http.StatusTooManyRequests,
		Message: "Rate limit exceeded",
	}
)
