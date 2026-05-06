import { defineStore } from 'pinia';
import TranquaraSDK from '../tranquara_sdk';
import type { AdminJournalTemplate, CreateUpdateTemplateRequest, ImportTemplatesRequest, ImportTemplatesResponse } from '../admin_templates';

interface AdminState {
  templates: AdminJournalTemplate[];
  currentTemplate: AdminJournalTemplate | null;
  isLoading: boolean;
  filters: {
    type: string;
    category: string;
    status: string;
    search: string;
  };
}

export const useAdminStore = defineStore('admin', {
  state: (): AdminState => ({
    templates: [],
    currentTemplate: null,
    isLoading: false,
    filters: {
      type: '__all__',
      category: '__all__',
      status: '__all__',
      search: '',
    },
  }),

  getters: {
    filteredTemplates(state): AdminJournalTemplate[] {
      let result = state.templates;

      if (state.filters.type && state.filters.type !== '__all__') {
        result = result.filter(t => t.type === state.filters.type);
      }
      if (state.filters.category && state.filters.category !== '__all__') {
        result = result.filter(t => t.category === state.filters.category);
      }
      if (state.filters.status === 'active') {
        result = result.filter(t => t.is_active);
      } else if (state.filters.status === 'inactive') {
        result = result.filter(t => !t.is_active);
      }
      if (state.filters.search) {
        const q = state.filters.search.toLowerCase();
        result = result.filter(t => t.title.toLowerCase().includes(q));
      }

      return result;
    },

    categories(state): string[] {
      const cats = new Set(state.templates.map(t => t.category));
      return Array.from(cats).sort();
    },

    stats(state) {
      const total = state.templates.length;
      const active = state.templates.filter(t => t.is_active).length;
      const inactive = total - active;
      const learn = state.templates.filter(t => t.type === 'learn').length;
      const journal = state.templates.filter(t => t.type === 'journal').length;
      return { total, active, inactive, learn, journal };
    },
  },

  actions: {
    async loadTemplates() {
      this.isLoading = true;
      try {
        const sdk = TranquaraSDK.getInstance();
        const res = await sdk.adminListTemplates();
        this.templates = res.templates || [];
      } finally {
        this.isLoading = false;
      }
    },

    async loadTemplate(id: string) {
      this.isLoading = true;
      try {
        const sdk = TranquaraSDK.getInstance();
        const res = await sdk.adminGetTemplate(id);
        this.currentTemplate = res.template;
        return res.template;
      } finally {
        this.isLoading = false;
      }
    },

    async createTemplate(data: CreateUpdateTemplateRequest) {
      const sdk = TranquaraSDK.getInstance();
      const res = await sdk.adminCreateTemplate(data);
      this.templates.unshift(res.template);
      return res.template;
    },

    async updateTemplate(id: string, data: CreateUpdateTemplateRequest) {
      const sdk = TranquaraSDK.getInstance();
      const res = await sdk.adminUpdateTemplate(id, data);
      const idx = this.templates.findIndex(t => t.id === id);
      if (idx !== -1) this.templates[idx] = res.template;
      this.currentTemplate = res.template;
      return res.template;
    },

    async deleteTemplate(id: string) {
      const sdk = TranquaraSDK.getInstance();
      await sdk.adminDeleteTemplate(id);
      this.templates = this.templates.filter(t => t.id !== id);
    },

    async duplicateTemplate(id: string) {
      const sdk = TranquaraSDK.getInstance();
      const res = await sdk.adminDuplicateTemplate(id);
      this.templates.unshift(res.template);
      return res.template;
    },

    async toggleActive(id: string) {
      const sdk = TranquaraSDK.getInstance();
      const res = await sdk.adminToggleActive(id);
      const idx = this.templates.findIndex(t => t.id === id);
      if (idx !== -1) this.templates[idx] = res.template;
      return res.template;
    },

    async exportTemplates() {
      const sdk = TranquaraSDK.getInstance();
      return sdk.adminExportTemplates();
    },

    async importTemplates(data: ImportTemplatesRequest): Promise<ImportTemplatesResponse> {
      const sdk = TranquaraSDK.getInstance();
      const res = await sdk.adminImportTemplates(data);
      // Reload to get fresh data
      await this.loadTemplates();
      return res;
    },
  },
});
