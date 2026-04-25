package main

import (
	"encoding/json"
	"errors"
	"net/http"

	"tranquara.net/internal/data"
)

// getCustomTemplateHandler returns the authenticated user's custom template.
// GET /v1/custom-template
// Returns 404 if the user has not created one yet.
func (app *application) getCustomTemplateHandler(w http.ResponseWriter, r *http.Request) {
	userID, err := app.GetUserUUIDFromContext(r.Context())
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	template, err := app.models.UserCustomTemplate.GetByUserId(userID)
	if err != nil {
		if errors.Is(err, data.ErrRecordNotFound) {
			app.writeJson(w, http.StatusNotFound, envolope{"custom_template": nil}, nil)
			return
		}
		app.serverErrorResponse(w, r, err)
		return
	}

	err = app.writeJson(w, http.StatusOK, envolope{"custom_template": template}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

// upsertCustomTemplateHandler creates or replaces the user's custom template.
// PUT /v1/custom-template
func (app *application) upsertCustomTemplateHandler(w http.ResponseWriter, r *http.Request) {
	userID, err := app.GetUserUUIDFromContext(r.Context())
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	var input struct {
		Title       string          `json:"title"`
		SlideGroups json.RawMessage `json:"slide_groups"`
	}

	err = app.readJson(w, r, &input)
	if err != nil {
		app.errorResponse(w, r, http.StatusBadRequest, err.Error())
		return
	}

	if input.Title == "" {
		input.Title = "My Daily Template"
	}

	if input.SlideGroups == nil {
		input.SlideGroups = json.RawMessage("[]")
	}

	template, err := app.models.UserCustomTemplate.Upsert(userID, input.Title, input.SlideGroups)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	err = app.writeJson(w, http.StatusOK, envolope{"custom_template": template}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}
