//! Shared utilities for the Snowflake frontend — used by the SQL API v2 handler.
//!
//! The Snowflake wire-protocol v1 (`/session/v1/login-request`, `/queries/v1/query-request`,
//! etc.) has been removed. Only the SQL API v2 (`/api/v2/statements`) is supported.

pub mod format;
pub mod handlers;
