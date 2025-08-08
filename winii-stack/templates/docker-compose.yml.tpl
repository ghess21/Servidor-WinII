version: '3.8'
services:
{{ if eq (getenv `ENABLE_REDIS`) "true" }}
  redis:
    image: redis:7
    ports:
      - "{{ getenv `REDIS_PORT` }}:6379"
{{ end }}

{{ if eq (getenv `ENABLE_POSTGRES`) "true" }}
  postgres:
    image: postgres:16
    environment:
      POSTGRES_PASSWORD: mysecret
    ports:
      - "{{ getenv `POSTGRES_PORT` }}:5432"
{{ end }}

{{ if eq (getenv `ENABLE_N8N`) "true" }}
  n8n:
    image: n8nio/n8n
    ports:
      - "{{ getenv `N8N_PORT` }}:5678"
{{ end }}

