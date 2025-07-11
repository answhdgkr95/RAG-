# Code Guideline Document

---

## 1. Project Overview

This project implements a Retrieval-Augmented Generation (RAG) document search web service for industrial field manuals, drawings, and contracts. The system enables users to upload documents (PDF, TXT, DOCX), ask natural language questions, and receive evidence-based answers using advanced AI models. The architecture is built on a cloud-native, containerized stack:

- **Frontend:** React with Next.js (SSR), Tailwind CSS
- **Backend:** Python FastAPI microservices
- **Datastores:** PostgreSQL (metadata), Milvus/Pinecone (vector), AWS S3 (documents)
- **Authentication:** OAuth2.0 + JWT
- **Deployment:** Docker, Kubernetes (EKS), GitHub Actions CI/CD
- **Monitoring:** Prometheus, Grafana, Sentry
- **Caching:** Redis

Key architectural decisions include strict domain-based modularization, API-driven integration, and asynchronous processing for heavy tasks.

---

## 2. Core Principles

1. **Single Responsibility:** Every file, function, and class MUST have a single, clear responsibility.
2. **Explicitness:** All data flows, dependencies, and side effects MUST be explicit and discoverable.
3. **Fail Fast & Log Clearly:** All errors MUST be handled early with actionable logging.
4. **Security by Default:** Sensitive operations MUST enforce authentication, authorization, and data protection.
5. **Testability:** All business logic MUST be unit-testable and covered by automated tests.

---

## 3. Language-Specific Guidelines

### 3.1. Frontend (React + Next.js + Tailwind CSS)

#### File Organization and Directory Structure

- MUST follow domain-first structure:
  ```
  frontend/
    components/
    pages/
    hooks/
    styles/
  ```
- Each component MUST reside in its own file.
- Shared hooks and utility functions go under `hooks/` and `utils/`.

#### Import/Dependency Management

- MUST use absolute imports (via `jsconfig.json` or `tsconfig.json` paths).
- MUST import only what is needed (no wildcard imports).
- MUST keep third-party imports at the top, followed by local imports.

#### Error Handling Patterns

- MUST handle all async errors using `try/catch` in async functions.
- MUST display user-friendly error messages; never expose stack traces.
- MUST log errors to Sentry using the provided client.

```javascript
// MUST: Proper error handling in async data fetching
import { useState } from "react";
import * as Sentry from "@sentry/browser";

export async function fetchData(url) {
  try {
    const res = await fetch(url);
    if (!res.ok) throw new Error("Failed to fetch");
    return await res.json();
  } catch (error) {
    Sentry.captureException(error);
    throw error;
  }
}
```

---

### 3.2. Backend (Python 3.11 + FastAPI)

#### File Organization and Directory Structure

- MUST follow:
  ```
  backend/app/
    api/
    domain/
      documents/
      search/
      users/
    core/
    services/
    models/
  ```
- Each domain submodule MUST encapsulate its logic and data models.

#### Import/Dependency Management

- MUST use absolute imports within the project.
- MUST declare all dependencies in `pyproject.toml` or `requirements.txt`.
- MUST NOT import unused modules.

#### Error Handling Patterns

- MUST use FastAPI exception handlers for HTTP errors.
- MUST log all errors with structured logs (JSON, including trace IDs).
- MUST return standardized error responses.

```python
# MUST: Standardized error handler
from fastapi import Request, HTTPException
from fastapi.responses import JSONResponse
import logging

@app.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException):
    logging.error(f"{request.url} - {exc.detail}")
    return JSONResponse(
        status_code=exc.status_code,
        content={"error": exc.detail, "code": exc.status_code},
    )
```

---

## 4. Code Style Rules

### 4.1. MUST Follow

- **Consistent Naming:** Use `camelCase` for JS/TS variables/functions, `PascalCase` for React components, `snake_case` for Python.
  - *Rationale:* Increases readability and aligns with language conventions.

- **Type Safety:** Use TypeScript for all React code; use Pydantic models for FastAPI.
  - *Rationale:* Prevents runtime errors and improves maintainability.

- **Modularization:** Each module/file must encapsulate a single domain or feature.
  - *Rationale:* Simplifies code navigation and testing.

- **Explicit API Schemas:** All API endpoints must define request/response schemas.
  - *Rationale:* Enables auto-documentation and client generation.

- **Security Checks:** All endpoints must enforce JWT authentication and role-based authorization.
  - *Rationale:* Prevents unauthorized access and data leaks.

```typescript
// MUST: Type-safe React component
type DocumentProps = { title: string; page: number };

const DocumentCard: React.FC<DocumentProps> = ({ title, page }) => (
  <div>
    <h2>{title}</h2>
    <span>Page: {page}</span>
  </div>
);
```

```python
# MUST: Pydantic schema for FastAPI endpoint
from pydantic import BaseModel

class DocumentUploadRequest(BaseModel):
    filename: str
    size: int
    content_type: str
```

### 4.2. MUST NOT Do

- **No God Objects:** MUST NOT create files or classes with multiple, unrelated responsibilities.
- **No Inline SQL:** MUST NOT use raw SQL queries; always use SQLAlchemy ORM.
- **No Silent Failures:** MUST NOT swallow exceptions without logging and user feedback.
- **No Hardcoded Secrets:** MUST NOT embed secrets or credentials in code; use environment variables or secret managers.
- **No Direct State Mutation in React:** MUST NOT mutate state directly; always use state setters.

```javascript
// MUST NOT: Direct state mutation in React
state.value = 5; // Wrong

// MUST: Use setter
setState({ ...state, value: 5 }); // Correct
```

```python
# MUST NOT: Multiple responsibilities in one class
class DocumentManager:
    def upload(self): ...
    def parse(self): ...
    def search(self): ...
    def authorize(self): ...
# Split into separate domain modules instead.
```

---

## 5. Architecture Patterns

### 5.1. Component/Module Structure

- MUST organize code by domain (`documents`, `search`, `users`) both in frontend and backend.
- Shared logic (e.g., authentication, logging) goes in `core/` or `hooks/`.

### 5.2. Data Flow Patterns

- **Frontend:** Data fetching via SWR or React Query, using custom hooks per domain.
- **Backend:** Use dependency injection (FastAPI `Depends`) for services and repositories.
- All inter-service communication MUST be via REST (JSON) or gRPC (vector DB).

```typescript
// MUST: Custom hook for data fetching
import useSWR from 'swr';

function useDocuments() {
  const { data, error } = useSWR('/api/documents');
  return { data, error };
}
```

```python
# MUST: Dependency injection in FastAPI
from fastapi import Depends

def get_db():
    ...

@app.get("/documents")
def list_documents(db=Depends(get_db)):
    ...
```

### 5.3. State Management Conventions

- MUST use React Context for global state (e.g., user session), but keep business logic in hooks.
- MUST NOT use Redux or complex state libraries unless justified by scale.

### 5.4. API Design Standards

- MUST use RESTful conventions: nouns for resources, HTTP verbs for actions.
- MUST version APIs (e.g., `/api/v1/`).
- MUST provide OpenAPI docs (FastAPI auto-generated).
- MUST validate and sanitize all input data.
- MUST return standardized error objects.

```python
# MUST: Versioned API router
from fastapi import APIRouter

router = APIRouter(prefix="/api/v1/documents")
```

---

## Example Code Snippets

```typescript
// MUST: Domain-based React component organization
// frontend/components/documents/DocumentList.tsx
import { useDocuments } from '../../hooks/useDocuments';

export function DocumentList() {
  const { data, error } = useDocuments();
  if (error) return <div>Error loading documents</div>;
  return (
    <ul>
      {data?.map(doc => (
        <li key={doc.id}>{doc.title}</li>
      ))}
    </ul>
  );
}
// Clear separation of concerns: fetching logic in hook, rendering in component.
```

```typescript
// MUST NOT: Mixing unrelated logic in a single component
function App() {
  // fetch documents, handle auth, render UI, manage state all here (bad)
}
// This is not maintainable. Split into hooks and domain components.
```

```python
# MUST: Structured logging with trace ID
import logging

def log_with_trace(message, trace_id):
    logging.info({"message": message, "trace_id": trace_id})
```

```python
# MUST NOT: Silent exception swallowing
try:
    process()
except Exception:
    pass  # Bad: No logging, no feedback
```

---

## Quality Criteria

- All code MUST be modular, explicit, and testable.
- All APIs MUST be documented and validated.
- All errors MUST be logged and traceable.
- All sensitive operations MUST be secured by authentication and authorization.
- Code reviews MUST enforce these guidelines as acceptance criteria.

---

This document is the definitive coding standard for this project. All contributors MUST comply to ensure code quality, maintainability, and security.