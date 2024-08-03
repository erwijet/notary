import { z } from "zod";

export function createZodHttpTransport(base: string) {
    function joinWithBase(path: string) {
        if (path.startsWith("/") && base.endsWith("/")) {
            return base + path.slice(1);
        }

        if (!path.startsWith("/") && base.endsWith("/")) {
            return base + "/" + path;
        }

        return base + path;
    }

    return {
        get<Z extends z.ZodSchema>(path: string, validator: Z): Promise<z.infer<Z>> {
            return fetch(joinWithBase(path))
                .then((res) => res.json())
                .then((data) => validator.parse(data));
        },
        post<Z extends z.ZodSchema>(path: string, body: unknown, validator: Z): Promise<z.infer<Z>> {
            return fetch(joinWithBase(path), {
                method: "POST",
                headers: {
                    "content-type": "application/json",
                },
                body: JSON.stringify(body),
            })
                .then((res) => res.json())
                .then((data) => validator.parse(data));
        },
    };
}
