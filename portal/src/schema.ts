import { z } from "zod";

export const clientSchema = z.object({
  id: z.number(),
  key: z.string(),
  name: z.string(),
  google_oauth_client_id: z.string().nullable(),
});

export type Client = z.infer<typeof clientSchema>;
