package main

import (
	"net/http"

	"tranquara.net/internal/data"
)

// ExportUserData godoc
// GET /v1/data/export
// Returns all user data as a JSON export file
func (app *application) exportUserDataHandler(w http.ResponseWriter, r *http.Request) {
	userID, err := app.GetUserUUIDFromContext(r.Context())
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	// Get username from JWT claims
	claims := app.GetUserFromContext(r.Context())
	username := ""
	if claims != nil {
		if preferred, ok := claims["preferred_username"].(string); ok {
			username = preferred
		}
	}

	exportFile, err := app.models.DataExport.ExportAll(userID, username)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	// Set headers for file download
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Content-Disposition", "attachment; filename=tranquara_export.json")
	err = app.writeJson(w, http.StatusOK, exportFile, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

// ImportUserData godoc
// POST /v1/data/import
// Imports user data from a Tranquara export JSON file
func (app *application) importUserDataHandler(w http.ResponseWriter, r *http.Request) {
	userID, err := app.GetUserUUIDFromContext(r.Context())
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	// Read the import file from request body
	var importFile data.ExportFile
	err = app.readJson(w, r, &importFile)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	// Validate the import file
	err = data.ValidateExportFile(&importFile)
	if err != nil {
		app.errorResponse(w, r, http.StatusBadRequest, err.Error())
		return
	}

	// Perform the import
	result, err := app.models.DataImport.ImportAll(userID, &importFile)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	err = app.writeJson(w, http.StatusOK, envolope{
		"message": "Import completed",
		"result":  result,
	}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}