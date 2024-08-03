import React from 'react'
import ReactDOM from 'react-dom/client'
import { routeTree } from "./routeTree.gen.ts";
import { createRouter, RouterProvider } from '@tanstack/react-router';

const router = createRouter({ routeTree });

declare module "@tanstack/react-router" {
  interface Registrar {
    router: typeof router
  }
}

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <RouterProvider router={router} />
  </React.StrictMode>,
)
