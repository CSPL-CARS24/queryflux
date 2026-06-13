pub mod http;
pub mod sql_api;

use std::sync::Arc;

use axum::Router;
use queryflux_core::error::{QueryFluxError, Result};
use tracing::info;

use crate::state::AppState;
use crate::FrontendListenerTrait;

/// Snowflake SQL API v2 frontend (`/api/v2/statements`).
///
/// The Snowflake wire-protocol v1 (`/session/v1/login-request`, `/queries/v1/query-request`,
/// etc.) is not supported — it required process-local session storage which breaks under
/// multi-replica deployments. Clients should use the SQL API v2 with per-request JWT or
/// key-pair authentication instead.
pub struct SnowflakeFrontend {
    state: Arc<AppState>,
    port: u16,
}

impl SnowflakeFrontend {
    pub fn new(state: Arc<AppState>, port: u16) -> Self {
        Self { state, port }
    }

    pub fn router(&self) -> Router {
        sql_api::routes().with_state(self.state.clone())
    }
}

#[async_trait::async_trait]
impl FrontendListenerTrait for SnowflakeFrontend {
    async fn listen(&self) -> Result<()> {
        let addr: std::net::SocketAddr = format!("0.0.0.0:{}", self.port)
            .parse()
            .map_err(|e: std::net::AddrParseError| QueryFluxError::Other(e.into()))?;

        info!("Snowflake SQL API v2 frontend listening on {addr}");

        axum::serve(
            tokio::net::TcpListener::bind(addr)
                .await
                .map_err(|e| QueryFluxError::Other(e.into()))?,
            self.router(),
        )
        .await
        .map_err(|e| QueryFluxError::Other(e.into()))
    }
}
