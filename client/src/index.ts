import { z } from "zod";
import { userInfoSchema } from "./schemas";
export { createNotary, type Notary } from "./notary";
export type UserInfo = z.infer<typeof userInfoSchema>;
