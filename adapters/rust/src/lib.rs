use proto::*;
use proto::o_auth2_client::OAuth2Client;

pub mod proto {
    tonic::include_proto!("notary.proto");
}

pub enum NotaryError {
    Connect(tonic::transport::Error),
    Response(tonic::Status)
}

pub async fn get_oauth2_page<U: Into<String>>(uri: U, payload: GoogleOauth2AuthPageReq) -> Result<OauthPage, NotaryError> {
    let mut client = OAuth2Client::connect(uri.into()).await.map_err(|err| NotaryError::Connect(err))?;
    Ok(client.get_oauth2_page(payload).await.map_err(|status| NotaryError::Response(status))?.into_parts().1)
}