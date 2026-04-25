import { Base } from '../base';
import type { SlideGroup } from '~/types/user_journal';

export interface CustomTemplate {
  id: string;
  user_id: string;
  title: string;
  slide_groups: SlideGroup[];
  created_at: string;
  updated_at: string;
}

export interface UpsertCustomTemplateRequest {
  title: string;
  slide_groups: SlideGroup[];
}

export class UserCustomTemplate extends Base {
  async getCustomTemplate(): Promise<CustomTemplate | null> {
    try {
      const res = await this.fetch(`${this.config.base_url}/custom-template`);
      return res.custom_template ?? null;
    } catch (e: any) {
      if (e?.status === 404 || e?.statusCode === 404) return null;
      throw e;
    }
  }

  async upsertCustomTemplate(data: UpsertCustomTemplateRequest): Promise<CustomTemplate> {
    const res = await this.fetch(`${this.config.base_url}/custom-template`, {
      method: 'PUT',
      body: JSON.stringify(data),
    });
    return res.custom_template;
  }
}
