import { defineConfig } from "vite";
import dns from "dns";

dns.setDefaultResultOrder("verbatim");

export default defineConfig({
    server: {
        hmr: {
            clientPort: process.env.CODESPACES ? 443 : undefined,
        },
    },
});

module.exports = {
    root: './', // Set your source folder as the root
    build: {
       outDir: './docs', // Set your desired output directory,
       emptyOutDir: true,
    }
 }