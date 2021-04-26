import { walk } from "https://deno.land/std@0.84.0/fs/walk.ts"

for await (const entry of walk(".")) {
    console.log(entry.path);
}
