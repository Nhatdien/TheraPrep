import { Base } from "../base";

export class UserInformation extends Base {

  /**
   * Update user information including settings.
   * Used to sync language preference and other settings to backend.
   */
  async updateUserInformation(data: {
    name?: string;
    age_range?: string;
    gender?: string;
    settings?: Record<string, any>;
  }): Promise<{ user_info: any }> {
    const response = await this.fetch<{ user_info: any }>(
      `${this.config.base_url}/user_information`,
      {
        method: "PUT",
        body: JSON.stringify(data),
      }
    );
    return response;
  }

  /**
   * Get current user information from backend.
   */
  async getUserInformation(): Promise<{ user_info: any }> {
    const response = await this.fetch<{ user_info: any }>(
      `${this.config.base_url}/user_information`,
      {
        method: "GET",
      }
    );
    return response;
  }
}
