import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { useEffect } from "react";
import { z } from "zod";

export const Route = createFileRoute("/callback")({
  validateSearch: (search: Record<string, unknown>) => {
    return z.object({ token: z.string() }).parse(search);
  },
  component: () => {
    const { token } = Route.useSearch();
    const nav = useNavigate();

    useEffect(() => {
      localStorage.setItem("dev.holewinski.notary.token", token);
      nav({ to: "/profile" });
    }, [token]);

    return "loading...";
  },
});
