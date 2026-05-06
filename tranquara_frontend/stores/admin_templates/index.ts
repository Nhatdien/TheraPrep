import { Base } from '../base';
import type { JournalTemplate, SlideGroup } from '~/types/user_journal';

export interface AdminJournalTemplate extends JournalTemplate {
  title_vi?: string;
  description_vi?: string;
  slide_groups_vi?: SlideGroup[];
}

export interface CreateUpdateTemplateRequest {
  title: string;
  title_vi?: string;
  description?: string;
  description_vi?: string;
  category: string;
  type: 'learn' | 'journal';
  slide_groups: SlideGroup[];
  slide_groups_vi?: SlideGroup[];
  is_active?: boolean;
}

export interface ImportTemplatesRequest {
  templates: CreateUpdateTemplateRequest[];
  strategy: 'skip' | 'overwrite' | 'new_ids';
}

export interface ImportTemplatesResponse {
  created: number;
  skipped: number;
  overwritten: number;
  errors: Array<{ index: number; title: string; error: string }>;
}

export class AdminTemplates extends Base {
  async adminListTemplates(): Promise<{ templates: AdminJournalTemplate[] }> {
    return this.fetch(`${this.config.base_url}/admin/templates`);
  }

  async adminGetTemplate(id: string): Promise<{ template: AdminJournalTemplate }> {
    return this.fetch(`${this.config.base_url}/admin/templates/${id}`);
  }

  async adminCreateTemplate(data: CreateUpdateTemplateRequest): Promise<{ template: AdminJournalTemplate }> {
    return this.fetch(`${this.config.base_url}/admin/templates`, {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  async adminUpdateTemplate(id: string, data: CreateUpdateTemplateRequest): Promise<{ template: AdminJournalTemplate }> {
    return this.fetch(`${this.config.base_url}/admin/templates/${id}`, {
      method: 'PUT',
      body: JSON.stringify(data),
    });
  }

  async adminDeleteTemplate(id: string): Promise<void> {
    await this.fetch(`${this.config.base_url}/admin/templates/${id}`, {
      method: 'DELETE',
    });
  }

  async adminDuplicateTemplate(id: string): Promise<{ template: AdminJournalTemplate }> {
    return this.fetch(`${this.config.base_url}/admin/templates/${id}/duplicate`, {
      method: 'POST',
    });
  }

  async adminToggleActive(id: string): Promise<{ template: AdminJournalTemplate }> {
    return this.fetch(`${this.config.base_url}/admin/templates/${id}/toggle-active`, {
      method: 'PATCH',
    });
  }

  async adminExportTemplates(): Promise<{ templates: AdminJournalTemplate[] }> {
    return this.fetch(`${this.config.base_url}/admin/templates-export`);
  }

  async adminImportTemplates(data: ImportTemplatesRequest): Promise<ImportTemplatesResponse> {
    return this.fetch(`${this.config.base_url}/admin/templates-import`, {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }
}
