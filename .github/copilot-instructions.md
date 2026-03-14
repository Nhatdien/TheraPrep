# Copilot Instructions for TheraPrep

## Project Overview
**TheraPrep** is an AI-assisted mental wellness platform for emotion journaling and therapy preparation. This is a **microservices monorepo** with three independent services.

## Architecture

### Services Structure
```
tranquara_frontend/      → Nuxt 3 mobile app (Capacitor iOS/Android)
tranquara_core_service/  → Go REST API backend
tranquara_ai_service/    → Python FastAPI AI service (LangChain + Qdrant)
```

### Tech Stack Summary
- **Frontend**: Nuxt 3 (SSR disabled) + Vue 3 + Capacitor + Pinia + Tailwind + Nuxt UI 3
- **Backend**: Golang + PostgreSQL + RabbitMQ + Keycloak
- **AI**: Python FastAPI + LangChain + OpenAI (GPT-4o-mini) + Qdrant (vector store)
- **Auth**: Keycloak Direct Grant Flow (Resource Owner Password Credentials) - realm: `tranquara_auth`

### Storage Architecture (Critical!)
**Heavy Data (Journals, Lessons)**:
- Local: SQLite via `@capacitor-community/sqlite` (iOS/Android native, Web via SQL.js)
- Encryption: Optional SQLite encryption for sensitive data
- Use for: Journal entries, lesson content, complex queries, high read/write load

**Simple Settings (Theme, Preferences)**:
- Local: Capacitor Preferences (key-value storage)
- Use for: Settings < 1KB, infrequent updates, simple data

**Secure Data (Tokens, PIN)**:
- Local: Capacitor SecureStorage (encrypted keychain/keystore)
- Use for: Keycloak tokens, PIN hash, biometric flags

**Cloud Sync**:
- PostgreSQL backend for all data (journals, lessons, settings)
- RabbitMQ for async sync operations

### Critical Architecture Patterns
1. **Hybrid Authentication**: Online auth via Keycloak Direct Grant, offline token persistence via SecureStorage
2. **Offline-First**: "Day One" journal style - full offline access via local SQLite database
3. **Async AI**: RabbitMQ queues (`ai_tasks`, `sync_data`) for background AI processing
4. **RAG-Enhanced Journaling**: AI generates follow-up questions using past journal context from Qdrant
5. **SPA Mode**: Nuxt SSR disabled (`ssr: false`) for Capacitor compatibility
6. **SQLite for Heavy Data**: Use `@capacitor-community/sqlite` for journals/lessons (NOT Capacitor Preferences)

## Development Workflows

### Frontend (`tranquara_frontend/`)
```bash
npm run dev                # Dev server at localhost:3000
npx cap run android        # Run on Android device/emulator
npm run build              # Production build
```

**Key Conventions**:
- Pinia stores: `stores/stores/**` (e.g., `user_journal.ts`, `auth_store.ts`, `chatlog.ts`)
- Auth services: `stores/auth/` — `AuthService` (Direct Grant) + `KeycloakService` (legacy, unused)
- SDK pattern: Singleton `TranquaraSDK` in `stores/tranquara_sdk.ts` wraps all API calls via mixin pattern
- SDK mixins compose: `Exercises`, `UserCompletedExercises`, `UserInformations`, `UserStreaks`, `Chatlogs`, `UserJournals`, `UserLearned`, `Auth`, `AIService`
- Auth: `AuthService` singleton handles Direct Grant login, token storage via `capacitor-secure-storage-plugin`
- Token refresh: Auto-refresh every 60s in `plugins/01.auth.client.ts`
- SQLite services: `services/sqlite/` — `sqlite_service.ts`, `journals_repository.ts`, `learned_repository.ts`, `templates_repository.ts`, `schema.ts`
- Sync services: `services/sync/` — `sync_service.ts`, `sync_queue.ts`, `network_monitor.ts`
- Storage utils: `utils/secure-storage.ts` (encrypted tokens) + `utils/storage.ts` (Capacitor Preferences wrapper)

**Plugin Load Order** (numbered, sequential):
1. `00.jeep-sqlite.client.ts` — Loads jeep-sqlite custom element for web platform
2. `01.auth.client.ts` — Initializes auth state from stored tokens, sets up token refresh interval
3. `02.database.client.ts` — Initializes SQLite database after auth is ready
4. `03.tranquaraSDK.client.ts` — Configures SDK with tokens, watches auth state changes
5. `04.background_sync.client.ts` — Sets up bi-directional sync on app resume / network change
6. `echarts.client.ts` — ECharts charting library setup

### Backend (`tranquara_core_service/`)
```bash
make run                   # Start Go server (port 4000)
# DB migrations in migrations/ folder
```

**Key Conventions**:
- RabbitMQ setup: `internal/pubsub/` - queues defined in `pubsub_helper.go`
- Data models: `internal/data/` - PostgreSQL repository pattern
- Auth: JWT validation via `publicKey.pem` from Keycloak

### AI Service (`tranquara_ai_service/`)
```bash
python main.py             # FastAPI (port 8000) + RabbitMQ consumer
# RabbitMQ consumer starts in lifespan context manager
```

**Key Conventions**:
- AI processor: `service/ai_service_processor.py` — LangChain + OpenAI (GPT-4o-mini) + Qdrant RAG
- REST endpoint: `POST /api/analyze-journal` — generates follow-up questions for journal entries
- RabbitMQ consumer: `ai_tasks` queue — handles `journal.index` and `journal.delete` events
- Vector store: Qdrant stores journal entries for semantic search (RAG retrieval of past journals)
- Prompts: `service/prompts.py` + `service/system_prompt.md`

## Important File Locations

### Documentation (ALWAYS CHECK FIRST)
```
feature-design/README.md                    → Architecture overview, feature navigation
feature-design/01. User register/           → Auth flows, Keycloak setup
feature-design/02. Jounral Feature/         → Core journaling feature
feature-design/03. Micro learning/          → Micro learning lessons
feature-design/06. User profile and Settings/ → User profile & settings
feature-design/07. Progress/               → Progress tracking & metrics
feature-design/00-DATABASE/                 → Complete database schema
feature-design/00-TEMPLATES/               → Document templates
```

**Feature Docs Structure** (standardized):
- `00-OVERVIEW.md` - Feature summary
- `01-*-FLOW.md` - User flows and interactions
- `02-TECHNICAL-SPEC.md` - Implementation details
- `03-DATA-MODELS.md` - Database models

### Code Entry Points
```
tranquara_frontend/app.vue                  → Root component (UApp + NuxtLayout + NuxtPage)
tranquara_frontend/nuxt.config.ts           → Nuxt config (SSR disabled!)
tranquara_frontend/plugins/01.auth.client.ts → Auth init + token refresh
tranquara_frontend/plugins/03.tranquaraSDK.client.ts → SDK config + auth state watcher
tranquara_core_service/cmd/api/main.go      → Go server entry
tranquara_ai_service/main.py                → FastAPI + RabbitMQ consumer
```

## Critical Patterns to Follow

### 1. State Management (Pinia)
- All stores in `stores/stores/**`
- Use `TranquaraSDK.getInstance()` for API calls (never direct fetch)
- Store pattern: `defineStore("store_name", { state, actions })`

### 2. Authentication Flow
```typescript
// Direct Grant Flow — AuthService handles login via Keycloak token endpoint
// Tokens stored in Capacitor SecureStorage, loaded on app start

// Plugin 01.auth.client.ts initializes auth state:
const authStore = useAuthStore();
await authStore.initialize(); // loads tokens from SecureStorage

// Plugin 03.tranquaraSDK.client.ts configures SDK:
if (authStore.isAuthenticated) {
  const token = await AuthService.getAccessToken();
  tranquaraSDK.config.access_token = token;
  tranquaraSDK.config.current_username = user.preferred_username || "";
}
```

### 3. Offline Data
- **Online**: Keycloak token required for API calls
- **Offline - Heavy Data**: SQLite via `@capacitor-community/sqlite` for journals, lessons, chat logs
- **Offline - Settings**: Capacitor Preferences for theme, language, simple preferences
- **Offline - Secure**: Capacitor SecureStorage for tokens, PIN
- **Sync**: RabbitMQ `sync_data` queue handles background sync when online

**Storage Decision Matrix**:
- Large data (>1MB) → SQLite
- Complex queries → SQLite  
- High read/write load → SQLite
- Simple key-value (<1KB) → Capacitor Preferences
- Sensitive tokens/PIN → Capacitor SecureStorage

### 4. AI Integration
- User writes journal → Frontend calls `POST /api/analyze-journal` → AI generates follow-up question
- AI uses RAG: retrieves past journals from Qdrant for personalized, pattern-aware questions
- RabbitMQ `ai_tasks` queue: `journal.index` (index new/updated journal in Qdrant) + `journal.delete` (remove from Qdrant)
- Journal entries stored in Qdrant for semantic search by user_id

## Common Tasks

### Adding a New API Endpoint
1. **Go Backend**: Add route in `cmd/api/router.go` + handler in dedicated file (e.g., `cmd/api/user_journal.go`)
2. **Frontend SDK**: Add method to relevant mixin in `stores/` (e.g., `stores/user_journal/index.ts`) using Base class fetch
3. **Pinia Store**: Call SDK method from store action in `stores/stores/`

### Working with Feature Docs
1. Check `feature-design/README.md` for feature navigation
2. Read relevant `00-OVERVIEW.md` for context
3. Check `03-DATA-MODELS.md` for database schema
4. **ALWAYS update** technical specs when tech stack changes
5. **Add reference links** to official documentation in implementation guides:
   - Link to RFCs for protocols (OAuth, WebSocket, JWT, etc.)
   - Include official framework/library documentation
   - Add security best practice guides (OWASP, vendor docs)
   - Reference API documentation for third-party services
   - Include validation tools (JWT.io, OAuth playground, etc.)

### Creating Implementation Guides
When writing implementation documentation:
1. **Add Quick Reference Section** with core specifications and standards
2. **Include inline documentation links** in implementation steps:
   - Every major technology should link to official docs
   - Protocol implementations should reference RFCs
   - Security-sensitive code should link to OWASP guidelines
   - Third-party services should link to their API docs
3. **Organize external references** by category at the end:
   - Authentication & Security
   - Framework/Library Documentation
   - Platform-Specific Guides (iOS, Android)
   - Best Practices & Standards
4. **Examples of good documentation links**:
   - OAuth 2.0 → [RFC 6749](https://datatracker.ietf.org/doc/html/rfc6749)
   - Keycloak → [Official Documentation](https://www.keycloak.org/documentation)
   - OWASP → [Security Guides](https://owasp.org/)
   - Capacitor → [Plugin API Reference](https://capacitorjs.com/docs)
5. **Use the template**: `feature-design/00-TEMPLATES/IMPLEMENTATION-TEMPLATE.md` includes placeholders for reference links

### Mobile Build
```bash
# Sync web assets to native projects
npx cap sync

# Run on Android
npx cap run android

# Run on iOS (macOS only)
npx cap run ios
```

## Anti-Patterns (DO NOT)
❌ Enable SSR in Nuxt config (breaks Capacitor)  
❌ Direct fetch calls (always use TranquaraSDK)  
❌ Hardcode Keycloak URLs (use config)  
❌ Ignore offline scenarios in UI  
❌ Skip checking `feature-design/` before implementing features  
❌ Use Capacitor Preferences for large data (use SQLite instead)  
❌ Use SQLite for simple settings (use Capacitor Preferences instead)  

## When Stuck
1. Check `feature-design/README.md` for architectural context
2. Search for similar patterns in existing code
3. Verify Keycloak token is valid (check browser DevTools)
4. Check RabbitMQ queues are running (Docker logs)
5. Review relevant `02-TECHNICAL-SPEC.md` in feature-design/
6. **Validate implementation against official docs** - check reference links in implementation guides

## Documentation Standards

### Implementation Guide Requirements
Every implementation guide MUST include:
1. **Quick Reference Section** with:
   - Core specifications (RFCs, W3C standards)
   - Official framework/library documentation
   - Security best practices (OWASP, vendor guides)
   - Platform-specific references (iOS, Android)
   - Testing/validation tools

2. **Inline Documentation Links** in implementation steps:
   - Link to official docs for technologies used
   - Reference RFCs for protocols (OAuth, JWT, WebSocket, etc.)
   - Include security guides for sensitive operations
   - Add API references for third-party integrations

3. **External References Section** organized by:
   - Authentication & Security
   - Framework/Library Docs
   - Platform Guides
   - Standards & Best Practices

### Code Review Checklist for Documentation
When reviewing implementation guides, verify:
- [ ] Quick Reference section exists with relevant links
- [ ] Each major technology has official documentation link
- [ ] Protocol implementations reference appropriate RFCs
- [ ] Security-sensitive features link to OWASP guidelines
- [ ] Third-party services link to current API documentation
- [ ] Links are to official/authoritative sources (not blog posts)
- [ ] External References section is complete and organized

## Key Dependencies
- **Nuxt**: 3.13.2 (SPA mode only)
- **Capacitor**: 7.4.2 (iOS/Android)
- **@capacitor-community/sqlite**: ^7.0.2 (local database for journals/lessons)
- **@capacitor/preferences**: ^7.0.2 (simple key-value storage)
- **@nuxt/ui**: ^3.1.3 (UI component library)
- **Keycloak-js**: ^26.0.5 (legacy — Direct Grant flow uses direct HTTP, not keycloak-js)
- **capacitor-secure-storage-plugin**: ^0.12.0 (encrypted token storage)
- **Tiptap**: ^2.25.0 (rich text editor for journaling)
- **ECharts / vue-echarts**: ^5.6.0 / ^7.0.3 (charting for progress)
- **LangChain + langchain-openai**: Latest (Python AI service)
- **Qdrant**: Vector database for RAG
