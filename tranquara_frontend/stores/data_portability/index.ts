import { Base } from "../base";

export interface ExportFile {
    version: number;
    exported_at: string;
    app: string;
    user: {
        username: string;
        display_name?: string;
    };
    data: {
        journals: any[];
        emotion_logs: any[];
        learned_slide_groups: any[];
        therapy_sessions: any[];
        homework_items: any[];
        user_information?: any;
        user_streak?: any;
    };
    counts: {
        journals: number;
        emotion_logs: number;
        learned_slide_groups: number;
        therapy_sessions: number;
        homework_items: number;
    };
}

export interface ImportResult {
    message: string;
    result: {
        imported: {
            journals: number;
            emotion_logs: number;
            learned_slide_groups: number;
            therapy_sessions: number;
            homework_items: number;
        };
        skipped: {
            journals: number;
            emotion_logs: number;
            learned_slide_groups: number;
            therapy_sessions: number;
            homework_items: number;
        };
        errors?: string[];
    };
}

export class DataPortability extends Base {
    /**
     * Export all user data as a JSON file
     */
    async exportData(): Promise<ExportFile> {
        return this.fetch<ExportFile>(`${this.config.base_url}/data/export`);
    }

    /**
     * Import user data from a Tranquara export JSON file
     */
    async importData(data: ExportFile): Promise<ImportResult> {
        return this.fetch<ImportResult>(`${this.config.base_url}/data/import`, {
            method: "POST",
            body: JSON.stringify(data),
        });
    }
}