package main

import (
	"encoding/json"
	"errors"
	"net/http"

	"github.com/google/uuid"
	"github.com/julienschmidt/httprouter"
	"tranquara.net/internal/data"
)

// adminListTemplates returns all templates (including inactive) for the admin panel.
func (app *application) adminListTemplates(w http.ResponseWriter, r *http.Request) {
	templates, err := app.models.UserJournal.GetAllTemplatesAdmin()
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	err = app.writeJson(w, http.StatusOK, envolope{"templates": templates}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

// adminGetTemplate returns a single template by ID.
func (app *application) adminGetTemplate(w http.ResponseWriter, r *http.Request) {
	params := httprouter.ParamsFromContext(r.Context())
	idStr := params.ByName("id")

	id, err := uuid.Parse(idStr)
	if err != nil {
		app.badRequestResponse(w, r, errors.New("invalid template ID"))
		return
	}

	template, err := app.models.UserJournal.GetTemplateByID(id)
	if err != nil {
		if errors.Is(err, data.ErrRecordNotFound) {
			app.notFoundRespond(w, r)
			return
		}
		app.serverErrorResponse(w, r, err)
		return
	}

	err = app.writeJson(w, http.StatusOK, envolope{"template": template}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

// adminCreateTemplate creates a new journal template.
func (app *application) adminCreateTemplate(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Title         string          `json:"title"`
		TitleVi       *string         `json:"title_vi"`
		Description   *string         `json:"description"`
		DescriptionVi *string         `json:"description_vi"`
		Category      string          `json:"category"`
		Type          string          `json:"type"`
		SlideGroups   json.RawMessage `json:"slide_groups"`
		SlideGroupsVi json.RawMessage `json:"slide_groups_vi"`
		IsActive      *bool           `json:"is_active"`
	}

	err := app.readJson(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	// Validate required fields
	if input.Title == "" {
		app.errorResponse(w, r, http.StatusUnprocessableEntity, "title is required")
		return
	}
	if input.Type != "learn" && input.Type != "journal" {
		app.errorResponse(w, r, http.StatusUnprocessableEntity, "type must be 'learn' or 'journal'")
		return
	}
	if input.Category == "" {
		app.errorResponse(w, r, http.StatusUnprocessableEntity, "category is required")
		return
	}
	if len(input.SlideGroups) == 0 || string(input.SlideGroups) == "null" {
		app.errorResponse(w, r, http.StatusUnprocessableEntity, "slide_groups is required")
		return
	}

	isActive := true
	if input.IsActive != nil {
		isActive = *input.IsActive
	}

	template := &data.JournalTemplate{
		Title:         input.Title,
		TitleVi:       input.TitleVi,
		Description:   input.Description,
		DescriptionVi: input.DescriptionVi,
		Category:      input.Category,
		Type:          input.Type,
		SlideGroups:   input.SlideGroups,
		SlideGroupsVi: input.SlideGroupsVi,
		IsActive:      isActive,
	}

	result, err := app.models.UserJournal.InsertTemplate(template)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	err = app.writeJson(w, http.StatusCreated, envolope{"template": result}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

// adminUpdateTemplate updates an existing journal template.
func (app *application) adminUpdateTemplate(w http.ResponseWriter, r *http.Request) {
	params := httprouter.ParamsFromContext(r.Context())
	idStr := params.ByName("id")

	id, err := uuid.Parse(idStr)
	if err != nil {
		app.badRequestResponse(w, r, errors.New("invalid template ID"))
		return
	}

	var input struct {
		Title         string          `json:"title"`
		TitleVi       *string         `json:"title_vi"`
		Description   *string         `json:"description"`
		DescriptionVi *string         `json:"description_vi"`
		Category      string          `json:"category"`
		Type          string          `json:"type"`
		SlideGroups   json.RawMessage `json:"slide_groups"`
		SlideGroupsVi json.RawMessage `json:"slide_groups_vi"`
		IsActive      bool            `json:"is_active"`
	}

	err = app.readJson(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	// Validate required fields
	if input.Title == "" {
		app.errorResponse(w, r, http.StatusUnprocessableEntity, "title is required")
		return
	}
	if input.Type != "learn" && input.Type != "journal" {
		app.errorResponse(w, r, http.StatusUnprocessableEntity, "type must be 'learn' or 'journal'")
		return
	}
	if input.Category == "" {
		app.errorResponse(w, r, http.StatusUnprocessableEntity, "category is required")
		return
	}

	template := &data.JournalTemplate{
		ID:            id,
		Title:         input.Title,
		TitleVi:       input.TitleVi,
		Description:   input.Description,
		DescriptionVi: input.DescriptionVi,
		Category:      input.Category,
		Type:          input.Type,
		SlideGroups:   input.SlideGroups,
		SlideGroupsVi: input.SlideGroupsVi,
		IsActive:      input.IsActive,
	}

	result, err := app.models.UserJournal.UpdateTemplate(template)
	if err != nil {
		if errors.Is(err, data.ErrRecordNotFound) {
			app.notFoundRespond(w, r)
			return
		}
		app.serverErrorResponse(w, r, err)
		return
	}

	err = app.writeJson(w, http.StatusOK, envolope{"template": result}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

// adminDeleteTemplate permanently deletes a template.
func (app *application) adminDeleteTemplate(w http.ResponseWriter, r *http.Request) {
	params := httprouter.ParamsFromContext(r.Context())
	idStr := params.ByName("id")

	id, err := uuid.Parse(idStr)
	if err != nil {
		app.badRequestResponse(w, r, errors.New("invalid template ID"))
		return
	}

	err = app.models.UserJournal.DeleteTemplate(id)
	if err != nil {
		if errors.Is(err, data.ErrRecordNotFound) {
			app.notFoundRespond(w, r)
			return
		}
		app.serverErrorResponse(w, r, err)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

// adminDuplicateTemplate clones a template with "(Copy)" suffix.
func (app *application) adminDuplicateTemplate(w http.ResponseWriter, r *http.Request) {
	params := httprouter.ParamsFromContext(r.Context())
	idStr := params.ByName("id")

	id, err := uuid.Parse(idStr)
	if err != nil {
		app.badRequestResponse(w, r, errors.New("invalid template ID"))
		return
	}

	result, err := app.models.UserJournal.DuplicateTemplate(id)
	if err != nil {
		if errors.Is(err, data.ErrRecordNotFound) {
			app.notFoundRespond(w, r)
			return
		}
		app.serverErrorResponse(w, r, err)
		return
	}

	err = app.writeJson(w, http.StatusCreated, envolope{"template": result}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

// adminToggleActiveTemplate flips the is_active status.
func (app *application) adminToggleActiveTemplate(w http.ResponseWriter, r *http.Request) {
	params := httprouter.ParamsFromContext(r.Context())
	idStr := params.ByName("id")

	id, err := uuid.Parse(idStr)
	if err != nil {
		app.badRequestResponse(w, r, errors.New("invalid template ID"))
		return
	}

	result, err := app.models.UserJournal.ToggleActiveTemplate(id)
	if err != nil {
		if errors.Is(err, data.ErrRecordNotFound) {
			app.notFoundRespond(w, r)
			return
		}
		app.serverErrorResponse(w, r, err)
		return
	}

	err = app.writeJson(w, http.StatusOK, envolope{"template": result}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

// adminExportTemplates returns all templates as a JSON array for export.
func (app *application) adminExportTemplates(w http.ResponseWriter, r *http.Request) {
	templates, err := app.models.UserJournal.GetAllTemplatesAdmin()
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	w.Header().Set("Content-Disposition", "attachment; filename=collections-export.json")
	err = app.writeJson(w, http.StatusOK, envolope{"templates": templates}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

// adminImportTemplates bulk imports templates from JSON.
func (app *application) adminImportTemplates(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Templates []struct {
			ID            *string         `json:"id"`
			Title         string          `json:"title"`
			TitleVi       *string         `json:"title_vi"`
			Description   *string         `json:"description"`
			DescriptionVi *string         `json:"description_vi"`
			Category      string          `json:"category"`
			Type          string          `json:"type"`
			SlideGroups   json.RawMessage `json:"slide_groups"`
			SlideGroupsVi json.RawMessage `json:"slide_groups_vi"`
			IsActive      *bool           `json:"is_active"`
		} `json:"templates"`
		Strategy string `json:"strategy"` // "skip", "overwrite", "new_ids"
	}

	err := app.readJson(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	if len(input.Templates) == 0 {
		app.errorResponse(w, r, http.StatusUnprocessableEntity, "templates array is required and must not be empty")
		return
	}

	strategy := input.Strategy
	if strategy == "" {
		strategy = "new_ids"
	}

	created := 0
	skipped := 0
	overwritten := 0
	importErrors := []map[string]interface{}{}

	for i, tmpl := range input.Templates {
		// Validate
		if tmpl.Title == "" || tmpl.Category == "" || (tmpl.Type != "learn" && tmpl.Type != "journal") {
			importErrors = append(importErrors, map[string]interface{}{
				"index": i,
				"title": tmpl.Title,
				"error": "missing required fields (title, category, type)",
			})
			continue
		}

		isActive := true
		if tmpl.IsActive != nil {
			isActive = *tmpl.IsActive
		}

		// Check if template with same ID exists
		var existingID *uuid.UUID
		if tmpl.ID != nil && *tmpl.ID != "" {
			parsed, parseErr := uuid.Parse(*tmpl.ID)
			if parseErr == nil {
				_, getErr := app.models.UserJournal.GetTemplateByID(parsed)
				if getErr == nil {
					existingID = &parsed
				}
			}
		}

		switch strategy {
		case "skip":
			if existingID != nil {
				skipped++
				continue
			}
		case "overwrite":
			if existingID != nil {
				t := &data.JournalTemplate{
					ID:            *existingID,
					Title:         tmpl.Title,
					TitleVi:       tmpl.TitleVi,
					Description:   tmpl.Description,
					DescriptionVi: tmpl.DescriptionVi,
					Category:      tmpl.Category,
					Type:          tmpl.Type,
					SlideGroups:   tmpl.SlideGroups,
					SlideGroupsVi: tmpl.SlideGroupsVi,
					IsActive:      isActive,
				}
				_, updateErr := app.models.UserJournal.UpdateTemplate(t)
				if updateErr != nil {
					importErrors = append(importErrors, map[string]interface{}{
						"index": i,
						"title": tmpl.Title,
						"error": updateErr.Error(),
					})
				} else {
					overwritten++
				}
				continue
			}
		}

		// Insert as new (new_ids or no existing match)
		t := &data.JournalTemplate{
			Title:         tmpl.Title,
			TitleVi:       tmpl.TitleVi,
			Description:   tmpl.Description,
			DescriptionVi: tmpl.DescriptionVi,
			Category:      tmpl.Category,
			Type:          tmpl.Type,
			SlideGroups:   tmpl.SlideGroups,
			SlideGroupsVi: tmpl.SlideGroupsVi,
			IsActive:      isActive,
		}

		_, insertErr := app.models.UserJournal.InsertTemplate(t)
		if insertErr != nil {
			importErrors = append(importErrors, map[string]interface{}{
				"index": i,
				"title": tmpl.Title,
				"error": insertErr.Error(),
			})
		} else {
			created++
		}
	}

	err = app.writeJson(w, http.StatusOK, envolope{
		"created":     created,
		"skipped":     skipped,
		"overwritten": overwritten,
		"errors":      importErrors,
	}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}
