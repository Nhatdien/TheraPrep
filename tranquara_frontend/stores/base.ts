export type Config = {
  base_url: string;
  base_frontend_url?: string;
  current_username?: string;
  websocket_url?: string;
  access_token?: string;
  client_id?: string;
  keycloakURL?: string; // Add Keycloak URL to config
  locale?: string; // Current app locale for Accept-Language header
};

const readResponseBody = async (response: Response) => {
  const contentType = response.headers.get("content-type");
  if (contentType && contentType.includes("application/json")) {
    return response.json();
  } else {
    return response.text();
  }
};

const checkJsonRes = (data: string) => {
  const jsonRegex = /((\[[^\}]{3,})?\{s*[^\}\{]{3,}?:.*\}([^\{]+\])?)/;
  return jsonRegex.test(
    data
      .replace(/\\["\\\/bfnrtu]/g, "@")
      .replace(
        /"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g,
        "]"
      )
      .replace(/(?:^|:|,)(?:\s*\[)+/g, "")
  );
};

const createNotify = (response: Response) => {
  readResponseBody(response).then((data) => {
    if (typeof data === "string" && checkJsonRes(data)) {
      const parsedData = JSON.parse(data);
      const errorMessage =
        parsedData?.detail || parsedData?.message || parsedData?.errorMessage;

    } else if (typeof data === "object") {

      const errorMessage = data?.detail || data?.message || data?.errorMessage || JSON.stringify(data);
    } else {
    }
  });
};

export abstract class Base {
  public loading: boolean = false;

  public error: string = "";

  public config: Config = {
    base_url: "",
    current_username: "",
    base_frontend_url: "",
    websocket_url: "",
    access_token: "",
    client_id: "",
  };

  constructor(config: Config) {
    // Ensure config is always properly set with defaults
    this.config = {
      base_url: config?.base_url || "",
      current_username: config?.current_username || "",
      base_frontend_url: config?.base_frontend_url || "",
      websocket_url: config?.websocket_url || "",
      access_token: config?.access_token || "",
      client_id: config?.client_id || "",
      keycloakURL: config?.keycloakURL || "",
      locale: config?.locale || "en",
    };
  }


  public onLoading = (loading: boolean, callback = (): void => { }): void => {
    this.loading = loading;
    callback();
  };

  public onResponse = (callback = (): void => { }): void => {
    callback();
  };

  public onError = (error: Error, callback = (): void => { }): void => {
    this.error = error.message;
    console.error(error);
    callback();
  };

  protected async fetch<T>(input: RequestInfo, init?: RequestInit, timeoutMs = 30000): Promise<T> {
    // Add default headers
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeoutMs);

    const defaultProperty: RequestInit = {
      ...init,
      signal: controller.signal,
      headers: {
        "Content-Type": "application/json",
        "Accept-Language": this.config.locale || "en",
        Authorization: this.config.access_token
          ? `Bearer ${this.config.access_token}`
          : "",
        ...init?.headers,
      },
    };

    try {
      const response = await fetch(input, defaultProperty);
      clearTimeout(timeoutId);

      if (response.status !== 200) {
        if (response.status === 401) {
          throw new Error("401 Unauthorized");
        } else if (response.status >= 400) {
          createNotify(response);
          throw new Error(response.statusText + response.status);
        }
      }

      const contentType = response.headers.get("content-type");
      if (contentType && contentType.includes("application/json")) {
        return await response.json() as T;
      } else {
        return await response.text() as unknown as T;
      }
    } catch (error) {
      clearTimeout(timeoutId);
      const err = error instanceof Error ? error : new Error(String(error));
      if (err.name === "AbortError") {
        err.message = "Request timeout";
      }
      this.onError(err);
      throw err;
    }
  }
}
