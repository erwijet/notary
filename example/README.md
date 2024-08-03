# Notary Demo Site

This is an example project of how a `Notary` server can be used to authenticate a app using [react](https://react.dev) + [vite](https://vite.dev) + [tanstack router](https://tanstack.com/router/latest).

Preview: https://notary-demo.holewinski.dev

### Key Points

- Configuring notary client: [`src/notary.ts`](src/notary.ts)
- Beginning the auth flow: [`src/routes/login.tsx`](src/routes/login.tsx)
- Handling the token response: [`src/routes/callback.tsx`](src/routes/callback.tsx)
- Protecting routes / fetching user info: [`src/routes/_auth.tsx`](src/routes/_auth.tsx)

### Token Persistence

This demo project persists the notary token just by writing to localstorage, but you could use something like [zustand](https://github.com/pmndrs/zustand) for a more scalable approach.
