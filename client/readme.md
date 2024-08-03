# Notary Client Bindings

Although RPC to a Notary server may be facilitated via regular HTTP calls, for added DX and typesaftey, you can use these official client bindings.

## Installation

```sh
$ npm install @erwijet/notary
```

## Usage

```ts
// src/shared/notary.ts
import { createNotary } from "@erwijet/notary";

export const notary = createNotary({
    url: "https://notary.example.com",
    client: "<client-name-as-configured-in-the-notary-portal>",
    key: "<associated-client-key>",
    callback: "http://localhost:8080/callback",
});
```

## Example

Check out the [example](../example) project for a demo app using [react](https://react.dev) + [vite](https://vite.dev) + [tanstack router](https://tanstack.com/router/latest) + [notary auth](https://github.com/erwijet/notary).
