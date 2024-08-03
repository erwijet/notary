import { z } from "zod";
import { obj } from "@tsly/obj";

export const userInfoSchema = z
    .object({
        user_id: z.string(),
        given_name: z.string(),
        family_name: z.string(),
        fullname: z.string(),
        picture: z.string(),
        sub: z.string(),
    })
    .transform((it) =>
        obj(it)
            .with("givenName", it.given_name)
            .with("familyName", it.family_name)
            .with("userId", it.user_id)
            .with("email", it.sub)
            .dropKeys(["given_name", "family_name", "user_id", "sub"])
            .take(),
    );

export const inspectionResultSchema = z.discriminatedUnion("valid", [
    z.object({ valid: z.literal(false) }),
    z.object({ valid: z.literal(true), claims: userInfoSchema }),
]);

export const authorizationResultSchema = z.object({
    url: z.string().url(),
});
