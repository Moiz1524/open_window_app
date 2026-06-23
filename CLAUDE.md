# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

| Task | Command |
|------|---------|
| Dev server | `bin/dev` |
| First-time setup | `bin/setup` |
| Run all tests | `bundle exec rspec` |
| Run single spec | `bundle exec rspec spec/models/foo_spec.rb:42` |
| Run system specs | `bundle exec rspec spec/system` |
| Lint | `bin/rubocop` |
| Lint + autofix | `bin/rubocop -A` |
| Security scan (gems) | `bin/bundler-audit` |
| Security scan (code) | `bin/brakeman --quiet` |
| Full CI pipeline | `bin/ci` |
| Background jobs | `bin/jobs` |

## Architecture

Rails 8.1 app with PostgreSQL. Background jobs use **Sidekiq** (requires Redis). Action Cable uses the `async` adapter.

**Frontend**: No build step. Importmap for ES modules, Propshaft as asset pipeline, Turbo + Stimulus (Hotwire) for interactivity.

**Deployment**: Kamal (Docker-based). Secrets in `.kamal/secrets`; `RAILS_MASTER_KEY` is injected at deploy time. Run the Sidekiq worker separately with `bin/jobs`.

## Linting

`.rubocop.yml` inherits both `rubocop-rails-omakase` and `rubocop-shopify`. NewCops are enabled, so new Rubocop cops apply automatically on upgrade.

## CI

GitHub Actions (`.github/workflows/ci.yml`) runs on push/PR to main: Brakeman → bundler-audit → importmap audit → Rubocop → test suite.
