import { createRootRoute, Outlet } from "@tanstack/react-router";

export const Route = createRootRoute({
    beforeLoad: () => {
        if (true) {
            return <h1>Login</h1>
        }
    },
    component: () => {
        return <Outlet />
    }
})