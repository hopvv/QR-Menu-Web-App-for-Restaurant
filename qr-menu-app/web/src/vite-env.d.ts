/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_API_URL?: string;
  readonly CHOKIDAR_USEPOLLING?: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
