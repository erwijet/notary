/// <reference types="vite/client" />

interface ImportMetaEnv {
    readonly VITE_NOTARY_KEY: string;
    readonly VITE_HOST: string;
}

interface ImportMeta {
    readonly env: ImportMetaEnv;
}