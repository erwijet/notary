import Config
import Dotenvy

source!([".env", System.get_env()])

config :notary, Notary.Repo,
  database: "notary",
  username: env!("POSTGRES_USERNAME", :string!),
  password: env!("POSTGRES_PASSWORD", :string!),
  hostname: env!("POSTGRES_HOSTNAME", :string!),
  port: env!("POSTGRES_PORT", :integer!)

##

config :notary,
  portal_passkey: env!("PORTAL_PASSKEY", :string!),
  hostname: env!("NOTARY_HOSTNAME", :string!)

##

config :joken,
  default_signer: env!("TOKEN_SECRET", :string!)
