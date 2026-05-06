import { Base } from "../base";
import AuthService from "./auth_service";
import type { LoginCredentials, UserProfile } from "~/types/auth";

export class Auth extends Base {

  login(credentials: LoginCredentials): Promise<boolean> {
    return AuthService.login(credentials);
  }

  register(email: string, username: string, password: string): Promise<boolean> {
    return AuthService.register(email, username, password);
  }

  loadTokens(): Promise<boolean> {
    return AuthService.loadTokens();
  }

  getAccessToken(): Promise<string | null> {
    return AuthService.getAccessToken();
  }

  refreshAccessToken(): Promise<boolean> {
    return AuthService.refreshAccessToken();
  }

  getUserProfile(): UserProfile | null {
    return AuthService.getUserProfile();
  }

  getPersistedProfile(): Promise<UserProfile | null> {
    return AuthService.getPersistedProfile();
  }

  hasValidToken(): boolean {
    return AuthService.hasValidToken();
  }

  hasLocalSession(): Promise<boolean> {
    return AuthService.hasLocalSession();
  }

  logout(): Promise<void> {
    return AuthService.logout();
  };

  clearTokens(): Promise<void> {
    return AuthService.clearTokens();
  }

  getGoogleOAuthStartURL(redirectUri: string): Promise<string> {
    return AuthService.getGoogleOAuthStartURL(redirectUri);
  }

  async exchangeGoogleOAuthCode(code: string, redirectUri: string): Promise<boolean> {
    const result = await AuthService.exchangeGoogleOAuthCode(code, redirectUri);
    if (result) {
      // Propagate the newly stored token into the SDK config so subsequent
      // calls (e.g. syncUserToBackend) can use it immediately.
      const token = await AuthService.getAccessToken();
      if (token && this.config) {
        this.config.access_token = token;
      }
    }
    return result;
  }

  async syncUserToBackend(userData: {
    email: string;
    username: string;
    oauth_provider: string;
  }): Promise<void> {
    const baseUrl = this.config?.base_url || '';
    // Prefer a fresh token from AuthService (covers Google OAuth where the
    // token may not yet have been propagated to config.access_token).
    const accessToken = await AuthService.getAccessToken() || this.config?.access_token || '';

    const response = await fetch(`${baseUrl}/users/sync`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: accessToken ? `Bearer ${accessToken}` : '',
      },
      body: JSON.stringify(userData),
    });

    if (!response.ok) {
      throw new Error(`Sync failed: ${response.status} ${response.statusText}`);
    }
  }

  requestPasswordReset(email: string): Promise<boolean> {
    return AuthService.requestPasswordReset(email);
  }

  resetPassword(token: string, newPassword: string, confirmPassword: string): Promise<boolean> {
    return AuthService.resetPassword(token, newPassword, confirmPassword);
  }
}
