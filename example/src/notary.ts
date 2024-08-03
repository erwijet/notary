import { createNotary } from "@erwijet/notary";

export const notary = createNotary({
  client: "notary-demo",
  url: "https://notary.holewinski.dev",
  callback: import.meta.env.VITE_HOST + "/callback",
  key: import.meta.env.VITE_NOTARY_KEY,
});
