import { createFileRoute, Outlet, redirect } from "@tanstack/react-router";
import { notary } from "../notary";

export const Route = createFileRoute("/_auth")({
  beforeLoad: async () => {
    const token = localStorage.getItem("dev.holewinski.notary.token");
    if (!token) throw redirect({ to: "/login" });

    const payload = await notary.inspect(token);
    if (!payload.valid) throw redirect({ to: "/login" });

    return payload.claims;
  },
  component: () => <Outlet />,
});
