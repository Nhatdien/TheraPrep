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

  exchangeGoogleOAuthCode(code: string, redirectUri: string): Promise<boolean> {
    return AuthService.exchangeGoogleOAuthCode(code, redirectUri);
  }

  requestPasswordReset(email: string): Promise<boolean> {
    return AuthService.requestPasswordReset(email);
  }

  resetPassword(token: string, newPassword: string, confirmPassword: string): Promise<boolean> {
    return AuthService.resetPassword(token, newPassword, confirmPassword);
  }
}
