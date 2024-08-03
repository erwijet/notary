import { createFileRoute } from "@tanstack/react-router";
import { notary } from "../notary";

export const Route = createFileRoute("/login")({
  component,
});

function component() {
  async function onClick() {
    const { url } = await notary.authorize({ via: "google" });
    window.location.replace(url);
  }

  return <button onClick={onClick}>Sign in with Google</button>;
}
